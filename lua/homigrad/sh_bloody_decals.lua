
if SERVER then
    util.AddNetworkString("bloody_decal_1")

    return
end


function ClearDecalToEnt(ent)
	if ent.decalshuy then
		ent:SetSubMaterial()
		
		ent.decalshuy = nil
	end
end

local matRepl = Material("decals/decalsplash")
local curmat
local curmat2
function AddDecalToEnt(ent, id, --[[optional]] entIndex, tex, clear, x, y, rot, size, alpha)
	local subm = ent:GetSubMaterial(id - 1) != "" and ent:GetSubMaterial(id - 1) or ent:GetMaterials()[id]
	if !subm then
		print("Invalid submaterial entered for weapon "..tostring(Entity(entIndex)).."; change SWEP.bloodID to something else or remove it completely if you don't wanna bother.")
			
		return
	end

	local mata = Material(subm)
	if !IsValid(ent) then return end
	if !mata then return end
	
	ent.decalshuy = ent.decalshuy or {}
	local firstime = !ent.decalshuy[id]

	local tabla = mata:GetKeyValues()
	
	-- you should set up entIndex for CSModels since their entIndex is -1
	local mat = CreateMaterial(mata:GetName()..(entIndex or ent:EntIndex()).."228", mata:GetShader(), {})
	
	--[[for i, val in pairs(tabla) do
		if type(val) == "ITexture" then
			mat:SetTexture(i, val)
		end
	end--]]
	
	local basetexture = mata:GetTexture("$basetexture")
	if !basetexture then return end

	local oldbasetex = basetexture:GetName()
	
	mat:SetTexture("$basetexture", basetexture)

	local name = mat:GetName()
	local olddetail = mata:GetTexture("$detail")
	local sizew = basetexture:Width()
	local sizeh = basetexture:Height()
	local size = size or 512
	local scale = 1

	local tex = tex or matRepl
	
	local rt = GetRenderTargetEx("vms_rt_"..util.CRC(name), size, size, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_SHARED, 0, CREATERENDERTARGETFLAGS_HDR, IMAGE_FORMAT_ARGB8888)

	render.PushRenderTarget(rt)

	--if olddetail and olddetail != rt and olddetail:GetName() != rt:GetName() then
	if clear or firstime then
		render.Clear(0, 0, 0, 0, true)
	end
	--end

	local x, y = x or math.random(0, size), y or math.random(0, size)
	local rot = rot or math.Rand(-180, 180)
	
	cam.Start2D()
		--if (clear or firstime) and olddetail:GetName() != "error" then
			--[[render.SuppressEngineLighting(true)
			render.ResetModelLighting( 1, 1, 1 )
			surface.SetDrawColor( 255, 255, 255, 1 )
			surface.SetMaterial( mata )
			--surface.SetTexture(surface.GetTextureID(mata:GetTexture("$basetexture"):GetName()))
			surface.DrawTexturedRect( 0, 0, sizew, sizeh)
			render.SuppressEngineLighting(false)--]]
		--end

		surface.SetDrawColor( 255, 255, 255, alpha or math.random(100, 255) )
		surface.SetMaterial( tex )
		--surface.SetTexture(surface.GetTextureID("zbattle/blood"))
		local rand = math.Clamp(math.random(), 0.5, 1)
		surface.DrawTexturedRectRotated(x, y, size * rand, size * rand, rot)
	cam.End2D()

	render.PopRenderTarget()

	mat:SetTexture("$detail", rt)
	mat:SetFloat("$detailscale", 1)
	mat:SetFloat("$detailblendfactor", 1)
	mat:SetInt("$detailblendmode", 2)

	curmat = mat
	curmat2 = mata

	ent.decalshuy[id] = ent:GetSubMaterial(id - 1)
	ent:SetSubMaterial(id - 1, "!"..mat:GetName())
	--print(ent:GetSubMaterial(id - 1), 1, "!"..mat:GetName(), 2)
end

function AddDecalToEnt2(ent, entIndex, tex, clear, x, y, rot, size, alpha) -- adds to all submats
	for id, val in ipairs(ent:GetMaterials()) do
		AddDecalToEnt(ent, id, entIndex, tex, clear, x, y, rot, size, alpha)
	end
end

local matBlood = Material("zbattle/blood")
net.Receive("bloody_decal_1", function()
	local self = net.ReadEntity()

	if IsValid(self) then
		local mdl = self.worldModel2
		mdl = IsValid(mdl) and mdl or self.worldModel
		mdl = IsValid(mdl) and mdl or self.NPCworldModel
		mdl = IsValid(mdl) and mdl or self
		
		if self.bloodID then
			AddDecalToEnt(mdl, self.bloodID, self:EntIndex(), matBlood, false, nil, nil, nil, nil, self.DamageType != DMG_SLASH and 100)
		else
			AddDecalToEnt2(mdl, self:EntIndex(), matBlood, false, nil, nil, nil, nil, self.DamageType != DMG_SLASH and 100)
		end
	end
end)

--[[
local wep = Entity(1):GetActiveWeapon()
local wm = wep.worldModel2--wep:GetWM()
--"effects/droplets/drop3_1"
AddDecalToEnt2(wm, wep:EntIndex(), Material("zbattle/blood"), false)--"decals/blood1", true)
--]]
--AddDecalToEnt2(Entity(1), Entity(1):EntIndex(), Material("zbattle/blood"), false)

-- local matat = Material("models/weapons/m4a1/weapon_m4a1_dm")
-- local white = Material("vgui/white")
-- hook.Add("HUDPaint", "testBlood", function()
-- 	do return end
-- 	if !curmat then return end
-- 	--render.SuppressEngineLighting(true)
-- 	--render.SetLightingMode(2)
-- 	--render.SetAmbientLight( 255, 255, 255 )
-- 	--render.ResetModelLighting( 1, 0, 0 )
-- 	print(surface.GetTextureID(curmat:GetTexture("$detail"):GetName()))
-- 	render.SetLightmapTexture(white:GetTexture("$basetexture"))
-- 	surface.SetTexture(surface.GetTextureID(curmat2:GetName()))
-- 	surface.SetDrawColor(255,255,255,255)
-- 	surface.DrawTexturedRect(0,0,255,255)
-- 	surface.SetMaterial(curmat)
-- 	surface.SetDrawColor(255,255,255,255)
-- 	surface.DrawTexturedRect(255,0,255,255)
-- 	surface.SetTexture(surface.GetTextureID(matat:GetName()))
-- 	surface.SetDrawColor(255,255,255,255)
-- 	surface.DrawTexturedRect(255+255,0,255,255)
-- 	surface.SetMaterial(matat)
-- 	surface.SetDrawColor(255,255,255,255)
-- 	surface.DrawTexturedRect(255+255+255,0,255,255)
-- 	--[[surface.SetTexture(surface.GetTextureID(curmat:GetTexture("$detail"):GetName()))
-- 	surface.SetDrawColor(255,255,255,255)
-- 	surface.DrawTexturedRect(255+255+255+255,0,255,255)--]]
-- 	--render.SetLightingMode(0)
-- 	--render.SuppressEngineLighting(false)
-- end)