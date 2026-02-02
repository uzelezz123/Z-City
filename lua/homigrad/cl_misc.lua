RunConsoleCommand("mat_bloomscale", "0")
RunConsoleCommand("cl_resend", "3.5")
RunConsoleCommand("ragdoll_sleepaftertime", "12.0f")
RunConsoleCommand("cl_timeout", "99999")
RunConsoleCommand("cl_showhints", "0")
RunConsoleCommand("cl_interp", "0.04")
RunConsoleCommand("r_radiosity", "4")
RunConsoleCommand("r_flashlightdepthres", "1024")
RunConsoleCommand("r_shadow_allowdynamic", "1")
RunConsoleCommand("r_shadow_allowbelow", "1")
RunConsoleCommand("tanktracktool_autotracks_detail_max", "2")
RunConsoleCommand("r_threaded_particles", "0")
RunConsoleCommand("advdupe2_limit_ghost", "24")
RunConsoleCommand("rate", "1048576")
RunConsoleCommand("net_compresspackets", "1")
RunConsoleCommand("net_maxcleartime", "4")
RunConsoleCommand("vfire_light_brightness", "0.1")
RunConsoleCommand("cl_new_impact_effects", "0")
RunConsoleCommand("async_simulate_delay", "0")
RunConsoleCommand("mat_motion_blur_enabled", "0")
RunConsoleCommand("r_fastzreject", "1")

RunConsoleCommand("filesystem_max_stdio_read", "16")
RunConsoleCommand("net_splitpacket_maxrate", "1048576")
RunConsoleCommand("net_udp_rcvbuf", "131072")

RunConsoleCommand("gmod_mcore_test", "1") -- :troll:
RunConsoleCommand("r_PhysPropStaticLighting", "0") -- fuck off
RunConsoleCommand("effects_unfreeze", "0") -- fuck off x2

-- Fuel

local function override()
    if BlackterioExtraFunctions and BlackterioExtraFunctions.UpdateFuel then
        function BlackterioExtraFunctions:UpdateFuel(vehicle, config)
            if vehicle.GetFuel and vehicle.GetMaxFuel then
                local fuel = (vehicle:GetFuel() / vehicle:GetMaxFuel())

                if not vehicle.fuel then
                    vehicle.fuel = 0
                end

                if vehicle:GetEngineState() > 1 then
                    local rpmFraction = vehicle:GetEngineRPM() / vehicle:GetMaxRPM()
                    local fuel2 = (vehicle:GetFuel() <= 0 and rpmFraction) or fuel

                    vehicle.fuel = Lerp(config.fuelLerpRate, vehicle.fuel, fuel2)
                else
                    vehicle.fuel = Lerp(config.fuelLerpRate, vehicle.fuel, 0)
                end

                vehicle:SetPoseParameter(config.poseParameters.fuel, vehicle.fuel)
            else
                if not vehicle.fuel then
                    vehicle.fuel = self:GetFuel()
                end

                if vehicle:GetEngineState() > 0 then
                    vehicle.fuel = Lerp(config.fuelLerpRate, vehicle.fuel, 1)
                else
                    vehicle.fuel = Lerp(config.fuelLerpRate, vehicle.fuel, 0)
                end

                vehicle:SetPoseParameter(config.poseParameters.fuel, vehicle.fuel)
            end
        end
    end
end

hook.Add("InitPostEntity", "OverrideBlackterio", function()
    override()
end)

override()

-- local seqOverride = {
-- 	["run_all_01"] = "jump_slam", ["run_all_02"] = "jump_slam", ["run_all_panicked_01"] = "jump_slam", ["run_all_panicked_02"] = "jump_slam", ["run_all_protected"] = "jump_slam", ["run_all_charging"] = "jump_slam",
-- 	["run_ar2"] = "jump_ar2", ["run_camera"] = "jump_camera", ["run_crossbow"] = "jump_crossbow", ["run_dual"] = "jump_dual", ["run_fist"] = "jump_fist", ["run_knife"] = "jump_knife",
-- 	["run_magic"] = "jump_magic", ["run_melee2"] = "jump_melee2", ["run_passive"] = "jump_passive", ["run_physgun"] = "jump_physgun", ["run_revolver"] = "jump_revolver", ["run_rpg"] = "jump_rpg",
-- 	["run_shotgun"] = "jump_shotgun", ["run_smg1"] = "jump_smg1", ["run_grenade"] = "jump_grenade", ["run_melee"] = "jump_melee", ["run_pistol"] = "jump_pistol", ["run_slam"] = "jump_slam",

-- 	["cwalk_ar2"] = "jump_ar2", ["cwalk_camera"] = "jump_camera", ["cwalk_crossbow"] = "jump_crossbow", ["cwalk_dual"] = "jump_dual", ["cwalk_fist"] = "jump_fist", ["cwalk_knife"] = "jump_knife",
-- 	["cwalk_magic"] = "jump_magic", ["cwalk_melee2"] = "jump_melee2", ["cwalk_passive"] = "jump_passive", ["cwalk_pistol"] = "jump_pistol", ["cwalk_physgun"] = "jump_physgun", ["cwalk_revolver"] = "jump_revolver",
-- 	["cwalk_rpg"] = "jump_rpg", ["cwalk_shotgun"] = "jump_shotgun", ["cwalk_smg1"] = "jump_smg1", ["cwalk_grenade"] = "jump_grenade", ["cwalk_melee"] = "jump_melee", ["cwalk_slam"] = "jump_slam",
-- 	["cwalk_all"] = "jump_slam",

-- 	["walk_ar2"] = "jump_ar2", ["walk_camera"] = "jump_camera", ["walk_crossbow"] = "jump_crossbow", ["walk_dual"] = "jump_dual", ["walk_fist"] = "jump_fist", ["walk_knife"] = "jump_knife",
-- 	["walk_magic"] = "jump_magic", ["walk_melee2"] = "jump_melee2", ["walk_passive"] = "jump_passive", ["walk_physgun"] = "jump_physgun", ["walk_revolver"] = "jump_revolver", ["walk_rpg"] = "jump_rpg",
-- 	["walk_shotgun"] = "jump_shotgun", ["walk_smg1"] = "jump_smg1", ["walk_grenade"] = "jump_grenade", ["walk_melee"] = "jump_melee", ["walk_pistol"] = "jump_pistol", ["walk_slam"] = "jump_slam",
-- 	["walk_all"] = "jump_slam"
-- }

-- hook.Add("UpdateAnimation", "AirAnimFix", function(ply, vel, maxSeqGroundSpeed)
-- 	if not IsValid(ply) or ply:IsOnGround() or not ply:Alive() then return end

-- 	local targetSeq = seqOverride[ply:GetSequenceName(ply:GetSequence())]
-- 	if targetSeq then
-- 		ply:SetAnimTime( CurTime() )
--     end
-- end)