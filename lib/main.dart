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
  WidgetsFlutterBinding.ensureInitialized();
  ByteData byteData = await rootBundle.load('lib/keystore/vmerchant_development.cer');
  HttpOverrides.global = new CustomHttpOverrides(byteData);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final title = 'WebSocket Demo';
    Map<String, String> headers = new HashMap();
    headers.putIfAbsent('Authorization', () => 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiJmNGE2MTZmMi0xYjdlLTQxYTUtOGUwMy05NjRkMWIzNzAwYzAiLCJzdWIiOiItIiwiUF9MSUQiOiJjTGZHOC9XS0EzYnpwSDlJMEJnd3NRPT0vYmdscGU1NlpGbUtyVVd4c3R6VHRRPT0iLCJQX1VJRCI6Im4yRzNiV2ZsZ0pSQVJqN0dDRDJUeXc9PXluRUpYUkZZT3dIbkZ4a0dXZFQwUC93Z3cwL3JBT0JhRDBJaVRaQ2h6Ym89IiwiaWF0IjoxNjA2ODk2MTA5LCJleHAiOjE2MDY5MzIxMDl9');
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
        // Correct URL (Connect to self made websocket-demo project: 'ws://192.168.88.156:8080/ws/websocket')
        // Correct URL: (Connect to self made juno-titan/titan-rest project: 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket')
        channel: IOWebSocketChannel.connect("ws://192.168.88.156:8080/ws/websocket", headers: headers),
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
    headers.putIfAbsent('Authorization', () => 'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiJmNGE2MTZmMi0xYjdlLTQxYTUtOGUwMy05NjRkMWIzNzAwYzAiLCJzdWIiOiItIiwiUF9MSUQiOiJjTGZHOC9XS0EzYnpwSDlJMEJnd3NRPT0vYmdscGU1NlpGbUtyVVd4c3R6VHRRPT0iLCJQX1VJRCI6Im4yRzNiV2ZsZ0pSQVJqN0dDRDJUeXc9PXluRUpYUkZZT3dIbkZ4a0dXZFQwUC93Z3cwL3JBT0JhRDBJaVRaQ2h6Ym89IiwiaWF0IjoxNjA2ODk2MTA5LCJleHAiOjE2MDY5MzIxMDl9');
    try {
      // Correct URL (Connect to self made websocket-demo project: 'ws://192.168.88.156:8080/ws/websocket')
      // Correct URL: (Connect to self made juno-titan/titan-rest project: 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket')
      String webSocketUrl = 'ws://192.168.88.156:8080/ws/websocket';

      StompClient stompClient = StompClient(
          config: StompConfig(
              useSockJS: true,
              reconnectDelay: 3000,
              connectionTimeout: Duration(seconds: 60),
              url: webSocketUrl,
              onConnect: (StompClient client, StompFrame frame) {
                print('main.dart onConnect()');
                client.subscribe(destination: '/topic/public', callback: (message) {
                  print('main.dart client.subscribe callback is working.');
                  print('main.dart message: $message');
                });
                Timer.periodic(Duration(seconds: 2), (_) {
                  print('main.dart Send message from here!');
                  client.send(destination: '/app/chat.sendMessage', body: 'Test message sent!');
                });

              },
              onWebSocketError: (dynamic error) {
                print('main.dart onWebSocketError:');
                print('main.dart error: $error');
                print(error.toString());
              },
              onStompError: (dynamic error) {
                print('main.dart onStompError:');
                print('main.dart error: $error');
              },
              onDebugMessage: (String debugMessage) {
                print('main.dart onDebugMessage:');
                print('main.dart debugMessage: $debugMessage');
              },
              // stompConnectHeaders: headers,
              webSocketConnectHeaders: headers));
      stompClient.activate();
      print('main.dart CHECKPOINT 1');
    } catch (e) {
      print('main.dart connect to websocket failed.');
    }
  }

  @override
  Widget build(BuildContext context) {
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
