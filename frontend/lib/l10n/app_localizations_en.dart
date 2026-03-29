// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vello';

  @override
  String get vello => 'Vello';

  @override
  String get home => 'Home';

  @override
  String get scan => 'Scan';

  @override
  String get event => 'Event';

  @override
  String get ai => 'AI';

  @override
  String get settings => 'Settings';

  @override
  String get allTransactions => 'All Transactions';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get statistics => 'Statistics';

  @override
  String get velloMenu => 'Vello Menu';

  @override
  String get viewCompleteTransactionHistory =>
      'View complete transaction history';

  @override
  String get setAndTrackSavingsGoals => 'Set and track savings goals';

  @override
  String get viewSpendingAnalytics => 'View spending analytics';

  @override
  String get settingsManagePreferences => 'App settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get sinhala => 'Sinhala';

  @override
  String get tamil => 'Tamil';

  @override
  String get autoBillDetection => 'Auto Bill Detection';

  @override
  String get emailBills => 'Email Bills';

  @override
  String get smsBills => 'SMS Bills';

  @override
  String get autoDetectBillsFromGmail => 'Detect bills from Gmail';

  @override
  String get autoDetectBillsFromMessages => 'Detect bills from SMS';

  @override
  String get notifications => 'Notifications';

  @override
  String get reminder => 'Reminder';

  @override
  String get receiveReminderNotifications => 'Get reminders';

  @override
  String get pleaseLogInFirst => 'Please log in first';

  @override
  String get gmailConnectedSuccessfully => 'Gmail connected successfully!';

  @override
  String get failedToConnectGmailPleaseTryAgain =>
      'Failed to connect Gmail. Please try again.';

  @override
  String get eventPlanner => 'Event Planner';

  @override
  String get eventPlannerSubtitle =>
      'Plan and budget for festivals, parties, and special occasions';

  @override
  String get newEvent => 'New Event';

  @override
  String get addEventDialogTitle => 'New Event';

  @override
  String get newEventDefault => 'New Event';

  @override
  String eventDeletedSnack(Object title) {
    return '$title deleted';
  }

  @override
  String get upcoming => 'Upcoming';

  @override
  String get eventTitle => 'Event Title';

  @override
  String get budgetAmount => 'Budget Amount (\$)';

  @override
  String get spentAmount => 'Spent Amount (\$)';

  @override
  String get autoAddToExpenses => 'Auto-add to Expenses';

  @override
  String get autoAddToExpensesSubtitle =>
      'Adds this event\'s spent amount to your expense list';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get spent => 'Spent';

  @override
  String get budget => 'Budget';

  @override
  String amountLeft(Object amount) {
    return '$amount left';
  }

  @override
  String get receiptScanSuccess =>
      'Receipt successfully scanned! \$34.50 added.';

  @override
  String get alignReceiptWithinFrame => 'Align receipt within the frame';

  @override
  String get analyzingReceipt => 'Analyzing Receipt...';

  @override
  String get weeklyPlannerWeekendOnly =>
      'This weekly planner is available on weekends only.\n\nCome back on Saturday or Sunday to plan your spending for the week ahead!';

  @override
  String get weeklyPlannerGreeting =>
      'Hi! I\'m your Weekly Budget Planner.\n\nEvery weekend I help you build a personalised budget for the coming week using your actual balance, spending history, and savings goals.\n\nTell me your planned expenses for next week. For example:\n\"food 5000, transport 2000, entertainment 1500, health 1000\"';

  @override
  String get weeklyPlannerAdjustMessage =>
      'You can adjust any category - just tell me the new amounts and I\'ll update the plan.';

  @override
  String get weeklyPlannerDataProblem =>
      'Sorry, I ran into a problem fetching your financial data. Please check your connection and try again.';

  @override
  String get weekendPlanningActive => 'Weekend planning is active';

  @override
  String get analysingYourFinances => 'Analysing your finances...';

  @override
  String get weeklyPlannerHint => 'e.g. food 5000, transport 2000...';

  @override
  String get availableOnWeekendsOnly => 'Available on weekends only';

  @override
  String get chipFoodTransport => 'food 5000, transport 2000';

  @override
  String get chipEntertainment => 'entertainment 1500';

  @override
  String get chipHealth => 'health 1000';

  @override
  String get chipHowMuchSave => 'How much can I save?';

  @override
  String get noTransactionsFound => 'No transactions found.';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get income => 'Income';

  @override
  String get expenses => 'Expenses';

  @override
  String get savingsRate => 'Savings Rate';

  @override
  String get budgetOverview => 'Budget Overview';

  @override
  String get noBudgetsSet => 'No budgets set. Set limits in the side menu!';

  @override
  String get monthlyBudgetStatus => 'Monthly Budget Status';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get noTransactionsYet => 'No transactions yet. Tap + to add one!';

  @override
  String get negativeBalance => 'Negative Balance';

  @override
  String get excellentBalance => 'Excellent Balance';

  @override
  String get healthyBalance => 'Healthy Balance';

  @override
  String get watchYourSpending => 'Watch Your Spending';

  @override
  String get addTransaction => 'Add Transaction';

  @override
  String get addTransactionDescription => 'Add income or expense.';

  @override
  String get type => 'Type';

  @override
  String get title => 'Title';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get enterTransactionTitle => 'Enter transaction title';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get transactionAddedSuccessfully => 'Transaction added successfully';

  @override
  String get errorPrefix => 'Error';

  @override
  String get expense => 'Expense';

  @override
  String get food => 'Food';

  @override
  String get transportation => 'Transportation';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get shopping => 'Shopping';

  @override
  String get bills => 'Bills';

  @override
  String get healthcare => 'Healthcare';

  @override
  String get education => 'Education';

  @override
  String get other => 'Other';

  @override
  String get salary => 'Salary';

  @override
  String get freelance => 'Freelance';

  @override
  String get investment => 'Investment';

  @override
  String get gift => 'Gift';

  @override
  String get myProfile => 'My Profile';

  @override
  String get user => 'User';

  @override
  String get fullName => 'Full Name';

  @override
  String get emailAddress => 'Email';

  @override
  String get memberSince => 'Member Since';

  @override
  String get userId => 'User ID';

  @override
  String get changePassword => 'Change Password';

  @override
  String get logOut => 'Log Out';

  @override
  String get confirmLogout => 'Log out now?';

  @override
  String get noEmailFound => 'No email found for this account.';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get resetPasswordTo => 'Send reset email to';

  @override
  String get sendEmail => 'Send Email';

  @override
  String get resetEmailSentTo => 'Reset email sent to';

  @override
  String get resetEmailFailed => 'Could not send reset email';
}
