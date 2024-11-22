

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Funcionalidad{


void showAlertDialogError(BuildContext context, String tituloalert, String contenido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Column(children: [
            const Icon(Icons.cancel, size: 70, color: Colors.red),
            const SizedBox(height: 20),
            Text(tituloalert), 
          ]),
         content: SingleChildScrollView(
              child: RichText(
            //textAlign: TextAlign.justify,
            text: TextSpan(
              text:
                  contenido,
              style: const TextStyle(fontSize: 16, color: Colors.black),
              
            ),
          )),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        );
      },
    );
  }

  void showAlertDialogSuccess(BuildContext context1, String tituloalert1, String contenido1,String tipo , Widget Function(BuildContext)? screenBuilder ) {
      showDialog(
        context: context1,
        
        builder: (BuildContext context) {
          return AlertDialog(

            title:  Column(children: [
              const Icon(Icons.check_circle, size: 70, color: Colors.green),
              const SizedBox(height: 20),
              Text(tituloalert1), 
            ]),
          content: SingleChildScrollView(
                child: RichText(
              //textAlign: TextAlign.justify,
              text: TextSpan(
                text:
                    contenido1,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                
              ),
            )),
          actions: <Widget>[

            TextButton(
              child: const Text('OK'),
              onPressed: () {
                if(tipo=='pro'){
                          Navigator.pop(context1);
                          if(screenBuilder!= null){
                       // Navigator.of(context).popUntil((route)=> route.isFirst);
                        int count = 0;
                Navigator.of(context).popUntil((route) {
                  return count++ == 2;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => screenBuilder(context),
                    ),
                  );
                // Navigator.of(context).popUntil((route)=> route.isFirst);
                /* // Mantener la tercera ruta en la pila
                  });*/
                          }else{

                          }
                }else if (tipo=='est'){
                  
                  Navigator.pushNamed(context, '/estudiante/inicioE');
                }
              },
            ),
          ],
          );
        },
      );
    }

    String fechaformatea(String fechaingresada){
    DateFormat formatoEntrada = DateFormat('dd-MMM-yy hh.mm.ss.SSSSSS a');
    DateFormat formatoSalida = DateFormat('dd/MM/yyyy HH:mm');
    String fecha = fechaingresada;
    DateTime fechaDateTime = formatoEntrada.parseLoose(fecha);
    String fechanueva = formatoSalida.format(fechaDateTime);

      return fechanueva;

    }

     //DEVUELVE EL VALOR DEL PROFESOR
  String mapText(String? value , var opcionFacultadList) {
    
    return opcionFacultadList.firstWhere((element) => element['id'] == value,
        orElse: () => {'text': 'No encontrado'})['text']!;
  }


}


//------------ END-----------//





