<?php
// DMCH
include("../../../../bases_datos/adodb/adodb.inc.php");
include("../../../../bases_datos/usb_defglobales.inc");

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

$dbi = NewADOConnection("$motor_p");
$dbi->Connect($base_p, $usuario_p, $contra_p);
if (!$dbi) {
    echo json_encode(array('error' => 'Error de conexión a la base de datos'));
    exit;
}

$resus = array(); 

if (isset($_POST["CURSO"])) {
    $CursoTutoria = $_POST['CURSO'];

    $Consulta_ProfesorTutoria = "SELECT DISTINCT Substr(a.datos,instr(a.datos,'Profesor: ')+9) AS PROFESOR, NATIONAL_ID_DOC
                                FROM ACADEMICO.APEX_LEGEND a 
                                JOIN ACADEMICO.profesores_tutorias_tb b ON b.documento = a.national_id_doc 
                                JOIN ACADEMICO.ASIGNA_ACAD_DOCENTES AAD ON AAD.NIT = a.national_id_doc 
                                JOIN ACADEMICO.DETALLE_ACTIVIDAD_DOCENTES DAD ON AAD.DAD_CODIGO = DAD.CODIGO
                                JOIN academico.facultades c ON AAD.FAC_CODIGO = C.CODIGO 
                                WHERE AAD.PA_CODIGO = '360'
                                AND AAD.DAD_CODIGO = 704
                                AND REPLACE(SUBSTR(datos, 1, INSTR(datos, 'Salón:') - 1), 'Asignatura: ', '') = '$CursoTutoria'";

    $Ejecutar_Consulta = $dbi->Execute($Consulta_ProfesorTutoria);
    $fquery = $Ejecutar_Consulta->recordCount();

    if ($fquery > 0) {
        while (!$Ejecutar_Consulta->EOF) {
            $Valor_DATOS1 = $Ejecutar_Consulta->fields["PROFESOR"];
            $Valor_DATOS2 = $Ejecutar_Consulta->fields["NATIONAL_ID_DOC"];

            $resulta = array(
                "PROFESOR" => $Valor_DATOS1,
                "NATIONAL_ID_DOC" => $Valor_DATOS2
            );

            $resus[] = $resulta;
            $Ejecutar_Consulta->MoveNext();
        }
        echo json_encode($resus);
    } else {
        $resulta["PROFESOR"] = "CARGANDO...";
        $resulta["NATIONAL_ID_DOC"] = "NO";
        $resus[] = $resulta;
        echo json_encode($resus);
    }
} else {
    $resulta["PROFESOR"] = "CARGANDO...";
    $resulta["NATIONAL_ID_DOC"] = "NO";
    $resus[] = $resulta;
    echo json_encode($resus);
}

$dbi->close();
?>
