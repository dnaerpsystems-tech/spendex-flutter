// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Spendex';

  @override
  String get appTagline => 'स्मार्ट धन प्रबंधन';

  @override
  String welcomeMessage(String name) {
    return 'स्वागत है, $name!';
  }

  @override
  String get goodMorning => 'सुप्रभात';

  @override
  String get goodAfternoon => 'नमस्ते';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get save => 'सहेजें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get done => 'हो गया';

  @override
  String get next => 'आगे';

  @override
  String get back => 'वापस';

  @override
  String get skip => 'छोड़ें';

  @override
  String get close => 'बंद करें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get dismiss => 'खारिज करें';

  @override
  String get add => 'जोड़ें';

  @override
  String get update => 'अपडेट करें';

  @override
  String get remove => 'हटाएं';

  @override
  String get view => 'देखें';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get seeMore => 'और देखें';

  @override
  String get seeLess => 'कम देखें';

  @override
  String get search => 'खोजें';

  @override
  String get filter => 'फ़िल्टर';

  @override
  String get sort => 'क्रमबद्ध करें';

  @override
  String get clear => 'साफ़ करें';

  @override
  String get clearAll => 'सभी साफ़ करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get reset => 'रीसेट करें';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get ok => 'ठीक है';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get pleaseWait => 'कृपया प्रतीक्षा करें...';

  @override
  String get processing => 'प्रोसेस हो रहा है...';

  @override
  String get success => 'सफल';

  @override
  String get error => 'त्रुटि';

  @override
  String get warning => 'चेतावनी';

  @override
  String get info => 'जानकारी';

  @override
  String get noData => 'कोई डेटा उपलब्ध नहीं है';

  @override
  String get noResults => 'कोई परिणाम नहीं मिला';

  @override
  String get emptyList => 'यहाँ अभी कुछ नहीं है';

  @override
  String get somethingWentWrong => 'कुछ गलत हो गया';

  @override
  String get tryAgain => 'पुनः प्रयास करें';

  @override
  String get networkError => 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।';

  @override
  String get serverError => 'सर्वर त्रुटि। कृपया बाद में पुनः प्रयास करें।';

  @override
  String get sessionExpired => 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।';

  @override
  String get unauthorized => 'आप इस कार्य को करने के लिए अधिकृत नहीं हैं।';

  @override
  String get today => 'आज';

  @override
  String get yesterday => 'कल';

  @override
  String get tomorrow => 'कल';

  @override
  String get thisWeek => 'इस सप्ताह';

  @override
  String get lastWeek => 'पिछले सप्ताह';

  @override
  String get thisMonth => 'इस महीने';

  @override
  String get lastMonth => 'पिछले महीने';

  @override
  String get thisYear => 'इस वर्ष';

  @override
  String get lastYear => 'पिछले वर्ष';

  @override
  String get custom => 'कस्टम';

  @override
  String get daily => 'दैनिक';

  @override
  String get weekly => 'साप्ताहिक';

  @override
  String get monthly => 'मासिक';

  @override
  String get yearly => 'वार्षिक';

  @override
  String get all => 'सभी';

  @override
  String get none => 'कोई नहीं';

  @override
  String get required => 'यह फ़ील्ड आवश्यक है';

  @override
  String get invalidEmail => 'कृपया एक वैध ईमेल पता दर्ज करें';

  @override
  String get invalidPhone => 'कृपया एक वैध फ़ोन नंबर दर्ज करें';

  @override
  String get invalidAmount => 'कृपया एक वैध राशि दर्ज करें';

  @override
  String get tooShort => 'बहुत छोटा';

  @override
  String get tooLong => 'बहुत लंबा';

  @override
  String minLength(int count) {
    return 'न्यूनतम $count अक्षर आवश्यक हैं';
  }

  @override
  String maxLength(int count) {
    return 'अधिकतम $count अक्षर अनुमत हैं';
  }

  @override
  String amountFormatted(String amount) {
    return '₹$amount';
  }

  @override
  String get login => 'लॉगिन';

  @override
  String get loginTitle => 'वापस स्वागत है';

  @override
  String get loginSubtitle => 'अपने वित्त को प्रबंधित करने के लिए साइन इन करें';

  @override
  String get email => 'ईमेल';

  @override
  String get emailHint => 'अपना ईमेल पता दर्ज करें';

  @override
  String get password => 'पासवर्ड';

  @override
  String get passwordHint => 'अपना पासवर्ड दर्ज करें';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get confirmPasswordHint => 'अपना पासवर्ड पुनः दर्ज करें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get rememberMe => 'मुझे याद रखें';

  @override
  String get orContinueWith => 'या इसके साथ जारी रखें';

  @override
  String get signInWithGoogle => 'Google से साइन इन करें';

  @override
  String get signInWithApple => 'Apple से साइन इन करें';

  @override
  String get dontHaveAccount => 'खाता नहीं है?';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get registerTitle => 'खाता बनाएं';

  @override
  String get registerSubtitle =>
      'वित्तीय स्वतंत्रता की ओर अपनी यात्रा शुरू करें';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get fullNameHint => 'अपना पूरा नाम दर्ज करें';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get phoneNumberHint => 'अपना फ़ोन नंबर दर्ज करें';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है?';

  @override
  String get agreeToTerms => 'मैं सेवा की शर्तों और गोपनीयता नीति से सहमत हूं';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get verifyEmail => 'ईमेल सत्यापित करें';

  @override
  String get verifyPhone => 'फ़ोन सत्यापित करें';

  @override
  String get otpVerification => 'OTP सत्यापन';

  @override
  String otpSentTo(String destination) {
    return 'हमने $destination पर सत्यापन कोड भेजा है';
  }

  @override
  String get enterOtp => 'OTP दर्ज करें';

  @override
  String get resendOtp => 'OTP पुनः भेजें';

  @override
  String resendOtpIn(int seconds) {
    return '$seconds सेकंड में OTP पुनः भेजें';
  }

  @override
  String get verify => 'सत्यापित करें';

  @override
  String get invalidOtp => 'अमान्य OTP। कृपया पुनः प्रयास करें।';

  @override
  String get otpExpired => 'OTP समाप्त हो गया है। कृपया नया अनुरोध करें।';

  @override
  String get resetPassword => 'पासवर्ड रीसेट करें';

  @override
  String get resetPasswordSubtitle =>
      'रीसेट निर्देश प्राप्त करने के लिए अपना ईमेल दर्ज करें';

  @override
  String get sendResetLink => 'रीसेट लिंक भेजें';

  @override
  String get resetLinkSent => 'पासवर्ड रीसेट लिंक आपके ईमेल पर भेजा गया';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get createNewPassword => 'नया पासवर्ड बनाएं';

  @override
  String get passwordRequirements => 'पासवर्ड में होना चाहिए:';

  @override
  String get passwordMinLength => 'कम से कम 8 अक्षर';

  @override
  String get passwordUppercase => 'एक बड़ा अक्षर';

  @override
  String get passwordLowercase => 'एक छोटा अक्षर';

  @override
  String get passwordNumber => 'एक संख्या';

  @override
  String get passwordSpecial => 'एक विशेष वर्ण';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String get passwordChanged => 'पासवर्ड सफलतापूर्वक बदला गया';

  @override
  String get loginFailed => 'लॉगिन विफल। कृपया अपने क्रेडेंशियल जांचें।';

  @override
  String get registrationFailed => 'पंजीकरण विफल। कृपया पुनः प्रयास करें।';

  @override
  String get accountCreated => 'खाता सफलतापूर्वक बनाया गया';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logoutConfirmation => 'क्या आप वाकई लॉगआउट करना चाहते हैं?';

  @override
  String get biometricLogin => 'बायोमेट्रिक से लॉगिन करें';

  @override
  String get useFaceId => 'Face ID का उपयोग करें';

  @override
  String get useFingerprint => 'फ़िंगरप्रिंट का उपयोग करें';

  @override
  String get biometricNotAvailable => 'बायोमेट्रिक प्रमाणीकरण उपलब्ध नहीं है';

  @override
  String get dashboard => 'डैशबोर्ड';

  @override
  String get totalBalance => 'कुल शेष';

  @override
  String get income => 'आय';

  @override
  String get expense => 'व्यय';

  @override
  String get expenses => 'व्यय';

  @override
  String get balance => 'शेष';

  @override
  String get availableBalance => 'उपलब्ध शेष';

  @override
  String get currentBalance => 'वर्तमान शेष';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get spendingOverview => 'खर्च का अवलोकन';

  @override
  String get incomeVsExpense => 'आय बनाम व्यय';

  @override
  String get monthlyOverview => 'मासिक अवलोकन';

  @override
  String get financialSummary => 'वित्तीय सारांश';

  @override
  String get cashFlow => 'नकद प्रवाह';

  @override
  String get netWorth => 'कुल संपत्ति';

  @override
  String get savings => 'बचत';

  @override
  String get savingsRate => 'बचत दर';

  @override
  String youSaved(String percentage) {
    return 'आपने इस महीने $percentage% बचाया';
  }

  @override
  String get transactions => 'लेन-देन';

  @override
  String get transaction => 'लेन-देन';

  @override
  String transactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लेन-देन',
      one: '1 लेन-देन',
      zero: 'कोई लेन-देन नहीं',
    );
    return '$_temp0';
  }

  @override
  String get addTransaction => 'लेन-देन जोड़ें';

  @override
  String get editTransaction => 'लेन-देन संपादित करें';

  @override
  String get deleteTransaction => 'लेन-देन हटाएं';

  @override
  String get deleteTransactionConfirmation =>
      'क्या आप वाकई इस लेन-देन को हटाना चाहते हैं?';

  @override
  String get transactionDeleted => 'लेन-देन सफलतापूर्वक हटाया गया';

  @override
  String get transactionSaved => 'लेन-देन सफलतापूर्वक सहेजा गया';

  @override
  String get amount => 'राशि';

  @override
  String get amountHint => 'राशि दर्ज करें';

  @override
  String get category => 'श्रेणी';

  @override
  String get selectCategory => 'श्रेणी चुनें';

  @override
  String get date => 'तारीख';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get time => 'समय';

  @override
  String get selectTime => 'समय चुनें';

  @override
  String get note => 'नोट';

  @override
  String get noteHint => 'नोट जोड़ें (वैकल्पिक)';

  @override
  String get description => 'विवरण';

  @override
  String get descriptionHint => 'विवरण दर्ज करें';

  @override
  String get attachReceipt => 'रसीद संलग्न करें';

  @override
  String get receipt => 'रसीद';

  @override
  String get scanReceipt => 'रसीद स्कैन करें';

  @override
  String get recurring => 'आवर्ती';

  @override
  String get recurringTransaction => 'आवर्ती लेन-देन';

  @override
  String get frequency => 'आवृत्ति';

  @override
  String get startDate => 'आरंभ तिथि';

  @override
  String get endDate => 'समाप्ति तिथि';

  @override
  String get noEndDate => 'कोई समाप्ति तिथि नहीं';

  @override
  String get transfer => 'ट्रांसफर';

  @override
  String get fromAccount => 'खाते से';

  @override
  String get toAccount => 'खाते में';

  @override
  String get transferFunds => 'धन ट्रांसफर करें';

  @override
  String get transferSuccessful => 'ट्रांसफर सफलतापूर्वक पूरा हुआ';

  @override
  String get searchTransactions => 'लेन-देन खोजें...';

  @override
  String get filterByCategory => 'श्रेणी के अनुसार फ़िल्टर करें';

  @override
  String get filterByAccount => 'खाते के अनुसार फ़िल्टर करें';

  @override
  String get filterByDate => 'तारीख के अनुसार फ़िल्टर करें';

  @override
  String get sortByDate => 'तारीख के अनुसार क्रमबद्ध करें';

  @override
  String get sortByAmount => 'राशि के अनुसार क्रमबद्ध करें';

  @override
  String get ascending => 'आरोही';

  @override
  String get descending => 'अवरोही';

  @override
  String get accounts => 'खाते';

  @override
  String get account => 'खाता';

  @override
  String get addAccount => 'खाता जोड़ें';

  @override
  String get editAccount => 'खाता संपादित करें';

  @override
  String get deleteAccount => 'खाता हटाएं';

  @override
  String get deleteAccountConfirmation =>
      'क्या आप वाकई अपना खाता हटाना चाहते हैं? आपका सारा डेटा स्थायी रूप से हटा दिया जाएगा।';

  @override
  String get accountDeleted => 'खाता सफलतापूर्वक हटाया गया';

  @override
  String get accountSaved => 'खाता सफलतापूर्वक सहेजा गया';

  @override
  String get accountName => 'खाते का नाम';

  @override
  String get accountNameHint => 'खाते का नाम दर्ज करें';

  @override
  String get accountType => 'खाते का प्रकार';

  @override
  String get selectAccountType => 'खाते का प्रकार चुनें';

  @override
  String get initialBalance => 'प्रारंभिक शेष';

  @override
  String get initialBalanceHint => 'प्रारंभिक शेष दर्ज करें';

  @override
  String get cash => 'नकद';

  @override
  String get bankAccount => 'बैंक खाता';

  @override
  String get savingsAccount => 'बचत खाता';

  @override
  String get creditCard => 'क्रेडिट कार्ड';

  @override
  String get debitCard => 'डेबिट कार्ड';

  @override
  String get wallet => 'वॉलेट';

  @override
  String get investment => 'निवेश';

  @override
  String get loan => 'ऋण';

  @override
  String get other => 'अन्य';

  @override
  String get currency => 'मुद्रा';

  @override
  String get inr => 'भारतीय रुपया (₹)';

  @override
  String get usd => 'अमेरिकी डॉलर (\$)';

  @override
  String get includeInTotal => 'कुल शेष में शामिल करें';

  @override
  String get makeDefault => 'डिफ़ॉल्ट खाता बनाएं';

  @override
  String get defaultAccount => 'डिफ़ॉल्ट खाता';

  @override
  String get budgets => 'बजट';

  @override
  String get budget => 'बजट';

  @override
  String get addBudget => 'बजट जोड़ें';

  @override
  String get editBudget => 'बजट संपादित करें';

  @override
  String get deleteBudget => 'बजट हटाएं';

  @override
  String get deleteBudgetConfirmation =>
      'क्या आप वाकई इस बजट को हटाना चाहते हैं?';

  @override
  String get budgetDeleted => 'बजट सफलतापूर्वक हटाया गया';

  @override
  String get budgetSaved => 'बजट सफलतापूर्वक सहेजा गया';

  @override
  String get budgetName => 'बजट का नाम';

  @override
  String get budgetAmount => 'बजट राशि';

  @override
  String get budgetPeriod => 'बजट अवधि';

  @override
  String get spent => 'खर्च किया';

  @override
  String get remaining => 'शेष';

  @override
  String budgetProgress(String spent, String total) {
    return '$total में से $spent खर्च';
  }

  @override
  String budgetRemaining(String amount) {
    return '$amount शेष';
  }

  @override
  String get budgetExceeded => 'बजट पार हो गया';

  @override
  String get overBudget => 'बजट से अधिक';

  @override
  String get underBudget => 'बजट के भीतर';

  @override
  String get onTrack => 'सही रास्ते पर';

  @override
  String budgetAlert(String percentage, String category) {
    return 'आपने अपने $category बजट का $percentage% खर्च किया है';
  }

  @override
  String get noBudgets => 'अभी तक कोई बजट सेट नहीं है';

  @override
  String get createFirstBudget =>
      'खर्च को ट्रैक करने के लिए अपना पहला बजट बनाएं';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get manageCategories => 'श्रेणियां प्रबंधित करें';

  @override
  String get addCategory => 'श्रेणी जोड़ें';

  @override
  String get editCategory => 'श्रेणी संपादित करें';

  @override
  String get deleteCategory => 'श्रेणी हटाएं';

  @override
  String get deleteCategoryConfirmation =>
      'क्या आप वाकई इस श्रेणी को हटाना चाहते हैं?';

  @override
  String get categoryDeleted => 'श्रेणी सफलतापूर्वक हटाई गई';

  @override
  String get categorySaved => 'श्रेणी सफलतापूर्वक सहेजी गई';

  @override
  String get categoryName => 'श्रेणी का नाम';

  @override
  String get categoryNameHint => 'श्रेणी का नाम दर्ज करें';

  @override
  String get categoryIcon => 'श्रेणी आइकन';

  @override
  String get categoryColor => 'श्रेणी का रंग';

  @override
  String get incomeCategories => 'आय श्रेणियां';

  @override
  String get expenseCategories => 'व्यय श्रेणियां';

  @override
  String get salary => 'वेतन';

  @override
  String get business => 'व्यापार';

  @override
  String get freelance => 'फ्रीलांस';

  @override
  String get investments => 'निवेश';

  @override
  String get rental => 'किराया आय';

  @override
  String get gifts => 'उपहार';

  @override
  String get refunds => 'रिफंड';

  @override
  String get food => 'भोजन और खान-पान';

  @override
  String get groceries => 'किराना';

  @override
  String get shopping => 'खरीदारी';

  @override
  String get transportation => 'परिवहन';

  @override
  String get utilities => 'उपयोगिताएं';

  @override
  String get entertainment => 'मनोरंजन';

  @override
  String get healthcare => 'स्वास्थ्य देखभाल';

  @override
  String get education => 'शिक्षा';

  @override
  String get personalCare => 'व्यक्तिगत देखभाल';

  @override
  String get travel => 'यात्रा';

  @override
  String get bills => 'बिल और शुल्क';

  @override
  String get insurance => 'बीमा';

  @override
  String get taxes => 'कर';

  @override
  String get subscriptions => 'सब्सक्रिप्शन';

  @override
  String get rent => 'किराया';

  @override
  String get goals => 'लक्ष्य';

  @override
  String get savingsGoals => 'बचत लक्ष्य';

  @override
  String get addGoal => 'लक्ष्य जोड़ें';

  @override
  String get editGoal => 'लक्ष्य संपादित करें';

  @override
  String get deleteGoal => 'लक्ष्य हटाएं';

  @override
  String get deleteGoalConfirmation =>
      'क्या आप वाकई इस लक्ष्य को हटाना चाहते हैं?';

  @override
  String get goalDeleted => 'लक्ष्य सफलतापूर्वक हटाया गया';

  @override
  String get goalSaved => 'लक्ष्य सफलतापूर्वक सहेजा गया';

  @override
  String get goalName => 'लक्ष्य का नाम';

  @override
  String get goalNameHint => 'आप किसलिए बचत कर रहे हैं?';

  @override
  String get targetAmount => 'लक्ष्य राशि';

  @override
  String get currentAmount => 'वर्तमान राशि';

  @override
  String get targetDate => 'लक्ष्य तिथि';

  @override
  String goalProgress(String percentage) {
    return '$percentage% पूर्ण';
  }

  @override
  String get addMoney => 'धन जोड़ें';

  @override
  String get withdrawMoney => 'धन निकालें';

  @override
  String get goalAchieved => 'लक्ष्य प्राप्त! 🎉';

  @override
  String daysRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन शेष',
      one: '1 दिन शेष',
      zero: 'आज देय',
    );
    return '$_temp0';
  }

  @override
  String monthlyContribution(String amount) {
    return 'सुझाया गया मासिक: $amount';
  }

  @override
  String get noGoals => 'अभी तक कोई बचत लक्ष्य नहीं';

  @override
  String get createFirstGoal => 'अपना पहला बचत लक्ष्य सेट करें';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get reports => 'रिपोर्ट';

  @override
  String get insights => 'अंतर्दृष्टि';

  @override
  String get spendingByCategory => 'श्रेणी के अनुसार खर्च';

  @override
  String get incomeByCategory => 'श्रेणी के अनुसार आय';

  @override
  String get trendAnalysis => 'रुझान विश्लेषण';

  @override
  String get expenseTrend => 'व्यय रुझान';

  @override
  String get incomeTrend => 'आय रुझान';

  @override
  String get comparison => 'तुलना';

  @override
  String get vsLastMonth => 'पिछले महीने की तुलना में';

  @override
  String get vsLastYear => 'पिछले वर्ष की तुलना में';

  @override
  String get averageSpending => 'औसत खर्च';

  @override
  String get averageIncome => 'औसत आय';

  @override
  String get highestSpending => 'सबसे अधिक खर्च';

  @override
  String get lowestSpending => 'सबसे कम खर्च';

  @override
  String get topCategories => 'शीर्ष श्रेणियां';

  @override
  String get exportReport => 'रिपोर्ट निर्यात करें';

  @override
  String get exportToPdf => 'PDF में निर्यात करें';

  @override
  String get exportToExcel => 'Excel में निर्यात करें';

  @override
  String get exportToCsv => 'CSV में निर्यात करें';

  @override
  String get exportSuccessful => 'रिपोर्ट सफलतापूर्वक निर्यात की गई';

  @override
  String get selectDateRange => 'तारीख सीमा चुनें';

  @override
  String get from => 'से';

  @override
  String get to => 'तक';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileUpdated => 'प्रोफ़ाइल सफलतापूर्वक अपडेट की गई';

  @override
  String get changePhoto => 'फ़ोटो बदलें';

  @override
  String get removePhoto => 'फ़ोटो हटाएं';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get personalInfo => 'व्यक्तिगत जानकारी';

  @override
  String get securitySettings => 'सुरक्षा सेटिंग्स';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get currentPassword => 'वर्तमान पासवर्ड';

  @override
  String get enableBiometric => 'बायोमेट्रिक लॉगिन सक्षम करें';

  @override
  String get enablePinLock => 'PIN लॉक सक्षम करें';

  @override
  String get setPin => 'PIN सेट करें';

  @override
  String get changePin => 'PIN बदलें';

  @override
  String get enterPin => 'PIN दर्ज करें';

  @override
  String get confirmPin => 'PIN की पुष्टि करें';

  @override
  String get pinChanged => 'PIN सफलतापूर्वक बदला गया';

  @override
  String get invalidPin => 'अमान्य PIN';

  @override
  String get autoLock => 'स्वतः लॉक';

  @override
  String get autoLockAfter => 'इसके बाद स्वतः लॉक';

  @override
  String get immediately => 'तुरंत';

  @override
  String get after1Minute => '1 मिनट बाद';

  @override
  String get after5Minutes => '5 मिनट बाद';

  @override
  String get after15Minutes => '15 मिनट बाद';

  @override
  String get never => 'कभी नहीं';

  @override
  String get appearance => 'दिखावट';

  @override
  String get theme => 'थीम';

  @override
  String get lightTheme => 'लाइट';

  @override
  String get darkTheme => 'डार्क';

  @override
  String get systemTheme => 'सिस्टम';

  @override
  String get language => 'भाषा';

  @override
  String get selectLanguage => 'भाषा चुनें';

  @override
  String get english => 'English';

  @override
  String get hindi => 'हिंदी';

  @override
  String get languageChanged => 'भाषा सफलतापूर्वक बदली गई';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get notificationSettings => 'सूचना सेटिंग्स';

  @override
  String get pushNotifications => 'पुश सूचनाएं';

  @override
  String get emailNotifications => 'ईमेल सूचनाएं';

  @override
  String get transactionAlerts => 'लेन-देन अलर्ट';

  @override
  String get budgetAlerts => 'बजट अलर्ट';

  @override
  String get goalReminders => 'लक्ष्य रिमाइंडर';

  @override
  String get billReminders => 'बिल रिमाइंडर';

  @override
  String get weeklyReport => 'साप्ताहिक रिपोर्ट';

  @override
  String get monthlyReport => 'मासिक रिपोर्ट';

  @override
  String get dataAndBackup => 'डेटा और बैकअप';

  @override
  String get backupData => 'डेटा बैकअप करें';

  @override
  String get restoreData => 'डेटा पुनर्स्थापित करें';

  @override
  String lastBackup(String date) {
    return 'अंतिम बैकअप: $date';
  }

  @override
  String get backupSuccessful => 'बैकअप सफलतापूर्वक बनाया गया';

  @override
  String get restoreSuccessful => 'डेटा सफलतापूर्वक पुनर्स्थापित किया गया';

  @override
  String get exportData => 'डेटा निर्यात करें';

  @override
  String get importData => 'डेटा आयात करें';

  @override
  String get deleteAllData => 'सभी डेटा हटाएं';

  @override
  String get deleteAllDataConfirmation =>
      'यह आपके सभी डेटा को स्थायी रूप से हटा देगा। यह कार्रवाई पूर्ववत नहीं की जा सकती।';

  @override
  String get dataDeleted => 'सभी डेटा हटा दिया गया है';

  @override
  String get helpAndSupport => 'मदद और सहायता';

  @override
  String get faq => 'अक्सर पूछे जाने वाले प्रश्न';

  @override
  String get contactSupport => 'सहायता से संपर्क करें';

  @override
  String get sendFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get rateApp => 'ऐप को रेट करें';

  @override
  String get shareApp => 'ऐप शेयर करें';

  @override
  String get aboutApp => 'बारे में';

  @override
  String version(String version) {
    return 'संस्करण $version';
  }

  @override
  String get licenses => 'ओपन सोर्स लाइसेंस';

  @override
  String get accountDeleted2 => 'खाता सफलतापूर्वक हटाया गया';

  @override
  String get subscription => 'सब्सक्रिप्शन';

  @override
  String get currentPlan => 'वर्तमान प्लान';

  @override
  String get freePlan => 'मुफ्त प्लान';

  @override
  String get basicPlan => 'बेसिक प्लान';

  @override
  String get premiumPlan => 'प्रीमियम प्लान';

  @override
  String get familyPlan => 'फैमिली प्लान';

  @override
  String get upgradePlan => 'प्लान अपग्रेड करें';

  @override
  String get choosePlan => 'प्लान चुनें';

  @override
  String get planFeatures => 'प्लान की विशेषताएं';

  @override
  String get perMonth => '/माह';

  @override
  String get perYear => '/वर्ष';

  @override
  String get billedMonthly => 'मासिक बिलिंग';

  @override
  String get billedYearly => 'वार्षिक बिलिंग';

  @override
  String savePercent(String percent) {
    return '$percent% बचाएं';
  }

  @override
  String get subscribe => 'सब्सक्राइब करें';

  @override
  String get subscriptionActive => 'सब्सक्रिप्शन सक्रिय';

  @override
  String subscriptionExpires(String date) {
    return '$date को समाप्त होगा';
  }

  @override
  String get cancelSubscription => 'सब्सक्रिप्शन रद्द करें';

  @override
  String get cancelSubscriptionConfirmation =>
      'क्या आप वाकई अपना सब्सक्रिप्शन रद्द करना चाहते हैं?';

  @override
  String get subscriptionCancelled => 'सब्सक्रिप्शन रद्द किया गया';

  @override
  String get renewSubscription => 'सब्सक्रिप्शन नवीनीकरण करें';

  @override
  String get paymentMethod => 'भुगतान विधि';

  @override
  String get addPaymentMethod => 'भुगतान विधि जोड़ें';

  @override
  String get paymentSuccessful => 'भुगतान सफल';

  @override
  String get paymentFailed => 'भुगतान विफल। कृपया पुनः प्रयास करें।';

  @override
  String get invoiceHistory => 'चालान इतिहास';

  @override
  String get downloadInvoice => 'चालान डाउनलोड करें';

  @override
  String get unlimitedTransactions => 'असीमित लेन-देन';

  @override
  String get unlimitedAccounts => 'असीमित खाते';

  @override
  String get unlimitedBudgets => 'असीमित बजट';

  @override
  String get advancedAnalytics => 'उन्नत विश्लेषण';

  @override
  String get prioritySupport => 'प्राथमिकता सहायता';

  @override
  String get cloudBackup => 'क्लाउड बैकअप';

  @override
  String get multiDeviceSync => 'मल्टी-डिवाइस सिंक';

  @override
  String get adFree => 'विज्ञापन-मुक्त अनुभव';

  @override
  String get family => 'परिवार';

  @override
  String get familyMembers => 'परिवार के सदस्य';

  @override
  String get inviteMember => 'सदस्य आमंत्रित करें';

  @override
  String get inviteByEmail => 'ईमेल द्वारा आमंत्रित करें';

  @override
  String get inviteByLink => 'लिंक द्वारा आमंत्रित करें';

  @override
  String get copyInviteLink => 'आमंत्रण लिंक कॉपी करें';

  @override
  String get linkCopied => 'लिंक क्लिपबोर्ड में कॉपी किया गया';

  @override
  String get invitationSent => 'आमंत्रण सफलतापूर्वक भेजा गया';

  @override
  String get pendingInvitations => 'लंबित आमंत्रण';

  @override
  String get memberRole => 'सदस्य की भूमिका';

  @override
  String get owner => 'मालिक';

  @override
  String get admin => 'प्रशासक';

  @override
  String get member => 'सदस्य';

  @override
  String get viewer => 'दर्शक';

  @override
  String get removeMember => 'सदस्य हटाएं';

  @override
  String get removeMemberConfirmation =>
      'क्या आप वाकई इस सदस्य को हटाना चाहते हैं?';

  @override
  String get memberRemoved => 'सदस्य सफलतापूर्वक हटाया गया';

  @override
  String get leaveFamily => 'परिवार छोड़ें';

  @override
  String get leaveFamilyConfirmation =>
      'क्या आप वाकई इस परिवार को छोड़ना चाहते हैं?';

  @override
  String get familyActivity => 'परिवार की गतिविधि';

  @override
  String get sharedExpenses => 'साझा खर्च';

  @override
  String get familyBudget => 'पारिवारिक बजट';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offlineMode => 'ऑफलाइन मोड';

  @override
  String get youAreOffline => 'आप वर्तमान में ऑफलाइन हैं';

  @override
  String get offlineChanges => 'ऑनलाइन होने पर परिवर्तन सिंक होंगे';

  @override
  String get syncNow => 'अभी सिंक करें';

  @override
  String get syncing => 'सिंक हो रहा है...';

  @override
  String get syncComplete => 'सिंक पूर्ण';

  @override
  String get syncFailed => 'सिंक विफल। कृपया पुनः प्रयास करें।';

  @override
  String lastSynced(String time) {
    return 'अंतिम सिंक: $time';
  }

  @override
  String pendingChanges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count लंबित परिवर्तन',
      one: '1 लंबित परिवर्तन',
    );
    return '$_temp0';
  }

  @override
  String get conflictDetected => 'विरोध पाया गया';

  @override
  String get keepLocal => 'स्थानीय संस्करण रखें';

  @override
  String get keepServer => 'सर्वर संस्करण रखें';

  @override
  String get mergeBoth => 'दोनों मिलाएं';

  @override
  String get bankImport => 'बैंक आयात';

  @override
  String get importFromBank => 'बैंक से आयात करें';

  @override
  String get importFromSms => 'SMS से आयात करें';

  @override
  String get importFromEmail => 'ईमेल से आयात करें';

  @override
  String get importSuccessful => 'आयात सफल';

  @override
  String transactionsImported(int count) {
    return '$count लेन-देन आयात किए गए';
  }

  @override
  String get duplicateDetected => 'डुप्लिकेट पाया गया';

  @override
  String get possibleDuplicate => 'यह लेन-देन डुप्लिकेट हो सकता है';

  @override
  String get keepBoth => 'दोनों रखें';

  @override
  String get skipDuplicate => 'डुप्लिकेट छोड़ें';

  @override
  String get loans => 'ऋण';

  @override
  String get addLoan => 'ऋण जोड़ें';

  @override
  String get loanDetails => 'ऋण विवरण';

  @override
  String get loanAmount => 'ऋण राशि';

  @override
  String get interestRate => 'ब्याज दर';

  @override
  String get emi => 'EMI';

  @override
  String get tenure => 'अवधि';

  @override
  String get remainingAmount => 'शेष राशि';

  @override
  String get paidAmount => 'चुकाई गई राशि';

  @override
  String get nextPayment => 'अगला भुगतान';

  @override
  String get paymentSchedule => 'भुगतान अनुसूची';

  @override
  String get voiceInput => 'वॉइस इनपुट';

  @override
  String get speakNow => 'अभी बोलें...';

  @override
  String get listeningFailed => 'समझ नहीं आया। कृपया पुनः प्रयास करें।';

  @override
  String get permissionRequired => 'अनुमति आवश्यक';

  @override
  String get cameraPermission =>
      'रसीद स्कैन करने के लिए कैमरा अनुमति आवश्यक है';

  @override
  String get microphonePermission =>
      'वॉइस इनपुट के लिए माइक्रोफ़ोन अनुमति आवश्यक है';

  @override
  String get storagePermission =>
      'फ़ाइलें सहेजने के लिए स्टोरेज अनुमति आवश्यक है';

  @override
  String get openSettings => 'सेटिंग्स खोलें';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get onboardingTitle1 => 'अपने खर्चों को ट्रैक करें';

  @override
  String get onboardingDesc1 =>
      'एक ही जगह पर अपनी सभी आय और खर्चों को आसानी से ट्रैक करें';

  @override
  String get onboardingTitle2 => 'बजट और लक्ष्य सेट करें';

  @override
  String get onboardingDesc2 =>
      'वित्तीय स्वतंत्रता प्राप्त करने के लिए बजट और बचत लक्ष्य बनाएं';

  @override
  String get onboardingTitle3 => 'अंतर्दृष्टि प्राप्त करें';

  @override
  String get onboardingDesc3 =>
      'विस्तृत विश्लेषण के साथ अपने खर्च पैटर्न को समझें';

  @override
  String get congratulations => 'बधाई हो!';

  @override
  String get setupComplete => 'आपका सेटअप पूरा हो गया है';

  @override
  String get startTracking => 'ट्रैकिंग शुरू करें';
}
