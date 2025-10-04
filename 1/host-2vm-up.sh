#!/usr/bin/env bash
set -euo pipefail
MASTER="k8s-m1"
WORKER="k8s-w1"

vagrant ssh "$MASTER" -c 'sudo bash /vagrant/vm-init-master.sh'
JOIN=$(vagrant ssh "$MASTER" -c "kubeadm token create --print-join-command" | tr -d '\r' | tail -n1)
echo "JOIN: $JOIN"
vagrant ssh "$WORKER" -c "sudo $JOIN --cri-socket=unix:///run/containerd/containerd.sock"
vagrant ssh "$MASTER" -c "kubectl get nodes -o wide"
