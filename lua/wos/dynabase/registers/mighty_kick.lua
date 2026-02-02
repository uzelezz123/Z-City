wOS.DynaBase:RegisterSource({
    Name = "ZCity | Mighty Kicking animation",
    Type = WOS_DYNABASE.EXTENSION,

    -- model paths per gender:
    Shared = "models/akick/kick_anim_m.mdl",      -- default or neutral model
    Female = "models/akick/kick_anim_f.mdl",    -- female-specific model (optional)
    Male   = "models/akick/kick_anim_m.mdl"     -- optional if you have a male version
})

hook.Add("PreLoadAnimations", "wOS.DynaBase.MountMightyKick_anim", function(gender)
    if gender == WOS_DYNABASE.SHARED then
        IncludeModel("models/akick/kick_anim_m.mdl")
    elseif gender == WOS_DYNABASE.FEMALE then
        IncludeModel("models/akick/kick_anim_f.mdl")
    elseif gender == WOS_DYNABASE.MALE then
        IncludeModel("models/akick/kick_anim_m.mdl")
    end
end)
