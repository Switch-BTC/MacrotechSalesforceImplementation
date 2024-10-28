@isTest
public class CitaStatusMapper_Test {

    @isTest
    static void testGetStatus_ValidCodes() {
        // Test for valid status code 1
        String status1 = CitaStatusMapper.getStatus(1);
        System.assertEquals('Pendiente', status1, 'Status for code 1 should be Pendiente');

        // Test for valid status code 2
        String status2 = CitaStatusMapper.getStatus(2);
        System.assertEquals('Realizada', status2, 'Status for code 2 should be Realizada');

        // Test for valid status code 3
        String status3 = CitaStatusMapper.getStatus(3);
        System.assertEquals('No Concertada', status3, 'Status for code 3 should be No Concertada');

        // Test for valid status code 4
        String status4 = CitaStatusMapper.getStatus(4);
        System.assertEquals('Fecha sin confirmar', status4, 'Status for code 4 should be Fecha sin confirmar');
    }

    @isTest
    static void testGetStatus_InvalidCode() {
        // Test for an invalid status code
        String statusInvalid = CitaStatusMapper.getStatus(999);
        System.assertEquals('Unknown Status', statusInvalid, 'Status for an invalid code should be Unknown Status');
    }

    @isTest
    static void testGetStatus_NullCode() {
        // Test for a null status code
        String statusNull = CitaStatusMapper.getStatus(null);
        System.assertEquals('Unknown Status', statusNull, 'Status for a null code should be Unknown Status');
    }
}