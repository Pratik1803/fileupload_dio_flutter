import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import "package:http/http.dart" as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  XFile? _image;
  List<XFile?> _images = [];
  String greetMsg = "";

  ImagePicker picker = ImagePicker();

  void _choose() async {
    XFile file;
    file = await picker.pickImage(
      source: ImageSource.camera,
    ) as XFile;
    if (file != null) {
      var futureImg = _upload(file);
    }
  }

// For single file
  void _upload(XFile file) async {
    print(file.path);
    Map<String, dynamic> map = {};
    map["operations"] = json.encode({
      "query":
          "mutation SingleUpload(\$file:Upload!){singleUpload(file:\$file)}",
      "variables": {"file": null}
    });
    map["map"] = json.encode({
      "file": ["variables.file"]
    });

    FormData data = FormData.fromMap(map);
    data.files.add(MapEntry("file", MultipartFile.fromFileSync(file.path)));

    Dio dio = new Dio();

    Response res = await dio.post("http://192.168.43.17:8084/graphql",
        data: data,
        options: Options(headers: {"apollo-require-preflight": true}));
    print(res);
  }

  // For Selecting files for Multiple Upload
  void _chooseMultiple() async {
    _images = await picker.pickMultiImage();
    if (_images.isEmpty) return;

    List correspondingNullImageArray = [];
    for (var element in _images) {
      correspondingNullImageArray.add(null);
    }

    Map<String, dynamic> map = {};
    map["operations"] = json.encode({
      "query":
          "mutation MultipleUpload(\$files:[Upload!]){multipleUpload(files:\$files)}",
      "variables": {"files": correspondingNullImageArray}
    });

    Map<String, dynamic> mapField = {};
    for (var i = 0; i < _images.length; i++) {
      mapField["$i"] = ["variables.files.$i"];
    }
    map["map"] = json.encode(mapField);

    FormData data = FormData.fromMap(map);
    for (var i = 0; i < _images.length; i++) {
      data.files
          .add(MapEntry("$i", MultipartFile.fromFileSync(_images[i]!.path)));
    }

    Dio dio = new Dio();
    Response res = await dio.post("http://192.168.43.17:8084/graphql",
        data: data,
        options: Options(headers: {"apollo-require-preflight": true}));
    print(res);
  }

// Function to trigger Greet
  Future<String?> greet() async {
    Dio dio = new Dio();
    try {
      Map<String, dynamic> greetMap = {
        "query": "query{greet}",
      };
      var response =
          await dio.post("http://192.168.43.17:8084/graphql", data: greetMap);
      print(response.data);
    } catch (e) {
      print("Err in greeting: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(onPressed: greet, child: Text("Greet")),
            SizedBox(
              height: 20,
            ),
            TextButton(
              onPressed: _chooseMultiple,
              child: Text("Upload Multiple Images"),
            ),
            SizedBox(
              height: 10,
            ),
            // ElevatedButton(
            //     onPressed: onPressed, child: Text("Upload (Multiple)"))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _choose,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
