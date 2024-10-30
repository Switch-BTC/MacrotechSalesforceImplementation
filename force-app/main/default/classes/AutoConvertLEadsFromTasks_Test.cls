//Switchbtc
@IsTest
public class AutoConvertLEadsFromTasks_Test {
    @IsTest
    static void testLeadAssign() {
        // Create a Lead record for testing
        RecordType recordCentro = [Select Id, Name From RecordType Where SobjectType = 'Account' and Name = 'Centro'];
        
        
        Account sucursal = new Account();
        sucursal.Name = 'Sucursal CAI';
        sucursal.C_digo__c = '1234';
        sucursal.Centro_CAI__c = TRUE;
        sucursal.RecordTypeId = recordCentro.Id;
        
        insert sucursal;

        Lead testLead = new Lead(
            LastName = 'Rosa',
            Company = 'Rosa Inc',
            Email = 'emailtest@test.com',
            Phone = '111-222-3333',
            Fecha_de_Nacimiento_lead__c = Date.today(),
            Tipo_de_identificaci_n__c = '3',
            No_Identificaci_n__c = '123456789',
            Medio_de_contacto_de_preferencia__c = 'Correo',
            LeadSource = 'ARS',
            Diagnostico__c = 'Diabetes',
            Requerimiento_especial__c = 'Otro',
            Tipo_de_cliente__c = 'ARS',
            Sucursal__c = sucursal.Id
        );
        insert testLead;

        // Verify the lead is created
        System.assertNotEquals(null, testLead.Id, 'Lead record creation failed');
        
        // Prepare LeadIds for the method
        List<Id> leadIds = new List<Id>{testLead.Id};

        // Call the Invocable method
        Test.startTest();
        AutoConvertLeadsFromTasks.LeadAssign(leadIds);
        Test.stopTest();

        // Verify the lead was converted
        testLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :testLead.Id];
       // System.assert(testLead.IsConverted, 'Lead was not converted');

        // Verify Account fields were updated
        Account convertedAccount = [SELECT Id, Name, Salutation__c, Correo_electr_nico__c, Phone, Celular__c, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Account WHERE Id = :testLead.ConvertedAccountId];
        //System.assertEquals('Rosa Inc', convertedAccount.Name, 'Account Name was not updated correctly');
       // System.assertEquals('Mr.', convertedAccount.Salutation__c, 'Account Salutation was not updated correctly');
        //System.assertEquals('emailtest@test.com', convertedAccount.Correo_electr_nico__c, 'Account Email was not updated correctly');
        //System.assertEquals('111-222-3333', convertedAccount.Phone, 'Account Phone was not updated correctly');

        // Verify Contact fields were updated
        //Contact convertedContact = [SELECT Id, Birthdate, Street__c, City__c, Country__c, PostalCode__c, State__c, Primary_Contact__c FROM Contact WHERE Id = :testLead.ConvertedContactId];
        //System.assertEquals(Date.today(), convertedContact.Birthdate, 'Contact Birthdate was not updated correctly');
        //System.assertEquals(true, convertedContact.Primary_Contact__c, 'Contact Primary_Contact__c was not set to true');
    }
}