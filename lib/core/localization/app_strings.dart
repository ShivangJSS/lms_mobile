/// Translations for the fixed labels in the app.
///
/// Content (module names, topics, questions) is already translated by the
/// API through language_id. This covers only the text baked into the UI, so
/// that switching language changes the whole screen rather than half of it.
///
/// Keyed by language_master.language_id: 1 English, 2 Hindi, 3 Bangla,
/// 4 Tamil. Missing keys fall back to English.
class AppStrings {
  AppStrings._();

  static const int _fallback = 1;

  static const Map<String, Map<int, String>> _values = {
    'dashboard': {
      1: 'Dashboard',
      2: 'डैशबोर्ड',
      3: 'ড্যাশবোর্ড',
      4: 'டாஷ்போர்டு',
    },
    'welcome': {
      1: 'Welcome',
      2: 'स्वागत है',
      3: 'স্বাগতম',
      4: 'வரவேற்கிறோம்',
    },
    'welcome_subtitle': {
      1: 'Continue your journey to becoming a confident driver',
      2: 'एक आत्मविश्वासी ड्राइवर बनने की अपनी यात्रा जारी रखें',
      3: 'আত্মবিশ্বাসী চালক হওয়ার যাত্রা চালিয়ে যান',
      4: 'நம்பிக்கையான ஓட்டுநராகும் பயணத்தைத் தொடருங்கள்',
    },
    'modules_completed': {
      1: 'Module\nCompleted',
      2: 'पूर्ण\nमॉड्यूल',
      3: 'সম্পন্ন\nমডিউল',
      4: 'நிறைவு\nதொகுதி',
    },
    'average_score': {
      1: 'Average\nScore',
      2: 'औसत\nस्कोर',
      3: 'গড়\nস্কোর',
      4: 'சராசரி\nமதிப்பெண்',
    },
    'time_invested': {
      1: 'Time\nInvested',
      2: 'लगाया गया\nसमय',
      3: 'ব্যয়িত\nসময়',
      4: 'செலவழித்த\nநேரம்',
    },
    'keep_going': {
      1: 'Keep up the great work!',
      2: 'बहुत बढ़िया काम जारी रखें!',
      3: 'দুর্দান্ত কাজ চালিয়ে যান!',
      4: 'சிறப்பான பணியைத் தொடருங்கள்!',
    },
    'start_journey': {
      1: 'Start Your Learning Journey',
      2: 'अपनी सीखने की यात्रा शुरू करें',
      3: 'আপনার শেখার যাত্রা শুরু করুন',
      4: 'உங்கள் கற்றல் பயணத்தைத் தொடங்குங்கள்',
    },
    'view_all_modules': {
      1: 'View All Modules',
      2: 'सभी मॉड्यूल देखें',
      3: 'সব মডিউল দেখুন',
      4: 'அனைத்து தொகுதிகளையும் காண்க',
    },
    'unlock_note': {
      1: 'Note: The topic will be unlocked once previous training completed.',
      2: 'नोट: पिछला प्रशिक्षण पूरा होने पर अगला विषय खुलेगा।',
      3: 'দ্রষ্টব্য: পূর্ববর্তী প্রশিক্ষণ শেষ হলে পরবর্তী বিষয় খুলবে।',
      4: 'குறிப்பு: முந்தைய பயிற்சி முடிந்ததும் அடுத்த தலைப்பு திறக்கும்.',
    },
    'did_you_know': {
      1: 'Did You Know?',
      2: 'क्या आप जानते हैं?',
      3: 'আপনি কি জানেন?',
      4: 'உங்களுக்குத் தெரியுமா?',
    },
    'module_list': {
      1: 'Module List',
      2: 'मॉड्यूल सूची',
      3: 'মডিউল তালিকা',
      4: 'தொகுதி பட்டியல்',
    },
    'view_profile': {
      1: 'View Profile',
      2: 'प्रोफ़ाइल देखें',
      3: 'প্রোফাইল দেখুন',
      4: 'சுயவிவரம் காண்க',
    },
    'change_language': {
      1: 'Change Language',
      2: 'भाषा बदलें',
      3: 'ভাষা পরিবর্তন করুন',
      4: 'மொழியை மாற்று',
    },
    'feedback': {
      1: 'Feedback',
      2: 'प्रतिक्रिया',
      3: 'মতামত',
      4: 'கருத்து',
    },
    'logout': {
      1: 'Logout',
      2: 'लॉग आउट',
      3: 'লগ আউট',
      4: 'வெளியேறு',
    },
    'duration': {
      1: 'Duration',
      2: 'अवधि',
      3: 'সময়কাল',
      4: 'கால அளவு',
    },
    'retry': {
      1: 'Retry',
      2: 'पुनः प्रयास करें',
      3: 'আবার চেষ্টা করুন',
      4: 'மீண்டும் முயற்சி',
    },
    'submit': {
      1: 'Submit',
      2: 'जमा करें',
      3: 'জমা দিন',
      4: 'சமர்ப்பி',
    },
    'start_assessment': {
      1: 'Start Assessment',
      2: 'मूल्यांकन शुरू करें',
      3: 'মূল্যায়ন শুরু করুন',
      4: 'மதிப்பீட்டைத் தொடங்கு',
    },
    'assessment': {
      1: 'Assessment',
      2: 'मूल्यांकन',
      3: 'মূল্যায়ন',
      4: 'மதிப்பீடு',
    },
    'module_completed_msg': {
      1: 'Module completed!',
      2: 'मॉड्यूल पूरा हुआ!',
      3: 'মডিউল সম্পন্ন হয়েছে!',
      4: 'தொகுதி நிறைவடைந்தது!',
    },
    'try_again_msg': {
      1: 'Not quite yet — review the content and try again.',
      2: 'अभी नहीं — सामग्री दोबारा देखें और फिर प्रयास करें।',
      3: 'এখনও নয় — বিষয়বস্তু দেখে আবার চেষ্টা করুন।',
      4: 'இன்னும் இல்லை — உள்ளடக்கத்தைப் பார்த்து மீண்டும் முயலுங்கள்.',
    },
    'select_all_apply': {
      1: 'Select all that apply',
      2: 'सभी लागू विकल्प चुनें',
      3: 'প্রযোজ্য সবগুলো নির্বাচন করুন',
      4: 'பொருந்தும் அனைத்தையும் தேர்ந்தெடுக்கவும்',
    },
    'drag_to_bucket': {
      1: 'Drag each item into the correct bucket',
      2: 'हर वस्तु को सही बकेट में खींचें',
      3: 'প্রতিটি আইটেম সঠিক বাকেটে টেনে আনুন',
      4: 'ஒவ்வொரு பொருளையும் சரியான வாளியில் இழுக்கவும்',
    },
    'all_items_placed': {
      1: 'All items placed',
      2: 'सभी वस्तुएं रखी गईं',
      3: 'সব আইটেম রাখা হয়েছে',
      4: 'அனைத்துப் பொருட்களும் வைக்கப்பட்டன',
    },
    'match_pairs': {
      1: 'Match each item on the left with one on the right',
      2: 'बाईं ओर की हर वस्तु को दाईं ओर से मिलाएं',
      3: 'বাঁ দিকের প্রতিটি আইটেম ডান দিকের সাথে মেলান',
      4: 'இடதுபுறப் பொருளை வலதுபுறத்துடன் பொருத்தவும்',
    },
    'overview': {
      1: 'Overview',
      2: 'अवलोकन',
      3: 'সংক্ষিপ্ত বিবরণ',
      4: 'மேலோட்டம்',
    },
    'objective': {
      1: 'Objective',
      2: 'उद्देश्य',
      3: 'উদ্দেশ্য',
      4: 'நோக்கம்',
    },
    'topics': {
      1: 'Topics',
      2: 'विषय',
      3: 'বিষয়সমূহ',
      4: 'தலைப்புகள்',
    },
    'answered': {
      1: 'answered',
      2: 'उत्तर दिए',
      3: 'উত্তর দেওয়া',
      4: 'பதிலளிக்கப்பட்டது',
    },
    'forgot_password': {
      1: 'Forgot Password?',
      2: 'पासवर्ड भूल गए?',
      3: 'পাসওয়ার্ড ভুলে গেছেন?',
      4: 'கடவுச்சொல் மறந்துவிட்டதா?',
    },
  };

  static String of(String key, int languageId) {
    final entry = _values[key];

    if (entry == null) return key;

    return entry[languageId] ?? entry[_fallback] ?? key;
  }
}
