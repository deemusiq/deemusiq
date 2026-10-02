#!/usr/bin/env bash

# DeeMusiq Linux installer — installs the portable tarball released by the
# Makefile `tar` target (build/deemusiq-linux-<ver>-x86_64.tar.xz) system-wide.

# Variables
fname="$(basename "$0")"
installDir='/usr/share/deemusiq'
desktopFile='/usr/share/applications/deemusiq.desktop'
appdataDir='/usr/share/appdata'
appdata="${appdataDir}/com.deemusiq.deemusiq.appdata.xml"
iconDir='/usr/share/icons/deemusiq'
icon="${iconDir}/deemusiq-logo.png"
symlink='/usr/bin/deemusiq'
temp='/tmp/deemusiq-installer'
latestVer="$(wget -qO- "https://api.github.com/repos/deemusiq/deemusiq/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/^v//')"

# Root check - From CAAIS (https://codeberg.org/RaptaG/CAAIS), under GPL-3.0
function rootCheck() {
     if [ "${EUID}" -ne 0 ]; then
          echo "Error: Root permissions are required for ${fname} to work."
          echo "Please run './${fname}' for more information."
          exit 1
     fi
}

# Flags
function help(){
  echo "Usage: sudo ./${fname} [flags]"
  echo 'Flags:'
  echo '  -i, --install <version>    Install any DeeMusiq version (if not specified, the latest is installed).'
  echo '  -h, --help                 This help menu'
  echo '  -r, --remove               Removes DeeMusiq from your system'
  exit 0
}

# Checks whether a given command exists or not and returns bool
function command_exists() {
    command -v "$@" >/dev/null 2>&1
}

function install_deps(){
    local debianDeps='mpv libappindicator3-1 gir1.2-appindicator3-0.1 libsecret-1-0 libnotify-bin libjsoncpp25'
    local rpmDeps='mpv libappindicator jsoncpp libsecret libnotify'
    local archDeps='mpv libappindicator-gtk3 libsecret jsoncpp libnotify'

    if command_exists apt; then
        apt install -y ${debianDeps}
    elif command_exists dnf; then
        dnf install -y ${rpmDeps}
    elif command_exists yum; then
        yum install -y ${rpmDeps}
    elif command_exists zypper; then
        zypper install -y ${rpmDeps}
    elif command_exists pacman; then
        pacman -Sy ${archDeps}
    else
        echo 'You have to install some dependencies manually in order for DeeMusiq to work.'
        echo "The deps are the following: ${rpmDeps}"
    fi
}

function download_extract_deemusiq(){
  local tarPath="/tmp/deemusiq-${ver}.tar.xz"
  local downloadURL="https://github.com/deemusiq/deemusiq/releases/download/v${ver}/deemusiq-linux-${ver}-x86_64.tar.xz"

  if [ "${ver}" = "nightly" ]; then
      downloadURL="https://github.com/deemusiq/deemusiq/releases/download/nightly/deemusiq-linux-nightly-x86_64.tar.xz"
  fi

  rm -rf ${temp}
  mkdir -p ${temp}

  # Check if already exists downloaded file
  if [ -f "${tarPath}" ]; then
    echo "Installation file detected. Skipping download..."
  else
    echo "Downloading deemusiq-${ver}.tar.xz..."
    wget -q "${downloadURL}" -O "${tarPath}"
  fi

  tar -xf "${tarPath}" -C ${temp}

  # Is $temp empty or not
  if [ ! "$(ls -A ${temp})" ]; then
    echo 'Failed to extract the tarball. Redownloading...'
    rm -f "${tarPath}"
    wget -q "${downloadURL}" -O "${tarPath}"
    tar -xf "${tarPath}" -C ${temp}
  fi

  # Once again
  if [ ! "$(ls -A ${temp})" ]; then
    echo 'Failed to extract the tarball. Installation aborted.'
    exit 1
  fi
}

function install_deemusiq(){
    if [ -d ${installDir} ]; then
        echo -n "DeeMusiq is already installed. Do you want to reinstall it? [y/N] "
        read reinstall

        case "${reinstall}" in
        [yY]*)
            uninstall_deemusiq ;;
        *)
            echo 'Aborting installation...'
            exit 1 ;;
        esac
    fi

    # Install DeeMusiq from temp dir
    mkdir -p ${installDir}
    mv ${temp}/data ${installDir}
    mv ${temp}/lib ${installDir}
    mv ${temp}/deemusiq ${installDir}
    mv ${temp}/deemusiq.desktop ${desktopFile}
    mkdir -p ${appdataDir}
    mv ${temp}/com.deemusiq.deemusiq.appdata.xml ${appdata}
    mkdir -p ${iconDir}
    mv ${temp}/deemusiq-logo.png ${icon}
    ln -sf ${installDir}/deemusiq ${symlink}

    rm -rf ${temp}  # Remove temp dir
    echo "DeeMusiq ${ver} has been installed successfully!"
}

function uninstall_deemusiq(){
    echo -n "Are you sure you want to uninstall DeeMusiq? [y/N] "
    read confirm

    case "${confirm}" in
    [yY]*)
            echo 'Uninstalling DeeMusiq...'
            rm -rf ${installDir} ${desktopFile} ${appdata} ${iconDir} ${symlink} ;;
    *)
            echo 'Aborting...'
            exit 0 ;;
    esac
}

case "$1" in
-i | --install)
    if [ "$2" != "" ]; then
        ver="$2"
    else
        ver="${latestVer}"
    fi

    rootCheck
    install_deps
    download_extract_deemusiq
    install_deemusiq
    exit 0 ;;
-r | --remove)
    rootCheck
    uninstall_deemusiq
    exit 0 ;;
-h | --help | "")
    help
    exit 0 ;;
*)
    echo "Invalid flag '$1'"
    echo "Please run ./${fname} for more information."
    exit 1 ;;
esac
