INNO_VERSION=6.2.0
TEMP_DIR=/tmp/deemusiq-tar
USR_SHARE=deb-struct/usr/share
BUNDLE_DIR=build/linux/${ARCH}/release/bundle
MIRRORLIST=${PWD}/build/mirrorlist

tar:
		mkdir -p $(TEMP_DIR)\
		&& cp -r $(BUNDLE_DIR)/* $(TEMP_DIR)\
		&& cp linux/deemusiq.desktop $(TEMP_DIR)\
		&& cp assets/branding/deemusiq-logo.png $(TEMP_DIR)\
		&& cp linux/com.deemusiq.deemusiq.appdata.xml $(TEMP_DIR)\
		&& tar -cJf build/deemusiq-linux-${VERSION}-${PKG_ARCH}.tar.xz -C $(TEMP_DIR) .\
		&& rm -rf $(TEMP_DIR)

aursrcinfo:
					 docker run -e EXPORT_SRC=1 -v ${PWD}/aur-struct:/pkg -v ${MIRRORLIST}:/etc/pacman.d/mirrorlist:ro whynothugo/makepkg

publishaur: 
					 echo '[Warning!]: you need SSH paired with AUR'\
					 && rm -rf build/deemusiq\
					 && git clone ssh://aur@aur.archlinux.org/deemusiq-bin.git build/deemusiq\
					 && cp aur-struct/PKGBUILD aur-struct/.SRCINFO build/deemusiq\
					 && cd build/deemusiq\
					 && git add .\
					 && git commit -m "${MSG}"\
					 && git push

innoinstall:
						powershell curl -o build\installer.exe http://files.jrsoftware.org/is/6/innosetup-${INNO_VERSION}.exe
						powershell git clone https://github.com/DomGries/InnoDependencyInstaller.git  build\inno-depend
		 				powershell build\installer.exe /verysilent /allusers /dir=build\iscc

inno:
		 powershell .\build\iscc\iscc.exe scripts\windows-setup-creator.iss

choco:
			powershell cp dist\DeeMusiq-windows-x86_64-setup.exe choco-struct\tools
			powershell choco pack .\choco-struct\deemusiq.nuspec  --outputdirectory dist

apk:
		mv build/app/outputs/apk/release/app-release.apk build/DeeMusiq-android-all-arch.apk

gensums:
				sh -c scripts/gensums.sh

migrate:
				dart run drift_dev make-migrations

dmg:
		flutter build macos &&\
		if [ -f dist/DeeMusiq-macos-universal.dmg ];\
		then rm dist/DeeMusiq-macos-universal.dmg;\
		fi &&\
		appdmg appdmg.json dist/DeeMusiq-macos-universal.dmg

changelog:
	git-cliff --unreleased