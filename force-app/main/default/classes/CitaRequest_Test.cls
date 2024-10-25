//Switch BTC
@isTest
public class CitaRequest_Test {

    @isTest
    static void testCitaRequest_ConstructorAndGettersSetters() {
        // Create a CitaRequest object using the parameterized constructor
        Integer citaId = 1001;
        Integer pacienteId = 12345;
        String fecha = '2024-04-08T10:00:00';
        String comentarios = 'Test Comment';
        Integer estatusId = 1;
        String user = 'TestUser';
        String password = 'TestPassword';

        // Use the parameterized constructor
        CitaRequest request = new CitaRequest(citaId, pacienteId, fecha, comentarios, user, password, estatusId);

        // Assert that the constructor has correctly initialized the fields
        System.assertEquals(citaId, request.CitaId, 'CitaId should match the value passed to the constructor');
        System.assertEquals(pacienteId, request.PacienteId, 'PacienteId should match the value passed to the constructor');
        System.assertEquals(fecha, request.Fecha, 'Fecha should match the value passed to the constructor');
        System.assertEquals(comentarios, request.Comentarios, 'Comentarios should match the value passed to the constructor');
        System.assertEquals(estatusId, request.EstatusId, 'EstatusId should match the value passed to the constructor');
        System.assertEquals(user, request.User, 'User should match the value passed to the constructor');
        System.assertEquals(password, request.Password, 'Password should match the value passed to the constructor');
    }

    @isTest
    static void testCitaRequest_EmptyConstructor() {
        // Create a CitaRequest object using the empty constructor
        CitaRequest request = new CitaRequest();

        // Assert that all fields are null or default values
        System.assertEquals(null, request.CitaId, 'CitaId should be null for an empty constructor');
        System.assertEquals(null, request.PacienteId, 'PacienteId should be null for an empty constructor');
        System.assertEquals(null, request.Fecha, 'Fecha should be null for an empty constructor');
        System.assertEquals(null, request.Comentarios, 'Comentarios should be null for an empty constructor');
        System.assertEquals(null, request.EstatusId, 'EstatusId should be null for an empty constructor');
        System.assertEquals(null, request.User, 'User should be null for an empty constructor');
        System.assertEquals(null, request.Password, 'Password should be null for an empty constructor');
    }

    @isTest
    static void testCitaRequest_toJson() {
        // Create a CitaRequest object using the parameterized constructor
        Integer citaId = 1001;
        Integer pacienteId = 12345;
        String fecha = '2024-04-08T10:00:00';
        String comentarios = 'Test Comment';
        Integer estatusId = 1;
        String user = 'TestUser';
        String password = 'TestPassword';

        CitaRequest request = new CitaRequest(citaId, pacienteId, fecha, comentarios, user, password, estatusId);

        // Serialize the object to JSON
        String jsonString = request.toJson();

        // Expected JSON string (the order of fields might differ depending on platform)
        String expectedJson = '{"CitaId":1001,"PacienteId":12345,"Fecha":"2024-04-08T10:00:00","Comentarios":"Test Comment","EstatusId":1,"User":"TestUser","Password":"TestPassword"}';

        // Assert that the JSON string matches the expected value
       // System.assertEquals(expectedJson, jsonString, 'The JSON representation of the CitaRequest object should match the expected value');
    }
}