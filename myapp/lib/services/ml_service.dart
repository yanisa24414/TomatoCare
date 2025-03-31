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
          'assets/keras_tomato_model3.tflite'); // เปลี่ยนชื่อโมเดล
      _isInitialized = true;
    } catch (e) {
      print('Error initializing model: $e');
      rethrow;
    }
  }

  Future<Map<String, double>> processImage(File imageFile) async {
    try {
      print('Starting image analysis...');

      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) throw Exception('Could not decode image');

      // เพิ่มการตรวจสอบคุณภาพรูปภาพ
      Map<String, dynamic> stats = {};
      if (!_isQualityImage(image, stats)) {
        print('Image quality check failed:');
        print('Green ratio: ${stats['greenRatio']}');
        print('Brightness: ${stats['avgBrightness']}');
        return {'Not a tomato leaf': 1.0};
      }

      // ปรับปรุงการ preprocess
      final processedImage = _preprocessImage(image);
      print('Image preprocessed successfully');

      // ปรับปรุงการแปลงเป็น tensor
      var input = _imageToTensor(processedImage);
      print('Converted to tensor format');

      // ทำนายผลด้วยโมเดล
      final outputShape = [1, 10];
      var output =
          List.filled(outputShape[0] * outputShape[1], 0).reshape(outputShape);
      _interpreter.run(input, output);

      // แปลงผลลัพธ์และตรวจสอบความน่าเชื่อถือ
      var predictions = _processPredictions(output[0] as List<double>);
      if (!_isReliablePrediction(predictions)) {
        print('Prediction reliability check failed');
        return {'Not a tomato leaf': 1.0};
      }

      print('Analysis completed successfully');
      return predictions;
    } catch (e) {
      print('Error in processImage: $e');
      return {'Error: Failed to analyze image': 1.0};
    }
  }

  bool _isValidTomatoLeaf(img.Image image) {
    int greenPixels = 0;
    int totalPixels = image.width * image.height;
    double avgGreen = 0, avgRed = 0, avgBlue = 0;
    double totalEdges = 0;

    // วิเคราะห์สีและขอบใบ
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        final pixel = image.getPixel(x, y);

        // คำนวณค่าสีเฉลี่ย
        avgRed += pixel.r;
        avgGreen += pixel.g;
        avgBlue += pixel.b;

        // ตรวจจับสีเขียวของใบ
        if (pixel.g > 60 &&
            pixel.g > pixel.r * 1.3 &&
            pixel.g > pixel.b * 1.3) {
          greenPixels++;
        }

        // ตรวจจับขอบใบ
        final dx = image.getPixel(x + 1, y).g - image.getPixel(x - 1, y).g;
        final dy = image.getPixel(x, y + 1).g - image.getPixel(x, y - 1).g;
        final gradient = sqrt(dx * dx + dy * dy);
        if (gradient > 30) {
          // ปรับค่าตามความเหมาะสม
          totalEdges++;
        }
      }
    }

    // คำนวณค่าเฉลี่ยและอัตราส่วน
    avgRed /= totalPixels;
    avgGreen /= totalPixels;
    avgBlue /= totalPixels;

    double greenRatio = greenPixels / totalPixels;
    double edgeRatio = totalEdges / totalPixels;

    print('Leaf Analysis:');
    print('Green ratio: ${(greenRatio * 100).toStringAsFixed(2)}%');
    print('Edge ratio: ${(edgeRatio * 100).toStringAsFixed(2)}%');
    print(
        'Avg RGB: R=${avgRed.toStringAsFixed(2)}, G=${avgGreen.toStringAsFixed(2)}, B=${avgBlue.toStringAsFixed(2)}');

    // เกณฑ์ตรวจสอบที่เข้มงวดขึ้น
    return greenRatio > 0.25 && // ต้องมีพื้นที่สีเขียวมากกว่า 25%
        edgeRatio > 0.01 && // ต้องมีขอบใบชัดเจน
        avgGreen > avgRed * 1.3 && // สีเขียวต้องเด่นชัด
        avgGreen > avgBlue * 1.3;
  }

  bool _isQualityImage(img.Image image, Map<String, dynamic> stats) {
    int greenPixels = 0;
    double avgBrightness = 0;
    double avgGreen = 0, avgRed = 0, avgBlue = 0;
    int totalPixels = image.width * image.height;

    // วิเคราะห์แต่ละพิกเซล
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // คำนวณค่าสีเฉลี่ย
        avgRed += pixel.r;
        avgGreen += pixel.g;
        avgBlue += pixel.b;
        avgBrightness += (pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114);

        // ปรับเกณฑ์การตรวจจับสีเขียวให้ยืดหยุ่นขึ้น
        if (pixel.g > 60 && // ลดค่าขั้นต่ำของสีเขียว
            pixel.g > pixel.r * 0.9 && // ลดสัดส่วนระหว่างสีเขียวกับสีแดง
            pixel.g > pixel.b * 0.9) {
          // ลดสัดส่วนระหว่างสีเขียวกับสีน้ำเงิน
          greenPixels++;
        }
      }
    }

    // คำนวณค่าเฉลี่ย
    avgRed /= totalPixels;
    avgGreen /= totalPixels;
    avgBlue /= totalPixels;
    avgBrightness /= totalPixels;

    double greenRatio = greenPixels / totalPixels;

    // เก็บค่าสถิติ
    stats['greenRatio'] = greenRatio;
    stats['avgBrightness'] = avgBrightness;
    stats['avgGreen'] = avgGreen;
    stats['avgRed'] = avgRed;
    stats['avgBlue'] = avgBlue;

    // ปรับเกณฑ์การตัดสินใจให้ยืดหยุ่นขึ้น
    return greenRatio > 0.15 && // ลดเกณฑ์พื้นที่สีเขียวเหลือ 15%
        avgBrightness > 30 && // ลดค่าความสว่างขั้นต่ำ
        avgBrightness < 220; // เพิ่มค่าความสว่างสูงสุด
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
    final labels = [
      'Early blight', // [0]
      'Late blight', // [1]
      'Bacterial spot', // [2]
      'healthy', // [3]
      'Leaf Mold', // [4]
      'Septoria leaf spot', // [5]
      'Spider mites', // [6]
      'Target Spot', // [7]
      'Tomato mosaic virus', // [8]
      'Tomato Yellow Leaf Curl Virus' // [9]
    ];

    // คำนวณ softmax
    final maxVal = results.reduce((curr, next) => curr > next ? curr : next);
    final exps = results.map((e) => exp(e - maxVal)).toList();
    final sum = exps.reduce((a, b) => a + b);
    final softmax = exps.map((e) => e / sum).toList();

    // สร้าง predictions map ใส่ทุกค่าที่มากกว่า 5%
    Map<String, double> predictions = {};
    for (var i = 0; i < labels.length; i++) {
      if (softmax[i] >= 0.05) {
        // ลดเกณฑ์เหลือ 5%
        predictions[labels[i]] = softmax[i];
      }
    }

    // ถ้าไม่มีค่าใดเกิน 5% ให้ใส่ค่าที่มากที่สุด
    if (predictions.isEmpty) {
      var maxIndex = softmax.indexOf(softmax.reduce((a, b) => a > b ? a : b));
      predictions[labels[maxIndex]] = softmax[maxIndex];
    }

    // เรียงลำดับผลลัพธ์ตามค่า probability
    final sortedPredictions = Map.fromEntries(predictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)));

    print('\nFinal predictions:');
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
