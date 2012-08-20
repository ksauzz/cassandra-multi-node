#!/bin/bash

ROOT=$(cd `dirname $0`; pwd)

usage() {
  cat<<EOS
usage
-----
  $0 create node_count cassandra_home
  $0 clean
EOS
}

clean(){
  rm -rf $ROOT/nodes
}

create_nodes(){
  node_cnt=$(expr $1)

  cassandra_home=$2

  n=1
  while [ $n -le $node_cnt ]; do seeds="$seeds,127.0.0.$n";n=$(($n+1)); done
  seeds=$(echo $seeds|sed s/,//)

  i=$node_cnt
  while [ $i -gt 0 ]; do
    app_root=$ROOT/nodes/$i
    mkdir -pv $app_root
    cp -r $cassandra_home/* $app_root/
    mkdir -pv $app_root/data
    mkdir -pv $app_root/commitlog
    mkdir -pv $app_root/saved_caches

    cat $cassandra_home/conf/cassandra.yaml | \
      sed "s|/var/lib/cassandra|${app_root}|" |\
      sed "s|: localhost|: 127.0.0.$i|" |\
      sed "s|- seeds: \"127.0.0.1\"|- seeds: \"$seeds\"|" \
      > $app_root/conf/cassandra.yaml

    i=$(($i-1))
  done
}

run(){
  for node in `ls -1 $ROOT/nodes`;do
    $ROOT/nodes/$node/bin/cassandra
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
  run)
    run
    ;;
  *)
    usage
    ;;
esac
