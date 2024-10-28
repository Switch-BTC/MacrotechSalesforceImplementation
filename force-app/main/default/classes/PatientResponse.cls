public class PatientResponse {
    public Integer PacienteId {get; set;}
    public Integer CentroId {get; set;}
    public String Cedula {get; set;}
    public String Nombres {get; set;}
    public String ApellidoPaterno {get; set;}
    public String ApellidoMaterno {get; set;}
    public Datetime FechaIngreso {get; set;}
    public Datetime FechaNac {get; set;}
    public Integer TipoTerapia {get; set;}
    public Integer TipoIdentidadId {get; set;}
    public String Sexo {get; set;}
    public String User {get; set;}
    public String Password {get; set;}
    public String ModifiedUser {get; set;}
    public String StatusCode {get; set;}
    public String Message {get; set;}

    // Method to parse the JSON response into the PatientResponse class
    public static PatientResponse parse(String json) {
        return (PatientResponse) System.JSON.deserialize(json, PatientResponse.class);
    }
}