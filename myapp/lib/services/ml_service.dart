import 'dart:io';
import 'dart:math' show exp, sqrt, pow;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  static final MLService instance = MLService._internal();
  late Interpreter _interpreter;
  bool _isInitialized = false;

  MLService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/my_model.tflite'); // เปลี่ยนชื่อโมเดล
      _isInitialized = true;
    } catch (e) {
      print('Error initializing model: $e');
      rethrow;
    }
  }

  bool _isValidTomatoLeaf(img.Image image) {
    int greenPixels = 0;
    int totalPixels = image.width * image.height;
    double avgGreen = 0;
    double avgRed = 0;
    double avgBlue = 0;
    double avgBrightness = 0;
    int brownGreenPixels = 0; // เพิ่มตัวแปรสำหรับนับพิกเซลสีน้ำตาล-เขียว

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // คำนวณค่าเฉลี่ย
        avgRed += pixel.r;
        avgGreen += pixel.g;
        avgBlue += pixel.b;
        avgBrightness += (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);

        // ตรวจจับสีเขียวปกติ
        if (pixel.g > 50 &&
            pixel.g > pixel.r * 1.1 &&
            pixel.g > pixel.b * 1.1) {
          greenPixels++;
        }

        // ตรวจจับสีน้ำตาล-เขียว (สำหรับใบที่เป็นโรค)
        else if (pixel.g > 40 && // ลดเกณฑ์สีเขียว
            pixel.r > 40 && // เพิ่มเกณฑ์สีแดง
            pixel.g >= pixel.r * 0.7 && // ผ่อนปรนสัดส่วน
            pixel.g >= pixel.b * 1.2) {
          brownGreenPixels++;
        }
      }
    }

    // คำนวณค่าเฉลี่ย
    avgRed /= totalPixels;
    avgGreen /= totalPixels;
    avgBlue /= totalPixels;
    avgBrightness /= totalPixels;

    // รวมจำนวนพิกเซลที่เป็นสีเขียวและสีน้ำตาล-เขียว
    double totalValidPixels = (greenPixels + brownGreenPixels) / totalPixels;

    print('Leaf Analysis:');
    print(
        'Green pixels: ${(greenPixels / totalPixels * 100).toStringAsFixed(2)}%');
    print(
        'Brown-green pixels: ${(brownGreenPixels / totalPixels * 100).toStringAsFixed(2)}%');
    print(
        'Total valid pixels: ${(totalValidPixels * 100).toStringAsFixed(2)}%');
    print('Avg Brightness: ${avgBrightness.toStringAsFixed(2)}');

    // เกณฑ์การตัดสินใจที่ปรับปรุงแล้ว
    return totalValidPixels > 0.1 && // ลดเกณฑ์ขั้นต่ำ
        avgBrightness > 30 && // ลดเกณฑ์ความสว่างขั้นต่ำ
        avgBrightness < 230; // เพิ่มเกณฑ์ความสว่างสูงสุด
  }

  Future<Map<String, double>> processImage(File imageFile) async {
    if (!_isInitialized) await initialize();

    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Could not decode image');

      print('Starting image analysis...');

      // ปรับปรุงขนาดภาพและคอนทราสต์
      final processedImage = _preprocessImage(image);

      // เปลี่ยนลำดับการทำงาน - วิเคราะห์โรคก่อนตรวจสอบใบ
      var predictions = await _runInference(processedImage);
      var maxPrediction =
          predictions.entries.reduce((a, b) => a.value > b.value ? a : b);

      // ถ้าพบโรคที่มีความน่าจะเป็นเพียงพอ (>20%) ให้คืนค่าเลย
      if (maxPrediction.value >= 0.2) {
        print('Found disease with confidence: ${maxPrediction.value}');
        return predictions;
      }

      // ถ้าความน่าจะเป็นต่ำ ค่อยตรวจสอบว่าเป็นใบมะเขือเทศหรือไม่
      if (!_isValidTomatoLeaf(processedImage)) {
        print('Image rejected: Not a tomato leaf');
        return {'Not a tomato leaf': 1.0};
      }

      // ถ้าเป็นใบมะเขือเทศแต่ไม่แน่ใจเรื่องโรค ให้คืนค่าโรคที่มีความน่าจะเป็นสูงสุด
      print('Image is tomato leaf with low confidence prediction');
      return predictions;
    } catch (e) {
      print('Error in processImage: $e');
      return {'Error: Failed to analyze image': 1.0};
    }
  }

  bool _isQualityImage(img.Image image, Map<String, dynamic> stats) {
    int greenPixels = 0;
    double avgBrightness = 0;
    double avgGreen = 0;
    double avgRed = 0;
    double avgBlue = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // คำนวณค่าเฉลี่ยสี
        avgRed += pixel.r;
        avgGreen += pixel.g;
        avgBlue += pixel.b;
        avgBrightness += (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);

        // ปรับเกณฑ์การตรวจจับสีเขียว
        if ((pixel.g > 50) && // ลดเกณฑ์ขั้นต่ำ
            (pixel.g > pixel.r * 0.9) && // ปรับสัดส่วนให้ยืดหยุ่นขึ้น
            (pixel.g > pixel.b * 0.9)) {
          greenPixels++;
        }
      }
    }

    // คำนวณค่าเฉลี่ย
    avgRed /= totalPixels;
    avgGreen /= totalPixels;
    avgBlue /= totalPixels;
    avgBrightness /= totalPixels;

    // เก็บค่าสถิติ
    double greenRatio = greenPixels / totalPixels;
    stats['greenRatio'] = greenRatio;
    stats['avgBrightness'] = avgBrightness;
    stats['avgGreen'] = avgGreen;
    stats['avgRed'] = avgRed;
    stats['avgBlue'] = avgBlue;

    // แสดง debug logs
    print('Image statistics:');
    print('Green ratio: ${(greenRatio * 100).toStringAsFixed(2)}%');
    print('Average brightness: ${avgBrightness.toStringAsFixed(2)}');
    print(
        'Average RGB: R=${avgRed.toStringAsFixed(2)}, G=${avgGreen.toStringAsFixed(2)}, B=${avgBlue.toStringAsFixed(2)}');

    // ปรับเกณฑ์การตัดสินใจ
    bool isGreenDominant = avgGreen > avgRed * 0.9 && avgGreen > avgBlue * 0.9;
    bool hasEnoughGreen = greenRatio > 0.05; // ลดเกณฑ์ลงเหลือ 5%
    bool hasSuitableBrightness = avgBrightness > 30 && avgBrightness < 240;

    return isGreenDominant && hasEnoughGreen && hasSuitableBrightness;
  }

  bool _isReliablePrediction(Map<String, double> predictions) {
    var sortedPredictions = predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // ถ้าค่าความน่าจะเป็นสูงสุดต่ำเกินไป
    if (sortedPredictions[0].value < 0.4) {
      return false;
    }

    // ถ้าผลต่างระหว่างอันดับ 1 และ 2 น้อยเกินไป
    if (sortedPredictions.length > 1 &&
        (sortedPredictions[0].value - sortedPredictions[1].value < 0.2)) {
      return false;
    }

    return true;
  }

  Future<img.Image> _loadAndPreprocessImage(
      File imageFile, Map<String, dynamic> stats) async {
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    // 1. ปรับปรุงการ preprocess ภาพ
    final preprocessedImage = _preprocessImage(image);
    print(
        'Preprocessed image size: ${preprocessedImage.width}x${preprocessedImage.height}');

    // 2. แปลงเป็น tensor ด้วยวิธีที่ถูกต้อง
    var input = _imageToTensor(preprocessedImage);
    print('Input tensor shape: 1x128x128x3');

    // 3. เพิ่มการ validate input
    _validateInputTensor(input);

    return preprocessedImage;
  }

  Future<Map<String, double>> _runInference(img.Image image) async {
    var input = _imageToTensor(image);
    final outputShape = [1, 10];
    var output =
        List.filled(outputShape[0] * outputShape[1], 0.0).reshape(outputShape);

    print('Running model inference...');
    _interpreter.run(input, output);
    final results = output[0] as List<double>;
    print('Raw model output: $results');

    return _processPredictions(results);
  }

  // 1. ฟังก์ชันสำหรับ preprocess ภาพ
  img.Image _preprocessImage(img.Image image) {
    // ปรับค่าความสว่างและคอนทราสต์เพื่อให้เห็นใบชัดขึ้น
    final enhancedImage = img.adjustColor(
      image,
      brightness: 1.1, // ลดลงจาก 1.2
      contrast: 1.2, // ลดลงจาก 1.3
      saturation: 1.1, // ลดลงจาก 1.2
    );

    // Crop ภาพให้เหลือเฉพาะส่วนที่สำคัญ แต่ขยายพื้นที่ให้มากขึ้น
    final croppedImage = img.copyCrop(
      enhancedImage,
      x: enhancedImage.width ~/ 8, // เปลี่ยนจาก 6 เป็น 8
      y: enhancedImage.height ~/ 8, // เปลี่ยนจาก 6 เป็น 8
      width: (enhancedImage.width * 3) ~/ 4, // ขยายพื้นที่
      height: (enhancedImage.height * 3) ~/ 4, // ขยายพื้นที่
    );

    return img.copyResize(
      croppedImage,
      width: 128,
      height: 128,
      interpolation: img.Interpolation.cubic,
    );
  }

  // 2. ฟังก์ชันแปลงภาพเป็น tensor
  List<List<List<List<double>>>> _imageToTensor(img.Image image) {
    return List.generate(
      1,
      (index) => List.generate(
        128,
        (y) => List.generate(
          128,
          (x) => List.generate(
            3,
            (c) {
              final pixel = image.getPixel(x, y);
              final value = c == 0 ? pixel.r : (c == 1 ? pixel.g : pixel.b);
              return (value - 127.5) / 127.5; // normalize to [-1, 1]
            },
          ),
        ),
      ),
    );
  }

  // 3. ฟังก์ชันตรวจสอบ input tensor
  void _validateInputTensor(List<List<List<List<double>>>> tensor) {
    if (tensor.length != 1 ||
        tensor[0].length != 128 ||
        tensor[0][0].length != 128 ||
        tensor[0][0][0].length != 3) {
      throw Exception('Invalid input tensor shape');
    }
  }

  // 4. ฟังก์ชันประมวลผล predictions
  Map<String, double> _processPredictions(List<double> results) {
    // ลดค่า temperature เพื่อให้การทำนายชัดเจนขึ้น
    const temperature = 1.0; // ปรับจาก 1.5 เป็น 1.0

    // ปรับค่า threshold ให้ต่ำลง
    const threshold = 0.05; // ปรับจาก 0.15 เป็น 0.05

    // คำนวณ softmax
    final maxVal = results.reduce((curr, next) => curr > next ? curr : next);
    final exps = results.map((e) => exp(e / temperature)).toList();
    final sum = exps.reduce((a, b) => a + b);
    final softmax = exps.map((e) => e / sum).toList();

    final labels = [
      'Bacterial spot', // สลับตำแหน่งให้ตรงกับ output ของโมเดล
      'Early blight',
      'Late blight',
      'Leaf Mold',
      'Septoria leaf spot',
      'Spider mites Two-spotted spider mites',
      'Target Spot',
      'Tomato Yellow Leaf Curl Virus',
      'Tomato mosaic virus',
      'healthy'
    ];

    // แสดง debug log สำหรับทุกค่าการทำนาย
    print('\nRaw predictions with labels:');
    for (var i = 0; i < labels.length; i++) {
      print('${labels[i]}: ${(softmax[i] * 100).toStringAsFixed(2)}%');
    }

    // สร้าง predictions map
    Map<String, double> predictions = {};
    for (var i = 0; i < labels.length; i++) {
      if (softmax[i] >= threshold) {
        predictions[labels[i]] = softmax[i];
      }
    }

    // ถ้าไม่พบค่าที่เกินค่า threshold
    if (predictions.isEmpty) {
      return {'Uncertain': 1.0};
    }

    // เรียงลำดับตามค่าความน่าจะเป็น
    var sortedPredictions = Map.fromEntries(predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));

    print('\nSorted predictions:');
    sortedPredictions.forEach((key, value) {
      print('$key: ${(value * 100).toStringAsFixed(2)}%');
    });

    return sortedPredictions;
  }

  double _calculateAverageBrightness(img.Image image) {
    double totalBrightness = 0;
    int totalPixels = image.width * image.height;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        // คำนวณความสว่างจากค่า RGB
        totalBrightness +=
            (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);
      }
    }

    return totalBrightness / totalPixels;
  }
}
