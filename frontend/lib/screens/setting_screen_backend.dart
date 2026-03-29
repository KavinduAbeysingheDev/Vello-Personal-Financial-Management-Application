import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  bool _isDarkMode = false;
  String _localeCode = 'en';
  bool _emailBills = false;
  bool _smsBills = false;
  bool _reminder = false;
  bool _budgetAlerts = true;
  bool _weeklySummary = true;

  bool get isDarkMode => _isDarkMode;
  String get localeCode => _localeCode;
  Locale get locale => Locale(_localeCode);
  String get language {
    switch (_localeCode) {
      case 'si':
        return 'Sinhala';
      case 'ta':
        return 'Tamil';
      default:
        return 'English';
    }
  }

  bool get emailBills => _emailBills;
  bool get smsBills => _smsBills;
  bool get reminder => _reminder;
  bool get budgetAlerts => _budgetAlerts;
  bool get weeklySummary => _weeklySummary;

  // Legacy helper used by screens that are still on key-based strings.
  String t(String key) {
    if (_localeCode == 'en') return key;
    final map = _localeCode == 'si' ? _siStrings : _taStrings;
    return map[key] ?? key;
  }

  static const Map<String, String> _siStrings = {
    'Event': 'සිදුවීම',
    'AI': 'ඒඅයි',
    'All Transactions': 'සියලු ගනුදෙනු',
    'Savings Goals': 'ඉතිරි කිරීමේ ඉලක්ක',
    'Statistics': 'සංඛ්‍යාලේඛන',
    'Smart Bill Scanner': 'ස්මාර්ට් බිල් ස්කෑනර්',
    'Scan bills with your camera and automatically add items':
        'කැමරාවෙන් බිල් ස්කෑන් කර අයිතම එක් කරන්න',
    'Scanned Total': 'ස්කෑන් කළ මුළු මුදල',
    'Rs.': 'රු.',
    'Total payable amount': 'ගෙවිය යුතු මුළු මුදල',
    'Add Transaction': 'ගනුදෙනුව එක් කරන්න',
    'Cancel': 'අවලංගු කරන්න',
    'Invalid scanned amount found.': 'වැරදි ස්කෑන් මුදලක් හමු විය.',
    'Bill Scan': 'බිල් ස්කෑන්',
    'Transaction of Rs.': 'රු. ගනුදෙනුව',
    'added successfully!': 'සාර්ථකව එක් කරන ලදි!',
    'Failed to save': 'සුරැකීමට අසාර්ථක විය',
    'Capture Bill': 'බිල් ගන්න',
    'Scanning...': 'ස්කෑන් කරමින්...',
    'Multi Scan': 'බහු ස්කෑන්',
    'Take Photo': 'ඡායාරූපය ගන්න',
    'Upload': 'උඩුගත කරන්න',
    'Tips for Best Results': 'හොඳම ප්‍රතිඵල සඳහා උපදෙස්',
    'Ensure good lighting — avoid shadows on the bill':
        'හොඳ ආලෝකය තබා ගන්න - බිල්පතේ සෙවණැලි වලක්වන්න',
    'Ensure good lighting â€” avoid shadows on the bill':
        'හොඳ ආලෝකය තබා ගන්න - බිල්පතේ සෙවණැලි වලක්වන්න',
    'Hold the camera steady and close to the bill':
        'කැමරාව ස්ථාවරව තබා බිල්පතට සමීප කරන්න',
    'Make sure all text is clearly visible':
        'සියලුම අකුරු පැහැදිලිව පෙනෙන බව තහවුරු කරන්න',
    'Keep the bill flat and unwrinkled': 'බිල්පත පැතලිව තබන්න',
    'OK, Take Photo': 'හරි, ඡායාරූපය ගන්න',
    'Error': 'දෝෂය',
    'Tips for Best Upload': 'හොඳම උඩුගත කිරීම සඳහා උපදෙස්',
    'Use a clear, well-lit photo of the bill':
        'පැහැදිලි හා ආලෝකමත් බිල් ඡායාරූපයක් භාවිතා කරන්න',
    'Make sure all text is readable':
        'සියලු අකුරු කියවිය හැකි බව තහවුරු කරන්න',
    'Avoid blurry or dark images': 'අපැහැදිලි හෝ අඳුරු රූප වලක්වන්න',
    'The bill should fill most of the image':
        'රූපයේ වැඩි කොටස බිල්පතෙන් පිරවිය යුතුය',
    'OK, Upload': 'හරි, උඩුගත කරන්න',
    'Gallery access denied or no image selected.':
        'ගැලරි ප්‍රවේශය නැත හෝ රූපයක් තෝරා නැත.',
    'Multi-photo mode enabled!': 'බහු ඡායාරූප ප්‍රකාරය සක්‍රියයි!',
    'Multi-photo mode disabled.': 'බහු ඡායාරූප ප්‍රකාරය අක්‍රියයි.',
    'Multi-photo support': 'බහු ඡායාරූප සහාය',
    'Enabled! Tap camera to scan multiple photos.':
        'සක්‍රියයි! ඡායාරූප කිහිපයක් ස්කෑන් කිරීමට කැමරා බොත්තම තට්ටු කරන්න.',
    'Tap here to enable multi-photo mode for long bills!':
        'දිගු බිල්පත් සඳහා බහු ඡායාරූප ප්‍රකාරය සක්‍රිය කිරීමට මෙතැන තට්ටු කරන්න!',
  };

  static const Map<String, String> _taStrings = {
    'Event': 'நிகழ்வு',
    'AI': 'ஏஐ',
    'All Transactions': 'அனைத்து பரிவர்த்தனைகள்',
    'Savings Goals': 'சேமிப்பு இலக்குகள்',
    'Statistics': 'புள்ளிவிவரங்கள்',
    'Smart Bill Scanner': 'ஸ்மார்ட் பில் ஸ்கேனர்',
    'Scan bills with your camera and automatically add items':
        'கேமராவால் பில்களை ஸ்கேன் செய்து பொருட்களை சேர்க்கவும்',
    'Scanned Total': 'ஸ்கேன் செய்யப்பட்ட மொத்தம்',
    'Rs.': 'ரூ.',
    'Total payable amount': 'மொத்தம் செலுத்த வேண்டியது',
    'Add Transaction': 'பரிவர்த்தனை சேர்',
    'Cancel': 'ரத்து செய்',
    'Invalid scanned amount found.': 'தவறான ஸ்கேன் தொகை கண்டுபிடிக்கப்பட்டது.',
    'Bill Scan': 'பில் ஸ்கேன்',
    'Transaction of Rs.': 'ரூ. பரிவர்த்தனை',
    'added successfully!': 'வெற்றிகரமாக சேர்க்கப்பட்டது!',
    'Failed to save': 'சேமிக்க முடியவில்லை',
    'Capture Bill': 'பில் பிடி',
    'Scanning...': 'ஸ்கேன் செய்கிறது...',
    'Multi Scan': 'பல ஸ்கேன்',
    'Take Photo': 'புகைப்படம் எடு',
    'Upload': 'பதிவேற்று',
    'Tips for Best Results': 'சிறந்த முடிவுகளுக்கான குறிப்புகள்',
    'Ensure good lighting — avoid shadows on the bill':
        'நல்ல வெளிச்சம் இருக்கட்டும் - பிலில் நிழல் வராதபடி செய்யவும்',
    'Ensure good lighting â€” avoid shadows on the bill':
        'நல்ல வெளிச்சம் இருக்கட்டும் - பிலில் நிழல் வராதபடி செய்யவும்',
    'Hold the camera steady and close to the bill':
        'கேமராவை நிலையாக பிடித்து பிலுக்கு அருகில் கொண்டு வாருங்கள்',
    'Make sure all text is clearly visible':
        'அனைத்து எழுத்துகளும் தெளிவாகத் தெரிகிறதா உறுதி செய்யவும்',
    'Keep the bill flat and unwrinkled': 'பிலை சமமாக வைத்திருக்கவும்',
    'OK, Take Photo': 'சரி, படம் எடு',
    'Error': 'பிழை',
    'Tips for Best Upload': 'சிறந்த பதிவேற்றத்திற்கான குறிப்புகள்',
    'Use a clear, well-lit photo of the bill':
        'தெளிவான மற்றும் நல்ல வெளிச்சமுள்ள பில் படத்தை பயன்படுத்தவும்',
    'Make sure all text is readable':
        'எல்லா எழுத்துகளும் படிக்கக்கூடியதா உறுதி செய்யவும்',
    'Avoid blurry or dark images': 'மங்கலான அல்லது இருண்ட படங்களை தவிர்க்கவும்',
    'The bill should fill most of the image':
        'படத்தின் பெரும்பகுதியை பில் நிரப்ப வேண்டும்',
    'OK, Upload': 'சரி, பதிவேற்று',
    'Gallery access denied or no image selected.':
        'கேலரி அணுகல் இல்லை அல்லது படம் தேர்வு செய்யப்படவில்லை.',
    'Multi-photo mode enabled!': 'பல-புகைப்பட முறை இயக்கப்பட்டது!',
    'Multi-photo mode disabled.': 'பல-புகைப்பட முறை முடக்கப்பட்டது.',
    'Multi-photo support': 'பல-புகைப்பட ஆதரவு',
    'Enabled! Tap camera to scan multiple photos.':
        'இயக்கப்பட்டது! பல புகைப்படங்களை ஸ்கேன் செய்ய கேமராவை தட்டவும்.',
    'Tap here to enable multi-photo mode for long bills!':
        'நீளமான பில்களுக்கு பல-புகைப்பட முறையை இயக்க இங்கே தட்டவும்!',
  };

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _localeCode = _resolveLocaleCode(
      prefs.getString('localeCode') ?? prefs.getString('language') ?? 'en',
    );
    _emailBills = prefs.getBool('emailBills') ?? false;
    _smsBills = prefs.getBool('smsBills') ?? false;
    _reminder = prefs.getBool('reminder') ?? false;
    _budgetAlerts = prefs.getBool('budgetAlerts') ?? true;
    _weeklySummary = prefs.getBool('weeklySummary') ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setLocaleCode(String value) async {
    final normalized = _resolveLocaleCode(value);
    if (_localeCode == normalized) return;

    _localeCode = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeCode', _localeCode);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    await setLocaleCode(value);
  }

  Future<void> setEmailBills(bool value) async {
    _emailBills = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailBills', value);
    notifyListeners();
  }

  Future<void> setSmsBills(bool value) async {
    _smsBills = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('smsBills', value);
    notifyListeners();
  }

  Future<void> setReminder(bool value) async {
    _reminder = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reminder', value);
    notifyListeners();
  }

  Future<void> setBudgetAlerts(bool value) async {
    _budgetAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetAlerts', value);
    notifyListeners();
  }

  Future<void> setWeeklySummary(bool value) async {
    _weeklySummary = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weeklySummary', value);
    notifyListeners();
  }

  String _resolveLocaleCode(String value) {
    switch (value) {
      case 'English':
      case 'en':
        return 'en';
      case 'Sinhala':
      case 'si':
        return 'si';
      case 'Tamil':
      case 'ta':
        return 'ta';
      default:
        return 'en';
    }
  }
}
