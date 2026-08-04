const UTF8_FLAG = 0x0800;

const CRC_TABLE = (() => {
    const table = new Uint32Array(256);
    for (let index = 0; index < 256; index++) {
        let value = index;
        for (let bit = 0; bit < 8; bit++) {
            value = value & 1 ? 0xedb88320 ^ (value >>> 1) : value >>> 1;
        }
        table[index] = value;
    }
    return table;
})();

function crc32(bytes) {
    let crc = 0xffffffff;
    for (const byte of bytes) {
        crc = CRC_TABLE[(crc ^ byte) & 0xff] ^ (crc >>> 8);
    }
    return (crc ^ 0xffffffff) >>> 0;
}

function concat(arrays) {
    const totalLength = arrays.reduce((total, array) => total + array.length, 0);
    const result = new Uint8Array(totalLength);
    let offset = 0;
    for (const array of arrays) {
        result.set(array, offset);
        offset += array.length;
    }
    return result;
}

function asBytes(value) {
    if (value instanceof Uint8Array) {
        return value;
    }
    if (value instanceof ArrayBuffer) {
        return new Uint8Array(value);
    }
    throw new TypeError('ZIP entry bytes must be a Uint8Array or ArrayBuffer.');
}

function buildLocalEntry(nameBytes, fileBytes) {
    const checksum = crc32(fileBytes);
    const size = fileBytes.length;
    const header = new Uint8Array(30 + nameBytes.length);
    const view = new DataView(header.buffer);

    view.setUint32(0, 0x04034b50, true);
    view.setUint16(4, 20, true);
    view.setUint16(6, UTF8_FLAG, true);
    view.setUint16(8, 0, true);
    view.setUint16(10, 0, true);
    view.setUint16(12, 0, true);
    view.setUint32(14, checksum, true);
    view.setUint32(18, size, true);
    view.setUint32(22, size, true);
    view.setUint16(26, nameBytes.length, true);
    view.setUint16(28, 0, true);
    header.set(nameBytes, 30);

    return {
        bytes: concat([header, fileBytes]),
        checksum,
        size
    };
}

function buildCentralEntry(nameBytes, checksum, size, localOffset) {
    const entry = new Uint8Array(46 + nameBytes.length);
    const view = new DataView(entry.buffer);

    view.setUint32(0, 0x02014b50, true);
    view.setUint16(4, 20, true);
    view.setUint16(6, 20, true);
    view.setUint16(8, UTF8_FLAG, true);
    view.setUint16(10, 0, true);
    view.setUint16(12, 0, true);
    view.setUint16(14, 0, true);
    view.setUint32(16, checksum, true);
    view.setUint32(20, size, true);
    view.setUint32(24, size, true);
    view.setUint16(28, nameBytes.length, true);
    view.setUint16(30, 0, true);
    view.setUint16(32, 0, true);
    view.setUint16(34, 0, true);
    view.setUint16(36, 0, true);
    view.setUint32(38, 0, true);
    view.setUint32(42, localOffset, true);
    entry.set(nameBytes, 46);

    return entry;
}

function buildEndOfCentralDirectory(entryCount, centralSize, centralOffset) {
    const record = new Uint8Array(22);
    const view = new DataView(record.buffer);

    view.setUint32(0, 0x06054b50, true);
    view.setUint16(4, 0, true);
    view.setUint16(6, 0, true);
    view.setUint16(8, entryCount, true);
    view.setUint16(10, entryCount, true);
    view.setUint32(12, centralSize, true);
    view.setUint32(16, centralOffset, true);
    view.setUint16(20, 0, true);

    return record;
}

export function buildZip(entries) {
    if (!Array.isArray(entries) || entries.length === 0) {
        throw new Error('At least one ZIP entry is required.');
    }
    if (entries.length > 65535) {
        throw new Error('This ZIP writer supports at most 65,535 entries.');
    }

    const encoder = new TextEncoder();
    const localEntries = [];
    const centralEntries = [];
    let offset = 0;

    for (const entry of entries) {
        const nameBytes = encoder.encode(entry.name);
        const fileBytes = asBytes(entry.bytes);
        const local = buildLocalEntry(nameBytes, fileBytes);

        centralEntries.push(
            buildCentralEntry(nameBytes, local.checksum, local.size, offset)
        );
        localEntries.push(local.bytes);
        offset += local.bytes.length;
    }

    const centralDirectory = concat(centralEntries);
    const endRecord = buildEndOfCentralDirectory(
        entries.length,
        centralDirectory.length,
        offset
    );

    return concat([...localEntries, centralDirectory, endRecord]);
}
