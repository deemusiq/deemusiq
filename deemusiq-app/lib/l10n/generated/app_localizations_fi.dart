// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get guest => 'Vieras';

  @override
  String get browse => 'Selaa';

  @override
  String get search => 'Hae';

  @override
  String get library => 'Kirjasto';

  @override
  String get lyrics => 'Lyriikat';

  @override
  String get settings => 'Asetukset';

  @override
  String get genre_categories_filter => 'Suodata kategorioita tai genrejä';

  @override
  String get genre => 'Genre';

  @override
  String get personalized => 'Personoidut';

  @override
  String get featured => 'Esittelyssä';

  @override
  String get new_releases => 'Uusi julkaisu';

  @override
  String get songs => 'Laulut';

  @override
  String playing_track(Object track) {
    return 'Soitetaan $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'Tämä tulee tyhjentämään jonon. $track_length Kappaleita poistetaan\nHaluatko jatkaa?';
  }

  @override
  String get load_more => 'Lataa lisää';

  @override
  String get playlists => 'Soittolistat';

  @override
  String get artists => 'Artistit';

  @override
  String get albums => 'Albumit';

  @override
  String get tracks => 'Kappaleet';

  @override
  String get downloads => 'Lataukset';

  @override
  String get filter_playlists => 'Suodata soittolistasi...';

  @override
  String get liked_tracks => 'Tykätyt kappaleet';

  @override
  String get liked_tracks_description => 'Kaikki tykättysi kappaleet';

  @override
  String get playlist => 'Soittolista';

  @override
  String get create_a_playlist => 'Luo soittolista';

  @override
  String get update_playlist => 'Päivitä soittolista';

  @override
  String get create => 'Luo';

  @override
  String get cancel => 'Peruuta';

  @override
  String get update => 'Päivitä';

  @override
  String get playlist_name => 'Soittolistan nimi';

  @override
  String get name_of_playlist => 'Soittolistan nimi';

  @override
  String get description => 'Kuvaus';

  @override
  String get public => 'Julkinen';

  @override
  String get collaborative => 'Collaborative';

  @override
  String get search_local_tracks => 'Hae paikallisia lauluja...';

  @override
  String get play => 'Soita';

  @override
  String get delete => 'Poista';

  @override
  String get none => 'Ei mitään';

  @override
  String get sort_a_z => 'Suodata A-Z';

  @override
  String get sort_z_a => 'Suodata Z-A';

  @override
  String get sort_artist => 'Suodata Artistilta';

  @override
  String get sort_album => 'Suodata Albumilta';

  @override
  String get sort_duration => 'Suodata Pituudelta';

  @override
  String get sort_tracks => 'Suodata Kappaleet';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Ladataan ($tracks_length)';
  }

  @override
  String get cancel_all => 'Peru kaikki';

  @override
  String get filter_artist => 'Suodata artistit...';

  @override
  String followers(Object followers) {
    return '$followers Seuraajaa';
  }

  @override
  String get add_artist_to_blacklist => 'Lisää artisti mustalle listalle';

  @override
  String get top_tracks => 'Suosituimmat kappaleet';

  @override
  String get fans_also_like => 'Fanit myös tykkäsivät';

  @override
  String get loading => 'Ladataan...';

  @override
  String get artist => 'Artisti';

  @override
  String get blacklisted => 'Mustalistattu';

  @override
  String get following => 'Seurataan';

  @override
  String get follow => 'Seuraa';

  @override
  String get artist_url_copied => 'Aristin URL kopioitiin leikepöytään';

  @override
  String added_to_queue(Object tracks) {
    return 'Lisättiin $tracks kappaletta jonoon';
  }

  @override
  String get filter_albums => 'Suodata albumit...';

  @override
  String get synced => 'Synkronoitu';

  @override
  String get plain => 'Tavallinen';

  @override
  String get shuffle => 'Sekoita';

  @override
  String get search_tracks => 'Hae kappaleita...';

  @override
  String get released => 'Julkaistu';

  @override
  String error(Object error) {
    return 'Virhe $error';
  }

  @override
  String get title => 'Otsikko';

  @override
  String get time => 'Aika';

  @override
  String get more_actions => 'Lisää toimintoja';

  @override
  String download_count(Object count) {
    return 'Lataa ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Lisää ($count) Soittolistaasi';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Lisää ($count) Jonoon';
  }

  @override
  String play_count_next(Object count) {
    return 'Soita ($count) seuraavaksi';
  }

  @override
  String get album => 'Albumi';

  @override
  String copied_to_clipboard(Object data) {
    return 'Kopioitiin $data leikepöytään';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Lisää $track seuraaviin soittolistoihin';
  }

  @override
  String get add => 'Lisää';

  @override
  String added_track_to_queue(Object track) {
    return 'Lisättiin $track jonoon';
  }

  @override
  String get add_to_queue => 'Lisää jonoon';

  @override
  String track_will_play_next(Object track) {
    return '$track Soitetaan seuraavaksi';
  }

  @override
  String get play_next => 'Soita seuraavaksi';

  @override
  String removed_track_from_queue(Object track) {
    return 'Poistettiin $track jonosta';
  }

  @override
  String get remove_from_queue => 'Poista jonosta';

  @override
  String get remove_from_favorites => 'Poista suosikeista';

  @override
  String get save_as_favorite => 'Tallenna soittolistana';

  @override
  String get add_to_playlist => 'Lisää soittolistaan';

  @override
  String get remove_from_playlist => 'Poista soittolistasta';

  @override
  String get add_to_blacklist => 'Lisää mustalle listalle';

  @override
  String get remove_from_blacklist => 'Poista mustalistalta';

  @override
  String get share => 'Jaa';

  @override
  String get mini_player => 'Minisoitin';

  @override
  String get slide_to_seek => 'Liu\'uta mennäkseen eteenpäin tai taaksepäin';

  @override
  String get shuffle_playlist => 'Sekoita soittolista';

  @override
  String get unshuffle_playlist => 'Poista sekoitus soittolistasta';

  @override
  String get previous_track => 'Äskeinen kappale';

  @override
  String get next_track => 'Seuraava kappale';

  @override
  String get pause_playback => 'Pysäytä soittolistan toisto';

  @override
  String get resume_playback => 'Jatka soittolistan toistoa';

  @override
  String get loop_track => 'Uudelleentoista kappale';

  @override
  String get no_loop => 'Ei silmukkaa';

  @override
  String get repeat_playlist => 'Toista soittolista uudelleen';

  @override
  String get queue => 'Jono';

  @override
  String get alternative_track_sources => 'Toinen kappale lähde';

  @override
  String get download_track => 'Lataa kappale';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks kappaletta jonossa';
  }

  @override
  String get clear_all => 'Tyhjennä kaikki';

  @override
  String get show_hide_ui_on_hover => 'Näytä/Piilota UI leijumalla';

  @override
  String get always_on_top => 'Aina päällimmäisenä';

  @override
  String get exit_mini_player => 'Lähde minisoittimesta';

  @override
  String get download_location => 'Lataus sijainti';

  @override
  String get local_library => 'Paikallinen kirjasto';

  @override
  String get add_library_location => 'Lisää kirjastoon';

  @override
  String get remove_library_location => 'Poista kirjastosta';

  @override
  String get account => 'Käyttäjä';

  @override
  String get logout => 'Kirjaudu ulos';

  @override
  String get logout_of_this_account => 'Kirjaudu ulos tältä käyttäjältä';

  @override
  String get language_region => 'Kieli ja Maa';

  @override
  String get language => 'Kieli';

  @override
  String get system_default => 'Järjestelmän oletus';

  @override
  String get market_place_region => 'Markkina-alue';

  @override
  String get recommendation_country => 'Suositeltu maa';

  @override
  String get appearance => 'Ulkomuto';

  @override
  String get layout_mode => 'Asettelutila';

  @override
  String get override_layout_settings =>
      'Jätä reagoiva asettelutila huomioimatta';

  @override
  String get adaptive => 'Mukautuva';

  @override
  String get compact => 'Kompakti';

  @override
  String get extended => 'Laajennettu';

  @override
  String get theme => 'Teema';

  @override
  String get dark => 'Tumma';

  @override
  String get light => 'Vaalea';

  @override
  String get system => 'Järjestelmä';

  @override
  String get accent_color => 'Korostusväri';

  @override
  String get sync_album_color => 'Synkronoi albumin väri';

  @override
  String get sync_album_color_description =>
      'Käyttää albumin kansitaiteen vallitsevaa väirä korostuvärinä';

  @override
  String get playback => 'Toisto';

  @override
  String get audio_quality => 'Äänenlaatu';

  @override
  String get high => 'Korkea';

  @override
  String get low => 'Matala';

  @override
  String get pre_download_play => 'Esilataa ja soita';

  @override
  String get pre_download_play_description =>
      'Audion suoratoiston sijaan, lataa tavut ja soita ne (Suositeltu korkeamman kaistanleveyden käyttäjille)';

  @override
  String get skip_non_music => 'Ohita ei-musiikki kohdat (SponsorBlock)';

  @override
  String get blacklist_description => 'Mustalistat kappaleet aja artistit';

  @override
  String get wait_for_download_to_finish =>
      'Odota nykyisen latauksen lopetteluun';

  @override
  String get desktop => 'Työpöytä';

  @override
  String get close_behavior => 'Sulkemisen käyttäytyminen';

  @override
  String get close => 'Sulje';

  @override
  String get minimize_to_tray => 'Minimisoi tehtäväpalkkiin';

  @override
  String get show_tray_icon => 'Näytä järjestelmäkuvake';

  @override
  String get about => 'Tietoa';

  @override
  String get u_love_spotube => 'Tiedämme että rakastat DeeMusiqa';

  @override
  String get check_for_updates => 'Tarkista päivitykset';

  @override
  String get about_spotube => 'Tietoa DeeMusiq:sta';

  @override
  String get blacklist => 'Mustalista';

  @override
  String get please_sponsor => 'Sponsoroi/Lahjoita, kiitos';

  @override
  String get spotube_description =>
      'DeeMusiq, kevyt, cross-platform, vapaa-kaikille spotify clientti';

  @override
  String get version => 'Versio';

  @override
  String get build_number => 'Rakennusnumero';

  @override
  String get founder => 'Perustaja';

  @override
  String get repository => 'Arkisto';

  @override
  String get bug_issues => 'Bugit+Ongelmat';

  @override
  String get made_with => 'Tehty ❤️ Bangladeshista 🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Lisenssi';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Älä huoli, tunnuksiasi ei talleteta tai jaeta kenenkään kanssa';

  @override
  String get know_how_to_login => 'Etkö tiedä miten tehdä tämä?';

  @override
  String get follow_step_by_step_guide => 'Seuraa askel askeleelta opasta';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Keksi';
  }

  @override
  String get fill_in_all_fields => 'Täytä kaikki kentät';

  @override
  String get submit => 'Lähetä';

  @override
  String get exit => 'Poistu';

  @override
  String get previous => 'Edellinen';

  @override
  String get next => 'Seuraava';

  @override
  String get done => 'Tehty';

  @override
  String get step_1 => 'Vaihe 1';

  @override
  String get first_go_to => 'Ensiksi, mene';

  @override
  String get something_went_wrong => 'Jotain meni pieleen';

  @override
  String get piped_instance => 'Johdettu palvelinesiintymä';

  @override
  String get piped_description =>
      'Johdettu palvelinesiintymä Kappale täsmäyksiin';

  @override
  String get piped_warning =>
      'Jotkut niistä eivät toimi hyvin, käytä siis omalla vastuullasi';

  @override
  String get invidious_instance => 'Invidious-palvelinesiintymä';

  @override
  String get invidious_description =>
      'Invidious-palvelinesiintymä raitojen yhteensovittamiseen';

  @override
  String get invidious_warning =>
      'Jotkin esiintymät eivät välttämättä toimi hyvin. Käytä omalla vastuullasi';

  @override
  String get generate => 'Luo';

  @override
  String track_exists(Object track) {
    return 'Kappale $track on jo olemassa!';
  }

  @override
  String get replace_downloaded_tracks => 'Korvaa kaikki ladatut kappaleet';

  @override
  String get skip_download_tracks => 'Ohita ladattujen laulujen lataaminen';

  @override
  String get do_you_want_to_replace =>
      'Haluatko korvata olemassa olevan kappaleen??';

  @override
  String get replace => 'Korvaa';

  @override
  String get skip => 'Ohita';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Valitse enintään $count $type';
  }

  @override
  String get select_genres => 'Valitse Genret';

  @override
  String get add_genres => 'Lisää Genrejä';

  @override
  String get country => 'Maa';

  @override
  String get number_of_tracks_generate => 'Numero tuotettavia kappaleita';

  @override
  String get acousticness => 'Akustisuus';

  @override
  String get danceability => 'Tanssittavuus';

  @override
  String get energy => 'Energia';

  @override
  String get instrumentalness => 'Instrumentaalisuus';

  @override
  String get liveness => 'Elävyyttä';

  @override
  String get loudness => 'Äänekkyys';

  @override
  String get speechiness => 'Puheisuus';

  @override
  String get valence => 'Valenssi';

  @override
  String get popularity => 'Suosio';

  @override
  String get key => 'Sävellaji';

  @override
  String get duration => 'Pituus (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Tila';

  @override
  String get time_signature => 'Aikamerkki';

  @override
  String get short => 'Lyhyt';

  @override
  String get medium => 'Keskikokoinen';

  @override
  String get long => 'Pitkä';

  @override
  String get min => 'Minimi';

  @override
  String get max => 'Maximi';

  @override
  String get target => 'Kohde';

  @override
  String get moderate => 'Kohtalainen';

  @override
  String get deselect_all => 'Poista kaikki valinnat';

  @override
  String get select_all => 'Valitse kaikki';

  @override
  String get are_you_sure => 'Oletko varma?';

  @override
  String get generating_playlist => 'Luodaan mukautettua soittolistoa...';

  @override
  String selected_count_tracks(Object count) {
    return 'Valittu $count kappaletta';
  }

  @override
  String get download_warning =>
      'Jos lataat kaikki laulut kerrällä olet selkeästi Piratoimassa ja aiheuttamassa vahinkoa musiikin luovaan yhteiskuntaan. Toivottavasti olet tietoinen tästä. Yritä aina kunnioittaa ja tukea Artistin kovaa työtä.';

  @override
  String get download_ip_ban_warning =>
      'BTW, YouTube voi estää IP-Osoitteesi tavallista liiallisten latauspyyntöjen takia. IP-Osoitteen esto tarkoittaa sitä, ettet voi käyttää YouTubea (vaikka olisit kirjautunut) vähintään 2-3kk aikana kyseiseltä laitteelta. DeeMusiq ei kanna yhtään vastuuta jos se tapahtuu.';

  @override
  String get by_clicking_accept_terms =>
      'Painamalla \'hyväksy\' hyväksyt seuraaviin ehtoihin:';

  @override
  String get download_agreement_1 =>
      'Tiedän että Piratoin musiikkia. Olen paha.';

  @override
  String get download_agreement_2 =>
      'Tuen Artisteja silloin kun pystyn, ja teen tämän vain koska minulla ei ole rahaa ostaa heidän taidetta';

  @override
  String get download_agreement_3 =>
      'Ymmärrän että minun YouTube voi estää IP-Osoitteeni ja en pidä DeeMusiqa tai omistajiinsa/avustajia vastuullisena mistään omista teoistsani';

  @override
  String get decline => 'Hylkää';

  @override
  String get accept => 'Hyväksy';

  @override
  String get details => 'Yksityiskohdat';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Kanava';

  @override
  String get likes => 'Tykkäykset';

  @override
  String get dislikes => 'Epä-tykkäykset';

  @override
  String get views => 'Näyttökerrat';

  @override
  String get streamUrl => 'Suoratoiston URL';

  @override
  String get stop => 'Lopeta';

  @override
  String get sort_newest => 'Suodata uusimmista';

  @override
  String get sort_oldest => 'Suodata vanhimmista';

  @override
  String get sleep_timer => 'Uniajastin';

  @override
  String mins(Object minutes) {
    return '$minutes Minuuttia';
  }

  @override
  String hours(Object hours) {
    return '$hours Tuntia';
  }

  @override
  String hour(Object hours) {
    return '$hours Tunti';
  }

  @override
  String get custom_hours => 'Mukautetut tunnit';

  @override
  String get logs => 'Lokit';

  @override
  String get developers => 'Kehittäjät';

  @override
  String get not_logged_in => 'Et ole kirjautunut sisään.';

  @override
  String get search_mode => 'Hakutila';

  @override
  String get audio_source => 'Äänilähde';

  @override
  String get ok => 'Ok';

  @override
  String get failed_to_encrypt => 'Salaaminen epäonnistui';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq käyttää salausta tallentaakseen tietosi, mutta epäonnistui, joten se palaa epäturvalliseen tallennukseen\nJos käytät Linuxia, varmista että sinulla on turvallisuuspalvelu (gnome-keyring, kde-wallet, keepassxc jne) asennettu';

  @override
  String get querying_info => 'Hankitaan tietoa...';

  @override
  String get piped_api_down => 'Johdettu palvelinesiintymä on alhaalla';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Johdettu palvelinesiintymä $pipedInstance on alhaalla.\n\nVaihda joko ilmeytymä tia vahda \'API tyyppi\' YouTuben viralliseen API\n\nKäynnistä sovellus uudestaan vaihdon jälkeen';
  }

  @override
  String get you_are_offline => 'Et ole yhdistetty verkkoon';

  @override
  String get connection_restored => 'Verkkoyhteys palautettu';

  @override
  String get use_system_title_bar => 'Käytä järjestelmäpalkkia';

  @override
  String get crunching_results => 'Paloitellaan tuloksia...';

  @override
  String get search_to_get_results => 'Hae saadakseen tuloksia';

  @override
  String get use_amoled_mode => 'Pilkkopimeä tumma teema';

  @override
  String get pitch_dark_theme => 'AMOLED Tila';

  @override
  String get normalize_audio => 'Normalisoi audio';

  @override
  String get change_cover => 'Vaihda koveri';

  @override
  String get add_cover => 'Lisää koveri';

  @override
  String get restore_defaults => 'Palauta oletukset';

  @override
  String get download_music_format => 'Musiikin latausmuoto';

  @override
  String get streaming_music_format => 'Musiikin suoratoistomuoto';

  @override
  String get download_music_quality => 'Musiikin latauslaatu';

  @override
  String get streaming_music_quality => 'Musiikin suoratoistolaadun';

  @override
  String get login_with_lastfm => 'Kirjaudu sisään Last.fm:llä';

  @override
  String get connect => 'Yhdistä';

  @override
  String get disconnect_lastfm => 'Katkaise Last.fm';

  @override
  String get disconnect => 'Katkaise';

  @override
  String get username => 'Käyttäjänimi';

  @override
  String get password => 'Salasana';

  @override
  String get login => 'Kirjaudu';

  @override
  String get login_with_your_lastfm => 'Kirjaudu Last.fm käyttäjälläsi';

  @override
  String get scrobble_to_lastfm => 'Scrobble Last.fm:ään';

  @override
  String get go_to_album => 'Mene albumiin';

  @override
  String get discord_rich_presence => 'Discord Rich Presence';

  @override
  String get browse_all => 'Selaa kaikki';

  @override
  String get genres => 'Genret';

  @override
  String get explore_genres => 'Seikkaile genrejä';

  @override
  String get friends => 'Kaverit';

  @override
  String get no_lyrics_available =>
      'Anteeksi, emme löytäneet lyriikoita tälle laululle';

  @override
  String get start_a_radio => 'Aloita Radio';

  @override
  String get how_to_start_radio => 'Kuinka haluat aloittaa radion?';

  @override
  String get replace_queue_question =>
      'Haluatko korvata nykyisen jonon vai lisätä siihen?';

  @override
  String get endless_playback => 'Loputon toisto';

  @override
  String get delete_playlist => 'Poista soittolista';

  @override
  String get delete_playlist_confirmation =>
      'Oletko varma että haluat poistaa tämän soittolistan?';

  @override
  String get local_tracks => 'Paikalliset kappaleet';

  @override
  String get local_tab => 'Paikallinen';

  @override
  String get song_link => 'Laulun linkki';

  @override
  String get youtube_source_description => 'Suositeltu ja toimii parhaiten.';

  @override
  String get piped_source_description =>
      'Tuntuuko vapaalta? Sama kuin YouTube mutta paljon vapautta';

  @override
  String get jiosaavn_source_description => 'Paras Etelä-Aasian alueelle.';

  @override
  String get invidious_source_description =>
      'Samankaltainen kuin Piped, mutta korkeammalla saatavuudella';

  @override
  String highest_quality(Object quality) {
    return 'Korkein laatu: $quality';
  }

  @override
  String get select_audio_source => 'Valitse äänilähde';

  @override
  String get contribute_on_github => 'Auta GitHub:ssa';

  @override
  String get browse_anonymously => 'Selaa anonyyminä';

  @override
  String get enable_connect => 'Ota käyttöön yhdistäminen';

  @override
  String get enable_connect_description =>
      'Ohjaa DeeMusiqa toiselta laitteelta';

  @override
  String get devices => 'Laitteet';

  @override
  String get select => 'Valitse';

  @override
  String connect_client_alert(Object client) {
    return '$client ohjaa sinua';
  }

  @override
  String get this_device => 'Tämä laite';

  @override
  String get remote => 'Etä';

  @override
  String get stats => 'Tilastot';

  @override
  String and_n_more(Object count) {
    return 'ja $count lisää';
  }

  @override
  String get recently_played => 'Äskettäin soitetut';

  @override
  String get browse_more => 'Selaa lisää';

  @override
  String get no_title => 'Ei otsikkoa';

  @override
  String get not_playing => 'Ei soi';

  @override
  String get epic_failure => 'Epäonnistuminen!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Lisätty $tracks_length kappaletta jonoon';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiqlla on päivitys';

  @override
  String get download_now => 'Lataa nyt';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum on julkaistu';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version on julkaistu';
  }

  @override
  String get read_the_latest => 'Lue viimeisimmät';

  @override
  String get release_notes => 'julkaisumuistiinpanot';

  @override
  String get pick_color_scheme => 'Valitse värimaailma';

  @override
  String get save => 'Tallenna';

  @override
  String get choose_the_device => 'Valitse laite:';

  @override
  String get multiple_device_connected =>
      'Useita laitteita on kytketty.\nValitse laite, jossa haluat toiminnon suorittaa';

  @override
  String get nothing_found => 'Ei tuloksia';

  @override
  String get the_box_is_empty => 'Laatikko on tyhjä';

  @override
  String get top_artists => 'Suosituimmat artistit';

  @override
  String get top_albums => 'Suosituimmat albumit';

  @override
  String get this_week => 'Tällä viikolla';

  @override
  String get this_month => 'Tässä kuussa';

  @override
  String get last_6_months => 'Viimeiset 6 kuukautta';

  @override
  String get this_year => 'Tänä vuonna';

  @override
  String get last_2_years => 'Viimeiset 2 vuotta';

  @override
  String get all_time => 'Kaikki ajat';

  @override
  String powered_by_provider(Object providerName) {
    return 'Tuottanut $providerName';
  }

  @override
  String get email => 'Sähköposti';

  @override
  String get profile_followers => 'Seuraajat';

  @override
  String get birthday => 'Syntymäpäivä';

  @override
  String get subscription => 'Tilaus';

  @override
  String get not_born => 'Ei syntynyt';

  @override
  String get hacker => 'Hakkeri';

  @override
  String get profile => 'Profiili';

  @override
  String get no_name => 'Ei nimeä';

  @override
  String get edit => 'Muokkaa';

  @override
  String get user_profile => 'Käyttäjäprofiili';

  @override
  String count_plays(Object count) {
    return '$count toistoa';
  }

  @override
  String get minutes_listened => 'Kuunneltuja minuutteja';

  @override
  String get streamed_songs => 'Suoratoistettuja kappaleita';

  @override
  String count_streams(Object count) {
    return '$count suoratoistoa';
  }

  @override
  String get owned_by_you => 'Sinun omistama';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl kopioitu leikepöydälle';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes min';
  }

  @override
  String get summary_minutes => 'minuuttia';

  @override
  String get summary_listened_to_music => 'Kuunneltu musiikkia';

  @override
  String get summary_songs => 'kappaletta';

  @override
  String get summary_streamed_overall => 'Suoratoistettu yhteensä';

  @override
  String get summary_artists => 'artisti';

  @override
  String get summary_music_reached_you => 'Musiikki saavutti sinut';

  @override
  String get summary_full_albums => 'täydet albumit';

  @override
  String get summary_got_your_love => 'Sai rakkautesi';

  @override
  String get summary_playlists => 'soittolistat';

  @override
  String get summary_were_on_repeat => 'Olivat toistossa';

  @override
  String get webview_not_found => 'Webview ei löydy';

  @override
  String get webview_not_found_description =>
      'Laitteellasi ei ole asennettua Webview-ajonaikaa.\nJos se on asennettu, varmista, että se on environment PATH:ssa\n\nAsennuksen jälkeen käynnistä sovellus uudelleen';

  @override
  String get unsupported_platform => 'Ei tuettu alusta';

  @override
  String get cache_music => 'Musiikki välimuistissa';

  @override
  String get open => 'Avaa';

  @override
  String get cache_folder => 'Välimuistikansio';

  @override
  String get export => 'Vie';

  @override
  String get clear_cache => 'Tyhjennä välimuisti';

  @override
  String get clear_cache_confirmation => 'Haluatko tyhjentää välimuistin?';

  @override
  String get export_cache_files => 'Vie välimuistitiedostot';

  @override
  String found_n_files(Object count) {
    return 'Löydettiin $count tiedostoa';
  }

  @override
  String get export_cache_confirmation => 'Haluatko viedä nämä tiedostot';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'Vietiin $filesExported/$files tiedostoa';
  }

  @override
  String get undo => 'Peruuta';

  @override
  String get download_all => 'Lataa kaikki';

  @override
  String get add_all_to_playlist => 'Lisää kaikki soittolistalle';

  @override
  String get add_all_to_queue => 'Lisää kaikki jonoon';

  @override
  String get play_all_next => 'Toista kaikki seuraavaksi';

  @override
  String get pause => 'Pysäytä';

  @override
  String get view_all => 'Näytä kaikki';

  @override
  String get no_tracks_added_yet =>
      'Näyttää siltä, että et ole lisännyt vielä mitään kappaleita.';

  @override
  String get no_tracks => 'Näyttää siltä, että täällä ei ole kappaleita.';

  @override
  String get no_tracks_listened_yet =>
      'Näyttää siltä, että et ole kuunnellut mitään vielä.';

  @override
  String get not_following_artists => 'Et seuraa yhtään artistia.';

  @override
  String get no_favorite_albums_yet =>
      'Näyttää siltä, että et ole lisännyt yhtään albumia suosikkeihisi.';

  @override
  String get no_logs_found => 'Ei lokitietoja löydetty';

  @override
  String get youtube_engine => 'YouTube-moottori';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine ei ole asennettu';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine ei ole asennettu järjestelmääsi.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Varmista, että se on saatavilla PATH-muuttujassa tai\nasetetaan $engine suoritettavan tiedoston absoluuttinen polku alla.';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'macOS/Linux/unix-tyyppisissä käyttöjärjestelmissä polun asettaminen .zshrc/.bashrc/.bash_profile jne. ei toimi.\nSinun täytyy asettaa polku shellin asetustiedostoon.';

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
  String get download => 'Lataa';

  @override
  String get file_not_found => 'Tiedostoa ei löydy';

  @override
  String get custom => 'Mukautettu';

  @override
  String get add_custom_url => 'Lisää mukautettu URL';

  @override
  String get edit_port => 'Muokkaa porttia';

  @override
  String get port_helper_msg =>
      'Oletusarvo on -1, mikä tarkoittaa satunnaista numeroa. Jos sinulla on palomuuri määritetty, tämän asettamista suositellaan.';

  @override
  String connect_request(Object client) {
    return 'Salli $client yhdistää?';
  }

  @override
  String get connection_request_denied =>
      'Yhteys evätty. Käyttäjä eväsi pääsyn.';

  @override
  String get an_error_occurred => 'Tapahtui virhe';

  @override
  String get copy_to_clipboard => 'Kopioi leikepöydälle';

  @override
  String get view_logs => 'Näytä lokit';

  @override
  String get retry => 'Yritä uudelleen';

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
      'Et ole asettanut oletusmetatietojen tarjoajaa';

  @override
  String get manage_metadata_providers => 'Hallinnoi metatietojen tarjoajia';

  @override
  String get open_link_in_browser => 'Avaa linkki selaimessa?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Haluatko avata seuraavan linkin';

  @override
  String get unsafe_url_warning =>
      'Linkkien avaaminen epäluotettavista lähteistä voi olla vaarallista. Ole varovainen!\nVoit myös kopioida linkin leikepöydälle.';

  @override
  String get copy_link => 'Kopioi linkki';

  @override
  String get building_your_timeline =>
      'Rakennetaan aikajanaasi kuuntelujesi perusteella...';

  @override
  String get official => 'Virallinen';

  @override
  String author_name(Object author) {
    return 'Tekijä: $author';
  }

  @override
  String get third_party => 'Kolmannen osapuolen';

  @override
  String get plugin_requires_authentication => 'Lisäosa vaatii todentamisen';

  @override
  String get update_available => 'Päivitys saatavilla';

  @override
  String get supports_scrobbling => 'Tukee scrobblingia';

  @override
  String get plugin_scrobbling_info =>
      'Tämä lisäosa scrobblaa musiikkisi luodakseen kuunteluhistoriasi.';

  @override
  String get default_metadata_source => 'Oletusarvoinen metatietolähde';

  @override
  String get set_default_metadata_source => 'Aseta oletusmetatietolähde';

  @override
  String get default_audio_source => 'Oletusarvoinen äänilähde';

  @override
  String get set_default_audio_source => 'Aseta oletusäänilähde';

  @override
  String get set_default => 'Aseta oletukseksi';

  @override
  String get support => 'Tuki';

  @override
  String get support_plugin_development => 'Tue lisäosan kehitystä';

  @override
  String can_access_name_api(Object name) {
    return '- Voi käyttää **$name** APIa';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Haluatko asentaa tämän lisäosan?';

  @override
  String get third_party_plugin_warning =>
      'Tämä lisäosa on kolmannen osapuolen arkistosta. Varmista, että luotat lähteeseen ennen asennusta.';

  @override
  String get author => 'Tekijä';

  @override
  String get this_plugin_can_do_following => 'Tämä lisäosa voi tehdä seuraavaa';

  @override
  String get install => 'Asenna';

  @override
  String get no_tracks_playing => 'Ei kappaletta toistossa tällä hetkellä';

  @override
  String get synced_lyrics_not_available =>
      'Synkronoidut sanoitukset eivät ole saatavilla tälle kappaleelle. Käytä sen sijaan';

  @override
  String get plain_lyrics => 'Pelkät sanoitukset';

  @override
  String get tab_instead => 'välilehteä.';

  @override
  String get disclaimer => 'Vastuuvapauslauseke';

  @override
  String get third_party_plugin_dmca_notice =>
      'DeeMusiq-tiimi ei ota mitään vastuuta (mukaan lukien oikeudellinen) mistään \"kolmannen osapuolen\" lisäosista.\nKäytä niitä omalla vastuullasi. Ilmoita kaikista virheistä/ongelmista lisäosan arkistoon.\n\nJos jokin \"kolmannen osapuolen\" lisäosa rikkoo jonkin palvelun/oikeushenkilön käyttöehtoja/DMCA:ta, pyydä \"kolmannen osapuolen\" lisäosan tekijää tai isännöintialustaa, esim. GitHubia/Codebergiä, ryhtymään toimiin. Yllä luetellut (\"kolmannen osapuolen\" merkityt) ovat kaikki julkisia/yhteisön ylläpitämiä lisäosia. Emme kuratoi niitä, joten emme voi ryhtyä niihin toimiin.\n\n';

  @override
  String get plugins => 'Laajennukset';

  @override
  String get paste_plugin_download_url =>
      'Liitä lataus-URL-osoite tai GitHub/Codeberg-arkiston URL-osoite tai suora linkki .smplug-tiedostoon';

  @override
  String get download_and_install_plugin_from_url =>
      'Lataa ja asenna lisäosa URL-osoitteesta';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Lisäosan lisääminen epäonnistui: $error';
  }

  @override
  String get upload_plugin_from_file => 'Lataa lisäosa tiedostosta';

  @override
  String get installed => 'Asennettu';

  @override
  String get available_plugins => 'Saatavilla olevat lisäosat';

  @override
  String get configure_plugins =>
      'Määritä omat metatietojen tarjoaja- ja äänilähdelaajennukset';

  @override
  String get audio_scrobblers => 'Äänen scrobblerit';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Lähde: ';

  @override
  String get uncompressed => 'Pakkaamaton';

  @override
  String get dab_music_source_description =>
      'Audiofiileille. Tarjoaa korkealaatuisia/häviöttömiä äänivirtoja. Tarkka ISRC-pohjainen kappaleiden tunnistus.';

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
  String get skip_this_nonsense => 'Ohita tämä hölynpöly';

  @override
  String get freedom_of_music => '“Musiikin vapaus”';

  @override
  String get freedom_of_music_palm => '“Musiikin vapaus käsissäsi”';

  @override
  String get get_started => 'Aloitetaan';

  @override
  String get endless_playback_description =>
      'Lisää automaattisesti uusia lauluja\njonon perään';

  @override
  String get choose_your_region => 'Valitse alueesi';

  @override
  String get choose_your_region_description =>
      'Tämä auttaa DeeMusiq näyttämään sinulle oikeaa sisältöä\nsijaintiasi varten.';

  @override
  String get choose_your_language => 'Valitse kielesi';

  @override
  String get help_project_grow => 'Auta tätä projektia kasvamaan';

  @override
  String get help_project_grow_description =>
      'DeeMusiq projekti minkä lähdekoodi on julkisesti saatavilla. Voit autta tätä projektia kasvamaan muutoksilla, ilmoittamalla bugeista, tai ehdottamalla uusia ominaisuuksia.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Lahjoita avoimessa kollektiivissa';

  @override
  String get install_a_metadata_provider => 'Asenna metatietojen tarjoaja';

  @override
  String get input_does_not_match_format => 'Syöte ei vastaa vaadittua muotoa';

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
  String get auth_mfa_required => 'Syötä todennuskoodisi';

  @override
  String get auth_mfa_body =>
      'Avaa tunnistussovellus ja syötä 6-numeroinen koodi jatkaaksesi kirjautumista.';

  @override
  String get auth_mfa_verify_action => 'Vahvista';

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
