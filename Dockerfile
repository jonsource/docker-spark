FROM sequenceiq/hadoop-ubuntu:2.6.0
MAINTAINER jan.sourek@performio.cz

#support for Hadoop 2.6.0
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.5.2-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark
RUN mkdir $SPARK_HOME/yarn-remote-client
ADD yarn-remote-client $SPARK_HOME/yarn-remote-client

RUN $BOOTSTRAP && $HADOOP_PREFIX/bin/hadoop dfsadmin -safemode leave && $HADOOP_PREFIX/bin/hdfs dfs -put $SPARK_HOME-1.5.2-bin-hadoop2.6/lib /spark

ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$SPARK_HOME/bin:$HADOOP_PREFIX/bin

RUN apt-get update; apt-get install -y python-pip python-dev libmysqlclient-dev; pip install MySQL-python

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh

ENTRYPOINT ["/etc/bootstrap.sh"]
