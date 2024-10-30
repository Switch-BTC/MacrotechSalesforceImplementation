//SwitchBTC
public class AutoConvertLeadsFromTasks {
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds) {
        List<Database.LeadConvert> MassLeadconvert = new List<Database.LeadConvert>();

        for (Id currentlead : LeadIds) {
            Database.LeadConvert Leadconvert = new Database.LeadConvert();
            Leadconvert.setLeadId(currentlead);
            Leadconvert.setConvertedStatus('Qualified');
            Leadconvert.setDoNotCreateOpportunity(true); // Remove this line if you want to create an opportunity from Lead Conversion
            MassLeadconvert.add(Leadconvert);
            System.debug(currentlead);
            System.debug('leadconvert.....' + Leadconvert);
            System.debug('massleadconvert....' + MassLeadconvert);
        }

        if (!MassLeadconvert.isEmpty()) {
            List<Database.LeadConvertResult> lcr = Database.convertLead(MassLeadconvert);
            List<Account> accountsToUpdate = new List<Account>();
            List<Contact> contactToUpdate = new List<Contact>();
            
            for (Database.LeadConvertResult result : lcr) {
                if (result.isSuccess()) {
                    // Retrieve the Account created during the Lead conversion
                    Lead convertedLead = [SELECT Id, FirstName, LastName, Salutation, Email, Phone, MobilePhone, City, Country, PostalCode, State, Street, Fecha_de_Nacimiento_lead__c FROM Lead WHERE Id = :result.getLeadId() LIMIT 1];
                    Account convertedAccount = [SELECT Id, Name FROM Account WHERE Id = :result.getAccountId() LIMIT 1];
                    Contact convertedContact = [SELECT Id, Name FROM Contact WHERE Id = :result.getContactId() LIMIT 1];

                    // Set the new name for the Account to be the Lead's name
                    convertedAccount.Name = convertedLead.FirstName + ' ' + convertedLead.LastName;
                    convertedAccount.Salutation__c = convertedLead.Salutation;
                    convertedAccount.Correo_electr_nico__c = convertedLead.Email;
                    convertedAccount.Phone = convertedLead.Phone;
                    convertedAccount.Celular__c = convertedLead.MobilePhone;
                    convertedAccount.BillingCity = convertedLead.City;
                    convertedAccount.BillingCountry = convertedLead.Country;
                    convertedAccount.BillingPostalCode = convertedLead.PostalCode;
                    convertedAccount.BillingState = convertedLead.State;
                    convertedAccount.BillingStreet = convertedLead.Street;
                    accountsToUpdate.add(convertedAccount);
                    
                    convertedContact.Birthdate = convertedLead.Fecha_de_Nacimiento_lead__c;
                    convertedContact.Street__c = convertedLead.Street;
                    convertedContact.City__c = convertedLead.City;
                    convertedContact.Country__c = convertedLead.Country;
                    convertedContact.PostalCode__c = convertedLead.PostalCode;
                    convertedContact.State__c = convertedLead.State;
                    convertedContact.Primary_Contact__c = TRUE;
                    
                    contactToUpdate.add(convertedContact);
                } else {
                    for(Database.Error error : result.getErrors()) {
                        System.debug('Error converting lead: ' + error.getMessage());
                    }
                }
            }
            
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
            
            if (!contactToUpdate.isEmpty()) {
                update contactToUpdate;
            }
        }
    }
}