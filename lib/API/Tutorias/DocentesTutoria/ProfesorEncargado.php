<?php
// DMCH
include_once "../../../../bases_datos/adodb/adodb.inc.php";
include_once "../../../../bases_datos/usb_defglobales.inc";

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$dbi = NewADOConnection("$motor_p");
$dbi->Connect($base_p, $usuario_p, $contra_p);

if (!$dbi) {
    echo json_encode(array('error' => 'Error en la conexión a la base de datos'));
    exit;
}

$doc_doc = isset($_POST['DOC_DOC']) ? $_POST['DOC_DOC'] : '';

if (empty($doc_doc)) {
    echo json_encode(array('error' => 'Faltan parámetros'));
    exit;
}

$sql_table = "SELECT NOMBREPROFESOR||' '||APELLIDOSPROFESOR AS PROFE FROM ACADEMICO.PROFESORES_TUTORIAS_TB WHERE DOCUMENTO = '$doc_doc'";

$Ejecutar_Consulta = $dbi->Execute($sql_table, array($doc_doc));

if ($Ejecutar_Consulta === false) {
    echo json_encode(array('error' => 'Error en la consulta a la base de datos'));
    exit;
}

$fquery = $Ejecutar_Consulta->RecordCount();

if ($fquery > 0) {
    $results = array();
    while (!$Ejecutar_Consulta->EOF) {
        $results[] = $Ejecutar_Consulta->fields;
        $Ejecutar_Consulta->MoveNext();
    }
    echo json_encode($results);
} else {
    echo json_encode(array('error' => 'No se encontraron resultados'));
}

$dbi->close();