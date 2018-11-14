#!/bin/bash

set -e

mkdir my-cluster
cd  my-cluster
ceph-deploy new node1 node2 node3
echo public network = 192.168.77.0/24 >> ceph.conf
ceph-deploy install node1 node2 node3
ceph-deploy mon create-initial
ceph-deploy admin node1 node2 node3
#ceph-deploy mds create node1
#ssh node1 sudo ceph osd pool create cephfs_data 3
#ceph osd pool create cephfs_metadata 3

ceph-deploy osd create  node1:/dev/sdc node2:/dev/sdc node3:/dev/sdc

ssh node1 sudo ceph osd pool create kube 100 100




ssh node1 sudo  ./create_docker.sh

exit 0
