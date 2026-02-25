# Network Routing Architecture

This document outlines the ingress routing architecture for the cluster.
The design targeted at efficiently handles both internal and external traffic,
utilizing Split DNS for local access and a combination of
Cloudflare Tunnels and Direct IPv6 for external access.

## Architecture Diagram

```mermaid
graph LR
    %% Clients
    Ext[External Client]
    Int[Internal Client]

    %% Middle Tier & Ingress
    CF_Tunnel("Cloudflare Tunnel<br/>(Terminates TLS)")
    Domain_i["*.i.isning.moe (IPv6)"]
    i_reroute("i-reroute Proxy<br/>(Terminates TLS<br/>& Rewrites Host)")

    %% Gateway (Rearranged node order to perfectly avoid line crossings)
    subgraph Gateway [Standard Gateway]
        GW_8080["*.isning.moe:8080"]
        GW_80["*.isning.moe:80"]
        GW_443["*.isning.moe:443"]
    end

    %% --- 1. Top Path ---
    Ext -->|"Slow Path"| CF_Tunnel
    CF_Tunnel -->|"Forward"| GW_8080

    %% --- 2. Middle Path (Includes IPv6 and i-reroute routing) ---
    Ext -->|"Direct IPv6 (Fast Path)"| Domain_i
    Int -->|"Direct IPv6 (Fast Path)"| Domain_i
    
    %% Domain receives 80 & 443 traffic and passes it to the proxy
    Domain_i -->|"HTTP & HTTPS"| i_reroute
    
    %% i-reroute routing logic
    i_reroute -->|"Forward 443 (Decrypted)"| GW_8080
    i_reroute -->|"Forward 80"| GW_80

    %% --- 3. Bottom Path (Internal Direct) ---
    Int -->|"Split DNS (Fast Path)"| GW_80
    Int -->|"Split DNS (Fast Path)"| GW_443

    %% Style Definitions
    style Domain_i fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    style CF_Tunnel fill:#fff3e0,stroke:#e65100,stroke-width:2px
    style i_reroute fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    style GW_80 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style GW_443 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style GW_8080 fill:#e8f5e9,stroke:#1b5e20,stroke-width:2px
    style Gateway fill:#fafafa,stroke:#9e9e9e,stroke-width:2px,stroke-dasharray: 5 5

```

## Traffic Flows

### 1. External Access (Slow Path)

* **Route:** External Client -> Cloudflare Tunnel -> Gateway (`:8080`)
* **Description:** Provides secure public access to `*.isning.moe` without exposing local ports. Cloudflare handles TLS termination.

### 2. IPv6 Direct Access (Fast Path)

* **Route:** Client -> `*.i.isning.moe` -> `i-reroute Proxy` -> Gateway (`:80` or `:8080`)
* **Description:** External or Internal clients with IPv6 support can bypass Cloudflare. The `i-reroute Proxy` terminates TLS, rewrites the Host header to `*.isning.moe`, and routes traffic based on the protocol.

### 3. Internal Access (Split DNS Fast Path)

* **Route:** Internal Client -> Gateway (`:80` or `:443`)
* **Description:** Local network clients resolve `*.isning.moe` directly to the local gateway IP via Split DNS, avoiding proxy overhead entirely.

## Core Components

* **Cloudflare Tunnel:** Secures external IPv4/general traffic. Terminates TLS before forwarding to the local network.
* **i-reroute Proxy:** A custom reverse proxy handling the `*.i.isning.moe` domain. Its primary jobs are TLS termination, Host header rewriting, and HTTP/HTTPS traffic splitting.
* **Standard Gateway:** The core entry point for the backend services.

## Gateway Port Mapping

| Port | Traffic Source | Description |
| --- | --- | --- |
| **80** | Internal Split DNS, `i-reroute` | Standard plain HTTP traffic. |
| **443** | Internal Split DNS | Standard HTTPS traffic (Gateway handles TLS). |
| **8080** | Cloudflare Tunnel, `i-reroute` | Decrypted HTTPS traffic forwarded from upstream proxies. |
