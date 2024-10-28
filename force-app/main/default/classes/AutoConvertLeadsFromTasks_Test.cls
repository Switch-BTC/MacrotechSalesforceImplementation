@isTest(SeeAllData=true)
public class AutoConvertLeadsFromTasks_Test {

    @isTest
    static void Test1(){
        Account sucursal = new Account();
        sucursal.Name = 'Sucursal CAI';
        sucursal.C_digo__c = '1234';
        sucursal.Centro_CAI__c = TRUE;
        sucursal.RecordTypeId = '012bb0000009DCYAA2';
        
        insert sucursal;
        
        
        Lead newLead = new Lead();
        
        newLead.LastName = 'Rosa';
        newLead.Company = 'Rosa Inc';
        newLead.Email = 'emailtest@test.com';
        newLead.Phone = '111-222-3333';
        newLead.Fecha_de_Nacimiento_lead__c = Date.today();
        newLead.Tipo_de_identificaci_n__c = '3';
        newLead.No_Identificaci_n__c = '123456789';
        newLead.Medio_de_contacto_de_preferencia__c = 'Correo';
        newLead.LeadSource = 'ARS';
        newLead.Diagnostico__c = 'Diabetes';
        newLead.Requerimiento_especial__c = 'Otro';
        newLead.Tipo_de_cliente__c = 'ARS';
        newLead.Sucursal__c = sucursal.Id;
        
        insert newLead;
        
        Task newTask = [SELECT Id, Subject, Status, Tipo_de_cita__c, WhoId FROM Task WHERE WhoId =: newLead.Id AND Subject = 'Llamada para coordinar cita'];
        
        newTask.Status = 'Crear Paciente';
        newTask.Tipo_de_cita__c = 'Cita Inicial';
        update newTask;
    }
}