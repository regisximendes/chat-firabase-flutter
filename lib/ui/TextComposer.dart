import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  final Function({String message, File image}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {
  bool _hasMessage = false;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
              icon: Icon(Icons.image),
            onPressed: () async {
               final PickedFile imageFile = await ImagePicker().getImage(source: ImageSource.gallery);
               if(imageFile != null) {
                 widget.sendMessage(image: File(imageFile.path));
               }
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration:
                  InputDecoration.collapsed(hintText: "Send messsge..."),
              onChanged: (text) {
                setState(() {
                  _hasMessage = text.isNotEmpty;
                });
              },
              onSubmitted: (text) {
                widget.sendMessage(message: text);
                clearTexField();
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _hasMessage
                ? () {
                    widget.sendMessage(message: _textController.text);
                    clearTexField();
                  }
                : null,
          )
        ],
      ),
    );
  }

  void clearTexField() {
    _textController.clear();
    setState(() {
      _hasMessage = false;
    });
  }
}
