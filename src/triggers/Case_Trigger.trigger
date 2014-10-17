/**
*	@author Victor Vargas
*	@date 10/21/2011
*	@version: 1.0
*	@description Trigger for the Case Object
*/

trigger Case_Trigger on Case (before insert) {
	
	if(Trigger.isBefore){
		if(Trigger.isInsert){
			
			//Set for the contact emails in the case and a list for the contacts that will be created
			Set<String> contactEmails = new Set<String>();
			List<Contact> newContacts = new List<Contact>();
			
			//Get the contact email address from the case
			for(Case newCase : Trigger.new){
				if(newCase.Origin=='Web' || newCase.Origin=='Email'){
					if(newCase.ContactId == null){
						if(newCase.SuppliedEmail != null){
							contactEmails.add(newCase.SuppliedEmail);
						}
					}
				}
			}
			
			//If the contact email set is not empty do a query to search in the contacts			
			if(!contactEmails.isEmpty()){
				List<Contact> existingContacts = [Select Id From Contact Where Email in:contactEmails];
				
				//If the contact query returned something assign the case to the contact
				if(!existingContacts.isEmpty()){
					for(Case newCase : Trigger.new){
						for(Contact contact : existingContacts){
							if(newCase.SuppliedEmail == contact.Email){
								newCase.ContactId = contact.Id;
							}
						}
					}
				}
			}
			
			//Get the Name, Phone and email address of those cases that doesn't have a contact assigned
			for(Case newCase : Trigger.new){
				if(newCase.ContactId == null){
					Contact newContact = new Contact();
					newContact.Phone = newCase.SuppliedPhone;
					newContact.Email = newCase.SuppliedEmail;
					String nameSupplied = newCase.SuppliedName;
					if(nameSupplied!= null && nameSupplied!= ''){
						List<String> suppName = nameSupplied.split(' ');
						for(Integer i=0; i<suppName.size();i++){
							if(i==0){
								newContact.FirstName = suppName[i];
							}
							if(i==1){
								newContact.LastName = suppName[i];
							}
						}
						newContacts.add(newContact);
					}
				}
			}
			
			//If the list for the new contacts isn't empty we create new contacts and assigned them to the case with the same supplied email
			if(newContacts.size()>0){
				insert newContacts;
				
				for(Case newCase : Trigger.new){
					for(Contact newContact : newContacts){
						if(newCase.SuppliedEmail==newContact.Email){
							newCase.ContactId = newContact.Id;
						}
					}
				}
			}
		}
	}
	
}