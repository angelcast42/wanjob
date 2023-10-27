import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'perfil_detail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat.dart';

class listTrabajadores extends StatefulWidget {
  listTrabajadores({this.nombreCategoria, this.codigoCategoria});
  final String codigoCategoria;
  final String nombreCategoria;
  @override
  _listTrabajadoresState createState() => _listTrabajadoresState();
}

class _listTrabajadoresState extends State<listTrabajadores> {
  String uid;
  void initState() {
    super.initState();
    setUserId();
  }
  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      this.uid = user.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(widget.nombreCategoria),
        backgroundColor: Color(0xff8877ff),
      ),
      body: widget.nombreCategoria != 'inbox'
          ? StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .where('categoria',
                      isEqualTo: int.parse(widget.codigoCategoria))
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('cargando...');
                return Container(
                    child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data.documents[index]['image'])),
                            contentPadding:
                                EdgeInsets.only(right: 15, left: 10),
                            title: Text(snapshot.data.documents[index]
                                    ['nombre'] +
                                ' ' +
                                snapshot.data.documents[index]['apellido']),
                            subtitle: Text(snapshot.data.documents[index]
                                    ['departamento'] +
                                ', ' +
                                snapshot.data.documents[index]['municipio']),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => perfilDetail(
                                          trabajadordata:
                                              snapshot.data.documents[index],
                                        )),
                              );
                            },
                          );
                        }));
              },
            )
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(this.uid)
                  .collection('chats')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Text('cargando...');
                return Container(
                    child: ListView.builder(
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    snapshot.data.documents[index]['image'])),
                            contentPadding:
                                EdgeInsets.only(right: 15, left: 10),
                            title:
                                Text(snapshot.data.documents[index]['nombre']),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => chat(
                                          chatID: snapshot.data.documents[index]['idChat'],
                                          sender: this.uid,
                                          receiver:
                                             snapshot.data.documents[index].documentID,
                                        )),
                              );
                            },
                          );
                        }));
              },
            ),
    );
  }
}
