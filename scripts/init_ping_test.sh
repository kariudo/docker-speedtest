#!/bin/sh
INTERVAL=${PING_DELAY:-30}
PING_FILE="/opt/speedtest/ping.log"
DATABASE="${INFLUXDB_DB:-speedtest}"

while true
do
        TIMESTAMP=$(date "+%s")
        echo "Running ping test ..."

        PING_RES=$(timeout 5 ping 1.1.1.1 -c 1 -4 | awk 'FS="=" { print $4 }' | awk '/ms/ { print $1}')
        EXIT_CODE=$?
        echo "Ping exited with $EXIT_CODE"
        if [ $EXIT_CODE -ne 0 ]; then
                echo "Ping failed."
                PING_RESP_CODE=$(curl --silent --show-error --write-out "%{http_code}" -XPOST "http://influxdb:8086/write?db=$DATABASE" --data-binary "ping,host=local value=0")
                echo "Ping failure send returned with $PING_RESP_CODE"
        else
                PING_RES=${PING_RES:-0}
                echo "Ping: $PING_RES"
                PING_RESP_CODE=$(curl --silent --show-error --write-out "%{http_code}" -XPOST "http://influxdb:8086/write?db=$DATABASE" --data-binary "ping,host=local value=$PING_RES")
                echo "Ping ($PING_RES ms) send returned with $PING_RESP_CODE"
        fi
        END_TIMESTAMP=$(date "+%s")
        DELTA=$(( INTERVAL - (END_TIMESTAMP - TIMESTAMP) ))
        echo "Sleep $INTERVAL before next run. $DELTA s remaining"
        sleep $DELTA
done
