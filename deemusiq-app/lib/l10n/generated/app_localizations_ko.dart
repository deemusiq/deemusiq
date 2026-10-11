// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get guest => '게스트';

  @override
  String get browse => '찾아보기';

  @override
  String get search => '검색';

  @override
  String get library => '라이브러리';

  @override
  String get lyrics => '가사';

  @override
  String get settings => '설정';

  @override
  String get genre_categories_filter => '카테고리 혹은 장르별로 불러오기';

  @override
  String get genre => '장르';

  @override
  String get personalized => '맞춤 추천';

  @override
  String get featured => '인기';

  @override
  String get new_releases => '신곡';

  @override
  String get songs => '노래';

  @override
  String playing_track(Object track) {
    return '$track 을 재생';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return '현재 재생 대기열을 없앱니다。$track_length 곡이 제거됩니다。\n계속 진행할까요？';
  }

  @override
  String get load_more => '더 불러오기';

  @override
  String get playlists => '플레이리스트';

  @override
  String get artists => '아티스트';

  @override
  String get albums => '앨범';

  @override
  String get tracks => '곡';

  @override
  String get downloads => '다운로드한 곡';

  @override
  String get filter_playlists => '플레이리스트를 필터링';

  @override
  String get liked_tracks => '좋아하는 곡';

  @override
  String get liked_tracks_description => '좋아요를 남긴 곡들';

  @override
  String get playlist => '재생 목록';

  @override
  String get create_a_playlist => '플레이리스트를 생성';

  @override
  String get update_playlist => '플레이리스트를 업데이트';

  @override
  String get create => '생성';

  @override
  String get cancel => '취소';

  @override
  String get update => '업데이트';

  @override
  String get playlist_name => '플레이리스트명';

  @override
  String get name_of_playlist => '플레이리스트의 이름';

  @override
  String get description => '설명';

  @override
  String get public => '공개';

  @override
  String get collaborative => '공유 플레이리스트';

  @override
  String get search_local_tracks => '기기에 저장된 곡을 검색하기';

  @override
  String get play => '재생';

  @override
  String get delete => '삭제';

  @override
  String get none => '없음';

  @override
  String get sort_a_z => 'A-Z 순으로 정렬';

  @override
  String get sort_z_a => 'Z-A 순으로 정렬';

  @override
  String get sort_artist => '아티스트 순으로 정렬';

  @override
  String get sort_album => '앨범 순으로 정렬';

  @override
  String get sort_duration => '시간순 정렬';

  @override
  String get sort_tracks => '곡명 순으로 정렬';

  @override
  String currently_downloading(Object tracks_length) {
    return '현재 ($tracks_length) 곡 다운로드 중';
  }

  @override
  String get cancel_all => '모두 취소';

  @override
  String get filter_artist => '아티스트 필터링';

  @override
  String followers(Object followers) {
    return '$followers 팔로워';
  }

  @override
  String get add_artist_to_blacklist => '이 아티스트를 블랙리스트에 추가';

  @override
  String get top_tracks => '인기곡';

  @override
  String get fans_also_like => '애청자들이 좋아하는 곡';

  @override
  String get loading => '불러오는 중...';

  @override
  String get artist => '아티스트';

  @override
  String get blacklisted => '블랙리스트';

  @override
  String get following => '팔로우 중';

  @override
  String get follow => '팔로우하기';

  @override
  String get artist_url_copied => '아티스트의 URL 주소를 클립보드에 복사함';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks 곡을 대기열에 추가함';
  }

  @override
  String get filter_albums => '앨범 필터링';

  @override
  String get synced => '동기화됨';

  @override
  String get plain => '그대로';

  @override
  String get shuffle => '셔플';

  @override
  String get search_tracks => '곡 검색하기';

  @override
  String get released => '공개일';

  @override
  String error(Object error) {
    return '에러';
  }

  @override
  String get title => '타이틀';

  @override
  String get time => '길이';

  @override
  String get more_actions => '다른 작업';

  @override
  String download_count(Object count) {
    return '($count) 곡 다운로드';
  }

  @override
  String add_count_to_playlist(Object count) {
    return '플레이리스트에 ($count) 곡을 추가';
  }

  @override
  String add_count_to_queue(Object count) {
    return '대기열에 ($count) 곡을 추가';
  }

  @override
  String play_count_next(Object count) {
    return '이 다음에 ($count) 곡을 재생';
  }

  @override
  String get album => '앨범';

  @override
  String copied_to_clipboard(Object data) {
    return '$data 를 클립보드에 복사함';
  }

  @override
  String add_to_following_playlists(Object track) {
    return '$track 을 이 플레이리스트에 추가';
  }

  @override
  String get add => '추가';

  @override
  String added_track_to_queue(Object track) {
    return '대기열에 $track 을 추가함';
  }

  @override
  String get add_to_queue => '대기열에 추가';

  @override
  String track_will_play_next(Object track) {
    return '$track 을 이 다음에 재생';
  }

  @override
  String get play_next => '이 다음에 재생';

  @override
  String removed_track_from_queue(Object track) {
    return '대기열에서 $track 를 제거함';
  }

  @override
  String get remove_from_queue => '대기열에서 제거';

  @override
  String get remove_from_favorites => '즐겨찾기에서 제거';

  @override
  String get save_as_favorite => '즐겨찾기에 추가';

  @override
  String get add_to_playlist => '플레이리스트에 추가';

  @override
  String get remove_from_playlist => '플레이리스트에서 제거';

  @override
  String get add_to_blacklist => '블랙리스트에 추가';

  @override
  String get remove_from_blacklist => '블랙리스트에서 제거';

  @override
  String get share => '공유';

  @override
  String get mini_player => '미니 플레이어';

  @override
  String get slide_to_seek => '앞뒤로 슬라이드하여 탐색';

  @override
  String get shuffle_playlist => '플레이리스트를 섞기';

  @override
  String get unshuffle_playlist => '플레이리스트를 섞지 않기';

  @override
  String get previous_track => '이전 곡';

  @override
  String get next_track => '다음 곡';

  @override
  String get pause_playback => '일시정지';

  @override
  String get resume_playback => '재개';

  @override
  String get loop_track => '반복 재생';

  @override
  String get no_loop => '반복 없음';

  @override
  String get repeat_playlist => '플레이리스트 반복';

  @override
  String get queue => '재생 대기열';

  @override
  String get alternative_track_sources => '대체가능한 음악 서버';

  @override
  String get download_track => '곡 다운로드';

  @override
  String tracks_in_queue(Object tracks) {
    return '대기열에 $tracks 곡이 있음';
  }

  @override
  String get clear_all => '모두 제거';

  @override
  String get show_hide_ui_on_hover => '마우스를 올리면 UI를 표시/숨김';

  @override
  String get always_on_top => '항상 위에 표시';

  @override
  String get exit_mini_player => '미니 플레이어 닫기';

  @override
  String get download_location => '다운로드 경로';

  @override
  String get local_library => '로컬 도서관';

  @override
  String get add_library_location => '도서관에 추가';

  @override
  String get remove_library_location => '도서관에서 제거';

  @override
  String get account => '계정';

  @override
  String get logout => '로그아웃';

  @override
  String get logout_of_this_account => '이 계정에서 로그아웃';

  @override
  String get language_region => '언어 & 지역';

  @override
  String get language => '언어';

  @override
  String get system_default => '시스템 기본설정';

  @override
  String get market_place_region => '마켓플레이스 지역';

  @override
  String get recommendation_country => '추천 국가';

  @override
  String get appearance => '디자인';

  @override
  String get layout_mode => '레이아웃 모드';

  @override
  String get override_layout_settings => '반응형 레이아웃 모드 설정 덮어씌우기';

  @override
  String get adaptive => '적응형';

  @override
  String get compact => '컴팩트';

  @override
  String get extended => '확장';

  @override
  String get theme => '테마';

  @override
  String get dark => '다크';

  @override
  String get light => '라이트';

  @override
  String get system => '시스템과 동일';

  @override
  String get accent_color => '보조색';

  @override
  String get sync_album_color => '앨범 색상';

  @override
  String get sync_album_color_description => '앨범아트의 주요 색상을 보조색으로 사용';

  @override
  String get playback => '재생';

  @override
  String get audio_quality => '음질';

  @override
  String get high => '높음';

  @override
  String get low => '낮음';

  @override
  String get pre_download_play => '재생할 곡을 미리 다운로드';

  @override
  String get pre_download_play_description =>
      '스트리밍 방식을 쓰는 대신 파일 단위로 다운로드 받고 재생 (인터넷 대역폭이 높은 환경에서 추천)';

  @override
  String get skip_non_music => '음악이 아닌 부분을 스킵 (SponsorBlock)';

  @override
  String get blacklist_description => '블랙리스트에 추가된 곡과 아티스트';

  @override
  String get wait_for_download_to_finish => '현재 진행중인 다운로드가 끝날 때까지 기다려주세요';

  @override
  String get desktop => '데스크톱';

  @override
  String get close_behavior => '닫을 때의 동작';

  @override
  String get close => '닫기';

  @override
  String get minimize_to_tray => '트레이로 최소화';

  @override
  String get show_tray_icon => '시스템 트레이 아이콘 표시';

  @override
  String get about => '앱 정보';

  @override
  String get u_love_spotube => 'DeeMusiq... 사랑하시죠?';

  @override
  String get check_for_updates => '업데이트 확인';

  @override
  String get about_spotube => 'DeeMusiq에 관해';

  @override
  String get blacklist => '블랙리스트';

  @override
  String get please_sponsor => '후원해주시면 감사하겠습니다.';

  @override
  String get spotube_description =>
      'DeeMusiq는, 경량에 크로스플랫폼인데다 무료이기까지한 스포티파이 클라이언트입니다';

  @override
  String get version => '버전';

  @override
  String get build_number => '빌드 번호';

  @override
  String get founder => '창시자';

  @override
  String get repository => '리포지토리';

  @override
  String get bug_issues => '버그 및 이슈';

  @override
  String get made_with => '❤️을 담아 방글라데시에서 만듦';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => '라이선스';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      '걱정마세요. 개인정보를 수집하거나 공유하지 않습니다.';

  @override
  String get know_how_to_login => '어떻게 하는건지 모르겠나요?';

  @override
  String get follow_step_by_step_guide => '사용법 확인하기';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Cookies';
  }

  @override
  String get fill_in_all_fields => '모든 필드에 정보를 입력해주세요';

  @override
  String get submit => '제출';

  @override
  String get exit => '종료';

  @override
  String get previous => '이전으로';

  @override
  String get next => '다음으로';

  @override
  String get done => '완료';

  @override
  String get step_1 => '1단계';

  @override
  String get first_go_to => '가장 먼저 먼저 들어갈 곳은 ';

  @override
  String get something_went_wrong => '알 수 없는 이유로 동작에 실패했습니다.';

  @override
  String get piped_instance => 'Piped 서버의 인스턴스';

  @override
  String get piped_description => '곡 탐색에 사용할 Piped 서버 인스턴스';

  @override
  String get piped_warning => '몇몇 서버는 제대로 동작하지 않을 수 있습니다. 본인 책임 하에 이용해주세요.';

  @override
  String get invidious_instance => 'Invidious 서버 인스턴스';

  @override
  String get invidious_description => '트랙 매칭에 사용할 Invidious 서버 인스턴스';

  @override
  String get invidious_warning => '일부는 제대로 작동하지 않을 수 있습니다. 자신의 책임 하에 사용하세요';

  @override
  String get generate => '생성';

  @override
  String track_exists(Object track) {
    return '곡 $track 은 이미 리스트에 있습니다';
  }

  @override
  String get replace_downloaded_tracks => '다운로드한 모든 곡을 교체';

  @override
  String get skip_download_tracks => '다운로드가 끝난 곡을 모두 건너뛰기';

  @override
  String get do_you_want_to_replace => '현재 곡을 교체하시겠습니까?';

  @override
  String get replace => '교체';

  @override
  String get skip => '건너뛰기';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return '$type을 $count개까지 선택';
  }

  @override
  String get select_genres => '장르 선택';

  @override
  String get add_genres => '장르 추가';

  @override
  String get country => '국가';

  @override
  String get number_of_tracks_generate => '생성할 곡 수';

  @override
  String get acousticness => '반주 구간 (Acousticness)';

  @override
  String get danceability => '흥겨운 정도 (Danceability)';

  @override
  String get energy => '에너지 (Energy)';

  @override
  String get instrumentalness => '기악성 (Instrumentalness)';

  @override
  String get liveness => '생동감 (Liveness)';

  @override
  String get loudness => '라우드니스 (Loudness)';

  @override
  String get speechiness => '회화성 (Speechniss)';

  @override
  String get valence => '감정가 (Valence)';

  @override
  String get popularity => '인기도 (Popularity)';

  @override
  String get key => '조성 (키)';

  @override
  String get duration => '길이 (초)';

  @override
  String get tempo => '템포 (BPM)';

  @override
  String get mode => '장조';

  @override
  String get time_signature => '박자';

  @override
  String get short => '짧음';

  @override
  String get medium => '중간';

  @override
  String get long => '긺';

  @override
  String get min => '최소';

  @override
  String get max => '최대';

  @override
  String get target => '목표';

  @override
  String get moderate => '보통';

  @override
  String get deselect_all => '모두 선택해제';

  @override
  String get select_all => '모두 선택';

  @override
  String get are_you_sure => '괜찮겠습니까?';

  @override
  String get generating_playlist => '커스텀 플레이리스트를 생성하는 중...';

  @override
  String selected_count_tracks(Object count) {
    return '$count 곡이 선택되었습니다.';
  }

  @override
  String get download_warning =>
      '모든 트랙을 대량으로 다운로드하는 것은 명백한 불법 복제이며 음악 창작 사회에 피해를 입히는 행위입니다. 이 점을 알아주셨으면 합니다. 항상 아티스트의 노력을 존중하고 응원해 주세요.';

  @override
  String get download_ip_ban_warning =>
      '참고로, 평소보다 과도한 다운로드 요청으로 인해 YouTube에서 IP가 차단될 수 있습니다. IP 차단은 해당 IP 기기에서 최소 2~3개월 동안 (로그인한 상태에서도) YouTube를 사용할 수 없음을 의미합니다. 그리고 이런 일이 발생하더라도 스포튜브는 어떠한 책임도 지지 않습니다.';

  @override
  String get by_clicking_accept_terms => '\'동의\'를 클릭하면 다음 약관에 동의하는 것입니다:';

  @override
  String get download_agreement_1 => '알고 있습니다. 전 나쁜 사람입니다.';

  @override
  String get download_agreement_2 =>
      '제가 할 수 있는 모든 곳에서 아티스트를 지원할 것이며, 저는 그들의 작품을 살 돈이 없기 때문에 이렇게 하는 것뿐입니다.';

  @override
  String get download_agreement_3 =>
      '본인은 YouTube에서 내 IP가 차단될 수 있음을 완전히 알고 있으며, 현재 내 행동으로 인해 발생하는 사고에 대해 DeeMusiq 또는 그 소유자/기여자에게 책임을 묻지 않습니다.';

  @override
  String get decline => '거절';

  @override
  String get accept => '동의';

  @override
  String get details => '상세';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => '채널';

  @override
  String get likes => '좋아요';

  @override
  String get dislikes => '싫어요';

  @override
  String get views => '조회수';

  @override
  String get streamUrl => '스트림 URL';

  @override
  String get stop => '중지';

  @override
  String get sort_newest => '최근에 추가된 순으로 정렬';

  @override
  String get sort_oldest => '예전에 추가된 순으로 정렬';

  @override
  String get sleep_timer => '취침 타이머';

  @override
  String mins(Object minutes) {
    return '$minutes 분';
  }

  @override
  String hours(Object hours) {
    return '$hours 시간';
  }

  @override
  String hour(Object hours) {
    return '$hours 시간';
  }

  @override
  String get custom_hours => '시간 설정';

  @override
  String get logs => '로그';

  @override
  String get developers => '개발';

  @override
  String get not_logged_in => '로그인하지 않았습니다';

  @override
  String get search_mode => '검색 모드';

  @override
  String get audio_source => '오디오 출처';

  @override
  String get ok => '알겠습니다';

  @override
  String get failed_to_encrypt => '암호화에 실패했습니다';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq는 암호화를 사용하여 데이터를 안전하게 저장합니다. 하지만 그렇게 하지 못했습니다. 따라서 안전하지 않은 저장소로 대체됩니다.\n리눅스를 사용하는 경우, 비밀 서비스(gnome-keyring, kde-wallet, keepassxc 등)가 설치되어 있는지 확인하세요.';

  @override
  String get querying_info => '정보를 얻는 중...';

  @override
  String get piped_api_down => 'Piped API가 응답하지 않습니다';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Piped 인스턴스 $pipedInstance가 현재 다운되었습니다.\n\n인스턴스를 변경하거나 \'API 유형\'을 공식 YouTube API로 변경하세요.\n\n변경 후 앱을 다시 시작해야 합니다.';
  }

  @override
  String get you_are_offline => '현재 오프라인입니다';

  @override
  String get connection_restored => '인터넷에 다시 연결되었습니다';

  @override
  String get use_system_title_bar => '시스템 타이틀바를 사용';

  @override
  String get crunching_results => '결과를 처리하는 중...';

  @override
  String get search_to_get_results => '결과를 얻으려면 검색해주세요';

  @override
  String get use_amoled_mode => 'AMOLED모드를 사용';

  @override
  String get pitch_dark_theme => '검정색 기반의 어두운 테마';

  @override
  String get normalize_audio => '오디오 노멀라이즈';

  @override
  String get change_cover => '커버 변경';

  @override
  String get add_cover => '커버 추가';

  @override
  String get restore_defaults => '기본값으로 복원';

  @override
  String get download_music_format => '다운로드 음악 포맷';

  @override
  String get streaming_music_format => '스트리밍 음악 포맷';

  @override
  String get download_music_quality => '다운로드 음질';

  @override
  String get streaming_music_quality => '스트리밍 음질';

  @override
  String get login_with_lastfm => 'Last.fm에 로그인';

  @override
  String get connect => '연결';

  @override
  String get disconnect_lastfm => 'Last.fm에서 연결 해제';

  @override
  String get disconnect => '연결 해제';

  @override
  String get username => '사용자명';

  @override
  String get password => '비밀번호';

  @override
  String get login => '로그인';

  @override
  String get login_with_your_lastfm => '내 Last.fm 계정으로로그인';

  @override
  String get scrobble_to_lastfm => 'Scrobble to Last.fm';

  @override
  String get go_to_album => '앨범으로 이동';

  @override
  String get discord_rich_presence => 'Discord Rich Presence';

  @override
  String get browse_all => '모두 탐색';

  @override
  String get genres => '장르';

  @override
  String get explore_genres => '장르 탐색';

  @override
  String get friends => '친구';

  @override
  String get no_lyrics_available => '죄송하지만 이 곡의 가사를 찾지 못했습니다';

  @override
  String get start_a_radio => '라디오 시작';

  @override
  String get how_to_start_radio => '라디오를 어떻게 시작하시겠습니까?';

  @override
  String get replace_queue_question => '현재 큐를 대체하시겠습니까 아니면 추가하시겠습니까?';

  @override
  String get endless_playback => '끝없는 재생';

  @override
  String get delete_playlist => '재생 목록 삭제';

  @override
  String get delete_playlist_confirmation => '이 재생 목록을 삭제하시겠습니까?';

  @override
  String get local_tracks => '로컬 트랙';

  @override
  String get local_tab => '로컬';

  @override
  String get song_link => '곡 링크';

  @override
  String get youtube_source_description => '추천되며 가장 잘 작동합니다.';

  @override
  String get piped_source_description =>
      '자유로운 기분이 듭니까? YouTube와 같지만 훨씬 더 무료합니다.';

  @override
  String get jiosaavn_source_description => '남아시아 지역에 최적입니다.';

  @override
  String get invidious_source_description => 'Piped와 비슷하지만 가용성이 높습니다.';

  @override
  String highest_quality(Object quality) {
    return '최고 품질: $quality';
  }

  @override
  String get select_audio_source => '오디오 소스 선택';

  @override
  String get contribute_on_github => 'GitHub에서 기여하기';

  @override
  String get browse_anonymously => '익명으로 둘러보기';

  @override
  String get enable_connect => '연결 활성화';

  @override
  String get enable_connect_description => '다른 장치에서 DeeMusiq 제어';

  @override
  String get devices => '장치';

  @override
  String get select => '선택';

  @override
  String connect_client_alert(Object client) {
    return '$client님에 의해 제어되고 있습니다';
  }

  @override
  String get this_device => '이 장치';

  @override
  String get remote => '원격';

  @override
  String get stats => '통계';

  @override
  String and_n_more(Object count) {
    return '그리고 $count개 더';
  }

  @override
  String get recently_played => '최근 재생';

  @override
  String get browse_more => '더 보기';

  @override
  String get no_title => '제목 없음';

  @override
  String get not_playing => '재생 중이 아님';

  @override
  String get epic_failure => '서사적 실패!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length 곡을 대기열에 추가했습니다';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq에 업데이트가 있습니다';

  @override
  String get download_now => '지금 다운로드';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum이 출시되었습니다';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version이 출시되었습니다';
  }

  @override
  String get read_the_latest => '최신 ';

  @override
  String get release_notes => '릴리스 노트';

  @override
  String get pick_color_scheme => '색상 테마 선택';

  @override
  String get save => '저장';

  @override
  String get choose_the_device => '디바이스 선택:';

  @override
  String get multiple_device_connected =>
      '여러 디바이스가 연결되어 있습니다.\n이 작업을 실행할 디바이스를 선택하세요';

  @override
  String get nothing_found => '찾을 수 없음';

  @override
  String get the_box_is_empty => '상자가 비어 있습니다';

  @override
  String get top_artists => '톱 아티스트';

  @override
  String get top_albums => '톱 앨범';

  @override
  String get this_week => '이번 주';

  @override
  String get this_month => '이번 달';

  @override
  String get last_6_months => '지난 6개월';

  @override
  String get this_year => '올해';

  @override
  String get last_2_years => '지난 2년';

  @override
  String get all_time => '모든 시간';

  @override
  String powered_by_provider(Object providerName) {
    return '$providerName 제공';
  }

  @override
  String get email => '이메일';

  @override
  String get profile_followers => '팔로워';

  @override
  String get birthday => '생일';

  @override
  String get subscription => '구독';

  @override
  String get not_born => '태어나지 않음';

  @override
  String get hacker => '해커';

  @override
  String get profile => '프로필';

  @override
  String get no_name => '이름 없음';

  @override
  String get edit => '편집';

  @override
  String get user_profile => '사용자 프로필';

  @override
  String count_plays(Object count) {
    return '$count 재생';
  }

  @override
  String get minutes_listened => '청취한 시간';

  @override
  String get streamed_songs => '스트리밍된 곡';

  @override
  String count_streams(Object count) {
    return '$count 스트림';
  }

  @override
  String get owned_by_you => '당신이 소유';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl를 클립보드에 복사했습니다';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes 분';
  }

  @override
  String get summary_minutes => '분';

  @override
  String get summary_listened_to_music => '듣는 음악';

  @override
  String get summary_songs => '곡';

  @override
  String get summary_streamed_overall => '전체 스트리밍';

  @override
  String get summary_artists => '아티스트의';

  @override
  String get summary_music_reached_you => '음악이 도달함';

  @override
  String get summary_full_albums => '전체 앨범';

  @override
  String get summary_got_your_love => '당신의 사랑을 받음';

  @override
  String get summary_playlists => '플레이리스트';

  @override
  String get summary_were_on_repeat => '반복 재생됨';

  @override
  String get webview_not_found => '웹뷰를 찾을 수 없음';

  @override
  String get webview_not_found_description =>
      '기기에 웹뷰 런타임이 설치되지 않았습니다.\n설치되어 있으면 environment PATH에 있는지 확인하십시오\n\n설치 후 앱을 다시 시작하세요';

  @override
  String get unsupported_platform => '지원되지 않는 플랫폼';

  @override
  String get cache_music => '음악 캐시';

  @override
  String get open => '열기';

  @override
  String get cache_folder => '캐시 폴더';

  @override
  String get export => '내보내기';

  @override
  String get clear_cache => '캐시 지우기';

  @override
  String get clear_cache_confirmation => '캐시를 지우시겠습니까?';

  @override
  String get export_cache_files => '캐시된 파일 내보내기';

  @override
  String found_n_files(Object count) {
    return '$count개의 파일을 찾았습니다';
  }

  @override
  String get export_cache_confirmation => '이 파일들을 내보내시겠습니까';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$files개 중 $filesExported개 파일을 내보냈습니다';
  }

  @override
  String get undo => '실행 취소';

  @override
  String get download_all => '모두 다운로드';

  @override
  String get add_all_to_playlist => '모두 재생 목록에 추가';

  @override
  String get add_all_to_queue => '모두 큐에 추가';

  @override
  String get play_all_next => '모두 다음에 재생';

  @override
  String get pause => '일시 정지';

  @override
  String get view_all => '모두 보기';

  @override
  String get no_tracks_added_yet => '아직 트랙을 추가하지 않은 것 같습니다';

  @override
  String get no_tracks => '여기에 트랙이 없는 것 같습니다';

  @override
  String get no_tracks_listened_yet => '아직 아무 것도 듣지 않은 것 같습니다';

  @override
  String get not_following_artists => '아티스트를 팔로우하지 않고 있습니다';

  @override
  String get no_favorite_albums_yet => '아직 즐겨찾기 앨범을 추가하지 않은 것 같습니다';

  @override
  String get no_logs_found => '로그를 찾을 수 없습니다';

  @override
  String get youtube_engine => 'YouTube 엔진';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine가 설치되지 않았습니다';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine가 시스템에 설치되지 않았습니다.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'PATH 변수에서 사용할 수 있는지 확인하거나\n아래에 $engine 실행 파일의 절대 경로를 설정하세요';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/unix와 같은 운영 체제에서는 .zshrc/.bashrc/.bash_profile 등에 경로 설정이 작동하지 않습니다.\n셸 구성 파일에 경로를 설정해야 합니다';

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
  String get download => '다운로드';

  @override
  String get file_not_found => '파일을 찾을 수 없습니다';

  @override
  String get custom => '사용자 정의';

  @override
  String get add_custom_url => '사용자 정의 URL 추가';

  @override
  String get edit_port => '포트 편집';

  @override
  String get port_helper_msg =>
      '기본값은 -1로 무작위 숫자를 나타냅니다. 방화벽이 구성된 경우 이를 설정하는 것이 좋습니다.';

  @override
  String connect_request(Object client) {
    return '$client의 연결을 허용하시겠습니까?';
  }

  @override
  String get connection_request_denied => '연결이 거부되었습니다. 사용자가 액세스를 거부했습니다.';

  @override
  String get an_error_occurred => '오류가 발생했습니다';

  @override
  String get copy_to_clipboard => '클립보드에 복사';

  @override
  String get view_logs => '로그 보기';

  @override
  String get retry => '다시 시도';

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
      '기본 메타데이터 제공자가 설정되지 않았습니다';

  @override
  String get manage_metadata_providers => '메타데이터 제공자 관리';

  @override
  String get open_link_in_browser => '브라우저에서 링크를 여시겠습니까?';

  @override
  String get do_you_want_to_open_the_following_link => '다음 링크를 여시겠습니까';

  @override
  String get unsafe_url_warning =>
      '신뢰할 수 없는 출처의 링크를 여는 것은 안전하지 않을 수 있습니다. 주의하세요!\n링크를 클립보드에 복사할 수도 있습니다.';

  @override
  String get copy_link => '링크 복사';

  @override
  String get building_your_timeline => '청취 기록을 기반으로 타임라인을 구축하고 있습니다...';

  @override
  String get official => '공식';

  @override
  String author_name(Object author) {
    return '저자: $author';
  }

  @override
  String get third_party => '타사';

  @override
  String get plugin_requires_authentication => '플러그인에 인증이 필요합니다';

  @override
  String get update_available => '업데이트 사용 가능';

  @override
  String get supports_scrobbling => '스크로블링 지원';

  @override
  String get plugin_scrobbling_info => '이 플러그인은 음악을 스크로블하여 청취 기록을 생성합니다.';

  @override
  String get default_metadata_source => '기본 메타데이터 소스';

  @override
  String get set_default_metadata_source => '기본 메타데이터 소스 설정';

  @override
  String get default_audio_source => '기본 오디오 소스';

  @override
  String get set_default_audio_source => '기본 오디오 소스 설정';

  @override
  String get set_default => '기본값으로 설정';

  @override
  String get support => '지원';

  @override
  String get support_plugin_development => '플러그인 개발 지원';

  @override
  String can_access_name_api(Object name) {
    return '- **$name** API에 액세스할 수 있습니다';
  }

  @override
  String get do_you_want_to_install_this_plugin => '이 플러그인을 설치하시겠습니까?';

  @override
  String get third_party_plugin_warning =>
      '이 플러그인은 타사 리포지토리에서 제공됩니다. 설치하기 전에 출처를 신뢰하는지 확인하세요.';

  @override
  String get author => '저자';

  @override
  String get this_plugin_can_do_following => '이 플러그인은 다음을 수행할 수 있습니다';

  @override
  String get install => '설치';

  @override
  String get no_tracks_playing => '현재 재생 중인 트랙이 없습니다';

  @override
  String get synced_lyrics_not_available => '이 노래에 대한 동기화된 가사를 사용할 수 없습니다. 대신';

  @override
  String get plain_lyrics => '일반 가사';

  @override
  String get tab_instead => '탭을 사용하세요.';

  @override
  String get disclaimer => '면책 조항';

  @override
  String get third_party_plugin_dmca_notice =>
      'DeeMusiq 팀은 어떠한 \"타사\" 플러그인에 대해서도 (법적 포함) 어떠한 책임도 지지 않습니다.\n사용자 자신의 책임하에 사용하시기 바랍니다. 버그/문제에 대해서는 플러그인 리포지토리에 보고해 주세요.\n\n만약 \"타사\" 플러그인이 서비스/법인의 ToS/DMCA를 위반하는 경우, \"타사\" 플러그인 저자 또는 호스팅 플랫폼(예: GitHub/Codeberg)에 조치를 취하도록 요청해 주세요. 위에 나열된 (\"타사\"로 표시된) 플러그인은 모두 공개/커뮤니티에서 유지 관리하는 플러그인입니다. 저희는 이를 큐레이션하지 않으므로 어떠한 조치도 취할 수 없습니다.\n\n';

  @override
  String get plugins => '플러그인';

  @override
  String get paste_plugin_download_url =>
      '다운로드 URL, GitHub/Codeberg 리포지토리 URL 또는 .smplug 파일에 대한 직접 링크를 붙여넣으세요';

  @override
  String get download_and_install_plugin_from_url => 'URL에서 플러그인 다운로드 및 설치';

  @override
  String failed_to_add_plugin_error(Object error) {
    return '플러그인 추가 실패: $error';
  }

  @override
  String get upload_plugin_from_file => '파일에서 플러그인 업로드';

  @override
  String get installed => '설치됨';

  @override
  String get available_plugins => '사용 가능한 플러그인';

  @override
  String get configure_plugins => '직접 메타데이터 제공자와 오디오 소스 플러그인을 구성하세요';

  @override
  String get audio_scrobblers => '오디오 스크로블러';

  @override
  String get scrobbling => '스크로블링';

  @override
  String get source => '출처: ';

  @override
  String get uncompressed => '비압축';

  @override
  String get dab_music_source_description =>
      '오디오파일을 위한 소스입니다. 고음질/무손실 오디오 스트림을 제공하며 ISRC 기반으로 정확한 트랙 매칭을 지원합니다.';

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
  String get skip_this_nonsense => '이 허튼소리 건너뛰기';

  @override
  String get freedom_of_music => '“음악의 자유”';

  @override
  String get freedom_of_music_palm => '“손바닥 안의 음악의 자유”';

  @override
  String get get_started => '시작합시다';

  @override
  String get endless_playback_description => '자동으로 새로운 노래를 대기열의 끝에 추가';

  @override
  String get choose_your_region => '지역 선택';

  @override
  String get choose_your_region_description =>
      '이것은 DeeMusiq가 위치에 맞는 콘텐츠를 표시하는 데 도움이 됩니다.';

  @override
  String get choose_your_language => '언어 선택';

  @override
  String get help_project_grow => '이 프로젝트 성장에 도움을 주세요';

  @override
  String get help_project_grow_description =>
      'DeeMusiq는 오픈 소스 프로젝트입니다. 프로젝트에 기여하거나 버그를 보고하거나 새로운 기능을 제안하여이 프로젝트의 성장에 도움을 줄 수 있습니다.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Open Collective에 기부하기';

  @override
  String get install_a_metadata_provider => '메타데이터 제공자 설치';

  @override
  String get input_does_not_match_format => '입력이 필요한 형식과 일치하지 않습니다';

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
  String get auth_mfa_required => '인증 코드를 입력하세요';

  @override
  String get auth_mfa_body => '인증 앱을 열고 6자리 코드를 입력해 로그인을 완료하세요.';

  @override
  String get auth_mfa_verify_action => '확인';

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
