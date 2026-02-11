import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import searchPricebookEntries from '@salesforce/apex/ProductWizardController.searchPricebookEntries';
import getFieldset from '@salesforce/apex/ProductWizardController.getFieldSet';

import getProductsByQuoteLine from '@salesforce/apex/ProductWizardController.getProductsByQuoteLine';
import getQuoteDetails from '@salesforce/apex/ProductWizardController.getQuoteDetails';


import btnSearch from '@salesforce/label/c.Btn_Search';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnBack from '@salesforce/label/c.Btn_Back';
import btnNext from '@salesforce/label/c.Btn_Next';
import showResultsLabel from '@salesforce/label/c.Show_Results';
import showSelectedLabel from '@salesforce/label/c.Show_Selected';



export default class PwProductSearch extends LightningElement {
  @track fatal = false;
  _searchResults = [];

  @track selectionSnapshot = [];
  _records = [];

  @track 
  tableIsLoading = false;

  @track
  pageDraftValues;

  @track
  errors = [];

  @track
  recordId;
  
  @track 
  toggleBtnLabel = '';

  @track
  toggleBtnState = 0;

  @track
  toggleBtnVisible = false;

  @track 
  backButtonVisible = true;

  @track 
  showSearchResults = false;

  @track 
  selectedRows = [];

  @wire(CurrentPageReference)
  currentPageReference; 
  
  @api
  pricebookid;

  @api
  get records(){
    return this._records;
  }

  set records(value) {
    this._records = value;
  } 

  @api
  get selectedRecords() {
    return this._selectedRectords;
  }

  set selectedRecords(value){
    this._selectedRectords = value;
  }

  @api
  get searchterms() {
    return this._searchterm;
  }

  @track
  columns = [];

  @track
  searchResults = [];

  labels = {
    btnSearch,
    btnCancel,
    btnNext,
    btnBack,
    showResultsLabel,
    showSelectedLabel    
  }

  performGetQuoteDetails(){
    const params = {
      quoteId: this.recordId
    }

    getQuoteDetails(params).then( item => {
      if (item.Pricebook2Id) {
        this.pricebookid = item.Pricebook2Id;
      }
    }).catch( error => {
      this.fatal = true;
      this.errors.push(error);
    });
  }  

  handleChange(evt) {
    let searchTerm = evt.detail.value;

    if (searchTerm.trim().length === 0) {
      this.searchResults = [];
      this.showSearchResults = true;
    }
  }

  handleSearch(){
    const searchInput = this.template.querySelector('[data-id="search"]');
    if(searchInput.value.length > 0){
      this.searchterm = searchInput.value;
      this.peformSearchPricebookEntries();
    }
  }

  refreshButtonLabels() {
    if( this.showSearchResults ){
      this.toggleBtnLabel = this.labels.showSelectedLabel + ' (' + this.selectedRows.length + ')';
    } else {
      this.toggleBtnLabel = this.labels.showResultsLabel + ' (' + this.searchResults.length + ')';
    }
  }

  peformSearchPricebookEntries(){
    const params = {
      priceBook2Id: this.pricebookid,
      searchTerm: this.searchterm
    }

    searchPricebookEntries(params).then(items => {
      this.showSearchResults = true;

      this.toggleBtnVisible = true;
      this.toggleBtnState = 0;

      if (!this.selectedRows) {
        this.selectedRows = [];
      }
      
      this.searchResults = items.filter(itm => !this.selectedRows.includes(itm.Id));
      this.refreshButtonLabels();
    }).catch(error => {
      this.errors.push(error);
    });
  }

  performGetFieldSetLabels(objName, fieldSet){
    const params = {
      objectName: objName,
      fieldSetName: fieldSet
    }

    getFieldset(params).then(items => {
      let tempColumns = JSON.parse(items)

      tempColumns.forEach(item => {
        switch(item.type){
          case 'STRING':
            item.type = 'text';
            break;
          case 'PICKLIST':
            item.type = 'text';
            break;
          case 'CURRENCY':
            item.type = 'currency';
            break;
          case 'PERCENT':
            item.type = 'percent';
            break;
          default:
            item.type = 'text';
        }
      })

      this.columns = tempColumns;
    }).catch(error => {
      this.errors.push(error);
    });
  }

  clean(data) {
    return JSON.parse(JSON.stringify(data));
  }

  removeBundleStandaloneOptions(items) {
    let result = items || [];

    console.log('%%%%%:', this.clean(items));
    return result;
  }

  performGetQuoteLines() {
    getProductsByQuoteLine({ quoteId: this.recordId }).then ( existingProducts => {
         
      this.selectedRows = existingProducts.map(product => {   
        return product.Id;
      })

      this.records = this.removeBundleStandaloneOptions(existingProducts);  

      if(this.records.length > 0){
        this.backButtonVisible = false;
      }          
    }).catch( error => {
      this.errors.push(error);
    });
  }

  toggleButtonClick(){
    if( this.showSearchResults ){
      this.showSearchResults = false;
    } else {
      this.showSearchResults = true;
    }

    this.refreshButtonLabels();
   }

  takeStateSnapshot(){
    this.selectionSnapshot = [];
    this.records.forEach(item => {
      if(this.selectedRows.find( r => r === item.Id)){
        this.selectionSnapshot.push(item.Id);
      }      
    })
  }

  onRowSelection(evt){
    evt.target.isLoading = true;

    let selection = [];

    if(evt.detail.selectedRows.length > 0) {      
      selection = evt.detail.selectedRows.map(item => {
        return item.Id;
      });
    }

    evt.target.isLoading = false;
    this.selectedRows = selection;

    this.refreshButtonLabels();
    evt.target.isLoading = false;
  }

  onSearchRowSelection(evt){
    evt.target.isLoading = true;
    let selection = [];

    if(evt.detail.selectedRows.length > 0) {
      selection = evt.detail.selectedRows.map(item => {
        return item.Id;
      });
    }

    if (!this.searchResults) {
      this.searchResults = [];
    }

    this.searchResults.forEach(row => {
      if (selection.includes(row.Id)) {

        if (!this.records.find(rec => rec.Id === row.Id)) {
          this.records = this.records.concat([row]);
         }

         if (!this.selectedRows.includes(row.Id)) {
          let tmp = this.selectedRows;
          tmp.push(row.Id);

          this.selectedRows = tmp;
        }
      } else {
        this.records = this.records.filter(rec => (rec.Id !== row.Id));
        this.selectedRows = this.selectedRows.filter(sr => (sr !== row.Id));
      }
    });

    this.refreshButtonLabels();
    evt.target.isLoading = false;
  }
  

  connectedCallback(){
    this.toggleBtnLabel = this.labels.showSelectedLabel;
    this.recordId = this.currentPageReference.state.c__recordId;
    this.performGetFieldSetLabels('Product2', 'LineEditor');
    this.performGetQuoteDetails();
    this.performGetQuoteLines();
  }

  saveTrigger(){
    if(this.selectedRows.length > 0){
      this.selectedRecords = this.selectedRows;
      console.log(this.selectedRows);
      
      this.dispatchEvent(new CustomEvent('savetrigger', {
        detail: { count: this.selectedRecords.length }
      }));
    }
  }

  onBack(){
    const backEvent = new CustomEvent('back', { detail: false });
    this.dispatchEvent(backEvent);
  }

  enterPressed(evt){
    if(evt.keyCode === 13) {
      this.handleSearch();
    }
  }
}