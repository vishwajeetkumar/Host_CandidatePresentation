/**
 * @class
 * @description Controller class for page-'CandidatePresentationFileOpener'.
 * */
public with sharing class CPFileOpenerController {
	public Id cpAttachId {get; set;}
	private id jobAppid;//job applicant id
	private id contactId;//contact id

	public void initController(){
		String recordIdAll = String.valueOf(ApexPages.currentPage().getParameters().get('id'));
		String recordId = null;

		if(String.isNotEmpty(recordIdAll)){//check if it has id in parameter
			String[] idList = recordIdAll.split(',');
			if(idList.size() > 0)
				recordId = idList[0];
			if(idList.size() > 1)
				jobAppid = idList[1];
			if(idList.size() > 2)
				contactId = idList[2];
		}
		//jobAppid = ApexPages.currentPage().getParameters().get('jaid');
		//contactId = ApexPages.currentPage().getParameters().get('conid');
		system.debug(logginglevel.error,'Page URL::' + ApexPages.currentPage().geturl());

		if(String.isNotEmpty(recordId)){

			List<Attachment> cpFileAttach = [select Id From Attachment where parentId = :recordId and Name Like '%Candidate Presentation%' order by createdDate desc limit 1];

			if (cpFileAttach != null && cpFileAttach.size() > 0)
				cpAttachId = cpFileAttach.get(0).Id;

		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.TRHC.Candidate_Presentation_Missing_Paramer));
			return;
		}
	}

	public void saveToJA(){
		if(String.isNotEmpty(jobAppid)){
			Attachment v_Att = [select Id,Name,body From Attachment where Id = :cpAttachId];

			Attachment v_NewAtt = new Attachment(Name = v_Att.Name,body = v_Att.body,parentid = jobAppid);

			/*DB.doSecureInsert(v_NewAtt,
					new Schema.sObjectField[] {
							Attachment.ParentId,
							Attachment.Name,
							Attachment.Body});VK,5/10/2017*/
            insert v_NewAtt;

			//update job applicant with latest url
			String attURL =  URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + v_NewAtt.ID;
			TRHC__Job_Applicant__c v_JA = new TRHC__Job_Applicant__c(id = jobAppid);
			v_JA.TRHC__Candidate_Presentation_File_URL__c = attURL;

			/*DB.doSecureUpdate(v_JA,
					new Schema.sObjectField[] {
							TRHC__Job_Applicant__c.TRHC__Candidate_Presentation_File_URL__c});*/
            update v_JA;

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.label.TRHC.Candidate_Presentation_Save));

		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.TRHC.Candidate_Presentation_Missing_Paramer));
			return;
		}

	}

	public void saveToContact(){
		if(String.isNotEmpty(contactId)){
			Attachment v_Att = [select Id,Name,body From Attachment where Id = :cpAttachId];

			Attachment v_NewAtt = new Attachment(Name = v_Att.Name,body = v_Att.body,parentid = contactId);

			/*DB.doSecureInsert(v_NewAtt,
					new Schema.sObjectField[] {
							Attachment.ParentId,
							Attachment.Name,
							Attachment.Body});*/
            insert v_NewAtt;
			//update contact with latest url
			String attURL =  URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + v_NewAtt.ID;
			Contact v_Con = new Contact(id = contactId);
			v_Con.TRHC__Candidate_Presentation_File_URL__c = attURL;

			/*DB.doSecureUpdate(v_Con,
					new Schema.sObjectField[] {
							Contact.TRHC__Candidate_Presentation_File_URL__c});*/
            update v_Con;

			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, System.label.TRHC.Candidate_Presentation_Save));

		}else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.label.TRHC.Candidate_Presentation_Missing_Paramer));
			return;
		}

	}
}