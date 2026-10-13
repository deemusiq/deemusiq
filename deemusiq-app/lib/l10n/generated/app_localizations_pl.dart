// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get guest => 'Gość';

  @override
  String get browse => 'Przeglądaj';

  @override
  String get search => 'Szukaj';

  @override
  String get library => 'Biblioteka';

  @override
  String get lyrics => 'Tekst utworu';

  @override
  String get settings => 'Ustawienia';

  @override
  String get genre_categories_filter => 'Filtruj kategorie lub gatunki...';

  @override
  String get genre => 'Gatunki';

  @override
  String get personalized => 'Spersonalizowane';

  @override
  String get featured => 'Wyróżnione';

  @override
  String get new_releases => 'Nowo wydane';

  @override
  String get songs => 'Utwory';

  @override
  String playing_track(Object track) {
    return 'Odtwarzanie $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'To spowoduje wyczyszczenie całej kolejki! $track_length pozycji zostanie usuniętych.\nCzy chcesz kontynuować?';
  }

  @override
  String get load_more => 'Załaduj więcej';

  @override
  String get playlists => 'Playlisty';

  @override
  String get artists => 'Artyści';

  @override
  String get albums => 'Albumy';

  @override
  String get tracks => 'Utwory';

  @override
  String get downloads => 'Pobrane';

  @override
  String get filter_playlists => 'Filtruj swoje playlisty...';

  @override
  String get liked_tracks => 'Ulubione utwory';

  @override
  String get liked_tracks_description => 'Wszystkie twoje ulubione utwory';

  @override
  String get playlist => 'Playlista';

  @override
  String get create_a_playlist => 'Utwórz playlistę';

  @override
  String get update_playlist => 'Zaktualizuj playlistę';

  @override
  String get create => 'Utwórz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get update => 'Aktualizuj';

  @override
  String get playlist_name => 'Nazwa playlisty';

  @override
  String get name_of_playlist => 'Nazwa playlisty';

  @override
  String get description => 'Opis';

  @override
  String get public => 'Publiczny';

  @override
  String get collaborative => 'Współpraca';

  @override
  String get search_local_tracks => 'Szukanie lokalnych utworów...';

  @override
  String get play => 'Odtwórz';

  @override
  String get delete => 'Usuń';

  @override
  String get none => 'Brak';

  @override
  String get sort_a_z => 'Sortuj od A do Z';

  @override
  String get sort_z_a => 'Sortuj od Z do A';

  @override
  String get sort_artist => 'Sortuj po Artyście';

  @override
  String get sort_album => 'Sortuj po Albumie';

  @override
  String get sort_duration => 'Sortuj według Czasu Trwania';

  @override
  String get sort_tracks => 'Sortuj Utwory';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Obecnie pobieram $tracks_length utworów.';
  }

  @override
  String get cancel_all => 'Anuluj wszystkie';

  @override
  String get filter_artist => 'Filtruj artystów...';

  @override
  String followers(Object followers) {
    return '$followers obserwujących';
  }

  @override
  String get add_artist_to_blacklist => 'Dodaj artystę do czarnej listy';

  @override
  String get top_tracks => 'Popularne Utwory';

  @override
  String get fans_also_like => 'Fani lubią także';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get artist => 'Artysta';

  @override
  String get blacklisted => 'Dodano do czarnej listy';

  @override
  String get following => 'Obserwujesz';

  @override
  String get follow => 'Zaobserwuj';

  @override
  String get artist_url_copied => 'Skopiowano URL artysty do schowka';

  @override
  String added_to_queue(Object tracks) {
    return 'Dodano $tracks utworów do kolejki';
  }

  @override
  String get filter_albums => 'Filtruj albumy...';

  @override
  String get synced => 'Zsynchronizowano';

  @override
  String get plain => 'Zwykły';

  @override
  String get shuffle => 'Losowe odtwarzanie';

  @override
  String get search_tracks => 'Szukam utworu...';

  @override
  String get released => 'Wydano';

  @override
  String error(Object error) {
    return 'Błąd $error';
  }

  @override
  String get title => 'Tytuł';

  @override
  String get time => 'Czas';

  @override
  String get more_actions => 'Więcej akcji';

  @override
  String download_count(Object count) {
    return 'Pobrane ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Dodaj ($count) do Playlisty';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Dodaj ($count) do Kolejki';
  }

  @override
  String play_count_next(Object count) {
    return 'Odtwórz ($count) następne';
  }

  @override
  String get album => 'Album';

  @override
  String copied_to_clipboard(Object data) {
    return 'Skopiowano $data do schowka';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Dodano $track do danych Playlist';
  }

  @override
  String get add => 'Dodaj';

  @override
  String added_track_to_queue(Object track) {
    return 'Dodano $track do kolejki';
  }

  @override
  String get add_to_queue => 'Dodano do kolejki';

  @override
  String track_will_play_next(Object track) {
    return '$track następny';
  }

  @override
  String get play_next => 'Odtwórz następny';

  @override
  String removed_track_from_queue(Object track) {
    return 'Usunięto $track z kolejki';
  }

  @override
  String get remove_from_queue => 'Usunięto z kolejki';

  @override
  String get remove_from_favorites => 'Usunięto z ulubionych';

  @override
  String get save_as_favorite => 'Zapisz do ulubionych';

  @override
  String get add_to_playlist => 'Dodaj do playlisty';

  @override
  String get remove_from_playlist => 'Usuń z playlisty';

  @override
  String get add_to_blacklist => 'Dodaj do czarnej listy';

  @override
  String get remove_from_blacklist => 'Usuń z czarnej listy';

  @override
  String get share => 'Udostępnij';

  @override
  String get mini_player => 'Mały odwarzacz';

  @override
  String get slide_to_seek => 'Przesuń, aby przewinąć do przodu lub do tyłu.';

  @override
  String get shuffle_playlist => 'Odtwarzaj losowo z playlisty';

  @override
  String get unshuffle_playlist => 'Nie odtwarzaj losowo z playlisty';

  @override
  String get previous_track => 'Poprzedni utwór';

  @override
  String get next_track => 'Następny utwór';

  @override
  String get pause_playback => 'Zatrzymaj odwarzanie';

  @override
  String get resume_playback => 'Wznów odwarzanie';

  @override
  String get loop_track => 'Zapętl utwór';

  @override
  String get no_loop => 'Brak pętli';

  @override
  String get repeat_playlist => 'Powtarzaj playlistę';

  @override
  String get queue => 'Kolejka';

  @override
  String get alternative_track_sources => 'Alternatywne źródła utworów';

  @override
  String get download_track => 'Pobierz utwór';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks utworów w kolejce';
  }

  @override
  String get clear_all => 'Wyczyść wszystko';

  @override
  String get show_hide_ui_on_hover => 'Pokaż/Ukryj unoszący się interfejs';

  @override
  String get always_on_top => 'Zawsze na wierzchu';

  @override
  String get exit_mini_player => 'Opuść Mały odtwarzacz';

  @override
  String get download_location => 'Zmień lokalizację';

  @override
  String get local_library => 'Biblioteka lokalna';

  @override
  String get add_library_location => 'Dodaj do biblioteki';

  @override
  String get remove_library_location => 'Usuń z biblioteki';

  @override
  String get account => 'Konto';

  @override
  String get logout => 'Wyloguj';

  @override
  String get logout_of_this_account => 'Wyloguj z tego konta';

  @override
  String get language_region => 'Język i Region';

  @override
  String get language => 'Język';

  @override
  String get system_default => 'Domyślny systemowy';

  @override
  String get market_place_region => 'Region Rynku';

  @override
  String get recommendation_country => 'Kraj rekomendacji';

  @override
  String get appearance => 'Wygląd';

  @override
  String get layout_mode => 'Tryb Układu';

  @override
  String get override_layout_settings =>
      'Nadpisz responsywne ustawienia trybu układu';

  @override
  String get adaptive => 'Adaptacyjny';

  @override
  String get compact => 'Kompaktowy';

  @override
  String get extended => 'Rozszerzony';

  @override
  String get theme => 'Motyw';

  @override
  String get dark => 'Ciemny';

  @override
  String get light => 'Jasny';

  @override
  String get system => 'Systemowy';

  @override
  String get accent_color => 'Kolor Akcentu';

  @override
  String get sync_album_color => 'Synchronizuj kolor albumu';

  @override
  String get sync_album_color_description =>
      'Używa dominującego koloru okładki albumu jako koloru akcentującego';

  @override
  String get playback => 'Odtwarzanie';

  @override
  String get audio_quality => 'Jakość dźwięku';

  @override
  String get high => 'Duża';

  @override
  String get low => 'Mała';

  @override
  String get pre_download_play => 'Wstępnie pobierz i odtwórz';

  @override
  String get pre_download_play_description =>
      'Zamiast przesyłać strumieniowo dźwięk, pobiera odpowiedni bufor i odtwarza (zalecane dla użytkowników o większej przepustowości)';

  @override
  String get skip_non_music => 'Pomiń nie-muzyczne segmenty (SponsorBlock)';

  @override
  String get blacklist_description => 'Czarna lista utworów i artystów';

  @override
  String get wait_for_download_to_finish =>
      'Proszę poczekać na zakończenie obecnego pobierania.';

  @override
  String get desktop => 'Pulpit';

  @override
  String get close_behavior => 'Zamknij';

  @override
  String get close => 'Zamknij';

  @override
  String get minimize_to_tray => 'Zminimalizuj do zasobnika';

  @override
  String get show_tray_icon => 'Pokazuj ikonę w zasobniku';

  @override
  String get about => 'O projekcie';

  @override
  String get u_love_spotube => 'Wiemy jak kochacie DeeMusiq';

  @override
  String get check_for_updates => 'Sprawdź aktualizacje';

  @override
  String get about_spotube => 'O DeeMusiq';

  @override
  String get blacklist => 'Czarna lista';

  @override
  String get please_sponsor => 'Proszę wesprzyj projekt';

  @override
  String get spotube_description =>
      'DeeMusiq, lekki, wieloplatformowy, darmowy dla wszystkich klient Spotify';

  @override
  String get version => 'Wersja';

  @override
  String get build_number => 'Numer Build\'a';

  @override
  String get founder => 'Twórca Założyciel';

  @override
  String get repository => 'Repozytorium';

  @override
  String get bug_issues => 'Błędy i propozycje';

  @override
  String get made_with => 'Stworzono z ❤️ w Bangladesh\'u 🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Licencja';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Nie martw się, żadne dane logowania nie są zbierane ani udostępniane nikomu';

  @override
  String get know_how_to_login => 'Nie wiesz, jak się zalogować?';

  @override
  String get follow_step_by_step_guide =>
      'Postępuj zgodnie z poradnikiem krok po kroku';

  @override
  String cookie_name_cookie(Object name) {
    return '$name Ciasteczko';
  }

  @override
  String get fill_in_all_fields => 'Proszę wypełnić wszystkie pola';

  @override
  String get submit => 'Zatwierdź';

  @override
  String get exit => 'Zamknij';

  @override
  String get previous => 'Poprzedni';

  @override
  String get next => 'Następny';

  @override
  String get done => 'Gotowe 🙂';

  @override
  String get step_1 => 'Krok 1';

  @override
  String get first_go_to => 'Po pierwsze przejdź do';

  @override
  String get something_went_wrong => 'Coś poszło nie tak 🙁';

  @override
  String get piped_instance => 'Instancja serwera Piped';

  @override
  String get piped_description =>
      'Instancja serwera Piped używana jest do dopasowania utworów.';

  @override
  String get piped_warning =>
      'Niektóre z nich mogą nie działać. Używasz na własną odpowiedzialność!';

  @override
  String get invidious_instance => 'Instancja serwera Invidious';

  @override
  String get invidious_description =>
      'Instancja serwera Invidious do dopasowywania utworów';

  @override
  String get invidious_warning =>
      'Niektóre z nich mogą nie działać dobrze. Używaj na własne ryzyko';

  @override
  String get generate => 'Generuj';

  @override
  String track_exists(Object track) {
    return 'Utwór $track już istnieje';
  }

  @override
  String get replace_downloaded_tracks => 'Zamień wszystkie pobrane utwory';

  @override
  String get skip_download_tracks =>
      'Pomiń pobieranie wszystkich pobranych utworów';

  @override
  String get do_you_want_to_replace => 'Chcesz zamienić istniejący utwór ??';

  @override
  String get replace => 'Zamień';

  @override
  String get skip => 'Pomiń';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Wybierz do $count $type';
  }

  @override
  String get select_genres => 'Wybierz Gatunki';

  @override
  String get add_genres => 'Dodaj Gatunki';

  @override
  String get country => 'Kraj';

  @override
  String get number_of_tracks_generate => 'Liczba utworów do wygenerowania';

  @override
  String get acousticness => 'Akustyczna';

  @override
  String get danceability => 'Taneczna';

  @override
  String get energy => 'Energiczna';

  @override
  String get instrumentalness => 'Instrumentalna';

  @override
  String get liveness => 'Żywa';

  @override
  String get loudness => 'Głośna';

  @override
  String get speechiness => 'Wymowna';

  @override
  String get valence => 'Wartościowa';

  @override
  String get popularity => 'Popularność';

  @override
  String get key => 'Kluczowa';

  @override
  String get duration => 'Długość (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Tryb';

  @override
  String get time_signature => 'Sygnatura Czasowa';

  @override
  String get short => 'Krótka';

  @override
  String get medium => 'Średnia';

  @override
  String get long => 'Długa';

  @override
  String get min => 'Minimalnie';

  @override
  String get max => 'Maksymalnie';

  @override
  String get target => 'Cel';

  @override
  String get moderate => 'Umiarkowanie';

  @override
  String get deselect_all => 'Odznacz wszystkie';

  @override
  String get select_all => 'Zaznacz wszystkie';

  @override
  String get are_you_sure => 'Jesteś pewny?';

  @override
  String get generating_playlist => 'Generowanie twojej własnej playlisty...';

  @override
  String selected_count_tracks(Object count) {
    return 'Wybrano $count utworów';
  }

  @override
  String get download_warning =>
      'Jeśli hurtowo pobierasz wszystkie utwory, wyraźnie piracisz muzykę i wyrządzasz szkody kreatywnej społeczności muzycznej. Mam nadzieję, że jesteś tego świadomy. Zawsze staraj się szanować i wspierać ciężką pracę Artysty';

  @override
  String get download_ip_ban_warning =>
      'Przy okazji, Twój adres IP może zostać zablokowany w YouTube z powodu nadmiernych żądań pobierania niż zwykle. Blokada IP oznacza, że nie możesz korzystać z YouTube (nawet jeśli jesteś zalogowany) przez co najmniej 2-3 miesiące z IP tego urządzenia. DeeMusiq nie ponosi żadnej odpowiedzialności, jeśli tak się stanie';

  @override
  String get by_clicking_accept_terms =>
      'Klikając \'Akceptuj\' zgadzasz się z następującymi warunkami:';

  @override
  String get download_agreement_1 => 'Wiem, że piracę muzykę. Jestem zły.';

  @override
  String get download_agreement_2 =>
      'Będę wspierał artystę i robię to tylko dlatego, że nie mam pieniędzy na albumy wykonawcy. ';

  @override
  String get download_agreement_3 =>
      'Jestem całkowicie świadomy, że moje IP może zostać zablokowane w YouTube i nie pociągam DeeMusiq ani jego właścicieli/współtwórców do odpowiedzialności za jakiekolwiek wypadki spowodowane moimi obecnymi działaniami';

  @override
  String get decline => 'Odrzuć';

  @override
  String get accept => 'Akceptuj';

  @override
  String get details => 'Szczegóły';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Kanał';

  @override
  String get likes => 'Polubienia';

  @override
  String get dislikes => 'Nie lubi';

  @override
  String get views => 'Wyświetlenia';

  @override
  String get streamUrl => 'URL strumienia';

  @override
  String get stop => 'Stop';

  @override
  String get sort_newest => 'Sortuj według ostatnio dodanych';

  @override
  String get sort_oldest => 'Sortuj według najstarszych dodanych';

  @override
  String get sleep_timer => 'Minutnik';

  @override
  String mins(Object minutes) {
    return '$minutes Minuty';
  }

  @override
  String hours(Object hours) {
    return '$hours Godziny';
  }

  @override
  String hour(Object hours) {
    return '$hours Godzina';
  }

  @override
  String get custom_hours => 'Własne godziny';

  @override
  String get logs => 'Logi';

  @override
  String get developers => 'Developerzy';

  @override
  String get not_logged_in => 'Nie jesteś zalogowany';

  @override
  String get search_mode => 'Tryb szukania';

  @override
  String get audio_source => 'Źródło dźwięku';

  @override
  String get ok => 'Ok';

  @override
  String get failed_to_encrypt => 'Nie można zaszyfrować :(';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq używa szyfrowania do bezpiecznego przechowywania danych. Ale nie udało się tego zrobić. Więc powróci do niezabezpieczonego przechowywania\nJeśli używasz Linuksa, upewnij się, że masz zainstalowane jakieś usługi do szyfrowania (gnome-keyring, kde-wallet, keepassxc itp.)';

  @override
  String get querying_info => 'Szukam informacji...';

  @override
  String get piped_api_down => 'API Piped jest niedostępne';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'Instancja Piped $pipedInstance jest obecnie niedostępna\n\nZmień instancję lub zmień \'Rodzaj API\' na oficjalne API YouTube\n\nUpewnij się, że po zmianie zrestartujesz aplikację';
  }

  @override
  String get you_are_offline => 'Obecnie jesteś offline';

  @override
  String get connection_restored =>
      'Twoje połączenie z internetem zostało przywrócone';

  @override
  String get use_system_title_bar => 'Użyj paska tytułu systemu';

  @override
  String get crunching_results => 'Przetwarzanie wyników...';

  @override
  String get search_to_get_results => 'Szukaj, aby uzyskać wyniki';

  @override
  String get use_amoled_mode => 'Tryb AMOLED';

  @override
  String get pitch_dark_theme => 'Ciemny motyw';

  @override
  String get normalize_audio => 'Normalizuj dźwięk';

  @override
  String get change_cover => 'Zmień okładkę';

  @override
  String get add_cover => 'Dodaj okładkę';

  @override
  String get restore_defaults => 'Przywróć domyślne';

  @override
  String get download_music_format => 'Format pobierania muzyki';

  @override
  String get streaming_music_format => 'Format strumieniowania muzyki';

  @override
  String get download_music_quality => 'Jakość pobierania';

  @override
  String get streaming_music_quality => 'Jakość strumieniowania';

  @override
  String get login_with_lastfm => 'Zaloguj się z Last.fm';

  @override
  String get connect => 'Połącz';

  @override
  String get disconnect_lastfm => 'Rozłącz z Last.fm';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get password => 'Hasło';

  @override
  String get login => 'Zaloguj';

  @override
  String get login_with_your_lastfm => 'Zaloguj się na swoje konto Last.fm';

  @override
  String get scrobble_to_lastfm => 'Scrobbluj do Last.fm';

  @override
  String get go_to_album => 'Przejdź do albumu';

  @override
  String get discord_rich_presence => 'Obecność na Discordzie';

  @override
  String get browse_all => 'Przeglądaj wszystko';

  @override
  String get genres => 'Gatunki muzyczne';

  @override
  String get explore_genres => 'Eksploruj gatunki';

  @override
  String get friends => 'Przyjaciele';

  @override
  String get no_lyrics_available =>
      'Przepraszamy, nie można znaleźć tekstu dla tego utworu';

  @override
  String get start_a_radio => 'Uruchom radio';

  @override
  String get how_to_start_radio => 'Jak chcesz uruchomić radio?';

  @override
  String get replace_queue_question =>
      'Czy chcesz zastąpić bieżącą kolejkę czy dodać do niej?';

  @override
  String get endless_playback => 'Nieskończona Odtwarzanie';

  @override
  String get delete_playlist => 'Usuń Playlistę';

  @override
  String get delete_playlist_confirmation =>
      'Czy na pewno chcesz usunąć tę listę odtwarzania?';

  @override
  String get local_tracks => 'Lokalne Utwory';

  @override
  String get local_tab => 'Lokalny';

  @override
  String get song_link => 'Link do Utworu';

  @override
  String get youtube_source_description => 'Polecane i działa najlepiej.';

  @override
  String get piped_source_description =>
      'Czujesz się wolny? To samo co YouTube, ale dużo za darmo.';

  @override
  String get jiosaavn_source_description =>
      'Najlepszy dla regionu Azji Południowej.';

  @override
  String get invidious_source_description =>
      'Podobne do Piped, ale o wyższej dostępności.';

  @override
  String highest_quality(Object quality) {
    return 'Najwyższa Jakość: $quality';
  }

  @override
  String get select_audio_source => 'Wybierz Źródło Audio';

  @override
  String get contribute_on_github => 'Przyczyniaj się na GitHubie';

  @override
  String get browse_anonymously => 'Przeglądaj Anonimowo';

  @override
  String get enable_connect => 'Włącz połączenie';

  @override
  String get enable_connect_description =>
      'Kontroluj DeeMusiq z innych urządzeń';

  @override
  String get devices => 'Urządzenia';

  @override
  String get select => 'Wybierz';

  @override
  String connect_client_alert(Object client) {
    return 'Jesteś sterowany przez $client';
  }

  @override
  String get this_device => 'To urządzenie';

  @override
  String get remote => 'Zdalny';

  @override
  String get stats => 'Statystyki';

  @override
  String and_n_more(Object count) {
    return 'i $count więcej';
  }

  @override
  String get recently_played => 'Ostatnio odtwarzane';

  @override
  String get browse_more => 'Zobacz więcej';

  @override
  String get no_title => 'Brak tytułu';

  @override
  String get not_playing => 'Nie odtwarzane';

  @override
  String get epic_failure => 'Epicka porażka!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return 'Dodano $tracks_length utworów do kolejki';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq ma aktualizację';

  @override
  String get download_now => 'Pobierz teraz';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum został wydany';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version został wydany';
  }

  @override
  String get read_the_latest => 'Przeczytaj najnowsze ';

  @override
  String get release_notes => 'notatki o wersji';

  @override
  String get pick_color_scheme => 'Wybierz schemat kolorów';

  @override
  String get save => 'Zapisz';

  @override
  String get choose_the_device => 'Wybierz urządzenie:';

  @override
  String get multiple_device_connected =>
      'Jest wiele urządzeń podłączonych.\nWybierz urządzenie, na którym chcesz wykonać tę akcję';

  @override
  String get nothing_found => 'Nic nie znaleziono';

  @override
  String get the_box_is_empty => 'Pudełko jest puste';

  @override
  String get top_artists => 'Najlepsi artyści';

  @override
  String get top_albums => 'Najlepsze albumy';

  @override
  String get this_week => 'W tym tygodniu';

  @override
  String get this_month => 'W tym miesiącu';

  @override
  String get last_6_months => 'Ostatnie 6 miesięcy';

  @override
  String get this_year => 'W tym roku';

  @override
  String get last_2_years => 'Ostatnie 2 lata';

  @override
  String get all_time => 'Wszystkie czasy';

  @override
  String powered_by_provider(Object providerName) {
    return 'Napędzane przez $providerName';
  }

  @override
  String get email => 'E-mail';

  @override
  String get profile_followers => 'Obserwujący';

  @override
  String get birthday => 'Data urodzenia';

  @override
  String get subscription => 'Subskrypcja';

  @override
  String get not_born => 'Nie urodzony';

  @override
  String get hacker => 'Haker';

  @override
  String get profile => 'Profil';

  @override
  String get no_name => 'Brak nazwy';

  @override
  String get edit => 'Edytuj';

  @override
  String get user_profile => 'Profil użytkownika';

  @override
  String count_plays(Object count) {
    return '$count odtworzeń';
  }

  @override
  String get minutes_listened => 'Minuty odsłuchane';

  @override
  String get streamed_songs => 'Strumieniowane utwory';

  @override
  String count_streams(Object count) {
    return '$count strumieni';
  }

  @override
  String get owned_by_you => 'Własność Twoja';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl skopiowano do schowka';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes min';
  }

  @override
  String get summary_minutes => 'minuty';

  @override
  String get summary_listened_to_music => 'Słuchana muzyka';

  @override
  String get summary_songs => 'utwory';

  @override
  String get summary_streamed_overall => 'Ogółem streamowane';

  @override
  String get summary_artists => 'artystów';

  @override
  String get summary_music_reached_you => 'Muzyka dotarła do Ciebie';

  @override
  String get summary_full_albums => 'pełne albumy';

  @override
  String get summary_got_your_love => 'Otrzymał Twoją miłość';

  @override
  String get summary_playlists => 'playlisty';

  @override
  String get summary_were_on_repeat => 'Były na powtarzaniu';

  @override
  String get webview_not_found => 'Nie znaleziono Webview';

  @override
  String get webview_not_found_description =>
      'Na twoim urządzeniu nie zainstalowano środowiska uruchomieniowego Webview.\nJeśli jest zainstalowany, upewnij się, że jest w environment PATH\n\nPo instalacji uruchom ponownie aplikację';

  @override
  String get unsupported_platform => 'Nieobsługiwana platforma';

  @override
  String get cache_music => 'Pamięć podręczna muzyki';

  @override
  String get open => 'Otwórz';

  @override
  String get cache_folder => 'Folder pamięci podręcznej';

  @override
  String get export => 'Eksportuj';

  @override
  String get clear_cache => 'Wyczyść pamięć podręczną';

  @override
  String get clear_cache_confirmation =>
      'Czy chcesz wyczyścić pamięć podręczną?';

  @override
  String get export_cache_files => 'Eksportuj pliki z pamięci podręcznej';

  @override
  String found_n_files(Object count) {
    return 'Znaleziono $count plików';
  }

  @override
  String get export_cache_confirmation =>
      'Czy chcesz wyeksportować te pliki do';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return 'Wyeksportowano $filesExported z $files plików';
  }

  @override
  String get undo => 'Cofnij';

  @override
  String get download_all => 'Pobierz wszystko';

  @override
  String get add_all_to_playlist => 'Dodaj wszystko do playlisty';

  @override
  String get add_all_to_queue => 'Dodaj wszystko do kolejki';

  @override
  String get play_all_next => 'Odtwórz wszystko następnie';

  @override
  String get pause => 'Pauza';

  @override
  String get view_all => 'Zobacz wszystko';

  @override
  String get no_tracks_added_yet =>
      'Wygląda na to, że jeszcze nie dodałeś żadnych utworów';

  @override
  String get no_tracks => 'Wygląda na to, że tutaj nie ma żadnych utworów';

  @override
  String get no_tracks_listened_yet =>
      'Wygląda na to, że jeszcze nic nie słuchałeś';

  @override
  String get not_following_artists => 'Nie obserwujesz żadnych artystów';

  @override
  String get no_favorite_albums_yet =>
      'Wygląda na to, że jeszcze nie dodałeś żadnych albumów do ulubionych';

  @override
  String get no_logs_found => 'Nie znaleziono żadnych logów';

  @override
  String get youtube_engine => 'Silnik YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine nie jest zainstalowany';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine nie jest zainstalowany w systemie.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Upewnij się, że jest dostępny w zmiennej PATH lub\nustaw absolutną ścieżkę do pliku wykonywalnego $engine poniżej';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'W systemach macOS/Linux/unix, ustawianie ścieżki w .zshrc/.bashrc/.bash_profile itp. nie będzie działać.\nMusisz ustawić ścieżkę w pliku konfiguracyjnym powłoki';

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
  String get download => 'Pobierz';

  @override
  String get file_not_found => 'Plik nie znaleziony';

  @override
  String get custom => 'Niestandardowy';

  @override
  String get add_custom_url => 'Dodaj niestandardowy URL';

  @override
  String get edit_port => 'Edytuj port';

  @override
  String get port_helper_msg =>
      'Domyślna wartość to -1, co oznacza losową liczbę. Jeśli masz skonfigurowany zaporę, zaleca się jej ustawienie.';

  @override
  String connect_request(Object client) {
    return 'Zezwolić $client na połączenie?';
  }

  @override
  String get connection_request_denied =>
      'Połączenie odrzucone. Użytkownik odmówił dostępu.';

  @override
  String get an_error_occurred => 'Wystąpił błąd';

  @override
  String get copy_to_clipboard => 'Kopiuj do schowka';

  @override
  String get view_logs => 'Wyświetl logi';

  @override
  String get retry => 'Ponów';

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
      'Nie masz ustawionego domyślnego dostawcy metadanych';

  @override
  String get manage_metadata_providers => 'Zarządzaj dostawcami metadanych';

  @override
  String get open_link_in_browser => 'Otworzyć link w przeglądarce?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Czy chcesz otworzyć następujący link';

  @override
  String get unsafe_url_warning =>
      'Otwieranie linków z niezaufanych źródeł może być niebezpieczne. Zachowaj ostrożność!\nMożesz również skopiować link do schowka.';

  @override
  String get copy_link => 'Kopiuj link';

  @override
  String get building_your_timeline =>
      'Budowanie Twojej osi czasu na podstawie Twoich odsłuchań...';

  @override
  String get official => 'Oficjalny';

  @override
  String author_name(Object author) {
    return 'Autor: $author';
  }

  @override
  String get third_party => 'Zewnętrzny';

  @override
  String get plugin_requires_authentication =>
      'Wtyczka wymaga uwierzytelnienia';

  @override
  String get update_available => 'Dostępna aktualizacja';

  @override
  String get supports_scrobbling => 'Obsługuje scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'Ta wtyczka scrobbluje Twoją muzykę, aby wygenerować historię odsłuchań.';

  @override
  String get default_metadata_source => 'Domyślne źródło metadanych';

  @override
  String get set_default_metadata_source => 'Ustaw domyślne źródło metadanych';

  @override
  String get default_audio_source => 'Domyślne źródło audio';

  @override
  String get set_default_audio_source => 'Ustaw domyślne źródło audio';

  @override
  String get set_default => 'Ustaw jako domyślną';

  @override
  String get support => 'Wsparcie';

  @override
  String get support_plugin_development => 'Wspieraj rozwój wtyczki';

  @override
  String can_access_name_api(Object name) {
    return '- Może uzyskać dostęp do API **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Czy chcesz zainstalować tę wtyczkę?';

  @override
  String get third_party_plugin_warning =>
      'Ta wtyczka pochodzi z zewnętrznego repozytorium. Upewnij się, że ufasz źródłu przed instalacją.';

  @override
  String get author => 'Autor';

  @override
  String get this_plugin_can_do_following =>
      'Ta wtyczka może wykonywać następujące czynności';

  @override
  String get install => 'Instaluj';

  @override
  String get no_tracks_playing => 'Obecnie nie odtwarzany jest żaden utwór';

  @override
  String get synced_lyrics_not_available =>
      'Zsynchronizowane teksty nie są dostępne dla tego utworu. Zamiast tego użyj zakładki';

  @override
  String get plain_lyrics => 'Zwykłe teksty';

  @override
  String get tab_instead => 'zamiast tego.';

  @override
  String get disclaimer => 'Zastrzeżenie';

  @override
  String get third_party_plugin_dmca_notice =>
      'Zespół DeeMusiq nie ponosi żadnej odpowiedzialności (w tym prawnej) za żadne wtyczki \"zewnętrzne\".\nUżywaj ich na własne ryzyko. Wszelkie błędy/problemy prosimy zgłaszać w repozytorium wtyczki.\n\nJeśli jakakolwiek wtyczka \"zewnętrzna\" narusza ToS/DMCA jakiejkolwiek usługi/podmiotu prawnego, prosimy o kontakt z autorem wtyczki \"zewnętrznej\" lub platformą hostingową, np. GitHub/Codeberg, w celu podjęcia działań. Wymienione powyżej (oznaczone jako \"zewnętrzne\") są publicznymi wtyczkami utrzymywanymi przez społeczność. Nie kuratujemy ich, więc nie możemy podjąć żadnych działań w ich sprawie.\n\n';

  @override
  String get plugins => 'Wtyczki';

  @override
  String get paste_plugin_download_url =>
      'Wklej adres URL do pobrania lub adres URL repozytorium GitHub/Codeberg lub bezpośredni link do pliku .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'Pobierz i zainstaluj wtyczkę z adresu URL';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Nie udało się dodać wtyczki: $error';
  }

  @override
  String get upload_plugin_from_file => 'Prześlij wtyczkę z pliku';

  @override
  String get installed => 'Zainstalowane';

  @override
  String get available_plugins => 'Dostępne wtyczki';

  @override
  String get configure_plugins =>
      'Skonfiguruj własne wtyczki dostawców metadanych i źródeł audio';

  @override
  String get audio_scrobblers => 'Scrobblery audio';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Źródło: ';

  @override
  String get uncompressed => 'Nieskompresowany';

  @override
  String get dab_music_source_description =>
      'Dla audiofilów. Oferuje strumienie audio wysokiej jakości/lossless. Precyzyjne dopasowanie utworów na podstawie ISRC.';

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
  String get skip_this_nonsense => 'Pomiń tę bzdurę';

  @override
  String get freedom_of_music => '“Wolność Muzyki”';

  @override
  String get freedom_of_music_palm => '“Wolność Muzyki w Twojej dłoni”';

  @override
  String get get_started => 'Zacznijmy';

  @override
  String get endless_playback_description =>
      'Automatycznie dodaj nowe utwory na koniec kolejki';

  @override
  String get choose_your_region => 'Wybierz swoją region';

  @override
  String get choose_your_region_description =>
      'To pomoże DeeMusiq pokazać Ci odpowiednią treść dla Twojej lokalizacji.';

  @override
  String get choose_your_language => 'Wybierz swój język';

  @override
  String get help_project_grow => 'Pomóż temu projektowi rosnąć';

  @override
  String get help_project_grow_description =>
      'DeeMusiq to projekt open-source. Możesz pomóc temu projektowi rosnąć, przyczyniając się do projektu, zgłaszając błędy lub sugerując nowe funkcje.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Dotuj na Open Collective';

  @override
  String get install_a_metadata_provider => 'Zainstaluj dostawcę metadanych';

  @override
  String get input_does_not_match_format =>
      'Wprowadzony tekst nie pasuje do wymaganego formatu';

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
  String get creator_email_gate_title => 'Sign in with email to create';

  @override
  String get creator_email_gate_body =>
      'The Creator Studio belongs to your email + password account. Sign in below, or create an account — we email you a 6-digit code to verify the address.';

  @override
  String get creator_sign_in_cta => 'Sign in';

  @override
  String get creator_add_email_title => 'Add an email to become a creator';

  @override
  String get creator_add_email_body =>
      'This account is device-only. Add an email and password — we\'ll email you a 6-digit code to confirm the address.';

  @override
  String get creator_save_and_email_code => 'Save & email code';

  @override
  String get creator_verify_email_title => 'Verify your email';

  @override
  String creator_verify_email_body(String email) {
    return 'We emailed a 6-digit code to $email. Enter it below to unlock the Creator Studio.';
  }

  @override
  String get creator_email_code_sent =>
      'Check your inbox — a new code is on its way.';

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
  String get auth_mfa_required => 'Wprowadź kod uwierzytelniający';

  @override
  String get auth_mfa_body =>
      'Otwórz aplikację uwierzytelniającą i wpisz 6-cyfrowy kod, aby zakończyć logowanie.';

  @override
  String get auth_mfa_verify_action => 'Zweryfikuj';

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

  @override
  String get signup_create_account => 'Create an account';

  @override
  String get signup_title => 'Create your DeeMusiq account';

  @override
  String get signup_subtitle =>
      'Sign up with any email address and a password. No device setup needed.';

  @override
  String get signup_email_hint => 'Email address';

  @override
  String get signup_password_hint => 'Password';

  @override
  String get signup_password_rule =>
      'At least 12 characters, using 3 of: uppercase, lowercase, a number, a symbol.';

  @override
  String get signup_invalid_email => 'Enter a valid email address.';

  @override
  String get signup_enter_password => 'Enter a password.';

  @override
  String get signup_confirm => 'Confirm my email';

  @override
  String signup_code_sent(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String signup_enter_code(String email) {
    return 'Enter the 6-digit code we emailed to $email.';
  }

  @override
  String get signup_code_hint => '6-digit code';

  @override
  String get signup_code_length => 'Enter the 6-digit code from your email.';

  @override
  String get signup_resend_code => 'Send a new code';

  @override
  String get signup_code_resent => 'A new code is on its way.';

  @override
  String get signup_back_to_sign_in => 'Back to sign in';
}
