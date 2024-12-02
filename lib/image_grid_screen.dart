

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
