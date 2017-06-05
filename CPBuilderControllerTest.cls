@isTest
public with sharing class CPBuilderControllerTest
{
    testmethod
        public static void test()
    {
        
        List<Attachment> attList = new List<Attachment>();
        
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
        
        //insert attachments to contact        
        Attachment v_Att = new Attachment();
        v_Att.Body = Blob.valueOf('This is contact File.');
        v_Att.Name = 'test1.pdf';
        v_Att.ParentId = contact.ID;
        attList.add(v_Att);
        
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
        
        //DeleteAttachmentsTrigger__c custom setting
        DeleteAttachmentsTrigger__c v_DelCustomSetting = new DeleteAttachmentsTrigger__c(Name = 'DeleteAttachmentTrigger');
        v_DelCustomSetting.Active__c = false;
        insert v_DelCustomSetting;
        
        //insert attachments to credential        
        Attachment v_Att1 = new Attachment();
        v_Att1.Body = Blob.valueOf('This is credential File.');
        v_Att1.Name = 'test1.pdf';
        v_Att1.ParentId = credential.ID;
        attList.add(v_Att1);
        
        ID licenseRecordTypeId = Schema.SObjectType.TRHC__Credentials_Additional_Information__c.getRecordTypeInfosByName().get('License').getRecordTypeId();
        
        TRHC__Credentials_Additional_Information__c addInfo = new TRHC__Credentials_Additional_Information__c();
        addInfo.TRHC__Candidate__c = contact.Id;
        addInfo.RecordTypeId = licenseRecordTypeId;
        insert addInfo;
        
        //insert attachments to credential        
        Attachment v_Att2 = new Attachment();
        v_Att2.Body = Blob.valueOf('This is License File.');
        v_Att2.Name = 'test1.pdf';
        v_Att2.ParentId = credential.ID;
        attList.add(v_Att2);
        
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
        
        //insert attachments to reference        
        Attachment v_Att3 = new Attachment();
        v_Att3.Body = Blob.valueOf('This is Reference File.');
        v_Att3.Name = 'test1.pdf';
        v_Att3.ParentId = reference.ID;
        attList.add(v_Att3);
        
        //skills checklist insert
        TRHC__Skill_Answers__c v_SkillAnswer = new TRHC__Skill_Answers__c();
        v_SkillAnswer.TRHC__Skill_Checklist_Name__c = 'Test';
        v_SkillAnswer.TRHC__Assessment_Type__c ='Checklist';
        v_SkillAnswer.TRHC__Results_URL__c = 'https://google.com';
        v_SkillAnswer.TRHC__Contact__c = contact.Id;
        insert v_SkillAnswer;
        
        //insert attachments to reference        
        Attachment v_Att4 = new Attachment();
        v_Att4.Body = Blob.valueOf('This is Reference File.');
        v_Att4.Name = 'test1.pdf';
        v_Att4.ParentId = v_SkillAnswer.ID;
        attList.add(v_Att4);
        
        //Assesment record
        TRHC__Assessment__c v_Assesment = new TRHC__Assessment__c();
        v_Assesment.TRHC__Assessment_Type__c = 'Situational';
        v_Assesment.TRHC__Assessment_Name__c = 'Clinical Competence - ICU';
        v_Assesment.TRHC__Results_URL__c = 'https://google.com';
        v_Assesment.TRHC__Contact__c = contact.Id;
        insert v_Assesment;
        
        //insert attachments
        Attachment v_Att5 = new Attachment();
        v_Att5.Body = Blob.valueOf('This is Assesment File.');
        v_Att5.Name = 'test1.pdf';
        v_Att5.ParentId = v_Assesment.ID;
        attList.add(v_Att5);
        
        //background check record
        TRHC__Background_Check__c v_BackGroundchk = new TRHC__Background_Check__c();
        v_BackGroundchk.TRHC__Screenings__c = 'Education Verification';
        v_BackGroundchk.TRHC__Contact__c = contact.Id;
        insert v_BackGroundchk;
        
        //insert attachments
        Attachment v_Att6 = new Attachment();
        v_Att6.Body = Blob.valueOf('This is Background check File.');
        v_Att6.Name = 'test1.pdf';
        v_Att6.ParentId = v_BackGroundchk.ID;
        attList.add(v_Att6);
        
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
        
        //insert attachments 
        insert attList;
        
        //update attachment id on objects
        credential.TRHC__Attachment_ID__c = v_Att1.id ;
        update credential;
        
        addInfo.TRHC__Attachment_ID__c = v_Att2.id ;
        update addInfo;
        
        PageReference testPage = Page.CandidatePresentationFileOpener;
        test.setCurrentPage(testPage);       
        ApexPages.currentPage().getParameters().put('Id', applicant.Id);
        CPBuilderController controller = new CPBuilderController();
        controller.initiateCPObject();//call initial method of controller        
        List<TRHC__ETCObject__c> tempCandPres = [select id,TRHC__Candidate__c from TRHC__ETCObject__c where TRHC__Candidate__c = :contact.Id and TRHC__Status__c = 'Candidate Presentation' and TRHC__Type__c = 'Candidate Presentation'];
        //System.assertEquals(0,tempCandPres.size());
        
        controller.initiateCPObject();//Reintiate to check it is not creating second candpresentation reference object
        List<TRHC__ETCObject__c> tempCandPres1 = [select id,TRHC__Candidate__c from TRHC__ETCObject__c where TRHC__Candidate__c = :contact.Id and TRHC__Status__c = 'Candidate Presentation' and TRHC__Type__c = 'Candidate Presentation'];
        //System.assertEquals(0,tempCandPres1.size());
        
        //select files/records to build presentation file
        for(CPBuilderController.AttachmentItem item : controller.candidateAttachments)               
            item.selected = true;                       
        
        for (CPBuilderController.CredentialItem item : controller.credentials)
            item.selected = true;
        
        for (CPBuilderController.LicenseItem item : controller.licenses)
            item.selected = true;
        
        for (CPBuilderController.SkillChecklistItem item : controller.skillchecklists)
            item.selected = true;
        
        for (CPBuilderController.AssesmentItem item : controller.assesments)
            item.selected = true;
        
        for (CPBuilderController.ReferenceItem item : controller.references)
            item.selected = true;
        
        for (CPBuilderController.BackGroundCheckItem item : controller.backgroundchecks)
            item.selected = true;
        
        controller.previewPresentation();
        controller.generatePresentation();      
        
        //return to job applicant
        controller.returnToPrvPage();
        
    }
}