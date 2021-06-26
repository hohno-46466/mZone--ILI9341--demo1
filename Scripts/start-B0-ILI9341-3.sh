#! /bin/sh

# First version: Mon Sep 14 18:48:18 JST 2020
# Prev update: Sat Sep 19 12:26:55 JST 2020
# Last update: Mon Sep 21 07:11:51 JST 2020

# ----------------------------------------------------------

PNAME=$(basename $0)
EXTENSION=".sh"
PREFIX=$(echo $PNAME | sed -e "s/$EXTENSION//" -e 's/-[0-9]$//')
POSTFIX=$(echo $PNAME | sed -e "s/$EXTENSION//" -e 's/^.*-//')

echo "[$PNAME][$PREFIX][$POSTFIX](${PREFIX}-${POSTFIX}${EXTENSION})"

PROJECT_ID=B0
PROJECT_DIR=$HOME/workspace/Scripts/screenCTRL
PROJECT_FILE=${PROJECT_DIR}/Project.cfg

MQTT_TOPIC=hohno/ILI9341
DEF_TTYPORT=/dev/ttyACM-B0_ILI9341

# ----------------------------------------------------------

exit_with_code() {
  /bin/echo -n "$PNAME: exit with code $1"; [ "x$2" != "x" ] && /bin/echo -n " ($2)"; echo; exit $1
}

# ----------------------------------------------------------

usage() {
  /bin/echo "usage: $PNAME [TimeDiff [TTYPORT]]"
  exit 99
}

# ----------------------------------------------------------

[ "x$1" = "x-h" -o "x$1" = "x--help" ] && usage

TD=${1:-0}
# shift

TTYPORT=${TTYPORT:-$2}
TTYPORT=${TTYPORT:-$DEF_TTYPORT}
[ "x$TTYPORT" = "x" -o ! -e $TTYPORT ] && TTYPORT=$(grep $PROJECT_ID $PROJECT_FILE | awk '{print $3}')
[ "x$TTYPORT" = "x" -o ! -e $TTYPORT ] && exit 2

# echo "[$TTYPORT]"
ls -l $TTYPORT || exit 9 
ls -lL $TTYPORT || exit 8 

# ----------------------------------------------------------

if [ "x$PNAME" = "x${PREFIX}-1${EXTENSION}" ]; then
  # B0-1$
  set -x
  mosquitto_sub -t $MQTT_TOPIC | cu -s 57600 -l $TTYPORT | nkf -u -Lu | gawk '{if($1 == "!"){printf "T%s\n",systime()+$TD*3600}; fflush()}' | mosquitto_pub -l -t $MQTT_TOPIC
  set +x

elif [ "x$PNAME" = "x${PREFIX}-2${EXTENSION}" ]; then
  # B0-2$
  set -x
  (echo; echo "T$(($(date +%s) + ${TD}*3600))") | mosquitto_pub -l -t $MQTT_TOPIC
  set +x

elif [ "x$PNAME" = "x${PREFIX}-3${EXTENSION}" ]; then
  # B0-3$
  set -x
  mosquitto_sub -t $MQTT_TOPIC | awk -FT '{printf "export LC_ALL=C; echo %s - $(date --date @%s)\n",$0,$2;fflush()}' | sh
  set +x

else
  echo "${PNAME}: ???"
fi

# ----------------------------------------------------------

exit $?
