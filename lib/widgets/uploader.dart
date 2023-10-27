import 'package:flutter/widgets.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class Uploader extends StatefulWidget{
  Uploader({this.file,this.uploadTask});
  File file;
  StorageUploadTask uploadTask;
  @override
  State<StatefulWidget> createState()=> _UploaderState();
}
class _UploaderState extends State<Uploader> {


  @override
  Widget build(BuildContext context) {
    if (widget.uploadTask != null) {
      return StreamBuilder<StorageTaskEvent>(
          stream: widget.uploadTask.events,
          builder: (_, snapshot) {
            var event = snapshot?.data?.snapshot;

            double progressPercent = event != null
                ? event.bytesTransferred / event.totalByteCount
                : 0;

            return Column(

                children: [
                  if (widget.uploadTask.isComplete)
                    Text('Foto subida exitosamente',style:TextStyle(color: Colors.white),),
                  
                  if (widget.uploadTask.isInProgress)
                    Text('Cargando...',style:TextStyle(color: Colors.white),),
                  
                  if (widget.uploadTask.isCanceled)
                    Text('error en carga',style:TextStyle(color: Colors.white),),
                  // Progress bar
                  LinearProgressIndicator(
                    backgroundColor: Colors.white,
                    value: progressPercent
                    ),
                  Text(
                    '${(progressPercent * 100).toStringAsFixed(2)} % '
                  ),
                ],
              );
          });

          
    }
    else{
      return Container(width: 0,height: 0,);
    }
  }
}