import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'auth.dart';
import 'widgets/nav-drawercliente.dart';
import 'widgets/ListViewEffect.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'list_trabajadores.dart';

class dashboard extends StatefulWidget {
  dashboard({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  @override
  _dashboardState createState() => _dashboardState();
}

class _dashboardState extends State<dashboard> {
  Icon customIcon = const Icon(Icons.search);
  Widget customSearchBar = const Text('WANYOB');
  List<String> _list = ["Hey", "that's", "the", "effect"].toList();
  Duration _duration = Duration(milliseconds: 300);
  Map<String, Map> categorias = {};

  void initState() {
    Firestore.instance
        .collection('varios')
        .document('categorias')
        .get()
        .then((data) {
      setState(() {
        categorias = Map<String, Map>.from(data.data);
      });
    });
  }

  logOut() {
    widget.auth.singOut();
    widget.onSignedOut();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: NavDrawerCliente(
          homecontext: context,
          onSignedOut: logOut,
        ),
        appBar: AppBar(
          title: customSearchBar,
          backgroundColor: Color(0xff8877ff),
          automaticallyImplyLeading: false,
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
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = const Icon(Icons.cancel);
                    customSearchBar = const ListTile(
                      leading: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 28,
                      ),
                      title: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar servicio',
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    );
                  } else {
                    customIcon = const Icon(Icons.search);
                    customSearchBar = const Text('WANYOB');
                  }
                });
              },
              icon: customIcon,
            )
          ],
          centerTitle: true,
        ),
        body: Column(children: <Widget>[
          Container(
            padding: EdgeInsets.only(top: 15),
            child: Text('Explora una categoría',
                textAlign: TextAlign.center,
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent)),
          ),
          Container(
              child: new Container(
                  padding: EdgeInsets.all(10),
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: new ListViewEffect(
                      duration: _duration,
                      children:
                          //categorias.map((s.nombre) => _buildWidgetExample(s.nombre)).toList()
                          categorias.entries
                              .map<Widget>((MapEntry<String, Map> e) {
                        return _buildWidgetExample(e.value['nombre'], e.key);
                      }).toList())))
        ]));
  }

  Widget _buildWidgetExample(String text, String codigo) {
    return new InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => listTrabajadores(
                      nombreCategoria: text,
                      codigoCategoria: codigo,
                    )),
          );
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.deepPurpleAccent,
                borderRadius: BorderRadius.all(Radius.circular(20))),
            height: 100,
            width: double.infinity,
            margin: EdgeInsets.all(10),
            child: new Center(
                child: new Text(text,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20)))));
  }
}
