// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get guest => 'অতিথি';

  @override
  String get browse => 'ব্রাউজ করুন';

  @override
  String get search => 'অনুসন্ধান করুন';

  @override
  String get library => 'লাইব্রেরী';

  @override
  String get lyrics => 'গানের কথা';

  @override
  String get settings => 'সেটিংস';

  @override
  String get genre_categories_filter => 'গানের ধরণ বা শ্রেণি খুঁজুন';

  @override
  String get genre => 'গানের ধরণ';

  @override
  String get personalized => 'আপনার জন্য';

  @override
  String get featured => 'বৈশিষ্ট্যযুক্ত';

  @override
  String get new_releases => 'সাম্প্রতিক মুক্তি প্রাপ্ত';

  @override
  String get songs => 'গান';

  @override
  String playing_track(Object track) {
    return '$track চালানো হচ্ছে';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'এটি বর্তমান প্লেলিষ্ট সাফ করে দিবে। $track_lengthটি গান বাদ দেওয়া হবে\nআপনি কি চালিয়ে যেতে চান?';
  }

  @override
  String get load_more => 'আরো লোড করুন';

  @override
  String get playlists => 'প্লেলিস্ট';

  @override
  String get artists => 'শিল্পী';

  @override
  String get albums => 'অ্যালবাম';

  @override
  String get tracks => 'গানের ট্র্যাক';

  @override
  String get downloads => 'ডাউনলোড';

  @override
  String get filter_playlists => 'প্লেলিস্ট অনুসন্ধান করুন...';

  @override
  String get liked_tracks => 'পছন্দের গান';

  @override
  String get liked_tracks_description => 'আপনার পছন্দের গান সমূহ';

  @override
  String get playlist => 'প্লেলিস্ট';

  @override
  String get create_a_playlist => 'একটি প্লেলিস্ট তৈরি করুন';

  @override
  String get update_playlist => 'প্লেলিস্ট আপডেট করুন';

  @override
  String get create => 'তৈরি করুন';

  @override
  String get cancel => 'বাতিল করুন';

  @override
  String get update => 'আপডেট';

  @override
  String get playlist_name => 'প্লেলিস্টের নাম';

  @override
  String get name_of_playlist => 'প্লেলিস্টের নাম';

  @override
  String get description => 'বিবরণ';

  @override
  String get public => 'পাবলিক';

  @override
  String get collaborative => 'সহযোগিতামূলক';

  @override
  String get search_local_tracks => 'ডাউনলোডকৃত গান অনুসন্ধান করুন...';

  @override
  String get play => 'চালান';

  @override
  String get delete => 'মুছে ফেলুন';

  @override
  String get none => 'কোনটিই না';

  @override
  String get sort_a_z => 'A-Z ক্রমে সাজান';

  @override
  String get sort_z_a => 'Z-A ক্রমে সাজান';

  @override
  String get sort_artist => 'শিল্পীর ক্রমে সাজান';

  @override
  String get sort_album => 'অ্যালবামের ক্রমে সাজান';

  @override
  String get sort_duration => 'দৈর্ঘ্য অনুযায়ী বাছাই করুন';

  @override
  String get sort_tracks => 'গানের ক্রম';

  @override
  String currently_downloading(Object tracks_length) {
    return 'ডাউনলোড করা হচ্ছে ($tracks_length)';
  }

  @override
  String get cancel_all => 'সব বাতিল করুন';

  @override
  String get filter_artist => 'শিল্পীর অনুসন্ধান করুন...';

  @override
  String followers(Object followers) {
    return '$followers অনুসরণকারী';
  }

  @override
  String get add_artist_to_blacklist => 'শিল্পীকে ব্ল্যাকলিস্টে যোগ করুন';

  @override
  String get top_tracks => 'শীর্ষ গানের ট্র্যাক';

  @override
  String get fans_also_like => 'অনুসরণকারীদের পছন্দ';

  @override
  String get loading => 'লোড হচ্ছে...';

  @override
  String get artist => 'শিল্পী';

  @override
  String get blacklisted => 'ব্ল্যাকলিস্টে আছে';

  @override
  String get following => 'অনুসরণ করছেন';

  @override
  String get follow => 'অনুসরণ করুন';

  @override
  String get artist_url_copied => 'শিল্পীর URL কপি করা হয়েছে';

  @override
  String added_to_queue(Object tracks) {
    return '$tracksটি গানের ট্র্যাক কিউতে যোগ করা হয়েছে';
  }

  @override
  String get filter_albums => 'অ্যালবাম অনুসন্ধান করুন...';

  @override
  String get synced => 'সময় সুসংগত';

  @override
  String get plain => 'অসুসংগত';

  @override
  String get shuffle => 'অদলবদল';

  @override
  String get search_tracks => 'গান অনুসন্ধান করুন...';

  @override
  String get released => 'প্রকাশিত হয়েছে';

  @override
  String error(Object error) {
    return 'ত্রুটি $error';
  }

  @override
  String get title => 'শিরোনাম';

  @override
  String get time => 'সময়';

  @override
  String get more_actions => 'আরও অপশন';

  @override
  String download_count(Object count) {
    return 'ডাউনলোড ($countটি)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'প্লেলিস্টে যোগ করুন ($countটি)';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'কিউতে যোগ করুন ($countটি)';
  }

  @override
  String play_count_next(Object count) {
    return 'পরবর্তীতে চালান ($countটি)';
  }

  @override
  String get album => 'অ্যালবাম';

  @override
  String copied_to_clipboard(Object data) {
    return '$data ক্লিপবোর্ডে কপি করা হয়েছে';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'নিম্নলিখিত প্লেলিস্টে $track যোগ করুন';
  }

  @override
  String get add => 'যোগ করুন';

  @override
  String added_track_to_queue(Object track) {
    return 'কিউতে $track যোগ করা হয়েছে';
  }

  @override
  String get add_to_queue => 'কিউতে যোগ করুন';

  @override
  String track_will_play_next(Object track) {
    return '$track পরবর্তীতে চালানো হবে';
  }

  @override
  String get play_next => 'পরবর্তীতে চালান';

  @override
  String removed_track_from_queue(Object track) {
    return 'কিউ থেকে $track সরিয়ে নেওয়া হয়েছে';
  }

  @override
  String get remove_from_queue => 'কিউ থেকে সরান';

  @override
  String get remove_from_favorites => 'পছন্দের তালিকা থেকে অপসারণ করুন';

  @override
  String get save_as_favorite => 'পছন্দের তালিকায় সংরক্ষণ করুন';

  @override
  String get add_to_playlist => 'প্লেলিস্টে যোগ করুন';

  @override
  String get remove_from_playlist => 'প্লেলিস্ট থেকে সরান';

  @override
  String get add_to_blacklist => 'ব্ল্যাকলিস্টে যোগ করুন';

  @override
  String get remove_from_blacklist => 'ব্ল্যাকলিস্ট থেকে সরান';

  @override
  String get share => 'শেয়ার করুন';

  @override
  String get mini_player => 'মিনি প্লেয়ার';

  @override
  String get slide_to_seek => 'গান সামনে বা পিছনে নিতে স্লাইড করুন';

  @override
  String get shuffle_playlist => 'প্লেলিস্ট এলোমেলো করুন';

  @override
  String get unshuffle_playlist => 'প্লেলিস্ট আগের মতো করুন';

  @override
  String get previous_track => 'আগের গানের ট্র্যাক';

  @override
  String get next_track => 'পরের গানের ট্র্যাক';

  @override
  String get pause_playback => 'গান বন্ধ করুন';

  @override
  String get resume_playback => 'গান চালু করুন';

  @override
  String get loop_track => 'গান শেষে পুনরায় চালান';

  @override
  String get no_loop => 'কোনো লুপ নেই';

  @override
  String get repeat_playlist => 'প্লেলিস্ট শেষে পুনরায় চালান';

  @override
  String get queue => 'গানের কিউ';

  @override
  String get alternative_track_sources => 'বিকল্প গানের উৎস';

  @override
  String get download_track => 'গান ডাউনলোড করুন';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracksটি গান কিউতে রয়েছে';
  }

  @override
  String get clear_all => 'সব মুছে ফেলুন';

  @override
  String get show_hide_ui_on_hover => 'হভার করলে UI দেখান/লুকান';

  @override
  String get always_on_top => 'সর্বদা উপরে';

  @override
  String get exit_mini_player => 'মিনি প্লেয়ার থেকে বের হয়ে যান';

  @override
  String get download_location => 'ডাউনলোড স্থান';

  @override
  String get local_library => 'স্থানীয় লাইব্রেরি';

  @override
  String get add_library_location => 'লাইব্রেরিতে যোগ করুন';

  @override
  String get remove_library_location => 'লাইব্রেরি থেকে সরান';

  @override
  String get account => 'অ্যাকাউন্ট';

  @override
  String get logout => 'লগআউট করুন';

  @override
  String get logout_of_this_account => 'অ্যাকাউন্ট থেকে লগআউট করুন';

  @override
  String get language_region => 'ভাষা ও অঞ্চল';

  @override
  String get language => 'ভাষা';

  @override
  String get system_default => 'সিস্টেম ডিফল্ট';

  @override
  String get market_place_region => 'মার্কেটপ্লেস অঞ্চল';

  @override
  String get recommendation_country => 'দেশভিত্তিক সঙ্গীত পরামর্শের জন্য দেশ';

  @override
  String get appearance => 'রুপ';

  @override
  String get layout_mode => 'UI বিন্যাস রূপ';

  @override
  String get override_layout_settings =>
      'প্রতিক্রিয়াশীল UI বিন্যাস রূপের সেটিংস পরিবর্তন করুন';

  @override
  String get adaptive => 'অভিযোজিত';

  @override
  String get compact => 'আঁটসাঁট UI';

  @override
  String get extended => 'বিস্তৃত UI';

  @override
  String get theme => 'থিম';

  @override
  String get dark => 'অন্ধকার';

  @override
  String get light => 'উজ্জল';

  @override
  String get system => 'সিস্টেম থিম';

  @override
  String get accent_color => 'প্রভাবশালী রং';

  @override
  String get sync_album_color => 'অ্যালবাম সুসংগত UI এর রং';

  @override
  String get sync_album_color_description =>
      'অ্যালবাম কভারের প্রভাবশালী রঙ UI অ্যাকসেন্ট রঙ হিসাবে ব্যবহার করে';

  @override
  String get playback => 'সংগীতের প্লেব্যাক';

  @override
  String get audio_quality => 'শব্দের গুণমান';

  @override
  String get high => 'উচ্চ';

  @override
  String get low => 'নিম্ন';

  @override
  String get pre_download_play => 'আগে গান ডাউনলোড করে পরে চালান ';

  @override
  String get pre_download_play_description =>
      'গান স্ট্রিম করার পরিবর্তে, ডাউনলোড করুন এবং প্লে করুন (উচ্চ ব্যান্ডউইথ ব্যবহারকারীদের জন্য প্রস্তাবিত)';

  @override
  String get skip_non_music =>
      'গানের নন-মিউজিক সেগমেন্ট এড়িয়ে যান (SponsorBlock)';

  @override
  String get blacklist_description =>
      'কালো তালিকাভুক্ত গানের ট্র্যাক এবং শিল্পী';

  @override
  String get wait_for_download_to_finish =>
      'ডাউনলোড শেষ হওয়ার জন্য অপেক্ষা করুন';

  @override
  String get desktop => 'ডেস্কটপ';

  @override
  String get close_behavior => 'বন্ধ করার প্রক্রিয়া';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get minimize_to_tray => 'সিস্টেম ট্রেতে রাখুন';

  @override
  String get show_tray_icon => 'সিস্টেম ট্রে আইকন দেখান';

  @override
  String get about => 'বিস্তারিত';

  @override
  String get u_love_spotube => 'আমরা জানি আপনি DeeMusiq কে ভালবাসেন';

  @override
  String get check_for_updates => 'আপডেট চেক করুন';

  @override
  String get about_spotube => 'DeeMusiq সম্পর্কে বিস্তারিত';

  @override
  String get blacklist => 'কালো তালিকা';

  @override
  String get please_sponsor => 'স্পনসর/সহায়তা করুন';

  @override
  String get spotube_description =>
      'DeeMusiq, একটি কর্মদক্ষ, ক্রস-প্ল্যাটফর্ম, বিনামূল্যের জন্য Spotify ক্লায়েন্ট';

  @override
  String get version => 'সংস্করণ';

  @override
  String get build_number => 'বিল্ড নম্বর';

  @override
  String get founder => 'প্রতিষ্ঠাতা';

  @override
  String get repository => 'সংগ্রহস্থল';

  @override
  String get bug_issues => 'বাগ/সমস্যা';

  @override
  String get made_with => '❤️ দিয়ে বাংলাদেশে🇧🇩 তৈরি';

  @override
  String get kingkor_roy_tirtho => 'কিংকর রায় তীর্থ';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year কিংকর রায় তীর্থ';
  }

  @override
  String get license => 'লাইসেন্স';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'চিন্তা করবেন না, আপনার কোনো লগইন তথ্য সংগ্রহ করা হবে না বা কারো সাথে শেয়ার করা হবে না';

  @override
  String get know_how_to_login => 'আপনি কিভাবে লগইন করবেন তা জানেন না?';

  @override
  String get follow_step_by_step_guide => 'ধাপে ধাপে নির্দেশিকা অনুসরণ করুন';

  @override
  String cookie_name_cookie(Object name) {
    return '$name কুকি';
  }

  @override
  String get fill_in_all_fields => 'সমস্ত ফর্ম ক্ষেত্র পূরণ করুন';

  @override
  String get submit => 'জমা দিন';

  @override
  String get exit => 'প্রস্থান';

  @override
  String get previous => 'পূর্ববর্তী';

  @override
  String get next => 'পরবর্তী';

  @override
  String get done => 'সম্পন্ন';

  @override
  String get step_1 => 'ধাপ 1';

  @override
  String get first_go_to => 'প্রথমে যান';

  @override
  String get something_went_wrong => 'কিছু ভুল হয়েছে';

  @override
  String get piped_instance => 'Piped সার্ভার এড্রেস';

  @override
  String get piped_description => 'গান ম্যাচ করার জন্য ব্যবহৃত পাইপড সার্ভার';

  @override
  String get piped_warning =>
      'এগুলোর মধ্যে কিছু ভাল কাজ নাও করতে পারে৷ তাই নিজ দায়িত্বে ব্যবহার করুন';

  @override
  String get invidious_instance => 'ইনভিডিয়াস সার্ভার ইন্সটেন্স';

  @override
  String get invidious_description =>
      'ট্রাক মিলানোর জন্য ব্যবহৃত ইনভিডিয়াস সার্ভার';

  @override
  String get invidious_warning =>
      'কিছু সার্ভার ভাল কাজ নাও করতে পারে। নিজের ঝুঁকিতে ব্যবহার করুন';

  @override
  String get generate => 'উৎপন্ন করুন';

  @override
  String track_exists(Object track) {
    return 'ট্র্যাক $track ইতিমধ্যে বিদ্যমান';
  }

  @override
  String get replace_downloaded_tracks =>
      'সমস্ত ডাউনলোড করা ট্র্যাক প্রতিস্থাপন করুন';

  @override
  String get skip_download_tracks => 'সমস্ত ডাউনলোড করা ট্র্যাক এ স্কিপ করুন';

  @override
  String get do_you_want_to_replace =>
      'আপনি কি বিদ্যমান ট্র্যাকটি প্রতিস্থাপন করতে চান?';

  @override
  String get replace => 'প্রতিস্থাপন করুন';

  @override
  String get skip => 'স্কিপ করুন';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return '$count $type পর্যন্ত নির্বাচন করুন';
  }

  @override
  String get select_genres => 'গানের ধরণ নির্বাচন করুন';

  @override
  String get add_genres => 'গানের ধরণ যুক্ত করুন';

  @override
  String get country => 'দেশ';

  @override
  String get number_of_tracks_generate => 'উত্পাদিত ট্র্যাকের সংখ্যা';

  @override
  String get acousticness => 'অধ্যাত্মিকতা';

  @override
  String get danceability => 'নৃত্যমূলকতা';

  @override
  String get energy => 'শক্তি';

  @override
  String get instrumentalness => 'সাধারণতা';

  @override
  String get liveness => 'জীবনমুক্ততা';

  @override
  String get loudness => 'স্বরের উচ্চতা';

  @override
  String get speechiness => 'বক্তব্যমূলকতা';

  @override
  String get valence => 'সন্তোষমূলকতা';

  @override
  String get popularity => 'জনপ্রিয়তা';

  @override
  String get key => 'কী';

  @override
  String get duration => 'সময়কাল (সেকেন্ড)';

  @override
  String get tempo => 'গতি (বিপিএম)';

  @override
  String get mode => 'মোড';

  @override
  String get time_signature => 'সময়ের স্বাক্ষর';

  @override
  String get short => 'সংক্ষিপ্ত';

  @override
  String get medium => 'মাঝারি';

  @override
  String get long => 'দীর্ঘ';

  @override
  String get min => 'সর্বনিম্ন';

  @override
  String get max => 'সর্বাধিক';

  @override
  String get target => 'লক্ষ্য';

  @override
  String get moderate => 'মাঝারি';

  @override
  String get deselect_all => 'সমস্ত অপচুন করুন';

  @override
  String get select_all => 'সমস্ত নির্বাচন করুন';

  @override
  String get are_you_sure => 'আপনি কি নিশ্চিত?';

  @override
  String get generating_playlist => 'আপনার কাস্টম প্লেলিস্ট তৈরি হচ্ছে...';

  @override
  String selected_count_tracks(Object count) {
    return '$count ট্র্যাক নির্বাচিত';
  }

  @override
  String get download_warning =>
      'যদি আপনি সমস্ত ট্র্যাকগুলি একসঙ্গে ডাউনলোড করেন, তবে আপনি নিশ্চিতভাবে সঙ্গীত চুরি করছেন এবং সৃষ্টিশীল সমাজে ক্ষতি দিচ্ছেন। আমি আশা করি আপনি এটা সম্পর্কে জানেন। সর্বদা, শিল্পীদের কঠিন পরিশ্রমকে সম্মান করতে চেষ্টা করুন এবং সমর্থন করুন';

  @override
  String get download_ip_ban_warning =>
      'তথ্যবিশ্বস্ত করে নেওয়া যায় যে, আপনার IP ঠিকানাটি YouTube দ্বারা স্থানান্তরিত করা হতে পারে যখন সাধারন থেকে বেশি ডাউনলোড অনুরোধ হয়। IP ব্লকের মাধ্যমে আপনি কমপক্ষে ২-৩ মাস ধরে (ঐ IP ডিভাইস থেকে) YouTube ব্যবহার করতে পারবেন না। এবং DeeMusiq কোনও দায়িত্ব সম্পর্কে দায়িত্ব বহন করে না যদি এটি ঘটে।';

  @override
  String get by_clicking_accept_terms =>
      '\'গ্রহণ\' ক্লিক করে আপনি নিম্নলিখিত শর্তাদি স্বীকার করছেন:';

  @override
  String get download_agreement_1 => 'আমি জানি আমি সঙ্গীত চুরি করছি। আমি খারাপ';

  @override
  String get download_agreement_2 =>
      'আমি কেবলমাত্র তাদের কাজ কেনার জন্য অর্থ নেই কিন্তু যেখানে প্রয়োজন সেখানে আমি শিল্পীদের সমর্থন করব।';

  @override
  String get download_agreement_3 =>
      'আমি সম্পূর্ণরূপে জানি যে আমার IP YouTube-তে ব্লক হতে পারে এবং আমি DeeMusiq বা তার মালিকানাধীন কোনও দায়িত্ব পেতে পারিনি আমার বর্তমান ক্রিয়াটি দ্বারা সৃষ্ট দুর্ঘটনা করার জন্য';

  @override
  String get decline => 'অগ্রায়ন করুন';

  @override
  String get accept => 'গ্রহণ করুন';

  @override
  String get details => 'বিস্তারিত';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'চ্যানেল';

  @override
  String get likes => 'লাইক';

  @override
  String get dislikes => 'অপছন্দ';

  @override
  String get views => 'দর্শনার্থী';

  @override
  String get streamUrl => 'স্ট্রিম URL';

  @override
  String get stop => 'বন্ধ করুন';

  @override
  String get sort_newest => 'নতুনতম অনুসারে সাজান';

  @override
  String get sort_oldest => 'পুরানোতম অনুসারে সাজান';

  @override
  String get sleep_timer => 'স্লীপ টাইমার';

  @override
  String mins(Object minutes) {
    return '$minutes মিনিট';
  }

  @override
  String hours(Object hours) {
    return '$hours ঘন্টা';
  }

  @override
  String hour(Object hours) {
    return '$hours ঘন্টা';
  }

  @override
  String get custom_hours => 'কাস্টম ঘন্টা';

  @override
  String get logs => 'লগ';

  @override
  String get developers => 'ডেভেলপার';

  @override
  String get not_logged_in => 'আপনি লগইন করা নেই';

  @override
  String get search_mode => 'অনুসন্ধান মোড';

  @override
  String get audio_source => 'অডিও উৎস';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get failed_to_encrypt => 'এনক্রিপ্ট করা ব্যর্থ হয়েছে';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq আপনার তথ্যগুলি নিরাপদভাবে স্টোর করতে এনক্রিপশন ব্যবহার করে। কিন্তু এটি ব্যর্থ হয়েছে। তাই এটি অনিরাপদ স্টোরে ফলফল হবে\nযদি আপনি Linux ব্যবহার করেন, তবে দয়া করে নিশ্চিত হউন যে আপনার কোনও সিক্রেট-সার্ভিস gnome-keyring, kde-wallet, keepassxc ইত্যাদি ইনস্টল করা আছে';

  @override
  String get querying_info => 'তথ্য অনুসন্ধান করা হচ্ছে';

  @override
  String get piped_api_down => 'পাইপড API ডাউন আছে';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'বর্তমানে পাইপড ইনস্ট্যান্স $pipedInstance ডাউন আছে\n\nইনস্ট্যান্স পরিবর্তন করুন অথবা \'API টাইপ\' পরিবর্তন করুন অফিসিয়াল ইউটিউব API হতে\n\nপরিবর্তনের পরে অ্যাপটি পুনরায় চালানোর নিশ্চিত করুন';
  }

  @override
  String get you_are_offline => 'আপনি বর্তমানে অফলাইন';

  @override
  String get connection_restored => 'আপনার ইন্টারনেট সংযোগ পুনরুদ্ধার হয়েছে';

  @override
  String get use_system_title_bar => 'সিস্টেম শিরোনাম বার ব্যবহার করুন';

  @override
  String get crunching_results => 'ফলাফল বিশ্লেষণ করা হচ্ছে...';

  @override
  String get search_to_get_results => 'ফলাফল পেতে খোঁজ করুন';

  @override
  String get use_amoled_mode => 'AMOLED মোড ব্যবহার করুন';

  @override
  String get pitch_dark_theme => 'পিচ ব্ল্যাক ডার্ট থিম';

  @override
  String get normalize_audio => 'অডিও স্তরমান করুন';

  @override
  String get change_cover => 'কভার পরিবর্তন করুন';

  @override
  String get add_cover => 'কভার যোগ করুন';

  @override
  String get restore_defaults => 'ডিফল্ট সেটিংস পুনরুদ্ধার করুন';

  @override
  String get download_music_format => 'গান ডাউনলোডের বিন্যাস';

  @override
  String get streaming_music_format => 'গান স্ট্রিমিং এর বিন্যাস';

  @override
  String get download_music_quality => 'গান ডাউনলোডের মান';

  @override
  String get streaming_music_quality => 'গান স্ট্রিমিং এর মান';

  @override
  String get login_with_lastfm => 'Last.fm দিয়ে লগইন করুন';

  @override
  String get connect => 'সংযোগ করুন';

  @override
  String get disconnect_lastfm => 'Last.fm সংযোগ বিচ্ছিন্ন করুন';

  @override
  String get disconnect => 'সংযোগ বিচ্ছিন্ন করুন';

  @override
  String get username => 'ব্যবহারকারীর নাম';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get login => 'লগইন';

  @override
  String get login_with_your_lastfm =>
      'আপনার Last.fm অ্যাকাউন্ট দিয়ে লগইন করুন';

  @override
  String get scrobble_to_lastfm => 'Last.fm এ স্ক্রবল করুন';

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
  String get friends => 'বন্ধু';

  @override
  String get no_lyrics_available =>
      'দুঃখিত, এই ট্র্যাকের জন্য কথা খুঁজে পাওয়া গেলনা';

  @override
  String get start_a_radio => 'রেডিও শুরু করুন';

  @override
  String get how_to_start_radio => 'রেডিও কিভাবে শুরু করতে চান?';

  @override
  String get replace_queue_question =>
      'আপনি বর্তমান কিউটি প্রতিস্থাপন করতে চান কিনা বা এর সাথে যুক্ত করতে চান?';

  @override
  String get endless_playback => 'অবিরাম প্রচার';

  @override
  String get delete_playlist => 'প্লেলিস্ট মুছুন';

  @override
  String get delete_playlist_confirmation =>
      'আপনি কি নিশ্চিত যে আপনি এই প্লেলিস্টটি মুছতে চান?';

  @override
  String get local_tracks => 'স্থানীয় ট্র্যাক';

  @override
  String get local_tab => 'স্থানীয়';

  @override
  String get song_link => 'গানের লিংক';

  @override
  String get youtube_source_description => 'প্রস্তাবিত এবং সেরা কাজ করে।';

  @override
  String get piped_source_description => 'মন খারাপ? ইউটিউবের মতো আবার ফ্রি।';

  @override
  String get jiosaavn_source_description => 'দক্ষিণ এশিয়ান অঞ্চলের জন্য সেরা।';

  @override
  String get invidious_source_description =>
      'পাইপের মতো কিন্তু আরও বেশি উপলব্ধতা সহ';

  @override
  String highest_quality(Object quality) {
    return 'সর্বোচ্চ গুণগতি: $quality';
  }

  @override
  String get select_audio_source => 'অডিও উৎস নির্বাচন করুন';

  @override
  String get contribute_on_github => 'গিটহাবে অবদান রাখুন';

  @override
  String get browse_anonymously => 'অজানে ব্রাউজ করুন';

  @override
  String get enable_connect => 'সংযোগ সক্রিয় করুন';

  @override
  String get enable_connect_description =>
      'অন্যান্য ডিভাইস থেকে DeeMusiq নিয়ন্ত্রণ করুন';

  @override
  String get devices => 'ডিভাইস';

  @override
  String get select => 'নির্বাচন করুন';

  @override
  String connect_client_alert(Object client) {
    return 'আপনি $client দ্বারা নিয়ন্ত্রিত হচ্ছেন';
  }

  @override
  String get this_device => 'এই ডিভাইস';

  @override
  String get remote => 'রিমোট';

  @override
  String get stats => 'পরিসংখ্যান';

  @override
  String and_n_more(Object count) {
    return 'এবং $count আরও';
  }

  @override
  String get recently_played => 'সম্প্রতি বাজানো';

  @override
  String get browse_more => 'আরও ব্রাউজ করুন';

  @override
  String get no_title => 'কোনো শিরোনাম নেই';

  @override
  String get not_playing => 'চালানো হচ্ছে না';

  @override
  String get epic_failure => 'বিরাট ব্যর্থতা!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length ট্র্যাক সারিতে যোগ করা হয়েছে';
  }

  @override
  String get spotube_has_an_update => 'ডিমিউজিক-এ একটি আপডেট আছে';

  @override
  String get download_now => 'এখনই ডাউনলোড করুন';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'ডিমিউজিক নাইটলি $nightlyBuildNum প্রকাশিত হয়েছে';
  }

  @override
  String release_version(Object version) {
    return 'ডিমিউজিক v$version প্রকাশিত হয়েছে';
  }

  @override
  String get read_the_latest => 'সর্বশেষ পড়ুন';

  @override
  String get release_notes => 'রিলিজ নোট';

  @override
  String get pick_color_scheme => 'রঙের থিম নির্বাচন করুন';

  @override
  String get save => 'সংরক্ষণ করুন';

  @override
  String get choose_the_device => 'ডিভাইস নির্বাচন করুন:';

  @override
  String get multiple_device_connected =>
      'একাধিক ডিভাইস সংযুক্ত রয়েছে।\nযে ডিভাইসে আপনি এই ক্রিয়াটি চালাতে চান সেটি নির্বাচন করুন';

  @override
  String get nothing_found => 'কিছুই পাওয়া যায়নি';

  @override
  String get the_box_is_empty => 'বাক্সটি খালি';

  @override
  String get top_artists => 'শীর্ষ শিল্পী';

  @override
  String get top_albums => 'শীর্ষ অ্যালবাম';

  @override
  String get this_week => 'এই সপ্তাহ';

  @override
  String get this_month => 'এই মাস';

  @override
  String get last_6_months => 'গত ৬ মাস';

  @override
  String get this_year => 'এই বছর';

  @override
  String get last_2_years => 'গত ২ বছর';

  @override
  String get all_time => 'সব সময়';

  @override
  String powered_by_provider(Object providerName) {
    return '$providerName দ্বারা চালিত';
  }

  @override
  String get email => 'ইমেইল';

  @override
  String get profile_followers => 'অনুসারী';

  @override
  String get birthday => 'জন্মদিন';

  @override
  String get subscription => 'সাবস্ক্রিপশন';

  @override
  String get not_born => 'জন্মগ্রহণ করেনি';

  @override
  String get hacker => 'হ্যাকার';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get no_name => 'কোন নাম নেই';

  @override
  String get edit => 'সম্পাদনা করুন';

  @override
  String get user_profile => 'ব্যবহারকারীর প্রোফাইল';

  @override
  String count_plays(Object count) {
    return '$count বার প্লে হয়েছে';
  }

  @override
  String get minutes_listened => 'শুনেছেন মিনিট';

  @override
  String get streamed_songs => 'স্ট্রিম করা গান';

  @override
  String count_streams(Object count) {
    return '$count বার স্ট্রিম';
  }

  @override
  String get owned_by_you => 'আপনার মালিকানাধীন';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl ক্লিপবোর্ডে কপি করা হয়েছে';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes মিনিট';
  }

  @override
  String get summary_minutes => 'মিনিট';

  @override
  String get summary_listened_to_music => 'সঙ্গীত শুনেছেন';

  @override
  String get summary_songs => 'গান';

  @override
  String get summary_streamed_overall => 'মোট স্ট্রিম';

  @override
  String get summary_artists => 'শিল্পীর';

  @override
  String get summary_music_reached_you => 'আপনার কাছে পৌঁছেছে সঙ্গীত';

  @override
  String get summary_full_albums => 'সম্পূর্ণ অ্যালবাম';

  @override
  String get summary_got_your_love => 'আপনার ভালোবাসা পেয়েছে';

  @override
  String get summary_playlists => 'প্লেলিস্ট';

  @override
  String get summary_were_on_repeat => 'পুনরাবৃত্তিতে ছিল';

  @override
  String get webview_not_found => 'ওয়েবভিউ পাওয়া যায়নি';

  @override
  String get webview_not_found_description =>
      'আপনার ডিভাইসে কোনো ওয়েবভিউ রানটাইম ইনস্টল করা নেই।\nযদি ইনস্টল থাকে, তা নিশ্চিত করুন যে এটি environment PATH এ রয়েছে\n\nইনস্টল করার পর, অ্যাপটি পুনরায় চালু করুন';

  @override
  String get unsupported_platform => 'সমর্থিত প্ল্যাটফর্ম নয়';

  @override
  String get cache_music => 'ক্যাশে সংগীত';

  @override
  String get open => 'খুলুন';

  @override
  String get cache_folder => 'ক্যাশে ফোল্ডার';

  @override
  String get export => 'রপ্তানি';

  @override
  String get clear_cache => 'ক্যাশে পরিষ্কার';

  @override
  String get clear_cache_confirmation => 'আপনি কি ক্যাশে পরিষ্কার করতে চান?';

  @override
  String get export_cache_files => 'ক্যাশে ফাইল রপ্তানি';

  @override
  String found_n_files(Object count) {
    return '$count টি ফাইল পাওয়া গেছে';
  }

  @override
  String get export_cache_confirmation =>
      'আপনি কি এই ফাইলগুলি রপ্তানি করতে চান';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported টি ফাইল রপ্তানি করা হয়েছে $files এর মধ্যে';
  }

  @override
  String get undo => 'পূর্বাবস্থায় ফিরুন';

  @override
  String get download_all => 'সব ডাউনলোড করুন';

  @override
  String get add_all_to_playlist => 'সব প্লেলিস্টে যোগ করুন';

  @override
  String get add_all_to_queue => 'সব কিউতে যোগ করুন';

  @override
  String get play_all_next => 'সব পরবর্তী খেলুন';

  @override
  String get pause => 'বিরতি';

  @override
  String get view_all => 'সব দেখুন';

  @override
  String get no_tracks_added_yet => 'এখনও কোনো ট্র্যাক যোগ করা হয়নি মনে হচ্ছে';

  @override
  String get no_tracks => 'এখানে কোনো ট্র্যাক নেই মনে হচ্ছে';

  @override
  String get no_tracks_listened_yet => 'এখনও কিছু শোনা হয়নি মনে হচ্ছে';

  @override
  String get not_following_artists => 'আপনি কোনো শিল্পীকে অনুসরণ করছেন না';

  @override
  String get no_favorite_albums_yet =>
      'এখনও কোনো অ্যালবাম প্রিয় তালিকায় যোগ করা হয়নি মনে হচ্ছে';

  @override
  String get no_logs_found => 'কোনো লগ পাওয়া যায়নি';

  @override
  String get youtube_engine => 'ইউটিউব ইঞ্জিন';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine ইনস্টল করা নেই';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine আপনার সিস্টেমে ইনস্টল করা নেই।';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'এটি PATH ভেরিয়েবলে উপলব্ধ কিনা নিশ্চিত করুন অথবা\nনীচে $engine এক্সিকিউটেবল এর পূর্ণপথ সেট করুন';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/Unix-এর মতো অপারেটিং সিস্টেমে, .zshrc/.bashrc/.bash_profile ইত্যাদিতে পাথ সেট করা কাজ করবে না।\nআপনাকে শেল কনফিগারেশন ফাইলে পাথ সেট করতে হবে';

  @override
  String get yt_dlp_install_title => 'Setting up yt-dlp';

  @override
  String get yt_dlp_install_phase_checking =>
      'Checking for an existing yt-dlp install…';

  @override
  String yt_dlp_install_phase_downloading(Object version) {
    return 'Downloading yt-dlp $version…';
  }

  @override
  String get yt_dlp_install_phase_verifying =>
      'Verifying the downloaded yt-dlp…';

  @override
  String yt_dlp_install_phase_installing(Object version) {
    return 'Installing yt-dlp $version…';
  }

  @override
  String yt_dlp_install_phase_done(Object version) {
    return 'yt-dlp $version is ready';
  }

  @override
  String get yt_dlp_install_phase_failed => 'yt-dlp setup failed';

  @override
  String yt_dlp_install_progress(Object received, Object total) {
    return '$received of $total';
  }

  @override
  String get yt_dlp_install_action => 'Install automatically';

  @override
  String get yt_dlp_install_latest_action =>
      'Install the latest yt-dlp automatically';

  @override
  String get yt_dlp_install_retry => 'Retry';

  @override
  String yt_dlp_install_failed_message(Object error) {
    return 'yt-dlp could not be installed automatically:\n$error';
  }

  @override
  String get yt_dlp_install_managed_message =>
      'DeeMusiq downloads the official yt-dlp release into its own folder and keeps it up to date, so nothing has to be installed system-wide.';

  @override
  String get download => 'ডাউনলোড';

  @override
  String get file_not_found => 'ফাইল পাওয়া যায়নি';

  @override
  String get custom => 'কাস্টম';

  @override
  String get add_custom_url => 'কাস্টম URL যোগ করুন';

  @override
  String get edit_port => 'পোর্ট সম্পাদনা করুন';

  @override
  String get port_helper_msg =>
      'ডিফল্ট হল -1 যা এলোমেলো সংখ্যা নির্দেশ করে। যদি আপনার ফায়ারওয়াল কনফিগার করা থাকে, তবে এটি সেট করা সুপারিশ করা হয়।';

  @override
  String connect_request(Object client) {
    return '$client কে সংযোগ করতে অনুমতি দেবেন?';
  }

  @override
  String get connection_request_denied =>
      'সংযোগ অস্বীকৃত। ব্যবহারকারী প্রবেশাধিকার অস্বীকার করেছে।';

  @override
  String get an_error_occurred => 'একটি ত্রুটি ঘটেছে';

  @override
  String get copy_to_clipboard => 'ক্লিপবোর্ডে কপি করুন';

  @override
  String get view_logs => 'লগ দেখুন';

  @override
  String get retry => 'পুনরায় চেষ্টা করুন';

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
      'আপনি কোনো ডিফল্ট মেটাডেটা প্রদানকারী সেট করেননি';

  @override
  String get manage_metadata_providers => 'মেটাডেটা প্রদানকারীগণ পরিচালনা করুন';

  @override
  String get open_link_in_browser => 'লিংকটি ব্রাউজারে খুলবেন?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'নিচের লিংকটি খুলতে চান?';

  @override
  String get unsafe_url_warning =>
      'অবিশ্বাসযোগ্য উৎস থেকে লিংক খোলা নিরাপদ নাও হতে পারে। সতর্ক থাকুন!\nআপনি এটি ক্লিপবোর্ডে কপি করতে পারেন।';

  @override
  String get copy_link => 'লিংক কপি করুন';

  @override
  String get building_your_timeline =>
      'আপনার শোনার ধারা অনুযায়ী টাইমলাইন তৈরি করা হচ্ছে...';

  @override
  String get official => 'সরকারি';

  @override
  String author_name(Object author) {
    return 'লেখক: $author';
  }

  @override
  String get third_party => 'তৃতীয় পক্ষ';

  @override
  String get plugin_requires_authentication => 'প্লাগইনটি প্রমাণীকরণ প্রয়োজন';

  @override
  String get update_available => 'হালনাগাদ উপলব্ধ';

  @override
  String get supports_scrobbling => 'স্ক্রোব্বলিং সমর্থিত';

  @override
  String get plugin_scrobbling_info =>
      'এই প্লাগইনটি আপনার সঙ্গীত স্ক্রোব্বল করে আপনার শোনা ইতিহাস তৈরি করে।';

  @override
  String get default_metadata_source => 'ডিফল্ট মেটাডেটা উৎস';

  @override
  String get set_default_metadata_source => 'ডিফল্ট মেটাডেটা উৎস সেট করুন';

  @override
  String get default_audio_source => 'ডিফল্ট অডিও উৎস';

  @override
  String get set_default_audio_source => 'ডিফল্ট অডিও উৎস সেট করুন';

  @override
  String get set_default => 'ডিফল্ট হিসাবে নির্ধারণ করুন';

  @override
  String get support => 'সমর্থন';

  @override
  String get support_plugin_development => 'প্লাগইন উন্নয়নকে সমর্থন করুন';

  @override
  String can_access_name_api(Object name) {
    return '- **$name** API-তে অ্যাক্সেস করতে পারে';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'আপনি কি এই প্লাগইন ইনস্টল করতে চান?';

  @override
  String get third_party_plugin_warning =>
      'এই প্লাগইন একটি তৃতীয় পক্ষের রেপোজিটরির। ইনস্টল করার আগে উৎস বিশ্বস্ত কিনা নিশ্চিত করুন।';

  @override
  String get author => 'লেখক';

  @override
  String get this_plugin_can_do_following => 'এই প্লাগইন নিচের কাজ করতে পারে';

  @override
  String get install => 'ইনস্টল করুন';

  @override
  String get no_tracks_playing => 'বর্তমানে কোনো ট্র্যাক শোনা হচ্ছে না';

  @override
  String get synced_lyrics_not_available =>
      'এই গানের জন্য সিঙ্ক্রোনাইজড লিরিক্স পাওয়া যায় না। অনুগ্রহ করে ব্যবহার করুন';

  @override
  String get plain_lyrics => 'সহজ লিরিক্স';

  @override
  String get tab_instead => 'তার পরিবর্তে ট্যাব ব্যবহার করুন।';

  @override
  String get disclaimer => 'অস্বীকৃতি';

  @override
  String get third_party_plugin_dmca_notice =>
      'DeeMusiq দল কোনো “তৃতীয় পক্ষ” প্লাগইনের জন্য কোনো (আইনগত সহ) দায়িত্ব নেয় না। নিজের বিপদে ব্যবহার করুন। কোনো বাগ/সমস্যা হলে প্লাগইন রেপোজিটরিতে জানাতে অনুরোধ করা হচ্ছে।\n\nযদি কোনো “তৃতীয় পক্ষ” প্লাগইন কোনো পরিষেবা/আইনগত সংস্থার ToS/DMCA ভূঙ্গ করে, অনুগ্রহ করে “তৃতীয় পক্ষ” প্লাগইনের লেখক বা হোস্টিং প্ল্যাটফর্মে (যেমন GitHub/Codeberg) পদক্ষেপ নিতে বলুন। “তৃতীয় পক্ষ” লেবেলযুক্ত যুক্তিগুলি সকলই পাবলিক/কমিউনিটি দ্বারা রক্ষণাবেক্ষণ করা হয়; আমরা সেগুলি কিউরেট করি না, তাই আমরা কোনো পদক্ষেপ নিতে পারি না।\n\n';

  @override
  String get plugins => 'প্লাগইন';

  @override
  String get paste_plugin_download_url =>
      'ডাউনলোড URL বা GitHub/Codeberg রিপো URL বা .smplug ফাইলের সরাসরি লিঙ্ক পেস্ট করুন';

  @override
  String get download_and_install_plugin_from_url =>
      'URL থেকে প্লাগইন ডাউনলোড এবং ইনস্টল করুন';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'প্লাগইন যোগ করতে ব্যর্থ: $error';
  }

  @override
  String get upload_plugin_from_file => 'ফাইল থেকে প্লাগইন আপলোড করুন';

  @override
  String get installed => 'ইনস্টল করা হয়েছে';

  @override
  String get available_plugins => 'উপলব্ধ প্লাগইনগুলো';

  @override
  String get configure_plugins =>
      'আপনার নিজের মেটাডেটা প্রদানকারী এবং অডিও উৎস প্লাগইন কনফিগার করুন';

  @override
  String get audio_scrobblers => 'অডিও স্ক্রোব্বলার্স';

  @override
  String get scrobbling => 'স্ক্রোব্বলিং';

  @override
  String get source => 'উৎস: ';

  @override
  String get uncompressed => 'অ-সংকুচিত';

  @override
  String get dab_music_source_description =>
      'অডিওফাইলদের জন্য। উচ্চ-মানের/লসলেস অডিও স্ট্রিম প্রদান করে। সঠিক ISRC ভিত্তিক ট্র্যাক ম্যাচিং।';

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
      'Couldn\'t reach the backend. Continuing on this device with YouTube.';

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
  String get skip_this_nonsense => 'এই বাকবাস পালান';

  @override
  String get freedom_of_music => '“সংগীতের স্বাধীনতা”';

  @override
  String get freedom_of_music_palm => '“তোমার হাতের কাছে সংগীতের স্বাধীনতা”';

  @override
  String get get_started => 'শুরু করা যাক';

  @override
  String get endless_playback_description =>
      'নতুন গান নিজে নিজে প্লেলিস্টের শেষে\nসংযুক্ত করুন';

  @override
  String get choose_your_region => 'আপনার অঞ্চল নির্বাচন করুন';

  @override
  String get choose_your_region_description =>
      'এটি স্পটুবে আপনাকে আপনার অবস্থানের জন্য ঠিক কন্টেন্ট দেখানোর সাহায্য করবে।';

  @override
  String get choose_your_language => 'আপনার ভাষা নির্বাচন করুন';

  @override
  String get help_project_grow => 'এই প্রকল্পের বৃদ্ধি করুন';

  @override
  String get help_project_grow_description =>
      'স্পটুব একটি ওপেন সোর্স প্রকল্প। আপনি প্রকল্পে অবদান রাখেন, বাগ রিপোর্ট করেন, বা নতুন বৈশিষ্ট্যগুলি সুপারিশ করেন।';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'ওপেন কলেক্টিভে অনুদান করুন';

  @override
  String get install_a_metadata_provider =>
      'একটি মেটাডেটা প্রদানকারী ইনস্টল করুন';

  @override
  String get input_does_not_match_format =>
      'ইনপুট প্রয়োজনীয় ফরম্যাটের সাথে মেলে না';

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
  String get auth_mfa_required => 'আপনার যাচাইকরণ কোড লিখুন';

  @override
  String get auth_mfa_body =>
      'অথেন্টিকেটর অ্যাপ খুলে ৬ সংখ্যার কোড দিয়ে সাইন ইন সম্পন্ন করুন।';

  @override
  String get auth_mfa_verify_action => 'যাচাই করুন';

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
