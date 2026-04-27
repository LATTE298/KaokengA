import 'scenario_config.dart';

class LoadedScenarioConfig {
  const LoadedScenarioConfig({
    required this.config,
    required this.placeholderImagePaths,
  });

  final ScenarioConfig config;
  final Set<String> placeholderImagePaths;

  bool usesPlaceholder(String imagePath) {
    return placeholderImagePaths.contains(imagePath);
  }
}
