import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'Klytic Pay';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://api.klyticpay.com'; // TODO: Replace with actual URL
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Solana Configuration
  static const String solanaRpcUrl = 'https://api.devnet.solana.com'; // TODO: Change to mainnet for production
  static const String solanaNetwork = 'devnet'; // devnet, testnet, mainnet-beta
  
  // Currencies
  static const String solToken = 'SOL';
  static const String usdcToken = 'USDC';
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
  // Solana Brand Colors
  static const Color solanaPurple = Color(0xFF9945FF);
  static const Color solanaGreen = Color(0xFF14F195);
  static const Color solanaGradientStart = Color(0xFF9945FF);
  static const Color solanaGradientEnd = Color(0xFF14F195);
  
  // Primary Colors
  static const Color primary = solanaPurple;
  static const Color primaryDark = Color(0xFF7B35E0);
  static const Color primaryLight = Color(0xFFB56CFF);
  
  // Secondary Colors
  static const Color secondary = solanaGreen;
  static const Color secondaryDark = Color(0xFF10C77A);
  static const Color secondaryLight = Color(0xFF4FFAAF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
  static const Color info = Color(0xFF29B6F6);
  
  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
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
  
  // Invoice
  static const String createInvoice = 'Create Invoice';
  static const String invoiceNumber = 'Invoice #';
  static const String clientEmail = 'Client Email';
  static const String amount = 'Amount';
  static const String description = 'Description';
  static const String dueDate = 'Due Date';
  static const String invoiceStatus = 'Status';
  
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
  
  // Payments
  static const String scanQrCode = 'Scan QR Code';
  static const String generateQrCode = 'Generate QR Code';
  static const String transactionStatus = 'Transaction Status';
  static const String transactionConfirmed = 'Transaction Confirmed';
  static const String transactionPending = 'Transaction Pending';
  static const String transactionFailed = 'Transaction Failed';
  
  // Settings
  static const String profile = 'Profile';
  static const String email = 'Email';
  static const String wallet = 'Wallet';
  static const String onOffRamp = 'On/Off Ramp';
  static const String theme = 'Theme';
  static const String logout = 'Logout';
  
  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String send = 'Send';
  static const String confirm = 'Confirm';
  static const String retry = 'Retry';
  
  // Messages
  static const String successMessage = 'Operation completed successfully';
  static const String errorMessage = 'An error occurred. Please try again.';
  static const String networkError = 'Network error. Please check your connection.';
  static const String invalidInput = 'Please check your input and try again.';
}
