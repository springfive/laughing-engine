/**
 * AccountBeforeUpdate 
 * @author: Sabine Yaacoub
 * @date: 02/28/2017
 * @class: AP01Account
 * @test: AP01Account_TEST
**/

/* 
 * AP01Account: Trigger launched when 'Cycle référentiel' = 'Vérifié' on record type 'Facturé' or 'Livré' 
 * AccountAP08: Trigger launched when the accounts record type is 'Compte Mutation'
 * AccountAP09: Trigger launched when the accounts record type is 'Compte_de_gestion_consolide'
*/

trigger AccountBeforeUpdate on Account (before update){
    List<Account> accountChangeCountryCode = new List<Account>();
    //List<Account> accountMeunerieList = new List<Account>();    
    Map<Id, Account> accountMap = new Map<Id, Account>();
    //Map<Id, Account> accountMeunerieMap = new Map<Id, Account>();    
    Map<Id,Schema.RecordTypeInfo> rtMap = Account.sobjectType.getDescribe().getRecordTypeInfosById();
    List<Account> lstAccounts = new List<Account>();
    List<Account> accCompteMutationList = new List<Account>();
    List<Account> accConsolideList = new List<Account>();

    // Recordtype Account
    map <String,Id> mapDeveloperIdAcc = new map <String,Id>();       
    mapDeveloperIdAcc = AP_Constant.getDeveloperIdMap(AP_Constant.sobjectAcc);

    for(Account acc:Trigger.new){
        if ((Trigger.oldMap.get(acc.Id).BillingCountryCode != Trigger.newMap.get(acc.Id).BillingCountryCode)&& (rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Livre || rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Facture)){
            accountChangeCountryCode.add(acc);
        }
    }
    
    for(Account acc:Trigger.new){
        if (rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_CompteMutation){
            accCompteMutationList.add(acc);
        }
    }
    
    for(Account acc:Trigger.new){
        if (rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Consolide){
            accConsolideList.add(acc);
        }
    }
    
    /*for(Account acc:Trigger.new){
        if (rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Livre || rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Facture){
            accountMeunerieMap.put(acc.Id, acc);
            accountMeunerieList.add(acc);
        }        
    }*/

    /*
    for(integer i=0;i<trigger.new.size();i++){
        if((trigger.new[i].BillingCountryCode <> trigger.old[i].BillingCountryCode || 
            trigger.new[i].BillingPostalCode <> trigger.old[i].BillingPostalCode || 
            trigger.new[i].BillingCity <> trigger.old[i].BillingCity || 
            trigger.new[i].Code_Reprise__c <> trigger.old[i].Code_Reprise__c || 
            trigger.new[i].Activite__c <> trigger.old[i].Activite__c) && 
            (trigger.new[i].RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccMeunerieFacture ) || 
            trigger.new[i].RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccMeunerieLivre ) || 
            trigger.new[i].RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneFacture ) || 
            trigger.new[i].RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneLivre ) || 
            trigger.new[i].RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneEnvoieDoc)
            )) {

            lstAccounts.add(trigger.new[i]);
        }
    }
    */
    
    // RJE : 22/05/2019 : mise à jour de la boucle ci-dessus 
    for(Account acct:Trigger.new){
        if ((Trigger.oldMap.get(acct.Id).BillingCountryCode != Trigger.newMap.get(acct.Id).BillingCountryCode
             || Trigger.oldMap.get(acct.Id).BillingPostalCode != Trigger.newMap.get(acct.Id).BillingPostalCode
             || Trigger.oldMap.get(acct.Id).BillingCity != Trigger.newMap.get(acct.Id).BillingCity
             || Trigger.oldMap.get(acct.Id).Code_Reprise__c != Trigger.newMap.get(acct.Id).Code_Reprise__c             
             || Trigger.oldMap.get(acct.Id).Activite__c != Trigger.newMap.get(acct.Id).Activite__c                 
            )
            && (
                rtMap.get(acct.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Livre 
                || rtMap.get(acct.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Facture
                || rtMap.get(acct.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Facture_Vigne 
                || rtMap.get(acct.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Livre_Vigne 
                || rtMap.get(acct.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_EnvoiDeDocument_Vigne              
                || rtMap.get(acct.RecordTypeId).getDeveloperName() == AP_Constant.rtAccSite )
            )
            {
            lstAccounts.add(acct);
            }
    }    

    //YRA -  20190319 : Logic moved to AP06
    /*
    if(PAD.canTrigger('AP01Account')){
        AP01Account.updateCycleRefLieu(accountMeunerieMap, Trigger.oldMap);
    }
    */

    /**if(PAD.canTrigger('AccountAP02')){
        AccountAP02.updateTerritoryManagementField(Trigger.newMap);
    }**/
    
    /*if (PAD.canTrigger('AccountAP03')){
        AccountAP03.checkSendOMCompte(accountMeunerieList);
    }*/
    if (PAD.canTrigger('AccountAP06') && !accountChangeCountryCode.isEmpty()){
        AccountAP06.fillPays(accountChangeCountryCode);
    }
    
    //YRA -  20190319 : Logic moved to AP06
    /*
    if(PAD.canTrigger('AP05Account')){
        for(Account acc:Trigger.new){
            if (rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Facture_Vigne || rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_Livre_Vigne ||rtMap.get(acc.RecordTypeId).getDeveloperName() == Label.ACC_Record_Type_DeveloperName_EnvoiDeDocument_Vigne){             
                accountMap.put(acc.Id, acc);
            }
        }
       AP05Account.updateCycleRefLieu(accountMap);
       System.debug('###accountMap' + accountMap);
    }*/

    if (PAD.canTrigger('AP06_AccountRefLieu') && !lstAccounts.isEmpty()){
        AP06_AccountRefLieu.updateRefLieu(lstAccounts);
    }
    
    if (PAD.canTrigger('AccountAP08')){
    	AccountAP08.updateOwnerCompteMutation(accCompteMutationList);
    }
    
    if (PAD.canTrigger('AccountAP08')){
    	AccountAP08.updateStatusRegister(accCompteMutationList);
    }
    
    if (PAD.canTrigger('AccountAP09')){
    	AccountAP09.cdgConsolide(accConsolideList, Trigger.oldMap);
    }
}