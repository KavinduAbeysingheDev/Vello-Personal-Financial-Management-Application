class SyncLog {
  final String? id;
  final String userId;
  final String sourceType;
  final String? status;
  final String? message;
  final int itemsScanned;
  final int itemsImported;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  SyncLog({
    this.id,
    required this.userId,
    required this.sourceType,
    this.status,
    this.message,
    this.itemsScanned = 0,
    this.itemsImported = 0,
    this.startedAt,
    this.finishedAt,
  });

  factory SyncLog.fromJson(Map<String, dynamic> json) {
    return SyncLog(
      id: json['id'],
      userId: json['user_id'],
      sourceType: json['source_type'],
      status: json['status'],
      message: json['message'],
      itemsScanned: json['items_scanned'] ?? 0,
      itemsImported: json['items_imported'] ?? 0,
      startedAt: json['started_at'] != null ? DateTime.parse(json['started_at']) : null,
      finishedAt: json['finished_at'] != null ? DateTime.parse(json['finished_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'source_type': sourceType,
      'status': status,
      'message': message,
      'items_scanned': itemsScanned,
      'items_imported': itemsImported,
      'started_at': startedAt?.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
    };
  }
}
