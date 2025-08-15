class AppointmentModel {
  final String id;
  final String psychologistId;
  final String psychologistName;
  final String userId;
  final String userName;
  final DateTime scheduledAt;
  final String note;
  final DateTime createdAt;
  final String status; // e.g. pending, confirmed, cancelled

  AppointmentModel({
    required this.id,
    required this.psychologistId,
    required this.psychologistName,
    required this.userId,
    required this.userName,
    required this.scheduledAt,
    required this.note,
    required this.createdAt,
    this.status = 'pending',
  });

  AppointmentModel copyWith({String? id}) {
    return AppointmentModel(
      id: id ?? this.id,
      psychologistId: psychologistId,
      psychologistName: psychologistName,
      userId: userId,
      userName: userName,
      scheduledAt: scheduledAt,
      note: note,
      createdAt: createdAt,
      status: status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'psychologistId': psychologistId,
      'psychologistName': psychologistName,
      'userId': userId,
      'userName': userName,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'note': note,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'status': status,
    };
  }

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> m) {
    return AppointmentModel(
      id: id,
      psychologistId: (m['psychologistId'] ?? '') as String,
      psychologistName: (m['psychologistName'] ?? '') as String,
      userId: (m['userId'] ?? '') as String,
      userName: (m['userName'] ?? '') as String,
      scheduledAt: DateTime.parse(m['scheduledAt'] as String).toLocal(),
      note: (m['note'] ?? '') as String,
      createdAt: DateTime.parse(m['createdAt'] as String).toLocal(),
      status: (m['status'] ?? 'pending') as String,
    );
  }
}
