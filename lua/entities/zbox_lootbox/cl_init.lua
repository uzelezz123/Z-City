include("shared.lua")

function ENT:Initialize()
end

function ENT:OnRemove()
end

function ENT:Draw()
	self:DrawModel()
end

hg = hg or {}
hg.OpenedContainer = hg.OpenedContainer or nil
local blurMat = Material("pp/blurscreen")
local Dynamic = 0

local cooldown = 0

local function nameThings(i)
    local weps = weapons.Get(i)
	local entss = scripted_ents.Get(i)
	if weps then return weps.PrintName end
	if entss then return entss.PrintName end
    return tostring(i)
end

local function getIconThing(i)
    if weapons.Get(i) then
        local GunTable = weapons.Get(i)
        --print(GunTable.WepSelectIcon2)
        local Icon = (GunTable.WepSelectIcon2 ~= nil and GunTable.WepSelectIcon2) or GunTable.WepSelectIcon
        local Overide = GunTable.WepSelectIcon2 == nil and true or false
        local HaveIcon = true
        return Icon, HaveIcon, Overide, false
    end

    local entss = scripted_ents.Get(i)
    if entss then 
        local GunTable = scripted_ents.Get(i)
        --print(GunTable.WepSelectIcon2)
        local Icon = (GunTable.IconOverride ~= nil and GunTable.IconOverride) or GunTable.IconOverride
        local Overide = GunTable.IconOverride == nil and true or false
        if not GunTable.IconOverride then return Icon, false, false, false end
        local HaveIcon = true
        return Icon, HaveIcon, Overide, true
    end
end
local colRed = Color(255, 0, 0, 255)
local function OpenContainer( ent )
    local name = "Container"
	local sizeX, sizeY = ScrW() / 3, ScrH() / 2.5
	zbContainerMenu = vgui.Create("DFrame")
	zbContainerMenu.ent = ent
	zbContainerMenu.entindex = ent:EntIndex()

	zbContainerMenu:SetTitle("")
	zbContainerMenu:SetSize(sizeX, sizeY)
    zbContainerMenu:SetPos(0, 500)
	--zbContainerMenu:Center()
	zbContainerMenu:MakePopup()
	zbContainerMenu:SetKeyBoardInputEnabled(false)
	zbContainerMenu:ShowCloseButton(true)
	zbContainerMenu:SetVisible(false)
	zbContainerMenu.Created = CurTime()
    zbContainerMenu:SetAlpha(0)
    zbContainerMenu.OnClose = function() zbContainerMenu = nil end 

    zbContainerMenu:MoveTo(0,0, 0.5, 0, 0.3, function()
    end)
    zbContainerMenu:AlphaTo( 255, 0.2, 0.1, nil )

    function zbContainerMenu:Close()
		self.Closing = true
	
        self:MoveTo(0, 500, 0.5, 0, 0.3, function()
            self:Remove()
        end)
        self:AlphaTo( 0, 0.1, 0, nil )
        self:SetKeyboardInputEnabled(false)
        self:SetMouseInputEnabled(false)
    end

	zbContainerMenu.Paint = function(self, w, h)
		draw.RoundedBox(0, 2.5, 2.5, w - 5, h - 5, Color(0, 0, 0, 140))
		surface.SetDrawColor(255, 0, 0, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		surface.SetDrawColor(92,0,0,240)
		surface.DrawRect(w / 2 - 100, 10,200,20)
		draw.DrawText(name, "HomigradFontSmall", w / 2, 10, color_white, TEXT_ALIGN_CENTER)
		draw.DrawText("R - Close", "HomigradFontSmall", w *0.012, h - h*0.055 , Color(255,255,255,15), TEXT_ALIGN_LEFT)
	end

	function zbContainerMenu:Think()
		local ent = self.ent
		if not IsValid(ent) then self:Close() return end
		if LocalPlayer().organism.otrub or not LocalPlayer():Alive() then self:Remove() return end
		if (ent:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 125^2 then self:Remove() return end
		if ent:IsPlayer() and not IsValid(ent.FakeRagdoll) then self:Remove() return end
		if input.IsKeyDown(KEY_R) then
			self:Close()
		end
	end

    local DScrollPanel = vgui.Create("DScrollPanel", zbContainerMenu)
	DScrollPanel:SetPos(sizeX / 30, sizeY / 12)
	DScrollPanel:SetSize(sizeX - sizeX / 16, sizeY - sizeY / 7)
	DScrollPanel:Dock(FILL)
	DScrollPanel:DockMargin(2,8,2,20)
	function DScrollPanel:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
		surface.SetDrawColor(255, 0, 0, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
	end
	local sbar = DScrollPanel:GetVBar()

	sbar:SetHideButtons( true )

	function sbar:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
		surface.SetDrawColor(255, 0, 0, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
	end
	function sbar.btnUp:Paint(w, h)
	end
	function sbar.btnDown:Paint(w, h)
	end
	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(0, 0, 0, w, h, Color(148, 0, 0, 100))
		surface.SetDrawColor(255, 0, 0, 128)
		surface.DrawOutlinedRect(0, 0, w, h, 2.5)
	end

	local grid = vgui.Create("DGrid", DScrollPanel)
	grid:Dock(FILL)
	grid:DockMargin(12, 10, 0, 0)
	grid:SetCols(5)
	grid:SetColWide(sizeX / 5 - sizeX / 16 / 9)
	grid:SetRowHeight(sizeY / 6.5 + sizeY / 32)

    for k,item in pairs(ent.Loot) do 
        local button = vgui.Create("DButton", plyMenu)
		button:SetText("")
		button:DockMargin(5, 0, 2, 0)
		--button:SetSize(0,0)
		button:SetSize(sizeX / 5.8, sizeY / 5.8)
		button.Think = function(self)
		end
		
		button.DoClick = function()
			if cooldown > CurTime() then return end
			cooldown = CurTime() + 0.5
			surface.PlaySound("arc9_eft_shared/generic_mag_pouch_in" .. math.random(7) .. ".ogg")
			grid.SoundKD = CurTime() + 0.2
            net.Start( "ZBox_LootSystem_net" )
                net.WriteEntity(ent)
                net.WriteUInt(k,10)
            net.SendToServer()
			button:Remove()
		end

		local name = nameThings(item.class)
		button.col1 = 100
		button.Paint = function(self, w, h)
			button.col1 = Lerp(0.1, button.col1, button:IsHovered() and 255 or 100)
			if button:IsHovered() then
				button.SoundKD = button.SoundKD or 0
				if (grid.SoundKD or 0) < CurTime() and button.SoundKD < CurTime() then surface.PlaySound("arc9_eft_shared/generic_mag_pouch_out" .. math.random(7) .. ".ogg") end
				button.SoundKD = CurTime() + 0.1
			end
			surface.SetDrawColor(button.col1, 25, 25, 150)
			surface.DrawRect(0, 0, w, h)
			local Icon, HaveIcon, Overide, Quad = getIconThing(item.class)
			if Icon then
				button.Icon = button.Icon or (isstring(Icon) and Material(Icon)) or Icon -- Ну тут так, без выбора если что материал будет
			end
			if HaveIcon then
				surface.SetMaterial(button.Icon)
				surface.SetDrawColor(255, 255, 255)
				surface.DrawTexturedRect(Quad and w / 5 + 5 or 0 - 5, 5, Quad and (w / 2 + 2.5) or (w + 10), Quad and h / 1.3 or h - 10)
			end
			surface.SetDrawColor(colRed)
			surface.DrawOutlinedRect(0, 0, w, h, 1)
			local Text = language.GetPhrase(name)
			local SubText = utf8.sub(Text, 14)
			Text = utf8.sub(Text, 1, 13) .. "\n" .. utf8.sub(Text, 14)
			draw.DrawText(Text, "DermaDefault", w / 2, (HaveIcon and h / ((#SubText > 0 and 1.65) or 1.3)) or h / 3, color_white, TEXT_ALIGN_CENTER)
		end
		grid:AddItem(button)
    end

    zbContainerMenu:SlideDown(0.5)
end

net.Receive( "ZBox_LootSystem_net", function( ) 
    local ent = net.ReadEntity()
    hg.OpenedContainer = ent
    ent.Loot = util.JSONToTable( net.ReadString() )
    OpenContainer(ent)
end)

zbContainerMenu = zbContainerMenu or nil
if IsValid(zbContainerMenu) then
    zbContainerMenu:Remove()
    zbContainerMenu = nil
end

local modelOffset = {
    ["models/props_c17/furnituredrawer002a.mdl"] = { Vector(0,0,25), Angle(0,90,-20) },
    ["models/props_c17/furnituredrawer003a.mdl"] = { Vector(0,0,25), Angle(0,90,-30) },
    ["models/props_junk/wood_crate001a.mdl"] = { Vector(0,0,25), Angle(0,90,-20) },
    ["models/props_junk/wood_crate002a.mdl"] = { Vector(0,0,25), Angle(0,90,-20) },
    ["models/props_c17/furniturefridge001a.mdl"] = { Vector(25,0,17), Angle(0,90,-50) },
    ["models/props_c17/furnituredrawer001a.mdl"] = { Vector(0,0,27), Angle(0,90,-25) },
    ["models/props_wasteland/controlroom_storagecloset001a.mdl"] = { Vector(20,0,15), Angle(0,90,-70) },
    ["models/props_wasteland/controlroom_filecabinet001a.mdl"] = { Vector(7,0,15), Angle(0,90,0) },
    ["models/props_wasteland/controlroom_filecabinet002a.mdl"] = { Vector(17,0,15), Angle(0,90,-50) },
    ["models/props_c17/lockers001a.mdl"] = { Vector(9,0,15), Angle(0,90,-50) },
    ["models/props_c17/furnituredresser001a.mdl"] = { Vector(17,0,15), Angle(0,90,-70) },
    ["models/props/de_prodigy/ammo_can_01.mdl"] = { Vector(17,0,45), Angle(0,90,-20) },
    ["models/props/de_prodigy/ammo_can_02.mdl"] = { Vector(0,0,10), Angle(0,90,30) },
    ["models/kali/props/cases/hard case a.mdl"] = { Vector(5,0,30), Angle(0,90,40) },
    ["models/props/cs_militia/footlocker01_closed.mdl"] = { Vector(5,0,12), Angle(0,90,30) },
    ["models/kali/props/cases/hard case c.mdl"] = { Vector(5,0,25), Angle(0,90,30) },
    
}

local offsetVec1,offsetAng1 = Vector(25,0,15),Angle(0,90,0)
local lerpang = Angle(0,0,0)
hook.Add("PostDrawOpaqueRenderables","Draw3D2DFrameContainer",function()
    local ent = hg.OpenedContainer

	if IsValid(ent) and IsValid(zbContainerMenu) and !zbContainerMenu.Closing then
        --print(ent:GetModel())
		local pos,ang = LocalToWorld(modelOffset[ent:GetModel()] and modelOffset[ent:GetModel()][1] or offsetVec1, modelOffset[ent:GetModel()] and modelOffset[ent:GetModel()][2] or offsetAng1, ent:GetPos(), ent:GetAngles())
        local veiwSetup = render.GetViewSetup()
        local angle = ( pos - veiwSetup.origin ):GetNormalized():Angle()
        --angle.y
        lerpang = LerpAngleFT( 0.1, EyeAngles(), angle )
        lerpang[3] = 0
        LocalPlayer():SetEyeAngles(lerpang)
        ang = Angle(0,angle.y,veiwSetup.angles[1]) - (modelOffset[ent:GetModel()] and modelOffset[ent:GetModel()][2] or offsetAng1)
		vgui.Start3D2D(pos + ang:Forward() * -12.7 - ang:Right() * 7 + ang:Up() * 5, ang, 0.04)
            zbContainerMenu:Paint3D2D()
            --print("asd")
		vgui.End3D2D()
	end
end)