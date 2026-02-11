import { LightningElement, track , wire} from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import getQuoteLineItems from '@salesforce/apex/ProductWizardController.getQuoteLineItems';
// import getFieldset from '@salesforce/apex/ProductWizardController.getFieldset';
import getFieldsetPure from '@salesforce/apex/ProductWizardController.getFieldsetPure';
import getRecordsForConfiguration from '@salesforce/apex/ProductWizardController.getRecordsForConfiguration';
import saveQuoteLines from '@salesforce/apex/ProductWizardController.saveQuoteLines';
import getQuoteDetails from '@salesforce/apex/ProductWizardController.getQuoteDetails';

import productWizardTitle from '@salesforce/label/c.Product_Wizard_Title';
import errDirectAccess from '@salesforce/label/c.Err_Direct_Access';

export default class ProductWizard extends NavigationMixin(LightningElement) {
  labels = {
    productWizardTitle,
    errDirectAccess
  }

  @track
  errors = [];

  @track
  recordId; 

  @track
  selectedProductsData;
  
  @track hidePriceBookSelect = true;
  @track showButtons = false;

  @track fatal = false;

  @track configuratorFieldset;

  @track hideProductSearch = false;

  @wire(CurrentPageReference)
  currentPageReference;  

  @track 
  quoteLines;

  @track 
  priceBookId; 

  clean(data) {
    return JSON.parse(JSON.stringify(data));
  }

  connectedCallback() {
    this.quoteLines = [];

    this.recordId = this.currentPageReference.state.c__recordId;
    this.performGetQuoteDetails();
    this.performGetQuoteLines();

    if (!this.recordId) {
      this.errors.push({ message: this.labels.errDirectAccess });
      this.fatal = true;
    }

    
  }
  
  onPricebookSelect(evt){
    this.priceBookId = evt.detail;
    console.log('onPricebookSelect', this.priceBookId);

    this.hidePriceBookSelect = true; 
    this.hideProductSearch = false;   
  }

  backToPBSelect(evt){
    this.hidePriceBookSelect = evt.detail;
  }

  @track showPriceConfigurator = false;
  @track showProcessingScreen = false;

  onHidePriceBookSelect(evt) {
    this.hidePriceBookSelect = evt.detail;
  }

  performGetQuoteLines() {
    const params = {
      quoteId: this.recordId
    }

    getQuoteLineItems(params).then( result => {
      this.quoteLines = result;

      console.log('!!!!getQuoteLineItems: ', this.clean(result));

      if ( result.length > 0 ) {
        this.hidePriceBookSelect = true;
        this.hideProductSearch = false;
      } else {
        this.hidePriceBookSelect = false;
      }
    }).catch( error => {
      this.fatal = true;
      this.errors.push(error);
    })
  }

  performGetQuoteDetails(){
    const params = {
      quoteId: this.recordId
    }

    getQuoteDetails(params).then( item => {
      if (item.Pricebook2Id) {
        this.priceBookId = item.Pricebook2Id;
      }
    }).catch( error => {
      this.fatal = true;
      this.errors.push(error);
    });
  }

  populateOptionFieldsIfExists(item) {
    console.log('Product:' + item.Product2.Id + ' Main product: ' + item.ConfiguredProduct__c);
    let matches = this.quoteLines.filter(ql => {
      let availOptionsRes = this.quoteLines.filter(al => al.Product2Id === item.ConfiguredProduct__c);
      console.log('availOptionsRes', this.clean(availOptionsRes));
      if (availOptionsRes.length === 0) {
        return false;
      }

      return ql.Product2Id === item.Product2.Id && availOptionsRes[0].Id === ql.ConfiguredProduct__c
    });

    if (matches.length) {
      console.log('matches:', this.clean(matches));
      this.configuratorFieldset.forEach(cfg => {
        if (cfg.fieldPath.indexOf('.') !== -1) {
          return;
        }

        item[cfg.fieldPath] = matches[0][cfg.fieldPath];
      });

      item._selectedOption = true;
    }

    console.log('populateOptionFieldsIfExists: ', this.clean(item));

    return item;
  }

  performProductMapping(items) {
    let pricing = {};

    items.prices.forEach(price => {
      pricing[price.Product2Id] = {
        price: price.UnitPrice,
        Id: price.Id
      }
    });

    console.log('pricing map:', JSON.parse(JSON.stringify(pricing)));
    let productsList = [];

    //work on QLs from DB
    items.products.filter(item => item.hasOwnProperty('Product2') === true).forEach(item => {
      if (pricing.hasOwnProperty(item.Product2.Id)) {
        item.PricebookEntryId = pricing[item.Product2.Id].Id;
        productsList.push(item);
      }
    });

    //work on products with their options..
    items.products.filter(item => item.hasOwnProperty('Product2') === false).forEach(item => {
      let found = false;
      let childrens = [];

      if (item.hasOwnProperty('Product_Options__r')) {
        childrens = item.Product_Options__r.filter(pOption => {
          if (!pricing.hasOwnProperty(pOption.Option__c)) {
            //this product options has no price in selected pricebook
            return false;
          }

          return true;
        }).map(pOption => {
          console.log('pOption::', this.clean(pOption));
          return this.populateOptionFieldsIfExists({
            Id: pOption.Id,
            ConfiguredProduct__c: pOption.ConfiguredProduct__c || null,
            PricebookEntryId: pricing[pOption.Option__c].Id,
            Product2: pOption.Option__r,
            UnitPrice: pricing[pOption.Option__c].price,
            ListPrice: pricing[pOption.Option__c].price,
            Quantity: 1,
            Mandatory__c: pOption.Mandatory__c || false
          });
        });
      }

      productsList.forEach(product => {
        if (product.Product2.Id === item.Id) {
          //
          product.Product2 = item;
          product._children = childrens;

          found = true;
        }
      });

      if (!found) {
        productsList.push({
          PricebookEntryId: pricing[item.Id].Id,
          Product2: item,
          _children: childrens,
          UnitPrice: pricing[item.Id].price,
          ListPrice: pricing[item.Id].price,
          Quantity: 1
        });
      }
    });


    console.log('performProductMapping result:', JSON.parse(JSON.stringify(productsList)));

    return { products: productsList };
  }

  hideAllScreens() {
    this.hidePriceBookSelect = true;
    this.hideProductSearch = true;

    this.showPriceConfigurator = false;
    this.showProcessingScreen = false;
    this.showPriceConfigurator = false;
  }

  quit() {
    if (this.recordId) {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this.recordId,
          objectApiName: "Quote",
          actionName: "view"
        }
      });

      return;
    }
 
    //fallback. If for any reason we do not have recordId - just go to the list of Accounts.
    this[NavigationMixin.Navigate]({
      type: 'standard__objectPage',
      attributes: {
        objectApiName: "Quote",
        actionName: "list"
      }
    });
  }

  performFieldsAndValueMapping(fieldsInfo, record, result) {
    Object.keys(record).forEach(k => {
      if (['PricebookEntryId', 'QuoteId', 'UnitPrice', 'Product2Id', 'ListPrice'].includes(k)) {
        return;
      }

      if (fieldsInfo.hasOwnProperty(k)) {
        //
        if (fieldsInfo[k].updateable === true) {
          result[k] = record[k];
        }
      }
    });

    return result;
  }

  getOptionProduct(bundleId, optionId) {
    console.log('getOptionProduct::::', this.clean(bundleId), this.clean(optionId));
  }

  onPriceConfiguratorTriggerSave(evt) {
    //
    let records = evt.target.recordsForSave;
    let fieldsInfo = evt.target.fieldsInfo;

    //this.hideAllScreens();
    this.showProcessingScreen = true;

    console.log('Saving records:', JSON.parse(JSON.stringify(records)));
    //perform saving.

    console.log('Current pricebook is:', this.priceBookId);

    const params = {
      quoteId: this.recordId,
      priceBookId: this.priceBookId,
      records: [],
      skipDeletion: false,
    };

    let options = [];

    console.log('Save parameters: ', JSON.parse(JSON.stringify(params)));
    let idx = 0;

    records.forEach(record => {
      let row = {
        PWID__c: (++idx).toString(),
        PricebookEntryId: record.PricebookEntryId,
        QuoteId: this.recordId,
        Quantity: record.Quantity,
        UnitPrice: record.UnitPrice,
        ListPrice: record.ListPrice,
        Product2Id: record.Product2.Id
      };

      console.log('about to push to params...', this.clean(row));
      params.records.push(this.performFieldsAndValueMapping(fieldsInfo, record, row));
      console.log('after push to params');

      if (record.hasOwnProperty('_children')) {
        console.log('It has children...');
        record._children.forEach(children => {
          console.log('Inside children loop...', this.clean(children));
          //this.getOptionProduct(record.Id, children.Id);

          console.log('after getOptionProduct');

          let crow = {
            belongs_to: idx.toString(),
            PricebookEntryId: children.PricebookEntryId,
            QuoteId: this.recordId,
            Quantity: children.Quantity || 1,
            UnitPrice: children.UnitPrice || 0,
            ListPrice: children.ListPrice || 0,
            Product2Id: children.Product2.Id
          };

          console.log('before push to options', this.clean(crow));
          options.push(this.performFieldsAndValueMapping(fieldsInfo, children, crow));
          console.log('after push to options');
        });
      }
    });

    console.log('After records foreach..');

    saveQuoteLines(params).then(data => {
      console.log('save returns:', this.clean(data));

      if (data.errors.length) {
        data.forEach(msg => {
          this.errors.push({ message: msg });  
        });
        
        this.fatal = true;
      } else {
        if (options.length > 0) {
          //
          let preparedOptions = options.map(optItem => {
            data.records.forEach(rrec => {
              if (rrec.PWID__c === optItem.belongs_to) {
                optItem.ConfiguredProduct__c = rrec.Id;
              }
            });

            return optItem;
          });

          params.records = preparedOptions.filter(fo => fo.hasOwnProperty('ConfiguredProduct__c'));
          params.skipDeletion = true;

          console.log('Options saving params:', this.clean(params));

          if (params.records.length) {
            saveQuoteLines(params).then(dataOpt => {
              if (dataOpt.errors && dataOpt.errors.length) {
                dataOpt.forEach(msg => {
                  this.errors.push({ message: msg });
                });
                
                this.fatal = true;
              } else {
                console.log('Successfull options saving!');
                this.quit();
              }
            }).catch(errorOpt => {
              this.errors.push(errorOpt);
            });
          }
        } else {
          this.quit();
        }
      }
    }).catch(error => {
      this.errors.push(error);
    });

    //uncomment when project is done :)
    //this.quit();
  }

  onPriceConfiguratorBack(evt) {
    this.hideAllScreens();

    if (evt.detail.goto === 'search') {
      this.hideProductSearch = false;
    }
  }

  onProductSearchSaveTrigger(evt) {
    if(evt.detail.count > 0){
      const searchCmp = this.template.querySelector('[data-id="product-search"]');

      getFieldsetPure({ obj: 'QuoteLineItem', fieldset: 'OptionConfiguration'}).then(data => {
        if (data) {
          this.configuratorFieldset = JSON.parse(data);
        }

        console.log('this.configuratorFieldset:', this.clean(this.configuratorFieldset));

        getRecordsForConfiguration({
          quoteId: this.recordId,
          priceList: searchCmp.pricebookid,
          productIds: searchCmp.selectedRecords
        }).then(items => {
          this.hideAllScreens();
          this.showPriceConfigurator = true;
          console.log('RAW:', JSON.parse(JSON.stringify(items)));
          try {
            items = this.performProductMapping(items);
          } catch (e) {
            console.log(e);
          }

          console.log('getRecordsForConfiguration!!!:::', JSON.parse(JSON.stringify(items)));
          this.selectedProductsData = items.products;
          console.log('assign products...');
        }).catch(error => {
          console.log('getRecordsForConfiguration error:', JSON.stringify(error));  
        });
      });
    }
  }
}