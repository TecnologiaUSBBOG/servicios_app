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
    echo json_encode(array('error' => 'Error en la conexión a la base de datos'));
    exit;
}
$faucltad = $_POST['FACULTAD'];
$sql_facultad = "SELECT DISTINCT DECODE(FACULTAD,'CIENCIAS ECONÓMICAS Y ADMINISTRATIVAS  ','CIENCIAS ECONÓMICAS Y ADMINISTRATIVAS','INGENIERIA ', 'INGENIERÍA',FACULTAD)FACULTAD,
    DECODE(FACULTAD,'CIENCIAS ECONÓMICAS Y ADMINISTRATIVAS  ','CIENCIAS ECONÓMICAS Y ADMINISTRATIVAS','INGENIERIA ', 'INGENIERÍA',FACULTAD) FACULTAD2
    FROM ACADEMICO.APEX_LEGEND A JOIN ACADEMICO.PROFESORES_TUTORIAS_TB B ON B.DOCUMENTO = A.NATIONAL_ID_DOC 
    JOIN ACADEMICO.ASIGNA_ACAD_DOCENTES AAD ON  AAD.NIT =A.NATIONAL_ID_DOC 
    JOIN ACADEMICO.DETALLE_ACTIVIDAD_DOCENTES DAD ON AAD.DAD_CODIGO = DAD.CODIGO
    JOIN ACADEMICO.FACULTADES C ON AAD.FAC_CODIGO = C.CODIGO
    AND AAD.PA_CODIGO IN (364)
    AND  AAD.DAD_CODIGO = 704
    ORDER BY FACULTAD";

$Ejecutar_Consulta = $dbi->Execute($sql_facultad);
$fquery = $Ejecutar_Consulta->recordCount();

if ($fquery > 0) {
    if ($Ejecutar_Consulta && !$Ejecutar_Consulta->EOF) {
        for ($i = 0; $i < $fquery; $i++) {
            $Valor_D = $Ejecutar_Consulta->fields["FACULTAD"];
            $Valor_R = $Ejecutar_Consulta->fields["FACULTAD2"];
            $resulta["FACULTAD"] = $Valor_D;
            $resulta["FACULTAD2"] = $Valor_R;
            $resus[] = $resulta;
            $Ejecutar_Consulta->MoveNext();
        }
        echo json_encode($resus);
    } else {
        $resulta["FACULTAD"] = "CARGANDO...";
        $resulta["FACULTAD2"] = "NO";
        $resus[] = $resulta;
        echo json_encode($resus);
    }
} else {
    $resulta["FACULTAD"] = "CARGANDO...";
    $resulta["FACULTAD2"] = "NO";
    $resus[] = $resulta;
    echo json_encode($resus);
}

$dbi->close();
