import 'package:flutter/material.dart';
import '../list_trabajadores.dart';

class NavDrawerCliente extends StatelessWidget {
  NavDrawerCliente({this.homecontext, this.onSignedOut});
  BuildContext homecontext;
  final VoidCallback onSignedOut;
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Container(
      color: Colors.black,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'WANYOB',
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            title: Text('Inbox',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                )),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => listTrabajadores(
                          nombreCategoria: 'inbox',
                          codigoCategoria: '',
                        )),
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
            title: Text('Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                )),
            onTap: () {
              onSignedOut();
            },
          ),
        ],
      ),
    ));
  }
}