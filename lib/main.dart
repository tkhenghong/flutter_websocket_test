import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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
        title: title,
        channel: IOWebSocketChannel.connect('ws://localhost:8080/gs-guide-websocket'),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
//    connect("/gs-guide-websocket", host: "192.168.88.157", port: 8080).then((StompClient client) {
//      client.subscribeString("uniqueId", "/topic/greetings",
//              (Map<String, String> headers, String message) {
//            print("Recieve $message");
//          });
//
//      print("Sending message Test...");
//      client.sendString("/topic/greetings", "Hi, Stomp");
//    });
  }

  @override
  Widget build(BuildContext context) {
//    widget.channel.stream.listen((message) {
//      print("Message Listener activated.");
//      print("message: " + message.toString());
//    });

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
              stream: widget.channel.stream,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
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
      widget.channel.sink.add(_controller.text);
    }
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    super.dispose();
  }
}