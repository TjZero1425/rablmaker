if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().consoleclear = function() end
getgenv().consolecreate = function() end
getgenv().consoledestroy = function() end
getgenv().consoleinput = function() end
getgenv().consoleprint = function() end
getgenv().consolesettitle = function() end
getgenv().rconsolename = function() end
getgenv().getactors = function()
    local actors = {};
    for i, v in game:GetDescendants() do
        if v:IsA("Actor") then
            table.insert(actors, v);
        end
    end
    return actors;
end;

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

getgenv().hookmetamethod = function(obj, method, rep)
    local mt = getrawmetatable(obj)
    local old = mt[method]
    
    setreadonly(mt, false)
    mt[method] = rep
    setreadonly(mt, true)
    
    return old
end

local oldreq = clonefunction(getrenv().require)
getgenv().require = function(v)
    local oldlevel = getthreadcontext()
    local succ, res = pcall(oldreq, v)
    if not succ and res:find('RobloxScript') then
        succ = nil
        coroutine.resume(coroutine.create(newcclosure(function()
            setthreadcontext((oldlevel > 5 and 2) or 8)
            succ, res = pcall(oldreq, v)
        end)))
        repeat task.wait() until succ ~= nil
    end
    
    setthreadcontext(oldlevel)
    
    if succ then
        return res
    end
end
loadstring(game:HttpGet("https://raw.githubusercontent.com/TjZero1425/maindll/refs/heads/main/drawing1.lua"))()

setreadonly(string, false)

local original_find = string.find
string.find = function(str, pattern, ...)
    return original_find(tostring(str), pattern, ...)
end

setreadonly(string, true)
