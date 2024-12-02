

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String serverAddress = 'ai.harnischmachers.de';
List<String> filenames = [];
List<String> subfolders = [];
List<String> folderTypes = [];
       
Future<void> send(String fileContent, Function(Map<String, dynamic>) onResponse) async {
  try {
   final response = await http.post(
      Uri.parse('https://$serverAddress/prompt'),
      headers: {'Content-Type': 'application/json'},
      body: fileContent,
    );
    if (response.statusCode == 200) {
      print('JSON Datei gesendet: ${response.body}');
      Map<String, dynamic> responseBody = json.decode(response.body);
      onResponse(responseBody);
    } else {
      print('Fehler beim Senden der JSON Datei: ${response.body}');
    }
  } catch (e) {
    print('Exception beim Senden der JSON Datei: $e');
    //print('URL: https://$serverAddress/api/prompt');
    //print('File Content: $fileContent');
    //print('headers: {\'Content-Type\': \'application/json\'}');
    //print('body: $fileContent');
  }
}

void searchForImages(Map<String, dynamic> json) {
    json.forEach((key, value) {
      if (key == 'images' && value is List) {
        for (var imageInfo in value) {
          filenames.add(imageInfo['filename']);
          subfolders.add(imageInfo['subfolder']);
          folderTypes.add(imageInfo['type']);

          print('Filename: ${imageInfo['filename']}, Subfolder: ${imageInfo['subfolder']}, Type: ${imageInfo['type']}');
        }
      } else if (value is Map) {
        searchForImages(value.cast<String, dynamic>());
      }
    });
  }

Future<void> pollForResponse(String promptId, Function(Map<String, dynamic>) onResponse) async {
  Completer<void> completer = Completer<void>();
  Uri uri = Uri.https(serverAddress, '/history/$promptId');
  print(uri);
  Timer.periodic(Duration(milliseconds: 500), (timer) async {
    try {
      var response = await http.get(uri);
      Map<String, dynamic> responseBody = json.decode(response.body);
      print("body: $responseBody");
      if (responseBody.isNotEmpty) {
        print("Bildinformationen gefunden");
        print(responseBody['images']);
        // Über die Bildinformationen iterieren und in den entsprechenden Arrays speichern
        /*for (var imageInfo in responseBody['images']) {
          filenames.add(imageInfo['filename']);
          subfolders.add(imageInfo['subfolder']);
          folderTypes.add(imageInfo['type']);
          
          print('Filename: ${imageInfo['filename']}, Subfolder: ${imageInfo['subfolder']}, Type: ${imageInfo['type']}');
        }*/
        searchForImages(responseBody);
        print('Filenames: $filenames');
        timer.cancel();
        completer.complete();
        onResponse({
          'filenames': filenames,
          'subfolders': subfolders,
          'folderTypes': folderTypes,
        });
        print('Response received: $responseBody');
      } else {
        print('Response is empty, continuing to poll...');
      }
    } catch (e) {
      timer.cancel();
      completer.completeError(e);
      print('Fehler beim Abrufen der Antwort: $e');
    }
  });

  return completer.future;
}

//Post request zu Ollama
Future<String> sendPostRequestLlama(String llamaText) async {
  final url = Uri.parse('http://llama.harnischmachers.de/api/chat/completions');
  final headers = {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6ImFlZjk1NjBjLWZjNmItNGY4OC1iMjlhLTAzYjExOThkY2Q1OSJ9.AtFEbKtuRNgBNIR_5_tnZ5HebxztLPMHDFWdYMPIpvY',
    'Content-Type': 'application/json',
  };
  final body = jsonEncode({
    'model': 'mistral:7b',
    'messages': [
      {
        'role': 'user',
        'content': llamaText
      }
      ],
      'files': [
        {
            "type": "collection",
            "id": "787a019e-2633-4fd6-862b-9bc5116f08d6"
        }
    ]
    
  });

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      String llamaResponse = data['choices'][0]['message']['content'];
      return llamaResponse;
    } else {
      return('Request failed: ${response.statusCode}');
    }
  } catch (e) {
    return('Error sending POST request: $e');
  }
}
