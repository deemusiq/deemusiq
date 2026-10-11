// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get guest => 'Invité';

  @override
  String get browse => 'Explorer';

  @override
  String get search => 'Rechercher';

  @override
  String get library => 'Bibliothèque';

  @override
  String get lyrics => 'Paroles';

  @override
  String get settings => 'Paramètres';

  @override
  String get genre_categories_filter =>
      'Filtrer les catégories ou les genres...';

  @override
  String get genre => 'Genre';

  @override
  String get personalized => 'Personnalisé';

  @override
  String get featured => 'En vedette';

  @override
  String get new_releases => 'Nouvelles sorties';

  @override
  String get songs => 'Chansons';

  @override
  String playing_track(Object track) {
    return 'Lecture de $track';
  }

  @override
  String queue_clear_alert(Object track_length) {
    return 'Cela effacera la file d\'attente actuelle. $track_length pistes seront supprimées\nVoulez-vous continuer?';
  }

  @override
  String get load_more => 'Charger plus';

  @override
  String get playlists => 'Listes de lecture';

  @override
  String get artists => 'Artistes';

  @override
  String get albums => 'Albums';

  @override
  String get tracks => 'Pistes';

  @override
  String get downloads => 'Téléchargements';

  @override
  String get filter_playlists => 'Filtrer vos listes de lecture...';

  @override
  String get liked_tracks => 'Pistes aimées';

  @override
  String get liked_tracks_description => 'Toutes vos pistes aimées';

  @override
  String get playlist => 'Playlist';

  @override
  String get create_a_playlist => 'Créer une liste de lecture';

  @override
  String get update_playlist => 'Mettre à jour la playlist';

  @override
  String get create => 'Créer';

  @override
  String get cancel => 'Annuler';

  @override
  String get update => 'Mettre à jour';

  @override
  String get playlist_name => 'Nom de la liste de lecture';

  @override
  String get name_of_playlist => 'Nom de la liste de lecture';

  @override
  String get description => 'Description';

  @override
  String get public => 'Public';

  @override
  String get collaborative => 'Collaborative';

  @override
  String get search_local_tracks => 'Rechercher des pistes locales...';

  @override
  String get play => 'Lecture';

  @override
  String get delete => 'Supprimer';

  @override
  String get none => 'Aucun';

  @override
  String get sort_a_z => 'Trier par ordre alphabétique';

  @override
  String get sort_z_a => 'Trier par ordre alphabétique inverse';

  @override
  String get sort_artist => 'Trier par artiste';

  @override
  String get sort_album => 'Trier par album';

  @override
  String get sort_duration => 'Trier par durée';

  @override
  String get sort_tracks => 'Trier les pistes';

  @override
  String currently_downloading(Object tracks_length) {
    return 'Téléchargement en cours ($tracks_length)';
  }

  @override
  String get cancel_all => 'Tout annuler';

  @override
  String get filter_artist => 'Filtrer les artistes...';

  @override
  String followers(Object followers) {
    return '$followers abonnés';
  }

  @override
  String get add_artist_to_blacklist => 'Ajouter l\'artiste à la liste noire';

  @override
  String get top_tracks => 'Meilleures pistes';

  @override
  String get fans_also_like => 'Les fans aiment aussi';

  @override
  String get loading => 'Chargement...';

  @override
  String get artist => 'Artiste';

  @override
  String get blacklisted => 'Liste noire';

  @override
  String get following => 'Abonné';

  @override
  String get follow => 'S\'abonner';

  @override
  String get artist_url_copied =>
      'URL de l\'artiste copiée dans le presse-papiers';

  @override
  String added_to_queue(Object tracks) {
    return '$tracks pistes ajoutées à la file d\'attente';
  }

  @override
  String get filter_albums => 'Filtrer les albums...';

  @override
  String get synced => 'Synchronisé';

  @override
  String get plain => 'Simple';

  @override
  String get shuffle => 'Lecture aléatoire';

  @override
  String get search_tracks => 'Rechercher des pistes...';

  @override
  String get released => 'Sorti';

  @override
  String error(Object error) {
    return 'Erreur $error';
  }

  @override
  String get title => 'Titre';

  @override
  String get time => 'Durée';

  @override
  String get more_actions => 'Plus d\'actions';

  @override
  String download_count(Object count) {
    return 'Téléchargement ($count)';
  }

  @override
  String add_count_to_playlist(Object count) {
    return 'Ajouter ($count) à la liste de lecture';
  }

  @override
  String add_count_to_queue(Object count) {
    return 'Ajouter ($count) à la file d\'attente';
  }

  @override
  String play_count_next(Object count) {
    return 'Lire ($count) ensuite';
  }

  @override
  String get album => 'Album';

  @override
  String copied_to_clipboard(Object data) {
    return '$data copié dans le presse-papiers';
  }

  @override
  String add_to_following_playlists(Object track) {
    return 'Ajouter $track aux listes de lecture suivantes';
  }

  @override
  String get add => 'Ajouter';

  @override
  String added_track_to_queue(Object track) {
    return '$track ajouté à la file d\'attente';
  }

  @override
  String get add_to_queue => 'Ajouter à la file d\'attente';

  @override
  String track_will_play_next(Object track) {
    return '$track sera joué ensuite';
  }

  @override
  String get play_next => 'Lire ensuite';

  @override
  String removed_track_from_queue(Object track) {
    return '$track retiré de la file d\'attente';
  }

  @override
  String get remove_from_queue => 'Retirer de la file d\'attente';

  @override
  String get remove_from_favorites => 'Retirer des favoris';

  @override
  String get save_as_favorite => 'Enregistrer comme favori';

  @override
  String get add_to_playlist => 'Ajouter à la liste de lecture';

  @override
  String get remove_from_playlist => 'Retirer de la liste de lecture';

  @override
  String get add_to_blacklist => 'Ajouter à la liste noire';

  @override
  String get remove_from_blacklist => 'Retirer de la liste noire';

  @override
  String get share => 'Partager';

  @override
  String get mini_player => 'Lecteur mini';

  @override
  String get slide_to_seek => 'Faites glisser pour avancer ou reculer';

  @override
  String get shuffle_playlist => 'Lecture aléatoire de la liste de lecture';

  @override
  String get unshuffle_playlist =>
      'Annuler la lecture aléatoire de la liste de lecture';

  @override
  String get previous_track => 'Piste précédente';

  @override
  String get next_track => 'Piste suivante';

  @override
  String get pause_playback => 'Mettre en pause la lecture';

  @override
  String get resume_playback => 'Reprendre la lecture';

  @override
  String get loop_track => 'Lecture en boucle de la piste';

  @override
  String get no_loop => 'Pas de boucle';

  @override
  String get repeat_playlist => 'Répéter la liste de lecture';

  @override
  String get queue => 'File d\'attente';

  @override
  String get alternative_track_sources => 'Sources alternatives de pistes';

  @override
  String get download_track => 'Télécharger la piste';

  @override
  String tracks_in_queue(Object tracks) {
    return '$tracks pistes dans la file d\'attente';
  }

  @override
  String get clear_all => 'Tout effacer';

  @override
  String get show_hide_ui_on_hover =>
      'Afficher/Masquer l\'interface utilisateur au survol';

  @override
  String get always_on_top => 'Toujours au-dessus';

  @override
  String get exit_mini_player => 'Quitter le lecteur mini';

  @override
  String get download_location => 'Emplacement de téléchargement';

  @override
  String get local_library => 'Bibliothèque locale';

  @override
  String get add_library_location => 'Ajouter à la bibliothèque';

  @override
  String get remove_library_location => 'Retirer de la bibliothèque';

  @override
  String get account => 'Compte';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logout_of_this_account => 'Se déconnecter de ce compte';

  @override
  String get language_region => 'Langue et région';

  @override
  String get language => 'Langue';

  @override
  String get system_default => 'Paramètres par défaut du système';

  @override
  String get market_place_region => 'Région du marché';

  @override
  String get recommendation_country => 'Pays de recommandation';

  @override
  String get appearance => 'Apparence';

  @override
  String get layout_mode => 'Mode de mise en page';

  @override
  String get override_layout_settings =>
      'Remplacer les paramètres de mise en page adaptative';

  @override
  String get adaptive => 'Adaptatif';

  @override
  String get compact => 'Compact';

  @override
  String get extended => 'Étendu';

  @override
  String get theme => 'Thème';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get system => 'Système';

  @override
  String get accent_color => 'Couleur d\'accentuation';

  @override
  String get sync_album_color => 'Synchroniser la couleur de l\'album';

  @override
  String get sync_album_color_description =>
      'Utilise la couleur dominante de l\'art de l\'album comme couleur d\'accentuation';

  @override
  String get playback => 'Lecture';

  @override
  String get audio_quality => 'Qualité audio';

  @override
  String get high => 'Haute';

  @override
  String get low => 'Basse';

  @override
  String get pre_download_play => 'Pré-télécharger et lire';

  @override
  String get pre_download_play_description =>
      'Au lieu de diffuser de l\'audio, téléchargez les octets et lisez-les à la place (recommandé pour les utilisateurs à bande passante élevée)';

  @override
  String get skip_non_music =>
      'Ignorer les segments non musicaux (SponsorBlock)';

  @override
  String get blacklist_description => 'Pistes et artistes en liste noire';

  @override
  String get wait_for_download_to_finish =>
      'Veuillez attendre la fin du téléchargement en cours';

  @override
  String get desktop => 'Bureau';

  @override
  String get close_behavior => 'Comportement de fermeture';

  @override
  String get close => 'Fermer';

  @override
  String get minimize_to_tray => 'Réduire dans la zone de notification';

  @override
  String get show_tray_icon => 'Afficher l\'icône de la zone de notification';

  @override
  String get about => 'À propos';

  @override
  String get u_love_spotube => 'Nous savons que vous aimez DeeMusiq';

  @override
  String get check_for_updates => 'Vérifier les mises à jour';

  @override
  String get about_spotube => 'À propos de DeeMusiq';

  @override
  String get blacklist => 'Liste noire';

  @override
  String get please_sponsor => 'S\'il vous plaît Sponsoriser/Donner';

  @override
  String get spotube_description =>
      'DeeMusiq, un client Spotify léger, multiplateforme et gratuit pour tous';

  @override
  String get version => 'Version';

  @override
  String get build_number => 'Numéro de version';

  @override
  String get founder => 'Fondateur';

  @override
  String get repository => 'Dépôt';

  @override
  String get bug_issues => 'Bugs + Problèmes';

  @override
  String get made_with => 'Fabriqué avec ❤️ au Bangladesh🇧🇩';

  @override
  String get kingkor_roy_tirtho => 'Kingkor Roy Tirtho';

  @override
  String copyright(Object current_year) {
    return '© 2021-$current_year Kingkor Roy Tirtho';
  }

  @override
  String get license => 'Licence';

  @override
  String get credentials_will_not_be_shared_disclaimer =>
      'Ne vous inquiétez pas, vos identifiants ne seront ni collectés ni partagés avec qui que ce soit';

  @override
  String get know_how_to_login => 'Vous ne savez pas comment faire?';

  @override
  String get follow_step_by_step_guide => 'Suivez le guide étape par étape';

  @override
  String cookie_name_cookie(Object name) {
    return 'Cookie $name';
  }

  @override
  String get fill_in_all_fields => 'Veuillez remplir tous les champs';

  @override
  String get submit => 'Soumettre';

  @override
  String get exit => 'Quitter';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get done => 'Terminé';

  @override
  String get step_1 => 'Étape 1';

  @override
  String get first_go_to => 'Tout d\'abord, allez sur';

  @override
  String get something_went_wrong => 'Quelque chose s\'est mal passé';

  @override
  String get piped_instance => 'Instance pipée';

  @override
  String get piped_description =>
      'L\'instance de serveur Piped à utiliser pour la correspondance des pistes';

  @override
  String get piped_warning =>
      'Certaines d\'entre elles peuvent ne pas fonctionner correctement. Alors utilisez à vos risques et périls';

  @override
  String get invidious_instance => 'Instance de serveur Invidious';

  @override
  String get invidious_description =>
      'L\'instance de serveur Invidious à utiliser pour la correspondance de pistes';

  @override
  String get invidious_warning =>
      'Certaines instances pourraient ne pas bien fonctionner. À utiliser à vos risques et périls';

  @override
  String get generate => 'Générer';

  @override
  String track_exists(Object track) {
    return 'La piste $track existe déjà';
  }

  @override
  String get replace_downloaded_tracks =>
      'Remplacer toutes les pistes téléchargées';

  @override
  String get skip_download_tracks =>
      'Ignorer le téléchargement de toutes les pistes téléchargées';

  @override
  String get do_you_want_to_replace =>
      'Voulez-vous remplacer la piste existante ?';

  @override
  String get replace => 'Remplacer';

  @override
  String get skip => 'Passer';

  @override
  String select_up_to_count_type(Object count, Object type) {
    return 'Sélectionnez jusqu\'à $count $type';
  }

  @override
  String get select_genres => 'Sélectionner les genres';

  @override
  String get add_genres => 'Ajouter des genres';

  @override
  String get country => 'Pays';

  @override
  String get number_of_tracks_generate => 'Nombre de pistes à générer';

  @override
  String get acousticness => 'Acoustique';

  @override
  String get danceability => 'Dansabilité';

  @override
  String get energy => 'Énergie';

  @override
  String get instrumentalness => 'Instrumentalité';

  @override
  String get liveness => 'Interprétation en direct';

  @override
  String get loudness => 'Sonorité';

  @override
  String get speechiness => 'Parlé';

  @override
  String get valence => 'Valeur émotionnelle';

  @override
  String get popularity => 'Popularité';

  @override
  String get key => 'Clé';

  @override
  String get duration => 'Durée (s)';

  @override
  String get tempo => 'Tempo (BPM)';

  @override
  String get mode => 'Mode';

  @override
  String get time_signature => 'Signature rythmique';

  @override
  String get short => 'Court';

  @override
  String get medium => 'Moyen';

  @override
  String get long => 'Long';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get target => 'Cible';

  @override
  String get moderate => 'Modéré';

  @override
  String get deselect_all => 'Tout désélectionner';

  @override
  String get select_all => 'Tout sélectionner';

  @override
  String get are_you_sure => 'Êtes-vous sûr(e) ?';

  @override
  String get generating_playlist =>
      'Génération de votre playlist personnalisée en cours...';

  @override
  String selected_count_tracks(Object count) {
    return '$count pistes sélectionnées';
  }

  @override
  String get download_warning =>
      'Si vous téléchargez toutes les pistes en vrac, vous violez clairement les droits d\'auteur de la musique et vous causez des dommages à la société créative de la musique. J\'espère que vous en êtes conscient. Essayez toujours de respecter et de soutenir le travail acharné des artistes.';

  @override
  String get download_ip_ban_warning =>
      'Au fait, votre adresse IP peut être bloquée sur YouTube en raison d\'une demande excessive de téléchargements par rapport à la normale. Le blocage de l\'IP signifie que vous ne pourrez pas utiliser YouTube (même si vous êtes connecté) pendant au moins 2 à 3 mois à partir de cet appareil IP. Et DeeMusiq ne peut être tenu responsable si cela se produit.';

  @override
  String get by_clicking_accept_terms =>
      'En cliquant sur \'accepter\', vous acceptez les conditions suivantes :';

  @override
  String get download_agreement_1 =>
      'Je sais que je pirate de la musique. Je suis méchant(e).';

  @override
  String get download_agreement_2 =>
      'Je soutiendrai l\'artiste autant que possible et je ne fais cela que parce que je n\'ai pas d\'argent pour acheter leur art.';

  @override
  String get download_agreement_3 =>
      'Je suis parfaitement conscient(e) que mon adresse IP peut être bloquée sur YouTube et je ne tiens pas DeeMusiq ni ses propriétaires/contributeurs responsables de tout accident causé par mon action actuelle.';

  @override
  String get decline => 'Refuser';

  @override
  String get accept => 'Accepter';

  @override
  String get details => 'Détails';

  @override
  String get youtube => 'YouTube';

  @override
  String get channel => 'Chaîne';

  @override
  String get likes => 'J\'aime';

  @override
  String get dislikes => 'Je n\'aime pas';

  @override
  String get views => 'Vues';

  @override
  String get streamUrl => 'URL de diffusion';

  @override
  String get stop => 'Arrêter';

  @override
  String get sort_newest => 'Trier par les plus récents';

  @override
  String get sort_oldest => 'Trier par les plus anciens';

  @override
  String get sleep_timer => 'Minuteur de veille';

  @override
  String mins(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String hours(Object hours) {
    return '$hours heures';
  }

  @override
  String hour(Object hours) {
    return '$hours heure';
  }

  @override
  String get custom_hours => 'Heures personnalisées';

  @override
  String get logs => 'Journaux';

  @override
  String get developers => 'Développeurs';

  @override
  String get not_logged_in => 'Vous n\'êtes pas connecté(e)';

  @override
  String get search_mode => 'Mode de recherche';

  @override
  String get audio_source => 'Source audio';

  @override
  String get ok => 'OK';

  @override
  String get failed_to_encrypt => 'Échec de la cryptage';

  @override
  String get encryption_failed_warning =>
      'DeeMusiq utilise le cryptage pour stocker vos données en toute sécurité. Mais cela a échoué. Il basculera donc vers un stockage non sécurisé\nSi vous utilisez Linux, assurez-vous d\'avoir installé des services secrets tels que gnome-keyring, kde-wallet et keepassxc';

  @override
  String get querying_info => 'Interrogation des info...';

  @override
  String get piped_api_down => 'L\'API Piped est hors service';

  @override
  String piped_down_error_instructions(Object pipedInstance) {
    return 'L\'instance Piped $pipedInstance est actuellement indisponible\n\nChangez soit l\'instance, soit le \'Type d\'API\' pour utiliser l\'API officielle de YouTube\n\nN\'oubliez pas de redémarrer l\'application après la modification';
  }

  @override
  String get you_are_offline => 'Vous êtes actuellement hors ligne';

  @override
  String get connection_restored => 'Votre connexion internet a été rétablie';

  @override
  String get use_system_title_bar => 'Utiliser la barre de titre système';

  @override
  String get crunching_results => 'Traitement des résultats...';

  @override
  String get search_to_get_results => 'Recherche pour obtenir des résultats';

  @override
  String get use_amoled_mode => 'Utiliser le mode AMOLED';

  @override
  String get pitch_dark_theme => 'Thème Dart noir intense';

  @override
  String get normalize_audio => 'Normaliser l\'audio';

  @override
  String get change_cover => 'Changer de couverture';

  @override
  String get add_cover => 'Ajouter une couverture';

  @override
  String get restore_defaults => 'Restaurer les valeurs par défaut';

  @override
  String get download_music_format => 'Format de téléchargement de musique';

  @override
  String get streaming_music_format => 'Format de streaming de musique';

  @override
  String get download_music_quality => 'Qualité de téléchargement de musique';

  @override
  String get streaming_music_quality => 'Qualité de streaming de musique';

  @override
  String get login_with_lastfm => 'Se connecter avec Last.fm';

  @override
  String get connect => 'Connecter';

  @override
  String get disconnect_lastfm => 'Déconnecter de Last.fm';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get username => 'Nom d\'utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get login_with_your_lastfm => 'Se connecter avec votre compte Last.fm';

  @override
  String get scrobble_to_lastfm => 'Scrobble à Last.fm';

  @override
  String get go_to_album => 'Aller à l\'album';

  @override
  String get discord_rich_presence => 'Présence riche de Discord';

  @override
  String get browse_all => 'Parcourir tout';

  @override
  String get genres => 'Genres';

  @override
  String get explore_genres => 'Explorer les genres';

  @override
  String get friends => 'Amis';

  @override
  String get no_lyrics_available =>
      'Désolé, impossible de trouver les paroles de cette piste';

  @override
  String get start_a_radio => 'Démarrer une radio';

  @override
  String get how_to_start_radio => 'Comment voulez-vous démarrer la radio ?';

  @override
  String get replace_queue_question =>
      'Voulez-vous remplacer la file d\'attente actuelle ou y ajouter ?';

  @override
  String get endless_playback => 'Lecture sans fin';

  @override
  String get delete_playlist => 'Supprimer la playlist';

  @override
  String get delete_playlist_confirmation =>
      'Êtes-vous sûr de vouloir supprimer cette playlist ?';

  @override
  String get local_tracks => 'Titres locaux';

  @override
  String get local_tab => 'Local';

  @override
  String get song_link => 'Lien de la chanson';

  @override
  String get youtube_source_description => 'Recommandé et fonctionne mieux.';

  @override
  String get piped_source_description =>
      'Vous vous sentez libre ? Comme YouTube mais beaucoup plus gratuit.';

  @override
  String get jiosaavn_source_description =>
      'Le meilleur pour la région d\'Asie du Sud.';

  @override
  String get invidious_source_description =>
      'Similaire à Piped mais avec une meilleure disponibilité';

  @override
  String highest_quality(Object quality) {
    return 'Meilleure qualité : $quality';
  }

  @override
  String get select_audio_source => 'Sélectionner la source audio';

  @override
  String get contribute_on_github => 'Contribuer sur GitHub';

  @override
  String get browse_anonymously => 'Naviguer anonymement';

  @override
  String get enable_connect => 'Activer la connexion';

  @override
  String get enable_connect_description =>
      'Contrôlez DeeMusiq depuis d\'autres appareils';

  @override
  String get devices => 'Appareils';

  @override
  String get select => 'Sélectionner';

  @override
  String connect_client_alert(Object client) {
    return 'Vous êtes contrôlé par $client';
  }

  @override
  String get this_device => 'Cet appareil';

  @override
  String get remote => 'À distance';

  @override
  String get stats => 'Statistiques';

  @override
  String and_n_more(Object count) {
    return 'et $count de plus';
  }

  @override
  String get recently_played => 'Récemment joué';

  @override
  String get browse_more => 'Parcourir plus';

  @override
  String get no_title => 'Sans titre';

  @override
  String get not_playing => 'Non joué';

  @override
  String get epic_failure => 'Échec épique!';

  @override
  String added_num_tracks_to_queue(Object tracks_length) {
    return '$tracks_length morceaux ajoutés à la file d\'attente';
  }

  @override
  String get spotube_has_an_update => 'DeeMusiq a une mise à jour';

  @override
  String get download_now => 'Télécharger maintenant';

  @override
  String nightly_version(Object nightlyBuildNum) {
    return 'DeeMusiq Nightly $nightlyBuildNum a été publié';
  }

  @override
  String release_version(Object version) {
    return 'DeeMusiq v$version a été publié';
  }

  @override
  String get read_the_latest => 'Lisez les dernières ';

  @override
  String get release_notes => 'notes de version';

  @override
  String get pick_color_scheme => 'Choisissez le schéma de couleurs';

  @override
  String get save => 'Sauvegarder';

  @override
  String get choose_the_device => 'Choisissez l\'appareil:';

  @override
  String get multiple_device_connected =>
      'Plusieurs appareils sont connectés.\nChoisissez l\'appareil sur lequel vous souhaitez effectuer cette action';

  @override
  String get nothing_found => 'Rien trouvé';

  @override
  String get the_box_is_empty => 'La boîte est vide';

  @override
  String get top_artists => 'Meilleurs artistes';

  @override
  String get top_albums => 'Meilleurs albums';

  @override
  String get this_week => 'Cette semaine';

  @override
  String get this_month => 'Ce mois-ci';

  @override
  String get last_6_months => 'Les 6 derniers mois';

  @override
  String get this_year => 'Cette année';

  @override
  String get last_2_years => 'Les 2 dernières années';

  @override
  String get all_time => 'De tous les temps';

  @override
  String powered_by_provider(Object providerName) {
    return 'Propulsé par $providerName';
  }

  @override
  String get email => 'Email';

  @override
  String get profile_followers => 'Abonnés';

  @override
  String get birthday => 'Anniversaire';

  @override
  String get subscription => 'Abonnement';

  @override
  String get not_born => 'Non né';

  @override
  String get hacker => 'Hacker';

  @override
  String get profile => 'Profil';

  @override
  String get no_name => 'Sans nom';

  @override
  String get edit => 'Modifier';

  @override
  String get user_profile => 'Profil utilisateur';

  @override
  String count_plays(Object count) {
    return '$count lectures';
  }

  @override
  String get minutes_listened => 'Minutes écoutées';

  @override
  String get streamed_songs => 'Morceaux diffusés';

  @override
  String count_streams(Object count) {
    return '$count streams';
  }

  @override
  String get owned_by_you => 'Possédé par vous';

  @override
  String copied_shareurl_to_clipboard(Object shareUrl) {
    return '$shareUrl copié dans le presse-papier';
  }

  @override
  String count_mins(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get summary_minutes => 'minutes';

  @override
  String get summary_listened_to_music => 'A écouté de la musique';

  @override
  String get summary_songs => 'morceaux';

  @override
  String get summary_streamed_overall => 'Diffusé en général';

  @override
  String get summary_artists => 'artistes';

  @override
  String get summary_music_reached_you => 'La musique vous a atteint';

  @override
  String get summary_full_albums => 'albums complets';

  @override
  String get summary_got_your_love => 'A obtenu votre amour';

  @override
  String get summary_playlists => 'playlists';

  @override
  String get summary_were_on_repeat => 'Était en répétition';

  @override
  String get webview_not_found => 'Webview non trouvé';

  @override
  String get webview_not_found_description =>
      'Aucun environnement d\'exécution Webview installé sur votre appareil.\nSi c\'est installé, assurez-vous qu\'il soit dans le environment PATH\n\nAprès l\'installation, redémarrez l\'application';

  @override
  String get unsupported_platform => 'Plateforme non prise en charge';

  @override
  String get cache_music => 'Mettre la musique en cache';

  @override
  String get open => 'Ouvrir';

  @override
  String get cache_folder => 'Dossier du cache';

  @override
  String get export => 'Exporter';

  @override
  String get clear_cache => 'Effacer le cache';

  @override
  String get clear_cache_confirmation => 'Voulez-vous effacer le cache ?';

  @override
  String get export_cache_files => 'Exporter les fichiers en cache';

  @override
  String found_n_files(Object count) {
    return '$count fichiers trouvés';
  }

  @override
  String get export_cache_confirmation =>
      'Voulez-vous exporter ces fichiers vers';

  @override
  String exported_n_out_of_m_files(Object files, Object filesExported) {
    return '$filesExported fichiers exportés sur $files';
  }

  @override
  String get undo => 'Annuler';

  @override
  String get download_all => 'Télécharger tout';

  @override
  String get add_all_to_playlist => 'Ajouter tout à la playlist';

  @override
  String get add_all_to_queue => 'Ajouter tout à la file d\'attente';

  @override
  String get play_all_next => 'Lire tout suivant';

  @override
  String get pause => 'Pause';

  @override
  String get view_all => 'Voir tout';

  @override
  String get no_tracks_added_yet =>
      'Il semble que vous n\'avez encore ajouté aucun morceau.';

  @override
  String get no_tracks => 'Il semble qu\'il n\'y ait pas de morceaux ici.';

  @override
  String get no_tracks_listened_yet =>
      'Il semble que vous n\'avez encore rien écouté.';

  @override
  String get not_following_artists => 'Vous ne suivez aucun artiste.';

  @override
  String get no_favorite_albums_yet =>
      'Il semble que vous n\'ayez encore ajouté aucun album à vos favoris.';

  @override
  String get no_logs_found => 'Aucun log trouvé';

  @override
  String get youtube_engine => 'Moteur YouTube';

  @override
  String youtube_engine_not_installed_title(Object engine) {
    return '$engine n\'est pas installé';
  }

  @override
  String youtube_engine_not_installed_message(Object engine) {
    return '$engine n\'est pas installé sur votre système.';
  }

  @override
  String youtube_engine_set_path(Object engine) {
    return 'Assurez-vous qu\'il est disponible dans la variable PATH ou\nfixez le chemin absolu du fichier exécutable $engine ci-dessous.';
  }

  @override
  String get youtube_engine_unix_issue_message =>
      'Dans macOS/Linux/les systèmes d\'exploitation similaires à Unix, définir le chemin dans .zshrc/.bashrc/.bash_profile etc. ne fonctionnera pas.\nVous devez définir le chemin dans le fichier de configuration du shell.';

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
  String get download => 'Télécharger';

  @override
  String get file_not_found => 'Fichier non trouvé';

  @override
  String get custom => 'Personnalisé';

  @override
  String get add_custom_url => 'Ajouter une URL personnalisée';

  @override
  String get edit_port => 'Modifier le port';

  @override
  String get port_helper_msg =>
      'La valeur par défaut est -1, ce qui indique un nombre aléatoire. Si vous avez configuré un pare-feu, il est recommandé de le définir.';

  @override
  String connect_request(Object client) {
    return 'Autoriser $client à se connecter ?';
  }

  @override
  String get connection_request_denied =>
      'Connexion refusée. L\'utilisateur a refusé l\'accès.';

  @override
  String get an_error_occurred => 'Une erreur est survenue';

  @override
  String get copy_to_clipboard => 'Copier dans le presse-papiers';

  @override
  String get view_logs => 'Afficher les journaux';

  @override
  String get retry => 'Réessayer';

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
      'Vous n\'avez pas de fournisseur de métadonnées par défaut';

  @override
  String get manage_metadata_providers =>
      'Gérer les fournisseurs de métadonnées';

  @override
  String get open_link_in_browser => 'Ouvrir le lien dans le navigateur ?';

  @override
  String get do_you_want_to_open_the_following_link =>
      'Voulez-vous ouvrir le lien suivant';

  @override
  String get unsafe_url_warning =>
      'L\'ouverture de liens provenant de sources non fiables peut être dangereuse. Soyez prudent !\nVous pouvez également copier le lien dans votre presse-papiers.';

  @override
  String get copy_link => 'Copier le lien';

  @override
  String get building_your_timeline =>
      'Construction de votre chronologie en fonction de vos écoutes...';

  @override
  String get official => 'Officiel';

  @override
  String author_name(Object author) {
    return 'Auteur : $author';
  }

  @override
  String get third_party => 'Tiers';

  @override
  String get plugin_requires_authentication =>
      'Le plugin nécessite une authentification';

  @override
  String get update_available => 'Mise à jour disponible';

  @override
  String get supports_scrobbling => 'Supporte le scrobbling';

  @override
  String get plugin_scrobbling_info =>
      'Ce plugin scrobble votre musique pour générer votre historique d\'écoute.';

  @override
  String get default_metadata_source => 'Source de métadonnées par défaut';

  @override
  String get set_default_metadata_source =>
      'Définir la source de métadonnées par défaut';

  @override
  String get default_audio_source => 'Source audio par défaut';

  @override
  String get set_default_audio_source => 'Définir la source audio par défaut';

  @override
  String get set_default => 'Définir par défaut';

  @override
  String get support => 'Soutien';

  @override
  String get support_plugin_development =>
      'Soutenir le développement de plugins';

  @override
  String can_access_name_api(Object name) {
    return '- Peut accéder à l\'API **$name**';
  }

  @override
  String get do_you_want_to_install_this_plugin =>
      'Voulez-vous installer ce plugin ?';

  @override
  String get third_party_plugin_warning =>
      'Ce plugin provient d\'un dépôt tiers. Assurez-vous de faire confiance à la source avant de l\'installer.';

  @override
  String get author => 'Auteur';

  @override
  String get this_plugin_can_do_following => 'Ce plugin peut faire ce qui suit';

  @override
  String get install => 'Installer';

  @override
  String get no_tracks_playing =>
      'Aucune piste n\'est en cours de lecture actuellement';

  @override
  String get synced_lyrics_not_available =>
      'Les paroles synchronisées ne sont pas disponibles pour cette chanson. Veuillez utiliser l\'onglet';

  @override
  String get plain_lyrics => 'Paroles simples';

  @override
  String get tab_instead => 'à la place.';

  @override
  String get disclaimer => 'Avertissement';

  @override
  String get third_party_plugin_dmca_notice =>
      'L\'équipe de DeeMusiq n\'assume aucune responsabilité (y compris juridique) pour les plugins \"tiers\".\nVeuillez les utiliser à vos propres risques. Pour tout bug/problème, veuillez le signaler au dépôt du plugin.\n\nSi un plugin \"tiers\" enfreint les conditions d\'utilisation/DMCA d\'un service/entité juridique, veuillez demander à l\'auteur du plugin \"tiers\" ou à la plateforme d\'hébergement (par exemple GitHub/Codeberg) de prendre des mesures. Les plugins listés ci-dessus (étiquetés \"tiers\") sont tous des plugins publics/maintenus par la communauté. Nous ne les gérons pas, nous ne pouvons donc prendre aucune mesure à leur sujet.\n\n';

  @override
  String get plugins => 'Plugins';

  @override
  String get paste_plugin_download_url =>
      'Collez l\'URL de téléchargement ou l\'URL du dépôt GitHub/Codeberg ou un lien direct vers le fichier .smplug';

  @override
  String get download_and_install_plugin_from_url =>
      'Télécharger et installer le plugin à partir de l\'URL';

  @override
  String failed_to_add_plugin_error(Object error) {
    return 'Échec de l\'ajout du plugin : $error';
  }

  @override
  String get upload_plugin_from_file =>
      'Télécharger le plugin à partir d\'un fichier';

  @override
  String get installed => 'Installé';

  @override
  String get available_plugins => 'Plugins disponibles';

  @override
  String get configure_plugins =>
      'Configurez vos propres plugins de fournisseur de métadonnées et de source audio';

  @override
  String get audio_scrobblers => 'Scrobblers audio';

  @override
  String get scrobbling => 'Scrobbling';

  @override
  String get source => 'Source : ';

  @override
  String get uncompressed => 'Non compressé';

  @override
  String get dab_music_source_description =>
      'Pour les audiophiles. Fournit des flux audio de haute qualité/sans perte. Correspondance précise des pistes basée sur ISRC.';

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
  String get skip_this_nonsense => 'Passer cette absurdité';

  @override
  String get freedom_of_music => '“Liberté de la musique”';

  @override
  String get freedom_of_music_palm =>
      '“Liberté de la musique dans la paume de votre main”';

  @override
  String get get_started => 'Commençons';

  @override
  String get endless_playback_description =>
      'Ajouter automatiquement de nouvelles chansons à la fin de la file d\'attente';

  @override
  String get choose_your_region => 'Choisissez votre région';

  @override
  String get choose_your_region_description =>
      'Cela aidera DeeMusiq à vous montrer le bon contenu pour votre emplacement.';

  @override
  String get choose_your_language => 'Choisissez votre langue';

  @override
  String get help_project_grow => 'Aidez ce projet à grandir';

  @override
  String get help_project_grow_description =>
      'DeeMusiq est un projet open-source. Vous pouvez aider ce projet à grandir en contribuant au projet, en signalant des bugs ou en suggérant de nouvelles fonctionnalités.';

  @override
  String get visit_our_website => 'Visit our website';

  @override
  String get donate_on_open_collective => 'Faire un don sur Open Collective';

  @override
  String get install_a_metadata_provider =>
      'Installer un fournisseur de métadonnées';

  @override
  String get input_does_not_match_format =>
      'L\'entrée ne correspond pas au format requis';

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
  String get auth_mfa_required => 'Saisissez votre code d\'authentification';

  @override
  String get auth_mfa_body =>
      'Ouvrez votre application d\'authentification et saisissez le code à 6 chiffres pour terminer la connexion.';

  @override
  String get auth_mfa_verify_action => 'Vérifier';

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
