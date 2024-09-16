import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class Permisions {
  final String name;
  final BuildContext context;

  Permisions({required this.name, required this.context});

  Future<bool> checkPermissions() async {
    PermissionStatus permissionStatus;
    switch (name) {
      case "Mic":
        permissionStatus = await Permission.microphone.request();
        if (permissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      case "Camera":
        permissionStatus = await Permission.camera.request();
        if (permissionStatus.isGranted) {
          return true;
        } else {
          return false;
        }
      default:
        return false;
    }
  }
}
