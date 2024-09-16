import 'dart:convert'; // Import for base64 encoding
import 'dart:io'; // Import for File
import 'package:edge_detection/edge_detection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../ServerService/Server.dart';
import 'package:path/path.dart';

class CameraServices {

  final ImagePicker _picker = ImagePicker();
  Servers servers = Servers();
  Future<String>? imageLabel;
  String _imageText = "";

  Future<void> pickImage(BuildContext context) async {

    final selectedOption = await showImageSourceDialog(context);
    if (selectedOption != null) {
      XFile? image;
      if (selectedOption == ImageSource.camera) {
        String imagePath = join((await getApplicationSupportDirectory()).path,
            "${(DateTime.now().millisecondsSinceEpoch / 1000).round()}.jpeg");
        await image?.saveTo(imagePath);
        try {

          bool success = await EdgeDetection.detectEdge(imagePath,
            canUseGallery: true,
            androidScanTitle: 'خذ الصورة',
            androidCropTitle: 'قص الصورة',
            androidCropBlackWhiteTitle: 'ابيض و أسود',
            androidCropReset: 'الصورة العادية',
          );

          if (success) {

            String base64Image = await _convertImageToBase64(imagePath);
            String label = await servers.sendToCameraServer(base64Image, context);
            setText(label);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم التشكيل')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لم يتم التصوير')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('لم يتم التصوير ${e.toString()}')),
          );
        }
      } else if (selectedOption == ImageSource.gallery) {

        image = await _openGallery(context);
        if (image != null) {

          String base64Image = await _convertImageToBase64(image.path);
          imageLabel = servers.sendToCameraServer(base64Image, context);
          String label = await imageLabel!;
          setText(label);

        }
      }
      }
    }

  void setText(String text) {
    _imageText = text;
  }

  String getText() {
    return _imageText;
  }

  // Function to open the camera and take a photo
  Future<XFile?> _openCamera(BuildContext context) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        return photo;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم تأخذ الصورة')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في أخذ الصورة ${e}')),
      );
    }
    return null;
  }

  Future<XFile?> _openGallery(BuildContext context) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        return image;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لم يتم اختيار الصورة ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في اختيار الصورة ${e}')),
      );
    }
    return null;
  }

  // Function to show a dialog allowing the user to choose between camera and gallery
  Future<ImageSource?> showImageSourceDialog(BuildContext context) async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('اختر النوع '),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.of(context).pop(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.of(context).pop(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String> _convertImageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to Base64: $e');
      return "";
    }
  }
}
