import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../constants/app_icons.dart';
import '../widgets/app_svg_icon.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _walletAddress;

  @override
  void initState() {
    super.initState();
    _loadWalletAddress();
  }

  void _loadWalletAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletAddress = prefs.getString(AppConstants.userWalletKey);
    });
  }

  void _connectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletAddress = 'BDAG:1a2b3c4d5e6f7g8h9i0j'; // Mock address
      prefs.setString(AppConstants.userWalletKey, _walletAddress!);
    });
  }

  void _disconnectWallet() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _walletAddress = null;
      prefs.remove(AppConstants.userWalletKey);
    });
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppStrings.couldNotLaunchUrl}: $urlString'),
        ),
      );
    }
  }

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
            leading: const AppSvgIcon(assetName: AppIcons.email),
            title: const Text(AppStrings.email),
            subtitle: const Text(AppStrings.loggedInUserEmail), // Using constant
            trailing: const AppSvgIcon(assetName: AppIcons.edit),
            onTap: () {
              // TODO: Edit email
            },
          ),
          ListTile(
            leading: const AppSvgIcon(assetName: AppIcons.wallet),
            title: const Text(AppStrings.wallet),
            subtitle: Text(_walletAddress ?? AppStrings.notConnected), // Using constant
            trailing: _walletAddress == null
                ? const AppSvgIcon(assetName: AppIcons.link)
                : const AppSvgIcon(assetName: AppIcons.delete, color: AppColors.error), // Using AppColors
            onTap: _walletAddress == null ? _connectWallet : _disconnectWallet,
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
            leading: const AppSvgIcon(assetName: AppIcons.swap),
            title: const Text('Ramp.network'), // Using specific name
            subtitle: const Text(AppStrings.buySellCrypto),
            trailing: const AppSvgIcon(assetName: AppIcons.arrowRight),
            onTap: () => _launchUrl(AppConstants.rampNetworkUrl),
          ),
          ListTile(
            leading: const AppSvgIcon(assetName: AppIcons.swap),
            title: const Text('Transak'), // Using specific name
            subtitle: const Text(AppStrings.buySellCrypto),
            trailing: const AppSvgIcon(assetName: AppIcons.arrowRight),
            onTap: () => _launchUrl(AppConstants.transakUrl),
          ),
          ListTile(
            leading: const AppSvgIcon(assetName: AppIcons.swap),
            title: const Text('OnMeta'), // Using specific name
            subtitle: const Text(AppStrings.buySellCrypto),
            trailing: const AppSvgIcon(assetName: AppIcons.arrowRight),
            onTap: () => _launchUrl(AppConstants.onmetaUrl),
          ),
          const Divider(),

          // Theme Settings
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppStrings.theme,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.lightMode),
                    value: ThemeMode.light,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setTheme(value!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.darkMode),
                    value: ThemeMode.dark,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setTheme(value!),
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text(AppStrings.systemTheme),
                    value: ThemeMode.system,
                    groupValue: themeProvider.themeMode,
                    onChanged: (value) => themeProvider.setTheme(value!),
                  ),
                ],
              );
            },
          ),
          const Divider(),

          // App Settings
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              AppStrings.appSettings, // Using constant
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const AppSvgIcon(assetName: AppIcons.info),
            title: const Text(AppStrings.about), // Using constant
            subtitle: Text('Version ${AppConstants.appVersion}'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: AppConstants.appName,
                applicationVersion: AppConstants.appVersion,
              );
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
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.logout, style: TextStyle(color: Theme.of(context).colorScheme.onError)),
            ),
          ),
        ],
      ),
    );
  }
}
