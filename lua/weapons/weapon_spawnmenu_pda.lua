-- Сообщение всем скриптхукерам, ну вы это хоть оставляйте тех кто это кодил. Уважайте чужой труд!
if SERVER then AddCSLuaFile() end
SWEP.Base = "weapon_tpik1_base"
SWEP.PrintName = "Tablet"
SWEP.Instructions = ""
SWEP.Category = "Weapons - Other"
SWEP.Instructions = "Just a tablet"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Slot = 1

if CLIENT then
	SWEP.WepSelectIcon = Material("vgui/wep_jack_hmcd_phone")
	SWEP.IconOverride = "vgui/wep_jack_hmcd_phone"
	SWEP.BounceWeaponIcon = false
end

SWEP.Weight = 0
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"

SWEP.WorldModel = "models/nirrti/tablet/tablet_sfm.mdl"
SWEP.ViewModel = ""
SWEP.HoldType = "normal"

SWEP.setrhik = true
SWEP.setlhik = true

SWEP.LHPos = Vector(0,-6.6,0)
SWEP.LHAng = Angle(0,0,180)

SWEP.RHPosOffset = Vector(0,0,-7.6)
SWEP.RHAngOffset = Angle(0,15,-90)

SWEP.LHPosOffset = Vector(0,0,-0.4)
SWEP.LHAngOffset = Angle(5,0,15)

SWEP.handPos = Vector(0,0,0)
SWEP.handAng = Angle(0,0,0)

SWEP.UsePistolHold = false

SWEP.offsetVec = Vector(5,-7,-1)
SWEP.offsetAng = Angle(0,90,195)   

SWEP.HeadPosOffset = Vector(15,1.7,-5)
SWEP.HeadAngOffset = Angle(-90,0,-90)

SWEP.BaseBone = "ValveBiped.Bip01_Head1"

SWEP.HoldLH = "normal"
SWEP.HoldRH = "normal"

SWEP.HoldClampMax = 35
SWEP.HoldClampMin = 35

SWEP.Skin = 1

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()
    
end

local BlackList = {
    ["weapon_fists"] = true,
    ["weapon_medkit"] = true,
    ["gmod_tool"] = true,
    ["weapon_physgun"] = true,
    ["npc_swarm"] = true,
    ["hg_brassknuckles"] = true,
    ["zbox_lootbox"] = true,
    ["npc_swarm_mother"] = true,
    ["npc_swarm_sentinel"] = true,
    ["npc_swarm_sentry"] = true,
    ["necrosis"] = true,
    ["necrosisrange"] = true,
    ["ent_hg_cyanide_plotnypih"] = true,
    ["weapon_traitor_poison3"] = true,
    ["weapon_shield"] = true,
    ["weapon_traitor_poison1"] = true,
    ["weapon_traitor_poison2"] = true,
    ["weapon_traitor_suit"] = true,
    ["weapon_musket"] = true,
    ["weapon_flintlock"] = true,
    ["weapon_spawnmenu_pda"] = true,
    ["weapon_tpik1_base"] = true,
    ["weapon_thaumaturgic_arm"] = true,
    ["weapon_hg_slam"] = true,
    ["weapon_claymore"] = true,
    ["weapon_ash12"] = true,
    ["weapon_hands_sh"] = true
}

local CategoresAllowed = {
    ["Weapons - Pistols"] = true,
    ["Weapons - Machineguns"] = true,
    ["Weapons - Assault Rifles"] = true,
    --["Weapons - Grenade Launchers"] = true,
    --["Weapons - Other"] = true,
    ["Weapons - Melee"] = true,
    ["Weapons - Shotguns"] = true,
    ["Weapons - Sniper Rifles"] = true,
    ["Weapons - Explosive"] = true,
    ["Medicine"] = true,
    ["ZCity Other"] = true,
    ["ZCity Ammo"] = true,
    ["ZCity Armor"] = true,
    ["ZCity Attachments Grips"] = true,
    ["ZCity Attachments Magwells"] = true,
    ["ZCity Attachments Muzzles"] = true,
    ["ZCity Attachments Sights"] = true,
    ["ZCity Attachments Underbarrel"] = true,
    ["Other"] = true,
}

local KgInTime = 40

if SERVER then
    util.AddNetworkString("Deliver")

    net.Receive("Deliver",function( len, ply )
        local wep = IsValid(ply:GetActiveWeapon()) and ply:GetActiveWeapon() or false
        if not wep or wep:GetClass() ~= "weapon_spawnmenu_pda" then return end
        ply.DeliverCD = ply.DeliverCD or 0
        if ply.DeliverCD > CurTime() then wep:AddNotificate("You can't exucute new deliver. Wait "..( math.Round((ply.DeliverCD - CurTime())/300, 1)).. " min" ) return end

        local Cart = net.ReadTable()
        local CartWeight = 0
        
        for k, item in pairs(Cart) do
            if not item or not item[1] then wep:AddNotificate("No.") return end
            local entStore = scripted_ents.GetStored(item[1])
            local entTbl = weapons.GetStored(item[1]) or (entStore and entStore.t) or nil
            CartWeight = CartWeight + 5
            if not entTbl or not CategoresAllowed[entTbl.Category] then wep:AddNotificate("No.") return end
            if not item[1] or BlackList[item[1]] then wep:AddNotificate("No.") return end
        end

        if CartWeight > 140 then wep:AddNotificate("Too much weight to ship.") return end

        local Time = (CartWeight/KgInTime)*60
        if Time == 0 then wep:AddNotificate("First, get stuff in your cart.") return end

        local pos = hg.eyeTrace(ply).HitPos
        local tr = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0,0,1) * 9999999,
            mask = MASK_SOLID_BRUSHONLY,
        })
        if tr.HitSky then
            wep:AddNotificate("Your order is being assembled, please wait.")
            timer.Create(ply:EntIndex().."_Deliver",Time,1,function()
                wep:AddNotificate("Your package arrived. You have 5 minutes to pick up your stuff.")
                --ply:ChatPrint("Weapon was called, estimated time of delivery 5-7 seconds.")
                if not IsValid(ply) then return end
                local ent = ents.Create("zbox_lootbox")
                ent:SetMaterial("models/mat_jack_aidbox")
                ent:SetModel("models/props_junk/wood_crate001a.mdl")
                ent:SetPos(tr.HitPos + tr.HitNormal * 15)
                ent:Spawn()

                for k,item in pairs(Cart) do
                    ent.Loot = ent.Loot or {}
                    ent.Loot[#ent.Loot + 1] = { class = item[1] }
                end

                timer.Simple(300,function()
                    if not IsValid(ent) then return end
                    ent:Remove()
                end)
            end)

            ply.DeliverCD = CurTime() + Time
        else
            wep:AddNotificate("We can't deliver it to you until you're outside.")
        end

    end)

    function SWEP:AddNotificate(txt, isFunc)
        isFunc = isFunc or false
        if self:GetOwner():IsPlayer() then
            net.Start("Deliver")
                net.WriteString( txt )
                net.WriteEntity( self )
            net.Send(self:GetOwner())
        end

        self:EmitSound("garrysmod/content_downloaded.wav",40,100,1)
    end
end

if SERVER then return end

net.Receive("Deliver",function()
    local txt = net.ReadString()
    local ent = net.ReadEntity()

    ent:AddNotificate(txt,os.date("%H:%M | "))
end)

SWEP.CartIndex = "none"
SWEP.CartWeight = 0

SWEP.Cart = {}

local function addDiliverPanel(panel,tbl,swep)
    local button = vgui.Create( "DButton", panel )
    button:Dock( TOP )
    button:SetSize( 0,55 )
    button:SetText( tbl[2].." | "..tbl[3].." kg" )
    button.Weight = tbl[3]
    button.ClassName = tbl[1]
    button:DockMargin( 6, 10, 11, 0 )
    button:SetFont("ZCity_Tiny")

    function button:DoClick()
        swep.Cart[tbl[4]] = nil
        self:Remove()
    end

    button:SetContentAlignment(5)
end

function SWEP:CreateMenu()
    if IsValid(self.menu) then self.menu:Remove() end
    self.menu = vgui.Create( "DFrame" )
    self.menu:SetSize( 625, 468 )
    -- Если б я мог поменять хтмл говно я бы сделал лучше
    self.menu:Center()
    self.menu:SetY(ScrH()-470)
    -- увы пока только такой костыль...
    self.menu:SetTitle("Order menu")
    self.menu:SetDraggable(false)
    local tablet = self
    function self.menu:Think()
        local wep = IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon() or false
        if not wep or wep:GetClass() ~= "weapon_spawnmenu_pda" then
            if tablet.MouseHasControl then
                gui.EnableScreenClicker(false)
                tablet.MouseHasControl = false
            end
            --self:Remove() 
        end
        if not IsValid(tablet) then
            gui.EnableScreenClicker(false)
            self:Remove()
        end
    end

    hook.Add("OnShowZCityPause","CloseDerma",function()
        if self.MouseHasControl then
            gui.EnableScreenClicker(false)
            self.menu:SetMouseInputEnabled( false )
            self.menu:SetKeyboardInputEnabled( false )
            self.MouseHasControl = false
            --hook.Remove("OnPauseMenuShow","CloseDerma")
            return false
        end
    end)

    self.menu.bNoBackgroundBlur = true
    self.menu.NoBlur = true
    --SWEP.menu:Center()
    --SWEP.menu:MakePopup()
    local swep = self
    local toolbar = vgui.Create( "DPanel", self.menu )
    toolbar:Dock( TOP )
    toolbar:SetSize(0,30)

    local LBLRich = vgui.Create( "DLabel", toolbar )
    LBLRich:Dock(FILL)
    LBLRich:DockMargin(0,0,0,0)
    LBLRich:SetFont("ZCity_Fixed_SuperTiny")
    LBLRich:SetContentAlignment(5)

    self.LastNotifyText = self.LastNotifyText or ""
    self.LastNotifyTime = self.LastNotifyTime or 0
    function LBLRich:Think()
        if not IsValid(swep) then return end
        if swep.LastNotifyTime < CurTime() then swep.LastNotifyText = "" end
        self:SetText(os.date("%H:%M")..swep.LastNotifyText)
    end
    
    local sheet = vgui.Create( "DPropertySheet", self.menu )
    sheet:Dock( FILL )

    local Deliver = vgui.Create( "DPanel", sheet )
    Deliver:SetParent( sheet ) 

        local LeftPanel = vgui.Create( "DPanel", Deliver )
        LeftPanel:SetParent( Deliver ) 
        LeftPanel:Dock(LEFT)
        LeftPanel:SetSize(200,0)

            local LBLRich = vgui.Create( "DLabel", LeftPanel )
            LBLRich:Dock(TOP)
            LBLRich:DockMargin(10,10,10,5)
            LBLRich:SetFont("ZCity_Fixed_Tiny")
            LBLRich:SetContentAlignment(7)
            
            function LBLRich:Think()
                if not IsValid(swep) then return end
                self:SetText([[Cart: #]]..(swep:EntIndex()*123)..[[

Weight: ]]..swep.CartWeight..[[/140 kg
Arrive: ]]..(swep.CartWeight/KgInTime)..[[ Min

Cost: Free]])
                swep.CartWeight = 0
                for k, item in pairs(swep.Cart) do
                    swep.CartWeight = swep.CartWeight + item[3]
                end
                
            end

            local button = vgui.Create( "DButton", LeftPanel )
            button:Dock( BOTTOM )
            button:SetSize( 0,55 )
            button:SetText( "Order" )
            button:DockMargin( 10, 5, 10, 10 )
            button:SetColor(color_green)
            button:SetFont("ZCity_Tiny")



        local RightPanel = vgui.Create( "DScrollPanel", Deliver )
        RightPanel:SetParent( Deliver )
        RightPanel:Dock( FILL )   

            function button:DoClick()

                net.Start("Deliver")
                    net.WriteTable(swep.Cart)
                net.SendToServer()

                timer.Simple(0.1,function()
                    swep.LastID = 0
                    table.Empty( swep.Cart )
                end)

                RightPanel:Remove()

                RightPanel = vgui.Create( "DScrollPanel", Deliver )
                RightPanel:SetParent( Deliver )
                RightPanel:Dock( FILL ) 
            end

        for k, item in pairs(self.Cart) do
            addDiliverPanel( RightPanel, item, self )
        end

    
    sheet:AddSheet( "Deliver", Deliver )

    local Categores = {}

    for k, guns in pairs(weapons.GetList()) do
        local gun = weapons.Get(guns.ClassName)
        local Category = gun.Category or nil
        if not Category then continue end
        if not gun.Spawnable or gun.AdminOnly then continue end
        if BlackList[gun.ClassName] then continue end
        --print(Category)
        if not CategoresAllowed[Category] then continue end

        local Names = gun.PrintName

        Categores[ Category ] = Categores[ Category ] or {}
        Categores[ Category ][ guns.ClassName ] = { guns.ClassName, gun.PrintName }
    end 

    for k, ent in pairs(scripted_ents.GetList()) do
        local rent = ent["t"]
        --PrintTable(ent)
        if not rent then continue end
        local Category = rent.Category or "Other"
        if not Category then continue end
        if not rent.Spawnable or rent.AdminOnly then continue end
        if BlackList[rent.ClassName] then continue end
        --print(Category)
        if not CategoresAllowed[Category] then continue end

        local Names = ent.PrintName

        Categores[ Category ] = Categores[ Category ] or {}
        Categores[ Category ][ rent.ClassName ] = { rent.ClassName, rent.PrintName }
    end

    local sheetDeliver = vgui.Create( "DPropertySheet", sheetDeliver )
    --sheetDeliver:Dock( FILL )
    
        for k,Category in pairs(Categores) do
            local Shop = vgui.Create( "DScrollPanel", sheetDeliver )
            Shop:SetParent( sheetDeliver )
            Shop:Dock( FILL )   

            for i,gun in pairs(Category) do
                local button = vgui.Create( "DButton", Shop )
                button:Dock( TOP )
                button:SetSize( 0,55 )
                button:SetText( gun[2] or "Gun" )
                button.Weight = 5
                button:DockMargin( 5, 0, 5, 5 )
                button:SetFont("ZCity_Fixed_Tiny")

                local swep = self
                function button:DoClick()
                    swep.LastID = swep.LastID or 0
                    local id = (swep.LastID + 1).."ID"
                    --print(id)
                    swep.Cart[id] = {gun[1],gun[2],self.Weight, id, k}
                    addDiliverPanel( RightPanel, {gun[1],gun[2],self.Weight, id}, swep )
                    swep.LastID = swep.LastID + 1
                end

                button:SetContentAlignment(5)
            end

            sheetDeliver:AddSheet( string.StartsWith(k, "Weapons") and string.sub(k,11) or k, Shop )
        end

    sheet:AddSheet( "Shop", sheetDeliver )

    
    --for k, v in SortedPairsByMemberValue( spawnmenu.GetCreationTabs(), "Order" ) do
    --    if k ~= "#spawnmenu.category.weapons" and k ~= "#spawnmenu.category.entities" then continue end
--
    --    local panel = v.Function()
    --    panel:SetParent( sheet )
    --    panel.bNoBackgroundBlur = true
    --    panel.NoBlur = true
    --
    --    sheet:AddSheet( k, panel, v.Icon )
    --end
    --Ultra ShitPost
    local html = vgui.Create("HTML",sheet)
    html:SetParent( sheet )
    --html:Dock(FILL)
    html:OpenURL("https://google.com/?persist_app=1&app=m")
    html.HTMLPosX = 0
    html.HTMLPosY = 0
    -- ПРОСТИТЕ ЗА ЖУТКИЙ КОСТЫЛЬ, НО ОНО РАБОТАЕТ!!!
    function html:OnCursorMoved( X, Y )
        self.HTMLPosX = X
        self.HTMLPosY = Y
    end


    function html:PaintOver(w,h)
        if tablet.MouseHasControl then
            draw.RoundedBox(0,self.HTMLPosX-3,self.HTMLPosY-3,6,6,ColorAlpha(color_black,250))
            draw.RoundedBox(0,self.HTMLPosX-2.5,self.HTMLPosY-2.5,5,5,ColorAlpha(color_white,250))
        end
    end

    --function html:PaintOver(w,h)
    --    
    --end

    sheet:AddSheet( "Browser", html )

    self.NotifiyPan = vgui.Create( "DPanel", sheet )
    self.NotifiyPan:SetParent( sheet ) 

    sheet:AddSheet( "Notifications", self.NotifiyPan )

end

function SWEP:AddNotificate(text,time)
    if not IsValid(self.NotifiyPan) then return end
    local button = vgui.Create( "DButton", self.NotifiyPan )
    button:Dock( TOP )
    button:SetSize( 0,45 )
    button:SetText( time..(isfunction(text) and text() or text) )

    function button:Think()
        button:SetText( time..(isfunction(text) and text() or text) )
    end

    button:DockMargin( 6, 5, 6, 2.5 )
    button:SetFont("ZCity_Fixed_SuperTiny")

    function button:DoClick()
        self:Remove()
    end

    button:SetContentAlignment(5)

    self.LastNotifyText = isfunction(text) and text() or text
    self.LastNotifyText = " | "..self.LastNotifyText
    self.LastNotifyTime = CurTime() + 5
end

--if SWEP.menu then SWEP.menu:Remove() end
--SWEP.menu = vgui.Create( "DFrame" )
--SWEP.menu:SetSize( 1000, 650 )
--SWEP.menu.bNoBackgroundBlur = true
--SWEP.menu.NoBlur = true
----SWEP.menu:Center()
----SWEP.menu:MakePopup()
--
--local sheet = vgui.Create( "DPropertySheet", SWEP.menu )
--sheet:Dock( FILL )
--sheet.bNoBackgroundBlur = true
--sheet.NoBlur = true
--
--for k, v in SortedPairsByMemberValue( spawnmenu.GetCreationTabs(), "Order" ) do
--    local panel = v.Function()
--    panel:SetParent( sheet )
--    panel.bNoBackgroundBlur = true
--    panel.NoBlur = true
--
--    sheet:AddSheet( k, panel, v.Icon )
--end

function SWEP:PrimaryAttack()
    if IsValid(self.menu) then
        self.menu:SetMouseInputEnabled( true )
        self.menu:MakePopup(  )
        self.MouseHasControl = true
        gui.EnableScreenClicker(true)
    end
end

function SWEP:AddDrawModel(ent)
    if not IsValid(self.menu) then self:CreateMenu() end
    if IsValid(self:GetOwner()) and not self:GetOwner() == LocalPlayer() then return end
    local pos, ang = ent:GetRenderOrigin(), ent:GetRenderAngles()
    pos = pos + ang:Up() * 1.2 + ang:Forward() * -14.82 + ang:Right() * -12.7
    local scale = 0.0151
    vgui.Start3D2D(pos,ang,scale)
        self.menu:Paint3D2D()
        --local posx, posy = vgui.getCursorPos3D2D()
        --draw.RoundedBox(0,(posx/scale)-3.5,(posy/scale)-3.5,7,7,color_black)
        --draw.RoundedBox(0,(posx/scale)-2.5,(posy/scale)-2.5,5,5,color_white)
    vgui.End3D2D()
end
