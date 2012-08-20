#!/bin/bash

ROOT=$(cd `dirname $0`; pwd)

usage() {
  cat<<EOS
usage
-----
  $0 create node_count
  $0 clean
EOS
}

clean(){
  rm -rfv $ROOT/nodes
}

create_nodes(){
  node_cnt=$(expr $1)
  i=$node_cnt

  n=1
  while [ $n -le $node_cnt ]; do seeds="$seeds,127.0.0.$n";n=$(($n+1)); done
  seeds=$(echo $seeds|sed s/,//)

  while [ $i -gt 0 ]; do
    app_root=$ROOT/nodes/$i
    mkdir -p $app_root/conf
    mkdir -p $app_root/data
    mkdir -p $app_root/commitlog
    mkdir -p $app_root/saved_caches

    cat $ROOT/etc/cassandra.yaml | \
      sed "s|/var/lib/cassandra|${app_root}|" |\
      sed "s|: localhost|: 127.0.0.$i|" |\
      sed "s|- seeds: \"127.0.0.1\"|- seeds: \"$seeds\"|" \
      > $app_root/conf/cassandra.yaml

    i=$(($i-1))
  done
}

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

case $1 in
  create)
    create_nodes $2
    ;;
  clean)
    clean
    ;;
  *)
    usage
    ;;
esac
