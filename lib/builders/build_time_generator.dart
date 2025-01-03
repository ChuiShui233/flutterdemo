import 'package:build/build.dart';
import 'dart:async';

class BuildTimeGenerator extends Builder {
  final String format;

  BuildTimeGenerator(BuilderOptions options)
      : format = options.config['format'] as String? ?? "yyyy-MM-dd HH:mm:ss";

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final outputId = buildStep.inputId.changeExtension('.g.dart');
    final now = DateTime.now();
    final formattedTime = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

    final content = '''
      const String buildTime = '$formattedTime';
    ''';

    await buildStep.writeAsString(outputId, content);
  }

  @override
  Map<String, List<String>> get buildExtensions => const {
    '.dart': ['.g.dart']
  };
}

Builder buildTimeGenerator(BuilderOptions options) => BuildTimeGenerator(options);