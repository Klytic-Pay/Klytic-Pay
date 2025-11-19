import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../widgets/app_svg_icon.dart';
import 'invoice_create_screen.dart';
import 'payroll_screen.dart';

// Placeholder for a more complex activity model
class Activity {
  final String title;
  final String subtitle;
  final String iconAsset;
  final Color iconColor;

  const Activity({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.iconColor,
  });
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<Activity> _recentActivities = [
    Activity(
      title: 'Invoice #123 paid',
      subtitle: 'Client A - 100 BDAG',
      iconAsset: AppIcons.check,
      iconColor: AppColors.success,
    ),
    Activity(
      title: 'Payroll for John Doe scheduled',
      subtitle: '50 BDAG - Weekly',
      iconAsset: AppIcons.schedule,
      iconColor: AppColors.info,
    ),
    Activity(
      title: 'New invoice created',
      subtitle: 'Client B - 250 BDAG',
      iconAsset: AppIcons.addCircle,
      iconColor: AppColors.primary,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboard),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    title: AppStrings.totalInvoices,
                    value: '0',
                    color: AppColors.primary,
                    iconAsset: AppIcons.receipt,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SummaryCard(
                    title: AppStrings.scheduledPayroll,
                    value: '0',
                    color: AppColors.primary,
                    iconAsset: AppIcons.payment,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              AppStrings.quickActions,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: AppStrings.createInvoice,
                    iconAsset: AppIcons.addCircle,
                    color: AppColors.accent,
                    textColor: AppColors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const InvoiceCreateScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    label: AppStrings.schedulePayroll,
                    iconAsset: AppIcons.schedule,
                    color: AppColors.accent,
                    textColor: AppColors.white,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PayrollScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Activity
            const Text(
              AppStrings.recentActivity,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent),
            ),
            const SizedBox(height: 16),
            _recentActivities.isEmpty
                ? Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          AppStrings.noRecentActivity,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true, // Important for nested list views
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling
                    itemCount: _recentActivities.length,
                    itemBuilder: (context, index) {
                      final activity = _recentActivities[index];
                      return _RecentActivityCard(activity: activity);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final String iconAsset;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.iconAsset,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.accent,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSvgIcon(assetName: iconAsset, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.white),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: AppColors.darkTextSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final String iconAsset;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _ActionButton({
    required this.label,
    required this.iconAsset,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.all(16)
      ),
      child: Column(
        children: [
          AppSvgIcon(
            assetName: iconAsset,
            size: 32,
            color: textColor,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ],
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final Activity activity;

  const _RecentActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: AppSvgIcon(
          assetName: activity.iconAsset,
          size: 24,
          color: activity.iconColor,
        ),
        title: Text(activity.title),
        subtitle: Text(activity.subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
        onTap: () {
          // TODO: Navigate to activity details
        },
      ),
    );
  }
}

