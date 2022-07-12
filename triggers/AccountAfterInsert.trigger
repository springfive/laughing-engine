/**
 * AccountBeforeInsert
 * @author: Lionel Ramos
 * @date: 15/03/2017
 * @class: AccountAP02
 * @test: 
**/

trigger AccountAfterInsert on Account (after insert) {
	/**if(PAD.canTrigger('AccountAP02')){
        AccountAP02.insertTerritoryManagementField(Trigger.newMap.keyset());
    }**/
    List<Id> sendAccs = new List<Id>();
    for (Account acc:Trigger.new){
    	if (acc.TECH_Envoi_Message_sortant__c){
    		sendAccs.add(acc.Id);
    	}
    }
    /*if (!sendAccs.isEmpty()){
    	if (PAD.canTrigger('AccountAP03')){
    		AccountAP03.sendOMCompte(sendAccs);
    	}
    }*/
    if(PAD.canTrigger('AccountAP07')){
        list<account> listAccountInsolvable = new list<account>();
        list<account> listAccountFerme = new list<account>();
        for(account acct: trigger.new){
            system.debug('test' + acct.Recordtype.DeveloperName);
            if(acct.RecordtypeID == Label.ACC_Facture_Record_Type_Id){
                if(acct.Statut__c == Label.ACC_StatusInsolvable){
                    listAccountInsolvable.add(acct);
                }
                if(acct.Statut__c == Label.ACC_StatusFerme){
                    listAccountFerme.add(acct);
                }
            }
        }
        /*if(listAccountInsolvable.size()>0){
            AccountAP07.UpdateAccountChildrenToInsolvable(listAccountInsolvable);
        }
        if(listAccountFerme.size()>0){
            AccountAP07.UpdateAccountChildrenToFerme(listAccountFerme);
        }*/
    }
}