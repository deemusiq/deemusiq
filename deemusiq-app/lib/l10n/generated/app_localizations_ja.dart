// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get guest => 'ゲスト';

  @override
  String get browse => '閲覧';

  @override
  String get search => '検索';

  @override
  String get library => 'ライブラリ';

  @override
  String get lyrics => '歌詞';

  @override
  String get settings => '設定';

  @override
  String get genre_categories_filter => 'カテゴリーやジャンルを絞り込み...';

  @override
  String get genre => 'ジャンル';

  @override
  String get personalized => 'あなたにおすすめ';

  @override
  String get featured => '注目';

  @override
  String get new_releases => '新着';

  @override
  String get songs => '曲';

  @override
  String playing_track(Object track) {
    return '$track を再生';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return '現在のキューを消去します。$track_length 曲を消去します。\n続行しますか？';
  }

  @override
  String get load_more => 'もっと読み込む';

  @override
  String get playlists => '再生リスト';

  @override
  String get artists => 'アーティスト';

  @override
  String get albums => 'アルバム';

  @override
  String get tracks => '曲';

  @override
  String get downloads => 'ダウンロード';

  @override
  String get filter_playlists => 'あなたの再生リストを絞り込み...';

  @override
  String get liked_tracks => 'いいねした曲';

  @override
  String get liked_tracks_description => 'いいねしたすべての曲';

  @override
  String get playlist => '再生リスト';

  @override
  String get create_a_playlist => '再生リストの作成';

  @override
  String get update_playlist => '再生リストを更新';

  @override
  String get create => '作成';

  @override
  String get cancel => 'キャンセル';

  @override
  String get update => '更新';

  @override
  String get playlist_name => '再生リスト名';

  @override
  String get name_of_playlist => '再生リストの名前';

  @override
  String get description => '説明';

  @override
  String get public => '公開';

  @override
  String get collaborative => 'コラボ';

  @override
  String get search_local_tracks => '端末内の曲を検索...';

  @override
  String get play => '再生';

  @override
  String get delete => '削除';

  @override
  String get none => 'なし';

  @override
  String get sort_a_z => 'A-Z 順に並び替え';

  @override
  String get sort_z_a => 'Z-A 順に並び替え';

  @override
  String get sort_artist => 'アーティスト順に並び替え';

  @override
  String get sort_album => 'アルバム順に並び替え';

  @override
  String get sort_duration => '長さ順に並べ替え';

  @override
  String get sort_tracks => '曲の並び替え';

  @override
  String currently_downloading(Object tracks_length) {
    return 'ダウンロード中 ($tracks_length) 曲';
  }

  @override
  String get cancel_all => 'すべてキャンセル';

  @override
  String get filter_artist => 'アーティストを絞り込み...';

  @override
  String followers(Object followers) {
    return '$followers フォロワー';
  }

  @override
  String get add_artist_to_blacklist => 'このアーティストをブラックリストに追加';

  @override
  String get top_tracks => '人気の曲';

  @override
  String get fans_also_like => 'ファンの間で人気';

  @override
  String get loading => '読み込み中...';

  @override
  String get artist => 'アーティスト';

  @override
  String get blacklisted => 'ブラックリスト';

  @override
  String get following => 'フォロー中';

  @override
  String get follow => 'フォローする';

  @override
  String get artist_url_copied => 'アーティストの URL をクリップボードにコピーしました';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks をキューに追加しました';
  }

  @override
  String get filter_albums => 'アルバムを絞り込み...';

  @override
  String get synced => '同期する';

  @override
  String get plain => 'そのまま';

  @override
  String get shuffle => 'シャッフル';

  @override
  String get search_tracks => '曲を検索...';

  @override
  String get released => 'リリース日';

  @override
  String error(Object error) {
    return 'エラー $error';
  }

  @override
  String get title => 'タイトル';

  @override
  String get time => '長さ';

  @override
  String get more_actions => 'ほかの操作';

  @override
  String download_count(Object count) {
    return 'ダウンロード ($count) 曲';
  }

  @override
  String add_count_to_playlist(Object count) {
    return '再生リストに ($count) 曲を追加';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'キューに ($count) 曲を追加';
  }

  @override
  String play_count_next(Object count) {
    return '次に ($count) 曲を再生';
  }

  @override
  String get album => 'アルバム';

  @override
  String copied_to_clipboard(Object data) {
    return '$data をクリップボードにコピーしました';
  }

  @override
  String add_to_following_playlists(Object track) {
    return '$track をこの再生リストに追加';
  }

  @override
  String get add => '追加';

  @override
  String added_track_to_queue(Object track) {
    return 'キューに $track を追加しました';
  }

  @override
  String get add_to_queue => 'キューに追加';

  @override
  String track_will_play_next(Object track) {
    return '$track を次に再生';
  }

  @override
  String get play_next => '次に再生';

  @override
  String removed_track_from_queue(Object track) {
    return 'キューから $track を除去しました';
  }

  @override
  String get remove_from_queue => 'キューから除去';

  @override
  String get remove_from_favorites => 'お気に入りから除去';

  @override
  String get save_as_favorite => 'お気に入りに保存';

  @override
  String get add_to_playlist => '再生リストに追加';

  @override
  String get remove_from_playlist => '再生リストから除去';

  @override
  String get add_to_blacklist => 'ブラックリストに追加';

  @override
  String get remove_from_blacklist => 'ブラックリストから除去';

  @override
  String get share => '共有';

  @override
  String get mini_player => 'ミニプレイヤー';

  @override
  String get slide_to_seek => '前後にスライドしてシーク';

  @override
  String get shuffle_playlist => '再生リストをシャッフル';

  @override
  String get unshuffle_playlist => '再生リストのシャッフル解除';

  @override
  String get previous_track => '前の曲';

  @override
  String get next_track => '次の曲';

  @override
  String get pause_playback => '再生を停止';

  @override
  String get resume_playback => '再生を再開';

  @override
  String get loop_track => '曲をループ';

  @override
  String get no_loop => 'ループなし';

  @override
  String get repeat_playlist => '再生リストをリピート';

  @override
  String get queue => '再生キュー';

  @override
  String get alternative_track_sources => 'この曲の別の音源を選ぶ';

  @override
  String get download_track => '曲のダウンロード';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks曲の再生キュー';
  }

  @override
  String get clear_all => 'すべて消去l';

  @override
  String get show_hide_ui_on_hover => 'マウスを乗せてUIを表示/隠す';

  @override
  String get always_on_top => '常に手前に表示';

  @override
  String get exit_mini_player => 'ミニプレイヤーを終了';

  @override
  String get download_location => 'ダウンロード先';

  @override
  String get local_library => '端末内ライブラリ';

  @override
  String get add_library_location => 'ライブラリに追加';

  @override
  String get remove_library_location => 'ライブラリから削除';

  @override
  String get account => 'アカウント';

  @override
  String get logout => 'ログアウト';

  @override
  String get logout_of_this_account => 'このアカウントからログアウト';

  @override
  String get language_region => '言語 & 地域';

  @override
  String get language => '言語';

  @override
  String get system_default => 'システムの既定値';

  @override
  String get market_place_region => '音楽市場の地域';

  @override
  String get recommendation_country => 'おすすめの国';

  @override
  String get appearance => '外観';

  @override
  String get layout_mode => 'レイアウトの種類';

  @override
  String get override_layout_settings => 'レスポンシブなレイアウトの種類の設定を上書きする';

  @override
  String get adaptive => '適応的';

  @override
  String get compact => 'コンパクト';

  @override
  String get extended => '幅広';

  @override
  String get theme => 'テーマ';

  @override
  String get dark => 'ダーク';

  @override
  String get light => 'ライト';

  @override
  String get system => 'システムに従う';

  @override
  String get accent_color => 'アクセントカラー';

  @override
  String get sync_album_color => 'アルバムの色に合わせる';

  @override
  String get sync_album_color_description => 'アルバムアートの主張色をアクセントカラーとして使用';

  @override
  String get playback => '再生';

  @override
  String get audio_quality => '音声品質';

  @override
  String get high => '高';

  @override
  String get low => '低';

  @override
  String get pre_download_play => '事前ダウンロードと再生';

  @override
  String get pre_download_play_description =>
      '音声をストリーミングする代わりに、データをバイト単位でダウンロードして再生 (回線速度が早いユーザーにおすすめ)';

  @override
  String get skip_non_music => '音楽でない部分をスキップ (SponsorBlock)';

  @override
  String get blacklist_description => '曲とアーティストのブラックリスト';

  @override
  String get wait_for_download_to_finish => '現在のダウンロードが完了するまでお待ちください';

  @override
  String get desktop => 'デスクトップ';

  @override
  String get close_behavior => '閉じた時の動作';

  @override
  String get close => '閉じる';

  @override
  String get minimize_to_tray => 'トレイに最小化';

  @override
  String get show_tray_icon => 'システムトレイにアイコンを表示';

  @override
  String get about => 'このアプリについて';

  @override
  String get u_love_spotube => 'DeeMusiq が好きだと知っていますよ';

  @override
  String get check_for_updates => 'アップデートの確認';

  @override
  String get about_spotube => 'DeeMusiq について';

  @override
  String get blacklist => 'ブラックリスト';

  @override
  String get please_sponsor => '出資/寄付もお待ちします';

  @override
  String get spotube_description =>
      'DeeMusiq は、軽量でクロスプラットフォームな、すべて無料の spotify クライアント';

  @override
  String get version => 'バージョン';

  @override
  String get build_number => 'ビルド番号';

  @override
  String get founder => '創始者';

  @override
  String get repository => 'リポジトリ';

  @override
  String get bug_issues => 'バグや問題';

  @override
  String get made_with => '❤️ を込めてバングラディシュ🇧🇩で開発';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'ライセンス';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      '心配ありません。個人情報を収集したり、共有されることはありません';

  @override
  String get know_how_to_login => 'やり方が分からないですか？';

  @override
  String get follow_step_by_step_guide => 'やり方の説明を見る';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Cookies';
  }

  @override
  String get fill_in_all_fields => 'すべての欄に入力してください';

  @override
  String get submit => '送信';

  @override
  String get exit => '終了';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get step_1 => 'ステップ 1';

  @override
  String get first_go_to => '最初にここを開き';

  @override
  String get something_went_wrong => '何か誤りがあります';

  @override
  String get piped_instance => 'Piped サーバーのインスタンス';

  @override
  String get piped_description => '曲の一致に使う Piped サーバーのインスタンス';

  @override
  String get piped_warning => 'それらの一部ではうまく動作しないこともあります。自己責任で使用してください';

  @override
  String get invidious_instance => 'Invidiousサーバーインスタンス';

  @override
  String get invidious_description => '曲の一致に使用するInvidiousサーバーインスタンス';

  @override
  String get invidious_warning => '一部はうまく機能しない可能性があります。自己責任で使用してください';

  @override
  String get generate => '生成';

  @override
  String track_exists(Object track) {
    return '曲 $track は既に存在します';
  }

  @override
  String get replace_downloaded_tracks => 'すべてのダウンロード済みの曲を置換';

  @override
  String get skip_download_tracks => 'すべてのダウンロード済みの曲をスキップ';

  @override
  String get do_you_want_to_replace => '既存の曲と置換しますか？';

  @override
  String get replace => '置換する';

  @override
  String get skip => 'スキップ';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return '$typeを最大$count 個まで選択';
  }

  @override
  String get select_genres => 'ジャンルを選択';

  @override
  String get add_genres => 'ジャンルを追加';

  @override
  String get country => '国';

  @override
  String get number_of_tracks_generate => '生成する曲数';

  @override
  String get acousticness => 'アコースティック感';

  @override
  String get danceability => 'ダンス感';

  @override
  String get energy => 'エネルギー';

  @override
  String get instrumentalness => 'インストゥルメンタル';

  @override
  String get liveness => 'ライブ感';

  @override
  String get loudness => 'ラウドネス';

  @override
  String get speechiness => '会話感';

  @override
  String get valence => '多幸性';

  @override
  String get popularity => '人気度';

  @override
  String get key => 'キー';

  @override
  String get duration => '長さ (秒)';

  @override
  String get tempo => 'テンポ (BPM)';

  @override
  String get mode => '長調';

  @override
  String get time_signature => '拍子記号';

  @override
  String get short => '短';

  @override
  String get medium => '中';

  @override
  String get long => '長';

  @override
  String get min => '最小';

  @override
  String get max => '最大';

  @override
  String get target => '目標';

  @override
  String get moderate => '中';

  @override
  String get deselect_all => 'すべて選択解除';

  @override
  String get select_all => 'すべて選択';

  @override
  String get are_you_sure => 'よろしいですか？';

  @override
  String get generating_playlist => 'カスタムの再生リストを生成中...';

  @override
  String selected_count_tracks(Object count) {
    return '$count 曲が選ばれました';
  }

  @override
  String get download_warning =>
      '全曲の一括ダウンロードは明らかに音楽への海賊行為であり、音楽を生み出す共同体に損害を与えるでしょう。気づいてほしい。アーティストの多大な努力に敬意を払い、支援するようにしてください';

  @override
  String get download_ip_ban_warning =>
      'また、通常よりも過剰なダウンロード要求があれば、YouTubeはあなたのIPをブロックします。つまりそのIPの端末からは、少なくとも2-3か月の間、（ログインしても）YouTubeを利用できなくなりす。そうなっても DeeMusiq は一切の責任を負いません';

  @override
  String get by_clicking_accept_terms => '「同意する」のクリックにより、以下への同意となります:';

  @override
  String get download_agreement_1 => 'ええ、音楽への海賊行為だ。私はよくない';

  @override
  String get download_agreement_2 => '芸術作品を買うお金がないのでそうするしかないが、アーティストをできる限り支援する';

  @override
  String get download_agreement_3 =>
      '私のIPがYouTubeにブロックされることがあると完全に把握した。私のこの行動により起きたどんな事故も、DeeMusiq やその所有者/貢献者に責任はありません。';

  @override
  String get decline => '同意しない';

  @override
  String get accept => '同意する';

  @override
  String get details => '詳細';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'チャンネル';

  @override
  String get likes => '高評価';

  @override
  String get dislikes => '低評価';

  @override
  String get views => '視聴回数';

  @override
  String get streamUrl => '動画の URL';

  @override
  String get stop => '中止';

  @override
  String get sort_newest => '追加日の新しい順に並び替え';

  @override
  String get sort_oldest => '追加日の古い順に並び替え';

  @override
  String get sleep_timer => 'スリープタイマー';

  @override
  String mins(Object minutes) {
    return '$minutes 分';
  }

  @override
  String hours(Object hours) {
    return '$hours 時間';
  }

  @override
  String hour(Object hours) {
    return '$hours 時間';
  }

  @override
  String get custom_hours => '時間を指定';

  @override
  String get logs => 'ログ';

  @override
  String get developers => '開発';

  @override
  String get not_logged_in => 'ログインしていません';

  @override
  String get search_mode => '検索モード';

  @override
  String get audio_source => '音声の提供元';

  @override
  String get ok => 'OK';

  @override
  String get failed_to_encrypt => '暗号化に失敗しました';

  @override
  String get encryption_failed_warning =>
      'SpoTubeはデータを安全に保存するために暗号化を用いますが、暗号化に失敗しました。このため、安全でない保存領域への保存に切り替えます\nOSがLinuxなら、gnome-keyring、kde-wallet、keepassxcなどの管理ツールがインストールされていることを確認してください';

  @override
  String get querying_info => '情報を取得中...';

  @override
  String get piped_api_down => 'Piped APIがダウンしています';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Pipedインスタンス $pipedInstance は現在ダウンしています\n\nインスタンスを変更するか、「APIの種類」を公式のYouTube APIに変更してください\n\n変更後にアプリを再起動してください';
  }

  @override
  String get you_are_offline => '現在、オフラインです';

  @override
  String get connection_restored => 'インターネット接続が復旧しました';

  @override
  String get use_system_title_bar => 'システムのタイトルバーを使う';

  @override
  String get crunching_results => '結果を処理中...';

  @override
  String get search_to_get_results => '結果を取得するために検索';

  @override
  String get use_amoled_mode => 'AMOLEDモードを使用';

  @override
  String get pitch_dark_theme => 'ピッチブラック ダークテーマ';

  @override
  String get normalize_audio => '音声を正規化';

  @override
  String get change_cover => 'カバーを変更';

  @override
  String get add_cover => 'カバーを追加';

  @override
  String get restore_defaults => '設定を初期化';

  @override
  String get download_music_format => '音楽ダウンロード形式';

  @override
  String get streaming_music_format => '音楽ストリーミング形式';

  @override
  String get download_music_quality => '音楽ダウンロード品質';

  @override
  String get streaming_music_quality => '音楽ストリーミング品質';

  @override
  String get login_with_lastfm => 'Last.fmでログイン';

  @override
  String get connect => '接続';

  @override
  String get disconnect_lastfm => 'Last.fmから切断';

  @override
  String get disconnect => '切断';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get login => 'ログイン';

  @override
  String get login_with_your_lastfm => 'Last.fmアカウントでログイン';

  @override
  String get scrobble_to_lastfm => 'Last.fmにスクロブルする';

  @override
  String get go_to_album => 'アルバムに移動';

  @override
  String get discord_rich_presence => 'Discord リッチプレゼンス';

  @override
  String get browse_all => 'すべてを閲覧';

  @override
  String get genres => 'ジャンル';

  @override
  String get explore_genres => 'ジャンルを探索';

  @override
  String get friends => '友達';

  @override
  String get no_lyrics_available => 'すみません、この曲の歌詞が見つかりません';

  @override
  String get start_a_radio => 'ラジオを開始';

  @override
  String get how_to_start_radio => 'ラジオをどのように開始しますか？';

  @override
  String get replace_queue_question => '現在のキューを置き換えるか、追加しますか？';

  @override
  String get endless_playback => 'エンドレス再生';

  @override
  String get delete_playlist => '再生リストを削除';

  @override
  String get delete_playlist_confirmation => 'この再生リストを削除しますか？';

  @override
  String get local_tracks => '端末内の曲';

  @override
  String get local_tab => '端末内';

  @override
  String get song_link => '曲のリンク';

  @override
  String get youtube_source_description => '推奨され、最適に機能します。';

  @override
  String get piped_source_description => '自由を感じる？YouTubeと同じだけど、はるかに自由です。';

  @override
  String get jiosaavn_source_description => '南アジア地域では最適です。';

  @override
  String get invidious_source_description => 'Pipedに似ていますが、より利用性があります。';

  @override
  String highest_quality(Object quality) {
    return '最高品質：$quality';
  }

  @override
  String get select_audio_source => '音声の提供元を選択';

  @override
  String get contribute_on_github => 'GitHubで貢献';

  @override
  String get browse_anonymously => '匿名で閲覧する';

  @override
  String get enable_connect => '接続する';

  @override
  String get enable_connect_description => '他の端末からDeeMusiqを制御する';

  @override
  String get devices => '機器';

  @override
  String get select => '選択';

  @override
  String connect_client_alert(Object client) {
    return '$client から操作されています';
  }

  @override
  String get this_device => 'この端末';

  @override
  String get remote => 'リモート';

  @override
  String get stats => '統計';

  @override
  String and_n_more(Object count) {
    return 'さらに $count 項目';
  }

  @override
  String get recently_played => '最近聴いた曲';

  @override
  String get browse_more => 'もっと表示';

  @override
  String get no_title => 'タイトルなし';

  @override
  String get not_playing => '再生なし';

  @override
  String get epic_failure => '壮大なエラー！';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length 曲をキューに追加しました';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq の最新版あり';

  @override
  String get download_now => '今すぐダウンロード';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum がリリースされました';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version がリリースされました';
  }

  @override
  String get read_the_latest => '最新の ';

  @override
  String get release_notes => '更新情報を読む';

  @override
  String get pick_color_scheme => 'カラーテーマを選択';

  @override
  String get save => '保存';

  @override
  String get choose_the_device => '端末を選択：';

  @override
  String get multiple_device_connected => '複数の端末が接続されています。\nこの操作を実行する端末を選択';

  @override
  String get nothing_found => '何も見つかりませんでした';

  @override
  String get the_box_is_empty => 'ボックスは空です';

  @override
  String get top_artists => 'トップアーティスト';

  @override
  String get top_albums => 'トップアルバム';

  @override
  String get this_week => '今週';

  @override
  String get this_month => '今月';

  @override
  String get last_6_months => '過去6か月';

  @override
  String get this_year => '今年';

  @override
  String get last_2_years => '過去2年間';

  @override
  String get all_time => '全期間';

  @override
  String powered_by_provider(Object providerName) {
    return '$providerName 提供';
  }

  @override
  String get email => 'メール';

  @override
  String get profile_followers => 'フォロワー';

  @override
  String get birthday => '誕生日';

  @override
  String get subscription => '登録';

  @override
  String get not_born => '未出生';

  @override
  String get hacker => 'ハッカー';

  @override
  String get profile => 'プロフィール';

  @override
  String get no_name => '名前なし';

  @override
  String get edit => '編集';

  @override
  String get user_profile => 'ユーザープロフィール';

  @override
  String count_plays(Object count) {
    return '$count 回再生';
  }

  @override
  String get minutes_listened => '視聴時間';

  @override
  String get streamed_songs => 'ストリーミングされた曲';

  @override
  String count_streams(Object count) {
    return '$count 回のストリーム';
  }

  @override
  String get owned_by_you => 'あなたが所有';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl をクリップボードにコピーしました';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes 分';
  }

  @override
  String get summary_minutes => '分';

  @override
  String get summary_listened_to_music => '音楽を聴いた';

  @override
  String get summary_songs => '曲';

  @override
  String get summary_streamed_overall => 'まるごと聴いた';

  @override
  String get summary_artists => 'アーティスト';

  @override
  String get summary_music_reached_you => 'の音楽が届いた';

  @override
  String get summary_full_albums => 'フルアルバム';

  @override
  String get summary_got_your_love => 'があなたの愛を受け取った';

  @override
  String get summary_playlists => '再生リスト';

  @override
  String get summary_were_on_repeat => 'をリピートしました';

  @override
  String get webview_not_found => 'Webviewが見つかりません';

  @override
  String get webview_not_found_description =>
      '端末にWebviewランタイムがインストールされていません。\nインストールされている場合は、環境変数のパスにあるか確認してください\n\nインストール後、アプリを再起動してください';

  @override
  String get unsupported_platform => '未対応のプラットフォーム';

  @override
  String get cache_music => '音楽をキャッシュ';

  @override
  String get open => '開く';

  @override
  String get cache_folder => 'キャッシュフォルダー';

  @override
  String get export => 'エクスポート';

  @override
  String get clear_cache => 'キャッシュをクリア';

  @override
  String get clear_cache_confirmation => 'キャッシュをクリアしますか？';

  @override
  String get export_cache_files => 'キャッシュされたファイルをエクスポート';

  @override
  String found_n_files(Object count) {
    return '$countファイルが見つかりました';
  }

  @override
  String get export_cache_confirmation => 'これらのファイルをエクスポートしますか';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported / $filesファイルがエクスポートされました';
  }

  @override
  String get undo => '元に戻す';

  @override
  String get download_all => 'すべてダウンロード';

  @override
  String get add_all_to_playlist => 'すべて再生リストに追加';

  @override
  String get add_all_to_queue => 'すべてキューに追加';

  @override
  String get play_all_next => 'すべてを次に再生';

  @override
  String get pause => '一時停止';

  @override
  String get view_all => 'すべて表示';

  @override
  String get no_tracks_added_yet => 'まだ曲を追加していないようです';

  @override
  String get no_tracks => 'ここには曲がないようです';

  @override
  String get no_tracks_listened_yet => 'まだ何も聞いていないようです';

  @override
  String get not_following_artists => 'アーティストをフォローしていません';

  @override
  String get no_favorite_albums_yet => 'まだお気に入りのアルバムを追加していないようです';

  @override
  String get no_logs_found => 'ログなし';

  @override
  String get youtube_engine => 'YouTubeエンジン';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engineはインストールされていません';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engineはシステムにインストールされていません。';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'PATH変数に設定されていることを確認するか\n$engine実行ファイルの絶対パスを下記に設定してください';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/Unix系OSでは、.zshrc/.bashrc/.bash_profileなどでパスを設定しても動作しません。\nシェルの設定ファイルにパスを設定する必要があります';

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
  String get download => 'ダウンロード';

  @override
  String get file_not_found => 'ファイルが見つかりません';

  @override
  String get custom => '独自';

  @override
  String get add_custom_url => '独自にURLを追加';

  @override
  String get edit_port => 'ポートを編集';

  @override
  String get port_helper_msg =>
      '初期設定は-1で、ランダムな番号を示します。ファイアウォールを設定している場合に設定することを推奨します。';

  @override
  String connect_request(Object client) {
    return '$clientの接続を許可しますか？';
  }

  @override
  String get connection_request_denied => '接続が拒否されました。ユーザーがアクセスを拒否しました。';

  @override
  String get an_error_occurred => 'エラーが発生しました';

  @override
  String get copy_to_clipboard => 'クリップボードにコピー';

  @override
  String get view_logs => 'ログを表示';

  @override
  String get retry => '再試行';

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
      'デフォルトのメタデータプロバイダーが設定されていません';

  @override
  String get manage_metadata_providers => 'メタデータプロバイダーを管理';

  @override
  String get open_link_in_browser => 'リンクをブラウザで開きますか？';

  @override
  String get do_you_want_to_open_the_following_link => '次のリンクを開きますか';

  @override
  String get unsafe_url_warning =>
      '信頼できないソースからのリンクを開くのは安全ではない場合があります。注意してください！\nリンクをクリップボードにコピーすることもできます。';

  @override
  String get copy_link => 'リンクをコピー';

  @override
  String get building_your_timeline => 'あなたの視聴履歴に基づいてタイムラインを作成しています...';

  @override
  String get official => '公式';

  @override
  String author_name(Object author) {
    return '作者: $author';
  }

  @override
  String get third_party => 'サードパーティ';

  @override
  String get plugin_requires_authentication => 'プラグインには認証が必要です';

  @override
  String get update_available => 'アップデートが利用可能です';

  @override
  String get supports_scrobbling => 'scrobblingに対応';

  @override
  String get plugin_scrobbling_info => 'このプラグインは、あなたの音楽をscrobbleして視聴履歴を生成します。';

  @override
  String get default_metadata_source => 'デフォルトメタデータソース';

  @override
  String get set_default_metadata_source => 'デフォルトメタデータソースを設定';

  @override
  String get default_audio_source => 'デフォルトオーディオソース';

  @override
  String get set_default_audio_source => 'デフォルトオーディオソースを設定';

  @override
  String get set_default => 'デフォルトに設定';

  @override
  String get support => 'サポート';

  @override
  String get support_plugin_development => 'プラグイン開発をサポート';

  @override
  String can_access_name_api(Object name) {
    return '- **$name** APIにアクセスできます';
  }

  @override
  String get do_you_want_to_install_this_plugin => 'このプラグインをインストールしますか？';

  @override
  String get third_party_plugin_warning =>
      'このプラグインはサードパーティのリポジトリからのものです。インストールする前にソースを信頼できるか確認してください。';

  @override
  String get author => '作者';

  @override
  String get this_plugin_can_do_following => 'このプラグインは以下のことができます';

  @override
  String get install => 'インストール';

  @override
  String get no_tracks_playing => '現在再生中のトラックはありません';

  @override
  String get synced_lyrics_not_available => 'この曲の同期歌詞は利用できません。代わりに';

  @override
  String get plain_lyrics => 'シンプルな歌詞';

  @override
  String get tab_instead => 'タブを使用してください。';

  @override
  String get disclaimer => '免責事項';

  @override
  String get third_party_plugin_dmca_notice =>
      'DeeMusiqチームは、いかなる「サードパーティ」プラグインについても責任（法的責任を含む）を負いません。\nご自身の責任でご使用ください。バグや問題については、プラグインリポジトリに報告してください。\n\n「サードパーティ」プラグインが何らかのサービス/法人のToS/DMCAを侵害している場合、その「サードパーティ」プラグインの作者またはホスティングプラットフォーム（例：GitHub/Codeberg）に措置を講じるよう依頼してください。上記に記載されている（「サードパーティ」とラベル付けされた）ものはすべて、パブリック/コミュニティによって維持されているプラグインです。私たちはそれらをキュレーションしていないため、それらに対して措置を講じることはできません。\n\n';

  @override
  String get plugins => 'プラグイン';

  @override
  String get paste_plugin_download_url =>
      'ダウンロードURL、GitHub/CodebergリポジトリURL、または.smplugファイルへの直接リンクを貼り付けます';

  @override
  String get download_and_install_plugin_from_url =>
      'URLからプラグインをダウンロードしてインストール';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'プラグインの追加に失敗しました: $error';
  }

  @override
  String get upload_plugin_from_file => 'ファイルからプラグインをアップロード';

  @override
  String get installed => 'インストール済み';

  @override
  String get available_plugins => '利用可能なプラグイン';

  @override
  String get configure_plugins => '独自のメタデータプロバイダーとオーディオソースプラグインを設定';

  @override
  String get audio_scrobblers => 'オーディオスクロッブラー';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'ソース: ';

  @override
  String get uncompressed => '非圧縮';

  @override
  String get dab_music_source_description =>
      'オーディオファイル向け。高品質/ロスレスオーディオストリームを提供。正確なISRCベースのトラックマッチング。';

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
  String get skip_this_nonsense => 'こんなことはスキップ';

  @override
  String get freedom_of_music => '“音楽の自由”';

  @override
  String get freedom_of_music_palm => '“音楽の自由を思いのままに”';

  @override
  String get get_started => 'さあ始めましょう';

  @override
  String get endless_playback_description => 'キューの最後に新しい曲を自動で追加';

  @override
  String get choose_your_region => '地域を選択';

  @override
  String get choose_your_region_description =>
      'DeeMusiqがあなたの地域に適したコンテンツを表示します。';

  @override
  String get choose_your_language => '言語を選択してください';

  @override
  String get help_project_grow => 'プロジェクトの成長を支援する';

  @override
  String get help_project_grow_description =>
      'SpoTubeはオープンソースプロジェクトです。貢献したり、バグ報告したり、新機能を提案することで、プロジェクトの成長に貢献できます。';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Open Collectiveで寄付';

  @override
  String get install_a_metadata_provider => 'メタデータプロバイダーをインストール';

  @override
  String get input_does_not_match_format => '入力が必須フォーマットと一致しません';

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
  String get auth_mfa_required => '認証コードを入力';

  @override
  String get auth_mfa_body => '認証アプリを開いて6桁のコードを入力し、サインインを完了してください。';

  @override
  String get auth_mfa_verify_action => '確認';

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
