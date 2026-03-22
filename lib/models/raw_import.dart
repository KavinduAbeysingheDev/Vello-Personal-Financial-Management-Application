class RawImport {
  final String? id;
  final String userId;
  final String sourceType; // 'sms' | 'gmail'
  final String externalId;
  final String? sender;
  final String? subject;
  final String? rawText;
  final DateTime? transactionDate;
  final Map<String, dynamic>? metadata;
  final DateTime? importedAt;

  RawImport({
    this.id,
    required this.userId,
    required this.sourceType,
    required this.externalId,
    this.sender,
    this.subject,
    this.rawText,
    this.transactionDate,
    this.metadata,
    this.importedAt,
  });

  factory RawImport.fromJson(Map<String, dynamic> json) {
    return RawImport(
      id: json['id'],
      userId: json['user_id'],
      sourceType: json['source_type'],
      externalId: json['external_id'],
      sender: json['sender'],
      subject: json['subject'],
      rawText: json['raw_text'],
      transactionDate: json['transaction_date'] != null ? DateTime.parse(json['transaction_date']) : null,
      metadata: json['metadata'],
      importedAt: json['imported_at'] != null ? DateTime.parse(json['imported_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'source_type': sourceType,
      'external_id': externalId,
      'sender': sender,
      'subject': subject,
      'raw_text': rawText,
      'transaction_date': transactionDate?.toIso8601String(),
      'metadata': metadata ?? {},
    };
  }
}
