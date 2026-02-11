import { LightningElement, api } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import pdfLib from '@salesforce/resourceUrl/pdflib';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';

// Importăm metodele Apex
import generateQuoteSummaryPdfAsBase64 from '@salesforce/apex/QuoteAnnexController.generateQuoteSummaryPdfAsBase64';
import generatePriceListPdfAsBase64 from '@salesforce/apex/QuoteAnnexController.generatePriceListPdfAsBase64';
import getRequiredPdfResourceNames from '@salesforce/apex/QuoteAnnexController.getRequiredPdfResourceNames';
import getSinglePdfAsBase64 from '@salesforce/apex/QuoteAnnexController.getSinglePdfAsBase64';
import getAgentPdfAsBase64 from '@salesforce/apex/QuoteAnnexController.getAgentPdfAsBase64';
import getApartmentPdfUrls from '@salesforce/apex/QuoteAnnexController.getApartmentPdfUrls';
import downloadPdfFromUrlAsBase64 from '@salesforce/apex/QuoteAnnexController.downloadPdfFromUrlAsBase64';
import getQuoteName from '@salesforce/apex/QuoteAnnexController.getQuoteName';
import getRoomTypeAndLobbyPdfsAsBase64 
    from '@salesforce/apex/QuoteAnnexController.getRoomTypeAndLobbyPdfsAsBase64';

export default class MergePdfComponent extends LightningElement {
    @api recordId;
    isMerging = false;
    statusMessage = '';
    isLibLoaded = false;

    renderedCallback() {
        if (this.isLibLoaded) return;
        loadScript(this, pdfLib)
            .then(() => { 
                this.isLibLoaded = true;
                console.log('PDFLib încărcat cu succes');
            })
            .catch(error => {
                console.error('Eroare la încărcarea PDFLib:', error);
                this.showToast('Eroare Critică', 'Biblioteca PDF (pdflib) nu a putut fi încărcată.', 'error');
            });
    }

async handleMergeClick() {
    if (!this.isLibLoaded) {
        this.showToast('Atenție', 'Componentele necesare nu sunt încărcate.', 'warning');
        return;
    }
    this.isMerging = true;

    try {
        // Obține numele Quote-ului
        const quoteName = await getQuoteName({ quoteId: this.recordId });
        
        // Colectează și îmbină PDF-urile
        const mergedPdfBytes = await this.collectAndMergePdfs();
        if (!mergedPdfBytes) {
            this.isMerging = false;
            return;
        }

        // Descarcă cu numele dinamic
        this.statusMessage = 'Se pregătește descărcarea...';
        const fileName = `Anexa Oferta - ${quoteName}.pdf`;
        this.downloadPdf(mergedPdfBytes, fileName);

        this.showToast('Succes!', 'Fișierul PDF este pregătit pentru descărcare.', 'success');
        this.dispatchEvent(new CloseActionScreenEvent());

    } catch (error) {
        const errorMessage = error.body ? error.body.message : (error.message ? error.message : 'A apărut o eroare necunoscută.');
        this.showToast('Eroare la Procesare', errorMessage, 'error');
    } finally {
        this.isMerging = false;
    }
}

    
    async collectAndMergePdfs() {
    let pdfBase64List = [];
    this.statusMessage = 'Se pregătesc documentele...';

    try {
        // 1. Încarcă fișierele statice inițiale (AV31-AV35)
        const av3Parts = ['AV31', 'AV32', 'AV33', 'AV34', 'AV35'];
        for (const partName of av3Parts) {
            try {
                const pdf = await getSinglePdfAsBase64({ resourceName: partName });
                if (pdf) {
                    pdfBase64List.push(pdf);
                }
            } catch (e) {
                console.warn(`Nu s-a putut încărca ${partName}:`, e);
            }
        }

        // 2. Obține PDF-urile produselor din ofertă din Static Resources
        const productAnnexNames = await getRequiredPdfResourceNames({ quoteId: this.recordId });
        if (productAnnexNames && productAnnexNames.length > 0) {
            for (const name of productAnnexNames) {
                try {
                    const pdf = await getSinglePdfAsBase64({ resourceName: name });
                    if (pdf) {
                        pdfBase64List.push(pdf);
                    }
                } catch (e) {
                    console.warn(`Nu s-a putut încărca ${name}:`, e);
                }
            }
        }

        // 3. APARTAMENTE - Se descarcă de pe server INAINTE de tabelele cu detalii
        try {
            console.log('Se încearcă obținerea URL-urilor apartamentelor...');
            const apartmentUrls = await getApartmentPdfUrls({ quoteId: this.recordId });
            console.log('URL-uri apartamente obținute:', apartmentUrls.length);
            
            for (const url of apartmentUrls) {
                try {
                    console.log('Descărcând apartament din:', url);
                    this.statusMessage = `Se descarcă apartament: ${url.split('/').pop()}`;
                    
                    const apartmentPdf = await downloadPdfFromUrlAsBase64({ pdfUrl: url });
                    if (apartmentPdf) {
                        pdfBase64List.push(apartmentPdf);
                        console.log('PDF apartament adăugat cu succes');
                    }
                } catch (e) {
                    console.warn('Nu s-a putut descărca apartament:', url, e);
                    this.showToast('Avertisment', `Nu s-a putut descărca: ${url}`, 'warning');
                }
            }
            console.log('Total apartamente încărcate:', apartmentUrls.length);
        } catch (e) {
            console.warn('Eroare la obținerea URL-urilor apartamentelor:', e);
            this.showToast('Avertisment', 'Nu s-au putut obține URL-urile apartamentelor', 'warning');
        }

        // 3.1 LOBBY + FINISAJE CAMERE (în funcție de numărul de camere din ofertă)
        try {
            console.log('Se încearcă obținerea PDF-urilor de lobby și finisaje camere...');
            this.statusMessage = 'Se pregătesc paginile de lobby și finisaje...';

            const roomTypePdfs = await getRoomTypeAndLobbyPdfsAsBase64({ quoteId: this.recordId });

            if (roomTypePdfs && roomTypePdfs.length > 0) {
                roomTypePdfs.forEach(pdf => {
                    if (pdf) {
                        pdfBase64List.push(pdf);
                    }
                });
                console.log('Lobby + finisaje camere adăugate, total: ' + roomTypePdfs.length);
            } else {
                console.log('Nu s-au găsit PDF-uri de lobby/finisaje pentru această ofertă.');
            }
        } catch (e) {
            console.warn('Nu s-au putut încărca lobby + finisaje camere:', e);
            this.showToast('Avertisment', 'Paginile de lobby/finisaje nu au putut fi încărcate, dar procesul continuă.', 'warning');
        }

        // 4. Adaugă lista de prețuri (detalii)
        try {
            const priceListPdf = await generatePriceListPdfAsBase64({ quoteId: this.recordId });
            if (priceListPdf) {
                pdfBase64List.push(priceListPdf);
            }
        } catch (e) {
            console.warn('Nu s-a putut încărca lista de prețuri:', e);
        }

        // 5. Adaugă sumarul ofertei
        try {
            const quoteSummaryPdf = await generateQuoteSummaryPdfAsBase64({ quoteId: this.recordId });
            if (quoteSummaryPdf) {
                pdfBase64List.push(quoteSummaryPdf);
            }
        } catch (e) {
            console.warn('Nu s-a putut încărca sumarul ofertei:', e);
        }

        // 6. Adaugă fișierul final AV36
        try {
            const av36Pdf = await getSinglePdfAsBase64({ resourceName: 'AV36' });
            if (av36Pdf) {
                pdfBase64List.push(av36Pdf);
            }
        } catch (e) {
            console.warn('Nu s-a putut încărca AV36:', e);
        }

        // 7. AGENT - Pagina cu agentul la FINAL
        try {
            console.log('Se încearcă obținerea PDF-ului agentului...');
            const agentPdf = await getAgentPdfAsBase64({ quoteId: this.recordId });
            if (agentPdf) {
                console.log('PDF agent obținut cu succes');
                pdfBase64List.push(agentPdf);
            }
        } catch (e) {
            console.warn('Nu s-a putut obține PDF-ul agentului:', e);
            this.showToast('Avertisment', 'PDF-ul agentului nu a putut fi încărcat, dar procesul continuă.', 'warning');
        }

        this.statusMessage = `Se îmbină ${pdfBase64List.length} documente...`;
        console.log('Total PDF-uri de îmbinat:', pdfBase64List.length);

        const { PDFDocument } = window.PDFLib;
        const mergedPdf = await PDFDocument.create();

        for (let i = 0; i < pdfBase64List.length; i++) {
            const pdfBase64 = pdfBase64List[i];
            if (pdfBase64) {
                try {
                    console.log(`Procesez PDF ${i + 1}/${pdfBase64List.length}...`);
                    const pdfBytes = Uint8Array.from(atob(pdfBase64), c => c.charCodeAt(0));
                    const pdfDoc = await PDFDocument.load(pdfBytes);
                    const copiedPages = await mergedPdf.copyPages(pdfDoc, pdfDoc.getPageIndices());
                    copiedPages.forEach(page => mergedPdf.addPage(page));
                } catch (e) {
                    console.warn(`Eroare la procesarea PDF ${i + 1}:`, e);
                }
            }
        }

        console.log('PDF-uri îmbinate cu succes');
        return await mergedPdf.save();

    } catch(e) {
        console.error('Eroare la colectarea documentelor:', e);
        const errorMessage = e.body ? e.body.message : (e.message ? e.message : 'Eroare la colectarea documentelor.');
        this.showToast('Eroare la Colectare', errorMessage, 'error');
        return null;
    }
}

    
    /**
     * @description Funcție helper care ia datele binare ale unui PDF și declanșează descărcarea în browser.
     * @param {Uint8Array} pdfBytes - Conținutul binar al fișierului PDF.
     * @param {string} fileName - Numele fișierului care va fi descărcat.
     */
    downloadPdf(pdfBytes, fileName) {
        // Creează un obiect Blob (Binary Large Object) din datele PDF
        const blob = new Blob([pdfBytes], { type: 'application/pdf' });
        // Creează un URL temporar pentru acest Blob
        const blobUrl = URL.createObjectURL(blob);

        // Creează un element de link (`<a>`) invizibil
        const link = document.createElement('a');
        link.href = blobUrl;
        link.download = fileName;
        link.style.display = 'none';

        // Adaugă link-ul la pagină, simulează un click și apoi îl șterge
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);

        // Revocă URL-ul temporar pentru a elibera memoria
        URL.revokeObjectURL(blobUrl);
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
    }
}