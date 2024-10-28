public without sharing class CitaHandler {

    @InvocableMethod(label='Process Cita ID' description='Processes Cita ID and interacts with external system')
    public static void processCitaID(List<CitaIDRequest> requests) {
        String citaid = '';
        for (CitaIDRequest request : requests) {
            citaid = request.citaId;
        }

        // Fetch the Cita record
        Cita__c cita = [SELECT Id, Account__c FROM Cita__c WHERE Id = :citaid LIMIT 1];
        Account account = [SELECT Id, PatientID__c, Sucursal__r.C_digo__c, Tipo_de_identificaci_n__c, Fecha_de_Nacimiento__c, No_Identificaci_n__c  
                            FROM Account WHERE Id = :cita.Account__c LIMIT 1];
        Contact cont = [SELECT Id, Name, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId = :account.Id LIMIT 1];

        if (account.PatientID__c == null) {
            // Enqueue the job to handle patient creation and cita creation
            System.enqueueJob(new CreatePatientAndCitaJob(account.Id, cont.Id, cita.Id));
        } else {
            // If PatientID exists, enqueue the job to create Cita directly
            System.enqueueJob(new CreateCitaJob(account.PatientID__c, cita.Id));
        }
    }

    // Queueable class to handle patient creation and then cita creation
    public class CreatePatientAndCitaJob implements Queueable, Database.AllowsCallouts {
        private Id accountid;
        private Id contid;
        private Id citaId;

        public CreatePatientAndCitaJob(Id accountid, Id contid, Id citaId) {
            this.accountid = accountid;
            this.contid = contid;
            this.citaId = citaId;
        }

        public void execute(QueueableContext context) {
            Cita__c cita = [SELECT Id, Account__c FROM Cita__c WHERE Id = :citaId LIMIT 1];
            Account account = [SELECT Id, PatientID__c, Sucursal__r.C_digo__c, Tipo_de_identificaci_n__c, Fecha_de_Nacimiento__c, No_Identificaci_n__c, SGR_Response__c  
                                FROM Account WHERE Id = :cita.Account__c LIMIT 1];
            Contact cont = [SELECT Id, Name, FirstName, LastName, Email, AccountId FROM Contact WHERE AccountId = :account.Id LIMIT 1];

            // Callout to create a patient in the external system
            String newPatientID = createPatientInExternalSystem(account, cont);

            if (newPatientID != null) {
                // Update the PatientID on the Account record
                account.PatientID__c = newPatientID;
                update account;

                // Update the Account with the response
                updatePatientRecord(account.Id, account.SGR_Response__c, newPatientID);

                // Enqueue a new job to create a Cita using the new PatientID
                if (!Test.isRunningTest()) {
                    System.enqueueJob(new CreateCitaJob(account.PatientID__c, citaId));
                } else {
                    // If running in test context, directly call the method to create Cita
                    CitaHandler.createCitaInExternalSystem(account.PatientID__c, citaId);
                }
            }
        }

        private String createPatientInExternalSystem(Account account, Contact cont) {
            try {
                // Check if the environment is sandbox or production
                Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
                Boolean isSandbox = org.IsSandbox;

                // Use the appropriate string based on the environment
                String environmentString = isSandbox ? 'Sandbox' : 'Production';

                // Get App Keys from SGR Keys App
                SGR_Key__c sgrKeys = [SELECT Id, Name, Patient_Endpoint__c, Cita_Endpoint__c, Username__c, Password__c  FROM SGR_Key__C WHERE Name = :environmentString LIMIT 1];

                HttpRequest req = new HttpRequest();
                req.setEndpoint(sgrKeys.Patient_Endpoint__c);
                req.setMethod('POST');
                req.setHeader('Content-Type', 'application/json');
                req.setTimeout(120000);

                // Create JSON body
                PatientRequest patientbody = new PatientRequest();
                patientbody.CentroId = Integer.valueOf(account.Sucursal__r.C_digo__c);
                patientbody.Cedula = account.No_Identificaci_n__c;
                patientbody.TipoIdentidadId = Integer.valueOf(account.Tipo_de_identificaci_n__c);
                patientbody.Nombres = cont.FirstName;
                patientbody.ApellidoPaterno = cont.LastName;
                patientbody.FechaIngreso = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                patientbody.FechaNac = String.valueOf(account.Fecha_de_Nacimiento__c);
                patientbody.Comentarios = null;
                patientbody.TipoTepapia = null;
                patientbody.User = sgrKeys.Username__c;
                patientbody.Password = sgrKeys.Password__c;

                req.setBody(patientbody.toJson());

                Http http = new Http();
                HttpResponse res = http.send(req);

                if (res.getStatusCode() == 200) {
                    PatientResponse patientres = PatientResponse.parse(res.getBody());
                    String patientid = String.valueOf(patientres.PacienteId);

                    // Update the SGR_Response__c field on the Account with the response body
                    account.SGR_Response__c = res.getBody();
                    return patientid;
                }
            } catch (Exception e) {
                System.debug('Error creating patient in external system: ' + e.getMessage());
            }
            return null;
        }

        // Moved updatePatientRecord as non-static and inside the class
        private void updatePatientRecord(Id accountId, String responseBody, String patientExternal) {
            Account patientToUpdate = new Account(Id = accountId, SGR_Response__c = responseBody, PatientID__c = patientExternal);
            update patientToUpdate;
        }
    }

    // Queueable class to handle cita creation
    public class CreateCitaJob implements Queueable, Database.AllowsCallouts {
        private String patientId;
        private Id citaId;

        public CreateCitaJob(String patientId, Id citaId) {
            this.patientId = patientId;
            this.citaId = citaId;
        }

        public void execute(QueueableContext context) {
            CitaHandler.createCitaInExternalSystem(patientId, citaId);
        }
    }

    // Moved createCitaInExternalSystem to the outer class
    public static void createCitaInExternalSystem(String patientId, Id citaid) {
        try {
            Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
            Boolean isSandbox = org.IsSandbox;

            // Use the appropriate string based on the environment
            String environmentString = isSandbox ? 'Sandbox' : 'Production';

            // Get App Keys from SGR Keys App
            SGR_Key__c sgrKeys = [SELECT Id, Name, Patient_Endpoint__c, Cita_Endpoint__c, Username__c, Password__c FROM SGR_Key__C WHERE Name = :environmentString LIMIT 1];

            Cita__c cita = [SELECT Id, Account__c, Start_Date__c, Comentarios__c FROM Cita__c WHERE Id = :citaid LIMIT 1];
            Integer pacienteId = Integer.valueOf(patientId);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(sgrKeys.Cita_Endpoint__c);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setTimeout(120000);

            CitaRequest citabody = new CitaRequest();
            citabody.PacienteId = pacienteId;
            citabody.Fecha = String.valueOf(cita.Start_Date__c);
            citabody.Comentarios = cita.Comentarios__c;
            citabody.EstatusId = 1;
            citabody.User = sgrKeys.Username__c;
            citabody.Password = sgrKeys.Password__c;

            req.setBody(citabody.toJson());

            Http http = new Http();
            HttpResponse res = http.send(req);

            if (res.getStatusCode() == 200) {
                CitaResponse citares = CitaResponse.parse(res.getBody());
                String citaIdFromResponse = String.valueOf(citares.CitaId);
                updateCitaRecord(citaid, res.getBody(), citaIdFromResponse);
            } else {
                System.debug('Failed to create Cita in external system: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Error creating Cita in external system: ' + e.getMessage());
        }
    }

    // Moved updateCitaRecord to the outer class
    private static void updateCitaRecord(Id citaId, String responseBody, String citaExternal) {
        Cita__c citaToUpdate = new Cita__c(Id = citaId, SGR_Response__c = responseBody, CitaId__c = citaExternal);
        update citaToUpdate;
    }

    public class CitaIDRequest {
        @InvocableVariable(label='Cita ID' description='ID of the Cita record' required=true)
        public String citaId;
    }
}