// QuickJS-based YouTube challenge solver for youtube_explode_dart.
//
// ENABLING: add these to pubspec.yaml dependencies:
//   jsf: ^x.y.z
//
// Then uncomment the entire file and uncomment the QuickJSEJSSolver.init()
// call in youtube_explode_engine.dart:_isolateEntry().
//
// Without a working solver, youtube_explode_dart will fail on videos that
// serve JavaScript challenges (bot-detection pages).

/*
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/js_challenge.dart';
import 'package:youtube_explode_dart/src/reverse_engineering/challenges/ejs/ejs.dart';
import 'package:jsf/jsf.dart';

class QuickJSEJSSolver extends BaseJSChallengeSolver {
  final _playerCache = <String, String>{};
  final _sigCache = <(String, String, JSChallengeType), String>{};
  final QuickJSRuntime qjs;
  QuickJSEJSSolver._(this.qjs);

  static Future<QuickJSEJSSolver> init() async {
    final modules = await EJSBuilder.getJSModules();
    final deno = await QuickJSRuntime.init(modules);
    return QuickJSEJSSolver._(deno);
  }

  @override
  Future<String> solve(
      String playerUrl, JSChallengeType type, String challenge) async {
    final key = (playerUrl, challenge, type);
    if (_sigCache.containsKey(key)) {
      return _sigCache[key]!;
    }

    try {
      final result = await qjs.eval('''
        const challenge = ${jsonEncode(challenge)};
        const playerUrl = ${jsonEncode(playerUrl)};
        const type = ${jsonEncode(type.name)};
        // JS challenge solving logic
        "";
      ''');
      _sigCache[key] = result;
      return result;
    } catch (e) {
      debugPrint('QuickJSEJSSolver solve failed: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, String>> solveBulk(
      Map<String, (String, JSChallengeType)> challenges) async {
    final results = <String, String>{};
    for (final entry in challenges.entries) {
      final (url, type) = entry.value;
      results[entry.key] = await solve(url, type, entry.key);
    }
    return results;
  }

  Future<String> loadPlayerCode(String playerUrl) async {
    if (_playerCache.containsKey(playerUrl)) {
      return _playerCache[playerUrl]!;
    }
    final response = await http.get(Uri.parse(playerUrl));
    _playerCache[playerUrl] = response.body;
    return response.body;
  }

  @override
  Future<void> dispose() async {
    await qjs.close();
  }
}

class QuickJSRuntime {
  final JsRuntime _runtime;
  final StreamController<dynamic> _stdoutController =
      StreamController<dynamic>.broadcast();

  QuickJSRuntime(this._runtime) {
    _runtime.onUserOutput((String message) {
      debugPrint("[QuickJS Output] $message");
    });

    _runtime.onServerMessage((String message) {
      debugPrint("[QuickJS Server] $message");
    });
  }

  Future<String> eval(String code) async {
    debugPrint("[QuickJS Solver] Evaluate $code");
    final result = _runtime.eval(code);
    debugPrint("[QuickJS Solver] Evaluation Result $result");
    return result;
  }

  Future<void> close() async {
    _runtime.close();
    _stdoutController.close();
  }

  static Future<QuickJSRuntime> init(String initCode) async {
    debugPrint("[QuickJS Solver] Initializing");
    debugPrint("[QuickJS Solver] script $initCode");

    final runtime = JsRuntime();

    runtime.execInitScript(initCode);

    return QuickJSRuntime(runtime);
  }
}
*/
