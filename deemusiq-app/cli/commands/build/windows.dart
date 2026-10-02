import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'common.dart';

class WindowsBuildCommand extends Command with BuildCommandCommonSteps {
  @override
  String get description => "Build Windows exe";

  @override
  String get name => "windows";

  /// Locates makensis on PATH (`where` on Windows, `which` elsewhere).
  String? findMakensis() {
    final result = Process.runSync(
      Platform.isWindows ? "where" : "which",
      ["makensis"],
    );
    if (result.exitCode != 0) return null;
    return (result.stdout as String).trim().split("\n").first;
  }

  @override
  void run() async {
    stdout.writeln("Replace versions");

    final chocoFiles = [
      join(cwd.path, "choco-struct", "tools", "VERIFICATION.txt"),
      join(cwd.path, "choco-struct", "deemusiq.nuspec"),
    ];

    for (final filePath in chocoFiles) {
      final file = File(filePath);
      final content = file.readAsStringSync();
      final newContent =
          content.replaceAll(versionVarRegExp, versionWithoutBuildNumber);

      file.writeAsStringSync(newContent);
    }

    await bootstrap();

    final runnerRCFile = File(
      join(cwd.path, "windows", "runner", "Runner.rc"),
    );

    runnerRCFile.writeAsStringSync(
      runnerRCFile
          .readAsStringSync()
          .replaceAll("%{{SPOTUBE_VERSION}}%", versionWithoutBuildNumber)
          .replaceAll(
            "%{{SPOTUBE_VERSION_AS_NUMBER}}%",
            [
              pubspec.version!.major,
              pubspec.version!.minor,
              pubspec.version!.patch,
              0
            ].join(","),
          ),
    );

    await shell.run("flutter build windows --release");

    // NSIS is the single Windows installer path. The checked-in script takes
    // version, build dir and output file as -D defines, exactly like the
    // Makefile `windows-installer` target (see packaging/windows/installer.nsi).
    final makensis = findMakensis();
    if (makensis == null) {
      throw Exception(
        "makensis not found on PATH. Install NSIS (`choco install nsis`) "
        "or add its install directory to PATH, then retry.",
      );
    }

    final buildDir = join(
      cwd.path,
      "build",
      "windows",
      "x64",
      "runner",
      "Release",
    );
    await Directory(join(cwd.path, "dist")).create(recursive: true);
    final exePath = join(cwd.path, "dist", "DeeMusiq-windows-x86_64-setup.exe");

    await shell.run(
      '"$makensis" '
      '-DVERSION="$versionWithoutBuildNumber" '
      '-DBUILD_DIR="$buildDir" '
      '-DOUT_FILE="$exePath" '
      '"${join(cwd.path, "packaging", "windows", "installer.nsi")}"',
    );

    stdout.writeln("✅ Windows exe built at $exePath");

    final exeFile = File(exePath);

    final hash = sha256.convert(await exeFile.readAsBytes()).toString();

    final chocoVerificationFile = File(chocoFiles.first);

    chocoVerificationFile.writeAsStringSync(
      chocoVerificationFile.readAsStringSync().replaceAll(
            RegExp(r"\%\{\{WIN_SHA256\}\}\%"),
            hash,
          ),
    );

    await exeFile.copy(
      join(cwd.path, "choco-struct", "tools", basename(exeFile.path)),
    );

    await shell.run(
      "choco pack ${chocoFiles[1]}  --outputdirectory ${join(cwd.path, "dist")}",
    );

    final chocoNupkg = File(
      join(cwd.path, "dist", "deemusiq.$versionWithoutBuildNumber.nupkg"),
    );

    final distNupkgPath = join(
      cwd.path,
      "dist",
      "DeeMusiq-windows-x86_64.nupkg",
    );

    await chocoNupkg.copy(distNupkgPath);
    await chocoNupkg.delete();

    stdout.writeln("✅ Windows nupkg built at $distNupkgPath");
  }
}
