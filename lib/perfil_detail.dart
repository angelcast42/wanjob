import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'chat.dart';

class perfilDetail extends StatefulWidget {
  perfilDetail({this.trabajadordata});
  final trabajadordata;
  @override
  _perfilDetailState createState() => _perfilDetailState();
}

class _perfilDetailState extends State<perfilDetail> {
  TextEditingController _controller;
  String uid;
  void initState() {
    setUserId();
    _controller = TextEditingController();
    print(widget.trabajadordata.data['nombre']);
    print('uid ' + widget.trabajadordata.documentID);
  }

  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
  }

  _launchCaller() async {
    var url = "tel:(+502)" + widget.trabajadordata.data['telefono'];
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  goToChat() {
    EasyLoading.show(status: 'cargando...');
    Firestore.instance
        .collection('users')
        .document(this.uid)
        .collection('chats')
        .document(widget.trabajadordata.documentID)
        .get()
        .then((doc) {
      if (doc.data != null) {
        EasyLoading.dismiss();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => chat(
                    chatID: doc.data['idChat'],
                    sender: this.uid,
                    receiver: widget.trabajadordata.documentID,
                  )),
        );
      } else {
        EasyLoading.dismiss();
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (context) => chat(
                    chatID: 'null',
                    sender:this.uid,
                    receiver: widget.trabajadordata.documentID,
                  )),
        );
      }
    });
  }

  guardarReferencia() {
    EasyLoading.show(status: 'cargando...');

    Firestore.instance.collection('users').document(uid).get().then((userdata) {
      Firestore.instance
          .collection('users')
          .document(widget.trabajadordata.documentID)
          .collection('referencias')
          .add({
        'clienteid': uid,
        'nombre': userdata.data['nombre'] + ' ' + userdata.data['apellido'],
        'image': userdata.data['image'],
        'referencia': _controller.text
      }).then((result) {
        EasyLoading.dismiss();
      }).catchError((error) {
        EasyLoading.dismiss();
        showLongToast('Un error ha ocurrido');
      });
    }).catchError((error) {
      EasyLoading.dismiss();
      showLongToast('Un error ha ocurrido');
    });
  }

  void showLongToast(message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, textColor: Colors.white);
  }

  Future<void> _showAddReferenciaDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    hintText:
                        '¿Cúal fue tu experiencia contratando a esta persona?',
                    labelText: 'Agregar referencia',
                  ),
                  maxLines: 6,
                )
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Agregar'),
              onPressed: () {
                guardarReferencia();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('Detalle'),
        backgroundColor: Color(0xff8306CF),
        actions: <Widget>[
          GestureDetector(
              //onTap: _launchCaller,
              onTap: () {
                this.goToChat();
              },
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.phone, // add custom icons also
                  ),
                  Text(' Contactar ',
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              )),
        ],
      ),
      body: Scrollbar(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              InkWell(
                  onTap: () {
                    var nav = Navigator.of(context);
                    nav.push<void>(_createRoute(
                        context, widget.trabajadordata.data['image']));
                  },
                  child: CircleAvatar(
                    radius: 80,
                    backgroundImage:
                        NetworkImage(widget.trabajadordata.data['image']),
                  ))
            ],
          ),
          Text(
              widget.trabajadordata.data['nombre'].toUpperCase() +
                  ' ' +
                  widget.trabajadordata.data['apellido'].toUpperCase(),
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent)),
          Text(
              widget.trabajadordata.data['departamento'] +
                  ', ' +
                  widget.trabajadordata.data['municipio'],
              textAlign: TextAlign.center,
              style: new TextStyle(
                  fontSize: 20.0, color: Colors.black.withOpacity(0.5))),
          Card(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.collections_bookmark),
                    title: Text('Acerca de mí'),
                    subtitle: Text(widget.trabajadordata.data['descripcion']),
                  )
                ],
              )),
          Container(
            margin: EdgeInsets.only(top: 20),
            width: double.infinity,
            child: Text('Referencias',
                textAlign: TextAlign.left,
                style: new TextStyle(
                    fontSize: 18.0, color: Colors.black.withOpacity(0.8))),
          ),
          StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(widget.trabajadordata.documentID)
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
                                  .data.documents[index].data['image'])),
                          contentPadding: EdgeInsets.only(right: 15, left: 10),
                          title: Text(
                              snapshot.data.documents[index].data['nombre']),
                          subtitle: Text(snapshot
                              .data.documents[index].data['referencia']),
                          onTap: () {},
                        );
                      }));
            },
          ),
        ]),
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReferenciaDialog,
        child: const Icon(Icons.add),
        backgroundColor: Color(0xff8306CF),
      ),
    );
  }
}

Route _createRoute(BuildContext parentContext, String image) {
  return PageRouteBuilder<void>(
    pageBuilder: (context, animation, secondaryAnimation) {
      return _SecondPage(image);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var rectAnimation = _createTween(parentContext)
          .chain(CurveTween(curve: Curves.ease))
          .animate(animation);

      return Stack(
        children: [
          PositionedTransition(rect: rectAnimation, child: child),
        ],
      );
    },
  );
}

Tween<RelativeRect> _createTween(BuildContext context) {
  var windowSize = MediaQuery.of(context).size;
  var box = context.findRenderObject() as RenderBox;
  var rect = box.localToGlobal(Offset.zero) & box.size;
  var relativeRect = RelativeRect.fromSize(rect, windowSize);

  return RelativeRectTween(
    begin: relativeRect,
    end: RelativeRect.fill,
  );
}

class _SecondPage extends StatelessWidget {
  final String imageAssetName;

  const _SecondPage(this.imageAssetName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Material(
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageAssetName,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
