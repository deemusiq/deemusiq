class ISOLanguageName {
  final String name;
  final String nativeName;

  const ISOLanguageName({
    required this.name,
    required this.nativeName,
  });

  @override
  String toString() {
    return "$name ($nativeName)";
  }
}

abstract class LanguageLocals {
  static final Map isoLangs = {
    "ar": const ISOLanguageName(
      name: "Arabic",
      nativeName: "العربية",
    ),
    "eu": const ISOLanguageName(
      name: "Basque",
      nativeName: "Euskara",
    ),
    "bn": const ISOLanguageName(
      name: "Bengali",
      nativeName: "বাংলা",
    ),
    "ca": const ISOLanguageName(
      name: "Catalan",
      nativeName: "Català",
    ),
    "zh_CN": const ISOLanguageName(
      name: "Simplified Chinese",
      nativeName: "简体中文",
    ),
    "zh_TW": const ISOLanguageName(
      name: "Traditional Chinese",
      nativeName: "繁體中文（台灣）",
    ),
    "cs": const ISOLanguageName(
      name: "Czech",
      nativeName: "česky, čeština",
    ),
    "nl": const ISOLanguageName(
      name: "Dutch",
      nativeName: "Nederlands",
    ),
    "en": const ISOLanguageName(
      name: "English",
      nativeName: "English",
    ),
    "fi": const ISOLanguageName(
      name: "Finnish",
      nativeName: "suomi",
    ),
    "fr": const ISOLanguageName(
      name: "French",
      nativeName: "français",
    ),
    "ka": const ISOLanguageName(
      name: "Georgian",
      nativeName: "ქართული",
    ),
    "de": const ISOLanguageName(
      name: "German",
      nativeName: "Deutsch",
    ),
    "hi": const ISOLanguageName(
      name: "Hindi",
      nativeName: "हिन्दी, हिंदी",
    ),
    "id": const ISOLanguageName(
      name: "Indonesian",
      nativeName: "Bahasa Indonesia",
    ),
    "it": const ISOLanguageName(
      name: "Italian",
      nativeName: "Italiano",
    ),
    "ja": const ISOLanguageName(
      name: "Japanese",
      nativeName: "日本語",
    ),
    "ko": const ISOLanguageName(
      name: "Korean",
      nativeName: "한국어 (韓國語), 조선말 (朝鮮語)",
    ),
    "ne": const ISOLanguageName(
      name: "Nepali",
      nativeName: "नेपाली",
    ),
    "fa": const ISOLanguageName(
      name: "Persian",
      nativeName: "فارسی",
    ),
    "pl": const ISOLanguageName(
      name: "Polish",
      nativeName: "polski",
    ),
    "pt": const ISOLanguageName(
      name: "Portuguese",
      nativeName: "Português",
    ),
    "ru": const ISOLanguageName(
      name: "Russian",
      nativeName: "русский язык",
    ),
    "es": const ISOLanguageName(
      name: "Spanish",
      nativeName: "español",
    ),
    "ta": const ISOLanguageName(
      name: "Tamil",
      nativeName: "தமிழ்",
    ),
    "th": const ISOLanguageName(
      name: "Thai",
      nativeName: "ไทย",
    ),
    "tl": const ISOLanguageName(
      name: "Tagalog",
      nativeName: "Wikang Tagalog",
    ),
    "tr": const ISOLanguageName(
      name: "Turkish",
      nativeName: "Türkçe",
    ),
    "uk": const ISOLanguageName(
      name: "Ukrainian",
      nativeName: "українська",
    ),
    "vi": const ISOLanguageName(
      name: "Vietnamese",
      nativeName: "Tiếng Việt",
    ),
  };

  static ISOLanguageName getDisplayLanguage(String key, String? countryCode) {
    if (isoLangs.containsKey(key)) {
      return isoLangs[key]!;
    } else if (countryCode != null &&
        countryCode.isNotEmpty &&
        isoLangs.containsKey("${key}_$countryCode")) {
      return isoLangs["${key}_$countryCode"]!;
    } else {
      throw Exception("Language key incorrect");
    }
  }
}
