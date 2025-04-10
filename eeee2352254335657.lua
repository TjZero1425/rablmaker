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

getgenv().getscriptclosure = nil

local localPlayer = cloneref(game:GetService("Players").LocalPlayer);
getgenv().isnetworkowner = newcclosure(function(part: BasePart): boolean
    local root = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart");
    if root == nil or (root.Position - part.Position).Magnitude > gethiddenproperty(localPlayer, "SimulationRadius") then
        return false;
    end
    if part:IsDescendantOf(localPlayer.Character) then
        return true;
    end
    local player, mag = nil, math.huge;
    for i, v in game:GetService("Players"):GetPlayers() do
        local vRoot = v.Character and v.Character:FindFirstChild("HumanoidRootPart");
        if vRoot then
            local vMag = (vRoot.Position - part.Position).Magnitude;
            if vMag < mag then
                player, mag = v, vMag;
            end
        end
    end
    return player == localPlayer;
end);

local ThreadLib = {}

function ThreadLib.getscriptfromthread(thread)
    return gettenv(thread).script
end 

local threads = {}
function ThreadLib.getallthreads()
    threads = {}
    for i, v in next, getreg() do
        if type(v) == "thread" then
            table.insert(threads, v)
        end
    end
    return threads
end
ThreadLib.getthreads = ThreadLib.getallthreads

local connectedThreads = {}
function ThreadLib.getscriptthreads(script)
    connectedThreads = {}
    for i, v in next, ThreadLib.getthreads() do
        if ThreadLib.getscriptfromthread(v) == script then
            table.insert(connectedThreads,v)
        end
    end
    return connectedThreads
end 

function ThreadLib.getfunctionthreads(func)
    local script = getfenv(func).script
    return ThreadLib.getscriptthreads(script)
end 

for i, v in next, ThreadLib do
    getfenv()[i] = v
end

local function register(i, v)
    getgenv()[i] = v
    return v
end

register('hookmetamethod', newcclosure(function(obj, method, func)
    assert(type(obj) == 'table' or typeof(obj) == 'Instance', 'Instance or userdata expected as argument #1')
    assert(type(method) == 'string', 'string expected as argument #2')
    assert(type(func) == 'function', 'function expected as argument #3')

    local mt = getrawmetatable(obj)
    assert(type(mt) == 'table', 'object given in argument #1 has no metatable/it is wrong')

    local funcfrom = rawget(mt, method)
    assert(type(funcfrom) == 'function', 'invalid method provided in argument #2')

    if (iscclosure(funcfrom) and not iscclosure(func)) then
        func = newcclosure(func)
    end

    local old
    old = hookfunction(funcfrom, func)

    return old
end))

getgenv().setsimulationradius = function(newRadius)
    assert(newRadius, `arg #1 is missing`)
    assert(type(newRadius) == "number", `arg #1 must be type number`)

    local LocalPlayer = cloneref(game:GetService("Players").LocalPlayer)
    if LocalPlayer then
        LocalPlayer.SimulationRadius = newRadius
        LocalPlayer.MaximumSimulationRadius = newRadius
    end
end

getgenv().getsimulationradius = function()
    assert(newRadius, `arg #1 is missing`)
    assert(type(newRadius) == "number", `arg #1 must be type number`)

    local LocalPlayer = cloneref(game:GetService("Players").LocalPlayer)
    if LocalPlayer then
        return LocalPlayer.SimulationRadius
    end
end

local oldreq = clonefunction(getrenv().require)
getgenv().require = newcclosure(function(v)
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
end)

getgenv().newlclosure = newcclosure(function(func)
	assert(type(func) == "function", "invalid argument #1 to 'newlclosure' (function expected, got " .. type(func) .. ") ", 2)
               local newfunc = clonefunction(func)
	return function(...)
		return newfunc(...)
	end
end)

 getgenv().getsenv = newcclosure(function(script_instance)
    for i, v in pairs(getreg()) do
       if type(v) == "function" then
          if getfenv(v).script == script_instance then
              return getfenv(v)
              end
           end
      end
 end)

do
    local CoreGui = cloneref(game:GetService('CoreGui'))
    local HttpService = cloneref(game:GetService('HttpService'))

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

local _saveinstance = nil
getgenv().saveinstance = newcclosure(function(options)
	options = options or {}
	assert(type(options) == "table", "invalid argument #1 to 'saveinstance' (table expected, got " .. type(options) .. ") ", 2)
	print("Saveinstance Powered by UniversalSynSaveInstance | AGPL-3.0 license")
	_saveinstance = _saveinstance or loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau", true), "saveinstance")()
	return _saveinstance(options)
end)
getgenv().savegame = saveinstance

--[[getgenv().getscriptclosure = newcclosure(function(scr) 
    local closure = _oldd(scr)

    if typeof(closure) == "function" then
        local scriptEnv = getfenv(closure)

        scriptEnv["script"] = scr

        return closure
    else
        return nil
    end
end)
]]

getgenv().getscriptfunction = getscriptclosure

getgenv().__Disassemble = decompile
getgenv().__disassemble = decompile
loadstring(httpget("https://raw.githubusercontent.com/TjZero1425/maindll/refs/heads/main/drawing1.lua"))()

local ScriptContextService = game:GetService("ScriptContext")
local ContentProvider = game:GetService("ContentProvider")
local CoreGuiService = game:GetService("CoreGui")


local SecurePrint = secureprint or print 
local GetActors = getactors or syn.getactors
local RunOnActor = run_on_actor or syn.run_on_actor

local OldPreloadAsync

for i,v in pairs(getconnections(ScriptContextService.Error)) do 
    v:Disable()
end

OldPreloadAsync = hookfunction(ContentProvider.PreloadAsync, function(self, ...)
    local args = {...}

    if not args[1] or typeof(args[1]) ~= "table" then 
        return OldPreloadAsync(self, ...)
    end

    local OriginalThreadIdentity = getthreadidentity()

    if(OriginalThreadIdentity~=4) then 
      setthreadidentity(4)
    end

    local TryingToAccessCoreGui = false 

    for i,v in pairs(args[1]) do 
      if typeof(v) == "Instance" and v == CoreGuiService then 
          TryingToAccessCoreGui = true --// ok dude 
        end
    end

    setthreadidentity(OriginalThreadIdentity)
    
    if TryingToAccessCoreGui == true then 
      local CallingScript = getcallingscript()
      SecurePrint("Game tried to access coregui ",CallingScript.Name)
       return {}
    end

    return OldPreloadAsync(self, ...)
end)

    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Dynamic!",
        Text = "Dynamic has been injected.",
        Duration = 3
    })
