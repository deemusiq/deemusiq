// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get guest => 'ผู้มาเยือน';

  @override
  String get browse => 'เรียกดู';

  @override
  String get search => 'ค้นหา';

  @override
  String get library => 'คลัง';

  @override
  String get lyrics => 'เนื้อเพลง';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get genre_categories_filter => 'กรองประเภทหรือแนวเพลง...';

  @override
  String get genre => 'ประเภท';

  @override
  String get personalized => 'ปรับแต่ง';

  @override
  String get featured => 'เด่น';

  @override
  String get new_releases => 'เพิ่งปล่อยใหม่';

  @override
  String get songs => 'เพลง';

  @override
  String playing_track(Object track) {
    return 'กำลังเล่น $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'การดำเนินการนี้จะล้างคิวปัจจุบัน $track_length แทร็ก จะถูกลบออก\nคุณต้องการดำเนินการต่อหรือไม่?';
  }

  @override
  String get load_more => 'โหลดเพิ่มเติม';

  @override
  String get playlists => 'เพลย์ลิสต์';

  @override
  String get artists => 'ศิลปิน';

  @override
  String get albums => 'อัลบั้ม';

  @override
  String get tracks => 'แทร็ก';

  @override
  String get downloads => 'ดาวน์โหลด';

  @override
  String get filter_playlists => 'กรองเพลย์ลิสต์...';

  @override
  String get liked_tracks => 'เพลงที่ชอบ';

  @override
  String get liked_tracks_description => 'เพลงที่คุณชื่นชอบทั้งหมด';

  @override
  String get playlist => 'เพลย์ลิสต์';

  @override
  String get create_a_playlist => 'สร้างเพลย์ลิสต์';

  @override
  String get update_playlist => 'อัพเดทเพลย์ลิสต์';

  @override
  String get create => 'สร้าง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get update => 'อัพเดท';

  @override
  String get playlist_name => 'ชื่อเพลย์ลิสต์';

  @override
  String get name_of_playlist => 'ชื่อของเพลย์ลิสต์';

  @override
  String get description => 'คำอธิบาย';

  @override
  String get public => 'สาธารณะ';

  @override
  String get collaborative => 'ร่วมมือกัน';

  @override
  String get search_local_tracks => 'ค้นหาเพลงในเครื่อง...';

  @override
  String get play => 'เล่น';

  @override
  String get delete => 'ลบ';

  @override
  String get none => 'ไม่มี';

  @override
  String get sort_a_z => 'เรียงตาม A-Z';

  @override
  String get sort_z_a => 'เรียงตาม Z-A';

  @override
  String get sort_artist => 'เรียงตามศิลปิน';

  @override
  String get sort_album => 'เรียงตามอัลบั้ม';

  @override
  String get sort_duration => 'เรียงตามความยาว';

  @override
  String get sort_tracks => 'เรียงตามเพลง';

  @override
  String currently_downloading(Object tracks_length) {
    return 'กำลังดาวน์โหลด ($tracks_length)';
  }

  @override
  String get cancel_all => 'ยกเลิกทั้งหมด';

  @override
  String get filter_artist => 'กรองศิลปิน...';

  @override
  String followers(Object followers) {
    return '$followers ผู้ติดตาม';
  }

  @override
  String get add_artist_to_blacklist => 'เพิ่มศิลปินในบัญชีดำ';

  @override
  String get top_tracks => 'เพลงฮิต';

  @override
  String get fans_also_like => 'แฟนๆ ยังชอบ';

  @override
  String get loading => 'กำลังโหลด...';

  @override
  String get artist => 'ศิลปิน';

  @override
  String get blacklisted => 'อยู่ในบัญชีดำ';

  @override
  String get following => 'กำลังติดตาม';

  @override
  String get follow => 'ติดตาม';

  @override
  String get artist_url_copied => 'คัดลอก URL ศิลปินไปยังคลิปบอร์ด';

  @override
  String added_to_queue(Object tracks) {
    return 'เพิ่ม $tracks เพลงลงในคิว';
  }

  @override
  String get filter_albums => 'กรองอัลบั้ม...';

  @override
  String get synced => 'ซิงค์';

  @override
  String get plain => 'เรียบง่าย';

  @override
  String get shuffle => 'สุ่ม';

  @override
  String get search_tracks => 'ค้นหาเพลง...';

  @override
  String get released => 'เผยแพร่';

  @override
  String error(Object error) {
    return 'ข้อผิดพลาด $error';
  }

  @override
  String get title => 'ชื่อ';

  @override
  String get time => 'เวลา';

  @override
  String get more_actions => 'เพิ่มเติม';

  @override
  String download_count(Object count) {
    return 'ดาวน์โหลด ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'เพิ่ม ($count) ลงในเพลย์ลิสต์';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'เพิ่ม ($count) ลงในคิว';
  }

  @override
  String play_count_next(Object count) {
    return 'เล่น ($count) ต่อไป';
  }

  @override
  String get album => 'อัลบั้ม';

  @override
  String copied_to_clipboard(Object data) {
    return 'คัดลอก $data ไปยังคลิปบอร์ด';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'เพิ่ม $track ลงในเพลย์ลิสต์';
  }

  @override
  String get add => 'เพิ่ม';

  @override
  String added_track_to_queue(Object track) {
    return 'เพิ่ม $track ลงในคิว';
  }

  @override
  String get add_to_queue => 'เพิ่มลงในคิว';

  @override
  String track_will_play_next(Object track) {
    return '$track จะเล่นต่อไป';
  }

  @override
  String get play_next => 'เล่นต่อไป';

  @override
  String removed_track_from_queue(Object track) {
    return 'ลบ $track ออกจากคิว';
  }

  @override
  String get remove_from_queue => 'ลบออกจากคิว';

  @override
  String get remove_from_favorites => 'ลบออกจากรายการโปรด';

  @override
  String get save_as_favorite => 'บันทึกเป็นรายการโปรด';

  @override
  String get add_to_playlist => 'เพิ่มลงในเพลย์ลิสต์';

  @override
  String get remove_from_playlist => 'ลบออกจากเพลย์ลิสต์';

  @override
  String get add_to_blacklist => 'เพิ่มลงในบัญชีดำ';

  @override
  String get remove_from_blacklist => 'ลบออกจากบัญชีดำ';

  @override
  String get share => 'แชร์';

  @override
  String get mini_player => 'มินิเพลเยอร์';

  @override
  String get slide_to_seek => 'เลื่อนเพื่อไปข้างหน้าหรือถอยหลัง';

  @override
  String get shuffle_playlist => 'สุ่มเพลย์ลิสต์';

  @override
  String get unshuffle_playlist => 'ยกเลิกการสุ่มเพลย์ลิสต์';

  @override
  String get previous_track => 'แทร็กก่อนหน้า';

  @override
  String get next_track => 'แทร็กถัดไป';

  @override
  String get pause_playback => 'หยุดการเล่น';

  @override
  String get resume_playback => 'เล่นต่อ';

  @override
  String get loop_track => 'วนเพลง';

  @override
  String get no_loop => 'ไม่มีการวนซ้ำ';

  @override
  String get repeat_playlist => 'ซ้ำเพลย์ลิสต์';

  @override
  String get queue => 'คิว';

  @override
  String get alternative_track_sources => 'แหล่งแทร็กอื่น';

  @override
  String get download_track => 'ดาวน์โหลดแทร็ก';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks แทร็กในคิว';
  }

  @override
  String get clear_all => 'ล้างทั้งหมด';

  @override
  String get show_hide_ui_on_hover => 'แสดง/ซ่อน UI เมื่อโฮเวอร์';

  @override
  String get always_on_top => 'อยู่ด้านบนเสมอ';

  @override
  String get exit_mini_player => 'ออกจากมินิเพลย์เยอร์';

  @override
  String get download_location => 'ตำแหน่งดาวน์โหลด';

  @override
  String get local_library => 'ห้องสมุดท้องถิ่น';

  @override
  String get add_library_location => 'เพิ่มในห้องสมุด';

  @override
  String get remove_library_location => 'ลบออกจากห้องสมุด';

  @override
  String get account => 'บัญชี';

  @override
  String get logout => 'ออกจากระบบ';

  @override
  String get logout_of_this_account => 'ออกจากระบบบัญชีนี้';

  @override
  String get language_region => 'ภาษาและภูมิภาค';

  @override
  String get language => 'ภาษา';

  @override
  String get system_default => 'ค่าเริ่มต้นของระบบ';

  @override
  String get market_place_region => 'ภูมิภาค Marketplace';

  @override
  String get recommendation_country => 'ประเทศที่แนะนำ';

  @override
  String get appearance => 'ลักษณะที่ปรากฏ';

  @override
  String get layout_mode => 'โหมดเค้าโครง';

  @override
  String get override_layout_settings =>
      'แทนที่การตั้งค่าโหมดเค้าโครงแบบตอบสนอง';

  @override
  String get adaptive => 'ปรับเปลี่ยน';

  @override
  String get compact => 'กระชับ';

  @override
  String get extended => 'ขยาย';

  @override
  String get theme => 'ธีม';

  @override
  String get dark => 'มืด';

  @override
  String get light => 'สว่าง';

  @override
  String get system => 'ระบบ';

  @override
  String get accent_color => 'สีเน้น';

  @override
  String get sync_album_color => 'ซิงค์สีอัลบั้ม';

  @override
  String get sync_album_color_description =>
      'ใช้สีเด่นของอาร์ตอัลบั้มเป็นสีเน้น';

  @override
  String get playback => 'การเล่น';

  @override
  String get audio_quality => 'คุณภาพเสียง';

  @override
  String get high => 'สูง';

  @override
  String get low => 'ต่ำ';

  @override
  String get pre_download_play => 'ดาวน์โหลดล่วงหน้าและเล่น';

  @override
  String get pre_download_play_description =>
      'แทนที่จะสตรีมเสียง ดาวน์โหลดข้อมูลและเล่นแทน (แนะนำสำหรับผู้ใช้แบนด์วิดธ์สูง)';

  @override
  String get skip_non_music => 'ข้ามส่วนที่ไม่ใช่เพลง (SponsorBlock)';

  @override
  String get blacklist_description => 'แทร็กและศิลปินที่บล็อก';

  @override
  String get wait_for_download_to_finish =>
      'โปรดรอให้การดาวน์โหลดปัจจุบันเสร็จสิ้น';

  @override
  String get desktop => 'เดสก์ท็อป';

  @override
  String get close_behavior => 'ปิดพฤติกรรม';

  @override
  String get close => 'ปิด';

  @override
  String get minimize_to_tray => 'ลดขนาดลงถาด';

  @override
  String get show_tray_icon => 'แสดงไอคอนถาดระบบ';

  @override
  String get about => 'เกี่ยวกับ';

  @override
  String get u_love_spotube => 'เรารู้ว่าคุณรัก DeeMusiq';

  @override
  String get check_for_updates => 'ตรวจสอบการปรับปรุง';

  @override
  String get about_spotube => 'เกี่ยวกับ DeeMusiq';

  @override
  String get blacklist => 'แบล็กลิสต์';

  @override
  String get please_sponsor => 'กรุณาสนับสนุน/บริจาค';

  @override
  String get spotube_description =>
      'DeeMusiq โปรแกรมเล่น Spotify ฟรีสำหรับทุกคน น้ำหนักเบา รองรับหลายแพลตฟอร์ม';

  @override
  String get version => 'รุ่น';

  @override
  String get build_number => 'หมายเลขบิลด์';

  @override
  String get founder => 'ผู้ก่อตั้ง';

  @override
  String get repository => 'ที่เก็บ';

  @override
  String get bug_issues => 'ข้อผิดพลาด+ปัญหา';

  @override
  String get made_with => 'ทำด้วย❤️ใน บังคลาเทศ🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'ใบอนุญาต';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'ไม่ต้องกังวล ข้อมูลรับรองใดๆ ของคุณจะไม่ถูกเก็บรวบรวมหรือแชร์กับใคร';

  @override
  String get know_how_to_login => 'ไม่รู้จักวิธีดำเนินการนี้ใช่ไหม';

  @override
  String get follow_step_by_step_guide => 'ทำตามคู่มือทีละขั้น';

  @override
  String cookie_name_cookie(Object name) {
    return 'คุกกี้ $name';
  }

  @override
  String get fill_in_all_fields => 'กรุณากรอกข้อมูลทุกช่อง';

  @override
  String get submit => 'ยื่น';

  @override
  String get exit => 'ออก';

  @override
  String get previous => 'ย้อนกลับ';

  @override
  String get next => 'ถัดไป';

  @override
  String get done => 'เสร็จ';

  @override
  String get step_1 => 'ขั้นที่ 1';

  @override
  String get first_go_to => 'ก่อนอื่น ไปที่';

  @override
  String get something_went_wrong => 'มีอะไรผิดพลาด';

  @override
  String get piped_instance => 'อินสแตนซ์เซิร์ฟเวอร์แบบ Pipe';

  @override
  String get piped_description =>
      'อินสแตนซ์เซิร์ฟเวอร์แบบ Pipe ที่ใช้สำหรับการจับคู่แทร็ก';

  @override
  String get piped_warning =>
      'บางอย่างอาจใช้งานไม่ได้ผล คุณจึงต้องรับความเสี่ยงเอง';

  @override
  String get invidious_instance => 'อินสแตนซ์เซิร์ฟเวอร์ Invidious';

  @override
  String get invidious_description =>
      'อินสแตนซ์เซิร์ฟเวอร์ Invidious ที่ใช้สำหรับการจับคู่เพลง';

  @override
  String get invidious_warning =>
      'บางอันอาจใช้งานไม่ดี ใช้ด้วยความเสี่ยงของคุณเอง';

  @override
  String get generate => 'สร้าง';

  @override
  String track_exists(Object track) {
    return 'แทร็ก $track มีอยู่แล้ว';
  }

  @override
  String get replace_downloaded_tracks => 'แทนที่แทร็กที่ดาวน์โหลดทั้งหมด';

  @override
  String get skip_download_tracks => 'ข้ามการดาวน์โหลดแทร็กที่ดาวน์โหลดทั้งหมด';

  @override
  String get do_you_want_to_replace => 'คุณต้องการแทนที่แทร็กที่มีอยู่หรือไม่';

  @override
  String get replace => 'แทนที่';

  @override
  String get skip => 'ข้าม';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'เลือกสูงสุด $count $type';
  }

  @override
  String get select_genres => 'เลือกประเภท';

  @override
  String get add_genres => 'เพิ่มประเภท';

  @override
  String get country => 'ประเทศ';

  @override
  String get number_of_tracks_generate => 'จำนวนแทร็กที่จะสร้าง';

  @override
  String get acousticness => 'อะคูสติก';

  @override
  String get danceability => 'ความสามารถในการเต้น';

  @override
  String get energy => 'พลัง';

  @override
  String get instrumentalness => 'บรรเลง';

  @override
  String get liveness => 'ความสด';

  @override
  String get loudness => 'ความดัง';

  @override
  String get speechiness => 'การพูด';

  @override
  String get valence => 'ความสุข';

  @override
  String get popularity => 'ความนิยม';

  @override
  String get key => 'คีย์';

  @override
  String get duration => 'ระยะเวลา (วินาที)';

  @override
  String get tempo => 'ความเร็ว (BPM)';

  @override
  String get mode => 'โหมด';

  @override
  String get time_signature => 'ลายเซ็นเวลา';

  @override
  String get short => 'สั้น';

  @override
  String get medium => 'กลาง';

  @override
  String get long => 'ยาว';

  @override
  String get min => 'ต่ำสุด';

  @override
  String get max => 'สูงสุด';

  @override
  String get target => 'เป้าหมาย';

  @override
  String get moderate => 'ปานกลาง';

  @override
  String get deselect_all => 'ยกเลิกการเลือกทั้งหมด';

  @override
  String get select_all => 'เลือกทั้งหมด';

  @override
  String get are_you_sure => 'คุณแน่ใจไหม?';

  @override
  String get generating_playlist => 'กำลังสร้างเพลย์ลิสต์ที่คุณกำหนดเอง...';

  @override
  String selected_count_tracks(Object count) {
    return 'เลือก $count แทร็ก';
  }

  @override
  String get download_warning =>
      'ถ้าคุณดาวน์โหลดเพลงทั้งหมดเป็นจำนวนมาก คุณกำลังละเมิดลิขสิทธิ์เพลงและสร้างความเสียหายให้กับสังคมดนตรี สร้างสรรค์ หวังว่าคุณจะรับรู้เรื่องนี้ เสมอ พยายามเคารพและสนับสนุนผลงานหนักของศิลปิน';

  @override
  String get download_ip_ban_warning =>
      'นอกเหนือจากนั้น IP ของคุณอาจถูกบล็อกบน YouTube เนื่องจากคำขอดาวน์โหลดมากเกินกว่าปกติ การบล็อก IP หมายความว่าคุณไม่สามารถใช้ YouTube (แม้ว่าคุณจะล็อกอินอยู่) เป็นเวลาอย่างน้อย 2-3 เดือนจากอุปกรณ์ IP นั้น และ DeeMusiq จะไม่รับผิดชอบใด ๆ หากสิ่งนี้เกิดขึ้น';

  @override
  String get by_clicking_accept_terms =>
      'คลิก \'ยอมรับ\' คุณยินยอมตามเงื่อนไขต่อไปนี้:';

  @override
  String get download_agreement_1 =>
      'ฉันรู้ว่าฉันกำลังละเมิดลิขสิทธิ์เพลง ฉันเลว';

  @override
  String get download_agreement_2 =>
      'ฉันจะสนับสนุนศิลปินทุกที่ที่ฉันทำได้และฉันทำสิ่งนี้เพียงเพราะฉันไม่มีเงินซื้อผลงานศิลปะของพวกเขา';

  @override
  String get download_agreement_3 =>
      'ฉันรับทราบอย่างสมบูรณ์ว่า IP ของฉันอาจถูกบล็อกบน YouTube และฉันจะไม่ถือ DeeMusiq หรือเจ้าของ/ผู้มีส่วนร่วมใด ๆ รับผิดชอบต่ออุบัติเหตุใด ๆ ที่เกิดจากการกระทำปัจจุบันของฉัน';

  @override
  String get decline => 'ปฏิเสธ';

  @override
  String get accept => 'ยอมรับ';

  @override
  String get details => 'รายละเอียด';

  @override
  String get youtube => 'youtube';

  @override
  String get channel => 'ช่อง';

  @override
  String get likes => 'ถูกใจ';

  @override
  String get dislikes => 'ไม่ชอบ';

  @override
  String get views => 'วิว';

  @override
  String get streamUrl => 'สตรีม URL';

  @override
  String get stop => 'หยุด';

  @override
  String get sort_newest => 'เรียงตามการเพิ่มใหม่ล่าสุด';

  @override
  String get sort_oldest => 'เรียงตามการเพิ่มเก่าสุด';

  @override
  String get sleep_timer => 'ตั้งเวลาปิด';

  @override
  String mins(Object minutes) {
    return '$minutes นาที';
  }

  @override
  String hours(Object hours) {
    return '$hours ชั่วโมง';
  }

  @override
  String hour(Object hours) {
    return '$hours ชั่วโมง';
  }

  @override
  String get custom_hours => 'ชั่วโมงที่กำหนดเอง';

  @override
  String get logs => 'บันทึก';

  @override
  String get developers => 'นักพัฒนา';

  @override
  String get not_logged_in => 'คุณไม่ได้เข้าสู่ระบบ';

  @override
  String get search_mode => 'โหมดการค้นหา';

  @override
  String get audio_source => 'แหล่งที่มาของเสียง';

  @override
  String get ok => 'ตกลง';

  @override
  String get failed_to_encrypt => 'เข้ารหัสล้มเหลว';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq ใช้การเข้ารหัสเพื่อเก็บข้อมูลของคุณอย่างปลอดภัย แต่ไม่สามารถทำได้ ดังนั้นจะเปลี่ยนเป็นการจัดเก็บที่ไม่ปลอดภัย\nหากคุณใช้ Linux โปรดตรวจสอบว่าคุณได้ติดตั้งบริการลับ (gnome-keyring, kde-wallet, keepassxc เป็นต้น)';

  @override
  String get querying_info => 'กำลังดึงข้อมูล...';

  @override
  String get piped_api_down => 'Piped API ไม่ทำงาน';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Piped instance $pipedInstance ไม่ทำงานขณะนี้\n\nเปลี่ยนอินสแตนซ์หรือเปลี่ยน \'ประเภท API\' เป็น YouTube API อย่างเป็นทางการ\n\nอย่าลืมรีสตาร์ทแอปหลังจากเปลี่ยน';
  }

  @override
  String get you_are_offline => 'คุณออฟไลน์อยู่';

  @override
  String get connection_restored =>
      'การเชื่อมต่ออินเทอร์เน็ตของคุณได้รับการกู้คืน';

  @override
  String get use_system_title_bar => 'ใช้แถบชื่อระบบ';

  @override
  String get crunching_results => 'กำลังประมวลผล...';

  @override
  String get search_to_get_results => 'ค้นหาเพื่อดูผลลัพธ์';

  @override
  String get use_amoled_mode => 'ธีมมืดสนิท';

  @override
  String get pitch_dark_theme => 'โหมด AMOLED';

  @override
  String get normalize_audio => 'ปรับระดับเสียง';

  @override
  String get change_cover => 'เปลี่ยนปก';

  @override
  String get add_cover => 'เพิ่มปก';

  @override
  String get restore_defaults => 'คืนค่าเริ่มต้น';

  @override
  String get download_music_format => 'รูปแบบการดาวน์โหลดเพลง';

  @override
  String get streaming_music_format => 'รูปแบบการสตรีมเพลง';

  @override
  String get download_music_quality => 'คุณภาพการดาวน์โหลด';

  @override
  String get streaming_music_quality => 'คุณภาพการสตรีม';

  @override
  String get login_with_lastfm => 'เข้าสู่ระบบด้วย Last.fm';

  @override
  String get connect => 'เชื่อมต่อ';

  @override
  String get disconnect_lastfm => 'ตัดการเชื่อมต่อ Last.fm';

  @override
  String get disconnect => 'ตัดการเชื่อมต่อ';

  @override
  String get username => 'ชื่อผู้ใช้';

  @override
  String get password => 'รหัสผ่าน';

  @override
  String get login => 'เข้าสู่ระบบ';

  @override
  String get login_with_your_lastfm => 'เข้าสู่ระบบด้วย Last.fm';

  @override
  String get scrobble_to_lastfm => 'Scrobble ไปเป็น Last.fm';

  @override
  String get go_to_album => 'ไปที่อัลบั้ม';

  @override
  String get discord_rich_presence => 'Discord Rich Presence';

  @override
  String get browse_all => 'เรียกดูทั้งหมด';

  @override
  String get genres => 'ประเภท';

  @override
  String get explore_genres => 'สำรวจประเภท';

  @override
  String get friends => 'เพื่อน';

  @override
  String get no_lyrics_available => 'ขออภัย ไม่พบเนื้อเพลงสำหรับเพลงนี้';

  @override
  String get start_a_radio => 'เปิดวิทยุ';

  @override
  String get how_to_start_radio => 'หากต้องการเปิดวิทยุฟังยังไง?';

  @override
  String get replace_queue_question =>
      'คุณต้องการแทนที่คิวปัจจุบันหรือเพิ่มเข้าไปหรือไม่';

  @override
  String get endless_playback => 'เล่นซ้ำ';

  @override
  String get delete_playlist => 'ลบเพลย์ลิสต์';

  @override
  String get delete_playlist_confirmation =>
      'คุณแน่ใจที่จะลบเพลย์ลิสต์นี้หรือไม่';

  @override
  String get local_tracks => 'เพลงในเครื่อง';

  @override
  String get local_tab => 'ท้องถิ่น';

  @override
  String get song_link => 'ลิงค์เพลง';

  @override
  String get youtube_source_description => 'แนะนำและใช้งานได้ดีที่สุด';

  @override
  String get piped_source_description =>
      'รู้สึกอิสระ? เหมือน YouTube แต่ฟรีกว่าเยอะ';

  @override
  String get jiosaavn_source_description => 'ดีที่สุดสำหรับภูมิภาคเอเชียใต้';

  @override
  String get invidious_source_description =>
      'คล้ายกับ Piped แต่มีความพร้อมใช้งานสูงกว่า';

  @override
  String highest_quality(Object quality) {
    return 'คุณภาพสูงสุด: $quality';
  }

  @override
  String get select_audio_source => 'เลือกแหล่งเสียง';

  @override
  String get contribute_on_github => 'มีส่วนร่วมบน GitHub';

  @override
  String get browse_anonymously => 'เรียกดูแบบไม่ระบุตัวตน';

  @override
  String get enable_connect => 'เปิดใช้งานการเชื่อมต่อ';

  @override
  String get enable_connect_description => 'ควบคุม DeeMusiq จากอุปกรณ์อื่น';

  @override
  String get devices => 'อุปกรณ์';

  @override
  String get select => 'เลือก';

  @override
  String connect_client_alert(Object client) {
    return 'คุณกำลังถูกควบคุมโดย $client';
  }

  @override
  String get this_device => 'อุปกรณ์นี้';

  @override
  String get remote => 'ระยะไกล';

  @override
  String get stats => 'สถิติ';

  @override
  String and_n_more(Object count) {
    return 'และ $count อีก';
  }

  @override
  String get recently_played => 'เพลงที่เพิ่งเล่น';

  @override
  String get browse_more => 'ดูเพิ่มเติม';

  @override
  String get no_title => 'ไม่มีชื่อ';

  @override
  String get not_playing => 'ไม่เล่น';

  @override
  String get epic_failure => 'ล้มเหลวอย่างยิ่ง!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'เพิ่ม $tracks_length เพลงในคิว';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq มีการอัปเดต';

  @override
  String get download_now => 'ดาวน์โหลดตอนนี้';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum ได้รับการปล่อยออกมา';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version ได้รับการปล่อยออกมา';
  }

  @override
  String get read_the_latest => 'อ่านข่าวสารล่าสุด ';

  @override
  String get release_notes => 'บันทึกการปล่อย';

  @override
  String get pick_color_scheme => 'เลือกธีมสี';

  @override
  String get save => 'บันทึก';

  @override
  String get choose_the_device => 'เลือกอุปกรณ์:';

  @override
  String get multiple_device_connected =>
      'มีอุปกรณ์เชื่อมต่อหลายเครื่อง\nเลือกอุปกรณ์ที่คุณต้องการให้การดำเนินการนี้เกิดขึ้น';

  @override
  String get nothing_found => 'ไม่พบข้อมูล';

  @override
  String get the_box_is_empty => 'กล่องว่างเปล่า';

  @override
  String get top_artists => 'ศิลปินยอดนิยม';

  @override
  String get top_albums => 'อัลบั้มยอดนิยม';

  @override
  String get this_week => 'สัปดาห์นี้';

  @override
  String get this_month => 'เดือนนี้';

  @override
  String get last_6_months => '6 เดือนที่ผ่านมา';

  @override
  String get this_year => 'ปีนี้';

  @override
  String get last_2_years => '2 ปีที่ผ่านมา';

  @override
  String get all_time => 'ตลอดกาล';

  @override
  String powered_by_provider(Object providerName) {
    return 'ขับเคลื่อนโดย $providerName';
  }

  @override
  String get email => 'อีเมล';

  @override
  String get profile_followers => 'ผู้ติดตาม';

  @override
  String get birthday => 'วันเกิด';

  @override
  String get subscription => 'การสมัครสมาชิก';

  @override
  String get not_born => 'ยังไม่เกิด';

  @override
  String get hacker => 'แฮ็กเกอร์';

  @override
  String get profile => 'โปรไฟล์';

  @override
  String get no_name => 'ไม่มีชื่อ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get user_profile => 'โปรไฟล์ผู้ใช้';

  @override
  String count_plays(Object count) {
    return '$count การเล่น';
  }

  @override
  String get minutes_listened => 'เวลาที่ฟัง';

  @override
  String get streamed_songs => 'เพลงที่สตรีม';

  @override
  String count_streams(Object count) {
    return '$count สตรีม';
  }

  @override
  String get owned_by_you => 'เป็นเจ้าของโดยคุณ';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl คัดลอกไปที่คลิปบอร์ดแล้ว';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes นาที';
  }

  @override
  String get summary_minutes => 'นาที';

  @override
  String get summary_listened_to_music => 'ฟังเพลง';

  @override
  String get summary_songs => 'เพลง';

  @override
  String get summary_streamed_overall => 'สตรีมทั้งหมด';

  @override
  String get summary_artists => 'ศิลปิน';

  @override
  String get summary_music_reached_you => 'เพลงมาถึงคุณ';

  @override
  String get summary_full_albums => 'อัลบั้มเต็ม';

  @override
  String get summary_got_your_love => 'ได้รับความรักของคุณ';

  @override
  String get summary_playlists => 'เพลย์ลิสต์';

  @override
  String get summary_were_on_repeat => 'อยู่ในโหมดซ้ำ';

  @override
  String get webview_not_found => 'ไม่พบ Webview';

  @override
  String get webview_not_found_description =>
      'ไม่พบ runtime ของ Webview บนอุปกรณ์ของคุณ\nหากติดตั้งแล้วตรวจสอบให้แน่ใจว่าอยู่ใน environment PATH\n\nหลังจากติดตั้งแล้ว ให้รีสตาร์ทแอป';

  @override
  String get unsupported_platform => 'แพลตฟอร์มไม่รองรับ';

  @override
  String get cache_music => 'แคชเพลง';

  @override
  String get open => 'เปิด';

  @override
  String get cache_folder => 'โฟลเดอร์แคช';

  @override
  String get export => 'ส่งออก';

  @override
  String get clear_cache => 'ล้างแคช';

  @override
  String get clear_cache_confirmation => 'คุณต้องการล้างแคชหรือไม่?';

  @override
  String get export_cache_files => 'ส่งออกไฟล์แคช';

  @override
  String found_n_files(Object count) {
    return 'พบ $count ไฟล์';
  }

  @override
  String get export_cache_confirmation => 'คุณต้องการส่งออกไฟล์เหล่านี้ไปยัง';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'ส่งออก $filesExported จาก $files ไฟล์';
  }

  @override
  String get undo => 'ย้อนกลับ';

  @override
  String get download_all => 'ดาวน์โหลดทั้งหมด';

  @override
  String get add_all_to_playlist => 'เพิ่มทั้งหมดในเพลย์ลิสต์';

  @override
  String get add_all_to_queue => 'เพิ่มทั้งหมดในคิว';

  @override
  String get play_all_next => 'เล่นทั้งหมดถัดไป';

  @override
  String get pause => 'หยุดชั่วคราว';

  @override
  String get view_all => 'ดูทั้งหมด';

  @override
  String get no_tracks_added_yet => 'ดูเหมือนคุณยังไม่ได้เพิ่มเพลงใด ๆ';

  @override
  String get no_tracks => 'ดูเหมือนจะไม่มีเพลงที่นี่';

  @override
  String get no_tracks_listened_yet => 'ดูเหมือนคุณยังไม่ได้ฟังอะไรเลย';

  @override
  String get not_following_artists => 'คุณไม่ได้ติดตามศิลปินใด ๆ';

  @override
  String get no_favorite_albums_yet =>
      'ดูเหมือนคุณยังไม่ได้เพิ่มอัลบัมใด ๆ ในรายการโปรด';

  @override
  String get no_logs_found => 'ไม่พบบันทึก';

  @override
  String get youtube_engine => 'เครื่องมือ YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine ยังไม่ได้ติดตั้ง';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine ยังไม่ได้ติดตั้งในระบบของคุณ';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'ตรวจสอบให้แน่ใจว่ามันมีอยู่ในตัวแปร PATH หรือ\nตั้งค่าพาธที่แท้จริงของไฟล์ที่สามารถทำงานได้ $engine ด้านล่าง';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'ใน macOS/Linux/Unix อย่าง OS การตั้งค่าพาธใน .zshrc/.bashrc/.bash_profile เป็นต้น จะไม่ทำงาน\nคุณต้องตั้งค่าพาธในไฟล์การกำหนดค่า shell';

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
  String get download => 'ดาวน์โหลด';

  @override
  String get file_not_found => 'ไม่พบไฟล์';

  @override
  String get custom => 'กำหนดเอง';

  @override
  String get add_custom_url => 'เพิ่ม URL แบบกำหนดเอง';

  @override
  String get edit_port => 'แก้ไขพอร์ต';

  @override
  String get port_helper_msg =>
      'ค่าเริ่มต้นคือ -1 ซึ่งหมายถึงหมายเลขสุ่ม หากคุณได้กำหนดค่าไฟร์วอลล์แล้ว แนะนำให้ตั้งค่านี้';

  @override
  String connect_request(Object client) {
    return 'อนุญาตให้ $client เชื่อมต่อหรือไม่?';
  }

  @override
  String get connection_request_denied =>
      'การเชื่อมต่อล้มเหลว ผู้ใช้ปฏิเสธการเข้าถึง';

  @override
  String get an_error_occurred => 'เกิดข้อผิดพลาด';

  @override
  String get copy_to_clipboard => 'คัดลอกไปยังคลิปบอร์ด';

  @override
  String get view_logs => 'ดูบันทึก';

  @override
  String get retry => 'ลองใหม่';

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
      'คุณไม่ได้ตั้งค่าผู้ให้บริการเมตาดาต้าเริ่มต้น';

  @override
  String get manage_metadata_providers => 'จัดการผู้ให้บริการเมตาดาต้า';

  @override
  String get open_link_in_browser => 'เปิดลิงก์ในเบราว์เซอร์หรือไม่?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'คุณต้องการเปิดลิงก์ต่อไปนี้หรือไม่';

  @override
  String get unsafe_url_warning =>
      'การเปิดลิงก์จากแหล่งที่ไม่น่าเชื่อถืออาจไม่ปลอดภัย โปรดระมัดระวัง!\nคุณยังสามารถคัดลอกลิงก์ไปยังคลิปบอร์ดของคุณได้';

  @override
  String get copy_link => 'คัดลอกลิงก์';

  @override
  String get building_your_timeline =>
      'กำลังสร้างไทม์ไลน์ของคุณตามการฟังของคุณ...';

  @override
  String get official => 'อย่างเป็นทางการ';

  @override
  String author_name(Object author) {
    return 'ผู้เขียน: $author';
  }

  @override
  String get third_party => 'บุคคลที่สาม';

  @override
  String get plugin_requires_authentication =>
      'ปลั๊กอินต้องมีการรับรองความถูกต้อง';

  @override
  String get update_available => 'มีการอัปเดต';

  @override
  String get supports_scrobbling => 'รองรับการ scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'ปลั๊กอินนี้จะ scrobble เพลงของคุณเพื่อสร้างประวัติการฟังของคุณ';

  @override
  String get default_metadata_source => 'แหล่งเมตาดาต้าพื้นฐาน';

  @override
  String get set_default_metadata_source => 'ตั้งค่าแหล่งเมตาดาต้าพื้นฐาน';

  @override
  String get default_audio_source => 'แหล่งเสียงพื้นฐาน';

  @override
  String get set_default_audio_source => 'ตั้งค่าแหล่งเสียงพื้นฐาน';

  @override
  String get set_default => 'ตั้งค่าเริ่มต้น';

  @override
  String get support => 'สนับสนุน';

  @override
  String get support_plugin_development => 'สนับสนุนการพัฒนาปลั๊กอิน';

  @override
  String can_access_name_api(Object name) {
    return '- สามารถเข้าถึง API **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'คุณต้องการติดตั้งปลั๊กอินนี้หรือไม่?';

  @override
  String get third_party_plugin_warning =>
      'ปลั๊กอินนี้มาจากที่เก็บของบุคคลที่สาม โปรดตรวจสอบให้แน่ใจว่าคุณเชื่อถือแหล่งที่มาก่อนทำการติดตั้ง';

  @override
  String get author => 'ผู้เขียน';

  @override
  String get this_plugin_can_do_following => 'ปลั๊กอินนี้สามารถทำสิ่งต่อไปนี้';

  @override
  String get install => 'ติดตั้ง';

  @override
  String get no_tracks_playing => 'ขณะนี้ไม่มีเพลงที่กำลังเล่นอยู่';

  @override
  String get synced_lyrics_not_available =>
      'ไม่มีเนื้อเพลงที่ซิงค์สำหรับเพลงนี้ กรุณาใช้แท็บ';

  @override
  String get plain_lyrics => 'เนื้อเพลงธรรมดา';

  @override
  String get tab_instead => 'แทน';

  @override
  String get disclaimer => 'ข้อสงวนสิทธิ์';

  @override
  String get third_party_plugin_dmca_notice =>
      'ทีม DeeMusiq ไม่รับผิดชอบใดๆ (รวมถึงทางกฎหมาย) สำหรับปลั๊กอิน \"บุคคลที่สาม\" ใดๆ\nโปรดใช้งานด้วยความเสี่ยงของคุณเอง สำหรับข้อบกพร่อง/ปัญหาใดๆ โปรดรายงานไปยังที่เก็บปลั๊กอิน\n\nหากปลั๊กอิน \"บุคคลที่สาม\" ใดๆ ละเมิด ToS/DMCA ของบริการ/นิติบุคคลใดๆ โปรดขอให้ผู้เขียนปลั๊กอิน \"บุคคลที่สาม\" หรือแพลตฟอร์มโฮสติ้ง เช่น GitHub/Codeberg ดำเนินการ ที่ระบุไว้ข้างต้น (ที่ติดป้าย \"บุคคลที่สาม\") เป็นปลั๊กอินสาธารณะ/ที่ดูแลโดยชุมชนทั้งหมด เราไม่ได้จัดการดูแล ดังนั้นเราจึงไม่สามารถดำเนินการใดๆ กับพวกเขาได้\n\n';

  @override
  String get plugins => 'ปลั๊กอิน';

  @override
  String get paste_plugin_download_url =>
      'วาง url ดาวน์โหลดหรือ url ที่เก็บ GitHub/Codeberg หรือลิงก์โดยตรงไปยังไฟล์ .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'ดาวน์โหลดและติดตั้งปลั๊กอินจาก url';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'ไม่สามารถเพิ่มปลั๊กอินได้: $error';
  }

  @override
  String get upload_plugin_from_file => 'อัปโหลดปลั๊กอินจากไฟล์';

  @override
  String get installed => 'ติดตั้งแล้ว';

  @override
  String get available_plugins => 'ปลั๊กอินที่มีอยู่';

  @override
  String get configure_plugins =>
      'กำหนดค่าปลั๊กอินผู้ให้บริการเมตาดาต้าและแหล่งเสียงของคุณเอง';

  @override
  String get audio_scrobblers => 'เครื่อง scrobbler เสียง';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'แหล่งที่มา: ';

  @override
  String get uncompressed => 'ไม่บีบอัด';

  @override
  String get dab_music_source_description =>
      'สำหรับคนรักเสียงเพลง ให้สตรีมเสียงคุณภาพสูง/ไร้การสูญเสียการบีบอัด การจับคู่แทร็กแม่นยำตาม ISRC';

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
  String get skip_this_nonsense => 'ข้ามสิ่งไร้สาระนี้';

  @override
  String get freedom_of_music => '“เสรีภาพแห่งเสียงเพลง”';

  @override
  String get freedom_of_music_palm => '“เสรีภาพแห่งเสียงเพลง ในมือของคุณ”';

  @override
  String get get_started => 'เริ่มต้น';

  @override
  String get endless_playback_description => 'เพิ่มเพลงใหม่ลงในคิวโดยอัตโนมัติ';

  @override
  String get choose_your_region => 'เลือกภูมิภาคของคุณ';

  @override
  String get choose_your_region_description =>
      'สิ่งนี้จะช่วยให้ DeeMusiq แสดงเนื้อหาที่เหมาะสมสำหรับคุณ';

  @override
  String get choose_your_language => 'เลือกภาษาของคุณ';

  @override
  String get help_project_grow => 'ช่วยให้โครงการนี้เติบโต';

  @override
  String get help_project_grow_description =>
      'DeeMusiq เป็นโครงการโอเพนซอร์ส คุณสามารถช่วยให้โครงการนี้เติบโตได้โดยการมีส่วนร่วมในโครงการ รายงานข้อบกพร่อง หรือเสนอคุณสมบัติใหม่';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'บริจาคบน Open Collective';

  @override
  String get install_a_metadata_provider => 'ติดตั้งผู้ให้บริการเมตาดาต้า';

  @override
  String get input_does_not_match_format => 'อินพุตไม่ตรงกับรูปแบบที่ต้องการ';

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
  String get auth_mfa_required => 'ป้อนรหัสยืนยันตัวตนของคุณ';

  @override
  String get auth_mfa_body =>
      'เปิดแอปตัวยืนยันตัวตนแล้วป้อนรหัส 6 หลักเพื่อเข้าสู่ระบบ';

  @override
  String get auth_mfa_verify_action => 'ยืนยัน';

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
