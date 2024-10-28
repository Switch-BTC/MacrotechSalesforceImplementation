global class CitaStatusMapper {
    private static final Map<Integer, String> statusMapping = new Map<Integer, String>{
        1 => 'Pendiente',
        2 => 'Realizada',
        3 => 'No Concertada',
        4 => 'Fecha sin confirmar'
    };

    public static String getStatus(Integer statusCode) {
        // Return the mapped value or a default if not found
        return statusMapping.get(statusCode) != null ? statusMapping.get(statusCode) : 'Unknown Status';
    }
}