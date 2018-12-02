#!/bin/bash

# Let's kill any running ones just in case
kill -9 $(pgrep -f getModemData.sh)

cd /root/ftapi

TABLEID=<YOUR_TABLEID>

while :; do
   MM=$(mmcli -m 0 --command="!GSTATUS?")

   RSSI_D=$(echo "${MM}" | grep "PCC RxD" | awk '{print $4}')
   RSRP_D=$(echo "${MM}" | grep "PCC RxD" | awk '{print $7}')
   RSSI_M=$(echo "${MM}" | grep "PCC RxM" | awk '{print $4}')
   RSRP_M=$(echo "${MM}" | grep "PCC RxM" | awk '{print $7}')
   BAND=$(echo "${MM}" | grep "LTE band" | awk '{print $3}' | cut -c 2-)
   RSRQ=$(echo "${MM}" | grep "RSRQ" | awk '{print $3}')
   SINR=$(echo "${MM}" | grep "SINR" | awk '{print $3}' | sed 's/.$//')
   DATE=$(date +%x' '%r)

./ftsql.sh "insert into ${TABLEID} ('BAND', 'RSSI-M', 'RSRP-M', 'RSSI-D', 'RSRP-D', 'SINR', 'RSRQ', 'DATE') \
	values($BAND, $RSSI_M, $RSRP_M, $RSSI_D, $RSRP_D, $SINR, $RSRQ, '${DATE}')"

sleep 5
done
