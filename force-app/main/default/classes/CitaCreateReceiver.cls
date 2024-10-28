//Switch BTC
@RestResource(urlMapping='/citas/create')
global with sharing class CitaCreateReceiver {

    @HttpPost
    global static String createCita() {
        // Parse the incoming JSON payload
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();

        CitaWrapper citaPayload;

        try {
            // Deserialize the JSON payload into a CitaWrapper object
            citaPayload = (CitaWrapper) JSON.deserialize(requestBody, CitaWrapper.class);

            String pacienteIdString = String.valueOf(citaPayload.PacienteId);

            // Query the Account based on the external PatientID__c field
            Account relatedAccount = [SELECT Id, Name FROM Account WHERE PatientID__c = :pacienteIdString LIMIT 1];

            //Convert datetime
            citaPayload.Fecha += 'Z';
            DateTime salesforceDateTime = DateTime.valueOf(citaPayload.Fecha.replace('T', ' ') + ':00.000');
            Datetime salesforceEndDate = salesforceDateTime.addHours(1);
            
            
            // Create a new Cita__c record and set the fields
            Cita__c newCita = new Cita__c();
            newCita.Account__c = relatedAccount.Id;
            newCita.CitaId__c = String.valueOf(citaPayload.CitaId);
            newCita.Start_Date__c = salesforceDateTime;
            newCita.End_Date__c = salesforceEndDate;
            newCita.Comentarios__c = citaPayload.Comentarios;
            newCita.Name = 'Cita' + ' - ' + relatedAccount.Name; 
            newCita.SGR_Response__c = requestBody;
            

            System.debug('This is the estaus Id' + ' ' + citaPayload.EstatusId);

            // Map the EstatusId to the corresponding status value
            newCita.Estatus_Cita__c = String.valueOf(citaPayload.EstatusId);
            //newCita.Estatus_Cita__c = 'Realizada';

            // Insert the new Cita record
            insert newCita;

            // Return success response
            return 'Cita ' + newCita.CitaId__c + ' - ' + relatedAccount.Name  + ' fue creado en Salesforce';

        } catch (QueryException qe) {
            // Handle case where Account is not found
            return 'Error: No existe una cuenta en Salesforce con el PatientId - ' + citaPayload.PacienteId + ' - ' + qe.getMessage();
        } catch (Exception e) {
            // Return error response for general exceptions
            return 'Error creating cita: ' + e.getMessage();
        }
    }

    // Wrapper class to parse incoming JSON payload
    public class CitaWrapper {
        public Integer CitaId;       // Field to store CitaId
        public Integer PacienteId;   // External ID used to link Cita to Account
        public String Fecha;         // Date field as string (e.g., "2024-04-08")
        public String Comentarios;   // Field to store comments
        public Integer EstatusId;    // Field to store status ID
    }
}