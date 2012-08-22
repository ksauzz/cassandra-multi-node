# Cassandra multi node setup script for single host.

_Tested cassandra 1.1.3 on OSX and Ubuntu 12.0x_

(cassandra 1.1.3 needs the patch. https://issues.apache.org/jira/browse/CASSANDRA-4494)

The script make nodes as follows:

    node 1: address=127.0.0.1, jmx port=7199
    node 2: address=127.0.0.2, jmx port=7200
    node 3: address=127.0.0.3, jmx port=7201

## Preparation (only OSX)
_Create interface aliases you need_

    sudo ifconfig lo0 alias 127.0.0.2 up
    sudo ifconfig lo0 alias 127.0.0.3 up

## Getting Started (make 3 nodes)

1. install cassandra. http://cassandra.apache.org/download/

2. clone this.

  <pre>
  $ git clone https://github.com/ksauzz/cassandra-multi-node.git
  $ cd cassandra-multi-node
  </pre>

3. create nodes.

  <pre>
  $ ./multi-node.sh create 3 cassandra_home
  </pre>

4. start cassandra multi-node.

  <pre>
  $ ./multi-node.sh start_all
  </pre>

5. show ring status.

  <pre>
  $ nodes/1/bin/nodetool ring
  Note: Ownership information does not include topology, please specify a keyspace. 
  Address         DC          Rack        Status State   Load            Owns                Token
                                                                                            60124436846790647144840725483529043142
  127.0.0.3       datacenter1 rack1       Up     Normal  6.74 KB         87.82%              39402250938272095434520910242661579171
  127.0.0.2       datacenter1 rack1       Up     Normal  13.52 KB        5.27%               48361166307902626090781384884410123881
  127.0.0.1       datacenter1 rack1       Up     Normal  6.74 KB         6.91%               60124436846790647144840725483529043142
  </pre>

## Usage

    usage
    -----
      ./multi-node.sh create node_count cassandra_home
      ./multi-node.sh start node_id
      ./multi-node.sh start_all
      ./multi-node.sh stop node_id
      ./multi-node.sh stop_all
      ./multi-node.sh clean

    example)
      ./multi-node.sh create 3 /usr/local/cassandra
      ./multi-node.sh stop 2
      ./multi-node.sh start 2

## Note

set heap size.

    MAX_HEAP_SIZE=512M HEAP_NEWSIZE=128M ./multi-node.sh start_all

## TODO

* avoid using sed.
