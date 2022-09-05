#!/bin/bash 
# -eux
function confirm()
{
    echo -n "$@ "
    read -e answer
    for response in y Y yes YES Yes Sure sure SURE OK ok Ok
    do
        if [ "_$answer" == "_$response" ]
        then
            return 0
        fi
    done

    # Any answer other than the list above is considered a "no" answer
    return 1
}

function widevine_install {

_chrome_ver=$( web -version | grep -oP '(?<=Chromium )[^ ]*')

_l_target_dir=~/.local/lib/WidevineCdm
_target_dir=/opt/ungoogled-chromium/WidevineCdm
_sudo="sudo"

if [[ "${1}" == "-l" ]]; then
    _sudo=""
	_target_dir=$_l_target_dir
	shift
fi	

echo "install widevineCDM for chromium version $_chrome_ver"
echo "into $_target_dir"

confirm "confirm (y/n)" || exit

_temp=/tmp/chromium_widevine
echo using $_temp to download deb and extract widevine
mkdir -p $_temp || exit &> /dev/null
pushd $_temp &> /dev/null || exit

# Download deb, which has corresponding Widevine version
# Support resuming partially downloaded (or skipping re-download) with -c flag
if [[ "${1}" == "-u" ]]; then
    _un="un"
fi
_url=https://dl.google.com/linux/deb/pool/main/g/google-chrome-${_un}stable/google-chrome-${_un}stable_${_chrome_ver}-1_amd64.deb
echo downloading $_url

exit
wget -c $_url || exit

# Unpack deb
rm -r unpack_deb &> /dev/null || true
mkdir -p unpack_deb
echo extracting package...
dpkg-deb -R google-chrome-stable_${_chrome_ver}-1_amd64.deb unpack_deb || exit
echo removing any old WidevineCDM installs at $_target_dir
$_sudo rm -r $_target_dir &> /dev/null || true
echo moving WidevineCDM to target $_target_dir
$_sudo mv unpack_deb/opt/google/chrome/WidevineCdm $_target_dir &> /dev/null || exit
[[ $_sudo ]] && $_sudo chown -R root:root $_target_dir 
echo done, removing $_temp
rm -r $_temp &> /dev/null || true
popd &> /dev/null

}

# if script was executed then call the function
(return 0 2>/dev/null) || widevine_install $@

