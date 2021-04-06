#!/bin/bash

# Let's kill any running ones just in case
kill -9 $(pgrep -f getModemData.sh)


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

	
sendStr = \
$(jq -n \
--arg band "$BAND" \
--arg rssi_m "$RSSI_M" \
--arg rsrp_m "$RSRP_M" \
--arg rssi_d "$RSSI_D" \
--arg rsrp_d "$RSRP_D" \
--arg sinr "$SINR" \
--arg rsrq "$RSRQ" \
'{band: $band, \
rssi_m: $rssi_m,\
rsrp_m: $rsrp_m, \
rssi_d: $rssi_d, \
rsrp_d: $rsrp_d, \
sinr: sinr, \
rsrq: $rsrq
}')

mosquitto_pub -t 'modem/signal' -m '$sendStr'

sleep 5
done
