/*
----------------------------------------------------------------------
-- - Name          : AccountBeforeInsert
-- - Author        : Sabine Yaacoub 
-- - Description   : Trigger launched when an Account is created, on record type 'Facturé' or 'Livré'
--                   
-- Maintenance History:
--
-- Date             Name                Version  Remarks
-- -----------      ----                -------  ---------------------------------------
-- 20-MAR-2017      Sabine Yaacoub      1.0         initial version
-- 15-MAR-2019      YRA (Comforth)      1.0         Updated Version version  'Facturé' or 'Livré' (Meunerie & Vigne)           
-- 04-JUL-2022		Subramanyam J		2.0			Added new lists and logic for 'CompteMutation' and 'Compte_de_gestion_consolide' records 
----------------------------------------------------------------------
*/

trigger AccountBeforeInsert on Account (before insert) {
    
    List<Account> lstAccounts = new List<Account>();
    List<Account> accCompteMutationList = new List<Account>();
    List<Account> accConsolideList = new List<Account>();
    Map<Id,Schema.RecordTypeInfo> rtMap = Account.sobjectType.getDescribe().getRecordTypeInfosById();
    
    // Recordtype Account
    map <String,Id> mapDeveloperIdAcc = new map <String,Id>();       
    mapDeveloperIdAcc = AP_Constant.getDeveloperIdMap(AP_Constant.sobjectAcc);     
    
    //Humairaa (Comforth) --> Comment code for custom settings
    /*if (PAD.canTrigger('AP03Account')){
       AP03Account.applyCustomSettings(Trigger.new);
    }*/
    
    for(Account acc:Trigger.new){
        if (acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccMeunerieFacture) || 
            acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccMeunerieLivre) || 
            acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneFacture) || 
            acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneLivre)|| 
            acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccVigneEnvoieDoc) ||
            acc.RecordTypeId == mapDeveloperIdAcc.get(AP_Constant.rtAccSite)){
            lstAccounts.add(acc);
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
    
    if (PAD.canTrigger('AP06_AccountRefLieu') && lstAccounts.size()>0){
    	AP06_AccountRefLieu.updateRefLieu(lstAccounts);
    }

   /* if (PAD.canTrigger('AccountAP03')){
    	AccountAP03.checkSendOMCompte(Trigger.new);
    }*/
    
    if (PAD.canTrigger('AccountAP06')){
    	AccountAP06.fillPays(Trigger.new);
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