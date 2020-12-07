import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_websocket_test/http_overrides/custom_http_overrides.dart';
import 'package:http/http.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
    return MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, @required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool connected = false;
  bool enableStompClient = true;
  bool enableOfficialWebSocket = false;
  Map<String, String> headers = new HashMap();

  // Correct URL (Connect to self made websocket-demo project: 'ws://192.168.88.156:8080/ws/websocket')
  // Correct URL: (Connect to self made juno-titan/titan-rest project: 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket')
  // String url = 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket';
  String url = 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket';
  String tokenValue =
      'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiJlNjJiODg0OS03YjM4LTQzYTctODExOS1hYzU4MmE1ZWJhMjYiLCJzdWIiOiItIiwiUF9MSUQiOiJhTHB3d0tRK0ZBRlM5a055VEt4bDl3PT1CWkVSdmV4bU01OHZFMTVxUXllcU82dHRORjgyL3Y1MWZCNEtmWm5LMUpRPSIsIlBfVUlEIjoiVjhDU0g0TEpPNUVzNVNrSW1RcTVwdz09TnVjZW9HVnBYcFZNVlFFcUxyVFQybnUxYTliZC9HWEFpNDZIcnZEKzhmOD0iLCJpYXQiOjE2MDcwODIzNzMsImV4cCI6MTYwNzExODM3M30.WrazaCBDh04mYLzhFON1jHOE7GK7l2gSK9S30h4R7AB21lXlbcvKOlM33YsxqXamZde5KbymxdTrqmWAoT9pmA';

  // String url = 'ws://echo.websocket.org';

  // /user/${event.userId}/notifications
  String stompTopic = '/secured/user/5fb7a5826279716b34d1153d/notifications';
  String stompSendMessageTopic = '/app/chat.sendMessage';

  TextEditingController _controller = TextEditingController();
  WebSocketChannel webSocketChannel;
  Stream<dynamic> webSocketStream;
  StompClient stompClient;

  String stompClientDebugMessage = '';
  String officialWebSocketDebugMessage = '';

  @override
  void initState() {
    headers.putIfAbsent('Authorization', () => tokenValue);
    super.initState();
  }

  testStompClientPlugin() async {
    print("testStompClientPlugin()");
    try {
      print('headers.length: ${headers.length}');
      headers.forEach((key, value) {
        print('key: $key');
        print('value: $value');
      });
      stompClient = StompClient(
          config: StompConfig(
        // useSockJS: false,
        reconnectDelay: 3000,
        heartbeatIncoming: 10000,
        heartbeatOutgoing: 10000,
        connectionTimeout: Duration(seconds: 5),
        url: url,
        onConnect: (StompClient client, StompFrame frame) {
          print('main.dart onConnect()');
          subscribeToSTOMPSTopic(client, frame, stompTopic: stompTopic);
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
          setState(() {
            stompClientDebugMessage = debugMessage;
          });
          print('main.dart onDebugMessage:');
          print('main.dart debugMessage: $debugMessage');
        },
        stompConnectHeaders: headers,
        webSocketConnectHeaders: headers,
      ));
      stompClient.activate();
      print('main.dart CHECKPOINT 1');
    } catch (e) {
      print('main.dart connect to websocket failed.');
    }
  }

  subscribeToSTOMPSTopic(StompClient client, StompFrame frame, {String stompTopic}) {
    print('main.dart subscribeToSTOMPSTopic()');
    client.subscribe(
        destination: stompTopic,
        callback: (stompFrame2) {
          print('main.dart stompFrame2: ${stompFrame2}');
          // print('main.dart stompFrame2.body: ${stompFrame2.body}');
          // print('main.dart stompFrame2.command: ${stompFrame2.command}');
          // print('main.dart stompFrame2.headers.length: ${stompFrame2.headers.length}');
        });
  }

  testOfficialWebSocket() async {
    print('main.dart testOfficialWebSocket()');
    webSocketChannel = IOWebSocketChannel.connect(url, headers: headers);
    webSocketStream = webSocketChannel.stream.asBroadcastStream();
    webSocketStream.listen((onData) {
      print("main.dart onData: $onData");
      setState(() {
        officialWebSocketDebugMessage = onData;
      });
    }, onError: (onError) {
      print("main.dart onError: $onError");
      print("main.dart onError.message: ${onError.message}");
      // print("main.dart onError.inner: ${onError.inner}");
      setState(() {
        officialWebSocketDebugMessage = onError.message;
      });
    }, onDone: () {
      print("main.dart onDone.");
      setState(() {
        officialWebSocketDebugMessage = 'onDone.';
      });
    }, cancelOnError: false);
  }

  void _sendMessage() async {
    print('_sendMessage()');
    if (_controller.text != null && _controller.text != '') {
      if (enableStompClient) {
        stompClient.send(destination: stompSendMessageTopic, body: _controller.text);
      }
      if (enableOfficialWebSocket) {
        webSocketChannel.sink.add(_controller.text);
      }

      print('main.dart _controller.text: ${_controller.text}');
    }
  }

  closeWebSockets() {
    print('main.dart closeWebSockets()');
    connected = false; // Just an indicator.
    if (enableStompClient) {
      stompClient.deactivate();
    }
    if (enableOfficialWebSocket) {
      webSocketChannel.sink.close(WebSocketStatus.goingAway);
    }
  }

  connectWebSockets() {
    print('main.dart connectWebSockets()');
    connected = true; // Just an indicator.
    if (enableStompClient) {
      testStompClientPlugin();
    }
    if (enableOfficialWebSocket) {
      testOfficialWebSocket();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('StompClient debug messages: $stompClientDebugMessage'),
                SizedBox(
                  height: 50,
                ),
                Text('Official WebSocket debug messages: $officialWebSocketDebugMessage'),
                SizedBox(
                  height: 50,
                ),
                Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message'),
                    onFieldSubmitted: (String message) {
                      _sendMessage();
                    },
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Response from STOMP Client WebSocket:'),
                    SizedBox(
                      height: 10,
                    ),
                    Text(''),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Text('Response from Official WebSocket:'),
                    SizedBox(
                      height: 10,
                    ),
                    Text(officialWebSocketDebugMessage.isNotEmpty ? officialWebSocketDebugMessage : 'No data.'),
                  ],
                ),
                RaisedButton(
                  child: Text('Connect WebSockets'),
                  onPressed: connectWebSockets,
                ),
                RaisedButton(
                  child: Text('Close WebSockets'),
                  onPressed: closeWebSockets,
                )
              ],
            ),
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

  @override
  void dispose() {
    closeWebSockets();
    super.dispose();
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
