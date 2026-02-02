hg.weaponInv = hg.weaponInv or {}
local weaponInv = hg.weaponInv
local ammoType

function weaponInv.CanInsert(ply, wep)
	local category = wep.weaponInvCategory
	if not category then return true end
	local slot = (CLIENT and weaponInv.invWeapon[category]) or (SERVER and ply.weaponInv[category])
	
	if not slot then return true end

	if #slot + 1 > slot.limit then return false end
	return slot
end

if SERVER then
	function weaponInv.CreateLimit(ply, i, count)
		local tbl = {
			limit = count
		}

		ply.weaponInv[i] = tbl
	end

	function weaponInv.CreateLimitAmmo(ply, ammoType, count)
		ammoType = game.GetAmmoID(ammoType)
		ply.ammoInv[ammoType] = count
	end

	local function Remove(self, slot)
		local id
		for i = 1, #slot do
			if slot[i] == wep then
				id = i
				break
			end
		end

		if not id then --lol
			return
		end

		table.remove(slot, id)
		weaponInv.Sync(self:GetOwner())
	end

	function weaponInv.Insert(ply, wep)
		local slot = weaponInv.CanInsert(ply, wep)
		if slot == true then return true end
		if slot == nil then return true end
		if slot == false then return false end
		slot[#slot + 1] = wep
		wep:CallOnRemove("weaponInv", Remove, slot)
		return true
	end
	
	function weaponInv.Remove(ply, wep)
		local id, slot
		if not ply.weaponInv then return end
		for category, _slot in pairs(ply.weaponInv) do
			for i = 1, #_slot do
				if _slot[i] == wep then
					slot = _slot
					id = i
					break
				end
			end

			if id then break end
		end

		if not id then return end
		wep:RemoveCallOnRemove("weaponInv")
		table.remove(slot, id)
		return true
	end

	hook.Add("Player Spawn", "homigrad-weapons-inv2", function(ply)
		ply.weaponInv = ply.weaponInv or {}
		ply.ammoInv = ply.weaponInv or {}
		for k in pairs(ply.weaponInv) do
			ply.weaponInv[k] = nil
		end

		for k in pairs(ply.ammoInv) do
			ply.ammoInv[k] = nil
		end

		if hook.Run("WeaponsInv Loadout", ply) == nil then
			weaponInv.CreateLimit(ply, 1, 1) --main
			weaponInv.CreateLimit(ply, 2, 2) --secondary
			weaponInv.CreateLimit(ply, 3, 1) --melee
			weaponInv.CreateLimit(ply, 4, 1) --traitor 22lr gun
			weaponInv.CreateLimit(ply, 5, 1) --traitor knife
			weaponInv.CreateLimit(ply, 6, 1) --heavy melee
		end

		weaponInv.Sync(ply)
	end)

	hook.Add("WeaponEquip", "homigrad", function(wep, ply)
		if weaponInv.Insert(ply, wep) then
			weaponInv.Sync(ply)
			return
		end
	end)

	hook.Add("PlayerDroppedWeapon", "homigrad-weaponInv", function(ply, wep)
		weaponInv.Remove(ply, wep)
		weaponInv.Sync(ply)
	end)

	hook.Add("PlayerCanPickupWeapon", "homigrad-weapons", function(ply, wep)
		if wep.init and ((ply:GetUseEntity() ~= wep or not ply:KeyPressed(IN_USE)) and not ply.force_pickup) then return false end
		if wep.init and wep.IsSpawned and ((ply.cooldown_grab or 0) > CurTime()) and not ply.force_pickup then return false end
		if wep.PickupFunc and (wep:PickupFunc(ply) == true) then return false end
		if ( ply:HasWeapon( wep:GetClass() ) ) then
			if wep:Clip1() > 0 and ishgweapon(wep) then
				local ammo = wep:Clip1()
				ply:GiveAmmo(ammo, wep:GetPrimaryAmmoType(), true)
				wep:SetClip1(0)
				ply:EmitSound("snd_jack_hmcd_ammotake.wav", 65)
				ply.cooldown_grab = CurTime() + 0.1
			elseif (wep:GetClass() == "weapon_hg_bow" and not wep.Initialzed) then
				ply:GiveAmmo(1, wep.Ammo, true)
				wep.Initialzed = true
				wep:EmitSound("weapons/bow_deerhunter/arrow_fetch_0"..math.random(4)..".wav")
				ply:EmitSound("weapons/bow_deerhunter/arrow_load_0"..math.random(3)..".wav", 60)
				ply.cooldown_grab = CurTime() + 0.1
			end
			return false
		end
		
		if weaponInv.CanInsert(ply, wep) == false then
			local wep = ply.weaponInv[wep.weaponInvCategory][1]
			
			if IsValid(wep) then
				ply:DropWeapon(wep)
				wep.IsSpawned = true
				wep.init = true
			end

			ply.cooldown_grab = CurTime() + 0.1
			return true
		end
		ply.cooldown_grab = CurTime() + 0.1
	end)

	util.AddNetworkString("weaponInv")
	local packet = {}
	function weaponInv.Sync(ply)
		if ply:IsNPC() then return end
		net.Start("weaponInv")
		packet[1] = ply.weaponInv
		packet[2] = ply.ammoInv
		net.WriteTable(packet)
		net.Send(ply)
	end
else
	weaponInv.invWeapon = weaponInv.invWeapon or {}
	weaponInv.invAmmo = weaponInv.invAmmo or {}
	local invWeapon = weaponInv.invWeapon
	local invAmmo = weaponInv.invAmmo
	net.Receive("weaponInv", function()
		local packet = net.ReadTable()
		for k in pairs(invWeapon) do
			invWeapon[k] = nil
		end

		for k in pairs(invAmmo) do
			invAmmo[k] = nil
		end

		for k, v in pairs(packet[1]) do
			invWeapon[k] = v
		end

		for k, v in pairs(packet[2]) do
			invAmmo[k] = v
		end
	end)

	concommand.Add("hg_listammo", function() PrintTable(game.GetAmmoTypes()) end)
	concommand.Add("hg_weaponInv_table", function() PrintTable(weaponInv) end)
end
--[[
	1	=	AR2
	2	=	AR2AltFire
	3	=	Pistol
	4	=	SMG1
	5	=	357
	6	=	XBowBolt
	7	=	Buckshot
	8	=	RPG_Round
	9	=	SMG1_Grenade
	10	=	Grenade
	11	=	slam
	12	=	AlyxGun
	13	=	SniperRound
	14	=	SniperPenetratedRound
	15	=	Thumper
	16	=	Gravity
	17	=	Battery
	18	=	GaussEnergy
	19	=	CombineCannon
	20	=	AirboatGun
	21	=	StriderMinigun
	22	=	HelicopterGun
	23	=	9mmRound
	24	=	357Round
	25	=	BuckshotHL1
	26	=	XBowBoltHL1
	27	=	MP5_Grenade
	28	=	RPG_Rocket
	29	=	Uranium
	30	=	GrenadeHL1
	31	=	Hornet
	32	=	Snark
	33	=	TripMine
	34	=	Satchel
	35	=	12mmRound
	36	=	StriderMinigunDirect
	37	=	CombineHeavyCannon
	38	=	40mm Grenade
	39	=	arccw_go_nade_knife
	40	=	arccw_go_taser
	41	=	Arrow
	42	=	Black Powder Metallic Cartridge
	43	=	Black Powder Paper Cartridge
	44	=	Heavy Rifle Round
	45	=	Light Rifle Round
	46	=	Light Rifle Round-Armor Piercing
	47	=	Light Rifle Round-Ballistic Tip
	48	=	Light Rifle Round-Tracer
	49	=	Magnum Pistol Round
	50	=	Magnum Rifle Round
	51	=	Medium Rifle Round
	52	=	Mini Rocket
	53	=	Pistol Round
	54	=	Plinking Round
	55	=	Shotgun Round
	56	=	Small Shotgun Round
]]