// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get guest => 'مهمان';

  @override
  String get browse => 'مرور';

  @override
  String get search => 'جستجو';

  @override
  String get library => 'مجموعه';

  @override
  String get lyrics => 'متن';

  @override
  String get settings => 'تنظیمات';

  @override
  String get genre_categories_filter => 'دسته ها یا ژانر ها را فیلتر کنید';

  @override
  String get genre => 'ژانر';

  @override
  String get personalized => ' شخصی سازی شده';

  @override
  String get featured => 'ویژه';

  @override
  String get new_releases => 'آخرین انتشارات';

  @override
  String get songs => 'آهنگ ها';

  @override
  String playing_track(Object track) {
    return 'درحال پخش $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'با این کار صف فعلی پاک می شود. $track_length آهنگ از صف حذف میشود\n؟آیا ادامه میدهید';
  }

  @override
  String get load_more => 'بارگذاری بیشتر';

  @override
  String get playlists => 'لیست های پخش';

  @override
  String get artists => 'هنرمندان';

  @override
  String get albums => 'آلبوم ها';

  @override
  String get tracks => 'آهنگ ها';

  @override
  String get downloads => 'بارگیری شده ها';

  @override
  String get filter_playlists => 'لیست پخش خود را فیلتر کنید...';

  @override
  String get liked_tracks => 'آهنگ های مورد علاقه';

  @override
  String get liked_tracks_description => 'همه آهنگ های دوست داشتنی شما';

  @override
  String get playlist => 'لیست پخش';

  @override
  String get create_a_playlist => 'ساخت لیست پخش';

  @override
  String get update_playlist => 'بروز کردن لیست پخش';

  @override
  String get create => 'ساختن';

  @override
  String get cancel => 'لغو';

  @override
  String get update => 'بروز رسانی';

  @override
  String get playlist_name => 'نام لیست پخش';

  @override
  String get name_of_playlist => 'نام لیست پخش';

  @override
  String get description => 'توضیحات';

  @override
  String get public => 'عمومی';

  @override
  String get collaborative => 'مبتنی بر همکاری';

  @override
  String get search_local_tracks => 'جستجوی آهنگ های محلی...';

  @override
  String get play => 'پخش';

  @override
  String get delete => 'حذف';

  @override
  String get none => 'هیچ کدام';

  @override
  String get sort_a_z => 'مرتب سازی بر اساس حروف الفبا';

  @override
  String get sort_z_a => 'مرتب سازی برعکس حروف الفبا';

  @override
  String get sort_artist => 'مرتب سازی بر اساس هنرمند';

  @override
  String get sort_album => 'مرتب سازی بر اساس آلبوم';

  @override
  String get sort_duration => 'مرتب کردن بر اساس مدت زمان';

  @override
  String get sort_tracks => 'مرتب سازی آهنگ ها';

  @override
  String currently_downloading(Object tracks_length) {
    return 'در حال بارگیری ($tracks_length)';
  }

  @override
  String get cancel_all => 'لغو همه';

  @override
  String get filter_artist => 'فیلتر کردن هنرمند...';

  @override
  String followers(Object followers) {
    return '$followers دنبال کننده';
  }

  @override
  String get add_artist_to_blacklist => 'اضافه کردن هنرمند به لیست سیاه';

  @override
  String get top_tracks => 'بهترین آهنگ ها';

  @override
  String get fans_also_like => 'طرفداران هم دوست داشتند';

  @override
  String get loading => 'بارگزاری...';

  @override
  String get artist => 'هنرمند';

  @override
  String get blacklisted => 'در لیست سیاه قرار گرفته است';

  @override
  String get following => 'دنبال کننده';

  @override
  String get follow => 'دنبال کردن';

  @override
  String get artist_url_copied => 'لینک هنرمند در کلیپ بورد کپی شد';

  @override
  String added_to_queue(Object tracks) {
    return 'تعداد $tracks آهنگ به صف اضافه شد';
  }

  @override
  String get filter_albums => 'فیلتر کردن آلبوم...';

  @override
  String get synced => 'همگام سازی شد';

  @override
  String get plain => 'ساده';

  @override
  String get shuffle => 'تصادفی';

  @override
  String get search_tracks => 'جستجوی آهنگ ها...';

  @override
  String get released => 'منتشر شده';

  @override
  String error(Object error) {
    return 'خطا $error';
  }

  @override
  String get title => 'عنوان';

  @override
  String get time => 'زمان';

  @override
  String get more_actions => 'اقدامات بیشتر';

  @override
  String download_count(Object count) {
    return 'دانلود ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'اضافه کردن ($count) به لیست پخش';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'اضافه کردن ($count) به صف';
  }

  @override
  String play_count_next(Object count) {
    return 'پخش ($count) بعدی';
  }

  @override
  String get album => 'آلبوم';

  @override
  String copied_to_clipboard(Object data) {
    return '$data در کلیپ بورد کپی شد';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'اضافه کردن $track به لیست پخش زیر';
  }

  @override
  String get add => 'اضافه کردن';

  @override
  String added_track_to_queue(Object track) {
    return '$track به لیست پخش اضافه شد';
  }

  @override
  String get add_to_queue => 'اضافه کردن به صف';

  @override
  String track_will_play_next(Object track) {
    return '$track پخش خواهد شد';
  }

  @override
  String get play_next => 'پخش آهنگ بعدی';

  @override
  String removed_track_from_queue(Object track) {
    return '$track از لیست پخش حذف شد';
  }

  @override
  String get remove_from_queue => 'از لیست پخش حذف شد';

  @override
  String get remove_from_favorites => 'از علاقمندی ها حدف شد';

  @override
  String get save_as_favorite => 'ذخیره به عنوان علاقمندی ها';

  @override
  String get add_to_playlist => 'به لیست پخش اضافه کردن';

  @override
  String get remove_from_playlist => 'از لیست پخش حذف کردن';

  @override
  String get add_to_blacklist => 'به لیست سیاه اضافه کردن';

  @override
  String get remove_from_blacklist => 'از لیست سیاه حذف کردن';

  @override
  String get share => 'اشتراک گذاری';

  @override
  String get mini_player => 'پخش کننده ';

  @override
  String get slide_to_seek => 'برای جستجو عقب یا جلو بکشید';

  @override
  String get shuffle_playlist => 'پخش تصادفی';

  @override
  String get unshuffle_playlist => 'خاموش کردن پخش تصادفی';

  @override
  String get previous_track => 'آهنگ قبلی';

  @override
  String get next_track => 'آهنگ بعدی';

  @override
  String get pause_playback => 'توقف آهنگ';

  @override
  String get resume_playback => 'ادامه آهنگ';

  @override
  String get loop_track => 'تکرار آهنگ';

  @override
  String get no_loop => 'بدون حلقه';

  @override
  String get repeat_playlist => 'تکرار لیست پخش';

  @override
  String get queue => 'صف';

  @override
  String get alternative_track_sources => ' منبع آهنگ را جاگزین کردن ';

  @override
  String get download_track => 'بارگیری آهنگ';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks آهنگ در صف';
  }

  @override
  String get clear_all => 'همه را حدف کن';

  @override
  String get show_hide_ui_on_hover => 'نمایش/پنهان رابط کاربری در حالت شناور';

  @override
  String get always_on_top => 'همیشه روشن';

  @override
  String get exit_mini_player => 'از پخش کننده خارج شوید';

  @override
  String get download_location => 'محل بارگیری';

  @override
  String get local_library => 'کتابخانه محلی';

  @override
  String get add_library_location => 'اضافه کردن به کتابخانه';

  @override
  String get remove_library_location => 'حذف از کتابخانه';

  @override
  String get account => 'حساب کاربری';

  @override
  String get logout => 'خارج شدن';

  @override
  String get logout_of_this_account => 'از حساب کاربری خارج شوید';

  @override
  String get language_region => 'زبان و منطقه ';

  @override
  String get language => 'زبان ';

  @override
  String get system_default => 'پیش فرض سیستم';

  @override
  String get market_place_region => 'منطقه';

  @override
  String get recommendation_country => 'کشور های پیشنهادی';

  @override
  String get appearance => 'ظاهر';

  @override
  String get layout_mode => 'حالت چیدمان';

  @override
  String get override_layout_settings =>
      'تنطیمات حالت واکنشگرای چیدمان را لغو کن';

  @override
  String get adaptive => 'قابل تطبیق';

  @override
  String get compact => 'فشرده';

  @override
  String get extended => 'گسترده';

  @override
  String get theme => 'تم';

  @override
  String get dark => 'تاریک';

  @override
  String get light => 'روشن';

  @override
  String get system => 'سیستم';

  @override
  String get accent_color => 'رنگ تاکیدی';

  @override
  String get sync_album_color => 'هنگام سازی رنگ البوم';

  @override
  String get sync_album_color_description =>
      'از رنگ البوم هنرمند به عنوان رنگ تاکیدی استفاده میکند';

  @override
  String get playback => 'پخش';

  @override
  String get audio_quality => 'کیفیت صدا';

  @override
  String get high => 'زیاد';

  @override
  String get low => 'کم';

  @override
  String get pre_download_play => 'دانلود و پخش کنید';

  @override
  String get pre_download_play_description =>
      'به جای پخش جریانی صدا، بایت ها را دانلود کنید و به جای آن پخش کنید (برای کاربران با پهنای باند بالاتر توصیه می شود)';

  @override
  String get skip_non_music => 'رد شدن از پخش های غیر موسیقی (SponsorBlock)';

  @override
  String get blacklist_description => 'آهنگ ها و هنرمند های در لیست سیاه';

  @override
  String get wait_for_download_to_finish =>
      'لطفا صبر کنید تا دانلود آهنگ جاری تمام شود';

  @override
  String get desktop => 'میز کار';

  @override
  String get close_behavior => 'رفتار نزدیک';

  @override
  String get close => 'بستن';

  @override
  String get minimize_to_tray => 'پتجره را کوچک کنید';

  @override
  String get show_tray_icon => 'نماد را نمایش بده';

  @override
  String get about => 'درباره';

  @override
  String get u_love_spotube => 'دوست داریدDeeMusiqما میدانیم شما ';

  @override
  String get check_for_updates => 'بروزرسانی را بررسی کنید';

  @override
  String get about_spotube => 'DeeMusiq درباره';

  @override
  String get blacklist => 'لیست سیاه';

  @override
  String get please_sponsor => 'لطفا کمک/حمایت کنید';

  @override
  String get spotube_description =>
      'یک برنامه سبک و مولتی پلتفرم و رایگان برای همه استDeeMusiq';

  @override
  String get version => 'نسخه';

  @override
  String get build_number => 'شماره ساخت';

  @override
  String get founder => 'بنیانگذار';

  @override
  String get repository => 'مخزن';

  @override
  String get bug_issues => 'اشکال+مسایل';

  @override
  String get made_with => '🇧🇩ساخته شده با ❤️ در بنگلادش';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'مجوز';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'نگران نباشید هیچ کدوما از اعتبارات شما جمع اوری نمیشود یا با کسی اشتراک گزاشته نمیشود';

  @override
  String get know_how_to_login => 'نمیدانی چگونه این کار را انجام بدهی؟';

  @override
  String get follow_step_by_step_guide => 'راهنما را گام به گام دنبال کنید';

  @override
  String cookie_name_cookie(Object name) {
    return '$name کوکی';
  }

  @override
  String get fill_in_all_fields => 'لطفا تمام فلید ها را پر کنید';

  @override
  String get submit => 'ثبت';

  @override
  String get exit => 'خروج';

  @override
  String get previous => 'قبلی';

  @override
  String get next => 'بعدی ';

  @override
  String get done => 'اتمام';

  @override
  String get step_1 => 'گام 1';

  @override
  String get first_go_to => 'اول برو داخل ';

  @override
  String get something_went_wrong => 'اشتباهی رخ داده';

  @override
  String get piped_instance => 'مشکل در ارتباط با سرور';

  @override
  String get piped_description => 'مشکل در ارتباط با سرور در دریافت آهنگ ها';

  @override
  String get piped_warning =>
      'برخی از آنها ممکن است خوب کارنکند.بنابراین با مسولیت خود استفاده کنید';

  @override
  String get invidious_instance => 'نمونه سرور Invidious';

  @override
  String get invidious_description => 'نمونه سرور Invidious برای تطبیق آهنگ';

  @override
  String get invidious_warning =>
      'برخی از نمونه‌ها ممکن است به خوبی کار نکنند. با احتیاط استفاده کنید';

  @override
  String get generate => 'ایجاد';

  @override
  String track_exists(Object track) {
    return 'آهنگ $track وجود دارد';
  }

  @override
  String get replace_downloaded_tracks =>
      'همه ی آهنگ های دانلود شده را جایگزین کنید';

  @override
  String get skip_download_tracks => 'همه ی آهنگ های دانلود شده را رد کنید';

  @override
  String get do_you_want_to_replace =>
      'ایا میخواهید آهنگ های موجود جایگزین کنید؟';

  @override
  String get replace => 'جایگزین کردن';

  @override
  String get skip => 'رد کردن';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'انتخاب کنید تا $count $type';
  }

  @override
  String get select_genres => 'ژانر ها را انتخاب کنید';

  @override
  String get add_genres => 'ژانر را اطافه کنید';

  @override
  String get country => 'کشور';

  @override
  String get number_of_tracks_generate => 'تعداد آهنگ های ساخته شده';

  @override
  String get acousticness => 'آکوستیک';

  @override
  String get danceability => 'رقصیدن';

  @override
  String get energy => 'انرژی';

  @override
  String get instrumentalness => 'بی کلام';

  @override
  String get liveness => 'حس زندگی';

  @override
  String get loudness => 'صدای بلند';

  @override
  String get speechiness => 'دکلمه';

  @override
  String get valence => 'ظرفیت';

  @override
  String get popularity => 'محبوبیت';

  @override
  String get key => 'کلید';

  @override
  String get duration => 'مدت زمان (ثانیه)';

  @override
  String get tempo => 'تمپو (BPM)';

  @override
  String get mode => 'حالت';

  @override
  String get time_signature => 'امضای زمان';

  @override
  String get short => 'کوتاه';

  @override
  String get medium => 'متوسط';

  @override
  String get long => 'بلند';

  @override
  String get min => 'حداقل';

  @override
  String get max => 'حداکثر';

  @override
  String get target => 'هدف';

  @override
  String get moderate => 'حد وسط';

  @override
  String get deselect_all => 'همه را لغو انتخاب کنید';

  @override
  String get select_all => 'همه را انتخاب کنید';

  @override
  String get are_you_sure => 'ایا مطمعن هستید؟';

  @override
  String get generating_playlist => ' درحال ایجاد لیست پخش سفارشی شما';

  @override
  String selected_count_tracks(Object count) {
    return 'آهنگ انتخاب شده $count';
  }

  @override
  String get download_warning =>
      'اگر همه ی آهنگ ها را به صورت انبو دانلود کنید به وضوح در حال دزدی موسقی هستید و در حال اسیب وارد کردن به جامه ی خلاق هنری می باشید .امیدوارم که از این موضوع اگاه باشید .همیشه سعی کنید به کار سخت هنرمند اخترام بگذارید.';

  @override
  String get download_ip_ban_warning =>
      'راستی آی پی شما می تواند در یوتوب به دلیل درخواست های دانلود بیش از حد معمول مسدود شود. بلوک آی پی به این معنی است که شما نمی توانید از یوتوب (حتی اگر وارد سیستم شده باشید) حداقل 2-3 ماه از آن دستگاه آی پی استفاده کنید. و DeeMusiq هیچ مسئولیتی در صورت وقوع این اتفاق ندارد';

  @override
  String get by_clicking_accept_terms =>
      'با کلیک بر روی قبول با شرایط زیر موافقت می کنید:';

  @override
  String get download_agreement_1 => 'من میدانم در حال دزدی هستم .من بد هستم';

  @override
  String get download_agreement_2 =>
      'من هر کجا ک بتوانم از هنرمندان حمایت میکنم اما این کارا فقط به دلیل اینکه توانایی مالی ندارم انجام میدهم';

  @override
  String get download_agreement_3 =>
      'من کاملا میدانم که از طرف یوتوب بلاک میشم و این برنامه و مالکان را مسول این حادثه نمیدانم.';

  @override
  String get decline => 'قبول نکردن';

  @override
  String get accept => 'قبول';

  @override
  String get details => 'جزئیات';

  @override
  String get youtube => 'یوتیوب';

  @override
  String get channel => 'کانال';

  @override
  String get likes => 'دوست داشتن';

  @override
  String get dislikes => 'دوست نداشتن';

  @override
  String get views => 'بازدید';

  @override
  String get streamUrl => 'لینک اثر';

  @override
  String get stop => 'توقف';

  @override
  String get sort_newest => 'مرتب سازی بر اساس جدید ترین اضافه شده';

  @override
  String get sort_oldest => 'مرتب سازی بر اساس قدیمی ترین اضافه شده';

  @override
  String get sleep_timer => 'زمان خواب';

  @override
  String mins(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String hours(Object hours) {
    return '$hours ساعت';
  }

  @override
  String hour(Object hours) {
    return '$hours ساعت';
  }

  @override
  String get custom_hours => 'ساعت سفارشی';

  @override
  String get logs => 'رسید خطا';

  @override
  String get developers => 'توسعه دهنده ها';

  @override
  String get not_logged_in => 'شما وارد نشده اید ';

  @override
  String get search_mode => 'حالت جستجو';

  @override
  String get audio_source => 'منبع صدا';

  @override
  String get ok => 'باشد';

  @override
  String get failed_to_encrypt => 'رمز گذاری نشده';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq از رمزگذاری برای ذخیره ایمن داده های شما استفاده می کند. اما موفق به انجام این کار نشد. بنابراین به فضای ذخیره‌سازی ناامن تبدیل می‌شود\nاگر از لینوکس استفاده می‌کنید، لطفاً مطمئن شوید که سرویس مخفی (gnome-keyring، kde-wallet، keepassxc و غیره) را نصب کرده‌اید.';

  @override
  String get querying_info => 'جستجو درباره ';

  @override
  String get piped_api_down => 'ایراد در سرور';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'به دلیل مشکل $pipedInstance ارتباط با سرور مقدور نیست\n\nنمونه را تغییر دهید یا «نوع API» را به API رسمی YouTube تغییر دهید\n\nحتماً پس از تغییر، برنامه را دوباره راه‌اندازی کنید';
  }

  @override
  String get you_are_offline => 'شما در حال حاضر افلاین هستید ';

  @override
  String get connection_restored => 'اتصال به اینترنت شما بازیابی شد ';

  @override
  String get use_system_title_bar => 'از نوار عنوان سیستم استفاده کنید ';

  @override
  String get crunching_results => 'نتایج خرد کردن...';

  @override
  String get search_to_get_results => 'جستجو کنید تا به نتیجه برسید';

  @override
  String get use_amoled_mode => 'استفاده از حالت AMOLED';

  @override
  String get pitch_dark_theme => 'تم تیره دارت';

  @override
  String get normalize_audio => 'نرمال کردن صدا';

  @override
  String get change_cover => 'تغییر جلد';

  @override
  String get add_cover => 'افزودن جلد';

  @override
  String get restore_defaults => 'بازیابی پیش فرض ها';

  @override
  String get download_music_format => 'فرمت دانلود موسیقی';

  @override
  String get streaming_music_format => 'فرمت پخش آنلاین موسیقی';

  @override
  String get download_music_quality => 'کیفیت دانلود موسیقی';

  @override
  String get streaming_music_quality => 'کیفیت پخش آنلاین موسیقی';

  @override
  String get login_with_lastfm => 'ورود با Last.fm';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect_lastfm => 'قطع ارتباط با Last.fm';

  @override
  String get disconnect => 'قطع ارتباط';

  @override
  String get username => 'نام کاربری';

  @override
  String get password => 'رمز عبور';

  @override
  String get login => 'ورود';

  @override
  String get login_with_your_lastfm => 'ورود با حساب کاربری Last.fm خود';

  @override
  String get scrobble_to_lastfm => 'Scrobble به Last.fm';

  @override
  String get go_to_album => 'رفتن به آلبوم';

  @override
  String get discord_rich_presence => 'حضور غنی دیسکورد';

  @override
  String get browse_all => 'مرور همه';

  @override
  String get genres => 'ژانرها';

  @override
  String get explore_genres => 'استکشاف ژانرها';

  @override
  String get friends => 'دوستان';

  @override
  String get no_lyrics_available =>
      'متاسفیم، قادر به یافتن متن این قطعه نیستیم';

  @override
  String get start_a_radio => 'شروع یک رادیو';

  @override
  String get how_to_start_radio => 'چگونه می‌خواهید رادیو را شروع کنید؟';

  @override
  String get replace_queue_question =>
      'آیا می‌خواهید لیست پخش فعلی را جایگزین کنید یا به آن اضافه کنید؟';

  @override
  String get endless_playback => 'پخش بی‌پایان';

  @override
  String get delete_playlist => 'حذف لیست پخش';

  @override
  String get delete_playlist_confirmation =>
      'آیا مطمئن هستید که می‌خواهید این لیست پخش را حذف کنید؟';

  @override
  String get local_tracks => 'موسیقی‌های محلی';

  @override
  String get local_tab => 'محلی';

  @override
  String get song_link => 'پیوند آهنگ';

  @override
  String get youtube_source_description => 'پیشنهاد شده و بهترین عمل می‌کند.';

  @override
  String get piped_source_description =>
      'احساس آزادی می‌کنید؟ مانند یوتیوب اما بیشتر آزاد.';

  @override
  String get jiosaavn_source_description => 'بهترین برای منطقه جنوب آسیا.';

  @override
  String get invidious_source_description =>
      'شبیه Piped اما با در دسترس بودن بیشتر';

  @override
  String highest_quality(Object quality) {
    return 'بالاترین کیفیت: $quality';
  }

  @override
  String get select_audio_source => 'انتخاب منبع صوتی';

  @override
  String get contribute_on_github => 'مشارکت در GitHub';

  @override
  String get browse_anonymously => 'مرور به صورت ناشناس';

  @override
  String get enable_connect => 'فعال‌سازی اتصال';

  @override
  String get enable_connect_description => 'کنترل DeeMusiq از دیگر دستگاه‌ها';

  @override
  String get devices => 'دستگاه‌ها';

  @override
  String get select => 'انتخاب';

  @override
  String connect_client_alert(Object client) {
    return 'شما توسط $client کنترل می‌شوید';
  }

  @override
  String get this_device => 'این دستگاه';

  @override
  String get remote => 'راه‌دور';

  @override
  String get stats => 'آمار';

  @override
  String and_n_more(Object count) {
    return 'و $count بیشتر';
  }

  @override
  String get recently_played => 'اخیراً پخش شده';

  @override
  String get browse_more => 'بیشتر مرور کنید';

  @override
  String get no_title => 'بدون عنوان';

  @override
  String get not_playing => 'در حال پخش نیست';

  @override
  String get epic_failure => 'شکست حماسی!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length ترک به صف اضافه شد';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq یک بروزرسانی دارد';

  @override
  String get download_now => 'اکنون دانلود کنید';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'نسخه شبانه DeeMusiq $nightlyBuildNum منتشر شد';
  }

  @override
  String release_version(Object version) {
    return 'نسخه DeeMusiq v$version منتشر شد';
  }

  @override
  String get read_the_latest => 'آخرین‌ها را بخوانید';

  @override
  String get release_notes => 'یادداشت‌های انتشار';

  @override
  String get pick_color_scheme => 'طرح رنگ را انتخاب کنید';

  @override
  String get save => 'ذخیره';

  @override
  String get choose_the_device => 'دستگاه را انتخاب کنید:';

  @override
  String get multiple_device_connected =>
      'چندین دستگاه متصل هستند.\nدستگاهی را انتخاب کنید که می‌خواهید این عملیات بر روی آن انجام شود';

  @override
  String get nothing_found => 'چیزی پیدا نشد';

  @override
  String get the_box_is_empty => 'جعبه خالی است';

  @override
  String get top_artists => 'بهترین هنرمندان';

  @override
  String get top_albums => 'بهترین آلبوم‌ها';

  @override
  String get this_week => 'این هفته';

  @override
  String get this_month => 'این ماه';

  @override
  String get last_6_months => '۶ ماه گذشته';

  @override
  String get this_year => 'امسال';

  @override
  String get last_2_years => '۲ سال گذشته';

  @override
  String get all_time => 'همیشه';

  @override
  String powered_by_provider(Object providerName) {
    return 'توسط $providerName پشتیبانی شده است';
  }

  @override
  String get email => 'ایمیل';

  @override
  String get profile_followers => 'دنبال‌کنندگان';

  @override
  String get birthday => 'تولد';

  @override
  String get subscription => 'اشتراک';

  @override
  String get not_born => 'متولد نشده';

  @override
  String get hacker => 'هکر';

  @override
  String get profile => 'پروفایل';

  @override
  String get no_name => 'بدون نام';

  @override
  String get edit => 'ویرایش';

  @override
  String get user_profile => 'پروفایل کاربر';

  @override
  String count_plays(Object count) {
    return '$count پخش';
  }

  @override
  String get minutes_listened => 'دقایق گوش داده شده';

  @override
  String get streamed_songs => 'ترانه‌های پخش شده';

  @override
  String count_streams(Object count) {
    return '$count پخش';
  }

  @override
  String get owned_by_you => 'توسط شما مالکیت شده';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl به کلیپ‌بورد کپی شد';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get summary_minutes => 'دقیقه‌ها';

  @override
  String get summary_listened_to_music => 'به موسیقی گوش داده شده';

  @override
  String get summary_songs => 'ترانه‌ها';

  @override
  String get summary_streamed_overall => 'پخش شده به طور کلی';

  @override
  String get summary_artists => 'هنرمندان';

  @override
  String get summary_music_reached_you => 'موسیقی به شما رسیده است';

  @override
  String get summary_full_albums => 'آلبوم‌های کامل';

  @override
  String get summary_got_your_love => 'عشق شما را به دست آورد';

  @override
  String get summary_playlists => 'لیست‌های پخش';

  @override
  String get summary_were_on_repeat => 'در تکرار بودند';

  @override
  String get webview_not_found => 'وب‌ویو پیدا نشد';

  @override
  String get webview_not_found_description =>
      'هیچ اجرای وب‌ویو روی دستگاه شما نصب نشده است.\nدر صورت نصب، مطمئن شوید که در environment PATH قرار دارد\n\nپس از نصب، برنامه را مجدداً راه‌اندازی کنید';

  @override
  String get unsupported_platform => 'پلتفرم پشتیبانی نمی‌شود';

  @override
  String get cache_music => 'موسیقی در حافظه موقت';

  @override
  String get open => 'باز کردن';

  @override
  String get cache_folder => 'پوشه حافظه موقت';

  @override
  String get export => 'صادر کردن';

  @override
  String get clear_cache => 'پاک کردن حافظه موقت';

  @override
  String get clear_cache_confirmation =>
      'آیا می‌خواهید حافظه موقت را پاک کنید؟';

  @override
  String get export_cache_files => 'صادر کردن فایل‌های حافظه موقت';

  @override
  String found_n_files(Object count) {
    return '$count فایل یافت شد';
  }

  @override
  String get export_cache_confirmation =>
      'آیا می‌خواهید این فایل‌ها را صادر کنید به';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported از $files فایل صادر شد';
  }

  @override
  String get undo => 'بازگشت';

  @override
  String get download_all => 'دانلود همه';

  @override
  String get add_all_to_playlist => 'افزودن همه به لیست پخش';

  @override
  String get add_all_to_queue => 'افزودن همه به صف';

  @override
  String get play_all_next => 'پخش همه بعدی';

  @override
  String get pause => 'مکث';

  @override
  String get view_all => 'مشاهده همه';

  @override
  String get no_tracks_added_yet =>
      'به نظر می‌رسد هنوز هیچ آهنگی اضافه نکرده‌اید.';

  @override
  String get no_tracks => 'به نظر می‌رسد هیچ آهنگی در اینجا وجود ندارد.';

  @override
  String get no_tracks_listened_yet => 'به نظر می‌رسد هنوز چیزی نشنیده‌اید.';

  @override
  String get not_following_artists => 'شما هیچ هنرمندی را دنبال نمی‌کنید.';

  @override
  String get no_favorite_albums_yet =>
      'به نظر می‌رسد هنوز هیچ آلبومی را به علاقه‌مندی‌هایتان اضافه نکرده‌اید.';

  @override
  String get no_logs_found => 'هیچ لاگی پیدا نشد';

  @override
  String get youtube_engine => 'موتور YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine نصب نشده است';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine در سیستم شما نصب نشده است.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'اطمینان حاصل کنید که در متغیر PATH موجود است یا\nآدرس مطلق فایل اجرایی $engine را در زیر تنظیم کنید.';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'در macOS/Linux/سیستم‌عامل‌های مشابه Unix، تنظیم مسیر در .zshrc/.bashrc/.bash_profile و غیره کار نمی‌کند.\nباید مسیر را در فایل پیکربندی شل تنظیم کنید.';

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
  String get download => 'دانلود';

  @override
  String get file_not_found => 'فایل پیدا نشد';

  @override
  String get custom => 'شخصی‌سازی شده';

  @override
  String get add_custom_url => 'اضافه کردن URL سفارشی';

  @override
  String get edit_port => 'ویرایش پورت';

  @override
  String get port_helper_msg =>
      'پیش‌فرض -1 است که نشان‌دهنده یک عدد تصادفی است. اگر فایروال شما پیکربندی شده است، توصیه می‌شود این را تنظیم کنید.';

  @override
  String connect_request(Object client) {
    return 'آیا اجازه می‌دهید $client متصل شود؟';
  }

  @override
  String get connection_request_denied =>
      'اتصال رد شد. کاربر دسترسی را رد کرد.';

  @override
  String get an_error_occurred => 'خطایی رخ داد';

  @override
  String get copy_to_clipboard => 'کپی به کلیپ‌بورد';

  @override
  String get view_logs => 'مشاهده لاگ‌ها';

  @override
  String get retry => 'دوباره تلاش کن';

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
      'هیچ ارائه‌دهندهٔ پیش‌فرض متادیتا تعیین نکرده‌اید';

  @override
  String get manage_metadata_providers => 'مدیریت ارائه‌دهندگان متادیتا';

  @override
  String get open_link_in_browser => 'باز کردن لینک در مرورگر؟';

  @override
  String get do_you_want_to_open_the_following_link =>
      'آیا می‌خواهید لینک زیر را باز کنید؟';

  @override
  String get unsafe_url_warning =>
      'باز کردن لینک از منابع نامطمئن می‌تواند ناامن باشد. مراقب باشید!\nهمچنین می‌توانید لینک را در کلیپ‌بورد خود کپی کنید.';

  @override
  String get copy_link => 'کپی لینک';

  @override
  String get building_your_timeline =>
      'در حال ساخت جدول زمانی بر اساس شنیده‌هایتان…';

  @override
  String get official => 'رسمی';

  @override
  String author_name(Object author) {
    return 'نویسنده: $author';
  }

  @override
  String get third_party => 'سوم‌شخص';

  @override
  String get plugin_requires_authentication => 'افزونه نیاز به احراز هویت دارد';

  @override
  String get update_available => 'به‌روزرسانی در دسترس است';

  @override
  String get supports_scrobbling => 'پشتیبانی از اسکراب‌بلینگ';

  @override
  String get plugin_scrobbling_info =>
      'این افزونه موسیقی شما را اسکراب می‌کند تا تاریخچهٔ شنیداری‌تان را تولید کند.';

  @override
  String get default_metadata_source => 'منبع پیش‌فرض فراداده';

  @override
  String get set_default_metadata_source => 'تنظیم منبع پیش‌فرض فراداده';

  @override
  String get default_audio_source => 'منبع پیش‌فرض صوت';

  @override
  String get set_default_audio_source => 'تنظیم منبع پیش‌فرض صوت';

  @override
  String get set_default => 'تنظیم به عنوان پیش‌فرض';

  @override
  String get support => 'پشتیبانی';

  @override
  String get support_plugin_development => 'حمایت از توسعهٔ افزونه';

  @override
  String can_access_name_api(Object name) {
    return '- می‌تواند به API **$name** دسترسی پیدا کند';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'می‌خواهید این افزونه را نصب کنید؟';

  @override
  String get third_party_plugin_warning =>
      'این افزونه از مخزن شخص ثالث آمده است. لطفاً قبل از نصب از منابع آن مطمئن شوید.';

  @override
  String get author => 'نویسنده';

  @override
  String get this_plugin_can_do_following =>
      'این افزونه می‌تواند موارد زیر را انجام دهد';

  @override
  String get install => 'نصب';

  @override
  String get no_tracks_playing => 'در حال‌ حاضر هیچ تراکی در حال پخش نیست';

  @override
  String get synced_lyrics_not_available =>
      'متن هم‌زمان‌شده برای این آهنگ در دسترس نیست. لطفاً از';

  @override
  String get plain_lyrics => 'متن ساده';

  @override
  String get tab_instead => 'به‌جای آن از کلید Tab استفاده کنید.';

  @override
  String get disclaimer => 'سلب مسئولیت';

  @override
  String get third_party_plugin_dmca_notice =>
      'تیم DeeMusiq هیچ مسئولیتی (حتی قانونی) در قبال افزونه‌های \"شخص ثالث\" ندارد. از آن‌ها به‌خاطر خود استفاده کنید. برای خطاها/مشکلات، لطفاً در مخزن افزونه گزارش دهید.\n\nاگر هر افزونهٔ \"شخص ثالث\" قوانین ToS/DMCA سرویس یا نهاد قانونی را نقض کند، لطفاً از نویسندهٔ افزونه یا پلتفرم میزبانی (مثل GitHub/Codeberg) درخواست اقدام کنید. افزونه‌هایی که با برچسب \"شخص ثالث\" مشخص شده‌اند، عمومی هستند و توسط جامعه نگهداری می‌شوند؛ ما آن‌ها را تغییر یا مدیریت نمی‌کنیم و نمی‌توانیم دخالت کنیم.\n\n';

  @override
  String get plugins => 'افزونه‌ها';

  @override
  String get paste_plugin_download_url =>
      'URL دانلود یا مخزن GitHub/Codeberg یا لینک مستقیم فایل .smplug را الصاق کنید';

  @override
  String get download_and_install_plugin_from_url =>
      'دانلود و نصب افزونه از طریق لینک';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'افزونه اضافه نشد: $error';
  }

  @override
  String get upload_plugin_from_file => 'بارگذاری افزونه از فایل';

  @override
  String get installed => 'نصب شد';

  @override
  String get available_plugins => 'افزونه‌های موجود';

  @override
  String get configure_plugins =>
      'افزونه‌های منبع صوت و ارائه‌دهنده فراداده خود را پیکربندی کنید';

  @override
  String get audio_scrobblers => 'اسکراب‌بلرهای صوتی';

  @override
  String get scrobbling => 'اسکراب‌بلینگ';

  @override
  String get source => 'منبع: ';

  @override
  String get uncompressed => 'بدون فشرده‌سازی';

  @override
  String get dab_music_source_description =>
      'مخصوص علاقه‌مندان صدا. ارائه‌دهنده استریم‌های باکیفیت/بدون افت. تطبیق دقیق آهنگ بر اساس ISRC.';

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
  String get skip_this_nonsense => 'این احمقانه را بگذرانید';

  @override
  String get freedom_of_music => '“آزادی موسیقی”';

  @override
  String get freedom_of_music_palm => '“آزادی موسیقی در دستان شما”';

  @override
  String get get_started => 'بیایید شروع کنیم';

  @override
  String get endless_playback_description =>
      'خودکار اضافه کردن آهنگ‌های جدید\nبه انتهای صف';

  @override
  String get choose_your_region => 'منطقه خود را انتخاب کنید';

  @override
  String get choose_your_region_description =>
      'این به DeeMusiq کمک می‌کند تا محتوای مناسبی را برای موقعیت شما نشان دهد.';

  @override
  String get choose_your_language => 'زبان خود را انتخاب کنید';

  @override
  String get help_project_grow => 'کمک به رشد این پروژه';

  @override
  String get help_project_grow_description =>
      'DeeMusiq یک پروژه متن باز است. شما می‌توانید با به پروژه کمک کردن، گزارش دادن اشکالات یا پیشنهاد ویژگی‌های جدید، به این پروژه کمک کنید.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'کمک مالی در Open Collective';

  @override
  String get install_a_metadata_provider => 'نصب یک ارائه‌دهندهٔ متادیتا';

  @override
  String get input_does_not_match_format =>
      'ورودی با قالب مورد نیاز تطابق ندارد';

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
  String get auth_mfa_required => 'کد احراز هویت خود را وارد کنید';

  @override
  String get auth_mfa_body =>
      'برنامه احراز هویت را باز کنید و کد ۶ رقمی را برای ورود وارد کنید.';

  @override
  String get auth_mfa_verify_action => 'تأیید';

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
