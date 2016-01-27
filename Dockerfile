FROM ubuntu:trusty
MAINTAINER jan.sourek@performio.cz

RUN apt-get update; apt-get install -y unzip openjdk-7-jre-headless wget curl
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.5.2-bin-hadoop2.6 spark
ENV SPARK_HOME /usr/local/spark

ENV PATH $PATH:$SPARK_HOME/bin

RUN apt-get update; apt-get install -y python-pip python-dev libmysqlclient-dev; pip install MySQL-python

# update boot script
COPY bootstrap.sh /etc/bootstrap.sh

ENTRYPOINT ["/etc/bootstrap.sh"]
