#!/bin/bash

DNSCRYPT_PORT=5300
DNSCRYPT_BIN="./dnscrypt-proxy"
DNSCRYPT_CONFIG="dnscrypt-proxy.toml"

echo "[+] Ogarnianie firewalla na port lokalny 53 i 5300"
sudo firewall-cmd --permanent --add-port=53/tcp
sudo firewall-cmd --permanent --add-port=53/udp
sudo firewall-cmd --permanent --add-port=5300/udp
sudo firewall-cmd --reload
sleep 2

echo "[+] Uruchamiam dnscrypt-proxy na porcie $DNSCRYPT_PORT..."
nohup "$DNSCRYPT_BIN" -config "$DNSCRYPT_CONFIG" > /dev/null 2>&1 &

sleep 2

echo "[+] Konfiguruję NetworkManager, by używał 127.0.0.1 jako DNS..."
# Wyłącz domyślne zarządzanie DNS przez NetworkManager
sudo mkdir -p /etc/NetworkManager/conf.d
echo -e "[main]\ndns=none" | sudo tee /etc/NetworkManager/conf.d/no-dns.conf > /dev/null

# Dispatcher script – wymusza wpis DNS po każdej zmianie interfejsu
sudo mkdir -p /etc/NetworkManager/dispatcher.d
sudo tee /etc/NetworkManager/dispatcher.d/99-force-localdns > /dev/null <<EOF
#!/bin/bash
INTERFACE="\$1"
STATUS="\$2"

if [ "\$STATUS" = "up" ]; then
    echo "nameserver 127.0.0.1" > /etc/resolv.conf
fi
EOF

sudo chmod +x /etc/NetworkManager/dispatcher.d/99-force-localdns

echo "[+] Przekierowuję port 53 -> $DNSCRYPT_PORT za pomocą iptables..."
# Przekierowanie portu 53 na 5300 lokalnie
sudo iptables -t nat -C OUTPUT -p udp --dport 53 -j REDIRECT --to-port $DNSCRYPT_PORT 2>/dev/null || \
sudo iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-port $DNSCRYPT_PORT

echo "[+] Restartuję NetworkManager..."
sudo systemctl restart NetworkManager

echo "[✓] dnscrypt-proxy działa na porcie $DNSCRYPT_PORT. DNS wymuszony na 127.0.0.1."

