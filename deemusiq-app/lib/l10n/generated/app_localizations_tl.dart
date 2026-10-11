// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tagalog (`tl`).
class AppLocalizationsTl extends AppLocalizations {
  AppLocalizationsTl([String locale = 'tl']) : super(locale);

  @override
  String get guest => 'Bisita';

  @override
  String get browse => 'Mag-browse';

  @override
  String get search => 'Maghanap';

  @override
  String get library => 'Silid-aklatan';

  @override
  String get lyrics => 'Mga Liriko';

  @override
  String get settings => 'Mga Setting';

  @override
  String get genre_categories_filter => 'I-filter ang mga kategorya o genre...';

  @override
  String get genre => 'Genre';

  @override
  String get personalized => 'Naka-personalize';

  @override
  String get featured => 'Tampok';

  @override
  String get new_releases => 'Mga Bagong Paglabas';

  @override
  String get songs => 'Mga Kanta';

  @override
  String playing_track(Object track) {
    return 'Tumutugtog ang $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'Ito ay magbubura ng kasalukuyang pila. $track_length na mga track ang tatanggalin\nGusto mo bang magpatuloy?';
  }

  @override
  String get load_more => 'Mag-load pa';

  @override
  String get playlists => 'Mga Playlist';

  @override
  String get artists => 'Mga Artista';

  @override
  String get albums => 'Mga Album';

  @override
  String get tracks => 'Mga Track';

  @override
  String get downloads => 'Mga Download';

  @override
  String get filter_playlists => 'I-filter ang iyong mga playlist...';

  @override
  String get liked_tracks => 'Mga Nagustuhang Track';

  @override
  String get liked_tracks_description =>
      'Lahat ng mga track na iyong nagustuhan';

  @override
  String get playlist => 'Playlist';

  @override
  String get create_a_playlist => 'Gumawa ng playlist';

  @override
  String get update_playlist => 'I-update ang playlist';

  @override
  String get create => 'Lumikha';

  @override
  String get cancel => 'Ikansela';

  @override
  String get update => 'I-update';

  @override
  String get playlist_name => 'Pangalan ng Playlist';

  @override
  String get name_of_playlist => 'Pangalan ng playlist';

  @override
  String get description => 'Paglalarawan';

  @override
  String get public => 'Pampubliko';

  @override
  String get collaborative => 'Pakikipagtulungan';

  @override
  String get search_local_tracks => 'Maghanap ng mga lokal na track...';

  @override
  String get play => 'I-play';

  @override
  String get delete => 'Burahin';

  @override
  String get none => 'Wala';

  @override
  String get sort_a_z => 'Ayusin ayon sa A-Z';

  @override
  String get sort_z_a => 'Ayusin ayon sa Z-A';

  @override
  String get sort_artist => 'Ayusin ayon sa Artista';

  @override
  String get sort_album => 'Ayusin ayon sa Album';

  @override
  String get sort_duration => 'Ayusin ayon sa Tagal';

  @override
  String get sort_tracks => 'Ayusin ang mga Track';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Kasalukuyang Nagda-download ($tracks_length)';
  }

  @override
  String get cancel_all => 'Kanselahin Lahat';

  @override
  String get filter_artist => 'I-filter ang mga artista...';

  @override
  String followers(Object followers) {
    return '$followers na mga Tagasunod';
  }

  @override
  String get add_artist_to_blacklist => 'Idagdag ang artista sa blacklist';

  @override
  String get top_tracks => 'Mga Nangungunang Track';

  @override
  String get fans_also_like => 'Gusto rin ng mga tagahanga';

  @override
  String get loading => 'Naglo-load...';

  @override
  String get artist => 'Artista';

  @override
  String get blacklisted => 'Naka-blacklist';

  @override
  String get following => 'Sinusundan';

  @override
  String get follow => 'Sundan';

  @override
  String get artist_url_copied => 'Na-copy sa clipboard ang URL ng artista';

  @override
  String added_to_queue(Object tracks) {
    return 'Idinagdag ang $tracks na mga track sa pila';
  }

  @override
  String get filter_albums => 'I-filter ang mga album...';

  @override
  String get synced => 'Naka-sync';

  @override
  String get plain => 'Simpleng';

  @override
  String get shuffle => 'I-shuffle';

  @override
  String get search_tracks => 'Maghanap ng mga track...';

  @override
  String get released => 'Inilabas';

  @override
  String error(Object error) {
    return 'Error $error';
  }

  @override
  String get title => 'Pamagat';

  @override
  String get time => 'Oras';

  @override
  String get more_actions => 'Higit pang mga aksyon';

  @override
  String download_count(Object count) {
    return 'I-download ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Idagdag ($count) sa Playlist';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Idagdag ($count) sa Pila';
  }

  @override
  String play_count_next(Object count) {
    return 'I-play ($count) kasunod';
  }

  @override
  String get album => 'Album';

  @override
  String copied_to_clipboard(Object data) {
    return 'Na-copy ang $data sa clipboard';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Idagdag ang $track sa mga sumusunod na Playlist';
  }

  @override
  String get add => 'Idagdag';

  @override
  String added_track_to_queue(Object track) {
    return 'Idinagdag ang $track sa pila';
  }

  @override
  String get add_to_queue => 'Idagdag sa pila';

  @override
  String track_will_play_next(Object track) {
    return 'Ang $track ay tutugtog susunod';
  }

  @override
  String get play_next => 'I-play susunod';

  @override
  String removed_track_from_queue(Object track) {
    return 'Tinanggal ang $track mula sa pila';
  }

  @override
  String get remove_from_queue => 'Alisin mula sa pila';

  @override
  String get remove_from_favorites => 'Alisin mula sa mga paborito';

  @override
  String get save_as_favorite => 'I-save bilang paborito';

  @override
  String get add_to_playlist => 'Idagdag sa playlist';

  @override
  String get remove_from_playlist => 'Alisin mula sa playlist';

  @override
  String get add_to_blacklist => 'Idagdag sa blacklist';

  @override
  String get remove_from_blacklist => 'Alisin mula sa blacklist';

  @override
  String get share => 'Ibahagi';

  @override
  String get mini_player => 'Mini Player';

  @override
  String get slide_to_seek => 'I-slide para mag-seek pasulong o pabalik';

  @override
  String get shuffle_playlist => 'I-shuffle ang playlist';

  @override
  String get unshuffle_playlist => 'I-unshuffle ang playlist';

  @override
  String get previous_track => 'Nakaraang track';

  @override
  String get next_track => 'Susunod na track';

  @override
  String get pause_playback => 'I-pause ang Playback';

  @override
  String get resume_playback => 'Ipagpatuloy ang Playback';

  @override
  String get loop_track => 'I-loop ang track';

  @override
  String get no_loop => 'Walang loop';

  @override
  String get repeat_playlist => 'Ulitin ang playlist';

  @override
  String get queue => 'Pila';

  @override
  String get alternative_track_sources =>
      'Alternatibong mga pinagmulan ng track';

  @override
  String get download_track => 'I-download ang track';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks na mga track sa pila';
  }

  @override
  String get clear_all => 'Burahin lahat';

  @override
  String get show_hide_ui_on_hover => 'Ipakita/Itago ang UI sa hover';

  @override
  String get always_on_top => 'Palaging nasa ibabaw';

  @override
  String get exit_mini_player => 'Lumabas sa Mini player';

  @override
  String get download_location => 'Lokasyon ng pag-download';

  @override
  String get local_library => 'Lokal na silid-aklatan';

  @override
  String get add_library_location => 'Idagdag sa silid-aklatan';

  @override
  String get remove_library_location => 'Alisin mula sa silid-aklatan';

  @override
  String get account => 'Account';

  @override
  String get logout => 'Mag-logout';

  @override
  String get logout_of_this_account => 'Mag-logout sa account na ito';

  @override
  String get language_region => 'Wika at Rehiyon';

  @override
  String get language => 'Wika';

  @override
  String get system_default => 'Default ng Sistema';

  @override
  String get market_place_region => 'Rehiyon ng Marketplace';

  @override
  String get recommendation_country => 'Bansang Inirerekomenda';

  @override
  String get appearance => 'Hitsura';

  @override
  String get layout_mode => 'Mode ng Layout';

  @override
  String get override_layout_settings =>
      'I-override ang mga setting ng responsive layout mode';

  @override
  String get adaptive => 'Umaangkop';

  @override
  String get compact => 'Kompakto';

  @override
  String get extended => 'Pinalawig';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Madilim';

  @override
  String get light => 'Maliwanag';

  @override
  String get system => 'Sistema';

  @override
  String get accent_color => 'Kulay ng Accent';

  @override
  String get sync_album_color => 'I-sync ang kulay ng album';

  @override
  String get sync_album_color_description =>
      'Ginagamit ang pangunahing kulay ng album art bilang kulay ng accent';

  @override
  String get playback => 'Playback';

  @override
  String get audio_quality => 'Kalidad ng Audio';

  @override
  String get high => 'Mataas';

  @override
  String get low => 'Mababa';

  @override
  String get pre_download_play => 'Mag-pre-download at i-play';

  @override
  String get pre_download_play_description =>
      'Sa halip na mag-stream ng audio, mag-download ng bytes at i-play sa halip (Inirerekomenda para sa mga gumagamit ng mataas na bandwidth)';

  @override
  String get skip_non_music =>
      'Laktawan ang mga segment na hindi musika (SponsorBlock)';

  @override
  String get blacklist_description => 'Mga track at artista na nasa blacklist';

  @override
  String get wait_for_download_to_finish =>
      'Mangyaring maghintay para matapos ang kasalukuyang pag-download';

  @override
  String get desktop => 'Desktop';

  @override
  String get close_behavior => 'Pag-uugali ng Pagsara';

  @override
  String get close => 'Isara';

  @override
  String get minimize_to_tray => 'I-minimize sa tray';

  @override
  String get show_tray_icon => 'Ipakita ang icon ng System tray';

  @override
  String get about => 'Tungkol sa';

  @override
  String get u_love_spotube => 'Alam naming gusto mo ang DeeMusiq';

  @override
  String get check_for_updates => 'Maghanap ng mga update';

  @override
  String get about_spotube => 'Tungkol sa DeeMusiq';

  @override
  String get blacklist => 'Blacklist';

  @override
  String get please_sponsor => 'Mangyaring Mag-sponsor/Mag-donate';

  @override
  String get spotube_description =>
      'DeeMusiq, isang magaan, cross-platform, libreng-para-sa-lahat na spotify client';

  @override
  String get version => 'Bersyon';

  @override
  String get build_number => 'Build Number';

  @override
  String get founder => 'Nagtatag';

  @override
  String get repository => 'Repository';

  @override
  String get bug_issues => 'Bug+Mga Isyu';

  @override
  String get made_with => 'Ginawa nang may ❤️ sa Bangladesh🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Lisensya';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Huwag mag-alala, ang alinman sa iyong mga kredensyal ay hindi kokolektahin o ibabahagi sa sinuman';

  @override
  String get know_how_to_login => 'Hindi mo alam kung paano gawin ito?';

  @override
  String get follow_step_by_step_guide => 'Sundin ang Hakbang-hakbang na gabay';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Cookie';
  }

  @override
  String get fill_in_all_fields => 'Mangyaring punan ang lahat ng field';

  @override
  String get submit => 'Isumite';

  @override
  String get exit => 'Lumabas';

  @override
  String get previous => 'Nakaraan';

  @override
  String get next => 'Susunod';

  @override
  String get done => 'Tapos na';

  @override
  String get step_1 => 'Hakbang 1';

  @override
  String get first_go_to => 'Una, Pumunta sa';

  @override
  String get something_went_wrong => 'May nangyaring mali';

  @override
  String get piped_instance => 'Instance ng Piped Server';

  @override
  String get piped_description =>
      'Ang instance ng Piped server na gagamitin para sa pagtutugma ng track';

  @override
  String get piped_warning =>
      'Maaaring hindi gumagana nang mabuti ang ilan sa mga ito. Kaya gamitin sa sarili mong peligro';

  @override
  String get invidious_instance => 'Instance ng Invidious Server';

  @override
  String get invidious_description =>
      'Ang instance ng Invidious server na gagamitin para sa pagtutugma ng track';

  @override
  String get invidious_warning =>
      'Maaaring hindi gumagana nang mabuti ang ilan sa mga ito. Kaya gamitin sa sarili mong peligro';

  @override
  String get generate => 'Gumawa';

  @override
  String track_exists(Object track) {
    return 'Ang Track na $track ay umiiral na';
  }

  @override
  String get replace_downloaded_tracks =>
      'Palitan ang lahat ng na-download na mga track';

  @override
  String get skip_download_tracks =>
      'Laktawan ang pag-download ng lahat ng na-download na mga track';

  @override
  String get do_you_want_to_replace =>
      'Gusto mo bang palitan ang umiiral na track??';

  @override
  String get replace => 'Palitan';

  @override
  String get skip => 'Laktawan';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Pumili ng hanggang $count $type';
  }

  @override
  String get select_genres => 'Pumili ng mga Genre';

  @override
  String get add_genres => 'Magdagdag ng mga Genre';

  @override
  String get country => 'Bansa';

  @override
  String get number_of_tracks_generate => 'Bilang ng mga track na gagawin';

  @override
  String get acousticness => 'Acoustic-ness';

  @override
  String get danceability => 'Kakayahang Sayawin';

  @override
  String get energy => 'Enerhiya';

  @override
  String get instrumentalness => 'Instrumental-ness';

  @override
  String get liveness => 'Liveness';

  @override
  String get loudness => 'Lakas';

  @override
  String get speechiness => 'Pagsasalita';

  @override
  String get valence => 'Valence';

  @override
  String get popularity => 'Popularidad';

  @override
  String get key => 'Key';

  @override
  String get duration => 'Tagal (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Mode';

  @override
  String get time_signature => 'Time Signature';

  @override
  String get short => 'Maikli';

  @override
  String get medium => 'Katamtaman';

  @override
  String get long => 'Mahaba';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get target => 'Target';

  @override
  String get moderate => 'Katamtaman';

  @override
  String get deselect_all => 'Alisin ang Pagkakapili sa Lahat';

  @override
  String get select_all => 'Piliin Lahat';

  @override
  String get are_you_sure => 'Sigurado ka ba?';

  @override
  String get generating_playlist => 'Gumagawa ng iyong custom na playlist...';

  @override
  String selected_count_tracks(Object count) {
    return 'Napili ang $count na mga track';
  }

  @override
  String get download_warning =>
      'Kung nag-download ka ng lahat ng Track sa maramihan, malinaw na nagpa-pirate ka ng Musika at nagsasanhi ng pinsala sa creative society ng Musika. Sana ay alam mo ito. Palaging, subukang igalang at suportahan ang masipag na paggawa ng Artist';

  @override
  String get download_ip_ban_warning =>
      'Sa nga pala, ang iyong IP ay maaaring ma-block sa YouTube dahil sa sobrang mga kahilingan sa pag-download kaysa sa karaniwan. Ang IP block ay nangangahulugang hindi mo magagamit ang YouTube (kahit na naka-log in ka) sa loob ng hindi bababa sa 2-3 buwan mula sa device na may IP na iyon. At hindi pinanghahawakan ng DeeMusiq ang anumang responsibilidad kung mangyayari ito';

  @override
  String get by_clicking_accept_terms =>
      'Sa pamamagitan ng pag-click sa \'tanggapin\', sumasang-ayon ka sa mga sumusunod na tuntunin:';

  @override
  String get download_agreement_1 =>
      'Alam kong nagpa-pirate ako ng Musika. Masama ako';

  @override
  String get download_agreement_2 =>
      'Susuportahan ko ang Artist saan man ako maaari at ginagawa ko lang ito dahil wala akong pera para bumili ng kanilang sining';

  @override
  String get download_agreement_3 =>
      'Lubos kong nauunawaan na ang aking IP ay maaaring ma-block sa YouTube at hindi ko pinanghahawakan ang DeeMusiq o ang kanyang mga may-ari/nag-ambag na responsable para sa anumang aksidente na sanhi ng aking kasalukuyang aksyon';

  @override
  String get decline => 'Tanggihan';

  @override
  String get accept => 'Tanggapin';

  @override
  String get details => 'Mga Detalye';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Channel';

  @override
  String get likes => 'Mga Like';

  @override
  String get dislikes => 'Mga Dislike';

  @override
  String get views => 'Mga View';

  @override
  String get streamUrl => 'Stream URL';

  @override
  String get stop => 'Ihinto';

  @override
  String get sort_newest => 'Ayusin ayon sa pinakabagong idinagdag';

  @override
  String get sort_oldest => 'Ayusin ayon sa pinakalumang idinagdag';

  @override
  String get sleep_timer => 'Sleep Timer';

  @override
  String mins(Object minutes) {
    return '$minutes Minuto';
  }

  @override
  String hours(Object hours) {
    return '$hours Oras';
  }

  @override
  String hour(Object hours) {
    return '$hours Oras';
  }

  @override
  String get custom_hours => 'Custom na Oras';

  @override
  String get logs => 'Mga Log';

  @override
  String get developers => 'Mga Developer';

  @override
  String get not_logged_in => 'Hindi ka naka-log in';

  @override
  String get search_mode => 'Mode ng Paghahanap';

  @override
  String get audio_source => 'Pinagmulan ng Audio';

  @override
  String get ok => 'Ok';

  @override
  String get failed_to_encrypt => 'Nabigong i-encrypt';

  @override
  String get encryption_failed_warning =>
      'Gumagamit ng encryption ang DeeMusiq para ligtas na i-store ang iyong data. Ngunit nabigo. Kaya babalik ito sa hindi secure na storage\nKung gumagamit ka ng linux, mangyaring tiyakin na mayroon kang anumang secret-service na naka-install (gnome-keyring, kde-wallet, keepassxc atbp)';

  @override
  String get querying_info => 'Kinukuha ang impormasyon...';

  @override
  String get piped_api_down => 'Ang Piped API ay hindi gumagana';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Ang instance ng Piped na $pipedInstance ay kasalukuyang hindi gumagana\n\nMaaari mong baguhin ang instance o baguhin ang \'Uri ng API\' sa opisyal na YouTube API\n\nSiguraduhing i-restart ang app pagkatapos ng pagbabago';
  }

  @override
  String get you_are_offline => 'Kasalukuyan kang offline';

  @override
  String get connection_restored =>
      'Naibalik na ang iyong koneksyon sa internet';

  @override
  String get use_system_title_bar => 'Gamitin ang title bar ng system';

  @override
  String get crunching_results => 'Pinaproseso ang mga resulta...';

  @override
  String get search_to_get_results => 'Maghanap para makakuha ng mga resulta';

  @override
  String get use_amoled_mode => 'Matingkad na itim na madilim na tema';

  @override
  String get pitch_dark_theme => 'AMOLED Mode';

  @override
  String get normalize_audio => 'I-normalize ang audio';

  @override
  String get change_cover => 'Baguhin ang cover';

  @override
  String get add_cover => 'Magdagdag ng cover';

  @override
  String get restore_defaults => 'Ibalik ang mga default';

  @override
  String get download_music_format => 'I-download na format ng musika';

  @override
  String get streaming_music_format => 'Format ng streaming ng musika';

  @override
  String get download_music_quality => 'Kalidad ng i-download na musika';

  @override
  String get streaming_music_quality => 'Kalidad ng streaming ng musika';

  @override
  String get login_with_lastfm => 'Mag-login gamit ang Last.fm';

  @override
  String get connect => 'Kumonekta';

  @override
  String get disconnect_lastfm => 'Idiskonekta ang Last.fm';

  @override
  String get disconnect => 'Idiskonekta';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Mag-login';

  @override
  String get login_with_your_lastfm =>
      'Mag-login gamit ang iyong Last.fm account';

  @override
  String get scrobble_to_lastfm => 'I-scrobble sa Last.fm';

  @override
  String get go_to_album => 'Pumunta sa Album';

  @override
  String get discord_rich_presence => 'Discord Rich Presence';

  @override
  String get browse_all => 'I-browse Lahat';

  @override
  String get genres => 'Mga Genre';

  @override
  String get explore_genres => 'Tuklasin ang mga Genre';

  @override
  String get friends => 'Mga Kaibigan';

  @override
  String get no_lyrics_available =>
      'Paumanhin, hindi mahanap ang lyrics para sa track na ito';

  @override
  String get start_a_radio => 'Magsimula ng Radio';

  @override
  String get how_to_start_radio => 'Paano mo gustong simulan ang radio?';

  @override
  String get replace_queue_question =>
      'Gusto mo bang palitan ang kasalukuyang pila o idagdag dito?';

  @override
  String get endless_playback => 'Walang Hanggang Playback';

  @override
  String get delete_playlist => 'Burahin ang Playlist';

  @override
  String get delete_playlist_confirmation =>
      'Sigurado ka bang gusto mong burahin ang playlist na ito?';

  @override
  String get local_tracks => 'Mga Lokal na Track';

  @override
  String get local_tab => 'Lokal';

  @override
  String get song_link => 'Link ng Kanta';

  @override
  String get youtube_source_description =>
      'Inirerekomenda at pinakamahusay na gumagana.';

  @override
  String get piped_source_description =>
      'Gusto ng kalayaan? Kapareho ng YouTube ngunit mas malaya.';

  @override
  String get jiosaavn_source_description =>
      'Pinakamahusay para sa rehiyon ng South Asia.';

  @override
  String get invidious_source_description =>
      'Katulad ng Piped ngunit may mas mataas na availability.';

  @override
  String highest_quality(Object quality) {
    return 'Pinakamataas na Kalidad: $quality';
  }

  @override
  String get select_audio_source => 'Pumili ng Pinagmulan ng Audio';

  @override
  String get contribute_on_github => 'Mag-contribute sa GitHub';

  @override
  String get browse_anonymously => 'Mag-browse nang Anonymous';

  @override
  String get enable_connect => 'I-enable ang Connect';

  @override
  String get enable_connect_description =>
      'Kontrolin ang DeeMusiq mula sa ibang mga device';

  @override
  String get devices => 'Mga Device';

  @override
  String get select => 'Pumili';

  @override
  String connect_client_alert(Object client) {
    return 'Ikaw ay kontrolado ng $client';
  }

  @override
  String get this_device => 'Ang Device na ito';

  @override
  String get remote => 'Remote';

  @override
  String get stats => 'Mga Stat';

  @override
  String and_n_more(Object count) {
    return 'at $count pa';
  }

  @override
  String get recently_played => 'Kamakailan Lang na Ni-play';

  @override
  String get browse_more => 'Mag-browse pa';

  @override
  String get no_title => 'Walang Pamagat';

  @override
  String get not_playing => 'Hindi tumutugtog';

  @override
  String get epic_failure => 'Epic na pagkabigo!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Nagdagdag ng $tracks_length na mga track sa pila';
  }

  @override
  String get spotube_has_an_update => 'Ang DeeMusiq ay may update';

  @override
  String get download_now => 'I-download Ngayon';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'Ang DeeMusiq Nightly $nightlyBuildNum ay inilabas na';
  }

  @override
  String release_version(Object version) {
    return 'Ang DeeMusiq v$version ay inilabas na';
  }

  @override
  String get read_the_latest => 'Basahin ang pinakabagong ';

  @override
  String get release_notes => 'release notes';

  @override
  String get pick_color_scheme => 'Pumili ng color scheme';

  @override
  String get save => 'I-save';

  @override
  String get choose_the_device => 'Piliin ang device:';

  @override
  String get multiple_device_connected =>
      'Mayroong maraming device na nakakonekta.\nPiliin ang device kung saan mo gustong maganap ang aksyon na ito';

  @override
  String get nothing_found => 'Walang nahanap';

  @override
  String get the_box_is_empty => 'Ang kahon ay walang laman';

  @override
  String get top_artists => 'Nangungunang mga Artista';

  @override
  String get top_albums => 'Nangungunang mga Album';

  @override
  String get this_week => 'Ngayong linggo';

  @override
  String get this_month => 'Ngayong buwan';

  @override
  String get last_6_months => 'Nakaraang 6 na buwan';

  @override
  String get this_year => 'Ngayong taon';

  @override
  String get last_2_years => 'Nakaraang 2 taon';

  @override
  String get all_time => 'Lahat ng panahon';

  @override
  String powered_by_provider(Object providerName) {
    return 'Pinapagana ng $providerName';
  }

  @override
  String get email => 'Email';

  @override
  String get profile_followers => 'Mga Tagasunod';

  @override
  String get birthday => 'Kaarawan';

  @override
  String get subscription => 'Subscription';

  @override
  String get not_born => 'Hindi pa ipinanganak';

  @override
  String get hacker => 'Hacker';

  @override
  String get profile => 'Profile';

  @override
  String get no_name => 'Walang Pangalan';

  @override
  String get edit => 'I-edit';

  @override
  String get user_profile => 'Profile ng User';

  @override
  String count_plays(Object count) {
    return '$count na mga play';
  }

  @override
  String get minutes_listened => 'Mga minutong pinapakinggan';

  @override
  String get streamed_songs => 'Mga na-stream na kanta';

  @override
  String count_streams(Object count) {
    return '$count na mga stream';
  }

  @override
  String get owned_by_you => 'Pag-aari mo';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return 'Na-kopya ang $shareUrl sa clipboard';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes minuto';
  }

  @override
  String get summary_minutes => 'minuto';

  @override
  String get summary_listened_to_music => 'Nakinig sa musika';

  @override
  String get summary_songs => 'mga kanta';

  @override
  String get summary_streamed_overall => 'Na-stream sa kabuuan';

  @override
  String get summary_artists => 'artista';

  @override
  String get summary_music_reached_you => 'Umabot sa iyo ang musika';

  @override
  String get summary_full_albums => 'buong album';

  @override
  String get summary_got_your_love => 'Nakuha ang iyong pagmamahal';

  @override
  String get summary_playlists => 'mga playlist';

  @override
  String get summary_were_on_repeat => 'Pinu-playlst muli';

  @override
  String get webview_not_found => 'Hindi nahanap ang Webview';

  @override
  String get webview_not_found_description =>
      'Walang webview runtime na naka-install sa iyong device.\nKung naka-install ito, siguraduhing nasa Environment PATH\n\nPagkatapos mag-install, i-restart ang app';

  @override
  String get unsupported_platform => 'Hindi suportadong platform';

  @override
  String get cache_music => 'I-cache ang musika';

  @override
  String get open => 'Buksan';

  @override
  String get cache_folder => 'Folder ng cache';

  @override
  String get export => 'I-export';

  @override
  String get clear_cache => 'Burahin ang cache';

  @override
  String get clear_cache_confirmation => 'Gusto mo bang burahin ang cache?';

  @override
  String get export_cache_files => 'I-export ang mga Naka-cache na File';

  @override
  String found_n_files(Object count) {
    return 'Nahanap ang $count na mga file';
  }

  @override
  String get export_cache_confirmation =>
      'Gusto mo bang i-export ang mga file na ito sa';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'Na-export ang $filesExported mula sa $files na mga file';
  }

  @override
  String get undo => 'I-undo';

  @override
  String get download_all => 'I-download lahat';

  @override
  String get add_all_to_playlist => 'Idagdag lahat sa playlist';

  @override
  String get add_all_to_queue => 'Idagdag lahat sa pila';

  @override
  String get play_all_next => 'I-play lahat susunod';

  @override
  String get pause => 'Pause';

  @override
  String get view_all => 'Tingnan lahat';

  @override
  String get no_tracks_added_yet =>
      'Mukhang wala ka pang idinaragdag na mga track';

  @override
  String get no_tracks => 'Mukhang walang mga track dito';

  @override
  String get no_tracks_listened_yet => 'Mukhang wala ka pang pinakikinggan';

  @override
  String get not_following_artists =>
      'Hindi ka sumusunod sa anumang mga artista';

  @override
  String get no_favorite_albums_yet =>
      'Mukhang wala ka pang idinagdag na anumang mga album sa iyong mga paborito';

  @override
  String get no_logs_found => 'Walang nahanap na mga log';

  @override
  String get youtube_engine => 'YouTube Engine';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return 'Hindi naka-install ang $engine';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return 'Hindi naka-install ang $engine sa iyong sistema.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Siguraduhing available ito sa PATH variable o\ni-set ang absolute path sa $engine executable sa ibaba';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'Sa macOS/Linux/unix tulad ng OS, ang pag-set ng path sa .zshrc/.bashrc/.bash_profile atbp. ay hindi gagana.\nKailangan mong i-set ang path sa configuration file ng shell';

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
  String get download => 'I-download';

  @override
  String get file_not_found => 'Hindi nahanap ang file';

  @override
  String get custom => 'Custom';

  @override
  String get add_custom_url => 'Magdagdag ng custom URL';

  @override
  String get edit_port => 'I-edit ang port';

  @override
  String get port_helper_msg =>
      'Ang default ay -1 na nagpapahiwatig ng random na numero. Kung na-configure mo ang firewall, inirerekomenda na itakda ito.';

  @override
  String connect_request(Object client) {
    return 'Payagan ang $client na kumonekta?';
  }

  @override
  String get connection_request_denied =>
      'Tanggihan ang koneksyon. Tinanggihan ng gumagamit ang pag-access.';

  @override
  String get an_error_occurred => 'May naganap na error';

  @override
  String get copy_to_clipboard => 'Kopyahin sa clipboard';

  @override
  String get view_logs => 'Tingnan ang mga log';

  @override
  String get retry => 'Subukang muli';

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
      'Wala kang nakatakdang default na metadata provider';

  @override
  String get manage_metadata_providers =>
      'Pamahalaan ang mga metadata provider';

  @override
  String get open_link_in_browser => 'Buksan ang Link sa Browser?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Gusto mo bang buksan ang sumusunod na link';

  @override
  String get unsafe_url_warning =>
      'Maaaring hindi ligtas ang pagbukas ng mga link mula sa hindi pinagkakatiwalaang pinagmulan. Mag-ingat!\nMaaari mo ring kopyahin ang link sa iyong clipboard.';

  @override
  String get copy_link => 'Kopyahin ang Link';

  @override
  String get building_your_timeline =>
      'Binubuo ang iyong timeline batay sa iyong mga pinakinggan...';

  @override
  String get official => 'Opisyal';

  @override
  String author_name(Object author) {
    return 'May-akda: $author';
  }

  @override
  String get third_party => 'Third-party';

  @override
  String get plugin_requires_authentication =>
      'Nangangailangan ng authentication ang plugin';

  @override
  String get update_available => 'May available na update';

  @override
  String get supports_scrobbling => 'Sinusuportahan ang scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'Sinis-scrobble ng plugin na ito ang iyong musika upang mabuo ang iyong kasaysayan ng pakikinig.';

  @override
  String get default_metadata_source => 'Default na pinagmulan ng metadata';

  @override
  String get set_default_metadata_source =>
      'Itakda ang default na pinagmulan ng metadata';

  @override
  String get default_audio_source => 'Default na pinagmulan ng audio';

  @override
  String get set_default_audio_source =>
      'Itakda ang default na pinagmulan ng audio';

  @override
  String get set_default => 'Itakda bilang default';

  @override
  String get support => 'Suporta';

  @override
  String get support_plugin_development => 'Suportahan ang pagbuo ng plugin';

  @override
  String can_access_name_api(Object name) {
    return '- Maaaring i-access ang **$name** API';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Gusto mo bang i-install ang plugin na ito?';

  @override
  String get third_party_plugin_warning =>
      'Ang plugin na ito ay mula sa third-party na repository. Mangyaring tiyakin na pinagkakatiwalaan mo ang pinagmulan bago mag-install.';

  @override
  String get author => 'May-akda';

  @override
  String get this_plugin_can_do_following =>
      'Maaaring gawin ng plugin na ito ang sumusunod';

  @override
  String get install => 'I-install';

  @override
  String get no_tracks_playing => 'Walang Track na kasalukuyang tumutugtog';

  @override
  String get synced_lyrics_not_available =>
      'Hindi available ang mga naka-sync na lyrics para sa kantang ito. Mangyaring gamitin ang';

  @override
  String get plain_lyrics => 'Simpleng Lyrics';

  @override
  String get tab_instead => 'na tab sa halip.';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get third_party_plugin_dmca_notice =>
      'Ang DeeMusiq team ay walang hawak na anumang responsibilidad (kabilang ang legal) para sa anumang \"Third-party\" plugins.\nMangyaring gamitin ang mga ito sa iyong sariling peligro. Para sa anumang mga bug/isyu, mangyaring iulat ang mga ito sa repository ng plugin.\n\nKung ang anumang \"Third-party\" plugin ay lumalabag sa ToS/DMCA ng anumang serbisyo/legal na entity, mangyaring hilingin sa \"Third-party\" plugin author o sa hosting platform e.g. GitHub/Codeberg na gumawa ng aksyon. Ang nakalista sa itaas (\"Third-party\" na may label) ay lahat ng pampubliko/komunidad na pinananatiling mga plugin. Hindi namin sila kinukurusado, kaya hindi kami makakagawa ng anumang aksyon sa kanila.\n\n';

  @override
  String get plugins => 'Mga plugin';

  @override
  String get paste_plugin_download_url =>
      'I-paste ang download url o GitHub/Codeberg repo url o direktang link sa .smplug file';

  @override
  String get download_and_install_plugin_from_url =>
      'I-download at i-install ang plugin mula sa url';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Nabigo ang pagdagdag ng plugin: $error';
  }

  @override
  String get upload_plugin_from_file => 'I-upload ang plugin mula sa file';

  @override
  String get installed => 'Naka-install';

  @override
  String get available_plugins => 'Mga available na plugin';

  @override
  String get configure_plugins =>
      'I-configure ang sarili mong metadata provider at mga audio source plugin';

  @override
  String get audio_scrobblers => 'Mga Audio Scrobbler';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Pinagmulan: ';

  @override
  String get uncompressed => 'Hindi naka-compress';

  @override
  String get dab_music_source_description =>
      'Para sa mga audiophile. Nagbibigay ng de-kalidad/walang loss na audio streams. Tumpak na pagtutugma ng track batay sa ISRC.';

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
  String get skip_this_nonsense => 'Laktawan ang kalokohan na ito';

  @override
  String get freedom_of_music => '\"Kalayaan ng Musika\"';

  @override
  String get freedom_of_music_palm => '\"Kalayaan ng Musika sa iyong palad\"';

  @override
  String get get_started => 'Magsimula na tayo';

  @override
  String get endless_playback_description =>
      'Awtomatikong magdagdag ng mga bagong kanta\nsa dulo ng pila';

  @override
  String get choose_your_region => 'Piliin ang iyong rehiyon';

  @override
  String get choose_your_region_description =>
      'Ito ay tutulong sa DeeMusiq na ipakita sa iyo ang tamang content\npara sa iyong lokasyon.';

  @override
  String get choose_your_language => 'Piliin ang iyong wika';

  @override
  String get help_project_grow => 'Tulungan ang proyektong ito na lumago';

  @override
  String get help_project_grow_description =>
      'Ang DeeMusiq ay isang open-source na proyekto. Maaari mong tulungan ang proyektong ito na lumago sa pamamagitan ng pag-contribute sa proyekto, pag-ulat ng mga bug, o pagmungkahi ng mga bagong feature.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Mag-donate sa Open Collective';

  @override
  String get install_a_metadata_provider => 'Mag-install ng Metadata Provider';

  @override
  String get input_does_not_match_format =>
      'Ang input ay hindi tumutugma sa kinakailangang format';

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
  String get auth_mfa_required => 'Ilagay ang iyong code ng pagpapatotoo';

  @override
  String get auth_mfa_body =>
      'Buksan ang iyong authenticator app at ilagay ang 6-digit na code upang matapos ang pag-sign in.';

  @override
  String get auth_mfa_verify_action => 'Beripika';

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
