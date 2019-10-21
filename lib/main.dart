import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
//import 'package:socket_flutter_plugin/socket_flutter_plugin.dart';
import 'package:alice/alice.dart';
import "package:stomp/stomp.dart";
import "package:stomp/vm.dart" show connect;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title, // 'ws://192.168.0.139:8080/gs-guide-websocket'
        channel: IOWebSocketChannel.connect("ws://192.168.0.139:8080/gs-guide-websocket"),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  final WebSocketChannel channel;

  MyHomePage({Key key, @required this.title, @required this.channel}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _controller = TextEditingController();
  Alice alice;
  StompClient client;
//  SocketFlutterPlugin myIO;

  @override
  void initState() {
    // TODO: implement initState
    alice = Alice(showNotification: true);
    super.initState();

  }

  void _runHttpInspector() {
    alice.showInspector();
  }

  testWebsocketPlugin() async {
    print("testWebsocketPlugin()");
    StompClient client = await connect("192.168.0.139", port: 8080, host: "192.168.0.139", onConnect: (StompClient client, Map<String, String> headers) {
      print("onConnect()");
    }, onError: (StompClient client, String message, String detail, Map<String, String> headers) {
      print("onError()");
    }, onFault: (StompClient client, error, stackTrace) {
      print("onFault()");
      print("client: " + client.toString());
      print("error: " + error.toString());
      print("stackTrace: " + stackTrace.toString());
    }, );
    print("Connected.");
    this.client = client;
    client.subscribeString("/topic/greetings", "/gs-guide-websocket",
            (Map<String, String> headers, String message) {

          print("Recieve $message");
        });

    print("Sending testwebsocket string");
    client.sendString("/group/0129137868", "Hi, Stomp");
  }

  @override
  Widget build(BuildContext context) {
//    testNewWebsocketPlugin();
    testWebsocketPlugin();
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

    return MaterialApp(
      navigatorKey: alice.getNavigatorKey(),
      home: Scaffold(
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
              ),
              RaisedButton(
                child: Text("Run HTTP Insepctor"),
                onPressed: _runHttpInspector,
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _sendMessage,
          tooltip: 'Send message',
          child: Icon(Icons.send),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  void _sendMessage() {
    print("Send Message");
    if (_controller.text.isNotEmpty) {
      sendMessageToREST(_controller.text);
      widget.channel.sink.add(_controller.text);
      this.client.sendString("/app/hello", _controller.text);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }

  sendMessageToREST(String message) async {
    String wholeURL = "http://192.168.0.139:8080" + "/testingWEbsocket";
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
    if (httpResponse.statusCode == 200) {
      return true;
    } else {
      print("Request failed with status: ${httpResponse.statusCode}.");
      return false;
    }
  }
}
