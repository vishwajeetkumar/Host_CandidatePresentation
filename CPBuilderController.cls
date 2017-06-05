public with sharing class CPBuilderController
{
    public with sharing class AttachmentItem
    {
        public Attachment sobj{private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class EducationItem
    {
        public TRHC__Educational_History__c sobj {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class EmploymentItem
    {
        public TRHC__Employment_History__c sobj {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class CredentialItem
    {
        public TRHC__Credentials__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class LicenseItem
    {
        public TRHC__Credentials_Additional_Information__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class SkillChecklistItem
    {
        public TRHC__Skill_Answers__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class AssesmentItem
    {
        public TRHC__Assessment__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class ReferenceItem
    {
        public TRHC__References__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public with sharing class BackGroundCheckItem
    {
        public TRHC__Background_Check__c sobj {private set; get;}
        public AttachmentItem attachment {private set; get;}
        public Boolean selected {set; get;}
    }

    public TRHC__Job_Applicant__c applicant {private set; get;}
    public Contact candidate {private set; get;}
    public TRHC__Job__c job {private set; get;}
    public boolean presentationMode{get;set;}//if page is in presentation mode
    public String previewUrl{get;Private set;}

    public List<EducationItem> educationHistory {private set; get;}
    public List<EmploymentItem> employmentHistory {private set; get;}
    public List<CredentialItem> credentials {private set; get;}
    public List<LicenseItem> licenses {private set; get;}
    public List<SkillChecklistItem> skillchecklists{private set;get;}
    public List<AssesmentItem> assesments{private set;get;}
    public List<ReferenceItem> references{private set;get;}
    public List<BackGroundCheckItem> backgroundchecks{private set;get;}
    private static TRHC__Candidate_Presentation__c customsetting = TRHC__Candidate_Presentation__c.getInstance();
    //public Boolean allAttSelected{get;set;}//variable, true if all items in table is selected.
    public List<AttachmentItem> candidateAttachments {private set; get;}

    private TRHC__ETCObject__c candPresentationNew;//ETC object for place holder of candidate presentation files
    Private Map<String,Candidate_Presentation_Odering__mdt> oderingMap ; //Map to hold infromation about odering of data
    public CPBuilderController()
    {
        //set presentation mode false
        presentationMode = false;
        this.applicant =
            [SELECT Id, Name, TRHC__Job__c, TRHC__Contact_Candidate__c
             FROM TRHC__Job_Applicant__c
             WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        if(this.applicant.TRHC__Contact_Candidate__c != null){
            
            //Populate Ordering Map
            oderingMap = new Map<String,Candidate_Presentation_Odering__mdt>();
            for(Candidate_Presentation_Odering__mdt v_Obj : [Select Object_Name__c,Odering_Field_Name__c,Record_Order_ASC__c from Candidate_Presentation_Odering__mdt]){
				oderingMap.put((v_Obj.Object_Name__c).toLowerCase(),v_Obj);                
            }

            this.candidate =
                [SELECT Name, Phone, TRHC__Best_time_day_to_reach_you__c, TRHC__Available_To_Start__c, TRHC__Preferred_Shifts__c,
                 MailingStreet, MailingCity, MailingState, MailingPostalCode,
                 Email, TRHC__SSN_New__c, Birthdate
                 FROM Contact
                 WHERE Id = :this.applicant.TRHC__Contact_Candidate__c];

            this.candidateAttachments = this.loadAttachments(this.candidate);

            this.job =
                [SELECT Id, TRHC__Account_Lookup__r.Name, TRHC__Hiring_Manager__r.Name, TRHC__Job_Title__c
                 FROM TRHC__Job__c
                 WHERE Id = :this.applicant.TRHC__Job__c];

            this.educationHistory = new List<EducationItem>();
            String v_EduQuery = 'SELECT TRHC__DegreeDate__c, TRHC__DegreeName__c, TRHC__SchoolName__c'
                + ' FROM TRHC__Educational_History__c' 
                + ' WHERE TRHC__Candidate__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
            
            //inforce sorting order, VK, 5/11/2017            
            String v_OrderBySt = getQueryOrderByString('TRHC__Educational_History__c');
            if(String.isNotEmpty(v_OrderBySt))                
                   v_EduQuery += v_OrderBySt; 
           
            for (TRHC__Educational_History__c sobj : DataBase.query(v_EduQuery)) {
                EducationItem item = new EducationItem();
                item.sobj = sobj;
                item.selected = false;
                this.educationHistory.add(item);
            }

            this.employmentHistory = new List<EmploymentItem>();
            String v_EmpQuery = 'SELECT TRHC__Start_Date__c,TRHC__End_Date__c,TRHC__City__c,TRHC__Country__c,'
                + ' TRHC__JobDuties__c, TRHC__EmployerOrgName__c,TRHC__Position_Title__c, TRHC__Position_Type__c,'
                + ' TRHC__StateProvince__c FROM TRHC__Employment_History__c' 
                + ' WHERE TRHC__Candidate__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
            
             //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt1 = getQueryOrderByString('TRHC__Employment_History__c');
            	if(String.isNotEmpty(v_OrderBySt1))                
                   v_EmpQuery += v_OrderBySt1; 
           
            for (TRHC__Employment_History__c sobj : DataBase.query(v_EmpQuery)){
                EmploymentItem item = new EmploymentItem();
                item.sobj = sobj;
                item.selected = false;
                this.employmentHistory.add(item);
            }

            this.credentials = new List<CredentialItem>();
            String v_CredQuery = 'SELECT TRHC__Expiration_Date__c, TRHC__Credential_Master_Name__c,' 
                + ' TRHC__Attachment_ID__c FROM TRHC__Credentials__c' 
                + ' WHERE TRHC__Contact__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
             
            //inforce sorting order, VK, 5/11/2017
            String v_OrderBySt2 = getQueryOrderByString('TRHC__Credentials__c');
            if(String.isNotEmpty(v_OrderBySt2))                
            	v_CredQuery += v_OrderBySt2;
            
            for (TRHC__Credentials__c sobj : DataBase.query(v_CredQuery)){
                CredentialItem item = new CredentialItem();
                item.sobj = sobj;
                item.selected = false;
                if (sobj.TRHC__Attachment_ID__c != null){
                    AttachmentItem v_AttItem = this.loadAttachment(sobj.TRHC__Attachment_ID__c);
                    if(v_AttItem != null)
                    	item.attachment = v_AttItem;  
                }
                    
                this.credentials.add(item);
            }

            ID licenseRecordTypeId = Schema.SObjectType.TRHC__Credentials_Additional_Information__c.getRecordTypeInfosByName().get('License').getRecordTypeId();

            this.licenses = new List<LicenseItem>();
            String v_LicQuery = 'SELECT Name, TRHC__State__c, TRHC__License_Number__c,' 
                + 'TRHC__Expiration_Date__c, TRHC__Attachment_ID__c '
                + ' FROM TRHC__Credentials_Additional_Information__c' 
                + ' WHERE TRHC__Candidate__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\''
                + 'AND RecordTypeId = \'' + licenseRecordTypeId + '\'';
            
            //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt3 = getQueryOrderByString('TRHC__Credentials_Additional_Information__c');
            	if(String.isNotEmpty(v_OrderBySt3))                
                   v_LicQuery += v_OrderBySt3;             
           
            for (TRHC__Credentials_Additional_Information__c sobj : DataBase.query(v_LicQuery)){
                LicenseItem item = new LicenseItem();
                item.sobj = sobj;
                item.selected = false;
                if (sobj.TRHC__Attachment_ID__c != null){                	
                	AttachmentItem v_AttItem = this.loadAttachment(sobj.TRHC__Attachment_ID__c);
                    if(v_AttItem != null)
                    	item.attachment = v_AttItem;               	
                }
                   
                this.licenses.add(item);
            }

            //skills checklist loading
            this.skillchecklists = new List<SkillChecklistItem>();
            
            String v_SkillQuery = 'SELECT id,TRHC__Skill_Checklist_Name__c, TRHC__Assessment_Type__c,' 
                +' TRHC__Results_URL__c FROM TRHC__Skill_Answers__c' 
                + ' WHERE TRHC__Contact__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'' 
                + 'and TRHC__Assessment_Type__c =\'Checklist\'';
            
             //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt5 = getQueryOrderByString('TRHC__Skill_Answers__c');
            	if(String.isNotEmpty(v_OrderBySt5))                
                   v_SkillQuery += v_OrderBySt5;
            
            for (TRHC__Skill_Answers__c sobj : DataBase.query(v_SkillQuery)){
                SkillChecklistItem item = new SkillChecklistItem();
                item.sobj = sobj;
                item.selected = false;
                //if (String.isNotEmpty(sobj.TRHC__Results_URL__c))
                List<AttachmentItem> atts = this.loadAttachments(sobj);
                if(atts != null && atts.size() > 0)
                    item.attachment = this.loadAttachments(sobj).get(0);
                this.skillchecklists.add(item);
            }

            //assesment loading
            this.assesments = new List<AssesmentItem>();
            String v_AsQuery = 'SELECT id, TRHC__Assessment_Type__c,TRHC__Assessment_Name__c,'
				+ ' TRHC__Results_URL__c FROM TRHC__Assessment__c' 
                + ' WHERE TRHC__Contact__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
            
             //inforce sorting order, VK, 5/11/2017
            String v_OrderBySt6 = getQueryOrderByString('TRHC__Assessment__c');
            if(String.isNotEmpty(v_OrderBySt6))                
            	v_AsQuery += v_OrderBySt6;
            
            for (TRHC__Assessment__c sobj : DataBase.query(v_AsQuery)){
                AssesmentItem item = new AssesmentItem();
                item.sobj = sobj;
                item.selected = false;

                List<AttachmentItem> atts = this.loadAttachments(sobj);
                if(atts != null && atts.size() > 0)
                    item.attachment = this.loadAttachments(sobj).get(0);
                //if (String.isNotEmpty(sobj.TRHC__Results_URL__c))
                //item.attachment = this.loadAttachments(sobj).get(0);
                this.assesments.add(item);
            }

            //Reference Loading
            this.references = new List<ReferenceItem>();
            
            String v_RefQuery = 'SELECT id, TRHC__Organization_Institution__c,TRHC__Reference_Date__c,' 
                +' TRHC__Reference_Is_Was_My__c FROM TRHC__References__c'               
                + ' WHERE TRHC__Candidate__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
            
             //inforce sorting order, VK, 5/11/2017
             String v_OrderBySt4 = getQueryOrderByString('TRHC__References__c');
             if(String.isNotEmpty(v_OrderBySt4))                
             	v_RefQuery += v_OrderBySt4;
            
            for (TRHC__References__c sobj : DataBase.query(v_RefQuery)){
                ReferenceItem item = new ReferenceItem();
                item.sobj = sobj;
                item.selected = false;
                List<AttachmentItem> atts = this.loadAttachments(sobj);
                if(atts != null && atts.size() > 0)
                    item.attachment = atts.get(0);
                this.references.add(item);
            }

            //background check loading
            this.backgroundchecks = new List<BackGroundCheckItem>();  
            
             String v_BCQuery = 'SELECT id, Name, TRHC__Screenings__c,TRHC__Order_Status__c'
                 + ' FROM TRHC__Background_Check__c' 
                 + ' WHERE TRHC__Contact__c = \'' + this.applicant.TRHC__Contact_Candidate__c + '\'';
            
             //inforce sorting order, VK, 5/11/2017
            String v_OrderBySt7 = getQueryOrderByString('TRHC__Background_Check__c');
            if(String.isNotEmpty(v_OrderBySt7))                
            	v_BCQuery += v_OrderBySt7;

            for (TRHC__Background_Check__c sobj : Database.query(v_BCQuery)){
                BackGroundCheckItem item = new BackGroundCheckItem();
                item.sobj = sobj;
                item.selected = false;
                List<AttachmentItem> atts = this.loadAttachments(sobj);
                if(atts != null && atts.size() > 0)
                    item.attachment = atts.get(0);
                this.backgroundchecks.add(item);
            }
        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.label.TRHC.Cand_Presentation_Missing_Cand));
            return;
        }


    }

    public PageReference previewPresentation()
    {
        String url = '/apex/CPOutput2?Id=' + applicant.Id;

        String ids = '&educationHistoryIds=';
        for (EducationItem item : this.educationHistory)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            url += ids;
        }

        ids = '&employmentHistoryIds=';
        for (EmploymentItem item : this.employmentHistory)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            url += ids;
        }

        ids = '&credentialIds=';
        for (CredentialItem item : this.credentials)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            url += ids;
        }

        ids = '&licenseIds=';
        for (LicenseItem item : this.licenses)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            url += ids;
        }
        //reference items
        ids = '&referenceIds=';
        for (ReferenceItem item : this.references)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            url += ids;
        }

        return new PageReference(url);
    }

    public PageReference generatePresentation()
    {
        if(String.isNotEmpty(customsetting.TRHC__Drawloop_DDP_URL__c)){
            List<Attachment> attachmentList = new List<Attachment>();
            Set<id> attidSet = new Set<ID>();
            try
            {
                presentationMode = true;//set variable to switch view
                //clear all existing attachments from candidate presentation object
                List<Attachment> deleteList = [Select id from Attachment where parentid = :candPresentationNew.id];
                if(deleteList != null && deleteList.size() > 0)
                    //DB.doSecureDelete(deleteList); VK,05/10/2017
                    delete deleteList;
                /*String allId = candPresentationNew.id +','+ this.applicant.id + ',' + this.candidate.id;
                String pageRefUrl = customsetting.TRHC__Drawloop_DDP_URL__c;
                pageRefUrl = String.format(pageRefUrl, new List<String>{UserInfo.getSessionId(),candPresentationNew.id,allId});VK,05/12/2017*/
                //add job applicant and contact id in url
                // pageRefUrl +='&jaid='+ this.applicant.id + '&conid='+ this.candidate.id;

                // PMD FALSE POSITIVE. URL comes from a custom setting
                //PageReference returnPage = new PageReference(pageRefUrl);
                

                for (AttachmentItem item : this.candidateAttachments)
                {
                    if (item.selected)
                        attidSet.add(item.sobj.Id);
                }

                for (CredentialItem item : this.credentials)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                for (LicenseItem item : this.licenses)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                for (SkillChecklistItem item : this.skillchecklists)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                for (AssesmentItem item : this.assesments)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                for (ReferenceItem item : this.references)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                for (BackGroundCheckItem item : this.backgroundchecks)
                {
                    if (item.selected && item.attachment != null)
                        attidSet.add(item.attachment.sobj.Id);
                }

                //create attachment from profiles
                PageReference profilePage = previewPresentation();
                //if(profilePage.getUrl().contains('&')){--add it all the time.
                    blob profileBody = profilePage.getContentAsPDF();
                    Attachment v_TempAtt1 =  new Attachment(name ='Candidate Profile.pdf', body = profileBody, parentid = candPresentationNew.id);
                    /*DB.doSecureInsert(v_TempAtt1,
                            new Schema.sObjectField[] {
                                    Attachment.name,
                                    Attachment.body,
                                    Attachment.parentid});Vk,05/10*/
                insert v_TempAtt1;
                    //attachmentList.add(v_TempAtt);
                //}

                if(attidSet.size() > 0){
                    List<Attachment> tempAttachmentList = [select id, Name, Body from Attachment where ID IN : attidSet];
                    for(Attachment v_Att : tempAttachmentList){
                        Attachment v_TempAtt =  new Attachment(name =
                                                               v_Att.name, body = v_Att.body, parentid = candPresentationNew.id);
                        attachmentList.add(v_TempAtt);
                    }

                    /*DB.doSecureInsert(attachmentList,
                            new Schema.sObjectField[] {
                                    Attachment.name,
                                    Attachment.body,
                                    Attachment.parentid});vk,5/10/2017*/
                    insert attachmentList;
                }
                
                String v_attachs = v_TempAtt1.ID;
                if(attachmentList.size() > 0){
                    for(Attachment v_Att : attachmentList){
                       v_attachs += ',' + v_Att.id + ',';
                    }
                    
                    v_attachs = v_attachs.substring(0, v_attachs.length() -1);                    
                }
                
				String allId = candPresentationNew.id +','+ this.applicant.id + ',' + this.candidate.id;
                String pageRefUrl = customsetting.TRHC__Drawloop_DDP_URL__c;
                pageRefUrl = String.format(pageRefUrl, new List<String>{UserInfo.getSessionId(),candPresentationNew.id,allId,v_attachs});
                
                //return returnPage;
                previewUrl = pageRefUrl;
                return null;
            }
            catch (Exception e)
            {
                ApexPages.addMessages(e);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getStackTraceString()));
                return null;
            }

        }else{
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.TRHC.Candidate_Presentation_DDP_Error));
            return null;
        }
    }

    /*private PageReference getGeneratedPageReference()
    {
        PageReference sectionPDFPage = Page.CPOutput2;
        sectionPDFPage.getParameters().put('Id', this.applicant.Id);

        String ids = '';
        for (EducationItem item : this.educationHistory)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            sectionPDFPage.getParameters().put('educationHistoryIds', ids);
        }

        ids = '';
        for (EmploymentItem item : this.employmentHistory)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            sectionPDFPage.getParameters().put('employmentHistoryIds', ids);
        }

        ids = '';
        for (CredentialItem item : this.credentials)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            sectionPDFPage.getParameters().put('credentialIds', ids);
        }

        ids = '';
        for (LicenseItem item : this.licenses)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            sectionPDFPage.getParameters().put('licenseIds', ids);
        }

        //Reference items
        ids = '';
        for (ReferenceItem item : this.references)
        {
            if (item.selected)
                ids += item.sobj.Id + ',';
        }

        if (ids.endsWith(','))
        {
            ids = ids.substring(0, ids.length() - 1);
            sectionPDFPage.getParameters().put('referenceIds', ids);
        }

        return sectionPDFPage;

    }*/

    private List<AttachmentItem> loadAttachments(SObject sobj)
    {
        List<SObject> sobjs = new List<SObject>{sobj};
            return this.loadAttachments(sobjs);
    }

    private List<AttachmentItem> loadAttachments(List<SObject> sobjs)
    {
        List<AttachmentItem> ret = new List<AttachmentItem>();
        for (Attachment sobj :
             [SELECT Name
              FROM Attachment
              WHERE parentId IN :sobjs])
        {
            AttachmentItem item = new AttachmentItem();
            item.sobj = sobj;
            item.selected = false;
            ret.add(item);
        }

        return ret;
    }

    private AttachmentItem loadAttachment(ID id)
    {
        List<Attachment> attList = [SELECT id,Name
                          FROM Attachment
                          WHERE Id = :id];		
       
        if(attList != null && attList.size() > 0){
             AttachmentItem item = new AttachmentItem();
             item.sobj = attList.get(0);
            item.selected = false;
            return item;
        }else
           return null;
        
        
        
    }

    /**
* @method
* @description Method to return to previous page.
* */
    public pageReference returnToPrvPage(){
        return new pageReference('/' + this.applicant.id);
    }

    /**
* @method
* @description Intialize upsert of candidate presentation.
* */
    public void initiateCPObject(){
        //create candidate presentation, do not duplicate
        List<TRHC__ETCObject__c> tempCandPres = [select id,TRHC__Candidate__c from TRHC__ETCObject__c where TRHC__Candidate__c = :this.applicant.TRHC__Contact_Candidate__c and TRHC__Status__c = 'Candidate Presentation' and TRHC__Type__c = 'Candidate Presentation'];
        if(tempCandPres != null && tempCandPres.size() > 0){
            candPresentationNew = tempCandPres.get(0);
        }else{
            TRHC__ETCObject__c candPres = new TRHC__ETCObject__c(TRHC__Candidate__c = this.applicant.TRHC__Contact_Candidate__c,TRHC__Status__c = 'Candidate Presentation',TRHC__Type__c = 'Candidate Presentation');
            //DB.doInsert(candPres);
            insert candPres;
            candPresentationNew = candPres;
        }
    }

    /**
* @method
* @description Button to switch view to file selection mode.
* */
/*  public void swtichMode(){
        presentationMode = false;//get back to file selection mode.
    }    */
    
     /*
     * @method 
     * @description Method to get Order by Query for Objects.
     * */    
    private String getQueryOrderByString(String ObjName){
        String querySt;
        if(oderingMap.containsKey(ObjName.toLowerCase())){
                Candidate_Presentation_Odering__mdt v_Cpo = oderingMap.get(ObjName.toLowerCase());
                String oderingField = v_Cpo.Odering_Field_Name__c;
                boolean v_Asc = v_Cpo.Record_Order_ASC__c;
                if(String.isNotEmpty(oderingField))
                   querySt = ' ORDER BY '+ oderingField  + (v_Asc ? ' ASC' : ' DESC');              
        }
        return querySt;
    }

}