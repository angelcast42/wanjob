import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class chat extends StatefulWidget {
  chat({this.chatID, this.sender, this.receiver});
  String chatID;
  final String sender;
  final String receiver;
  @override
  _chatState createState() => _chatState();
}

class _chatState extends State<chat> {
  String uid;
  TextEditingController _controllerMessage;
  bool previousChatFlag = false;
  var dataSender = {};
  var dataReceiver = {};
  void initState() {
    super.initState();
    _controllerMessage = TextEditingController();
    setUserId();
    setDataUsers();
  }

  // validateChat() {
  //   Firestore.instance
  //       .collection('users')
  //       .document(uid)
  //       .collection('chat')
  //       .getDocuments()
  //       .then((datauser) {
  //     datauser.documents.forEach((chat) {
  //       Firestore.instance
  //           .collection('users')
  //           .document(widget.usercontact.documentID)
  //           .collection('chat').document(chat.documentID).get().then((doc){
  //             this.previousChatFlag=true
  //           })
  //     });
  //   });
  // }
  setDataUsers() {
    Firestore.instance
        .collection('users')
        .document(widget.sender)
        .get()
        .then((user) {
      setState(() {
        this.dataSender = {
          "nombre": user.data['nombre'] + ' ' + user.data['apellido'],
          "image": user.data["image"]
        };
      });
    });
    Firestore.instance
        .collection('users')
        .document(widget.receiver)
        .get()
        .then((user) {
      setState(() {
        this.dataReceiver = {
          "nombre": user.data['nombre'] + ' ' + user.data['apellido'],
          "image": user.data["image"]
        };
      });
    });
  }

  setUserId() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    uid = user.uid;
  }

  addMessage() {
    if (widget.chatID != "null") {
      Firestore.instance
          .collection('chats')
          .document(widget.chatID)
          .collection('messages')
          .add({
        "timestamp": Timestamp.now().millisecondsSinceEpoch.toString(),
        "uid": widget.sender,
        "message": _controllerMessage.text
      }).then((data) {
        setState(() {
          this._controllerMessage.text = '';
        });
      });
    } else {
      var timestamp = Timestamp.now().millisecondsSinceEpoch.toString();
      Firestore.instance
          .collection('chats')
          .document(timestamp)
          .collection('messages')
          .add({
        "timestamp": Timestamp.now().millisecondsSinceEpoch.toString(),
        "uid": widget.sender,
        "message": _controllerMessage.text
      }).then((data) {
        setState(() {
          widget.chatID = timestamp;
          this._controllerMessage.text = '';
        });
        Firestore.instance
            .collection('users')
            .document(widget.sender)
            .collection('chats')
            .document(widget.receiver)
            .setData({
          "image": this.dataReceiver['image'],
          "nombre": this.dataReceiver["nombre"],
          "idChat": timestamp
        });
        Firestore.instance
            .collection('users')
            .document(widget.receiver)
            .collection('chats')
            .document(widget.sender)
            .setData({
          "image": this.dataSender['image'],
          "nombre": this.dataSender["nombre"],
          "idChat": timestamp
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text(this.dataReceiver['nombre']),
        backgroundColor: Color(0xff8306CF),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey.shade200,
              child: widget.chatID != "null"
                  ? Center(
                      child: StreamBuilder(
                      stream: Firestore.instance
                          .collection('chats')
                          .document(widget.chatID)
                          .collection('messages')
                          .orderBy('timestamp', descending: false)
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
                                                    .data['uid'] ==
                                                widget.sender
                                            ? this.dataSender['image']
                                            : this.dataReceiver['image'])),
                                    contentPadding:
                                        EdgeInsets.only(right: 15, left: 10),
                                    title: Text(snapshot
                                        .data.documents[index].data['message']),
                                    onTap: () {},
                                  );
                                }));
                      },
                    ))
                  : Container(),
            ),
          ),
          Card(
              margin: EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(children: <Widget>[
                    Flexible(
                        child: TextField(
                      style: new TextStyle(
                        color: Colors.black,
                      ),
                      controller: _controllerMessage,
                      keyboardType: TextInputType.multiline,
                    )),
                    IconButton(
                      icon: Icon(Icons.send),
                      color: Color(0xff8306CF),
                      onPressed: () {
                        this.addMessage();
                      },
                    )
                  ])
                ],
              )),
        ],
      ),
    );
  }
}
