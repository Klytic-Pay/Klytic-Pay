import 'dart:async';
import 'package:flutter/material.dart';
import 'package:klytic_pay/models/invoice.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../widgets/app_svg_icon.dart';

class PaymentScreen extends StatefulWidget {
  final Invoice invoice;

  const PaymentScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isProcessing = true;
  bool _isCompleted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTransactionCheck();
  }

  void _startTransactionCheck() {
    // In a real app, this would be a WebSocket or periodic API call.
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      // Mocking a fast confirmation (<1s)
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isCompleted = true;
        });
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payments),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Payment Info
              Text(
                '${AppStrings.pay} ${widget.invoice.amount} ${widget.invoice.currency}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
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
                      data:
                          'blockdag:${widget.invoice.transactionHash}?amount=${widget.invoice.amount}',
                      version: QrVersions.auto,
                      size: 250,
                      backgroundColor: AppColors.white,
                    ),
                  ),
                ),

              // Success State
              if (_isCompleted)
                Column(
                  children: [
                    AppSvgIcon(
                      assetName: AppIcons.check,
                      size: 100,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      AppStrings.transactionConfirmed,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Transaction Status
              if (_isProcessing)
                Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
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
                      AppStrings.scanQrCodeWithWallet,
                      style: TextStyle(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
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
                          label: AppStrings.amount,
                          value:
                              '${widget.invoice.amount} ${widget.invoice.currency}',
                        ),
                        const Divider(),
                        _DetailRow(
                          label: AppStrings.network,
                          value: 'BlockDAG (${AppConstants.blockdagNetwork})',
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text(
                      AppStrings.done,
                      style: TextStyle(color: AppColors.white),
                    ),
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
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.accent),
        ),
      ],
    );
  }
}
