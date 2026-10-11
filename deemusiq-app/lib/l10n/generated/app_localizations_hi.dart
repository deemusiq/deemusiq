// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get guest => 'अतिथि';

  @override
  String get browse => 'ब्राउज़ करें';

  @override
  String get search => 'खोजें';

  @override
  String get library => 'लाइब्रेरी';

  @override
  String get lyrics => 'गीतों के बोल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get genre_categories_filter => 'श्रेणियों या जानरों को फिल्टर करें...';

  @override
  String get genre => 'जानर';

  @override
  String get personalized => 'व्यक्तिगत';

  @override
  String get featured => 'विशेष रुप से प्रदर्शित';

  @override
  String get new_releases => 'नई रिलीज़';

  @override
  String get songs => 'गाने';

  @override
  String playing_track(Object track) {
    return '$track चल रहा है';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'यह मौजूदा कतार को साफ़ कर देगा। $track_length ट्रैक हटा दिए जाएंगे\nक्या आप जारी रखना चाहते हैं?';
  }

  @override
  String get load_more => 'और लोड करें';

  @override
  String get playlists => 'प्लेलिस्ट';

  @override
  String get artists => 'कलाकार';

  @override
  String get albums => 'एल्बम';

  @override
  String get tracks => 'ट्रैक';

  @override
  String get downloads => 'डाउनलोड';

  @override
  String get filter_playlists => 'अपनी प्लेलिस्टों को फ़िल्टर करें...';

  @override
  String get liked_tracks => 'पसंदीदा ट्रैक';

  @override
  String get liked_tracks_description => 'आपके सभी पसंदीदा ट्रैक';

  @override
  String get playlist => 'प्लेलिस्ट';

  @override
  String get create_a_playlist => 'एक प्लेलिस्ट बनाएं';

  @override
  String get update_playlist => 'प्लेलिस्ट अपडेट करें';

  @override
  String get create => 'बनाएं';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get update => 'अपडेट करें';

  @override
  String get playlist_name => 'प्लेलिस्ट का नाम';

  @override
  String get name_of_playlist => 'प्लेलिस्ट का नाम';

  @override
  String get description => 'विवरण';

  @override
  String get public => 'सार्वजनिक';

  @override
  String get collaborative => 'सहयोगी';

  @override
  String get search_local_tracks => 'स्थानीय ट्रैक खोजें...';

  @override
  String get play => 'चलाएँ';

  @override
  String get delete => 'हटाएँ';

  @override
  String get none => 'कोई नहीं';

  @override
  String get sort_a_z => 'A-Z सॉर्ट करें';

  @override
  String get sort_z_a => 'Z-A सॉर्ट करें';

  @override
  String get sort_artist => 'कलाकार के अनुसार सॉर्ट करें';

  @override
  String get sort_album => 'एल्बम के अनुसार सॉर्ट करें';

  @override
  String get sort_duration => 'समय के आधार पर क्रमबद्ध करें';

  @override
  String get sort_tracks => 'ट्रैक को सॉर्ट करें';

  @override
  String currently_downloading(Object tracks_length) {
    return 'वर्तमान में डाउनलोड हो रहा है ($tracks_length)';
  }

  @override
  String get cancel_all => 'सभी को रद्द करें';

  @override
  String get filter_artist => 'कलाकारों को फ़िल्टर करें...';

  @override
  String followers(Object followers) {
    return '$followers फॉलोअर्स';
  }

  @override
  String get add_artist_to_blacklist => 'काल सूची में कलाकार जोड़ें';

  @override
  String get top_tracks => 'शीर्ष ट्रैक';

  @override
  String get fans_also_like => 'फैंस भी पसंद करते हैं';

  @override
  String get loading => 'लोड हो रहा है...';

  @override
  String get artist => 'कलाकार';

  @override
  String get blacklisted => 'काल सूची में है';

  @override
  String get following => 'फॉलो करना';

  @override
  String get follow => 'फॉलो करें';

  @override
  String get artist_url_copied => 'कलाकार URL क्लिपबोर्ड पर कॉपी हुआ';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks ट्रैक कतार में जोड़े गए';
  }

  @override
  String get filter_albums => 'एल्बमों को फ़िल्टर करें...';

  @override
  String get synced => 'सिंक किया गया';

  @override
  String get plain => 'सादा';

  @override
  String get shuffle => 'शफल';

  @override
  String get search_tracks => 'ट्रैक खोजें...';

  @override
  String get released => 'जारी हुआ';

  @override
  String error(Object error) {
    return 'त्रुटि $error';
  }

  @override
  String get title => 'शीर्षक';

  @override
  String get time => 'समय';

  @override
  String get more_actions => 'अधिक कार्रवाई';

  @override
  String download_count(Object count) {
    return 'डाउनलोड ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return '($count) को प्लेलिस्ट में जोड़ें';
  }

  @override
  String add_count_to_queue(Object count) {
    return '($count) को कतार में जोड़ें';
  }

  @override
  String play_count_next(Object count) {
    return '($count) अगले में चलाएँ';
  }

  @override
  String get album => 'एल्बम';

  @override
  String copied_to_clipboard(Object data) {
    return '$data क्लिपबोर्ड पर कॉपी किया गया';
  }

  @override
  String add_to_following_playlists(Object track) {
    return '$track को निम्नलिखित प्लेलिस्ट में जोड़ें';
  }

  @override
  String get add => 'जोड़ें';

  @override
  String added_track_to_queue(Object track) {
    return '$track को कतार में जोड़ दिया गया';
  }

  @override
  String get add_to_queue => 'कतार में जोड़ें';

  @override
  String track_will_play_next(Object track) {
    return '$track अगले में चलेगा';
  }

  @override
  String get play_next => 'अगले में चलाएँ';

  @override
  String removed_track_from_queue(Object track) {
    return '$track को कतार से हटा दिया गया';
  }

  @override
  String get remove_from_queue => 'कतार से हटाएँ';

  @override
  String get remove_from_favorites => 'पसंदीदा से हटाएँ';

  @override
  String get save_as_favorite => 'पसंदीदा के रूप में सहेजें';

  @override
  String get add_to_playlist => 'प्लेलिस्ट में जोड़ें';

  @override
  String get remove_from_playlist => 'प्लेलिस्ट से हटाएँ';

  @override
  String get add_to_blacklist => 'ब्लैकलिस्ट में जोड़ें';

  @override
  String get remove_from_blacklist => 'ब्लैकलिस्ट से हटाएँ';

  @override
  String get share => 'साझा करें';

  @override
  String get mini_player => 'मिनी प्लेयर';

  @override
  String get slide_to_seek => 'आगे या पीछे खोजने के लिए स्लाइड करें';

  @override
  String get shuffle_playlist => 'प्लेलिस्ट शफल करें';

  @override
  String get unshuffle_playlist => 'अनशफल प्लेलिस्ट';

  @override
  String get previous_track => 'पिछला ट्रैक';

  @override
  String get next_track => 'अगला ट्रैक';

  @override
  String get pause_playback => 'वापसी बंद करें';

  @override
  String get resume_playback => 'पुनः चलाना';

  @override
  String get loop_track => 'लूप ट्रैक';

  @override
  String get no_loop => 'कोई लूप नहीं';

  @override
  String get repeat_playlist => 'प्लेलिस्ट दोहराएं';

  @override
  String get queue => 'कतार';

  @override
  String get alternative_track_sources => 'वैकल्पिक ट्रैक स्रोत';

  @override
  String get download_track => 'ट्रैक डाउनलोड करें';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks ट्रैक कतार में हैं';
  }

  @override
  String get clear_all => 'सभी हटाएं';

  @override
  String get show_hide_ui_on_hover => 'होवर पर यूआई दिखाएँ/छिपाएँ';

  @override
  String get always_on_top => 'हमेशा ऊपर हो';

  @override
  String get exit_mini_player => 'मिनी प्लेयर से बाहर निकलें';

  @override
  String get download_location => 'डाउनलोड स्थान';

  @override
  String get local_library => 'स्थानीय पुस्तकालय';

  @override
  String get add_library_location => 'पुस्तकालय में जोड़ें';

  @override
  String get remove_library_location => 'पुस्तकालय से हटाएं';

  @override
  String get account => 'खाता';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get logout_of_this_account => 'इस खाते से लॉगआउट करें';

  @override
  String get language_region => 'भाषा और क्षेत्र';

  @override
  String get language => 'भाषा';

  @override
  String get system_default => 'सिस्टम डिफ़ॉल्ट';

  @override
  String get market_place_region => 'मार्केटप्लेस क्षेत्र';

  @override
  String get recommendation_country => 'सिफ़ारिश देने वाला देश';

  @override
  String get appearance => 'दिखने में';

  @override
  String get layout_mode => 'लेआउट मोड';

  @override
  String get override_layout_settings =>
      'ओवरराइड रेस्पॉन्सिव लेआउट मोड सेटिंग्स';

  @override
  String get adaptive => 'अनुकूल';

  @override
  String get compact => 'कॉम्पैक्ट';

  @override
  String get extended => 'विस्तृत';

  @override
  String get theme => 'थीम';

  @override
  String get dark => 'डार्क';

  @override
  String get light => 'लाइट';

  @override
  String get system => 'सिस्टम';

  @override
  String get accent_color => 'अक्षरशैली का रंग';

  @override
  String get sync_album_color => 'एल्बम का रंग सिंक करें';

  @override
  String get sync_album_color_description =>
      'एल्बम कला का प्रधान रंग एक्सेंट रंग के रूप में उपयोग किया जाता है';

  @override
  String get playback => 'प्लेबैक';

  @override
  String get audio_quality => 'ऑडियो क्वालिटी';

  @override
  String get high => 'उच्च';

  @override
  String get low => 'निम्न';

  @override
  String get pre_download_play => 'पूर्वावत डाउनलोड और प्ले करें';

  @override
  String get pre_download_play_description =>
      'ऑडियो स्ट्रीमिंग की बजाय बाइट्स डाउनलोड करें और बजाय में प्ले करें (उच्च बैंडविड्थ उपयोगकर्ताओं के लिए सिफारिश किया जाता है)';

  @override
  String get skip_non_music =>
      'गाने के अलावा सेगमेंट्स को छोड़ें (स्पॉन्सरब्लॉक)';

  @override
  String get blacklist_description => 'ब्लैकलिस्ट में शामिल ट्रैक और कलाकार';

  @override
  String get wait_for_download_to_finish =>
      'वर्तमान डाउनलोड समाप्त होने तक कृपया प्रतीक्षा करें';

  @override
  String get desktop => 'डेस्कटॉप';

  @override
  String get close_behavior => 'बंद करने का व्यवहार';

  @override
  String get close => 'बंद करें';

  @override
  String get minimize_to_tray => 'ट्रे में कम करें';

  @override
  String get show_tray_icon => 'सिस्टम ट्रे आइकन दिखाएं';

  @override
  String get about => 'के बारे में';

  @override
  String get u_love_spotube => 'हम जानते हैं कि आप DeeMusiq से प्यार करते हैं';

  @override
  String get check_for_updates => 'अपडेट के लिए जाँच करें';

  @override
  String get about_spotube => 'DeeMusiq के बारे में';

  @override
  String get blacklist => 'ब्लैकलिस्ट';

  @override
  String get please_sponsor => 'कृपया स्पॉन्सर / डोनेट करें';

  @override
  String get spotube_description =>
      'DeeMusiq, एक हल्का, सभी प्लेटफॉर्मों पर चलने वाला, मुफ्त स्पॉटिफाई क्लाइंट';

  @override
  String get version => 'संस्करण';

  @override
  String get build_number => 'बिल्ड नंबर';

  @override
  String get founder => 'संस्थापक';

  @override
  String get repository => 'भण्डार';

  @override
  String get bug_issues => 'बग+मुद्दे';

  @override
  String get made_with => 'बांग्लादेश🇧🇩 में दिल से बनाया गया';

  @override
  String get kingkor_roy_tirtho => 'किंगकोर रॉय तिर्थो';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year किंगकोर रॉय तिर्थो';
  }

  @override
  String get license => 'लाइसेंस';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'चिंता न करें, आपके क्रेडेंशियल किसी भी तरह से नहीं एकत्रित या साझा किए जाएंगे';

  @override
  String get know_how_to_login => 'इसे कैसे करें पता नहीं?';

  @override
  String get follow_step_by_step_guide => 'कदम से कदम गाइड के साथ चलें';

  @override
  String cookie_name_cookie(Object name) {
    return '$name कुकी';
  }

  @override
  String get fill_in_all_fields => 'कृपया सभी फ़ील्ड भरें';

  @override
  String get submit => 'सबमिट';

  @override
  String get exit => 'बाहर निकलें';

  @override
  String get previous => 'पिछला';

  @override
  String get next => 'अगला';

  @override
  String get done => 'किया हुआ';

  @override
  String get step_1 => '1 चरण';

  @override
  String get first_go_to => 'पहले, जाएं';

  @override
  String get something_went_wrong => 'कुछ गलत हो गया';

  @override
  String get piped_instance => 'पाइप्ड सर्वर';

  @override
  String get piped_description => 'पाइप किए गए सर्वर';

  @override
  String get piped_warning =>
      'गानों का मिलान करने के लिए उपयोग किए जाते हैं, हो सकता है कि उनमें से कुछ के साथ ठीक से काम न करें इसलिए अपने जोखिम पर उपयोग करें';

  @override
  String get invidious_instance => 'इन्विडियस सर्वर इंस्टेंस';

  @override
  String get invidious_description =>
      'ट्रैक मिलान के लिए इन्विडियस सर्वर इंस्टेंस';

  @override
  String get invidious_warning =>
      'कुछ इंस्टेंस अच्छी तरह से काम नहीं कर सकते। अपने जोखिम पर उपयोग करें';

  @override
  String get generate => 'उत्पन्न करें';

  @override
  String track_exists(Object track) {
    return 'ट्रैक $track पहले से मौजूद है';
  }

  @override
  String get replace_downloaded_tracks => 'सभी डाउनलोड किए गए ट्रैक्स को बदलें';

  @override
  String get skip_download_tracks => 'सभी डाउनलोड किए गए ट्रैक्स को छोड़ें';

  @override
  String get do_you_want_to_replace =>
      'क्या आप मौजूदा ट्रैक को बदलना चाहते हैं?';

  @override
  String get replace => 'बदलें';

  @override
  String get skip => 'छोड़ें';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return '$count $type तक चुनें';
  }

  @override
  String get select_genres => 'जान्र चुनें';

  @override
  String get add_genres => 'जान्र जोड़ें';

  @override
  String get country => 'देश';

  @override
  String get number_of_tracks_generate => 'उत्पन्न करने के लिए ट्रैक की संख्या';

  @override
  String get acousticness => 'ध्वनिकता';

  @override
  String get danceability => 'नृत्यता';

  @override
  String get energy => 'ऊर्जा';

  @override
  String get instrumentalness => 'आलापिकता';

  @override
  String get liveness => 'जीवंतता';

  @override
  String get loudness => 'शोर';

  @override
  String get speechiness => 'बोलचालता';

  @override
  String get valence => 'मनोदयता';

  @override
  String get popularity => 'लोकप्रियता';

  @override
  String get key => 'कुंजी';

  @override
  String get duration => 'अवधि (सेकंड)';

  @override
  String get tempo => 'गति (BPM)';

  @override
  String get mode => 'मोड';

  @override
  String get time_signature => 'समय छाप';

  @override
  String get short => 'संक्षेप';

  @override
  String get medium => 'मध्यम';

  @override
  String get long => 'लंबा';

  @override
  String get min => 'न्यूनतम';

  @override
  String get max => 'अधिकतम';

  @override
  String get target => 'लक्ष्य';

  @override
  String get moderate => 'मध्यम';

  @override
  String get deselect_all => 'सभी को अचयनित करें';

  @override
  String get select_all => 'सभी को चुनें';

  @override
  String get are_you_sure => 'क्या आपको यकीन है?';

  @override
  String get generating_playlist => 'आपकी कस्टम प्लेलिस्ट बनाई जा रही है...';

  @override
  String selected_count_tracks(Object count) {
    return '$count ट्रैक्स चयनित हैं';
  }

  @override
  String get download_warning =>
      'यदि आप सभी ट्रैक्स को बल्क में डाउनलोड करते हैं, तो आप स्पष्ट रूप से संगीत की अवैध नकली बना रहे हैं और संगीत के रचनात्मक समाज को क्षति पहुंचा रहे हैं। मुझे आशा है कि आप इसके बारे में जागरूक हैं। हमेशा कोशिश करें कि कलाकार के मेहनत का सम्मान और समर्थन करें।';

  @override
  String get download_ip_ban_warning =>
      'बाहरी डाउनलोड अनुरोधों के कारण आपका आईपी YouTube पर अधिक से अधिक ब्लॉक हो सकता है। आईपी ब्लॉक का अर्थ है कि आप उसी आईपी उपकरण से कम से कम 2-3 महीनों तक YouTube का उपयोग नहीं कर सकेंगे (यदि आप लॉग इन हैं तो भी)। और स्पोट्यूब किसी भी जिम्मेदारी को नहीं उठाता है अगर ऐसा कभी होता है।';

  @override
  String get by_clicking_accept_terms =>
      '\'स्वीकार\' पर क्लिक करके आप निम्नलिखित शर्तों से सहमत होते हैं:';

  @override
  String get download_agreement_1 =>
      'मुझे पता है कि मैं संगीत की अवैध नकली बना रहा हूं। मैं बुरा हूं';

  @override
  String get download_agreement_2 =>
      'मैं कलाकार का समर्थन करूंगा जहां भी मुझे संभव हो और मैं केवल इसल  िए ऐसा कर रहा हूं क्योंकि मेरे पास उनकी कला खरीदने के लिए पैसे नहीं हैं।';

  @override
  String get download_agreement_3 =>
      'मैं पूरी तरह से जागरूक हूं कि मेरा आईपी YouTube पर ब्लॉक हो सकता है और मैं स्पोट्यूब या उसके मालिकों / सहयोगियों को किसी भी दुर्घटना के लिए जिम्मेदार नहीं मानता।';

  @override
  String get decline => 'इनकार करें';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get details => 'विवरण';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'चैनल';

  @override
  String get likes => 'पसंद';

  @override
  String get dislikes => 'अप्रिय';

  @override
  String get views => 'दृश्य';

  @override
  String get streamUrl => 'स्ट्रीम URL';

  @override
  String get stop => 'रोकें';

  @override
  String get sort_newest => 'नवीनतम जोड़े गए के अनुसार क्रमबद्ध करें';

  @override
  String get sort_oldest => 'सबसे पुराने जोड़े गए के अनुसार क्रमबद्ध करें';

  @override
  String get sleep_timer => 'स्लीप टाइमर';

  @override
  String mins(Object minutes) {
    return '$minutes मिनट';
  }

  @override
  String hours(Object hours) {
    return '$hours घंटे';
  }

  @override
  String hour(Object hours) {
    return '$hours घंटा';
  }

  @override
  String get custom_hours => 'कस्टम घंटे';

  @override
  String get logs => 'लॉग';

  @override
  String get developers => 'डेवलपर्स';

  @override
  String get not_logged_in => 'आप लॉग इन नहीं हैं';

  @override
  String get search_mode => 'खोज मोड';

  @override
  String get audio_source => 'ऑडियो स्रोत';

  @override
  String get ok => 'ठीक है';

  @override
  String get failed_to_encrypt => 'एन्क्रिप्ट करने में विफल रहा';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq आपके डेटा को सुरक्षित रूप से स्टोर करने के लिए एन्क्रिप्शन का उपयोग करता है। लेकिन इसमें विफल रहा। इसलिए, यह असुरक्षित स्टोरेज पर फॉलबैक करेगा\nयदि आप Linux का उपयोग कर रहे हैं, तो कृपया सुनिश्चित करें कि आपके पास gnome-keyring, kde-wallet, keepassxc आदि जैसी कोई सीक्रेट-सर्विस इंस्टॉल की गई है';

  @override
  String get querying_info => 'जानकारी प्राप्त करना';

  @override
  String get piped_api_down => 'पाइप्ड एपीआई डाउन है';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'पाइप्ड इंस्टेंस $pipedInstance वर्तमान में डाउन है\n\nइंस्टेंस बदलें या \'एपीआई प्रकार\' को आधिकृत YouTube एपीआई में बदलें\n\nपरिवर्तन के बाद ऐप को फिर से चालने की सुनिश्चित करें';
  }

  @override
  String get you_are_offline => 'आप वर्तमान में ऑफ़लाइन हैं';

  @override
  String get connection_restored => 'आपका इंटरनेट कनेक्शन बहाल हो गया है';

  @override
  String get use_system_title_bar => 'सिस्टम शीर्षक पट्टी का उपयोग करें';

  @override
  String get crunching_results => 'परिणाम को प्रसंस्कृत किया जा रहा है...';

  @override
  String get search_to_get_results => 'परिणाम प्राप्त करने के लिए खोजें';

  @override
  String get use_amoled_mode => 'AMOLED मोड का उपयोग करें';

  @override
  String get pitch_dark_theme => 'पिच ब्लैक डार्ट थीम';

  @override
  String get normalize_audio => 'ऑडियो को सामान्य करें';

  @override
  String get change_cover => 'कवर बदलें';

  @override
  String get add_cover => 'कवर जोड़ें';

  @override
  String get restore_defaults => 'डिफ़ॉल्ट सेटिंग्स को बहाल करें';

  @override
  String get download_music_format => 'संगीत डाउनलोड प्रारूप';

  @override
  String get streaming_music_format => 'संगीत स्ट्रीमिंग प्रारूप';

  @override
  String get download_music_quality => 'संगीत डाउनलोड गुणवत्ता';

  @override
  String get streaming_music_quality => 'संगीत स्ट्रीमिंग गुणवत्ता';

  @override
  String get login_with_lastfm => 'Last.fm से लॉगिन करें';

  @override
  String get connect => 'कनेक्ट करें';

  @override
  String get disconnect_lastfm => 'Last.fm से डिस्कनेक्ट करें';

  @override
  String get disconnect => 'डिस्कनेक्ट करें';

  @override
  String get username => 'उपयोगकर्ता नाम';

  @override
  String get password => 'पासवर्ड';

  @override
  String get login => 'लॉग इन करें';

  @override
  String get login_with_your_lastfm => 'अपने Last.fm अकाउंट से लॉगिन करें';

  @override
  String get scrobble_to_lastfm => 'Last.fm पर स्क्रॉबल करें';

  @override
  String get go_to_album => 'एल्बम पर जाएं';

  @override
  String get discord_rich_presence => 'डिस्कॉर्ड रिच प्रेजेंस';

  @override
  String get browse_all => 'सभी को ब्राउज़ करें';

  @override
  String get genres => 'शैलियाँ';

  @override
  String get explore_genres => 'शैलियों का अन्वेषण करें';

  @override
  String get friends => 'दोस्त';

  @override
  String get no_lyrics_available =>
      'क्षमा करें, इस ट्रैक के लिए गाने नहीं मिल सके';

  @override
  String get start_a_radio => 'रेडियो शुरू करें';

  @override
  String get how_to_start_radio => 'रेडियो कैसे शुरू करना चाहते हैं?';

  @override
  String get replace_queue_question =>
      'क्या आप वर्तमान कतार को बदलना चाहते हैं या इसे जोड़ना चाहते हैं?';

  @override
  String get endless_playback => 'अंतहीन प्लेबैक';

  @override
  String get delete_playlist => 'प्लेलिस्ट हटाएं';

  @override
  String get delete_playlist_confirmation =>
      'क्या आप वाकई इस प्लेलिस्ट को हटाना चाहते हैं?';

  @override
  String get local_tracks => 'स्थानीय ट्रैक्स';

  @override
  String get local_tab => 'स्थानीय';

  @override
  String get song_link => 'गाने का लिंक';

  @override
  String get youtube_source_description =>
      'सिफारिश किया गया और सबसे अच्छा काम करता है।';

  @override
  String get piped_source_description =>
      'मुफ्त महसूस कर रहे हैं? YouTube के समान लेकिन काफी अधिक मुफ्त।';

  @override
  String get jiosaavn_source_description =>
      'दक्षिण एशियाई क्षेत्र के लिए सर्वोत्तम।';

  @override
  String get invidious_source_description =>
      'पाइप्ड के समान, लेकिन अधिक उपलब्धता के साथ';

  @override
  String highest_quality(Object quality) {
    return 'सर्वोत्तम गुणवत्ता: $quality';
  }

  @override
  String get select_audio_source => 'ऑडियो स्रोत चुनें';

  @override
  String get contribute_on_github => 'GitHub पर योगदान करें';

  @override
  String get browse_anonymously => 'बिना नाम के ब्राउज़ करें';

  @override
  String get enable_connect => 'कनेक्ट सक्षम करें';

  @override
  String get enable_connect_description =>
      'अन्य उपकरणों से DeeMusiq को नियंत्रित करें';

  @override
  String get devices => 'उपकरण';

  @override
  String get select => 'चयन करें';

  @override
  String connect_client_alert(Object client) {
    return 'आप $client द्वारा नियंत्रित हो रहे हैं';
  }

  @override
  String get this_device => 'यह उपकरण';

  @override
  String get remote => 'रिमोट';

  @override
  String get stats => 'आंकड़े';

  @override
  String and_n_more(Object count) {
    return 'और $count और';
  }

  @override
  String get recently_played => 'हाल ही में खेले गए';

  @override
  String get browse_more => 'अधिक ब्राउज़ करें';

  @override
  String get no_title => 'कोई शीर्षक नहीं';

  @override
  String get not_playing => 'नहीं चल रहा';

  @override
  String get epic_failure => 'महान असफलता!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length ट्रैक्स कतार में जोड़े गए';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq में एक अपडेट है';

  @override
  String get download_now => 'अभी डाउनलोड करें';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum जारी किया गया है';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version जारी किया गया है';
  }

  @override
  String get read_the_latest => 'नवीनतम पढ़ें';

  @override
  String get release_notes => 'रिलीज़ नोट्स';

  @override
  String get pick_color_scheme => 'रंग योजना चुनें';

  @override
  String get save => 'सहेजें';

  @override
  String get choose_the_device => 'उपकरण चुनें:';

  @override
  String get multiple_device_connected =>
      'कई उपकरण जुड़े हुए हैं।\nउस उपकरण को चुनें जिस पर आप यह क्रिया करना चाहते हैं';

  @override
  String get nothing_found => 'कुछ भी नहीं मिला';

  @override
  String get the_box_is_empty => 'बॉक्स खाली है';

  @override
  String get top_artists => 'शीर्ष कलाकार';

  @override
  String get top_albums => 'शीर्ष एल्बम';

  @override
  String get this_week => 'इस हफ्ते';

  @override
  String get this_month => 'इस महीने';

  @override
  String get last_6_months => 'पिछले 6 महीने';

  @override
  String get this_year => 'इस साल';

  @override
  String get last_2_years => 'पिछले 2 साल';

  @override
  String get all_time => 'सभी समय';

  @override
  String powered_by_provider(Object providerName) {
    return '$providerName द्वारा संचालित';
  }

  @override
  String get email => 'ईमेल';

  @override
  String get profile_followers => 'अनुयायी';

  @override
  String get birthday => 'जन्मदिन';

  @override
  String get subscription => 'सदस्यता';

  @override
  String get not_born => 'अभी पैदा नहीं हुआ';

  @override
  String get hacker => 'हैकर';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get no_name => 'कोई नाम नहीं';

  @override
  String get edit => 'संपादित करें';

  @override
  String get user_profile => 'उपयोगकर्ता प्रोफ़ाइल';

  @override
  String count_plays(Object count) {
    return '$count प्ले';
  }

  @override
  String get minutes_listened => 'सुनिएका मिनेटहरू';

  @override
  String get streamed_songs => 'स्ट्रीम गरिएका गीतहरू';

  @override
  String count_streams(Object count) {
    return '$count स्ट्रिम';
  }

  @override
  String get owned_by_you => 'तपाईंले स्वामित्व गरेको';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl क्लिपबोर्डमा कपी गरियो';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes मिनट';
  }

  @override
  String get summary_minutes => 'मिनट';

  @override
  String get summary_listened_to_music => 'सुनी गई संगीत';

  @override
  String get summary_songs => 'गाने';

  @override
  String get summary_streamed_overall => 'कुल स्ट्रीम';

  @override
  String get summary_artists => 'कलाकार';

  @override
  String get summary_music_reached_you => 'संगीत आपके पास पहुंच गया';

  @override
  String get summary_full_albums => 'पूरा एल्बम';

  @override
  String get summary_got_your_love => 'आपका प्यार मिला';

  @override
  String get summary_playlists => 'प्लेलिस्ट';

  @override
  String get summary_were_on_repeat => 'दोहराया गया';

  @override
  String get webview_not_found => 'वेबव्यू नहीं मिला';

  @override
  String get webview_not_found_description =>
      'आपके डिवाइस पर वेबव्यू रनटाइम इंस्टॉल नहीं है।\nअगर इंस्टॉल है, तो सुनिश्चित करें कि यह environment PATH में है\n\nइंस्टॉल करने के बाद, ऐप को पुनः शुरू करें';

  @override
  String get unsupported_platform => 'असमर्थित प्लेटफार्म';

  @override
  String get cache_music => 'संगीत को कैश करें';

  @override
  String get open => 'खोलें';

  @override
  String get cache_folder => 'कैश फ़ोल्डर';

  @override
  String get export => 'निर्यात करें';

  @override
  String get clear_cache => 'कैश साफ़ करें';

  @override
  String get clear_cache_confirmation => 'क्या आप कैश साफ़ करना चाहते हैं?';

  @override
  String get export_cache_files => 'कैश फ़ाइलें निर्यात करें';

  @override
  String found_n_files(Object count) {
    return '$count फ़ाइलें मिलीं';
  }

  @override
  String get export_cache_confirmation =>
      'क्या आप इन फ़ाइलों को निर्यात करना चाहते हैं';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported फ़ाइलें निर्यात की गईं $files में से';
  }

  @override
  String get undo => 'पूर्ववत करें';

  @override
  String get download_all => 'सभी डाउनलोड करें';

  @override
  String get add_all_to_playlist => 'सभी को प्लेलिस्ट में जोड़ें';

  @override
  String get add_all_to_queue => 'सभी को कतार में जोड़ें';

  @override
  String get play_all_next => 'सभी को अगले खेलने के लिए';

  @override
  String get pause => 'रोकें';

  @override
  String get view_all => 'सभी देखें';

  @override
  String get no_tracks_added_yet =>
      'लगता है आपने अभी तक कोई ट्रैक नहीं जोड़ा है।';

  @override
  String get no_tracks => 'लगता है यहाँ कोई ट्रैक नहीं है।';

  @override
  String get no_tracks_listened_yet => 'लगता है आपने अभी तक कुछ नहीं सुना है।';

  @override
  String get not_following_artists =>
      'आप किसी भी कलाकार को फॉलो नहीं कर रहे हैं।';

  @override
  String get no_favorite_albums_yet =>
      'लगता है आपने अभी तक कोई एल्बम अपनी पसंदीदा सूची में नहीं जोड़ा है।';

  @override
  String get no_logs_found => 'कोई लॉग नहीं मिला';

  @override
  String get youtube_engine => 'YouTube इंजन';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine स्थापित नहीं है';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine आपके सिस्टम में स्थापित नहीं है।';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'यह सुनिश्चित करें कि यह PATH वेरिएबल में उपलब्ध हो या\nनीचे $engine निष्पादन योग्य फ़ाइल का पूर्ण पथ सेट करें।';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/यूनिक्स जैसे OS में, .zshrc/.bashrc/.bash_profile आदि में पथ सेट करना काम नहीं करेगा।\nआपको पथ को शेल कॉन्फ़िगरेशन फ़ाइल में सेट करना होगा।';

  @override
  String get yt_dlp_install_title => 'Setting up Drop 1';

  @override
  String get yt_dlp_install_phase_checking =>
      'Checking for an existing Drop 1 install…';

  @override
  String yt_dlp_install_phase_downloading(Object version) {
    return 'Downloading Drop 1 $version…';
  }

  @override
  String get yt_dlp_install_phase_verifying =>
      'Verifying the downloaded Drop 1…';

  @override
  String yt_dlp_install_phase_installing(Object version) {
    return 'Installing Drop 1 $version…';
  }

  @override
  String yt_dlp_install_phase_done(Object version) {
    return 'Drop 1 $version is ready';
  }

  @override
  String get yt_dlp_install_phase_failed => 'Drop 1 setup failed';

  @override
  String yt_dlp_install_progress(Object received, Object total) {
    return '$received of $total';
  }

  @override
  String get yt_dlp_install_action => 'Install automatically';

  @override
  String get yt_dlp_install_latest_action =>
      'Install the latest Drop 1 automatically';

  @override
  String get yt_dlp_install_retry => 'Retry';

  @override
  String yt_dlp_install_failed_message(Object error) {
    return 'Drop 1 could not be installed automatically:\n$error';
  }

  @override
  String get yt_dlp_install_managed_message =>
      'DeeMusiq downloads the official Drop 1 release into its own folder and keeps it up to date, so nothing has to be installed system-wide.';

  @override
  String get download => 'डाउनलोड करें';

  @override
  String get file_not_found => 'फाइल नहीं मिली';

  @override
  String get custom => 'कस्टम';

  @override
  String get add_custom_url => 'कस्टम URL जोड़ें';

  @override
  String get edit_port => 'पोर्ट संपादित करें';

  @override
  String get port_helper_msg =>
      'डिफ़ॉल्ट -1 है जो यादृच्छिक संख्या को दर्शाता है। यदि आपने फ़ायरवॉल कॉन्फ़िगर किया है, तो इसे सेट करना अनुशंसित है।';

  @override
  String connect_request(Object client) {
    return '$client को कनेक्ट करने की अनुमति दें?';
  }

  @override
  String get connection_request_denied =>
      'कनेक्शन अस्वीकृत। उपयोगकर्ता ने पहुंच अस्वीकृत कर दी।';

  @override
  String get an_error_occurred => 'एक त्रुटि हुई';

  @override
  String get copy_to_clipboard => 'क्लिपबोर्ड पर कॉपी करें';

  @override
  String get view_logs => 'लॉग देखें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get rate_this_track => 'Rate this track';

  @override
  String get rating_like => 'Like';

  @override
  String get rating_dislike => 'Dislike';

  @override
  String get rating_save_failed => 'Couldn\'t save your rating — try again.';

  @override
  String rating_summary(int pct, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$pct% like this · $total ratings',
      one: '$pct% like this · 1 rating',
      zero: 'No ratings yet',
    );
    return '$_temp0';
  }

  @override
  String get no_default_metadata_provider_selected =>
      'आपने कोई डिफ़ॉल्ट मेटाडेटा प्रदाता सेट नहीं किया है';

  @override
  String get manage_metadata_providers => 'मेटाडेटा प्रदाताओं को प्रबंधित करें';

  @override
  String get open_link_in_browser => 'ब्राउज़र में लिंक खोलें?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'क्या आप निम्नलिखित लिंक खोलना चाहते हैं';

  @override
  String get unsafe_url_warning =>
      'अविश्वसनीय स्रोतों से लिंक खोलना असुरक्षित हो सकता है। सावधान रहें!\nआप लिंक को अपने क्लिपबोर्ड पर भी कॉपी कर सकते हैं।';

  @override
  String get copy_link => 'लिंक कॉपी करें';

  @override
  String get building_your_timeline =>
      'आपकी सुनने की आदतों के आधार पर आपकी टाइमलाइन बनाई जा रही है...';

  @override
  String get official => 'आधिकारिक';

  @override
  String author_name(Object author) {
    return 'लेखक: $author';
  }

  @override
  String get third_party => 'तृतीय-पक्ष';

  @override
  String get plugin_requires_authentication =>
      'प्लगइन को प्रमाणीकरण की आवश्यकता है';

  @override
  String get update_available => 'अपडेट उपलब्ध है';

  @override
  String get supports_scrobbling => 'स्क्रॉबलिंग का समर्थन करता है';

  @override
  String get plugin_scrobbling_info =>
      'यह प्लगइन आपके सुनने के इतिहास को उत्पन्न करने के लिए आपके संगीत को स्क्रॉबल करता है।';

  @override
  String get default_metadata_source => 'डिफ़ॉल्ट मेटाडेटा स्रोत';

  @override
  String get set_default_metadata_source => 'डिफ़ॉल्ट मेटाडेटा स्रोत सेट करें';

  @override
  String get default_audio_source => 'डिफ़ॉल्ट ऑडियो स्रोत';

  @override
  String get set_default_audio_source => 'डिफ़ॉल्ट ऑडियो स्रोत सेट करें';

  @override
  String get set_default => 'डिफ़ॉल्ट सेट करें';

  @override
  String get support => 'समर्थन';

  @override
  String get support_plugin_development => 'प्लगइन विकास का समर्थन करें';

  @override
  String can_access_name_api(Object name) {
    return '- **$name** API तक पहुंच सकता है';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'क्या आप इस प्लगइन को स्थापित करना चाहते हैं?';

  @override
  String get third_party_plugin_warning =>
      'यह प्लगइन एक तृतीय-पक्ष रिपॉजिटरी से है। कृपया सुनिश्चित करें कि आप इसे स्थापित करने से पहले स्रोत पर भरोसा करते हैं।';

  @override
  String get author => 'लेखक';

  @override
  String get this_plugin_can_do_following => 'यह प्लगइन निम्नलिखित कर सकता है';

  @override
  String get install => 'स्थापित करें';

  @override
  String get no_tracks_playing => 'वर्तमान में कोई ट्रैक नहीं चल रहा है';

  @override
  String get synced_lyrics_not_available =>
      'इस गाने के लिए सिंक्रनाइज़ किए गए बोल उपलब्ध नहीं हैं। कृपया';

  @override
  String get plain_lyrics => 'सादे बोल';

  @override
  String get tab_instead => 'टैब का उपयोग करें।';

  @override
  String get disclaimer => 'अस्वीकरण';

  @override
  String get third_party_plugin_dmca_notice =>
      'स्पॉट्यूब टीम किसी भी \"तृतीय-पक्ष\" प्लगइन के लिए कोई जिम्मेदारी (कानूनी सहित) नहीं लेती है।\nकृपया उन्हें अपने जोखिम पर उपयोग करें। किसी भी बग/समस्या के लिए, कृपया उन्हें प्लगइन रिपॉजिटरी को रिपोर्ट करें।\n\nयदि कोई \"तृतीय-पक्ष\" प्लगइन किसी सेवा/कानूनी इकाई के ToS/DMCA को तोड़ रहा है, तो कृपया \"तृतीय-पक्ष\" प्लगइन लेखक या होस्टिंग प्लेटफ़ॉर्म जैसे GitHub/Codeberg से कार्रवाई करने के लिए कहें। ऊपर सूचीबद्ध (\"तृतीय-पक्ष\" लेबल वाले) सभी सार्वजनिक/समुदाय-द्वारा-रखरखाव किए गए प्लगइन हैं। हम उन्हें क्यूरेट नहीं कर रहे हैं, इसलिए हम उन पर कोई कार्रवाई नहीं कर सकते हैं।\n\n';

  @override
  String get plugins => 'प्लगइन्स';

  @override
  String get paste_plugin_download_url =>
      'डाउनलोड यूआरएल या गिटहब/कोडबर्ग रेपो यूआरएल या .smplug फ़ाइल का सीधा लिंक पेस्ट करें';

  @override
  String get download_and_install_plugin_from_url =>
      'यूआरएल से प्लगइन डाउनलोड और स्थापित करें';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'प्लगइन जोड़ने में विफल: $error';
  }

  @override
  String get upload_plugin_from_file => 'फ़ाइल से प्लगइन अपलोड करें';

  @override
  String get installed => 'स्थापित';

  @override
  String get available_plugins => 'उपलब्ध प्लगइन';

  @override
  String get configure_plugins =>
      'अपने स्वयं के मेटाडेटा प्रदाता और ऑडियो स्रोत प्लगइन्स कॉन्फ़िगर करें';

  @override
  String get audio_scrobblers => 'ऑडियो स्क्रॉबलर्स';

  @override
  String get scrobbling => 'स्क्रॉबलिंग';

  @override
  String get source => 'स्रोत: ';

  @override
  String get uncompressed => 'असंपीड़ित';

  @override
  String get dab_music_source_description =>
      'ऑडियोफाइलों के लिए। उच्च-गुणवत्ता/बिना हानि वाले ऑडियो स्ट्रीम प्रदान करता है। सटीक ISRC आधारित ट्रैक मिलान।';

  @override
  String get confirm_age_18 => 'I am 18 or older';

  @override
  String get birth_year_hint => 'Birth year (e.g. 1990)';

  @override
  String get must_enter_valid_birth_year =>
      'Enter a valid birth year (e.g. 1990).';

  @override
  String get under_min_age_message =>
      'Sorry — DeeMusiq is only available to users 18 or older.';

  @override
  String get agree_privacy_policy => 'I agree to the Privacy Policy';

  @override
  String get must_confirm_age => 'You must confirm you are 18 or older.';

  @override
  String get must_agree_privacy_policy =>
      'You must agree to the Privacy Policy.';

  @override
  String get sign_in_with_google => 'Sign in with Google';

  @override
  String get google_sign_in_mobile_only =>
      'Google sign-in is available in the DeeMusiq mobile app. Sign in on your phone or tablet to use this feature.';

  @override
  String get continue_with_device_limited => 'Continue with device (limited)';

  @override
  String get offline_staying_on_device =>
      'Couldn\'t reach the backend. Continuing on this device with direct playback.';

  @override
  String get wallet_sync_failed_retry =>
      'Wallet sync failed. Please try again later.';

  @override
  String get its_a_drop_day => 'It\'s a drop day';

  @override
  String get artist_name_required => 'Enter your artist name.';

  @override
  String get takedown_request_title => 'Request takedown';

  @override
  String get takedown_request_body =>
      'Published songs are taken down by the DeeMusiq team. Tell us why this song should be removed — it stays live until the request is reviewed.';

  @override
  String get takedown_reason_hint =>
      'Reason (e.g. rights change, wrong upload)';

  @override
  String get takedown_reason_required => 'Enter a reason for the takedown.';

  @override
  String get takedown_request_sent =>
      'Takedown requested — the song stays live until it is reviewed.';

  @override
  String get skip_this_nonsense => 'इस माया को छोड़ें';

  @override
  String get freedom_of_music => '“संगीत की स्वतंत्रता”';

  @override
  String get freedom_of_music_palm => '“हाथ में संगीत की स्वतंत्रता”';

  @override
  String get get_started => 'आइए शुरू करें';

  @override
  String get endless_playback_description =>
      'क्रमबद्ध कतार के अंत में नए गाने स्वचालित रूप से जोड़ें';

  @override
  String get choose_your_region => 'अपना क्षेत्र चुनें';

  @override
  String get choose_your_region_description =>
      'यह DeeMusiq को आपके स्थान के लिए सही सामग्री दिखाने में मदद करेगा।';

  @override
  String get choose_your_language => 'अपनी भाषा चुनें';

  @override
  String get help_project_grow => 'इस परियोजना को बढ़ावा दें';

  @override
  String get help_project_grow_description =>
      'DeeMusiq एक ओपन सोर्स परियोजना है। आप इस परियोजना को योगदान देकर, बग रिपोर्ट करके या नई विशेषताओं का सुझाव देकर इस परियोजना को बढ़ा सकते हैं।';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'ओपन कलेक्टिव पर दान करें';

  @override
  String get install_a_metadata_provider => 'एक मेटाडेटा प्रदाता स्थापित करें';

  @override
  String get input_does_not_match_format =>
      'इनपुट आवश्यक प्रारूप से मेल नहीं खाता है';

  @override
  String get wallet => 'Wallet';

  @override
  String get notifications => 'Notifications';

  @override
  String get verified => 'Verified';

  @override
  String get refresh => 'Refresh';

  @override
  String get remove => 'Remove';

  @override
  String get report => 'Report';

  @override
  String get sign_in => 'Sign in';

  @override
  String get sign_out => 'Sign out';

  @override
  String get like => 'Like';

  @override
  String get liked => 'Liked';

  @override
  String get unknown_title => 'Unknown title';

  @override
  String get please_wait => 'Please wait…';

  @override
  String get verifying => 'Verifying…';

  @override
  String get get_tokens => 'Get tokens';

  @override
  String get continue_action => 'Continue';

  @override
  String get tokens_label => 'tokens';

  @override
  String token_balance(String balance) {
    return 'Balance: $balance tokens';
  }

  @override
  String get native_catalog => 'DeeMusiq';

  @override
  String get native_catalog_tagline => 'Exclusive DeeMusiq drops';

  @override
  String get artists_of_the_year => 'Artists of the Year';

  @override
  String get creator_studio => 'Creator Studio';

  @override
  String get ad_badge => 'Ad';

  @override
  String ad_remaining(int seconds) {
    return '${seconds}s';
  }

  @override
  String get ad_skip => 'Skip Ad';

  @override
  String ad_skip_in(int seconds) {
    return 'Skip in ${seconds}s';
  }

  @override
  String get creator_connect_title => 'Connect to become a creator';

  @override
  String get creator_connect_body =>
      'Creator Studio needs DeeMusiq\'s backend to be configured.';

  @override
  String get creator_google_sign_in_failed => 'Google sign-in failed';

  @override
  String get creator_become_title => 'Become a DeeMusiq creator';

  @override
  String get creator_become_body =>
      'Sign in with Google to claim your artist profile, submit songs, and track how they\'re doing. Your Google account also carries your likes and library across devices.';

  @override
  String get creator_studio_load_failed => 'Couldn\'t load your studio';

  @override
  String get creator_release_console => 'Release Console';

  @override
  String get creator_get_verified => 'Get Verified';

  @override
  String get creator_your_songs => 'Your songs';

  @override
  String get creator_profile_created => 'Creator profile created';

  @override
  String get creator_claim_title => 'Claim your artist name';

  @override
  String get creator_claim_body =>
      'This is how listeners will find you. Names are unique.';

  @override
  String get creator_artist_name_hint => 'Artist name';

  @override
  String get creator_bio_hint => 'Short bio (optional)';

  @override
  String get creator_create_profile => 'Create profile';

  @override
  String get creator_stat_songs => 'Songs';

  @override
  String get creator_stat_tokens_year => 'Tokens (yr)';

  @override
  String get creator_stat_rank_year => 'Rank (yr)';

  @override
  String get creator_file_picker_failed => 'Could not open file picker';

  @override
  String get creator_title_required => 'Title is required.';

  @override
  String get creator_pick_audio_required => 'Pick an audio file.';

  @override
  String get creator_pick_cover_required => 'Pick a cover image.';

  @override
  String get creator_pick_audio_missing => 'Pick the missing audio file.';

  @override
  String get creator_pick_cover_missing => 'Pick the missing cover image.';

  @override
  String get creator_upload_start_failed =>
      'Upload didn\'t start — please try again.';

  @override
  String get creator_uploaded_submit_hint => 'Uploaded! Tap Submit for review.';

  @override
  String get creator_upload_failed => 'Upload failed.';

  @override
  String get creator_upload_before_review =>
      'Upload audio and cover before review.';

  @override
  String get creator_submitted_for_review => 'Submitted for review';

  @override
  String get creator_submit_review_failed => 'Could not submit for review.';

  @override
  String get creator_submit_song_title => 'Submit a song';

  @override
  String get creator_submit_song_body =>
      'Pick an audio master (MP3 · M4A · AAC · WAV · FLAC · OGG · Opus · WebM · AIFF) and a cover image. The operator reviews the submission; once approved, you choose when to publish — then add payment, set your cut and track analytics below.';

  @override
  String get creator_song_title_hint => 'Song title';

  @override
  String get creator_description_hint => 'Description (optional)';

  @override
  String get creator_pick_audio => 'Pick audio file';

  @override
  String creator_audio_picked(String name) {
    return 'Audio: $name';
  }

  @override
  String get creator_pick_cover => 'Pick cover image';

  @override
  String creator_cover_picked(String name) {
    return 'Cover: $name';
  }

  @override
  String get creator_uploading => 'Uploading…';

  @override
  String get creator_upload => 'Upload';

  @override
  String get creator_retry_upload => 'Retry upload';

  @override
  String get creator_submitting => 'Submitting…';

  @override
  String get creator_submit_for_review => 'Submit for review';

  @override
  String get creator_no_songs => 'No songs yet — submit your first above.';

  @override
  String get creator_status_draft => 'Draft';

  @override
  String get creator_status_pending => 'In review';

  @override
  String get creator_status_approved => 'Approved';

  @override
  String get creator_status_scheduled => 'Scheduled';

  @override
  String get creator_status_published => 'Published';

  @override
  String get creator_status_hidden => 'Hidden / Cancelled';

  @override
  String creator_publishes_at(String date) {
    return 'Publishes $date';
  }

  @override
  String creator_audio_size(String size) {
    return '$size MB audio';
  }

  @override
  String creator_review_note(String note) {
    return 'Note: $note';
  }

  @override
  String creator_song_stats(int pushes, String tokens) {
    return '$pushes · $tokens tokens';
  }

  @override
  String get creator_open_release_console => 'Open Release Console';

  @override
  String get creator_song_removed => 'Song removed';

  @override
  String get payout_phone_invalid =>
      'Enter a valid phone number (e.g. +27 82 123 4567).';

  @override
  String get payout_destination_saved => 'Payment destination saved';

  @override
  String get payout_cut_range_hint => 'Cut must be 0–50 (30 = default)';

  @override
  String get payout_cut_request_sent => 'Cut request sent for approval';

  @override
  String get payout_enter_tokens => 'Enter tokens to cash out';

  @override
  String payout_request_result(String id, String status) {
    return 'Payout $id $status';
  }

  @override
  String payout_request_result_manual(String id, String status) {
    return 'Payout $id $status (manual review)';
  }

  @override
  String get payout_monetization => 'Monetization';

  @override
  String get payout_analytics_title => 'Payments & analytics';

  @override
  String payout_totals(
      String gross, String fees, String net, String tips, String listens) {
    return 'Gross $gross · fee $fees · net $net · $tips tips · $listens listens';
  }

  @override
  String get payout_destination_title => 'Payout destination';

  @override
  String payout_saved_method(String method) {
    return 'Saved: $method';
  }

  @override
  String get payout_method_payshap => 'PayShap';

  @override
  String get payout_method_bank => 'Bank transfer';

  @override
  String get payout_method_manual => 'Manual';

  @override
  String get payout_hint_payshap => 'PayShap phone number';

  @override
  String get payout_hint_bank => 'Account number / branch code';

  @override
  String get payout_hint_manual => 'Payout details';

  @override
  String get payout_platform_cut => 'Platform cut';

  @override
  String payout_cut_pending(String requested, int current) {
    return 'Request pending: $requested% (current $current%)';
  }

  @override
  String payout_cut_current(int cut, int keep) {
    return 'Current cut $cut% (artist keeps $keep%). Request 30% or a custom 0–50%.';
  }

  @override
  String get payout_request_cut => 'Request cut';

  @override
  String get payout_cash_out_title => 'Cash out (tokens → ZAR)';

  @override
  String get payout_balance_unavailable =>
      'Balance unavailable — connect backend to cash out.';

  @override
  String payout_balance_summary(int payable, String amount, int min,
      String received, String pending, String paid) {
    return 'Payable $payable tokens (≈ R$amount) · min $min · received $received · pending $pending · paid out $paid';
  }

  @override
  String get payout_tokens_hint => 'Tokens';

  @override
  String get payout_cash_out => 'Cash out';

  @override
  String get payout_settlement_hint =>
      'Settlement details (optional — uses saved method)';

  @override
  String get payout_history_empty => 'No payout requests yet.';

  @override
  String payout_history_entry(String tokens, String amount, String status) {
    return '$tokens tokens → ${amount}c · $status';
  }

  @override
  String payout_history_entry_ref(
      String tokens, String amount, String status, String reference) {
    return '$tokens tokens → ${amount}c · $status · $reference';
  }

  @override
  String get account_security => 'Account & security';

  @override
  String get account_created_verify =>
      'Account created — check your email to verify.';

  @override
  String get account_signed_in => 'Signed in.';

  @override
  String get account_create_email_title => 'Create an email account';

  @override
  String get account_have_one_sign_in => 'Have one? Sign in';

  @override
  String get account_email_body =>
      'An email + password lets you use this wallet on another device and recover it. Your password is never stored — only a hash.';

  @override
  String get account_password_hint => 'Password (12+ characters)';

  @override
  String get account_accept_terms =>
      'I accept the DeeMusiq Terms of Service and Privacy Policy.';

  @override
  String get account_create => 'Create account';

  @override
  String get account_totp_scan_hint =>
      'Scan or enter the secret in your authenticator app.';

  @override
  String get account_totp_enabled => 'Two-factor authentication enabled.';

  @override
  String get account_totp_title => 'Two-factor authentication (2FA)';

  @override
  String get account_totp_body =>
      'Use any authenticator app (Google Authenticator, Authy, Aegis…). 2FA also lets you recover your wallet on a new device.';

  @override
  String get account_stepup_password_body =>
      'Confirm your account password to continue.';

  @override
  String get account_stepup_password_hint => 'Account password';

  @override
  String get account_stepup_code_body =>
      'Enter a code from your current authenticator app to replace it.';

  @override
  String get account_stepup_code_hint => 'Current 6-digit code';

  @override
  String get account_totp_setup => 'Set up 2FA';

  @override
  String get account_totp_secret_body =>
      'Add this secret to your authenticator app:';

  @override
  String get account_secret_copied => 'Secret copied.';

  @override
  String get account_totp_code_hint => '6-digit code';

  @override
  String get account_totp_verify_enable => 'Verify & enable';

  @override
  String get account_recovered => 'Recovered — welcome back.';

  @override
  String get account_recovery_title => 'Recover with your authenticator';

  @override
  String get account_recovery_body =>
      'On a new device? Enter your account email and a current 2FA code to restore your wallet.';

  @override
  String get account_email_hint => 'Account email';

  @override
  String get account_recover_action => 'Recover wallet';

  @override
  String get account_google_title => 'Google Sign-In';

  @override
  String get account_google_signed_in => 'Signed in with Google.';

  @override
  String get account_google_signed_out =>
      'Signed out of Google. Synced data on this device was cleared.';

  @override
  String get account_google_connected_body =>
      'Connected. Your liked songs and playlists sync anonymously — only hashed IDs are stored, and playlist names travel inside the encrypted channel. No personal data leaves your device.';

  @override
  String get account_google_connect_body =>
      'Sign in with Google to sync your library across devices. We only store anonymized data (hashed song IDs; playlist names travel inside the encrypted channel). No email, name, or location is ever stored.';

  @override
  String get account_google_unconfigured_body =>
      'Google Sign-In needs backend connectivity. Connect to the DeeMusiq server to enable.';

  @override
  String get account_verify_link_sent =>
      'If your email needs verifying, a link is on its way.';

  @override
  String get account_reset_link_sent =>
      'If that email has an account, a reset link is on its way.';

  @override
  String get account_logged_out_all =>
      'Signed out on all devices. Synced data on this device was cleared.';

  @override
  String account_data_exported(String path) {
    return 'Data exported to $path';
  }

  @override
  String get account_export_failed => 'Export failed.';

  @override
  String get account_delete_confirm_title => 'Delete account?';

  @override
  String get account_delete_confirm_body =>
      'This permanently deletes your DeeMusiq account, wallet balance, history and linked accounts. This cannot be undone.';

  @override
  String get account_delete_forever => 'Delete forever';

  @override
  String get account_deleted => 'Account deleted.';

  @override
  String get account_security_card_title => 'Security';

  @override
  String get account_resend_verification => 'Resend verification email';

  @override
  String get account_reset_email_hint => 'Email for password reset';

  @override
  String get account_send_reset_link => 'Email me a password reset link';

  @override
  String get account_logout_all => 'Log out on all devices';

  @override
  String get account_export_data => 'Export my data (JSON)';

  @override
  String get account_delete => 'Delete account';

  @override
  String get privacy_heading => 'Privacy & data';

  @override
  String get privacy_offline_body =>
      'Connect a backend to manage consent, export, and deletion.';

  @override
  String privacy_consent_granted(String purpose) {
    return 'Consent $purpose granted';
  }

  @override
  String privacy_consent_withdrawn(String purpose) {
    return 'Consent $purpose withdrawn';
  }

  @override
  String get privacy_purpose_terms => 'terms';

  @override
  String get privacy_purpose_privacy => 'privacy';

  @override
  String get privacy_purpose_marketing => 'marketing';

  @override
  String get privacy_blurb_terms =>
      'Required to run the account. Withdrawing restricts processing.';

  @override
  String get privacy_blurb_privacy =>
      'Required privacy policy. Withdrawing restricts processing.';

  @override
  String get privacy_blurb_marketing => 'Opt-in recommendations and offers.';

  @override
  String get privacy_email_section => 'Email verification & hardening';

  @override
  String get privacy_verify_link_sent => 'Verification link sent';

  @override
  String get privacy_resend_verify => 'Resend verify link';

  @override
  String get privacy_code_sent => 'One-time code sent to email';

  @override
  String get privacy_request_code => 'Request login code';

  @override
  String get privacy_code_hint => '6-digit email code';

  @override
  String get privacy_code_confirmed => 'Code confirmed';

  @override
  String get privacy_confirm_code => 'Confirm code';

  @override
  String get privacy_verify_token_hint => 'Email-verify token (from link)';

  @override
  String get privacy_email_verified => 'Email verified';

  @override
  String get privacy_verify_with_token => 'Verify email with token';

  @override
  String get privacy_reset_section => 'Password reset (emailed token)';

  @override
  String get privacy_reset_token_hint => 'Reset token from email';

  @override
  String get privacy_new_password_hint => 'New password (12+ chars)';

  @override
  String get privacy_reset_requirements => 'Token + 12-char password required';

  @override
  String get privacy_password_reset => 'Password reset';

  @override
  String get privacy_reset_action => 'Reset';

  @override
  String privacy_export_ready(int count) {
    return 'Export ready: $count sections';
  }

  @override
  String get privacy_export_data => 'Export my data';

  @override
  String get privacy_delete_body =>
      'Anonymizes everything (GDPR Art. 17). JWT dies immediately. Cannot undo.';

  @override
  String get release_load_failed => 'Couldn\'t load your releases';

  @override
  String get release_empty_title => 'Nothing to release yet';

  @override
  String get release_empty_body =>
      'Once an operator approves your submitted songs, they\'ll appear here for you to publish or schedule.';

  @override
  String get release_cancel_title => 'Cancel release?';

  @override
  String get release_cancel_body =>
      'The song will be hidden from the catalog. You can resubmit later.';

  @override
  String get release_keep => 'Keep';

  @override
  String get release_cancel_action => 'Cancel release';

  @override
  String release_scheduled_for(String date) {
    return 'Scheduled for $date';
  }

  @override
  String get release_approved_ready => 'Approved — ready to publish';

  @override
  String get release_publish_now => 'Publish Now';

  @override
  String get release_reschedule => 'Reschedule';

  @override
  String get release_schedule => 'Schedule';

  @override
  String get release_schedule_title => 'Schedule release';

  @override
  String get release_schedule_body => 'Pick when this song goes live.';

  @override
  String get release_pick_date => 'Pick a date';

  @override
  String get release_date => 'Release date';

  @override
  String get release_time => 'Release time';

  @override
  String get verification_pick_failed => 'Could not access camera/gallery';

  @override
  String get verification_pick_first => 'Pick a photo first.';

  @override
  String get verification_photo_uploaded =>
      'Photo uploaded. Fill in the form and submit.';

  @override
  String get verification_upload_first => 'Upload your proof photo first.';

  @override
  String get verification_fields_required =>
      'Legal name and country are required.';

  @override
  String get verification_submitted =>
      'Submitted. The DeeMusiq team will review shortly.';

  @override
  String get verification_done => 'You\'re verified!';

  @override
  String get verification_how_title => 'How verification works';

  @override
  String get verification_how_body =>
      '1. Take a photo of yourself holding a sign that says \"deemusiq\" (and your artist name).\n2. Upload the photo below.\n3. Submit the form. An operator reviews within a few days.\n4. On approval, the verified badge appears next to your name.';

  @override
  String verification_status(String status) {
    return 'Status: $status';
  }

  @override
  String get verification_proof_title => 'Proof photo';

  @override
  String get verification_no_photo => 'No photo selected yet.';

  @override
  String get verification_take_photo => 'Take photo';

  @override
  String get verification_from_gallery => 'From gallery';

  @override
  String get verification_upload_proof => 'Upload proof';

  @override
  String get verification_details_title => 'Your details';

  @override
  String get verification_legal_name_hint =>
      'Legal name (as it appears on your ID)';

  @override
  String get verification_country_hint => 'Country (e.g. South Africa)';

  @override
  String get verification_socials_hint =>
      'Social links (optional): instagram: https://..., youtube: https://...';

  @override
  String get wallet_refresh_failed => 'Couldn\'t refresh your wallet';

  @override
  String get wallet_retrying => 'Retrying…';

  @override
  String get wallet_tokens_title => 'DeeMusiq tokens';

  @override
  String wallet_prices_region(String region) {
    return 'Prices shown for $region.';
  }

  @override
  String get wallet_buy_tokens => 'Buy tokens';

  @override
  String get wallet_trending => 'Trending';

  @override
  String get wallet_recent_activity => 'Recent activity';

  @override
  String wallet_activity_totals(int purchased, int spent) {
    return '$purchased in · $spent out';
  }

  @override
  String get wallet_show_less => 'Show less';

  @override
  String get wallet_see_all => 'See all';

  @override
  String get wallet_token_store => 'Token store';

  @override
  String get wallet_token_store_sub => 'Buy regional packs';

  @override
  String get wallet_linked_accounts => 'Linked accounts';

  @override
  String get wallet_linked_connect => 'Connect a service';

  @override
  String wallet_linked_connected(int count) {
    return '$count connected';
  }

  @override
  String get wallet_security_sub => 'Sign in, 2FA, recovery';

  @override
  String get wallet_creators_supported => 'Creators you support';

  @override
  String get wallet_creators_sub => 'See your impact';

  @override
  String get wallet_trending_pushes => 'Trending pushes';

  @override
  String get wallet_pushes_sub => 'Most-pushed songs';

  @override
  String get wallet_no_activity => 'No activity yet';

  @override
  String get wallet_no_activity_body =>
      'Buy tokens, then push your favourite songs to support artists.';

  @override
  String get wallet_buy_first => 'Buy your first tokens';

  @override
  String get wallet_integrity_warning =>
      'This app may have been modified — payments are disabled. Reinstall the official DeeMusiq to use your wallet.';

  @override
  String get rewards_title => 'Listening rewards';

  @override
  String rewards_earned_today(int earned, int cap) {
    return 'Earned today: $earned / $cap tokens';
  }

  @override
  String rewards_lifetime(int count) {
    return '$count tokens earned all-time';
  }

  @override
  String rewards_per_play(int count) {
    return '$count tokens per verified play';
  }

  @override
  String get rewards_explainer =>
      'Tokens are credited automatically for verified listening — there\'s nothing to claim.';

  @override
  String get rewards_taper_notice => 'New accounts earn at a reduced rate.';

  @override
  String get rewards_load_failed => 'Couldn\'t load rewards';

  @override
  String get rewards_details => 'Details';

  @override
  String get leaderboard_empty_title => 'Nothing trending yet';

  @override
  String get leaderboard_empty_body =>
      'Push a song from its menu or the player to start the board.';

  @override
  String get leaderboard_explainer =>
      'The most-pushed songs rise to the top. Push your favourites to move them up the board.';

  @override
  String get leaderboard_load_failed => 'Couldn\'t load the board';

  @override
  String get leaderboard_offline_title => 'Your pushes (offline)';

  @override
  String leaderboard_push_count(String artist, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$artist · $count pushes',
      one: '$artist · $count push',
    );
    return '$_temp0';
  }

  @override
  String get push_action => 'Push';

  @override
  String get store_region_body =>
      'Token packs are priced fairly per region (purchasing-power adjusted).';

  @override
  String get store_za_only =>
      'DeeMusiq top-ups are available in South Africa (ZAR) for now.';

  @override
  String store_prices_for(String region) {
    return 'Prices for $region · adjusted for your region.';
  }

  @override
  String get store_payment_methods_title => 'Cards & crypto';

  @override
  String get store_payment_methods_body =>
      'Pay with PayShap instant EFT, PayFast/Stripe cards, or Monero, Ethereum, Bitcoin and USDT. Top-ups are processed securely online by the DeeMusiq backend and are available in South Africa for now — tokens appear once your payment confirms.';

  @override
  String store_pack_tokens(String count) {
    return '$count tokens';
  }

  @override
  String get store_popular => 'Popular';

  @override
  String store_pack_bonus(String label, int tokens, int bonus) {
    return '$label · $tokens + $bonus bonus';
  }

  @override
  String get artists_connect_title => 'Connect to see the board';

  @override
  String get artists_connect_body =>
      'The artist leaderboard is live once DeeMusiq\'s backend is configured.';

  @override
  String get artists_hall_of_fame => 'Hall of Fame';

  @override
  String get artists_hof_subtitle => 'Best Artist of each past year.';

  @override
  String get artists_hof_empty => 'No past winners yet.';

  @override
  String artists_no_boosts(int year) {
    return 'No boosts yet in $year';
  }

  @override
  String artists_no_boosts_body(int year) {
    return 'Boost an artist you love to start the $year race.';
  }

  @override
  String artists_leading(int year) {
    return 'Leading $year';
  }

  @override
  String artists_supporters(String tokens, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count supporters',
      one: '$count supporter',
    );
    return '$tokens tokens · $_temp0';
  }

  @override
  String get boost_action => 'Boost';

  @override
  String get supported_tokens_given => 'tokens given';

  @override
  String get supported_creators_backed => 'creators backed';

  @override
  String get supported_empty_title => 'No creators supported yet';

  @override
  String get supported_empty_body =>
      'Push a song or support an artist directly — your tokens show up here.';

  @override
  String supported_sent(int tokens, String name) {
    return 'Sent $tokens tokens to $name';
  }

  @override
  String get supported_send_failed =>
      'Couldn\'t send the tokens — refresh your wallet and try again.';

  @override
  String supported_contributions(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contributions',
      one: '$count contribution',
    );
    return '$_temp0 · $time';
  }

  @override
  String get supported_support_more => 'Support more';

  @override
  String supported_dialog_title(String name) {
    return 'Support $name';
  }

  @override
  String get supported_dialog_body => 'Choose how many tokens to send.';

  @override
  String supported_need_more(int count) {
    return 'You need $count more tokens for this.';
  }

  @override
  String supported_send_amount(int amount) {
    return 'Send $amount';
  }

  @override
  String get linked_connect_body =>
      'Connect your accounts on other services to bring your playlists and favourites into DeeMusiq. Connecting opens that provider\'s secure login (OAuth) in your browser, then returns you here.';

  @override
  String get linked_offline_body =>
      'Account linking needs a DeeMusiq connection — this build is offline, so connecting is disabled. You can still disconnect accounts stored on this device.';

  @override
  String linked_finish_browser(String provider) {
    return 'Finish connecting $provider in your browser';
  }

  @override
  String get linked_browser_failed => 'Couldn\'t open your browser — try again';

  @override
  String get linked_load_failed => 'Failed to load linked accounts';

  @override
  String linked_disconnected(String provider) {
    return '$provider disconnected';
  }

  @override
  String get linked_provider_not_enabled =>
      'This provider isn\'t enabled by the DeeMusiq operator yet — try another one or check back later.';

  @override
  String linked_connected_as(String name) {
    return 'Connected as $name';
  }

  @override
  String get linked_disconnecting => 'Disconnecting…';

  @override
  String get linked_connecting => 'Connecting…';

  @override
  String get comments_title => 'Comments';

  @override
  String get comments_empty_title => 'No comments yet';

  @override
  String get comments_empty_body => 'Be the first to share what you think.';

  @override
  String get comments_load_more_failed => 'Couldn\'t load more comments.';

  @override
  String get comments_load_more => 'Load more comments';

  @override
  String get comments_sign_in_body => 'Sign in to join the conversation.';

  @override
  String get comments_post_failed => 'Couldn\'t post your comment — try again.';

  @override
  String get comments_add_hint => 'Add a comment…';

  @override
  String get comments_reply_hint => 'Write a reply…';

  @override
  String get comments_post => 'Post';

  @override
  String get comments_reply => 'Reply';

  @override
  String get comments_listener => 'Listener';

  @override
  String comments_listener_named(String label) {
    return 'Listener $label';
  }

  @override
  String comments_replies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '$count reply',
    );
    return '$_temp0';
  }

  @override
  String get comments_no_replies => 'No replies yet.';

  @override
  String get purchase_confirmed =>
      'Payment confirmed — tokens added to your wallet 🎉';

  @override
  String purchase_added(int count) {
    return 'Added $count tokens 🎉';
  }

  @override
  String get purchase_phone_invalid =>
      'That phone number doesn\'t look right — use a number like +27 82 123 4567.';

  @override
  String purchase_title(int count) {
    return 'Buy $count tokens';
  }

  @override
  String get purchase_processing => 'Processing…';

  @override
  String get purchase_try_another => 'Try another method';

  @override
  String get purchase_open_checkout => 'Open checkout';

  @override
  String purchase_bonus_included(int count) {
    return 'incl. $count bonus';
  }

  @override
  String get purchase_choose_method => 'Choose how to pay';

  @override
  String get purchase_phone_label => 'PayShap phone number (optional)';

  @override
  String get purchase_phone_hint => '+27 82 123 4567';

  @override
  String get purchase_phone_body =>
      'We\'ll send the payment request to this number. Leave blank to reuse your saved number.';

  @override
  String get purchase_unavailable => 'Unavailable right now';

  @override
  String get purchase_awaiting_deposit => 'Awaiting deposit';

  @override
  String get purchase_checkout_failed => 'Couldn\'t start checkout';

  @override
  String get purchase_almost_there => 'Almost there';

  @override
  String purchase_amount(String amount) {
    return 'Amount: $amount';
  }

  @override
  String get purchase_address_copied => 'Address copied';

  @override
  String get purchase_no_wallet =>
      'No receiving wallet configured yet — set one in the backend / DEEMUSIQ_WALLET.md to accept this asset.';

  @override
  String purchase_reference_pending(String reference) {
    return 'Reference $reference · tokens appear automatically once the payment confirms.';
  }

  @override
  String purchase_reference(String reference) {
    return 'Reference $reference';
  }

  @override
  String boost_success(String name, int tokens) {
    return 'Boosted $name with $tokens tokens';
  }

  @override
  String get boost_failed => 'Couldn\'t boost right now';

  @override
  String boost_dialog_title(String name) {
    return 'Boost $name';
  }

  @override
  String get boost_dialog_body =>
      'Spend tokens to move this artist up the yearly leaderboard.';

  @override
  String boost_amount(int amount) {
    return 'Boost $amount';
  }

  @override
  String get boost_artist_tooltip => 'Boost this artist with tokens';

  @override
  String push_success(String title, int amount) {
    return 'Pushed \"$title\" with $amount tokens 🚀';
  }

  @override
  String get push_not_enough => 'Not enough tokens for that push';

  @override
  String get push_failed =>
      'Something went wrong — refresh your wallet before trying again.';

  @override
  String get push_dialog_title => 'Push this song';

  @override
  String get push_how_many => 'How many tokens?';

  @override
  String push_explainer(String artist) {
    return 'Pushing boosts this song on the DeeMusiq trending board and supports $artist.';
  }

  @override
  String get push_the_artist => 'the artist';

  @override
  String push_need_more(int count) {
    return 'You need $count more tokens for this push.';
  }

  @override
  String get push_pushing => 'Pushing…';

  @override
  String push_amount(int amount) {
    return 'Push $amount';
  }

  @override
  String get app_lock_title => 'DeeMusiq is locked';

  @override
  String get app_lock_body =>
      'Use your fingerprint, face or device PIN to continue.';

  @override
  String get app_lock_unlock => 'Unlock';

  @override
  String get app_lock_failed => 'Unlock failed — try again.';

  @override
  String get for_you_unlike_failed => 'Couldn\'t remove the like — try again';

  @override
  String get for_you_like_failed => 'Couldn\'t save the like — try again';

  @override
  String get for_you_title => 'For You';

  @override
  String get for_you_gmail_linked => 'Gmail linked';

  @override
  String get for_you_gmail_prompt => 'Sign in with Gmail for smarter picks';

  @override
  String get for_you_empty =>
      'Like songs to train For You — picks appear here.';

  @override
  String get notifications_offline_title => 'You\'re offline';

  @override
  String get notifications_offline_body =>
      'Notifications live on DeeMusiq — connect to the internet and they\'ll show up here.';

  @override
  String get notifications_empty_title => 'No notifications yet';

  @override
  String get notifications_empty_body =>
      'Payouts, publishes, follows and replies will land here.';

  @override
  String get notifications_refresh_failed => 'Couldn\'t refresh notifications.';

  @override
  String get notifications_mark_all_read => 'Mark all read';

  @override
  String get security_heading => 'Security & personalization';

  @override
  String get security_biometrics_unavailable => 'Biometrics unavailable';

  @override
  String get security_no_biometrics_enrolled =>
      'No fingerprint or face unlock is enrolled on this device. Set one up in your system settings first.';

  @override
  String get security_unlock_prompt_reason =>
      'Enable fingerprint unlock for DeeMusiq';

  @override
  String get security_fingerprint_unlock => 'Fingerprint unlock';

  @override
  String get security_lock_enabled =>
      'DeeMusiq locks on start and after 2 min away.';

  @override
  String security_biometrics_available(String biometrics) {
    return 'Available on this device ($biometrics). Enable to require fingerprint / face / PIN on start.';
  }

  @override
  String security_no_biometrics(String biometrics) {
    return 'No biometrics enrolled on this device ($biometrics).';
  }

  @override
  String get security_biometrics_none => 'none detected';

  @override
  String get security_gmail_title => 'Gmail personalization';

  @override
  String security_gmail_linked(int count) {
    return 'linked · $count likes';
  }

  @override
  String get security_gmail_not_linked => 'not linked';

  @override
  String get security_gmail_body =>
      'Sign in with Google (Creator Studio or Account) to carry likes and listening history across devices — For You recommendations follow your Gmail identity.';

  @override
  String get security_google_active => 'Google session active on this device.';

  @override
  String get security_google_inactive => 'Google session not active.';

  @override
  String get storage_heading => 'Storage';

  @override
  String get storage_downloaded_music => 'Downloaded music';

  @override
  String get storage_scanning => 'Scanning…';

  @override
  String storage_usage(String bytes, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files',
      one: '$count file',
    );
    return '$bytes across $_temp0';
  }

  @override
  String get storage_license_title => 'Offline playback license';

  @override
  String storage_license_valid(String date) {
    return 'Offline license valid until $date';
  }

  @override
  String storage_license_grace(String date) {
    return 'Offline license expired — grace period, reconnect to renew (last confirmed $date)';
  }

  @override
  String storage_license_locked(String date) {
    return 'Offline playback locked since $date — connect to the internet to renew the license';
  }

  @override
  String get storage_license_unconfirmed =>
      'Offline license not active (no backend confirmation yet)';

  @override
  String get storage_pending_sync => 'Pending sync';

  @override
  String storage_pending_sync_body(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actions',
      one: '$count action',
    );
    return '$_temp0 will sync when you\'re back online';
  }

  @override
  String get storage_delete_title => 'Delete download';

  @override
  String storage_delete_message(String name, String size) {
    return 'Delete \"$name\" ($size)? This frees the space but the song won\'t be playable offline anymore.';
  }

  @override
  String get storage_clear_all => 'Clear all downloads';

  @override
  String storage_clear_all_message(int count, String size) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count downloaded files',
      one: '$count downloaded file',
    );
    return 'Delete all $_temp0 ($size)? They won\'t be playable offline anymore.';
  }

  @override
  String storage_scan_failed(String error) {
    return 'Could not scan downloads: $error';
  }

  @override
  String get pairing_title => 'Paired devices';

  @override
  String get pairing_empty =>
      'No devices paired. Approving a Connect request pairs it.';

  @override
  String pairing_count(int count) {
    return '$count paired — revoking also drops its HTTP access token.';
  }

  @override
  String get pairing_revoke_all => 'Revoke all pairings';

  @override
  String get pairing_revoke => 'Revoke pairing';

  @override
  String get playback_youtube_quality => 'YouTube Audio Quality';

  @override
  String get about_built_on => 'Built on';

  @override
  String get about_website => 'Website';

  @override
  String get about_made_in_sa => 'Made with ❤️ in South Africa 🇿🇦';

  @override
  String get share_nearby_title => 'Send to nearby device';

  @override
  String get share_nearby_empty =>
      'No nearby devices found. Open DeeMusiq on the other device and make sure Connect is enabled on both.';

  @override
  String share_nearby_sent(String name) {
    return 'Shared with $name';
  }

  @override
  String share_nearby_declined(String name) {
    return '$name declined the share';
  }

  @override
  String share_nearby_unreachable(String name) {
    return 'Couldn\'t reach $name';
  }

  @override
  String get age_restriction_title => 'Age Restriction';

  @override
  String get age_restriction_explicit =>
      'This application may contain explicit music content.';

  @override
  String get age_restriction_fpb =>
      'In compliance with the South African Films and Publications Act (FPB), you must be 18 years or older to access explicit content.';

  @override
  String get age_restriction_confirm =>
      'By proceeding, you confirm that you are at least 18 years old.';

  @override
  String get age_restriction_under => 'I am under 18';

  @override
  String get report_artist => 'Report artist';

  @override
  String tempo_speed(String value) {
    return 'Speed: ${value}x';
  }

  @override
  String tempo_pitch(String value) {
    return 'Pitch: ${value}x';
  }

  @override
  String get seek_to_timestamp => 'Jump to time';

  @override
  String get seek_timestamp_hint => 'mm:ss (e.g. 1:23)';

  @override
  String get seek_timestamp_invalid => 'Use mm:ss, e.g. 1:23';

  @override
  String get logs_clear => 'Clear logs';

  @override
  String get logs_clear_message =>
      'Delete all stored logs? This cannot be undone.';

  @override
  String home_listening_streak(int days) {
    return '🔥 $days-day listening streak';
  }

  @override
  String get metadata_providers_title => 'Metadata Providers';

  @override
  String get metadata_providers_removed_body =>
      'External plugins have been removed. DeeMusiq uses its native backend for metadata.';

  @override
  String get audio_error_servers_unreachable =>
      'Couldn\'t reach DeeMusiq servers — check your connection and try again';

  @override
  String get audio_error_unavailable_retry =>
      'Playback unavailable — retry or download this track';

  @override
  String get audio_error_connection_timeout =>
      'Connection timed out — retrying...';

  @override
  String get audio_error_connection_refused =>
      'Connection refused — trying another source...';

  @override
  String get audio_error_no_internet =>
      'No internet connection — please check your network';

  @override
  String get audio_error_network => 'Network error — retrying...';

  @override
  String get audio_error_trying_next_source =>
      'Unable to play this track — trying next source...';

  @override
  String get audio_error_track_unavailable =>
      'This track is unavailable — skipping to next';

  @override
  String get audio_error_track_not_found =>
      'Track not found — skipping to next';

  @override
  String get audio_error_track_removed =>
      'This track has been removed — skipping to next';

  @override
  String get audio_error_rate_limited =>
      'Rate limited — waiting before retrying...';

  @override
  String get audio_error_track_protected =>
      'This track is protected and cannot be played';

  @override
  String get audio_error_track_corrupt =>
      'Track file appears to be corrupt — skipping to next';

  @override
  String get audio_error_engine_start =>
      'Audio engine failed to start — please restart the app';

  @override
  String get audio_error_output_device =>
      'Audio output error — check your speakers or headphones';

  @override
  String get audio_error_unsupported_format =>
      'Unsupported audio format — skipping to next';

  @override
  String get audio_error_playback_retrying => 'Playback error — retrying...';

  @override
  String get audio_error_generic => 'Something went wrong — please try again';

  @override
  String get audio_error_multiple_failed =>
      'Multiple tracks failed to play — check your connection and try again';

  @override
  String get audio_error_switching_track => 'Switching to next track...';

  @override
  String get audio_error_playback_restored => 'Playback restored';

  @override
  String get audio_error_engine_restart =>
      'Audio engine error — please restart the app if this persists';

  @override
  String get audio_error_download_requested =>
      'Download requested — retry when it is ready';

  @override
  String audio_error_retrying_in(int seconds, int attempt, int max) {
    return 'Retrying in ${seconds}s... ($attempt/$max)';
  }

  @override
  String get audio_error_fallback_source =>
      'DeeMusiq servers unreachable — playing from YouTube';

  @override
  String get profile_linked_connect_hint => 'Connect your Google account';

  @override
  String get username_required => 'Username is required';

  @override
  String get password_required => 'Password is required';

  @override
  String get report_dialog_title => 'Report content';

  @override
  String get report_submitted => 'Report submitted. Thank you.';

  @override
  String get report_network_error => 'Network error';

  @override
  String report_what_wrong(String label) {
    return 'What\'s wrong with $label?';
  }

  @override
  String get report_reason_label => 'Reason';

  @override
  String get report_reason_spam => 'Spam or misleading';

  @override
  String get report_reason_copyright => 'Copyright / DMCA';

  @override
  String get report_reason_harassment => 'Harassment or hate';

  @override
  String get report_reason_csam => 'Child safety (CSAM)';

  @override
  String get report_reason_illegal => 'Other illegal content';

  @override
  String get report_reason_other => 'Other';

  @override
  String get report_details_label => 'Details (optional)';

  @override
  String get report_details_hint => 'Tell us what happened';

  @override
  String get report_evidence_label =>
      'Evidence URL (required for copyright claims)';

  @override
  String get report_submitting => 'Submitting…';

  @override
  String get time_just_now => 'just now';

  @override
  String time_minutes_ago(int count) {
    return '${count}m ago';
  }

  @override
  String time_hours_ago(int count) {
    return '${count}h ago';
  }

  @override
  String time_days_ago(int count) {
    return '${count}d ago';
  }

  @override
  String time_weeks_ago(int count) {
    return '${count}w ago';
  }

  @override
  String time_months_ago(int count) {
    return '${count}mo ago';
  }

  @override
  String time_years_ago(int count) {
    return '${count}y ago';
  }

  @override
  String get auth_mfa_required => 'अपना प्रमाणीकरण कोड दर्ज करें';

  @override
  String get auth_mfa_body =>
      'अपना ऑथेंटिकेटर ऐप खोलें और साइन इन पूरा करने के लिए 6 अंकों का कोड दर्ज करें।';

  @override
  String get auth_mfa_verify_action => 'सत्यापित करें';

  @override
  String get supporters_section_title => 'Top Supporters';

  @override
  String get supporters_empty =>
      'No supporters yet — be the first to back this artist.';

  @override
  String get supporters_load_failed => 'Couldn\'t load supporters';

  @override
  String get supporter_tier_gold => 'Gold';

  @override
  String get supporter_tier_silver => 'Silver';

  @override
  String get supporter_tier_bronze => 'Bronze';

  @override
  String get supporter_top_badge => 'Top supporter';

  @override
  String supporter_status_line(int rank, String tier) {
    return 'You\'re supporter #$rank · $tier tier';
  }

  @override
  String supporter_status_rank_only(int rank) {
    return 'You\'re supporter #$rank';
  }

  @override
  String get region_filter_global => 'Global';

  @override
  String region_filter_my_region(String region) {
    return 'My region ($region)';
  }

  @override
  String get normalize_volume => 'Normalize volume';

  @override
  String get normalize_volume_description =>
      'Even out loudness between tracks — measured gain on catalog songs, dynamic normalization elsewhere.';

  @override
  String get data_saver => 'Data saver';

  @override
  String get data_saver_description =>
      'Play lower-bitrate audio, shrink buffers and skip prefetching to use less data.';

  @override
  String get data_saver_off => 'Off';

  @override
  String get data_saver_on => 'On';

  @override
  String get data_saver_auto => 'Auto on metered';

  @override
  String get now_playing_lite => 'Lite';

  @override
  String get now_playing_lite_tooltip =>
      'Playing the lite rendition to save data';

  @override
  String payout_pending_settlement(int tokens) {
    return 'Pending settlement: $tokens tokens';
  }

  @override
  String get payout_settlement_explainer =>
      'Tips become payable after a 7-day settlement window.';
}
