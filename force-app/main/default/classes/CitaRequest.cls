//Switch BTC
public class CitaRequest {
    public Integer CitaId { get; set; }
    public Integer PacienteId { get; set; }
    public String Fecha { get; set; }
    public String Comentarios { get; set; }
    public Integer EstatusId { get; set; }
    public String User { get; set; }
    public String Password { get; set; }

    // Constructor
    public CitaRequest(Integer citaId, Integer pacienteId, String fecha, String comentarios, String user, String password, Integer estatusid) {
        this.CitaId = citaId;
        this.PacienteId = pacienteId;
        this.Fecha = fecha;
        this.Comentarios = comentarios;
        this.EstatusId = estatusid;
        this.User = user;
        this.Password = password;
    }

    public CitaRequest() {
        // No initialization required
    }

    // Method to serialize the object to JSON
    public String toJson() {
        return JSON.serialize(this);
    }
}