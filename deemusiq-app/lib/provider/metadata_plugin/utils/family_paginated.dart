import 'dart:math';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:deemusiq/models/metadata/metadata.dart';
import 'package:deemusiq/provider/metadata_plugin/utils/common.dart';
import 'package:deemusiq/services/logger/logger.dart';

abstract class FamilyPaginatedAsyncNotifier<K, A>
    extends FamilyAsyncNotifier<DeeMusiqPaginationResponseObject<K>, A>
    with MetadataPluginMixin<K> {
  Future<DeeMusiqPaginationResponseObject<K>> fetch(int offset, int limit);

  Future<void> fetchMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    // hasMore without a nextOffset would loop on the same page — stop instead.
    final nextOffset = current.nextOffset;
    if (nextOffset == null) return;

    try {
      state = AsyncLoadingNext(current);

      final newState = await fetch(nextOffset, current.limit);

      final items = newState.items.isEmpty ? <K>[] : newState.items.cast<K>();

      state = AsyncData(
        newState.copyWith(items: <K>[...current.items.cast<K>(), ...items]),
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncData(current);
    }
  }

  Future<List<K>> fetchAll() async {
    final initial = state.value;
    if (initial == null) return [];
    if (!initial.hasMore) return initial.items.cast<K>();

    var current = initial;

    bool hasMore = true;
    while (hasMore) {
      final nextOffset = current.nextOffset;
      if (nextOffset == null) break;
      final newState = await fetch(
        nextOffset,
        max(current.limit, 100),
      )
          .catchError(
            (e) => fetch(nextOffset, max(current.limit, 50)),
          )
          .catchError(
            (e) => fetch(nextOffset, current.limit),
          )
          .catchError(
        (e) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return fetch(nextOffset, current.limit);
        },
      );

      hasMore = newState.hasMore;

      final items = newState.items.isEmpty ? <K>[] : newState.items.cast<K>();

      current = newState.copyWith(
        items: [...current.items.cast<K>(), ...items],
      );
      state = AsyncData(current);
    }

    return current.items.cast<K>();
  }
}

abstract class AutoDisposeFamilyPaginatedAsyncNotifier<K, A>
    extends AutoDisposeFamilyAsyncNotifier<DeeMusiqPaginationResponseObject<K>,
        A> with MetadataPluginMixin<K> {
  Future<DeeMusiqPaginationResponseObject<K>> fetch(int offset, int limit);

  Future<void> fetchMore() async {
    final current = state.value;
    if (current == null || !current.hasMore) return;
    // hasMore without a nextOffset would loop on the same page — stop instead.
    final nextOffset = current.nextOffset;
    if (nextOffset == null) return;

    try {
      state = AsyncLoadingNext(current);

      final newState = await fetch(nextOffset, current.limit);

      state = AsyncData(
        newState.copyWith(items: [
          ...current.items.cast<K>(),
          ...newState.items.cast<K>(),
        ]),
      );
    } catch (e, stack) {
      AppLogger.reportError(e, stack);
      state = AsyncData(current);
    }
  }

  Future<List<K>> fetchAll() async {
    final initial = state.value;
    if (initial == null) return [];
    if (!initial.hasMore) return initial.items.cast<K>();

    var current = initial;

    bool hasMore = true;
    while (hasMore) {
      final nextOffset = current.nextOffset;
      if (nextOffset == null) break;
      final newState = await fetch(
        nextOffset,
        max(current.limit, 100),
      )
          .catchError(
            (e) => fetch(nextOffset, max(current.limit, 50)),
          )
          .catchError(
            (e) => fetch(nextOffset, current.limit),
          )
          .catchError(
        (e) async {
          await Future.delayed(const Duration(milliseconds: 500));
          return fetch(nextOffset, current.limit);
        },
      );

      hasMore = newState.hasMore;

      final items = newState.items.isEmpty ? <K>[] : newState.items.cast<K>();

      current = newState.copyWith(
        items: [...current.items.cast<K>(), ...items],
      );
      state = AsyncData(current);
    }

    return current.items.cast<K>();
  }
}
