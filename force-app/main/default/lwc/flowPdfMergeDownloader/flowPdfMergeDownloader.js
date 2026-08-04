import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { api, LightningElement } from 'lwc';
import { mergePdfs } from 'c/genericPdfLib';
import {
    ensureFileExtension,
    getResolvedFilePayloads,
    normalizeStringArray,
    triggerBrowserDownload
} from 'c/flowFileActionLib';

export default class FlowPdfMergeDownloader extends LightningElement {
    @api fileIds;
    @api outputFileName = 'pdfMerge';
    @api buttonLabel = 'Download Merged PDF';
    @api variant = 'neutral';
    @api downloadComplete = false;
    @api errorMessage = '';

    isWorking = false;

    get normalizedFileIds() {
        return normalizeStringArray(this.fileIds);
    }

    get resolvedButtonLabel() {
        return this.buttonLabel || 'Download Merged PDF';
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
            this.showToast('Merge PDF', this.errorMessage, 'error');
            return;
        }

        this.isWorking = true;
        try {
            const resolvedFiles = await getResolvedFilePayloads(fileIds);
            const pdfBytesArray = resolvedFiles.map((file) => file.bytes);

            const mergedBytes =
                pdfBytesArray.length === 1 ? pdfBytesArray[0] : mergePdfs(pdfBytesArray);

            triggerBrowserDownload(
                mergedBytes,
                ensureFileExtension(this.outputFileName || 'pdfMerge', 'pdf'),
                'application/pdf'
            );
            this.downloadComplete = true;
            this.showToast('Merge PDF', 'Merged PDF download started.', 'success');
        } catch (error) {
            this.errorMessage =
                error?.message ||
                'PDF merge failed. Ensure each supplied file is a valid PDF.';
            this.showToast('Merge PDF', this.errorMessage, 'error');
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
