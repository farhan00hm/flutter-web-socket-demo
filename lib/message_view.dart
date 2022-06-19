import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket/model/chat_message.dart';

class MessageView extends StatefulWidget {
  const MessageView({Key? key}) : super(key: key);

  @override
  _MessageViewState createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  final inputController = TextEditingController();
  StompClient? stompClient;
  final socketUrl = 'http://192.168.1.243:7001/javatechie';
  String message = '';
  List<String> messageList = [];

  void onConnect(StompFrame frame) {
    ChatMessage chatMessage =
        ChatMessage(content: "This is test", sender: "John");
    stompClient!.subscribe(
        destination: '/topic/public',
        callback: (StompFrame frame) {
          print("printing frame");
          print(frame.body);
          if (frame.body != null) {
            Map<String, dynamic> obj = json.decode(frame.body!);
            print(obj);
            List<String> messages = [];
            messageList.add(obj['content']);
            // for (int i = 0; i < obj.length; i++) {
            //   messages.add(obj['content'][i]);
            // }
            setState(() => messageList = messageList);
          }
        });
    stompClient!
        .send(destination: '/app/chat.send', body: chatMessage.toJson());
  }

  @override
  void initState() {
    super.initState();
    if (stompClient == null) {
      stompClient = StompClient(
          config: StompConfig.SockJS(
        url: socketUrl,
        onConnect: onConnect,
        onWebSocketError: (dynamic error) {
          print("on web socket error");
          print(error);
          print(error.toString());
        },
      ));
      stompClient!.activate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: inputController,
                    decoration: InputDecoration(
                      labelText: 'Send Message',
                      border: OutlineInputBorder(),
                    ),
                    style: TextStyle(fontSize: 22),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text(
                      'Send',
                      style: TextStyle(fontSize: 20),
                    ),
                    onPressed: () {
                      if (inputController.text.isNotEmpty) {
                        ChatMessage chatMessage = ChatMessage(
                          content: inputController.text,
                          sender: "John",
                        );

                        stompClient!.send(
                            destination: '/app/chat.send',
                            body: chatMessage.toJson());

                        print(inputController.text);
                        // channel.sink.add(inputController.text);
                      }
                      inputController.text = '';
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: getMessageList(),
          ),
//          Expanded(
//            child: StreamBuilder(
//              stream: channel.stream,
//              builder: (context, snapshot) {
//                if (snapshot.hasData) {
//                  messageList.add(snapshot.data);
//                }
//
//                return getMessageList();
//              },
//            ),
//          ),
        ],
      ),
    );
  }

  ListView getMessageList() {
    List<Widget> listWidget = [];

    for (String message in messageList) {
      listWidget.add(ListTile(
        title: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: TextStyle(fontSize: 22),
            ),
          ),
          color: Colors.teal[50],
          height: 60,
        ),
      ));
    }

    return ListView(children: listWidget);
  }
}
