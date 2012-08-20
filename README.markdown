# Cassandra multi node setup script for single node.

_Tested cassandra 1.1.3 on OSX only._ with the patch (https://issues.apache.org/jira/browse/CASSANDRA-4494)

The script make nodes as follows:

    node 1: address=127.0.0.1, jmx port=7199
    node 2: address=127.0.0.2, jmx port=7200
    node 3: address=127.0.0.3, jmx port=7201

_Create interface aliases you need_

    sudo ifconfig lo0 alias 127.0.0.2 up
    sudo ifconfig lo0 alias 127.0.0.3 up

## Usage

    usage
    -----
      ./multi-node.sh create node_count cassandra_home
      ./multi-node.sh start
      ./multi-node.sh stop
      ./multi-node.sh clean

## Instruction (make 3 nodes)

1. install cassandra. http://cassandra.apache.org/download/

2. clone this.

    git clone https://github.com/ksauzz/cassandra-multi-node.git
    cd cassandra-multi-node

3. create nodes.

    ./multi-node.sh create 3 cassandra\_home

4. start cassandra multi-node.

    ./multi-node.sh run

## TODO

* optimize JVM memory.
