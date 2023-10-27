import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'widgets/nav-drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io'; //para seleccionar file
import 'crop_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class perfilTrabajador extends StatefulWidget {
  perfilTrabajador({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  @override
  _perfilTrabajadorState createState() => _perfilTrabajadorState();
}

class _perfilTrabajadorState extends State<perfilTrabajador> {
  String uid;
  Map<String, dynamic> trabajadordata;
  String imageSelect =
      'https://firebasestorage.googleapis.com/v0/b/wanyob-414ce.appspot.com/o/avatarimage.png?alt=media&token=e62c52da-66c8-44fd-9799-0cbc34b69df1';
  void initState() {
    setUserId();
  }

  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
    Firestore.instance.collection('users').document(uid).get().then((result) {
      setState(() {
        imageSelect = result.data['image'];
        trabajadordata = result.data;
      });
    });
  }

  logOut() {
    widget.auth.singOut();
    widget.onSignedOut();
  }

  Future<void> _showFileChooserDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¡Excelente!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Selecciona una opción para cargar tu foto'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Gallería'),
              onPressed: () {
                openFileChooser('galeria');
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Camara'),
              onPressed: () {
                openFileChooser('camara');
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openFileChooser(tipo) async {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (tipo == 'camara') {
      _pickImage(ImageSource.camera);
    } else {
      _pickImage(ImageSource.gallery);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected = await ImagePicker.pickImage(source: source);
    if (selected != null) {
      setState(() {
        openCrop(selected);
      });
    } else {
      showLongToast('No se ha seleccionado la imagen correctamente');
    }
  }

  void openCrop(imageFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CropPage(
              imageFile: imageFile, setImage: setImageOnline, uid: uid)),
    );
  }

  setImageOnline(String namefile, StorageUploadTask task) async {
    StorageTaskSnapshot taskSnapshot = await task.onComplete;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    setState(() {
      imageSelect = downloadUrl;
      Firestore.instance.collection('users').document(uid).updateData({
        'image': imageSelect
      });
      Navigator.of(context).pop();
    });
  }

  void showLongToast(message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: NavDrawer(
          homecontext: context,
          onSignedOut: logOut,
        ),
        appBar: new AppBar(
          title: new Text('Wanyob'),
          backgroundColor: Color(0xff8877ff),
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              );
            },
          ),
        ),
        body: Scrollbar(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(imageSelect),
                        ),
                      ],
                    ),
                    Container(
                      width: 200,
                      child: RaisedButton(
                        textColor: Colors.white,
                        color: Color(0xff8877ff),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            FaIcon(
                              FontAwesomeIcons.camera,
                              color: Colors.white,
                            ),
                            Text(' Subir foto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0, color: Colors.white)),
                          ],
                        ),
                        onPressed: () {
                          _showFileChooserDialog();
                        },
                        shape: new RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                      ),
                    ),
                    RatingBar.builder(
                      initialRating: 4,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30,
                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {
                        print(rating);
                      },
                    ),
                    Text('Calificaciones (5)',
                        textAlign: TextAlign.center,
                        style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black.withOpacity(0.5))),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: double.infinity,
                      child: Text('Referencias',
                          textAlign: TextAlign.left,
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.black.withOpacity(0.8))),
                    ),
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('users')
                          .document(uid)
                          .collection('referencias')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Text('cargando...');
                        return Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: CircleAvatar(
                                        backgroundImage: NetworkImage(snapshot
                                            .data
                                            .documents[index]
                                            .data['image'])),
                                    contentPadding:
                                        EdgeInsets.only(right: 15, left: 10),
                                    title: Text(snapshot
                                        .data.documents[index].data['nombre']),
                                    subtitle: Text(snapshot.data
                                        .documents[index].data['referencia']),
                                    onTap: () {},
                                  );
                                }));
                      },
                    ),
                  ],
                ))));
  }
}
