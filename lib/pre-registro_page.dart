import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:wanjob/registro.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class preRegistro extends StatefulWidget {
  preRegistro({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  _preRegistroState createState() => _preRegistroState();
}

class _preRegistroState extends State<preRegistro> {
  final formKey = new GlobalKey<FormState>();
  String _email;
  String _password;
  String _repassword;
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
        if (_password == _repassword) {
          String userId = await widget.auth.signUpWithEmail(_email, _password);
          EasyLoading.dismiss();
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => registro()), (route) => false);

        } else {
          EasyLoading.dismiss();
          showLongToast('Las contraseñas no coinciden, por favor verifica');
        }
      } catch (e) {
        if (e.code == 'ERROR_EMAIL_ALREADY_IN_USE') {
          EasyLoading.dismiss();
          showLongToast('Ya existe un usuario registardo con este correo');
        }else{
          EasyLoading.dismiss();
          showLongToast('Un error ha ocurrido');
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
        Navigator.of(context).pop();
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
    return Scaffold(
        appBar: new AppBar(
          title: new Text('Registro'),
          backgroundColor: Color(0xff8877ff),
        ),
        body: new Container(
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                colorFilter: new ColorFilter.mode(
                    Colors.black.withOpacity(0.85), BlendMode.dstATop),
                image: AssetImage('assets/img/mecanico.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.all(20.0),
            child: SingleChildScrollView(
                child: Form(
                    key: formKey,
                    child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                            validator: (value) => value.isEmpty
                                ? 'Por favor ingresa un correo'
                                : null,
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
                                  labelText: 'contraseña',
                                  labelStyle: TextStyle(color: Colors.white)),
                              validator: (value) => value.isEmpty
                                  ? 'Por favor ingresa la contraseña'
                                  : null,
                              onSaved: (value) => _password = value.trimRight(),
                              obscureText: true),
                          new TextFormField(
                              style: new TextStyle(color: Colors.white),
                              decoration: new InputDecoration(
                                  enabledBorder: new UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: new UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  labelText: 'Confirmar contraseña',
                                  labelStyle: TextStyle(color: Colors.white)),
                              validator: (value) => value.isEmpty
                                  ? 'Por favor ingresa la contraseña'
                                  : null,
                              onSaved: (value) => _repassword = value,
                              obscureText: true),
                          new Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: new RaisedButton(
                                  color: Color(0xff8877ff),
                                  child: new Text('Registrarme',
                                      style: new TextStyle(
                                          fontSize: 20.0, color: Colors.white)),
                                  onPressed: validateAndSubmit)),
                          new Text('Ó Registrate con Facebook',
                              textAlign: TextAlign.center,
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          new Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: RaisedButton(
                                color: Color(0xff4267B2),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FaIcon(
                                      FontAwesomeIcons.facebook,
                                      color: Colors.white,
                                    ),
                                    Text('  Registrarme',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20.0,
                                            color: Colors.white)),
                                  ],
                                ),
                                onPressed: loginwithfacebook),
                          ),
                        ])))));
  }
}
