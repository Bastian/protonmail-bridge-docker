# Protonmail Bridge Docker

A Docker image for running [Protonmail Bridge](https://proton.me/mail/bridge) in
headless mode.

> [!WARNING]  
> For use on my private home server. Use at your own risk. There are no plans to
> add features beyond what I need for myself.

## Quick Start

### 1. Build the Image

```bash
docker build -t protonmail-bridge .
```

### 2. Initial Setup (Interactive)

First run must be interactive to log in:

```bash
mkdir -p ./proton_state
docker run -it --name proton-bridge \
    -v ./proton_state:/home/bridge \
    --user "$(id -u):$(id -g)" \
    protonmail-bridge protonmail-bridge --cli
```

### 3. Log In

At the `>>>` prompt:

```bash
>>> login
```

Follow the prompts to enter your Protonmail email and password. If you have 2FA enabled, you'll be prompted for the code.

### 4. Get Your Bridge Credentials

After logging in, get your IMAP/SMTP credentials:

```bash
>>> info
```

Exit the CLI:

```bash
>>> exit
```

### 5. Run in Background

After initial setup, restart the container in headless mode:

```bash
docker rm proton-bridge
docker run -d --name proton-bridge \
    -v ./proton_state:/home/bridge \
    --user "$(id -u):$(id -g)" \
    --restart unless-stopped \
    protonmail-bridge
```

To access the CLI later (e.g., to check credentials), stop the container and run interactively again:

```bash
docker rm -f proton-bridge
docker run -it --name proton-bridge \
    -v ./proton_state:/home/bridge \
    --user "$(id -u):$(id -g)" \
    protonmail-bridge protonmail-bridge --cli
```

## Ports

| Container Port | Protocol | Notes                                      |
| -------------- | -------- | ------------------------------------------ |
| 1144           | IMAP     | External port (socat forwards to 1143)     |
| 1026           | SMTP     | External port (socat forwards to 1025)     |

Connect from other containers using `protonmail-bridge:1144` (IMAP) and `protonmail-bridge:1026` (SMTP).

## Volumes

| Path           | Description                               |
| -------------- | ----------------------------------------- |
| `/home/bridge` | Bridge data, GPG keys, and password store |

**Important**: Persist this volume to retain your login across container restarts.

## Updating

To update to a new Bridge version:

1. Edit `BRIDGE_VER` and `BRIDGE_SHA256` in the Dockerfile
2. Get the new SHA256: Build once and check the error message for the correct hash
