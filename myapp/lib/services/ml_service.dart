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
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing model: $e');
      rethrow;
    }
  }

  bool _isValidTomatoLeaf(img.Image image) {
    int greenPixels = 0;
    int totalPixels = image.width * image.height;
    double avgGreen = 0, avgRed = 0, avgBlue = 0;
    double variance = 0;

    // คำนวณค่าเฉลี่ยสี
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        avgRed += pixel.r;
        avgGreen += pixel.g;
        avgBlue += pixel.b;
      }
    }

    avgRed /= totalPixels;
    avgGreen /= totalPixels;
    avgBlue /= totalPixels;

    // คำนวณความแปรปรวนของสีเขียว
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        variance += pow(pixel.g - avgGreen, 2);

        // ปรับเกณฑ์การตรวจจับสีเขียว
        if ((pixel.g > 60) && // ค่าสีเขียวขั้นต่ำ
            (pixel.g > pixel.r * 1.1) && // สีเขียวต้องมากกว่าสีแดงชัดเจน
            (pixel.g > pixel.b * 1.1) && // สีเขียวต้องมากกว่าสีน้ำเงินชัดเจน
            (pixel.g - pixel.r > 20) && // ความต่างระหว่างสีเขียวกับสีแดง
            (pixel.g - pixel.b > 20)) {
          // ความต่างระหว่างสีเขียวกับสีน้ำเงิน
          greenPixels++;
        }
      }
    }

    variance = sqrt(variance / totalPixels);
    double greenRatio = greenPixels / totalPixels;

    print('Image Analysis:');
    print('Green Ratio: ${(greenRatio * 100).toStringAsFixed(2)}%');
    print(
        'Color Averages - R: ${avgRed.toStringAsFixed(2)}, G: ${avgGreen.toStringAsFixed(2)}, B: ${avgBlue.toStringAsFixed(2)}');
    print('Green Variance: ${variance.toStringAsFixed(2)}');

    // เงื่อนไขการตรวจสอบใบมะเขือเทศ
    bool isGreenDominant = avgGreen > avgRed * 1.2 && avgGreen > avgBlue * 1.2;
    bool hasEnoughGreen =
        greenRatio > 0.25; // ต้องมีพื้นที่สีเขียวอย่างน้อย 25%
    bool hasGoodVariance = variance > 20; // ต้องมีความแปรปรวนของสีพอสมควร

    return isGreenDominant && hasEnoughGreen && hasGoodVariance;
  }

  Future<Map<String, double>> processImage(File imageFile) async {
    if (!_isInitialized) await initialize();
    print('=== Starting image processing ===');

    // เก็บข้อมูลการ preprocessing เพื่อตรวจสอบ
    Map<String, dynamic> preprocessingStats = {};

    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Could not decode image');

      // ปรับแต่งภาพก่อนวิเคราะห์
      final enhancedImage = img.adjustColor(
        image,
        brightness: 1.1, // เพิ่มความสว่างเล็กน้อย
        contrast: 1.2, // เพิ่มความคมชัด
        saturation: 1.3, // เพิ่มความอิ่มตัวของสี
      );

      // ตรวจสอบว่าเป็นใบมะเขือเทศหรือไม่
      if (!_isValidTomatoLeaf(enhancedImage)) {
        print('Image validation failed: Not a tomato leaf');
        return {'Not a tomato leaf': 1.0};
      }

      // Crop และ resize ภาพ
      final processedImage = _preprocessImage(enhancedImage);

      // แก้ไขตรงนี้: เปลี่ยนจาก _prepareModelInput เป็น _imageToTensor
      var input = _imageToTensor(processedImage);

      // ประมวลผลด้วยโมเดล
      var predictions = await _runInference(processedImage);
      print('Raw predictions: $predictions');

      // ตรวจสอบความน่าเชื่อถือของผลลัพธ์
      if (!_isReliablePrediction(predictions)) {
        print('Prediction reliability check failed');
        return {'Uncertain result - Please retake photo': 1.0};
      }

      return predictions;
    } catch (e) {
      print('Error in processImage: $e');
      rethrow;
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

    // 4. เพิ่ม debug logs สำหรับ inference
    print('Running model inference...');
    _interpreter.run(input, output);
    final results = output[0] as List<double>;
    print('Raw model output: $results');

    // 5. ปรับปรุงการคำนวณ softmax และการกรองผล
    final predictions = _processPredictions(results);

    return predictions;
  }

  // 1. ฟังก์ชันสำหรับ preprocess ภาพ
  img.Image _preprocessImage(img.Image image) {
    // ปรับความสว่างและคอนทราสต์
    final enhancedImage = img.adjustColor(
      image,
      brightness: 1.2,
      contrast: 1.3,
      saturation: 1.2,
    );

    // Crop ภาพให้เหลือเฉพาะส่วนที่สำคัญ
    final croppedImage = img.copyCrop(
      enhancedImage,
      x: enhancedImage.width ~/ 6,
      y: enhancedImage.height ~/ 6,
      width: enhancedImage.width * 2 ~/ 3,
      height: enhancedImage.height * 2 ~/ 3,
    );

    // Resize ให้ได้ขนาดที่ต้องการ
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
    // Apply softmax
    final maxVal = results.reduce((curr, next) => curr > next ? curr : next);
    final exps = results.map((e) => exp(e - maxVal)).toList();
    final sum = exps.reduce((a, b) => a + b);
    final softmax = exps.map((e) => e / sum).toList();

    // Filter weak predictions
    final threshold = 0.1; // 10% threshold
    final labels = [
      'Late blight',
      'Early blight',
      'Bacterial spot',
      'healthy',
      'Leaf Mold',
      'Septoria leaf spot',
      'Spider mites Two-spotted spider mites',
      'Target Spot',
      'Tomato mosaic virus',
      'Tomato Yellow Leaf Curl Virus'
    ];

    Map<String, double> predictions = {};
    for (var i = 0; i < labels.length; i++) {
      if (softmax[i] >= threshold) {
        predictions[labels[i]] = softmax[i];
      }
    }

    print('\nFiltered predictions:');
    predictions.forEach((key, value) {
      print('$key: ${(value * 100).toStringAsFixed(2)}%');
    });

    return predictions;
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
