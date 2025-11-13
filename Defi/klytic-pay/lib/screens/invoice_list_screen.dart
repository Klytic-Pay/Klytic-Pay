import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/invoice.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  InvoiceStatus? _selectedFilter;
  
  // Mock data - replace with API call
  final List<Invoice> _invoices = [];

  List<Invoice> get _filteredInvoices {
    if (_selectedFilter == null) return _invoices;
    return _invoices.where((inv) => inv.status == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.invoices),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create invoice
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
                  label: const Text('All'),
                  selected: _selectedFilter == null,
                  onSelected: (_) => setState(() => _selectedFilter = null),
                ),
                FilterChip(
                  label: const Text(AppStrings.statusPending),
                  selected: _selectedFilter == InvoiceStatus.pending,
                  onSelected: (_) => setState(() => _selectedFilter = InvoiceStatus.pending),
                ),
                FilterChip(
                  label: const Text(AppStrings.statusPaid),
                  selected: _selectedFilter == InvoiceStatus.paid,
                  onSelected: (_) => setState(() => _selectedFilter = InvoiceStatus.paid),
                ),
                FilterChip(
                  label: const Text(AppStrings.statusOverdue),
                  selected: _selectedFilter == InvoiceStatus.overdue,
                  onSelected: (_) => setState(() => _selectedFilter = InvoiceStatus.overdue),
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
                        Icon(Icons.receipt_long, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text(
                          'No invoices found',
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
          backgroundColor: _getStatusColor().withValues(alpha: 0.2),
          child: Icon(Icons.receipt, color: _getStatusColor()),
        ),
        title: Text(invoice.clientEmail),
        subtitle: Text('${invoice.currency} ${invoice.amount.toStringAsFixed(2)}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withValues(alpha: 0.2),
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
          // TODO: Navigate to invoice details
        },
      ),
    );
  }
}
