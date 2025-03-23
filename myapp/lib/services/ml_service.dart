import 'dart:io';
import 'dart:math' show exp;
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

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        if ((pixel.g > pixel.r * 1.2) &&
            (pixel.g > pixel.b * 1.2) &&
            (pixel.g > 100)) {
          greenPixels++;
        }
      }
    }

    double greenRatio = greenPixels / totalPixels;
    return greenRatio > 0.3;
  }

  Future<Map<String, double>> processImage(File imageFile) async {
    if (!_isInitialized) await initialize();
    print('=== Starting image processing ===');

    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('Could not decode image');

    final enhancedImage = img.adjustColor(
      image,
      brightness: 1.1,
      contrast: 1.2,
      saturation: 1.2,
    );

    final croppedImage = img.copyCrop(
      enhancedImage,
      x: enhancedImage.width ~/ 6,
      y: enhancedImage.height ~/ 6,
      width: enhancedImage.width * 2 ~/ 3,
      height: enhancedImage.height * 2 ~/ 3,
    );

    final resizedImage = img.copyResize(
      croppedImage,
      width: 128,
      height: 128,
      interpolation: img.Interpolation.cubic,
    );

    var input = List.generate(
      1,
      (index) => List.generate(
        128,
        (y) => List.generate(
          128,
          (x) => List.generate(
            3,
            (c) {
              final pixel = resizedImage.getPixel(x, y);
              final value = c == 0
                  ? pixel.r
                  : c == 1
                      ? pixel.g
                      : pixel.b;
              return (value - 127.5) / 127.5;
            },
          ),
        ),
      ),
    );

    try {
      if (!_isValidTomatoLeaf(resizedImage)) {
        return {'Not a tomato leaf': 1.0};
      }

      final outputShape = [1, 10];
      var output = List.filled(outputShape[0] * outputShape[1], 0.0)
          .reshape(outputShape);

      _interpreter.run(input, output);
      final results = output[0] as List<double>;

      var filteredResults = List<double>.from(results);
      for (var i = 0; i < filteredResults.length; i++) {
        if (filteredResults[i] < 0.1) {
          filteredResults[i] = 0.0;
        }
      }

      final sum = filteredResults.reduce((a, b) => a + b);
      if (sum > 0) {
        filteredResults = filteredResults.map((e) => e / sum).toList();
      }

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
        predictions[labels[i]] = filteredResults[i];
        print(
            '${labels[i]}: ${(filteredResults[i] * 100).toStringAsFixed(2)}%');
      }

      var maxPrediction =
          predictions.entries.reduce((a, b) => a.value > b.value ? a : b);
      print(
          'Highest confidence: ${maxPrediction.key} with ${(maxPrediction.value * 100).toStringAsFixed(2)}%');

      return predictions;
    } catch (e) {
      print('Error in model inference: $e');
      rethrow;
    }
  }
}
