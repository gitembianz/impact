import { LightningElement, api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import QUOTE_LINE_ITEM_OBJECT from '@salesforce/schema/QuoteLineItem';
import currency from '@salesforce/i18n/currency';

import productConfigurator from '@salesforce/label/c.Product_Configurator';
import btnCancel from '@salesforce/label/c.Btn_Cancel';
import btnSave from '@salesforce/label/c.Btn_Save';
import btnBack from '@salesforce/label/c.Btn_Back';
import labelTotal from '@salesforce/label/c.Total';
import Error_optional_and_standalone_product from '@salesforce/label/c.Error_optional_and_standalone_product';
import Please_correct_issues from '@salesforce/label/c.Please_correct_issues';

export default class PwPriceConfiguration extends LightningElement {
  @track columns;
  @track grandTotal = 0;
  @track currenyCode = currency;
  @track currentSelection = {};
  @track errors = [];
  @track disableSave = undefined;

  _recordsForSave = [];

  labels = {
    productConfigurator,
    btnCancel,
    btnSave,
    btnBack,
    labelTotal,
    Error_optional_and_standalone_product,
    Please_correct_issues
  }

  @api executed;

  @api 
  set recordsForSave(value) {
    this._unused = value;
  }

  get recordsForSave() {
    return this._recordsForSave;
  }

  @api
  set records(value) {
    if (value) {
      value.forEach(row => {
        if (!row.hasOwnProperty('Quantity')) {
          row.Quantity = 1;
        } else if (row.Quantity < 1) {
          row.Quantity = 1;
        }
      });

      value = this.calculateLinesAndTotal(value);
    }

    this._records = value;
    this.tryInit();
  }

  get records() {
    return this._records;
  }

  @api
  set fieldset(value) {
    this._fieldset = value;
    this.tryInit();
  }

  get fieldset() {
    return this._fieldset;
  }

  @api
  set fieldsInfo(value) {
    this._fieldsInfo = value;
    this.tryInit();
  }

  get fieldsInfo() {
    return this._fieldsInfo;
  }

  loopPrevent = false;

  @wire(getObjectInfo, { objectApiName: QUOTE_LINE_ITEM_OBJECT })
  onGetObjectInfoDone({ error, data }) {
    if (data) {
      this.fieldsInfo = data.fields;
    } else if (error) {
      console.log('Done.. the data is error:', JSON.parse(JSON.stringify(error)));
    } else {
      console.log('No data and no error!');
    }
  }

  setDefaultValues(rows) {
    rows.forEach(row => {
      if (!row.hasOwnProperty('Quantity')) {
        row.Quantity = 1;
      } else if (row.Quantity < 1) {
        row.Quantity = 1;
      }
    });

    return rows;
  }


  constructor() {
    super();
    console.log('Price Configurator: Contructor');
    this.executed = false;
  }

  tryInit() {
    console.log('try init is called. executed:', this.executed);

    if (!this._fieldset || !this._records || !this.fieldsInfo || this.loopPrevent) {
      return;
    }

    this.generateColumns();

    let cols = JSON.parse(JSON.stringify(this.columns));
    
    cols.forEach(item => {
      item._description = this.fieldsInfo[item.fieldName] || {};
    });

    if (this.executed === false) {
      this._records.forEach(item => {
        if (item.hasOwnProperty('_children')) {
          item._children.forEach(children => {
            if (children.hasOwnProperty('_selectedOption') && children._selectedOption) {
              if (!this.currentSelection[item.Product2.Id]) {
                this.currentSelection[item.Product2.Id] = [];
              }

              if (!this.currentSelection[item.Product2.Id].includes(children.Product2.Id)) {
                this.currentSelection[item.Product2.Id].push(children.Product2.Id);
              }
            }
          });
        }
      });

      console.log('initial selected options process');
      this._records = this.calculateLinesAndTotal(this._records);
      this.executed = true;
    }

    this.loopPrevent = true;
    this.columns = cols;
    this.loopPrevent = false;
  }

  generateColumns() {
    let fieldsetColumns = [];

    this.fieldset.forEach(field => {
      let type = 'text';

      switch(field.type) {
        case 'string':
        case 'reference':
        case 'id':
          type = 'text';
          break;

        case 'integer':
        case 'decimal':
        case 'double':
          type = 'number';
          break;
        case 'currency':
          type = 'currency';
          break;
        case 'percent':
          type = 'percent';
          break;
        case 'boolean':
          type = 'boolean';
          break;
        default:
          type = 'text';
      }

      let item = {
        label: field.label,
        fieldName: field.fieldPath,
        type: type
      };

      fieldsetColumns.push(item);
    });

    this.columns = [
      {
        label: '', fieldName: '_selectedOption', type: 'checkbox', isCheckbox: true, valueField: '', mandatoryField: 'Mandatory__c'
      },
      {
        label: '', fieldName: 'Product2.Name', isName: true
      }
    ].concat(fieldsetColumns).concat([
      { label: 'Total Price', fieldName: '_TotalPrice', type: 'currency', readonly: true },
    ]);
  }

  connectedCallback() {
    this.disableSave = undefined;
    console.log('connected callback!');
  }

  calculateLineTotal(row) {
    let unitPrice = (row.hasOwnProperty('UnitPrice') ? row.UnitPrice : 0) || 0;
    let discount = (row.hasOwnProperty('Discount') ? row.Discount : 0) || 0;
    let quantity = (row.hasOwnProperty('Quantity') ? row.Quantity : 0) || 1;

    if (discount !== 0) {
      discount = discount / 100;
    }

    // console.log('Calculate Line: ', JSON.parse(JSON.stringify(row)), (quantity * (unitPrice  - (unitPrice * discount))) || 0);

    return (quantity * (unitPrice  - (unitPrice * discount))) || 0;
  }

  calculateLinesAndTotal(records) {
    const result =  JSON.parse(JSON.stringify(records));
    this.grandTotal = 0;

    result.forEach(record => {
      record._TotalPrice = this.calculateLineTotal(record);
      this.grandTotal += record._TotalPrice;

      if (record.hasOwnProperty('_children')) {
        record._children.forEach(children => {
          children._TotalPrice = this.calculateLineTotal(children);

          if ((this.currentSelection.hasOwnProperty(record.Product2.Id)
            && this.currentSelection[record.Product2.Id].includes(children.Product2.Id))
            || children.Mandatory__c === true) {
            this.grandTotal += children._TotalPrice;
          }
        });
      }
    });

    return result;
  }

  onCellChange(evt) {
    const result =  JSON.parse(JSON.stringify(this._records));
    const parentId = evt.detail.parentId;

    result.forEach(record => {
      if ((record.Product2.Id === evt.detail.recordId) && !parentId) {
        record[evt.detail.target] = evt.detail.value;
      } else if (record.hasOwnProperty('_children') && parentId && parentId === record.Product2.Id) {
        record._children.forEach(children => {
          if (children.Product2.Id === evt.detail.recordId) {
            children[evt.detail.target] = evt.detail.value;
          } 
        });
      }
    });

    this.records = result;
  }

  performDataValidation(data, selection) {
    let uniqProducts = new Set();
    const result = {
      valid: true,
      message: '',
      addMessage: function(value) {
        if (this.message.length > 0) {
          this.message += '\n';
          this.message += value;
        } else {
          this.message = value;
        }
      }
    };

    if (data) {
      const pcItems = this.template.querySelectorAll('c-pw-price-configuration-item');

      pcItems.forEach(pcItem => {
        if (result.valid === true) {
          if (pcItem.level === '2') {
            if (pcItem.record.Mandatory__c === true || (selection.hasOwnProperty(pcItem.parentId) && selection[pcItem.parentId].includes(pcItem.record.Product2.Id)))  {
              if (!pcItem.isValid()) {
                result.valid = false;
                result.addMessage(this.labels.Please_correct_issues);
              }
            }
          } else if (pcItem.level === '1') {
            if (!pcItem.isValid()) {
              //fail
              result.valid = false;
              result.addMessage(this.labels.Please_correct_issues);
            }
          }
        }
      });

      console.log('selection: ', JSON.parse(JSON.stringify(selection)));

      data.forEach(item => {
        console.log('validation: product type:', item.Product2.ProductType__c);
        if (item.Product2.ProductType__c === 'Asset') {
          console.log('product is asset...');
          if (!uniqProducts.has(item.Product2.Id)) {
            console.log('Add product to uniq:', JSON.parse(JSON.stringify(item)));
            uniqProducts.add(item.Product2.Id);
          } else {
            //fail
            result.valid = false;
            result.addMessage(this.labels.Error_optional_and_standalone_product.replace('{0}', item.Product2.Name).replace('{1}', item.Product2.Id));
          }
        }

        if (item.hasOwnProperty('_children')) {
          item._children.forEach(children => {
            console.log('validation: product children type:', children.Product2.ProductType__c, children.Product2.ProductType__c.length, children.Product2.ProductType__c === 'Asset');
            if (children.Product2.ProductType__c === 'Asset') {
              console.log('option is asset...');
              if ((selection.hasOwnProperty(item.Product2.Id) && selection[item.Product2.Id].includes(children.Product2.Id)) || children.Mandatory__c === true) {
                console.log('Option is selected:', JSON.parse(JSON.stringify(children)));

                if (!uniqProducts.has(children.Product2.Id)) {
                  uniqProducts.add(children.Product2.Id);
                  console.log('Add children product to uniq:', JSON.parse(JSON.stringify(children)));
                } else {
                  //fail..
                  result.valid = false;
                  result.addMessage(this.labels.Error_optional_and_standalone_product.replace('{0}', children.Product2.Name).replace('{1}', children.Product2.Id));
                }
              }
            }
          });
        }
        
      });

    }

    return  result;
  }

  fireSave() {
    this._recordsForSave = [];

    if (this.records) {
      this.disableSave = true;
      let fieldConfig;

      try {
      this.errors = [];
      const validationResult = this.performDataValidation(this.records, this.currentSelection);

      if (!validationResult.valid) {
        this.errors.push({ message: validationResult.message });
        this.disableSave = undefined;
        return;
      }

    } catch (e) {
      console.log('Exception:', e);
    }


      this.columns.forEach(cfg => {
        if (cfg.fieldName === '_selectedOption') {
          fieldConfig = cfg;
        }
      });

      if (fieldConfig) {
        this.records.forEach(record => {
          let recordCopy = JSON.parse(JSON.stringify(record));

          if (recordCopy.hasOwnProperty('_children')) {
            let childrens = [];

            recordCopy._children.forEach(children => {
              if (
                this.currentSelection[recordCopy.Product2.Id] &&
                this.currentSelection[recordCopy.Product2.Id].find(cs => cs === children.Product2.Id)
              ) {
                childrens.push(children);
              } else if (fieldConfig.mandatoryField && children[fieldConfig.mandatoryField]) {
                childrens.push(children);
              }
            });

            recordCopy._children = childrens;
          }

          this._recordsForSave.push(recordCopy);
        });
      }

      const evt = new CustomEvent('triggersave', {});
      this.dispatchEvent(evt);
    }
  }

  fireBack() {
    const evt = new CustomEvent('back', {
      detail: {
        goto: 'search'
      }
    });

    this.executed = false;
    this.dispatchEvent(evt);
  }

  onSelectionChange(evt) {
    //this.currentSelection
    let selection = [];

    if (this.currentSelection.hasOwnProperty(evt.detail.parentId)) {
      selection = this.currentSelection[evt.detail.parentId];
      console.log('current section is:', JSON.parse(JSON.stringify(selection)));
    }

    if (evt.detail.value) {
      if (!selection.find(item => item === evt.detail.recordId)) {
        selection.push(evt.detail.recordId);
      }
    } else {
      console.log('Attempt to remove :', evt.detail.recordId, 'from ', JSON.parse(JSON.stringify(selection)));
      selection = selection.filter(item => {
        if (item === evt.detail.recordId) {
          return false;
        }

        return true;
      });
    }

    this.currentSelection[evt.detail.parentId] = selection;

    console.log('this.currentSelection::', JSON.parse(JSON.stringify(this.currentSelection)));
    
    //invoke lines calculation
    this.records = JSON.parse(JSON.stringify(this._records));
  }
}