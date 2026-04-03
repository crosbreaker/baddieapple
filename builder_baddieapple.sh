#!/bin/bash
# Written by HarryJarry1
board=$1
recover=$2
zipped_link="https://github.com/crosbreaker/baddieapple/releases/download/minios/minios-$board.zip"
zipped_name="minios-$board.zip"
image1="minios-$board.bin"
: "${recover:=142}"
board=$(echo "$board" | tr '[:upper:]' '[:lower:]') # mw thingy needs lowercase board names
fail(){
	printf "$1\n"
	printf "error occurred\n"
	exit 1
}
if [[ $EUID -ne 0 ]]; then
       fail "Not running as root, please run with sudo"
     fi
if [ -z "$board" ]; then
    echo "Error: please enter a board"
	fail "example command:  sudo ./builder_baddieapple.sh <board> <OPTIONAL:version (default is 140 if unset)>"
fi
if [ "$recover" -gt 142 ]; then
    echo "You are attempting to make a baddieapple image on a unsupport recovery image. Please use a less modern version."
	echo "Current version is $recover"
	exit 1
fi
findimage(){ # Taken from murkmod
    echo "Attempting to find recovery image from https://github.com/MercuryWorkshop/chromeos-releases-data..."
    local mercury_data_url="https://cdn.jsdelivr.net/gh/MercuryWorkshop/chromeos-releases-data/data.json"
    local mercury_url=$(curl -ks "$mercury_data_url" | jq -r --arg board "$board" --arg version "$recover" '
      .[$board].images
      | map(select(
          .channel == "stable-channel" and
          (.chrome_version | type) == "string" and
          (.chrome_version | startswith($version + "."))
        ))
      | sort_by(.platform_version)
      | .[0].url
    ')

    if [ -n "$mercury_url" ] && [ "$mercury_url" != "null" ]; then
        echo "Found a match!"
        echo "$mercury_url"
		FINAL_URL="$mercury_url"
	else
    	echo "Failed to find the requested recovery image"
		if [ "$recover" = "142" ]; then
    		recover="141"
			echo "Trying to find a 141 image, this board doesn't have a 142 image."
			findimage
		else
			exit 1
		fi
	fi
}

main(){
	echo "Welcome to the automatic miniOS downloader for baddieapple."
 	findimage
	download_images
 	flash_to_image
	cleanup
}
trynominiosprebuilt(){
    rm "$zipped_name"
	echo
 	echo
  	echo "Failed to find an extracted miniOS archive.  Trying full recovery image..."
	./no_minios_prebuilt.sh "$board" "$recover"
	exit
}
download_images(){
	echo "Attempting to download old minios image..."
	wget -q "$zipped_link" > /dev/null >&1 || trynominiosprebuilt
	echo "Unzipping old miniOS..."
	unzip "$zipped_name" > /dev/null 2>&1 || fail "Failed to unzip."
	echo "Deleting (now uneeded) minios zip file..."
	rm "$zipped_name" > /dev/null 2>&1 || fail "Failed deleting zip file"
	echo "Downloading new recovery image"
	curl --progress-bar -k "$FINAL_URL" -o recovery.zip || fail "Failed to download recovery image"
	echo "Extracting new recovery image"
	unzip recovery.zip || fail "Failed to unzip recovery image"
	echo "Deleting new recovery image zip (unneeded now)"
	rm recovery.zip || fail "Failed to delete zipped recovery image"
	image2=$(find . -maxdepth 2 -name "chromeos_*.bin") # 2 incase the zip format changes
	echo "Found recovery image from archive at $image2"
}
# main baddieapple commands from original POC
flash_to_image(){
	echo "Mounting and editing $image2"
	LOOPDEV=$(losetup -f) || fail "could not find an available loop"
	losetup -P "$LOOPDEV" "$image2" > /dev/null 2>&1 || fail "Could not losetup second image, does it exist?"
	dd if="minios-$board-p9.bin" of="${LOOPDEV}p9" bs=4MiB > /dev/null 2>&1 || fail "Failed to swap p9" #NOTICE: There is no partiton table in these images
	dd if="minios-$board-p10.bin" of="${LOOPDEV}p10" bs=4MiB > /dev/null 2>&1 || fail "Failed to swap p10"
}
cleanup(){
	echo "Cleaning up..."
	losetup -d "$LOOPDEV" || fail "Failed to unmount dev1"
 	echo "File saved to $image2"
	rm "minios-$board-p9.bin"> /dev/null 2>&1 || fail "failed to delete miniOS bin"
	rm "minios-$board-p10.bin"> /dev/null 2>&1 || fail "failed to delete miniOS bin"
 }
check_deps() {
	for dep in "$@"; do
		command -v "$dep" &>/dev/null || echo "$dep"
	done
}
trydebianinstall() {
    #shimboot inspired
    if [ -f "/etc/debian_version" ]; then
    	echo "attempting to install build deps"
    	apt-get install jq wget unzip curl -y
    else
    	fail "not debian. install jq, wget, curl, and unzip."
    fi
}
missing_deps=$(check_deps jq wget unzip curl)
[ "$missing_deps" ] && trydebianinstall
main
echo "Success!  No errors detected."
