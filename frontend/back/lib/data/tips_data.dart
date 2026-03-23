/// Curated financial tips organized by category.
class TipsData {
  TipsData._();

  /// General savings tips.
  static const List<String> savingsTips = [
    'Try the 50/30/20 rule: 50% needs, 30% wants, 20% savings.',
    'Set up automatic transfers to your savings account on payday.',
    'Track every expense for a month — awareness alone reduces spending by 10-15%.',
    'Use the 24-hour rule: wait a day before any non-essential purchase over \$50.',
    'Cancel subscriptions you haven\'t used in the last 30 days.',
    'Cook meals at home — eating out costs 3-5x more than home cooking.',
    'Use cashback apps and rewards programs for purchases you\'d make anyway.',
    'Review your recurring bills quarterly and negotiate better rates.',
    'Set specific savings goals with deadlines — "Save \$1,000 by June" beats "save more money".',
    'Build an emergency fund covering 3-6 months of expenses before other goals.',
  ];

  /// Budgeting tips.
  static const List<String> budgetingTips = [
    'Start with the 50/30/20 framework: 50% needs, 30% wants, 20% savings & debt.',
    'Review and adjust your budget at the start of each month.',
    'Use envelope budgeting for categories where you tend to overspend.',
    'Include a small "fun money" category to avoid budget fatigue.',
    'Track your budget weekly, not just monthly — catch overspending early.',
    'Account for irregular expenses (car maintenance, gifts) with a sinking fund.',
    'Round up your bill estimates slightly to create a built-in buffer.',
    'Prioritize paying off high-interest debt — it\'s the best "return" on your money.',
  ];

  /// Food & dining savings tips.
  static const List<String> foodTips = [
    'Meal prep on Sundays to reduce weekday takeout spending.',
    'Make a grocery list and stick to it — impulse buys add 20-40% to your bill.',
    'Buy store brands instead of name brands — same quality, 20-30% cheaper.',
    'Use a slow cooker or instant pot for easy, affordable batch cooking.',
    'Limit eating out to once or twice a week as a treat, not a habit.',
    'Bring lunch to work — you\'ll save \$50-100 per week.',
    'Check for restaurant deals and happy hour specials when dining out.',
  ];

  /// Transport savings tips.
  static const List<String> transportTips = [
    'Use public transit or carpool to work when possible.',
    'Combine errands into one trip to save on fuel.',
    'Consider biking or walking for short distances — it\'s free and healthy.',
    'Compare gas prices using apps before filling up.',
    'Keep your car maintained — proper tire pressure alone saves 3% on fuel.',
    'If you work remotely, consider reducing to one car for big savings.',
  ];

  /// Shopping savings tips.
  static const List<String> shoppingTips = [
    'Unsubscribe from retail emails — out of sight, out of cart.',
    'Wait for seasonal sales for big purchases (Black Friday, end-of-season).',
    'Use price comparison tools before buying anything over \$25.',
    'Adopt a "one in, one out" rule — donate something before buying new.',
    'Shop with a list and a budget cap for each trip.',
    'Avoid browsing online stores as entertainment — it leads to impulse buys.',
  ];

  /// Subscription management tips.
  static const List<String> subscriptionTips = [
    'Audit all your subscriptions — most people forget about 2-3 active ones.',
    'Share family plans for streaming services to split costs.',
    'Use free alternatives where possible (library, free podcast apps, etc.).',
    'Set calendar reminders before free trials expire.',
    'Consider annual plans vs monthly — they\'re usually 15-30% cheaper.',
  ];

  /// Bill reduction tips.
  static const List<String> billTips = [
    'Call your internet/phone provider annually to negotiate rates.',
    'Switch to LED bulbs and smart plugs to reduce electricity costs.',
    'Compare insurance rates yearly — loyalty doesn\'t always pay.',
    'Bundle services (internet + phone) for package discounts.',
    'Set thermostats 2-3 degrees lower in winter and higher in summer.',
  ];

  /// Get tips relevant to a specific category.
  static List<String> getTipsForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'groceries':
        return foodTips;
      case 'transport':
      case 'transportation':
        return transportTips;
      case 'shopping':
        return shoppingTips;
      case 'subscription':
      case 'subscriptions':
        return subscriptionTips;
      case 'bills':
      case 'utilities':
        return billTips;
      default:
        return savingsTips;
    }
  }

  /// Get a random selection of tips.
  static List<String> getRandomTips(int count, {String? category}) {
    final source =
        category != null ? getTipsForCategory(category) : savingsTips;
    final shuffled = List<String>.from(source)..shuffle();
    return shuffled.take(count.clamp(1, source.length)).toList();
  }
}
