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


local bit = {
    badd = newcclosure(function(a, b)
        return a + b
    end),
    bsub = newcclosure(function(a, b)
        return a - b
    end),
    bmul = newcclosure(function(a, b)
        return a * b
    end),
    bdiv = newcclosure(function(a, b)
        return bit32.rshift(a, b)
    end),
    tobit = newcclosure(function(a)
        a = a % (2 ^ 32)
        if a >= 0x80000000 then
            a = a - (2 ^ 32)
        end
        return a
    end),
    bswap = newcclosure(function(a)
        a = a % (2 ^ 32)
        local b = bit32.band(a, 0xff)
        a = bit32.rshift(a, 8)
        local c = bit32.band(a, 0xff)
        a = bit32.rshift(a, 8)
        local d = bit32.band(a, 0xff)
        a = bit32.rshift(a, 8)
        return bit32.tobit(bit32.lshift(bit32.lshift(bit32.lshift(b, 8) + c, 8) + d, 8) + bit32.band(a, 0xff))
    end),
    ror = newcclosure(function(a, b)
        return bit32.tobit(bit32.rrotate(a % 2 ^ 32, b % 32))
    end),
    rol = newcclosure(function(a, b)
        return bit32.tobit(bit32.lrotate(a % 2 ^ 32, b % 32))
    end),
    tohex = newcclosure(function(num)
        local hex = string.format("%08x", bit32.tobit(num))
        return hex
    end),
}
for i, v in bit32 do
    bit[i] = v
end
getgenv().bit = bit
setreadonly(bit, true);

getgenv().getscriptfunction = getscriptclosure

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

local _saveinstance = nil
getgenv().saveinstance = newcclosure(function(options)
	options = options or {}
	assert(type(options) == "table", "invalid argument #1 to 'saveinstance' (table expected, got " .. type(options) .. ") ", 2)
	print("Saveinstance Powered by UniversalSynSaveInstance | AGPL-3.0 license")
	_saveinstance = _saveinstance or loadstring(game:HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau", true), "saveinstance")()
	return _saveinstance(options)
end)
getgenv().savegame = saveinstance

getgenv().__Disassemble = decompile
getgenv().__disassemble = decompile
loadstring(httpget("https://raw.githubusercontent.com/TjZero1425/maindll/refs/heads/main/drawing1.lua"))()
