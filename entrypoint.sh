#!/bin/bash

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

if [ "$SPARK_WORKLOAD" == "master" ]; then
  start-master.sh -p 7077
elif [ "$SPARK_WORKLOAD" == "worker" ]; then
  start-worker.sh spark://spark-master:7077
elif [ "$SPARK_WORKLOAD" == "history" ]; then
  start-history-server.sh
elif [ "$SPARK_WORKLOAD" == "notebook" ]; then
  # Start the Jupyter notebook server
  jupyter notebook --no-browser --ip="0.0.0.0" --port=8888 --allow-root
else
  echo "Unknown SPARK_WORKLOAD: $SPARK_WORKLOAD"
  echo "Valid values are 'master', 'worker', 'history', or 'notebook'."
  exit 1
fi
