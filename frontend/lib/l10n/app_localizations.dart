import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_si.dart';
import 'app_localizations_ta.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vello'**
  String get appTitle;

  /// No description provided for @vello.
  ///
  /// In en, this message translates to:
  /// **'Vello'**
  String get vello;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'Event'**
  String get event;

  /// No description provided for @ai.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @allTransactions.
  ///
  /// In en, this message translates to:
  /// **'All Transactions'**
  String get allTransactions;

  /// No description provided for @savingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @velloMenu.
  ///
  /// In en, this message translates to:
  /// **'Vello Menu'**
  String get velloMenu;

  /// No description provided for @viewCompleteTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'View complete transaction history'**
  String get viewCompleteTransactionHistory;

  /// No description provided for @setAndTrackSavingsGoals.
  ///
  /// In en, this message translates to:
  /// **'Set and track savings goals'**
  String get setAndTrackSavingsGoals;

  /// No description provided for @viewSpendingAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View spending analytics'**
  String get viewSpendingAnalytics;

  /// No description provided for @settingsManagePreferences.
  ///
  /// In en, this message translates to:
  /// **'App settings'**
  String get settingsManagePreferences;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// No description provided for @disabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @sinhala.
  ///
  /// In en, this message translates to:
  /// **'Sinhala'**
  String get sinhala;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @autoBillDetection.
  ///
  /// In en, this message translates to:
  /// **'Auto Bill Detection'**
  String get autoBillDetection;

  /// No description provided for @emailBills.
  ///
  /// In en, this message translates to:
  /// **'Email Bills'**
  String get emailBills;

  /// No description provided for @smsBills.
  ///
  /// In en, this message translates to:
  /// **'SMS Bills'**
  String get smsBills;

  /// No description provided for @autoDetectBillsFromGmail.
  ///
  /// In en, this message translates to:
  /// **'Detect bills from Gmail'**
  String get autoDetectBillsFromGmail;

  /// No description provided for @autoDetectBillsFromMessages.
  ///
  /// In en, this message translates to:
  /// **'Detect bills from SMS'**
  String get autoDetectBillsFromMessages;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get reminder;

  /// No description provided for @receiveReminderNotifications.
  ///
  /// In en, this message translates to:
  /// **'Get reminders'**
  String get receiveReminderNotifications;

  /// No description provided for @pleaseLogInFirst.
  ///
  /// In en, this message translates to:
  /// **'Please log in first'**
  String get pleaseLogInFirst;

  /// No description provided for @gmailConnectedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Gmail connected successfully!'**
  String get gmailConnectedSuccessfully;

  /// No description provided for @failedToConnectGmailPleaseTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect Gmail. Please try again.'**
  String get failedToConnectGmailPleaseTryAgain;

  /// No description provided for @eventPlanner.
  ///
  /// In en, this message translates to:
  /// **'Event Planner'**
  String get eventPlanner;

  /// No description provided for @eventPlannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plan and budget for festivals, parties, and special occasions'**
  String get eventPlannerSubtitle;

  /// No description provided for @newEvent.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEvent;

  /// No description provided for @addEventDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get addEventDialogTitle;

  /// No description provided for @newEventDefault.
  ///
  /// In en, this message translates to:
  /// **'New Event'**
  String get newEventDefault;

  /// No description provided for @eventDeletedSnack.
  ///
  /// In en, this message translates to:
  /// **'{title} deleted'**
  String eventDeletedSnack(Object title);

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @eventTitle.
  ///
  /// In en, this message translates to:
  /// **'Event Title'**
  String get eventTitle;

  /// No description provided for @budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget Amount (\$)'**
  String get budgetAmount;

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent Amount (\$)'**
  String get spentAmount;

  /// No description provided for @autoAddToExpenses.
  ///
  /// In en, this message translates to:
  /// **'Auto-add to Expenses'**
  String get autoAddToExpenses;

  /// No description provided for @autoAddToExpensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds this event\'s spent amount to your expense list'**
  String get autoAddToExpensesSubtitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @amountLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left'**
  String amountLeft(Object amount);

  /// No description provided for @receiptScanSuccess.
  ///
  /// In en, this message translates to:
  /// **'Receipt successfully scanned! \$34.50 added.'**
  String get receiptScanSuccess;

  /// No description provided for @alignReceiptWithinFrame.
  ///
  /// In en, this message translates to:
  /// **'Align receipt within the frame'**
  String get alignReceiptWithinFrame;

  /// No description provided for @analyzingReceipt.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Receipt...'**
  String get analyzingReceipt;

  /// No description provided for @weeklyPlannerWeekendOnly.
  ///
  /// In en, this message translates to:
  /// **'This weekly planner is available on weekends only.\n\nCome back on Saturday or Sunday to plan your spending for the week ahead!'**
  String get weeklyPlannerWeekendOnly;

  /// No description provided for @weeklyPlannerGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'m your Weekly Budget Planner.\n\nEvery weekend I help you build a personalised budget for the coming week using your actual balance, spending history, and savings goals.\n\nTell me your planned expenses for next week. For example:\n\"food 5000, transport 2000, entertainment 1500, health 1000\"'**
  String get weeklyPlannerGreeting;

  /// No description provided for @weeklyPlannerAdjustMessage.
  ///
  /// In en, this message translates to:
  /// **'You can adjust any category - just tell me the new amounts and I\'ll update the plan.'**
  String get weeklyPlannerAdjustMessage;

  /// No description provided for @weeklyPlannerDataProblem.
  ///
  /// In en, this message translates to:
  /// **'Sorry, I ran into a problem fetching your financial data. Please check your connection and try again.'**
  String get weeklyPlannerDataProblem;

  /// No description provided for @weekendPlanningActive.
  ///
  /// In en, this message translates to:
  /// **'Weekend planning is active'**
  String get weekendPlanningActive;

  /// No description provided for @analysingYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Analysing your finances...'**
  String get analysingYourFinances;

  /// No description provided for @weeklyPlannerHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. food 5000, transport 2000...'**
  String get weeklyPlannerHint;

  /// No description provided for @availableOnWeekendsOnly.
  ///
  /// In en, this message translates to:
  /// **'Available on weekends only'**
  String get availableOnWeekendsOnly;

  /// No description provided for @chipFoodTransport.
  ///
  /// In en, this message translates to:
  /// **'food 5000, transport 2000'**
  String get chipFoodTransport;

  /// No description provided for @chipEntertainment.
  ///
  /// In en, this message translates to:
  /// **'entertainment 1500'**
  String get chipEntertainment;

  /// No description provided for @chipHealth.
  ///
  /// In en, this message translates to:
  /// **'health 1000'**
  String get chipHealth;

  /// No description provided for @chipHowMuchSave.
  ///
  /// In en, this message translates to:
  /// **'How much can I save?'**
  String get chipHowMuchSave;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found.'**
  String get noTransactionsFound;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get savingsRate;

  /// No description provided for @budgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// No description provided for @noBudgetsSet.
  ///
  /// In en, this message translates to:
  /// **'No budgets set. Set limits in the side menu!'**
  String get noBudgetsSet;

  /// No description provided for @monthlyBudgetStatus.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget Status'**
  String get monthlyBudgetStatus;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Tap + to add one!'**
  String get noTransactionsYet;

  /// No description provided for @negativeBalance.
  ///
  /// In en, this message translates to:
  /// **'Negative Balance'**
  String get negativeBalance;

  /// No description provided for @excellentBalance.
  ///
  /// In en, this message translates to:
  /// **'Excellent Balance'**
  String get excellentBalance;

  /// No description provided for @healthyBalance.
  ///
  /// In en, this message translates to:
  /// **'Healthy Balance'**
  String get healthyBalance;

  /// No description provided for @watchYourSpending.
  ///
  /// In en, this message translates to:
  /// **'Watch Your Spending'**
  String get watchYourSpending;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @addTransactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Add income or expense.'**
  String get addTransactionDescription;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @enterTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter transaction title'**
  String get enterTransactionTitle;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @transactionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAddedSuccessfully;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get errorPrefix;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @transportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get transportation;

  /// No description provided for @entertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// No description provided for @shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// No description provided for @bills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get bills;

  /// No description provided for @healthcare.
  ///
  /// In en, this message translates to:
  /// **'Healthcare'**
  String get healthcare;

  /// No description provided for @education.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get salary;

  /// No description provided for @freelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get freelance;

  /// No description provided for @investment.
  ///
  /// In en, this message translates to:
  /// **'Investment'**
  String get investment;

  /// No description provided for @gift.
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get gift;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailAddress;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Log out now?'**
  String get confirmLogout;

  /// No description provided for @noEmailFound.
  ///
  /// In en, this message translates to:
  /// **'No email found for this account.'**
  String get noEmailFound;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @resetPasswordTo.
  ///
  /// In en, this message translates to:
  /// **'Send reset email to'**
  String get resetPasswordTo;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @resetEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'Reset email sent to'**
  String get resetEmailSentTo;

  /// No description provided for @resetEmailFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send reset email'**
  String get resetEmailFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'si', 'ta'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'si':
      return AppLocalizationsSi();
    case 'ta':
      return AppLocalizationsTa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
