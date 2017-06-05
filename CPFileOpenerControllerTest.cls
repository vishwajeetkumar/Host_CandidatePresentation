/**
* @autor vishwajeet kumar
* @class CPFileOpenerControllerTest 
* @description Test Class for class-"CPFileOpenerController".
* */
@isTest
public class CPFileOpenerControllerTest {
    
    //Method to intiate test data
    @testSetup static void initData(){
        
        TRHC__Config_Settings__c settings = new TRHC__Config_Settings__c();
        settings.TRHC__Fill_Cover_Letter_and_Write_Up__c = false;
        settings.Name = 'Default';
        insert settings;
        
		TRHC__Healthcare_Setting__c health = new TRHC__Healthcare_Setting__c(
			Name='Default',
			TRHC__Clone_scrachsheet_if_applicant_created__c = false,
			Clone_Scr_at_Job_App_Host__c = true
			);
		insert health;
        
        TRHC__CredentialsCustomSettings__c credentialCustomSettings = new TRHC__CredentialsCustomSettings__c();
        credentialCustomSettings.Name = 'Default';
        insert credentialCustomSettings;   
        
         //DeleteAttachmentsTrigger__c custom setting
        DeleteAttachmentsTrigger__c v_DelCustomSetting = new DeleteAttachmentsTrigger__c(Name = 'DeleteAttachmentTrigger');
        v_DelCustomSetting.Active__c = false;
        insert v_DelCustomSetting;
        
         //insert custom setting
        TRHC__Candidate_Presentation__c customsetting = TRHC__Candidate_Presentation__c.getInstance();
        customsetting.TRHC__Drawloop_DDP_URL__c = '/apex/loop__looplus?sessionId={0}&eid={1}&attachids=all&ddpIds=&autorun=false&header=false&sidebar=false&retURL=apex/CandidatePresentationFileOpener?Id={2}';
        customsetting.TRHC__Credential_Fields__c = 'TRHC__Expiration_Date__c, TRHC__Credential_Master_Name__c, TRHC__Attachment_ID__c';
        customsetting.TRHC__Education_Fields__c = 'TRHC__DegreeDate__c, TRHC__DegreeName__c, TRHC__SchoolName__c, TRHC__Major__c,TRHC__City__c,TRHC__StateProvince__c,TRHC__Country__c';
        customsetting.TRHC__Employment_Fields__c = 'TRHC__Start_Date__c, TRHC__End_Date__c, TRHC__City__c, TRHC__Country__c, TRHC__JobDuties__c, TRHC__EmployerOrgName__c';
        customsetting.TRHC__Job_Information__c = 'TRHC__Job_Title__c';
        customsetting.TRHC__License_Fields__c = 'Name, TRHC__State__c, TRHC__License_Number__c, TRHC__Expiration_Date__c';
        customsetting.TRHC__Personal_Info_Fields__c = 'Name,Phone,TRHC__Best_time_day_to_reach_you__c';
        customsetting.TRHC__Reference_Fields__c = 'Name, TRHC__Organization_Institution__c, TRHC__Organization_Phone__c, TRHC__First_Name__c, TRHC__Last_Name__c,TRHC__Notes__c,TRHC__Reference_Date__c,TRHC__Reference_Is_Was_My__c';
        
        if(customsetting.id == null)
            insert customsetting;
        else
            update customsetting;
        
        Account account = new Account(Name = 'My Account',BillingState='TN');
        insert account;
        
        Contact contact = new Contact();
        contact.LastName = 'Test1';
        contact.AccountId=account.Id;
        contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
		insert contact;
        
        TRHC__Job__c  job = new TRHC__Job__c (
            TRHC__Job_Title__c = 'Test',
            TRHC__Account_Lookup__c=account.id,
            TRHC__Start_Date__c = Date.today());
        insert job;
        
        List<TRHC__Job_Applicant__c> jobApplicants = new List<TRHC__Job_Applicant__c>{
            new TRHC__Job_Applicant__c(
                TRHC__Contact_Candidate__c = contact.Id,
                TRHC__Job__c = job.Id,
                License_Status__c = 'Active',
                Time_Off_Requested__c = 'Test Status')
           }; 
                    insert jobApplicants;       
        
        //create ETC presentation object for candidate
        TRHC__ETCObject__c candPres = new TRHC__ETCObject__c(TRHC__Candidate__c = contact.Id,TRHC__Status__c = 'Candidate Presentation',TRHC__Type__c = 'Candidate Presentation'); 
        insert candPres;     
        
        //insert attachment to candidate presentation for testing
        Attachment v_Att = new Attachment();
        v_Att.Body = Blob.valueOf('This is Presentation File generated after merge from Drawloop.');
        v_Att.Name = 'Candidate Presentation.pdf';
        v_Att.ParentId = candPres.ID;
        insert v_Att;         
        
    }
    
    //test controller
    @isTest static void testController(){
        Test.startTest();        
        TRHC__ETCObject__c candPres = [Select id from TRHC__ETCObject__c LIMIT 1];
        TRHC__Job_Applicant__c jobApplicant = [select id,TRHC__Contact_Candidate__c 
                                               from TRHC__Job_Applicant__c LIMIT 1];
        
        CPFileOpenerController v_Controller = new CPFileOpenerController();
        //testing page 'CandidatePresentationFileOpener'
        PageReference testPage = Page.CandidatePresentationFileOpener;
        test.setCurrentPage(testPage);
        ApexPages.currentPage().getParameters().put('id', '');
        v_Controller.initController();
        
        //set id parameter
        String allId = candPres.id ;
        ApexPages.currentPage().getParameters().put('id', allId);
        v_Controller.initController();        
        
        //save to Ja
        v_Controller.saveToJA();
        //Save to Contact
        v_Controller.saveToContact();
        
        //set all required parameters
        String allId1 = candPres.id +','+ jobApplicant.id + ',' + jobApplicant.TRHC__Contact_Candidate__c;        
        ApexPages.currentPage().getParameters().put('id', allId1);
        v_Controller.initController();        
        
        //save to Ja
        v_Controller.saveToJA();
        List<Attachment> jobAppAttList = [Select id from Attachment where parentId = :jobApplicant.id];
        system.assertEquals(1, jobAppAttList.size());
        //Save to Contact
        v_Controller.saveToContact();
        List<Attachment> contactAttList = [Select id from Attachment where parentId = :jobApplicant.TRHC__Contact_Candidate__c];
        system.assertEquals(1, contactAttList.size());
        
        Test.stopTest();
        
    }
    
    
}