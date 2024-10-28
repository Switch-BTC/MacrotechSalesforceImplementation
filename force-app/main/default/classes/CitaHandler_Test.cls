@IsTest
public class CitaHandler_Test {
    @IsTest
    static void testProcessCitaIDWithPatientIDNull() {
        // Create test data for environment setup
        Id centroRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Centro').getRecordTypeId();

        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        String environmentString = org.IsSandbox ? 'Sandbox' : 'Production';

        SGR_Key__c sgrKey = new SGR_Key__c(
            Name = environmentString,  
            Username__c = 'admin', 
            Password__c = '123', 
            Cita_Endpoint__c = '/CitaEndpoint', 
            Patient_Endpoint__c = '/PatientEndpoint'
        );
        insert sgrKey;

        Account sucursal = new Account(Name = 'Centro Sucursal', Centro_CAI__c = TRUE, C_digo__c = '22', RecordTypeId = centroRecordTypeId);
        insert sucursal;

        // Create an Account without PatientID__c
        Account account = new Account(
            Name = 'Test Account', 
            No_Identificaci_n__c = '111222333', 
            Tipo_de_identificaci_n__c = '1',
            Sucursal__c = sucursal.Id,
            Fecha_de_Nacimiento__c = Date.today()
        );
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id, Email = 'test@example.com');
        insert contact;

        Cita__c cita = new Cita__c(Account__c = account.Id, Is_Job_Processed__c = true, Start_Date__c = DateTime.now(), Estatus_Cita__c = '1');
        insert cita;

        // Prepare a mock request
        CitaHandler.CitaIDRequest request = new CitaHandler.CitaIDRequest();
        request.citaId = cita.Id;

        // Mock HTTP responses for external system callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test start and execute
        Test.startTest();
        CitaHandler.processCitaID(new List<CitaHandler.CitaIDRequest>{ request });
        Test.stopTest();

        // Verify account update with a new PatientID
        Account updatedAccount = [SELECT PatientID__c FROM Account WHERE Id = :account.Id];
        System.assertNotEquals(null, updatedAccount.PatientID__c, 'PatientID should be set on Account after job execution.');

        // Verify that the Cita record's SGR_Response__c was updated
        Cita__c updatedCita = [SELECT SGR_Response__c FROM Cita__c WHERE Id = :cita.Id];
       // System.assertNotEquals(null, updatedCita.SGR_Response__c, 'SGR_Response__c should be set on Cita after job execution.');
    }

    @IsTest
    static void testProcessCitaIDWithExistingPatientID() {
        // Set up SGR_Key for the environment
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        String environmentString = org.IsSandbox ? 'Sandbox' : 'Production';

        SGR_Key__c sgrKey = new SGR_Key__c(
            Name = environmentString,  
            Username__c = 'admin', 
            Password__c = '123', 
            Cita_Endpoint__c = '/CitaEndpoint', 
            Patient_Endpoint__c = '/PatientEndpoint'
        );
        insert sgrKey;

        // Create an Account with an existing PatientID
        Account account = new Account(
            Name = 'Test Account', 
            PatientID__c = '12345', 
            No_Identificaci_n__c = '111222333', 
            Tipo_de_identificaci_n__c = '1'
        );
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id, Email = 'test@example.com');
        insert contact;

        Cita__c cita = new Cita__c(Account__c = account.Id, Is_Job_Processed__c = true, Estatus_Cita__c = '1', Start_Date__c = DateTime.now());
        insert cita;

        // Prepare a mock request
        CitaHandler.CitaIDRequest request = new CitaHandler.CitaIDRequest();
        request.citaId = cita.Id;

        // Mock HTTP responses for external system callouts
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Test start and execute
        Test.startTest();
        CitaHandler.processCitaID(new List<CitaHandler.CitaIDRequest>{ request });
        Test.stopTest();

        // Verify that the Cita record's SGR_Response__c was updated
        Cita__c updatedCita = [SELECT SGR_Response__c FROM Cita__c WHERE Id = :cita.Id];
        System.assertNotEquals(null, updatedCita.SGR_Response__c, 'SGR_Response__c should be set on Cita after job execution.');
    }

    // Other test methods remain the same...

    // Mock response generator for HTTP callouts
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);

            // Return a mock response depending on the request endpoint
            if (req.getEndpoint().contains('/PatientEndpoint')) {
                res.setBody('{"PacienteId": "56789"}');
            } else if (req.getEndpoint().contains('/CitaEndpoint')) {
                res.setBody('{"CitaId": "98765"}');
            }
            return res;
        }
    }

    // Mock response generator for HTTP callouts that simulate failures
    private class MockHttpResponseGeneratorFailure implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            // Return a mock response depending on the request endpoint
            if (req.getEndpoint().contains('/PatientEndpoint')) {
                res.setStatusCode(500);
                res.setBody('{"error":"Internal Server Error"}');
            } else if (req.getEndpoint().contains('/CitaEndpoint')) {
                res.setStatusCode(200);
                res.setBody('{"CitaId": "98765"}');
            }
            return res;
        }
    }
}