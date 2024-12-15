import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String predictionText = "No prediction yet";
  Color backgroundColor = Colors.white;
  bool isLoading = false; // For showing a progress indicator

  // Function to pick an audio file
  Future<void> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      String filePath = result.files.single.path!;
      String fileExtension = filePath.split('.').last.toLowerCase();
      if (fileExtension == 'm4a') {
        // Convert m4a to wav
        String wavFilePath = filePath.replaceAll('.m4a', '.wav');
        await FFmpegKit.execute('-i "$filePath" "$wavFilePath"').then((session) async {
          final returnCode = await session.getReturnCode();
          if (returnCode != null && returnCode.isValueSuccess()) {
            // Conversion successful, send the WAV file
            sendAudioToApi(File(wavFilePath));
          } else {
            // Handle conversion error
            setState(() {
              predictionText = "Error converting file to WAV.";
              backgroundColor = Colors.white;
            });
          }
        });
      } else if (fileExtension == 'wav') {
        // Directly send the WAV file
        sendAudioToApi(File(filePath));
      } else {
        // Handle unsupported file types
        setState(() {
          predictionText = "Unsupported file type. Please select an m4a or wav file.";
          backgroundColor = Colors.white;
        });
      }
    }  else {
      setState(() {
        predictionText = "No file selected.";
        backgroundColor = Colors.white;
      });
    }
  }

  // Function to send the audio to the Flask API
  Future<void> sendAudioToApi(File audioFile) async {
    setState(() {
      isLoading = true; // Start loading
    });

    var uri = Uri.parse('http://192.168.1.17:5000/predict');
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        audioFile.path,
        contentType: MediaType('audio', 'wav'), // Adjust MIME type if needed
      ));

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var responseJson = jsonDecode(responseData);
      int predictedClass = responseJson['predicted_class'];

      // Update text and background based on the prediction
      setState(() {
        isLoading = false; // Stop loading
        switch (predictedClass) {
          case 0:
            predictionText = "Stressed";
            backgroundColor = Colors.deepOrange;
            break;
          case 1:
            predictionText = "Not Stressed";
            backgroundColor = Colors.blue.shade200;
            break;
          case 2:
            predictionText = "Mildly Stressed";
            backgroundColor = Colors.orange.shade200;
            break;
          case 3:
            predictionText = "Very Stressed";
            backgroundColor = Colors.red.shade900;
            break;
          default:
            predictionText = "Unknown";
            backgroundColor = Colors.grey.shade300;
        }
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading
        predictionText = "Error occurred during prediction.";
        backgroundColor = Colors.white;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: 'M',
                      style: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'O',
                      style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'O',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'D',
                      style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: ' ',
                      style: TextStyle(color: Colors.transparent, fontSize: 20)),
                  TextSpan(
                      text: 'C',
                      style: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'A',
                      style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'L',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 20, fontWeight: FontWeight.bold)),
                  TextSpan(
                      text: 'L',
                      style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            SizedBox(width: 8), // Add spacing between text and icons
            Icon(Icons.sentiment_satisfied_alt, color: Colors.teal),
            Icon(Icons.sentiment_dissatisfied, color: Colors.orange),
            Icon(Icons.sentiment_neutral, color: Colors.blueAccent),
            Icon(Icons.sentiment_very_dissatisfied, color: Colors.red),
          ],
        ),
        backgroundColor: Colors.transparent,
      ),


      body: Container(
        color: backgroundColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card for prediction display
              Card(
                elevation: 4,
                margin: EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Prediction',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      SizedBox(height: 10),
                      isLoading
                          ? CircularProgressIndicator() // Show progress indicator while loading
                          : Text(
                        predictionText,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Button to pick an audio file
              ElevatedButton.icon(
                onPressed: pickAudioFile,
                icon: Icon(Icons.audiotrack),
                label: Text('Select an Audio File'),
                style: ElevatedButton.styleFrom(
                  iconColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
