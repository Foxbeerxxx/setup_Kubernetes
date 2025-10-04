#!/usr/bin/env bash
set -euo pipefail
MASTER_IP="192.168.1.141"

sudo kubeadm init \
  --apiserver-advertise-address=${MASTER_IP} \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

echo "kubeadm token create --print-join-command"
