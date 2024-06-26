import delay, guard from ChatTransit
import SteamIDTo64 from util
-- TODO: Send a preliminary avatarservice link that will be backfilled when they fully connect

ChatTransit.PlayerConnect = (data) =>
    :bot, :name, networkid: steamId = data

    bot = tobool bot
    steamId = nil if bot

    @Send
        Type: "connect"
        Data:
            SteamName: name
            NetworkId: steamId
            SteamId: steamId and SteamIDTo64 steamId
            PlayerCountCurrent: ChatTransit.playerCount
            PlayerCountMax: game\MaxPlayers!

ChatTransit.PlayerInitialSpawn = (ply) =>
    @Send
        Type: "spawn"
        Data:
            SteamName: ply\Nick!
            NetworkId: ply\SteamID!
            SteamId: ply\SteamID64!

gameevent.Listen "player_connect"
hook.Add "player_connect", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerConnect, 0
hook.Add "PlayerInitialSpawn", "CFC_ChatTransit_SpawnListener", guard ChatTransit\PlayerInitialSpawn
