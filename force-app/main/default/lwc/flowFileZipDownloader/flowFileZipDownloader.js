import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement } from 'lwc';
import { buildZip } from 'c/genericZipLib';
import {
    ensureFileExtension,
    getResolvedFilePayloads,
    normalizeStringArray,
    triggerBrowserDownload
} from 'c/flowFileActionLib';

export default class FlowFileZipDownloader extends LightningElement {
    @api fileIds;
    @api outputFileName = 'fileZip';
    @api buttonLabel = 'Download ZIP';
    @api variant = 'neutral';
    @api downloadComplete = false;
    @api errorMessage = '';

    isWorking = false;

    get normalizedFileIds() {
        return normalizeStringArray(this.fileIds);
    }

    get resolvedButtonLabel() {
        return this.buttonLabel || 'Download ZIP';
    }

    get isDisabled() {
        return this.isWorking || this.normalizedFileIds.length === 0;
    }

    async handleDownload() {
        this.downloadComplete = false;
        this.errorMessage = '';

        const fileIds = this.normalizedFileIds;
        if (fileIds.length === 0) {
            this.errorMessage = 'Add at least one ContentDocumentId or ContentVersionId.';
            this.showToast('Download ZIP', this.errorMessage, 'error');
            return;
        }

        this.isWorking = true;
        try {
            const resolvedFiles = await getResolvedFilePayloads(fileIds);
            const entries = resolvedFiles.map((file, index) => ({
                name: `${String(index + 1).padStart(2, '0')} - ${file.fileName}`,
                bytes: file.bytes
            }));

            const zipBytes = buildZip(entries);
            triggerBrowserDownload(
                zipBytes,
                ensureFileExtension(this.outputFileName || 'fileZip', 'zip'),
                'application/zip'
            );
            this.downloadComplete = true;
            this.showToast('Download ZIP', 'ZIP download started.', 'success');
        } catch (error) {
            this.errorMessage = error?.message || 'ZIP download failed.';
            this.showToast('Download ZIP', this.errorMessage, 'error');
        } finally {
            this.isWorking = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                variant
            })
        );
    }
}
