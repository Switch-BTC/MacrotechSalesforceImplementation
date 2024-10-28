//switchbtc
public class PatientRequest {
    public Integer CentroId { get; set; }
    public String Cedula { get; set; }
    public Integer TipoIdentidadId { get; set; }
    public String Nombres { get; set; }
    public String ApellidoPaterno { get; set; }
    public String ApellidoMaterno { get; set; }
    public String FechaIngreso { get; set; }
    public String FechaNac { get; set; }
    public String Comentarios { get; set; }
    public Integer TipoTepapia { get; set; }
    public String User { get; set; }
    public String Password { get; set; }

    // Constructor
    public PatientRequest(Integer centroId, String cedula, Integer tipoIdentidadId, String nombres, 
                          String apellidoPaterno, String apellidoMaterno, String fechaIngreso, 
                          String fechaNac, String comentarios, Integer tipoTepapia, String user, String password) {
        this.CentroId = centroId;
        this.Cedula = cedula;
        this.TipoIdentidadId = tipoIdentidadId;
        this.Nombres = nombres;
        this.ApellidoPaterno = apellidoPaterno;
        this.ApellidoMaterno = apellidoMaterno;
        this.FechaIngreso = fechaIngreso;
        this.FechaNac = fechaNac;
        this.Comentarios = comentarios;
        this.TipoTepapia = tipoTepapia;
        this.User = user;
        this.Password = password;
    }

    public PatientRequest() {
        // No initialization required
    }

    // Method to serialize the object to JSON
    public String toJson() {
        return JSON.serialize(this);
    }
}