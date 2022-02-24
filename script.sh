#!/usr/bin/env sh

set -e

# Plugin input settings
FOLDER="${PLUGIN_FOLDER:-.}"
RELEASE="${PLUGIN_RELEASE}"
VERSION="${PLUGIN_VERSION}"
VERSION_PATH="${PLUGIN_VERSION_PATH:-.image.tag}"
ALLOW_MULTIPLE="${PLUGIN_ALLOW_MULTIPLE:-false}"

echo "🔆 Running helm-semver on release: ${RELEASE}"
echo "🏷️ Bumping ${VERSION_PATH} to ${VERSION}"

# Constants
RELEASE_VALUES_FILE=$(find ${FOLDER} -name "*${RELEASE}.yaml")
RELEASE_NEW_VALUES="/tmp/${RELEASE}.yaml"
RELEASE_DIFF_VALUES="${RELEASE_NEW_VALUES}.diff"
RELEASE_DEST_VALUES="/tmp/${RELEASE}.yaml.new"

# Input validation

if [ -z "${RELEASE_VALUES_FILE}" ]; then
  echo "|- ⁉️ Could not find value files matching \"${RELEASE}\" in \"${FOLDER}\", aborting"
  exit 1
fi
if [ $(echo "${RELEASE_VALUES_FILE}" | wc -l) -eq 1 ]; then
  echo "|- ✔️ Found value file matching \"${RELEASE}\" in \"${FOLDER}\": ${RELEASE_VALUES_FILE}"
else
  if [ "${ALLOW_MULTIPLE}" = "false" ]; then
    echo "|- ⁉️ Found multiple value files matching \"${RELEASE}\" in \"${FOLDER}\" and allow multiple is currently false, aborting"
    echo "${RELEASE_VALUES_FILE}"
    exit 2
  else
    echo "|- ✔️ Found  multiple files matching \"${RELEASE}\" in \"${FOLDER}\", will process them in a loop"
  fi
fi


print_version() {
  cat "${1}" | yq e "${VERSION_PATH}" -
}


for RELEASE_VALUES_FILE in "${FOLDER}"/**/*"${RELEASE}.yaml"; do
  # Step 1 - Generate new values file
  yq e "${VERSION_PATH} = \"${VERSION}\"" ${RELEASE_VALUES_FILE} > ${RELEASE_NEW_VALUES}

  # Step 2 - Diff new values with the old one to preserve original file
  diff -U0 -w -b --ignore-blank-lines ${RELEASE_VALUES_FILE} ${RELEASE_NEW_VALUES} | tee ${RELEASE_DIFF_VALUES} | colordiff || true

  # Step 3 - Apply the patch with new values
  echo "|- 📋 $(patch -o ${RELEASE_DEST_VALUES} ${RELEASE_VALUES_FILE} < ${RELEASE_DIFF_VALUES})"

  echo "|- 🎏 Version changed from $(print_version ${RELEASE_VALUES_FILE}) to $(print_version ${RELEASE_NEW_VALUES})"

  # Step 4 - Override the current values file with the newly generated file
  cp ${RELEASE_DEST_VALUES} ${RELEASE_VALUES_FILE}
done
