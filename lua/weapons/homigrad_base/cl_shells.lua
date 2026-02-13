local Shells = {}
Shells["9x19"] = {m = "models/shells/fhell_9x19mm.mdl", s = "Shell"}
Shells["9x18"] = {m = "models/shells/fhell_9x18mm.mdl", s = "Shell"}
Shells["45acp"] = {m = "models/shells/fhell_45cal.mdl", s = "Shell"}
Shells["380acp"] = {m = "models/shells/fhell_380acp.mdl", s = "Shell"}
Shells["50ae"] = {m = "models/shells/fhell_50ae.mdl", s = "Shell"}
Shells["50cal"] = {m = "models/shells/fhell_50cal.mdl", s = {"weapons/shells/m249_link_concrete_01.wav","weapons/shells/m249_link_concrete_02.wav","weapons/shells/m249_link_concrete_03.wav","weapons/shells/m249_link_concrete_04.wav","weapons/shells/m249_link_concrete_05.wav","weapons/shells/m249_link_concrete_06.wav","weapons/shells/m249_link_concrete_07.wav","weapons/shells/m249_link_concrete_08.wav"}}
Shells["545x39"] = {m = "models/shells/fhell_545.mdl", s = "Shell"}
Shells["556x45"] = {m = "models/shells/fhell_556.mdl", s = "Shell"}
Shells["762x39"] = {m = "models/shells/fhell_762x39.mdl", s = "Shell"}
Shells["366tkm"] = {m = "models/weapons/arccw/uc_shells/366tkm.mdl", s = "Shell", vCustomScale = 0.6} -- models/weapons/arccw/uc_shells/366tkm.mdl
Shells["762x51"] = {m = "models/shells/fhell_762x51.mdl", s = "Shell"}
Shells["762x54"] = {m = "models/weapons/arc9/darsu_eft/shells/762x54r.mdl", s = "Shell"}
Shells[".338Lapua"] = {m = "models/shells/shell_338mag.mdl", s = "Shell"}
Shells["12x70"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_12x70_shell.mdl", s = "12Guage"}
Shells["Pulse"] = {m = "models/weapons/arccw/irifleshell.mdl", s = "12Guage"}
Shells["10mm"] = {m = "models/shells/fhell_10mm.mdl", s = "Shell"}
Shells["mc51len"] = {m = "models/shells/fhell_mc51.mdl"}
Shells["m249len"] = {m = "models/shells/fhell_m249.mdl"}
Shells["m60len"] = {m = "models/shells/fhell_m60.mdl"}
Shells["12x70beanbag"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_12x70_slug_grizzly_40_shell.mdl", s = "12Guage"}
Shells["12x70slug"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_12x70_slug_poleva_3_shell.mdl", s = "12Guage"}
Shells["ags_shell"] = {m = "models/weapons/arc9/darsu_eft/shells/40x46_m716.mdl", s = "12Guage", vCustomPhys = Vector(1,1,1)}
Shells["12x70blank"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_12x70_slug_poleva_6u_shell.mdl", s = "12Guage"}
Shells[".22lr"] = {m = "models/weapons/arccw/uc_shells/22lr.mdl", s = "Shell"}
Shells["23x75sh10"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_sh10.mdl", s = "12Guage"}
Shells["23x75sh25"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_sh25.mdl", s = "12Guage"}
Shells["23x75barricade"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_bar.mdl", s = "12Guage"}
Shells["23x75zvezda"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_zvezda.mdl", s = "12Guage"}
Shells["23x75waver"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_waver.mdl", s = "12Guage"}
Shells["20/70"] = {m = "models/weapons/arc9/darsu_eft/shells/patron_23x75_sh10.mdl", s = "12Guage", vCustomScale = 0.75}

hg_shelles = hg_shelles or {}
local gamemod = engine.ActiveGamemode()

local Types = {
	["grass"] = "grass",
	["carpet"] = "carpet",
	["sand"] = "sand",
	["metal"] = "metal",
	["metalgrate"] = "metal",
	["wood"] = "wood",
	["wood_plank"] = "wood",
	["rubber"] = "carpet",
	["water"] = "water",
	["metalpanel"] = "metal",
	["wood_panel"] = "wood",
	["default"] = "dirt"
}

local ShellsSND = {
	["12Guage"] ="zcity/shells/shell_12ga_",
	["Shell"] = "zcity/shells/shell_39mm_"
}

hg_trails = hg_trails or {}
local hg_shouldnt_autoremove = ConVarExists("hg_shouldnt_autoremove") and GetConVar("hg_shouldnt_autoremove") or CreateConVar("hg_shouldnt_autoremove", 0, FCVAR_REPLICATED, "Toggle weapon shell disappearing", 0, 1)
local hg_potatopc
local hg_maxsmoketrails = GetConVar("hg_maxsmoketrails") or CreateClientConVar("hg_maxsmoketrails", "7", true, false, "Max amount of smoke trail effects (lags starts after 10)", 0, 30)
function SWEP:MakeShell(shell, pos, ang, vel)
	if not shell or not pos or not ang then
		return
	end
		
	local t = Shells[shell]
	
	if not t then
		return
	end
	
	vel = vel or Vector(0, 0, -100)
	vel = vel + VectorRand() * 5
	
	local ent = ClientsideModel(t.m, RENDERGROUP_BOTH) 
	function ent:Draw()
		if (LocalPlayer():EyePos() - self:GetPos()):LengthSqr() < 512^2 then
			self:DrawModel()
		end
	end
	ent:SetPos(pos)

	ent:PhysicsInitBox( t.vCustomPhys and -t.vCustomPhys or Vector(-0.5, -0.15, -0.5), t.vCustomPhys or Vector(0.5, 0.15, 0.5),"gmod_silent")

	ent:SetAngles(ang)
	ent:SetMoveType(MOVETYPE_VPHYSICS)
	ent:SetModelScale(t.vCustomScale and t.vCustomScale or 1)
	ent:SetSolid(SOLID_VPHYSICS) 
	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
    hg_shelles[#hg_shelles+1] = ent
	
	local phys = ent:GetPhysicsObject()
	phys:SetMaterial("gmod_silent")
	phys:SetMass(10)
	phys:SetVelocity(vel + (((IsValid(self) and IsValid(self:GetOwner())) and self:GetOwner():GetVelocity()/1.1) or Vector(0,0,0)))
    phys:SetAngleVelocity(VectorRand() * 100 - ang:Forward() * math.random(1500,3500))
	
	hg_potatopc = hg_potatopc or hg.ConVars.potatopc
	
	if not hg_potatopc:GetBool() then
		if math.random(1) == 1 and #hg_trails < hg_maxsmoketrails:GetInt() then
			local eff = ent:CreateParticleEffect("smoke_trail_wild",1,{PATTACH_ABSORIGIN_FOLLOW,ent,ent:GetPos()})
			table.insert(hg_trails,eff)
			eff:StartEmission()
			timer.Simple(3,function()
				if IsValid(eff) then
					eff:StopEmission()
				end
			end)
			timer.Simple(5,function()
				if IsValid(eff) then
					eff:StopEmissionAndDestroyImmediately()
					table.RemoveByValue(hg_trails,eff)
				end
			end)
		end
	end

    ent:AddCallback("PhysicsCollide",function(ent,data)
        if data.Speed > 50 then
			if isstring(t.s) then
				local fallmat = util.GetSurfacePropName( data.TheirSurfaceProps )
				if ent:WaterLevel() > 0 then
					fallmat = "water"
				end
				local Type = Types[fallmat] or "default"
				ent:EmitSound(ShellsSND[t.s]..Type.."_"..math.random(1,5)..".mp3", 60, 100) 
			end

            if istable(t.s) then
                ent:EmitSound(table.Random(t.s), 60, 100)   
            end
        end
    end)
	gamemod = gamemod or engine.ActiveGamemode()
	if not hg_shouldnt_autoremove:GetBool() and ( zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" ) then	
		SafeRemoveEntityDelayed(ent, 10)
	end
end
local vec = Vector(1.3,0.2,4.5)
local lpos, lang = Vector(-5,0,0), Angle(0,0,0)
local lpos2, lang2 = Vector(0,5,0), Angle(0,0,0)
function hg.CreateMag( self, vel, bodygroups, bDontChangePhys )
	if not IsValid(self) then return end
	if not IsValid(self:GetWM()) then return end
	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	
	local matrix = self:GetWM():GetBoneMatrix(isnumber(self.FakeMagDropBone) and self.FakeMagDropBone or self:GetWM():LookupBone(self.FakeMagDropBone or "Magazine") or self:GetWM():LookupBone("ValveBiped.Bip01_L_Hand"))
	

	if not matrix then return end
	local lpos, lang = self.lmagpos or lpos, self.lmagang or lang
	local lpos2, lang2 = self.lmagpos2 or lpos2, self.lmagang2 or lang2
	local pos = matrix:GetTranslation()
	local ang = matrix:GetAngles()
	local pos, ang = LocalToWorld(lpos2, lang2, pos, ang)
	ang:RotateAroundAxis(ang:Up(),-90)
	local ent = ClientsideModel(self.MagModel or "models/weapons/upgrades/w_magazine_m1a1_30.mdl")
	hg_shelles[#hg_shelles+1] = ent
	ent.RenderOverride = function(self)
		
		if (LocalPlayer():EyePos() - self:GetPos()):LengthSqr() < 512*512 then -- так быстрее
			if not bDontChangePhys then
				local phys = self:GetPhysicsObject()
				if IsValid(phys) then
					local min, max = phys:GetAABB()
					//debugoverlay.BoxAngles( self:GetPos(), min, max, self:GetAngles(), 1)
					local pos, ang = LocalToWorld(lpos, lang, self:GetPos(), self:GetAngles())
					self:SetRenderOrigin(pos)
					self:SetRenderAngles(ang)
					self:DrawModel()
					self:SetRenderOrigin()
					self:SetRenderAngles()
				else
					self:DrawModel()
				end
			else
				self:DrawModel()
			end
		end
	end
	local invmat = Matrix()
	invmat:SetTranslation(lpos)
	invmat:SetAngles(lang)
	invmat:Invert()
	local newmat = Matrix()
	newmat:SetTranslation(pos)
	newmat:SetAngles(ang)
	newmat = newmat * invmat
	ent:SetPos(newmat:GetTranslation())
	ent:SetAngles(newmat:GetAngles())
	ent:SetBodyGroups(bodygroups or "0000000")
	--debugoverlay.BoxAngles( pos, vec, -vec, self:GetAngles(), 5)
	--ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if not bDontChangePhys then
		ent:PhysicsInitBox(-vec, vec,"gmod_silent")
	else
		ent:PhysicsInit(SOLID_VPHYSICS)
	end
	ent:SetMoveType(MOVETYPE_VPHYSICS) 
	ent:SetSolid(SOLID_VPHYSICS) 
	ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	if not bDontChangePhys then
		ent:SetRenderBounds( -Vector(1,1,1), Vector(1,1,1), lpos2 )
	end
	local phys = ent:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetMaterial("gmod_silent")
		phys:SetMass(10)

		local vel = vel and -(-vel) or -(-vector_origin)
		vel:Rotate(owner:EyeAngles())
		

		phys:SetVelocity(vel + (((IsValid(self) and IsValid(owner)) and owner:GetVelocity()*1.1) or Vector(0,0,0)))
		phys:SetAngleVelocity(VectorRand() * 5)
	end

	ent:AddCallback("PhysicsCollide",function(ent,data)
		if data.Speed > 100 then
			ent:EmitSound("physics/metal/weapon_impact_hard"..math.random(1,3)..".wav", 60, 110)   
		end
	end)
	gamemod = gamemod or engine.ActiveGamemode()
	if not hg_shouldnt_autoremove:GetBool() and ( zb.CROUND and zb.CROUND ~= "hmcd" or gamemod == "sandbox" )then	
		SafeRemoveEntityDelayed(ent, 10)
	end

	return ent
	--ent:Spawn()
	--print("SHIT")
end

function hg.addBulletHoleEffect(pos)
	if not hg_potatopc:GetBool() then
		if math.random(3) == 1 and #hg_trails < hg_maxsmoketrails:GetInt() then
			local eff = CreateParticleSystemNoEntity( "smoke_trail_wild", pos )
			table.insert(hg_trails,eff)
			eff:StartEmission()
			timer.Simple(3,function()
				if IsValid(eff) then
					eff:StopEmission()
				end
			end)
			timer.Simple(5,function()
				if IsValid(eff) then
					eff:StopEmissionAndDestroyImmediately()
					table.RemoveByValue(hg_trails,eff)
				end
			end)
		end
	end
end

hook.Add("PostCleanupMap","cleanupshells",function()
    for k,v in ipairs(hg_shelles) do
        --print("huy")
        v:Remove()
    end
    hg_shelles = {}
end)