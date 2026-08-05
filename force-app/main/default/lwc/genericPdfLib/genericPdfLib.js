/**
 * Pure JavaScript PDF merger. No external dependencies.
 * Combines multiple PDF documents into a single PDF.
 *
 * Public API:
 *   mergePdfs(pdfBytesArray) -> Uint8Array
**/

function latin1Decode(bytes) {
    return new TextDecoder('latin1').decode(bytes);
}

function latin1Encode(str) {
    const bytes = new Uint8Array(str.length);
    for (let i = 0; i < str.length; i++) {
        bytes[i] = str.charCodeAt(i) & 0xff;
    }
    return bytes;
}

function concat(arrays) {
    let total = 0;
    for (const a of arrays) {
        total += a.length;
    }
    const result = new Uint8Array(total);
    let off = 0;
    for (const a of arrays) {
        result.set(a, off);
        off += a.length;
    }
    return result;
}

function extractDict(str, pos) {
    const start = str.indexOf('<<', pos);
    if (start === -1) {
        return '';
    }
    let depth = 0;
    let i = start;
    while (i < str.length - 1) {
        if (str[i] === '<' && str[i + 1] === '<') {
            depth++;
            i += 2;
        } else if (str[i] === '>' && str[i + 1] === '>') {
            depth--;
            if (depth === 0) {
                return str.substring(start, i + 2);
            }
            i += 2;
        } else {
            i++;
        }
    }
    return str.substring(start);
}

function renumberRefs(text, numMap) {
    return text.replace(/\b(\d+)(\s+0\s+R)\b/g, (match, numStr, rest) => {
        const num = parseInt(numStr, 10);
        return numMap.has(num) ? numMap.get(num) + rest : match;
    });
}

function parsePdf(bytes) {
    if (!(bytes instanceof Uint8Array)) {
        bytes = new Uint8Array(bytes);
    }
    const str = latin1Decode(bytes);

    if (!str.startsWith('%PDF-')) {
        throw new Error('Not a valid PDF file');
    }

    const objects = new Map();
    const objRe = /\b(\d+)\s+0\s+obj\b/g;
    let match;

    while ((match = objRe.exec(str)) !== null) {
        const num = parseInt(match[1], 10);
        const headerEnd = match.index + match[0].length;
        const endIdx = str.indexOf('endobj', headerEnd);
        if (endIdx === -1) {
            continue;
        }

        const body = str.substring(headerEnd, endIdx);
        const streamIndex = body.indexOf('stream');
        let dictText;
        let streamBytes = null;

        if (streamIndex !== -1 && body.indexOf('endstream') > streamIndex) {
            dictText = body.substring(0, streamIndex);

            let dataStart = headerEnd + streamIndex + 6;
            if (bytes[dataStart] === 0x0d) {
                dataStart++;
            }
            if (bytes[dataStart] === 0x0a) {
                dataStart++;
            }

            const lenMatch = dictText.match(/\/Length\s+(\d+)(?!\s+\d+\s+R)/);
            if (lenMatch) {
                const len = parseInt(lenMatch[1], 10);
                streamBytes = bytes.slice(dataStart, dataStart + len);
            } else {
                const endStreamIndex = str.indexOf('endstream', dataStart);
                let dataEnd = endStreamIndex;
                if (bytes[dataEnd - 1] === 0x0a) {
                    dataEnd--;
                }
                if (bytes[dataEnd - 1] === 0x0d) {
                    dataEnd--;
                }
                streamBytes = bytes.slice(dataStart, dataEnd);
            }
        } else {
            dictText = body;
        }

        objects.set(num, { num, dictText, streamBytes });
    }

    let rootNum = null;
    const startxrefIdx = str.lastIndexOf('startxref');
    if (startxrefIdx !== -1) {
        const xrefOffsetMatch = str.substring(startxrefIdx + 9).match(/\s*(\d+)/);
        if (xrefOffsetMatch) {
            const xrefOffset = parseInt(xrefOffsetMatch[1], 10);
            const atOffset = str.substring(xrefOffset, xrefOffset + 10).trimStart();

            if (atOffset.startsWith('xref')) {
                const trailerIdx = str.indexOf('trailer', xrefOffset);
                if (trailerIdx !== -1) {
                    const trailerDict = extractDict(str, trailerIdx);
                    if (trailerDict.includes('/Encrypt')) {
                        throw new Error('Encrypted PDFs cannot be merged');
                    }
                    const rootMatch = trailerDict.match(/\/Root\s+(\d+)\s+0\s+R/);
                    if (rootMatch) {
                        rootNum = parseInt(rootMatch[1], 10);
                    }
                }
            } else {
                const objMatch = str.substring(xrefOffset).match(/(\d+)\s+0\s+obj/);
                if (objMatch) {
                    const dictStart = xrefOffset + objMatch.index + objMatch[0].length;
                    const streamIdx = str.indexOf('stream', dictStart);
                    const endIdx = str.indexOf('endobj', dictStart);
                    const dictEnd = (streamIdx !== -1 && streamIdx < endIdx) ? streamIdx : endIdx;
                    const dictText = str.substring(dictStart, dictEnd);
                    if (dictText.includes('/Encrypt')) {
                        throw new Error('Encrypted PDFs cannot be merged');
                    }
                    const rootMatch = dictText.match(/\/Root\s+(\d+)\s+0\s+R/);
                    if (rootMatch) {
                        rootNum = parseInt(rootMatch[1], 10);
                    }
                }
            }
        }
    }

    if (rootNum === null) {
        const trailerIndex = str.lastIndexOf('trailer');
        if (trailerIndex !== -1) {
            const trailerDict = extractDict(str, trailerIndex);
            if (trailerDict.includes('/Encrypt')) {
                throw new Error('Encrypted PDFs cannot be merged');
            }
            const rootMatch = trailerDict.match(/\/Root\s+(\d+)\s+0\s+R/);
            if (rootMatch) {
                rootNum = parseInt(rootMatch[1], 10);
            }
        }
    }

    if (rootNum === null) {
        for (const [, obj] of objects) {
            if (obj.dictText.includes('/Root')) {
                const rootMatch = obj.dictText.match(/\/Root\s+(\d+)\s+0\s+R/);
                if (rootMatch) {
                    rootNum = parseInt(rootMatch[1], 10);
                    break;
                }
            }
        }
    }

    if (rootNum === null) {
        throw new Error('PDF root catalog not found');
    }

    const catalog = objects.get(rootNum);
    if (!catalog) {
        throw new Error('Catalog object ' + rootNum + ' missing');
    }
    const pagesMatch = catalog.dictText.match(/\/Pages\s+(\d+)\s+0\s+R/);
    if (!pagesMatch) {
        throw new Error('/Pages reference not found in catalog');
    }

    function walkPages(objNum, visited) {
        if (visited.has(objNum)) {
            return [];
        }
        visited.add(objNum);
        const obj = objects.get(objNum);
        if (!obj) {
            return [];
        }

        const kidsMatch = obj.dictText.match(/\/Kids\s*\[([\s\S]*?)\]/);
        if (kidsMatch) {
            const refs = [...kidsMatch[1].matchAll(/(\d+)\s+0\s+R/g)];
            const pages = [];
            for (const ref of refs) {
                pages.push(...walkPages(parseInt(ref[1], 10), visited));
            }
            return pages;
        }
        return [objNum];
    }

    const pageNums = walkPages(parseInt(pagesMatch[1], 10), new Set());

    return { objects, rootNum, pageNums };
}

function resolveMediaBox(objects, pageNum) {
    const visited = new Set();
    let num = pageNum;
    while (num != null && !visited.has(num)) {
        visited.add(num);
        const obj = objects.get(num);
        if (!obj) {
            break;
        }
        const mediaBoxMatch = obj.dictText.match(/\/MediaBox\s*\[([^\]]+)\]/);
        if (mediaBoxMatch) {
            return mediaBoxMatch[0];
        }
        const parentMatch = obj.dictText.match(/\/Parent\s+(\d+)\s+0\s+R/);
        num = parentMatch ? parseInt(parentMatch[1], 10) : null;
    }
    return '/MediaBox [0 0 612 792]';
}

function writeObject(num, dictText, streamBytes) {
    const header = num + ' 0 obj';
    if (streamBytes) {
        let dict = dictText;
        if (/\/Length\s+\d+(?!\s+\d+\s+R)/.test(dict)) {
            dict = dict.replace(/\/Length\s+\d+(?!\s+\d+\s+R)/, '/Length ' + streamBytes.length);
        }
        const pre = latin1Encode(header + dict + 'stream\n');
        const post = latin1Encode('\nendstream\nendobj\n');
        return concat([pre, streamBytes, post]);
    }
    return latin1Encode(header + dictText + 'endobj\n');
}

export function mergePdfs(pdfBytesArray) {
    if (!pdfBytesArray || pdfBytesArray.length === 0) {
        throw new Error('No PDFs provided');
    }
    if (pdfBytesArray.length === 1) {
        const bytes = pdfBytesArray[0];
        return bytes instanceof Uint8Array ? bytes : new Uint8Array(bytes);
    }

    const parsed = pdfBytesArray.map((bytes) => parsePdf(bytes));

    for (const pdf of parsed) {
        for (const pageNum of pdf.pageNums) {
            const obj = pdf.objects.get(pageNum);
            if (obj && !obj.dictText.includes('/MediaBox')) {
                const mediaBox = resolveMediaBox(pdf.objects, pageNum);
                obj.dictText = obj.dictText.replace(/<</, '<< ' + mediaBox);
            }
        }
    }

    let nextNum = 1;
    const allObjs = [];
    const allPages = [];

    for (const pdf of parsed) {
        const numMap = new Map();
        for (const oldNum of pdf.objects.keys()) {
            numMap.set(oldNum, nextNum++);
        }

        for (const [oldNum, obj] of pdf.objects) {
            const newNum = numMap.get(oldNum);
            const isPage = pdf.pageNums.includes(oldNum);
            allObjs.push({
                newNum,
                dictText: renumberRefs(obj.dictText, numMap),
                streamBytes: obj.streamBytes,
                isPage
            });
        }

        for (const pageNum of pdf.pageNums) {
            allPages.push(numMap.get(pageNum));
        }
    }

    const newPagesNum = nextNum++;
    const newCatalogNum = nextNum++;

    for (const obj of allObjs) {
        if (obj.isPage) {
            obj.dictText = obj.dictText.replace(/\/Parent\s+\d+\s+0\s+R/, '/Parent ' + newPagesNum + ' 0 R');
        }
    }

    const parts = [];
    const offsets = new Map();
    let offset = 0;

    const header = latin1Encode('%PDF-1.7\n%\xe2\xe3\xcf\xd3\n');
    parts.push(header);
    offset += header.length;

    for (const obj of allObjs) {
        offsets.set(obj.newNum, offset);
        const bytes = writeObject(obj.newNum, obj.dictText, obj.streamBytes);
        parts.push(bytes);
        offset += bytes.length;
    }

    const kids = allPages.map((num) => num + ' 0 R').join(' ');
    offsets.set(newPagesNum, offset);
    const pagesBytes = latin1Encode(
        newPagesNum + ' 0 obj\n<< /Type /Pages /Kids [' + kids + '] /Count ' + allPages.length + ' >>\nendobj\n'
    );
    parts.push(pagesBytes);
    offset += pagesBytes.length;

    offsets.set(newCatalogNum, offset);
    const catalogBytes = latin1Encode(
        newCatalogNum + ' 0 obj\n<< /Type /Catalog /Pages ' + newPagesNum + ' 0 R >>\nendobj\n'
    );
    parts.push(catalogBytes);
    offset += catalogBytes.length;

    const xrefStart = offset;
    let xref = 'xref\n0 ' + nextNum + '\n';
    xref += '0000000000 65535 f \n';

    for (let i = 1; i < nextNum; i++) {
        const objOffset = offsets.get(i);
        xref += String(objOffset).padStart(10, '0') + ' 00000 n \n';
    }

    xref +=
        'trailer\n<< /Size ' + nextNum + ' /Root ' + newCatalogNum + ' 0 R >>\n' +
        'startxref\n' + xrefStart + '\n%%EOF\n';

    parts.push(latin1Encode(xref));

    return concat(parts);
}
