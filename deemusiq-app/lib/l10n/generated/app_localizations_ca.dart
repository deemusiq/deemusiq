// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get guest => 'Convidat';

  @override
  String get browse => 'Explorar';

  @override
  String get search => 'Cercar';

  @override
  String get library => 'Biblioteca';

  @override
  String get lyrics => 'Lletres';

  @override
  String get settings => 'Configuració';

  @override
  String get genre_categories_filter => 'Filtrar categories o gèneres...';

  @override
  String get genre => 'Gènere';

  @override
  String get personalized => 'Personalizat';

  @override
  String get featured => 'Destacat';

  @override
  String get new_releases => 'Nous Llançaments';

  @override
  String get songs => 'Cançons';

  @override
  String playing_track(Object track) {
    return 'Reproduint $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'Això eliminarà la llista actual. S\'eliminaran $track_length cançons.\n¿Vol continuar?';
  }

  @override
  String get load_more => 'Carregar més';

  @override
  String get playlists => 'Llistes de reproducció';

  @override
  String get artists => 'Artistes';

  @override
  String get albums => 'Àlbums';

  @override
  String get tracks => 'Cançons';

  @override
  String get downloads => 'Descàrregues';

  @override
  String get filter_playlists => 'Filtrar les seves llistes de reproducció...';

  @override
  String get liked_tracks => 'Cançons Preferides';

  @override
  String get liked_tracks_description => 'Totes les seves cançons preferides';

  @override
  String get playlist => 'Llista de reproducció';

  @override
  String get create_a_playlist => 'Crear una llista de reproducció';

  @override
  String get update_playlist => 'Actualitzar la llista de reproducció';

  @override
  String get create => 'Crear';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get update => 'Actualitzar';

  @override
  String get playlist_name => 'Nom de la llista';

  @override
  String get name_of_playlist => 'Nom de la lista';

  @override
  String get description => 'Descripció';

  @override
  String get public => 'Pública';

  @override
  String get collaborative => 'Col·laborativa';

  @override
  String get search_local_tracks => 'Cercar cançons locals...';

  @override
  String get play => 'Reproduir';

  @override
  String get delete => 'Eliminar';

  @override
  String get none => 'Cap';

  @override
  String get sort_a_z => 'Ordenar de la A a la Z';

  @override
  String get sort_z_a => 'Ordenar de la Z a la A';

  @override
  String get sort_artist => 'Ordenar per Artista';

  @override
  String get sort_album => 'Ordenar per Àlbum';

  @override
  String get sort_duration => 'Ordenar per Durada';

  @override
  String get sort_tracks => 'Ordenar Cançons';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Descàrrega en curs ($tracks_length)';
  }

  @override
  String get cancel_all => 'Cancel·lar todo';

  @override
  String get filter_artist => 'Filtrar artistes...';

  @override
  String followers(Object followers) {
    return '$followers Seguidors';
  }

  @override
  String get add_artist_to_blacklist => 'Afegir artista a la llista negra';

  @override
  String get top_tracks => 'Millors Cançons';

  @override
  String get fans_also_like => 'Als fans també els hi agrada';

  @override
  String get loading => 'Carregant...';

  @override
  String get artist => 'Artista';

  @override
  String get blacklisted => 'A la llista negra';

  @override
  String get following => 'Seguint';

  @override
  String get follow => 'Seguir';

  @override
  String get artist_url_copied => 'URL de l\'artista copiada al porta-retalls ';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks cançons afegides a la llista';
  }

  @override
  String get filter_albums => 'Filtrar àlbums...';

  @override
  String get synced => 'Sincronitzat';

  @override
  String get plain => 'Normal';

  @override
  String get shuffle => 'Aleatori';

  @override
  String get search_tracks => 'Buscar cançons...';

  @override
  String get released => 'Publicat';

  @override
  String error(Object error) {
    return 'Error $error';
  }

  @override
  String get title => 'Títul';

  @override
  String get time => 'Duració';

  @override
  String get more_actions => 'Més accios';

  @override
  String download_count(Object count) {
    return 'Descarregar ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Afegir ($count) a la llista de reproducció';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Agregar ($count) a la llista';
  }

  @override
  String play_count_next(Object count) {
    return 'Reproduir ($count) a continuació';
  }

  @override
  String get album => 'Àlbum';

  @override
  String copied_to_clipboard(Object data) {
    return '$data copiado al porta-retalls';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Afegir $track a les llistes de reproducció següents';
  }

  @override
  String get add => 'Afegir';

  @override
  String added_track_to_queue(Object track) {
    return '$track afegida a la llista';
  }

  @override
  String get add_to_queue => 'Afegir a la llista';

  @override
  String track_will_play_next(Object track) {
    return '$track es reproduirà a continuació';
  }

  @override
  String get play_next => 'Reproduir a continuació';

  @override
  String removed_track_from_queue(Object track) {
    return '$track eliminada de la llista';
  }

  @override
  String get remove_from_queue => 'Eliminar de la llista';

  @override
  String get remove_from_favorites => 'Eliminar de preferits';

  @override
  String get save_as_favorite => 'Guardar a preferits';

  @override
  String get add_to_playlist => 'Afegir a la llista de reproducció';

  @override
  String get remove_from_playlist => 'Eliminar de la llista de reproducció';

  @override
  String get add_to_blacklist => 'Afegir a la llista negra';

  @override
  String get remove_from_blacklist => 'Eliminar de la llista negra';

  @override
  String get share => 'Compartir';

  @override
  String get mini_player => 'Reproductor Petit';

  @override
  String get slide_to_seek => 'Lliscar per cercar endavant o endarrere';

  @override
  String get shuffle_playlist => 'Mesclar la llista de reproducció';

  @override
  String get unshuffle_playlist => 'No mesclar la llista de reproducció';

  @override
  String get previous_track => 'Cançó anterior';

  @override
  String get next_track => 'Canço següent';

  @override
  String get pause_playback => 'Pausar reproducció';

  @override
  String get resume_playback => 'Continuar reproducció';

  @override
  String get loop_track => 'Repetir canço';

  @override
  String get no_loop => 'Sense repetició';

  @override
  String get repeat_playlist => 'Repetir la llista de reproducció';

  @override
  String get queue => 'Llista';

  @override
  String get alternative_track_sources => 'Fonts alternatives de cançons';

  @override
  String get download_track => 'Descarregar cançó';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks cançons a la llista';
  }

  @override
  String get clear_all => 'Netejar tot';

  @override
  String get show_hide_ui_on_hover =>
      'Mostrar/Ocultar interfície al passar el cursor';

  @override
  String get always_on_top => 'Sempre visible';

  @override
  String get exit_mini_player => 'Sortir del reproductor petit';

  @override
  String get download_location => 'Ubicació de descàrregues';

  @override
  String get local_library => 'Biblioteca local';

  @override
  String get add_library_location => 'Afegeix a la biblioteca';

  @override
  String get remove_library_location => 'Elimina de la biblioteca';

  @override
  String get account => 'Compte';

  @override
  String get logout => 'Tancar sessió';

  @override
  String get logout_of_this_account => 'Tancar sessió d\'aquest compte';

  @override
  String get language_region => 'Idioma i Regió';

  @override
  String get language => 'Idioma';

  @override
  String get system_default => 'Predeterminat del sistema';

  @override
  String get market_place_region => 'Regió de la botiga';

  @override
  String get recommendation_country => 'País de recomanació';

  @override
  String get appearance => 'Apariència';

  @override
  String get layout_mode => 'Mode de disseny';

  @override
  String get override_layout_settings =>
      'Anul·leu la configuració del mode de disseny responsiu';

  @override
  String get adaptive => 'Adaptable';

  @override
  String get compact => 'Compacte';

  @override
  String get extended => 'Extès';

  @override
  String get theme => 'Tema';

  @override
  String get dark => 'Fosc';

  @override
  String get light => 'Clar';

  @override
  String get system => 'Sistema';

  @override
  String get accent_color => 'Color d\'accent';

  @override
  String get sync_album_color => 'Sincronitzar color de l\'àlbum';

  @override
  String get sync_album_color_description =>
      'Utilitza el color dominant de l\'álbum com a color d\'accent';

  @override
  String get playback => 'Reproducció';

  @override
  String get audio_quality => 'Qualitat d\'àudio';

  @override
  String get high => 'Alta';

  @override
  String get low => 'Baixa';

  @override
  String get pre_download_play => 'Descàrrega prèvia i reproduir';

  @override
  String get pre_download_play_description =>
      'En lloc de transmetre l\'àudio, descarrega bytes i ho reprodueix (recomendat per usuaris amb un bon ample de banda)';

  @override
  String get skip_non_music =>
      'Ometre segments que no son música (SponsorBlock)';

  @override
  String get blacklist_description => 'Cançons i artistes de la llista negra';

  @override
  String get wait_for_download_to_finish =>
      'Si us plau, esperi que acabi la descàrrega actual';

  @override
  String get desktop => 'Escriptori';

  @override
  String get close_behavior => 'Comportament al tancar';

  @override
  String get close => 'Tancar';

  @override
  String get minimize_to_tray => 'Minimizar a la safata del sistema';

  @override
  String get show_tray_icon => 'Mostrar icona a la safata del sistema';

  @override
  String get about => 'Sobre';

  @override
  String get u_love_spotube => 'Sabem que li encanta DeeMusiq';

  @override
  String get check_for_updates => 'Buscar actualitzacions';

  @override
  String get about_spotube => 'Sobre DeeMusiq';

  @override
  String get blacklist => 'Llista negra';

  @override
  String get please_sponsor => 'Si us plau, patrocina/dona';

  @override
  String get spotube_description =>
      'DeeMusiq, un client lleuger, multiplataforma i gratuït de Spotify';

  @override
  String get version => 'Versió';

  @override
  String get build_number => 'Número de compilació';

  @override
  String get founder => 'Fundador';

  @override
  String get repository => 'Repositori';

  @override
  String get bug_issues => 'Errors i problemes';

  @override
  String get made_with => 'Fet amb ❤️ a Bangladesh🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Llicència';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'No es preocupi, les seves credencials no seran recollides ni compartides amb ningú';

  @override
  String get know_how_to_login => 'No sap com fer-ho?';

  @override
  String get follow_step_by_step_guide => 'Segueixi la guia pas a pas';

  @override
  String cookie_name_cookie(Object name) {
    return 'Cookie $name';
  }

  @override
  String get fill_in_all_fields => 'Si us plau, completi tots els camps';

  @override
  String get submit => 'Enviar';

  @override
  String get exit => 'Sortir';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Següent';

  @override
  String get done => 'Fet';

  @override
  String get step_1 => 'Pas 1';

  @override
  String get first_go_to => 'Primer, vagi a';

  @override
  String get something_went_wrong => 'Quelcom ha sortit malament';

  @override
  String get piped_instance => 'Instància del servidor Piped';

  @override
  String get piped_description =>
      'La instància del servidor Piped a utilitzar per la coincidència de cançons';

  @override
  String get piped_warning =>
      'Algunes poden no funcionar bé, utilitzi-les sota el seu propi risc';

  @override
  String get invidious_instance => 'Instància del servidor Invidious';

  @override
  String get invidious_description =>
      'La instància del servidor Invidious per fer coincidir pistes';

  @override
  String get invidious_warning =>
      'Algunes instàncies podrien no funcionar bé. Feu-les servir sota la vostra responsabilitat';

  @override
  String get generate => 'Generar';

  @override
  String track_exists(Object track) {
    return 'La cançó $track ja existeix';
  }

  @override
  String get replace_downloaded_tracks =>
      'Substituir totes les cançons descarregades';

  @override
  String get skip_download_tracks =>
      'Ometre la descàrrega de totes les cançons descarregades';

  @override
  String get do_you_want_to_replace => 'Vol substituir la cançó existent?';

  @override
  String get replace => 'Substituir';

  @override
  String get skip => 'Ometre';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Seleccionar fins$count $type';
  }

  @override
  String get select_genres => 'Seleccionar Gèneres';

  @override
  String get add_genres => 'Afegir Gèneres';

  @override
  String get country => 'País';

  @override
  String get number_of_tracks_generate => 'Número de cançons a generar';

  @override
  String get acousticness => 'Acústica';

  @override
  String get danceability => 'Ballabilitat';

  @override
  String get energy => 'Energia';

  @override
  String get instrumentalness => 'Instrumental';

  @override
  String get liveness => 'En viu';

  @override
  String get loudness => 'Sonoritat';

  @override
  String get speechiness => 'Parla';

  @override
  String get valence => 'Valencia';

  @override
  String get popularity => 'Popularidad';

  @override
  String get key => 'To';

  @override
  String get duration => 'Duració (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Mode';

  @override
  String get time_signature => 'Signatura de temps';

  @override
  String get short => 'Curt';

  @override
  String get medium => 'Mig';

  @override
  String get long => 'Llarg';

  @override
  String get min => 'Mín.';

  @override
  String get max => 'Màx.';

  @override
  String get target => 'Objetiu';

  @override
  String get moderate => 'Moderat';

  @override
  String get deselect_all => 'Desseleccionar tot';

  @override
  String get select_all => 'Seleccionar tot';

  @override
  String get are_you_sure => 'Està segur?';

  @override
  String get generating_playlist =>
      'Generant la seva llista de reproducció personalitzada...';

  @override
  String selected_count_tracks(Object count) {
    return 'Cançons $count seleccionades';
  }

  @override
  String get download_warning =>
      'Si descarrega totes les cançons de cop, està piratejant música clarament i causant dany a la societat creativa de la música. Espero que sigui conscient d\'això i sempre intenti respectar i recolzar la forta feina dels artístes';

  @override
  String get download_ip_ban_warning =>
      'Per cert, la seva IP pot ser bloquejada a YouTube degut a solicituds de descàrrega excessives. El bloqueig d\'IP vol dir que no podrà utilitzar YouTube (fins i tot si ha iniciat sessió) durant un mínim de 2-3 meses desde esa dirección IP. I DeeMusiq no es fa responsable si això succeeix en alguna ocasió';

  @override
  String get by_clicking_accept_terms =>
      'Al fer clic a \'Acceptar\', acepta els següents termes:';

  @override
  String get download_agreement_1 =>
      'Se que estic piratejant música. Sóc dolent';

  @override
  String get download_agreement_2 =>
      'Recolzaré l\'artista quan pugui i només ho faig perquè no tinc diners per comprar el seu art';

  @override
  String get download_agreement_3 =>
      'Sóc completament conscient que la meva IP pot ser bloqueada per YouTube i no responsabilizo a DeeMusiq ni als seus propietaris/contribuents per qualsevol incident causat per la meva acció actual';

  @override
  String get decline => 'Rebutjar';

  @override
  String get accept => 'Acceptar';

  @override
  String get details => 'Detalls';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Canal';

  @override
  String get likes => 'M\'agrada';

  @override
  String get dislikes => 'No m\'agrada';

  @override
  String get views => 'Vistes';

  @override
  String get streamUrl => 'URL del streaming';

  @override
  String get stop => 'Parar';

  @override
  String get sort_newest => 'Ordenar per més noves';

  @override
  String get sort_oldest => 'Ordenar per més antigues';

  @override
  String get sleep_timer => 'Temporitzador d\'apagat';

  @override
  String mins(Object minutes) {
    return '$minutes minuts';
  }

  @override
  String hours(Object hours) {
    return '$hours hores';
  }

  @override
  String hour(Object hours) {
    return '$hours hora';
  }

  @override
  String get custom_hours => 'Hores personalitzades';

  @override
  String get logs => 'Registres';

  @override
  String get developers => 'Desenvolupadors';

  @override
  String get not_logged_in => 'No ha iniciat sesió';

  @override
  String get search_mode => 'Mode de cerca';

  @override
  String get audio_source => 'Font d\'àudio';

  @override
  String get ok => 'OK';

  @override
  String get failed_to_encrypt => 'Error al xifrar';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq utilitza el xifrado per emmagatzemar les seves dades de forma segura. Però ha fallat. Per tant, tornarà a un emmagatzament no segur\nSi estè utilizant Linux, asseguri\'s de tenir instal·lats els serveis secrets com gnome-keyring, kde-wallet i keepassxc';

  @override
  String get querying_info => 'Consultant informació...';

  @override
  String get piped_api_down => 'La API de Piped no està operativa';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'La instància de Piped $pipedInstance no està operativa en aquest moment\n\nCanvieu la instància o canvieu el \'Tipus d\'API\' a l\'API oficial de YouTube\n\nAssegureu-vos de reiniciar l\'aplicació després del canvi';
  }

  @override
  String get you_are_offline => 'Actualment no teniu connexió a internet';

  @override
  String get connection_restored => 'S\'ha restablert la connexió a internet';

  @override
  String get use_system_title_bar => 'Utilitza la barra de títol del sistema';

  @override
  String get crunching_results => 'Processant resultats...';

  @override
  String get search_to_get_results => 'Cerca per obtenir resultats';

  @override
  String get use_amoled_mode => 'Utilitza el mode AMOLED';

  @override
  String get pitch_dark_theme => 'Tema de dart negre intens';

  @override
  String get normalize_audio => 'Normalitza l\'àudio';

  @override
  String get change_cover => 'Canvia la coberta';

  @override
  String get add_cover => 'Afegeix una coberta';

  @override
  String get restore_defaults => 'Restaura els valors per defecte';

  @override
  String get download_music_format => 'Format de descàrrega de música';

  @override
  String get streaming_music_format =>
      'Format de reproducció de música en temps real';

  @override
  String get download_music_quality => 'Qualitat de descàrrega de música';

  @override
  String get streaming_music_quality =>
      'Qualitat de reproducció de música en temps real';

  @override
  String get login_with_lastfm => 'Inicia la sessió amb Last.fm';

  @override
  String get connect => 'Connecta';

  @override
  String get disconnect_lastfm => 'Desconnecta de Last.fm';

  @override
  String get disconnect => 'Desconnecta';

  @override
  String get username => 'Nom d\'usuari';

  @override
  String get password => 'Contrasenya';

  @override
  String get login => 'Inicia la sessió';

  @override
  String get login_with_your_lastfm =>
      'Inicia la sessió amb el teu compte de Last.fm';

  @override
  String get scrobble_to_lastfm => 'Scrobble a Last.fm';

  @override
  String get go_to_album => 'Anar a l\'àlbum';

  @override
  String get discord_rich_presence => 'Presència rica de Discord';

  @override
  String get browse_all => 'Navega per tot';

  @override
  String get genres => 'Gèneres';

  @override
  String get explore_genres => 'Explora els gèneres';

  @override
  String get friends => 'Amics';

  @override
  String get no_lyrics_available =>
      'Ho sentim, no es poden trobar les lletres d\'aquesta pista';

  @override
  String get start_a_radio => 'Inicia una ràdio';

  @override
  String get how_to_start_radio => 'Com vols començar la ràdio?';

  @override
  String get replace_queue_question =>
      'Voleu substituir la cua actual o afegir-hi?';

  @override
  String get endless_playback => 'Reproducció infinita';

  @override
  String get delete_playlist => 'Suprimeix la llista de reproducció';

  @override
  String get delete_playlist_confirmation =>
      'Esteu segur que voleu suprimir aquesta llista de reproducció?';

  @override
  String get local_tracks => 'Pistes locals';

  @override
  String get local_tab => 'Local';

  @override
  String get song_link => 'Enllaç de la cançó';

  @override
  String get youtube_source_description => 'Recomanat i funciona millor.';

  @override
  String get piped_source_description =>
      'Et sents lliure? El mateix que YouTube però més lliure.';

  @override
  String get jiosaavn_source_description =>
      'El millor per a la regió del sud d\'Àsia.';

  @override
  String get invidious_source_description =>
      'Similar a Piped però amb més disponibilitat';

  @override
  String highest_quality(Object quality) {
    return 'Qualitat més alta: $quality';
  }

  @override
  String get select_audio_source => 'Seleccioneu la font d\'àudio';

  @override
  String get contribute_on_github => 'Contribueix a GitHub';

  @override
  String get browse_anonymously => 'Navega de manera anònima';

  @override
  String get enable_connect => 'Habilita la connexió';

  @override
  String get enable_connect_description =>
      'Controla DeeMusiq des d\'altres dispositius';

  @override
  String get devices => 'Dispositius';

  @override
  String get select => 'Selecciona';

  @override
  String connect_client_alert(Object client) {
    return 'Estàs sent controlat per $client';
  }

  @override
  String get this_device => 'Aquest dispositiu';

  @override
  String get remote => 'Remot';

  @override
  String get stats => 'Estadístiques';

  @override
  String and_n_more(Object count) {
    return 'i $count més';
  }

  @override
  String get recently_played => 'Reproduït recentment';

  @override
  String get browse_more => 'Navega més';

  @override
  String get no_title => 'Sense títol';

  @override
  String get not_playing => 'No s\'està reproduint';

  @override
  String get epic_failure => 'Fracàs èpic!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Afegit $tracks_length pistes a la cua';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq té una actualització';

  @override
  String get download_now => 'Descarregar ara';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum ha estat publicat';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version ha estat publicat';
  }

  @override
  String get read_the_latest => 'Llegeix el més recent';

  @override
  String get release_notes => 'notes de la versió';

  @override
  String get pick_color_scheme => 'Tria l\'esquema de colors';

  @override
  String get save => 'Desar';

  @override
  String get choose_the_device => 'Tria el dispositiu:';

  @override
  String get multiple_device_connected =>
      'Hi ha diversos dispositius connectats.\nTria el dispositiu on vols realitzar aquesta acció';

  @override
  String get nothing_found => 'No s\'ha trobat res';

  @override
  String get the_box_is_empty => 'La caixa està buida';

  @override
  String get top_artists => 'Millors artistes';

  @override
  String get top_albums => 'Millors àlbums';

  @override
  String get this_week => 'Aquesta setmana';

  @override
  String get this_month => 'Aquest mes';

  @override
  String get last_6_months => 'Últims 6 mesos';

  @override
  String get this_year => 'Aquest any';

  @override
  String get last_2_years => 'Últims 2 anys';

  @override
  String get all_time => 'Tots els temps';

  @override
  String powered_by_provider(Object providerName) {
    return 'Funciona amb $providerName';
  }

  @override
  String get email => 'Correu electrònic';

  @override
  String get profile_followers => 'Seguidors';

  @override
  String get birthday => 'Aniversari';

  @override
  String get subscription => 'Subscripció';

  @override
  String get not_born => 'No ha nascut';

  @override
  String get hacker => 'Hacker';

  @override
  String get profile => 'Perfil';

  @override
  String get no_name => 'Sense nom';

  @override
  String get edit => 'Editar';

  @override
  String get user_profile => 'Perfil d\'usuari';

  @override
  String count_plays(Object count) {
    return '$count reproduccions';
  }

  @override
  String get minutes_listened => 'minuts escoltats';

  @override
  String get streamed_songs => 'cançons reproduïdes';

  @override
  String count_streams(Object count) {
    return '$count reproduccions';
  }

  @override
  String get owned_by_you => 'De la teva propietat';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return 'S\'ha copiat $shareUrl al porta-retalls';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes minuts';
  }

  @override
  String get summary_minutes => 'minuts';

  @override
  String get summary_listened_to_music => 'has escoltat música';

  @override
  String get summary_songs => 'cançons';

  @override
  String get summary_streamed_overall => 'reproduït en general';

  @override
  String get summary_artists => 'artistes';

  @override
  String get summary_music_reached_you => 'La música t\'ha arribat';

  @override
  String get summary_full_albums => 'Àlbums complets';

  @override
  String get summary_got_your_love => 'ha aconseguit el teu amor';

  @override
  String get summary_playlists => 'llistes de reproducció';

  @override
  String get summary_were_on_repeat => 'estaven en repetició';

  @override
  String get webview_not_found => 'No s\'ha trobat el Webview';

  @override
  String get webview_not_found_description =>
      'No hi ha cap temps d\'execució de Webview instal·lat al dispositiu.\nSi està instal·lat, assegureu-vos que estigui en el environment PATH\n\nDesprés d\'instal·lar-lo, reinicieu l\'aplicació';

  @override
  String get unsupported_platform => 'Plataforma no compatible';

  @override
  String get cache_music => 'Música en caché';

  @override
  String get open => 'Obrir';

  @override
  String get cache_folder => 'Carpeta de caché';

  @override
  String get export => 'Exportar';

  @override
  String get clear_cache => 'Netejar caché';

  @override
  String get clear_cache_confirmation => 'Voleu netejar la memòria cau?';

  @override
  String get export_cache_files => 'Exportar arxius en caché';

  @override
  String found_n_files(Object count) {
    return 'S\'han trobat $count arxius';
  }

  @override
  String get export_cache_confirmation => 'Voleu exportar aquests arxius a';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'S\'han exportat $filesExported de $files arxius';
  }

  @override
  String get undo => 'Desfer';

  @override
  String get download_all => 'Descarregar tot';

  @override
  String get add_all_to_playlist => 'Afegir tot a la llista de reproducció';

  @override
  String get add_all_to_queue => 'Afegir tot a la cua';

  @override
  String get play_all_next => 'Reproduir tot a continuació';

  @override
  String get pause => 'Pausa';

  @override
  String get view_all => 'Veure tot';

  @override
  String get no_tracks_added_yet => 'Sembla que encara no has afegit cap pista';

  @override
  String get no_tracks => 'Sembla que no hi ha pistes aquí';

  @override
  String get no_tracks_listened_yet => 'Sembla que no has escoltat res encara';

  @override
  String get not_following_artists => 'No estàs seguint cap artista';

  @override
  String get no_favorite_albums_yet =>
      'Sembla que encara no has afegit cap àlbum als teus favorits';

  @override
  String get no_logs_found => 'No s\'han trobat registres';

  @override
  String get youtube_engine => 'Motor de YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine no està instal·lat';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine no està instal·lat al teu sistema.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Assegura\'t que estigui disponible a la variable PATH o\nestableix el camí absolut a l\'executable de $engine a continuació';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'En macOS/Linux/Unix com a sistemes operatius, establir el camí a .zshrc/.bashrc/.bash_profile etc. no funcionarà.\nHas de configurar el camí al fitxer de configuració de la shell';

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
  String get download => 'Descarregar';

  @override
  String get file_not_found => 'Fitxer no trobat';

  @override
  String get custom => 'Personalitzat';

  @override
  String get add_custom_url => 'Afegir URL personalitzada';

  @override
  String get edit_port => 'Editar port';

  @override
  String get port_helper_msg =>
      'El valor per defecte és -1, que indica un número aleatori. Si teniu un tallafoc configurat, es recomana establir-ho.';

  @override
  String connect_request(Object client) {
    return 'Permetre que $client es connecti?';
  }

  @override
  String get connection_request_denied =>
      'Connexió denegada. L\'usuari ha denegat l\'accés.';

  @override
  String get an_error_occurred => 'S’ha produït un error';

  @override
  String get copy_to_clipboard => 'Copiar al porta-retalls';

  @override
  String get view_logs => 'Veure registres';

  @override
  String get retry => 'Tornar-ho a provar';

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
      'No has configurat cap proveïdor de metadades predeterminat';

  @override
  String get manage_metadata_providers => 'Gestionar proveïdors de metadades';

  @override
  String get open_link_in_browser => 'Obrir l’enllaç en el navegador?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Vols obrir l’enllaç següent?';

  @override
  String get unsafe_url_warning =>
      'Pot ser perillós obrir enllaços de fonts no fiables. Sigues precavís!\nTambé pots copiar l’enllaç al porta-retalls.';

  @override
  String get copy_link => 'Copiar enllaç';

  @override
  String get building_your_timeline =>
      'Construint la teva cronologia en funció de les teves escoltes...';

  @override
  String get official => 'Oficial';

  @override
  String author_name(Object author) {
    return 'Autor: $author';
  }

  @override
  String get third_party => 'Tercers';

  @override
  String get plugin_requires_authentication =>
      'El complement requereix autenticació';

  @override
  String get update_available => 'Actualització disponible';

  @override
  String get supports_scrobbling => 'Admet scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'Aquest complement fa scrobbling de la teva música per generar l’historial d’escoltes.';

  @override
  String get default_metadata_source => 'Font de metadades per defecte';

  @override
  String get set_default_metadata_source =>
      'Estableix la font de metadades per defecte';

  @override
  String get default_audio_source => 'Font d\'àudio per defecte';

  @override
  String get set_default_audio_source =>
      'Estableix la font d\'àudio per defecte';

  @override
  String get set_default => 'Establir com a predeterminat';

  @override
  String get support => 'Suport';

  @override
  String get support_plugin_development =>
      'Suportar el desenvolupament del complement';

  @override
  String can_access_name_api(Object name) {
    return '- Pot accedir a l’API **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Vols instal·lar aquest complement?';

  @override
  String get third_party_plugin_warning =>
      'Aquest complement prové d’un repositori de tercers. Assegura’t de confiar en la font abans d’instal·lar-lo.';

  @override
  String get author => 'Autor';

  @override
  String get this_plugin_can_do_following =>
      'Aquest complement pot fer el següent';

  @override
  String get install => 'Instal·lar';

  @override
  String get no_tracks_playing => 'No s’està reproduint cap pista actualment';

  @override
  String get synced_lyrics_not_available =>
      'Les lletres sincronitzades no estan disponibles per a aquesta cançó. Si us plau, usa';

  @override
  String get plain_lyrics => 'Lletres sense format';

  @override
  String get tab_instead => 'en lloc d’això, utilitza la tecla Tab.';

  @override
  String get disclaimer => 'Avís legal';

  @override
  String get third_party_plugin_dmca_notice =>
      'L’equip de DeeMusiq no accepta cap responsabilitat (inclosa legal) pels complements de “tercers”.\nFes-los servir sota la teva responsabilitat. Si detectes errors/problemes, informa’ls al repositori del complement.\n\nSi algun complement de “tercers” incompleix els ToS/DMCA d’un servei o entitat legal, contacta amb l’autor del complement o amb la plataforma d’allotjament (per exemple GitHub/Codeberg) per prendre mesures. Els complements etiquetats com a “tercers” són públics i gestionats per la comunitat; no els curatem, per la qual cosa no podem intervenir-hi.\n\n';

  @override
  String get plugins => 'Connectors';

  @override
  String get paste_plugin_download_url =>
      'Enllaça l’URL de descàrrega o el repositori de GitHub/Codeberg o l’enllaç directe al fitxer .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'Descarrega i instal·la el complement des d’un URL';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Error en afegir el complement: $error';
  }

  @override
  String get upload_plugin_from_file => 'Penja el complement des d’un fitxer';

  @override
  String get installed => 'Instal·lat';

  @override
  String get available_plugins => 'Complements disponibles';

  @override
  String get configure_plugins =>
      'Configura els teus propis connectors de proveïdor de metadades i de font d\'àudio';

  @override
  String get audio_scrobblers => 'Scrobblers d’àudio';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Font: ';

  @override
  String get uncompressed => 'Sense comprimir';

  @override
  String get dab_music_source_description =>
      'Per als audiòfils. Ofereix fluxos d\'àudio d\'alta qualitat/sense pèrdua. Coincidència precisa de pistes basada en ISRC.';

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
  String get skip_this_nonsense => 'Omet aquesta tonteria';

  @override
  String get freedom_of_music => '“Llibertat de la música”';

  @override
  String get freedom_of_music_palm =>
      '“Llibertat de la música a la palma de la mà”';

  @override
  String get get_started => 'Comencem';

  @override
  String get endless_playback_description =>
      'Afegiu automàticament noves cançons\nal final de la cua';

  @override
  String get choose_your_region => 'Trieu la vostra regió';

  @override
  String get choose_your_region_description =>
      'Això ajudarà a DeeMusiq a mostrar-vos el contingut adequat\nper a la vostra ubicació.';

  @override
  String get choose_your_language => 'Trieu el vostre idioma';

  @override
  String get help_project_grow => 'Ajuda a fer créixer aquest projecte';

  @override
  String get help_project_grow_description =>
      'DeeMusiq és un projecte de codi obert. Podeu ajudar a fer créixer aquest projecte contribuint al projecte, informant d\'errors o suggerint noves funcionalitats.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Fes una donació a Open Collective';

  @override
  String get install_a_metadata_provider =>
      'Instal·lar un proveïdor de metadades';

  @override
  String get input_does_not_match_format =>
      'L’entrada no coincideix amb el format requerit';

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
  String get auth_mfa_required => 'Introdueix el teu codi d\'autenticació';

  @override
  String get auth_mfa_body =>
      'Obre l\'aplicació autenticadora i introdueix el codi de 6 xifres per continuar.';

  @override
  String get auth_mfa_verify_action => 'Verifica';

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
