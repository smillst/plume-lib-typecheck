#!/bin/bash
ROOT=$TRAVIS_BUILD_DIR/..

# Optional argument $1 is the group.
export GROUPARG=$1
# These are all the Java projects at https://github.com/plume-lib
if [[ "${GROUPARG}" == "bcel-util" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "bibtex-clean" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "html-pretty-print" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "icalavailable" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "lookup" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "multi-version-control" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "options" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "plume-util" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "require-javadoc" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "all" ]] || [[ "${GROUPARG}" == "" ]]; then echo "GROUPARG is all or empty"; PACKAGES=(bcel-util bibtex-clean html-pretty-print icalavailable lookup multi-version-control options plume-util require-javadoc); fi
if [ -z ${PACKAGES+x} ]; then
  echo "Bad group argument '${GROUPARG}'"
  exit 1
fi

# Fail the whole script if any command fails
set -e

## Build the Checker Framework
echo "CHECKERFRAMEWORK=$CHECKERFRAMEWORK"
export CHECKERFRAMEWORK=${CHECKERFRAMEWORK:-$ROOT/checker-framework}
if [ -d $CHECKERFRAMEWORK ] ; then
  git -C $CHECKERFRAMEWORK pull
else
  (cd $ROOT && git clone https://github.com/typetools/checker-framework.git) || (cd $ROOT && git clone https://github.com/typetools/checker-framework.git)
fi
# This also builds annotation-tools and jsr308-langtools
(cd $ROOT/checker-framework/ && ./.travis-build-without-test.sh downloadjdk)

echo "PACKAGES=$PACKAGES"
for PACKAGE in "${PACKAGES[@]}"; do
  echo "PACKAGE=$PACKAGE"
  (cd $ROOT && git clone https://github.com/plume-lib/${PACKAGE}.git) || (cd $ROOT && git clone https://github.com/plume-lib/${PACKAGE}.git)
  (cd $ROOT/${PACKAGE} && ./gradlew --console=plain -PcfLocal assemble)
done
