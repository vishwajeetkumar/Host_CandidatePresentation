public with sharing class CPOutputController {
    public TRHC__Job_Applicant__c applicant {private set; get;}
    public Contact candidate {private set; get;}
    public TRHC__Job__c job {private set; get;}
    public List<TRHC__Educational_History__c> educationHistory {private set; get;}
    public List<TRHC__Employment_History__c> employmentHistory {private set; get;}
    public List<TRHC__Credentials__c> credentials {private set; get;}
    public List<TRHC__Credentials_Additional_Information__c> licenses {private set; get;}
    public List<TRHC__References__c> references{private set;get;}
    public list<String> eduFieldList{private set;get;}
    public list<String> empFieldList{private set;get;}
    public list<String> refFieldList{private set;get;}
    public list<String> credFieldList{private set;get;}
    public list<String> licFieldList{private set;get;}
    public list<String> contactFieldList{private set;get;}
    public list<String> jobFieldList{private set;get;}
    Private Map<String,Candidate_Presentation_Odering__mdt> oderingMap ; //Map to hold infromation about odering of data
    
    //private
    private static TRHC__Candidate_Presentation__c customsetting = TRHC__Candidate_Presentation__c.getInstance();
    
    public CPOutputController() {
        this.applicant =
            [SELECT Id, Name, TRHC__Job__c, TRHC__Contact_Candidate__c
             FROM TRHC__Job_Applicant__c
             WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        
        //Populate Ordering Map
        oderingMap = new Map<String,Candidate_Presentation_Odering__mdt>();
        for(Candidate_Presentation_Odering__mdt v_Obj : [Select Object_Name__c,Odering_Field_Name__c,Record_Order_ASC__c from Candidate_Presentation_Odering__mdt]){
            oderingMap.put((v_Obj.Object_Name__c).toLowerCase(),v_Obj);                
        }
        
        
        
        //get fields from candidate presentation custom setting
        //
        //
        //contact fields
        if(String.isNotEmpty(customsetting.TRHC__Personal_Info_Fields__c)){
            String[] fieldList =  (customsetting.TRHC__Personal_Info_Fields__c).split(',');
            if(fieldList.size() > 0){
                contactFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    contactFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //job Infromation fields
        if(String.isNotEmpty(customsetting.TRHC__Job_Information__c)){
            String[] fieldList =  (customsetting.TRHC__Job_Information__c).split(',');
            if(fieldList.size() > 0){
                jobFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    jobFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //credential fields
        if(String.isNotEmpty(customsetting.TRHC__Credential_Fields__c)){
            String[] fieldList =  customsetting.TRHC__Credential_Fields__c.split(',');
            if(fieldList.size() > 0){
                credFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    credFieldList.add(v_Fld.trim());
                }
                
            }
        }
        
        //License fields
        if(String.isNotEmpty(customsetting.TRHC__License_Fields__c)){
            String[] fieldList =  customsetting.TRHC__License_Fields__c.split(',');
            if(fieldList.size() > 0){
                licFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    licFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //Reference fields
        if(String.isNotEmpty(customsetting.TRHC__Reference_Fields__c)){
            String[] fieldList =  customsetting.TRHC__Reference_Fields__c.split(',');
            if(fieldList.size() > 0){
                refFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    refFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //Employment fields
        if(String.isNotEmpty(customsetting.TRHC__Employment_Fields__c)){
            String[] fieldList =  customsetting.TRHC__Employment_Fields__c.split(',');
            if(fieldList.size() > 0){
                empFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    empFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //Education fields
        if(String.isNotEmpty(customsetting.TRHC__Education_Fields__c)){
            String[] fieldList =  customsetting.TRHC__Education_Fields__c.split(',');
            if(fieldList.size() > 0){
                eduFieldList = new List<String>();
                for(String v_Fld : fieldList){
                    eduFieldList.add(v_Fld.trim());
                }
            }
        }
        
        //query contact fields
        if(contactFieldList != null){
            String queryString = 'Select id';
            for(String v_Field : contactFieldList){
                queryString += ',' + v_Field.trim();
            }
            String conID = this.applicant.TRHC__Contact_Candidate__c;
            queryString+= ' From Contact where Id = :conID ';
            System.debug(logginglevel.ERROR,'Query String::' + queryString);
            this.candidate = Database.query(String.escapeSingleQuotes(queryString));
        }
        if(jobFieldList != null){
            String queryString = 'Select id';
            for(String v_Field : jobFieldList){
                queryString += ',' + v_Field.trim();
            }
            String jobId = this.applicant.TRHC__Job__c;
            queryString += ' From TRHC__Job__c where Id = :jobId';
            System.debug(logginglevel.ERROR,'Query String::' + queryString);
            this.job = Database.query(String.escapeSingleQuotes(queryString));
        }
        
        this.educationHistory = new List<TRHC__Educational_History__c>();
        String educationHistoryIdsParam = ApexPages.currentPage().getParameters().get('educationHistoryIds');
        if (educationHistoryIdsParam != null) {
            String [] educationHistoryIds = educationHistoryIdsParam.split(',');
            if(eduFieldList != null){
                String queryString = 'Select id';
                for(String v_Field : eduFieldList){
                    queryString += ',' + v_Field.trim();
                }
                queryString+= ' From TRHC__Educational_History__c where Id IN :educationHistoryIds';
                
                //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt = getQueryOrderByString('TRHC__Educational_History__c');
            	if(String.isNotEmpty(v_OrderBySt))                
                   queryString += v_OrderBySt;              
            
                System.debug(logginglevel.ERROR,'Query String::' + queryString);
                this.educationHistory = Database.query(String.escapeSingleQuotes(queryString));
            }
        }
        
        this.employmentHistory = new List<TRHC__Employment_History__c>();
        String employmentHistoryIdsParam = ApexPages.currentPage().getParameters().get('employmentHistoryIds');
        if (employmentHistoryIdsParam != null) {
            String [] employmentHistoryIds = employmentHistoryIdsParam.split(',');
            if(empFieldList != null){
                String queryString = 'Select id';
                for(String v_Field : empFieldList){
                    queryString += ',' + v_Field.trim();
                }
                queryString += ' From TRHC__Employment_History__c where Id IN :employmentHistoryIds';
                
                //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt1 = getQueryOrderByString('TRHC__Employment_History__c');
            	if(String.isNotEmpty(v_OrderBySt1))                
                   queryString += v_OrderBySt1;   
                
                System.debug(logginglevel.ERROR,'Query String::' + queryString);
                this.employmentHistory = Database.query(String.escapeSingleQuotes(queryString));
            }
        }
        
        this.credentials = new List<TRHC__Credentials__c>();
        String credentialIdsParam = ApexPages.currentPage().getParameters().get('credentialIds');
        if (credentialIdsParam != null) {
            String [] credentialIds = credentialIdsParam.split(',');
            if(credFieldList != null){
                String queryString = 'Select id';
                for(String v_Field : credFieldList){
                    queryString += ',' + v_Field.trim();
                }
                queryString += ' From TRHC__Credentials__c where Id IN :credentialIds';
                
                 //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt2 = getQueryOrderByString('TRHC__Credentials__c');
            	if(String.isNotEmpty(v_OrderBySt2))                
                   queryString += v_OrderBySt2; 
                System.debug(logginglevel.ERROR,'Query String::' + queryString);
                this.credentials = Database.query(String.escapeSingleQuotes(queryString));
            }
        }
        
        this.licenses = new List<TRHC__Credentials_Additional_Information__c>();
        String licenseIdsParam = ApexPages.currentPage().getParameters().get('licenseIds');
        if (licenseIdsParam != null)
        {
            String [] licenseIds = licenseIdsParam.split(',');
            ID licenseRecordTypeId = Schema.SObjectType.TRHC__Credentials_Additional_Information__c.getRecordTypeInfosByName().get('License').getRecordTypeId();
            if(licFieldList != null){
                String queryString = 'Select id';
                for(String v_Field : licFieldList){
                    queryString += ',' + v_Field.trim();
                }
                queryString+= ' From TRHC__Credentials_Additional_Information__c where Id IN :licenseIds AND RecordTypeId = :licenseRecordTypeId';
                
                //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt3 = getQueryOrderByString('TRHC__Credentials_Additional_Information__c');
            	if(String.isNotEmpty(v_OrderBySt3))                
                   queryString += v_OrderBySt3; 
                System.debug(logginglevel.ERROR,'Query String::' + queryString);
                this.licenses = Database.query(String.escapeSingleQuotes(queryString));
            }
        }
        
        //References 
        this.references = new List<TRHC__References__c>();
        String referenceIdsParam = ApexPages.currentPage().getParameters().get('referenceIds');
        if (referenceIdsParam != null)
        {
            String [] referenceIds = referenceIdsParam.split(',');
            if(refFieldList != null){
                String queryString = 'Select id';
                for(String v_Field : refFieldList){
                    queryString += ',' + v_Field.trim();
                }
                queryString+= ' From TRHC__References__c where Id IN :referenceIds';
                
                //inforce sorting order, VK, 5/11/2017
                String v_OrderBySt4 = getQueryOrderByString('TRHC__References__c');
            	if(String.isNotEmpty(v_OrderBySt4))                
                   queryString += v_OrderBySt4; 
                System.debug(logginglevel.ERROR,'Query String::' + queryString);
                this.references = Database.query(String.escapeSingleQuotes(queryString));
            }
        }
        
    }
    
    
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