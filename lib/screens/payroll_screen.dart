import 'package:flutter/material.dart';
import 'package:klytic_pay/models/payroll.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../widgets/app_svg_icon.dart';

class PayrollScreen extends StatefulWidget {
  const PayrollScreen({super.key});

  @override
  State<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends State<PayrollScreen> {
  final List<Payroll> _payrolls = [];

  void _addPayroll(Payroll payroll) {
    setState(() {
      _payrolls.add(payroll);
    });
  }

  void _deletePayroll(String id) {
    setState(() {
      _payrolls.removeWhere((p) => p.id == id);
    });
  }

  void _navigateToPayrollForm() async {
    if (_payrolls.length >= AppConstants.maxPayrollPayees) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Maximum ${AppConstants.maxPayrollPayees} payees allowed'),
        ),
      );
      return;
    }

    final newPayroll = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PayrollFormScreen(),
      ),
    );

    if (newPayroll != null) {
      _addPayroll(newPayroll);
    }
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
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _payrolls.length,
              itemBuilder: (context, index) {
                final payroll = _payrolls[index];
                return _PayrollCard(
                  payroll: payroll,
                  onDelete: () => _deletePayroll(payroll.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToPayrollForm,
        backgroundColor: AppColors.primary,
        child: const AppSvgIcon(
          assetName: AppIcons.plus,
          size: 24,
          color: AppColors.accent,
        ),
      ),
    );
  }
}

class _PayrollCard extends StatelessWidget {
  final Payroll payroll;
  final VoidCallback onDelete;

  const _PayrollCard({required this.payroll, required this.onDelete});

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
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: AppSvgIcon(
            assetName: AppIcons.person,
            size: 24,
            color: AppColors.primary,
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
          onPressed: onDelete,
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

  String _selectedCurrency = AppConstants.bdagToken;
  PaymentFrequency _selectedFrequency = PaymentFrequency.oneTime;
  final List<bool> _isSelected = [true, false]; // For USD/BDAG toggle

  void _schedulePayroll() {
    if (_formKey.currentState!.validate()) {
      final newPayroll = Payroll(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        payeeName: _nameController.text,
        walletAddress: _walletController.text,
        amount: double.parse(_amountController.text),
        currency: _selectedCurrency,
        frequency: _selectedFrequency,
        createdAt: DateTime.now(),
        status: PayrollStatus.scheduled,
      );
      Navigator.pop(context, newPayroll);
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
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
                  ),
                  const SizedBox(width: 10),
                  ToggleButtons(
                    isSelected: _isSelected,
                    onPressed: (int index) {
                      setState(() {
                        for (int i = 0; i < _isSelected.length; i++) {
                          _isSelected[i] = i == index;
                        }
                        _selectedCurrency = index == 0
                            ? AppConstants.bdagToken
                            : AppConstants.usdCurrency;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    selectedColor: AppColors.white,
                    color: AppColors.accent,
                    fillColor: AppColors.accent,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(AppConstants.bdagToken),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(AppConstants.usdCurrency),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<PaymentFrequency>(
                value: _selectedFrequency,
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
                  DropdownMenuItem(
                    value: PaymentFrequency.biWeekly,
                    child: Text(AppStrings.biWeekly),
                  ),
                  DropdownMenuItem(
                    value: PaymentFrequency.monthly,
                    child: Text(AppStrings.monthly),
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text(
                      AppStrings.schedulePayroll,
                      style: TextStyle(color: AppColors.white),
                    )),
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
