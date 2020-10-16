import 'dart:convert';

class PreparationStep {
  final String title;
  final String instructions;

  const PreparationStep({this.title, this.instructions});
}

class PreparationStepsConverter extends Converter<List, List<PreparationStep>> {
  @override
  List<PreparationStep> convert(List<dynamic> input) {
    return input
        .map((item) => PreparationStep(
            title: item['title'], instructions: item['instructions']))
        .toList();
  }
}
