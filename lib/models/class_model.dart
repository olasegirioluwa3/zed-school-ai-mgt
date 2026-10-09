class ClassModel {
  final String code;
  final String name;
  final String description;
  final String country;
  final int studentCount;

  ClassModel({
    required this.code,
    required this.name,
    required this.description,
    required this.country,
    required this.studentCount,
  });
}

class StudentModel {
  final String name;
  final String admissionNo;
  final String initials;
  final String status;

  StudentModel({
    required this.name,
    required this.admissionNo,
    required this.initials,
    required this.status,
  });
}