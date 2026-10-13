import type { IconType } from "react-icons";
import {
  FaAndroid,
  FaApple,
  FaDebian,
  FaUbuntu,
  FaWindows,
  FaLinux,
} from "react-icons/fa6";
import { LuHouse, LuNewspaper, LuDownload, LuBook } from "react-icons/lu";

export const routes: Record<string, [string, IconType | null]> = {
  "/": ["Home", LuHouse],
  "/blog": ["Blog", LuNewspaper],
  "/docs": ["Docs", LuBook],
  "/downloads": ["Downloads", LuDownload],
  "/about": ["About", null],
};

const releasesUrl =
  "https://github.com/deemusiq/deemusiq/releases/latest/download";

export const downloadLinks: Record<string, [string, IconType[]]> = {
  "Android Apk": [`${releasesUrl}/DeeMusiq.apk`, [FaAndroid]],
  "Windows Executable": [
    `${releasesUrl}/DeeMusiq-windows-x86_64-setup.exe`,
    [FaWindows],
  ],
  "macOS Dmg": [`${releasesUrl}/DeeMusiq-macos-universal.dmg`, [FaApple]],
  "Ubuntu, Debian": [
    `${releasesUrl}/DeeMusiq-linux-amd64.deb`,
    [FaUbuntu, FaDebian],
  ],
};

export const extendedDownloadLinks: Record<
  string,
  [string, IconType[], string]
> = {
  Android: [`${releasesUrl}/DeeMusiq.apk`, [FaAndroid], "apk"],
  Windows: [
    `${releasesUrl}/DeeMusiq-windows-x86_64-setup.exe`,
    [FaWindows],
    "exe",
  ],
  macOS: [`${releasesUrl}/DeeMusiq-macos-universal.dmg`, [FaApple], "dmg"],
  "Ubuntu, Debian (x64)": [
    `${releasesUrl}/DeeMusiq-linux-amd64.deb`,
    [FaUbuntu, FaDebian],
    "deb",
  ],
  "Linux AppImage (x64)": [
    `${releasesUrl}/DeeMusiq-linux-x86_64.AppImage`,
    [FaLinux],
    "AppImage",
  ],
};

// Ad slots — replace with DeeMusiq's own AdSense/ad-network IDs when
// monetisation partners are onboarded. Currently inactive placeholders.
export const ADS_SLOTS = Object.freeze({
  rootPageDisplay: 0,
  blogPageInFeed: 0,
  downloadPageDisplay: 0,
  packagePageArticle: 0,
  blogArticlePageArticle: 0,
});
