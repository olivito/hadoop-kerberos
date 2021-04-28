#! /bin/bash

## TEAR DOWN CONTAINERS
docker container rm dn1.example -f
docker container rm nn.example -f
docker container rm kerberos.example -f
docker container rm data-populator.example -f
docker container rm hive.example -f

## TEAR DOWN IMAGES
docker rmi hadoop-kerberos_dn1 --force
docker rmi hadoop-kerberos_nn --force
docker rmi hadoop-kerberos_kerberos --force
docker rmi hadoop-kerberos_data-populator --force
docker rmi hadoop-kerberos_hive --force

## TEAR DOWN VOLUME (THIS IS IMPORTANT FOR NEW KEYTABS)
docker volume rm hadoop-kerberos_server-keytab
