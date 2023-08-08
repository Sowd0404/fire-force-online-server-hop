local httpService = game:GetService("HttpService")
local teleportService = game:GetService("TeleportService")
local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"

local current = nil
local response = httpService:JSONDecode(game:HttpGet(url))
local servers;

success, result = pcall(function()
    return readfile("servers.txt")
end)
if not success then writefile("servers.txt", "[]") end 
servers = httpService:JSONDecode(readfile("servers.txt"))

local function hopServers(recursive)
    table.insert(servers, game.JobId)
    if recursive then 
        response = httpService:JSONDecode(game:HttpGet(url .. "&cursor=" .. (response.nextPageCursor)))
    end

    for _, v in response.data do
        if not (v.playing < 6) then continue end
        if (not current or current.playing > v.playing) then
            current = v
        end
    end

    if not current or table.find(servers, current.id) then
        hopServers(true)
    end

    writefile("servers.txt", httpService:JSONEncode(servers))
    teleportService:TeleportToPlaceInstance(game.PlaceId, current.id)
end
return hopServers
