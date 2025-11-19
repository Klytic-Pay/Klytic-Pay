import 'package:flutter/material.dart';
import 'package:klytic_pay/screens/invoice_create_screen.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../models/invoice.dart';
import '../widgets/app_svg_icon.dart';
import 'package:url_launcher/url_launcher.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  InvoiceStatus? _selectedFilter;

  // Mock data - replace with API call
  final List<Invoice> _invoices = [
    Invoice(
      id: '1',
      clientEmail: 'client1@example.com',
      amount: 100.0,
      currency: AppConstants.bdagToken,
      description: 'Logo Design',
      status: InvoiceStatus.paid,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      paidAt: DateTime.now(),
      transactionHash: '0x1234567890abcdef',
    ),
    Invoice(
      id: '2',
      clientEmail: 'client2@example.com',
      amount: 250.0,
      currency: AppConstants.bdagToken,
      description: 'Website Development',
      status: InvoiceStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Invoice(
      id: '3',
      clientEmail: 'client3@example.com',
      amount: 50.0,
      currency: AppConstants.bdagToken,
      description: 'Consulting',
      status: InvoiceStatus.overdue,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
  ];

  List<Invoice> get _filteredInvoices {
    if (_selectedFilter == null) return _invoices;
    return _invoices.where((inv) => inv.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.invoices),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
        actions: [
          IconButton(
            icon: const AppSvgIcon(
              assetName: AppIcons.plus,
              size: 20,
              color: AppColors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const InvoiceCreateScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text(AppStrings.all),
                  selected: _selectedFilter == null,
                  onSelected: (_) => setState(() => _selectedFilter = null),
                  selectedColor: AppColors.primary,
                ),
                FilterChip(
                  label: const Text(AppStrings.statusPending),
                  selected: _selectedFilter == InvoiceStatus.pending,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = InvoiceStatus.pending),
                  selectedColor: AppColors.primary,
                ),
                FilterChip(
                  label: const Text(AppStrings.statusPaid),
                  selected: _selectedFilter == InvoiceStatus.paid,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = InvoiceStatus.paid),
                  selectedColor: AppColors.primary,
                ),
                FilterChip(
                  label: const Text(AppStrings.statusOverdue),
                  selected: _selectedFilter == InvoiceStatus.overdue,
                  onSelected: (_) =>
                      setState(() => _selectedFilter = InvoiceStatus.overdue),
                  selectedColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // Invoice list
          Expanded(
            child: _filteredInvoices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppSvgIcon(
                          assetName: AppIcons.receipt,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.noInvoicesFound,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _filteredInvoices[index];
                      return _InvoiceCard(invoice: invoice);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final Invoice invoice;

  const _InvoiceCard({required this.invoice});

  Color _getStatusColor() {
    switch (invoice.status) {
      case InvoiceStatus.paid:
        return AppColors.success;
      case InvoiceStatus.pending:
        return AppColors.warning;
      case InvoiceStatus.overdue:
        return AppColors.error;
      case InvoiceStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (invoice.status) {
      case InvoiceStatus.paid:
        return AppStrings.statusPaid;
      case InvoiceStatus.pending:
        return AppStrings.statusPending;
      case InvoiceStatus.overdue:
        return AppStrings.statusOverdue;
      case InvoiceStatus.cancelled:
        return AppStrings.statusCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.2),
          child: AppSvgIcon(
            assetName: AppIcons.receipt,
            size: 24,
            color: _getStatusColor(),
          ),
        ),
        title: Text(invoice.clientEmail),
        subtitle:
            Text('${invoice.currency} ${invoice.amount.toStringAsFixed(2)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getStatusText(),
                style: TextStyle(
                  color: _getStatusColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceDetailsScreen(invoice: invoice),
            ),
          );
        },
      ),
    );
  }
}

class InvoiceDetailsScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  Future<void> _sharePaymentLink(BuildContext context, Invoice invoice) async {
    final String paymentLink =
        '${AppConstants.apiBaseUrl}/invoice/${invoice.id}/pay'; // Mock payment link
    final Uri url = Uri.parse(paymentLink);

    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.couldNotLaunchUrl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${AppStrings.invoiceNumber}${invoice.id}'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${AppStrings.amount}: ${invoice.amount} ${invoice.currency}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${AppStrings.client}: ${invoice.clientEmail}'),
                    const SizedBox(height: 8),
                    Text('${AppStrings.date}: ${invoice.createdAt.toLocal().toString().split(' ')[0]}'),
                    const SizedBox(height: 8),
                    Text('${AppStrings.invoiceStatus}: ${invoice.status.name}'),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(AppStrings.transactionDetails, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('${AppStrings.hash}: ${invoice.transactionHash ?? 'N/A'}'),
                    const SizedBox(height: 8),
                    Text('${AppStrings.confirmations}: ${invoice.status == InvoiceStatus.paid ? AppStrings.confirmed : AppStrings.statusPending}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const AppSvgIcon(assetName: AppIcons.link),
              title: const Text(AppStrings.sharePaymentLink),
              onTap: () => _sharePaymentLink(context, invoice),
            ),
          ],
        ),
      ),
    );
  }
}
