import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../widgets/app_svg_icon.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppGradients.primary),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppStrings.profile,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: AppSvgIcon(assetName: AppIcons.email),
            title: const Text(AppStrings.email),
            subtitle: const Text('user@example.com'), // TODO: Get from auth
            trailing: AppSvgIcon(assetName: AppIcons.edit),
            onTap: () {
              // TODO: Edit email
            },
          ),
          ListTile(
            leading: AppSvgIcon(assetName: AppIcons.wallet),
            title: const Text(AppStrings.wallet),
            subtitle: const Text('Not connected'), // TODO: Get wallet address
            trailing: AppSvgIcon(assetName: AppIcons.link),
            onTap: () {
              // TODO: Connect wallet
            },
          ),
          const Divider(),
          
          // On/Off Ramp Section
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppStrings.onOffRamp,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: AppSvgIcon(assetName: AppIcons.swap),
            title: const Text('Buy/Sell Crypto'),
            subtitle: const Text('Convert SOL/USDC to USD'),
            trailing: AppSvgIcon(assetName: AppIcons.arrowRight),
            onTap: () {
              // TODO: Open on/off-ramp provider
            },
          ),
          const Divider(),
          
          // App Settings
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'App Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: AppSvgIcon(assetName: AppIcons.darkMode),
            title: const Text(AppStrings.theme),
            subtitle: Text(isDarkMode ? 'Dark' : 'Light'),
            trailing: Switch(
              value: isDarkMode,
              onChanged: onThemeChanged,
            ),
          ),
          ListTile(
            leading: AppSvgIcon(assetName: AppIcons.info),
            title: const Text('About'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
            onTap: () {
              // TODO: Show about dialog
            },
          ),
          const Divider(),
          
          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              child: const Text(AppStrings.logout),
            ),
          ),
        ],
      ),
    );
  }
}
