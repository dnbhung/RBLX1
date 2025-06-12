local knitMod = require(game:GetService("ReplicatedStorage").Packages.Knit)
local BiBFSService = knitMod.CreateService {
    Name = "BiBFSService",
    Client={}
}

function BiBFSService:init()
    local BiBFS = require(script.Parent.BiBFSUtil)
    local search = BiBFS.new()
    return search
end

return BiBFSService