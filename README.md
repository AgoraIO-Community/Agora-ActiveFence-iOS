# Agora Content Inspect Moderation Showcase

This GitHub project showcases the content inspect moderation features available with Agora and their partner ActiveFence. It demonstrates how to enable and use the Agora Content Inspector to moderate content in real-time during Agora video calls.

<p align="center">
    <img style="max-width:512px" src="media/activefence_content_inspect.gif" />
</p>

> This feature is not yet live, so the full configuration may not yet be available.

## Prerequisites

Before getting started, ensure that you have the following:

- An Agora developer account. If you don't have one, you can create an account at the [Agora Developer Console](https://console.agora.io).
- Xcode 14+.
- Basic knowledge of Swift and SwiftUI.

## Installation

To run the project locally, follow these steps:

1. Clone the repository to your local machine:

```bash
git clone https://github.com/AgoraIO-Community/Agora-ActiveFence-iOS.git
```

1. Open the project in Xcode.
2. Replace <#Agora App ID#> in ContentView with your Agora App ID. You can obtain an App ID by creating a project at the Agora Developer Console.
3. Enable ActiveFence moderation on your Agora Account (not yet available)
4. Optional: Set up Kicking Server
   1. Head to [agora-activefence-kicker](https://github.com/AgoraIO-Community/agora-activefence-kicker) and use the one-click deployment for the server
   2. Add the deployment link + `/kick/` to the webhook URL for the desired event in the ActiveFence dashboard.
5. Build and run the project on an iOS device.

## Usage

Focusing on only the content moderation portions, this example app completes the following steps:

### Initialise an `AgoraContentInspectConfig`

The inspect config is set up inside `ContentInspectManager` as such:

```swift
    var inspectConfig: AgoraContentInspectConfig = {
        let module = AgoraContentInspectModule()
        module.type = .imageModeration
        module.interval = 5

        let config = AgoraContentInspectConfig()
        config.modules = [module]

        return config
    }()
```

The above config monitors the images in a video feed, taking one frame every 5 seconds.

### Apply `AgoraContentInspectConfig` To The Engine

The content inspect should be enabled after joining a channel.

```swift
self.agoraEngine.enableContentInspect(true, config: self.inspectConfig)
```

### Catch Banning Events

To know when your local user is banned from the scene, you can utilise the `connectionStateChangedTo` delegate method:

```swift
    func rtcEngine(
        _ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState,
        reason: AgoraConnectionChangedReason
    ) {
        if state == .failed, reason == .reasonBannedByServer {
            isBanned = true
        }
    }
```

> This will only happen if you have applied the `Kicking Server` steps above, or created your own kicking server that communicates with ActiveFence.

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please feel free to open a GitHub issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).