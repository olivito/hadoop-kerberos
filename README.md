# HDFS / Hive / Kerberos Example

This example creates a HDFS / Hive / Kerberos working setup using docker-compose.

## 1. Configure Docker networking

Hadoop requires reverse DNS.  Under docker-compose, we require an external network named "com" for hosts to resolve forward and backwards.

```bash
sudo docker network create com
```

## 2. Download a distro of Hadoop and Hive

If these links don't work, you may need to navigate to the root
directory in your browser and find a newer version.

Copy these files into the `hadoop-kerberos` directory:
```bash
wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.3/hadoop-2.7.3.tar.gz
wget https://apache.osuosl.org/hive/hive-2.3.9/apache-hive-2.3.9-bin.tar.gz
```

## 3. Start it up

```bash
sudo docker volume rm hadoopkerberos_server-keytab
sudo docker-compose up -d --force-recreate --build
```

It is important to remove the volume `hadoopkerberos_server-keytab`
each time you restart.
See the Shut Down instructions below.

## 4. Run HDFS commands to test

This confirms that the `hdfs` principal can run `ls`.

```bash
sudo docker exec -it nn.example /bin/bash
kinit -kt /var/keytabs/hdfs.keytab hdfs/nn.example.com
hdfs dfs -ls /
```

If `kinit` fails to get credentials, likely you have a stale volume
for `hadoopkerberos_server-keytab`.  See the Shut Down instructions above.

## 5. Run Hive commands

This creates a table `pokes` using an example file.

```bash
sudo docker exec -it hive.example /bin/bash
kinit hive/hive.example.com@EXAMPLE.COM -kt /var/keytabs/hive.keytab
/hive/bin/beeline -u "jdbc:hive2://hive.example.com:10000/default;principal=hive/hive.example.com@EXAMPLE.COM"
```

Then in beeline:
```
CREATE TABLE pokes (foo INT, bar STRING);
LOAD DATA LOCAL INPATH '/hive/examples/files/kv1.txt' OVERWRITE INTO TABLE pokes;
SELECT * FROM pokes LIMIT 5;
exit
```

## 6. Shut Down / Restart

To shut down:
```bash
chmod a+x teardown.sh
sudo ./teardown.sh
```

Or:
```bash
sudo docker-compose down
sudo docker volume rm hadoopkerberos_server-keytab
```

Otherwise old entries will be present in the keytab files and prevent authentication.
If you have run multiple times, you may need to also prune stale
Docker volumes:

```bash
sudo docker volume prune
```

To restart, use the commands in Step 3.


# To authenticate using kerberos from another host

Install kerberos user client.  On Ubuntu:
```bash
sudo apt-get install krb5-user
```

Add the host to `/etc/hosts`.  For example:
```
xx.yy.zz.qq kerberos.example.com hive.example.com
```

Verify that you can ping the host:
```bash
ping kerberos.example.com
```

Update the `/etc/krb5.conf` file:
```
[libdefaults]
 dns_lookup_realm = false
 ticket_lifetime = 24h
 # renew_lifetime = 7d
 forwardable = true
 rdns = false
 pkinit_anchors = FILE:/etc/pki/tls/certs/ca-bundle.crt
 default_realm = EXAMPLE.COM
 # default_ccache_name = KEYRING:persistent:%{uid}

[realms]
 EXAMPLE.COM = {
  kdc = kerberos.example.com
  admin_server = kerberos.example.com
 }

[domain_realm]
 .example.com = EXAMPLE.COM
 example.com = EXAMPLE.COM
```

Try to `kinit` as a user:
```
kinit enduser@EXAMPLE.COM
# enter password
klist
```

You can add users or adjust passwords in `start-kdc.sh`.

To create a keytab file for the user:
```
ktutil
# inside ktutil
ktutil:  addent -password -p enduser@EXAMPLE.COM -k 1 -e aes256-cts-hmac-sha1-96
Password for enduser@EXAMPLE.COM: 
ktutil:  addent -password -p enduser@EXAMPLE.COM -k 1 -e aes128-cts-hmac-sha1-96
Password for enduser@EXAMPLE.COM: 
ktutil:  wkt enduser.keytab
```
Depending on your OS, you may need to add additional encryption types (`-e` flag).
