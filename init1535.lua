if not game:IsLoaded() then game.Loaded:Wait() end

getgenv().consoleclear = function() end
getgenv().consolecreate = function() end
getgenv().consoledestroy = function() end
getgenv().consoleinput = function() end
getgenv().consoleprint = function() end
getgenv().consolesettitle = function() end
getgenv().rconsolename = function() end

getgenv().bit = {}

for i, v in next, bit32 do
bit[i] = v
end

bit.ror = bit.rrotate
bit.rol = bit.lrotate
bit.rrotate = nil
bit.lrotate = nil

bit.badd = function(a, b)
   return a + b
end

bit.bsub = function(a, b)
   return a - b
end

bit.bdiv = function(a, b)
   return a / b
end

bit.bmul = function(a, b)
   return a * b
end

bit.tobit = function(x)
  x = x % (2^32)
  if x >= 0x80000000 then x = x - (2^32) end
  return x
end

bit.tohex = function(x, n)
 n = n or 8
 local up
 if n <= 0 then
   if n == 0 then return '' end
   up = true
   n = - n
 end
 x = bit.band(x, 16^n-1)
 return ('%0'..n..(up and 'X' or 'x')):format(x)
end

bit.bswap = function(x)
 local a = bit.band(x, 0xff)
 x = bit.rshift(x, 8)
 local b = bit.band(x, 0xff)
 x = bit.rshift(x, 8)
 local c = bit.band(x, 0xff)
 x = bit.rshift(x, 8)
 local d = bit.band(x, 0xff)
 return bit.lshift(bit.lshift(bit.lshift(a, 8) + b, 8) + c, 8) + d
end

getgenv().setthreadidentity = function(identity: number): ()
    --_setidentity(identity)
    task.wait()
end

getgenv().setidentity = getgenv().setthreadidentity
getgenv().setthreadcontext = getgenv().setthreadidentity

do
    local CoreGui = game:GetService('CoreGui')
    local HttpService = game:GetService('HttpService')

    local comm_channels = CoreGui:FindFirstChild('comm_channels') or Instance.new('Folder', CoreGui)
    if comm_channels.Name ~= 'comm_channels' then
        comm_channels.Name = 'comm_channels'
    end
    getgenv().create_comm_channel = function() 
        local id = HttpService:GenerateGUID()
        local event = Instance.new('BindableEvent', comm_channels)
        event.Name = id
        return id, event
    end

    getgenv().get_comm_channel = function(id) 
        assert(type(id) == 'string', 'string expected as argument #1')
        return comm_channels:FindFirstChild(id)
    end
end

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
--loadstring(game:HttpGet("https://raw.githubusercontent.com/TjZero1425/maindll/refs/heads/main/drawing1.lua"))()
