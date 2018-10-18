#!/bin/bash
USER=kube

#sudo ceph osd pool create kube 100 100
ceph auth get-or-create client.kube mon 'allow r' osd 'allow rwx pool=kube'
ceph auth get-key client.admin > /etc/ceph/client.admin
ceph auth get-key client.kube > /etc/ceph/ceph.client.kube.keyring

kubeadm init --apiserver-advertise-address=192.168.77.10 --pod-network-cidr=10.244.0.0/16 | tee  /tmp/for_connect


#useradd -s /bin/bash -m kube
mkdir ~kube/.kube
cp /etc/kubernetes/admin.conf ~kube/.kube/config
chown kube: ~kube/.kube/config

su - kube -c "kubectl taint nodes --all node-role.kubernetes.io/master-"
su - kube -c "kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default"

su - kube -c "kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml"
# cheack
su - kube -c "kubectl -n kube-system get pods"

sleep 2

#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
su - kube -c "kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml"
su - kube -c "kubectl -n kube-system create -f ~/account.yaml"
su - kube -c "kubectl proxy &"

su - kube -c "kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') | tee /tmp/token"

#rbl create
chmod 777 /var/run/docker.sock
docker build -t "my-kube-controller-manager:v1.12.1" /home/kube/

docker images | grep my-kube-controller-manager
docker run my-kube-controller-manager:v1.12.1 whereis rbd
#/etc/kubernetes/manifests/kube-controller-manager.yaml
sed -e "s/k8s.gcr.io\/kube-controller-manager:v1.12.1/my-kube-controller-manager:v1.12.1/g" /etc/kubernetes/manifests/kube-controller-manager.yaml -i

su - kube -c "kubectl -n kube-system describe pods | grep kube-controller"
su - kube -c 'kubectl create secret generic ceph-secret --type="kubernetes.io/rbd" --from-file=/etc/ceph/client.admin --namespace=kube-system'
su - kube -c 'kubectl create secret generic ceph-secret-kube --type="kubernetes.io/rbd" --from-file=/etc/ceph/ceph.client.kube.keyring  --namespace=default'
su - kube -c "kubectl create -f ceph_storage.yaml"
su - kube -c "kubectl get storageclass"
su - kube -c "kubectl create -f test_pod.yaml"

