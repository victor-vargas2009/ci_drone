public class ContactMessage{
    Contact selContact{get;set;}
    public ContactMessage(ApexPages.StandardController controller) {
        selContact = (Contact)controller.getRecord();
    }

    String account = 'ACf72e26e33a6ff3fd43a6c257ac5e5b13';
    String token = '9c9cf82735f6954a0210eb84673b3231';
    TwilioRestClient client = new TwilioRestClient(account, token);

Map<String,String> params = new Map<String,String> {
        'To'   => '+14153079366',
        'From' => '+16507638309',
        'Body' => 'Hello there!'
    };
    
    public void sendMessageToContact(){
        TwilioSms sms = client.getAccount().getSMSMessages().create(params);
        Task call = new Task();
        call.WhoId = selContact.Id;
        call.Priority = 'Low';
        call.Subject = 'test message';
        insert call;
    }

}