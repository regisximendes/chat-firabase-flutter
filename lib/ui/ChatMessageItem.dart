import 'package:flutter/material.dart';

class ChatMessageItem extends StatelessWidget {
  ChatMessageItem(this.data, this.isMyMessage);

  final Map<String, dynamic> data;
  final bool isMyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            !isMyMessage
                ? Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(data["senderImage"]),
                    ),
                  )
                : Container(),
            Expanded(
                child: Column(
              crossAxisAlignment: isMyMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: <Widget>[
                data["imageUrl"] != null
                    ? Image.network(
                        data["imageUrl"],
                        width: 250,
                      )
                    : Text(data["message"],
                    textAlign: isMyMessage ? TextAlign.end : TextAlign.start ,
                    style: TextStyle(fontSize: 16)),
                Text(
                  data["senderName"],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                )
              ],
            )),
            isMyMessage
                ? Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(data["senderImage"]),
                    ),
                  )
                : Container(),
          ],
        ));
  }
}
