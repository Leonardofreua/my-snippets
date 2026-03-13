The Wi-Fi Idle Policy aims to configure a short time to trigger the screen lock when a connection to
a unknown network is detected.

# Behavior

| Event                                   | Script Executes | Reason                                                                 |
|------------------------------------------|----------------|------------------------------------------------------------------------|
| Computer boots                           | ❌ No          | Dispatcher runs only when NetworkManager triggers an event.           |
| User logs in                             | ❌ No          | Login does not trigger NetworkManager dispatcher events.              |
| Wi-Fi auto-connects during boot/login    | ✅ Yes         | NetworkManager emits `up` or `connectivity-change`.                   |
| Connect to a Wi-Fi network manually      | ✅ Yes         | Dispatcher runs on `up` event for the Wi-Fi interface.                |
| Switch between Wi-Fi networks            | ✅ Yes         | New connection triggers dispatcher with updated `CONNECTION_ID`.      |
| Disconnect from Wi-Fi                    | ✅ Yes         | Connectivity change triggers dispatcher.                              |
| Lock screen                              | ❌ No          | Locking does not affect NetworkManager state.                         |
| Unlock screen                            | ❌ No          | Unlocking does not trigger dispatcher events.                         |
| Resume from suspend with Wi-Fi reconnect | ✅ Usually     | NetworkManager typically emits a connectivity change event.           |

# Installation

* Create a scripts folder in your home directory;
* Move `wifi_idle_policy.sh` to `/home/<user_name>/scripts`;
* Provide execute permission:

```shell
sudo chmod +x ~/scripts/wifi_idle_policy.sh
```

* Create a service in /home/<user_name>/.config/systemd/user

> wifi-idle-policy.service
```
[Unit]
Description=WiFi Idle Policy

[Service]
Type=oneshot
ExecStart=%h/scripts/wifi_idle_policy.sh

[Install]
WantedBy=default.target
```

* Run below commands to enable the service:

```shell
systemctl --user daemon-reload
systemctl --user enable wifi-idle-policy.service
systemctl --user status wifi-idle-policy.service
```

Expected stdout:

```shell
○ wifi-idle-policy.service - WiFi Idle Policy
     Loaded: loaded (/home/eniac/.config/systemd/user/wifi-idle-policy.service; enabled; preset: enabled)
     Active: inactive (dead) since Thu 2026-03-12 21:02:54 -03; 1s ago
    Process: 42506 ExecStart=/home/eniac/scripts/wifi_idle_policy.sh (code=exited, status=0/SUCCESS)
   Main PID: 42506 (code=exited, status=0/SUCCESS)
        CPU: 31ms

mar 12 21:02:54 004587 systemd[2510]: Starting wifi-idle-policy.service - WiFi Idle Policy...
mar 12 21:02:54 004587 wifi_idle_policy.sh[42506]: Allowed Wi-Fi Detected: NW_1
mar 12 21:02:54 004587 systemd[2510]: Finished wifi-idle-policy.service - WiFi Idle Policy.
```

* Move `wifi_idle_policy_dispatcher` to `/etc/NetworkManager/dispatcher.d`
* Provide execute permission:

```shell
sudo chmod +x /etc/NetworkManager/dispatcher.d/wifi_idle_policy_dispatcher
```