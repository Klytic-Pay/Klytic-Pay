import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_constants.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentData;
  final String amount;
  final String currency;

  const PaymentScreen({
    super.key,
    required this.paymentData,
    required this.amount,
    required this.currency,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = false;
  bool _isCompleted = false;

  void _checkTransaction() {
    setState(() => _isProcessing = true);
    
    // TODO: Check transaction status via Solana
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isCompleted = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payments),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment Info
              Text(
                'Pay ${widget.amount} ${widget.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              
              // QR Code
              if (!_isCompleted)
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: QrImageView(
                      data: widget.paymentData,
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              
              // Success State
              if (_isCompleted)
                Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 100,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.transactionConfirmed,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              
              const SizedBox(height: 32),
              
              // Transaction Status
              if (_isProcessing)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.transactionPending,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                )
              else if (!_isCompleted)
                Column(
                  children: [
                    Text(
                      'Scan QR code with your Solana wallet',
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _checkTransaction,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Check Status'),
                    ),
                  ],
                ),
              
              // Payment Details
              if (!_isCompleted) ...[
                const SizedBox(height: 32),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Amount',
                          value: '${widget.amount} ${widget.currency}',
                        ),
                        const Divider(),
                        _DetailRow(
                          label: 'Network',
                          value: 'Solana (${AppConstants.solanaNetwork})',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              
              // Done Button
              if (_isCompleted) ...[
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
