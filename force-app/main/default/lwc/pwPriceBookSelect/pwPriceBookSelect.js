import { LightningElement, track, api} from 'lwc';

import getQuoteDetails from '@salesforce/apex/ProductWizardController.getQuoteDetails';
import getPricebooks from '@salesforce/apex/ProductWizardController.getPricebooks';

import selectPricebook from '@salesforce/label/c.Select_Pricebook';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnNext from "@salesforce/label/c.Btn_Next";
import errNoPBsAvailable from '@salesforce/label/c.Err_No_PBs_Available';

export default class PwPriceBookSelect extends LightningElement {
  @track
  errors = [];

  @track
  records = [];

  @track
  options = [];

  @api
  get quoteDetails() {
    return this._quoteDetails;
  }

  set quoteDetails(value) {
    this._quoteDetails = value;
  }

  @api 
  get quoteid() {
    return this._quoteid;
  }

  set quoteid(value) {
    this._quoteid = value;
  }

  @api
  value;

  labels = {
    btnCancel,
    btnNext,
    selectPricebook,
    errNoPBsAvailable
  }

  performGetQuoteDetails(){
    const params = {
      quoteId: this._quoteid
    }

    getQuoteDetails(params).then( result => {
      this.quoteDetails = result;
      this.performGetPricebooks(); 
    }).catch(error => {
      this.errors.push(error);
    })
  }

  performGetPricebooks(){
    const params = {
      quoteDate: this.quoteDetails.QuoteDate__c
    }

    getPricebooks(params).then( result => {
      if (result.length > 0) {
        this.records = result;
        this.options = result.map(item => {
          return {
            label: item.Name,
            value: item.Id
          };
        });
      } else {
        this.errors.push({ message: this.labels.errNoPBsAvailable });
      }
    }).catch( error => {
      this.errors.push(error);
    })
  }

  onComboboxSelect(evt) {
    this.value = evt.detail.value;
  }

  onSelect() {
    if (this.value) {
      this.emitSelectEvent();
    }
  }

  emitSelectEvent() {
    const selectEvent = new CustomEvent('select', { detail: this.value });
    this.dispatchEvent(selectEvent);
  }

  connectedCallback(){
    this.performGetQuoteDetails();       
  }

}