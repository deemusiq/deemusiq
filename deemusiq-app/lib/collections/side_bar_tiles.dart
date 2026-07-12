import 'package:auto_route/auto_route.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/routes.gr.dart';
import 'package:deemusiq/collections/deemusiq_icons.dart';
import 'package:deemusiq/collections/assets.gen.dart';
import 'package:deemusiq/l10n/l10n.dart';
import 'package:deemusiq/models/metadata/metadata.dart';

class SideBarTiles {
  final IconData icon;
  final String title;
  final String id;
  final String pathPrefix;
  final PageRouteInfo route;

  SideBarTiles({
    required this.icon,
    required this.title,
    required this.id,
    required this.route,
    required this.pathPrefix,
  });
}

List<SideBarTiles> getSidebarTileList(AppLocalizations l10n) => [
      SideBarTiles(
        id: "home",
        pathPrefix: "/home",
        route: const HomeRoute(),
        icon: DeeMusiqIcons.home,
        title: l10n.browse,
      ),
      SideBarTiles(
        id: "catalog",
        pathPrefix: "/catalog",
        route: const CatalogRoute(),
        icon: DeeMusiqIcons.verified,
        title: "DeeMusiq",
      ),
      SideBarTiles(
        id: "search",
        pathPrefix: "/search",
        route: const SearchRoute(),
        icon: DeeMusiqIcons.search,
        title: l10n.search,
      ),
      SideBarTiles(
        id: "lyrics",
        pathPrefix: "/lyrics",
        route: const LyricsRoute(),
        icon: DeeMusiqIcons.music,
        title: l10n.lyrics,
      ),
      SideBarTiles(
        id: "stats",
        pathPrefix: "/stats",
        route: const StatsRoute(),
        icon: DeeMusiqIcons.chart,
        title: l10n.stats,
      ),
      SideBarTiles(
        id: "wallet",
        pathPrefix: "/wallet",
        route: const WalletRoute(),
        icon: DeeMusiqIcons.wallet,
        title: "Wallet",
      ),
      SideBarTiles(
        id: "artists-of-the-year",
        pathPrefix: "/wallet/artists-of-the-year",
        route: const ArtistLeaderboardRoute(),
        icon: DeeMusiqIcons.trophy,
        title: "Artists of the Year",
      ),
      SideBarTiles(
        id: "creator-studio",
        pathPrefix: "/creator-studio",
        route: const CreatorStudioRoute(),
        icon: DeeMusiqIcons.upload,
        title: "Creator Studio",
      ),
      SideBarTiles(
        id: "settings",
        pathPrefix: "/settings",
        route: const SettingsRoute(),
        icon: DeeMusiqIcons.settings,
        title: l10n.settings,
      ),
    ];

List<SideBarTiles> getSidebarLibraryTileList(AppLocalizations l10n) => [
      SideBarTiles(
        id: "favorites",
        pathPrefix: "/liked-tracks",
        title: l10n.liked_tracks,
        route: LikedPlaylistRoute(
          playlist: DeeMusiqSimplePlaylistObject(
            id: "user-liked-tracks",
            name: l10n.liked_tracks,
            description: l10n.liked_tracks_description,
            externalUri: "",
            owner: DeeMusiqUserObject(
              id: "",
              name: "DeeMusiq",
              externalUri: "",
            ),
            images: [
              DeeMusiqImageObject(
                url: Assets.images.likedTracks.path,
                width: 300,
                height: 300,
              ),
            ],
          ),
        ),
        icon: DeeMusiqIcons.heart,
      ),
      SideBarTiles(
        id: "playlists",
        pathPrefix: "/library/playlists",
        title: l10n.playlists,
        route: const UserPlaylistsRoute(),
        icon: DeeMusiqIcons.playlist,
      ),
      SideBarTiles(
        id: "artists",
        pathPrefix: "/library/artists",
        title: l10n.artists,
        route: const UserArtistsRoute(),
        icon: DeeMusiqIcons.artist,
      ),
      SideBarTiles(
        id: "albums",
        pathPrefix: "/library/albums",
        title: l10n.albums,
        route: const UserAlbumsRoute(),
        icon: DeeMusiqIcons.album,
      ),
      SideBarTiles(
        id: "local_library",
        pathPrefix: "/library/local",
        title: l10n.local_library,
        route: const UserLocalLibraryRoute(),
        icon: DeeMusiqIcons.device,
      ),
    ];

List<SideBarTiles> getNavbarTileList(AppLocalizations l10n) => [
      SideBarTiles(
        id: "home",
        pathPrefix: "/home",
        route: const HomeRoute(),
        icon: DeeMusiqIcons.home,
        title: l10n.browse,
      ),
      SideBarTiles(
        id: "search",
        pathPrefix: "/search",
        route: const SearchRoute(),
        icon: DeeMusiqIcons.search,
        title: l10n.search,
      ),
      SideBarTiles(
        id: "library",
        pathPrefix: "/library",
        route: const UserPlaylistsRoute(),
        icon: DeeMusiqIcons.library,
        title: l10n.library,
      ),
      SideBarTiles(
        id: "stats",
        pathPrefix: "/stats",
        route: const StatsRoute(),
        icon: DeeMusiqIcons.chart,
        title: l10n.stats,
      ),
    ];
