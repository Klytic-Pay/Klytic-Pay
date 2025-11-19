import 'package:flutter/material.dart';
import 'package:klytic_pay/models/invoice.dart'; // Ensure this model exists and is relevant
import 'package:klytic_pay/screens/payment_screen.dart'; // Ensure this screen exists
import '../constants/app_constants.dart';
import '../constants/app_icons.dart'; // For AppSvgIcon
import '../widgets/app_svg_icon.dart'; // For AppSvgIcon
import 'package:url_launcher/url_launcher.dart'; // For sending email
import '../services/price_service.dart'; // For fetching real-time BDAG price

class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _walletController = TextEditingController(); // Added back from previous version
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  double? _convertedAmount;
  double? _bdagToUsdRate; // Real-time BDAG price
  bool _isLoadingPrice = true;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _fetchBdagPrice();
    _amountController.addListener(_convertAmount);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _walletController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountController.removeListener(_convertAmount);
    super.dispose();
  }

  void _fetchBdagPrice() async {
    setState(() {
      _isLoadingPrice = true;
      _priceError = null;
    });
    try {
      final price = await PriceService().fetchBdagToUsdPrice();
      setState(() {
        _bdagToUsdRate = price;
        _isLoadingPrice = false;
        _convertAmount(); // Re-calculate converted amount once rate is fetched
      });
    } catch (e) {
      setState(() {
        _priceError = 'Failed to fetch price: ${e.toString()}';
        _isLoadingPrice = false;
      });
    }
  }

  void _convertAmount() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null && _bdagToUsdRate != null) {
      setState(() {
        _convertedAmount = amount / _bdagToUsdRate!;
      });
    } else {
      setState(() {
        _convertedAmount = null;
      });
    }
  }

  void _createInvoice() {
    if (_formKey.currentState!.validate() && _bdagToUsdRate != null) {
      final newInvoice = Invoice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientEmail: _emailController.text,
        amount: double.parse(_amountController.text),
        currency: AppConstants.bdagToken, // Use BDAG token
        description: _descriptionController.text,
        status: InvoiceStatus.pending,
        createdAt: DateTime.now(),
        transactionHash: 'mock_hash_${DateTime.now().millisecondsSinceEpoch}',
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(invoice: newInvoice),
        ),
      );
    } else if (_bdagToUsdRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot create invoice: BDAG price not available.'),
        ),
      );
    }
  }

  void _showPreview() {
    if (_formKey.currentState!.validate() && _bdagToUsdRate != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(AppStrings.invoicePreview),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('${AppStrings.clientEmail}: ${_emailController.text}'),
                Text('${AppStrings.clientWallet}: ${_walletController.text}'), // Added back
                Text('${AppStrings.amountUSD}: ${_amountController.text}'),
                Text('${AppStrings.amountBDAG}: ${_convertedAmount?.toStringAsFixed(4) ?? AppStrings.notAvailable}'),
                Text('${AppStrings.description}: ${_descriptionController.text}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(AppStrings.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(AppStrings.create),
              onPressed: () {
                Navigator.of(context).pop();
                _createInvoice();
              },
            ),
          ],
        ),
      );
    } else if (_bdagToUsdRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot preview invoice: BDAG price not available.'),
        ),
      );
    }
  }

  void _sendInvoiceEmail() async {
    if (_formKey.currentState!.validate() && _bdagToUsdRate != null) {
      final String recipient = _emailController.text;
      final String subject = 'Klytic Pay Invoice for ${AppConstants.appName}';
      final String body = '''
Dear ${recipient.split('@').first},

Here is your invoice details:

Amount: ${double.parse(_amountController.text).toStringAsFixed(2)} USD
Amount in BDAG: ${_convertedAmount?.toStringAsFixed(4) ?? AppStrings.notAvailable} ${AppConstants.bdagToken}
Description: ${_descriptionController.text}
Wallet Address: ${_walletController.text}

Thank you for your business!

Sincerely,
The ${AppConstants.appName} Team
''';

      final Uri emailLaunchUri = Uri(
        scheme: 'mailto',
        path: recipient,
        query: encodeQueryParameters(<String, String>{
          'subject': subject,
          'body': body,
        }),
      );

      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch email client.'),
          ),
        );
      }
    } else if (_bdagToUsdRate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot send invoice email: BDAG price not available.'),
        ),
      );
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createInvoice),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary), // Added back
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Client Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: AppStrings.clientEmail,
                  prefixIcon: AppSvgIcon(assetName: AppIcons.email, size: 20), // Using AppSvgIcon
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if ((value == null || value.isEmpty) && _walletController.text.isEmpty) { // Added wallet check
                    return AppStrings.enterClientEmailOrWallet;
                  }
                  if (value!.isNotEmpty && !value.contains('@')) {
                    return AppStrings.enterValidEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Client Wallet (added back)
              TextFormField(
                controller: _walletController,
                decoration: const InputDecoration(
                  labelText: AppStrings.clientBdagWallet,
                  prefixIcon: AppSvgIcon(assetName: AppIcons.wallet, size: 20),
                ),
                validator: (value) {
                  if ((value == null || value.isEmpty) && _emailController.text.isEmpty) {
                    return AppStrings.enterClientEmailOrWallet;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount in USD
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: AppStrings.amountUSD, // Using constant
                  prefixIcon: AppSvgIcon(assetName: AppIcons.money, size: 20), // Using AppSvgIcon
                ),
                keyboardType: TextInputType.number,
                // onChanged: (_) => _convertAmount(), // Will be handled by listener
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return AppStrings.enterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8), // Added spacing
              // Price Loading/Error Indicator
              if (_isLoadingPrice)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text(AppStrings.fetchingBdagPrice), // Using constant
                    ],
                  ),
                )
              else if (_priceError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    _priceError!,
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 8), // Added spacing

              // Converted Amount Display
              if (_convertedAmount != null && _bdagToUsdRate != null)
                Card(
                  color: AppColors.primary.withOpacity(0.1), // Fixed withValues
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          AppStrings.cryptoAmount,
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent),
                        ),
                        Text(
                          '${_convertedAmount!.toStringAsFixed(4)} ${AppConstants.bdagToken}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.description,
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.document, // Using AppSvgIcon
                    size: 20,
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: AppConstants.invoiceDescriptionMaxLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterDescription;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _showPreview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.grey,
                      ),
                      child: const Text(AppStrings.preview),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                      ),
                      child: const Text(
                        AppStrings.createInvoice,
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Add some spacing
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _sendInvoiceEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    AppStrings.sendInvoiceEmail,
                    style: TextStyle(color: AppColors.accent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
