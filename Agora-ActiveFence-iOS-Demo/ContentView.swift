//
//  ContentView.swift
//  Agora-ActiveFence-iOS-Demo
//
//  Created by Max Cobb on 27/06/2023.
//

import SwiftUI
import AgoraRtcKit

class ContentInspectManager: AgoraManager {

    /// Label showing the current state of the content inspector
    @Published var inspectLabel: String = "Connecting..."

    @Published var isBanned = false

    /// Configuration for Agora Content Inspector
    var inspectConfig: AgoraContentInspectConfig = {
        let module = AgoraContentInspectModule()
        module.type = .imageModeration
        module.interval = 5

        let config = AgoraContentInspectConfig()
        config.modules = [module]

        return config
    }()

    /// Enable content inspector.
    ///
    /// This should be called after joining a channel.
    func setupContentInspect() {
        let enableResp = self.agoraEngine.enableContentInspect(true, config: self.inspectConfig)
        inspectLabel = "Content Inspect \(enableResp == 0 ? "Enabled" : "Failed: \(enableResp)")"
    }

    func rtcEngine(
        _ engine: AgoraRtcEngineKit, connectionChangedTo state: AgoraConnectionState,
        reason: AgoraConnectionChangedReason
    ) {
        if state == .failed, reason == .reasonBannedByServer {
            inspectLabel = ""
            isBanned = true
            self.leaveChannel()
        }
    }

    /// Disable the content inspector
    func stopContentInspect() {
        self.agoraEngine.enableContentInspect(false, config: self.inspectConfig)
    }

    override func joinChannel(
        _ channel: String, token: String? = nil,
        uid: UInt = 0, info: String? = nil
    ) {
        super.joinChannel(channel, token: token, uid: uid, info: info)
        self.setupContentInspect()
    }
    override func leaveChannel(leaveChannelBlock: ((AgoraChannelStats) -> Void)? = nil) {
        self.stopContentInspect()
        super.leaveChannel(leaveChannelBlock: leaveChannelBlock)
    }
}

struct ContentView: View {
    @ObservedObject var agoraManager = ContentInspectManager(
        appId: <#Agora App ID#>, role: .broadcaster
    )
    var channelId: String = "test"
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    ForEach(Array(agoraManager.allUsers), id: \.self) { uid in
                        AgoraVideoCanvasView(manager: agoraManager, uid: uid)
                            .aspectRatio(contentMode: .fit).cornerRadius(10)
                    }
                }.padding(20)
            }
            if !agoraManager.inspectLabel.isEmpty {
                VStack {
                    Text(agoraManager.inspectLabel)
                        .padding().background(.tertiary).cornerRadius(8)
                    Spacer()
                    Button {
                        agoraManager.agoraEngine.switchCamera()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath.camera")
                            .font(Font.headline).padding(4)
                    }.buttonStyle(BorderedProminentButtonStyle())
                }.padding()
            }
            if agoraManager.isBanned {
                Text("🚨 Content Violation 🚨")
                    .font(Font.headline).padding()
                    .background(.tertiary).cornerRadius(8)
            }
        }.onAppear { agoraManager.joinChannel(channelId, token: nil)
        }.onDisappear { agoraManager.leaveChannel() }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
