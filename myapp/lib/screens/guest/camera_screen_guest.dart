import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io'; // เพิ่ม import นี้
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';
import '../../services/ml_service.dart'; // เพิ่ม import

class CameraScreenGuest extends StatefulWidget {
  const CameraScreenGuest({super.key});

  @override
  State<CameraScreenGuest> createState() => _CameraScreenGuestState();
}

class _CameraScreenGuestState extends State<CameraScreenGuest> {
  CameraController? controller;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.max);
    await controller!.initialize();
    if (!mounted) return;
    setState(() => _isCameraInitialized = true);
  }

  Future<void> _takePicture() async {
    if (!_isCameraInitialized) return;

    try {
      final image = await controller!.takePicture();
      if (!mounted) return;

      final context = this.context;
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // ส่ง mock predictions แทนการใช้ diseaseName
      if (context.mounted) {
        await _analyzeCapturedImage(image.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to capture image')),
      );
    }
  }

  Future<void> _analyzeCapturedImage(String imagePath) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // ใช้ MLService แทน mock data
      final results = await MLService.instance.processImage(File(imagePath));

      if (mounted) {
        Navigator.pop(context); // Hide loading

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: imagePath,
              predictions: results,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        Navigator.pop(context); // Hide loading if showing
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing image: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Camera"),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview with Overlay
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(controller!),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.width * 0.8,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Position leaf in frame',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Questrial',
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 3,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top Helper Text
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: const Text(
                'Center the leaf for best results',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Questrial',
                  backgroundColor: Colors.black38,
                ),
              ),
            ),
          ),

          // Bottom Controls Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 120,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF7D2424),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7D2424).withAlpha(128),
                          spreadRadius: 2,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
