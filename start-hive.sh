#! /bin/bash



until kinit -kt /var/keytabs/hive.keytab hive/hive.example.com; do sleep 2; done

until (echo > /dev/tcp/nn.example.com/9000) >/dev/null 2>&1; do sleep 2; done

sleep 60;

export HADOOP_HOME=/hadoop
export HADOOP_PREFIX=/hadoop
export HIVE_HOME=/hive
export PATH=$HIVE_HOME/bin:$PATH

cd /hive/bin
schematool -dbType derby -initSchema
#./hiveserver2 --hiveconf hive.server2.enable.doAs=false
./hiveserver2
