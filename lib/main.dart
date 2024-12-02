
import 'package:flutter/material.dart';
import 'input_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InputScreen(),
    );
  }
}


/*
Old Class



import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: InputScreen(),
    );
  }
}
class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: WebSocketDemo(),
    );
  }
}
*/
/*class WebSocketDemo extends StatefulWidget {
  const WebSocketDemo({super.key});

  @override
  _WebSocketDemoState createState() => _WebSocketDemoState();
}*/

//class _WebSocketDemoState extends State<WebSocketDemo> {
class _InputScreenState extends State<InputScreen> {
  WebSocketChannel? channel;
  final TextEditingController _controller = TextEditingController(text: "Clemens sitting on a black bench. Looking into the camera. Background is a park with trees and a blue sky.");

  final String serverAddress = 'ai.harnischmachers.de'; // Server-Adresse
  String prompt_id = ''; // Variable zum Speichern der Antwort
  String myUuid = "1"; // Erzeugt eine initiale UUID
  String statusAnswer = ""; // Variable zum Speichern der Antwort des Servers
  List<String> filenames = []; // Liste zum Speichern der Dateinamen
  List<String> subfolders = []; // Liste zum Speichern der Unterordner
  List<String> folderTypes = []; // Liste zum Speichern der Ordner-Typen
  String subfolder = ""; 
 // String filename = "ComfyUI_00287_.png";
  String folderType = "output";
  var uuid = Uuid(); // Erzeugt eine UUID für die Verbindung
  Uint8List? imageData; // Variable zum Speichern der Bilddaten
  String fileContent = "";
  bool textChanged = false; // Variable zum Speichern des Textzustands
  bool isLoading = false; // Variable to track loading state

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

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
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

  //Establish a connection to the WebSocket server
  void _connect() {
    myUuid = uuid.v4(); // Erzeugt eine zufällige UUID
   /* channel = WebSocketChannel.connect(
      Uri.parse('wss://ai.harnischmachers.de/ws?clientId=$myUuid'),
    );
    //print('WebSocket-Verbindung erfolgreich aufgebaut');*/
  }

    // Update JSON text
  Future<void> _updateJsonText(String filePath, String newText) async {
    setState(() {
      textChanged = true;
    });
    try {
      //print(filePath);
      //print(newText); 
      fileContent = await rootBundle.loadString(filePath);
      Map<String, dynamic> jsonContent = json.decode(fileContent);
      String jsonString = json.encode(jsonContent);
 
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Wert ändern
      jsonData['prompt']['28']['inputs']['string'] = newText;

      // JSON-Inhalt in Variable speichern
      final updatedJsonString = json.encode(jsonData);
      fileContent = updatedJsonString;
      //print(fileContent);
      print('JSON Text updated successfully');
    } catch (e) {
     _showErrorDialog('Error updating JSON Text: $e');
    }
  }

  //Send the message to the WebSocket server
  Future<void> _send() async {
      try {
        if (textChanged == false) {
          print("Text wurde nicht geändert");
          fileContent = await rootBundle.loadString('assets/workflow_clemens.json');
          Map<String, dynamic> jsonContent = json.decode(fileContent);
          String jsonString = json.encode(jsonContent);
          fileContent = jsonString;
        }
      //print(fileContent);
      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: fileContent,
      );
      if (response.statusCode == 200) {
        print('JSON Datei gesendet: ${response.body}');
        Map<String, dynamic> responseBody = json.decode(response.body);
        setState(() {
          prompt_id = responseBody['prompt_id'];
        });
        print('Prompt ID: $prompt_id');
      } else {
        print('Fehler beim Senden der JSON Datei: ${response.body}');
      }
    } catch (e) {
      print('Exception beim Senden der JSON Datei: $e');
      _showErrorDialog('Fehler beim Senden der JSON Datei: $e');
      
    }
  }
 
 List<dynamic> findValuesByKey(Map<String, dynamic> json, String key) {
  List<dynamic> values = [];
  //print("Json: $json");
  //print("keys: $key");
  void _findValues(Map<String, dynamic> json, String key) {
    json.forEach((k, v) {
      if (k == key) {
        values.add(v);
        //print("Value: $v");
        print("Values: $values");
      }
      if (v is Map<String, dynamic>) {
        //print("Map gefunden");
        _findValues(v, key);
      } else if (v is List) {
        //print("List gefunden");
        for (var element in v) {
          if (element is Map<String, dynamic>) {
            _findValues(element, key);
          }
        }
      }
    });
  }
 _findValues(json, key);
  return values;
}
 
 /*
// Rekursive Funktion, um den Wert für einen bestimmten Schlüssel zu finden
dynamic findValueByKey(Map<String, dynamic> json, String key) {
  if (json.containsKey(key)) {
    return json[key];
  }
  for (var value in json.values) {
    if (value is Map) {
      var result = findValueByKey(value.cast<String, dynamic>(), key);
      if (result != null) {
        return result;
      }
    } else if (value is List) {
      for (var element in value) {
        if (element is Map) {
          var result = findValueByKey(element.cast<String, dynamic>(), key);
          if (result != null) {
            return result;
          }
        }
      }
    }
  }
  return null;
}*/

/*
  // Get history from the server
  void _getHistory(String promptId) async {
    try {
      Uri uri = Uri.https(serverAddress, '/history/$promptId');
      print("URI: $uri");
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        //print(json.decode(response.body));
        
        
        
        //ToDO das wird nie aufgerufen, die Liste ja aber vorher gefüllt. Benltige ich das noch? Wieso wird das BIld nicht angezeigt?
        Map<String, dynamic> responseBody = json.decode(response.body);
        setState(() {
          try {
              filenames = List<String>.from(findValuesByKey(responseBody, 'filename'));
              print("Filenames: $filenames"); 
              subfolders = List<String>.from(findValuesByKey(responseBody, 'subfolder'));
              folderTypes = List<String>.from(findValuesByKey(responseBody, 'type'));
              statusAnswer = responseBody['status'] as String;
          } catch (e) {
            statusAnswer = 'Status nicht gefunden';
            print("Fehler beim Abrufen des Bildes: $e");
          }

        });
        setState(() {
          statusAnswer = response.body;
        });
        print('History erhalten: ${response.body}');
      } else {
        print('Fehler beim Abrufen der History: ${response.body}');
      }
    } catch (e) {
      print('Exception beim Abrufen der History: $e');
    }
  }
*/
  Future<void> _pollForResponse(String promptId) async {
      Completer<void> completer = Completer<void>();
      Uri uri = Uri.https(serverAddress, '/history/$promptId');
      setState(() {
        isLoading = true; // Start loading
      });

        Timer.periodic(Duration(milliseconds: 500), (timer) async {
          try {
            var response = await http.get(uri);
            Map<String, dynamic> responseBody = json.decode(response.body);

            if (responseBody.isNotEmpty) {

              print("Filename gefunden");
              //print(findValuesByKey(responseBody, "filename").first as String);
              print('Response received: $responseBody');
              filenames = List<String>.from(findValuesByKey(responseBody, 'filename'));
              print("Filenames: $filenames"); 
              subfolders = List<String>.from(findValuesByKey(responseBody, 'subfolder'));
              folderTypes = List<String>.from(findValuesByKey(responseBody, 'type'));
              //filenames.add(findValuesByKey(responseBody, "filename").first as String);
              //subfolders.add(findValuesByKey(responseBody, "subfolder").first as String);
              //folderTypes.add(findValuesByKey(responseBody, "type").first as String);
              print("Filenmanes: $filenames");
            
              timer.cancel();
              completer.complete();
              setState(() {
                isLoading = false; // Stop loading
              });
            } else {
              print('Response is empty, continuing to poll...');
            }
          } catch (e) {
            timer.cancel();
            setState(() {
                isLoading = false; // Stop loading
             });
            completer.completeError(e);
            //print('Fehler beim Abrufen der Antwort: $e');
            _showErrorDialog('Fehler beim Abrufen der Antwort: $e');
          }
        });

  return completer.future;
}  

    // Get image from the server
  void _getImage(List<String>  filenames, List<String>  subfolders, List<String>  folderTypes) async {
    print("Displaying image");  
    try {
      print('Displaying image: $filenames');
      print(filenames[1]);
      Map<String, String> data = {
    
        "filename": filenames[1],
        //"subfolder": subfolders[1],
        "type": "output"
        //"type": folderType
      };
      print("data: $data");
      Uri uri = Uri.https(serverAddress, '/view', data);
      print(uri);
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() {
          imageData = response.bodyBytes;
        });
        print('Bild erhalten');
      } else {
        print('Fehler beim Abrufen des Bildes: ${response.body}');
      }
    } catch (e) {
      print('Exception beim Abrufen des Bildes: $e');
      _showErrorDialog('Fehler beim Abrufen des Bildes: $e');
    }
  }
 // Build image gallery
  Widget _buildImageGallery(List<String> imageUrls) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showImageDialog(imageUrls[index]),
          child: Image.network(imageUrls[index]),
        );
      },
    );
  }

// Show image in a dialog
  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network(imageUrl),
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your text',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : () async {
                try {
                  await _updateJsonText('assets/workflow_clemens.json', _controller.text);
                  print("JSON Text aktualisiert");
                  await _send();
                  print("Daten gesendet");
                  await _pollForResponse(prompt_id);
                  print("Bild wird abgerufen");
                  _getImage(filenames, subfolders, folderTypes);
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
                  _showErrorDialog('Fehler beim Senden der JSON Datei: $e');
                }
              },
             child: isLoading ? CircularProgressIndicator() : Text('Send'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageGridScreen extends StatelessWidget {
  final List<String> filenames;
  final List<String> subfolders;
  final List<String> folderTypes;

  ImageGridScreen({required this.filenames, required this.subfolders, required this.folderTypes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Grid'),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: filenames.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showImageDialog(context, filenames[index]),
            child: Image.network(
              'https://ai.harnischmachers.de/view?filename=${filenames[index]}&subfolder=&type=output',
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }


 // Show image in a dialog
  void _showImageDialog(BuildContext context, String filename) {
    String imageUrl = 'https://ai.harnischmachers.de/view?filename=$filename&subfolder=&type=output';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
                TextButton(
                  child: Text("Close", style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
 /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Image Demo'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Geben Sie den neuen Text ein',
              ),
            ),
            SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            onPressed: () async {
              try {
                await _updateJsonText('assets/workflow_clemens.json', _controller.text);
                print("JSON Text aktualisiert");
                await _send();
                print("Daten gesendet");
                await _pollForResponse(prompt_id);
                print("Bild wird abgerufen");
                _getImage(filenames, subfolders, folderTypes);
              } catch (e) {
                print("Fehler: $e");
              }
            },
            child: Text('Bild generieren'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Bild speichern
                if (imageData != null) {
                  // Speichern in der Galerie
                  final result = await ImageGallerySaver.saveImage(Uint8List.fromList(imageData!));
                  print('Bild gespeichert: $result');
                } else {
                  print('Kein Bild zum Speichern vorhanden');
                }
              } catch (e) {
                print('Fehler beim Speichern des Bildes: $e');
              }
            },
            child: Text('Bild speichern'),
          ),
        ],
      ),
      SizedBox(height: 20),
            Expanded(
              child: imageData != null
                  ? Image.memory(
                      imageData!,
                      fit: BoxFit.cover,
                    )
                  : Container(), // Container anzeigen, wenn kein Bild vorhanden ist
            ),
          ],
        ),
      ),
    );
  }
}*/

*/


