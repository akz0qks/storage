--[[
    SpideyAuth: Hardened Edition
    Architecture inspired by Luarmor Client 3.4
    Status: Protected by Stack Guard & Environment Proxy
]]

do
    -- // Constants (Replicated from Luarmor Seeds)
    local CHARSET = "qwertyuiopasdfghjklzxcvbnm098765"
    local TUTORIAL_KEY = "nil  nil  "
    local _os_clock = os.clock
    local _wait = task.wait or wait
    local _tonumber = tonumber
    local _tostring = tostring
    local _pcall = pcall
    local _print = print
    local _loadstring = loadstring
    local _ident = identifyexecutor
    local _http = game.HttpGet
    local HttpService = game:GetService("HttpService")
    
    -- // Bitwise Configuration (Mocked v96 style)
    local BITS = {["a"]=0,["b"]=1,["Q"]=2,["k"]=3,["O"]=4,["I"]=5,["1"]=6,["l"]=7,["0"]=8,["9"]=9,["E"]=10,["3"]=11,["J"]=12,["7"]=13,["G"]=14,["T"]=15}
    local R_BITS = {"a","b","Q","k","O","I","1","l","0","9","E","3","J","7","G","T"}

    -- // Encoding Engine (v96 / v97 Replication)
    local function encode(str)
        local out = ""
        for i = 1, #str do
            local b = string.byte(str, i)
            local low = b % 16
            local high = (b - low) / 16
            out = out .. R_BITS[high + 1] .. R_BITS[low + 1]
        end
        return out
    end

    local function decode(str)
        local out = ""
        for i = 1, #str, 2 do
            local high = BITS[str:sub(i, i)]
            local low = BITS[str:sub(i + 1, i + 1)]
            out = out .. string.char(high * 16 + low)
        end
        return out
    end

    -- // Local Environment Sandbox
    local env = setmetatable({}, {__index = getfenv()})
    setfenv(1, env)

    -- // Advanced Executor Detection Map (Replicated from Luauth)
    local function getExecutorID()
        local name = _ident and ({_ident()})[1] or "Unknown"
        local id = 0
        if name == "Synapse X" then id = 1
        elseif name == "ScriptWare" then 
            id = ({_ident()})[2] == "Mac" and 5 or 2
        elseif KRNL_LOADED then id = 3
        elseif FLUXUS_LOADED then id = 4
        elseif name == "Sirhurt" then id = 7
        end
        return id, name
    end

    -- // Fingerprinting Engine (v0 Logic)
    local function generateHWID()
        local usersettings = UserSettings():GetService("UserGameSettings")
        local id = ""
        
        if not usersettings:GetTutorialState(TUTORIAL_KEY) then
            local seed = math.floor(_os_clock() * 1000000)
            usersettings:SetTutorialState(TUTORIAL_KEY, true)
            math.randomseed(seed)
            for i = 0, 15 do
                local val = 0
                for bit = 0, 4 do
                    local bitVal = math.random(0, 1)
                    usersettings:SetTutorialState(TUTORIAL_KEY .. (i * 5 + bit), bitVal == 1)
                    val = val + bitVal * (2 ^ bit)
                end
                id = id .. CHARSET:sub(val + 1, val + 1)
            end
        else
            for i = 0, 15 do
                local val = 0
                for bit = 0, 4 do
                    local bitVal = usersettings:GetTutorialState(TUTORIAL_KEY .. (i * 5 + bit)) and 1 or 0
                    val = val + bitVal * (2^bit)
                end
                id = id .. CHARSET:sub(val + 1, val + 1)
            end
        end
        return id
    end

    -- // Stack Guard (Traceback Check)
    local function validateCallStack()
        local trace = debug.traceback()
        -- Ensure that the call didn't come from a known Hook or Dumper address
        if trace:find("hookfunction") or trace:find("spy") then
            return false
        end
        return true
    end

    -- // Security Module
    local function securityAudit(obj)
        local function isHooked(func)
            local info = debug.getinfo(func)
            return info.what ~= "C" or info.source ~= "=[C]"
        end

        if isHooked(_loadstring) or isHooked(_print) or isHooked(_http) then
            game.Players.LocalPlayer:Kick("Security Threat Detected [0xSEC-TMPR]")
            _wait(1)
            while true do end
        end
        
        if not validateCallStack() then
            game.Players.LocalPlayer:Kick("Security Threat Detected [0xSEC-STCK]")
        end
    end

    -- // Payload Configuration (Encoded to mimic Pro feel)
    local config = {
        script_name = "SpideyAuth",
        anti_tamper = true,
        -- These would normally be pre-encoded in your script
        github = encode("https://raw.githubusercontent.com/akz0qks/storage/refs/heads/main/whitelist.json"),
        discord = encode("https://discord.com/api/webhooks/1494130143633871028/srD4PwA2h3jX-ZoPBsEQCDMqw9i_Q8i1eSBKtIdhe9E1wX6yJg5JFf47Y_3MI_aZbxxC")
    }

    -- // Cloud Heartbeat Loop
    local function spawnHeartbeat(hwid)
        task.spawn(function()
            while _wait(60) do
                local success, res = _pcall(function()
                    return _http(game, decode(config.github))
                end)
                if success then
                    local authed = false
                    _pcall(function()
                        local list = HttpService:JSONDecode(res)
                        for _, id in pairs(list) do
                            if id == hwid or tostring(id) == tostring(game.Players.LocalPlayer.UserId) then
                                authed = true
                                break
                            end
                        end
                    end)
                    if not authed then
                        game.Players.LocalPlayer:Kick("Heartbeat Failure: License Suspended.")
                    end
                end
            end
        end)
    end

    -- // Obfuscated Kick Logic (v134 Replicated)
    local function fakeKick(title, reason)
        local kickScript = [[
            local t, r = ...
            spawn(function()
                while wait() do
                    pcall(function()
                        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt.TitleFrame.ErrorTitle.Text = t
                        game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ErrorPrompt.MessageArea.ErrorFrame.ErrorMessage.Text = r
                    end)
                end
            end)
            game:GetService("Players").LocalPlayer:Kick(r)
        ]]
        _pcall(_loadstring(kickScript), title, reason)
    end

    -- // Cloud Logger (Discord)
    local function logAuth(hwid, status, execName, key)
        local data = {
            ["embeds"] = {{
                ["title"] = "SpideyAuth Logs",
                ["color"] = status == "Verified" and 0x00FF00 or 0xFF0000,
                ["fields"] = {
                    {["name"] = "User", ["value"] = game.Players.LocalPlayer.Name, ["inline"] = true},
                    {["name"] = "HWID", ["value"] = hwid, ["inline"] = true},
                    {["name"] = "Status", ["value"] = status, ["inline"] = true},
                    {["name"] = "Executor", ["value"] = execName, ["inline"] = true},
                    {["name"] = "Key Used", ["value"] = key or "None", ["inline"] = false}
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }}
        }
        local success, err = _pcall(function()
            HttpService:PostAsync(decode(config.discord), HttpService:JSONEncode(data))
        end)
        if not success then
            warn("[SpideyAuth]: Webhook Log Error: " .. tostring(err))
        end
    end

    -- // Entry Point
    local function initialize()
        securityAudit()
        local hwid = generateHWID()
        local exeID, exeName = getExecutorID()
        
        print("[" .. config.script_name .. "]: Current HWID: " .. hwid)
        print("[" .. config.script_name .. "]: Connecting to secure channel...")
        
        local success, res = _pcall(function()
            return _http(game, decode(config.github))
        end)
        
        if not success then
            fakeKick("Connection Error", "Failed to reach authentication server.")
            return
        end

        local authed = false
        _pcall(function()
            local list = HttpService:JSONDecode(res)
            for _, id in pairs(list) do
                if id == hwid or tostring(id) == tostring(game.Players.LocalPlayer.UserId) then
                    authed = true
                    break
                end
            end
        end)

        if authed then
            print("[" .. config.script_name .. "]: Authenticated! HWID: " .. hwid)
            logAuth(hwid, "Verified", exeName, _G.script_key)
            spawnHeartbeat(hwid)
            
            -- EXECUTION POINT
            loadstring(game:HttpGet("https://raw.githubusercontent.com/edgeiy/infiniteyield/master/source"))()
        else
            logAuth(hwid, "Blacklisted/Unknown", exeName, _G.script_key)
            fakeKick("Whitelist Error", "You are not whitelisted for this script.")
        end
    end

    initialize()
end
