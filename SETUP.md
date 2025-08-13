## Node Hardware

I used Raspberry Pi 5 devices, specifically the 16gb version (4 CPU cores each, so 16 total CPU cores + 64gb memory). I decided to run the cluster initially with 4 of them.

I plan to add a full PC with a 5090 to the cluster to allow for scheduling model training in the cluster.

Here's the list of what I bought for each of the main control/worker nodes:
1. [Raspberry Pi 5](https://www.amazon.com/dp/B0DSPYPKRG)
2. [NVMe + POE+ Pi 5 Hat and Active Cooler](https://www.amazon.com/dp/B0D8JC3MXQ)
3. [Samsung 2TB NVMe SSD](https://www.amazon.com/dp/B0DHLCRF91)
4. [256gb Micro SD Card](https://www.amazon.com/dp/B08TJZDJ4D)


## Node Networking

TODO: Discuss R Pi flashing micro sd, headless boot, and other node setup tasks

Next, install the DHCP server for each device via this command:

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
127.0.1.1       localhost # This should already be in your hosts file

192.168.0.11    node1 node1.local # Control node
192.168.0.12    node2 node2.local
192.168.0.13    node3 node3.local
192.168.0.14    node4 node4.local
```

TODO: Include section on generating SSH key and copying it over to worker nodes

Next, we're going to use a tool called Ansible to set up remote control over all our nodes. You might need to run this with `sudo`:

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
node1  ansible_connection=ssh
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
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --disable servicelb --token some_random_password --node-taint CriticalAddonsOnly=true:NoExecute --bind-address 192.168.0.10 --disable-cloud-controller --disable local-storage
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
ansible workers -b -m shell -a "curl -sfL https://get.k3s.io | K3S_URL=https:/<your control node IP>:6443 K3S_TOKEN=some_random_password sh -"
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

## Bootstrapping ArgoCD

This repo has a variety of services and architecture patterns. Initially on the Kube cluster, we'll want to bootstrap a ArgoCD installation which will then point to this repo and allow Argo to start deploying itself as well as other services. This repo has an app-of-apps architecture pattern for deployments.

