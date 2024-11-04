import { LightningElement, track, wire } from 'lwc';
import getAllParties from '@salesforce/apex/PartyController.getAllParties';
import getUserChoice from '@salesforce/apex/ChoiceController.getUserChoice';
import createOrUpdateChoice from '@salesforce/apex/ChoiceController.createOrUpdateChoice';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';

export default class PartyChoice extends LightningElement {
    @track parties = [];
    @track selectedPartyId = '';
    @track comment = '';
    @track isBlankVoteSelected = false;
    @track successMessage;
    @track hasExistingChoice = false;

    @wire(CurrentPageReference)
    pageRef;
   

    connectedCallback() {
        this.getUserChoice();
        this.fetchParties();
    }

    getUserChoice() {
        getUserChoice()
            .then((choice) => {
                if (choice) {
                    this.hasExistingChoice = true;
                    this.selectedPartyId = choice.Party__c || '';
                    this.comment = choice.Comment__c || '';
                    this.isBlankVoteSelected = !choice.Party__c;  // אם אין Party Id, נבחר הצבעה ריקה
                    this.updatePartySelection();
                }
            })
            .catch(error => {
                console.error('Error fetching user choice:', error);
            });
    }

    fetchParties() {
        getAllParties()
            .then(data => {
                this.parties = data.map(party => ({
                    ...party,
                    isSelected: party.Id === this.selectedPartyId,
                    cssClass: party.Id === this.selectedPartyId ? 'party-card selected' : 'party-card'
                }));
            })
            .catch(error => {
                console.error('Error fetching parties:', error);
            });
    }

    handlePartySelect(event) {
        const selectedElement = event.currentTarget;
        this.selectedPartyId = selectedElement ? selectedElement.dataset.id : '';
        this.isBlankVoteSelected = false;

        // Update party selection
        this.parties = this.parties.map(party => ({
            ...party,
            isSelected: party.Id === this.selectedPartyId,
            cssClass: party.Id === this.selectedPartyId ? 'party-card selected' : 'party-card'
        }));
    }

    handleBlankVoteSelect() {
        if (this.isBlankVoteSelected) {
            this.isBlankVoteSelected = false;
            this.selectedPartyId = '';
        } else {
            //blank vote selected
            this.isBlankVoteSelected = true;
            this.selectedPartyId = '';
            this.parties = this.parties.map(party => ({
                ...party,
                isSelected: false,
                cssClass: 'party-card' // remove "selected"
            }));
        }
        this.updatePartySelection();
    }
    

    @wire(getAllParties)
    wiredParties({ error, data }) {
        if (data) {
            this.parties = data.map(party => ({
                ...party,
                isSelected: party.Id === this.selectedPartyId
            }));
        } else if (error) {
            console.error('Error fetching parties:', error);
        }
    }

    handleCommentInput(event) {
        this.comment = event.target.value;
    }

    handleSaveChoice() {
        createOrUpdateChoice({
            partyId: this.selectedPartyId || null,
            comment: this.isBlankVoteSelected ? this.comment : ''
        })
        .then(() => {
            this.successMessage = 'Your choice has been saved successfully!';
            this.hasExistingChoice = true;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: this.successMessage,
                variant: 'success'
            }));
        })
        .catch(error => {
            console.error('Error saving choice:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to save choice: ' + (error.body ? error.body.message : error.message),
                variant: 'error'
            }));
        });
    }

    updatePartySelection() {
        this.parties = this.parties.map(party => ({
            ...party,
            isSelected: party.Id === this.selectedPartyId,
            cssClass: party.Id === this.selectedPartyId ? 'party-card selected' : 'party-card'
        }));
    
        if (this.isBlankVoteSelected) {
            this.template.querySelector('.blank-vote').classList.add('selected');
        } else {
            const blankVoteElement = this.template.querySelector('.blank-vote');
            if (blankVoteElement) {
                blankVoteElement.classList.remove('selected');
            }
        }
    }

    get isSaveDisabled() {
        return !this.selectedPartyId && !this.isBlankVoteSelected;
    }

    get getBlankVoteClass() {
        return `blank-vote ${this.isBlankVoteSelected ? 'selected' : ''}`;
    }

    stopPropagation(event) {
        event.stopPropagation();
    }
    
}