class TaskModel {
  String id;
  String title;
  DateTime createdAt;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      title: map['title'],
      createdAt: DateTime.parse(map['createdAt']),
      isCompleted: map['isCompleted'],
    );
  }
}
