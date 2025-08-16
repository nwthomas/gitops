# Cluster Setup

The following is a loose record of exactly how I managed to set up my own home Kubernetes cluster. It is useful for others following this path or for myself in 6 months when I can't remember all of this.

## Node Hardware

I used Raspberry Pi 5 devices, specifically the 16gb version (4 CPU cores each, so 16 total CPU cores + 64gb memory). I decided to run the cluster initially with 4 of them.

I plan to add a full PC with a 5090 to the cluster to allow for scheduling model training in the cluster.

Here's the list of what I bought for each of the main control/worker nodes:
1. [Raspberry Pi 5](https://www.amazon.com/dp/B0DSPYPKRG)
2. [NVMe + POE+ Pi 5 Hat and Active Cooler](https://www.amazon.com/dp/B0D8JC3MXQ)
3. [Samsung 2TB NVMe SSD](https://www.amazon.com/dp/B0DHLCRF91)
4. [256gb Micro SD Card](https://www.amazon.com/dp/B08TJZDJ4D)

## Node OS Software Installation

After putting together your hardware, you'll need to go ahead and flash the Pi OS to an SD card. I used micro SD cards for the boot drive (the NVMe drives are for all other data used in the kube cluster).

Download [Raspberry Pi Imager](https://www.raspberrypi.com/software/) and connect your micro SD card.

When going through the flow, select the following options:

1. Choose Raspberry Pi 5 for the device
2. `Raspberry Pi OS 64 bit`
3. Choose your SD card as the storage to write to
4. Edit settings under `General` and set the hostname, a username/password for SSH (although we won't use it), configure the LAN, and set your locale
5. Also, go to `Services` and enable SSH. I'd allow public-key authentication only (and set an authorized_keys key for your account)

Go ahead and write to the device. Once it's done, remove your micro SD card.

Insert it into the Pi and power it up. Your Pi will initiate the headless boot process, but you should be able to ssh into it eventually via:

```bash
ssh <your username>@<pi hostname>.local
```

Great job. You're ssh-ed into your Pi!

## Node Networking

After you can ssh into your Pi, install the DHCP server for each device via this command:

```bash
sudo apt upgrade
sudo apt install dhcpcd5 # The 5 here is correct
sudo systemctl enable dhcpcd
sudo systemctl start dhcpcd
```

Then, add a static IP to the `dchpcd.conf` file:

```bash
sudo nano /etc/dhcpcd.conf

# Add something like this to the bottom. It will be different for you depending on your router IP ranges.
interface wlan0
static ip_address=192.168.0.18/24
static routers=192.168.0.1
static domain_name_servers=1.1.1.1 8.8.8.8
nohook wpa_supplicant
```

Flush your DHCP leases and restart your Pi afterwards:

```bash
sudo ip addr flush dev wlan0
sudo systemctl restart dhcpcd
sudo reboot
ip addr show wlan0 # Check for correct IP assignment
```

Next, set a static hostname on the network. Example:

```bash
sudo hostnamectl set-hostname some-cool-pi-name-here
```

If you're using ethernet connections like me, you'll also want to disable Wi-Fi for cluster stability:

```bash
echo "dtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
```

Also, set the CPU governer to `schedutil` so that you can control CPU frequency scaling for balanced performance and power usage:

```bash
# This will make it persistent across reboots which is what you want
sudo apt install -y cpufrequtils
echo 'GOVERNOR="schedutil"' | sudo tee /etc/default/cpufrequtils
```

Do this on every single one of your Pis after booting them up. Next, check the network from your control node via:

```bash
#switch to root
sudo -s
#install nmap
apt install nmap
#scan local network range to see who is up
nmap -sP 192.168.0.1-254
```

Then, edit your `/etc/hosts` file on the control node (whichever one you choose). Here's an example of mine:

```bash
127.0.1.1       node1 # There's already a localhost one, but add this as well

192.168.0.11    node1 node1.local # Control node
192.168.0.12    node2 node2.local
192.168.0.13    node3 node3.local
192.168.0.14    node4 node4.local
```

[defaults]
private_key_file = /Users/nathanthomas/.ssh/id_ed25519

10.0.0.3        red1 red1.local # Control node
10.0.0.4        red2 red2.local
10.0.0.5        red3 red3.local
10.0.0.6        red4 red4.local

Next, we need to generate an RSA key and distribute it to our worker nodes in order for us to issue ssh commands from inside our control node. I'd advise NOT reusing your own SSH key you're using right now already to connect to each of the nodes. Ideally, we'll be able to tell later if the intra-node SSH key was being used.

Run this on your control node Pi:

```bash
ssh-keygen -t ed25519 -C "ansible_key" -f ~/.ssh/anbsible_id_ed25519
```

Then, copy it to your computer and then to other Pis in the cluster. This will allow the control node to ssh into them:

```bash
# Copy from control node Pi to computer
scp <your ssh username>@<your control node pi name>.local:~/.ssh/anbsible_id_ed25519.pub ~/ansible_id_ed25519.pub
scp <your ssh username>@<your control node pi name>.local:~/.ssh/anbsible_id_ed25519 ~/ansible_id_ed25519

# Copy from your computer to Pis
ssh-copy-id -i ~/ansible_id_ed25519.pub -f nathanthomas@red2
```

Next, we're going to use a tool called Ansible to set up remote control over all our nodes. It will effectively allow us to issue install commands or customize all our nodes at once via single commands.

Run the following commands:

```bash
# You may need to run this as root
sudo -i

# Install ansible
apt install ansible
```

Next, you'll want to create a file called `/etc/ansible/hosts` and add all our hosts to it. We're defining hosts and groups of hosts that Ansible will try to manage for us:

```bash
# To edit the file (you make have to create this file)
sudo nano /etc/ansible/hosts

# File /etc/ansible/hosts
[control]
node1  ansible_connection=local

[workers]
node2  ansible_connection=ssh
node3  ansible_connection=ssh
node4  ansible_connection=ssh

[cube:children]
control
workers
```

Above, you can see I have added 3 groups: `control`, `workers` and `cube`. Name of the group is the one in between [ ]. This was split so that if I want to execute some actions only on control server, I use the “control” group. Group “cube” has children. This basically means that it’s a group of groups, and when I’m using cube I’m targeting every single node from the listed groups.

Variable: `ansible_connection`: we are telling Ansible how to connect to that host. The primary method is ssh, but I specified “local” for `node1`, because this is the node that we are running Ansible from. This way, it won’t try to ssh to itself.

Lastly, we are going to make it so that user root will be able to log in to other nodes from `node1` without the password using an ssh key. This step is optional, but after this you won’t need to type the password every time you run Ansible.

Once this is set up, you can do a test run of Ansible with this command:

```bash
# Test pinging all control + worker nodes to verify they are setup correctly
ansible cube -m ping

## Response
node1 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node2 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node3 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
node4 | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

Also, install iptables on all of the nodes via this process (needed for k3s/Kubernetes):

```bash
# Install
ansible cube -m apt -a "name=iptables state=present" --become

# Reboot
ansible workers -b -m shell -a "reboot"

# Manually install on each node
apt -y install iptables
```

Finally, logout of the control node and get ready for the next section:

```bash
logout
```

## Setting Up Kubernetes / K3s

At any time during this guide, you can run the following commands to start/stop k3s:

```bash
# Stop k3s
sudo systemctl stop k3s

# Start k3s
sudo systemctl restart k3s

# Check status
sudo systemctl status k3s
```

First, set memory constraints for every node (including control) via appending this to the end of `/boot/firmware/cmdline.txt` (you will need to open with `sudo`):

```bash
cgroup_enable=memory cgroup_memory=1

# Reboot when you're done
sudo reboot
```

Install k3s via this command:

```bash
# Install
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable servicelb --token some_random_password --node-taint CriticalAddonsOnly=true:NoExecute --bind-address 192.168.0.10 --disable-cloud-controller --disable local-storage

# Verify the node taint with this
kubectl describe node red1 | grep -i taint
```

Be sure to replace "some_random_password" with a password you save and preserve. You'll need this to connect to the main k3s master node. Replace the bind address flag IP with your control node's IP that you set earlier.

Once you run and install this via the `curl` command, check the installation with `kubectl`:

```bash
# Check nodes
kubectl get nodes

# Listing out
NAME   STATUS     ROLES                  AGE     VERSION
node1   Ready      control-plane,master   10m     v1.33.3+k3s1
```

After this, you'll need to install k3s onto your worker nodes which you can do with Ansible:

```bash
ansible workers -b -m shell -a "curl -sfL https://get.k3s.io | K3S_URL=https://<your control node IP>:6443 K3S_TOKEN=some_random_password sh -"
```

Once you've done this, verify this worked via:

```bash
# Checking if it worked
kubectl get nodes

# Response with nodes in cluster
NAME    STATUS     ROLES                  AGE     VERSION
node1   Ready      control-plane,master   10m     v1.33.3+k3s1
node2   Ready      <none>                 3m32s   v1.33.3+k3s1
node3   Ready      <none>                 3m32s   v1.33.3+k3s1
node3   Ready      <none>                 3m32s   v1.33.3+k3s1
```

If you're interested in total resources now in the cluster, you can check with this command:

```bash
# Long
kubectl get nodes -o custom-columns=NAME:.metadata.name,CPU:.status.capacity.cpu,MEM:.status.capacity.memory
```

You should also probably label the other nodes, so do something like this:

```bash
# Labels for cosmetic reasons
kubectl label nodes node2 kubernetes.io/role=worker
kubectl label nodes node3 kubernetes.io/role=worker
kubectl label nodes node4 kubernetes.io/role=worker

# Labels used for directing deployments to prefer certain nodes
kubectl label nodes node2 node-type=worker
kubectl label nodes node3 node-type=worker
kubectl label nodes node4 node-type=worker
```

Verify via showing all labels:

```bash
kubectl get nodes --show-labels
```

Show any taints with this command:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints --no-headers
```

Lastly, change the source of the kubeconfig like so via Ansible:

```bash
ansible cube -b -m lineinfile -a "path='/etc/environment' line='KUBECONFIG=/etc/rancher/k3s/k3s.yaml'"
```

This is the source of truth for each of the kube deployments (client and servers for control and workers).

## Setting Up Helm

Next, we need to install Helm in order to make use of Helm charts. Run this on the control node Pi:

```bash
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

That's it! Onwards!

## Swapping Traefik for Metallb

K3s comes with Traefik which is pretty great. However, we want to be able to assign an external IP to service (like our dashboards), and it's just not as customizable as we'd like.

Instead, let's move to using `metallb` as our load balancer for the cluster. [Documentation](https://metallb.io/?ref=rpi4cluster.com)

Run these commands on your control node to install it:

```bash
# First add metallb repository to your helm
helm repo add metallb https://metallb.github.io/metallb

# Check if it was found
helm search repo metallb

# Install metallb
helm upgrade --install metallb metallb/metallb --create-namespace \
--namespace metallb-system --wait
```

The command may take a second. You can check in another terminal tab while ssh-ed into your control node to check the installation process:

```bash
kubectl get pods -n metallb-system
```

Once install is done, the command from above will finish. If it hands longer than ~5 minutes, you have networking issues you'll need to resolve and god help you.

Finally, apply this custum resource definition:

```bash
cat << 'EOF' | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.0.200-192.168.0.250 # replace this with your own IP range
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF
```

## Storage

Next, we're going to boostrap Longhorn for our file storage. This will enable us to use the NVMe drives on our Pis. We'll later move to using ArgoCD and Helm charts as the source of truth for these, but that will come later.

Run these on the control node:

```bash
ansible cube -b -m apt -a "name=nfs-common state=present"
ansible cube -b -m apt -a "name=open-iscsi state=present"
ansible cube -b -m apt -a "name=util-linux state=present"
```

We'll be using Ansible a ton for this setup which will make all the pain there worth it.

Go ahead and run this command to see all disk labels:

```bash
ansible cube -b -m shell -a "lsblk -f"
```

If you decided to go the route of NVMEs like I did, you'll actually need to format them.

First, set the below in your `/etc/ansible/hosts`:

```bash
sudo nano /etc/ansible/hosts

# File /etc/ansible/hosts
[control]
node1  ansible_connection=local var_hostname=node1 var_disk=<your nvme drive name here>

[workers]
node2  ansible_connection=ssh var_hostname=node2 var_disk=<your nvme drive name here>
node3  ansible_connection=ssh var_hostname=node3 var_disk=<your nvme drive name here>
node4  ansible_connection=ssh var_hostname=node4 var_disk=<your nvme drive name here>

[cube:children]
control
workers
```

Then, run these commands (but triple check you set the right drives above beforehand):

```bash
# Wipe
ansible workers -b -m shell -a "wipefs -a /dev/{{ var_disk }}"

# Format to ext4
ansible workers -b -m filesystem -a "fstype=ext4 dev=/dev/{{ var_disk }}"
```

Afterwards, get all drives and their available sizes with this command:

```bash
# Command
ansible cube -b -m shell -a "lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT"

# Response
node1 | CHANGED | rc=0 >>
f1f2c384-4619-4a93-be82-42bbfee0269c
node2 | CHANGED | rc=0 >>
5002bfe6-dcd1-4814-85ab-54b9c0fe710e
node3 | CHANGED | rc=0 >>
4f92985d-5d8f-4429-ab2c-b10c650a5d0b
node4 | CHANGED | rc=0 >>
b114d056-c935-4410-b490-02a3302b38d2
```

We'll get unique UUIDs for the drives in case the paths change. Let's go ahead and update our Ansible config to use these:

```bash
[control]
node1  ansible_connection=local var_hostname=node1 var_disk=<your nvme drive name here> var_uuid=<your drive UUID here>

[workers]
node2  ansible_connection=ssh var_hostname=node2 var_disk=<your nvme drive name here> var_uuid=<your drive UUID here>
node3  ansible_connection=ssh var_hostname=node3 var_disk=<your nvme drive name here> var_uuid=<your drive UUID here>
node4  ansible_connection=ssh var_hostname=node4 var_disk=<your nvme drive name here> var_uuid=<your drive UUID here>

[cube:children]
control
workers
```

Next, we'll go ahead and mount the storage disks via this command:

```bash
ansible cube -m ansible.posix.mount -a "path=/storage01 src=UUID={{ var_uuid }} fstype=ext4 state=mounted" -b
```

We'll now install longhorn to be able to interact with these drives. Fortunately, we can just use Helm again for this. We'll make ArgoCD pages to deploy it later:

```bash
# Run these on the control node
cd
helm repo add longhorn https://charts.longhorn.io
helm repo update
helm install longhorn longhorn/longhorn --namespace longhorn-system --create-namespace --set defaultSettings.defaultDataPath="/storage01" --version 1.9.1
```

I had a lot of trouble getting this to work correctly and had to fully delete all the resources and reinstall several times.

You can check the pods for the deployment and the CRDs with these commands:

```bash
# Pods
kubectl -n longhorn-system get pod

# CRDs
kubectl get crds | grep engineimages
```

Next, apply a config for it here:

```bash
# On your control node
touch longhorn.yaml

# File contents
apiVersion: v1
kind: Service
metadata:
  name: longhorn-ingress-lb
  namespace: longhorn-system
spec:
  selector:
    app: longhorn-ui
  type: LoadBalancer
  loadBalancerIP: <one of your IPs from the metallb range here>
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: http

# Then apply
kubectl apply -f longhorn.yaml
```

Before we finish, verify that Longhorn is now the default storage class:

```bash
kubectl get storageclass
```

## Bootstrapping ArgoCD

This repo has a variety of services and architecture patterns. Initially on the Kube cluster, we'll want to bootstrap a ArgoCD installation which will then point to this repo and allow Argo to start deploying itself as well as other services. This repo has an app-of-apps architecture pattern for deployments.

First, create a namespace for ArgoCD (we'll later set up Terraform to handle this for us, but we're bootstrapping at the moment):

```bash
# Create the namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Validate the install worked 
kubectl get pods -n argocd
kubectl get svc -n argocd
```

Next, create an `argocd_boostrap.yaml` file in the control Pi. We're going to manually apply it to point to your gitops repository (realistically, a fork of this one):

```bash
touch argocd_bootstrap.yaml
```

Copy in the content from [this file](https://github.com/nwthomas/gitops/blob/main/argocd/root/root-app.yaml)