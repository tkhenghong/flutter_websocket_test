import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        channel: IOWebSocketChannel.connect('ws://192.168.88.165:8080/topic/public'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel})
      : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Stream<dynamic> stream = widget.channel.stream.asBroadcastStream();
    stream.listen((onData) {
      print("onData listener is working.");
      print("onData: " + onData.toString());
    }, onError: (onError) {
      print("onError listener is working.");
      print("onError: " + onError.toString());
    }, onDone: () {
      print("onDone listener is working.");
    }, cancelOnError: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Form(
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Send a message'),
              ),
            ),
            StreamBuilder(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("if(snapshot.hasData)");
                  print("snapshot.data: " + snapshot.data.toString());
                } else {
                  print("if(!snapshot.hasData)");
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(snapshot.hasData ? '${snapshot.data}' : ''),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendMessage,
        tooltip: 'Send message',
        child: Icon(Icons.send),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _sendMessage() {
    print("Send Message");
    if (_controller.text.isNotEmpty) {
      addConversationGroup(_controller.text);
      widget.channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  addConversationGroup(String message) async {
    String wholeURL = "http://192.168.88.165:8080" + "/chat.sendMessage";
    var httpResponse = await http.post(wholeURL, body: message, headers: createAcceptJSONHeader());

    print("HTTP RESPONSE");
    if (httpResponseIsCreated(httpResponse)) {
//      String locationString = httpResponse.headers['location'];

      print("Run here?");
    }
    return null;
  }

  Map<String, String> createAcceptJSONHeader() {
    Map<String, String> headers = new HashMap();
    headers['Content-Type'] = "application/json";
//    headers['Connection'] = "Upgrade";
//    headers['Upgrade'] = "WebSocket";
    return headers;
  }

  bool httpResponseIsCreated(Response httpResponse) {
    if (httpResponse.statusCode == 201) {
      return true;
    } else {
      print("Request failed with status: ${httpResponse.statusCode}.");
      return false;
    }
  }
}
