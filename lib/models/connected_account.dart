import 'package:intl/intl.dart';

class ConnectedAccount {
  final String id;
  final String userId;
  final String provider;
  final String? providerEmail;
  final String? providerUserId;
  final String status;
  final String? accessScope;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConnectedAccount({
    required this.id,
    required this.userId,
    required this.provider,
    this.providerEmail,
    this.providerUserId,
    this.status = 'connected',
    this.accessScope,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConnectedAccount.fromJson(Map<String, dynamic> json) {
    return ConnectedAccount(
      id: json['id'],
      userId: json['user_id'],
      provider: json['provider'],
      providerEmail: json['provider_email'],
      providerUserId: json['provider_user_id'],
      status: json['status'] ?? 'connected',
      accessScope: json['access_scope'],
      lastSyncedAt: json['last_synced_at'] != null ? DateTime.parse(json['last_synced_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'provider': provider,
      'provider_email': providerEmail,
      'provider_user_id': providerUserId,
      'status': status,
      'access_scope': accessScope,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
    };
  }

  ConnectedAccount copyWith({
    String? status,
    DateTime? lastSyncedAt,
    String? accessScope,
  }) {
    return ConnectedAccount(
      id: id,
      userId: userId,
      provider: provider,
      providerEmail: providerEmail,
      providerUserId: providerUserId,
      status: status ?? this.status,
      accessScope: accessScope ?? this.accessScope,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
