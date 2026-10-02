import 'package:deemusiq/models/wallet/linked_account.dart';
import 'package:deemusiq/models/wallet/pushed_song.dart';
import 'package:deemusiq/models/wallet/supported_creator.dart';
import 'package:deemusiq/models/wallet/token_transaction.dart';

/// The full, persisted state of a user's DeeMusiq wallet.
class WalletState {
  final List<TokenTransaction> transactions;
  final List<LinkedAccount> linkedAccounts;
  final List<SupportedCreator> supportedCreators;
  final List<PushedSong> pushedSongs;
  final int? authoritativeBalance;
  final String? syncError;

  /// Optional region override (ISO code). When null, pricing follows the app's
  /// recommendation market.
  final String? regionCode;

  const WalletState({
    this.transactions = const [],
    this.linkedAccounts = const [],
    this.supportedCreators = const [],
    this.pushedSongs = const [],
    this.authoritativeBalance,
    this.syncError,
    this.regionCode,
  });

  int get ledgerBalance => transactions.fold(0, (sum, tx) => sum + tx.tokens);

  int get balance => authoritativeBalance ?? ledgerBalance;

  int get totalSpent => transactions
      .where((tx) => tx.tokens < 0)
      .fold(0, (sum, tx) => sum - tx.tokens);

  int get totalPurchased => transactions
      .where((tx) => tx.tokens > 0)
      .fold(0, (sum, tx) => sum + tx.tokens);

  WalletState copyWith({
    List<TokenTransaction>? transactions,
    List<LinkedAccount>? linkedAccounts,
    List<SupportedCreator>? supportedCreators,
    List<PushedSong>? pushedSongs,
    int? authoritativeBalance,
    bool clearAuthoritativeBalance = false,
    String? syncError,
    bool clearSyncError = false,
    String? regionCode,
    bool clearRegion = false,
  }) {
    return WalletState(
      transactions: transactions ?? this.transactions,
      linkedAccounts: linkedAccounts ?? this.linkedAccounts,
      supportedCreators: supportedCreators ?? this.supportedCreators,
      pushedSongs: pushedSongs ?? this.pushedSongs,
      authoritativeBalance: clearAuthoritativeBalance
          ? null
          : (authoritativeBalance ?? this.authoritativeBalance),
      syncError: clearSyncError ? null : (syncError ?? this.syncError),
      regionCode: clearRegion ? null : (regionCode ?? this.regionCode),
    );
  }

  Map<String, dynamic> toJson() => {
        "transactions": transactions.map((e) => e.toJson()).toList(),
        "linkedAccounts": linkedAccounts.map((e) => e.toJson()).toList(),
        "supportedCreators": supportedCreators.map((e) => e.toJson()).toList(),
        "pushedSongs": pushedSongs.map((e) => e.toJson()).toList(),
        "authoritativeBalance": authoritativeBalance,
        "syncError": syncError,
        "regionCode": regionCode,
      };

  factory WalletState.fromJson(Map<String, dynamic> json) {
    List<T> parse<T>(String key, T Function(Map<String, dynamic>) fromJson) {
      final raw = json[key];
      if (raw is! List) return <T>[];
      return raw
          .whereType<Map>()
          .map((e) => fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return WalletState(
      transactions: parse("transactions", TokenTransaction.fromJson),
      linkedAccounts: parse("linkedAccounts", LinkedAccount.fromJson),
      supportedCreators: parse("supportedCreators", SupportedCreator.fromJson),
      pushedSongs: parse("pushedSongs", PushedSong.fromJson),
      authoritativeBalance: (json["authoritativeBalance"] as num?)?.toInt(),
      syncError: json["syncError"] as String?,
      regionCode: json["regionCode"] as String?,
    );
  }
}
