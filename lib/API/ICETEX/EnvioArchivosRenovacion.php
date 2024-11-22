<?php
// DMCH
$host = '192.168.4.178:1521';
$username = 'APP_ANDROID';
$password = 'b2ASDL455tO';
$database = 'SIRA';

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Recibir los datos en formato JSON
$json = file_get_contents('php://input');
$data = json_decode($json, true);

// Obtener los datos de la solicitud
$ID_PROCESO = $data['ID_PROCESO'];
$pdfBase64 = $data['pdf_file'];
$pdfFileName = $data['pdf_file_name'];

// Convertir la cadena Base64 a bytes
$pdfBytes = base64_decode($pdfBase64);

$conn = oci_connect($username, $password, $host . '/' . $database);

if (!$conn) {
    echo json_encode(array("status" => "error", "message" => "Error al conectar con la base de datos."));
    exit;
} else {
    if (isset($pdfFileName) && isset($ID_PROCESO) && isset($pdfBase64)) {

        $sql_insert = "INSERT INTO ACADEMICO.DET_PROCESOS_RENOVACION_TEMP(ID_PROCESO, NOMBRE_ARCHIVO, ARCHIVO_CARGADO, MIMETYPE, CHARSET, LAST_UPDATE, TIPO_ARCHIVO) 
                VALUES(:ID_PROCESO, :pdfFileName, EMPTY_BLOB(), 'application/pdf', NULL, SYSDATE, NULL) RETURNING ARCHIVO_CARGADO INTO :blob_data";

        // Preparar la sentencia SQL
        $stmt_insert = oci_parse($conn, $sql_insert);

        // Vincular los valores
        oci_bind_by_name($stmt_insert, ':ID_PROCESO', $ID_PROCESO);
        oci_bind_by_name($stmt_insert, ':pdfFileName', $pdfFileName);
        $blob_data = oci_new_descriptor($conn, OCI_D_LOB);
        oci_bind_by_name($stmt_insert, ':blob_data', $blob_data, -1, OCI_B_BLOB);

        // Ejecutar el INSERT
        $result = oci_execute($stmt_insert, OCI_NO_AUTO_COMMIT);

        // Escribir los datos del BLOB desde la cadena Base64 si el INSERT fue exitoso
        if ($result) {
            $blob_data->save($pdfBytes);
            oci_commit($conn); // Confirmar los cambios realizados
            echo "Archivo insertado exitosamente";
        } else {
            oci_rollback($conn); // Revertir los cambios en caso de error
            echo "Error al insertar el archivo";
        }

        // Liberar los recursos y cerrar la conexión
        oci_free_descriptor($blob_data);
        oci_free_statement($stmt_insert);
        oci_close($conn);
    } else {
        $error = oci_error();
        echo json_encode(array("status" => "error", "message" => "Error de conexión con la base de datos: " . $error['message']));
        exit;
    }
}
