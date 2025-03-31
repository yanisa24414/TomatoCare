import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../../widgets/app_bar.dart';
import '../common/analysis_result_screen.dart';
import '../../db.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // เพิ่ม import นี้

class CameraScreenMember extends StatefulWidget {
  const CameraScreenMember({super.key});

  @override
  State<CameraScreenMember> createState() => _CameraScreenMemberState();
}

class _CameraScreenMemberState extends State<CameraScreenMember> {
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 1. วิเคราะห์รูปด้วยโมเดล
      final predictions =
          await DatabaseHelper.instance.analyzeImage(File(imagePath));
      final topDisease =
          predictions.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final diseaseInfo =
          await DatabaseHelper.instance.getDiseaseInfo(topDisease);

      // 2. บันทึกประวัติการสแกนสำหรับ member
      final user = DatabaseHelper.instance.client.auth.currentUser;
      if (user != null) {
        final fileName = 'scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await File(imagePath).readAsBytes();

        // อัปโหลดรูปไปยัง storage โดยใช้ fileOptions
        await DatabaseHelper.instance.client.storage
            .from('scan-images')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(
                // เปลี่ยนจาก options เป็น fileOptions
                contentType: 'image/jpeg',
                upsert: true,
              ),
            );

        // สร้าง public URL
        final imageUrl = DatabaseHelper.instance.client.storage
            .from('scan-images')
            .getPublicUrl(fileName);

        // บันทึกข้อมูลลงใน scan_history
        await DatabaseHelper.instance.client.from('scan_history').insert({
          'user_id': user.id,
          'image_url': imageUrl,
          'disease_name': topDisease,
          'confidence': ((predictions[topDisease]! * 100).round()),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // 3. แสดงผลการวิเคราะห์
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(
              imagePath: imagePath,
              predictions: predictions,
              diseaseInfo: diseaseInfo,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
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
