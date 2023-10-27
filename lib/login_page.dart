import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanjob/dashboard_page.dart';
import 'auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:wanjob/registro.dart';
import 'pre-registro_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      print('Fomr is invalid');
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        print('correo usuario ' + _email);
        EasyLoading.show(status: 'cargando...');
        String result = await widget.auth.signInWithEmail(_email, _password);
        if (result == 'usuario registrado') {
          EasyLoading.dismiss();
          widget.onSignedIn();
        } else if (result == 'usuario pendiente') {
          EasyLoading.dismiss();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => registro()), (route) => false);
        } else {
          EasyLoading.dismiss();
          showLongToast('El usario no existe, por favor registrate');
        }
      } catch (e) {
        EasyLoading.dismiss();
        if (e.code == 'ERROR_USER_NOT_FOUND') {
          showLongToast('El usario no existe, por favor registrate');
        } else if (e.code == 'ERROR_WRONG_PASSWORD') {
          showLongToast('Usuario o contraseña incorrecta');
        } else if (e.code == 'ERROR_INVALID_EMAIL') {
          showLongToast('El correo electronico no es valido');
        } else {
          showLongToast('Un error ha ocurrido, verifique e intente de nuevo');
        }
      }
    }
  }

  var loading = false;
  void loginwithfacebook() async {
    setState(() {
      loading = true;
    });
    try {
      EasyLoading.show(status: 'cargando...');
      var result = await widget.auth.signInWithFacebook();
      if (result == 'usuario registrado') {
        EasyLoading.dismiss();
        widget.onSignedIn();
      } else {
        EasyLoading.dismiss();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => registro()), (route) => false);
      }
    } catch (e) {
      EasyLoading.dismiss();
      showLongToast('Un error ha ocurrido');
      print('error: $e');
    }
  }

  void showLongToast(message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, textColor: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Container(
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.85), BlendMode.dstATop),
                image: AssetImage('assets/img/limpieza.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(20.0),
            child: new Form(
              key: formKey,
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 300),
                          child: Container(
                            child: Image.asset(
                              'assets/img/wanyob.png',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  new TextFormField(
                    style: new TextStyle(color: Colors.white),
                    decoration: new InputDecoration(
                        enabledBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: new UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        labelText: 'Correo electronico',
                        labelStyle: TextStyle(color: Colors.white)),
                    validator: (value) =>
                        value.isEmpty ? 'Por favor ingresa un correo' : null,
                    onSaved: (value) => _email = value.trim(),
                  ),
                  new TextFormField(
                      style: new TextStyle(color: Colors.white),
                      decoration: new InputDecoration(
                          enabledBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: new UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: Colors.white)),
                      validator: (value) => value.isEmpty
                          ? 'Por favor ingresa la contraseña'
                          : null,
                      onSaved: (value) => _password = value.trimRight(),
                      obscureText: true),
                  new Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: new RaisedButton(
                          color: Color(0xff8877ff),
                          child: new Text('Ingresar',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: validateAndSubmit)),
                  new Container(
                    width: double.infinity,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            flex: 10,
                            child: Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: RaisedButton(
                                  color: Color(0xffc71610),
                                  splashColor: Colors.black26,
                                  child: new Text('Crear cuenta',
                                      style: new TextStyle(
                                          fontSize: 20.0, color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => preRegistro(
                                                auth: widget.auth,
                                                onSignedIn: widget.onSignedIn,
                                              )),
                                    );
                                  }),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }
}
