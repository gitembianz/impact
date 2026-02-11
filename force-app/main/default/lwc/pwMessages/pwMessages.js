import { LightningElement, api, track } from 'lwc';

const VARIANTS = {
  default: 'utility:info',
  success: 'utility:success',
  warning: 'utility:warning',
  error: 'utility:clear'
};

export default class PwMessages extends LightningElement {

  /** Generic / user-friendly message */
  @api message = ''; //'Fatal error occured';
  /** Single or array of LDS errors */
  @api errors;

  @api
  get variant() {
    return this._variant;
  }

  @track iconName = VARIANTS.info;
  @track viewDetails = false;

  _variant = 'error';

  set variant(value) {
    if (VARIANTS[value]) {
      this._variant = value;
      this.iconName = VARIANTS[value];
    }
  }

  get errorMessages() {
    console.log(this.reduceErrors(this.errors));
    return this.reduceErrors(this.errors);
  }

  handleCheckboxChange(event) {
    this.viewDetails = event.target.checked;
  }

  reduceErrors(err) {
    if (!Array.isArray(err)) {
      err = [err];
    }

    return (
      err
        // Remove null/undefined items
        .filter(error => !!error)
        // Extract an error message
        .map(error => {
          // UI API read errors
          if (Array.isArray(error.body)) {
            return error.body.map(e => e.message);
          }
          // UI API DML, Apex and network errors
          else if (error.body && typeof error.body.message === 'string') {
            return error.body.message;
          }
          // JS errors
          else if (typeof error.message === 'string') {
            return error.message;
          }
          // Unknown error shape so try HTTP status text
          return error.statusText;
        })
        // Flatten
        .reduce((prev, curr) => prev.concat(curr), [])
        // Remove empty strings
        .filter(message => !!message)
    );
  }
}