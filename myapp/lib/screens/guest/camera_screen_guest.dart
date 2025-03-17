import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../widgets/app_bar.dart';
import '../../navigation/tab_navigation.dart';
import '../common/analysis_result_screen.dart';

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

      // นำภาพไปวิเคราะห์
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: image.path,
              diseaseName: "Leaf Spot Disease",
              confidence: 92.5,
            ),
          ),
        );
      });
    } catch (e) {
      // Handle error
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
      body: Column(
        children: [
          Expanded(
            child: CameraPreview(controller!),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF7D2424),
              child: const Icon(Icons.camera_alt),
              onPressed: _takePicture,
            ),
          ),
        ],
      ),
      bottomNavigationBar: TabNavigation(
        isMember: false,
        selectedIndex: 2,
        onTabPress: (index) => Navigator.pushReplacementNamed(
          context,
          [
            '/guest/home',
            '/guest/gallery',
            '/guest/camera',
            '/guest/settings'
          ][index],
        ),
      ),
    );
  }
}
