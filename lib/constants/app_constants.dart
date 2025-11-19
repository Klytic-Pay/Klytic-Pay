import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Klytic Pay';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl =
      'https://api.klyticpay.com'; // TODO: Replace with actual URL
  static const Duration apiTimeout = Duration(seconds: 30);

  // External APIs
  static const String coingeckoApiBaseUrl = 'https://api.coingecko.com/api/v3';
  static const String coingeckoBlockdagId = 'blockdag'; // Assuming 'blockdag' is the CoinGecko ID

  // On/Off Ramp Providers
  static const String rampNetworkUrl = 'https://ramp.network/buy';
  static const String transakUrl = 'https://global.transak.com/';
  static const String onmetaUrl = 'https://onmeta.in/';

  // BlockDAG Configuration
  static const String blockdagRpcUrl =
      'https://rpc.blockdag.network'; // TODO: Change to mainnet for production
  static const String blockdagNetwork = 'mainnet'; // devnet, testnet, mainnet

  // Currencies
  static const String bdagToken = 'BDAG';
  static const String usdCurrency = 'USD';

  // Limits
  static const int maxPayrollPayees = 5;
  static const int invoiceDescriptionMaxLength = 500;

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  // Storage Keys
  static const String userWalletKey = 'user_wallet';
  static const String userEmailKey = 'user_email';
  static const String themeKey = 'theme_mode';
}

/// App-wide color scheme
class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF00FF00); // Bright Green
  static const Color accent = Color(0xFF000000); // Black
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF808080);

  // Primary Colors (Brand)
  static const Color primaryDark = Color(0xFF00E600);
  static const Color primaryLight = Color(0xFF33FF33);

  // Secondary Colors
  static const Color secondary = Color(0xFF000000); // Black
  static const Color secondaryDark = Color(0xFF1A1A1A);
  static const Color secondaryLight = Color(0xFF333333);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);

  // Neutral Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF757575);
  static const Color divider = Color(0xFFE0E0E0);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
}

class AppGradients {
  static const LinearGradient primary = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App-wide text strings
class AppStrings {
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String invoices = 'Invoices';
  static const String payroll = 'Payroll';
  static const String payments = 'Payments';
  static const String settings = 'Settings';

  // Dashboard
  static const String totalInvoices = 'Total Invoices';
  static const String pendingPayments = 'Pending Payments';
  static const String scheduledPayroll = 'Scheduled Payroll';
  static const String recentActivity = 'Recent Activity';
  static const String quickActions = 'Quick Actions';
  static const String noRecentActivity = 'No recent activity';

  // Invoice
  static const String createInvoice = 'Create Invoice';
  static const String invoiceNumber = 'Invoice #';
  static const String clientEmail = 'Client Email';
  static const String amount = 'Amount';
  static const String description = 'Description';
  static const String dueDate = 'Due Date';
  static const String invoiceStatus = 'Status';
  static const String invoicePreview = 'Invoice Preview';
  static const String clientWallet = 'Client Wallet';
  static const String amountUSD = 'Amount (USD)';
  static const String amountBDAG = 'Amount (BDAG)';
  static const String clientBdagWallet = 'Client BDAG Wallet';
  static const String cryptoAmount = 'Crypto Amount:';

  // Invoice Status
  static const String statusPending = 'Pending';
  static const String statusPaid = 'Paid';
  static const String statusOverdue = 'Overdue';
  static const String statusCancelled = 'Cancelled';

  // Payroll
  static const String schedulePayroll = 'Schedule Payroll';
  static const String payeeName = 'Payee Name';
  static const String walletAddress = 'Wallet Address';
  static const String paymentFrequency = 'Payment Frequency';
  static const String oneTime = 'One-time';
  static const String weekly = 'Weekly';
  static const String biWeekly = 'Bi-weekly';
  static const String monthly = 'Monthly';
  static const String maxPayeesAllowed = 'Maximum {max} payees allowed';
  static const String noPayrollScheduled = 'No payroll scheduled';
  static const String maxPayees = 'Max {max} payees';
  static const String enterPayeeName = 'Please enter payee name';
  static const String enterWalletAddress = 'Please enter wallet address';

  // Payments
  static const String scanQrCode = 'Scan QR Code';
  static const String generateQrCode = 'Generate QR Code';
  static const String transactionStatus = 'Transaction Status';
  static const String transactionConfirmed = 'Transaction Confirmed';
  static const String transactionPending = 'Transaction Pending';
  static const String transactionFailed = 'Transaction Failed';
  static const String pay = 'Pay';
  static const String scanQrCodeWithWallet = 'Scan QR code with your BlockDAG wallet';
  static const String network = 'Network';

  // Settings
  static const String profile = 'Profile';
  static const String email = 'Email';
  static const String wallet = 'Wallet';
  static const String onOffRamp = 'On/Off Ramp';
  static const String logout = 'Logout';

  // Profile & Wallet
  static const String loggedInUserEmail = 'user@example.com'; // Placeholder
  static const String notConnected = 'Not connected';
  static const String connectWallet = 'Connect Wallet';
  static const String disconnectWallet = 'Disconnect Wallet';

  // On/Off Ramp
  static const String buySellCrypto = 'Buy/Sell Crypto';
  static const String convertBdagToUsd = 'Convert BDAG to USD';

  // App Settings
  static const String appSettings = 'App Settings';
  static const String about = 'About';
  static const String couldNotLaunchUrl = 'Could not launch URL.';
  static const String theme = 'Theme';
  static const String lightMode = 'Light Mode';
  static const String darkMode = 'Dark Mode';
  static const String systemTheme = 'System Theme';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String send = 'Send';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  static const String create = 'Create';
  static const String preview = 'Preview';
  static const String done = 'Done';
  static const String sendInvoiceEmail = 'Send Invoice Email';
  static const String sharePaymentLink = 'Share Payment Link';

  // Filters
  static const String all = 'All';

  // Invoice Details
  static const String invoiceDetails = 'Invoice Details';
  static const String transactionDetails = 'Transaction Details';
  static const String hash = 'Hash';
  static const String confirmations = 'Confirmations';
  static const String confirmed = 'Confirmed';
  static const String client = 'Client';
  static const String date = 'Date';

  // Messages
  static const String successMessage = 'Operation completed successfully';
  static const String errorMessage = 'An error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String invalidInput = 'Please check your input and try again.';
  static const String enterClientEmailOrWallet = 'Please enter client email or wallet address';
  static const String enterValidEmail = 'Please enter a valid email';
  static const String enterAmount = 'Please enter amount';
  static const String enterValidNumber = 'Please enter a valid number';
  static const String enterDescription = 'Please enter description';
  static const String noInvoicesFound = 'No invoices found';
  static const String notAvailable = 'N/A';
  static const String fetchingBdagPrice = 'Fetching BDAG price...';
}
