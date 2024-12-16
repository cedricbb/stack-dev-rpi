#!/bin/bash
# install-wireguard.sh

# Installation de WireGuard
sudo apt-get update
sudo apt-get install -y wireguard

# Générer les clés
wg genkey | sudo tee /etc/wireguard/privatekey
sudo cat /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

# Configuration du serveur WireGuard
cat <<EOF | sudo tee /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
PrivateKey = $(sudo cat /etc/wireguard/privatekey)
ListenPort = 51820

# Exemple de configuration client (à répéter pour chaque client)
[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
EOF

# Activer le forwarding
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Démarrer WireGuard
sudo systemctl enable wg-quick@wg0
sudo systemctl start wg-quick@wg0

# Configuration du pare-feu
sudo ufw allow 51820/udp
sudo ufw allow 22/tcp
sudo ufw enable