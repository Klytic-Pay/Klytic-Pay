class Invoice {
  final String id;
  final String clientEmail;
  final double amount;
  final String currency;
  final String description;
  final InvoiceStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? transactionHash;

  Invoice({
    required this.id,
    required this.clientEmail,
    required this.amount,
    required this.currency,
    required this.description,
    required this.status,
    required this.createdAt,
    this.paidAt,
    this.transactionHash,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      clientEmail: json['clientEmail'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      description: json['description'],
      status: InvoiceStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InvoiceStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      transactionHash: json['transactionHash'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientEmail': clientEmail,
      'amount': amount,
      'currency': currency,
      'description': description,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'paidAt': paidAt?.toIso8601String(),
      'transactionHash': transactionHash,
    };
  }
}

enum InvoiceStatus {
  pending,
  paid,
  overdue,
  cancelled,
}
