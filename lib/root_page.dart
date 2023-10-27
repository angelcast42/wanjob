import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'login_page.dart';
import 'auth.dart';
import 'dashboard_page.dart';
import 'perfil_trabajador.dart';
import 'package:intl/intl.dart'; //formatter date
import 'package:wanjob/registro.dart';

class RootPage extends StatefulWidget {
  RootPage({this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

enum AuthStatus { notSignedIn, signedIn }

class _RootPageState extends State<RootPage> {
  String uid;
  var formatter = new DateFormat('dd-MM-yyyy');
  var usuario;
  AuthStatus authStatus = AuthStatus.notSignedIn;
  @override
  void initState() {
    super.initState();
    widget.auth.currentUser().then((userId) {
      setState(() {
        uid = userId;
        authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  /* Future<dynamic> getUsuario= Future<dynamic>.delayed(
    Duration(seconds: 5),
    ()=>{
      getUser()
    }
  );*/
  getUser() async {
    var snapshot =
        await Firestore.instance.collection('users').document(uid).get();
    print(snapshot['nombre']);
    return snapshot;
  }

  void _signedIn() {
    widget.auth.currentUser().then((userId) {
      setState(() {
        authStatus = AuthStatus.signedIn;
        uid = userId;
      });
    });
  }

  void _signedOut() {
    setState(() {
      uid = null;
      authStatus = AuthStatus.notSignedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notSignedIn:
        return new LoginPage(
          auth: widget.auth,
          onSignedIn: _signedIn,
        );
      case AuthStatus.signedIn:
        {
          return FutureBuilder(
              future:
                  Firestore.instance.collection('users').document(uid).get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data.data != null) {
                    if (snapshot.data['tipo'] == 'trabajador' &&
                        snapshot.data['registroterminado'] == true) {
                      return new perfilTrabajador(
                        auth: widget.auth,
                        onSignedOut: _signedOut
                      );
                    } else if (snapshot.data['tipo'] == 'cliente' &&
                        snapshot.data['registroterminado'] == true) {
                      return new dashboard(
                        auth: widget.auth,
                        onSignedOut: _signedOut
                      );
                    } else {
                      return new LoginPage(
                        auth: widget.auth,
                        onSignedIn: _signedIn,
                      );
                    }
                  } else {
                    return new LoginPage(
                      auth: widget.auth,
                      onSignedIn: _signedIn,
                    );
                  }
                } else {
                  return new CircularProgressIndicator();
                }
              });
        }
    }
  }
}
