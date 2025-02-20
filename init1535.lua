if not game:IsLoaded() then game.Loaded:Wait() end
getgenv().consoleclear = function() end
getgenv().consolecreate = function() end
getgenv().consoledestroy = function() end
getgenv().consoleinput = function() end
getgenv().consoleprint = function() end
getgenv().consolesettitle = function() end
getgenv().rconsolename = function() end

setreadonly(getgenv().debug,false)
getgenv().debug.traceback = getrenv().debug.traceback
getgenv().debug.profilebegin = getrenv().debug.profilebegin
getgenv().debug.profileend = getrenv().debug.profileend
getgenv().debug.getmetatable = getgenv().getrawmetatable
getgenv().debug.setmetatable = getgenv().setrawmetatable
getgenv().debug.info = getrenv().debug.info

getgenv().isnetworkowner = function(part: BasePart): boolean
    return part.ReceiveAge == 0 and not part.Anchored and part.Velocity.Magnitude > 0
end

getgenv().setsimulationradius = function(newRadius)
    assert(newRadius, `arg #1 is missing`)
    assert(type(newRadius) == "number", `arg #1 must be type number`)

    local LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer then
        LocalPlayer.SimulationRadius = newRadius
        LocalPlayer.MaximumSimulationRadius = newRadius
    end
end

getgenv().getsimulationradius = function()
    assert(newRadius, `arg #1 is missing`)
    assert(type(newRadius) == "number", `arg #1 must be type number`)

    local LocalPlayer = game:GetService("Players").LocalPlayer
    if LocalPlayer then
        return LocalPlayer.SimulationRadius
    end
end

getgenv().http = {}
getgenv().http.request = request
setreadonly(http, true)

getgenv().http_request = request
getgenv().getscriptfunction = getscriptclosure
do
    local CoreGui = game:GetService('CoreGui')
    local HttpService = game:GetService('HttpService')

    local comm_channels = CoreGui:FindFirstChild('comm_channels') or Instance.new('Folder', CoreGui)
    if comm_channels.Name ~= 'comm_channels' then
        comm_channels.Name = 'comm_channels'
    end
    getgenv().create_comm_channel = newcclosure(function() 
        local id = HttpService:GenerateGUID()
        local event = Instance.new('BindableEvent', comm_channels)
        event.Name = id
        return id, event
    end)

    getgenv().get_comm_channel = newcclosure(function(id) 
        assert(type(id) == 'string', 'string expected as argument #1')
        return comm_channels:FindFirstChild(id)
    end)
end

getgenv().hookmetamethod = function(obj, method, rep)
    local mt = getrawmetatable(obj)
    local old = mt[method]
    
    setreadonly(mt, false)
    mt[method] = rep
    setreadonly(mt, true)
    
    return old
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/TjZero1425/maindll/refs/heads/main/drawing1.lua"))()

setreadonly(string, false)

local original_find = string.find
string.find = function(str, pattern, ...)
    return original_find(tostring(str), pattern, ...)
end

setreadonly(string, true)
