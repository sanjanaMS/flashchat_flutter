import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final _firebase = FirebaseFirestore.instance;
User loggedInUser;


class ChatScreen extends StatefulWidget {
  static const String chat = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textController=TextEditingController();

  String message;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    getUser();
    super.initState();
  }

  void getUser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {

                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
           MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      onChanged: (value) {
                        message = value;
                        //Do something with the user input.
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textController.clear();
                      _firebase.collection('messages').add({
                        'sender': loggedInUser.email,
                        'text': message});
                      print(message);
                      //Implement send functionality.
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class Buttonbubble extends StatelessWidget {
  Buttonbubble({this.sender,this.text,this.isme});
  String text;
  String sender;
  bool isme;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0 ),
      child: Column(
        crossAxisAlignment:isme? CrossAxisAlignment.end:CrossAxisAlignment.start,
        children: [
          Text(sender,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 12.0,
          ),),
          Material(
            borderRadius:isme? BorderRadius.only(topLeft: Radius.circular(30.0),bottomLeft: Radius.circular(30.0),
            bottomRight: Radius.circular(30.0)):BorderRadius.only(
            bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),topRight: Radius.circular(30.0)),
            elevation: 5.0,
            color:isme? Colors.lightBlueAccent:Colors.white,
            child: Padding(
              padding:EdgeInsets.symmetric(horizontal: 20,vertical: 10),
              child: Text( '$text',
              style: TextStyle(
                fontSize: 20.0,
                color:isme? Colors.white:Colors.black54,

              ),),
            ),
          ),
        ],
      ),
    );
  }
}
class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  StreamBuilder<QuerySnapshot>(
        stream: _firebase.collection('messages').snapshots(),
        builder: (context, snapshot) {

          if (snapshot.hasData) {
            final messages = snapshot.data.docs.reversed;
            List<Buttonbubble> messageWidget = [];
            for (var message in messages) {
              final messageText = message.get('text');
              final messageSender = message.get('sender');
              final currentUser=loggedInUser.email;
              final meswid = Buttonbubble(sender: messageSender,text: messageText,isme: currentUser==messageSender,);
              messageWidget.add(meswid);
            }
            return Expanded(
              child: ListView(
                reverse: true,
                children: messageWidget,
              ),
            );

          }
        }

    );
  }
}
