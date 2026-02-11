import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProformaInvoicePDFButton extends LightningElement {
    @api recordId;
    isGenerating = false;

    handleGeneratePDF() {
        this.isGenerating = true;

        // Deschide Visualforce Page care generează PDF direct
        const pdfUrl = `/apex/ProformaInvoicePDFTemplate?id=${this.recordId}&pdf=1`;
        
        // Download PDF prin redirect
        window.location.href = pdfUrl;
        
        // Toast message
        this.showToast('Success', 'PDF is generating...', 'success');
        
        this.isGenerating = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}