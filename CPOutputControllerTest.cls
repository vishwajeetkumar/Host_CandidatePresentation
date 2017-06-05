@isTest
public with sharing class CPOutputControllerTest
{
	testmethod
	public static void test()
	{
		TRHC__Config_Settings__c settings = new TRHC__Config_Settings__c();
		settings.TRHC__Fill_Cover_Letter_and_Write_Up__c = false;
		settings.Name = 'Default';
		insert settings;

		TRHC__CredentialsCustomSettings__c credentialCustomSettings = new TRHC__CredentialsCustomSettings__c();
		credentialCustomSettings.Name = 'Default';
		insert credentialCustomSettings;
        
        TRHC__Healthcare_Setting__c health = new TRHC__Healthcare_Setting__c(
			Name='Default',
			TRHC__Clone_scrachsheet_if_applicant_created__c = false,
			Clone_Scr_at_Job_App_Host__c = true
			);
		insert health;

		Account account = new Account();
		account.Name = 'FC Barcelona';
		insert account;

		TRHC__Job__c job = new TRHC__Job__c();
		job.TRHC__Account_Lookup__c = account.Id;
		insert job;

		Contact contact = new Contact();
		contact.LastName = 'Messi';
        contact.RecordTypeID = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Candidate').getRecordTypeId();
		insert contact;

		TRHC__Job_Applicant__c applicant = new TRHC__Job_Applicant__c();
		applicant.TRHC__Contact_Candidate__c = contact.Id;
		applicant.TRHC__Job__c = job.Id;
        applicant.License_Status__c = 'Active';
        applicant.Time_Off_Requested__c = 'Test Status';
		insert applicant;

		TRHC__Educational_History__c edHis = new TRHC__Educational_History__c();
		edHis.TRHC__Candidate__c = contact.Id;
		insert edHis;

		TRHC__Employment_History__c empHis = new TRHC__Employment_History__c();
		empHis.TRHC__Candidate__c = contact.Id;
		insert empHis;

		TRHC__Credentials__c credential = new TRHC__Credentials__c();
		credential.TRHC__Contact__c = contact.Id;
		insert credential;

		TRHC__Credentials_Additional_Information__c addInfo = new TRHC__Credentials_Additional_Information__c();
		addInfo.TRHC__Candidate__c = contact.Id;
		insert addInfo;
        
        //insert reference
        TRHC__References__c reference =  new TRHC__References__c();
        reference.TRHC__Organization_Institution__c = 'Org Name';
        reference.TRHC__Organization_Phone__c = '1234567890';
        reference.TRHC__First_Name__c = 'First Name';
        reference.TRHC__Last_Name__c = 'Last Name';
        reference.TRHC__Notes__c = 'Test';
        reference.TRHC__Reference_Date__c = system.today();
        reference.TRHC__Reference_Is_Was_My__c = 'Teacher (Professor, Instructor)';
        reference.TRHC__Candidate__c =  contact.Id;
        insert reference;            
        
        //insert custom setting
        TRHC__Candidate_Presentation__c customsetting = TRHC__Candidate_Presentation__c.getInstance();
        customsetting.TRHC__Drawloop_DDP_URL__c = '/apex/loop__looplus?sessionId={0}&eid={1}&attachids=all&ddpIds=&autorun=false&header=false&sidebar=false&retURL=apex/CandidatePresentationFileOpener?Id={2}';
        customsetting.TRHC__Credential_Fields__c = 'TRHC__Expiration_Date__c, TRHC__Credential_Master_Name__c, TRHC__Attachment_ID__c';
        customsetting.TRHC__Education_Fields__c = 'TRHC__DegreeDate__c,TRHC__DegreeName__c,TRHC__SchoolName__c,TRHC__Major__c,TRHC__City__c,TRHC__StateProvince__c,TRHC__Country__c';
		customsetting.TRHC__Employment_Fields__c = 'TRHC__Start_Date__c, TRHC__End_Date__c, TRHC__City__c, TRHC__Country__c, TRHC__JobDuties__c, TRHC__EmployerOrgName__c';
        customsetting.TRHC__Job_Information__c = 'TRHC__Job_Title__c';
        customsetting.TRHC__License_Fields__c = 'Name, TRHC__State__c, TRHC__License_Number__c, TRHC__Expiration_Date__c';
        customsetting.TRHC__Personal_Info_Fields__c = 'Name,Phone,TRHC__Best_time_day_to_reach_you__c';
        customsetting.TRHC__Reference_Fields__c = 'Name, TRHC__Organization_Institution__c, TRHC__Organization_Phone__c, TRHC__First_Name__c, TRHC__Last_Name__c,TRHC__Notes__c,TRHC__Reference_Date__c,TRHC__Reference_Is_Was_My__c';
        
        if(customsetting.id == null)
        	insert customsetting;
        else
            update customsetting;
            
            
		ApexPages.currentPage().getParameters().put('Id', applicant.Id);
		ApexPages.currentPage().getParameters().put('educationHistoryIds', edHis.Id);
		ApexPages.currentPage().getParameters().put('employmentHistoryIds', empHis.Id);
		ApexPages.currentPage().getParameters().put('credentialIds', credential.Id);
		ApexPages.currentPage().getParameters().put('licenseIds', addInfo.Id);
        ApexPages.currentPage().getParameters().put('referenceIds', reference.Id);

		CPOutputController controller = new CPOutputController();
	}
}