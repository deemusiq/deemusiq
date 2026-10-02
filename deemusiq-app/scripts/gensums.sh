#!/bin/env bash
md5sum build/**/*.{AppImage,deb,tar.xz,dmg,exe,nupkg,apk} >build/RELEASE.md5sum
sha256sum build/**/*.{AppImage,deb,tar.xz,dmg,exe,nupkg,apk} >build/RELEASE.sha256sum