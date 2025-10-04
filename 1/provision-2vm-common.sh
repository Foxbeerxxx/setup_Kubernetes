#!/usr/bin/env bash
set -euo pipefail
NODE_IP=$(hostname -I | awk '{print $1}')

cat >/etc/hosts <<'HST'
127.0.0.1 localhost
127.0.1.1 $(hostname)

192.168.1.140 dellalexey
192.168.1.141 k8s-m1
192.168.1.145 k8s-w1
HST

swapoff -a || true
sed -i '/\sswap\s/s/^/#/' /etc/fstab || true

cat >/etc/modules-load.d/k8s.conf <<'M'
overlay
br_netfilter
M
modprobe overlay || true
modprobe br_netfilter || true

cat >/etc/sysctl.d/k8s.conf <<'S'
net.bridge.bridge-nf-call-iptables=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.ip_forward=1
S
sysctl --system

apt-get update
apt-get install -y containerd apt-transport-https ca-certificates curl gpg
mkdir -p /etc/containerd
containerd config default >/etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable --now containerd

mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.34/deb/Release.key \
 | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.34/deb/ /" \
 >/etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

echo "KUBELET_EXTRA_ARGS=--node-ip=${NODE_IP}" >/etc/default/kubelet
systemctl daemon-reload
systemctl restart kubelet
