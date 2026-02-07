local CLASS = player.RegClass("Slugcat")

function CLASS.Off(self)
    self:SetNWString("scug", nil)

    if self.oldspeed then
        self:SetRunSpeed(self.oldspeed)
        self.oldspeed = nil
    end

    self.JumpPowerMul = nil
    self.SpeedGainClassMul = nil
    self.MeleeDamageMul = nil
    self.StaminaExhaustMul = nil
end

local scugs = {
    ["normal"] = "models/crusader/rainworld/scug.mdl",
    ["arti"] = "models/crusader/rainworld/scugarti.mdl",
    ["gourm"] = "models/crusader/rainworld/scuggorm.mdl",
    ["riv"] = "models/crusader/rainworld/scugriv.mdl",
    ["saint"] = "models/crusader/rainworld/scugsaint.mdl",
}

local names = {
    ["normal"] = "Survivor",
    ["arti"] = "Artificer",
    ["gourm"] = "Gourmand",
    ["riv"] = "Rivulet",
    ["saint"] = "Saint",
}

local colors = {
    ["normal"] = Color(255,255,255),
    ["arti"] = Color(122,0,0),
    ["gourm"] = Color(223,180,125),
    ["riv"] = Color(104,199,255),
    ["saint"] = Color(0,165,49),
}

CLASS.NoGloves = true
CLASS.CanEmitRNDSound = false
function CLASS.FallDmgFunc(self, speed, tr)
    if speed > 1000 then
        hg.LightStunPlayer(self)
    end
    
    if speed > 250 then
        if tr.Entity:IsPlayer() then
            hg.drop(tr.Entity)
		    hg.LightStunPlayer(tr.Entity,2)
		    tr.Entity:TakeDamage(speed / 5 * (self.scug == "gourm" and 100 or 1),ply,ply)
        end
    end
end

function CLASS.On(self)
    local model, scug = table.Random(scugs)

    if SERVER then
        self:SetNWString("scug",scug)
    end

    if self:GetNWString("scug") == "riv" then
        self.oldspeed = self:GetRunSpeed()
        self:SetRunSpeed(1000)
        self.JumpPowerMul = 2
        self.SpeedGainClassMul = 5
    end

    if CLIENT then return end

    if scug == "gourm" then
        self.MeleeDamageMul = 3
        self.StaminaExhaustMul = 2
    end

    if scug == "saint" then
        self.MeleeDamageMul = 0.05
    end

    if zb.GiveRole then zb.GiveRole(self, names[scug], colors[scug]) end
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    self:SetModel(model)
    self:SetSubMaterial()
	self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance
end

function CLASS.Think(self)
    if CLIENT then return end

    local scug = self:GetNWString("scug")

    if scug == "arti" then
        local tr = util.QuickTrace(self:GetPos(),-vector_up * 15,self)
        if self.explodedasd and tr.Hit then
            self.explodedasd = nil
        end

        if self:KeyDown(IN_JUMP) and not self.explodedasd then
            if tr.Hit then
                self.pressedasd = true
            end
            
            if not self.pressedasd then
                --ParticleEffect("pcf_jack_airsplode_small3",self:GetPos(),vector_up:Angle())
                --hg.ExplosionEffect(self:GetPos(), 100, 80)
                local effectdata = EffectData()
                effectdata:SetOrigin(self:GetPos())
                effectdata:SetMagnitude(1)
                effectdata:SetScale(1)
                effectdata:SetFlags(0)
                util.Effect("Explosion",effectdata,nil,true)
                --[[net.Start("hg_booom")
                    net.WriteVector(self:GetPos())
                    net.WriteString("Normal")
                net.Broadcast()--]]
                local vel = self:GetVelocity()
                vel[3] = 0
                self:SetLocalVelocity(vel + vector_up * 500)
                self.explodedasd = true
                self.pressedasd = true
            end
        else
            self.pressedasd = nil
        end
    end
end

function CLASS.Move(self,mv)
    local scug = self:GetNWString("scug")
    if scug == "saint" then
        if self:KeyDown(IN_JUMP) then
            local licked = self:GetNetVar("licked")

            if licked then
                local pos = licked[1].HitPos
                local tr = hg.eyeTrace(self,1000)

                local dist = math.min(licked[2] - pos:Distance(tr.StartPos),0)

                if SERVER and (self.cooldownhuyhuyasd or 0) < CurTime() then
                    self.cooldownhuyhuyasd = CurTime() + 0.1

                    licked[2] = math.max(licked[2] - 5, 8)
                    self:SetNetVar("licked",licked)
                end

                --mv:SetVelocity( (mv:GetVelocity() / 250) + ( (dist * 1 ) * (tr.StartPos-pos):GetNormalized())  )
            elseif not self:OnGround() and self:KeyPressed(IN_JUMP) then
                local tr = hg.eyeTrace(self,1000)

                if tr.Hit and not tr.HitSky then
                    if SERVER then
                        self:SetNetVar("licked",{tr, tr.HitPos:Distance(tr.StartPos)})
                    end

                    local vel = self:GetVelocity()
                    vel[3] = 0
                    self:SetVelocity(vector_up * 600)
                end
            end
        else
            if self:GetNetVar("licked") and SERVER then
                self:SetNetVar("licked",nil)
            end
        end
    end
end

local collick = Color(204,88,88)
local mat = Material("color")
function CLASS.PlayerDraw(self)
    local scug = self:GetNWString("scug")
    if scug == "saint" then
        local tr = hg.eyeTrace(self)
        
        if self:GetNetVar("licked") then
            local pos = self:GetNetVar("licked")[1].HitPos
            render.SetMaterial(mat)
            render.DrawBeam(tr.StartPos - vector_up * 2,pos,2,0,10,collick)
        end
    end
end

if SERVER then
	local slugy_phrases = {
		"zcity/voice/slugcat_1/waw_1.mp3",
		"zcity/voice/slugcat_1/waw_2.mp3",
		"zcity/voice/slugcat_1/waw_3.mp3",
		"zcity/voice/slugcat_1/waw_4.mp3"
	}

	hook.Add("HG_ReplacePhrase", "ScugPhrases", function(ply, phrase, muffed, pitch)
		if IsValid(ply) then
			local wawer = string.match(ply:GetModel(), "scug")
			if wawer then
				return ply, slugy_phrases[math.random(#slugy_phrases)], muffed, pitch
			end
		end
	end)
end