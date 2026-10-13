// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get guest => 'ضيف';

  @override
  String get browse => 'تصفح';

  @override
  String get search => 'بحث';

  @override
  String get library => 'مكتبة';

  @override
  String get lyrics => 'كلمات';

  @override
  String get settings => 'إعدادات';

  @override
  String get genre_categories_filter => 'تصفية الفئات أو الأنواع...';

  @override
  String get genre => 'النوع';

  @override
  String get personalized => 'شخصية';

  @override
  String get featured => 'متميز';

  @override
  String get new_releases => 'الإصدارات الجديدة';

  @override
  String get songs => 'أغاني';

  @override
  String playing_track(Object track) {
    return 'تشغيل $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'سيؤدي هذا إلى مسح قائمة الانتظار الحالية. $track_length ستتم إزالة المقطوعات\nهل تريد الإستمرار؟';
  }

  @override
  String get load_more => 'تحميل المزيد';

  @override
  String get playlists => 'قوائم التشغيل';

  @override
  String get artists => 'فنانون';

  @override
  String get albums => 'ألبومات';

  @override
  String get tracks => 'مقطوعات';

  @override
  String get downloads => 'تنزيلات';

  @override
  String get filter_playlists => 'تصفية قوائم التشغيل الخاصة بك...';

  @override
  String get liked_tracks => 'المقطوعات التي أعجبتك';

  @override
  String get liked_tracks_description => 'جميع المقطوعات التي أعجبتك';

  @override
  String get playlist => 'قائمة التشغيل';

  @override
  String get create_a_playlist => 'إنشاء قائمة تشغيل';

  @override
  String get update_playlist => 'تحديث قائمة التشغيل';

  @override
  String get create => 'إنشاء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get update => 'تحديث';

  @override
  String get playlist_name => 'اسم قائمة التشغيل';

  @override
  String get name_of_playlist => 'اسم قائمة التشغيل';

  @override
  String get description => 'وصف';

  @override
  String get public => 'عام';

  @override
  String get collaborative => 'تعاوني';

  @override
  String get search_local_tracks => 'بحث عن مقطوعات محلية';

  @override
  String get play => 'تشغيل';

  @override
  String get delete => 'حذف';

  @override
  String get none => 'لا شيء';

  @override
  String get sort_a_z => 'الترتيب من A-Z';

  @override
  String get sort_z_a => 'الترتيب من Z-A';

  @override
  String get sort_artist => 'الترتيب حسب الفنان';

  @override
  String get sort_album => 'فرز حسب الألبوم';

  @override
  String get sort_duration => 'ترتيب حسب المدة';

  @override
  String get sort_tracks => 'ترتيب المقطوعات';

  @override
  String currently_downloading(Object tracks_length) {
    return 'يتم التنزيل ($tracks_length)';
  }

  @override
  String get cancel_all => 'إلغاء الكل';

  @override
  String get filter_artist => 'تصفية الفنانين...';

  @override
  String followers(Object followers) {
    return '$followers متابعون';
  }

  @override
  String get add_artist_to_blacklist => 'إضافة فنان إلى القائمة السوداء';

  @override
  String get top_tracks => 'أهم المقطوعات الصوتية';

  @override
  String get fans_also_like => 'المعجبون يحبون أيضاً';

  @override
  String get loading => 'جارٍ التحميل';

  @override
  String get artist => 'فنان';

  @override
  String get blacklisted => 'في القائمة السوداء';

  @override
  String get following => 'يتابع';

  @override
  String get follow => 'تابع';

  @override
  String get artist_url_copied => 'تم نسخ عنوان URL للفنان إلى الحافظة';

  @override
  String added_to_queue(Object tracks) {
    return 'تم إضافة المقطوعات إلى قائمة الإنتظار $tracks';
  }

  @override
  String get filter_albums => 'تصفية الألبومات...';

  @override
  String get synced => 'تم المزامنة';

  @override
  String get plain => 'سهل';

  @override
  String get shuffle => 'خلط';

  @override
  String get search_tracks => 'يحث عن مقطوعات';

  @override
  String get released => 'تم الإصدار';

  @override
  String error(Object error) {
    return 'خطأ $error';
  }

  @override
  String get title => 'عنوان';

  @override
  String get time => 'وقت';

  @override
  String get more_actions => 'المزيد من الإجراءات';

  @override
  String download_count(Object count) {
    return 'تنزيل ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'إضافة ($count) إلى قائمة التشغيل';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'إضافة ($count) إلى قائمة الإنتظار';
  }

  @override
  String play_count_next(Object count) {
    return 'تشغيل ($count) التالي';
  }

  @override
  String get album => 'ألبوم';

  @override
  String copied_to_clipboard(Object data) {
    return 'تم النسخ $data إلى الحافظة';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'إضافة $track إلى قوائم التشغيل التالية';
  }

  @override
  String get add => 'إضافة';

  @override
  String added_track_to_queue(Object track) {
    return 'تم الإضافة $track إلى قائمة الإنتظار';
  }

  @override
  String get add_to_queue => 'إضافة إلى قائمة التشغيل';

  @override
  String track_will_play_next(Object track) {
    return '$track سيتم تشغيل التالي';
  }

  @override
  String get play_next => 'تشغيل التالي';

  @override
  String removed_track_from_queue(Object track) {
    return 'تم الإزالة $track من قائمة الإنتظار';
  }

  @override
  String get remove_from_queue => 'إزالة من قائمة الإنتظار';

  @override
  String get remove_from_favorites => 'إزالة من المفضلة';

  @override
  String get save_as_favorite => 'حفظ كمفضل';

  @override
  String get add_to_playlist => 'إضافة إلى قائمة التشغيل';

  @override
  String get remove_from_playlist => 'إزالة من قائمة التشغيل';

  @override
  String get add_to_blacklist => 'إضافة إلى القائمة السوداء';

  @override
  String get remove_from_blacklist => 'إزالة من القائمة السوداء';

  @override
  String get share => 'مشاكرة';

  @override
  String get mini_player => 'مشغل مصغر';

  @override
  String get slide_to_seek => 'قم بالتمرير للبحث للأمام أو للخلف';

  @override
  String get shuffle_playlist => 'قائمة تشغيل عشوائية';

  @override
  String get unshuffle_playlist => 'إلغاء ترتيب قائمة التشغيل';

  @override
  String get previous_track => 'المقطوعة السابقة';

  @override
  String get next_track => 'مقطوعة جديدة';

  @override
  String get pause_playback => 'إيقاف التشغيل مؤقتًا';

  @override
  String get resume_playback => 'استئناف التشغيل';

  @override
  String get loop_track => 'تشغيل المقطوعة بشكل لا نهائي';

  @override
  String get no_loop => 'بدون تكرار';

  @override
  String get repeat_playlist => 'تكرار قائمة التشغيل';

  @override
  String get queue => 'قائمة الإنتظار';

  @override
  String get alternative_track_sources => 'مصادر مقطوعات بديلة';

  @override
  String get download_track => 'تنزيل المقطوعة';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks المقطوعات في قائمة الإنتظار';
  }

  @override
  String get clear_all => 'مسح الكل';

  @override
  String get show_hide_ui_on_hover => 'إظهار/إخفاء واجهة المستخدم عند التمرير';

  @override
  String get always_on_top => 'دائما في القمة';

  @override
  String get exit_mini_player => 'خروج من المشغل المصغر';

  @override
  String get download_location => 'تنزيل الموقع';

  @override
  String get local_library => 'المكتبة المحلية';

  @override
  String get add_library_location => 'أضف إلى المكتبة';

  @override
  String get remove_library_location => 'إزالة من المكتبة';

  @override
  String get account => 'حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logout_of_this_account => 'تسجيل الخروج من هذا الحساب';

  @override
  String get language_region => 'اللغة والمنطقة';

  @override
  String get language => 'لغة';

  @override
  String get system_default => 'لغة النظام الإفتراضية';

  @override
  String get market_place_region => 'منطقة السوق';

  @override
  String get recommendation_country => 'بلد التوصية';

  @override
  String get appearance => 'مظهر';

  @override
  String get layout_mode => 'وضع التخطيط';

  @override
  String get override_layout_settings =>
      'تجاوز إعدادات وضع التخطيط سريع الاستجابة';

  @override
  String get adaptive => 'متكيف';

  @override
  String get compact => 'مدمج';

  @override
  String get extended => 'ممتد';

  @override
  String get theme => 'مظهر';

  @override
  String get dark => 'داكن';

  @override
  String get light => 'ساطعt';

  @override
  String get system => 'حسب النظام';

  @override
  String get accent_color => 'لون تمييز';

  @override
  String get sync_album_color => 'مزامنة لون الألبوم';

  @override
  String get sync_album_color_description =>
      'يستخدم اللون السائد لصورة الألبوم باعتباره لون التمييز';

  @override
  String get playback => 'التشغيل';

  @override
  String get audio_quality => 'جودة الصوت';

  @override
  String get high => 'مرتفعة';

  @override
  String get low => 'منخفضة';

  @override
  String get pre_download_play => 'التحميل المسبق والتشغيل';

  @override
  String get pre_download_play_description =>
      'بدلاً من دفق الصوت، قم بتنزيل وحدات البايت وتشغيلها بدلاً من ذلك (موصى به لمستخدمي Bandwidth)';

  @override
  String get skip_non_music => 'تخطي المقاطع غير الموسيقية (SponsorBlock)';

  @override
  String get blacklist_description =>
      'المقطوعات والفنانون المدرجون في القائمة السوداء';

  @override
  String get wait_for_download_to_finish =>
      'يرجى الانتظار حتى انتهاء التنزيل الحالي';

  @override
  String get desktop => 'سطح المكتب';

  @override
  String get close_behavior => 'إغلاق التصرف';

  @override
  String get close => 'إغلاق';

  @override
  String get minimize_to_tray => 'تصغير إلى الدرج';

  @override
  String get show_tray_icon => 'إظهار أيقونات درج النظام';

  @override
  String get about => 'حول';

  @override
  String get u_love_spotube => 'نحن نعلم أنك تحب DeeMusiq';

  @override
  String get check_for_updates => 'تحقق من وجود تحديثات';

  @override
  String get about_spotube => 'حول DeeMusiq';

  @override
  String get blacklist => 'قائمة سوداء';

  @override
  String get please_sponsor => 'يرجى دعم/التبرع';

  @override
  String get spotube_description =>
      'DeeMusiq، عميل Spotify خفيف الوزن ومتعدد المنصات ومجاني للجميع';

  @override
  String get version => 'إصدار';

  @override
  String get build_number => 'رقم البنية';

  @override
  String get founder => 'الموئسس';

  @override
  String get repository => 'المستودع';

  @override
  String get bug_issues => 'أخطاء+مشاكل';

  @override
  String get made_with => 'صُنع باستخدام ❤️ في بنغلاديش🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'الترخيص';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'لا تقلق، لن يتم جمع أي من بيانات الخاصة بك أو مشاركتها مع أي شخص';

  @override
  String get know_how_to_login => 'لا تعرف كيف تفعل هذا؟';

  @override
  String get follow_step_by_step_guide => 'اتبع الدليل خطوة بخطوة';

  @override
  String cookie_name_cookie(Object name) {
    return '$name كوكيز';
  }

  @override
  String get fill_in_all_fields => 'يرجى تعبئة جميع الحقول';

  @override
  String get submit => 'إرسال';

  @override
  String get exit => 'خروج';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get done => 'تم';

  @override
  String get step_1 => 'الخطوة 1';

  @override
  String get first_go_to => 'أولا، اذهب إلى';

  @override
  String get something_went_wrong => 'هناك خطأ ما';

  @override
  String get piped_instance => 'مثيل خادم Piped';

  @override
  String get piped_description =>
      'مثيل خادم Piped الذي سيتم استخدامه لمطابقة المقطوعة';

  @override
  String get piped_warning =>
      'البعض منهم قد لا يعمل بشكل جيد. لذلك استخدمه على مسؤوليتك';

  @override
  String get invidious_instance => 'مثيل خادم Invidious';

  @override
  String get invidious_description =>
      'مثيل خادم Invidious المستخدم لمطابقة المسارات';

  @override
  String get invidious_warning =>
      'قد لا تعمل بعض الخوادم بشكل جيد. استخدمها على مسؤوليتك الخاصة';

  @override
  String get generate => 'إنشاء';

  @override
  String track_exists(Object track) {
    return 'المقطوعة $track بالفعل موجودة';
  }

  @override
  String get replace_downloaded_tracks =>
      'استبدل جميع المقطوعات التي تم تنزيلها';

  @override
  String get skip_download_tracks =>
      'تخطي تنزيل كافة المقطوعات التي تم تنزيلها';

  @override
  String get do_you_want_to_replace => 'هل تريد استبدال المقطوعة الحالية؟';

  @override
  String get replace => 'إستبدال';

  @override
  String get skip => 'تخطي';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'إختر ما يصل إلى $count $type';
  }

  @override
  String get select_genres => 'حدد الأنواع';

  @override
  String get add_genres => 'أضف الأنواع';

  @override
  String get country => 'دولة';

  @override
  String get number_of_tracks_generate =>
      'عدد المسارات المقطوعات المراد توليدها';

  @override
  String get acousticness => 'صوتية';

  @override
  String get danceability => 'قدرة على الرقص';

  @override
  String get energy => 'طاقة';

  @override
  String get instrumentalness => 'نفعية';

  @override
  String get liveness => 'حيوية';

  @override
  String get loudness => 'بريق';

  @override
  String get speechiness => 'كلام';

  @override
  String get valence => 'تكافؤ';

  @override
  String get popularity => 'شعبية';

  @override
  String get key => 'مفتاح';

  @override
  String get duration => 'مدة (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Mode';

  @override
  String get time_signature => 'توقيع الوقت';

  @override
  String get short => 'قصير';

  @override
  String get medium => 'متوسط';

  @override
  String get long => 'طويل';

  @override
  String get min => 'أدنى';

  @override
  String get max => 'أقصى';

  @override
  String get target => 'هدف';

  @override
  String get moderate => 'معتدل';

  @override
  String get deselect_all => 'الغاء تحديد الكل';

  @override
  String get select_all => 'اختر الكل';

  @override
  String get are_you_sure => 'هل أنت متأكد؟';

  @override
  String get generating_playlist => 'جارٍ إنشاء قائمة التشغيل المخصصة...';

  @override
  String selected_count_tracks(Object count) {
    return 'مقطوعات $count مختارة';
  }

  @override
  String get download_warning =>
      'إذا قمت بتنزيل جميع المقاطع الصوتية بكميات كبيرة، فمن الواضح أنك تقوم بقرصنة الموسيقى وتسبب الضرر للمجتمع الإبداعي للموسيقى. أتمنى أن تكون على علم بهذا. حاول دائمًا احترام ودعم العمل الجاد للفنان';

  @override
  String get download_ip_ban_warning =>
      'بالمناسبة، يمكن أن يتم حظر عنوان IP الخاص بك على YouTube بسبب طلبات التنزيل الزائدة عن المعتاد. يعني حظر IP أنه لا يمكنك استخدام YouTube (حتى إذا قمت بتسجيل الدخول) لمدة تتراوح بين شهرين إلى ثلاثة أشهر على الأقل من جهاز IP هذا. ولا يتحمل DeeMusiq أي مسؤولية إذا حدث هذا على الإطلاق';

  @override
  String get by_clicking_accept_terms =>
      'بالنقر على \"قبول\"، فإنك توافق على الشروط التالية:';

  @override
  String get download_agreement_1 => 'أعلم أنني أقوم بقرصنة الموسيقى. انا سيئ';

  @override
  String get download_agreement_2 =>
      'سأدعم الفنان أينما أستطيع، وأنا أفعل هذا فقط لأنني لا أملك المال لشراء أعمالهم الفنية';

  @override
  String get download_agreement_3 =>
      'أدرك تمامًا أنه يمكن حظر عنوان IP الخاص بي على YouTube ولا أحمل DeeMusiq أو مالكيه/مساهميه المسؤولية عن أي حوادث ناجمة عن الإجراء الحالي الخاص بي';

  @override
  String get decline => 'رفض';

  @override
  String get accept => 'قبول';

  @override
  String get details => 'تفاصيل';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'قناة';

  @override
  String get likes => 'إعجابات';

  @override
  String get dislikes => 'عدم الإعجابات';

  @override
  String get views => 'مشاهدات';

  @override
  String get streamUrl => 'عنوان URL البث';

  @override
  String get stop => 'إيقاف';

  @override
  String get sort_newest => 'الترتيب حسب الأقدم';

  @override
  String get sort_oldest => 'الترتيب حسب الأقدم';

  @override
  String get sleep_timer => 'مؤقت النوم';

  @override
  String mins(Object minutes) {
    return '$minutes دقائق';
  }

  @override
  String hours(Object hours) {
    return '$hours ساعات';
  }

  @override
  String hour(Object hours) {
    return '$hours ساعة';
  }

  @override
  String get custom_hours => 'ساعات مخصصة';

  @override
  String get logs => 'سجلات';

  @override
  String get developers => 'المطورون';

  @override
  String get not_logged_in => 'لم تقم بتسجيل الدخول';

  @override
  String get search_mode => 'وضع البحث';

  @override
  String get audio_source => 'مصدر الصوت';

  @override
  String get ok => 'حسسناً';

  @override
  String get failed_to_encrypt => 'فشل في التشفير';

  @override
  String get encryption_failed_warning =>
      'يستخدم DeeMusiq التشفير لتخزين بياناتك بشكل آمن. لكنها فشلت في القيام بذلك. لذلك سيعود الأمر إلى التخزين غير الآمن\nإذا كنت تستخدم Linux، فيرجى التأكد من تثبيت أي خدمة سرية (gnome-keyring، kde-wallet، keepassxc، إلخ)';

  @override
  String get querying_info => 'جارٍ الاستعلام عن معلومات...';

  @override
  String get piped_api_down => 'Piped API معطلة';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'المثيل الموجه $pipedInstance معطل حاليًا\n\nيمكنك إما تغيير المثيل أو تغيير \'نوع API\' إلى YouTube API الرسمي\n\nتأكد من إعادة تشغيل التطبيق بعد التغيير';
  }

  @override
  String get you_are_offline => 'أنت غير متصل حالياً';

  @override
  String get connection_restored => 'تمت استعادة اتصالك بالإنترنت';

  @override
  String get use_system_title_bar => 'استخدم شريط عنوان النظام';

  @override
  String get crunching_results => 'تدمير النتائج';

  @override
  String get search_to_get_results => 'إبحث للحصول على النتائج';

  @override
  String get use_amoled_mode => 'استخدم وضع AMOLED';

  @override
  String get pitch_dark_theme => 'موضوع دارت الأسود الفحمي';

  @override
  String get normalize_audio => 'تطبيع الصوت';

  @override
  String get change_cover => 'تغيير الغلاف';

  @override
  String get add_cover => 'إضافة غلاف';

  @override
  String get restore_defaults => 'استعادة الإعدادات الافتراضية';

  @override
  String get download_music_format => 'تنسيق تنزيل الموسيقى';

  @override
  String get streaming_music_format => 'تنسيق بث الموسيقى';

  @override
  String get download_music_quality => 'جودة تنزيل الموسيقى';

  @override
  String get streaming_music_quality => 'جودة بث الموسيقى';

  @override
  String get login_with_lastfm => 'تسجيل الدخول باستخدام Last.fm';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect_lastfm => 'قطع الاتصال بـ Last.fm';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get login_with_your_lastfm =>
      'تسجيل الدخول باستخدام حساب Last.fm الخاص بك';

  @override
  String get scrobble_to_lastfm => 'تسجيل الاستماع على Last.fm';

  @override
  String get go_to_album => 'الانتقال إلى الألبوم';

  @override
  String get discord_rich_presence => 'وجود ديسكورد الغني';

  @override
  String get browse_all => 'تصفح الكل';

  @override
  String get genres => 'الأنواع الموسيقية';

  @override
  String get explore_genres => 'استكشاف الأنواع';

  @override
  String get friends => 'أصدقاء';

  @override
  String get no_lyrics_available =>
      'عذرًا، تعذر العثور على كلمات الأغنية لهذه العنصر';

  @override
  String get start_a_radio => 'بدء راديو';

  @override
  String get how_to_start_radio => 'كيف تريد بدء الراديو؟';

  @override
  String get replace_queue_question =>
      'هل تريد استبدال قائمة التشغيل الحالية أم إضافة إليها؟';

  @override
  String get endless_playback => 'تشغيل بلا نهاية';

  @override
  String get delete_playlist => 'حذف قائمة التشغيل';

  @override
  String get delete_playlist_confirmation =>
      'هل أنت متأكد أنك تريد حذف هذه قائمة التشغيل؟';

  @override
  String get local_tracks => 'المسارات المحلية';

  @override
  String get local_tab => 'محلي';

  @override
  String get song_link => 'رابط الأغنية';

  @override
  String get youtube_source_description => 'موصى به ويعمل بشكل أفضل.';

  @override
  String get piped_source_description =>
      'تشعر بالحرية؟ نفس يوتيوب ولكن أكثر حرية.';

  @override
  String get jiosaavn_source_description => 'الأفضل لمنطقة جنوب آسيا.';

  @override
  String get invidious_source_description => 'مشابه لـ Piped ولكن بتوافر أعلى';

  @override
  String highest_quality(Object quality) {
    return 'أعلى جودة: $quality';
  }

  @override
  String get select_audio_source => 'اختر مصدر الصوت';

  @override
  String get contribute_on_github => 'المساهمة على GitHub';

  @override
  String get browse_anonymously => 'تصفح بشكل مجهول';

  @override
  String get enable_connect => 'تمكين الاتصال';

  @override
  String get enable_connect_description =>
      'التحكم في DeeMusiq من الأجهزة الأخرى';

  @override
  String get devices => 'الأجهزة';

  @override
  String get select => 'اختر';

  @override
  String connect_client_alert(Object client) {
    return 'أنت تتم التحكم بواسطة $client';
  }

  @override
  String get this_device => 'هذا الجهاز';

  @override
  String get remote => 'بعيد';

  @override
  String get stats => 'إحصائيات';

  @override
  String and_n_more(Object count) {
    return 'و $count أكثر';
  }

  @override
  String get recently_played => 'تم تشغيله مؤخرًا';

  @override
  String get browse_more => 'تصفح المزيد';

  @override
  String get no_title => 'بدون عنوان';

  @override
  String get not_playing => 'غير مشغل';

  @override
  String get epic_failure => 'فشل كبير!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'تمت إضافة $tracks_length مسارات إلى قائمة الانتظار';
  }

  @override
  String get spotube_has_an_update => 'يوجد تحديث لسبوتيوب';

  @override
  String get download_now => 'تحميل الآن';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'تم إصدار سبوتيوب الليلي $nightlyBuildNum';
  }

  @override
  String release_version(Object version) {
    return 'تم إصدار سبوتيوب v$version';
  }

  @override
  String get read_the_latest => 'اقرأ الأحدث';

  @override
  String get release_notes => 'ملاحظات الإصدار';

  @override
  String get pick_color_scheme => 'اختر نظام الألوان';

  @override
  String get save => 'حفظ';

  @override
  String get choose_the_device => 'اختر الجهاز:';

  @override
  String get multiple_device_connected =>
      'تم توصيل أجهزة متعددة.\nاختر الجهاز الذي تريد إجراء هذه العملية عليه';

  @override
  String get nothing_found => 'لم يتم العثور على شيء';

  @override
  String get the_box_is_empty => 'الصندوق فارغ';

  @override
  String get top_artists => 'أفضل الفنانين';

  @override
  String get top_albums => 'أفضل الألبومات';

  @override
  String get this_week => 'هذا الأسبوع';

  @override
  String get this_month => 'هذا الشهر';

  @override
  String get last_6_months => 'آخر 6 أشهر';

  @override
  String get this_year => 'هذا العام';

  @override
  String get last_2_years => 'آخر سنتين';

  @override
  String get all_time => 'كل الوقت';

  @override
  String powered_by_provider(Object providerName) {
    return 'مدعوم من $providerName';
  }

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get profile_followers => 'المتابعين';

  @override
  String get birthday => 'عيد الميلاد';

  @override
  String get subscription => 'اشتراك';

  @override
  String get not_born => 'لم يولد';

  @override
  String get hacker => 'هاكر';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get no_name => 'بدون اسم';

  @override
  String get edit => 'تعديل';

  @override
  String get user_profile => 'ملف المستخدم';

  @override
  String count_plays(Object count) {
    return '$count تشغيلات';
  }

  @override
  String get minutes_listened => 'الدقائق المستمعة';

  @override
  String get streamed_songs => 'الأغاني المذاعة';

  @override
  String count_streams(Object count) {
    return '$count بث';
  }

  @override
  String get owned_by_you => 'مملوك لك';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return 'تم نسخ $shareUrl إلى الحافظة';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes دقيقة';
  }

  @override
  String get summary_minutes => 'الدقائق';

  @override
  String get summary_listened_to_music => 'استمعت إلى الموسيقى';

  @override
  String get summary_songs => 'أغاني';

  @override
  String get summary_streamed_overall => 'بث بشكل عام';

  @override
  String get summary_artists => 'الفنانين';

  @override
  String get summary_music_reached_you => 'وصلت إليك الموسيقى';

  @override
  String get summary_full_albums => 'ألبومات كاملة';

  @override
  String get summary_got_your_love => 'حصلت على حبك';

  @override
  String get summary_playlists => 'قوائم التشغيل';

  @override
  String get summary_were_on_repeat => 'كانت على التكرار';

  @override
  String get webview_not_found => 'لم يتم العثور على Webview';

  @override
  String get webview_not_found_description =>
      'لم يتم تثبيت بيئة تشغيل Webview على جهازك.\nإذا كانت مثبتة، تأكد من وجودها في environment PATH\n\nبعد التثبيت، أعد تشغيل التطبيق';

  @override
  String get unsupported_platform => 'المنصة غير مدعومة';

  @override
  String get cache_music => 'تخزين الموسيقى مؤقتًا';

  @override
  String get open => 'فتح';

  @override
  String get cache_folder => 'مجلد التخزين المؤقت';

  @override
  String get export => 'تصدير';

  @override
  String get clear_cache => 'مسح التخزين المؤقت';

  @override
  String get clear_cache_confirmation => 'هل تريد مسح التخزين المؤقت؟';

  @override
  String get export_cache_files => 'تصدير الملفات المخزنة مؤقتًا';

  @override
  String found_n_files(Object count) {
    return 'تم العثور على $count ملف';
  }

  @override
  String get export_cache_confirmation => 'هل تريد تصدير هذه الملفات إلى';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'تم تصدير $filesExported من أصل $files ملفات';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get download_all => 'تنزيل الكل';

  @override
  String get add_all_to_playlist => 'إضافة الكل إلى قائمة التشغيل';

  @override
  String get add_all_to_queue => 'إضافة الكل إلى القائمة';

  @override
  String get play_all_next => 'تشغيل الكل بعد ذلك';

  @override
  String get pause => 'إيقاف مؤقت';

  @override
  String get view_all => 'عرض الكل';

  @override
  String get no_tracks_added_yet => 'يبدو أنك لم تضف أي مسارات بعد';

  @override
  String get no_tracks => 'يبدو أنه لا يوجد أي مسارات هنا';

  @override
  String get no_tracks_listened_yet => 'يبدو أنك لم تستمع إلى أي شيء بعد';

  @override
  String get not_following_artists => 'أنت لا تتابع أي فنانين';

  @override
  String get no_favorite_albums_yet =>
      'يبدو أنك لم تضف أي ألبومات إلى المفضلة بعد';

  @override
  String get no_logs_found => 'لم يتم العثور على سجلات';

  @override
  String get youtube_engine => 'محرك يوتيوب';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine غير مثبت';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine غير مثبت في نظامك.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'تأكد من أنه متاح في متغير PATH أو\nحدد المسار الكامل للملف القابل للتنفيذ $engine أدناه';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'في أنظمة macOS/Linux/Unix مثل الأنظمة، لن يعمل تعيين المسار في .zshrc/.bashrc/.bash_profile وما إلى ذلك.\nيجب تعيين المسار في ملف تكوين الصدفة';

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
  String get download => 'تنزيل';

  @override
  String get file_not_found => 'الملف غير موجود';

  @override
  String get custom => 'مخصص';

  @override
  String get add_custom_url => 'إضافة URL مخصص';

  @override
  String get edit_port => 'تعديل المنفذ';

  @override
  String get port_helper_msg =>
      'القيمة الافتراضية هي -1 والتي تشير إلى رقم عشوائي. إذا كان لديك جدار ناري مُعد، يُوصى بتعيين هذا.';

  @override
  String connect_request(Object client) {
    return 'السماح لـ $client بالاتصال؟';
  }

  @override
  String get connection_request_denied =>
      'تم رفض الاتصال. المستخدم رفض الوصول.';

  @override
  String get an_error_occurred => 'حدث خطأ';

  @override
  String get copy_to_clipboard => 'نسخ إلى الحافظة';

  @override
  String get view_logs => 'عرض السجلات';

  @override
  String get retry => 'إعادة المحاولة';

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
      'لم تقُم بتعيين مزود بيانات افتراضي';

  @override
  String get manage_metadata_providers => 'إدارة مزوّدي البيانات';

  @override
  String get open_link_in_browser => 'فتح الرابط في المتصفح؟';

  @override
  String get do_you_want_to_open_the_following_link =>
      'هل ترغب في فتح الرابط التالي؟';

  @override
  String get unsafe_url_warning =>
      'قد يكون فتح الروابط من مصادر غير موثوقة غير آمن. تحرّ الحذر!\nيمكنك أيضًا نسخ الرابط إلى الحافظة.';

  @override
  String get copy_link => 'نسخ الرابط';

  @override
  String get building_your_timeline =>
      'جاري بناء المخطط الزمني استنادًا إلى استماعاتك...';

  @override
  String get official => 'رسمي';

  @override
  String author_name(Object author) {
    return 'المؤلّف: $author';
  }

  @override
  String get third_party => 'طرف ثالث';

  @override
  String get plugin_requires_authentication => 'تتطلّب الإضافة تسجيل الدخول';

  @override
  String get update_available => 'تحديث متوفر';

  @override
  String get supports_scrobbling => 'يدعم التتبع (scrobbling)';

  @override
  String get plugin_scrobbling_info =>
      'تقوم هذه الإضافة بتتبع مقاطعك الموسيقية لإنشاء سجل الاستماع الخاص بك.';

  @override
  String get default_metadata_source => 'مصدر البيانات الوصفية الافتراضي';

  @override
  String get set_default_metadata_source =>
      'تعيين مصدر البيانات الوصفية الافتراضي';

  @override
  String get default_audio_source => 'مصدر الصوت الافتراضي';

  @override
  String get set_default_audio_source => 'تعيين مصدر الصوت الافتراضي';

  @override
  String get set_default => 'تعيين كافتراضي';

  @override
  String get support => 'الدعم';

  @override
  String get support_plugin_development => 'دعم تطوير الإضافات';

  @override
  String can_access_name_api(Object name) {
    return '- يمكن الوصول إلى واجهة برمجة التطبيقات **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'هل ترغب في تثبيت هذه الإضافة؟';

  @override
  String get third_party_plugin_warning =>
      'هذه الإضافة من مستودع طرف ثالث. تأكد من موثوقية المصدر قبل التثبيت.';

  @override
  String get author => 'المؤلف';

  @override
  String get this_plugin_can_do_following => 'يمكن لهذه الإضافة القيام بما يلي';

  @override
  String get install => 'تثبيت';

  @override
  String get no_tracks_playing => 'لا توجد مقاطع تعمل حاليًا';

  @override
  String get synced_lyrics_not_available =>
      'الكلمات المتزامنة غير متوفرة لهذه الأغنية. يُرجى استخدام';

  @override
  String get plain_lyrics => 'الكلمات العادية';

  @override
  String get tab_instead => 'بدلاً من ذلك، استخدم التبويب.';

  @override
  String get disclaimer => 'إخلاء المسؤولية';

  @override
  String get third_party_plugin_dmca_notice =>
      'لا تتحمّل فريق DeeMusiq أي مسؤولية (بما في ذلك القانونية) عن أي من الإضافات “لطرف ثالث”.\nاستخدمها على مسؤوليتك الخاصّة. لأيّة أخطاء/مشكلات، يُرجى الإبلاغ عنها في مستودع الإضافة.\n\nإذا كانت أي إضافة “لطرف ثالث” تنتهك شروط الخدمة أو قانون DMCA الخاص بأي خدمة أو كيان قانوني، فيُرجى طلب اتخاذ إجراء من مؤلف الإضافة أو منصة الاستضافة مثل GitHub/Codeberg. الإضافات المدرجة كـ “لطرف ثالث” هي مفعّلة ومُدارة من المجتمع، وليس لدينا صلاحية إدارتها أو التدخل فيها.\n\n';

  @override
  String get plugins => 'الإضافات';

  @override
  String get paste_plugin_download_url =>
      'الصق رابط التنزيل أو GitHub/Codeberg أو رابط مباشر لملف .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'تنزيل وتثبيت الإضافة من رابط';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'فشل في إضافة الإضافة: $error';
  }

  @override
  String get upload_plugin_from_file => 'رفع الإضافة من ملف';

  @override
  String get installed => 'تم التثبيت';

  @override
  String get available_plugins => 'الإضافات المتوفّرة';

  @override
  String get configure_plugins =>
      'قم بتكوين مزود البيانات الوصفية ومكونات مصدر الصوت الخاصة بك';

  @override
  String get audio_scrobblers => 'أجهزة تتبع الصوت';

  @override
  String get scrobbling => 'التتبع';

  @override
  String get source => 'المصدر: ';

  @override
  String get uncompressed => 'غير مضغوط';

  @override
  String get dab_music_source_description =>
      'لمحبي الصوتيات. يوفر تدفقات صوتية عالية الجودة/بدون فقدان. مطابقة دقيقة للمسارات بناءً على ISRC.';

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
  String get skip_this_nonsense => 'تخطي هذه الهراء';

  @override
  String get freedom_of_music => '“حرية الموسيقى”';

  @override
  String get freedom_of_music_palm => '“حرية الموسيقى في متناول يدك”';

  @override
  String get get_started => 'لنبدأ';

  @override
  String get endless_playback_description =>
      'إلحاق الأغاني الجديدة تلقائيًا\nإلى نهاية قائمة التشغيل';

  @override
  String get choose_your_region => 'اختر منطقتك';

  @override
  String get choose_your_region_description =>
      'سيساعدك هذا في عرض المحتوى المناسب\nلموقعك.';

  @override
  String get choose_your_language => 'اختر لغتك';

  @override
  String get help_project_grow => 'ساعد في نمو هذا المشروع';

  @override
  String get help_project_grow_description =>
      'DeeMusiq هو مشروع مفتوح المصدر. يمكنك مساعدة هذا المشروع في النمو عن طريق المساهمة في المشروع، أو الإبلاغ عن الأخطاء، أو اقتراح ميزات جديدة.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'التبرع على Open Collective';

  @override
  String get install_a_metadata_provider => 'تثبيت مزوّد بيانات';

  @override
  String get input_does_not_match_format =>
      'المدخل لا يتوافق مع التنسيق المطلوب';

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
  String get creator_email_gate_title => 'Sign in with email to create';

  @override
  String get creator_email_gate_body =>
      'The Creator Studio belongs to your email + password account. Sign in below, or create an account — we email you a 6-digit code to verify the address.';

  @override
  String get creator_sign_in_cta => 'Sign in';

  @override
  String get creator_add_email_title => 'Add an email to become a creator';

  @override
  String get creator_add_email_body =>
      'This account is device-only. Add an email and password — we\'ll email you a 6-digit code to confirm the address.';

  @override
  String get creator_save_and_email_code => 'Save & email code';

  @override
  String get creator_verify_email_title => 'Verify your email';

  @override
  String creator_verify_email_body(String email) {
    return 'We emailed a 6-digit code to $email. Enter it below to unlock the Creator Studio.';
  }

  @override
  String get creator_email_code_sent =>
      'Check your inbox — a new code is on its way.';

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
  String get playback_youtube_quality => 'Stream Quality';

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
  String get auth_mfa_required => 'أدخل رمز المصادقة';

  @override
  String get auth_mfa_body =>
      'افتح تطبيق المصادقة وأدخل الرمز المكون من 6 أرقام لإكمال تسجيل الدخول.';

  @override
  String get auth_mfa_verify_action => 'تحقق';

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

  @override
  String get signup_create_account => 'Create an account';

  @override
  String get signup_title => 'Create your DeeMusiq account';

  @override
  String get signup_subtitle =>
      'Sign up with any email address and a password. No device setup needed.';

  @override
  String get signup_email_hint => 'Email address';

  @override
  String get signup_password_hint => 'Password';

  @override
  String get signup_password_rule =>
      'At least 12 characters, using 3 of: uppercase, lowercase, a number, a symbol.';

  @override
  String get signup_invalid_email => 'Enter a valid email address.';

  @override
  String get signup_enter_password => 'Enter a password.';

  @override
  String get signup_confirm => 'Confirm my email';

  @override
  String signup_code_sent(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String signup_enter_code(String email) {
    return 'Enter the 6-digit code we emailed to $email.';
  }

  @override
  String get signup_code_hint => '6-digit code';

  @override
  String get signup_code_length => 'Enter the 6-digit code from your email.';

  @override
  String get signup_resend_code => 'Send a new code';

  @override
  String get signup_code_resent => 'A new code is on its way.';

  @override
  String get signup_back_to_sign_in => 'Back to sign in';
}
