//Switch BTC
public class CitaResponse {

	public Integer CitaId;
	public Integer PacienteId;
	public String Fecha;
	public String FechaRealizacion;
	public String Comentarios;
	public String EstatusId;
	public String User;
	public String Password;

	
	public static CitaResponse parse(String json) {
		return (CitaResponse) System.JSON.deserialize(json, CitaResponse.class);
	}
}