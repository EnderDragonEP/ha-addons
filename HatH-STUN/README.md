# !!! IN EARLY DEVELOPMENT !!!

**Please don’t use this yet.**
I need to publish this app so I can test it on my own system, changes are comming in very repidly. Do not waste your time on trying this until I update the README and mark this as ready for use.

# HatH-STUN Home Assistant app

A Home Assistant app for running a STUN server to facilitate NAT traversal and peer-to-peer connections for Hentai@Home.

## About

This app is a fork of the [HatH-STUN-Docker](https://github.com/Oniicyan/HatH-STUN-Docker) project, modified to work as a Home Assistant app. It provides an easy way to set up and manage a Hentai@Home client with STUN support within the Home Assistant ecosystem.

STUN (Session Traversal Utilities for NAT) is a protocol that helps devices behind firewall or router to discover their public IP address and the type of NAT they are behind. This is crucial for applications like Hentai@Home that require peer-to-peer communication. By running a STUN service, this app allows your Hentai@Home client to establish direct connections and participate in the Hentai@Home network.

## Installation

1. Add this repository to your Home Assistant app store

[![Add repository your Home Assistant instance and show the add app repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2FEnderDragonEP%2Fha-apps)

2. Install the "HatH-STUN" app
3. Configure the app with your credentials and STUN settings
4. Start the app


Then install and configure the app using the steps above. 

## Configuration

Blow is an example configuration for the app. You will need to replace the placeholders with your actual Hentai@Home client credentials and STUN settings.

```yaml
HathClientId: "H@H Client ID"
HathClientKey: "H@H Client Key"
HathData: "/share/hath"
Dns: 1.1.1.1
Stun: true
StunIpbId: "ipb_member_id"
StunIpbPass: "ipb_pass_hash"
```

| Option | Description |
|--------|-------------|
| `HathClientId` | Your Hentai@Home Client ID |
| `HathClientKey` | Your Hentai@Home Client Key |
| `HathData` | Path to store Hentai@Home data (default: `/share/hath`) |
| `Dns` | DNS server to use (default: `1.1.1.1`) |
| `Stun` | Enable STUN support (default: `true`) |
| `StunIpbId` | Your IPB member ID for STUN |
| `StunIpbPass` | Your IPB password hash for STUN |

You can get the IPB member ID and password hash from visiting e-hentai.org while logged in and inspecting the cookies for `ipb_member_id` and `ipb_pass_hash` with a chrome extension like [Get cookies.txt LOCALLY](https://chromewebstore.google.com/detail/get-cookiestxt-locally/cclelndahbckbenkjhflpdbgdldlbecc) or with developer tools.

For more information on the other options, please refer to [oniicyan99's Docker container documentation](https://github.com/Oniicyan/HatH-STUN-Docker).