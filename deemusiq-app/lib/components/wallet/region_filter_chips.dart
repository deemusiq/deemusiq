import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:deemusiq/collections/markets.dart';
import 'package:deemusiq/extensions/context.dart';
import 'package:deemusiq/models/metadata/market.dart';
import 'package:deemusiq/provider/wallet/leaderboard_provider.dart';

/// Fixed regional boards offered on the leaderboard pages: South Africa plus
/// the neighbouring SADC markets the catalog serves.
const regionFilterMarkets = [
  Market.ZA,
  Market.BW,
  Market.ZW,
  Market.MZ,
];

String marketDisplayName(Market market) {
  for (final entry in marketsMap) {
    if (entry.$1 == market) return entry.$2;
  }
  return market.name;
}

/// Region filter chips for the leaderboards: Global / My region (hidden when
/// the user has no stored region) / fixed SADC markets. Selecting a chip
/// refetches the board with `?region=`; null means the global board.
class RegionFilterChips extends ConsumerWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const RegionFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myRegion = ref.watch(userRegionProvider).valueOrNull;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          style: selected == null
              ? ButtonVariance.primary
              : ButtonVariance.outline,
          onPressed: () => onChanged(null),
          child: Text(context.l10n.region_filter_global),
        ),
        if (myRegion != null && myRegion.isNotEmpty)
          Chip(
            style: selected == myRegion
                ? ButtonVariance.primary
                : ButtonVariance.outline,
            onPressed: () => onChanged(myRegion),
            child: Text(context.l10n.region_filter_my_region(myRegion)),
          ),
        for (final market in regionFilterMarkets)
          Chip(
            style: selected == market.name
                ? ButtonVariance.primary
                : ButtonVariance.outline,
            onPressed: () => onChanged(market.name),
            child: Text(marketDisplayName(market)),
          ),
      ],
    );
  }
}
