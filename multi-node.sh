#!/bin/bash

ROOT=$(cd `dirname $0`; pwd)
DEFAULT_JMX_PORT=7199

usage() {
  cat<<EOS
usage
-----
  $0 create node_count cassandra_home
  $0 start node_id
  $0 start_all
  $0 stop node_id
  $0 stop_all
  $0 clean

example)
  $0 create 3 /usr/local/cassandra
  $0 stop 2
  $0 start 2
EOS
}

clean(){
  for node in `ls -1 $ROOT/nodes`;do
    echo "rm $ROOT/nodes/$node"
    rm -rf $ROOT/nodes/$node
  done
  rmdir $ROOT/nodes
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
    echo "making $app_root"
    mkdir -p $app_root
    cp -r $cassandra_home/* $app_root/
    mkdir -p $app_root/data
    mkdir -p $app_root/commitlog
    mkdir -p $app_root/saved_caches
    mkdir -p $app_root/logs

    echo "modifying $app_root/conf/cassandra.yaml"
    cat $cassandra_home/conf/cassandra.yaml | \
      sed "s|/var/lib/cassandra|${app_root}|" |\
      sed "s|: localhost|: 127.0.0.$i|" |\
      sed "s|- seeds: \"127.0.0.1\"|- seeds: \"$seeds\"|" \
      > $app_root/conf/cassandra.yaml

    echo "modifying $app_root/conf/log4j-server.properties"
    cat $cassandra_home/conf/log4j-server.properties |\
      sed "s|/var/log/cassandra|$app_root/logs|" \
      > $app_root/conf/log4j-server.properties

    echo "modifying $app_root/conf/cassandra-env.sh"
    cat $cassandra_home/conf/cassandra-env.sh | \
      sed "s/JMX_PORT=\"7199\"/JMX_PORT=\"$(($DEFAULT_JMX_PORT+($i-1)))\"/" \
      > $app_root/conf/cassandra-env.sh

    i=$(($i+1))
  done
}

start_all(){
  for node in `ls -1 $ROOT/nodes`;do
    start $node
  done
}

start(){
  node=$1
  echo "starting node$node"
  $ROOT/nodes/$node/bin/cassandra -p $ROOT/nodes/$node/cassandra.pid
}

stop_all(){
  for node in `ls -1 $ROOT/nodes`;do
    stop $node
  done
}

stop(){
  node=$1
  echo "killing node$node"
  kill $(cat $ROOT/nodes/$node/cassandra.pid)
}

required_args(){
  actual=$1
  required=$2
  if [[ $actual -lt $required ]]; then
    usage
    exit 1
  fi
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case $1 in
  create)
    required_args $# 3
    create_nodes $2 $3
    ;;
  clean)
    clean
    ;;
  start_all)
    start_all
    ;;
  start)
    required_args $# 2
    start $2
    ;;
  stop_all)
    stop_all
    ;;
  stop)
    required_args $# 2
    stop $2
    ;;
  *)
    usage
    ;;
esac
