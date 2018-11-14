#!/bin/bash

set -e

USER=kube
CTR_FILE=/etc/kubernetes/manifests/kube-controller-manager.yaml
KUBE_TOKEN=/tmp/kuber_connect_token
IP_MASTER=192.168.77.10
POD_NET=10.244.0.0/16
TOKEN=/tmp/token

URL_FLANEL=https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
URL_DASHBORD=https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml


create_ceph_user(){
    ceph auth get-or-create client.${USER} mon 'allow r' osd 'allow rwx pool=kube'
    ceph auth get-key client.admin > /etc/ceph/client.admin
    ceph auth get-key client.${USER} > /etc/ceph/ceph.client.${USER}.keyring
}
create_ceph_user

init_kuber(){
    kubeadm init --apiserver-advertise-address=${IP_MASTER} --pod-network-cidr=${POD_NET} | tee  ${KUBE_TOKEN}
    #useradd 
    mkdir ~kube/.kube
    cp /etc/kubernetes/admin.conf ~kube/.kube/config
    chown kube: ~kube/.kube/config

    su - ${USER} -c "kubectl taint nodes --all node-role.kubernetes.io/master-"
    sleep 25
    su - ${USER} -c "kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default"
    sleep 15
    su - ${USER} -c "kubectl apply -f ${URL_FLANEL}"
    # cheack

    for i in {1..4}; do
        su - ${USER} -c "kubectl -n kube-system get pods";
        sleep 25
    done
}
init_kuber



#kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
su - ${USER} -c "kubectl create -f ${URL_DASHBORD}" && sleep 25
su - ${USER} -c "kubectl -n kube-system create -f account.yaml"
su - ${USER} -c "kubectl proxy &"
su - ${USER} -c "kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') > ${TOKEN}"

#rbd create
create_rbd(){
    chmod 777 /var/run/docker.sock
    docker build -t "my-kube-controller-manager:v1.12.1" /home/kube/
    docker images | grep my-kube-controller-manager
    docker run my-kube-controller-manager:v1.12.1 whereis rbd
    #/etc/kubernetes/manifests/kube-controller-manager.yaml
    sed -e "s/k8s.gcr.io\/kube-controller-manager:v1.12.1/my-kube-controller-manager:v1.12.1/g" ${CTR_FILE} -i

    su - ${USER} -c "kubectl -n kube-system describe pods | grep kube-controller"
}
create_rbd

su - ${USER} -c 'kubectl create secret generic ceph-secret --type="kubernetes.io/rbd" --from-file=/etc/ceph/client.admin --namespace=kube-system'
su - ${USER} -c 'kubectl create secret generic ceph-secret-kube --type="kubernetes.io/rbd" --from-file=/etc/ceph/ceph.client.kube.keyring  --namespace=default'
su - ${USER} -c "kubectl create -f ceph_storage.yaml"
sleep 5
su - ${USER} -c "kubectl get storageclass"
#su - ${USER} -c "kubectl create -f test_pod.yaml"
su - ${USER} -c "kubectl create -f storege_claim3.yml"
sleep 5
su - ${USER} -c "kubectl create -f django_dp.yml"
su - ${USER} -c "kubectl get pods"
sleep 5
su - ${USER} -c "kubectl create -f django_svc.yml"
su - ${USER} -c "kubectl get pvc"
sleep 5
su - ${USER} -c "kubectl get pv" 

cat ${KUBE_TOKEN} | grep "kubeadm join" 


exit 0




