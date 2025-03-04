import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:developer';

class CameraScreen extends StatefulWidget {
  final bool isMember; // ตรวจสอบว่าเป็นสมาชิกหรือไม่

  const CameraScreen({super.key, required this.isMember});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _errorMessage; // ✅ เพิ่มตัวแปรเก็บข้อความ error

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(_cameras![0], ResolutionPreset.high);
        await _controller!.initialize();

        log("📷 Camera initialized: ${_cameras![0].sensorOrientation}");

        setState(() => _isCameraInitialized = true);
      } else {
        setState(() {
          _errorMessage = "ไม่พบกล้องในอุปกรณ์";
        });
      }
    } catch (e) {
      log("❌ Camera error: $e");
      setState(() {
        _errorMessage = "เกิดข้อผิดพลาดในการเปิดกล้อง";
      });
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
          // ✅ แสดงกล้อง หรือ ข้อความ Error
          Positioned.fill(
            child: _errorMessage != null
                ? Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _isCameraInitialized && _controller != null
                    ? CameraPreview(_controller!)
                    : const Center(child: CircularProgressIndicator()),
          ),

          // ✅ ปุ่มย้อนกลับ (ไปยัง Home ตามประเภทผู้ใช้)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
              onPressed: () {
                if (widget.isMember) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/member/home', (route) => false);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/guest/home', (route) => false);
                }
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
