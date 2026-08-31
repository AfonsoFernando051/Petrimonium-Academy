import 'package:petrimonium/features/onboarding/data/models/option_model.dart';

class QuestionModel {
  final String id;
  final String text;
  final List<OptionModel> options;

  const QuestionModel({
    required this.id,
    required this.text,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>)
          .map((o) => OptionModel.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

