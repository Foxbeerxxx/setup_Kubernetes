# Домашнее задание к занятию "`Установка Kubernetes`" - `Татаринцев Алексей`



---

### Задание 1


1. `Основной хост у меня не мощный, поэтому создаю кластер только с 2мя ВМ`
```
Схема кластера

master: 192.168.1.141 → hostname k8s-m1
worker1: 192.168.1.145 → hostname k8s-w1


Параметры установки:
-kubeadm + containerd
-сеть: Flannel
-etcd: на мастере
```
2. `Для запуска кластера буду использовать Vagrantfile c наполнением`

```
Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.synced_folder ".", "/vagrant", disabled: true

  BRIDGE_IF = "enp2s0"  #  физический интерфейс LAN

  NODES = [
    {name: "k8s-m1", ip: "192.168.1.141", mem: 2048, cpus: 2},
    {name: "k8s-w1", ip: "192.168.1.145", mem: 2048, cpus: 2},
  ]

  NODES.each do |node|
    config.vm.define node[:name] do |n|
      n.vm.hostname = node[:name]
      n.vm.provider :virtualbox do |vb|
        vb.name   = node[:name]
        vb.memory = node[:mem]
        vb.cpus   = node[:cpus]
      end
      n.vm.network "public_network", ip: node[:ip], bridge: BRIDGE_IF
      n.vm.provision "shell", path: "provision-2vm-common.sh"
    end
  end
end
```

3. `Запускаю vagrant up и проверяю`

![1](https://github.com/Foxbeerxxx/setup_Kubernetes/blob/main/img/img1.png)

4. `kubeadm init на мастере`
```
vagrant ssh k8s-m1 -c 'sudo kubeadm init \
  --apiserver-advertise-address=192.168.1.141 \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock'

Последовал вывод:

alexey@dellalexey:~/dz/setup_Kubernetes/1$ vagrant ssh k8s-m1 -c 'sudo kubeadm init \
  --apiserver-advertise-address=192.168.1.141 \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock'
[init] Using Kubernetes version: v1.34.1
[preflight] Running pre-flight checks
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action beforehand using 'kubeadm config images pull'
W1004 16:03:16.284667    4574 checks.go:830] detected that the sandbox image "registry.k8s.io/pause:3.8" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.1" as the CRI sandbox image.
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [k8s-m1 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.141]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [k8s-m1 localhost] and IPs [192.168.1.141 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [k8s-m1 localhost] and IPs [192.168.1.141 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "super-admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/instance-config.yaml"
[patches] Applied patch of type "application/strategic-merge-patch+json" to target "kubeletconfiguration"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests"
[kubelet-check] Waiting for a healthy kubelet at http://127.0.0.1:10248/healthz. This can take up to 4m0s
[kubelet-check] The kubelet is healthy after 1.003038457s
[control-plane-check] Waiting for healthy control plane components. This can take up to 4m0s
[control-plane-check] Checking kube-apiserver at https://192.168.1.141:6443/livez
[control-plane-check] Checking kube-controller-manager at https://127.0.0.1:10257/healthz
[control-plane-check] Checking kube-scheduler at https://127.0.0.1:10259/livez
[control-plane-check] kube-scheduler is healthy after 5.118950241s
[control-plane-check] kube-controller-manager is healthy after 6.978525205s
[control-plane-check] kube-apiserver is healthy after 10.507190818s
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node k8s-m1 as control-plane by adding the labels: [node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node k8s-m1 as control-plane by adding the taints [node-role.kubernetes.io/control-plane:NoSchedule]
[bootstrap-token] Using token: 39yqx7.puwia5raymmj468i
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] Configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] Configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] Configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 192.168.1.141:6443 --token 39yqx7.puwia5raymmj468i \
        --discovery-token-ca-cert-hash sha256:de3bef855a6e61c455221522e1606603839b58df6c38a009cef438ebf20d244c 

```

5. `Скопировать kubeconfig:`

```
vagrant ssh k8s-m1 -c 'mkdir -p $HOME/.kube && \
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config && \
  sudo chown $(id -u):$(id -g) $HOME/.kube/config'

```
6. `Получить join-команду и присоединить воркер`

```
JOIN=$(vagrant ssh k8s-m1 -c "kubeadm token create --print-join-command" | tr -d '\r' | tail -n1)
echo "$JOIN"
vagrant ssh k8s-w1 -c "sudo $JOIN --cri-socket=unix:///run/containerd/containerd.sock"
```
![2](https://github.com/Foxbeerxxx/setup_Kubernetes/blob/main/img/img2.png)


7. `Проверка кластера`

```
захожу в мастер
vagrant ssh k8s-m1
kubectl get nodes -o wide
kubectl get pods -A
kubectl get svc nginx -o wide

Делаю проверку через Curl
curl -I http://192.168.1.145:30316
ну и через браузер
```
![3](https://github.com/Foxbeerxxx/setup_Kubernetes/blob/main/img/img3.png)

![4](https://github.com/Foxbeerxxx/setup_Kubernetes/blob/main/img/img4.png)

