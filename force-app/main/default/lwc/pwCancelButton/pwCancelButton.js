import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class PwCancelButton extends NavigationMixin(LightningElement) {
  @api
  title;

  @api
  label;

  @wire(CurrentPageReference)
  currentPageReference;

  handleClick() {
    if (this.currentPageReference && this.currentPageReference.state.c__recordId) {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this.currentPageReference.state.c__recordId,
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
}