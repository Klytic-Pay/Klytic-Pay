import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../models/payroll.dart';
import '../widgets/app_svg_icon.dart';

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
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
      ),
      body: _payrolls.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppSvgIcon(
                    assetName: AppIcons.team,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
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
        child: const AppSvgIcon(
          assetName: AppIcons.plus,
          size: 24,
        ),
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
          child: AppSvgIcon(
            assetName: AppIcons.person,
            size: 24,
            color: AppColors.secondary,
          ),
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
          icon: const AppSvgIcon(
            assetName: AppIcons.delete,
            size: 20,
            color: Colors.red,
          ),
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
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
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.person,
                    size: 20,
                  ),
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
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.wallet,
                    size: 20,
                  ),
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
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.money,
                    size: 20,
                  ),
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
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.crypto,
                    size: 20,
                  ),
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
                  prefixIcon: AppSvgIcon(
                    assetName: AppIcons.schedule,
                    size: 20,
                  ),
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
