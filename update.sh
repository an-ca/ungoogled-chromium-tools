#!/bin/bash

clean ()
{
    echo "Cleaning..."
    [[ -f "${WORKING_DIR}/${PACKAGE_FILENAME}" ]] \
        && rm "${WORKING_DIR}/${PACKAGE_FILENAME}"

    [[ -f "${WORKING_DIR}/${CHECK_FILE}" ]] \
        && rm "${WORKING_DIR}/${CHECK_FILE}"
}

die() { echo "$*" 1>&2 ; clean ; exit 1; }

WORKING_DIR=/tmp
DESTINATION_DIR=/opt
CHECK_FILE=sum

while getopts d:P:S: option
do
    case "${option}" in
        d) DESTINATION_DIR="${OPTARG}" ;;
        P) PACKAGE_LOCATION="${OPTARG}" ;;
        S) CHECKSUM="${OPTARG}" ;;
    esac
done

LINK="${DESTINATION_DIR}/ungoogled-chromium"

[[ -z "${PACKAGE_LOCATION}" ]] && read -p "Package location ? " PACKAGE_LOCATION
[[ -z "${CHECKSUM}" ]] && read -p "Package SHA256 checksum ? " CHECKSUM

PACKAGE_FILENAME="$(basename "${PACKAGE_LOCATION}")"
PACKAGE_NAME="${PACKAGE_FILENAME%%.tar.xz}"
MAJOR_DIGIT="$(echo "${PACKAGE_NAME}" | cut -d. -f1 | cut -d_ -f2)"

echo "Downloading..."

wget -cq  -P "${WORKING_DIR}" "${PACKAGE_LOCATION}" \
    || die "Error downloading"

echo "${CHECKSUM}  ${WORKING_DIR}/${PACKAGE_FILENAME}" > "${WORKING_DIR}/${CHECK_FILE}"

echo "Verifying package..."

sha256sum --status -c "${WORKING_DIR}/${CHECK_FILE}" \
    || die "Checksum verification failed"

echo "Extracting package..."

sudo tar -C "${DESTINATION_DIR}" -xf "${WORKING_DIR}/${PACKAGE_FILENAME}" \
    || die "Extraction failed"

clean

echo "Updating link..."

sudo ln -snfv "${DESTINATION_DIR}/${PACKAGE_NAME}" "${LINK}" \
    || die "Link update failed"

WIDEVINE_DIR="$(find "${DESTINATION_DIR}" -maxdepth 2 -mindepth 2 \
    -type d -wholename \
    "*ungoogled-chromium_${MAJOR_DIGIT}*/WidevineCdm" -print -quit)"

if [[ -d "${WIDEVINE_DIR}" ]];
then
    echo "Found Widevine for same major version, copying..."
    sudo cp -al "${WIDEVINE_DIR}" "${DESTINATION_DIR}/${PACKAGE_NAME}" \
        || die "Copying failed"
else
    echo "No Widevine found for same major version."
    read -r -p "Install Widevine? [y/N] " response
    response=${response,,}    # tolower
    [[ "$response" =~ ^(yes|y)$ ]] && widevine.sh
fi
