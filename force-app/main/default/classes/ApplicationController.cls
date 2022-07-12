public class ApplicationController {

    public Boolean submitted {get;set;}
    public JobApp__c jobApp {get;set;}
    public List<String> errorMessages {get;set;}
    public Boolean isValidMotivation {get;set;}
    public Boolean isValidCV {get;set;}
    public Boolean isRejectedApplication {get;set;}
  
    public Transient Attachment attachment {
    get {
        if (attachment == null)
        attachment = new Attachment();
        return attachment;
    }
        set;
    }
    
    public ApplicationController(ApexPages.StandardController sc) {
		init();
    }
    
    public ApplicationController() {
		init();    
    }    
    
    public void init() {
        
        jobApp = new jobApp__c();
        
        Id recordTypeId = [SELECT Id FROM RecordType
                                WHERE DeveloperName = 'French_Application' AND sObjectType = 'JobApp__c'].Id;
            
        jobApp.RecordTypeId = recordTypeId;
        
        jobApp.HowDoYouFindUs__c       = ApexPages.currentPage().getParameters().get('source');
        jobApp.Profile__c              = ApexPages.currentPage().getParameters().get('profile');
        jobApp.TargetedPosition__c     = ApexPages.currentPage().getParameters().get('position');
        
        if(jobApp.HowDoYouFindUs__c == 'Shortlist') {
            jobApp.GDPR_Consent__c = true;
        }
        
        this.isValidMotivation = true;
        this.isValidCV = true;
        this.isRejectedApplication = false;
        
        this.submitted = false;
    }
    
    public PageReference upload() {
        
        this.isValidMotivation = true;
        this.isValidCV = true;
        this.isRejectedApplication = false;
        this.jobApp.Id = null;
        
        errorMessages = new List<String>();
        
        List<JobApp__c> jaList = [SELECT Id FROM JobApp__c WHERE Email__c = :jobApp.Email__c];
        
        
        // Check if application has already been rejected        
        if(jaList.size() > 0) {
            this.isRejectedApplication = true;
            errorMessages.add('Une candidature a déjà été soumise pour cette personne.');
        }
        else {
        
            jobApp.FirstName__c = jobApp.FirstName__c.capitalize();
            jobApp.LastName__c = jobApp.LastName__c.capitalize();
                
            String p = jobApp.Phone__c;
            if(p.length() == 10) {
                jobApp.Phone__c = p.substring(0, 2)+' '+ p.substring(2, 4) +' '+ p.substring(4, 6) +' '+ p.substring(6, 8) +' '+ p.substring(8, 10);            
            }
        
            jobApp.Name = jobApp.Salutations__c + ' '+ jobApp.FirstName__c +' '+ jobApp.LastName__c.toUpperCase();
            
            Set<String> motivationsMandatorySet = new Set<String>{'JobTeaser', 'LinkedIn'};
            
            if(jobApp.ConsultingMotivations__c == null && motivationsMandatorySet.contains(jobApp.HowDoYouFindUs__c)) {
                this.isValidMotivation = false;
                errorMessages.add('Vous devez rédiger une lettre de motivation. ');
            }
            else {
                this.isValidMotivation = true;
            }
            
            if(attachment != null && attachment.body != null ) {
            
                 if((isValidMotivation && !isRejectedApplication) || jobApp.HowDoYouFindUs__c == 'Shortlist') {
                
                    Savepoint sp = Database.setSavepoint();
        
                    try {
                        insert jobApp;    
                        
                        attachment.ParentId = jobApp.Id;
                        insert attachment;
                        
                        attachment.body = null;
                        attachment = null;
                        
                        this.submitted = true;
                                        
                    }
                    catch(Exception e) {
                        Database.rollback(sp);
                        errorMessages.add(e.getMessage());
                        resetJobAppId();                    
                    }
                    finally {
                        attachment.body = null;
                        attachment      = null;
                    }   
                }
            }
            else {
                isValidCV = false;
                 errorMessages.add('Vous devez ajouter un CV.');
            }           
        }

        return null;
    }
    
    /*
    public ContentDocumentLink createContentDocumentLink(Id contentDocumentId, Id parentId){
    
        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: contentDocumentId].ContentDocumentId;
        contentDocumentLink.LinkedEntityId = parentId;
        contentDocumentLink.ShareType = 'I'; // Inferred permission
        contentDocumentLink.Visibility = 'InternalUsers';
        return contentDocumentLink;
    }    
	*/
    
    public void resetJobAppId() {
    
        JobApp__c previousJobApp = jobApp.clone();
        this.jobApp = new JobApp__c();
        this.jobApp = previousJobApp;
    }
}