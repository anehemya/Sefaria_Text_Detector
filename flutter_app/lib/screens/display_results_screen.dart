import 'package:flutter/material.dart';
import 'dart:io';

class DisplayResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final File croppedImage = ModalRoute.of(context)!.settings.arguments as File;

    // Placeholder for actual results, replace with API call in production
    List<String> results = ["Result 1", "Result 2", "Result 3"];

    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: Column(
        children: <Widget>[
          Image.file(croppedImage),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(results[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
