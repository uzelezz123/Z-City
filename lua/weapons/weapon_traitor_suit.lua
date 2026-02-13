if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_base"
SWEP.PrintName = "Suit"
SWEP.Instructions = "A simple costume, along with a mask, can help hide your identity, your clothes will stay in the suitcase in the future you can put them back on."
SWEP.Category = "ZCity Other"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Wait = 1
SWEP.Primary.Next = 0
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.HoldType = "normal"
SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_c17/SuitCase_Passenger_Physics.mdl"
SWEP.Model = "models/props_c17/SuitCase_Passenger_Physics.mdl"

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_mask")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_mask"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.Slot = 5
SWEP.SlotPos = 99
SWEP.WorkWithFake = false
SWEP.offsetVec = Vector(5, -1.5, -0.6)
SWEP.offsetAng = Angle(-90, 0, 0)
SWEP.ModelScale = 0.8

SWEP.AvailableCostumes = {
    {
        Name = "Ghostface",
        Model = "models/distac/player/ghostface.mdl",
        Description = "Classic horror movie villain costume",
        Color = Color(255, 0, 0),
        ttachments = {}
    },
    {
        Name = "Jason Voorhees",
        Model = "models/eu_homicide/mkx_jajon.mdl",
        Description = "Stop fucking in my lake!",
        Color = Color(255, 255, 255),
        Attachments = {}
    }
    --;; К слову можно добавить донатные костюмы
}

SWEP.Identity = {
    AName = "Unknown", -- Player CustomName... 
    AModel = "models/distac/player/ghostface.mdl", -- GMODModel?
    AColor = Color(255, 0, 0),
    AAttachments = {} -- Таблица внешней одежды по типу шапки и так далее... -- Потом! 
}

SWEP.IsCostumeActive = false

if SERVER then
    hook.Add("HG_ReplacePhrase", "costume_pitch", function(ply, phrase, muffed, pitch)
		if IsValid(ply) then
			if ply:GetModel() == "models/distac/player/ghostface.mdl" then
				return ply, phrase, muffed, true
			elseif ply:GetModel() == "models/eu_homicide/mkx_jajon.mdl" then
				return ply, phrase, true, pitch
			end
		end
	end)
end

function SWEP:DrawWorldModel()
	self.model = IsValid(self.model) and self.model or ClientsideModel(self.WorldModel)
	local WorldModel = self.model
	local owner = self:GetOwner()
	WorldModel:SetNoDraw(true)
	WorldModel:SetModelScale(self.ModelScale)
	if IsValid(owner) then
		local offsetVec = self.offsetVec
		local offsetAng = self.offsetAng
		local boneid = owner:LookupBone("ValveBiped.Bip01_L_Hand")
		if not boneid then return end
		local matrix = owner:GetBoneMatrix(boneid)
		if not matrix then return end
		local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())
		WorldModel:SetPos(newPos)
		WorldModel:SetAngles(newAng)
		WorldModel:SetupBones()
	else
		WorldModel:SetPos(self:GetPos())
		WorldModel:SetAngles(self:GetAngles())
	end

	WorldModel:DrawModel()
end

function SWEP:SetHold(value)
	self:SetWeaponHoldType(value)
	self:SetHoldType(value)
	self.holdtype = value
end

function SWEP:Think()
	self:SetHold(self.HoldType)
end

function SWEP:GetEyeTrace()
	return hg.eyeTrace( self:GetOwner() )
end
--;; Ненавижу работать над визуалом...
if CLIENT then
	function SWEP:DrawHUD()
	end

	local color_white = Color(255, 255, 255)
    function SWEP:OpenCostumeMenu()
        if self.IsCostumeActive then
            notification.AddLegacy("You must remove your current costume first!", NOTIFY_ERROR, 3)
            --surface.PlaySound("buttons/button10.wav")
            return
        end
        
        if IsValid(self.CostumeMenu) then
            self.CostumeMenu:Remove()
        end
        
        local scrW, scrH = ScrW(), ScrH()
        local menuW, menuH = 600, 500
        

        self.CostumeMenu = vgui.Create("ZFrame")
        self.CostumeMenu:SetSize(menuW, menuH)
        self.CostumeMenu:Center()
        self.CostumeMenu:SetTitle("Costume Selection")
        self.CostumeMenu:SetDraggable(true)
        self.CostumeMenu:ShowCloseButton(true)
        self.CostumeMenu:MakePopup()
        

        self.CostumeMenu.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(20, 20, 20, 230))
            draw.RoundedBox(8, 5, 5, w-10, h-10, Color(40, 0, 0, 180))
            
            draw.RoundedBox(0, 0, 0, w, 30, Color(60, 0, 0, 200))
            
            surface.SetDrawColor(180, 0, 0, 255)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
        
		local font = "ZB_InterfaceSmall"
		if engine.ActiveGamemode() == "sandbox" then
			font = "ZCity_Fixed_SuperTiny"
		end

        self.CostumeMenu.lblTitle:SetFont(font)
        self.CostumeMenu.lblTitle:SetTextColor(color_white)
        

        local grid = vgui.Create("DGrid", self.CostumeMenu)
        grid:Dock(FILL)
        grid:DockMargin(10, 10, 10, 10)
        grid:SetCols(2)
        grid:SetColWide(280)
        grid:SetRowHeight(350) 
        
        for i, costume in ipairs(self.AvailableCostumes) do
            local costumePanel = vgui.Create("DPanel")
            costumePanel:SetSize(270, 340) 
            
            costumePanel.Paint = function(self, w, h)
                draw.RoundedBox(4, 0, 0, w, h, Color(60, 0, 0, 180))
                draw.RoundedBox(4, 2, 2, w-4, h-4, Color(30, 30, 30, 200))
                draw.RoundedBox(0, 0, 0, w, 30, Color(100, 0, 0, 200))
                surface.SetDrawColor(120, 0, 0, 255)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
                draw.SimpleText(costume.Name, font, w/2, 15, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                draw.DrawText(costume.Description, font, w/2, h - 80, Color(200, 200, 200), TEXT_ALIGN_CENTER)
            end
            

            local modelPanel = vgui.Create("DModelPanel", costumePanel)
            modelPanel:SetSize(220, 220)
            modelPanel:SetPos(25, 40)
            modelPanel:SetModel(costume.Model)
            
            local mn, mx = modelPanel.Entity:GetRenderBounds()
            local size = 0
            size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
            size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
            size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
            modelPanel:SetFOV(45)
            modelPanel:SetCamPos(Vector(size * 1.2, size * 1.2, size * 0.8))
            modelPanel:SetLookAt((mn + mx) * 0.5)
            

            function modelPanel:LayoutEntity(ent)
                ent:SetAngles(Angle(0, RealTime() * 30 % 360, 0))
            end
            
            local selectButton = vgui.Create("DButton", costumePanel)
            selectButton:SetSize(100, 30) 
            selectButton:SetPos(85, 295) 
            selectButton:SetText("Select")
            selectButton:SetFont(font)
            
            selectButton.Paint = function(self, w, h)
                local buttonColor = self:IsHovered() and Color(180, 0, 0, 200) or Color(120, 0, 0, 200)
                draw.RoundedBox(4, 0, 0, w, h, buttonColor)
                surface.SetDrawColor(200, 0, 0, 255)
                surface.DrawOutlinedRect(0, 0, w, h, 1)
            end
            
            selectButton.DoClick = function()
                self.SelectedCostume = table.Copy(costume)
                
                self.CostumeMenu:Close()
                
                net.Start("SuitCostumeSelected")
                net.WriteInt(i, 8) 
                net.SendToServer()
                
                --surface.PlaySound("buttons/button14.wav")
            end
            
            grid:AddItem(costumePanel)
        end
    end
    
    net.Receive("SuitCostumeStatus", function()
        local wep = LocalPlayer():GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_traitor_suit" then
            wep.IsCostumeActive = net.ReadBool()
        end
    end)
end

if SERVER then
    util.AddNetworkString("SuitCostumeSelected")
    util.AddNetworkString("SuitCostumeStatus")
    
    net.Receive("SuitCostumeSelected", function(len, ply)
        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "weapon_traitor_suit" then
            if wep.IsCostumeActive then return end
            
            local costumeIndex = net.ReadInt(8)
            local selectedCostume = wep.AvailableCostumes[costumeIndex]
            
            if selectedCostume then

                wep.StoredIdentity = table.Copy(ply.CurAppearance or {})
                
                local newIdentity = {
                    AName = selectedCostume.Name,
                    AClothes = {},
                    AModel = selectedCostume.Model,
                    AColor = selectedCostume.Color,
                    AAttachments = selectedCostume.Attachments or {}
                }
                
                hg.Appearance.ForceApplyAppearance(ply, newIdentity)
                
                wep.IsCostumeActive = true
                
                net.Start("SuitCostumeStatus")
                    net.WriteBool(true)
                net.Send(ply)

                wep:EmitSound("snds_jack_gmod/equip"..math.random(1,5)..".wav")

                wep.StoredPluv = ply:GetNetVar("CurPluv", "pluv")
                ply:SetNetVar("CurPluv", "pluv51")
            end
        end
    end)
end

function SWEP:SecondaryAttack()
    if SERVER then
        if self.IsCostumeActive and self.StoredIdentity then
            hg.Appearance.ForceApplyAppearance(self:GetOwner(), self.StoredIdentity)
            self:EmitSound("snds_jack_gmod/equip"..math.random(1,5)..".wav")
            
            self.IsCostumeActive = false
            
            net.Start("SuitCostumeStatus")
            net.WriteBool(false)
            net.Send(self:GetOwner())

            self:GetOwner():SetNetVar("CurPluv", self.StoredPluv or "pluv")
        else
            net.Start("SuitCostumeStatus")
            net.WriteBool(false)
            net.Send(self:GetOwner())
        end
    end
end

function SWEP:Initialize()
	self:SetHold(self.HoldType)
    self.IsCostumeActive = false
end

function SWEP:PrimaryAttack()
	if self.CD and self.CD > CurTime() then return end
    
    if CLIENT then
        self:OpenCostumeMenu()
    end
    
	self.CD = CurTime() + 1.5
end

function SWEP:Reload()
end