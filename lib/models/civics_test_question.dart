import 'package:json_annotation/json_annotation.dart';

part 'civics_test_question.g.dart';

enum QuestionCategory {
  @JsonValue(0)
  americanGovernment,
  @JsonValue(1)
  americanHistory,
  @JsonValue(2)
  integratedCivics,
}

enum QuestionType {
  @JsonValue(0)
  text,
  @JsonValue(1)
  date,
  @JsonValue(2)
  number,
}

const Map<QuestionCategory, Map<String, String>> kQuestionCategories = {
  QuestionCategory.americanGovernment: {
    'A': 'Principles of American Democracy',
    'B': 'System of Government',
    'C': 'Rights and Responsibilities',
  },
  QuestionCategory.americanHistory: {
    'A': 'Colonial Period and Independence',
    'B': '1800s',
    'C': 'Recent American History and Other Important Historical Information',
  },
  QuestionCategory.integratedCivics: {
    'A': 'Geography',
    'B': 'Symbols',
    'C': 'Holidays',
  }
};

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class CivicsTestQuestion {
  final int id;
  final String text;
  final QuestionType type;
  final QuestionCategory category;
  final String subCategory;
  final bool is6520;
  final int minAnswers;
  List<String> answers;
  final String? textTts;

  CivicsTestQuestion(this.id, this.text, this.type, this.category, this.subCategory, this.is6520, this.minAnswers,
      this.answers, this.textTts);

  factory CivicsTestQuestion.fromJson(Map<String, dynamic> json) => _$CivicsTestQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$CivicsTestQuestionToJson(this);
}
