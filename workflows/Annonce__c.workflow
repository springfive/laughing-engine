<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ALLEnregistrement_d_une_annonce_dans_SF</fullName>
        <description>ALL - Enregistrement d&apos;une annonce vente dans SF</description>
        <protected>false</protected>
        <recipients>
            <field>EmailDuDCR__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>EmailduRDS__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <recipient>Equipe_mutation_RDB</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>contact@ruedesboulangers.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Rue_des_boulangers/Enregistrement_d_une_annonce_dans_Salesforce</template>
    </alerts>
    <alerts>
        <fullName>Alerte_RDS_Son_annonce_est_publi_e</fullName>
        <description>Alerte RDS : Son annonce est publiée</description>
        <protected>false</protected>
        <recipients>
            <field>EmailduRDS__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>contact@ruedesboulangers.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Rue_des_boulangers/Alerte_RDS_Son_annonce_est_publi_e</template>
    </alerts>
</Workflow>
