import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Servers {
  bool _isConnected = false; // Tracks the connection status
  final String _serverURL = "http://44.223.68.179:5000/";
  // Function to check the server connection status
  Future<void> _initializeConnection(BuildContext context) async {
    if (!_isConnected) {
      _isConnected = await serverConnection(context);
    }
  }

  Future<bool> serverConnection(BuildContext context) async {
    var url = Uri.parse(_serverURL);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ لا يمكن تشكيل الكلام بسبب عدم الاتصال بالسيرفر: ${response.statusCode}')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ اثناء الاتصال بالسيرفر  $e')),
      );
      return false;
    }
  }

  Future<String> sendToCameraServer(
      String base64Image, BuildContext context) async {
    await _initializeConnection(
        context); // Ensures connection is checked only once
    if (_isConnected) {
      return await _cameraConnection(base64Image, context);
    }
    return "";
  }

  Future<String> sendToTextServer(String text, BuildContext context) async {
    await _initializeConnection(
        context); // Ensures connection is checked only once
    if (_isConnected) {
      return await _textConnection(text, context);
    }
    return "";
  }

  Future<String> _textConnection(String text, BuildContext context) async {
    var url = Uri.parse('$_serverURL/tashkeel?text=$text&secret=1234512345');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // Parse the JSON response
        Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Extract the text directly as a string
        String arabicText = jsonResponse['text'];
        return arabicText;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ ف ارسال النص بسبب : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ ف ارسال النص بسبب: $e')),
      );
    }
    return "";
  }

  Future<String> _cameraConnection(
      String base64Image, BuildContext context) async {
    var url = Uri.parse('$_serverURL/ocr?secret=1234512345');
    try {
      // Create the JSON body with the correct format
      var body = json.encode({'image': 'data:image/jpeg;base64,$base64Image'});

      // Send the request to the server
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ); // Log the response body
      if (response.statusCode == 200) {
        // Parse the response JSON
        var jsonResponse = json.decode(response.body); // Log the parsed response
        // Extract the 'text' field from the response
        String extractedText = jsonResponse['text'] ?? '';
        return extractedText; // Return the extracted text
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('خطأ ف ارسال الصورة بسبب: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ ف ارسال الصورة بسبب: $e')),
      );
    }
    return "";
  }
}
