// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get guest => 'விருந்தினர்';

  @override
  String get browse => 'உலாவு';

  @override
  String get search => 'தேடுக';

  @override
  String get library => 'நூலகம்';

  @override
  String get lyrics => 'பாடல் வரிகள்';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get genre_categories_filter => 'வகைகள் அல்லது பாணிகளை வடிகட்டுக...';

  @override
  String get genre => 'பாணி';

  @override
  String get personalized => 'தனிப்பயனாக்கப்பட்ட';

  @override
  String get featured => 'சிறப்பிடம் பெற்ற';

  @override
  String get new_releases => 'புதிய வெளியீடுகள்';

  @override
  String get songs => 'பாடல்கள்';

  @override
  String playing_track(Object track) {
    return '$track இயங்குகிறது';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'இது தற்போதைய வரிசையை அழிக்கும். $track_length பாடல்கள் நீக்கப்படும்\nதொடர விரும்புகிறீர்களா?';
  }

  @override
  String get load_more => 'மேலும் ஏற்றுக';

  @override
  String get playlists => 'பாடல் பட்டியல்கள்';

  @override
  String get artists => 'கலைஞர்கள்';

  @override
  String get albums => 'ஆல்பங்கள்';

  @override
  String get tracks => 'பாடல்கள்';

  @override
  String get downloads => 'பதிவிறக்கங்கள்';

  @override
  String get filter_playlists => 'உங்கள் பாடல் பட்டியல்களை வடிகட்டுக...';

  @override
  String get liked_tracks => 'விரும்பிய பாடல்கள்';

  @override
  String get liked_tracks_description => 'உங்கள் விரும்பிய பாடல்கள் அனைத்தும்';

  @override
  String get playlist => 'பாடல் பட்டியல்';

  @override
  String get create_a_playlist => 'பாடல் பட்டியலை உருவாக்குக';

  @override
  String get update_playlist => 'பாடல் பட்டியலைப் புதுப்பிக்க';

  @override
  String get create => 'உருவாக்கு';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get update => 'புதுப்பி';

  @override
  String get playlist_name => 'பாடல் பட்டியல் பெயர்';

  @override
  String get name_of_playlist => 'பாடல் பட்டியலின் பெயர்';

  @override
  String get description => 'விளக்கம்';

  @override
  String get public => 'பொது';

  @override
  String get collaborative => 'கூட்டு';

  @override
  String get search_local_tracks => 'உள்ளூர் பாடல்களைத் தேடுக...';

  @override
  String get play => 'இயக்கு';

  @override
  String get delete => 'அழி';

  @override
  String get none => 'எதுவுமில்லை';

  @override
  String get sort_a_z => 'A-Z வரிசைப்படுத்து';

  @override
  String get sort_z_a => 'Z-A வரிசைப்படுத்து';

  @override
  String get sort_artist => 'கலைஞர் மூலம் வரிசைப்படுத்து';

  @override
  String get sort_album => 'ஆல்பம் மூலம் வரிசைப்படுத்து';

  @override
  String get sort_duration => 'கால அளவு மூலம் வரிசைப்படுத்து';

  @override
  String get sort_tracks => 'பாடல்களை வரிசைப்படுத்து';

  @override
  String currently_downloading(Object tracks_length) {
    return 'தற்போது பதிவிறக்குகிறது ($tracks_length)';
  }

  @override
  String get cancel_all => 'அனைத்தையும் ரத்து செய்';

  @override
  String get filter_artist => 'கலைஞர்களை வடிகட்டுக...';

  @override
  String followers(Object followers) {
    return '$followers பின்தொடர்பவர்கள்';
  }

  @override
  String get add_artist_to_blacklist => 'கலைஞரை தடைப்பட்டியலில் சேர்க்க';

  @override
  String get top_tracks => 'சிறந்த பாடல்கள்';

  @override
  String get fans_also_like => 'ரசிகர்கள் விரும்புவது';

  @override
  String get loading => 'ஏற்றுகிறது...';

  @override
  String get artist => 'கலைஞர்';

  @override
  String get blacklisted => 'தடைப்பட்டியலில் உள்ளது';

  @override
  String get following => 'பின்தொடர்கிறது';

  @override
  String get follow => 'பின்தொடர்';

  @override
  String get artist_url_copied =>
      'கலைஞர் URL கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks பாடல்கள் வரிசையில் சேர்க்கப்பட்டன';
  }

  @override
  String get filter_albums => 'ஆல்பங்களை வடிகட்டுக...';

  @override
  String get synced => 'ஒத்திசைக்கப்பட்டது';

  @override
  String get plain => 'சாதாரண';

  @override
  String get shuffle => 'கலக்கு';

  @override
  String get search_tracks => 'பாடல்களைத் தேடுக...';

  @override
  String get released => 'வெளியிடப்பட்டது';

  @override
  String error(Object error) {
    return 'பிழை $error';
  }

  @override
  String get title => 'தலைப்பு';

  @override
  String get time => 'நேரம்';

  @override
  String get more_actions => 'மேலும் செயல்கள்';

  @override
  String download_count(Object count) {
    return 'பதிவிறக்கு ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return '($count) பாடல் பட்டியலில் சேர்';
  }

  @override
  String add_count_to_queue(Object count) {
    return '($count) வரிசையில் சேர்';
  }

  @override
  String play_count_next(Object count) {
    return '($count) அடுத்து இயக்கு';
  }

  @override
  String get album => 'ஆல்பம்';

  @override
  String copied_to_clipboard(Object data) {
    return '$data கிளிப்போர்டுக்கு நகலெடுக்கப்பட்டது';
  }

  @override
  String add_to_following_playlists(Object track) {
    return '$track பின்வரும் பாடல் பட்டியல்களில் சேர்';
  }

  @override
  String get add => 'சேர்';

  @override
  String added_track_to_queue(Object track) {
    return '$track வரிசையில் சேர்க்கப்பட்டது';
  }

  @override
  String get add_to_queue => 'வரிசையில் சேர்';

  @override
  String track_will_play_next(Object track) {
    return '$track அடுத்து இயக்கப்படும்';
  }

  @override
  String get play_next => 'அடுத்து இயக்கு';

  @override
  String removed_track_from_queue(Object track) {
    return '$track வரிசையிலிருந்து நீக்கப்பட்டது';
  }

  @override
  String get remove_from_queue => 'வரிசையிலிருந்து நீக்கு';

  @override
  String get remove_from_favorites => 'பிடித்தவையிலிருந்து நீக்கு';

  @override
  String get save_as_favorite => 'பிடித்தவையாக சேமி';

  @override
  String get add_to_playlist => 'பாடல் பட்டியலில் சேர்';

  @override
  String get remove_from_playlist => 'பாடல் பட்டியலிலிருந்து நீக்கு';

  @override
  String get add_to_blacklist => 'தடைப்பட்டியலில் சேர்';

  @override
  String get remove_from_blacklist => 'தடைப்பட்டியலிலிருந்து நீக்கு';

  @override
  String get share => 'பகிர்';

  @override
  String get mini_player => 'சிறிய இயக்கி';

  @override
  String get slide_to_seek => 'முன்னோக்கி அல்லது பின்னோக்கி செல்ல சறுக்கவும்';

  @override
  String get shuffle_playlist => 'பாடல் பட்டியலை கலக்கு';

  @override
  String get unshuffle_playlist => 'பாடல் பட்டியலை கலக்காதே';

  @override
  String get previous_track => 'முந்தைய பாடல்';

  @override
  String get next_track => 'அடுத்த பாடல்';

  @override
  String get pause_playback => 'இயக்கத்தை நிறுத்து';

  @override
  String get resume_playback => 'இயக்கத்தை தொடர்';

  @override
  String get loop_track => 'பாடலை சுழற்று';

  @override
  String get no_loop => 'சுழற்சி இல்லை';

  @override
  String get repeat_playlist => 'பாடல் பட்டியலை மீண்டும் இயக்கு';

  @override
  String get queue => 'வரிசை';

  @override
  String get alternative_track_sources => 'மாற்று பாடல் மூலங்கள்';

  @override
  String get download_track => 'பாடலைப் பதிவிறக்கு';

  @override
  String tracks_in_queue(Object tracks) {
    return 'வரிசையில் $tracks பாடல்கள்';
  }

  @override
  String get clear_all => 'அனைத்தையும் அழி';

  @override
  String get show_hide_ui_on_hover => 'மேலே வரும்போது UI ஐக் காட்டு/மறை';

  @override
  String get always_on_top => 'எப்போதும் மேலே';

  @override
  String get exit_mini_player => 'சிறிய இயக்கியிலிருந்து வெளியேறு';

  @override
  String get download_location => 'பதிவிறக்க இடம்';

  @override
  String get local_library => 'உள்ளூர் நூலகம்';

  @override
  String get add_library_location => 'நூலகத்தில் சேர்';

  @override
  String get remove_library_location => 'நூலகத்திலிருந்து நீக்கு';

  @override
  String get account => 'கணக்கு';

  @override
  String get logout => 'வெளியேறு';

  @override
  String get logout_of_this_account => 'இந்த கணக்கிலிருந்து வெளியேறு';

  @override
  String get language_region => 'மொழி & பிராந்தியம்';

  @override
  String get language => 'மொழி';

  @override
  String get system_default => 'கணினி இயல்புநிலை';

  @override
  String get market_place_region => 'சந்தை பிராந்தியம்';

  @override
  String get recommendation_country => 'பரிந்துரை நாடு';

  @override
  String get appearance => 'தோற்றம்';

  @override
  String get layout_mode => 'அமைப்பு முறை';

  @override
  String get override_layout_settings => 'தளவமைப்பு அமைப்புகளை மாற்றியமை';

  @override
  String get adaptive => 'தகவமைப்பு';

  @override
  String get compact => 'சுருக்கமான';

  @override
  String get extended => 'விரிவான';

  @override
  String get theme => 'தீம்';

  @override
  String get dark => 'இருள்';

  @override
  String get light => 'வெளிர்';

  @override
  String get system => 'கணினி வழி';

  @override
  String get accent_color => 'அழுத்த நிறம்';

  @override
  String get sync_album_color => 'ஆல்பம் நிறத்தை ஒத்திசை';

  @override
  String get sync_album_color_description =>
      'ஆல்பம் படத்தின் முக்கிய நிறத்தை அழுத்த நிறமாகப் பயன்படுத்துகிறது';

  @override
  String get playback => 'பின்னணி';

  @override
  String get audio_quality => 'ஒலி தரம்';

  @override
  String get high => 'உயர்';

  @override
  String get low => 'குறைந்த';

  @override
  String get pre_download_play => 'முன்பதிவிறக்கம் மற்றும் இயக்கம்';

  @override
  String get pre_download_play_description =>
      'ஒலியை ஸ்ட்ரீம் செய்வதற்குப் பதிலாக, பைட்டுகளைப் பதிவிறக்கி இயக்கவும் (அதிக பேண்ட்விட்த் பயனர்களுக்கு பரிந்துரைக்கப்படுகிறது)';

  @override
  String get skip_non_music => 'இசையல்லாத பகுதிகளைத் தவிர் (SponsorBlock)';

  @override
  String get blacklist_description =>
      'தடைசெய்யப்பட்ட பாடல்கள் மற்றும் கலைஞர்கள்';

  @override
  String get wait_for_download_to_finish =>
      'தற்போதைய பதிவிறக்கம் முடியும் வரை காத்திருக்கவும்';

  @override
  String get desktop => 'கணினி';

  @override
  String get close_behavior => 'மூடும் நடத்தை';

  @override
  String get close => 'மூடு';

  @override
  String get minimize_to_tray => 'ட்ரேயை குறைக்கவும்';

  @override
  String get show_tray_icon => 'ட்ரே ஐகானைக் காட்டு';

  @override
  String get about => 'பற்றி';

  @override
  String get u_love_spotube =>
      'நீங்கள் DeeMusiq ஐ நேசிக்கிறீர்கள் என்பது எங்களுக்குத் தெரியும்';

  @override
  String get check_for_updates => 'புதுப்பிப்புகளைச் சரிபார்';

  @override
  String get about_spotube => 'DeeMusiq பற்றி';

  @override
  String get blacklist => 'தடைப்பட்டியல்';

  @override
  String get please_sponsor => 'தயவுசெய்து ஆதரவு/நன்கொடை அளியுங்கள்';

  @override
  String get spotube_description =>
      'DeeMusiq, ஒரு லேசான, பல தளங்களில் இயங்கும், அனைவருக்கும் இலவசமான spotify கிளையன்ட்';

  @override
  String get version => 'பதிப்பு';

  @override
  String get build_number => 'கட்டமைப்பு எண்';

  @override
  String get founder => 'நிறுவனர்';

  @override
  String get repository => 'களஞ்சியம்';

  @override
  String get bug_issues => 'பிழை_சிக்கல்கள்';

  @override
  String get made_with => 'வங்காளதேசத்திலிருந்து🇧🇩 ❤️ உருவாக்கப்பட்டது';

  @override
  String get kingkor_roy_tirtho => 'கிங்கர் ராய் திர்தோ';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year கிங்கர் ராய் திர்தோ';
  }

  @override
  String get license => 'உரிமம்';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'கவலைப்பட வேண்டாம், உங்கள் சான்றுகள் எதுவும் சேகரிக்கப்படாது அல்லது யாருடனும் பகிரப்படாது';

  @override
  String get know_how_to_login => 'இதை எப்படி செய்வது என்று தெரியவில்லையா?';

  @override
  String get follow_step_by_step_guide =>
      'படிப்படியான வழிகாட்டியைப் பின்பற்றவும்';

  @override
  String cookie_name_cookie(Object name) {
    return '$name நட்புநிரல்';
  }

  @override
  String get fill_in_all_fields => 'அனைத்து களங்களையும் நிரப்பவும்';

  @override
  String get submit => 'சமர்ப்பி';

  @override
  String get exit => 'வெளியேறு';

  @override
  String get previous => 'முந்தைய';

  @override
  String get next => 'அடுத்து';

  @override
  String get done => 'முடிந்தது';

  @override
  String get step_1 => 'முதல் படி';

  @override
  String get first_go_to => 'முதலில், செல்லவேண்டியது';

  @override
  String get something_went_wrong => 'ஏதோ தவறு நடந்துவிட்டது';

  @override
  String get piped_instance => 'Piped சேவையகம் நிகழ்வு';

  @override
  String get piped_description =>
      'பாடல் பொருத்தத்திற்குப் பயன்படுத்த வேண்டிய Piped சேவையகம் நிகழ்வு';

  @override
  String get piped_warning =>
      'அவற்றில் சில நன்றாக வேலை செய்யாமல் இருக்கலாம். எனவே உங்கள் சொந்த ஆபத்தில் பயன்படுத்தவும்';

  @override
  String get invidious_instance => 'Invidious சேவையக நிகழ்வு';

  @override
  String get invidious_description =>
      'பாடல் பொருத்தத்திற்குப் பயன்படுத்த வேண்டிய Invidious சேவையக நிகழ்வு';

  @override
  String get invidious_warning =>
      'அவற்றில் சில நன்றாக வேலை செய்யாமல் இருக்கலாம். எனவே உங்கள் சொந்த ஆபத்தில் பயன்படுத்தவும்';

  @override
  String get generate => 'உருவாக்கு';

  @override
  String track_exists(Object track) {
    return 'பாடல் $track ஏற்கனவே உள்ளது';
  }

  @override
  String get replace_downloaded_tracks =>
      'பதிவிறக்கம் செய்யப்பட்ட அனைத்து பாடல்களையும் மாற்றவும்';

  @override
  String get skip_download_tracks =>
      'பதிவிறக்கம் செய்யப்பட்ட அனைத்து பாடல்களையும் தவிர்க்கவும்';

  @override
  String get do_you_want_to_replace =>
      'ஏற்கனவே உள்ள பாடலை மாற்ற விரும்புகிறீர்களா?';

  @override
  String get replace => 'மாற்று';

  @override
  String get skip => 'தவிர்';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return '$count $type வரை தேர்ந்தெடுக்கவும்';
  }

  @override
  String get select_genres => 'வகைகளைத் தேர்ந்தெடுக்கவும்';

  @override
  String get add_genres => 'வகைகளைச் சேர்க்கவும்';

  @override
  String get country => 'நாடு';

  @override
  String get number_of_tracks_generate =>
      'உருவாக்க வேண்டிய பாடல்களின் எண்ணிக்கை';

  @override
  String get acousticness => 'அகவுஸ்டிக்னெஸ்';

  @override
  String get danceability => 'நடனத்தன்மை';

  @override
  String get energy => 'ஆற்றல்';

  @override
  String get instrumentalness => 'கருவித்தன்மை';

  @override
  String get liveness => 'உயிர்ப்புத்தன்மை';

  @override
  String get loudness => 'ஒலி அளவு';

  @override
  String get speechiness => 'பேச்சுத்தன்மை';

  @override
  String get valence => 'உணர்வு';

  @override
  String get popularity => 'பிரபலம்';

  @override
  String get key => 'இசை குறிப்பு';

  @override
  String get duration => 'கால அளவு (வினாடிகள்)';

  @override
  String get tempo => 'வேகம் (BPM)';

  @override
  String get mode => 'முறை';

  @override
  String get time_signature => 'நேர கையொப்பம்';

  @override
  String get short => 'குறுகிய';

  @override
  String get medium => 'நடுத்தர';

  @override
  String get long => 'நீண்ட';

  @override
  String get min => 'குறைந்தபட்சம்';

  @override
  String get max => 'அதிகபட்சம்';

  @override
  String get target => 'இலக்கு';

  @override
  String get moderate => 'மிதமான';

  @override
  String get deselect_all => 'அனைத்தையும் தேர்வுநீக்கு';

  @override
  String get select_all => 'அனைத்தையும் தேர்ந்தெடு';

  @override
  String get are_you_sure => 'உறுதியாக இருக்கிறீர்களா?';

  @override
  String get generating_playlist =>
      'உங்கள் தனிப்பயன்பாட்டிற்கான பாடல் பட்டியலை உருவாக்குகிறது...';

  @override
  String selected_count_tracks(Object count) {
    return '$count பாடல்கள் தேர்ந்தெடுக்கப்பட்டன';
  }

  @override
  String get download_warning =>
      'நீங்கள் அனைத்து பாடல்களையும் மொத்தமாக பதிவிறக்கினால், நீங்கள் தெளிவாக இசையைத் திருடுகிறீர்கள் மற்றும் இசையின் படைப்பாற்றல் சமூகத்திற்கு சேதம் விளைவிக்கிறீர்கள். நீங்கள் இதை அறிந்திருக்கிறீர்கள் என்று நம்புகிறேன். எப்போதும், கலைஞரின் கடின உழைப்பை மதித்து ஆதரிக்க முயற்சி செய்யுங்கள்';

  @override
  String get download_ip_ban_warning =>
      'மேலும், அதிகப்படியான பதிவிறக்க கோரிக்கைகள் காரணமாக உங்கள் IP YouTube இல் தடைசெய்யப்படலாம். IP தடை என்பது குறைந்தது 2-3 மாதங்களுக்கு அந்த IP சாதனத்திலிருந்து YouTube ஐப் பயன்படுத்த முடியாது (நீங்கள் உள்நுழைந்திருந்தாலும் கூட). இது ஒருபோதும் நடந்தால் DeeMusiq பொறுப்பேற்காது';

  @override
  String get by_clicking_accept_terms =>
      '\'ஏற்றுக்கொள்\' என்பதைக் கிளிக் செய்வதன் மூலம் பின்வரும் விதிமுறைகளுக்கு நீங்கள் ஒப்புக்கொள்கிறீர்கள்:';

  @override
  String get download_agreement_1 =>
      'நான் இசையைத் திருடுகிறேன் என்பது எனக்குத் தெரியும். நான் கெட்டவன்';

  @override
  String get download_agreement_2 =>
      'நான் கலைஞரை முடிந்தவரை ஆதரிப்பேன், அவர்களின் கலைக்கு பணம் செலுத்த எனக்கு பணம் இல்லாததால் மட்டுமே இதைச் செய்கிறேன்';

  @override
  String get download_agreement_3 =>
      'என் IP YouTube இல் தடைசெய்யப்படலாம் என்பதை நான் முழுமையாக அறிவேன், மேலும் என் தற்போதைய செயலால் ஏற்படும் எந்த விபத்துகளுக்கும் DeeMusiq அல்லது அதன் உரிமையாளர்கள்/பங்களிப்பாளர்களை பொறுப்பாக்க மாட்டேன்';

  @override
  String get decline => 'மறு';

  @override
  String get accept => 'ஏற்றுக்கொள்';

  @override
  String get details => 'விவரங்கள்';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'சேனல்';

  @override
  String get likes => 'விருப்பங்கள்';

  @override
  String get dislikes => 'விருப்பமில்லாதவை';

  @override
  String get views => 'பார்வைகள்';

  @override
  String get streamUrl => 'ஸ்ட்ரீம் URL';

  @override
  String get stop => 'நிறுத்து';

  @override
  String get sort_newest => 'புதிதாக சேர்க்கப்பட்டவற்றை வரிசைப்படுத்து';

  @override
  String get sort_oldest => 'பழமையானவற்றை வரிசைப்படுத்து';

  @override
  String get sleep_timer => 'உறக்க நேரம்';

  @override
  String mins(Object minutes) {
    return '$minutes நிமிடங்கள்';
  }

  @override
  String hours(Object hours) {
    return '$hours மணிநேரங்கள்';
  }

  @override
  String hour(Object hours) {
    return '$hours மணிநேரம்';
  }

  @override
  String get custom_hours => 'தனிப்பயன் மணிநேரங்கள்';

  @override
  String get logs => 'பதிவுகள்';

  @override
  String get developers => 'உருவாக்குநர்கள்';

  @override
  String get not_logged_in => 'நீங்கள் உள்நுழையவில்லை';

  @override
  String get search_mode => 'தேடல் முறை';

  @override
  String get audio_source => 'ஒலி மூலம்';

  @override
  String get ok => 'சரி';

  @override
  String get failed_to_encrypt => 'குறியாக்கம் தோல்வியடைந்தது';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq உங்கள் தரவை பாதுகாப்பாக சேமிக்க குறியாக்கத்தைப் பயன்படுத்துகிறது. ஆனால் அவ்வாறு செய்ய முடியவில்லை. எனவே இது பாதுகாப்பற்ற சேமிப்பகத்திற்கு மாறும்\nநீங்கள் லினக்ஸ் பயன்படுத்துகிறீர்கள் என்றால், எந்த ரகசிய சேவையும் (gnome-keyring, kde-wallet, keepassxc போன்றவை) நிறுவப்பட்டுள்ளதா என்பதை உறுதிப்படுத்தவும்';

  @override
  String get querying_info => 'தகவலைக் கேட்கிறது...';

  @override
  String get piped_api_down => 'Piped API செயலிழந்துள்ளது';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Piped நிகழ்வு $pipedInstance தற்போது செயலிழந்துள்ளது\n\nநிகழ்வை மாற்றவும் அல்லது \'API வகை\'யை அதிகாரப்பூர்வ YouTube API க்கு மாற்றவும்\n\nமாற்றத்திற்குப் பிறகு பயன்பாட்டை மறுதொடக்கம் செய்வதை உறுதிப்படுத்தவும்';
  }

  @override
  String get you_are_offline => 'நீங்கள் தற்போது ஆஃப்லைனில் உள்ளீர்கள்';

  @override
  String get connection_restored => 'உங்கள் இணைய இணைப்பு மீட்டெடுக்கப்பட்டது';

  @override
  String get use_system_title_bar => 'கணினி தலைப்புப் பட்டியைப் பயன்படுத்தவும்';

  @override
  String get crunching_results => 'முடிவுகளை செயலாக்குகிறது...';

  @override
  String get search_to_get_results => 'முடிவுகளைப் பெற தேடவும்';

  @override
  String get use_amoled_mode => 'கருமை நிற இருண்ட தீம்';

  @override
  String get pitch_dark_theme => 'AMOLED முறை';

  @override
  String get normalize_audio => 'ஒலியை சீரமை';

  @override
  String get change_cover => 'அட்டையை மாற்று';

  @override
  String get add_cover => 'அட்டையைச் சேர்';

  @override
  String get restore_defaults => 'இயல்புநிலைகளை மீட்டமை';

  @override
  String get download_music_format => 'இசை பதிவிறக்க வடிவம்';

  @override
  String get streaming_music_format => 'இசை ஸ்ட்ரீமிங் வடிவம்';

  @override
  String get download_music_quality => 'பதிவிறக்க தரம்';

  @override
  String get streaming_music_quality => 'ஸ்ட்ரீமிங் தரம்';

  @override
  String get login_with_lastfm => 'Last.fm உடன் உள்நுழைக';

  @override
  String get connect => 'இணை';

  @override
  String get disconnect_lastfm => 'Last.fm இலிருந்து துண்டி';

  @override
  String get disconnect => 'துண்டி';

  @override
  String get username => 'பயனர்பெயர்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get login => 'உள்நுழைக';

  @override
  String get login_with_your_lastfm => 'உங்கள் Last.fm கணக்குடன் உள்நுழைக';

  @override
  String get scrobble_to_lastfm => 'Last.fm க்கு ஸ்க்ரோபிள் செய்';

  @override
  String get go_to_album => 'ஆல்பத்திற்குச் செல்';

  @override
  String get discord_rich_presence => 'Discord செழுமையான தோற்றம்';

  @override
  String get browse_all => 'அனைத்தையும் உலாவு';

  @override
  String get genres => 'வகைகள்';

  @override
  String get explore_genres => 'வகைகளை ஆராயுங்கள்';

  @override
  String get friends => 'நண்பர்கள்';

  @override
  String get no_lyrics_available =>
      'மன்னிக்கவும், இந்தப் பாடலுக்கான பாடல் வரிகளைக் கண்டுபிடிக்க முடியவில்லை';

  @override
  String get start_a_radio => 'வானொலியைத் தொடங்கு';

  @override
  String get how_to_start_radio => 'வானொலியை எவ்வாறு தொடங்க விரும்புகிறீர்கள்?';

  @override
  String get replace_queue_question =>
      'தற்போதைய வரிசையை மாற்ற விரும்புகிறீர்களா அல்லது அதனுடன் சேர்க்க விரும்புகிறீர்களா?';

  @override
  String get endless_playback => 'முடிவற்ற இயக்கம்';

  @override
  String get delete_playlist => 'பாடல் பட்டியலை நீக்கு';

  @override
  String get delete_playlist_confirmation =>
      'இந்த பாடல் பட்டியலை நீக்க விரும்புகிறீர்களா?';

  @override
  String get local_tracks => 'உள்ளூர் பாடல்கள்';

  @override
  String get local_tab => 'உள்ளூர்';

  @override
  String get song_link => 'பாடல் இணைப்பு';

  @override
  String get youtube_source_description =>
      'பரிந்துரைக்கப்படுகிறது மற்றும் சிறப்பாக செயல்படுகிறது.';

  @override
  String get piped_source_description =>
      'சுதந்திரமாக உணர்கிறீர்களா? YouTube போலவே ஆனால் மிகவும் சுதந்திரமானது.';

  @override
  String get jiosaavn_source_description =>
      'தெற்காசியப் பிராந்தியத்திற்கு சிறந்தது.';

  @override
  String get invidious_source_description =>
      'Piped ஐப் போன்றது ஆனால் அதிக கிடைக்கும் தன்மையுடன்.';

  @override
  String highest_quality(Object quality) {
    return 'உயர்ந்த தரம்: $quality';
  }

  @override
  String get select_audio_source => 'ஒலி மூலத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get contribute_on_github => 'GitHub இல் பங்களியுங்கள்';

  @override
  String get browse_anonymously => 'அநாமதேயமாக உலாவுக';

  @override
  String get enable_connect => 'இணைப்பை இயக்கு';

  @override
  String get enable_connect_description =>
      'மற்ற சாதனங்களிலிருந்து DeeMusiq ஐக் கட்டுப்படுத்தவும்';

  @override
  String get devices => 'சாதனங்கள்';

  @override
  String get select => 'தேர்ந்தெடு';

  @override
  String connect_client_alert(Object client) {
    return 'நீங்கள் $client ஆல் கட்டுப்படுத்தப்படுகிறீர்கள்';
  }

  @override
  String get this_device => 'இந்த சாதனம்';

  @override
  String get remote => 'தொலைநிலை';

  @override
  String get stats => 'புள்ளிவிவரங்கள்';

  @override
  String and_n_more(Object count) {
    return 'மற்றும் $count கூடுதலாக';
  }

  @override
  String get recently_played => 'சமீபத்தில் இயக்கியவை';

  @override
  String get browse_more => 'மேலும் உலாவு';

  @override
  String get no_title => 'தலைப்பு இல்லை';

  @override
  String get not_playing => 'இயக்கப்படவில்லை';

  @override
  String get epic_failure => 'மோசமான தோல்வி!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length பாடல்கள் வரிசையில் சேர்க்கப்பட்டன';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq க்கு ஒரு புதுப்பிப்பு உள்ளது';

  @override
  String get download_now => 'இப்போது பதிவிறக்கு';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum வெளியிடப்பட்டுள்ளது';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version வெளியிடப்பட்டுள்ளது';
  }

  @override
  String get read_the_latest => 'சமீபத்திய ';

  @override
  String get release_notes => 'வெளியீட்டு குறிப்புகளைப் படிக்கவும்';

  @override
  String get pick_color_scheme => 'வண்ணத் திட்டத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get save => 'சேமி';

  @override
  String get choose_the_device => 'சாதனத்தைத் தேர்ந்தெடுக்கவும்:';

  @override
  String get multiple_device_connected =>
      'பல சாதனங்கள் இணைக்கப்பட்டுள்ளன.\nஇந்த செயல் நடைபெற வேண்டிய சாதனத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get nothing_found => 'எதுவும் கிடைக்கவில்லை';

  @override
  String get the_box_is_empty => 'பெட்டி காலியாக உள்ளது';

  @override
  String get top_artists => 'சிறந்த கலைஞர்கள்';

  @override
  String get top_albums => 'சிறந்த ஆல்பங்கள்';

  @override
  String get this_week => 'இந்த வாரம்';

  @override
  String get this_month => 'இந்த மாதம்';

  @override
  String get last_6_months => 'கடந்த 6 மாதங்கள்';

  @override
  String get this_year => 'இந்த ஆண்டு';

  @override
  String get last_2_years => 'கடந்த 2 ஆண்டுகள்';

  @override
  String get all_time => 'எல்லா நேரமும்';

  @override
  String powered_by_provider(Object providerName) {
    return '$providerName ஆல் இயக்கப்படுகிறது';
  }

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get profile_followers => 'பின்தொடர்பவர்கள்';

  @override
  String get birthday => 'பிறந்த நாள்';

  @override
  String get subscription => 'சந்தா';

  @override
  String get not_born => 'பிறக்கவில்லை';

  @override
  String get hacker => 'ஹேக்கர்';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get no_name => 'பெயர் இல்லை';

  @override
  String get edit => 'திருத்து';

  @override
  String get user_profile => 'பயனர் சுயவிவரம்';

  @override
  String count_plays(Object count) {
    return '$count முறை இசைக்கப்பட்டது';
  }

  @override
  String get minutes_listened => 'காலம் கேட்டது';

  @override
  String get streamed_songs => 'ஸ்ட்ரீமிங் செய்யப்பட்ட பாடல்கள்';

  @override
  String count_streams(Object count) {
    return '$count ஸ்ட்ரீம்கள்';
  }

  @override
  String get owned_by_you => 'உங்களால் கொண்டது';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return 'நகலெடுக்கப்பட்டது $shareUrl கிளிப்போர்டுக்காக';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes நிமிடங்கள்';
  }

  @override
  String get summary_minutes => 'நிமிடங்கள்';

  @override
  String get summary_listened_to_music => 'இசை கேட்டது';

  @override
  String get summary_songs => 'பாடல்கள்';

  @override
  String get summary_streamed_overall => 'மொத்தமாக ஸ்ட்ரீமிங்';

  @override
  String get summary_artists => 'கலைஞர்கள்';

  @override
  String get summary_music_reached_you => 'இசை உங்களுக்கு வந்தது';

  @override
  String get summary_full_albums => 'முழு ஆல்பங்கள்';

  @override
  String get summary_got_your_love => 'உங்கள் அன்பை பெற்றுக்கொண்டேன்';

  @override
  String get summary_playlists => 'பாடல் பட்டியல்கள்';

  @override
  String get summary_were_on_repeat => 'மீண்டும் மீண்டும் இருந்தன';

  @override
  String get webview_not_found => 'வெப்வியூ கிடைக்கவில்லை';

  @override
  String get webview_not_found_description =>
      'உங்கள் சாதனத்தில் எந்தவொரு வெப்வியூ இயக்கத்தை நிறுவவில்லை.\nஇது நிறுவப்பட்டிருந்தால், சுற்றுச்சூழல் பாதையில் PATH உள்ளது என்பதை உறுதிபடுத்தவும்\n\nநிறுவித்த பிறகு, செயலியை மறுதொடக்கம் செய்யவும்';

  @override
  String get unsupported_platform => 'அதிர்ஷ்டகாத உருப்படியை ஆதரிக்கவில்லை';

  @override
  String get cache_music => 'இசையை கேஷ் செய்';

  @override
  String get open => 'திறக்கவும்';

  @override
  String get cache_folder => 'கேஷ் அடைவு';

  @override
  String get export => 'ஏற்றுமதி';

  @override
  String get clear_cache => 'கேஷ் அழிக்கவும்';

  @override
  String get clear_cache_confirmation => 'கேஷைப் அழிக்க விரும்புகிறீர்களா?';

  @override
  String get export_cache_files => 'கேஷில் உள்ள கோப்புகளை ஏற்றுமதி செய்யவும்';

  @override
  String found_n_files(Object count) {
    return '$count கோப்புகள் கிடைத்தன';
  }

  @override
  String get export_cache_confirmation =>
      'இந்த கோப்புகளை ஏற்றுமதி செய்ய விரும்புகிறீர்களா?';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported கோப்புகள் ஏற்றுமதி செய்யப்பட்டன, $files கோப்புகளில்';
  }

  @override
  String get undo => 'செயல்தவிர்';

  @override
  String get download_all => 'அனைத்தையும் பதிவிறக்குக';

  @override
  String get add_all_to_playlist => 'அனைத்தையும் பாடல் பட்டியலில் சேர்க்கவும்';

  @override
  String get add_all_to_queue => 'அனைத்தையும் வரிசைப்படுத்து';

  @override
  String get play_all_next => 'அடுத்த உள்ள அனைத்தையும் இயக்கு';

  @override
  String get pause => 'நிறுத்து';

  @override
  String get view_all => 'அனைத்தையும் காண்க';

  @override
  String get no_tracks_added_yet =>
      'உங்கள் பாடல்களை இன்னும் சேர்க்கவில்லை என்றால் தெரியாதே';

  @override
  String get no_tracks => 'இங்கு பாடல்கள் எதுவும் இல்லை';

  @override
  String get no_tracks_listened_yet => 'இன்னும் எதையும் கேள்வியில்லை';

  @override
  String get not_following_artists => 'நீங்கள் எந்த கலைஞரையும் பின்தொடரவில்லை';

  @override
  String get no_favorite_albums_yet =>
      'நீங்கள் இன்னும் எந்த ஆல்பங்களையும் பிடித்தவையாகச் சேர்க்கவில்லை';

  @override
  String get no_logs_found => 'பதிவுகள் எதுவும் கிடைக்கவில்லை';

  @override
  String get youtube_engine => 'YouTube இயந்திரம்';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine நிறுவியதில்லை';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine உங்கள் கணினியில் நிறுவியதில்லை.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'PATH மாறியில் கிடைக்கிறதா என்பதை உறுதிப்படுத்தவும் அல்லது\n$engine செயல் செய்யக்கூடிய முறையை கீழே அமைக்கவும்';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/unix போல் OS இல், .zshrc/.bashrc/.bash_profile போன்றவை அமைப்பில் பாதையை PATH அமைப்பது இயலாது.\nநீங்கள்.shell configuration file இல் பாதையை அமைக்க வேண்டும்';

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
  String get download => 'பதிவிறக்கு';

  @override
  String get file_not_found => 'கோப்பு கிடைக்கவில்லை';

  @override
  String get custom => 'தனிப்பயன்';

  @override
  String get add_custom_url => 'தனிப்பயன் URL ஐச் சேர்க்கவும்';

  @override
  String get edit_port => 'போர்டு திருத்தவும்';

  @override
  String get port_helper_msg =>
      'இயல்புநிலை -1 ஆகும், இது சீரற்ற எண்ணை குறிக்கிறது. நீங்கள் தீயணைப்பு அமைக்கப்பட்டிருந்தால், இதை அமைப்பது பரிந்துரைக்கப்படுகிறது.';

  @override
  String connect_request(Object client) {
    return '$client க்கு இணைக்க அனுமதிக்கவா?';
  }

  @override
  String get connection_request_denied =>
      'இணைப்பு மறுக்கப்பட்டது. பயனர் அணுகலை மறுத்தார்.';

  @override
  String get an_error_occurred => 'ஒரு பிழை ஏற்பட்டது';

  @override
  String get copy_to_clipboard => 'கிளிப்போர்டுக்கு நகலெடுக்கவும்';

  @override
  String get view_logs => 'பதிவுகளைப் பார்க்கவும்';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

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
      'நீங்கள் எந்த இயல்புநிலை மெட்டாடேட்டா வழங்குநரையும் அமைக்கவில்லை';

  @override
  String get manage_metadata_providers =>
      'மெட்டாடேட்டா வழங்குநர்களை நிர்வகிக்கவும்';

  @override
  String get open_link_in_browser => 'இணைப்பை உலாவியில் திறக்கவா?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'பின்வரும் இணைப்பை நீங்கள் திறக்க விரும்புகிறீர்களா';

  @override
  String get unsafe_url_warning =>
      'நம்பத்தகாத மூலங்களிலிருந்து இணைப்புகளைத் திறப்பது பாதுகாப்பற்றதாக இருக்கலாம். எச்சரிக்கையாக இருங்கள்!\nநீங்கள் இணைப்பை உங்கள் கிளிப்போர்டுக்கு நகலெடுக்கலாம்.';

  @override
  String get copy_link => 'இணைப்பை நகலெடுக்கவும்';

  @override
  String get building_your_timeline =>
      'உங்கள் கேட்டலின் அடிப்படையில் உங்கள் காலவரிசையை உருவாக்குகிறது...';

  @override
  String get official => 'அதிகாரபூர்வமானது';

  @override
  String author_name(Object author) {
    return 'ஆசிரியர்: $author';
  }

  @override
  String get third_party => 'மூன்றாம் தரப்பு';

  @override
  String get plugin_requires_authentication =>
      'பிளகின் அங்கீகாரத்தைக் கோருகிறது';

  @override
  String get update_available => 'புதுப்பிப்பு உள்ளது';

  @override
  String get supports_scrobbling => 'ஸ்க்ரோப்ளிங்கை ஆதரிக்கிறது';

  @override
  String get plugin_scrobbling_info =>
      'இந்த பிளகின் உங்கள் கேட்பதின் வரலாற்றை உருவாக்க உங்கள் இசையை ஸ்க்ரோப்ள் செய்கிறது.';

  @override
  String get default_metadata_source => 'இயல்புநிலை மெட்டாடேட்டா மூலம்';

  @override
  String get set_default_metadata_source =>
      'இயல்புநிலை மெட்டாடேட்டா மூலத்தை அமை';

  @override
  String get default_audio_source => 'இயல்புநிலை ஆடியோ மூலம்';

  @override
  String get set_default_audio_source => 'இயல்புநிலை ஆடியோ மூலத்தை அமை';

  @override
  String get set_default => 'இயல்புநிலையாக அமைக்கவும்';

  @override
  String get support => 'ஆதரவு';

  @override
  String get support_plugin_development => 'பிளகின் வளர்ச்சிக்கு ஆதரவு';

  @override
  String can_access_name_api(Object name) {
    return '- **$name** API ஐ அணுக முடியும்';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'இந்த பிளகினை நீங்கள் நிறுவ விரும்புகிறீர்களா?';

  @override
  String get third_party_plugin_warning =>
      'இந்த பிளகின் மூன்றாம் தரப்பு களஞ்சியத்திலிருந்து வருகிறது. நிறுவும் முன் மூலத்தை நீங்கள் நம்புகிறீர்கள் என்பதை உறுதிப்படுத்தவும்.';

  @override
  String get author => 'ஆசிரியர்';

  @override
  String get this_plugin_can_do_following =>
      'இந்த பிளகின் பின்வருவனவற்றைச் செய்ய முடியும்';

  @override
  String get install => 'நிறுவவும்';

  @override
  String get no_tracks_playing => 'தற்போது எந்த பாடலும் இயங்கவில்லை';

  @override
  String get synced_lyrics_not_available =>
      'இந்த பாடலுக்கு ஒத்திசைக்கப்பட்ட வரிகள் கிடைக்கவில்லை. தயவுசெய்து';

  @override
  String get plain_lyrics => 'சாதாரண வரிகள்';

  @override
  String get tab_instead => 'தாவலை அதற்கு பதிலாக பயன்படுத்தவும்.';

  @override
  String get disclaimer => 'துறப்பு';

  @override
  String get third_party_plugin_dmca_notice =>
      'ஸ்பாட்யூப் குழு எந்த \"மூன்றாம் தரப்பு\" பிளகின்களுக்கும் எந்தப் பொறுப்பையும் (சட்டரீதியான உட்பட) ஏற்காது.\nதயவுசெய்து உங்கள் சொந்த ஆபத்தில் அவற்றைப் பயன்படுத்தவும். ஏதேனும் பிழைகள்/சிக்கல்களுக்கு, பிளகின் களஞ்சியத்தில் அவற்றைப் புகாரளிக்கவும்.\n\nஏதேனும் ஒரு \"மூன்றாம் தரப்பு\" பிளகின் ஒரு சேவை/சட்ட நிறுவனத்தின் ToS/DMCA ஐ மீறினால், தயவுசெய்து \"மூன்றாம் தரப்பு\" பிளகின் ஆசிரியரையோ அல்லது ஹோஸ்டிங் தளத்தையோ, எ.கா. GitHub/Codeberg, நடவடிக்கை எடுக்கக் கோரவும். மேலே பட்டியலிடப்பட்ட (\"மூன்றாம் தரப்பு\" என பெயரிடப்பட்ட) அனைத்து பொதுவான/சமூகத்தால் பராமரிக்கப்படும் பிளகின்கள். நாங்கள் அவற்றை க்யூரேட் செய்யவில்லை, எனவே அவற்றின் மீது எந்த நடவடிக்கையும் எடுக்க முடியாது.\n\n';

  @override
  String get plugins => 'செருகுநிரல்கள்';

  @override
  String get paste_plugin_download_url =>
      'பதிவிறக்க url அல்லது GitHub/Codeberg repo url அல்லது .smplug கோப்பிற்கான நேரடி இணைப்பை ஒட்டவும்';

  @override
  String get download_and_install_plugin_from_url =>
      'url இலிருந்து பிளகினைப் பதிவிறக்கி நிறுவவும்';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'பிளகினைச் சேர்க்கத் தவறிவிட்டது: $error';
  }

  @override
  String get upload_plugin_from_file => 'கோப்பிலிருந்து பிளகினைப் பதிவேற்றவும்';

  @override
  String get installed => 'நிறுவப்பட்டது';

  @override
  String get available_plugins => 'கிடைக்கக்கூடிய பிளகின்கள்';

  @override
  String get configure_plugins =>
      'உங்கள் சொந்த மெட்டாடேட்டா வழங்குநர் மற்றும் ஆடியோ மூல செருகுநிரல்களை அமைக்கவும்';

  @override
  String get audio_scrobblers => 'ஆடியோ ஸ்க்ரோப்ளர்கள்';

  @override
  String get scrobbling => 'ஸ்க்ரோப்ளிங்';

  @override
  String get source => 'மூலம்: ';

  @override
  String get uncompressed => 'அழுத்தப்படாத';

  @override
  String get dab_music_source_description =>
      'ஆடியோஃபைல்களுக்காக. உயர்தர/லாஸ்லெஸ் ஆடியோ ஸ்ட்ரீம்களை வழங்குகிறது. ISRC அடிப்படையில் துல்லியமான பாடல் பொருத்தம்.';

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
  String get skip_this_nonsense => 'இந்த அர்த்தமற்றதைத் தவிர்';

  @override
  String get freedom_of_music => '\"இசையின் சுதந்திரம்\"';

  @override
  String get freedom_of_music_palm => '\"உங்கள் கைகளில் இசையின் சுதந்திரம்\"';

  @override
  String get get_started => 'தொடங்குவோம்';

  @override
  String get endless_playback_description =>
      'வரிசையின் இறுதியில் புதிய பாடல்களை\nதானாகவே சேர்க்கவும்';

  @override
  String get choose_your_region => 'உங்கள் பிராந்தியத்தைத் தேர்ந்தெடுக்கவும்';

  @override
  String get choose_your_region_description =>
      'இது உங்கள் இருப்பிடத்திற்கான சரியான உள்ளடக்கத்தை\nDeeMusiq காட்ட உதவும்.';

  @override
  String get choose_your_language => 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்';

  @override
  String get help_project_grow => 'இந்த திட்டம் வளர உதவுங்கள்';

  @override
  String get help_project_grow_description =>
      'DeeMusiq ஒரு திறந்த மூல திட்டம். திட்டத்திற்கு பங்களிப்பு செய்வதன் மூலம், பிழைகளைப் புகாரளிப்பதன் மூலம் அல்லது புதிய அம்சங்களைப் பரிந்துரைப்பதன் மூலம் இந்தத் திட்டம் வளர உதவலாம்.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective =>
      'Open Collective இல் நன்கொடை அளியுங்கள்';

  @override
  String get install_a_metadata_provider => 'மெட்டாடேட்டா வழங்குநரை நிறுவவும்';

  @override
  String get input_does_not_match_format =>
      'உள்ளீடு தேவையான வடிவத்துடன் பொருந்தவில்லை';

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
  String get auth_mfa_required => 'உங்கள் அங்கீகாரக் குறியீட்டை உள்ளிடவும்';

  @override
  String get auth_mfa_body =>
      'அங்கீகார பயன்பாட்டைத் திறந்து 6 இலக்கக் குறியீட்டை உள்ளிட்டு உள்நுழைவை முடிக்கவும்.';

  @override
  String get auth_mfa_verify_action => 'சரிபார்க்கவும்';

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
