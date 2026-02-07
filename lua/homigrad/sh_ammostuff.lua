--\\Silk
HGAmmo_MaxKeyBits = 13

if(SERVER)then
	util.AddNetworkString("HGAmmo(TranslateSilkToEntity)")
else
	HGAmmo_PhysSilkTranslationExpectedEntitiesTable = HGAmmo_PhysSilkTranslationExpectedEntitiesTable or {}
	HGAmmo_PhysSilkTranslationTable = HGAmmo_PhysSilkTranslationTable or {}
	
	local function translate_silk_to_ent(ent, bullet_key)
		local translation_info = HGAmmo_PhysSilkTranslationTable[bullet_key]
		
		if(translation_info)then
			if(ent.Silks)then
				for key, silk in pairs(ent.Silks) do
					silk:Die()
				end
			end
		
			for key, silk in pairs(translation_info.Silks) do
				silk.Entity = ent
			end
		
			ent.Silks = translation_info.Silks
			HGAmmo_PhysSilkTranslationTable[bullet_key] = nil
		end
	end
	
	hook.Add("Think", "HGAmmo_PhysSilkTranslationTable", function()
		for bullet_key, translation_info in pairs(HGAmmo_PhysSilkTranslationTable) do
			if(translation_info.DeathTime <= CurTime())then
				for key, silk in pairs(translation_info.Silks) do
					silk:Die()
				end
				
				HGAmmo_PhysSilkTranslationTable[bullet_key] = nil
			end
		end
	end)
	
	hook.Add("NotifyShouldTransmit", "HGAmmo_PhysSilkTranslationTable", function(ent, state)
		if(state == true)then
			local ent_id = ent:EntIndex()
			
			if(HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id])then
				translate_silk_to_ent(ent, HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id])
				
				HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id] = nil
			end
		end
	end)
	
	net.Receive("HGAmmo(TranslateSilkToEntity)", function(len, ply)
		-- Entity(1):ChatPrint(12312)
		local bullet_key = net.ReadUInt(hg.PhysBullet.MaxKeyBits)
		local ent_id = net.ReadUInt(HGAmmo_MaxKeyBits)
		local ent = Entity(ent_id)
		
		if(IsValid(ent))then
			translate_silk_to_ent(ent, bullet_key)
		else
			HGAmmo_PhysSilkTranslationExpectedEntitiesTable[ent_id] = bullet_key
		end
	end)
end
--//

--\\Common Function Overrides
local function scrape_blood(self, trace, len, len_before)
	if(SERVER)then
		if(trace and !trace.HitSky)then
			if(trace.Entity.organism)then
				local hit_organism = trace.Entity.organism
				hit_organism.pain = (hit_organism.pain or 0) + 60
				hit_organism.disorientation = (hit_organism.disorientation or 0) + 5
			else--if(trace.Entity:IsNPC() or trace.Entity:IsNextBot())then
				local dmg = DamageInfo()
				
				if(IsValid(self.Shooter))then
					dmg:SetAttacker(self.Shooter)
				else
					dmg:SetAttacker(game.GetWorld())
				end
				
				dmg:SetDamageType(DMG_DISSOLVE)
				dmg:SetDamage(80)
				trace.Entity:TakeDamageInfo(dmg)
			end
			
			local effect_data = EffectData()
			
			effect_data:SetOrigin(trace.HitPos)
			util.Effect("BloodImpact", effect_data)
		end
	end
	
	-- self:Die()
end

local function onstopped_blood(self, last_unsure_penetration_pos, reason, trace)
	scrape_blood(self, trace, len, len_before)
end

local function postricochet_blood(self, new_vel_normal, len, ricochet, ang_diff, len_before, trace)
	scrape_blood(self, trace, len, len_before)
end

local function postpenetration_blood(self, new_vel_normal, len, ricochet, ang_diff, len_before, trace)
	scrape_blood(self, trace, len, len_before)
end

local function draw_silk(self)
	if(IsValid(self.Draw_Model))then
		--
	else
		local model_ent = ClientsideModel(self.FunctionInfo.Model)
		self.Draw_Model = model_ent
	end
	
	local model_ent = self.Draw_Model
	local vel_ang = self.Vel:Angle()
	
	model_ent:SetPos(self.Pos)
	model_ent:SetAngles(vel_ang)
	
	--if(hg.PhysSilk)then
	--	if(!self.DesiredSilks)then
	--		self.DesiredSilks = self.FunctionInfo.DesiredSilks
	--	end
	--	
	--	self.Silks = self.Silks or {}	--; TODO, Network translation to entity
--
	--	for silk_desired_key, silk_desired in ipairs(self.DesiredSilks) do
	--		local desired_pos, _ = LocalToWorld(silk_desired.EntityOffset, angle_zero, self.Pos, vel_ang)
	--		
	--		if(IsValid(self.Silks[silk_desired_key]))then
	--			self.Silks[silk_desired_key].Pos = desired_pos
	--		else
	--			local silk = table.Copy(silk_desired)	--; WARNING POINTERS
	--			silk.Pos = desired_pos
	--			self.Silks[silk_desired_key] = hg.PhysSilk.CreateSilk(silk, true)
	--		end
	--	end
	--end
	-- if(self.PathPoints)then
		-- local color = self.TracerSetings.TracerColor or color_white
		
		-- render.SetColorMaterial()
		-- render.StartBeam(math.min(#self.PathPoints, self.TracerSetings.MaxPathPoints))
		
		-- for i = math.max(#self.PathPoints - self.TracerSetings.MaxPathPoints, 1), #self.PathPoints do
			-- render.AddBeam(self.PathPoints[i], self.TracerSetings.TracerWidth or 0.4, 1, color)
		-- end
		
		-- render.EndBeam()
	-- end
end

local function onstopped_silk(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local normal = self.Vel:GetNormalized()
			local projectile = ents.Create(self.FunctionInfo.Ent)
			projectile:SetPos(self.Pos)
			projectile:SetAngles(normal:Angle())
			projectile:Spawn()
			self.SpawnedEntity = projectile

			if(trace)then
				projectile:Hit(trace.Entity, trace.HitPos - normal * 10, trace.PhysicsBone, normal)
			end
		end
	end
end

local function arrow_hit(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local normal = -self.Vel:GetNormalized()
			local projectile = ents.Create(self.FunctionInfo.Ent)
			projectile:SetPos(self.Pos)
			projectile:SetAngles(normal:Angle())
			projectile:Spawn()
			self.SpawnedEntity = projectile
			
			if(trace)then
				projectile:Hit(trace.Entity, trace.HitPos + normal * -4, trace.PhysicsBone, normal)
			end
		end
	end
end

local function preremove_silk(self)
	if(IsValid(self.Draw_Model))then
		self.Draw_Model:Remove()
	end
	
	if(CLIENT and self.Silks)then
		HGAmmo_PhysSilkTranslationTable[self.Key] = {	--; СЕЛФ КЕУ МОЖЕТ БЫТЬ ОДИН И ТОТ ЖЕ У 2 ПУЛЬ ЕСЛИ ПРОШЛАЯ УСПЕЛА УДАЛИТЬСЯ
			Silks = self.Silks,
			DeathTime = CurTime() + 1,
		}
	end
end

local function postremove_silk(self)
	if(SERVER)then
		if(IsValid(self.SpawnedEntity))then
			net.Start("HGAmmo(TranslateSilkToEntity)")
				net.WriteUInt(self.Key, hg.PhysBullet.MaxKeyBits)
				net.WriteUInt(self.SpawnedEntity:EntIndex(), HGAmmo_MaxKeyBits)
			net.SendPVS(self.SpawnedEntity:GetPos())
			-- net.Broadcast()	--; PLUG
		end
	end
end

--=\\Scheduled explosions
APScheduledExplosions = APScheduledExplosions or {}

hook.Add("Think", "APScheduledExplosions", function()	--; AimPoint Mr.Point
	for id, coroutine_example in pairs(APScheduledExplosions) do
		if(!coroutine.resume(coroutine_example))then
			APScheduledExplosions[id] = nil
		end
	end
end)
--=//

--=\\Explosive Projectile
local function draw_explosive(self)
	if(IsValid(self.Draw_Model))then
		--
	else
		local model_ent = ClientsideModel(self.FunctionInfo.Model)
		self.Draw_Model = model_ent
	end
	
	local model_ent = self.Draw_Model
	local vel_ang = self.Vel:Angle()
	
	model_ent:SetPos(self.Pos)
	model_ent:SetAngles(vel_ang)
end

local function preremove_explosive(self)
	if(IsValid(self.Draw_Model))then
		self.Draw_Model:Remove()
	end
end

local function onstopped_explosive(self, last_unsure_penetration_pos, reason, trace)
	if(SERVER)then
		if(!trace or !trace.HitSky)then
			local attacker = self.Shooter
			local pos = self.Pos - self.Vel:GetNormalized() * 2
			local vec_cone = Vector(0, 0, 0)
			local shrapnel_coroutine_id = #APScheduledExplosions + 1
			
			util.ScreenShake(self.Pos, 35, 1, 1, 3000)

			timer.Simple(.01,function()
				ParticleEffect("pcf_jack_airsplode_small3",pos + vector_up * 1,-vector_up:Angle())
			end)

			net.Start("projectileFarSound")
				net.WriteString("m67/m67_detonate_01.wav")
				net.WriteString("m67/m67_detonate_far_dist_03.wav")
				net.WriteVector(pos)
				net.WriteEntity(Entity(0))
				net.WriteBool(false)
				net.WriteString("")
			net.Broadcast()
			
			util.BlastDamage(Entity(0), IsValid(attacker) and attacker or Entity(0), self.Pos, 100, 50)
			hg.ExplosionEffect(self.Pos, 1500 / 0.01905, 250)

			--local effectdata = EffectData()
			--effectdata:SetOrigin(selfPos)
			--effectdata:SetScale(0.9)
			--util.Effect("eff_jack_fragsplosion", effectdata)
	
			timer.Simple(.15,function()
				local coroutine_antilag = coroutine.create(function()
					local last_shrapnel = SysTime()

					for i = 1, 600 do
						last_shrapnel = SysTime()
						local dir = VectorRand(-1, 1)
						
						dir:Normalize()
						
						dir[3] = dir[3] > 0 and math.abs(dir[3] - 0.5) or -math.abs(dir[3] + 0.5)
						
						dir:Normalize()
						
						local bullet = {}
						bullet.Src = pos
						bullet.Spread = vec_cone
						bullet.Force = 4
						bullet.Damage = 40
						bullet.AmmoType = "Metal Debris"
						bullet.Attacker = game.GetWorld()
						bullet.Inflictor = attacker
						bullet.Distance = 567
						bullet.DisableLagComp = true
						bullet.Dir = dir
						
						game.GetWorld():FireLuaBullets(bullet, true)

						last_shrapnel = SysTime() - last_shrapnel

						if(last_shrapnel > 0.001)then
							coroutine.yield()
						end
					end
					
					APScheduledExplosions[shrapnel_coroutine_id] = nil
				end)

				APScheduledExplosions[shrapnel_coroutine_id] = coroutine_antilag
				
				coroutine.resume(coroutine_antilag)
			end)
			util.ScreenShake( self.Pos, 35, 1, 1, 1000, true )
		end
	end
end
--=//
--//

--
local matPistolAmmo = Material("vgui/hud/bullets/low_caliber.png")
local matRfileAmmo = Material("vgui/hud/bullets/high_caliber.png")
local matShotgunAmmo = Material("vgui/hud/bullets/buck_caliber.png")
hg.ammotypes = {
	["5.56x45mm"] = {
		name = "5.56x45 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 155,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 44,
			Force = 44,
			Penetration = 13,
			Shell = "556x45",
			Speed = 890,
			Diameter = 5.56,
			Mass = 4,
			Icon = matRfileAmmo
		}
	},
	["5.56x45mmm856"] = {
		name = "5.56x45 mm M856",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 90,
			TracerLength = 255,
			TracerWidth = 5,
			TracerColor = Color(255, 0, 0),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 44,
			Force = 44,
			Penetration = 16,
			Shell = "556x45",
			Speed = 860,
			Diameter = 5.56,
			Mass = 4,
			Icon = matRfileAmmo
		}
	},
	["5.56x45mmap"] = {
		name = "5.56x45 mm AP",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 155,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 44,
			Force = 44,
			Penetration = 15,
			Shell = "556x45",
			Speed = 980,
			Diameter = 5.56,
			Mass = 4,
			Icon = matRfileAmmo
		}
	},
	["7.62x39mmsp"] = {
		name = "7.62x39 mm SP",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 127,
		maxcarry = 120,
		minsplash = 8,
		maxsplash = 8,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 175,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 68,
			Force = 45,
			Penetration = 9.98,
			Shell = "762x39",
			Speed = 772,
			AirResistMul = 0.00011,
			Diameter = 7.62,
			Mass = 8.5,
			Icon = matRfileAmmo
		}
	},
	["7.62x39mm"] = {
		name = "7.62x39 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 160,
		maxcarry = 120,
		minsplash = 8,
		maxsplash = 8,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 175,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 50,
			Force = 50,
			Penetration = 13,
			Shell = "762x39",
			Speed = 650,
			AirResistMul = 0.00011,
			Diameter = 7.62,
			Mass = 8.5,
			Icon = matRfileAmmo
		}
	},
	["7.62x39mmbp"] = {
		name = "7.62x39 mm BP gzh",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 160,
		maxcarry = 120,
		minsplash = 8,
		maxsplash = 8,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 175,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 58.8,
			Force = 66,
			Penetration = 17.8,
			Shell = "762x39",
			Speed = 730,
			AirResistMul = 0.00011,
			Diameter = 7.62,
			Mass = 8.5,
			Icon = matRfileAmmo
		}
	},
	[".366tkm"] = {
		name = ".366 TKM",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 160,
		maxcarry = 120,
		minsplash = 8,
		maxsplash = 8,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 175,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 50,
			Force = 50,
			Penetration = 3,
			Shell = "366tkm",
			Speed = 650,
			AirResistMul = 0.00011,
			Diameter = 9.58,
			Mass = 13.5,
			Icon = matRfileAmmo
		}
	},
	["5.45x39mm"] = {
		name = "5.45x39 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 155,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 35,
			Force = 35,
			Penetration = 11,
			Shell = "545x39",
			Speed = 850,
			Diameter = 5.45,
			Mass = 4.5,
			Icon = matRfileAmmo
		}
	},
	["metal_debris"] = {
		name = "Metal Debris",
		dmgtype = DMG_AIRBOAT + DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 16,
			Force = 12,
			Penetration = 8,
			NumBullet = 8,
			Shell = "12x70",
			Speed = 700,
			PhysPenetrationMul = 65,
			AirResistMul = 0.001,
			Diameter = 12,
			Mass = 32/8,
		}
	},
	["12/70gauge"] = {
		name = "12/70 gauge",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 16,
			Force = 8,
			Penetration = 8,
			NumBullet = 8,
			Shell = "12x70",
			Speed = 400,
			AirResistMul = 0.0003,
			Diameter = 12/8,
			Mass = 32/8,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,0,0)
		}
	},
	["12/70beanbag"] = {
		name = "12/70 beanbag",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 46,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1.5,
			TracerLength = 155,
			TracerWidth = 5,
			TracerColor = Color(70, 78, 36),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 3000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 60,
			Force = 150,
			Penetration = 3,
			Shell = "12x70beanbag",
			Spread = Vector(0, 0, 0),
			Speed = 550,
			AirResistMul = 0.0003,
			Diameter = 12,
			Mass = 20,
			Icon = matShotgunAmmo,
			ShellColor = Color(122,122,122)
		}
	},
	["12/70slug"] = {
		name = "12/70 Slug",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 250,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1.5,
			TracerLength = 25,
			TracerWidth = 3,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 120,
			Force = 120,
			Penetration = 15,
			Shell = "12x70slug",
			Spread = Vector(0, 0, 0),
			Speed = 550,
			AirResistMul = 0.00015,
			Diameter = 12,
			Mass = 30,
			Icon = matShotgunAmmo,
			ShellColor = Color(12,75,12)
		}
	},
	["12/70rip"] = {
		name = "12/70 RIP",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 250,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1.5,
			TracerLength = 25,
			TracerWidth = 3,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
			
		},
		BulletSettings = {
			Damage = 200,
			Force = 90,
			Penetration = 8,
			Shell = "12x70slug",
			Spread = Vector(0, 0, 0),
			Speed = 410,
			AirResistMul = 0.00015,
			Diameter = 12,
			Mass = 30,
			Icon = matShotgunAmmo,
			ShellColor = Color(50,110,90)
		}
	},
	["12/70blank"] = {
		name = "12/70 Blank",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 16,
			Force = 8,
			Penetration = 8,
			NumBullet = 8,
			Shell = "12x70blank",
			Speed = 400,
			AirResistMul = 0.0003,
			Diameter = 12/8,
			Mass = 32/8,
			Icon = matShotgunAmmo,
			ShellColor = Color(75,75,155),
			IsBlank = true
		}
	},
	["23x75sh10"] = {
		name = "23x75 SH10",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 450,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 20,
			Force = 6,
			Penetration = 8,
			NumBullet = 10,
			Shell = "23x75sh10",
			Speed = 300,
			AirResistMul = 0.0007,
			Diameter = 23/10,
			Mass = 32/10,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,185,0)
		}
	},
	["23x75sh25"] = {
		name = "23x75 SH25",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 450,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 20,
			Force = 2,
			Penetration = 8,
			NumBullet = 25,
			Shell = "23x75sh25",
			Speed = 300,
			AirResistMul = 0.0007,
			Diameter = 23/25,
			Mass = 32/25,
			Icon = matShotgunAmmo,
			ShellColor = Color(130,130,130)
		}
	},
	["23x75barricade"] = {
		name = "23x75 Barricade",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 450,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 120,
			Force = 100,
			Penetration = 25,
			Shell = "23x75barricade",
			Spread = Vector(0, 0, 0),
			Speed = 420,
			AirResistMul = 0.0009,
			Diameter = 23,
			Mass = 40,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,185,0)
		}
	},
	["23x75zvezda"] = {
		name = "23x75 Zvezda",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 16,
			Force = 6,
			Penetration = 8,
			NumBullet = 8,
			Shell = "23x75zvezda",
			Speed = 400,
			AirResistMul = 0.0003,
			Diameter = 12/8,
			Mass = 32/8,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,185,0),
			Distance = 32,
		}
	},
	["23x75waver"] = {
		name = "23x75 Wave R",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 450,
		maxcarry = 46,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 15,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 80,
			Force = 100,
			Penetration = 1,
			Shell = "23x75waver",
			Spread = Vector(0, 0, 0),
			Speed = 390,
			AirResistMul = 0.0008,
			Diameter = 23,
			Mass = 20,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,185,0)
		}
	},
	["20/70gauge"] = { //потом другие добавлю
		name = "20/70 gauge",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 370,
		maxcarry = 50,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 0.8,
			TracerLength = 12,
			TracerWidth = 0.8,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 9000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 12,
			Force = 6,
			Penetration = 6,
			NumBullet = 11,
			Shell = "20/70",
			Speed = 420,
			AirResistMul = 0.00025,
			Diameter = 20/6,
			Mass = 26/6,
			Icon = matShotgunAmmo,
			ShellColor = Color(255,150,0)
		}
	},
	["20/70slug"] = {
		name = "20/70 Slug",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 400,
		maxcarry = 50,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 0.8,
			TracerLength = 12,
			TracerWidth = 0.8,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 9000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 120,
			Force = 120,
			Penetration = 8,
			Shell = "20x70slug",
			Spread = Vector(0, 0, 0),
			Speed = 420,
			AirResistMul = 0.00025,
			Diameter = 20/6,
			Mass = 26/6,
			Icon = matShotgunAmmo,
			ShellColor = Color(12,75,12)
		}
	},
	["20/70flechette"] = {
		name = "20/70 Flechette",
		allowed = true,
		--dmgtype = DMG_BUCKSHOT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 350,
		maxcarry = 50,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 0.8,
			TracerLength = 12,
			TracerWidth = 0.8,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 9000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 16,
			Force = 6,
			Penetration = 6,
			NumBullet = 8,
			Shell = "20/70flechette",
			Speed = 520,
			AirResistMul = 0.00025,
			Diameter = 20/6,
			Mass = 26/6,
			Icon = matShotgunAmmo,
			ShellColor = Color(195,143,0),
		}
	},
	["9x18mm"] = {
		name = "9x18 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 90,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 24,
			Force = 24,
			Penetration = 6,
			Shell = "9x18",
			Speed = 309,
			Diameter = 9,
			Mass = 7,
			Icon = matPistolAmmo
		}
	},
	["9x17mm"] = {
		name = "9x17 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 90,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 24,
			Force = 24,
			Penetration = 6,
			Shell = "9x18",
			Speed = 309,
			Diameter = 9,
			Mass = 7,
			Icon = matPistolAmmo
		}
	},
	["9x19mmparabellum"] = {
		name = "9x19 mm Parabellum",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 25,
			Force = 25,
			Penetration = 7,
			Shell = "9x19",
			Speed = 352,
			Diameter = 9,
			Mass = 7,
			Icon = matPistolAmmo
		}
	},
	["9x19mmqm"] = {
		name = "9x19 mm QuakeMaker",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 58.23,
			Force = 27,
			Penetration = 6.1,
			Shell = "9x19",
			Speed = 291,
			Diameter = 9,
			Mass = 7,
			Icon = matPistolAmmo
		}
	},
	["7.65x17mm"] = {
		name = "7.65x17 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 95,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 25,
			Force = 25,
			Penetration = 7,
			Shell = "45acp",
			Speed = 352,
			Diameter = 9,
			Mass = 7,
			Icon = matRfileAmmo
		}
	},
	[".40sw"] = {
		name = ".40 SW",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 110,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 45,
			Force = 45,
			Penetration = 4,
			Shell = "45acp",
			Speed = 256,
			Diameter = 11.18,
			Mass = 15,
			Icon = matPistolAmmo
		}
	},
	[".45acp"] = {
		name = ".45 ACP",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 30,
			Force = 35,
			Penetration = 6.5,
			Shell = "45acp",
			Speed = 259,
			Diameter = 11.19,
			Mass = 14,
			Icon = matPistolAmmo
		}
	},
	[".45acphydroshock"] = {
		name = ".45 ACP Hydro Shock",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 45,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 50,
			Force = 50,
			Penetration = 5,
			Shell = "45acp",
			Speed = 259,
			Diameter = 11.19,
			Mass = 14,
			Icon = matPistolAmmo
		}
	},
	["9x19mmgreentracer"] = {
		name = "9x19 mm Green Tracer",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 55,
			TracerLength = 85,
			TracerWidth = 5,
			TracerColor = Color(0, 255, 0),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 25,
			Force = 25,
			Penetration = 7,
			Shell = "9x19",
			Speed = 352,
			Diameter = 9,
			Mass = 7,
			Icon = matPistolAmmo
		}
	},
	[".45rubber"] = {
		name = ".45 Rubber",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 5,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 6000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 30,
			Force = 30,
			Penetration = 1,
			Shell = "9x18",
			Speed = 259,
			Diameter = 11.19,
			Mass = 10,
			Icon = matPistolAmmo
		}
	},
	["9mmpakblank"] = {
		name = "9mm PAK Blank",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 5,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 6000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 8,
			Force = 5,
			Penetration = 4,
			Shell = "9x18",
			Speed = 259,
			Diameter = 11.19,
			Distance = 32,
			Mass = 10,
			Icon = matPistolAmmo
		}
	},
	["9mmpakflashdefense"] = {
		name = "9mm PAK Flash Defense",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 5,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 6000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 8,
			Force = 5,
			Penetration = 4,
			Shell = "9x18",
			Speed = 259,
			Diameter = 11.19,
			Distance = 32,
			Mass = 10,
			Icon = matPistolAmmo
		}
	},
	["18x45mmtraumatic"] = {
		name = "18x45mm Traumatic",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
		--[[ -- FLARE AMMO BAZA!!!!!
			TracerBody = Material("particle/particle_glow_05"),
			TracerTail = Material("trails/smoke"),
			TracerHeadSize = 500,
			TracerLength = 350,
			TracerWidth = 60,
			TracerColor = Color(255, 0, 0),
			TracerTPoint1 = 0.1,
			TracerTPoint2 = 0.5,
			TracerSpeed = 2500,
			NoSpin = true,
		]]
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 5,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 6000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 35,
			Force = 32,
			Penetration = 1,
			Shell = "9x18",
			Speed = 250,
			Diameter = 18,
			Mass = 22,
			Icon = matPistolAmmo
		}
	},
	["18x45mmflashdefense"] = {
		name = "18x45mm Flash Defense",
		allowed = true,
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 80,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1,
			TracerLength = 5,
			TracerWidth = 1,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 6000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 15,
			Force = 10,
			Penetration = 2,
			Shell = "9x18",
			Speed = 250,
			Diameter = 18,
			Distance = 32,
			Mass = 1180,
			Icon = matPistolAmmo
		}
	},
	["4.6x30mm"] = {
		name = "4.6x30 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 4,
		maxsplash = 4,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 2,
			TracerLength = 45,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 32,
			Force = 32,
			Penetration = 10,
			Shell = "556x45",
			Speed = 734,
			Diameter = 4.6,
			Mass = 1.6,
			Icon = matRfileAmmo
		}
	},
	["5.7x28mm"] = {
		name = "5.7x28 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 150,
		minsplash = 4,
		maxsplash = 4,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 45,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 32,
			Force = 32,
			Penetration = 10.5,
			Shell = "556x45",
			Speed = 853,
			Diameter = 5.7,
			Mass = 2,
			Icon = matRfileAmmo
		}
	},
	[".44remingtonmagnum"] = {
		name = ".44 Remington Magnum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 150,
		minsplash = 3,
		maxsplash = 3,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 20000
		},
		BulletSettings = {
			Damage = 40,
			Force = 40,
			Penetration = 10,
			Shell = "10mm",
			Speed = 472,
			Diameter = 10.9,
			Mass = 13,
			Icon = matPistolAmmo
		}
	},
	[".357magnum"] = {
		name = ".357 Magnum",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 130,
		maxcarry = 150,
		minsplash = 2.5,
		maxsplash = 2.5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 20000
		},
		BulletSettings = {
			Damage = 40,
			Force = 40,
			Penetration = 10,
			Shell = "10mm",
			Speed = 450,
			Diameter = 9,
			Mass = 10,
			Icon = matPistolAmmo
		}
	},
	[".38special"] = {
		name = ".38 Special",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 110,
		maxcarry = 150,
		minsplash = 2.5,
		maxsplash = 2.5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 20000
		},
		BulletSettings = {
			Damage = 27,
			Force = 27,
			Penetration = 7,
			Shell = "10mm",
			Speed = 290,
			Diameter = 9.1,
			Mass = 10,
			Icon = matPistolAmmo
		}
	},
	["14.5x114mmb32"] = { -- Салат ты у нас тут балансище, сделаешь конфетку 
		name = "14.5x114mm B32",
		dmgtype = DMG_BULLET + DMG_AIRBOAT,
		tracer = TRACER_NONE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 10,
		minsplash = 5,
		maxsplash = 5,
		BulletSettings = {
			Damage = 550,
			Force = 100,
			Penetration = 320,
			Shell = "762x39",
			Speed = 1000,
			Diameter = 14.5,
			Mass = 64,
			Icon = matRfileAmmo
		}
	},
	["14.5x114mmbztm"] = { -- это тоже самое что и выше просто с трасером :D
		name = "14.5x114mm BZTM",
		dmgtype = DMG_BULLET + DMG_AIRBOAT,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 100,
		maxcarry = 120,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 100,
			TracerLength = 255,
			TracerWidth = 20,
			TracerColor = Color(255,91,0),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 250,
			Force = 100,
			Penetration = 320,
			Shell = "762x39",
			Speed = 1000,
			Diameter = 14.5,
			Mass = 64,
			Icon = matRfileAmmo
		}
	},
	["9x39mm"] = {
		name = "9x39 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 150,
		minsplash = 5,
		maxsplash = 5,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 75,
			TracerWidth = 2.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 0.5,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 42,
			Force = 42,
			Penetration = 15,
			Shell = "762x39",
			Speed = 300,
			Diameter = 9,
			Mass = 16,
			Icon = matRfileAmmo
		}
	},
	[".50actionexpress"] = {
		name = ".50 Action Express",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 150,
		minsplash = 6,
		maxsplash = 6,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 1.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 40,
			Force = 40,
			Penetration = 11,
			Shell = "50ae",
			Speed = 440,
			Diameter = 12.7,
			Mass = 19,
			Icon = matPistolAmmo
		}
	},
	[".50actionexpresscopper"] = {
		name = ".50 Action Express Copper Solid",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 150,
		minsplash = 6,
		maxsplash = 6,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 1.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 81,
			Force = 40,
			Penetration = 10,
			Shell = "50ae",
			Speed = 460,
			Diameter = 12.7,
			Mass = 19,
			Icon = matPistolAmmo
		}
	},
	[".50actionexpressjhp"] = {
		name = ".50 Action Express JHP",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 150,
		minsplash = 6,
		maxsplash = 6,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 35,
			TracerWidth = 1.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 101.5,
			Force = 110,
			Penetration = 9.6,
			Shell = "50ae",
			Speed = 440,
			Diameter = 12.7,
			Mass = 19,
			Icon = matPistolAmmo
		}
	},
	["7.62x51mm"] = {
		name = "7.62x51 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 250,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 10,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 75,
			TracerWidth = 1.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 65,
			Force = 65,
			Penetration = 18,
			Shell = "762x51",
			Speed = 840,
			Diameter = 7.62,
			Mass = 10,
			Icon = matRfileAmmo
		}
	},
	["7.62x51mmm993"] = {
		name = "7.62x51 mm M993",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 250,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 10,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 75,
			TracerWidth = 1.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 74.7,
			Force = 69,
			Penetration = 23.4,
			Shell = "762x51",
			Speed = 930,
			Diameter = 7.62,
			Mass = 18,
			Icon = matRfileAmmo
		}
	},
	["7.62x54mm"] = {
		name = "7.62x54 mm",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 250,
		maxcarry = 120,
		minsplash = 11,
		maxsplash = 11,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 75,
			TracerWidth = 2,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 70,
			Force = 70,
			Penetration = 20,
			Shell = "762x54",
			Speed = 860,
			Diameter = 7.62,
			Mass = 10,
			Icon = matRfileAmmo
		}
	},
	[".338lapuamagnum"] = {
		name = ".338 Lapua Magnum",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 400,
		maxcarry = 120,
		minsplash = 15,
		maxsplash = 15,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 105,
			TracerWidth = 5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 180,
			Force = 60,
			Penetration = 35,
			Shell = ".338Lapua",
			Speed = 880,
			Diameter = 8.6,
			Mass = 16,
			Icon = matRfileAmmo
		}
	},
	[".22longrifle"] = {
		name = ".22 Long Rifle",
		allowed = true,
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 70,
		maxcarry = 120,
		minsplash = 1,
		maxsplash = 1,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = .5,
			TracerLength = 55,
			TracerWidth = .5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 10000
		},
		BulletSettings = {
			Damage = 17,
			Force = 20,
			Penetration = 6.5,
			Shell = ".22lr",
			Speed = 335,
			Diameter = 5.72,
			Mass = 2.5,
			Icon = matPistolAmmo
		}
	},
	["rpg-7projectile"] = {
		name = "RPG-7 Projectile",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 5000,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["12.7x108mm"] = {
		name = "12.7x108 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 550,
		maxcarry = 120,
		minsplash = 20,
		maxsplash = 20,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 150,
			TracerWidth = 8.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 45000
		},
		BulletSettings = {
			Damage = 150,
			Force = 40,
			Penetration = 60,
			Shell = "50cal",
			Speed = 820,
			Diameter = 12.7,
			Mass = 48,
			Icon = matRfileAmmo
		}
	},
	["12.7x55mm"] = {
		name = "12.7x55 mm",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 96.8,
		npcdmg = 96.8,
		force = 180,
		maxcarry = 120,
		minsplash = 20,
		maxsplash = 20,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 150,
			TracerWidth = 8.5,
			TracerColor = Color(255, 237, 155),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 45000
		},
		BulletSettings = {
			Damage = 255,
			Force = 40,
			Penetration = 9,
			Shell = "50cal",
			Speed = 315,
			Diameter = 12.7,
			Mass = 20,
			Icon = matRfileAmmo
		}
	},
	["nails"] = {
		name = "Nails",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 50,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5
	},
	["armature"] = {
		name = "Armature",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 90,
		minsplash = 10,
		maxsplash = 5,
		TracerSetings = {
			MaxPathPoints = 5,
		},
		BulletSettings = {
			Mass = 200,
			Icon = matRfileAmmo,
			Damage = 256.8,
			Force = 30.9,
			Penetration = 50,
		},
		FunctionInfo = {
			Model = "models/crossbow_bolt.mdl",
			--DesiredSilks = {	--; WARNING POINTER
			--	{SegmentsDesiredAmt = 5, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
			--	{SegmentsDesiredAmt = 6, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2.1, 0, 0)},
			--	{SegmentsDesiredAmt = 10, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
			--},
			Ent = "crossbow_projectile",
		},
		BulletFunctions = {
			-- Draw = draw_silk,
			OnStopped = onstopped_silk,
			--PreRemove = preremove_silk,
			--PostRemove = postremove_silk,
		},
	},
	["arrow"] = {
		name = "Arrow",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 5,
		maxcarry = 40,
		minsplash = 10,
		maxsplash = 5,
		TracerSetings = {
			MaxPathPoints = 4,
			TracerWidth = 5,
			TracerColor = Color(15, 15, 15),
		},
		BulletSettings = {
			Mass = 40,
			Icon = matRfileAmmo,
			Damage = 35,
			Speed = 5,
			PhysPenetrationMul = 0.0,
		},
		FunctionInfo = {
			Model = "models/z_city/nmrih/items/arrow/ammo_arrow_single.mdl",
			--DesiredSilks = {	--; WARNING POINTER
			--	{SegmentsDesiredAmt = 5, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
			--	{SegmentsDesiredAmt = 6, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2.1, 0, 0)},
			--	{SegmentsDesiredAmt = 10, SegmentsDesiredWidth = 1, SegmentsDesiredLength = 3, EntityOffset = Vector(2, 0, 0)},
			--},
			Ent = "arrow_projectile",
		},
		BulletFunctions = {
			-- Draw = draw_silk,
			OnStopped = arrow_hit,
			--PreRemove = preremove_silk,
			--PostRemove = postremove_silk,
		},
	},
	["grenade_30x29mm"] = {
		name = "Grenade 30x29mm",
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 150,
		maxcarry = 120,
		minsplash = 10,
		maxsplash = 5,
		TracerSetings = {
			MaxPathPoints = 5,
		},
		BulletSettings = {
			Mass = 200,
			PhysPenetrationMul = 0.0,
			-- Speed = 185,
			Speed = 55,	--; Comically slow
			LifeTime = 15,
			Shell = "12guage",
			Icon = matRfileAmmo
		},
		FunctionInfo = {
			Model = "models/Items/AR2_Grenade.mdl",
			-- Ent = "crossbow_projectile",
		},
		BulletFunctions = {
			Draw = draw_explosive,
			OnStopped = onstopped_explosive,
			PreRemove = preremove_explosive,
		},
	},
	["pulse"] = {
		name = "Pulse",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 120,
		maxcarry = 120,
		minsplash = 16,
		maxsplash = 16,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 25,
			TracerLength = 150,
			TracerWidth = 1.5,
			TracerColor = Color(155, 232, 255),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 50,
			Force = 50,
			Penetration = 17,
			Shell = "Pulse",
			Speed = 1000,
			Diameter = 10,
			Mass = 10,
			Icon = matRfileAmmo,
			noricochet = true,
		}
	},
	["blood"] = {
		name = "Blood",
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		noentity = true,
		plydmg = 0,
		npcdmg = 0,
		force = 120,
		maxcarry = 120,
		minsplash = 16,
		maxsplash = 16,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 25,
			TracerLength = 150,
			MaxPathPoints = 10,
			TracerWidth = 4.5,
			TracerColor = Color(255, 0, 0),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
		BulletSettings = {
			Damage = 0,
			Force = 50,
			Penetration = 17,
			-- Shell = "Pulse",
			Speed = 1000,
			Diameter = 10,
			Mass = 10,
			Icon = matRfileAmmo
		},
		BulletFunctions = {
			-- Hit = hit_blood,
			OnStopped = onstopped_blood,
			PostRicochet = postricochet_blood,
			PostPenetration = postpenetration_blood,
		}
	},
	["tasercartridge"] = {
		name = "Taser Cartridge",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 120,
		maxcarry = 120,
		minsplash = 16,
		maxsplash = 16,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 25,
			TracerLength = 150,
			TracerWidth = 1.5,
			TracerColor = Color(155, 232, 255),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 25000
		},
	},
	["metallicball"] = {
		name = "Metallic Ball",
		dmgtype = DMG_BULLET,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 230,
		maxcarry = 30,
		minsplash = 8,
		maxsplash = 10,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 5,
			TracerLength = 45,
			TracerWidth = 2.5,
			TracerColor = Color(90, 90, 90),
			TracerTPoint1 = 0.4,
			TracerTPoint2 = 1,
			TracerSpeed = 15000
		},
		BulletSettings = {
			Damage = 70,
			Force = 70,
			Penetration = 8,
			Shell = "",
			Speed = 450,
			Diameter = 19,
			Mass = 28,
			Icon = matShotgunAmmo
		}
	},
	["tranquilizerdarts"] = {
		name = "Tranquilizer Darts",
		dmgtype = DMG_CLUB,
		tracer = TRACER_LINE,
		plydmg = 0,
		npcdmg = 0,
		force = 50,
		maxcarry = 30,
		minsplash = 0,
		maxsplash = 0,
		TracerSetings = {
			TracerBody = Material("particle/fire"),
			TracerTail = Material("effects/laser_tracer"),
			TracerHeadSize = 1.5,
			TracerLength = 155,
			TracerWidth = 5,
			TracerColor = Color(37, 78, 36),
			TracerTPoint1 = 0.25,
			TracerTPoint2 = 1,
			TracerSpeed = 3000,
			NoSpin = true,
		},
		BulletSettings = {
			Damage = 5,
			Force = 10,
			Penetration = 0,
			Shell = "9x19",
			Spread = Vector(0, 0, 0),
			Speed = 650,
			AirResistMul = 0.0002,
			Diameter = 9,
			Mass = 18,
			Icon = matPistolAmmo,
			tranquilizer = true,
		}
	},
}

local ammotypes = hg.ammotypes

--[[
name = "5.56x45 mm",

name = "7.62x39 mm",

name = "5.45x39 mm",

name = "12/70 gauge",

name = "12/70 beanbag",

name = "9x19 mm Parabellum",

name = ".45 Rubber",

name = "4.6×30 mm",

name = "5.7×28 mm",

name = ".44 Remington Magnum",

name = "9x39 mm",

name = ".50 Action Express",

name = "7.62x51 mm",

name = "7.62x54 mm",

name = ".338 Lapua Magnum"
]]
local ammoents = {
	["5.56x45mm"] = {
		Material = "models/hmcd_ammobox_556",
		Scale = 1
	},
	["5.56x45mmap"] = {
		Model = "models/zcity/ammo/ammo_556x45_ap.mdl",
		Scale = 1,
	},
	["5.56x45mmm856"] = {
		Material = "models/hmcd_ammobox_556",
		Scale = 1,
		Color = Color(255,0,0)
	},
	["7.62x39mm"] = {
		Model = "models/items/ammo_76239.mdl",
		Scale = 1
	},
	["7.62x51mm"] = {  
		Model = "models/items/ammo_76251.mdl",
		Scale = 1,
		Count = 25,
	},
	["7.62x51mmm993"] = {  
		Model = "models/items/ammo_76251.mdl",
		Scale = 1,
		Count = 25,
	},
	["7.62x54mm"] = {
		Model = "models/zcity/ammo/ammo_762x54_7h1.mdl",
		Scale = 1,
		Count = 25,
	},
	["7.62x39mmsp"] = {
		Model = "models/zcity/ammo/ammo_762x54_7h1.mdl",
		Scale = 1,
		Count = 25,
		Color = Color(14,54,22)
	},
	["7.62x39mmbp"] = {
		Model = "models/zcity/ammo/ammo_762x54_7h1.mdl",
		Scale = 1,
		Count = 25,
		Color = Color(14,54,22)
	},
	[".366tkm"] = {
		Model = "models/items/ammo_76239.mdl",
		Scale = 1
	},
	["5.45x39mm"] = {
		Model = "models/zcity/ammo/ammo_545x39_fmj.mdl",
		Scale = 1,
	},
	["metal_debris"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
		Count = 12,
	},
	["12/70gauge"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
		Count = 12,
	},
	["12/70beanbag"] = {
		Model = "models/ammo/beanbag12_ammo.mdl",
		Scale = 1,
		Count = 12,
	},
	["12/70slug"] = {
		Model = "models/zcity/ammo/ammo_12x76_zhekan.mdl",
		Scale = 1.1,
		Count = 12,
		Color = Color(125, 155, 95)
	},
	["12/70rip"] = {
		Model = "models/zcity/ammo/ammo_12x76_zhekan.mdl",
		Scale = 1.1,
		Count = 12,
		Color = Color(22, 168, 221)
	},
	["12/70blank"] = {
		Model = "models/ammo/beanbag12_ammo.mdl",
		Scale = 1,
		Count = 12,
		Color = Color(22, 168, 221)
	},
	["23x75sh10"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.2,
		Count = 12,
	},
	["23x75sh25"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.2,
		Count = 12,
	},
	["23x75barricade"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.2,
		Count = 12,
	},
	["23x75zvezda"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.2,
		Count = 12,
	},
	["23x75waver"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.2,
		Count = 12,
	},
	["20/70gauge"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
		Count = 12,
		Color = Color(255,150,0)
	},
	["20/70slug"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
		Count = 12,
		Color(0,84,0)
	},
	["20/70flechette"] = {
		Material = "models/hmcd_ammobox_12",
		Scale = 1.1,
		Count = 12,
		Color = Color(154,154,154)
	},
	["9x18mm"] = {
		Model = "models/zcity/ammo/ammo_9x18_pmm.mdl",
		Scale = 1
	},
	["9x17mm"] = {
		Model = "models/zcity/ammo/ammo_9x18_pmm.mdl",
		Scale = 1
	},
	["9x19mmparabellum"] = {
		Material = "models/hmcd_ammobox_9",
		Scale = 0.8,
	},
	["9x19mmgreentracer"] = {
		Material = "models/hmcd_ammobox_9",
		Color = Color(0, 255, 0),
		Scale = 0.8
	},
	["9x19mmqm"] = {
		Material = "models/hmcd_ammobox_9",
		Color = Color(0, 26, 255),
		Scale = 0.8
	},
	[".45rubber"] = {
		Model = "models/ammo/beanbag9_ammo.mdl",
		Scale = 1
	},
	["9mmpakblank"] = {
		Model = "models/ammo/beanbag9_ammo.mdl",
		Scale = 1
	},
	["9mmpakflashdefense"] = {
		Model = "models/ammo/beanbag9_ammo.mdl",
		Scale = 1
	},
	["18x45mmtraumatic"] = {
		Model = "models/zcity/ammo/ammo_12x70_buck.mdl",
		Scale = 0.8,
		Color = Color(87, 110, 82),
		Count = 4,
	},
	["18x45mmflashdefense"] = {
		Model = "models/zcity/ammo/ammo_12x76_dart.mdl",
		Scale = 0.8,
		Color = Color(119, 47, 47),
		Count = 4,
	},
	["4.6x30mm"] = {
		Model = "models/4630_ammobox.mdl",
		Scale = 1,
	},
	[".44remingtonmagnum"] = {
		Material = "models/hmcd_ammobox_22",
		Color = Color(125, 155, 95),
		Scale = 0.8,
		Count = 20,
	},
	[".357magnum"] = {
		Model = "models/Items/357ammobox.mdl",
		Scale = 0.5,
		Count = 20,
	},
	[".38special"] = {
		Material = "models/hmcd_ammobox_38",
		Color = Color(255, 255, 255),
		Scale = 0.8,
		Count = 20,
	},
	["9x39mm"] = {
		Model = "models/zcity/ammo/ammo_9x39_sp5.mdl",
		Scale = 1,
		Count = 20,
	},
	["5.7x28mm"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1.2,
		Color = Color(125, 155, 95)
	},
	[".50actionexpress"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
		Color = Color(255, 255, 125),
		Count = 20,
	},
	[".50actionexpressjhp"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
		Color = Color(73, 73, 32),
		Count = 20,
	},
	[".50actionexpresscopper"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
		Color = Color(245, 149, 5),
		Count = 20,
	},
	["14.5x114mmbztm"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
		Color = Color(246, 129, 5),
		Count = 20,
	},
	["14.5x114mmb32"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1,
		Color = Color(55, 55, 2),
		Count = 20,
	},
	[".338lapuamagnum"] = {
		Material = "models/hmcd_ammobox_792",
		Scale = 1,
		Color = Color(125, 255, 125),
		Count = 20,
	},
	["12.7x108mm"] = {
		Material = "models/hmcd_ammobox_792",
		Scale = 1.6,
		Color = Color(225, 122, 125),
		Count = 20,
	},
	["12.7x55mm"] = {
		Material = "models/hmcd_ammobox_792",
		Scale = 1.2,
		Color = Color(204, 241, 140),
		Count = 20,
	},
	[".22longrifle"] = {
		Material = "models/hmcd_ammobox_22",
		Scale = 1
	},
	["rpg-7projectile"] = {
		Model = "models/weapons/tfa_ins2/w_rpg7_projectile.mdl",
		Count = 1
	},
	["nails"] = {
		Material = "models/hmcd_nails",
		Scale = 1,
		Count = 3,
	},
	["armature"] = {
		Model = "models/Items/CrossbowRounds.mdl",
		Count = 5
	},
	["arrow"] = {
		Model = "models/z_city/nmrih/items/arrow/ammo_arrow_box.mdl",
		Count = 5
	},
	["grenade_30x29mm"] = {
		Model = "models/Items/BoxMRounds.mdl",
		Count = 15
	},
	["pulse"] = {
		Model = "models/Items/combine_rifle_cartridge01.mdl",
		Count = 30
	},
	["tasercartridge"] = {
		Model = "models/ammo/taser_ammo.mdl",
		Count = 1,
		Material = "models/defcon/taser/taser",
	},
	[".45acp"] = {
		Model = "models/zcity/ammo/ammo_1143x23_fmj.mdl"
	},
	[".45acphydroshock"] = {
		Model = "models/zcity/ammo/ammo_1143x23_hydro.mdl"
	},
	["7.65x17mm"] = {
		Model = "models/zcity/ammo/ammo_1143x23_fmj.mdl"
	},
	[".40sw"] = {
		Model = "models/zcity/ammo/ammo_1143x23_hydro.mdl"
	},
	["metallicball"] = {
		Model = "models/hunter/misc/sphere025x025.mdl",
		Material = "models/mat_jack_dullscratchedmetal",
		Scale = 0.25,
		Count = 1
	},
	["tranquilizerdarts"] = {
		Material = "models/hmcd_ammobox_9",
		Scale = 0.8,
	},
}

hg.ammoents = ammoents

local function addAmmoTypes()
	for name, tbl in pairs(ammotypes) do
		game.AddAmmoType(tbl)
		
		if(!tbl.noentity)then
			if CLIENT then language.Add(tbl.name .. "_ammo", tbl.name) end
			local ammoent = {}
			ammoent.Base = "ammo_base"
			ammoent.PrintName = tbl.name
			ammoent.Category = "ZCity Ammo"
			ammoent.Spawnable = true
			ammoent.AmmoCount = ammoents[name].Count or 30
			ammoent.AmmoType = tbl.name
			ammoent.Model = ammoents[name].Model or "models/props_lab/box01a.mdl"
			ammoent.ModelMaterial = ammoents[name].Material or ""
			ammoent.ModelScale = ammoents[name].Scale or 1
			ammoent.Color = ammoents[name].Color or Color(255, 255, 255)
			scripted_ents.Register(ammoent, "ent_ammo_" .. name)
		end
	end

	game.BuildAmmoTypes()
	--PrintTable(game.GetAmmoTypes())
end

addAmmoTypes()
hook.Add("Initialize", "init-ammo", addAmmoTypes)

--коэффициент лобового сопротивления также можно рассчитать математически
--11300 - плотность свинца в кг/м3
for i,tbl in pairs(ammotypes) do
	if not tbl.BulletSettings or not tbl.BulletSettings.Diameter or not tbl.BulletSettings.Speed then continue end
	local coef = 8 / (1.2255 * (tbl.BulletSettings.Speed^2) * math.pi * ((tbl.BulletSettings.Diameter / 1000)^2))
	tbl.BulletSettings.AirResistanceCoef = coef
	--local ballistic_coef = tbl.BulletSettings.Mass / 1000 / coef / (math.pi * (tbl.BulletSettings.Diameter / 1000 / 2)^2)
	--неверно
	--print(i,coef,ballistic_coef)
end

local ammotypeshuy = {}
for i,tbl in pairs(table.Copy(ammotypes)) do
	ammotypeshuy[tbl.name] = tbl
	ammotypeshuy[tbl.name].name = i
end

hg.ammotypeshuy = ammotypeshuy

local ammotypesallowed = {}
for i,tbl in pairs(table.Copy(ammotypeshuy)) do
	if not tbl.allowed then continue end
	ammotypesallowed[i] = tbl
end

hg.ammotypesallowed = ammotypesallowed

if CLIENT then
    local blurMat = Material("pp/blurscreen")
    local Dynamic = 0
	local red = Color(75,25,25)
	local panclr = Color( 0, 0, 0, 140)

	local gradient_u = Material("vgui/gradient-u")
	local gradient_d = Material("vgui/gradient-d")
	BlurBackground = hg.DrawBlur

	local function PaintInnerFrame(self,w,h)
		BlurBackground(self)
		surface.SetDrawColor(80, 0, 0, 155)
		surface.SetMaterial(gradient_d)
		surface.DrawTexturedRect( 0, 0, w, h )
	end

	local function PaintButton(self,w,h)
		BlurBackground(self)
		surface.SetDrawColor(155, 0, 0, 155)
		surface.SetMaterial(gradient_u)
		surface.DrawTexturedRect( 0, 0, w, h )
	end

    function AmmoMenu(ply)
        local ammodrop = 0
        if !ply:Alive() then return end
        local Frame = vgui.Create( "ZFrame" )
        Frame:SetTitle( "" ) -- "Ammunition"
        Frame:SetSize( 200,300 )
        Frame:Center()			
        Frame:MakePopup()
		Frame:SetVisible(false)

        local DPanel = vgui.Create( "DScrollPanel", Frame )
        DPanel:SetPos( 5, 30 ) -- Set the position of the panel
        DPanel:SetSize( 190, 215 ) -- Set the size of the panel
        DPanel.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
			PaintInnerFrame(self, w, h)
            draw.RoundedBox( 0, 0, 0, w, h, panclr )
        end

        local DermaNumSlider = vgui.Create( "DNumSlider", Frame )
        DermaNumSlider:SetPos( 10, 245 )
        DermaNumSlider:SetSize( 210, 25 )
        DermaNumSlider:SetMin( 0 )
        DermaNumSlider:SetMax( 60 )
        DermaNumSlider:SetDecimals( 0 )

        -- If not using convars, you can use this hook + Panel.SetValue()
        DermaNumSlider.OnValueChanged = function( self, value )
            ammodrop = math.Round(value)
        end

        local ammos = LocalPlayer():GetAmmo()

        for k,v in pairs(ammos) do
            local DermaButton = vgui.Create( "DButton", DPanel ) 
            DermaButton:SetText( game.GetAmmoName( k )..": "..v )	
            DermaButton:SetTextColor( Color(255,255,255) )	
			DermaButton:SetFont("HomigradFontVSmall")
            DermaButton:SetPos( 0, 0 )	
            DermaButton:Dock( TOP )
            DermaButton:DockMargin( 2, 2.5, 2, 0 )	
            DermaButton:SetSize( 120, 25 )

            DermaButton.Paint = function( self, w, h ) -- 'function Frame:Paint( w, h )' works too
				PaintButton(self, w, h)
                DermaButton.a = Lerp(0.1,DermaButton.a or 100,DermaButton:IsHovered() and 180 or 100)
				draw.RoundedBox(0, 0, 0, w, h, Color(red.r,red.g,red.b,DermaButton.a))
                --BlurBackground(DermaButton)
            end				
            DermaButton.DoClick = function()
                --print( math.min(ammodrop,v),game.GetAmmoName( k ))				
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(ammodrop,v) )
                net.SendToServer()
                Frame:Close()
            end

            DermaButton.DoRightClick = function()
                net.Start( "drop_ammo" )
                    net.WriteFloat( k )
                    net.WriteFloat( math.min(v,v) )
                net.SendToServer()
                Frame:Close()
            end
        end
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 10, 268 )
		DLabel:SetTextColor(color_white)
        DLabel:SetText( "LMB - Drop count\nRMB - Drop all" )
		DLabel:SetFont("HomigradFontVSmall")
        DLabel:SizeToContents()
        local DLabel = vgui.Create( "DLabel", Frame )
        DLabel:SetPos( 10, 252 )
		DLabel:SetTextColor(color_white)
        DLabel:SetText( "Count: " )
		DLabel:SetFont("HomigradFontVSmall")
        DLabel:SizeToContents()
		Frame:SlideDown(0.5)
    end

    concommand.Add( "hg_ammomenu", function( ply, cmd, args )
        AmmoMenu(ply)
    end )

	hook.Add("radialOptions", "hg-ammomenu", function()
		local organism = LocalPlayer().organism or {}
		if not organism.otrub and table.Count(LocalPlayer():GetAmmo()) > 0 then
			hg.radialOptions[#hg.radialOptions + 1] = {
				function()
					RunConsoleCommand("hg_ammomenu")

					return 0
				end,
				"Drop Ammo"
			}
		end
	end)
end

if SERVER then
    util.AddNetworkString( "drop_ammo" )

    net.Receive( "drop_ammo", function( len, ply )
        if !ply:Alive() or ply.organism.otrub or !ply.organism.canmove then return end
        local ammotype = net.ReadFloat()
        local count = net.ReadFloat()
        local pos = ply:EyePos()+ply:EyeAngles():Forward()*15
        if ply:GetAmmoCount(ammotype)-count < 0 then ply:ChatPrint(((math.random(1,100) == 100 or 1) and "I need mor booolets!!!" ) or "You don't have enogh ammo") return end
        if count < 1 then ply:ChatPrint("You can't drop zero ammo") return end
			--if not ammolistent[ammotype] then ply:ChatPrint("Invalid entitytype...") return end
			--print(game.GetAmmoName(ammotype))
		
        local AmmoEnt = ents.Create( "ent_ammo_"..string.lower( string.Replace(game.GetAmmoName(ammotype)," ", "") ) )
		if not IsValid(AmmoEnt) then
			ply:ChatPrint("Invalid entitytype...")
		else
			AmmoEnt:SetPos( pos )
			AmmoEnt:Spawn()
			AmmoEnt.AmmoCount = count
			local phys = AmmoEnt:GetPhysicsObject()
			if IsValid(phys) then
				phys:SetMass((game.GetAmmoForce(ammotype) * count) / 1500)
			end
		end
        ply:SetAmmo(ply:GetAmmoCount(ammotype)-count,ammotype)
        ply:EmitSound("snd_jack_hmcd_ammobox.wav", 75, math.random(80,90), 1, CHAN_ITEM )
		ply.inventory.Ammo = ply:GetAmmo()
		ply:SetNetVar("Inventory",ply.inventory)
    end)
end