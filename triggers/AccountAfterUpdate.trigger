/**
 * AccountAfterUpdate
 * @author: Lionel Ramos
 * @date: 05/04/2017
 * @class: AccountAP02, AccountAP03
 * @test: UserAP01_TEST && UserTerritory2AssociationAP01_TEST && AccountAP03_TEST
**/

trigger AccountAfterUpdate on Account (after update) {
    // Cette méthode va de paire avec l'assignation des champs dans le before
   /** if(PAD.canTrigger('AccountAP02')){
       AccountAP02.resetTerritoryManagementField(Trigger.newMap);
    }**/

    Map<Id,Schema.RecordTypeInfo> rtMap = Account.sobjectType.getDescribe().getRecordTypeInfosById();
    Map<Id, Account> updateAccountMap = new Map<Id, Account>();

    List<Id> sendAccs = new List<Id>();
    List<Id> ownerHasChanged = new List<Id>();
    for (Account acc:Trigger.new){
        /*if (acc.TECH_Envoi_Message_sortant__c == true 
            && acc.TECH_Envoi_Message_sortant__c != Trigger.oldMap.get(acc.Id).TECH_Envoi_Message_sortant__c){
            sendAccs.add(acc.Id);
        }*/
        if (acc.OwnerId != Trigger.oldMap.get(acc.Id).OwnerId){
            ownerHasChanged.add(acc.Id);
        }
    }
    /*if (!sendAccs.isEmpty() && PAD.canTrigger('AccountAP03')){
        AccountAP03.sendOMCompte(sendAccs);
    }*/
 /*   if (!ownerHasChanged.isEmpty() && PAD.canTrigger('AccountAP05')){
        AccountAP05.changeOwnerOpportunity(ownerHasChanged);
    }*/
   /* if(PAD.canTrigger('AccountAP07')){
        list<account> listAccountInsolvable = new list<account>();
        list<account> listAccountFerme = new list<account>();
        for(account acct: trigger.new){
            if(acct.RecordtypeID == Label.ACC_Facture_Record_Type_Id){
                if(acct.Statut__c == Label.ACC_StatusInsolvable && acct.Statut__c != trigger.oldMap.get(acct.Id).Statut__c ){
                    listAccountInsolvable.add(acct);
                }
                if(acct.Statut__c == Label.ACC_StatusFerme && acct.Statut__c != trigger.oldMap.get(acct.Id).Statut__c){
                    listAccountFerme.add(acct);
                }
            }
        }
        if(listAccountInsolvable.size()>0){
            AccountAP07.UpdateAccountChildrenToInsolvable(listAccountInsolvable);
        }
        if(listAccountFerme.size()>0){
            AccountAP07.UpdateAccountChildrenToFerme(listAccountFerme);
        }
    }*/

	for (Account acc : Trigger.new){
        if ((acc.Name != Trigger.oldMap.get(acc.Id).Name ||
            acc.Numero_Legal__c != Trigger.oldMap.get(acc.Id).Numero_Legal__c ||
            acc.Code_NAF_APE__c != Trigger.oldMap.get(acc.Id).Code_NAF_APE__c) &&
            rtMap.get(acc.RecordTypeId).getDeveloperName() == 'Compte'){
            updateAccountMap.put(acc.Id, acc);
        }
    }
    
    if(!updateAccountMap.isEmpty() && PAD.canTrigger('Batch_AccountChildUpdate')){
        Boolean isExecuting = (([SELECT COUNT() FROM AsyncApexJob WHERE ApexClassId IN (SELECT Id FROM ApexClass WHERE Name = 'Batch_AccountChildUpdate') AND Status IN ('Processing','Preparing','Queued','Holding')]) == 0) ? false : true ;

        if(!isExecuting){    
            Id batchId = Database.executeBatch(new Batch_AccountChildUpdate(updateAccountMap));
            System.debug('After Update BatchId:' + batchId);
        }
    }
}