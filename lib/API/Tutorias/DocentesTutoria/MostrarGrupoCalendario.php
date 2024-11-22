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
    error_log("Algun dato está vacio", 0);
    exit;
}

$sql_query = "SELECT A.FECHATUTORIA,
                        B.NOMBRE,
                        A.NOMBREDELCURSO,
                        C.NOMBREPROFESOR|| ' ' ||C.APELLIDOSPROFESOR PROFESOR, 
                        A.TEMATICA,
                        A.MODALIDAD,
                        A.LUGAR,
                        A.METODOLOGIA FROM ACADEMICO.PROGRAMACION_TUTORIAS_TB A 
            JOIN ACADEMICO.PERSONAL_DATOS_TUTORIAS_TB B ON A.DOCUMENTO = B.DOCUMENTO 
            JOIN ACADEMICO.PROFESORES_TUTORIAS_TB C ON A.DOCUMENTOP = C.DOCUMENTO WHERE A.DOCUMENTOP = '$doc_doc' AND A.FECHATUTORIA > SYSDATE
            UNION
            SELECT A.FECHATUTORIA,
                        B.NOMBRES,
                        A.NOMBREDELCURSO,
                        C.NOMBREPROFESOR|| ' ' ||C.APELLIDOSPROFESOR PROFESOR, 
                        A.TEMATICA,
                        A.MODALIDAD,
                        A.LUGAR,
                        A.METODOLOGIA FROM ACADEMICO.GRUPOS_SESIONES_TUTORIAS A 
            JOIN ACADEMICO.GRUPOS_ESTUDIANTES_TUTORIAS B ON A.GRUPO = B.GRUPO 
            JOIN ACADEMICO.PROFESORES_TUTORIAS_TB C ON A.DOCUMENTOPROFESOR = C.DOCUMENTO WHERE A.DOCUMENTOPROFESOR = '$doc_doc' AND A.FECHATUTORIA > SYSDATE";

// error_log("SQL selected: " . $sql_query);

$Ejecutar_Consulta = $dbi->Execute($sql_query);

if ($Ejecutar_Consulta === false) {
    echo json_encode(array('error' => 'Error en la consulta de inserción a la base de datos'));
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
