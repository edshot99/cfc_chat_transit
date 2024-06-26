import delay, guard from ChatTransit
import GetBySteamID from player
import SteamIDTo64 from util

ChatTransit.PlayerDisconnected = (data) =>
    :name, :reason, networkid: steamId = data

    ply = GetBySteamID steamId

    @Send
        Type: "disconnect"
        Data:
            SteamName: ply and ply\Nick! or name
            NetworkId: steamId
            SteamId: ply and ply\SteamID64! or SteamIDTo64 steamId
            PlayerCountCurrent: ChatTransit.playerCount
            PlayerCountMax: game\MaxPlayers!
            Content: reason

gameevent.Listen "player_disconnect"
hook.Add "player_disconnect", "CFC_ChatTransit_DisconnectListener", guard ChatTransit\PlayerDisconnected, 0
