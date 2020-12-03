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
  Map<String, String> headers = new HashMap();

  // Correct URL (Connect to self made websocket-demo project: 'ws://192.168.88.156:8080/ws/websocket')
  // Correct URL: (Connect to self made juno-titan/titan-rest project: 'wss://vmerchant.neurogine.com/rest/secured/socket/websocket')
  String url = 'ws://192.168.0.195:8080/ws/websocket';

  TextEditingController _controller = TextEditingController();
  WebSocketChannel webSocketChannel;
  Stream<dynamic> webSocketStream;
  StompClient stompClient;

  String stompClientDebugMessage = '';
  String officialWebSocketDebugMessage = '';

  @override
  void initState() {
    // headers.putIfAbsent(
    //     'Authorization',
    //     () =>
    //         'Bearer eyJhbGciOiJIUzUxMiJ9.eyJqdGkiOiJkMDIyZWE4Ni00YjUyLTRhZjgtYTJlYi1jNzIwMTRjZDliYzkiLCJzdWIiOiItIiwiUF9MSUQiOiJHdHVFZkJ1NXJ4VGM0ZnhDaW9MVnhBPT15TWZFdkZnQ3dxc08wODV6TFQ2dWVRPT0iLCJQX1VJRCI6IjBSMFdnN0xlTmhIaTFjRmJ1OHY1Z3c9PUJrQUp6RzVoUUgveHRlNTNhakUwcTBrRUNOdFp2U2lxSnZSUkM4MWJ3dFk9IiwiaWF0IjoxNjA2ODkzMjE5LCJleHAiOjE2MDY5MjkyMTl9.TUxqvv_RNW0ggJvkjOmQgBtLyecL_syeZlPCuW2rz1quj7_7UexDUPijUGziXj91hMlkiiKfQvm-ovavSe3sGA');
    webSocketChannel = IOWebSocketChannel.connect(url, headers: headers);
    super.initState();
  }

  testStompClientPlugin() async {
    print("testStompClientPlugin()");
    try {
      stompClient = StompClient(
          config: StompConfig(
              useSockJS: true,
              reconnectDelay: 3000,
              connectionTimeout: Duration(seconds: 5),
              url: url,
              onConnect: (StompClient client, StompFrame frame) {
                print('main.dart onConnect()');
                // onConnect(userId, client, frame);
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
              webSocketConnectHeaders: headers));
      stompClient.activate();
      print('main.dart CHECKPOINT 1');
    } catch (e) {
      print('main.dart connect to websocket failed.');
    }
  }

  testOfficialWebSocket() async {
    print('');
    webSocketStream = webSocketChannel.stream.asBroadcastStream();
    webSocketStream.listen((onData) {
      print("main.dart onData: $onData");
      setState(() {
        officialWebSocketDebugMessage = onData;
      });
    }, onError: (onError) {
      print("main.dart onError: $onError");
      setState(() {
        officialWebSocketDebugMessage = onError;
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
      print('main.dart _controller.text: ${_controller.text}');
      webSocketChannel.sink.add(_controller.text);
      // String wholeURL = "http://192.168.0.139:8080" + "/testingWEbsocket";
      // Response httpResponse = await http.post(wholeURL, body: _controller.text, headers: headers);
      //
      // if (httpResponseIsCreated(httpResponse)) {
      //   print('main.dart httpResponse.body: ${httpResponse.body}');
      // }
    }
  }

  closeWebSockets() {
    webSocketChannel.sink.close();
    stompClient.deactivate();
  }

  connectWebSockets() {
    testStompClientPlugin();
    testOfficialWebSocket();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
                Text('Official WebSocket debug messages: $officialWebSocketDebugMessage'),
                Form(
                  child: TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Send a message'),
                  ),
                ),
                StreamBuilder(
                  stream: webSocketStream,
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
                  child: Text('Connect WebSockets'),
                  onPressed: connectWebSockets,
                ),
                RaisedButton(
                  child: Text('Close WebSockets'),
                  onPressed: closeWebSockets,
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
    webSocketChannel.sink.close();
    stompClient.deactivate();
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
