#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$HOSTNAME/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

# setting spark defaults
echo spark.yarn.jar hdfs:///spark/spark-assembly-1.5.2-hadoop2.6.0.jar > $SPARK_HOME/conf/spark-defaults.conf
cp $SPARK_HOME/conf/metrics.properties.template $SPARK_HOME/conf/metrics.properties

service ssh start
$HADOOP_PREFIX/sbin/start-dfs.sh
$HADOOP_PREFIX/sbin/start-yarn.sh


# add own IP to hosts with correct hostname
OWN_IP="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

cp /etc/hosts /etc/hosts.bkp
sed '1 i\'"$OWN_IP `hostname`"'' /etc/hosts.bkp > /etc/hosts.tmp
cp /etc/hosts.tmp /etc/hosts
rm /etc/hosts.tmp
cat /etc/hosts

# run master or worker scripts
    if [ "${RUN_MASTER}" == "1" ];
    then
        export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=${ZK_ENSAMBLE_IP}"
        if [ -z "${SPARK_MASTER_IP}" ];
        then
            export SPARK_MASTER_IP="$OWN_IP"
        fi
        echo "Running as master - ${SPARK_MASTER_IP}"
        /usr/local/spark/sbin/start-master.sh -i ${SPARK_MASTER_IP}
    fi
    if [ "${RUN_WORKER}" == "1" ];
    then
        echo "Running as worker - connecting to ${SPARK_MASTER_IP}"
        /usr/local/spark/sbin/start-slave.sh "${SPARK_MASTER_IP}"
    fi

trap "echo Exited!; exit;" SIGINT SIGTERM

CMD=${1:-"exit 0"}
if [[ "$CMD" == "-d" ]];
then
    service ssh stop
    /usr/sbin/sshd -D -d
else
    /bin/bash -c "$*"
    SPARK_PID=$(ps -ef | grep 'spark-' | grep -v grep | awk '{print $2}')
    if [ -n "$SPARK_PID" ];
    then
        echo Waiting for $SPARK_PID
        while [ -e "/proc/$SPARK_PID" ] && [ "$SPARK_PID" != "" ]
        do
            echo "$SPARK_PID still running"
            sleep 10
        done
            echo "$SPARK_PID finished running"
    fi
fi
