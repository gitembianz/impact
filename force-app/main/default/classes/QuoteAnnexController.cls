// ========================================
// QUOTE ANNEX CONTROLLER - VERSIUNE COMPLETA
// ========================================
// CODUL ORIGINAL (nemodificat) + NOUA METODA (getRoomTypeAndLobbyPdfsAsBase64)

public with sharing class QuoteAnnexController {

    /**
     * @description Găsește numele resurselor statice necesare pe baza produselor din ofertă.
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getRequiredPdfResourceNames(Id quoteId) {
        Set<String> productCodesWithAnnex = new Set<String>{
            'AV3_AP11', 'AV3_AP12', 'AV3_AP13', 'AV3_AP14', 'AV3_AP15',
            'AV3_AP16', 'AV3_AP17', 'AV3_AP21', 'AV3_AP22', 'AV3_AP23',
            'AV3_AP24', 'AV3_AP25', 'AV3_AP26', 'AV3_AP27'
        };
        List<String> resourceNames = new List<String>();
        for (QuoteLineItem qli : [SELECT Product2.ProductCode FROM QuoteLineItem WHERE QuoteId = :quoteId AND Product2.ProductCode IN :productCodesWithAnnex]) {
            resourceNames.add(qli.Product2.ProductCode);
        }
        return resourceNames;
    }

    /**
     * @description Returnează conținutul unei resurse statice în format Base64.
     */
    @AuraEnabled(cacheable=true)
    public static String getSinglePdfAsBase64(String resourceName) {
        try { 
            return EncodingUtil.base64Encode([SELECT Body FROM StaticResource WHERE Name = :resourceName].Body); 
        } 
        catch (Exception e) { 
            throw new AuraHandledException('Resursa "' + resourceName + '" nu a fost găsită.'); 
        }
    }

    /**
     * @description Generează PDF-ul pentru pagina de listă de prețuri.
     */
    @AuraEnabled(cacheable=true)
    public static String generatePriceListPdfAsBase64(Id quoteId) {
        PageReference pdfPage = Page.PriceListPage;
        pdfPage.getParameters().put('id', quoteId);
        return EncodingUtil.base64Encode(Test.isRunningTest() ? Blob.valueOf('test') : pdfPage.getContentAsPDF());
    }

    /**
     * @description Generează PDF-ul pentru pagina de sumar a ofertei.
     */
    @AuraEnabled(cacheable=true)
    public static String generateQuoteSummaryPdfAsBase64(Id quoteId) {
        PageReference pdfPage = Page.QuoteSummaryPage;
        pdfPage.getParameters().put('id', quoteId);
        return EncodingUtil.base64Encode(Test.isRunningTest() ? Blob.valueOf('test') : pdfPage.getContentAsPDF());
    }

    /**
     * @description Descarcă PDF-ul agentului de pe server extern
     * URL format: https://forms.impactsa.ro/agents/{userId}.pdf
     */
    @AuraEnabled(cacheable=false)
    public static String getAgentPdfAsBase64(Id quoteId) {
        try {
            Quote quote = [SELECT OwnerId FROM Quote WHERE Id = :quoteId LIMIT 1];
            String userId = String.valueOf(quote.OwnerId);
            
            System.debug('=== AGENT PDF ONLINE DEBUG START ===');
            System.debug('User ID: ' + userId);
            
            String baseUrl = 'https://forms.impactsa.ro/agents/';
            String userFileName = userId + '.pdf';
            String userUrl = baseUrl + userFileName;
            System.debug('Încerc URL utilizator: ' + userUrl);
            
            try {
                Blob userPdf = downloadPdfFromUrl(userUrl);
                if (userPdf != null && userPdf.size() > 0) {
                    System.debug('PDF agent găsit pentru utilizator: ' + userId + ', mărime: ' + userPdf.size());
                    System.debug('=== AGENT PDF ONLINE DEBUG END (SUCCESS) ===');
                    return EncodingUtil.base64Encode(userPdf);
                }
            } catch (Exception e) {
                System.debug('Utilizatorul PDF nu a fost găsit: ' + e.getMessage());    
            }
            
            String defaultUrl = baseUrl + 'default.pdf';
            System.debug('Încerc default URL: ' + defaultUrl);
            
            try {
                Blob defaultPdf = downloadPdfFromUrl(defaultUrl);
                if (defaultPdf != null && defaultPdf.size() > 0) {
                    System.debug('PDF default găsit, mărime: ' + defaultPdf.size());
                    System.debug('=== AGENT PDF ONLINE DEBUG END (DEFAULT SUCCESS) ===');
                    return EncodingUtil.base64Encode(defaultPdf);
                }
            } catch (Exception e) {
                System.debug('Default PDF nu a fost găsit: ' + e.getMessage());
            }
            
            System.debug('=== AGENT PDF ONLINE DEBUG END (FAILED) ===');
            throw new AuraHandledException('Nu s-a găsit nici PDF-ul utilizatorului (' + userFileName + '), nici default.pdf pe server.');
            
        } catch (Exception e) {
            System.debug('EROARE GENERALA: ' + e.getMessage());
            throw new AuraHandledException('Eroare: ' + e.getMessage());
        }
    }

    /**
     * @description Obține lista de URL-uri pentru PDF-urile apartamentelor din ofertă
     * URL format: https://forms.impactsa.ro/avproducts/{productCode}.pdf
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getApartmentPdfUrls(Id quoteId) {
        try {
            List<String> pdfUrls = new List<String>();
            String baseUrl = 'https://forms.impactsa.ro/avproducts/';
            
            for (QuoteLineItem qli : [
                SELECT Product2.ProductCode 
                FROM QuoteLineItem 
                WHERE QuoteId = :quoteId 
                AND Product2.ProductCode != null
                ORDER BY Product2.ProductCode
            ]) {
                String pdfUrl = baseUrl + qli.Product2.ProductCode + '.pdf';
                pdfUrls.add(pdfUrl);
                System.debug('Added apartment PDF URL: ' + pdfUrl);
            }
            
            System.debug('Total apartment URLs: ' + pdfUrls.size());
            return pdfUrls;
            
        } catch (Exception e) {
            System.debug('Eroare la getApartmentPdfUrls: ' + e.getMessage());
            throw new AuraHandledException('Eroare: ' + e.getMessage());
        }
    }

    /**
     * @description Descarcă un PDF de pe URL și returnează Base64
     */
    @AuraEnabled(cacheable=false)
    public static String downloadPdfFromUrlAsBase64(String pdfUrl) {
        try {
            System.debug('Descărcând PDF din: ' + pdfUrl);
            
            Blob pdfBlob = downloadPdfFromUrl(pdfUrl);
            
            if (pdfBlob != null && pdfBlob.size() > 0) {
                System.debug('PDF descărcat cu succes, mărime: ' + pdfBlob.size());
                return EncodingUtil.base64Encode(pdfBlob);
            } else {
                throw new AuraHandledException('PDF este gol');
            }
            
        } catch (Exception e) {
            System.debug('Eroare la downloadPdfFromUrlAsBase64: ' + e.getMessage());
            throw new AuraHandledException('Eroare la descărcarea PDF: ' + e.getMessage());
        }
    }

    /**
     * @description Descarcă un PDF de pe URL și returnează Blob-ul
     */
    private static Blob downloadPdfFromUrl(String pdfUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(pdfUrl);
        req.setMethod('GET');
        req.setTimeout(120000);
        req.setHeader('User-Agent', 'Salesforce');
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        System.debug('Status pentru ' + pdfUrl + ': ' + res.getStatusCode());
        
        if (res.getStatusCode() == 200) {
            return res.getBodyAsBlob();
        } else {
            throw new AuraHandledException('URL ' + pdfUrl + ' returnat status ' + res.getStatusCode());
        }
    }

    @AuraEnabled(cacheable=true)
    public static String getQuoteName(Id quoteId) {
        try {
            Quote q = [SELECT Name FROM Quote WHERE Id = :quoteId LIMIT 1];
            return q.Name;
        } catch (Exception e) {
            return 'Oferta';
        }
    }

    /**
     * @description NOUA METODA: Returnează lobby + finisaje camere ca Base64
     * URL base: https://forms.impactsa.ro/avproducttypes/
     * - lobby.pdf (o singură dată, dacă există cel puțin un QLI cu NumberofRooms__c > 0)
     * - 2cam.pdf, 3cam.pdf, 4camt1.pdf, 5cam.pdf, 6cam.pdf (o singură dată pentru fiecare tip prezent)
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getRoomTypeAndLobbyPdfsAsBase64(Id quoteId) {
        List<String> result = new List<String>();

        try {
            // 1. Obținem QLI + numărul de camere de pe Product2
            List<QuoteLineItem> qlis = [
                SELECT Product2.NumberofRooms__c
                FROM QuoteLineItem
                WHERE QuoteId = :quoteId
                AND Product2.NumberofRooms__c != null
                AND Product2.NumberofRooms__c > 0
            ];

            if (qlis.isEmpty()) {
                return result;
            }

            // 2. Construim setul de numere distincte de camere
            Set<Integer> roomCounts = new Set<Integer>();
            for (QuoteLineItem qli : qlis) {
                Integer rooms = qli.Product2.NumberofRooms__c.intValue();
                roomCounts.add(rooms);
            }

            if (roomCounts.isEmpty()) {
                return result;
            }

            // 3. Base URL pentru tipuri + lobby
            String baseUrl = 'https://forms.impactsa.ro/avproducttypes/';

            // 4. Adăugăm lobby.pdf o singură dată, primul în listă
            try {
                String lobbyUrl = baseUrl + 'lobby.pdf';
                Blob lobbyBlob = downloadPdfFromUrl(lobbyUrl);
                if (lobbyBlob != null && lobbyBlob.size() > 0) {
                    result.add(EncodingUtil.base64Encode(lobbyBlob));
                }
            } catch (Exception e) {
                System.debug('Nu s-a putut descărca lobby.pdf: ' + e.getMessage());
                // Continuăm fără lobby, nu oprim procesul
            }

            // 5. Mapare număr camere -> fișier
            Map<Integer, String> roomToFile = new Map<Integer, String>{
                2 => '2cam.pdf',
                3 => '3cam.pdf',
                4 => '4camt1.pdf',
                5 => '5cam.pdf',
                6 => '6cam.pdf'
            };

            // 6. Pentru a respecta ordinea "naturală", iterăm explicit 2..6
            List<Integer> orderedRooms = new List<Integer>{2, 3, 4, 5, 6};

            for (Integer room : orderedRooms) {
                if (!roomCounts.contains(room)) {
                    continue;
                }

                if (!roomToFile.containsKey(room)) {
                    continue;
                }

                String fileName = roomToFile.get(room);
                String url = baseUrl + fileName;

                try {
                    Blob pdfBlob = downloadPdfFromUrl(url);
                    if (pdfBlob != null && pdfBlob.size() > 0) {
                        result.add(EncodingUtil.base64Encode(pdfBlob));
                    }
                } catch (Exception e) {
                    System.debug('Nu s-a putut descărca ' + fileName + ': ' + e.getMessage());
                    // Continuăm cu restul tipurilor, fără să oprim tot procesul
                }
            }

            return result;

        } catch (Exception e) {
            System.debug('Eroare în getRoomTypeAndLobbyPdfsAsBase64: ' + e.getMessage());
            throw new AuraHandledException('Eroare: ' + e.getMessage());
        }
    }
}