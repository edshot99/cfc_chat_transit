require "gwsockets"
require "cfclogger"

import lshift from bit
import GetColor from team
export ChatTransit = {}

RelayPort = file.Read "cfc/cfc_relay_port.txt", "DATA"
RelayPort = string.Replace RelayPort, "\r", ""
RelayPort = string.Replace RelayPort, "\n", ""

RelayPassword = file.Read "cfc/cfc_relay_password.txt", "DATA"
RelayPassword = string.Replace RelayPassword, "\r", ""
RelayPassword = string.Replace RelayPassword, "\n", ""

Realm = file.Read "cfc/realm.txt", "DATA"
Realm = string.Replace Realm, "\r", ""
Realm = string.Replace Realm, "\n", ""

ChatTransit.Logger = CFCLogger "CFC_ChatTransit"
ChatTransit.TeamColorCache = {}

hook.Add "PostEntityInit", "CFC_ChatTransit_WSInit", ->
    Logger = ChatTransit.Logger

    with ChatTransit.WebSocket = GWSockets.createWebSocket "ws://127.0.0.1#{RelayPort}"
        \setHeader "Authorization", "Bearer #{RelayPassword}"
        \onConnected -> Logger\info "Established websocket connection"
        \onDisconnected -> Logger\warn "Lost websocket connection!"
        \onError (message) -> Logger\error "Websocket Error!", message
        \open!


ChatTransit.GetTeamColorCode = (teamName) =>
    return @TeamColorCache[teamName] if @TeamColorCache[teamName]

    color = GetColor teamName
    r, g, b = color\Unpack!

    calculated = lshift(r, 16) + lshift(g, 8) + b
    @TeamColorCache[teamName] = calculated

    calculated

ChatTransit.ReceiveMessage = (ply, text, teamChat) =>
    return if teamChat
    return unless text
    return if text == ""

    teamName = ply\Team!
    rankColor = @GetTeamColorCode teamName
    avatar = ply.response.players[1].avatar
    steamName = ply\Nick!
    steamId = ply\SteamID64!
    irisId = "none"

    struct =
        Realm: Realm
        Content: text
        RankColor: rankColor
        Avatar: avatar
        SteamName: steamName
        SteamId: steamId
        IrisId: irisId

    message = TableToJSON struct

    @WebSocket\write message

hook.Add "PlayerSay", "CFC_ChatTransit_MessageListener", ChatTransit\ReceiveMessage, HOOK_MONITOR_LOW
