// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get guest => 'Guest';

  @override
  String get browse => 'Browse';

  @override
  String get search => 'Search';

  @override
  String get library => 'Library';

  @override
  String get lyrics => 'Lyrics';

  @override
  String get settings => 'Settings';

  @override
  String get genre_categories_filter => 'Filter categories or genres...';

  @override
  String get genre => 'Genre';

  @override
  String get personalized => 'Personalized';

  @override
  String get featured => 'Featured';

  @override
  String get new_releases => 'New Releases';

  @override
  String get songs => 'Songs';

  @override
  String playing_track(Object track) {
    return 'Playing $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'This will clear the current queue. $track_length tracks will be removed\nDo you want to continue?';
  }

  @override
  String get load_more => 'Load more';

  @override
  String get playlists => 'Playlists';

  @override
  String get artists => 'Artists';

  @override
  String get albums => 'Albums';

  @override
  String get tracks => 'Tracks';

  @override
  String get downloads => 'Downloads';

  @override
  String get filter_playlists => 'Filter your playlists...';

  @override
  String get liked_tracks => 'Liked Tracks';

  @override
  String get liked_tracks_description => 'All your liked tracks';

  @override
  String get playlist => 'Playlist';

  @override
  String get create_a_playlist => 'Create a playlist';

  @override
  String get update_playlist => 'Update playlist';

  @override
  String get create => 'Create';

  @override
  String get cancel => 'Cancel';

  @override
  String get update => 'Update';

  @override
  String get playlist_name => 'Playlist Name';

  @override
  String get name_of_playlist => 'Name of the playlist';

  @override
  String get description => 'Description';

  @override
  String get public => 'Public';

  @override
  String get collaborative => 'Collaborative';

  @override
  String get search_local_tracks => 'Search local tracks...';

  @override
  String get play => 'Play';

  @override
  String get delete => 'Delete';

  @override
  String get none => 'None';

  @override
  String get sort_a_z => 'Sort by A-Z';

  @override
  String get sort_z_a => 'Sort by Z-A';

  @override
  String get sort_artist => 'Sort by Artist';

  @override
  String get sort_album => 'Sort by Album';

  @override
  String get sort_duration => 'Sort by Duration';

  @override
  String get sort_tracks => 'Sort Tracks';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Currently Downloading ($tracks_length)';
  }

  @override
  String get cancel_all => 'Cancel All';

  @override
  String get filter_artist => 'Filter artists...';

  @override
  String followers(Object followers) {
    return '$followers Followers';
  }

  @override
  String get add_artist_to_blacklist => 'Add artist to blacklist';

  @override
  String get top_tracks => 'Top Tracks';

  @override
  String get fans_also_like => 'Fans also like';

  @override
  String get loading => 'Loading...';

  @override
  String get artist => 'Artist';

  @override
  String get blacklisted => 'Blacklisted';

  @override
  String get following => 'Following';

  @override
  String get follow => 'Follow';

  @override
  String get artist_url_copied => 'Artist URL copied to clipboard';

  @override
  String added_to_queue(Object tracks) {
    return 'Added $tracks tracks to queue';
  }

  @override
  String get filter_albums => 'Filter albums...';

  @override
  String get synced => 'Synced';

  @override
  String get plain => 'Plain';

  @override
  String get shuffle => 'Shuffle';

  @override
  String get search_tracks => 'Search tracks...';

  @override
  String get released => 'Released';

  @override
  String error(Object error) {
    return 'Error $error';
  }

  @override
  String get title => 'Title';

  @override
  String get time => 'Time';

  @override
  String get more_actions => 'More actions';

  @override
  String download_count(Object count) {
    return 'Download ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Add ($count) to Playlist';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Add ($count) to Queue';
  }

  @override
  String play_count_next(Object count) {
    return 'Play ($count) next';
  }

  @override
  String get album => 'Album';

  @override
  String copied_to_clipboard(Object data) {
    return 'Copied $data to clipboard';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Add $track to following Playlists';
  }

  @override
  String get add => 'Add';

  @override
  String added_track_to_queue(Object track) {
    return 'Added $track to queue';
  }

  @override
  String get add_to_queue => 'Add to queue';

  @override
  String track_will_play_next(Object track) {
    return '$track will play next';
  }

  @override
  String get play_next => 'Play next';

  @override
  String removed_track_from_queue(Object track) {
    return 'Removed $track from queue';
  }

  @override
  String get remove_from_queue => 'Remove from queue';

  @override
  String get remove_from_favorites => 'Remove from favorites';

  @override
  String get save_as_favorite => 'Save as favorite';

  @override
  String get add_to_playlist => 'Add to playlist';

  @override
  String get remove_from_playlist => 'Remove from playlist';

  @override
  String get add_to_blacklist => 'Add to blacklist';

  @override
  String get remove_from_blacklist => 'Remove from blacklist';

  @override
  String get share => 'Share';

  @override
  String get mini_player => 'Mini Player';

  @override
  String get slide_to_seek => 'Slide to seek forward or backward';

  @override
  String get shuffle_playlist => 'Shuffle playlist';

  @override
  String get unshuffle_playlist => 'Unshuffle playlist';

  @override
  String get previous_track => 'Previous track';

  @override
  String get next_track => 'Next track';

  @override
  String get pause_playback => 'Pause Playback';

  @override
  String get resume_playback => 'Resume Playback';

  @override
  String get loop_track => 'Loop track';

  @override
  String get no_loop => 'No loop';

  @override
  String get repeat_playlist => 'Repeat playlist';

  @override
  String get queue => 'Queue';

  @override
  String get alternative_track_sources => 'Alternative track sources';

  @override
  String get download_track => 'Download track';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks tracks in queue';
  }

  @override
  String get clear_all => 'Clear all';

  @override
  String get show_hide_ui_on_hover => 'Show/Hide UI on hover';

  @override
  String get always_on_top => 'Always on top';

  @override
  String get exit_mini_player => 'Exit Mini player';

  @override
  String get download_location => 'Download location';

  @override
  String get local_library => 'Local library';

  @override
  String get add_library_location => 'Add to library';

  @override
  String get remove_library_location => 'Remove from library';

  @override
  String get account => 'Account';

  @override
  String get logout => 'Logout';

  @override
  String get logout_of_this_account => 'Logout of this account';

  @override
  String get language_region => 'Language & Region';

  @override
  String get language => 'Language';

  @override
  String get system_default => 'System Default';

  @override
  String get market_place_region => 'Marketplace Region';

  @override
  String get recommendation_country => 'Recommendation Country';

  @override
  String get appearance => 'Appearance';

  @override
  String get layout_mode => 'Layout Mode';

  @override
  String get override_layout_settings =>
      'Override responsive layout mode settings';

  @override
  String get adaptive => 'Adaptive';

  @override
  String get compact => 'Compact';

  @override
  String get extended => 'Extended';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get system => 'System';

  @override
  String get accent_color => 'Accent Color';

  @override
  String get sync_album_color => 'Sync album color';

  @override
  String get sync_album_color_description =>
      'Uses the dominant color of the album art as the accent color';

  @override
  String get playback => 'Playback';

  @override
  String get audio_quality => 'Audio Quality';

  @override
  String get high => 'High';

  @override
  String get low => 'Low';

  @override
  String get pre_download_play => 'Pre-download and play';

  @override
  String get pre_download_play_description =>
      'Instead of streaming audio, download bytes and play instead (Recommended for higher bandwidth users)';

  @override
  String get skip_non_music => 'Skip non-music segments (SponsorBlock)';

  @override
  String get blacklist_description => 'Blacklisted tracks and artists';

  @override
  String get wait_for_download_to_finish =>
      'Please wait for the current download to finish';

  @override
  String get desktop => 'Desktop';

  @override
  String get close_behavior => 'Close Behavior';

  @override
  String get close => 'Close';

  @override
  String get minimize_to_tray => 'Minimize to tray';

  @override
  String get show_tray_icon => 'Show System tray icon';

  @override
  String get about => 'About';

  @override
  String get u_love_spotube => 'We know you love DeeMusiq';

  @override
  String get check_for_updates => 'Check for updates';

  @override
  String get about_spotube => 'About DeeMusiq';

  @override
  String get blacklist => 'Blacklist';

  @override
  String get please_sponsor => 'Please Sponsor/Donate';

  @override
  String get spotube_description =>
      'DeeMusiq - African music streaming and download platform. It is a drop day.';

  @override
  String get version => 'Version';

  @override
  String get build_number => 'Build Number';

  @override
  String get founder => 'Founder';

  @override
  String get repository => 'Repository';

  @override
  String get bug_issues => 'Bug+Issues';

  @override
  String get made_with => 'Made with ❤️ in Bangladesh🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'License';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Don\'t worry, any of your credentials won\'t be collected or shared with anyone';

  @override
  String get know_how_to_login => 'Don\'t know how to do this?';

  @override
  String get follow_step_by_step_guide => 'Follow along the Step by Step guide';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Cookie';
  }

  @override
  String get fill_in_all_fields => 'Please fill in all the fields';

  @override
  String get submit => 'Submit';

  @override
  String get exit => 'Exit';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get step_1 => 'Step 1';

  @override
  String get first_go_to => 'First, Go to';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get piped_instance => 'Piped Server Instance';

  @override
  String get piped_description =>
      'The Piped server instance to use for track matching';

  @override
  String get piped_warning =>
      'Some of them might not work well. So use at your own risk';

  @override
  String get invidious_instance => 'Invidious Server Instance';

  @override
  String get invidious_description =>
      'The Invidious server instance to use for track matching';

  @override
  String get invidious_warning =>
      'Some of them might not work well. So use at your own risk';

  @override
  String get generate => 'Generate';

  @override
  String track_exists(Object track) {
    return 'Track $track already exists';
  }

  @override
  String get replace_downloaded_tracks => 'Replace all downloaded tracks';

  @override
  String get skip_download_tracks => 'Skip downloading all downloaded tracks';

  @override
  String get do_you_want_to_replace =>
      'Do you want to replace the existing track??';

  @override
  String get replace => 'Replace';

  @override
  String get skip => 'Skip';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Select up to $count $type';
  }

  @override
  String get select_genres => 'Select Genres';

  @override
  String get add_genres => 'Add Genres';

  @override
  String get country => 'Country';

  @override
  String get number_of_tracks_generate => 'Number of tracks to generate';

  @override
  String get acousticness => 'Acousticness';

  @override
  String get danceability => 'Danceability';

  @override
  String get energy => 'Energy';

  @override
  String get instrumentalness => 'Instrumentalness';

  @override
  String get liveness => 'Liveness';

  @override
  String get loudness => 'Loudness';

  @override
  String get speechiness => 'Speechiness';

  @override
  String get valence => 'Valence';

  @override
  String get popularity => 'Popularity';

  @override
  String get key => 'Key';

  @override
  String get duration => 'Duration (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Mode';

  @override
  String get time_signature => 'Time Signature';

  @override
  String get short => 'Short';

  @override
  String get medium => 'Medium';

  @override
  String get long => 'Long';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get target => 'Target';

  @override
  String get moderate => 'Moderate';

  @override
  String get deselect_all => 'Deselect All';

  @override
  String get select_all => 'Select All';

  @override
  String get are_you_sure => 'Are you sure?';

  @override
  String get generating_playlist => 'Generating your custom playlist...';

  @override
  String selected_count_tracks(Object count) {
    return 'Selected $count tracks';
  }

  @override
  String get download_warning =>
      'If you download all Tracks at bulk you\'re clearly pirating Music & causing damage to the creative society of Music. I hope you are aware of this. Always, try respecting & supporting Artist\'s hard work';

  @override
  String get download_ip_ban_warning =>
      'BTW, your IP can get blocked on YouTube due excessive download requests than usual. IP block means you can\'t use YouTube (even if you\'re logged in) for at least 2-3 months from that IP device. And DeeMusiq doesn\'t hold any responsibility if this ever happens';

  @override
  String get by_clicking_accept_terms =>
      'By clicking \'accept\' you agree to following terms:';

  @override
  String get download_agreement_1 => 'I know I\'m pirating Music. I\'m bad';

  @override
  String get download_agreement_2 =>
      'I\'ll support the Artist wherever I can and I\'m only doing this because I don\'t have money to buy their art';

  @override
  String get download_agreement_3 =>
      'I\'m completely aware that my IP can get blocked on YouTube & I don\'t hold DeeMusiq or his owners/contributors responsible for any accidents caused by my current action';

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get details => 'Details';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Channel';

  @override
  String get likes => 'Likes';

  @override
  String get dislikes => 'Dislikes';

  @override
  String get views => 'Views';

  @override
  String get streamUrl => 'Stream URL';

  @override
  String get stop => 'Stop';

  @override
  String get sort_newest => 'Sort by newest added';

  @override
  String get sort_oldest => 'Sort by oldest added';

  @override
  String get sleep_timer => 'Sleep Timer';

  @override
  String mins(Object minutes) {
    return '$minutes Minutes';
  }

  @override
  String hours(Object hours) {
    return '$hours Hours';
  }

  @override
  String hour(Object hours) {
    return '$hours Hour';
  }

  @override
  String get custom_hours => 'Custom Hours';

  @override
  String get logs => 'Logs';

  @override
  String get developers => 'Developers';

  @override
  String get not_logged_in => 'You\'re not logged in';

  @override
  String get search_mode => 'Search Mode';

  @override
  String get audio_source => 'Audio Source';

  @override
  String get ok => 'Ok';

  @override
  String get failed_to_encrypt => 'Failed to encrypt';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq uses encryption to securely store your data. But failed to do so. So it\'ll fallback to insecure storage\nIf you\'re using linux, please make sure you\'ve any secret-service (gnome-keyring, kde-wallet, keepassxc etc) installed';

  @override
  String get querying_info => 'Querying info...';

  @override
  String get piped_api_down => 'Piped API is down';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'The Piped instance $pipedInstance is currently down\n\nEither change the instance or change the \'API type\' to official YouTube API\n\nMake sure to restart the app after change';
  }

  @override
  String get you_are_offline => 'You are currently offline';

  @override
  String get connection_restored => 'Your internet connection was restored';

  @override
  String get use_system_title_bar => 'Use system title bar';

  @override
  String get crunching_results => 'Crunching results...';

  @override
  String get search_to_get_results => 'Search to get results';

  @override
  String get use_amoled_mode => 'Pitch black dark theme';

  @override
  String get pitch_dark_theme => 'AMOLED Mode';

  @override
  String get normalize_audio => 'Normalize audio';

  @override
  String get change_cover => 'Change cover';

  @override
  String get add_cover => 'Add cover';

  @override
  String get restore_defaults => 'Restore defaults';

  @override
  String get download_music_format => 'Download music format';

  @override
  String get streaming_music_format => 'Streaming music format';

  @override
  String get download_music_quality => 'Download music quality';

  @override
  String get streaming_music_quality => 'Streaming music quality';

  @override
  String get login_with_lastfm => 'Login with Last.fm';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect_lastfm => 'Disconnect Last.fm';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get login => 'Login';

  @override
  String get login_with_your_lastfm => 'Login with your Last.fm account';

  @override
  String get scrobble_to_lastfm => 'Scrobble to Last.fm';

  @override
  String get go_to_album => 'Go to Album';

  @override
  String get discord_rich_presence => 'Discord Rich Presence';

  @override
  String get browse_all => 'Browse All';

  @override
  String get genres => 'Genres';

  @override
  String get explore_genres => 'Explore Genres';

  @override
  String get friends => 'Friends';

  @override
  String get no_lyrics_available => 'Sorry, unable find lyrics for this track';

  @override
  String get start_a_radio => 'Start a Radio';

  @override
  String get how_to_start_radio => 'How do you want to start the radio?';

  @override
  String get replace_queue_question =>
      'Do you want to replace the current queue or append to it?';

  @override
  String get endless_playback => 'Endless Playback';

  @override
  String get delete_playlist => 'Delete Playlist';

  @override
  String get delete_playlist_confirmation =>
      'Are you sure you want to delete this playlist?';

  @override
  String get local_tracks => 'Local Tracks';

  @override
  String get local_tab => 'Local';

  @override
  String get song_link => 'Song Link';

  @override
  String get youtube_source_description => 'Recommended and works best.';

  @override
  String get piped_source_description =>
      'Feeling free? Same as YouTube but a lot free.';

  @override
  String get jiosaavn_source_description => 'Best for South Asian region.';

  @override
  String get invidious_source_description =>
      'Similar to Piped but with higher availability.';

  @override
  String highest_quality(Object quality) {
    return 'Highest Quality: $quality';
  }

  @override
  String get select_audio_source => 'Select Audio Source';

  @override
  String get contribute_on_github => 'Contribute on GitHub';

  @override
  String get browse_anonymously => 'Browse Anonymously';

  @override
  String get enable_connect => 'Enable Connect';

  @override
  String get enable_connect_description =>
      'Control DeeMusiq from other devices';

  @override
  String get devices => 'Devices';

  @override
  String get select => 'Select';

  @override
  String connect_client_alert(Object client) {
    return 'You\'re being controlled by $client';
  }

  @override
  String get this_device => 'This Device';

  @override
  String get remote => 'Remote';

  @override
  String get stats => 'Stats';

  @override
  String and_n_more(Object count) {
    return 'and $count more';
  }

  @override
  String get recently_played => 'Recently Played';

  @override
  String get browse_more => 'Browse More';

  @override
  String get no_title => 'No Title';

  @override
  String get not_playing => 'Not playing';

  @override
  String get epic_failure => 'Epic failure!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Added $tracks_length tracks to queue';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq has an update';

  @override
  String get download_now => 'Download Now';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum has been released';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version has been released';
  }

  @override
  String get read_the_latest => 'Read the latest ';

  @override
  String get release_notes => 'release notes';

  @override
  String get pick_color_scheme => 'Pick color scheme';

  @override
  String get save => 'Save';

  @override
  String get choose_the_device => 'Choose the device:';

  @override
  String get multiple_device_connected =>
      'There are multiple device connected.\nChoose the device you want this action to take place';

  @override
  String get nothing_found => 'Nothing found';

  @override
  String get the_box_is_empty => 'The box is empty';

  @override
  String get top_artists => 'Top Artists';

  @override
  String get top_albums => 'Top Albums';

  @override
  String get this_week => 'This week';

  @override
  String get this_month => 'This month';

  @override
  String get last_6_months => 'Last 6 months';

  @override
  String get this_year => 'This year';

  @override
  String get last_2_years => 'Last 2 years';

  @override
  String get all_time => 'All time';

  @override
  String powered_by_provider(Object providerName) {
    return 'Powered by $providerName';
  }

  @override
  String get email => 'Email';

  @override
  String get profile_followers => 'Followers';

  @override
  String get birthday => 'Birthday';

  @override
  String get subscription => 'Subscription';

  @override
  String get not_born => 'Not born';

  @override
  String get hacker => 'Hacker';

  @override
  String get profile => 'Profile';

  @override
  String get no_name => 'No Name';

  @override
  String get edit => 'Edit';

  @override
  String get user_profile => 'User Profile';

  @override
  String count_plays(Object count) {
    return '$count plays';
  }

  @override
  String get minutes_listened => 'Minutes listened';

  @override
  String get streamed_songs => 'Streamed songs';

  @override
  String count_streams(Object count) {
    return '$count streams';
  }

  @override
  String get owned_by_you => 'Owned by you';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return 'Copied $shareUrl to clipboard';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes mins';
  }

  @override
  String get summary_minutes => 'minutes';

  @override
  String get summary_listened_to_music => 'Listened to music';

  @override
  String get summary_songs => 'songs';

  @override
  String get summary_streamed_overall => 'Streamed overall';

  @override
  String get summary_artists => 'artist\'s';

  @override
  String get summary_music_reached_you => 'Music reached you';

  @override
  String get summary_full_albums => 'full albums';

  @override
  String get summary_got_your_love => 'Got your love';

  @override
  String get summary_playlists => 'playlists';

  @override
  String get summary_were_on_repeat => 'Were on repeat';

  @override
  String get webview_not_found => 'Webview not found';

  @override
  String get webview_not_found_description =>
      'No webview runtime is installed in your device.\nIf it\'s installed make sure it\'s in the Environment PATH\n\nAfter installing, restart the app';

  @override
  String get unsupported_platform => 'Unsupported platform';

  @override
  String get cache_music => 'Cache music';

  @override
  String get open => 'Open';

  @override
  String get cache_folder => 'Cache folder';

  @override
  String get export => 'Export';

  @override
  String get clear_cache => 'Clear cache';

  @override
  String get clear_cache_confirmation => 'Do you want to clear the cache?';

  @override
  String get export_cache_files => 'Export Cached Files';

  @override
  String found_n_files(Object count) {
    return 'Found $count files';
  }

  @override
  String get export_cache_confirmation =>
      'Do you want to export these files to';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'Exported $filesExported out of $files files';
  }

  @override
  String get undo => 'Undo';

  @override
  String get download_all => 'Download all';

  @override
  String get add_all_to_playlist => 'Add all to playlist';

  @override
  String get add_all_to_queue => 'Add all to queue';

  @override
  String get play_all_next => 'Play all next';

  @override
  String get pause => 'Pause';

  @override
  String get view_all => 'View all';

  @override
  String get no_tracks_added_yet =>
      'Looks like you haven\'t added any tracks yet';

  @override
  String get no_tracks => 'Looks like there are no tracks here';

  @override
  String get no_tracks_listened_yet =>
      'Looks like you haven\'t listened to anything yet';

  @override
  String get not_following_artists => 'You\'re not following any artists';

  @override
  String get no_favorite_albums_yet =>
      'Looks like you haven\'t added any albums to your favorites yet';

  @override
  String get no_logs_found => 'No logs found';

  @override
  String get youtube_engine => 'DeeMusiq Engine';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine is not installed';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine is not installed in your system.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Make sure it\'s available in the PATH variable or\nset the absolute path to the $engine executable below';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'In macOS/Linux/unix like OS\'s, setting path on .zshrc/.bashrc/.bash_profile etc. won\'t work.\nYou need to set the path in the shell configuration file';

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
  String get download => 'Download';

  @override
  String get file_not_found => 'File not found';

  @override
  String get custom => 'Custom';

  @override
  String get add_custom_url => 'Add custom URL';

  @override
  String get edit_port => 'Edit port';

  @override
  String get port_helper_msg =>
      'Default is -1 which indicates random number. If you\'ve firewall configured, setting this is recommended.';

  @override
  String connect_request(Object client) {
    return 'Allow $client to connect?';
  }

  @override
  String get connection_request_denied =>
      'Connection denied. User denied access.';

  @override
  String get an_error_occurred => 'An error occurred';

  @override
  String get copy_to_clipboard => 'Copy to clipboard';

  @override
  String get view_logs => 'View logs';

  @override
  String get retry => 'Retry';

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
      'You\'ve no default metadata provider set';

  @override
  String get manage_metadata_providers => 'Manage metadata providers';

  @override
  String get open_link_in_browser => 'Open Link in Browser?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Do you want to open the following link';

  @override
  String get unsafe_url_warning =>
      'It can be unsafe to open links from untrusted sources. Be cautious!\nYou can also copy the link to your clipboard.';

  @override
  String get copy_link => 'Copy Link';

  @override
  String get building_your_timeline =>
      'Building your timeline based on your listenings...';

  @override
  String get official => 'Official';

  @override
  String author_name(Object author) {
    return 'Author: $author';
  }

  @override
  String get third_party => 'Third-party';

  @override
  String get plugin_requires_authentication => 'Plugin requires authentication';

  @override
  String get update_available => 'Update available';

  @override
  String get supports_scrobbling => 'Supports scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'This plugin scrobbles your music to generate your listening history.';

  @override
  String get default_metadata_source => 'Default metadata source';

  @override
  String get set_default_metadata_source => 'Set default metadata source';

  @override
  String get default_audio_source => 'Default audio source';

  @override
  String get set_default_audio_source => 'Set default audio source';

  @override
  String get set_default => 'Set default';

  @override
  String get support => 'Support';

  @override
  String get support_plugin_development => 'Support plugin development';

  @override
  String can_access_name_api(Object name) {
    return '- Can access **$name** API';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Do you want to install this plugin?';

  @override
  String get third_party_plugin_warning =>
      'This plugin is from a third-party repository. Please ensure you trust the source before installing.';

  @override
  String get author => 'Author';

  @override
  String get this_plugin_can_do_following => 'This plugin can do following';

  @override
  String get install => 'Install';

  @override
  String get no_tracks_playing => 'No Track being played currently';

  @override
  String get synced_lyrics_not_available =>
      'Synced lyrics are not available for this song. Please use the';

  @override
  String get plain_lyrics => 'Plain Lyrics';

  @override
  String get tab_instead => 'tab instead.';

  @override
  String get disclaimer => 'Disclaimer';

  @override
  String get third_party_plugin_dmca_notice =>
      'The DeeMusiq team does not hold any responsibility (including legal) for any \"Third-party\" plugins.\nPlease use them at your own risk. For any bugs/issues, please report them to the plugin repository.\n\nIf any \"Third-party\" plugin is breaking ToS/DMCA of any service/legal entity, please ask the \"Third-party\" plugin author or the hosting platform .e.g GitHub/Codeberg to take action. Above listed (\"Third-party\" labelled) are all public/community maintained plugins. We\'re not curating them, so we cannot take any action on them.\n\n';

  @override
  String get plugins => 'Plugins';

  @override
  String get paste_plugin_download_url =>
      'Paste download url or GitHub/Codeberg repo url or direct link to .smplug file';

  @override
  String get download_and_install_plugin_from_url =>
      'Download and install plugin from url';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Failed to add plugin: $error';
  }

  @override
  String get upload_plugin_from_file => 'Upload plugin from file';

  @override
  String get installed => 'Installed';

  @override
  String get available_plugins => 'Available plugins';

  @override
  String get configure_plugins =>
      'Configure your own metadata provider and audio source plugins';

  @override
  String get audio_scrobblers => 'Audio Scrobblers';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Source: ';

  @override
  String get uncompressed => 'Uncompressed';

  @override
  String get dab_music_source_description =>
      'For audiophiles. Provides high-quality/lossless audio streams. Accurate ISRC based track matching.';

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
  String get skip_this_nonsense => 'Skip this nonsense';

  @override
  String get freedom_of_music => '“Freedom of Music”';

  @override
  String get freedom_of_music_palm =>
      '“Freedom of Music in the palm of your hand”';

  @override
  String get get_started => 'Let\'s get started';

  @override
  String get endless_playback_description =>
      'Automatically append new songs\nto the end of the queue';

  @override
  String get choose_your_region => 'Choose your region';

  @override
  String get choose_your_region_description =>
      'This will help DeeMusiq show you the right content\nfor your location.';

  @override
  String get choose_your_language => 'Choose your language';

  @override
  String get help_project_grow => 'Help this project grow';

  @override
  String get help_project_grow_description =>
      'DeeMusiq is an open-source project. You can help this project grow by contributing to the project, reporting bugs, or suggesting new features.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Donate on Open Collective';

  @override
  String get install_a_metadata_provider => 'Install a Metadata Provider';

  @override
  String get input_does_not_match_format =>
      'Input doesn\'t match the required format';

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
  String get auth_mfa_required => 'Enter your authentication code';

  @override
  String get auth_mfa_body =>
      'Open your authenticator app and enter the 6-digit code to finish signing in.';

  @override
  String get auth_mfa_verify_action => 'Verify';

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
