#!/bin/sh

set -e

RED='\033[0;31m'

GREEN='\033[0;32m'

BLUE='\033[0;34m'

NC='\033[0m'

mkdir -p log

echo -e "${GREEN}Checking for wine...${NC}"

if ! [ -x "$(command -v wine)" ]; then

  echo '${RED}Error: wine is not installed.${NC}' >&2

  echo 'Install wine and run this script again.' >&2

  exit 1

fi

if ! [ -x "$(command -v winetricks)" ]; then

  echo '${RED}Error: winetricks is not installed.${NC}' >&2

  echo 'Install winetricks and run this script again.' >&2

  exit 1

fi

function gr {

    if echo '' | grep -P '' 2&>1 >/dev/null; then

	grep -oP $1    else

	perl -nle "print \$& if m{$1}"

    fi

}

SS13DIR=$PWD/ss13

mkdir -p $SS13DIR

export WINEPREFIX=$SS13DIR

export WINEARCH=win32

export WINEDEBUG=-all

echo -e "${GREEN}Setting up wineprefix...${NC}"

wineboot 2>&1 >log/wine.log

echo -e "${BLUE}Done!${NC}"

echo -e "${GREEN}Setting up windows DLLs...${NC}"

winetricks -q wsh57 mfc42 vcrun2013 2>&1 >log/winetricks.log

echo -e "${BLUE}Done!${NC}"

echo -e "${GREEN}Setting up IE...${NC}"

winetricks -q ie8 2>&1 >>log/wine.log

echo -e "${BLUE}Done!${NC}"

echo -e "${GREEN}Setting up BYOND...${NC}"

DETECTED=0

if [ -f "$SS13DIR/.byondver" ]

then

    DETECTED=$(cat $SS13DIR/.byondver)

fi

#MAJOR=$(curl -s http://www.byond.com/download/build/ | gr 'href="\d+/"' | cut -c 7-9 | sort -r | head -n 1)

#MAJORURL=

FULLVER=512.1461_byond.zip

FULLURL=http://www.byond.com/download/build/512/512.1461_byond.zip

if [ ! -d "$SS13DIR/drive_c/Program Files/BYOND" ]

then

    echo -e "${BLUE}Did not detect any BYOND install, installing...${NC}"

    curl -L -O $FULLURL 2>&1 >log/wget.log

    mkdir -p ziptmp

    unzip -qq 512.1461_byond.zip -d ziptmp

    ls ziptmp

    mv ziptmp/byond $SS13DIR/drive_c/Program\ Files/BYOND

    rm ./512.1461_byond.zip

    rm -rf ziptmp

    echo "512.1461_byond.zip" > $SS13DIR/.byondver

    echo -e "${BLUE}Done!${NC}"

else

    echo -e "${BLUE}Detected BYOND install with version ${DETECTED}.${NC}"

    if [ "$DETECTED" \< "$FULLVER" -a "$DETECTED" != "$FULLVER" ]

    then

	echo -e "${BLUE}BYOND install is out of date, installing version ${FULLVER}.${NC}"

	rm -rf $SS13DIR/drive_c/Program\ Files/BYOND

	curl -L -O $FULLURL 2>&1 >log/wget.log

	mkdir -p ziptmp

	unzip -qq $FULLVER -d ziptmp

	ls ziptmp

	mv ziptmp/byond $SS13DIR/drive_c/Program\ Files/BYOND

	rm ./$FULLVER

	rm -rf ziptmp

	echo "$FULLVER" > $SS13DIR/.byondver

	echo -e "${BLUE}Done!${NC}"

    else

	echo -e "${BLUE}BYOND install is up-to-date.${NC}"

    fi

fi

echo -e "${GREEN}Setting up DirectX...${NC}"

if [ ! -d "$SS13DIR/drive_c/windows/system32/DirectX" ]

then

    curl -L -O https://download.microsoft.com/download/8/4/A/84A35BF1-DAFE-4AE8-82AF-AD2AE20B6B14/directx_Jun2010_redist.exe 2>&1 >>log/wget.log

    wine directx_Jun2010_redist.exe /c /q /t:C:\\dxtmp 2>&1 >log/dxsdk.log

    pushd $SS13DIR/drive_c/dxtmp

    wine DXSETUP.exe /silent

    popd

    rm -rf $SS13DIR/drive_c/dxtmp

    rm directx_Jun2010_redist.exe

    echo -e "${BLUE}Done!${NC}"

else

    echo -e "${BLUE}Detected existing DirectX install.${NC}"

fi

echo -e "${GREEN}Setting up Gecko...${NC}"

if [ ! -d "$SS13DIR/drive_c/windows/system32/gecko" ]

then

    curl -L -O https://dl.winehq.org/wine/wine-gecko/2.47/wine_gecko-2.47-x86-unstripped.tar.bz2 2>&1 >>log/wget.log

    mkdir -p $SS13DIR/drive_c/windows/system32/gecko/2.47/wine-gecko

    tar -vxjf wine_gecko-2.47-x86-unstripped.tar.bz2 -C $SS13DIR/drive_c/windows/system32/gecko/2.47/wine-gecko 2>&1 >/dev/null

    rm wine_gecko-2.47-x86-unstripped.tar.bz2

    echo -e "${BLUE}Done!${NC}"

else

    echo -e "${BLUE}Detected existing Gecko install.${NC}"

fi

echo -e "${GREEN}Setting up fonts...${NC}"

# curl http://pastebin.com/raw/Ziqx5ZrT > ./fontsmooth.reg 2>&1 >>log/wget.log

# regedit fontsmooth.reg 2>&1 >log/regedit.log

# winetricks -q allfonts 2>&1 >log/fonts.log

# winetricks -q settings fontsmooth=rgb 2>&1 >>log/regedit.log

# rm fontsmooth.reg

echo -e "${BLUE}Done!${NC}"

cat <<EOF > $SS13DIR/runss13.sh

#!/bin/sh

export WINEPREFIX=$PWD/ss13

export WINEARCH=win32

export WINEDEBUG=-all

wine $WINEPREFIX/drive_c/Program\ Files/BYOND/bin/byond.exe

EOF

chmod a+x $SS13DIR/runss13.sh

if ! [ -f $SS13DIR/icon.png ]

then

    curl -s http://files.byondhome.com/Zamura/2009-10/Zamura-0001/Byond.png > $SS13DIR/icon.png

fi

cat <<EOF > ~/.local/share/applications/byond.desktop

[Desktop Entry]

Type=Application

Version=1.0

Name=BYOND

Comment=A one-way ticket to space hell.

Path=$SS13DIR

Exec=$SS13DIR/runss13.sh

Icon=$SS13DIR/icon.png

Terminal=false

Categories=Games;

EOF

rm -rf ./log
