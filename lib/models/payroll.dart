class Payroll {
  final String id;
  final String payeeName;
  final String walletAddress;
  final double amount;
  final String currency;
  final PaymentFrequency frequency;
  final DateTime createdAt;
  final DateTime? nextPaymentDate;
  final PayrollStatus status;

  Payroll({
    required this.id,
    required this.payeeName,
    required this.walletAddress,
    required this.amount,
    required this.currency,
    required this.frequency,
    required this.createdAt,
    this.nextPaymentDate,
    required this.status,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'],
      payeeName: json['payeeName'],
      walletAddress: json['walletAddress'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      frequency: PaymentFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => PaymentFrequency.oneTime,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      nextPaymentDate: json['nextPaymentDate'] != null
          ? DateTime.parse(json['nextPaymentDate'])
          : null,
      status: PayrollStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PayrollStatus.scheduled,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payeeName': payeeName,
      'walletAddress': walletAddress,
      'amount': amount,
      'currency': currency,
      'frequency': frequency.name,
      'createdAt': createdAt.toIso8601String(),
      'nextPaymentDate': nextPaymentDate?.toIso8601String(),
      'status': status.name,
    };
  }
}

enum PaymentFrequency {
  oneTime,
  weekly,
  biWeekly,
  monthly,
}

enum PayrollStatus {
  scheduled,
  processing,
  completed,
  cancelled,
}
