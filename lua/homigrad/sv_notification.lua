util.AddNetworkString("HGNotificate")
util.AddNetworkString("HGNotificateBerserk")

--local hg_old_notificate = ConVarExists("hg_old_notificate") and GetConVar("hg_old_notificate") or CreateConVar("hg_old_notificate",0,FCVAR_SERVER_CAN_EXECUTE,"enable old notifications (chatprints)",0,1)
local hev_color = Color(255, 125, 0)

local function ValidateNotification(ply, clr, msg)
    if msg == "" then return false end
    if not IsValid(ply) or not ply:IsPlayer() then error("player is not valid!") return false end
    
    if !ply.organism then return false end
    if ply.organism.otrub then return false end
    if ply.PlayerClassName and ply.PlayerClassName == "Gordon" and clr != hev_color then return false end
    if not msg or not isstring(msg) then error("no message or message is invalid!") return false end

    return true
end

local function TotalNotification(ply, msgKey, clr, clr2, msg, berserk, func)
    if !IsValid(ply) then return end
    if !ply.msgs[msgKey] then return end

    if (ply.organism and ply.organism.otrub) or !ply:Alive() then
        return
    end

    if ply.organism and ply.organism.pain > 60 and (!clr or clr.g > 250) then
        return
    end

    if berserk and func and isfunction(func) then
        if func(ply) then
            return
        end
    end

    local netmessage = (berserk and "HGNotificateBerserk") or "HGNotificate"
    net.Start(netmessage)
        net.WriteString(msg)
        net.WriteColor(clr2)
    net.Send(ply)
end

local function CreateNotification(ply, msg, delay, msgKey, showTime, func, clr)
    if not ValidateNotification(ply, clr, msg) then return false end
    
    msgKey = msgKey or msg
    ply.msgs = ply.msgs or {}
    
    if msgKey and ply.msgs[msgKey] then
        if isnumber(ply.msgs[msgKey]) then
            if ply.msgs[msgKey] > CurTime() then
                return false
            end
        else
            return false
        end
    end

    delay = delay or 0

    if msgKey then ply.msgs[msgKey] = delay and (not isnumber(delay) or CurTime() + delay) or nil end
    
    --показывать один раз за промежуток времени
    --(если delay не номерок то оно пинганет в следующей жизни)

    if ply.organism.brain > 0.1 then
        for i = 1, utf8.len(msg) do
            if math.random(3) == 1 and msg[i] != "?" and msg[i] != "." then
                msg = hg.replace_by_index(msg, i, (math.random(1,2) > 1 and "m" or "b") )
            end
        end
    end
    
    showTime = showTime or 0

    local clr = clr or color_white
    local clr2 = Color(clr.r, clr.g, clr.b, 255)

    timer.Simple(showTime, function()
        TotalNotification(ply, msgKey, clr, clr2, msg, false, nil) -- Функция nil, так как берсерк выключен, и она исполняется только когда он true.
    end)

    return true
end

local function CreateNotificationBerserk(ply, msg, delay, msgKey, showTime, func, clr)
    if not ValidateNotification(ply, clr, msg) then return false end
    
    msgKey = msgKey or msg
    ply.msgs = ply.msgs or {}
    
    if msgKey and ply.msgs[msgKey] then
        if isnumber(ply.msgs[msgKey]) then
            if ply.msgs[msgKey] > CurTime() then
                return false
            end
        else
            return false
        end
    end

    delay = delay or 0
    if msgKey then ply.msgs[msgKey] = delay and (not isnumber(delay) or CurTime() + delay) or nil end
    --показывать один раз за промежуток времени
    --(если delay не номерок то оно пинганет в следующей жизни)
    if func and isfunction(func) then
        func(ply)
    end

    if ply.organism.brain > 0.1 then
        for i = 1, utf8.len(msg) do
            if math.random(3) == 1 and msg[i] != "?" and msg[i] != "." then
                msg = hg.replace_by_index(msg, i, (math.random(1,2) > 1 and "m" or "b") )
            end
        end
    end
    
    showTime = showTime or 0

    local clr = clr or color_white
    local clr2 = Color(clr.r, clr.g, clr.b, 255)
    timer.Simple(showTime, function()
        TotalNotification(ply, msgKey, clr, clr2, msg, true, func)
    end)

    return true
end

local function ResetNotification(ply, key)
    if not ply.msgs or not ply.msgs[key] then return end
    ply.msgs[key] = nil
end

hg.CreateNotification = CreateNotification

hook.Add("Player Spawn","removeNotifications",function(ply)
    ply.msgs = {}
end)

hook.Add("HG_OnOtrub","removeNotifications",function(ply)
    ply.msgs = {}
end)

hook.Add("Player_Death","removeNotifications",function(ply)
    ply.msgs = {}
end)

local PLAYER = FindMetaTable("Player")

function PLAYER:Notify(...)
    return CreateNotification(self, ...)
end

function PLAYER:NotifyBerserk(...)
    return CreateNotificationBerserk(self, ...)
end

function PLAYER:ResetNotification(key)
    ResetNotification(self,key)
end
