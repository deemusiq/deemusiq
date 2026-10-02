import 'dart:async';
import 'dart:io';

import 'package:io/io.dart';
import 'package:args/command_runner.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';

import '../../core/env.dart';
import 'common.dart';

class LinuxBuildCommand extends Command with BuildCommandCommonSteps {
  @override
  String get description => "Linux build command";

  @override
  String get name => "linux";

  @override
  FutureOr? run() async {
    stdout.writeln("Replacing versions");

    final appDataFile = File(
      join(cwd.path, "linux", "com.deemusiq.deemusiq.appdata.xml"),
    );

    appDataFile.writeAsStringSync(
      appDataFile.readAsStringSync().replaceAll(
            versionVarRegExp,
            '<release'
            ' version="$versionWithoutBuildNumber"'
            ' date="${DateFormat("yyyy-MM-dd").format(DateTime.now())}"'
            '/>',
          ),
    );

    await bootstrap();

    await shell.run(
      "fastforge package --platform=linux --targets=deb,appimage",
    );
    if (architecture == "x86") {
      await shell.run(
        "fastforge package --platform=linux --targets=rpm",
      );
    }

    final tempDir = join(Directory.systemTemp.path, "deemusiq-tar");
    final bundleArchName = architecture == "x86" ? "x86_64" : "aarch64";
    final bundleDirPath = join(
      cwd.path,
      "build",
      "linux",
      architecture == "x86" ? "x64" : architecture,
      "release",
      "bundle",
    );

    final tarFile = File(join(
      cwd.path,
      "dist",
      "deemusiq-linux-"
          "${CliEnv.channel == BuildChannel.nightly ? "nightly" : versionWithoutBuildNumber}"
          "-$bundleArchName.tar.xz",
    ));

    await copyPath(bundleDirPath, tempDir);
    await File(join(cwd.path, "linux", "deemusiq.desktop")).copy(
      join(tempDir, "deemusiq.desktop"),
    );
    await File(
      join(cwd.path, "linux", "com.deemusiq.deemusiq.appdata.xml"),
    ).copy(
      join(tempDir, "com.deemusiq.deemusiq.appdata.xml"),
    );
    await File(join(cwd.path, "assets", "branding", "deemusiq-logo.png")).copy(
      join(tempDir, "deemusiq-logo.png"),
    );

    await shell.run(
      "tar -cJf ${tarFile.path} -C $tempDir .",
    );

    final ogDeb = File(
      join(
        cwd.path,
        "dist",
        pubspec.version.toString(),
        "deemusiq-${pubspec.version}-linux.deb",
      ),
    );
    await ogDeb.copy(
      join(
        cwd.path,
        "dist",
        "DeeMusiq-linux-$bundleArchName.deb",
      ),
    );
    await ogDeb.delete();

    if (architecture == "x86") {
      final ogRpm = File(
        join(
          cwd.path,
          "dist",
          pubspec.version.toString(),
          "deemusiq-${pubspec.version}-linux.rpm",
        ),
      );

      await ogRpm.copy(
        join(cwd.path, "dist", "DeeMusiq-linux-$bundleArchName.rpm"),
      );

      await ogRpm.delete();
    }

    final ogAppImage = File(
      join(
        cwd.path,
        "dist",
        pubspec.version.toString(),
        "deemusiq-${pubspec.version}-linux.AppImage",
      ),
    );
    await ogAppImage.copy(
      join(
        cwd.path,
        "dist",
        "DeeMusiq-linux-$bundleArchName.AppImage",
      ),
    );
    await ogAppImage.delete();

    stdout.writeln("✅ Linux building done");
  }
}
