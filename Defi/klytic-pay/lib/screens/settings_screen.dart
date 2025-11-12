import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.settings),
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
            leading: const Icon(Icons.email),
            title: const Text(AppStrings.email),
            subtitle: const Text('user@example.com'), // TODO: Get from auth
            trailing: const Icon(Icons.edit),
            onTap: () {
              // TODO: Edit email
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text(AppStrings.wallet),
            subtitle: const Text('Not connected'), // TODO: Get wallet address
            trailing: const Icon(Icons.link),
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
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Buy/Sell Crypto'),
            subtitle: const Text('Convert SOL/USDC to USD'),
            trailing: const Icon(Icons.arrow_forward),
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
            leading: const Icon(Icons.dark_mode),
            title: const Text(AppStrings.theme),
            subtitle: const Text('Light'),
            trailing: Switch(
              value: false,
              onChanged: (value) {
                // TODO: Toggle theme
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
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
