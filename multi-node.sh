#!/bin/bash

ROOT=$(cd `dirname $0`; pwd)

usage() {
  cat<<EOS
usage
-----
  $0 create node_count cassandra_home
  $0 start
  $0 stop
  $0 clean
EOS
}

clean(){
  for node in `ls -1 $ROOT/nodes`;do
    echo "rm $node"
    rm -rfv $node
  done
}

create_nodes(){
  node_cnt=$(expr $1)

  cassandra_home=$2

  n=1
  while [ $n -le $node_cnt ]; do seeds="$seeds,127.0.0.$n";n=$(($n+1)); done
  seeds=$(echo $seeds|sed s/,//)

  i=1
  while [ $i -le $node_cnt ]; do

    app_root=$ROOT/nodes/$i
    mkdir -pv $app_root
    cp -r $cassandra_home/* $app_root/
    mkdir -pv $app_root/data
    mkdir -pv $app_root/commitlog
    mkdir -pv $app_root/saved_caches
    mkdir -pv $app_root/logs

    cat $cassandra_home/conf/cassandra.yaml | \
      sed "s|/var/lib/cassandra|${app_root}|" |\
      sed "s|: localhost|: 127.0.0.$i|" |\
      sed "s|- seeds: \"127.0.0.1\"|- seeds: \"$seeds\"|" \
      > $app_root/conf/cassandra.yaml

    cat $cassandra_home/conf/log4j-server.properties |\
      sed "s|/var/log/cassandra|$app_root/logs|" \
      > $app_root/conf/log4j-server.properties

    cat $cassandra_home/conf/cassandra-env.sh | \
      sed "s/JMX_PORT=\"7199\"/JMX_PORT=\"$((7199+($i-1)))\"/" \
      > $app_root/conf/cassandra-env.sh

    i=$(($i+1))
  done
}

run(){
  for node in `ls -1 $ROOT/nodes`;do
    $ROOT/nodes/$node/bin/cassandra -p $ROOT/nodes/$node/cassandra.pid
  done
}

stop(){
  for node in `ls -1 $ROOT/nodes`;do
    kill $(cat $ROOT/nodes/$node/cassandra.pid)
  done
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case $1 in
  create)
    if [[ $# -lt 3 ]]; then
      usage
      exit 1
    fi
    create_nodes $2 $3
    ;;
  clean)
    clean
    ;;
  start|run)
    run
    ;;
  stop)
    stop
    ;;
  *)
    usage
    ;;
esac
