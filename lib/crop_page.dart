import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'widgets/uploader.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CropPage extends StatefulWidget {
  CropPage({
    this.imageFile,
    this.setImage,
    this.uid
  });
  File imageFile;
  Function setImage;
  String uid;
  static const String routeName = '/cropPage';
  @override
  State<StatefulWidget> createState() => _cropPageState();
}

class _cropPageState extends State<CropPage> {
  bool _clicked = false; //si el boton de guardar ya fue oprimido
  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cortar',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
    );
    setState(() {
      widget.imageFile = cropped ?? widget.imageFile;
    });
  }

  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://wanyob-414ce.appspot.com');

  StorageUploadTask _uploadTask;

  void _startUpload() async {
    var datekey = DateTime.now();
    String filePath = 'images/'+widget.uid+'.png';
    setState(() {
      _clicked = true;
      _uploadTask = _storage.ref().child(filePath).putFile(widget.imageFile);
      widget.setImage(datekey.toString(), _uploadTask);
    });
  }

  void showLongToast(message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(title: new Text('Edicion de foto'),backgroundColor: Color(0xff8306CF),),
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomAppBar(
          color: Color(0xff8306CF),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.crop),
                  onPressed: _cropImage),
              IconButton(
                  color: Colors.white,
                  icon: Icon(Icons.save),
                  onPressed: _clicked ? null : _startUpload),
            ],
          ),
        ),
        body: new Center(
            child: Container(
                color: Colors.black,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child:Image.file(widget.imageFile),
                    ),
                    Uploader(file: widget.imageFile, uploadTask: _uploadTask)
                  ],
                ))));
  }
}
