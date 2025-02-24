import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer';

class CameraScreenMember extends StatefulWidget {
  const CameraScreenMember({super.key});

  @override
  State<CameraScreenMember> createState() => _CameraScreenMemberState();
}

class _CameraScreenMemberState extends State<CameraScreenMember> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();

      log("Camera orientation: ${_cameras![0].sensorOrientation}");

      setState(() => _isCameraInitialized = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      try {
        final image = await _controller!.takePicture();
        log("📸 Image captured: ${image.path}");
      } catch (e) {
        log("❌ Error capturing image: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ✅ แสดงกล้องเต็มจอ
          Positioned.fill(
            child: _isCameraInitialized && _controller != null
                ? CameraPreview(_controller!)
                : const Center(child: CircularProgressIndicator()),
          ),

          // ✅ ปุ่มย้อนกลับ (กลับไปหน้า HomeScreenMember)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/member/home');
              },
            ),
          ),

          // ✅ ปุ่มถ่ายภาพตรงกลางด้านล่าง
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 4),
                  ),
                  child: const Icon(Icons.camera_alt,
                      size: 32, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
