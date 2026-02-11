import { LightningElement, api, track } from 'lwc';
import currency from '@salesforce/i18n/currency';
import timeZone from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';

export default class PwPriceConfigurationItem extends NavigationMixin(LightningElement) {
  @api parentId;

  @api
  value;

  @api
  readOnlyFields = ['ListPrice'];

  @api
  isValid() {
    if (this.isEditable && this.isInput) {
      const input = this.template.querySelector('lightning-input');

      if (!input) {
        console.log('this.template.querySelector(\'lightning-input[type^="checkbox"]\') return null...');
        return true;
      }
      
      return input.reportValidity();
    }

    return true;
  }


  @track 
  recordPageURL = '';

  @api
  set config(value) {
    //remove proxy class which treat this value as readonly
    value = JSON.parse(JSON.stringify(value));
    if (!value.hasOwnProperty('type')) {
      value.type = 'text';
    }

    this._config = value;
    this.onConfigured();
  }

  get config() {
    return this._config;
  }

  @api
  set recordId(value) {
    this._recordId = value;
    this.onConfigured();
  }

  get recordId() {
    return this._recordId;
  }

  @api
  set record(value) {
    this._record = value;
    this.onConfigured();
  }

  get record() {
    return this._record;
  }
  

  @api
  set level(value) {
    this._level = value;
    this.onConfigured();
  }

  get level() {
    return this._level;
  }

  @track
  isHeading = false;

  @track
  isNotHeading = false;

  @track
  isUnsupported = true;

  @track
  isCheckbox = false;

  @track
  isInput = false;

  @track
  isChecked;

  @track
  isMandatory = false;

  @track
  formatter;

  @track
  step = 0.01;

  @track
  type;


  @track
  isPercentType = false;

  @track
  isCurrencyType = false;

  @track
  isDateType = false;

  @track
  isOtherType = false;

  @track
  isNumberType = false;

  @track
  isDateTimeType = false;

  @track
  tz = timeZone;

  @track
  currenyCode = currency;

  setType() {
    this.type = this.config.type;

    this.isPercentType = false;
    this.isCurrencyType = false;
    this.isDateType = false;
    this.isOtherType = false;
    this.isNumberType = false;
    this.isDateTimeType = false;
    this.isBoolean = false;
    this.isMandatory = false;

    switch (this.type.toLowerCase()) {
      case 'currency':
        this.isCurrencyType = true;
        break;
      case 'percent':
        this.isPercentType = true;
        this.formatter = 'number';
        //this.isNumberType = true;
        this.type = 'number';
        break;
      case 'date':
        this.isDateType = true;
        break;
        case 'datetime':
        this.isDateTimeType = true;
        break;
      case 'number':
        this.isNumberType = true;
        break;
      case 'boolean':
        this.isBoolean = true;
        break;
      default:
        this.isOtherType = true;
    }
  }

  validateConfig(config) {
    if (!config) {
      return false;
    }

    if (!config.hasOwnProperty('fieldName')) {
      console.log('validateConfig: fieldName is not supplied.');
      return false;
    }

    if (!config.hasOwnProperty('type')) {
      console.log('validateConfig: `type` is not supplied.');
      return false;
    }

    const supportedTypes = ['text', 'string', 'currency', 'date', 'phone', 'url', 'number', 'percent', 'checkbox', 'boolean'];

    if (!supportedTypes.includes(config.type)) {
      console.log(`validateConfig: '${config.type}' type is not supported.`);
      return false;
    }

    return true;
  }

  checkIsEditable(config) {
    const editableTypes = ['currency', 'number', 'percent', 'checkbox'];

    if (config.hasOwnProperty('readonly')) {
      if (config.readonly) {
        return false;
      }
    }

    if (this.readOnlyFields && this.readOnlyFields.includes(config.fieldName)) {
      return false;
    }

    return editableTypes.includes(config.type);
  }

  setValue() {
    if (this.record.hasOwnProperty(this.config.fieldName)) {
      this.value = this.record[this.config.fieldName];
    } else {
      if (this.config.fieldName.indexOf('.') !== -1) {
        //it is a child object
        let object = this.config.fieldName.split('.')[0];
        let field =  this.config.fieldName.split('.')[1];

        if (this.record.hasOwnProperty(object)) {
          if (this.record[object].hasOwnProperty(field)) {
            this.value = this.record[object][field];
            return;
          }
        }
      }

      this.value = '';
    }
  }

  onConfigured() {
    if (!this.config || !this.recordId || !this.level) {
      return;
    }

    if (!this.validateConfig(this.config)) {
      this.isHeading = false;
      this.isNotHeading = false;
      this.isUnsupported = true;

      return;
    }

    this.setType();

    if (this.config.fieldName.toLowerCase() === 'product2.name') {
      this.isHeading = true;
      this.isNotHeading = false;
      this.isUnsupported = false;
    } else {
      this.isHeading = false;
      this.isNotHeading = true;
      this.isUnsupported = false;
    }

    this.isEditable = this.checkIsEditable(this.config);
    this.setValue();

    if (this.isEditable) {
      if (this.config.type === 'checkbox') {
        if (this.level === '2') {
          this.isCheckbox = true;
          this.isInput = false;

          this.setCheckboxProperties();
        }
      } else {
        this.isCheckbox = false;
        this.isInput = true;
      }
    }

    /* For some unknown reason, this does not works!
    let productDetailPageRef = {
      type: 'standard__recordPage',
      attributes: {
        recordId: this.recordId,
        objectApiName: "Product2",
        actionName: "view"
      }
    };
    this[NavigationMixin.GenerateUrl](productDetailPageRef).then(url => {
      console.log('The URL is: ', url);
      this.recordPageURL = url;
    }).catch(error => {
      console.log('Error during generate url:', JSON.stringify(error));
    });
    */

    this.recordPageURL = '/' + this.recordId;
  }

  setCheckboxProperties() {
    if (this.value === true) {
      this.isChecked = true;
    } else {
      this.isChecked = undefined;
    }

    if (this.config.hasOwnProperty('mandatoryField')) {
      
      if (this.record.hasOwnProperty(this.config.mandatoryField)) {
        this.isMandatory = this.record[this.config.mandatoryField] === true ? true:false;
      } else {
        if (this.config.mandatoryField.indexOf('.') !== -1) {
          //it is a child object
          let object = this.config.mandatoryField.split('.')[0];
          let field =  this.config.mandatoryField.split('.')[1];
  
          if (this.record.hasOwnProperty(object)) {
            if (this.record[object].hasOwnProperty(field)) {
              this.isMandatory = this.record[object][field] === true ? true:false;
            }
          }
        }
      }
    }

    if (this.isMandatory) {
      this.isChecked = true;
    }
  }

  onInputChange(evt) {
    this.fireCellChangeEvent(this.config.fieldName, evt.detail.value, this.recordId, this.parentId);
  }

  onCheckboxChange(evt) {
    if (this.isMandatory) {
      evt.target.checked = true;
    }

    this.dispatchEvent(new CustomEvent('selectionchange', {
      detail: {
        value: evt.target.checked,
        recordId: this.recordId,
        parentId: this.parentId
      }
    }));
  }

  fireCellChangeEvent(target, value, recordId, parentId) {
    const evt = new CustomEvent('cellchange', {
      detail: {
        target: target,
        value: value,
        recordId: recordId,
        parentId: parentId
      }
    });

    this.dispatchEvent(evt);
  }
}