--SOMEWHERE IN PLUVTOWN...

hg.PluvTown = hg.PluvTown or {}
hg.PluvTown.Hooks = hg.PluvTown.Hooks or {}
hg.PluvTown.Active = false

local PLUGIN = hg.PluvTown

CreateConVar("zb_pluvtown", 0, {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "Toggle pluvtown mode :3", 0, 1)

if SERVER then
    cvars.AddChangeCallback("zb_pluvtown", function(name, old, new)
        PLUGIN.UpdateStatus()

        net.Start("UpdatePluvTownStatus")
        net.Broadcast()
    end)

    util.AddNetworkString("UpdatePluvTownStatus")
else
    net.Receive("UpdatePluvTownStatus", function()
        PLUGIN.UpdateStatus()
    end)
end

hook.Add("InitPostEntity", "PluvTown", function()
    PLUGIN.UpdateStatus()
end)

function PLUGIN.UpdateStatus()
    local value = GetConVar("zb_pluvtown"):GetBool()

    if value then
        PLUGIN.InitHooks()
        hg.PluvTown.Active = true
    else
        PLUGIN.DeInitHooks()
        hg.PluvTown.Active = false
    end
end

function PLUGIN.InitHooks()
    for k, v in pairs(PLUGIN.Hooks) do
        hook.Add(k, "PLUVTOWN HOOK " .. k, v)
    end
end

function PLUGIN.DeInitHooks()
    for k, _ in pairs(PLUGIN.Hooks) do
        hook.Remove(k, "PLUVTOWN HOOK " .. k)
    end
end

function PLUGIN.AddHook(name, func)
    PLUGIN.Hooks[name] = func
end

function PLUGIN.RemoveHook(name)
    hook.Remove(name, "PLUVTOWN HOOK " .. name)
end

hg.PluvTown.PluvMats = {
    ["pluv"] = Material("pluv/pluv.png"),
    ["pluvboss"] = Material("pluv/pluvboss.png"),
    ["pluvnerd"] = Material("pluv/pluvnerd.png"),
    ["pluvfancy"] = Material("pluv/pluvfancy.jpg"),
    ["pluvmad"] = Material("pluv/pluvmad.png"),
    ["pluvsad"] = Material("pluv/pluvsad.png"),
    ["pluv51"] = Material("pluv/pluv51.png"),
    ["pluvmajima"] = Material("pluv/pluvmajima.jpg"),
    ["pluvdobro"] = Material("pluv/pluvdobro.png"),
    ["pluvberet"] = Material("pluv/pluvberet.png"),
    ["pluvicible"] = Material("pluv/pluvicible.jpg"),
    ["pluvortego"] = Material("pluv/pluvortego.jpg"),
    ["pluvyakuza"] = Material("pluv/pluvyakuza.jpg"),
    ["pluvgreen"] = Material("pluv/pluvgreen.png"),
    ["pluvred"] = Material("pluv/pluvred.png"),
}

hg.PluvTown.PluvLayers = {
    ["dead"] = Material("pluv/pluvdead.png"),
    ["cry"] = Material("pluv/pluvcry.png")
}

hg.PluvTown.PluvMadness = Material("pluv/pluvmadness.png")

-- for _, v in player.Iterator() do
--     v:SetNetVar("CurPluv", "pluvnerd")
-- end