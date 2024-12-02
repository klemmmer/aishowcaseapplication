

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'image_grid_screen.dart';
import 'network_service.dart';

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _controller1 = TextEditingController(text: "Clemens sitting on a black bench. Looking into the camera. Background is a park with trees and a blue sky.");
  final TextEditingController _controller2 = TextEditingController();
  late WebSocketChannel channel;
  late String myUuid;
  bool textChanged = false;
  late String fileContent;
  List<String> filenames = [];
  List<String> subfolders = [];
  List<String> folderTypes = [];
  String llamaText = "Why is the Sky blue?";
  late Uint8List imageData;
  String prompt_id = '';
  bool isLoading = false; // Variable to track loading state von Comfyui
  bool isLlamaLoading = false; // Variable to track loading state von Llama

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  // Establish a connection to the WebSocket server
  void _connect() {
    myUuid = Uuid().v4(); // Erzeugt eine zufällige UUID
    channel = WebSocketChannel.connect(
      Uri.parse('wss://ai.harnischmachers.de/ws?clientId=$myUuid'),
    );
    print('WebSocket-Verbindung erfolgreich aufgebaut');
  }

  // Update JSON text
  Future<void> _updateJsonText(String filePath, String newText) async {
    setState(() {
      textChanged = true;
    });
    try {
      fileContent = await rootBundle.loadString(filePath);
      Map<String, dynamic> jsonContent = json.decode(fileContent);
      String jsonString = json.encode(jsonContent);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Wert ändern
      jsonData['prompt']['28']['inputs']['string'] = newText;

      // JSON-Inhalt in Variable speichern
      final updatedJsonString = json.encode(jsonData);
      fileContent = updatedJsonString;
    } catch (e) {
      print('Error: $e');
    }
  }

   void _showResponsePopup(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Llama Response'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Input Screen'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller1,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your text',
              ),
              enabled: !isLoading, // Disable TextField when loading
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                try {
                  await _updateJsonText('assets/workflow_clemens.json', _controller1.text);
                  print("JSON Text aktualisiert");
                  await send(fileContent, (responseBody) {
                    setState(() {
                      prompt_id = responseBody['prompt_id'];
                    });
                  });
                  print("Daten gesendet");
                  await pollForResponse(prompt_id, (responseBody) {
                    setState(() {
                      filenames = responseBody['filenames'];
                      subfolders = responseBody['subfolders'];
                      folderTypes = responseBody['folderTypes'];
                      isLoading = false;
                    });
                  });
                  print("Bild wird abgerufen");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageGridScreen(
                        filenames: filenames,
                        subfolders: subfolders,
                        folderTypes: folderTypes,
                      ),
                    ),
                  );
                } catch (e) {
                  print("Fehler: $e");
                }
              },
              child: isLoading ? CircularProgressIndicator() : Text('Send'),
            ),
            SizedBox(height: 10),
            TextField(
  controller: _controller2,
  maxLines: 10,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Was möchtest du wissen?',
  ),
  enabled: !isLlamaLoading, // Textfeld wird deaktiviert während des Ladens
),
SizedBox(height: 20),
ElevatedButton(
  onPressed: isLlamaLoading ? null : () async {
    setState(() {
      isLlamaLoading = true; // Setze Loading-Status auf true
    });
    String llamaResponse = await sendPostRequestLlama(_controller2.text);
    _showResponsePopup(llamaResponse);
    setState(() {
      isLlamaLoading = false; // Setze Loading-Status zurück auf false
    });
  },                
  child: isLlamaLoading 
    ? SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ) 
    : Text('Senden'),
),
          ],
        ),
      ),
    );
  }
}
