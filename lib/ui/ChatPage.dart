import 'dart:io';

import 'package:chat_flutter/ui/ChatMessageItem.dart';
import 'package:chat_flutter/ui/TextComposer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  FirebaseUser _currentUser;
  final GlobalKey<ScaffoldState> _scafoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _currentUser = user;
      });
    });
  }

  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<FirebaseUser> _getUser() async {
    if (_currentUser != null) return _currentUser;

    try {
      final GoogleSignInAccount googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      final AuthResult result =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final FirebaseUser user = result.user;

      return user;
    } catch (error) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scafoldKey,
      appBar: AppBar(
        title: Text("Chat"),
        centerTitle: true,
        backgroundColor: Colors.amber,
        actions: <Widget>[
          _currentUser != null
              ? IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                    googleSignIn.signOut();
                    _scafoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          "Bye, see you later!",
                        ),
                        backgroundColor: Colors.amber));
                  },
                )
              : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance
                .collection("messages")
                .orderBy("time")
                .snapshots(),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );

                default:
                  List<DocumentSnapshot> docs =
                      snapshot.data.documents.reversed.toList();

                  return ListView.builder(
                      reverse: true,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        return ChatMessageItem(docs[index].data,
                        docs[index].data["uid"] == _currentUser?.uid);
                      });
              }
            },
          )),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage)
        ],
      ),
    );
  }

  void _sendMessage({String message, File image}) async {
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scafoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
            "Error, try again later",
          ),
          backgroundColor: Colors.amber));
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderImage": user.photoUrl,
      "time": Timestamp.now()
    };

    if (image != null) {
      setState(() {
        _isLoading = true;
      });
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child(user.uid + DateTime.now().millisecondsSinceEpoch.toString())
          .putFile(image);

      StorageTaskSnapshot storageTaskSnapshot = await task.onComplete;
      String url = await storageTaskSnapshot.ref.getDownloadURL();
      data["imageUrl"] = url;
      Firestore.instance.collection("messages").add(data);

      setState(() {
        _isLoading = false;
      });
    } else if (message != null || message.isNotEmpty) {
      data["message"] = message;
      Firestore.instance.collection("messages").add(data);
    }
  }
}
