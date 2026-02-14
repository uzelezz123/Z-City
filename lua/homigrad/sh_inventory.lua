hg.TraitorLoot = {
	["weapon_sogknife"] = 10,
	["weapon_buck200knife"] = 10,
	["weapon_hg_shuriken"] = 9,
	["weapon_p22"] = 9,
	["weapon_traitor_ied"] = 8,
	["weapon_traitor_poison1"] = 7,
	["weapon_traitor_poison2"] = 6,
	["weapon_traitor_poison3"] = 5,
	["weapon_hg_smokenade_tpik"] = 4,
	["weapon_hg_rgd_tpik"] = 3,
	["weapon_walkie_talkie"] = 2,
	["weapon_adrenaline"] = 1,
	["hg_flashlight"] = 1,
}

if CLIENT then
	hook.Add("Player_Death","foundloot",function(ply)
		if IsValid(ply.FakeRagdoll) then ply.FakeRagdoll.foundloot = table.Copy(ply.foundloot) end
		ply.foundloot = {}
	end)

	local OpenInv
	net.Receive("should_open_inv", function()
		local ent = net.ReadEntity()
		OpenInv(ent)
	end)

	local colRed = Color(255, 0, 0, 255)
	local colBlack2 = Color(100, 100, 100)
	local colBlack3 = Color(50, 50, 50, 120)
	local colBlue = Color(150, 150, 150)
	local buttons = {}
	local function nameThings(i, thing)
		local weps = weapons.Get(i)
		local entss = scripted_ents.Get(i)
		if weps then return weps.PrintName end
		if entss then return entss.PrintName end
		if hg.armor and hg.armor[i] and hg.armor[i][thing] then return thing end
		if hg.attachmentslaunguage and hg.attachmentslaunguage[thing] then return thing end
		if i == "Money" then return "Money, " .. tostring(thing) .. "$" end
		return tostring(i)
	end

	local function getIconThing(i, thing, tab)
		if tab == "Weapons" and weapons.Get(i) then
			local GunTable = weapons.Get(i)
			--print(GunTable.WepSelectIcon2)
			local Icon = (GunTable.WepSelectIcon2 ~= nil and GunTable.WepSelectIcon2) or GunTable.WepSelectIcon
			local Overide = GunTable.WepSelectIcon2 == nil and true or false
			local HaveIcon = true
			return Icon, HaveIcon, Overide, GunTable.WepSelectIcon2box
		end

		if tab == "Attachments" and hg.attachmentsIcons[thing] then
			local AttIcon = hg.attachmentsIcons[thing]
			local HaveIcon = true
			return AttIcon, HaveIcon, false, true
		end

		if tab == "Armor" then
			local AttIcon = hg.armorIcons[thing]
			local HaveIcon = true
			return AttIcon, HaveIcon, false, true
		end

		if tab == "Money" then
			local AttIcon = "scrappers/money_icon.png"
			local HaveIcon = true
			return AttIcon, HaveIcon, false
		end
	end

	local functions2 = {
		["Weapons"] = function(ply, ent, wep)
			if true then return true end
		end,
		["Ammo"] = function(ply, ent, ammo, amt)
			if true then return true end
		end,
		["Armor"] = function(ply, ent, placement, armor)
			if hg.armor[placement][armor].nodrop then return false end
			if true then return true end
		end,
		["Attachments"] = function(ply, ent, att, tbl)
			if true then return true end
		end,
		["Money"] = function(ply, ent)
			if true then return true end
		end,
	}

	local functions = {
		["Weapons"] = function(ply, ent, wep)
			local weapon = weapons.Get(wep)
			if (ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon() == wep) then return end
			--if not hg.weaponInv.CanInsert(ply, weapon) or ply:HasWeapon(wep) then return false end
			return true
		end,
		["Ammo"] = function(ply, ent, ammo, amt)
			if true then return true end
		end,
		["Armor"] = function(ply, ent, placement, armor)
			local armors = ply:GetNetVar("Armor",{})
			if armors[placement] then return false end
			if true then return true end
		end,
		["Attachments"] = function(ply, ent, att, tbl)
			if true then return true end
		end,
		["Money"] = function(ply, ent)
			if true then return true end
		end,
	}

	local cooldown = 0

	local function TakeItem(tblIndex, thing, item, owner)
		local item = istable(item) and item or {item}

		net.Start("ply_take_item")
			net.WriteString(tblIndex)
			net.WriteString(thing)
			net.WriteTable(item)
			net.WriteEntity(owner)
		net.SendToServer()
	end

	local plyMenu
	local chosen
	local chooseButton
	local chooseButtonHuy
	local blurMat = Material("pp/blurscreen")
	local Dynamic = 0
	BlurBackground = BlurBackground or hg.DrawBlur

	hook.Add("OnNetVarSet","inventory_netvar",function(index,key,var)
		if key == "Inventory" then
			local ent = Entity(index)

			if IsValid(plyMenu) and plyMenu.entindex == index then
				timer.Simple(0,function()
					--OpenInv(ent)
				end)
			end
		end
	end)

	OpenInv = function(ent)
		if IsValid(plyMenu) then
			plyMenu:Remove()
			plyMenu = nil
		end
		
		cooldown = CurTime() + 0

		if not IsValid(ent) then return end

		local ply = LocalPlayer()
		Dynamic = 0
		local inv = ent:GetNetVar("Inventory")
		inv["Money"] = {}
		-- local entmoney = ent:GetNetVar("zb_Scrappers_RaidMoney") or 0
		-- if entmoney > 0 then inv["Money"]["Money"] = entmoney end
		local armor = ent:GetNetVar("Armor")
		inv["Armor"] = armor
		if not inv then return end

		local nameStr = "Unknown"
		if IsValid(ent) then
			if (ent:IsPlayer() or ent:IsRagdoll()) then
				nameStr = ent:GetPlayerName() or string.NiceName(ent:GetClass())
			end
		end
		local name = nameStr .. "'s inventory" or "Container"
		local sizeX, sizeY = ScrW() / 3, ScrH() / 2.5
		plyMenu = vgui.Create("ZFrame")
		plyMenu.ent = ent
		plyMenu.entindex = ent:EntIndex()

		plyMenu:SetTitle("")
		plyMenu:SetSize(sizeX, sizeY)
		plyMenu:Center()
		plyMenu:MakePopup()
		plyMenu:SetKeyBoardInputEnabled(false)
		plyMenu:ShowCloseButton(true)
		plyMenu:SetVisible(true)
		plyMenu.Created = CurTime()
		--plyMenu.OldPaint = 
		plyMenu.PaintOver = function(self, w, h)

			draw.DrawText(name, "HomigradFontSmall", w / 2, 10, color_white, TEXT_ALIGN_CENTER)

			draw.DrawText("R - Close | LMB - Take | RMB - Item menu", "HomigradFontSmall", w / 2, h - h*0.055 , Color(255,255,255,45), TEXT_ALIGN_CENTER)
		end
		function plyMenu:Think()
			local ent = self.ent
			if not IsValid(ent) then self:Close() return end
			if LocalPlayer().organism.otrub or not LocalPlayer():Alive() then self:Remove() return end
			if (ent:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 125^2 then self:Remove() return end
			if ent:IsPlayer() and not IsValid(ent.FakeRagdoll) then self:Remove() return end
			if input.IsKeyDown(KEY_R) then
				self:Close()
			end
		end

		local DScrollPanel = vgui.Create("DScrollPanel", plyMenu)
		DScrollPanel:SetPos(sizeX / 30, sizeY / 12)
		DScrollPanel:SetSize(sizeX - sizeX / 16, sizeY - sizeY / 7)
		DScrollPanel:Dock(FILL)
		DScrollPanel:DockMargin(2,8,2,20)
		--function DScrollPanel:Paint(w, h)
		--	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
		--	surface.SetDrawColor(255, 0, 0, 128)
		--	surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		--end

		--local sbar = DScrollPanel:GetVBar()
		--sbar:SetHideButtons( true )
		--function sbar:Paint(w, h)
		--	draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
		--	surface.SetDrawColor(255, 0, 0, 128)
		--	surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		--end
--
		--function sbar.btnUp:Paint(w, h)
		--end
--
		--function sbar.btnDown:Paint(w, h)
		--end
--
		--function sbar.btnGrip:Paint(w, h)
		--	draw.RoundedBox(0, 0, 0, w, h, Color(148, 0, 0, 100))
		--	surface.SetDrawColor(255, 0, 0, 128)
		--	surface.DrawOutlinedRect(0, 0, w, h, 2.5)
		--end

		local grid = vgui.Create("DGrid", DScrollPanel)
		grid:Dock(FILL)
		grid:DockMargin(12, 10, 0, 0)
		grid:SetCols(5)
		grid:SetColWide(sizeX / 5 - sizeX / 16 / 9)
		grid:SetRowHeight(sizeY / 6.5 + sizeY / 32)
		local count = 0
		for tab, things in pairs(inv) do
			if not istable(things) then continue end
			for i, thing in pairs(things) do
				ent.foundloot = ent.foundloot or {}
				count = count + ((ent:IsPlayer() or ent:IsRagdoll()) and ((hg.TraitorLoot[i] and ent:IsPlayer()) and 2 or 0.5) or 1) * (not ent.foundloot[i] and 1 or 0)
			end
		end
		local time = CurTime() + 3
		function DScrollPanel:Paint(w, h)
			txt = "Searching"
			if time > 0 then
				for i = 1, 3 - math.Round(time-CurTime(),0) do
					txt = txt .. "."
				end
				if time < CurTime() then
					time = CurTime() + 3
				end
			end
			draw.DrawText((plyMenu.Created + count + 3) < CurTime() and "" or txt, "ZCity_Small", w / 2, h / 2.8, Color(255,255,255,15), TEXT_ALIGN_CENTER)
		end
		local count2 = 0
		
		for tab, things in pairs(inv) do
			if not istable(things) then continue end
			local keys = table.GetKeys(things)
			table.sort(keys,function(a,b)
				local atbl = weapons.Get(a)
				local wep = atbl and atbl.holsteredBone and not atbl.shouldntDrawHolstered
				return (ent.foundloot[a] and 1 or 0) > (ent.foundloot[b] and 1 or 0)//(hg.TraitorLoot[a] or 0) < (hg.TraitorLoot[b] or (wep and 1 or 0) or 0)
			end)
			
			for k, i in ipairs(keys) do
				local thing = things[i]
				local thing1 = istable(thing) and thing or {thing}

				if not functions2[tab](ply, ent, i, unpack(thing1)) then continue end

				--ent.foundloot = {}
				ent.foundloot = ent.foundloot or {}

				if ent:IsPlayer() and IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() == i then continue end
				count2 = count2 + (!ent.foundloot[i] and 1 or 0)//((ent:IsPlayer() or ent:IsRagdoll()) and ((hg.TraitorLoot[i] and ent:IsPlayer()) and 2 or 0.5) or 1) * (not ent.foundloot[i] and 1 or 0)

				local button = vgui.Create("DButton", plyMenu)
				button:SetText("")
				button:DockMargin(5, 0, 2, 0)
				button:SetSize(0,0)
				--button:SetSize(sizeX / 5.8, sizeY / 5.8)
				button.Created = CurTime() + (!ent.foundloot[i] and 2 or 0) + count2
				button.Think = function(self)
					if self.Created and (self.Created < CurTime()) then
						self:SetSize(sizeX / 5.8, sizeY / 5.8)
						self:SetAlpha(0)
						surface.PlaySound("arc9_eft_shared/generic_mag_pouch_in" .. math.random(7) .. ".ogg")
						self:AlphaTo(255,0.3,0)
						ent.foundloot[i] = true
						self.Created = nil
					end
				end
				
				button.DoClick = function()
					if cooldown > CurTime() then return end

					cooldown = CurTime() + 0.5
					
					if not functions[tab](ply, ent, i, unpack(thing1)) then
						local OptionsMenu = DermaMenu() 
							OptionsMenu:AddOption( "You have item like this", function() end )
						OptionsMenu:Open()
						return
					end
					if istable(thing) then
						thing["render"] = {}
					end
					
					surface.PlaySound("arc9_eft_shared/generic_mag_pouch_in" .. math.random(7) .. ".ogg")
					grid.SoundKD = CurTime() + 0.2
					button:Remove()
					TakeItem(tab, i, thing, ent)
					--timer.Simple(0.5 * math.max(ply:Ping() / 50,1),function()
					--	--OpenInv(ent)
					--end)
				end

				button.DoRightClick = function()
					if cooldown > CurTime() then return end

					cooldown = CurTime() + 0.5

					
					if not functions[tab](ply, ent, i, unpack(thing1)) then
						local OptionsMenu = DermaMenu() 
							OptionsMenu:AddOption( "You have item like this", function() end )
						OptionsMenu:Open()
						return
					end
					if istable(thing) then
						thing["render"] = {}
					end
					
					surface.PlaySound("arc9_eft_shared/generic_mag_pouch_in" .. math.random(7) .. ".ogg")
					grid.SoundKD = CurTime() + 0.2
					--button:Remove()
					local OptionsMenu = DermaMenu() 
						OptionsMenu:AddOption( "Take", function() button:Remove() TakeItem(tab, i, thing, ent) end )
					OptionsMenu:Open()
					--timer.Simple(0.5 * math.max(ply:Ping() / 50,1),function()
					--	--OpenInv(ent)
					--end)
				end

				local name = nameThings(i, thing)
				button.col1 = 100
				button.Paint = function(self, w, h)
					button.col1 = Lerp(0.1, button.col1, button:IsHovered() and 255 or 100)
					if button:IsHovered() then
						button.SoundKD = button.SoundKD or 0
						if (grid.SoundKD or 0) < CurTime() and button.SoundKD < CurTime() then surface.PlaySound("arc9_eft_shared/generic_mag_pouch_out" .. math.random(7) .. ".ogg") end
						button.SoundKD = CurTime() + 0.1
					end

					surface.SetDrawColor(button.col1, 0, 0, 15)
					surface.DrawRect(0, 0, w, h)
					local Icon, HaveIcon, Overide, Quad = getIconThing(i, thing, tab)
					if Icon then
						button.Icon = button.Icon or (isstring(Icon) and Material(Icon)) or Icon -- Ну тут так, без выбора если что материал будет
					end

					if HaveIcon then
						if Overide and isnumber( Icon ) then
							surface.SetTexture(button.Icon)
						else
							surface.SetMaterial(button.Icon)
						end

						surface.SetDrawColor(255, 255, 255)
						surface.DrawTexturedRect(Quad and w / 5 + 5 or 0 - 5, 5, Quad and (w / 2 + 2.5) or (w + 10), Quad and h / 1.3 or h - 10)
					end

					surface.SetDrawColor(button.col1,0,0,button.col1)
					surface.DrawOutlinedRect(0, 0, w, h, 1)
					local Text = (tab == "Ammo" and game.GetAmmoName(name)) or language.GetPhrase(name)
					local SubText = utf8.sub(Text, 17)
					Text = utf8.sub(Text, 1, 17) .. "\n" .. utf8.sub(Text, 18)
					draw.DrawText(Text, "ZCity_VerySuperTiny", w / 2, (HaveIcon and h / ((#SubText > 0 and 1.65) or 1.3)) or h / 3, color_white, TEXT_ALIGN_CENTER)
				end
				grid:AddItem(button)
			end
		end
	--plyMenu:SlideDown(0.5)
	end
end