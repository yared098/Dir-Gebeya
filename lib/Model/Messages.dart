class Message {
  final int id;
  final String moduleName;
  final int moduleId;
  final String name;
  final String image;
  final String text;
  final int seen;
  final int received;
  final String? estimation;
  final int userId;
  final String? status;
  final DateTime createdAt;
  final String? dateCreated;

  Message({
    required this.id,
    required this.moduleName,
    required this.moduleId,
    required this.name,
    required this.image,
    required this.text,
    required this.seen,
    required this.received,
    this.estimation,
    required this.userId,
    this.status,
    required this.createdAt,
    this.dateCreated,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      moduleName: json['module_name'],
      moduleId: json['module_id'],
      name: json['name'],
      image: json['image'],
      text: json['text'],
      seen: json['seen'],
      received: json['received'],
      estimation: json['estimation'],
      userId: json['user_id'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      dateCreated: json['date_created'],
    );
  }
}
