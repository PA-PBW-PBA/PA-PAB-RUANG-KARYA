class KasModel {
  final String id;
  final String divisionId;
  final String divisionName;
  final String type;
  final double amount;
  final String? description;
  final DateTime transactionDate;
  final String createdBy;
  final DateTime createdAt;

  KasModel({
    required this.id,
    required this.divisionId,
    required this.divisionName,
    required this.type,
    required this.amount,
    this.description,
    required this.transactionDate,
    required this.createdBy,
    required this.createdAt,
  });

  bool get isPemasukan => type == 'pemasukan';
  bool get isPengeluaran => type == 'pengeluaran';

  factory KasModel.fromJson(Map<String, dynamic> json) {
    return KasModel(
      id: json['id'] ?? '',
      divisionId: json['division_id'] ?? '',
      divisionName: json['divisions']?['name'] ?? '',
      type: json['type'] ?? 'pemasukan',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      transactionDate: DateTime.parse(json['transaction_date']),
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'division_id': divisionId,
      'type': type,
      'amount': amount,
      'description': description,
      'transaction_date': transactionDate.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
