import getFilePayloads from '@salesforce/apex/H8FilePdfZipHelper.getFilePayloads';

function splitStringValues(value) {
    return String(value || '')
        .split(/[\n,;]+/)
        .map((item) => item.trim())
        .filter((item) => item.length > 0);
}

export function normalizeStringArray(value) {
    if (Array.isArray(value)) {
        return value
            .map((item) => String(item || '').trim())
            .filter((item) => item.length > 0);
    }

    if (value === null || value === undefined || value === '') {
        return [];
    }

    return splitStringValues(value);
}

export function sanitizeFileName(value, fallback) {
    const sanitized = String(value || '')
        .replace(/[<>:"/\\|?*\u0000-\u001f]/g, '_')
        .replace(/[. ]+$/g, '')
        .trim();
    return sanitized || fallback;
}

export function ensureFileExtension(fileName, extensionWithoutDot) {
    const safeBaseName = sanitizeFileName(fileName, 'download');
    const normalizedExtension = String(extensionWithoutDot || '').replace(/^\./, '').trim();
    if (!normalizedExtension) {
        return safeBaseName;
    }

    const expectedExtension = `.${normalizedExtension.toLowerCase()}`;
    return safeBaseName.toLowerCase().endsWith(expectedExtension)
        ? safeBaseName
        : `${safeBaseName}${expectedExtension}`;
}

function decodeBase64ToBytes(base64Value) {
    const normalizedValue = String(base64Value || '');
    const binary = atob(normalizedValue);
    const bytes = new Uint8Array(binary.length);
    for (let index = 0; index < binary.length; index++) {
        bytes[index] = binary.charCodeAt(index);
    }
    return bytes;
}

function buildPayloadError(payload, fallbackName) {
    const requestedId = payload?.requestedId || fallbackName || 'file';
    return payload?.errorMessage
        ? `${requestedId}: ${payload.errorMessage}`
        : `Unable to download ${requestedId}.`;
}

export async function getResolvedFilePayloads(fileIds) {
    const normalizedIds = normalizeStringArray(fileIds);

    if (normalizedIds.length === 0) {
        return [];
    }

    const payloads = await getFilePayloads({
        fileIds: normalizedIds
    });

    if (!Array.isArray(payloads) || payloads.length !== normalizedIds.length) {
        throw new Error('File payload response was incomplete.');
    }

    return payloads.map((payload, index) => {
        const fallbackName = `file-${String(index + 1).padStart(2, '0')}`;
        if (payload?.errorMessage) {
            throw new Error(buildPayloadError(payload, fallbackName));
        }

        return {
            requestedId: payload?.requestedId,
            contentDocumentId: payload?.contentDocumentId,
            contentVersionId: payload?.contentVersionId,
            fileExtension: payload?.fileExtension,
            fileName: sanitizeFileName(
                payload?.fileName,
                payload?.fileName || fallbackName
            ),
            bytes: decodeBase64ToBytes(payload?.base64Data)
        };
    });
}

export function triggerBrowserDownload(fileBytes, fileName, mimeType) {
    const blob = new Blob([fileBytes], { type: mimeType });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = fileName;
    document.body.appendChild(anchor);
    anchor.click();
    document.body.removeChild(anchor);
    window.setTimeout(() => URL.revokeObjectURL(url), 0);
}
