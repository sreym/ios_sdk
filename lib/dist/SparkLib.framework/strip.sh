#!/bin/sh

#  build_sdk.sh
#  spark_sdk
#
#  Created by volodymyr on 22/02/2018.
#  Copyright © 2018 Hola. All rights reserved.

if [ "${CONFIGURATION}" != "Release" ]; then
    echo "Expecting to strip architectures only for Release configuration"
    exit 0
fi

if [ -z "${BUILT_PRODUCTS_DIR}" ] || [ -z "${FRAMEWORKS_FOLDER_PATH}" ] || [ -z "${CONFIGURATION}" ]; then
    echo "XCode environment missing, are you building from CLI?"
    echo "Use 'xcodebuild -scheme SparkLib build' instead.";
    exit 1
fi

set -ex

LIBNAME="SparkLib"
BUILD_PATH="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}"
FRAMEWORK="${BUILD_PATH}/${LIBNAME}.framework/${LIBNAME}"

if [ "$ACTION" = "install" ]; then
  find . -name '*.bcsymbolmap' -type f -exec mv {} "${CONFIGURATION_BUILD_DIR}" \;
else
  find . -name '*.bcsymbolmap' -type f -exec rm -rf "{}" +\;
fi

archs="$(lipo -info "${FRAMEWORK}" | rev | cut -d ':' -f1 | rev)"
stripped="0"
for arch in $archs; do
  if ! [[ "${VALID_ARCHS}" == *"$arch"* ]]; then
    lipo -remove "$arch" -output "$FRAMEWORK" "$FRAMEWORK" || exit 1
    stripped="1"
  fi
done
if [[ "$stripped" == "1" ]]; then
  if [ "${CODE_SIGNING_REQUIRED}" == "YES" ]; then
    /usr/bin/codesign --force --sign ${EXPANDED_CODE_SIGN_IDENTITY} --preserve-metadata=identifier,entitlements "$FRAMEWORK"
  fi
fi
