/**
*	@author Victor Vargas
*	@date 10/21/2011
*	@version: 1.0
*	@description Class for email service that creates a new case 
*/

global class OnDemand_EmailToCase implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        try{
        	Case newCase = new Case();
        	String emailSubject = email.subject;
        	String contactEmail = '';
        	String caseDescription = email.plainTextBody;
        	List<String> emailBody = email.plainTextBody.split('\n');
        	
        	if(emailSubject.contains('Fw:')==true){
        			newCase.Subject = emailSubject.replace('Fw:', '');
        			contactEmail = getDataFromEmailBody(emailBody, 'Email');
        	}else{
	        	if(emailSubject.contains('Fwd:')==true){
	        			newCase.Subject = emailSubject.replace('Fwd:', '');
        				contactEmail = getDataFromEmailBody(emailBody, 'Email');
	        	}else{
	        		if(emailSubject.contains('FW:')==true){
		    			newCase.Subject = emailSubject.replace('FW:', '');
        				contactEmail = getDataFromEmailBody(emailBody, 'Email');
		    		}else{
		    			newCase.Subject = emailSubject;
		    			contactEmail = email.fromAddress;
		    		}
	        	}	
        	}
        	
        	Contact relatedContact = getContact(contactEmail);
        	
        	if(relatedContact!=null){
        		newCase.ContactId = relatedContact.Id;
        	}else{
        		newCase.SuppliedName = getDataFromEmailBody(emailBody, 'Name');
        		newCase.SuppliedEmail = getDataFromEmailBody(emailBody, 'Email');
        		newCase.SuppliedPhone = getDataFromEmailBody(emailBody, 'Phone');
        	}
        	
        	newCase.Description = caseDescription;
        	insert newCase;
        	
        	result.success = true;
        	
        }catch(Exception e){
        	result.success = false;
        	System.debug('EXCEPTION: '+e);        	
        }
        
        return result;
    }
    
    public Contact getContact(String emailAd){
    	try{
    		Contact resultContact = [Select Id From Contact Where Email=:emailAd Limit 1];
    		return resultContact;
    	}catch(Exception e){
    		return null;
    	}
    }
    
    public String getEmailFromFwBody(List<String> emailBody){
    	String resultString = '';    	    	
    	for(String emailLine: emailBody){
			if(emailLine.contains('From')){
				List<String> emailLineSplited = emailLine.split(' ');
				for(String emailAd: emailLineSplited){
					if(emailAd.contains('<')){
						Integer emailSize = (emailAd.length())-1;
						resultString = emailAd.substring(1,emailSize);
						break;
					}
				}
			}
		}
		return resultString;
    }
        
    public String getDataFromEmailBody(List<String> emailBody, String getData){    	
    	String resultString = ''; 
    	
    	for(String emailLine: emailBody){
			if(emailLine.contains(getData)){
				List<String> emailLineSplited = emailLine.split(':');
				for(String emailData: emailLineSplited){
					if(getData == 'Email'){
						if(emailData.contains('@')){
							resultString = emailData.trim();
							break;
						}
					}else{
						if(getData == 'Name'){
							if(!emailData.contains('Name')){
								resultString = emailData;
								break;
							}
						}else{
							if(!emailData.contains('Phone')){
								resultString = emailData;
								break;
							}
						}
					}
				}
			}
		}
		return resultString;
    }
    
}