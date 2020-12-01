import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_websocket_test/http_overrides/custom_http_overrides.dart';
import 'package:http/http.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;


void main() async {
  ByteData byteData = await rootBundle.load('lib/keystore/vmerchant_development.cer');
  HttpOverrides.global = new CustomHttpOverrides(byteData);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiI4ZDY0ZmFhNC00ZmJlLTQ0NzctYmJmMy04ZTIxODYwZmJkYjciLCJzdWIiOiItIiwiUF9MSUQiOiJQMTlIbE55UnU5OGF2SzVLcnBTVUl3PT1LOEVpdjgrNWJFNEI0Y3Vka1MxeDkvSlFieEI5RGI3YXFnSFlqWGVaYVJBPSIsIlBfVUlEIjoiZUw0bFN6MWtUV1BBS245OE9OOXc5UT09eFczdGdTYTc5ZzlXeUVaYitsVHZMeGgzZytwcllTNy90c1RvVmNlYkxJcz0iLCJpYXQiOjE2MDY4MDc2MTIsImV4cCI6MTYwNjg0MzYxMn0.F5z2OAA0x_MFsweKtQH8CBjtyG0W1mMGPZnWEjLb_6riCUVOedHGd5q-6QAHfu3392pUr4Jnaye8TbZZEIk3NQ');
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title, // 'ws://192.168.0.139:8080/gs-guide-websocket'
        channel: IOWebSocketChannel.connect("wss://vmerchant.neurogine.com/rest/secured/socket", headers: headers),
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
//  SocketFlutterPlugin myIO;

  @override
  void initState() {
    super.initState();
  }

  testWebsocketPlugin() async {
    print("testWebsocketPlugin()");
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiI4ZDY0ZmFhNC00ZmJlLTQ0NzctYmJmMy04ZTIxODYwZmJkYjciLCJzdWIiOiItIiwiUF9MSUQiOiJQMTlIbE55UnU5OGF2SzVLcnBTVUl3PT1LOEVpdjgrNWJFNEI0Y3Vka1MxeDkvSlFieEI5RGI3YXFnSFlqWGVaYVJBPSIsIlBfVUlEIjoiZUw0bFN6MWtUV1BBS245OE9OOXc5UT09eFczdGdTYTc5ZzlXeUVaYitsVHZMeGgzZytwcllTNy90c1RvVmNlYkxJcz0iLCJpYXQiOjE2MDY4MDc2MTIsImV4cCI6MTYwNjg0MzYxMn0.F5z2OAA0x_MFsweKtQH8CBjtyG0W1mMGPZnWEjLb_6riCUVOedHGd5q-6QAHfu3392pUr4Jnaye8TbZZEIk3NQ');
    try {
      // print('websocket.service.dart connectWebSocketTest() userId: $userId');
      String webSocketUrl = 'https://vmerchant.neurogine.com/rest/secured/socket';
      // String webSocketUrl = 'wss://echo.websocket.org';

      StompClient stompClient = StompClient(
          config: StompConfig(
              useSockJS: true,
              reconnectDelay: 3000,
              connectionTimeout: Duration(seconds: 5),
              url: webSocketUrl,
              onConnect: (StompClient client, StompFrame frame) {
                print('websocket.service.dart onConnect()');
                // onConnect(userId, client, frame);
              },
              onWebSocketError: (dynamic error) {
                print('websocket.service.dart onWebSocketError:');
                print('websocket.service.dart error: $error');
                print(error.toString());
              },
              onStompError: (dynamic error) {
                print('websocket.service.dart onStompError:');
                print('websocket.service.dart error: $error');
              },
              onDebugMessage: (String debugMessage) {
                print('websocket.service.dart onDebugMessage:');
                print('websocket.service.dart debugMessage: $debugMessage');
              },
              stompConnectHeaders: headers,
              webSocketConnectHeaders: headers));
      stompClient.activate();
      print('websocket.service.dart CHECKPOINT 1');
    } catch (e) {
      print('websocket.service.dart connect to websocket failed.');
    }
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
                onPressed: () {
                  print('Pressed Nothing.');
                },
                child: Text("Run HTTP Insepctor"),
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
    if (_controller.text != null && _controller.text != '') {
      sendMessageToREST(_controller.text);
      // widget.channel.sink.add(_controller.text);
      // this.client.sendString("/app/hello", _controller.text);
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
