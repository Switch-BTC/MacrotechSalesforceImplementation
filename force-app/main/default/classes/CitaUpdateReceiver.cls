//Switch BTC
@RestResource(urlMapping='/citas/update')
global with sharing class CitaUpdateReceiver {

    @HttpPost
    global static String updateCita() {
        // Parse the incoming JSON payload
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();

        CitaWrapper citaPayload;

        try {
            // Deserialize the JSON payload into a CitaWrapper object
            citaPayload = (CitaWrapper) JSON.deserialize(requestBody, CitaWrapper.class);

            // Query for an existing Cita__c record based on the CitaId
            List<Cita__c> existingCitas = [SELECT Id, Estatus_Cita__c, CitaId__c FROM Cita__c WHERE CitaId__c = :String.valueOf(citaPayload.CitaId) LIMIT 1];

            if (!existingCitas.isEmpty()) {
                // Get the existing Cita__c record
                Cita__c existingCita = existingCitas[0];
           

                // Map the EstatusId to the corresponding status value
               // String newStatus = CitaStatusMapper.getStatus(citaPayload.EstatusId);

                // Update the Estatus_Cita__c field with the new status value
                existingCita.Estatus_Cita__c = String.valueOf(citaPayload.EstatusId); 

                // Update the existing Cita record
                update existingCita;

                // Return success response for update
                return 'Cita ' + existingCita.CitaId__c + ' status updated to ' + CitaStatusMapper.getStatus(citaPayload.EstatusId);
            } else {
                // Return response indicating that the Cita was not found
                return 'Error: No Cita record found with CitaId - ' + citaPayload.CitaId;
            }

        } catch (DmlException de) {
            // Handle DML exceptions
            return 'Error updating cita: ' + de.getMessage();
        } catch (Exception e) {
            // Return error response for general exceptions
            return 'Error processing cita: ' + e.getMessage();
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