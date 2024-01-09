#!/bin/bash
#===============================================================================
#
#          FILE: controlCamera.sh
#
#         USAGE: ./controlCamera.sh
#
#   DESCRIPTION: This script will use curl to attempt to control an ONVIF camera
#
#  REQUIREMENTS: curl, xml2, Linux
#          BUGS: Probably
#        AUTHOR: Christopher Hubbard (CSH), chubbard@iwillfearnoevil.com
#  ORGANIZATION: Home
#       CREATED: 01/09/2024 11:07:52 AM
#      REVISION: Amanda
#===============================================================================

#set -o nounset                        # Treat unset variables as an error
#set -o pipefai                        # Any non-zero exits in pipes fail
#set -e                                # Any non-zero exit is a failure
#canonicalpath=$(readlink -f $0)                 # Breaks Mac due to readlink differences
#canonicaldirname=$(dirname ${canonicalpath}/..) # Breaks Mac
#samedirname=$(dirname ${canonicalpath})         # Breaks Mac

usage() {
cat << EOF
This script will attempt to control a generic ONVIF camera.  It is assumed the camera
is online, and you know your login information.

Values are set in the settings.cfg file
The script ATTEMPTS to find your profile for ONVIF, however if it is already known, add
it and skip that discovery attempt.

The horizontal and vertical values are default values of 0.1, however if the camera
does not respond to that small of a value, attempt 0.5 for each.

When in doubt, cat your response xml and pipe it through xml2 looking for clues
to what your camera was expecting

Options:
  usage | -h  show this help screen
  left        move left
  right       move right
  up          move up
  down        move down

Example:
$0 up

EOF
}

function verifyDeps() {
# Dont even bother running if we do not have the binaries that we need
needed="curl xml2 grep sed"
for i in ${needed} ; do
  type $i >/dev/null 2>&1
  if [[ $? -eq 1 ]]; then
    echo "FATAL - Missing manditory component: $i"
    exit1
  fi
done
}

function capabilitiesTemplate() {
DIR="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"> <s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"> <GetCapabilities xmlns=\"http://www.onvif.org/ver10/device/wsdl\"> <Category>All</Category> </GetCapabilities> </s:Body> </s:Envelope>"
}

function profileTemplate() {
DIR="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"> <s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"> <GetProfiles xmlns=\"http://www.onvif.org/ver10/media/wsdl\"/> </s:Body> </s:Envelope>"
}

function horoTemplate() {
DIR="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"><s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"><ContinuousMove xmlns=\"http://www.onvif.org/ver20/ptz/wsdl\"><ProfileToken>${CONTROL}</ProfileToken><Velocity><PanTilt xmlns=\"http://www.onvif.org/ver10/schema\" x=\"${DIRECTION}${HORO}\" y=\"0\"/></Velocity></ContinuousMove></s:Body></s:Envelope>"
}

function vertTempate() {
DIR="<s:Envelope xmlns:s=\"http://www.w3.org/2003/05/soap-envelope\"> <s:Body xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\"> <ContinuousMove xmlns=\"http://www.onvif.org/ver20/ptz/wsdl\"> <ProfileToken>${CONTROL}</ProfileToken> <Velocity> <PanTilt xmlns=\"http://www.onvif.org/ver10/schema\" x=\"0\" y=\"${DIRECTION}${VIRT}\"/></Velocity></ContinuousMove></s:Body></s:Envelope>"
}

function setHoro() {
  echo "Missing Left Right move parameters.  Setting defaults"
  echo "HORO='0.1'" >> ./settings.cfg
}

function setVirt() {
  echo "Missing Up Down move parameters.  Setting defaults"
  echo "VIRT='0.1'" >> ./settings.cfg
}

function findCapabilities() {
  capabilitiesTemplate
  curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/GetCapabilities"  --data "$(echo ${DIR})" > ./responses/findCapabilities.xml
}

function findProfile() {
  profileTemplate
  PROFILES=$(curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/GetProfiles"  --data "$(echo ${DIR})" > ./responses/getProfilesResponse.xml)
  CONTROL=$(cat ./responses/getProfilesResponse.xml | xml2 |  grep 'Profiles\/tt:Name=' | sed 's/.*.=//')
  echo -e "Found profiles adding the first one to your settings.cfg:\n${CONTROL}"
  CONT_SINGLE=$(echo -e "${CONTROL}" | head -1)
  echo -e "CONTROL=${CONT_SINGLE}" >> ./settings.cfg
}

function moveLeft() {
  DIRECTION='-'
  horoTemplate
  curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/ContinuousMove"  --data "$(echo ${DIR})" > ./responses/moveLeft.xml
}

function moveRight() {
  DIRECTION=''
  horoTemplate
  curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/ContinuousMove"  --data "$(echo ${DIR})" > ./responses/moveRight.xml
}

function moveUp() {
  DIRECTION=''
  vertTempate
  curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/ContinuousMove"  --data "$(echo ${DIR})" > ./responses/moveUp.xml
}

function moveDown() {
  DIRECTION='-'
  vertTempate
  curl -s -X POST "http://${HOST}:${PORT}/onvif/media_service" -u ${USER}:${PASS} -H "Content-Type: application/soap+xml; charset=utf-8" -H "SOAPAction: http://www.onvif.org/ver10/media/wsdl/ContinuousMove"  --data "$(echo ${DIR})" > ./responses/moveDown.xml
}


# Make sure we have our binaries before attempting work
verifyDeps

# Where we store our XML responses
if [[ ! -e ./responses ]]; then
  mkdir responses
fi

if [[  -e settings.cfg ]]; then
  . ./settings.cfg
  echo "Loaded existing config settings"
else
  echo "Cannot find settings file (./settings.cfg)"
  exit 1
fi

# Make sure our settings.cfg is complete
if [[ -z ${CONTROL} ]] ; then
  findProfile
else
  echo "Using Profile control ${CONTROL}"
fi

if [[ -z ${HORO} ]]; then
  setHoro

else
  echo "Left Right movement set at ${HORO} steps"
fi

if [[ -z ${VIRT} ]]; then
  setVirt
else
  echo "Up Down movement set at ${VIRT} steps"
fi

if [[ ! -e ./responses/findCapabilities.xml ]]; then
  findCapabilities
  echo "Grabbing the camera capabilities if possible"
fi

# Reinclude our settings with anything that we have set
. ./settings.cfg

case ${1} in
  usage|-h) usage; exit 0 ;;
  l*) moveLeft ;;
  r*) moveRight ;;
  u*) moveUp ;;
  d*) moveDown ;;
  *) echo "Missing valid command to do" ;;
esac

