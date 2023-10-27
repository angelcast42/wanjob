import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'widgets/combobox.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; //formatter date
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wanjob/dashboard_page.dart';
import 'perfil_trabajador.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; //para seleccionar file
import 'package:fluttertoast/fluttertoast.dart';
import 'crop_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;

class registro extends StatefulWidget {
  @override
  _registroState createState() => _registroState();
}

class _registroState extends State<registro> {
  int tipoCategoria = 1;
  String departamentoSelected = '1';
  String municipioSelected = '101';
  String descripcion;
  String numerodpi;
  String primerNombre;
  String segundoNombre = '';
  String primerApellido;
  String segundoApellido = '';
  String telefonocliente;
  String tipocliente = 'cliente';
  String imageSelect =
      'https://firebasestorage.googleapis.com/v0/b/wanyob-414ce.appspot.com/o/avatarimage.png?alt=media&token=e62c52da-66c8-44fd-9799-0cbc34b69df1';
  final FirebaseStorage _storage =
      FirebaseStorage(storageBucket: 'gs://wanyob-414ce.appspot.com');
  TextEditingController _controllerDate;
  String uid;
  DateTime _date = DateTime.now();
  var formatter = new DateFormat('dd-MM-yyyy');
  Map<int, String> departamentos = {
    1: "Guatemala",
    2: "El Progreso",
    3: "Sacatepéquez",
    4: "Chimaltenango",
    5: "Escuintla",
    6: "Santa Rosa",
    7: "Sololá",
    8: "Totonicapán",
    9: "Quetzaltenango",
    10: "Suchitepéquez",
    11: "Retalhuleu",
    12: "San Marcos",
    13: "Huehuetenango",
    14: "Quiché",
    15: "Baja Verapaz",
    16: "Alta Verapaz",
    17: "Petén",
    18: "Izabal",
    19: "Zacapa",
    20: "Chiquimula",
    21: "Jalapa",
    22: "Jutiapa",
  };
  List<Map> municipios;
  List<Map> municipiosbackup;
  Map<String, Map> categorias = {};
  void initState() {
    _controllerDate = TextEditingController();
    setUserId();
    Firestore.instance
        .collection('varios')
        .document('categorias')
        .get()
        .then((data) {
      categorias = Map<String, Map>.from(data.data);
    });
    setMunicipios();
    EasyLoading.instance..displayDuration = const Duration(milliseconds: 6000);
  }

  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
  }

  selectCategoria(value) {
    setState(() {
      tipoCategoria = value;
    });
  }

  setMunicipios() async {
    String json = await rootBundle.loadString('assets/files/municipios.txt');
    municipios = List<Map>.from(jsonDecode(json) as List);
    municipiosbackup = List<Map>.from(jsonDecode(json) as List);
    fiterMunicipios("1");
  }

  Future<Null> selectStartDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
        lastDate: _date);
    if (picked != null) {
      print(_date.toString());
      setState(() {
        _controllerDate.text = formatter.format(picked);
      });
    }
  }

  fiterMunicipios(newValue) {
    setState(() {
      municipios = municipiosbackup.where((item) {
        return item['codigo_depto'] == newValue;
      }).toList();
      municipioSelected = municipios[0]['codigo_municipio'];
      print(municipios);
    });
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      print('Fomr is invalid');
      return false;
    }
  }

  Future getDataRenap(dpi) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/json',
      'User-banca-bt': 'dfdf',
      'Password-banca-bt': 'dfdfd'
    };
    var body = jsonEncode({"p_Cui": dpi, "p_Usuario": "AUTOGESTION"});
    var url =
        "https://hermes.bantrab.com:2096/api/v1/Servicios/VerificaDPIRenap";
    var response = await http.post(url, body: body, headers: requestHeaders);
    if (response.statusCode != 200) {
      throw Exception(
          "Request to $url failed with status ${response.statusCode}: ${response.body}");
    }
    print(json.decode(response.body));
    return json.decode(response.body);
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        EasyLoading.show(status: 'cargando...');
        if (tipocliente == 'trabajador') {
          this.getDataRenap(numerodpi).then((result) {
            var datarenap = result["Respuesta"]["ROW"];
            if (datarenap["PRIMER_NOMBRE"].toUpperCase() ==
                    primerNombre.toUpperCase() &&
                datarenap["PRIMER_APELLIDO"].toUpperCase() ==
                    primerApellido.toUpperCase() &&
                datarenap["SEGUNDO_APELLIDO"].toUpperCase() ==
                    segundoApellido.toUpperCase()) {
              if (segundoNombre != '' &&
                  datarenap["SEGUNDO_NOMBRE"].toUpperCase() !=
                      segundoNombre.toUpperCase()) {
                EasyLoading.dismiss();
                EasyLoading.showError('La validación de identediad fallo, debe validar que la información ingresada este tal como aparece en su DPI.');
              } else {
                EasyLoading.dismiss();
                EasyLoading.showSuccess('Identidad validada con exito');
                Firestore.instance
                    .collection('users')
                    .document(uid)
                    .updateData({
                  'tipo': tipocliente,
                  'categoria': tipoCategoria,
                  'dpi': numerodpi,
                  'nombre': primerNombre + ' ' + segundoNombre,
                  'apellido': primerApellido + ' ' + segundoApellido,
                  'telefono': telefonocliente,
                  'departamento':
                      departamentos[int.parse(departamentoSelected)],
                  'municipio': municipiosbackup.singleWhere((item) =>
                      item['codigo_municipio'] ==
                      municipioSelected)['Municipio'],
                  'fechanacimiento': _controllerDate.text,
                  'descripcion': descripcion,
                  'registroterminado': true,
                  'image': imageSelect
                });
                this.startUpload(datarenap["FOTO"]);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => perfilTrabajador()),
                    (route) => false);
              }
            } else {
              EasyLoading.dismiss();
              EasyLoading.showError('La validación de identediad fallo, debe validar que la información ingresada este tal como aparece en su DPI.');
            }
            print(result);
          }).catchError((error) {
            print("error" + error);
          });
        } else {
          this.getDataRenap(numerodpi).then((result) {
            var datarenap = result["Respuesta"]["ROW"];
            if (datarenap["PRIMER_NOMBRE"].toUpperCase() ==
                    primerNombre.toUpperCase() &&
                datarenap["PRIMER_APELLIDO"].toUpperCase() ==
                    primerApellido.toUpperCase() &&
                datarenap["SEGUNDO_APELLIDO"].toUpperCase() ==
                    segundoApellido.toUpperCase()) {
              if (segundoNombre != '' &&
                  datarenap["SEGUNDO_NOMBRE"].toUpperCase() !=
                      segundoNombre.toUpperCase()) {
                EasyLoading.dismiss();
                EasyLoading.showError('La validación de identediad fallo, debe validar que la información ingresada este tal como aparece en su DPI.');
              } else {
                EasyLoading.dismiss();
                EasyLoading.showSuccess('Identidad validada con exito');
                Firestore.instance
                    .collection('users')
                    .document(uid)
                    .updateData({
                  'tipo': tipocliente,
                  'dpi': numerodpi,
                  'nombre': primerNombre + ' ' + segundoNombre,
                  'apellido': primerApellido + ' ' + segundoApellido,
                  'telefono': telefonocliente,
                  'departamento':
                      departamentos[int.parse(departamentoSelected)],
                  'municipio': municipiosbackup.singleWhere((item) =>
                      item['codigo_municipio'] ==
                      municipioSelected)['Municipio'],
                  'fechanacimiento': _controllerDate.text,
                  'registroterminado': true,
                  'image': imageSelect
                });
                this.startUpload(datarenap["FOTO"]);
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => dashboard()),
                    (route) => false);
              }
            } else {
              EasyLoading.dismiss();
              EasyLoading.showError('La validación de identediad fallo, debe validar que la información ingresada este tal como aparece en su DPI.');
            }
            print(result);
          }).catchError((error) {
            print("error" + error);
          });
        }
      } catch (e) {
        EasyLoading.dismiss();
        showLongToast('Un error ha ocurrido, intentalo mas tarde');
        print('error: $e');
      }
    }
  }

  Future startUpload(imageb64) async {
    String filePath = 'renapimages/' + numerodpi + '.png';
    var bytes = base64.decode(imageb64);
    _storage.ref().child(filePath).putData(bytes);
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
      Navigator.of(context).pop();
    });
  }

  void showLongToast(message) {
    Fluttertoast.showToast(
        msg: message, toastLength: Toast.LENGTH_LONG, textColor: Colors.white);
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

  final _formKey = GlobalKey<FormState>();
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
        backgroundColor: Color(0xff8877ff),
      ),
      body: Form(
        key: _formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(imageSelect),
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
                  DropdownButtonFormField<String>(
                    value: tipocliente,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 20,
                    elevation: 16,
                    isDense: true,
                    decoration: new InputDecoration(
                      labelText: '¿Qué estas buscando?',
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        tipocliente = newValue;
                      });
                    },
                    items: [
                      DropdownMenuItem<String>(
                          value: 'cliente',
                          child: Text('Contratar un servicio')),
                      DropdownMenuItem<String>(
                          value: 'trabajador',
                          child: Text('Vender un servicio'))
                    ],
                  ),
                  tipocliente == 'trabajador'
                      ? FutureBuilder<String>(
                          future: _calculation,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.hasData) {
                              return ComboBox(
                                comboList: categorias,
                                title: 'Selecciona la categoria de tu servicio',
                                changeValue: selectCategoria,
                                dropdownValue: tipoCategoria.toString(),
                                tipo: 'nombre',
                              );
                            } else {
                              return new CircularProgressIndicator();
                            }
                          })
                      : Container(),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'DPI',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Por favor ingrese su DPI';
                      } else if (value.length > 13 || value.length < 13) {
                        return 'DPI incorrecto';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => numerodpi = value,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Primer nombre',
                    ),
                    validator: (value) => value.isEmpty
                        ? 'Por favor ingrese su primer nombre'
                        : null,
                    onSaved: (value) => primerNombre = value,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Segundo nombre',
                    ),
                    onSaved: (value) => segundoNombre = value,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Primer apellido',
                    ),
                    validator: (value) => value.isEmpty
                        ? 'Por favor ingrese su primer apellido'
                        : null,
                    onSaved: (value) => primerApellido = value,
                  ),
                  TextFormField(
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Segundo apellido',
                    ),
                    validator: (value) => value.isEmpty
                        ? 'Por favor ingrese su segundo apellido'
                        : null,
                    onSaved: (value) => segundoApellido = value,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Telefono',
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Por favor ingrese su telefono';
                      } else if (value.length > 8 || value.length < 8) {
                        return 'Numero incorrecto';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => telefonocliente = value,
                  ),
                  DropdownButtonFormField<String>(
                    value: departamentoSelected,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 20,
                    elevation: 16,
                    isDense: true,
                    decoration: new InputDecoration(
                      labelText: 'Departamento',
                    ),
                    onChanged: (String newValue) {
                      setState(() {
                        departamentoSelected = newValue;
                        fiterMunicipios(newValue);
                      });
                    },
                    items: departamentos.entries.map<DropdownMenuItem<String>>(
                        (MapEntry<int, String> e) {
                      return DropdownMenuItem<String>(
                          value: e.key.toString(), child: Text(e.value));
                    }).toList(),
                  ),
                  FutureBuilder<String>(
                      future: _calculation,
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.hasData) {
                          return DropdownButtonFormField<String>(
                            value: municipioSelected,
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 20,
                            elevation: 16,
                            isDense: true,
                            decoration: new InputDecoration(
                              labelText: 'Municipio',
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                municipioSelected = newValue;
                              });
                            },
                            items: municipios.map((dynamic map) {
                              return new DropdownMenuItem<String>(
                                value: map['codigo_municipio'],
                                child: Text(map['Municipio']),
                              );
                            }).toList(),
                          );
                        } else {
                          return new CircularProgressIndicator();
                        }
                      }),
                  Row(
                    children: <Widget>[
                      Flexible(
                          child: TextField(
                        style: new TextStyle(
                          color: Colors.black,
                        ),
                        controller: _controllerDate,
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                          isDense: true,
                          labelText: 'Fecha de nacimiento',
                        ),
                      )),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        color: Color(0xff8877ff),
                        onPressed: () {
                          selectStartDate(context);
                        },
                      )
                    ],
                  ),
                  tipocliente == 'trabajador'
                      ? TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            hintText:
                                'Soy una persona responsable con más de 5 años de experiencia...',
                            labelText: 'Acerca de ti',
                          ),
                          validator: (value) => value.isEmpty
                              ? 'Este campo es obligatorio'
                              : null,
                          onSaved: (value) => descripcion = value,
                          maxLines: 6,
                        )
                      : Container(),
                  Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: double.infinity,
                      child: new RaisedButton(
                          color: Color(0xff8877ff),
                          child: new Text('Registrarme',
                              style: new TextStyle(
                                  fontSize: 20.0, color: Colors.white)),
                          onPressed: validateAndSubmit)),
                ].expand(
                  (widget) => [
                    widget,
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
