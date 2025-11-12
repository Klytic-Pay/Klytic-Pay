import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class InvoiceCreateScreen extends StatefulWidget {
  const InvoiceCreateScreen({super.key});

  @override
  State<InvoiceCreateScreen> createState() => _InvoiceCreateScreenState();
}

class _InvoiceCreateScreenState extends State<InvoiceCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCurrency = AppConstants.solToken;
  double? _convertedAmount;
  
  // Mock conversion rate - replace with API
  final double _solRate = 150.0; // 1 SOL = $150
  final double _usdcRate = 1.0; // 1 USDC = $1

  void _convertAmount() {
    final amount = double.tryParse(_amountController.text);
    if (amount != null) {
      setState(() {
        if (_selectedCurrency == AppConstants.solToken) {
          _convertedAmount = amount / _solRate;
        } else {
          _convertedAmount = amount / _usdcRate;
        }
      });
    }
  }

  void _createInvoice() {
    if (_formKey.currentState!.validate()) {
      // TODO: Create invoice via API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice created successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.createInvoice),
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
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter client email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Amount in USD
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (USD)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _convertAmount(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Currency Selection
              DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Payment Currency',
                  prefixIcon: Icon(Icons.currency_bitcoin),
                ),
                items: [
                  DropdownMenuItem(
                    value: AppConstants.solToken,
                    child: Text(AppConstants.solToken),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.usdcToken,
                    child: Text(AppConstants.usdcToken),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value!;
                    _convertAmount();
                  });
                },
              ),
              const SizedBox(height: 16),
              
              // Converted Amount Display
              if (_convertedAmount != null)
                Card(
                  color: AppColors.primary.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Crypto Amount:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${_convertedAmount!.toStringAsFixed(4)} $_selectedCurrency',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
                  prefixIcon: Icon(Icons.description),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: AppConstants.invoiceDescriptionMaxLength,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createInvoice,
                  child: const Text(AppStrings.createInvoice),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
