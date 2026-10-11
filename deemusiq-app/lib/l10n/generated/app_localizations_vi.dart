// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get guest => 'Khách';

  @override
  String get browse => 'Khám phá';

  @override
  String get search => 'Tìm kiếm';

  @override
  String get library => 'Thư viên';

  @override
  String get lyrics => 'Lời bài hát';

  @override
  String get settings => 'Cài đặt';

  @override
  String get genre_categories_filter => 'Lọc theo thể loại nhạc...';

  @override
  String get genre => 'Thể loại nhạc';

  @override
  String get personalized => 'Cá nhân hóa';

  @override
  String get featured => 'Nổi bật';

  @override
  String get new_releases => 'Bản phát hành mới';

  @override
  String get songs => 'Bài hát';

  @override
  String playing_track(Object track) {
    return 'Đang phát $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'Điều này sẽ xóa hàng đợi hiện tại. $track_length bài hát sẽ bị xóa\nBạn có muốn tiếp tục không?';
  }

  @override
  String get load_more => 'Tải thêm';

  @override
  String get playlists => 'Danh sách phát';

  @override
  String get artists => 'Nghệ sĩ';

  @override
  String get albums => 'Album';

  @override
  String get tracks => 'Bài hát';

  @override
  String get downloads => 'Tải về';

  @override
  String get filter_playlists => 'Lọc danh sách phát...';

  @override
  String get liked_tracks => 'Bài hát được thích';

  @override
  String get liked_tracks_description => 'Tất cả bài hát bạn đã thích';

  @override
  String get playlist => 'Danh sách phát';

  @override
  String get create_a_playlist => 'Tạo danh sách phát';

  @override
  String get update_playlist => 'Cập nhật danh sách phát';

  @override
  String get create => 'Tạo';

  @override
  String get cancel => 'Hủy';

  @override
  String get update => 'Cập nhật';

  @override
  String get playlist_name => 'Tên danh sách phát';

  @override
  String get name_of_playlist => 'Tên của danh sách phát';

  @override
  String get description => 'Mô tả';

  @override
  String get public => 'Công khai';

  @override
  String get collaborative => 'Hợp tác';

  @override
  String get search_local_tracks => 'Tìm kiếm bài hát trong máy...';

  @override
  String get play => 'Phát';

  @override
  String get delete => 'Xóa';

  @override
  String get none => 'Không có';

  @override
  String get sort_a_z => 'Sắp xếp theo A-Z';

  @override
  String get sort_z_a => 'Sắp xếp theo Z-A';

  @override
  String get sort_artist => 'Sắp xếp theo Nghệ sĩ';

  @override
  String get sort_album => 'Sắp xếp theo Album';

  @override
  String get sort_duration => 'Sắp xếp theo Thời lượng';

  @override
  String get sort_tracks => 'Sắp xếp các bài hát';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Đang tải về ($tracks_length bài hát)';
  }

  @override
  String get cancel_all => 'Hủy tất cả';

  @override
  String get filter_artist => 'Lọc nghệ sĩ...';

  @override
  String followers(Object followers) {
    return '$followers Người theo dõi';
  }

  @override
  String get add_artist_to_blacklist => 'Thêm nghệ sĩ vào blacklist';

  @override
  String get top_tracks => 'Bài hát nổi bật';

  @override
  String get fans_also_like => 'Người hâm mộ cũng thích';

  @override
  String get loading => 'Đang tải...';

  @override
  String get artist => 'Nghệ sĩ';

  @override
  String get blacklisted => 'Đã đưa vào blacklist';

  @override
  String get following => 'Đang theo dõi';

  @override
  String get follow => 'Theo dõi';

  @override
  String get artist_url_copied => 'Đã sao chép URL nghệ sĩ';

  @override
  String added_to_queue(Object tracks) {
    return 'Đã thêm $tracks bài hát vào hàng đợi';
  }

  @override
  String get filter_albums => 'Lọc album...';

  @override
  String get synced => 'Đồng bộ';

  @override
  String get plain => 'Bình thường';

  @override
  String get shuffle => 'Trộn';

  @override
  String get search_tracks => 'Tìm kiếm bài hát...';

  @override
  String get released => 'Phát hành';

  @override
  String error(Object error) {
    return 'Lỗi $error';
  }

  @override
  String get title => 'Đề mục';

  @override
  String get time => 'Thời gian';

  @override
  String get more_actions => 'Thao tác khác';

  @override
  String download_count(Object count) {
    return 'Tải xuống ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Thêm ($count) vào danh sách phát';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Thêm ($count) vào hàng đợi';
  }

  @override
  String play_count_next(Object count) {
    return 'Phát ($count) tiếp theo';
  }

  @override
  String get album => 'Album';

  @override
  String copied_to_clipboard(Object data) {
    return 'Đã sao chép $data vào clipboard';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Thêm $track vào danh sách phát đang theo dõi';
  }

  @override
  String get add => 'Thêm';

  @override
  String added_track_to_queue(Object track) {
    return 'Đã thêm $track vào hàng đợi';
  }

  @override
  String get add_to_queue => 'Thêm vào hàng đợi';

  @override
  String track_will_play_next(Object track) {
    return '$track sẽ được phát tiếp theo';
  }

  @override
  String get play_next => 'Phát tiếp theo';

  @override
  String removed_track_from_queue(Object track) {
    return 'Đã xóa $track khỏi hàng đợi';
  }

  @override
  String get remove_from_queue => 'Xóa khỏi hàng đợi';

  @override
  String get remove_from_favorites => 'Xóa khỏi bài hát yêu thích';

  @override
  String get save_as_favorite => 'Thêm vào bài hát yêu thích';

  @override
  String get add_to_playlist => 'Thêm vào danh sách phát';

  @override
  String get remove_from_playlist => 'Xóa khỏi danh sách phát';

  @override
  String get add_to_blacklist => 'Thêm vào blacklist';

  @override
  String get remove_from_blacklist => 'Xóa khỏi blacklist';

  @override
  String get share => 'Chia sẻ';

  @override
  String get mini_player => 'Trình phát thu nhỏ';

  @override
  String get slide_to_seek => 'Trượt để tìm kiếm tiến hoặc lùi';

  @override
  String get shuffle_playlist => 'Xáo trộn bài hát';

  @override
  String get unshuffle_playlist => 'Hủy xáo trộn bài hát';

  @override
  String get previous_track => 'Bài hát trước';

  @override
  String get next_track => 'Bài hát tiếp theo';

  @override
  String get pause_playback => 'Tạm dừng phát';

  @override
  String get resume_playback => 'Tiếp tục phát';

  @override
  String get loop_track => 'Lặp lại bài hát';

  @override
  String get no_loop => 'Không lặp lại';

  @override
  String get repeat_playlist => 'Lặp lại danh sách phát';

  @override
  String get queue => 'Hàng đợi';

  @override
  String get alternative_track_sources => 'Đổi nguồn bài hát';

  @override
  String get download_track => 'Tải xuống';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks bài hát trong hàng đợi';
  }

  @override
  String get clear_all => 'Xóa tất cả';

  @override
  String get show_hide_ui_on_hover =>
      'Hiển thị/Ẩn giao diện người dùng khi di chuột qua';

  @override
  String get always_on_top => 'Luôn ở trên cùng';

  @override
  String get exit_mini_player => 'Thoát khỏi trình phát thu nhỏ';

  @override
  String get download_location => 'Vị trí tải xuống';

  @override
  String get local_library => 'Thư viện địa phương';

  @override
  String get add_library_location => 'Thêm vào thư viện';

  @override
  String get remove_library_location => 'Xóa khỏi thư viện';

  @override
  String get account => 'Tài khoản';

  @override
  String get logout => 'Đăng xuất';

  @override
  String get logout_of_this_account => 'Đăng xuất khỏi tài khoản này';

  @override
  String get language_region => 'Ngôn ngữ và Khu vực';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get system_default => 'Mặc định hệ thống';

  @override
  String get market_place_region => 'Khu vực Marketplace';

  @override
  String get recommendation_country => 'Quốc gia gợi ý';

  @override
  String get appearance => 'Giao diện';

  @override
  String get layout_mode => 'Chế độ layout';

  @override
  String get override_layout_settings => 'Ghi đè cài đặt layout';

  @override
  String get adaptive => 'Tương thích';

  @override
  String get compact => 'Nhỏ gọn';

  @override
  String get extended => 'Mở rộng';

  @override
  String get theme => 'Chủ đề';

  @override
  String get dark => 'Tối';

  @override
  String get light => 'Sáng';

  @override
  String get system => 'Hệ thống';

  @override
  String get accent_color => 'Màu nhấn';

  @override
  String get sync_album_color => 'Đồng bộ màu album';

  @override
  String get sync_album_color_description =>
      'Sử dụng màu chủ đạo của hình ảnh album làm màu nhấn';

  @override
  String get playback => 'Phát';

  @override
  String get audio_quality => 'Chất lượng âm thanh';

  @override
  String get high => 'Cao';

  @override
  String get low => 'Thấp';

  @override
  String get pre_download_play => 'Tải xuống và phát';

  @override
  String get pre_download_play_description =>
      'Thay vì stream âm thanh, tải xuống trước và phát (Khuyến nghị cho người dùng có băng thông cao)';

  @override
  String get skip_non_music => 'Bỏ qua các đoạn không phải nhạc (SponsorBlock)';

  @override
  String get blacklist_description => 'Các bài hát và nghệ sĩ trong blacklist';

  @override
  String get wait_for_download_to_finish =>
      'Vui lòng đợi quá trình tải xuống hiện tại hoàn thành';

  @override
  String get desktop => 'Máy tính';

  @override
  String get close_behavior => 'Thao tác đóng';

  @override
  String get close => 'Đóng';

  @override
  String get minimize_to_tray => 'Thu nhỏ vào khay hệ thống';

  @override
  String get show_tray_icon => 'Hiển thị biểu tượng trên khay hệ thống';

  @override
  String get about => 'Về chúng tôi';

  @override
  String get u_love_spotube => 'Chúng tôi biết bạn yêu DeeMusiq';

  @override
  String get check_for_updates => 'Kiểm tra cập nhật';

  @override
  String get about_spotube => 'Về DeeMusiq';

  @override
  String get blacklist => 'blacklist';

  @override
  String get please_sponsor => 'Vui lòng tài trợ/ủng hộ';

  @override
  String get spotube_description =>
      'DeeMusiq, một ứng dụng Spotify nhẹ, đa nền tảng và miễn phí';

  @override
  String get version => 'Phiên bản';

  @override
  String get build_number => 'Số phiên bản';

  @override
  String get founder => 'Người sáng lập';

  @override
  String get repository => 'Mã nguồn';

  @override
  String get bug_issues => 'Báo cáo lỗi';

  @override
  String get made_with => 'Được làm bằng ❤️ ở Băng-la-đét';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Giấy phép';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Đừng lo, thông tin đăng nhập của bạn sẽ không được thu thập hoặc chia sẻ với bất kỳ ai';

  @override
  String get know_how_to_login => 'Không biết cách lấy thông tin đăng nhập?';

  @override
  String get follow_step_by_step_guide => 'Các bước lấy thông tin đăng nhập';

  @override
  String cookie_name_cookie(Object name) {
    return 'Cookie $name';
  }

  @override
  String get fill_in_all_fields => 'Vui lòng điền đầy đủ thông tin';

  @override
  String get submit => 'Gửi';

  @override
  String get exit => 'Thoát';

  @override
  String get previous => 'Trước';

  @override
  String get next => 'Tiếp';

  @override
  String get done => 'Hoàn tất';

  @override
  String get step_1 => 'Bước 1';

  @override
  String get first_go_to => 'Đầu tiên, truy cập';

  @override
  String get something_went_wrong => 'Đã xảy ra lỗi';

  @override
  String get piped_instance => 'Phiên bản Server Piped';

  @override
  String get piped_description =>
      'Phiên bản Piped để sử dụng cho Track matching';

  @override
  String get piped_warning =>
      'Một số phiên bản Piped có thể không hoạt động tốt';

  @override
  String get invidious_instance => 'Phiên bản máy chủ Invidious';

  @override
  String get invidious_description =>
      'Phiên bản máy chủ Invidious để sử dụng để so khớp bản nhạc';

  @override
  String get invidious_warning =>
      'Một số có thể sẽ không hoạt động tốt. Vì vậy hãy sử dụng với rủi ro của riêng bạn';

  @override
  String get generate => 'Tạo';

  @override
  String track_exists(Object track) {
    return 'Bài hát $track đã tồn tại';
  }

  @override
  String get replace_downloaded_tracks => 'Thay thế tất cả các bài hát đã tải';

  @override
  String get skip_download_tracks =>
      'Bỏ qua tải xuống tất cả các bài hát đã tải';

  @override
  String get do_you_want_to_replace =>
      'Bạn có muốn thay thế bài hát hiện có không?';

  @override
  String get replace => 'Thay thế';

  @override
  String get skip => 'Bỏ qua';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Chọn tối đa $count $type';
  }

  @override
  String get select_genres => 'Chọn Thể loại';

  @override
  String get add_genres => 'Thêm Thể loại';

  @override
  String get country => 'Quốc gia';

  @override
  String get number_of_tracks_generate => 'Số lượng bài hát để tạo';

  @override
  String get acousticness => 'Độ âm thanh';

  @override
  String get danceability => 'Khả năng nhảy';

  @override
  String get energy => 'Năng lượng';

  @override
  String get instrumentalness => 'Độ nhạc cụ';

  @override
  String get liveness => 'Sống động';

  @override
  String get loudness => 'Độ ồn';

  @override
  String get speechiness => 'Độ nói';

  @override
  String get valence => 'Tính tích cực';

  @override
  String get popularity => 'Độ phổ biến';

  @override
  String get key => 'Tông';

  @override
  String get duration => 'Thời lượng (giây)';

  @override
  String get tempo => 'Nhịp độ (BPM)';

  @override
  String get mode => 'Chế độ';

  @override
  String get time_signature => 'Chữ ký thời gian';

  @override
  String get short => 'Ngắn';

  @override
  String get medium => 'Trung bình';

  @override
  String get long => 'Dài';

  @override
  String get min => 'Tối thiểu';

  @override
  String get max => 'Tối đa';

  @override
  String get target => 'Mục tiêu';

  @override
  String get moderate => 'Trung bình';

  @override
  String get deselect_all => 'Bỏ chọn tất cả';

  @override
  String get select_all => 'Chọn tất cả';

  @override
  String get are_you_sure => 'Bạn có chắc chắn?';

  @override
  String get generating_playlist =>
      'Đang tạo danh sách phát tùy chỉnh của bạn...';

  @override
  String selected_count_tracks(Object count) {
    return 'Đã chọn $count bài hát';
  }

  @override
  String get download_warning =>
      'Tải xuống tất cả các bài hát một lần, sẽ vi phạm bản quyền âm nhạc và gây thiệt hại cho xã hội sáng tạo âm nhạc. Hy vọng bạn nhận thức được điều này. Hãy luôn tôn trọng và ủng hộ công sức của nghệ sĩ';

  @override
  String get download_ip_ban_warning =>
      'Địa chỉ IP của bạn có thể bị chặn trên YouTube do yêu cầu tải xuống quá mức so với bình thường. Chặn IP có nghĩa là bạn không thể sử dụng YouTube (ngay cả khi bạn đã đăng nhập) ít nhất 2-3 tháng từ thiết bị IP đó. Và DeeMusiq không chịu trách nhiệm nếu điều này xảy ra';

  @override
  String get by_clicking_accept_terms =>
      'Bằng cách nhấp vào \'Chấp nhận\', bạn đồng ý với các điều khoản sau:';

  @override
  String get download_agreement_1 =>
      'Tôi biết mình đang vi phạm bản quyền âm nhạc. Đó là không tốt.';

  @override
  String get download_agreement_2 =>
      'Tôi sẽ ủng hộ nghệ sĩ bất cứ nơi nào tôi có thể và tôi chỉ làm điều này vì tôi không có tiền để mua tác phẩm của họ';

  @override
  String get download_agreement_3 =>
      'Tôi hoàn toàn nhận thức được rằng địa chỉ IP của tôi có thể bị chặn trên YouTube và tôi không đổ lỗi cho DeeMusiq hoặc chủ sở hữu/người đóng góp của nó về bất kỳ tai nạn nào do hành động này của tôi';

  @override
  String get decline => 'Từ chối';

  @override
  String get accept => 'Chấp nhận';

  @override
  String get details => 'Chi tiết';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Kênh';

  @override
  String get likes => 'Thích';

  @override
  String get dislikes => 'Không thích';

  @override
  String get views => 'Lượt xem';

  @override
  String get streamUrl => 'URL phát trực tiếp';

  @override
  String get stop => 'Dừng';

  @override
  String get sort_newest => 'Sắp xếp theo mới nhất';

  @override
  String get sort_oldest => 'Sắp xếp theo cũ nhất';

  @override
  String get sleep_timer => 'Hẹn giờ tắt';

  @override
  String mins(Object minutes) {
    return '$minutes Phút';
  }

  @override
  String hours(Object hours) {
    return '$hours Giờ';
  }

  @override
  String hour(Object hours) {
    return '$hours Giờ';
  }

  @override
  String get custom_hours => 'Giờ Tùy chỉnh';

  @override
  String get logs => 'Nhật ký';

  @override
  String get developers => 'Nhà phát triển';

  @override
  String get not_logged_in => 'Bạn chưa đăng nhập';

  @override
  String get search_mode => 'Chế độ tìm kiếm';

  @override
  String get audio_source => 'Nguồn âm thanh';

  @override
  String get ok => 'Ok';

  @override
  String get failed_to_encrypt => 'Mã hóa không thành công';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq không thành công trong việc mã hóa nhằm lưu trữ dữ liêu an toàn. vậy nên sẽ chuyển về lưu trữ không an toàn\nNếu bạn đang sử dụng Linux, đảm bảo rằng bạn có sử dụng dịch vụ bảo mật (gnome-keyring, kde-wallet, keepassxc, v.v.)';

  @override
  String get querying_info => 'Đang truy vấn thông tin...';

  @override
  String get piped_api_down => 'API Piped đang gặp sự cố';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Phiên bản Piped $pipedInstance hiện đang gặp sự cố\n\nThay đổi phiên bản hoặc thay đổi \'Loại API\' thành API YouTube official\n\nKhởi động lai ứng dụng sau khi thay đổi.';
  }

  @override
  String get you_are_offline => 'Bạn đang ngoại tuyến';

  @override
  String get connection_restored =>
      'Kết nối internet của bạn đã được khôi phục';

  @override
  String get use_system_title_bar => 'Sử dụng thanh tiêu đề hệ thống';

  @override
  String get crunching_results => 'Đang tìm kiếm...';

  @override
  String get search_to_get_results => 'Chưa tìm kiếm';

  @override
  String get use_amoled_mode => 'Chủ đề tối hoàn toàn';

  @override
  String get pitch_dark_theme => 'Chế độ AMOLED';

  @override
  String get normalize_audio => 'Bình thường hóa âm thanh';

  @override
  String get change_cover => 'Thay đổi ảnh bìa';

  @override
  String get add_cover => 'Thêm ảnh bìa';

  @override
  String get restore_defaults => 'Khôi phục mặc định';

  @override
  String get download_music_format => 'Định dạng nhạc tải về';

  @override
  String get streaming_music_format => 'Định dạng nhạc phát trực tuyến';

  @override
  String get download_music_quality => 'Chất lượng nhạc tải về';

  @override
  String get streaming_music_quality => 'Chất lượng nhạc phát trực tuyến';

  @override
  String get login_with_lastfm => 'Đăng nhập bằng tài khoản Last.fm';

  @override
  String get connect => 'Liên kết';

  @override
  String get disconnect_lastfm => 'Dừng liên kết Last.fm';

  @override
  String get disconnect => 'Ngắt kết nối';

  @override
  String get username => 'Tên người dùng';

  @override
  String get password => 'Mật khẩu';

  @override
  String get login => 'Đăng nhập';

  @override
  String get login_with_your_lastfm =>
      'Đăng nhập bằng tài khoản Last.fm của bạn';

  @override
  String get scrobble_to_lastfm => 'Scrobble đến Last.fm';

  @override
  String get go_to_album => 'Đi đến Album';

  @override
  String get discord_rich_presence => 'Hiển thị trạng thái Discord';

  @override
  String get browse_all => 'Duyệt tất cả';

  @override
  String get genres => 'Thể loại';

  @override
  String get explore_genres => 'Khám phá Thể loại';

  @override
  String get friends => 'Bạn bè';

  @override
  String get no_lyrics_available =>
      'Xin lỗi, không tìm thấy lời cho bài hát này';

  @override
  String get start_a_radio => 'Bắt đầu Một Đài phát thanh';

  @override
  String get how_to_start_radio =>
      'Bạn muốn bắt đầu đài phát thanh như thế nào?';

  @override
  String get replace_queue_question =>
      'Bạn muốn thay thế hàng đợi hiện tại hay thêm vào?';

  @override
  String get endless_playback => 'Phát không giới hạn';

  @override
  String get delete_playlist => 'Xóa Danh sách phát';

  @override
  String get delete_playlist_confirmation =>
      'Bạn có chắc chắn muốn xóa danh sách phát này không?';

  @override
  String get local_tracks => 'Bài hát Địa phương';

  @override
  String get local_tab => 'Địa phương';

  @override
  String get song_link => 'Liên kết Bài hát';

  @override
  String get youtube_source_description =>
      'Được đề xuất và hoạt động tốt nhất.';

  @override
  String get piped_source_description =>
      'Cảm thấy tự do? Giống như YouTube nhưng miễn phí hơn rất nhiều.';

  @override
  String get jiosaavn_source_description => 'Tốt nhất cho khu vực Nam Á.';

  @override
  String get invidious_source_description =>
      'Tương tự như Piped nhưng có tính khả dụng cao hơn.';

  @override
  String highest_quality(Object quality) {
    return 'Chất lượng Tốt nhất: $quality';
  }

  @override
  String get select_audio_source => 'Chọn Nguồn Âm thanh';

  @override
  String get contribute_on_github => 'Đóng góp trên GitHub';

  @override
  String get browse_anonymously => 'Duyệt Anonymously';

  @override
  String get enable_connect => 'Kích hoạt kết nối';

  @override
  String get enable_connect_description =>
      'Điều khiển DeeMusiq từ các thiết bị khác';

  @override
  String get devices => 'Thiết bị';

  @override
  String get select => 'Chọn';

  @override
  String connect_client_alert(Object client) {
    return 'Bạn đang được điều khiển bởi $client';
  }

  @override
  String get this_device => 'Thiết bị này';

  @override
  String get remote => 'Từ xa';

  @override
  String get stats => 'Thống kê';

  @override
  String and_n_more(Object count) {
    return 'và $count cái khác';
  }

  @override
  String get recently_played => 'Gần đây đã phát';

  @override
  String get browse_more => 'Xem thêm';

  @override
  String get no_title => 'Không có tiêu đề';

  @override
  String get not_playing => 'Không phát';

  @override
  String get epic_failure => 'Thất bại hoàn toàn!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Đã thêm $tracks_length bài hát vào danh sách phát';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq có bản cập nhật';

  @override
  String get download_now => 'Tải về ngay';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum đã được phát hành';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version đã được phát hành';
  }

  @override
  String get read_the_latest => 'Đọc tin mới nhất';

  @override
  String get release_notes => 'ghi chú phát hành';

  @override
  String get pick_color_scheme => 'Chọn chủ đề màu sắc';

  @override
  String get save => 'Lưu';

  @override
  String get choose_the_device => 'Chọn thiết bị:';

  @override
  String get multiple_device_connected =>
      'Có nhiều thiết bị kết nối.\nChọn thiết bị mà bạn muốn thực hiện hành động này';

  @override
  String get nothing_found => 'Không tìm thấy gì';

  @override
  String get the_box_is_empty => 'Hộp trống';

  @override
  String get top_artists => 'Những Nghệ Sĩ Hàng Đầu';

  @override
  String get top_albums => 'Những Album Hàng Đầu';

  @override
  String get this_week => 'Tuần này';

  @override
  String get this_month => 'Tháng này';

  @override
  String get last_6_months => '6 tháng qua';

  @override
  String get this_year => 'Năm nay';

  @override
  String get last_2_years => '2 năm qua';

  @override
  String get all_time => 'Mọi thời đại';

  @override
  String powered_by_provider(Object providerName) {
    return 'Cung cấp bởi $providerName';
  }

  @override
  String get email => 'Email';

  @override
  String get profile_followers => 'Người theo dõi';

  @override
  String get birthday => 'Ngày sinh';

  @override
  String get subscription => 'Gói cước';

  @override
  String get not_born => 'Chưa sinh';

  @override
  String get hacker => 'Tin tặc';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get no_name => 'Không có tên';

  @override
  String get edit => 'Chỉnh sửa';

  @override
  String get user_profile => 'Hồ sơ người dùng';

  @override
  String count_plays(Object count) {
    return '$count lần phát';
  }

  @override
  String get minutes_listened => 'Thời gian nghe';

  @override
  String get streamed_songs => 'Bài hát đã phát';

  @override
  String count_streams(Object count) {
    return '$count lượt phát';
  }

  @override
  String get owned_by_you => 'Thuộc sở hữu của bạn';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl đã sao chép vào bảng tạm';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes phút';
  }

  @override
  String get summary_minutes => 'phút';

  @override
  String get summary_listened_to_music => 'Đã nghe nhạc';

  @override
  String get summary_songs => 'bài hát';

  @override
  String get summary_streamed_overall => 'Stream tổng cộng';

  @override
  String get summary_artists => 'nghệ sĩ';

  @override
  String get summary_music_reached_you => 'Âm nhạc đã đến với bạn';

  @override
  String get summary_full_albums => 'album đầy đủ';

  @override
  String get summary_got_your_love => 'Nhận được tình yêu của bạn';

  @override
  String get summary_playlists => 'danh sách phát';

  @override
  String get summary_were_on_repeat => 'Đã được phát lại';

  @override
  String get webview_not_found => 'Không tìm thấy Webview';

  @override
  String get webview_not_found_description =>
      'Không có runtime Webview nào được cài đặt trên thiết bị của bạn.\nNếu đã cài đặt, hãy đảm bảo rằng nó nằm trong environment PATH\n\nSau khi cài đặt, hãy khởi động lại ứng dụng';

  @override
  String get unsupported_platform => 'Nền tảng không được hỗ trợ';

  @override
  String get cache_music => 'Lưu nhạc vào bộ nhớ đệm';

  @override
  String get open => 'Mở';

  @override
  String get cache_folder => 'Thư mục bộ nhớ đệm';

  @override
  String get export => 'Xuất';

  @override
  String get clear_cache => 'Xóa bộ nhớ đệm';

  @override
  String get clear_cache_confirmation => 'Bạn có muốn xóa bộ nhớ đệm không?';

  @override
  String get export_cache_files => 'Xuất các tệp được lưu trong bộ nhớ đệm';

  @override
  String found_n_files(Object count) {
    return 'Tìm thấy $count tệp';
  }

  @override
  String get export_cache_confirmation => 'Bạn có muốn xuất các tệp này đến';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'Đã xuất $filesExported trên $files tệp';
  }

  @override
  String get undo => 'Hoàn tác';

  @override
  String get download_all => 'Tải xuống tất cả';

  @override
  String get add_all_to_playlist => 'Thêm tất cả vào danh sách phát';

  @override
  String get add_all_to_queue => 'Thêm tất cả vào danh sách chờ';

  @override
  String get play_all_next => 'Chơi tất cả tiếp theo';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get view_all => 'Xem tất cả';

  @override
  String get no_tracks_added_yet => 'Có vẻ bạn chưa thêm bất kỳ bài hát nào';

  @override
  String get no_tracks => 'Có vẻ không có bài hát nào ở đây';

  @override
  String get no_tracks_listened_yet => 'Có vẻ bạn chưa nghe gì cả';

  @override
  String get not_following_artists =>
      'Bạn không đang theo dõi bất kỳ nghệ sĩ nào';

  @override
  String get no_favorite_albums_yet =>
      'Có vẻ bạn chưa thêm album nào vào danh sách yêu thích';

  @override
  String get no_logs_found => 'Không tìm thấy nhật ký';

  @override
  String get youtube_engine => 'Công cụ YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine chưa được cài đặt';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine chưa được cài đặt trong hệ thống của bạn.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Đảm bảo nó có sẵn trong biến PATH hoặc\nđặt đường dẫn tuyệt đối đến tệp thực thi $engine dưới đây';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'Trên macOS/Linux/Unix, việc thiết lập đường dẫn trong .zshrc/.bashrc/.bash_profile v.v. sẽ không hoạt động.\nBạn cần thiết lập đường dẫn trong tệp cấu hình shell';

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
  String get download => 'Tải xuống';

  @override
  String get file_not_found => 'Không tìm thấy tệp';

  @override
  String get custom => 'Tùy chỉnh';

  @override
  String get add_custom_url => 'Thêm URL tùy chỉnh';

  @override
  String get edit_port => 'Chỉnh sửa cổng';

  @override
  String get port_helper_msg =>
      'Mặc định là -1, có nghĩa là số ngẫu nhiên. Nếu bạn đã cấu hình tường lửa, nên đặt điều này.';

  @override
  String connect_request(Object client) {
    return 'Cho phép $client kết nối?';
  }

  @override
  String get connection_request_denied =>
      'Kết nối bị từ chối. Người dùng đã từ chối quyền truy cập.';

  @override
  String get an_error_occurred => 'Đã xảy ra lỗi';

  @override
  String get copy_to_clipboard => 'Sao chép vào khay nhớ tạm';

  @override
  String get view_logs => 'Xem nhật ký';

  @override
  String get retry => 'Thử lại';

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
      'Bạn chưa đặt nhà cung cấp siêu dữ liệu mặc định nào';

  @override
  String get manage_metadata_providers => 'Quản lý nhà cung cấp siêu dữ liệu';

  @override
  String get open_link_in_browser => 'Mở liên kết trong Trình duyệt?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Bạn có muốn mở liên kết sau không';

  @override
  String get unsafe_url_warning =>
      'Việc mở các liên kết từ các nguồn không đáng tin cậy có thể không an toàn. Hãy thận trọng!\nBạn cũng có thể sao chép liên kết vào khay nhớ tạm của mình.';

  @override
  String get copy_link => 'Sao chép liên kết';

  @override
  String get building_your_timeline =>
      'Đang xây dựng dòng thời gian của bạn dựa trên những gì bạn đã nghe...';

  @override
  String get official => 'Chính thức';

  @override
  String author_name(Object author) {
    return 'Tác giả: $author';
  }

  @override
  String get third_party => 'Bên thứ ba';

  @override
  String get plugin_requires_authentication => 'Plugin yêu cầu xác thực';

  @override
  String get update_available => 'Có bản cập nhật';

  @override
  String get supports_scrobbling => 'Hỗ trợ scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'Plugin này scrobble nhạc của bạn để tạo lịch sử nghe của bạn.';

  @override
  String get default_metadata_source => 'Nguồn siêu dữ liệu mặc định';

  @override
  String get set_default_metadata_source => 'Đặt nguồn siêu dữ liệu mặc định';

  @override
  String get default_audio_source => 'Nguồn âm thanh mặc định';

  @override
  String get set_default_audio_source => 'Đặt nguồn âm thanh mặc định';

  @override
  String get set_default => 'Đặt làm mặc định';

  @override
  String get support => 'Hỗ trợ';

  @override
  String get support_plugin_development => 'Hỗ trợ phát triển plugin';

  @override
  String can_access_name_api(Object name) {
    return '- Có thể truy cập API **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Bạn có muốn cài đặt plugin này không?';

  @override
  String get third_party_plugin_warning =>
      'Plugin này đến từ một kho lưu trữ của bên thứ ba. Vui lòng đảm bảo rằng bạn tin tưởng nguồn trước khi cài đặt.';

  @override
  String get author => 'Tác giả';

  @override
  String get this_plugin_can_do_following =>
      'Plugin này có thể làm những việc sau';

  @override
  String get install => 'Cài đặt';

  @override
  String get no_tracks_playing => 'Hiện không có bản nhạc nào đang phát';

  @override
  String get synced_lyrics_not_available =>
      'Lời bài hát được đồng bộ hóa không có sẵn cho bài hát này. Vui lòng sử dụng';

  @override
  String get plain_lyrics => 'Lời bài hát thuần túy';

  @override
  String get tab_instead => 'thay thế.';

  @override
  String get disclaimer => 'Miễn trừ trách nhiệm';

  @override
  String get third_party_plugin_dmca_notice =>
      'Nhóm DeeMusiq không chịu bất kỳ trách nhiệm nào (bao gồm cả pháp lý) đối với bất kỳ plugin \"Bên thứ ba\" nào.\nVui lòng sử dụng chúng với rủi ro của riêng bạn. Đối với bất kỳ lỗi/vấn đề nào, vui lòng báo cáo chúng cho kho lưu trữ plugin.\n\nNếu bất kỳ plugin \"Bên thứ ba\" nào vi phạm ToS/DMCA của bất kỳ dịch vụ/thực thể pháp lý nào, vui lòng yêu cầu tác giả plugin \"Bên thứ ba\" hoặc nền tảng lưu trữ, ví dụ: GitHub/Codeberg, thực hiện hành động. Tất cả các plugin được liệt kê ở trên (được gắn nhãn \"Bên thứ ba\") đều là các plugin công cộng/do cộng đồng duy trì. Chúng tôi không quản lý chúng, vì vậy chúng tôi không thể thực hiện bất kỳ hành động nào đối với chúng.\n\n';

  @override
  String get plugins => 'Tiện ích bổ sung';

  @override
  String get paste_plugin_download_url =>
      'Dán url tải xuống hoặc url kho lưu trữ GitHub/Codeberg hoặc liên kết trực tiếp đến tệp .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'Tải xuống và cài đặt plugin từ url';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Không thể thêm plugin: $error';
  }

  @override
  String get upload_plugin_from_file => 'Tải lên plugin từ tệp';

  @override
  String get installed => 'Đã cài đặt';

  @override
  String get available_plugins => 'Các plugin có sẵn';

  @override
  String get configure_plugins =>
      'Cấu hình nhà cung cấp siêu dữ liệu và tiện ích nguồn âm thanh riêng';

  @override
  String get audio_scrobblers => 'Bộ scrobbler âm thanh';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Nguồn: ';

  @override
  String get uncompressed => 'Không nén';

  @override
  String get dab_music_source_description =>
      'Dành cho người yêu âm nhạc chất lượng cao. Cung cấp luồng âm thanh chất lượng cao/không nén. Phù hợp bài hát dựa trên ISRC chính xác.';

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
  String get skip_this_nonsense => 'Bỏ qua bớt rối này';

  @override
  String get freedom_of_music => '“Sự Tự do của Âm nhạc”';

  @override
  String get freedom_of_music_palm =>
      '“Sự Tự do của Âm nhạc trong lòng bàn tay của bạn”';

  @override
  String get get_started => 'Bắt đầu thôi';

  @override
  String get endless_playback_description =>
      'Tự động thêm các bài hát mới\nvào cuối hàng đợi';

  @override
  String get choose_your_region => 'Chọn khu vực của bạn';

  @override
  String get choose_your_region_description =>
      'Điều này sẽ giúp DeeMusiq hiển thị nội dung phù hợp cho vị trí của bạn.';

  @override
  String get choose_your_language => 'Chọn ngôn ngữ của bạn';

  @override
  String get help_project_grow => 'Hãy giúp dự án này phát triển';

  @override
  String get help_project_grow_description =>
      'DeeMusiq là một dự án mã nguồn mở. Bạn có thể giúp dự án này phát triển bằng cách đóng góp vào dự án, báo cáo lỗi hoặc đề xuất tính năng mới.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Quyên góp trên Open Collective';

  @override
  String get install_a_metadata_provider =>
      'Cài đặt một Nhà cung cấp siêu dữ liệu';

  @override
  String get input_does_not_match_format =>
      'Đầu vào không khớp với định dạng yêu cầu';

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
  String get auth_mfa_required => 'Nhập mã xác thực của bạn';

  @override
  String get auth_mfa_body =>
      'Mở ứng dụng xác thực và nhập mã 6 chữ số để hoàn tất đăng nhập.';

  @override
  String get auth_mfa_verify_action => 'Xác minh';

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
