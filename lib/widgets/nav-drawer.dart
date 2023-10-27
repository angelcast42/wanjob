import 'package:flutter/material.dart';
import '../list_trabajadores.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NavDrawer extends StatelessWidget {
  NavDrawer({this.homecontext, this.onSignedOut});
  BuildContext homecontext;
  String uid;
  final VoidCallback onSignedOut;
  void initState() {
    setUserId();
  }

  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    this.uid = user.uid;
  }

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
              'Rita',
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
                          codigoCategoria: this.uid,
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
