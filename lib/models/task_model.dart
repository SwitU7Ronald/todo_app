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
}
