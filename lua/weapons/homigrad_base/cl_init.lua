--
include("shared.lua")
include("sh_anim.lua")
include("sh_bullet.lua")
include("sh_replicate.lua")
include("sh_holster_deploy.lua")
include("sh_reload.lua")
include("sh_spray.lua")
include("sh_worldmodel.lua")
include("sh_attachment.lua")
include("sh_fake.lua")
include("sh_ammo.lua")
include("sh_weaponsinv.lua")
include("cl_camera.lua")
include("cl_optics.lua")
include("cl_shells.lua")
include("sh_options.lua")

matproxy.Add({
    name = "UC_ShellColor",
    init = function(self, mat, values)
        --self.envMin = values.min
        --self.envMax = values.max
        self.col = Vector()
    end,
    bind = function(self, mat, ent)
        local swent = ent
        
        if IsValid(swent) then
            local herg = color_white
            local r = 255
            local g = 255
            local b = 255
            
            if swent.GetShellColor then
                herg = swent:GetShellColor() or color_white
                r = herg.r or 255
                g = herg.g or 255
                b = herg.b or 255
            end

            self.col.x = r / 255
            self.col.y = g / 255
            self.col.z = b / 255
            mat:SetVector("$color2", self.col)
        end
    end
})

hook.Add("radialOptions", "ReloadOnFloor", function()
	if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	local org = lply.organism
	if org.pain > 50 or (org.rarmamputated and org.larmamputated) then return end
	local ent = (IsValid(hg.eyeTrace(lply).Entity) and hg.eyeTrace(lply).Entity) or (IsValid(lply:GetNetVar("carryent")) and lply:GetNetVar("carryent"))
	if not IsValid(ent) then return end
	if not ishgweapon(ent) then return end
	local clip, maxclip = ent:Clip1(), ent:GetMaxClip1()
	local isshotgun = (ent.Base == "weapon_m4super" or ent:GetClass() == "weapon_m4super")
	if ((clip < maxclip or lply:GetAmmoCount(ent.Primary.Ammo) > 0) or (isshotgun and not ent.drawBullet)) then
		if clip >= maxclip then return end
		if isshotgun and ent.drawBullet and lply:GetAmmoCount(ent.Primary.Ammo) <= 0 then return end
		local tbl = {
			function()
				RunConsoleCommand("hg_reloadfloorweapon")
			end,
			((isshotgun and lply:GetAmmoCount(ent.Primary.Ammo) <= 0 and not ent.drawBullet) and "Pump " or "Reload ") .. ent:GetPrintName()
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

hook.Add("radialOptions", "PlaceBipod", function()
	if !lply:Alive() or !lply.organism or lply.organism.otrub then return end
	local org = lply.organism
	if org.pain > 50 or (org.rarmamputated and org.larmamputated) then return end
	local ent = lply:GetActiveWeapon()
	if not IsValid(ent) then return end
	if not ishgweapon(ent) then return end
	local clip, maxclip = ent:Clip1(), ent:GetMaxClip1()
	if ent.CanRest and ent:CanRest() or ent.IsResting and ent:IsResting() then
		local tbl = {
			function()
				RunConsoleCommand("hg_place_bipod")
			end,
			ent:IsResting() and "Pickup bipod" or "Place bipod"
		}
		hg.radialOptions[#hg.radialOptions + 1] = tbl
	end
end)

hook.Add("StartCommand", "reloadfloorweapon", function(ply, cmd)
    if IsValid(ply) and ply:Alive() and ply:GetNW2Bool("FloorReloading", false) then
		cmd:AddKey(IN_DUCK)
		cmd:RemoveKey(IN_JUMP)
    end
end)