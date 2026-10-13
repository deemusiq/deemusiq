import 'dart:io';

import 'package:deemusiq/services/connectivity_adapter.dart';
import 'package:deemusiq/services/logger/logger.dart';

/// Checks internet connectivity by doing DNS lookups against well-known hosts.
/// Results are cached for [cacheDuration] to avoid spamming the network.
class ConnectionChecker {
  ConnectionChecker._();
  static final ConnectionChecker instance = ConnectionChecker._();

  static const _lookupHosts = ['google.com', 'cloudflare.com', 'github.com'];
  static const cacheDuration = Duration(seconds: 30);

  /// HTTPS probes used when DNS fails for every lookup host — VPN tunnels and
  /// filtered DNS break lookups while traffic still flows. Any completed HTTP
  /// response (any status) proves DNS + TCP + TLS all work end to end.
  static const _probeUrls = [
    'https://www.gstatic.com/generate_204',
    'https://www.baidu.com/', // reachable where Google is not
  ];
  static const _probeTimeout = Duration(seconds: 4);

  ConnectionStatus? _cached;
  DateTime? _cachedAt;

  /// Performs a full connectivity check. Cached for 30 seconds.
  Future<ConnectionStatus> check() async {
    if (_cached != null && _cachedAt != null &&
        DateTime.now().difference(_cachedAt!) < cacheDuration) {
      return _cached!;
    }

    final results = <String, bool>{};
    var totalLatency = 0;
    var successfulPings = 0;
    Object? lastLookupError;
    StackTrace? lastLookupStack;

    // Try to resolve each host with a short timeout.
    // If any resolves, we have internet.
    for (final host in _lookupHosts) {
      try {
        final sw = Stopwatch()..start();
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        sw.stop();
        if (result.isNotEmpty && result.any((a) => a.rawAddress.isNotEmpty)) {
          successfulPings++;
          totalLatency += sw.elapsedMilliseconds;
          results[host] = true;
        } else {
          results[host] = false;
        }
      } catch (e, stack) {
        AppLogger.log.d('ConnectionChecker: DNS lookup failed for $host: $e');
        lastLookupError = e;
        lastLookupStack = stack;
        results[host] = false;
      }
    }

    var hasInternet = results.values.any((v) => v);
    var viaFallback = false;
    if (!hasInternet) {
      // DNS-only verdicts produce false "offline" on VPNs and DNS-filtered
      // networks. Probe HTTPS, then treat an active VPN interface as
      // connected — same ladder as ConnectionCheckerService._isConnected.
      hasInternet = await _httpsProbe();
      if (!hasInternet) {
        hasInternet = await ConnectionCheckerService.instance.isVpnActive();
      }
      viaFallback = hasInternet;
    }
    if (!hasInternet && lastLookupError != null) {
      // A confirmed-offline verdict is the signal worth reporting; routine
      // lookup failures on a working connection (fallback succeeded) stay at
      // debug level above.
      AppLogger.reportError(
        lastLookupError,
        lastLookupStack ?? StackTrace.current,
        'ConnectionChecker: all lookups and probes failed — offline',
      );
    }
    final avgLatency = successfulPings > 0 ? totalLatency ~/ successfulPings : -1;

    _cached = ConnectionStatus(
      hasInternet: hasInternet,
      dnsResults: results,
      avgLatencyMs: avgLatency,
      checkedAt: DateTime.now(),
      viaFallback: viaFallback,
    );
    _cachedAt = DateTime.now();

    AppLogger.log.i(
      'ConnectionCheck: internet=$hasInternet latency=${avgLatency}ms '
      'via=${viaFallback ? 'fallback-probe' : 'dns'} '
      'results=${results.entries.where((e) => e.value).map((e) => e.key).join(',')}',
    );
    return _cached!;
  }

  Future<bool> _httpsProbe() async {
    for (final url in _probeUrls) {
      final client = HttpClient()..connectionTimeout = _probeTimeout;
      try {
        final request = await client.getUrl(Uri.parse(url)).timeout(_probeTimeout);
        final response = await request.close().timeout(_probeTimeout);
        await response.drain<void>();
        return true;
      } catch (e) {
        AppLogger.log.d('ConnectionChecker: HTTPS probe failed for $url: $e');
      } finally {
        client.close(force: true);
      }
    }
    return false;
  }

  /// Quick check — uses cache if available.
  Future<bool> get hasInternet async {
    final status = await check();
    return status.hasInternet;
  }

  /// Returns a user-friendly message based on connection state.
  String userMessage(ConnectionStatus status) {
    if (!status.hasInternet) return 'Sorry, no internet';
    if (status.avgLatencyMs > 1000) return 'Bad connection, retrying...';
    return 'Connected — playing...';
  }

  void clearCache() {
    _cached = null;
    _cachedAt = null;
  }
}

class ConnectionStatus {
  final bool hasInternet;
  final Map<String, bool> dnsResults;
  final int avgLatencyMs;
  final DateTime checkedAt;

  /// True when connectivity was established by the HTTPS/VPN fallback rather
  /// than DNS — useful for diagnosing "offline while online" reports.
  final bool viaFallback;

  const ConnectionStatus({
    required this.hasInternet,
    required this.dnsResults,
    required this.avgLatencyMs,
    required this.checkedAt,
    this.viaFallback = false,
  });
}
