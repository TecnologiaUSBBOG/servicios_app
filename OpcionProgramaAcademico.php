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

if (isset($_POST["PROG_ACADEMICO"])) {
    $facultad = $_POST["PROG_ACADEMICO"];

    $Consulta_ProgramaAcademico = "SELECT DISTINCT 
                                        SUBSTR(PROGRAMA,INSTR(PROGRAMA,'-')+2) PROGRAMA,
                                        SUBSTR(PROGRAMA,INSTR(PROGRAMA,'-')+2) PROGRAMA2
                                        FROM ACADEMICO.APEX_LEGEND A JOIN ACADEMICO.PROFESORES_TUTORIAS_TB B ON B.DOCUMENTO = A.NATIONAL_ID_DOC 
                                        JOIN ACADEMICO.ASIGNA_ACAD_DOCENTES AAD ON AAD.NIT = A.NATIONAL_ID_DOC 
                                        JOIN ACADEMICO.DETALLE_ACTIVIDAD_DOCENTES DAD on AAD.DAD_CODIGO = DAD.CODIGO
                                        JOIN ACADEMICO.FACULTADES C ON AAD.FAC_CODIGO = C.CODIGO
                                        AND AAD.PA_CODIGO in (364)
                                        AND  AAD.DAD_CODIGO = 704
                                        AND FACULTAD = '$facultad'";

    $Ejecutar_Consulta = $dbi->Execute($Consulta_ProgramaAcademico);
    $fquery = $Ejecutar_Consulta->recordCount();

    if ($fquery > 0) {
        if ($Ejecutar_Consulta && !$Ejecutar_Consulta->EOF) {
            for ($i = 0; $i < $fquery; $i++) {
                $Valor_D = $Ejecutar_Consulta->fields["PROGRAMA"];
                $Valor_R = $Ejecutar_Consulta->fields["PROGRAMA2"];
                $resulta["PROGRAMA"] = $Valor_D;
                $resulta["PROGRAMA2"] = $Valor_R;
                $resus[] = $resulta;
                $Ejecutar_Consulta->MoveNext();
            }
            echo json_encode($resus);
        } else {
            $resulta["PROGRAMA"] = "SELECCION UNA FACULTAD";
            $resulta["PROGRAMA2"] = "NO";
            $resus[] = $resulta;
            echo json_encode($resus);
        }
    } else {
        $resulta["PROGRAMA"] = "SELECCION UNA FACULTAD";
        $resulta["PROGRAMA2"] = "NO";
        $resus[] = $resulta;
        echo json_encode($resus);
    }
} else {
    $resulta["PROGRAMA"] = "CARGANDO...";
    $resulta["PROGRAMA2"] = "NO";
    $resus[] = $resulta;
    echo json_encode($resus);
}

$dbi->close();
