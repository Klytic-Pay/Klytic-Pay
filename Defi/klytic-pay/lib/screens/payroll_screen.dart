import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/payroll.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final List<Payroll> _payrolls = [];
  
  void _addPayroll() {
    if (_payrolls.length >= AppConstants.maxPayrollPayees) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum ${AppConstants.maxPayrollPayees} payees allowed'),
        ),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PayrollFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.payroll),
      ),
      body: _payrolls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text(
                    'No payroll scheduled',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Max ${AppConstants.maxPayrollPayees} payees',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payrolls.length,
              itemBuilder: (context, index) {
                final payroll = _payrolls[index];
                return _PayrollCard(payroll: payroll);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPayroll,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final Payroll payroll;

  const _PayrollCard({required this.payroll});

  String _getFrequencyText() {
    switch (payroll.frequency) {
      case PaymentFrequency.oneTime:
        return AppStrings.oneTime;
      case PaymentFrequency.weekly:
        return AppStrings.weekly;
      case PaymentFrequency.biWeekly:
        return AppStrings.biWeekly;
      case PaymentFrequency.monthly:
        return AppStrings.monthly;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
          child: Icon(Icons.person, color: AppColors.secondary),
        ),
        title: Text(payroll.payeeName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${payroll.currency} ${payroll.amount.toStringAsFixed(2)}'),
            Text(
              _getFrequencyText(),
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            // TODO: Delete payroll
          },
        ),
      ),
    );
  }
}

class PayrollFormScreen extends StatefulWidget {
  const PayrollFormScreen({super.key});

  @override
  State<PayrollFormScreen> createState() => _PayrollFormScreenState();
}

class _PayrollFormScreenState extends State<PayrollFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _walletController = TextEditingController();
  final _amountController = TextEditingController();
  
  String _selectedCurrency = AppConstants.solToken;
  PaymentFrequency _selectedFrequency = PaymentFrequency.oneTime;

  void _schedulePayroll() {
    if (_formKey.currentState!.validate()) {
      // TODO: Create payroll via API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payroll scheduled successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.schedulePayroll),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.payeeName,
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter payee name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _walletController,
                decoration: const InputDecoration(
                  labelText: AppStrings.walletAddress,
                  prefixIcon: Icon(Icons.account_balance_wallet),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter wallet address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: AppStrings.amount,
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
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
              
              DropdownButtonFormField<String>(
                initialValue: _selectedCurrency,
                decoration: const InputDecoration(
                  labelText: 'Currency',
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
                  if (value != null) {
                    setState(() => _selectedCurrency = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<PaymentFrequency>(
                initialValue: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: AppStrings.paymentFrequency,
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: const [
                  DropdownMenuItem(
                    value: PaymentFrequency.oneTime,
                    child: Text(AppStrings.oneTime),
                  ),
                  DropdownMenuItem(
                    value: PaymentFrequency.weekly,
                    child: Text(AppStrings.weekly),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedFrequency = value);
                  }
                },
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _schedulePayroll,
                  child: const Text(AppStrings.schedulePayroll),
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
    _nameController.dispose();
    _walletController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
