//
//  ContentView.swift
//  Stossy11DIscord
//
//  Created by Stossy11 on 4/5/2024.
//


import Foundation
import SwiftUI
import KeychainSwift
import UniformTypeIdentifiers
import AVFoundation
import AVKit

// let user = DiscordREST()


/* struct SheetView: View {
    @AppStorage("ISOpened") var hasbeenopened = true
    @State private var token = ""
    private var isdisabled = true
    @Environment(\.dismiss) var dismiss
    var body: some View {
        Text("")
        Text("Welcome to StossyCord it is a custom Discord Client")
            .font(.title)
        // WebView(url: URL(string: "https://discord.com/login")!)
        Button("Continue") {
            let keychain = KeychainSwift()
            token = keychain.get("token") ?? ""
            if token == "" {
                // do nothing
            } else {
                hasbeenopened = false
                dismiss()
            }
        }
        .padding()
        // .disabled(true)
    }
}
*/


struct ContentView: View {
    @ObservedObject var webSocketClient: WebSocketClient
    @AppStorage("ISOpened") var hasbeenopened = true
    @State var guilds: [(name: String, id: String, icon: String?)] = []
    @State var user = ""
    @State var hasnitro = false
    @State var token = ""
    @State var username = ""
    @State var searchTerm = ""
    let keychain = KeychainSwift()

    var body: some View {
        let keychain = KeychainSwift()
        NavigationView {
            VStack {
                Text("")
                    .font(.title)
                    .onTapGesture {
                        hasbeenopened = true
                    }
                    .onAppear() {
                        // let keychain = KeychainSwift()
                        token = keychain.get("token") ?? ""
                        if token == "" {
                            hasbeenopened = true
                        }
                        webSocketClient.getcurrentchannel(input: "", guild: "")
                        webSocketClient.data = []
                        webSocketClient.messageIDs = []
                        webSocketClient.usernames = []
                        webSocketClient.disconnect()
                    }
                List {
                    ForEach(guilds.filter { guild in
                        searchTerm.isEmpty || guild.name.lowercased().contains(searchTerm.lowercased())
                    }, id: \.id) { guild in
                        NavigationLink {
                            // ChannelView(webSocketClient: webSocketClient, token: token)
                            ServerView(webSocketClient: webSocketClient, token: token, username: username, serverId: guild.id)
                        } label: {
                            HStack {
                                if guild.icon != nil {
                                    AsyncImage(url: URL(string: guild.icon!)) { image in
                                        image.resizable()
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                                // AsyncImage(url: URL(string: guild.icon!))
                                Text(guild.name)
                                    
                            }
                        }
                        .onAppear() {
                    
                            webSocketClient.getcurrentchannel(input: "", guild: "")
                        }
                        
                        /* Button(action: {
                         // print("Guild ID: \(guild.id)")
                         }) {
                         Text(guild.name)
                         }
                         */
                    }
                }.navigationTitle("Servers:")
                    .searchable(text: $searchTerm)
            }.onAppear {
                token = keychain.get("token") ?? ""
                if !token.isEmpty {
                    getDiscordUsername(token: token) { fetchedUsername, coolid  in
                        self.webSocketClient.currentusername = fetchedUsername
                        self.webSocketClient.currentuserid = coolid
                        self.user = coolid
                        self.username = self.webSocketClient.currentusername
                        print(self.username)
                    }
                    getDiscordGuilds(token: token) { fetchedGuilds in
                        self.guilds = fetchedGuilds
                    }
                }
                print("test: \(self.webSocketClient.currentuserid)")
            }
            .sheet(isPresented: $hasbeenopened) {
                LoginView()
            }
        }
        .navigationViewStyle(.stack)
    }
    public func SetGuilds() {
        token = keychain.get("token") ?? ""
        if !token.isEmpty {
            getDiscordGuilds(token: token) { fetchedGuilds in
                self.webSocketClient.guilds = fetchedGuilds
            }
        }
    }
}

struct NavView: View {
    @ObservedObject var webSocketClient: WebSocketClient
    @State var token = ""
    @State var username = ""
    let keychain = KeychainSwift()

    var body: some View {
        TabView {
            ContentView(webSocketClient: webSocketClient, token: token, username: username)
                .tabItem {
                    Label("Servers", systemImage: "house")
                }

            DMa(webSocketClient: webSocketClient, token: token, username: username)
                .tabItem {
                    Label("DM's", systemImage: "person")
                }
            SettingsView(webSocketClient: webSocketClient, token: $token)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .onAppear {
            token = keychain.get("token") ?? ""
            if let storedUsername = UserDefaults.standard.string(forKey: "username") {
                username = storedUsername
            }
        }
    }
}

func getDiscordUsername(token: String, completion: @escaping (String, String) -> Void) {
    let url = URL(string: "https://discord.com/api/v9/users/@me")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let username = json["username"] as? String, let id = json["id"] as? String {
                        completion(username, id)
                    }
                }
            } catch {
                // print("Error: \(error)")
            }
        }
    }

    task.resume()
}

func getDiscordisnitro(token: String, userid: String, completion: @escaping (Bool) -> Void) {
    let url = URL(string: "https://discord.com/api/v9/users/\(userid)")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
        } else if let data = data {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let premiumtype = json["premium_type"] as? String {
                        if premiumtype >= "0" {
                            completion(true)
                            print("test: ", premiumtype)
                        } else {
                            completion(false)
                            print("test: ", premiumtype)
                        }
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }

    task.resume()
}


struct ServerView: View {
    @ObservedObject var webSocketClient: WebSocketClient
    let token: String
    let username: String
    let serverId: String
    @State private var items: [Item] = []
    @State private var selectedChannelId: String?
    @State var vc = false
    var voiceWebSocketClient: VoiceWebSocketClient?

    var body: some View {
        VStack {
            List {
                ForEach(items) { item in
                    if item.type == 4 { // This is a heading
                        Text(item.name)
                            .font(.headline)
                            .padding(.top)
                    } else if item.type == 0 || item.type == 5 { // This is a channel
                        VStack {
                            NavigationLink {
                                ChannelView(channelid: item.id, webSocketClient: webSocketClient, token: token, guild: serverId, channelname: item.name, username: username)
                            } label: {
                                HStack {
                                    if let lastReadMessage = webSocketClient.lastReadMessageID[item.id], lastReadMessage.1 != item.lastMessageId {
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(.white)
                                    }
                                    Text("# " + item.name)
                                }
                            }
                        }
                    } else if item.type == 2 {
                        Button {
                            if vc {
                                if selectedChannelId == item.id {
                                    self.webSocketClient.disconnect()
                                    self.voiceWebSocketClient?.disconnect()
                                    selectedChannelId = nil
                                    vc = false
                                } else {
                                    self.webSocketClient.disconnect()
                                    self.voiceWebSocketClient?.disconnect()
                                    vc = true
                                    selectedChannelId = item.id
                                    self.webSocketClient.connectToVoiceChannel(guildID: serverId, channelID: item.id)
                                }
                            } else {
                                vc = true
                                selectedChannelId = item.id
                                self.webSocketClient.connectToVoiceChannel(guildID: serverId, channelID: item.id)
                            }
                        } label: {
                            HStack {
                                if vc && selectedChannelId == item.id {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.system(size: 16)) // Change the icon size here
                                        .foregroundColor(.blue) // Change the icon color here
                                    Text(item.name)
                                        .font(.system(size: 16)) // Change the font size here
                                        .foregroundColor(.blue) // Change the text color here
                                } else {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.system(size: 16)) // Change the icon size here
                                        .foregroundColor(.white) // Change the icon color here
                                    Text(item.name)
                                        .font(.system(size: 16)) // Change the font size here
                                        .foregroundColor(.white) // Change the text color here
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear() {
            webSocketClient.disconnect()
            self.webSocketClient.getTokenAndConnect()
            getDiscordChannels(serverId: serverId, token: token) { items in
                self.items = items
            }
        }
    }
    func getDiscordChannels(serverId: String, token: String, completion: @escaping ([Item]) -> Void) {
        guard let url = URL(string: "https://discord.com/api/v9/guilds/\(serverId)/channels?channel_limit=100") else {
            // print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
        request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
        request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
        request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // print("Error: \(error)")
            } else if let data = data {
                do {
                    // print("MAYO BEANS: aaaa\(String(data: data, encoding: .utf8) ?? ""))aaaa")
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        var items: [Item] = []
                        var currentHeading: String? = nil
                        for dict in jsonArray {
                            if let name = dict["name"] as? String, let type = dict["type"] as? Int, let id = dict["id"] as? String, let position = dict["position"] as? Int {
                                if type == 4 { // This is a category
                                    currentHeading = name
                                } else { // This is a channel
                                    let lastMessageId = webSocketClient.lastReadMessageID[id]?.1 ?? ""
                                    let item = Item(id: id, name: type == 0 ? name : name, heading: currentHeading, type: type, position: position, lastMessageId: lastMessageId)
                                    items.append(item)
                                }
                            }
                        }
                        // Sort the items first by type and then by position
                        items.sort { $0.type != $1.type ? $0.type < $1.type : $0.position < $1.position }
                        DispatchQueue.main.async {
                            completion(items)
                        }
                    }
                } catch {
                    // print("Error: \(error)")
                }
            }
        }

        task.resume()
    }

    struct Item: Identifiable {
        let id: String
        let name: String
        let heading: String?
        let type: Int
        let position: Int
        let lastMessageId: String
    }
}

struct DMa: View {
    @ObservedObject var webSocketClient: WebSocketClient
    let token: String
    let username: String
    @State private var items: [Item1] = []

    var body: some View {
        VStack {
            List(items) { item in
                NavigationLink {
                    ChannelView(channelid: item.id, webSocketClient: webSocketClient, token: token, guild: "", channelname: item.name, username: username)
                } label: {
                    Text(item.name)
                }
            }
        }
        .onAppear() {
            webSocketClient.getcurrentchannel(input: "", guild: "")
            webSocketClient.data = []
            webSocketClient.messageIDs = []
            webSocketClient.icons = []
            webSocketClient.icons = []
            webSocketClient.usernames = []
            webSocketClient.disconnect()
            getDiscordDMs(token: token) { items in
                self.items = items
            }
        }
    }
    func getDiscordDMs(token: String, completion: @escaping ([Item1]) -> Void) {
        guard let url = URL(string: "https://discord.com/api/v9/users/@me/channels") else {
            // print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
        request.addValue("keep-alive", forHTTPHeaderField: "Connection")
        request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
        request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
        request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
        request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
        request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
        request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
        request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
        request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // print("Error: \(error)")
            } else if let data = data {
                do {
                    if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                        var items: [Item1] = []
                        for dict in jsonArray {
                            if let id = dict["id"] as? String, let type = dict["type"] as? Int {
                                if type == 1, let recipients = dict["recipients"] as? [[String: Any]], let global_name = recipients.first?["global_name"] as? String, let username = recipients.first?["username"] as? String {
                                    var name = ""
                                    if global_name.isEmpty {
                                        name = "@ \(username)"
                                    } else {
                                        name = "@ \(global_name)"
                                    }
                                    let lastMessageId = dict["last_message_id"] as? String
                                    let item = Item1(id: id, name: name, heading: nil, position: Int(lastMessageId ?? "") ?? 0)
                                    items.append(item)
                                } else if type == 3 {
                                    let name = "Group DM"
                                    let lastMessageId = dict["last_message_id"] as? String
                                    let item = Item1(id: id, name: name, heading: nil, position: Int(lastMessageId ?? "") ?? 0)
                                    items.append(item)
                                }
                            }
                        }
                        // Sort the items based on the last message ID
                        items.sort { $0.position > $1.position }
                        DispatchQueue.main.async {
                            completion(items)
                        }
                    }

                } catch {
                    // print("Error: \(error)")
                }
            }
        }

        task.resume()
    }

    struct Item1: Identifiable {
        let id: String
        let name: String
        let heading: String?
        let position: Int
    }
}








// https://discord.com/api/v9/channels/1119174763651272786/messages?limit=50

func sendPostRequest(content: String, token: String, channel: String) {
    let url = URL(string: "https://discord.com/api/v9/channels/\(channel)/messages")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")


    // JSON Body
    let bodyObject: [String: Any] = ["content": content]
    request.httpBody = try? JSONSerialization.data(withJSONObject: bodyObject)

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            let str = String(data: data, encoding: .utf8)
            // print("Received data:\n\(str ?? "")")
        }
    }

    task.resume()
}

func getDiscordGuilds(token: String, completion: @escaping ([(name: String, id: String, icon: String?)]) -> Void) {
    let url = URL(string: "https://discord.com/api/v9/users/@me/guilds")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")
    // ... rest of your headers ...

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let guilds = jsonArray.compactMap { dict in
                        if let name = dict["name"] as? String, let id = dict["id"] as? String {
                            let icon = dict["icon"] as? String
                            let iconUrl = icon != nil ? "https://cdn.discordapp.com/icons/\(id)/\(icon!).png" : nil
                            return (name: name, id: id, icon: iconUrl)
                        }
                        return nil
                    }
                    completion(guilds)
                }
            } catch {
                // print("Error: \(error)")
            }
        }
    }

    task.resume()
}


func getDiscordGuildsold(token: String, completion: @escaping ([(name: String, id: String)]) -> Void) {
    let url = URL(string: "https://discord.com/api/users/@me/guilds")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let guilds = jsonArray.compactMap { dict in
                        if let name = dict["name"] as? String, let id = dict["id"] as? String {
                            return (name: name, id: id)
                        }
                        return nil
                    }
                    completion(guilds)
                }
            } catch {
                // print("Error: \(error)")
            }
        }
    }

    task.resume()
}

func sendPostRequest1(content: String, token: String, channel: String, messageReference: [String: String]?) {
    let url = URL(string: "https://discord.com/api/v9/channels/\(channel)/messages")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    // Headers
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    // JSON Body
    var bodyObject: [String: Any] = ["content": content]
    if let messageReference = messageReference {
        bodyObject["message_reference"] = messageReference
    }
    request.httpBody = try? JSONSerialization.data(withJSONObject: bodyObject)

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            let str = String(data: data, encoding: .utf8)
            // print("Received data:\n\(str ?? "")")
        }
    }

    task.resume()
}


func getDiscordGuilds1(token: String, completion: @escaping ([(name: String, id: String, icon: String?)]) -> Void) {
    let url = URL(string: "https://discord.com/api/v9/users/@me/guilds")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("https://discord.com/channels/949183273383395328/958116619706564668", forHTTPHeaderField: "Referer")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")
    // ... rest of your headers ...

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            // print("Error: \(error)")
        } else if let data = data {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                    let guilds = jsonArray.compactMap { dict in
                        if let name = dict["name"] as? String, let id = dict["id"] as? String {
                            let icon = dict["icon"] as? String
                            let iconUrl = icon != nil ? "https://cdn.discordapp.com/icons/\(id)/\(icon!).png" : nil
                            return (name: name, id: id, icon: iconUrl)
                        }
                        return nil
                    }
                    completion(guilds)
                }
            } catch {
                // print("Error: \(error)")
            }
        }
    }

    task.resume()
}

struct Message: Identifiable {
    let id: String
    let content: String
    let username: String
}

struct Guild: Decodable {
    let id: String
    let name: String
}



struct ChannelView: View {
    @AppStorage("ISOpened") var hasbeenopened = true
    @State private var image: URL?
    @State var text = ""
    // @State var token = ""
    @State var imageurl2 = ""
    @State var currentsearch = ""
    let channelid: String
    @State var selectedMessage: Message? = nil
    @ObservedObject var webSocketClient: WebSocketClient
    let keychain = KeychainSwift()
    let token: String
    let guild: String
    let channelname: String
    let username: String
    @State private var translation = ""
    @State var replyMessage: Message? = nil
    @State var reactionMessage: Message? = nil
    @State var editmessage: Message? = nil
    
    @State var oldtext = ""
    @State var isuploadingfile: Bool = false
    @State var file: URL? = nil
    @State var ispickedauto = false
    @State var editing = false
    @State var showEmojiPicker = false
    @State var previousMessageDate: Date? = nil
    @State var emojis: [Emoji] = []
    @State var importing = false
    @State var importingimages = false
    @State var reactons = false
    @State var showprompt: Bool? = nil
    let speechSynthesizer = AVSpeechSynthesizer()
    @State private var scrollTarget: CGFloat?

        var body: some View {
            VStack {
                ScrollView {
                    ForEach(webSocketClient.data, id: \.messageId) { messageData in
                        let timestamp = (Int(messageData.messageId)! >> 22 + 1420070400000) / 1000
                        let messageDate = Date(timeIntervalSince1970: TimeInterval(timestamp))
                        
                        // Check if the message is the first message of a new day
                        VStack {
                            if let previousDate = previousMessageDate, !Calendar.current.isDate(previousMessageDate!, inSameDayAs: messageDate) {
                                // If it is, add a section divider here
                                Divider()
                                    .padding(.vertical)
                                    .onAppear() {
                                        // print(previousDate)
                                    }
                            }
                            VStack {
                                HStack {
                                    AsyncImage(url: URL(string: messageData.icon)) { image in
                                        image.resizable()
                                            .frame(width: 40, height: 40)
                                            .clipShape(Circle())
                                            .onAppear() {
                                                previousMessageDate = messageDate
                                            }
                                            .contextMenu {
                                                // Show the message date when holding the message
                                                Text("Message Date: \(messageDate)")
                                                Button(action: {
                                                    self.selectedMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                }) {
                                                    Text("Delete")
                                                }
                                                Button(action: {
                                                    self.replyMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                }) {
                                                    Text("Reply")
                                                }
                                                Button(action: {
                                                    self.reactionMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                    self.reactons = true
                                                }) {
                                                    Text("React")
                                                }
                                                if messageData.userId == webSocketClient.currentuserid {
                                                    Button(action: {
                                                        self.editmessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                        self.editing = true
                                                        oldtext = text
                                                        self.text = messageData.message
                                                    }) {
                                                        Text("Edit")
                                                    }
                                                }
                                                Button(action: {
                                                    let utterance = AVSpeechUtterance(string: messageData.message)
                                                    speechSynthesizer.speak(utterance)
                                                    
                                                }) {
                                                    Text("Speak with TTS")
                                                }
                                            }
                                    } placeholder: {
                                        ProgressView()
                                            .onAppear() {
                                                previousMessageDate = messageDate
                                            }
                                    }
                                    VStack(alignment: .leading) {
                                        if let beansman = messageData.replyTo {
                                            HStack {
                                                (Text(Image(systemName: "arrow.turn.up.right")) + Text(beansman))
                                                    .font(.system(size: 10))
                                            }
                                        }
                                        Text("\(messageData.username)")
                                            .bold()
                                        HStack {
                                            MessageChannelView(token: token, message: messageData.message, curremtusername: webSocketClient.currentusername, username: messageData.username)
                                                .contextMenu {
                                                    // Show the message date when holding the message
                                                    Text("Message Date: \(messageDate)")
                                                    Button(action: {
                                                        self.selectedMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                    }) {
                                                        Text("Delete")
                                                    }
                                                    Button(action: {
                                                        self.replyMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                    }) {
                                                        Text("Reply")
                                                    }
                                                    Button(action: {
                                                        self.reactionMessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                        self.reactons = true
                                                    }) {
                                                        Text("React")
                                                    }
                                                    if messageData.userId == webSocketClient.currentuserid {
                                                        Button(action: {
                                                            self.editmessage = Message(id: messageData.messageId, content: messageData.message, username: messageData.username)
                                                            self.editing = true
                                                            oldtext = text
                                                            self.text = messageData.message
                                                        }) {
                                                            Text("Edit")
                                                        }
                                                    }
                                                    Button(action: {
                                                        let utterance = AVSpeechUtterance(string: messageData.message)
                                                        speechSynthesizer.speak(utterance)
                                                        
                                                    }) {
                                                        Text("Speak with TTS")
                                                    }
                                                }
                                        }
                                    }
                                }
                                if !messageData.attachment.isEmpty {
                                    MediaView(url: messageData.attachment)
                                }
                            }
                        }
                    }
                }
                if let replyMessage = replyMessage {
                    HStack {
                        Text("Replying to \(replyMessage.username):")
                            .font(.headline)
                        Text(replyMessage.content)
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            self.replyMessage = nil
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
                if let editmessage = editmessage, editing {
                    HStack {
                        Text("Editing:")
                            .font(.headline)
                        Text(editmessage.content)
                            .font(.subheadline)
                        Spacer()
                        Button(action: {
                            self.editmessage = nil
                            self.text = oldtext
                            self.oldtext = ""
                            self.editing = false
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                }
                if let showprompt = showprompt {
                    VStack {
                        Text("Upload Photo or Upload Video")
                            .font(.headline)
                        Divider()
                        HStack {
                            Button(action: {
                                self.showprompt = nil
                                self.importingimages = true
                            }) {
                                Text("Photo")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(width: 80, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            Button(action: {
                                self.showprompt = nil
                                self.importing = true
                            }) {
                                Text("Files")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(width: 80, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                            Button(action: {
                                self.showprompt = nil
                            }) {
                                Text("Cancel")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .frame(width: 80, height: 30)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
                if showEmojiPicker {
                    EmojiPicker(text: $text, pickauto: $ispickedauto, currentsearch: $currentsearch, emojis: emojis)
                        .padding(.horizontal)
                         .frame(width: 340, height: 45)
                         .background(Color.gray.opacity(0.2))
                         .cornerRadius(10)
                }
                if reactons {
                    reactionpicker(token: token, messageid: reactionMessage?.id ?? "", channelid: channelid, shown: $reactons, emojis: emojis)
                }
                if let file = file {
                    EmojiPicker2(image: self.$file)
                }
                HStack {
                    TextField("Message \(channelname)", text: $text)
                        .onChange(of: text) { newValue in
                            let patternDoubleColon = "^(.*\\S)?:(.*):\\s*(\\S*)$"
                            let patternSingleColon = "^(.*\\S)?:\\s*(\\S*)$"
                            let regexDoubleColon = try? NSRegularExpression(pattern: patternDoubleColon)
                            let regexSingleColon = try? NSRegularExpression(pattern: patternSingleColon)
                            
                            if let match = regexDoubleColon?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                                showEmojiPicker = false
                            } else if let match = regexSingleColon?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                                let range = Range(match.range(at: 2), in: text)!
                                let textAfterColon = String(text[range])
                                currentsearch = textAfterColon
                                showEmojiPicker = true
                                ispickedauto = false
                            } else {
                                showEmojiPicker = false
                                currentsearch = ""
                                ispickedauto = false
                            }
                            if newValue.count <= 1 {
                                typing(token: token, channel: channelid)
                            }
                        }
                        .padding(.horizontal)
                        .frame(width: 340, height: 45)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .onSubmit {
                            let patternDoubleColon = "^(.*\\S)?:(.*):\\s*(\\S*)$"
                            let regexDoubleColon = try? NSRegularExpression(pattern: patternDoubleColon)
                            
                            if let match = regexDoubleColon?.firstMatch(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count)) {
                                let range = Range(match.range(at: 2), in: text)!
                                let textBetweenColons = String(text[range])
                                currentsearch = textBetweenColons
                                ispickedauto = true
                                showEmojiPicker = false
                            }
                            
                            if let replyMessage = replyMessage {
                                if let file = file {
                                    if file.startAccessingSecurityScopedResource() {
                                        uploadFileToDiscord2(fileUrl: file, token: token, channelid: channelid, message: text, messageReference: ["message_id": replyMessage.id])
                                        file.stopAccessingSecurityScopedResource()
                                        self.file = nil
                                    } else {
                                        print("Failed to access the file")
                                    }
                                } else {
                                    sendPostRequest1(content: text, token: token, channel: channelid, messageReference: ["message_id": replyMessage.id])
                                }
                                self.replyMessage = nil
                            } else if editing {
                                if let editmessage = editmessage {
                                    editMessage(token: token, channelID: channelid, messageID: editmessage.id, newContent: text)
                                    self.editmessage = nil
                                    self.text = oldtext
                                    self.oldtext = ""
                                    self.editing = false
                                }
                            } else {
                                if let file = file {
                                    if file.startAccessingSecurityScopedResource() {
                                        uploadFileToDiscord2(fileUrl: file, token: token, channelid: channelid, message: text)
                                        file.stopAccessingSecurityScopedResource()
                                        self.file = nil
                                    } else {
                                        print("Failed to access the file")
                                    }
                                } else {
                                    sendPostRequest1(content: text, token: token, channel: channelid, messageReference: nil)
                                }
                            }
                            text = ""
                            ispickedauto = false
                            if showEmojiPicker {
                                showEmojiPicker.toggle()
                            }
                        }
                    Button {
                        if showprompt == true {
                            showprompt = nil
                        } else  {
                            showprompt = true
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                    .padding(.horizontal)
                     .frame(width: 45, height: 45)
                     .background(Color.gray.opacity(0.2))
                     .cornerRadius(45)
                    .onAppear() {
                        /* fetchEmojis(token: token, guildID: guild) { fetchedEmojis in
                         emojis = fetchedEmojis ?? []
                         }
                         */
                        if webSocketClient.hasnitro {
                            fetchAllEmojis(token: token) { fetchedEmojis in
                                if fetchedEmojis != nil {
                                    emojis = fetchedEmojis!
                                }
                            }
                        } else {
                            fetchEmojis(token: token, guildID: guild) { fetchedEmojis in
                                emojis = fetchedEmojis ?? []
                            }
                        }
                    }
                }
                
            }
            .fileImporter(
                isPresented: $importing,
                allowedContentTypes: [.image, .audio, .archive, .text, .video, .data]
            ) { result in
                switch result {
                case .success(let file):
                    print(file.absoluteString)
                    let fileManager = FileManager.default
                    if file.startAccessingSecurityScopedResource() {
                        if fileManager.fileExists(atPath: file.path) {
                            self.file = file
                            // uploadFileToDiscord2(fileUrl: file, token: token, channelid: channelid, message: text, messageReference: ["message_id": replyMessage.id])
                            } else {
                                print("File Doesnt Exist 1")
                            }
                        file.stopAccessingSecurityScopedResource()
                    } else {
                        print("Failed to access the file")
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .popover(isPresented: $importingimages, content: {
                VideoPicker(fileURL: $file, token: token, channelid: channelid, message: text)
            })
            .padding()
            .alert(item: $selectedMessage) { message in
                Alert(
                    title: Text("Delete Message"),
                    message: Text("Are you sure you want to delete this message?"),
                    primaryButton: .destructive(Text("Delete")) {
                        deleteDiscordMessage(token: token, serverID: "", channelID: channelid, messageID: message.id)
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear() {
                if webSocketClient.hasnitro {
                    fetchAllEmojis(token: token) { fetchedEmojis in
                        if fetchedEmojis != nil {
                            emojis = fetchedEmojis!
                        }
                    }
                } else {
                    fetchEmojis(token: token, guildID: guild) { fetchedEmojis in
                        emojis = fetchedEmojis ?? []
                    }
                }
                
                webSocketClient.messageIDs = []
                webSocketClient.icons = []
                webSocketClient.usernames = []
                webSocketClient.data = []
                webSocketClient.disconnect()
                getDiscordMessages(token: token, channelID: channelid, webSocketClient: webSocketClient)
                webSocketClient.getcurrentchannel(input: channelid, guild: guild)
                webSocketClient.getTokenAndConnect()
                
            }
        }
}


func editMessage(token: String, channelID: String, messageID: String, newContent: String) {
    let url = URL(string: "https://discord.com/api/v9/channels/\(channelID)/messages/\(messageID)")!
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")

    let body: [String: Any] = ["content": newContent]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let error = error {
            print("Error: \(error)")
        } else if let data = data {
            let str = String(data: data, encoding: .utf8)
            print("Received data:\n\(str ?? "")")
        }
    }

    task.resume()
}



struct EmojiPicker2: View {
    @Binding var image: URL?

    var body: some View {
        ScrollView {
            VStack {
                if let image = image {
                    Button {
                        self.image = nil
                    } label: {
                        Image(systemName: "x.square")
                    }
                    if image.startAccessingSecurityScopedResource() {
                        if isImage(url: image) {
                            AsyncImage(url: image) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fit)
                                case .failure:
                                    DownloadView(url: image)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else if isVideo(url: image) {
                            VideoPlayer(player: AVPlayer(url: image))
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 300, height: 200)
                        } else {
                            AsyncImage(url: image) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image.resizable().aspectRatio(contentMode: .fit)
                                case .failure:
                                    AsyncImage(url: image) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image.resizable().aspectRatio(contentMode: .fit)
                                        case .failure:
                                            DownloadView(url: image)
                                                .onAppear() {
                                                    print("is not Video")
                                                }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .onAppear() {
                                        print("is not image")
                                    }
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                        
                        Text("")
                            .onAppear() {
                                image.stopAccessingSecurityScopedResource()
                            }
                    }
                }
            }
        }
    }
    
    func isImage(url: URL) -> Bool {
        guard let uttype = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        return uttype.conforms(to: UTType.image)
    }

    func isVideo(url: URL) -> Bool {
        guard let uttype = UTType(filenameExtension: url.pathExtension) else {
            return false
        }
        return uttype.conforms(to: UTType.movie)
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat?
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = value ?? nextValue()
    }
}

func fetchAllEmojis(token: String, completion: @escaping ([Emoji]?) -> Void) {
    // First, fetch all guilds the bot is in
    let guildsUrl = URL(string: "https://discord.com/api/v9/users/@me/guilds")!
    var request = URLRequest(url: guildsUrl)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    
    let guildsTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let data = data {
            let decoder = JSONDecoder()
            if let guilds = try? decoder.decode([Guild].self, from: data) {
                // Then, fetch emojis for each guild
                for guild in guilds {
                    fetchEmojis(token: token, guildID: guild.id, completion: completion)
                }
            
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    guildsTask.resume()
}



func addReaction(token: String, channel: String, message: String, emojiId: String, emojiName: String) {
   let emoji = "\(emojiName):\(emojiId)"
   let urlString = "https://discord.com/api/v9/channels/\(channel)/messages/\(message)/reactions/\(emoji)/%40me"
   guard let url = URL(string: urlString) else {
       print("Invalid URL")
       return
   }

   var request = URLRequest(url: url)
   request.httpMethod = "PUT"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")

   let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
       if let error = error {
           print("Error: \(error)")
       } else if let response = response as? HTTPURLResponse {
           print("Status code: \(response.statusCode)")
       }
   }
   task.resume()
}

struct reactionpicker: View {
    let token: String
    let messageid: String
    let channelid: String
    @Binding var shown: Bool
    @State var currentsearch = ""
    var emojis: [Emoji] // Your Emoji model here

    var firstMatchingEmoji: Emoji? {
        emojis.first { emoji in
            currentsearch.isEmpty || emoji.name.lowercased().contains(currentsearch.lowercased())
        }
    }

    var body: some View {
        HStack {
            Spacer()
            Text("Reacting:")
                .font(.title)
            Spacer()
        }
        ScrollView {
            ForEach(emojis.filter { emoji in
                currentsearch.isEmpty || emoji.name.lowercased().contains(currentsearch.lowercased())
            }, id: \.id) { emoji in
                let imageUrl = "https://cdn.discordapp.com/emojis/\(emoji.id).png?size=96"
                Button {
                    addReaction(token: token, channel: channelid, message: messageid, emojiId: emoji.id, emojiName: emoji.name)
                    shown = false
                } label: {
                    HStack {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        Text(emoji.name)
                    }
                }
            }
        }
    }
}


struct EmojiPicker: View {
    @Binding var text: String
    @Binding var pickauto: Bool
    @Binding var currentsearch: String
    var emojis: [Emoji] // Your Emoji model here

    var firstMatchingEmoji: Emoji? {
        emojis.first { emoji in
            currentsearch.isEmpty || emoji.name.lowercased().contains(currentsearch.lowercased())
        }
    }

    var body: some View {
        ScrollView {
            ForEach(emojis.filter { emoji in
                currentsearch.isEmpty || emoji.name.lowercased().contains(currentsearch.lowercased())
            }, id: \.id) { emoji in
                let imageUrl = "https://cdn.discordapp.com/emojis/\(emoji.id).png?size=96"
                Button {
                    text = text.replacingOccurrences(of: ":\(currentsearch)", with: "")
                    text += "<:\(emoji.name):\(emoji.id)>"
                } label: {
                    HStack {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image.resizable()
                                .frame(width: 32, height: 32)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                        }
                        Text(emoji.name)
                    }
                }
                .onChange(of: pickauto, perform: { newValue in
                    if pickauto, let firstEmoji = firstMatchingEmoji, firstEmoji.id == emoji.id {
                        text = text.replacingOccurrences(of: ":\(currentsearch):", with: "")
                        text += "<:\(firstEmoji.name):\(firstEmoji.id)>"
                        pickauto = false
                    }
                })
            }
        }
    }
}


struct Emoji: Codable {
    let id: String
    let name: String
}

// https://discord.com/api/v9/users/@me/guilds

func retrieveAllEmojis(userToken: String, completion: @escaping ([Emoji]?) -> Void) {
    // First, fetch all guilds the bot is in
    let guildsUrl = URL(string: "https://discord.com/api/v9/users/@me/guilds")!
    var guildsRequest = URLRequest(url: guildsUrl)
    guildsRequest.addValue(userToken, forHTTPHeaderField: "Authorization")
    
    let guildsTask = URLSession.shared.dataTask(with: guildsRequest) { (data, response, error) in
        if let data = data {
            let decoder = JSONDecoder()
            if let guilds = try? decoder.decode([Guild].self, from: data) {
                // Then, fetch emojis for each guild
                for guild in guilds {
                    fetchEmojis(token: userToken, guildID: guild.id, completion: completion)
                }
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }
    
    guildsTask.resume()
}



func fetchEmojis(token: String, guildID: String, completion: @escaping ([Emoji]?) -> Void) {
    let url = URL(string: "https://discord.com/api/guilds/\(guildID)/emojis")!
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        if let data = data {
            let decoder = JSONDecoder()
            if let emojis = try? decoder.decode([Emoji].self, from: data) {
                completion(emojis)
            } else {
                completion(nil)
            }
        } else {
            completion(nil)
        }
    }

    task.resume()
}


struct MessageChannelView: View {
    let token: String
    let message: String
    let curremtusername: String
    let username: String
    var body: some View {
        //  let pattern = "<:(.*):(\\d*)>"
        let gifEmojiPattern = "<a:(.*):(\\d*)>"
        let userIdPattern = "<@(\\d*)>"
        let emojiPattern = "<:(.*):(\\d*)>"
        
        let userIdRegex = try? NSRegularExpression(pattern: userIdPattern)
        let emojiRegex = try? NSRegularExpression(pattern: emojiPattern)
        let animatedEmojiRegex = try? NSRegularExpression(pattern: gifEmojiPattern)
        
        let range = NSRange(location: 0, length: message.utf16.count)
        
        let userIdMatch = userIdRegex?.firstMatch(in: message, options: [], range: range)
        let emojiMatch = emojiRegex?.firstMatch(in: message, options: [], range: range)
        let animatedEmojiMatch = animatedEmojiRegex?.firstMatch(in: message, options: [], range: range)
        
        if userIdMatch == nil && emojiMatch == nil && animatedEmojiMatch == nil {
            Text(LocalizedStringKey(message))
            Spacer()
        } else {
            // Process user IDs
            if let match = userIdMatch {
                if let userIdRange = Range(match.range(at: 1), in: message) {
                    let userId = String(message[userIdRange])
                    if curremtusername == username {
                        Spacer()
                        MessageView(message: message, isEmoji: "userid", token: token)
                    } else {
                        MessageView(message: message, isEmoji: "userid", token: token)
                        Spacer()
                    }
                }
            }
            
            // Process static emojis
            if let match = emojiMatch {
                if let emojiRange = Range(match.range(at: 2), in: message) {
                    let emojiId = String(message[emojiRange])
                    if curremtusername == username {
                        Spacer()
                        MessageView(message: message, isEmoji: "yes", token: token)
                    } else {
                        MessageView(message: message, isEmoji: "yes", token: token)
                        Spacer()
                    }
                }
            }
            
            // Process animated emojis
            if let match = animatedEmojiMatch {
                if let animatedEmojiRange = Range(match.range(at: 2), in: message) {
                    let animatedEmojiId = String(message[animatedEmojiRange])
                    if curremtusername == username {
                        Spacer()
                        MessageView(message: message, isEmoji: "no", token: token)
                    } else {
                        MessageView(message: message, isEmoji: "no", token: token)
                        Spacer()
                    }
                }
            }
        }
    }
}




// https://discord.com/api/v9/channels/1119174763651272786/messages?limit=50


func getDiscordMessages(token: String, channelID: String, webSocketClient: WebSocketClient) {
    var MessageLimit: Int? = nil
    if #available(iOS 16, *) {
        MessageLimit = 50
    } else if #available(iOS 17, *)  {
        MessageLimit = 100
    } else {
        MessageLimit = 150
    }
    let url = URL(string: "https://discord.com/api/v9/channels/\(channelID)/messages?limit=\(MessageLimit ?? 25)")!
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")
    
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            // print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
                var uniqueMessages = Set<String>()
                for message in json {
                    if let content = message["content"] as? String,
                       let id = message["id"] as? String,
                       let user = message["author"] as? [String: Any],
                       let username = user["username"] as? String,
                       let avatar = user["avatar"] as? String {
                        DispatchQueue.main.async {
                            let avatarURL = "https://cdn.discordapp.com/avatars/\(user["id"] ?? "")/\(avatar).png"
                            
                            // Handle attachments
                            var attachmentURL = ""
                            if let attachments = message["attachments"] as? [[String: Any]] {
                                for attachment in attachments {
                                    if let url = attachment["url"] as? String {
                                        attachmentURL = url
                                    }
                                }
                            }
                            
                            var replyTo: String? = nil
                            
                            var messageData: MessageData
                            
                            let authorid = user["id"] as? String
                            if let member = message["member"] as? [String: Any],
                               let nickname = member["nick"] as? String {
                                messageData = MessageData(icon: avatarURL, message: "\(content)", attachment: attachmentURL, username: nickname, messageId: id, userId: authorid ?? "", replyTo: nil)
                            } else if let globalname = user["global_name"] as? String {
                                messageData = MessageData(icon: avatarURL, message: "\(content)", attachment: attachmentURL, username: globalname, messageId: id, userId: authorid ?? "", replyTo: nil)
                            } else {
                                messageData = MessageData(icon: avatarURL, message: "\(content)", attachment: attachmentURL, username: username, messageId: id, userId: authorid ?? "", replyTo: nil)
                            }
                            
                            if let messageReference = message["message_reference"] as? [String: Any],
                               let parentMessageId = messageReference["message_id"] as? String {
                                if let parentMessage = webSocketClient.data.first(where: { $0.messageId == parentMessageId }) {
                                    replyTo = "\(parentMessage.username): \(parentMessage.message)"
                                } else {
                                    replyTo = "Unable to load Message"
                                }
                            }
                            
                            messageData.replyTo = replyTo
                            webSocketClient.data.append(messageData)
                            uniqueMessages.insert(id)
                        }
                    }
                }
                
                // Sort the messages by their IDs (which are timestamps)
                DispatchQueue.main.async {
                    let sortedIndices = webSocketClient.data.indices.sorted { webSocketClient.data[$0].messageId < webSocketClient.data[$1].messageId }
                    webSocketClient.data = sortedIndices.map { webSocketClient.data[$0] }
                }
            }
        } catch {
            // print("Error parsing JSON: \(error)")
        }
    }
    
    task.resume()
}

func deleteDiscordMessage(token: String, serverID: String, channelID: String, messageID: String) {
    let url = URL(string: "https://discord.com/api/v9/channels/\(channelID)/messages/\(messageID)")!
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue(token, forHTTPHeaderField: "Authorization")
    request.addValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
    request.addValue("en-AU,en;q=0.9", forHTTPHeaderField: "Accept-Language")
    request.addValue("keep-alive", forHTTPHeaderField: "Connection")
    request.addValue("https://discord.com", forHTTPHeaderField: "Origin")
    request.addValue("empty", forHTTPHeaderField: "Sec-Fetch-Dest")
    request.addValue("cors", forHTTPHeaderField: "Sec-Fetch-Mode")
    request.addValue("same-origin", forHTTPHeaderField: "Sec-Fetch-Site")
    request.addValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Safari/605.1.15", forHTTPHeaderField: "User-Agent")
    request.addValue("bugReporterEnabled", forHTTPHeaderField: "X-Debug-Options")
    request.addValue("en-US", forHTTPHeaderField: "X-Discord-Locale")
    request.addValue("Australia/Sydney", forHTTPHeaderField: "X-Discord-Timezone")
    request.addValue("eyJvcyI6Ik1hYyBPUyBYIiwiYnJvd3NlciI6IlNhZmFyaSIsImRldmljZSI6IiIsInN5c3RlbV9sb2NhbGUiOiJlbi1BVSIsImJyb3dzZXJfdXNlcl9hZ2VudCI6Ik1vemlsbGEvNS4wIChNYWNpbnRvc2g7IEludGVsIE1hYyBPUyBYIDEwXzE1XzcpIEFwcGxlV2ViS2l0LzYwNS4xLjE1IChLSFRNTCwgbGlrZSBHZWNrbykgVmVyc2lvbi8xNy40IFNhZmFyaS82MDUuMS4xNSIsImJyb3dzZXJfdmVyc2lvbiI6IjE3LjQiLCJvc192ZXJzaW9uIjoiMTAuMTUuNyIsInJlZmVycmVyIjoiIiwicmVmZXJyaW5nX2RvbWFpbiI6IiIsInJlZmVycmVyX2N1cnJlbnQiOiIiLCJyZWZlcnJpbmdfZG9tYWluX2N1cnJlbnQiOiIiLCJyZWxlYXNlX2NoYW5uZWwiOiJzdGFibGUiLCJjbGllbnRfYnVpbGRfbnVtYmVyIjoyOTE1MDcsImNsaWVudF9ldmVudF9zb3VyY2UiOm51bGwsImRlc2lnbl9pZCI6MH0=", forHTTPHeaderField: "X-Super-Properties")

    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            // print(error?.localizedDescription ?? "No data")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
        if let responseJSON = responseJSON as? [String: Any] {
            // print(responseJSON)
        }
    }

    task.resume()
}
