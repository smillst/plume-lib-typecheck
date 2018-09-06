#!/bin/bash

echo "Entering plume-lib-typecheck/.travis-build.sh"
pwd

# Optional argument $1 is the group.
GROUPARG=$1
echo "GROUPARG=$GROUPARG"
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
if [[ "${GROUPARG}" == "signature-util" ]]; then PACKAGES=(${GROUPARG}); fi
if [[ "${GROUPARG}" == "all" ]] || [[ "${GROUPARG}" == "" ]]; then echo "GROUPARG is all or empty"; PACKAGES=(bcel-util bibtex-clean html-pretty-print icalavailable lookup multi-version-control options plume-util require-javadoc); fi
if [ -z ${PACKAGES+x} ]; then
  echo "Bad group argument '${GROUPARG}'"
  exit 1
fi
echo "PACKAGES=$PACKAGES"

# Fail the whole script if any command fails
set -e

## Build the Checker Framework
echo "initial CHECKERFRAMEWORK=$CHECKERFRAMEWORK"
export CHECKERFRAMEWORK=${CHECKERFRAMEWORK:-../checker-framework}
echo "CHECKERFRAMEWORK=$CHECKERFRAMEWORK"
if [ -d $CHECKERFRAMEWORK ] ; then
  # Fails if not currently on a branch
  git -C $CHECKERFRAMEWORK pull || true
else
  JSR308=`readlink -m $CHECKERFRAMEWORK/..`
  (cd $JSR308 && git clone https://github.com/typetools/checker-framework.git) || (cd $JSR308 && git clone https://github.com/typetools/checker-framework.git)
fi
# This also builds annotation-tools and jsr308-langtools
(cd $CHECKERFRAMEWORK && ./.travis-build-without-test.sh downloadjdk)
echo "CHECKERFRAMEWORK=$CHECKERFRAMEWORK"
ls -al $CHECKERFRAMEWORK

echo "PACKAGES=$PACKAGES"
for PACKAGE in "${PACKAGES[@]}"; do
  echo "PACKAGE=$PACKAGE"
  (cd .. && git clone https://github.com/plume-lib/${PACKAGE}.git) || (cd .. && git clone https://github.com/plume-lib/${PACKAGE}.git)
  echo "About to call ./gradlew --console=plain -PcfLocal assemble"
  (cd ../${PACKAGE} && CHECKERFRAMEWORK=$CHECKERFRAMEWORK ./gradlew --console=plain -PcfLocal assemble)
done

echo "Exiting plume-lib-typecheck/.travis-build.sh"
