import 'package:practice_1/features/core/data/debug/weather_repository_debug.dart';
import 'package:practice_1/features/core/data/osm/osm_api.dart';
import 'package:practice_1/features/core/data/osm/weather_repository_osm.dart';
import 'package:practice_1/features/core/presentation/app.dart';
import 'dart:io';
import 'package:lakos/lakos.dart';
import 'package:path/path.dart' as path;
import 'package:lakos/src/build_model.dart';
import 'package:test/test.dart';

const String version = '0.0.1';
const String url = 'https://api.openweathermap.org';
const String apiKey = 'f11a8d09666e4acbd56e3ecc1ccbe31b';



// Функция для создания .dot файла
void createDotFile(String projectPath, String outputFilePath) {
  final buffer = StringBuffer();
  buffer.writeln('digraph G {');

  // Рекурсивно обходим все файлы в проекте
  void parseDirectory(Directory dir) {
    for (var entity in dir.listSync(recursive: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final nodeName = path.basename(entity.path);
        buffer.writeln('"$nodeName";');
      } else if (entity is Directory) {
        parseDirectory(entity);
      }
    }
  }

  // Стартуем с корневой директории проекта
  parseDirectory(Directory(projectPath));

  buffer.writeln('}');

  // Сохраняем результат в файл
  File(outputFilePath).writeAsStringSync(buffer.toString());
  print('DOT файл успешно создан: $outputFilePath');
}

// Функция для конвертации .dot файла в .png
Future<void> convertDotToPng(String dotFilePath, String pngFilePath) async {
  try {
    // Запускаем процесс 'dot' с аргументами для конвертации .dot в .png
    final result = await Process.run('dot', ['-Tpng', dotFilePath, '-o', pngFilePath]);

    if (result.exitCode == 0) {
      print('PNG картинка успешно создана: $pngFilePath');
    } else {
      print('Ошибка при создании PNG: ${result.stderr}');
    }
  } catch (e) {
    print('Не удалось запустить Graphviz: $e');
  }
}

void createLakosGraph() async {
  // Создаем экземпляр LakosDiagramGenerator
  var model = buildModel(Directory('.'), ignoreGlob: 'test/**', showMetrics: true);

  // Генерация графа в формате DOT
  var dotOutput = model.getOutput(OutputFormat.dot);

  // Сохраняем граф в DOT-файл
  var dotFile = File('project_graph.dot');
  dotFile.writeAsString(dotOutput);

  // Проверяем наличие циклов зависимостей
  if (!model.metrics!.isAcyclic) {
    print('Dependency cycle detected.');
  }

  // Выводим метрики по SLOC
  var nodesSortedBySloc = model.nodes.values.toList();
  nodesSortedBySloc.sort((a, b) => a.sloc!.compareTo(b.sloc!));
  for (var node in nodesSortedBySloc) {
    print('${node.sloc}: ${node.id}');
  }

  // Конвертируем DOT в PNG используя Graphviz (предполагается, что Graphviz установлен)
  var result = await Process.run('dot', ['-Tpng', 'project_graph.dot', '-o', 'project_graph1.png']);

  if (result.exitCode == 0) {
    print('Graph generated and saved as project_graph1.png');
  } else {
    print('Error generating graph: ${result.stderr}');
  }
}

void main(List<String> arguments) async {
  var app = App(WeatherRepositoryDebug());

  app.run();

  /*
  final projectPath = Directory.current.path;
  final outputFilePath = path.join(projectPath, 'project_diagram.dot');
  final pngFilePath = path.join(projectPath, 'project_diagram.png');

  createDotFile(projectPath, outputFilePath);

  await convertDotToPng(outputFilePath, pngFilePath);
  */
  //createLakosGraph();

}
//разноцветные стрелочки
/*
  var model = buildModel(Directory('.'), ignoreGlob: 'test/**', showMetrics: true);

  // Генерация графа в формате DOT с разноцветными стрелками
  var dotOutput = generateColoredDot(model);

  // Сохраняем граф в DOT-файл
  var dotFile = File('project_graph.dot');
  await dotFile.writeAsString(dotOutput);

  // Проверяем наличие циклов зависимостей
  if (!model.metrics!.isAcyclic) {
    print('Dependency cycle detected.');
  }

  //Выводим метрики по SLOC
  var nodesSortedBySloc = model.nodes.values.toList();
  nodesSortedBySloc.sort((a, b) => a.sloc!.compareTo(b.sloc!));
  for (var node in nodesSortedBySloc) {
    print('${node.sloc}: ${node.id}');
  }

  // Конвертируем DOT в PNG, используя Graphviz (предполагается, что Graphviz установлен)
  var result = await Process.run('dot', ['-Tpng', 'project_graph.dot', '-o', 'project_graph.png']);
  if (result.exitCode != 0) {
    print('Error generating PNG: ${result.stderr}');
  } else {
    print('Generated PNG successfully.');
  }
}

String generateColoredDot(Model model) {
  var buffer = StringBuffer();
  buffer.writeln('digraph project_graph {');

  // Добавляем узлы
  for (var node in model.nodes.values) {
    buffer.writeln('  "${node.id}" [label="${node.id}\\n(SLOC: ${node.sloc})"];');
  }

  // Добавляем ребра с разными цветами
  var colors = ['red', 'green', 'blue', 'orange', 'purple', 'brown'];
  var colorIndex = 0;
  for (var edge in model.edges) {
    var color = colors[colorIndex % colors.length];
    buffer.writeln('  "${edge.from}" -> "${edge.to}" [color="$color"];');
    colorIndex++;
  }

  buffer.writeln('}');
  return buffer.toString();
}

 */
*/
