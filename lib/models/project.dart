import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

// Bentuknya mengikuti ProjectSerializer di backend Django (Tutorial 07):
// title, problem, solution, tech_stack, dan project_url. Field lain seperti
// star_count tidak dipakai di aplikasi ini, jadi diabaikan saat membaca JSON.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.problem,
    required this.solution,
    required this.techStack,
    this.projectUrl = '',
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  // UUID dibuat oleh server, jadi tidak ikut dikirim saat POST
  @JsonKey(includeToJson: false)
  final String? id;
  final String title;
  final String problem;
  final String solution;
  final String techStack;

  // di database boleh kosong atau null
  @JsonKey(defaultValue: '')
  final String projectUrl;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
