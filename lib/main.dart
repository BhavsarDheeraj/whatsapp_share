import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const platform = const MethodChannel('flutter.native/helper');
  String response = "Waiting to download...";
  String downloadPath = "";
  Dio dio = Dio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Share'),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _sendTapped),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(response),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: FloatingActionButton(
                  onPressed: _downloadTapped,
                  child: Icon(Icons.file_download),
                ),
              ),
              Expanded(
                child: FloatingActionButton(
                  onPressed: _sendTapped,
                  child: Icon(Icons.send),
                ),
              ),
            ],
          )
        ],
        // child: Center(
        //   child: Text(_responseFromNativeCode),
        // ),
      ),
    );
  }

  _downloadTapped() async {
    try {
      Directory directory = await getApplicationDocumentsDirectory();
      String savePath = '${directory.path}/temp.mp4';
      await dio.download('https://video.harf.in/uploads/files/videos/Chashni-Song-Bharat-Salman-Khan-Katrina-Kaif-video-status.mp4', savePath, onReceiveProgress: (rec, tot) {
        setState(() {
          var progressString = ((rec / tot) * 100).toStringAsFixed(0) + ' %';
          response = 'downloading $progressString';
        });
      });
      setState(() {
        response = "Downloaded";
        downloadPath = savePath;
      });
    } catch (e) {
      setState(() {
        response = "Error in download";
      });
    }
  }

  Future<void> _sendTapped() async {
    String response = "Start";
    try {
      final String result = await platform.invokeMethod('whatsAppShare', downloadPath);
      response = result;
    } on PlatformException catch (e) {
      response = 'Failed to invoke: ${e.message}';
    }
    setState(() {
      this.response = response;
    });
  }
}
