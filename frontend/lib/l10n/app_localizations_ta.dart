// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'Vello';

  @override
  String get vello => 'Vello';

  @override
  String get home => 'முகப்பு';

  @override
  String get scan => 'ஸ்கேன்';

  @override
  String get event => 'நிகழ்வு';

  @override
  String get ai => 'AI';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get allTransactions => 'அனைத்து பரிவர்த்தனைகள்';

  @override
  String get savingsGoals => 'சேமிப்பு இலக்குகள்';

  @override
  String get statistics => 'புள்ளிவிவரங்கள்';

  @override
  String get velloMenu => 'Vello Menu';

  @override
  String get viewCompleteTransactionHistory =>
      'முழு பரிவர்த்தனை வரலாற்றைக் காண்க';

  @override
  String get setAndTrackSavingsGoals =>
      'சேமிப்பு இலக்குகளை அமைத்து கண்காணிக்கவும்';

  @override
  String get viewSpendingAnalytics => 'செலவுப் பகுப்பாய்வைக் காண்க';

  @override
  String get settingsManagePreferences => 'அப் அமைப்புகள்';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get darkMode => 'இருள் நிலை';

  @override
  String get enabled => 'இயக்கப்பட்டது';

  @override
  String get disabled => 'முடக்கப்பட்டது';

  @override
  String get language => 'மொழி';

  @override
  String get english => 'ஆங்கிலம்';

  @override
  String get sinhala => 'சிங்களம்';

  @override
  String get tamil => 'தமிழ்';

  @override
  String get autoBillDetection => 'தானியங்கி பில் கண்டறிதல்';

  @override
  String get emailBills => 'மின்னஞ்சல் பில்கள்';

  @override
  String get smsBills => 'SMS பில்கள்';

  @override
  String get autoDetectBillsFromGmail => 'Gmail பில்களை கண்டறி';

  @override
  String get autoDetectBillsFromMessages => 'SMS பில்களை கண்டறி';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get reminder => 'நினைவூட்டல்';

  @override
  String get receiveReminderNotifications => 'நினைவூட்டல்கள் பெறுங்கள்';

  @override
  String get pleaseLogInFirst => 'முதலில் உள்நுழையவும்';

  @override
  String get gmailConnectedSuccessfully => 'Gmail வெற்றிகரமாக இணைக்கப்பட்டது!';

  @override
  String get failedToConnectGmailPleaseTryAgain =>
      'Gmail-ஐ இணைக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get eventPlanner => 'நிகழ்வு திட்டமிடல்';

  @override
  String get eventPlannerSubtitle =>
      'திருவிழாக்கள், விருந்து மற்றும் சிறப்பு நிகழ்வுகளுக்கான திட்டம் மற்றும் பட்ஜெட்';

  @override
  String get newEvent => 'புதிய நிகழ்வு';

  @override
  String get addEventDialogTitle => 'புதிய நிகழ்வு';

  @override
  String get newEventDefault => 'புதிய நிகழ்வு';

  @override
  String eventDeletedSnack(Object title) {
    return '$title நீக்கப்பட்டது';
  }

  @override
  String get upcoming => 'வரவிருக்கும்';

  @override
  String get eventTitle => 'நிகழ்வு தலைப்பு';

  @override
  String get budgetAmount => 'பட்ஜெட் தொகை (\$)';

  @override
  String get spentAmount => 'செலவிட்ட தொகை (\$)';

  @override
  String get autoAddToExpenses => 'செலவுகளுக்கு தானாக சேர்க்கவும்';

  @override
  String get autoAddToExpensesSubtitle =>
      'இந்த நிகழ்வின் செலவினை உங்கள் செலவு பட்டியலில் சேர்க்கும்';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get add => 'சேர்';

  @override
  String get spent => 'செலவு';

  @override
  String get budget => 'பட்ஜெட்';

  @override
  String amountLeft(Object amount) {
    return '$amount மீதம்';
  }

  @override
  String get receiptScanSuccess =>
      'ரசீது வெற்றிகரமாக ஸ்கேன் செய்யப்பட்டது! \$34.50 சேர்க்கப்பட்டது.';

  @override
  String get alignReceiptWithinFrame => 'ரசீதையை கட்டத்தின் உள்ளே பொருத்தவும்';

  @override
  String get analyzingReceipt => 'ரசீதையை பகுப்பாய்வு செய்கிறது...';

  @override
  String get weeklyPlannerWeekendOnly =>
      'இந்த வார திட்டமிடல் வார இறுதிகளில் மட்டும் கிடைக்கும்.\n\nஅடுத்த வார செலவுகளை திட்டமிட சனி அல்லது ஞாயிற்றுக்கிழமை திரும்ப வாருங்கள்!';

  @override
  String get weeklyPlannerGreeting =>
      'வணக்கம்! நான் உங்கள் வாராந்திர பட்ஜெட் திட்டமிடுபவன்.\n\nஒவ்வொரு வார இறுதியிலும், உங்கள் இருப்பு, செலவுத் தகவல் மற்றும் சேமிப்பு இலக்குகள் அடிப்படையில் அடுத்த வாரத்திற்கான தனிப்பயன் திட்டம் அமைக்க உதவுகிறேன்.\n\nஅடுத்த வாரம் நீங்கள் திட்டமிடும் செலவுகளை சொல்லுங்கள். உதாரணம்:\n\"food 5000, transport 2000, entertainment 1500, health 1000\"';

  @override
  String get weeklyPlannerAdjustMessage =>
      'ஏதேனும் பிரிவை மாற்றலாம் - புதிய தொகையை சொல்லுங்கள், திட்டத்தை புதுப்பிக்கிறேன்.';

  @override
  String get weeklyPlannerDataProblem =>
      'மன்னிக்கவும், உங்கள் நிதி தகவலை பெறுவதில் சிக்கல் ஏற்பட்டது. இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get weekendPlanningActive =>
      'வார இறுதி திட்டமிடல் செயல்பாட்டில் உள்ளது';

  @override
  String get analysingYourFinances => 'உங்கள் நிதியை பகுப்பாய்வு செய்கிறது...';

  @override
  String get weeklyPlannerHint => 'எ.கா., food 5000, transport 2000...';

  @override
  String get availableOnWeekendsOnly => 'வார இறுதிகளில் மட்டும் கிடைக்கும்';

  @override
  String get chipFoodTransport => 'food 5000, transport 2000';

  @override
  String get chipEntertainment => 'entertainment 1500';

  @override
  String get chipHealth => 'health 1000';

  @override
  String get chipHowMuchSave => 'நான் எவ்வளவு சேமிக்க முடியும்?';

  @override
  String get noTransactionsFound => 'பரிவர்த்தனைகள் எதுவும் இல்லை.';

  @override
  String get totalBalance => 'மொத்த இருப்பு';

  @override
  String get income => 'வருமானம்';

  @override
  String get expenses => 'செலவுகள்';

  @override
  String get savingsRate => 'சேமிப்பு விகிதம்';

  @override
  String get budgetOverview => 'பட்ஜெட் ஒட்டுமொத்தம்';

  @override
  String get noBudgetsSet =>
      'பட்ஜெட்டுகள் அமைக்கப்படவில்லை. பக்க மெனுவில் வரம்புகளை அமைக்கவும்!';

  @override
  String get monthlyBudgetStatus => 'மாதாந்திர பட்ஜெட் நிலை';

  @override
  String get recentTransactions => 'சமீபத்திய பரிவர்த்தனைகள்';

  @override
  String get noTransactionsYet =>
      'இன்னும் பரிவர்த்தனைகள் இல்லை. சேர்க்க + ஐ அழுத்தவும்!';

  @override
  String get negativeBalance => 'எதிர்மறை இருப்பு';

  @override
  String get excellentBalance => 'சிறந்த இருப்பு';

  @override
  String get healthyBalance => 'ஆரோக்கியமான இருப்பு';

  @override
  String get watchYourSpending => 'உங்கள் செலவுகளை கவனிக்கவும்';

  @override
  String get addTransaction => 'பரிவர்த்தனை சேர்';

  @override
  String get addTransactionDescription => 'வருமானம் அல்லது செலவு சேர்க்கவும்.';

  @override
  String get type => 'வகை';

  @override
  String get title => 'தலைப்பு';

  @override
  String get amount => 'தொகை';

  @override
  String get category => 'பிரிவு';

  @override
  String get date => 'தேதி';

  @override
  String get enterTransactionTitle => 'பரிவர்த்தனை தலைப்பை உள்ளிடவும்';

  @override
  String get pleaseEnterTitle => 'தயவுசெய்து தலைப்பை உள்ளிடவும்';

  @override
  String get pleaseEnterAmount => 'தயவுசெய்து தொகையை உள்ளிடவும்';

  @override
  String get pleaseEnterValidNumber => 'சரியான எண்ணை உள்ளிடவும்';

  @override
  String get transactionAddedSuccessfully =>
      'பரிவர்த்தனை வெற்றிகரமாக சேர்க்கப்பட்டது';

  @override
  String get errorPrefix => 'பிழை';

  @override
  String get expense => 'செலவு';

  @override
  String get food => 'உணவு';

  @override
  String get transportation => 'போக்குவரத்து';

  @override
  String get entertainment => 'பொழுதுபோக்கு';

  @override
  String get shopping => 'கடைசெய்தல்';

  @override
  String get bills => 'பில்கள்';

  @override
  String get healthcare => 'சுகாதாரம்';

  @override
  String get education => 'கல்வி';

  @override
  String get other => 'மற்றவை';

  @override
  String get salary => 'சம்பளம்';

  @override
  String get freelance => 'சுயதொழில்';

  @override
  String get investment => 'முதலீடு';

  @override
  String get gift => 'பரிசு';

  @override
  String get myProfile => 'என் சுயவிவரம்';

  @override
  String get user => 'பயனர்';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get emailAddress => 'மின்னஞ்சல்';

  @override
  String get memberSince => 'உறுப்பினர் தேதி';

  @override
  String get userId => 'பயனர் ஐடி';

  @override
  String get changePassword => 'கடவுச்சொல் மாற்று';

  @override
  String get logOut => 'வெளியேறு';

  @override
  String get confirmLogout => 'இப்போது வெளியேறவா?';

  @override
  String get noEmailFound => 'இந்த கணக்கிற்கு மின்னஞ்சல் இல்லை.';

  @override
  String get resetPassword => 'கடவுச்சொல் மீட்டமை';

  @override
  String get resetPasswordTo => 'மீட்டமைப்பு மின்னஞ்சல் அனுப்பு';

  @override
  String get sendEmail => 'மின்னஞ்சல் அனுப்பு';

  @override
  String get resetEmailSentTo => 'மீட்டமைப்பு மின்னஞ்சல் அனுப்பப்பட்டது';

  @override
  String get resetEmailFailed => 'மீட்டமைப்பு மின்னஞ்சல் அனுப்ப முடியவில்லை';
}
