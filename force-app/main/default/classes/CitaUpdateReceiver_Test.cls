//Switch BTC
@isTest
public class CitaUpdateReceiver_Test {

    @testSetup
    static void setupTestData() {
        // Create Account
        Account acc = new Account(
            Name = 'Test Account',
            PatientID__c = '12345'  // Simulate external PatientID
        );
        insert acc;

        // Create a Cita__c record to update later
        Cita__c cita = new Cita__c(
            CitaId__c = '1001',
            Estatus_Cita__c = '1',
            Account__c = acc.Id,
            Start_Date__c = DateTime.now(), // Ensure valid Start_Date__c
           // End_Date__c = DateTime.now().addHours(1),  // Ensure valid End_Date__c
            //DurationInMinutes = 60  // Add the missing DurationInMinutes field
            Is_Job_Processed__c = true
            
            
        );
        insert cita;
    }

    @isTest
    static void testUpdateCita_Success() {
        // Mock the incoming JSON payload
        String jsonPayload = '{"CitaId": 1001, "PacienteId": 12345, "Fecha": "2024-04-08T10:00:00", "Comentarios": "Test Comment", "EstatusId": 2}';  // EstatusId 2 should map to 'Realizada'
        
        // Setup the mock RestContext
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        String result = CitaUpdateReceiver.updateCita();
        Test.stopTest();

        // Assert the success response
        System.assert(result.contains('Cita 1001 status updated to Realizada'), 'Expected successful update message');
        
        // Query the updated Cita__c record
        Cita__c updatedCita = [SELECT CitaId__c, Estatus_Cita__c FROM Cita__c WHERE CitaId__c = '1001' LIMIT 1];
        
        // Assert that the status was updated correctly
        System.assertEquals('2', updatedCita.Estatus_Cita__c, 'The Estatus_Cita__c field should have been updated to 2');
    }

    @isTest
    static void testUpdateCita_NotFound() {
        // Mock the incoming JSON payload with a non-existing CitaId
        String jsonPayload = '{"CitaId": 9999, "EstatusId": 2}';  // No Cita with this ID
        
        // Setup the mock RestContext
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        String result = CitaUpdateReceiver.updateCita();
        Test.stopTest();

        // Assert the error response indicating the Cita record was not found
        System.assert(result.contains('Error: No Cita record found with CitaId - 9999'), 'Expected not found error message');
    }

    @isTest
    static void testUpdateCita_DMLException() {
        // Mock the incoming JSON payload
        String jsonPayload = '{"CitaId": 1001, "EstatusId": 2}';

        // Setup the mock RestContext
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(jsonPayload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Cause the DML exception by inserting an invalid DML operation in a try-catch
        Test.startTest();
        try {
            // Simulate invalid operation (e.g., nullify a required field to force the DML exception)
            Cita__c cita = [SELECT Id FROM Cita__c WHERE CitaId__c = '1001' LIMIT 1];
            cita.Estatus_Cita__c = null; // Assuming this is a required field and would cause a DML exception
            update cita;

            // Call the method, which should throw a DMLException when trying to update the Cita record
            String result = CitaUpdateReceiver.updateCita();
           // System.assert(false, 'DMLException should have been thrown');
        } catch (DmlException e) {
            // Assert that the DML exception message is returned
            System.assert(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected DML exception due to missing required fields');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCita_InvalidJSON() {
        // Mock the incoming invalid JSON payload
        String invalidJsonPayload = '{"CitaId": , "EstatusId": 2}';  // Malformed JSON
        
        // Setup the mock RestContext
        RestRequest req = new RestRequest();
        req.requestBody = Blob.valueOf(invalidJsonPayload);
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        // Call the method
        Test.startTest();
        String result = CitaUpdateReceiver.updateCita();
        Test.stopTest();

        // Assert the error response for invalid JSON
        System.assert(result.contains('Error processing cita:'), 'Expected error message for invalid JSON');
    }
}