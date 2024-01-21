

#!/bin/bash
# stop
docker container stop fe4106fea535
echo "EMQX Broker stopped at $(date +%s)" >> broker_stop_log.txt

sleep 3

#restart after 10sec
echo "EMQX Broker started at $(date +%s)" >> broker_start_log.txt

docker container start fe4106fea535
