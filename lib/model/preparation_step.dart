import 'dart:convert';
import 'dart:developer';

class PreparationStep {
  final String title;
  final String instructions;

  const PreparationStep({this.title, this.instructions});

  toJson() {
    return {"title": title, "instructions": instructions};
  }
}

class PreparationStepsConverter extends Converter<List, List<PreparationStep>> {
  @override
  List<PreparationStep> convert(List<dynamic> input) {
    if (input == null) {
      log("No steps for recipe");
      return [];
    }

    return input
        .map((item) => PreparationStep(
            title: item['title'], instructions: item['instructions']))
        .toList();
  }
}
