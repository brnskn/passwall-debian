GIT=$(which git)
NPM=$(which npm)
GO=$(which go)
TMP_DIR=/tmp/passwall-build
SERVER_PATH=$TMP_DIR/passwall-server
DESKTOP_PATH=$TMP_DIR/passwall-desktop
DEBIAN_PATH=$TMP_DIR/passwall-debian
SERVER_BIN_PATH=$DEBIAN_PATH/usr/bin/passwall/server
DESKTOP_BIN_PATH=$DEBIAN_PATH/usr/bin/passwall/client
APPLICATION_PATH=$DEBIAN_PATH/usr/share/applications
ICON_PATH=$DEBIAN_PATH/usr/share/pixmaps

rm -rf $TMP_DIR

mkdir $TMP_DIR
mkdir $DEBIAN_PATH
mkdir -p $SERVER_BIN_PATH
mkdir -p $DESKTOP_BIN_PATH
mkdir -p $APPLICATION_PATH
mkdir -p $ICON_PATH

mkdir -p $DEBIAN_PATH/DEBIAN
cp -r ./debian/control $DEBIAN_PATH/DEBIAN/control
cp -r ./debian/postinst $DEBIAN_PATH/DEBIAN/postinst
cp ./debian/passwall.desktop $APPLICATION_PATH/passwall.desktop
cp ./debian/passwall.png $ICON_PATH/passwall.png

$GIT clone https://github.com/pass-wall/passwall-server $SERVER_PATH
$GIT clone https://github.com/pass-wall/passwall-desktop $DESKTOP_PATH

echo "Building passwall-server..."
cd $SERVER_PATH && CGO_ENABLED=1 GOOS=linux $GO build -a --ldflags="-s" -o passwall-server
cp $SERVER_PATH/passwall-server $SERVER_BIN_PATH/passwall-server
cp -r $SERVER_PATH/store $SERVER_BIN_PATH/store
echo "Building passwall-server completed successfully."

echo "Building passwall-desktop..."
cd $DESKTOP_PATH && $NPM install && $NPM run build:linux
echo "Version: $(cat $DESKTOP_PATH/build/PassWall-linux-x64/version | tr -cd [:digit:])" >> $DEBIAN_PATH/DEBIAN/control
cp -r $DESKTOP_PATH/build/PassWall-linux-x64/* $DESKTOP_BIN_PATH/
echo "Building passwall-desktop completed successfully."

echo "Building deb package..."
dpkg-deb --build $DEBIAN_PATH
echo "Building deb package completed successfully."

echo "You can install this deb package by running: sudo apt install $DEBIAN_PATH.deb"