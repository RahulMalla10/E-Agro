/// In-app strings for English and Nepali (नेपाली).
class AppStrings {
  AppStrings(this.languageCode);

  final String languageCode;

  bool get isNepali => languageCode == 'ne';

  String t(String en, String ne) => isNepali ? ne : en;

  String get appName => t('Krishi Smart', 'कृषि स्मार्ट');
  String get tagline =>
      t('Farm trade & advice for Nepal', 'नेपालका लागि कृषि व्यापार र सल्लाह');

  // Drawer & settings
  String get profile => t('Profile', 'प्रोफाइल');
  String get profileSubtitle => t('Account & role', 'खाता र भूमिका');
  String get settings => t('Settings', 'सेटिङ');
  String get language => t('Language', 'भाषा');
  String get appearance => t('Appearance', 'देखावट');
  String get darkMode => t('Dark mode', 'गाढा मोड');
  String get lightMode => t('Light mode', 'उज्यालो मोड');
  String get accountType => t('Account type', 'खाताको प्रकार');
  String get drawerFooter => t('Krishi Smart — Nepal', 'कृषि स्मार्ट — नेपाल');
  String get switchRole => t('Switch role', 'भूमिका बदल्नुहोस्');
  String get switchRoleSubtitle =>
      t('Buyer or seller', 'क्रेता वा विक्रेता');
  String get logout => t('Log out', 'लग आउट');
  String get logoutConfirm => t(
        'You will choose buyer or seller again. Language and theme stay saved.',
        'तपाईं फेरि क्रेता वा विक्रेता छान्नुहुनेछ। भाषा र थिम सुरक्षित रहन्छ।',
      );
  String get logoutRoleHint => t(
        'Pick how you want to use the app',
        'एप कसरी प्रयोग गर्ने छान्नुहोस्',
      );

  // Navigation
  String get navHome => t('Home', 'गृह');
  String get navFarmTools => t('Farm', 'खेती');
  String get navInsights => t('Insights', 'जानकारी');
  String get navSellerAnalytics => t('Analytics', 'विश्लेषण');

  // Seller analytics
  String get sellerAnalyticsTitle => t('Sales & inventory', 'बिक्री र स्टक');
  String get salesTrendTitle => t('Sales trend (7 days)', '७ दिन बिक्री');
  String get topProductsTitle => t('Top products', 'शीर्ष सामान');
  String get inventoryTitle => t('Inventory', 'स्टक व्यवस्थापन');
  String get analyticsRevenue => t('Revenue', 'आम्दानी');
  String get analyticsOrders => t('Orders', 'अर्डर');
  String get analyticsActiveListings => t('Active listings', 'सक्रिय सूची');
  String get analyticsLowStock => t('Low stock', 'कम स्टक');
  String get analyticsOutOfStock => t('out of stock', 'स्टक सकियो');
  String get sellerOrdersTitle => t('Orders', 'अर्डर');
  String get sellerOrdersEmpty => t('No orders yet', 'अहिले अर्डर छैन');
  String get orderDetails => t('Order details', 'अर्डर विवरण');
  String get sellerBuyerDetails => t('Buyer details', 'क्रेताको विवरण');
  String get orderDate => t('Date', 'मिति');
  String get orderProduct => t('Product', 'उत्पादन');
  String get navAdvisor => t('Advisor', 'सल्लाह');
  String get navDisease => t('Disease', 'रोग');
  String get navNews => t('News', 'समाचार');
  String get navWeather => t('Weather', 'मौसम');

  // Role
  String get chooseRole => t('How will you use Krishi Smart?', 'कृषि स्मार्ट कसरी प्रयोग गर्नुहुन्छ?');
  String get roleBuyer => t('Buyer', 'क्रेता');
  String get roleBuyerDesc => t('Browse & buy farm products', 'कृषि उत्पादन हेर्नु र किन्नु');
  String get roleSeller => t('Seller', 'विक्रेता');
  String get roleSellerDesc => t('List products for sale', 'बिक्रीका लागि सामान राख्नु');

  // Onboarding
  String get onboardingWelcome => t('Welcome', 'स्वागत छ');
  String get onboardingStepLanguage => t('Language', 'भाषा');
  String get onboardingStepRole => t('Your role', 'भूमिका');
  String get onboardingStepPermissions => t('Permissions', 'अनुमति');
  String get languageTitle => t('Choose your language', 'भाषा छान्नुहोस्');
  String get languageNepali => 'नेपाली';
  String get languageEnglish => 'English';
  String get permissionsTitle => t('Quick permissions', 'अनुमति');
  String get permissionsSubtitle => t(
        'Needed for weather, photos & listings.',
        'मौसम, फोटो र सूचीका लागि।',
      );
  String get consentLocationTitle => t('Location', 'स्थान');
  String get consentLocationBody => t(
        'Local weather & alerts only.',
        'स्थानीय मौसम र सूचना मात्र।',
      );
  String get consentPhotosTitle => t('Camera & photos', 'क्यामेरा');
  String get consentPhotosBody => t(
        'Product photos & disease scan on device.',
        'उत्पादन फोटो र रोग जाँच।',
      );
  String get consentRequired => t(
        'Enable at least one to continue.',
        'अगाडि बढ्न कम्तीमा एक अनुमति दिनुहोस्।',
      );
  String get btnGetStarted => t('Get started', 'सुरु गर्नुहोस्');
  String get btnBack => t('Back', 'पछाडि');
  String get btnNext => t('Next', 'अर्को');
  String get btnContinue => t('Continue', 'जारी राख्नुहोस्');

  // Home
  String get homeSubtitle => t('Marketplace', 'बजार');
  String get searchHint => t('Search produce…', 'खोज्नुहोस्…');
  String get sectionVegetables => t('Vegetables', 'तरकारी');
  String get sectionFruits => t('Fruits', 'फलफूल');
  String get sectionDairy => t('Dairy', 'दुधजन्य');
  String get noListings => t('No listings yet', 'अहिले सूची छैन');
  String searchResults(int n) => t('Results ($n)', 'परिणाम ($n)');

  // Seller listing
  String get listProduct => t('List product', 'सामान राख्नुहोस्');
  String get photosHint => t('Add 2–5 photos', '२–५ फोटो थप्नुहोस्');
  String get productNameEn => t('Name (English)', 'नाम (अङ्ग्रेजी)');
  String get productNameNeRequired => t('Name (Nepali)', 'नाम (नेपाली)');
  String get productNameNeRomanHint =>
      t('Type in Roman — converts live', 'रोमनमा टाइप गर्नुहोस् — तुरुन्त नेपाली');
  String get enterBothNames => t('Enter both names', 'दुवै नाम लेख्नुहोस्');
  String get photosRequired => t('Add at least 2 photos', 'कम्तीमा २ फोटो');
  String get stockPriceRequired => t('Enter valid stock & price', 'मात्रा र मूल्य लेख्नुहोस्');
  String get category => t('Category', 'श्रेणी');
  String get stockAmount => t('Stock', 'मात्रा');
  String get unit => t('Unit', 'इकाई');
  String get pricePerUnit => t('Price (Rs per unit)', 'मूल्य (रु./इकाई)');
  String get publishListing => t('Publish', 'प्रकाशित गर्नुहोस्');

  // Buyer / product
  String get productDetails => t('Product', 'उत्पादन');
  String get productNotFound => t('Not found', 'भेटिएन');
  String get stockAvailable => t('In stock', 'उपलब्ध');
  String get quantity => t('Quantity', 'मात्रा');
  String get total => t('Total', 'जम्मा');
  String get buyNow => t('Buy now', 'किन्नुहोस्');
  String get checkout => t('Checkout', 'भुक्तानी');
  String get orderSummary => t('Order', 'अर्डर');
  String get buyerDetails => t('Your details', 'तपाईंको विवरण');
  String get fullName => t('Full name', 'पूरा नाम');
  String get phone => t('Phone', 'फोन');
  String get address => t('Address', 'ठेगाना');
  String get landmark => t('Landmark (optional)', 'ल्यान्डमार्क');
  String get checkoutFieldsRequired => t('Fill name, phone & address', 'नाम, फोन, ठेगाना भर्नुहोस्');
  String get proceedToEsewa => t('Pay with eSewa', 'eSewa बाट तिर्नुहोस्');

  // eSewa
  String get payWithEsewa => t('eSewa payment', 'eSewa भुक्तानी');
  String get esewaLoginTitle => t('Sign in to eSewa', 'eSewa मा लगइन');
  String get esewaLoginSubtitle => t(
        'Enter your eSewa ID and password to continue.',
        'जारी राख्न eSewa ID र पासवर्ड लेख्नुहोस्।',
      );
  String get esewaIdLabel => t('eSewa ID', 'eSewa ID');
  String get esewaLoginButton => t('Sign in', 'लगइन');
  String get esewaEnterCredentials =>
      t('Enter eSewa ID and password', 'eSewa ID र पासवर्ड लेख्नुहोस्');
  String get esewaMpinTitle => t('Enter MPIN', 'MPIN लेख्नुहोस्');
  String get esewaMpinSubtitle => t(
        'Enter your 4-digit eSewa MPIN.',
        '४ अङ्कको eSewa MPIN लेख्नुहोस्।',
      );
  String get esewaMpinLabel => t('MPIN', 'MPIN');
  String get esewaMpinInvalid => t('Enter 4-digit MPIN', '४ अङ्कको MPIN लेख्नुहोस्');
  String get esewaConfirmTitle => t('Confirm payment', 'भुक्तानी पुष्टि');
  String get esewaPayNow => t('Pay now', 'अहिले तिर्नुहोस्');
  String get amount => t('Amount', 'रकम');
  String get merchant => t('Merchant', 'व्यापारी');
  String get password => t('Password', 'पासवर्ड');
  String get paymentSuccess => t('Payment successful', 'भुक्तानी सफल');
  String get reference => t('Reference', 'सन्दर्भ');
  String get backToHome => t('Back to home', 'गृहमा फर्कनुहोस्');

  // Advisor
  String get advisorTitle => t('Advisor', 'सल्लाह');
  String get advisorSubtitle => t('Growing guides', 'खेती गाइड');
  String get all => t('All', 'सबै');
  String get stepByStep => t('Directions', 'निर्देशन');

  // News & weather
  String get newsTitle => t('News', 'समाचार');
  String get readMore => t('Read more', 'थप पढ्नुहोस्');
  String get couldNotOpen => t('Could not open', 'खोल्न सकिएन');
  String get loadingNews => t('Loading…', 'लोड…');
  String get weatherTitle => t('Weather', 'मौसम');
  String get alerts => t('Alerts', 'सूचना');
  String get forecast5Day => t('5-day forecast', '५ दिन');
  String get humidityLabel => t('humidity', 'आद्रता');
  String get windLabel => t('wind', 'हावा');
  String get offlineWeatherHint => t(
        'Estimated data — add OPENWEATHER_API_KEY in .env for live data.',
        'अनुमानित — लाइभ डाटाका लागि .env मा API key।',
      );
  String get loading => t('Loading…', 'लोड…');
  String get error => t('Error', 'त्रुटि');

  String categoryLabel(String key) => switch (key) {
        'vegetables' => sectionVegetables,
        'fruits' => sectionFruits,
        'dairy' => sectionDairy,
        _ => t('Other', 'अन्य'),
      };

  String allCategoryTitle(String key) => switch (key) {
        'vegetables' => t('Vegetables', 'तरकारी'),
        'fruits' => t('Fruits', 'फलफूल'),
        'dairy' => t('Dairy', 'दुधजन्य'),
        _ => t('Products', 'उत्पादन'),
      };
}
