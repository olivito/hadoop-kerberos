FROM centos:7

RUN yum -y install krb5-server krb5-workstation
RUN yum -y install java-1.8.0-openjdk-headless
RUN yum -y install apache-commons-daemon-jsvc
RUN yum install net-tools -y
RUN yum install telnet telnet-server -y
RUN yum -y install which

RUN sed -i -e 's/#//' -e 's/default_ccache_name/# default_ccache_name/' -e 's/renew_lifetime/# renew_lifetime/' /etc/krb5.conf

RUN useradd -u 1098 hdfs
RUN useradd -u 1099 hive

ADD hadoop-2.7.3.tar.gz /
ADD apache-hive-2.3.8-bin.tar.gz /
RUN ln -s hadoop-2.7.3 hadoop
RUN ln -s apache-hive-2.3.8-bin hive
RUN chown -R -L hdfs /hadoop
RUN chown -R -L hive /hive


COPY core-site.xml /hadoop/etc/hadoop/
COPY hdfs-site.xml /hadoop/etc/hadoop/
COPY ssl-server.xml /hadoop/etc/hadoop/
COPY yarn-site.xml /hadoop/etc/hadoop/

COPY hive-site.xml /hive/conf/
COPY hive-env.sh /hive/conf/

COPY start-namenode.sh /
COPY start-datanode.sh /
COPY populate-data.sh /
COPY start-kdc.sh /
COPY start-hive.sh /

COPY people.json /
COPY people.txt /

ENV JAVA_HOME=/usr/lib/jvm/jre-1.8.0-openjdk
ENV PATH=/hadoop/bin:/hive/bin:$PATH
ENV HADOOP_CONF_DIR=/hadoop/etc/hadoop
# added for hive
ENV HADOOP_HOME=/hadoop
ENV HADOOP_PREFIX=/hadoop
ENV HIVE_HOME=/hive
