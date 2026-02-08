local CLASS = player.RegClass("Gordon")

function CLASS.Off(self, equipment)
    if CLIENT then return end
    ApplyAppearance(self,nil,nil,nil,true)
    if CLIENT then return end
    self:SetNetVar("HEVPower", nil)
    self:SetNetVar("HEVSuit", nil)
    self.HEV = nil
    self.organism.recoilmul = 1
    self.organism.CantCheckPulse = nil
end

CLASS.NoFreeze = true
CLASS.NoGloves = true
CLASS.CanEmitRNDSound = false

local model = "models/gfreakman/gordonf_highpoly.mdl"

local maxMorphine = 4
local maxMedicine = 600
local maxPower = 100

local function hevchanged(ply)
    if not ply.HEV or not ply.HEV.Power then return end

    local hevpow = (ply.HEV.Power / maxPower)
    ply.organism.recoilmul = 1 - 0.8 * hevpow
    ply.organism.meleespeed = 1 + 1 * hevpow
    ply.organism.stamina.regen = 1 + 3 * hevpow
end

local function createhev(ply)
    ply.organism.recoilmul = 0.2
    ply.organism.meleespeed = 2
    ply.HEV = {}
    ply.HEV.Morphine = maxMorphine
    ply.HEV.Medicine = maxMedicine
    ply.HEV.Power = maxPower * (0.75)
    ply.organism.HEV = ply.HEV
    ply:SetNetVar("HEVMedicine", ply.HEV.Medicine)
    ply:SetNetVar("HEVPower", ply.HEV.Power)
    ply:SetNetVar("HEVSuit", true)
    ply:SetModel(model)
    ply:SetSubMaterial()
    ply:SetBodygroup(2, 2)

    ply.organism.CantCheckPulse = true
    ply.armors = {}
    ply.armors["torso"] = "gordon_armor"
    ply.armors["head"] = "gordon_helmet"
    ply:SyncArmor()
    
    local Appearance = ply.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""
    ply:SetNetVar("Accessories", "")
    ply.CurAppearance = Appearance

    hevchanged(ply)
end

function CLASS.On(self, data)
    if CLIENT then return end
    local equipment = data and data.equipment
    local bRestored = data and data.bRestored 
    ApplyAppearance(self,nil,nil,nil,true)
    local Appearance = self.CurAppearance or hg.Appearance.GetRandomAppearance()
    Appearance.AAttachments = ""
    Appearance.AColthes = ""

    self:SetNetVar("Accessories", "")
    self.CurAppearance = Appearance
    
    self:SetModel("models/humans/gordon/group01/gordoncitizen.mdl")--gordon without HEV
    self:SetNWString("PlayerName", "Gordon")
    self:SetPlayerColor(Color(246, 139, 0):ToVector())
    self:SetSubMaterial()

    if equipment then
        if equipment == "rebel" then
            local wep = self:Give(math.random(2) == 1 and "weapon_osipr" or "weapon_akm")
            self:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)

            local wep = self:Give(math.random(2) == 1 and "weapon_hk_usp" or "weapon_revolver357")
            self:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)

            self:Give("weapon_hg_crowbar")--GORDON FREEMAN SAVED MY LIFE

            self:Give("weapon_physcannon")

            local wep = self:Give("weapon_hg_hl2nade_tpik")
            wep.count = 3
            
            self:Give("weapon_hg_slam")
            self:Give("weapon_walkie_talkie")
        elseif equipment == "refugee" then
            if game.GetMap() ~= "d1_trainstation_06" then
                if game.GetMap() ~= "d1_canals_01" then
                    local wep = self:Give("weapon_hk_usp")
                    self:GiveAmmo(wep:GetMaxClip1() * 3, wep:GetPrimaryAmmoType(), true)
                end

                self:Give("weapon_hg_crowbar")
            end
        end
    end

    if equipment != "citizen" and not bRestored then
        timer.Simple(1,function()
            for i,ent in pairs(ents.FindByClass("item_suit")) do
                ent:Remove()
            end
        end)

        createhev(self)
    elseif bRestored then
        if self.organism then
            self.organism.recoilmul = 0.2
            self.organism.meleespeed = 2
        end
        self.HEV = self.HEV or {}
        self.HEV.Morphine = self.HEV.Morphine or maxMorphine
        self.HEV.Medicine = self.HEV.Medicine or maxMedicine
        self.HEV.Power = self.HEV.Power or (maxPower * 0.75)
        if self.organism then
            self.organism.HEV = self.HEV
            self.organism.CantCheckPulse = true
        end
        self:SetNetVar("HEVMedicine", self.HEV.Medicine)
        self:SetNetVar("HEVPower", self.HEV.Power)
        self:SetNetVar("HEVSuit", true)
        self:SetModel(model)
        self:SetSubMaterial()
        self:SetBodygroup(2, 2)
        
        self.armors = self.armors or {}
        if not self.armors["torso"] then
            self.armors["torso"] = "gordon_armor"
        end
        if not self.armors["head"] then
            self.armors["head"] = "gordon_helmet"
        end
        self:SyncArmor()
        hevchanged(self)

        --print("JOOOPAAAA")
    end
end

if SERVER then
    hook.Add("PostCleanupMap","huyhuygordonspasjizn",function(ent)
        timer.Simple(1,function()
            for i, ent in ents.Iterator() do
                if ent:GetClass() == "item_suitcharger" then
                    local entnew = ents.Create("prop_physics")
                    entnew:SetModel(ent:GetModel())
                    entnew:SetPos(ent:GetPos())
                    entnew:SetAngles(ent:GetAngles())
                    entnew.armorcharger = true
                    entnew.power = 100
                    entnew:Spawn()
        
                    local phys = entnew:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:EnableMotion(false)
                    end
        
                    timer.Simple(0.1,function()
                        ent:Remove()
                    end)
                end
        
                if ent:GetClass() == "item_healthcharger" then
                    local entnew = ents.Create("prop_physics")
                    entnew:SetModel(ent:GetModel())
                    entnew:SetPos(ent:GetPos())
                    entnew:SetAngles(ent:GetAngles())
                    entnew.healthcharger = true
                    entnew.power = 100
                    entnew:Spawn()
                    
                    local phys = entnew:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:EnableMotion(false)
                    end
        
                    timer.Simple(0.1,function()
                        ent:Remove()
                    end)
                end
            end
        end)
    end)
end

hook.Add("Player Think","health_armor_gordonthings",function(ply)
    if not (ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit")) then return end
    local ent = hg.eyeTrace(ply).Entity
    if not (ent.armorcharger or ent.healthcharger) then return end
    if (ent.ThinkCharge or 0) > CurTime() then return end
    ent:SetCycle(1 - ent.power / 100)

    if not ply:KeyDown(IN_USE) then
        ply.keypresseduse = nil
        if ent.snd then ent:StopLoopingSound(ent.snd) ent.snd = nil end
        return
    end

    ent.ThinkCharge = CurTime() + 0.25
    
    if ent.power > 0 then
        timer.Create("huasd"..ent:EntIndex(),1,1,function()
            if ent.snd then ent:StopLoopingSound(ent.snd) ent.snd = nil end
        end)

        if ent.armorcharger then
            local noneedarmor = ply.HEV.Power == maxPower
            if noneedarmor then
                if not ply.keypresseduse then
                    ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
                end
                ply.keypresseduse = true
                if ent.snd then ent:StopLoopingSound(ent.snd) ent.snd = nil end
                return
            end

            if not ply.keypresseduse then
                ent:EmitSound("items/suitchargeok1.wav")
                
                ent.snd = ent:StartLoopingSound("items/suitcharge1.wav")
            end

            ply.HEV.Power = math.min(ply.HEV.Power + 1, maxPower)
            ply:SetNetVar("HEVPower", ply.HEV.Power)
            hevchanged(ply)
            ent.power = ent.power - 1
        else
            local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == maxMedicine) and (ply.HEV.Morphine == maxMorphine)
            
            if noneedhealth then
                if not ply.keypresseduse then
                    ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
                end
                ply.keypresseduse = true
                if ent.snd then ent:StopLoopingSound(ent.snd) ent.snd = nil end
                return
            end

            if not ply.keypresseduse then
                ent:EmitSound("items/medshot4.wav")
                
                ent.snd = ent:StartLoopingSound("items/medcharge4.wav")
            end

            ply.HEV.Medicine = math.min(ply.HEV.Medicine + 5, maxMedicine)
            ply.HEV.Morphine = math.min(ply.HEV.Morphine + 0.01, maxMorphine)
            ply:SetHealth(math.min(ply:Health() + 1,100))
            ent.power = ent.power - 1
        end
    else
        if not ply.keypresseduse then
            ent:EmitSound(ent.armorcharger and "items/suitchargeno1.wav" or "items/medshotno1.wav")
        end
        if ent.snd then ent:StopLoopingSound(ent.snd) ent.snd = nil end
    end
    
    ply.keypresseduse = true
end)

hook.Add("WeaponEquip","pickuplom",function(wep,ply)
    if ply.PlayerClassName == "Gordon" and wep:GetClass() == "weapon_hg_crowbar" then
        wep:Remove()
		local bar = ply:Give("weapon_hg_crowbar_gordon")
		ply:SelectWeapon(bar)
	elseif ply.PlayerClassName ~= "Gordon" and wep:GetClass() == "weapon_hg_crowbar_gordon" then -- не достоен
		wep:Remove()
		local bar = ply:Give("weapon_hg_crowbar")
		ply:SelectWeapon(bar)
	end
end)

hook.Add("HG_CanThoughts", "GordonCantDumat", function(ply)
	if ply.PlayerClassName == "Gordon" then
		return false
	end
end)

hook.Add("PlayerCanPickupItem","hevsuit",function(ply, ent)
    local entclass = ent:GetClass()
    if entclass == "item_suit" then
        if ply.PlayerClassName == "Gordon" and not ply:GetNetVar("HEVSuit") then
            createhev(ply)
        else
            return false
        end
    end

    if entclass == "item_healthvial" then
        if ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit") then
            local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == maxMedicine) and (ply.HEV.Morphine == maxMorphine)
            if noneedhealth then return false end
            ply.HEV.Medicine = math.min(ply.HEV.Medicine + 100, maxMedicine)
            if ply:Health() == 100 then ply:SetHealth(99) end
        else
            return false
        end
    end

    if entclass == "item_healthkit" then
        if ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit") then
            local noneedhealth = (ply:Health() == 100) and (ply.HEV.Medicine == maxMedicine) and (ply.HEV.Morphine == maxMorphine)
            if noneedhealth then return false end
            ply.HEV.Medicine = math.min(ply.HEV.Medicine + 250, maxMedicine)
            ply.HEV.Morphine = math.min(ply.HEV.Morphine + 1, maxMorphine)
            if ply:Health() == 100 then ply:SetHealth(99) end
        else
            return false
        end
    end

    if entclass == "item_battery" then
        if ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit") then
            local noneedarmor = ply.HEV.Power == maxPower
            if noneedarmor then return false end
            ply.HEV.Power = math.min(ply.HEV.Power + 25, maxPower)
            ply:SetNetVar("HEVPower", ply.HEV.Power)
            ply:SetArmor(0)
            hevchanged(ply)
        else
            return false
        end
    end
end)

hook.Add("HomigradDamage","takesomearmor",function(ply,dmginfo,hitgroup,ent,harm)
    if not (ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit")) then return end

    if dmginfo:IsDamageType(DMG_FALL + DMG_DROWN + DMG_POISON + DMG_RADIATION) then return end

    local sub = math.Round(dmginfo:GetDamage() / 4,0)
    ply.HEV.Power = math.Clamp(ply.HEV.Power - sub, 0, maxPower)
    ply:SetNetVar("HEVPower", ply.HEV.Power)

    hevchanged(ply)
end)

if CLIENT then
    local BGColor = Color(0,0,0,255)

    local function drawBGPanel(PosX,PosY,alpha)
        local sizeW, sizeH = ScrW()*0.12, ScrH()*0.075
        local posW, posH = ScrW()*PosX, ScrH()*PosY - sizeH

        return {posW, posH}, {sizeW, sizeH}
    end
    local armorlerp = 0

    surface.CreateFont("HEVFontDefault",{
        font = "Bahnschrift",
        extended = true,
        size = ScreenScale(24),
        weight = 500,
        blursize = 0,
        scanlines = 2,
        antialias = true
    })

    surface.CreateFont("HEVFontSmall",{
        font = "Bahnschrift",
        extended = true,
        size = ScreenScale(7.5),
        weight = 1500,
        blursize = 0,
        scanlines = 2,
        antialias = true
    })

    surface.CreateFont("HEVFontSmallBG",{
        font = "Bahnschrift",
        extended = true,
        size = ScreenScale(7.5),
        weight = 500,
        blursize = 1,
        scanlines = 2,
        antialias = true
    })

    surface.CreateFont("HEVFontDefaultBG",{
        font = "Bahnschrift",
        extended = true,
        size = ScreenScale(24.5),
        weight = 1500,
        blursize = 1,
        scanlines = 2,
        antialias = true
    })

    local color_hp1 = Color(255,155,0)
    local color_crit = Color(255,0,0)
    local color_ar = Color(255,155,0)
    local color_glow = Color(255,155,0,0)
    local color_glow_ar = Color(255,155,0,0)
    local color_glow_ammo = Color(255,155,0,0)
    local color_bld = Color(255,155,0)
    local color_sight = Color(255,155,0,220) -- Color(240,240,240,255) uncomment for real hl2 crosshair
    local armorTxt = 0
    local hpTxt = 0
    local BloodTxt = 0
    local bloodlerp = 0
    local ammoTxt = 0
    local ammolerp = 0 
    local bloodOld = 5000
    local oldHpTxt = 0
    local oldArTxt = 0
    local oldAmmoTxt = 0
    local posSight = Vector(ScrW(),ScrH(),0)
    function CLASS.HUDPaint(self)
        if not self:Alive() then return end
        if not self:GetNetVar("HEVSuit") then return end
        --HP
        local FRT = FrameTime() * 5
        local pos, size = drawBGPanel(0.065,0.98)
        surface.SetFont("HEVFontDefault")
        local _,txtSizeY = surface.GetTextSize(math.Round(lply:GetNetVar("HEVMedicine",600)/6,0))
        hpTxt = math.min(hpTxt + 1, math.Round(lply:GetNetVar("HEVMedicine",600)/6,0))
        local color_bg = BGColor
        color_bg.a = 225
        draw.DrawText("000","HEVFontDefaultBG",pos[1]+size[1]*0.08 + 1,pos[2]+(size[2]/2) - txtSizeY/2 + 1,color_bg,TEXT_ALIGN_RIGHT)

        --draw.GlowingText(text, font, x, y, col, colglow, colglow2, align )
        color_glow.a = math.Round( Lerp( FRT, color_glow.a, oldHpTxt ~= hpTxt and 255 or 0 ) ) 

        local color_hp = color_hp1:Lerp(color_crit,(1-hpTxt/25)*math.abs(math.cos(CurTime()*2)))
        
        draw.GlowingText( hpTxt, "HEVFontDefault", pos[1]+size[1]*0.08, pos[2]+(size[2]/2) - txtSizeY/2, color_hp, color_glow, nil, TEXT_ALIGN_RIGHT)
        oldHpTxt = hpTxt

        draw.DrawText("Medicine","HEVFontSmall",pos[1]+size[1]*0.085+1,pos[2]+(size[2]/1.8)+1,color_bg,TEXT_ALIGN_LEFT)
        draw.DrawText("Medicine","HEVFontSmall",pos[1]+size[1]*0.085,pos[2]+(size[2]/1.8),color_hp,TEXT_ALIGN_LEFT)
        
        local armor = self:GetNetVar("HEVPower") or 0
        armorlerp = Lerp(FRT,armorlerp,armor > 1 and 1 or 0)
        local pos, size = drawBGPanel(0.17,0.98,125 * (armor > 1 and 1 or 0))
        surface.SetFont("HEVFontDefault")
        local _,txtSizeY = surface.GetTextSize(armor)
        local color_bg = BGColor
        color_bg.a = 225*armorlerp
        color_ar.a = 255*armorlerp
        armorTxt = math.min(armorTxt + 1, armor)
        draw.DrawText("000","HEVFontDefaultBG",pos[1]+size[1]*0.08 + 1,pos[2]+(size[2]/2) - txtSizeY/2 + 1,color_bg,TEXT_ALIGN_RIGHT)

        draw.DrawText(armorTxt,"HEVFontDefault",pos[1]+size[1]*0.08,pos[2]+(size[2]/2) - txtSizeY/2,color_ar,TEXT_ALIGN_RIGHT)
        color_glow_ar.a = math.Round( Lerp( FRT, color_glow_ar.a, oldArTxt ~= armorTxt and 255 or 0 ) ) 
        draw.GlowingText( armorTxt, "HEVFontDefault", pos[1]+size[1]*0.08, pos[2]+(size[2]/2) - txtSizeY/2, color_ar, color_glow_ar, nil, TEXT_ALIGN_RIGHT)
        oldArTxt = armorTxt
        draw.DrawText("Armor","HEVFontSmall",pos[1]+size[1]*0.085+1,pos[2]+(size[2]/1.8)+1,color_bg,TEXT_ALIGN_LEFT)
        draw.DrawText("Armor","HEVFontSmall",pos[1]+size[1]*0.085,pos[2]+(size[2]/1.8),color_ar,TEXT_ALIGN_LEFT)
        -- Sights
        local wep = self:GetActiveWeapon()
        if IsValid(wep) then
            if not IsValid(wep) or not wep.GetTrace then return end
            local tr = wep:GetTrace(true)
            posSight = LerpVector(FRT*5, posSight, Vector(tr.HitPos:ToScreen().x,tr.HitPos:ToScreen().y,0) )
            color_sight.a = Lerp(FRT*5,color_sight.a, lply:KeyDown(IN_ATTACK2) and 0 or 255)
			--[[ uncomment for real hl2 crosshair
				draw.RoundedBox(0, posSight.x - 1, posSight.y - 1, 1, 1, color_sight)
				draw.RoundedBox(0, posSight.x - 1, posSight.y + 6, 1, 1, color_sight)
				draw.RoundedBox(0, posSight.x - 1, posSight.y - 8, 1, 1, color_sight)
				draw.RoundedBox(0, posSight.x + 8, posSight.y - 1, 1, 1, color_sight)
				draw.RoundedBox(0, posSight.x - 10, posSight.y - 1, 1, 1, color_sight)
			]]
            draw.RoundedBox(0, posSight.x - 1, posSight.y + 2, 2, 6, color_sight)
            draw.RoundedBox(0, posSight.x - 1, posSight.y - 8, 2, 6, color_sight)
            draw.RoundedBox(0, posSight.x + 2, posSight.y - 1, 6, 2, color_sight)
            draw.RoundedBox(0, posSight.x - 8, posSight.y - 1, 6, 2, color_sight)
        end
        --Ammo
        if IsValid(wep) and wep.Clip1 then
            local FRT = FrameTime() * 5
            ammolerp = Lerp(FRT,ammolerp,wep:Clip1() < 0 and 0 or 1)
            local pos, size = drawBGPanel(0.93,0.98)
            surface.SetFont("HEVFontDefault")
            local _,txtSizeY = surface.GetTextSize(self:Armor())
            local color_bg = BGColor
            color_bg.a = 225*ammolerp
            color_ar.a = 255*ammolerp
            ammoTxt = math.min(ammoTxt + 1, wep:Clip1())
            draw.DrawText( "000", "HEVFontDefaultBG",pos[1]+size[1]*0.08 + 1,pos[2]+(size[2]/2) - txtSizeY/2 + 1,color_bg,TEXT_ALIGN_RIGHT)
            --draw.DrawText( ammoTxt, "HEVFontDefault",pos[1]+size[1]*0.08,pos[2]+(size[2]/2) - txtSizeY/2,color_ar,TEXT_ALIGN_RIGHT)

            color_glow_ammo.a = math.Round( Lerp( FRT, color_glow_ammo.a, oldAmmoTxt ~= ammoTxt and 255 or 0 ) ) 
            draw.GlowingText( ammoTxt, "HEVFontDefault", pos[1]+size[1]*0.08, pos[2]+(size[2]/2) - txtSizeY/2, color_ar, color_glow_ammo,nil, TEXT_ALIGN_RIGHT)
            oldAmmoTxt = ammoTxt

            draw.DrawText( "Ammo", "HEVFontSmall",pos[1]+size[1]*0.085+1,pos[2]+(size[2]/1.8)+1,color_bg,TEXT_ALIGN_LEFT)
            draw.DrawText( "Ammo", "HEVFontSmall",pos[1]+size[1]*0.085,pos[2]+(size[2]/1.8),color_ar,TEXT_ALIGN_LEFT)
        end
        --Blood
        local pos, size = drawBGPanel(0.035,0.93)
        surface.SetFont("HEVFontSmall")
        if not self.organism or not self.organism.blood then return end
        bloodlerp = Lerp(FRT,bloodlerp,self.organism.blood > 4900 and 0 or 1)
        bloodOld = self.organism.blood
        local _,txtSizeY = surface.GetTextSize(self.organism.blood)
        --print(self.organism.blood)
        BloodTxt = math.Round(math.min(BloodTxt + 25, self.organism.blood))

        local color_bg = BGColor
        color_bg.a = 125*bloodlerp
        color_bld.a = 255*bloodlerp
        
        draw.DrawText(BloodTxt,"HEVFontSmall",pos[1]+size[1]*-0.09,pos[2]+(size[2]/2),color_bg,TEXT_ALIGN_LEFT)
        draw.DrawText(BloodTxt,"HEVFontSmall",pos[1]+size[1]*-0.09,pos[2]+(size[2]/2),color_bld,TEXT_ALIGN_LEFT)
        draw.DrawText("Blood/Ml","HEVFontSmall",pos[1]+size[1]*0.085+1,pos[2]+(size[2]/2)+1,color_bg,TEXT_ALIGN_LEFT)
        draw.DrawText("Blood/Ml","HEVFontSmall",pos[1]+size[1]*0.085,pos[2]+(size[2]/2),color_bld,TEXT_ALIGN_LEFT)
    end

    local hevMat = Material("sprites/mat_jack_helmoverlay_r")
    hook.Add("RenderScreenspaceEffects","HEV_helmet",function()
        if not lply:GetNetVar("HEVSuit") then return end
        local armors = lply.armors
        if armors["head"] ~= "gordon_helmet" then return end
        if lply:Alive() and lply.PlayerClassName == "Gordon" then			
			surface.SetDrawColor(255,132,0,200)
			surface.SetMaterial(hevMat)
			surface.DrawTexturedRectRotated((ScrW()/2) - 5, (ScrH()/2) - 5, ScrW()  + 10, ScrH() + 450,180)
        end
        render.PushFilterMag(TEXFILTER.ANISOTROPIC)
        render.PushFilterMin(TEXFILTER.ANISOTROPIC)
            CLASS.HUDPaint(lply)
        render.PopFilterMag()
        render.PopFilterMin()
    end)

end

hook.Add("CanListenOthers", "GordonWeDontHearYou", function(talker)
    if talker:Alive() and talker.PlayerClassName == "Gordon" then
        return false, false 
    end
end)

hook.Add("HG_PlayerSay", "GordonWeDontSeeYouChat", function(ply, txtTbl, text)
    if ply:Alive() and ply.PlayerClassName == "Gordon" then
        txtTbl[1] = ""
    end
end)

if CLIENT then
    local queen = {}
    net.Receive("HEV_DAMAGE",function()
        local armors = lply.armors
        if not armors then return end
        if armors["head"] ~= "gordon_helmet" then return end
        queen[#queen + 1] = net.ReadString()
    end)
    local inPlaying = 0
    hook.Add("Think","HEV_Notify",function()
        local armors = lply.armors
        if !lply:Alive() and #queen > 0 then queen = {} return end
        if not armors then return end
        if armors["head"] ~= "gordon_helmet" then return end
        if inPlaying < CurTime() - 0.1 and queen[#queen] and !lply.organism.otrub then
            inPlaying = CurTime() + SoundDuration(queen[#queen])
            surface.PlaySound(queen[#queen])
            queen[#queen] = nil
        end
    end)

elseif SERVER then
    util.AddNetworkString("HEV_DAMAGE")

    local CheckBones = {
        "spine3",
        "spine2",
        "spine1",
        "rleg",
        "lleg",
        "rarm",
        "larm",
        "skull",
        "chest",
        "pelvis"
    }

    local phrases = {
        "Gordon Freeman has died. Now what?",
        "He's dead. Who will lead the way now?",
        "Gordon Freeman has failed his mission.",
        "What an unfortunate end to such a good employee.",
    }

    local hev_color = Color(255,125,0)
    local dead_color = Color(255,0,0)

    hook.Add("Org Think","gordon_healing",function(ply, org, timeValue)

        if org.HEV and not org.alive and not org.emitflatline then
            org.emitflatline = true
            hg.GetCurrentCharacter(ply):EmitSound("hl1/fvox/flatline.wav")

            if CurrentRound and CurrentRound().name == "coop" then
                if zChatPrint then
                    zChatPrint(dead_color, phrases[math.random(#phrases)])
                else
                    PrintMessage(HUD_PRINTTALK, phrases[math.random(#phrases)])
                end
            end
        end

        if not ply:IsPlayer() or not ply:Alive() then return end

        if ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit") then
            ply:SetNetVar("HEVMedicine", ply.HEV.Medicine)
            if org.brain > 0.1 then
                org.mannitol = org.brain * 2
                --ply, msg, delay, msgKey, showTime, func, clr)
                ply:Notify("HEV suit has detected a traumatic brain injury. Injecting mannitol.",true,"mannitol_hev",0.5,function(ply)
                    net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                    net.Send(ply)
                end, hev_color)
            else
                ply:ResetNotification("mannitol_hev")
            end

            if org.pneumothorax > 0 then
                org.lungsR[2] = 0
                org.lungsL[2] = 0
                org.pneumothorax = 0
                org.needle = 0

                ply:Notify("HEV suit has detected pneumothorax. Repairing.", true, "needle_hev", 0.5, function(ply)
                    net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                    net.Send(ply)
                end, hev_color)
            end
            
            local pain = org.pain + org.shock * 3
            if pain > 30 then
                if (org.NextMorphineInject or 0) < CurTime() then
                    org.NextMorphineInject = CurTime() + 10

                    local need = math.min(ply.HEV.Morphine, pain / 80)
                    local old = org.analgesia
                    org.analgesia = math.max(math.min(org.analgesia + need, pain / 80, 1), org.analgesia)
                    local administer = (org.analgesia - old)
                    ply.HEV.Morphine = ply.HEV.Morphine - administer
                    
                    if administer > 0.1 then
                        ply:Notify("HEV suit has detected pain receptors almost reaching the threshold. Injecting morphine.", 10, "morphine_hev", 0.5,
                        function(ply)
                            net.Start("HEV_DAMAGE")
                                net.WriteString("hl1/fvox/morphine_shot.wav")
                            net.Send(ply)
                        end, hev_color)
                    end
                end
            end

            if (org.CO > 10) or (org.COregen > 10) then
                ply:Notify("HEV suit has detected a carbon monoxide presence in the organism. Neutralising.",60,"co_hev",0.5,function(ply)
                    net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                    net.Send(ply)
                end, hev_color)

                if (org.COThink or 0) < CurTime() then
                    org.COThink = CurTime() + (1 / 120) * 60

                    if org.alive then
                        org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2, org.o2.range)
                        org.CO = math.Approach(org.CO, 0, 2)
                        org.COregen = math.Approach(org.COregen, 0, 2)
                    end
                end
            end

            if (org.BoneCheck or 0) < CurTime() then
                org.BoneCheck = CurTime() + 10

                local bonesfixed = false
                for _, v in ipairs(CheckBones) do
                    if org[v] > 0 then
                        local old = org[v]
                        org[v] = math.max(org[v] - ply.HEV.Medicine, 0) 
                        ply.HEV.Medicine = math.max(ply.HEV.Medicine - (old - org[v]) * 10, 0) 
                        
                        if old == 1 then bonesfixed = true end
                    end
                end

                if bonesfixed then
                    ply:Notify("HEV suit has detected fractures. Repairing.",60,"bones_hev",0.5,function(ply)
                        net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/automedic_on.wav")
                        net.Send(ply)
                    end, hev_color)
                end
            end

            if org.bleed > 5 then
                if (org.BleedThink or 0) < CurTime() then
                    org.BleedThink = CurTime() + 1

                    for i, wound in pairs(org.wounds) do
                        local old = wound[1]
                        wound[1] = math.max(wound[1] - 5, 0)
                        ply.HEV.Medicine = math.max(ply.HEV.Medicine - (-wound[1] + old), 0)
                    end
                end
            end
            
            if ply.HEV.Medicine > 300 then
                local regen = timeValue / 30

                org.lleg = math.max(org.lleg - regen, 0)
                org.rleg = math.max(org.rleg - regen, 0)
                org.rarm = math.max(org.rarm - regen, 0)
                org.larm = math.max(org.larm - regen, 0)
                org.chest = math.max(org.chest - regen, 0)
                org.pelvis = math.max(org.pelvis - regen, 0)
                org.spine1 = math.max(org.spine1 - regen, 0)
                org.spine2 = math.max(org.spine2 - regen, 0)
                org.spine3 = math.max(org.spine3 - regen, 0)
                org.skull = math.max(org.skull - regen, 0)
            
                org.liver = math.max(org.liver - regen, 0)
                org.intestines = math.max(org.intestines - regen, 0)
                org.heart = math.max(org.heart - regen, 0)
                org.stomach = math.max(org.stomach - regen, 0)
                org.lungsR[1] = math.max(org.lungsR[1] - regen, 0)
                org.lungsL[1] = math.max(org.lungsL[1] - regen, 0)
                org.lungsR[2] = math.max(org.lungsR[2] - regen, 0)
                org.lungsL[2] = math.max(org.lungsL[2] - regen, 0)
                org.brain = math.max(org.brain - regen * 0.1, 0)
            end

            if (org.pulse < 40) or (org.blood < 3000) or (org.o2[1] < 10) then
                ply:Notify("HEV suit has detected a critically low pulse. Epinephrine injected. Auto-pulse enabled. Plasma injected.", 60, "pulse_hev", 0.5, function(ply)
                    net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/health_critical.wav")
                    net.Send(ply)
                end, hev_color)
                
                if (org.BloodThink or 0) < CurTime() then
                    org.BloodThink = CurTime() + 4
    
                    if org.blood < 4000 then
                        local needed = math.min(4000 - org.blood, 500, ply.HEV.Medicine / 6)
                        ply.HEV.Medicine = math.max( ply.HEV.Medicine - needed / 10, 0 )
                        org.blood = org.blood + needed

                        org.adrenalineAdd = 4
                    end
                end
                
                if (org.CPRThink or 0) < CurTime() then
                    org.CPRThink = CurTime() + (1 / 120) * 60
                    
                    if org.alive then
                        org.o2[1] = math.min(org.o2[1] + hg.organism.OxygenateBlood(org) * 2, org.o2.range)
                        org.pulse = math.min(org.pulse + 5,70)
                        org.CO = math.Approach(org.CO, 0, 1)
                        org.COregen = math.Approach(org.COregen, 0, 1)
                        if org.pulse > 15 then org.heartstop = false end
                    end
                end
            end
        end
    end)

    hook.Add("HomigradDamage", "HEV_Medical",function(ply, dmgInfo, hitgroup, ent, entharm)
        if ply.PlayerClassName == "Gordon" and ply:GetNetVar("HEVSuit") then
            timer.Simple(0, function()
                timer.Create("HEV_CheckDMG",2,1,function()
                    if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= "Gordon" or ply.HEV.Medicine <= 0 then return end
                    
                    if ply:Health() < 35 then
                        net.Start("HEV_DAMAGE")
                            net.WriteString("hl1/fvox/health_critical.wav")
                        net.Send(ply)
                    end
                end)

                timer.Create("HEV_CheckHP",10,1,function()
                    if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= "Gordon" or ply.HEV.Medicine <= 0 then return end
                    if !entharm or entharm < 1 then return end
                    
                    local org = ply.organism

                    net.Start("HEV_DAMAGE")
                        net.WriteString("hl1/fvox/automedic_on.wav")
                    net.Send(ply)

                    local oldMedicine = ply.HEV.Medicine
                    
                    timer.Create("HEV_CheckHP",5,1,function()
                        local ammoutNeeds = 0

                        for _,v in ipairs(CheckBones) do
                            if !istable(org[v]) and org[v] > 0 then
                                local needed = ( 1 - org[v] ) * 10
                                org[v] = math.max(org[v] - ply.HEV.Medicine, 0) 
                                ply.HEV.Medicine = math.max( ply.HEV.Medicine - needed, 0 ) 
                            end

                            if istable(org[v]) then
                                for k,w in pairs(org[v]) do
                                    local needed = ( 1 - w ) * 10
                                    w = math.max(w - ply.HEV.Medicine, 0)
                                    ply.HEV.Medicine = math.max( ply.HEV.Medicine - needed, 0 )
                                end
                            end
                        end

                        if oldMedicine ~= ply.HEV.Medicine then
                            net.Start("HEV_DAMAGE")
                                net.WriteString("hl1/fvox/medical_repaired.wav")
                            net.Send(ply)
                        end
                    end)
                end)

                if #ply.organism.wounds > 0 or #ply.organism.arterialwounds > 0 or ply.organism.internalBleed > 0 then
                    if ply.organism.bleed > 0.025 and (!ply.HEV.BloodLossDetect or ply.HEV.BloodLossDetect < CurTime()) then
                        snd = "hl1/fvox/blood_loss.wav"
                        if ply.organism.internalBleed > 0.02 then
                            snd = "hl1/fvox/internal_bleeding.wav"
                        end
                        net.Start("HEV_DAMAGE")
                            net.WriteString(snd)
                        net.Send(ply)

                        ply.HEV.BloodLossDetect = CurTime() + 5
                    end

                    timer.Create("HEV_StopBleed", 5, 1, function()
                        if not IsValid(ply) or not ply:Alive() or ply.PlayerClassName ~= "Gordon" or ply.HEV.Medicine <= 0 then return end
                        
                        local bleedneedRemove = ply.organism.bleed
                        local bleedInterNeedRemove = ply.organism.internalBleed

                        ply.organism.internalBleed = math.max(ply.organism.internalBleed - ply.HEV.Medicine,0)
                        
                        ply.HEV.Medicine = math.max(ply.HEV.Medicine - bleedneedRemove, 0)
                        ply.HEV.Medicine = math.max(ply.HEV.Medicine - bleedInterNeedRemove, 0)
                        
                        table.Empty(ply.organism.wounds)

                        ply.HEV.Medicine = ply.HEV.Medicine - #ply.organism.arterialwounds * 2.5
                        local snd = "hl1/fvox/bleeding_stopped.wav"
                        if #ply.organism.arterialwounds > 0 then
                            snd = "hl1/fvox/torniquette_applied.wav"
                        end
                        --table.Empty(ply.organism.arterialwounds)
                        for i, wound in pairs(ply.organism.arterialwounds) do
                            wound[1] = 0
                        end

                        ply:SetNetVar("arterialwounds", ply.organism.arterialwounds)
                        ply:SetNetVar("wounds", ply.organism.wounds)
                        if ply.organism.bleed > 0.025 then
                            net.Start("HEV_DAMAGE")
                                net.WriteString(snd)
                            net.Send(ply)
                        end
                        ply.HEV.Medicine = math.max(ply.HEV.Medicine, 0)
                    end)
                end
            end)
        end
    end)

end

-- hl1/fvox/armor_gone.wav