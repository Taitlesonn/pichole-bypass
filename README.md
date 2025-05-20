# pichole-bypass


---

# 🔐 dnscrypt-setup

Ten skrypt Bash automatyzuje konfigurację lokalnej ochrony DNS przy użyciu `dnscrypt-proxy`. Ustawia reguły firewalla, przekierowuje ruch DNS, konfiguruje `NetworkManager` i uruchamia `dnscrypt-proxy` na porcie 5300.

## 📋 Wymagania

* Linux z `firewalld`, `iptables` i `NetworkManager`
* `dnscrypt-proxy` w tym samym katalogu co skrypt
* Plik konfiguracyjny `dnscrypt-proxy.toml` również w tym samym katalogu

## 🛠️ Co robi skrypt?

1. **Konfiguruje firewall**:

   * Otwiera porty 53/tcp, 53/udp i 5300/udp.

2. **Uruchamia `dnscrypt-proxy`**:

   * Na porcie `5300` w tle, przy użyciu `nohup`.

3. **Modyfikuje `NetworkManager`**:

   * Wyłącza domyślne zarządzanie DNS.
   * Dodaje dispatcher, który wymusza `127.0.0.1` jako serwer DNS przy każdej zmianie połączenia.

4. **Przekierowuje ruch DNS (port 53)**:

   * Za pomocą `iptables`, lokalny ruch na porcie 53 jest przekierowywany do `dnscrypt-proxy` na porcie 5300.

5. **Restartuje `NetworkManager`**:

   * Zmiany zaczynają działać od razu.

## ⚠️ Uwaga

* Skrypt wymaga uprawnień administratora (`sudo`).
* Jeśli masz inne reguły firewalla lub konfigurację DNS, upewnij się, że nie będą one kolidowały z tym skryptem.
* `dnscrypt-proxy` powinien być odpowiednio skonfigurowany w pliku `dnscrypt-proxy.toml`.

## 📦 Jak używać

```bash
chmod +x dns.sh
chmod +x dnscrypt-proxy
./dns.sh
```

## 🔁 Resetowanie zmian

Jeśli chcesz cofnąć zmiany:

* Usuń pliki:

  ```bash
  sudo rm /etc/NetworkManager/conf.d/no-dns.conf
  sudo rm /etc/NetworkManager/dispatcher.d/99-force-localdns
  ```
* Usuń regułę `iptables`:

  ```bash
  sudo iptables -t nat -D OUTPUT -p udp --dport 53 -j REDIRECT --to-port 5300
  ```
* Restartuj `NetworkManager`:

  ```bash
  sudo systemctl restart NetworkManager
  ```

---

