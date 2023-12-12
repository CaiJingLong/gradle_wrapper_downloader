#/bin/sh

os_type=$(uname -s)

OS=""
REPO_URL="https://github.com/CaiJingLong/gradle_wrapper_downloader"

OUTPUT_FILE="gradle_wrapper_downloader.tar.gz"
EXE_NAME="gw_dl.exe"

# if TARGET_NAME is empty
if [ -z "$TARGET_NAME" ]; then
  TARGET_NAME="gradle_wrapper"
fi

if [ "$os_type" == "Linux" ]; then
  OS="ubuntu"
  echo "Current OS is linux"
elif [ "$os_type" == "Darwin" ]; then
  OS="macos"
  echo "Current OS is macos"
else
  echo "Not support OS: $os_type"
  exit 1
fi

YAML_FILE="$REPO_URL/blob/main/pubspec.yaml?raw=true"

VERSION_TEXT=$(curl -s -L "https://mirror.ghproxy.com/$YAML_FILE")

# echo "Downloading version info from $VERSION"

V=$(echo "$VERSION_TEXT" | grep -e "version:.*" | sed -e "s/version: //g")
V="v$V"

RELEASE_URL="$REPO_URL/releases/download/$V/${OS}_$V.tar.gz"

echo "Downloading $RELEASE_URL"

curl -L "https://mirror.ghproxy.com/$RELEASE_URL" -o "$OUTPUT_FILE"
tar -zxvf "$OUTPUT_FILE"

rm -rf "$OUTPUT_FILE"

chmod +x $EXE_NAME

echo "Download success, you can use ./$EXE_NAME to use it."

echo "Or"

echo "You can move $EXE_NAME to /usr/local/bin to use it globally."
echo "Use 'mv $EXE_NAME /usr/local/bin/$TARGET_NAME' to move it."

# read input to move it to /usr/local/bin
read -p "Do you want to move it to /usr/local/bin? (y/n)" input

if [ "$input" == "y" ]; then
  mv $EXE_NAME /usr/local/bin/$TARGET_NAME
  echo "Moved to /usr/local/bin/$TARGET_NAME"
fi
