AddCSLuaFile()
--
local delta = 0
local color_red = Color(255, 0, 0)

hook.Add("HG.InputMouseApply", "ChangeZoom", function(tbl)
	local ply = LocalPlayer()

	delta = Lerp(FrameTime() * 5, delta, 0)

	if IsAiming(ply) then
		delta = input.WasMousePressed(MOUSE_WHEEL_UP) and delta + 1 * (FrameTime() / engine.TickInterval()) or input.WasMousePressed(MOUSE_WHEEL_DOWN) and delta - 1 * (FrameTime() / engine.TickInterval()) or delta
		//tbl.cmd:SetMouseWheel(0)
		if LocalPlayer():KeyDown(IN_WALK) then
			delta = delta - tbl.y / 24
			tbl.y = 0
		end
	end
end)

function IsAimingNoScope(ply)
	local wep = ply:GetActiveWeapon()

	return IsValid(wep) and ishgweapon(wep) and hg.KeyDown(ply, IN_ATTACK2) and wep:CanUse()
end

function IsAiming(ply)
	local wep = ply:GetActiveWeapon()

	return IsValid(wep) and ishgweapon(wep) and hg.KeyDown(ply, IN_ATTACK2) and wep.attachments and wep:HasAttachment("sight","optic")
end

local rtsize = 512
local rtmat = GetRenderTargetEx("huy-glass22",
	rtsize, rtsize,
	RT_SIZE_NO_CHANGE,
	MATERIAL_RT_DEPTH_SHARED,
	bit.bor(2, 256),
	0,
	IMAGE_FORMAT_BGR888
)
local mat = Material("huy-glass")
local mat2 = Material("huy-glass")
SWEP.scopemat = Material("decals/scope.png")
SWEP.perekrestie = Material("decals/perekrestie3.png")
local limit = 1
local vecVel = Vector(0, 0, 0)
local angZero = Angle(0, 0, 0)
local vecZero = Vector(0, 0, 0)
SWEP.localScopePos = Vector(-21, 3.95, -0.2)
SWEP.scope_blackout = 400
SWEP.maxzoom = 3.5
SWEP.rot = 37
SWEP.FOVMin = 3.5
SWEP.FOVMax = 10
SWEP.blackoutsize = 2500
function surface.DrawTexturedRectRotatedHuy(x, y, w, h, rot, offsetX, offsetY, rotHuy)
	rotHuy = rotHuy or 0
	local newX = x + offsetX * math.sin(math.rad(rot))
	local newY = x + offsetX * math.cos(math.rad(rot))
	local newX = newX + offsetY * math.cos(math.rad(rot))
	local newY = newY - offsetY * math.sin(math.rad(rot))
	surface.DrawTexturedRectRotated(newX, newY, w, h, rot + rotHuy)
end

function surface.DrawTexturedRectRotatedPoint(x, y, w, h, rot, x0, y0)
	local c = math.cos(math.rad(rot))
	local s = math.sin(math.rad(rot))
	local newx = y0 * s - x0 * c
	local newy = y0 * c + x0 * s
	surface.DrawTexturedRectRotated(x + newx, y + newy, w, h, rot)
end

local addmat_r = Material("CA/add_r")
local addmat_g = Material("CA/add_g")
local addmat_b = Material("CA/add_b")
local vgbm = Material("vgui/black")
local function DrawCA(rx, gx, bx, ry, gy, by, mater)
	render.UpdateScreenEffectTexture()
	addmat_r:SetTexture("$basetexture", mater)
	addmat_g:SetTexture("$basetexture", mater)
	addmat_b:SetTexture("$basetexture", mater)
	local w, h = ScrW(), ScrH()
	render.SetMaterial(vgbm)
	render.DrawScreenQuad()
	render.SetMaterial(addmat_r)
	render.DrawScreenQuadEx(-rx / 2, -ry / 2, w + rx, h + ry)
	render.SetMaterial(addmat_g)
	render.DrawScreenQuadEx(-gx / 2, -gy / 2, w + gx, h + gy)
	render.SetMaterial(addmat_b)
	render.DrawScreenQuadEx(-bx / 2, -by / 2, w + bx, h + by)
end

lodset = false

local hg_optimise_scopes = GetConVar("hg_optimise_scopes") or CreateClientConVar("hg_optimise_scopes", "1", true, false, "Enable this if scoping makes your fps cry (1 - lowers quality of props around you, 2 - \"disables\" main render)", 0, 2)
local hg_show_hitposmuzzle = ConVarExists("hg_show_hitposmuzzle") and GetConVar("hg_show_hitposmuzzle") or CreateClientConVar("hg_show_hitposmuzzle", "0", false, false, "shows weapons crosshair, work only ведьма admin rank or sv_cheats 1")

local angaddhuy = Angle(0,0,0)
local scrw, scrh = ScrW(), ScrH() --retarded
function SWEP:DoRT()
	LOW_RENDER = nil
	
	local gun = self:GetWeaponEntity()
	local att = self:GetMuzzleAtt(gun, true)
	local owner = self:GetOwner()
	
	if not att then return end
	if not self.sizeperekrestie then return end
	
	self.isscoping = true

	local pos, ang = self:GetTrace(true, nil, nil, true)
	
	local optic
	local sight, foundatt = self:HasAttachment("sight", "optic")
	
	if foundatt and self.modelAtt and IsValid(self.modelAtt.sight) then
		pos = self.modelAtt.sight:GetPos()
		optic = true
	end
	
	local localPos = vecZero
	localPos:Set(self.localScopePos)
	localPos:Rotate(ang)
	pos:Add(localPos)
	--debugoverlay.Cross(pos,5,1)
	local view = render.GetViewSetup(true)
	local diff, point = util.DistanceToLine(view.origin, view.origin + ang:Forward() * 50, pos)
	local scope_pos = WorldToLocal(point, angle_zero, pos, view.angles)
	local mat = self.mat or mat2
	
	mat:SetTexture("$basetexture", rtmat)
	
	if hg_show_hitposmuzzle:GetBool() then
		//cam.Start3D()
			render.DrawLine(pos,point, Color( 255, 255, 255 ))
		//cam.End3D()
	end

	local firstPerson = lply == GetViewEntity()

	local localhuy = pos - view.origin
	local anghuy = localhuy:Angle()
	local dist = pos:Distance(view.origin)
	--ang[3] = ang[3] - 90--lply:EyeAngles()[3] + self.AdditionalAng[3]
	//ang[3] = ang//lply:EyeAngles()[3] //+ self.AdditionalAng[3]
	--ang[3] = view.angles[3]
	
	local mul = 4 * self.ZoomFOV / 7 * (self.scopedef and 400 / self.scope_blackout or 1)
	angaddhuy[1] = scope_pos[3] * mul
	angaddhuy[2] = -scope_pos[2] * mul
	
	local ang2 = ang + angaddhuy
	local pos2 = pos-- + ang2:Right() * -scope_pos[2] + ang2:Up() * scope_pos[3]

	local tr = util.QuickTrace(owner:EyePos(), (pos2 - owner:EyePos()) + (pos2 - owner:EyePos()):GetNormalized() * 5, {owner, owner.FakeRagdoll})

	local rt = {
		x = 0,
		y = 0,
		w = rtsize,
		h = rtsize,
		angles = ang2 + angle_difference2 * -0,
		origin = owner:InVehicle() and pos2 or tr.HitPos - (pos2 - owner:EyePos()):GetNormalized() * 5,
		drawviewmodel = false,
		fov = math.max(self.ZoomFOV,0.5) / dist * 12,
		znear = 1,
		zfar = zfar,
		bloomtone = false
	}
	--debugoverlay.Axis(rt.origin,rt.angles,5,1)
	--render.RenderView(rt)

	local scr1 = pos:ToScreen()
	local scr2 = point:ToScreen()
	local diffa = Vector((scr1.x-scr2.x) / scrw,(scr1.y-scr2.y) / scrh)

	render.PushRenderTarget(rtmat, 0, 0, rtsize, rtsize)
	RENDERING_SCOPE = self
	render.Clear(1, 1, 1, 255)
	render.SetWriteDepthToDestAlpha( false )

	local old = DisableClipping(true)

	diffa[1] = diffa[1] * ScrW() * 2
	diffa[2] = diffa[2] * ScrH() * 2

	if diffa:LengthSqr() < 10000.0 * (rtsize / 512) / (self.scope_blackout / 400) then
		if hg_optimise_scopes:GetInt() >= 2 then
			--LOW_RENDER = true
			--render.UpdateScreenEffectTexture()
			--render.UpdateFullScreenDepthTexture()
			--local screen = render.GetScreenEffectTexture()

			--render.CopyTexture( screen, rtmat )

			--render.DrawTextureToScreen(rtmat_spare)
    		--render.UpdateFullScreenDepthTexture()
		end
		
		render.RenderView(rt)

		cam.Start3D()
			local aimWay = (ang:Forward()) * 10000000000
			local toscreen = aimWay:ToScreen()
			local x, y = toscreen.x, toscreen.y
			local hitPos
			if hg_show_hitposmuzzle:GetBool() then
				hitPos = self:GetTrace(true).HitPos:ToScreen()
			end
		cam.End3D()
		
		local cocking = self:GetNetVar("shootgunReload", 0) > CurTime()
		
		if cocking then
			local val = (CurTime() - self:GetNetVar("shootgunReload", 0)) * 1024
			--x = x + val
			--diffa[1] = diffa[1] - val
			--y = y - 0
		end

		local distMul = math.min(15, 1.2 * 2.5 * (15 / self.ZoomFOV))
		
		local dist = math.sqrt(((x - scrw / 2) * distMul)^2 + ((y - scrh / 2) * distMul)^2)
		
		if dist > 2048 then
			render.Clear(0, 0, 0, 255)
		end

		render.PushFilterMin(TEXFILTER.ANISOTROPIC)
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		cam.Start2D()
			if hg_show_hitposmuzzle:GetBool() then
				draw.RoundedBox(0, hitPos.x / (scrw / ScrW()) - 2, hitPos.y / (scrh / ScrH()) - 2, 4, 4, color_red)
			end
			local blackout = self.blackoutsize * 0.75
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetMaterial(self.perekrestie)
			surface.DrawTexturedRectRotatedHuy(0, 0, (self.sizeperekrestie * rtsize / 512) / ((self.perekrestieSize and 4 ) or self.ZoomFOV / 3), (self.sizeperekrestie * rtsize / 512) / ((self.perekrestieSize and 4 ) or self.ZoomFOV / 3), 0, y / (scrh / ScrH()), x / (scrw / ScrW()), self.rot)

			surface.SetDrawColor(100, 100, 100)
			surface.SetMaterial(self.scopemat)
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * rtsize / 512 * 2 + 512, blackout * rtsize / 512 * 2 + 512, 0, (ScrH() - y / (scrh / ScrH()) - rtsize / 2) * distMul * 1 + rtsize / 2, (ScrW() - x / (scrw / ScrW()) - rtsize / 2) * distMul * 1 + rtsize / 2)
			surface.SetDrawColor(0, 0, 0, 255)
			surface.SetMaterial(self.scopemat)
			local x1 = x * math.atan(math.rad(math.cos(CurTime()) * 1))
			local y1 = y * math.atan(math.rad(math.sin(CurTime()) * 1))
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * 0.75 * rtsize / 512 + 512, blackout * rtsize / 512 * 0.75 + 512, 0, (y1 * 1 / (scrh / ScrH())) * distMul + rtsize / 2, (x1 * 1 / (scrw / ScrW()) * distMul) + rtsize / 2)
			surface.DrawTexturedRectRotatedHuy(0, 0, blackout * 0.75 * rtsize / 512 + 512, blackout * rtsize / 512 * 0.75 + 512, 0, -diffa[2] * 2 * distMul + rtsize / 2, -diffa[1] * 2 * distMul + rtsize / 2)
			if self.SightDrawFunc then self:SightDrawFunc() end
			if optic and foundatt.SightDrawFunc then foundatt.SightDrawFunc(self) end
			--surface.DrawTexturedRectRotatedHuy(rtsize / 2, rtsize / 2, blackout * rtsize / 512 + 100, blackout * rtsize / 512 + 100, self.rot, -scope_pos[3] * (self.scope_blackout * blackout / 4000), -scope_pos[2] * (self.scope_blackout * blackout / 4000))
		cam.End2D()
		render.PopFilterMin()
		render.PopFilterMag()
	end

	DisableClipping(old)
	RENDERING_SCOPE = false
	render.PopRenderTarget()

	--surface.SetDrawColor(255, 255, 255, 255)
	--surface.SetMaterial(mat)
	--surface.DrawTexturedRect(0, 0, 255, 255)

	--if self.k > 0.5 then
	--	DrawCA(10, -10, 50, 20, -10, 5, rtmat)
	--end
end

function SWEP:ChangeFOV()
	self.ZoomFOV = math.Clamp(self.ZoomFOV - (delta / 10 or 0), self.FOVMin, self.FOVMax)
end

--
local vecZero = Vector(0, 0, 0)
local function WorldToScreen(vWorldPos, vPos, vScale, aRot, verticalScale)
	local vWorldPos = vWorldPos - vPos
	vWorldPos:Rotate(Angle(0, -aRot.y, 0))
	vWorldPos:Rotate(Angle(-aRot.p, 0, 0))
	vWorldPos:Rotate(Angle(0, 0, -aRot.r))
	return vWorldPos.x / vScale, (-vWorldPos.y) / (vScale * verticalScale)
end

SWEP.size = 0.0007
SWEP.holo_pos = Vector(-0.82, 3.48, 25)
SWEP.holo = Material("holo/huy-holo2.png")
SWEP.holo_lum = 1
SWEP.scale = Vector(1, 1.3, 1)

local anghuy = Angle(0,0,0)
local vechuy = Vector(0,0,0)

local exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

local customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
	["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
	["$translucent"] = 1,
		["$vertexcolor"] = 1
} )

local mat_Mul = Material("pp/mul")
local mat_Add = Material("pp/add")
mat_Add:SetTexture("$basetexture", exampleRT)
mat_Add:SetVector("$color2", Vector(10, 10, 10))

hook.Add("InitPostEntity","zc_huyhuy",function()
	exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

	customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
		["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
		["$translucent"] = 1,
		["$vertexcolor"] = 1
	} )

	mat_Mul = Material("pp/mul")
	mat_Add = Material("pp/add")
	mat_Add:SetTexture("$basetexture", exampleRT)
	mat_Add:SetVector("$color2", Vector(10, 10, 10))

end)


gameevent.Listen( "OnRequestFullUpdate" )
hook.Add( "OnRequestFullUpdate", "RT_shits", function( data )
	exampleRT = GetRenderTarget( "example_rt", 1024, 1024 )

	customMaterial = CreateMaterial( "example_rt_mat", "UnlitGeneric", {
		["$basetexture"] = exampleRT:GetName(), -- You can use "example_rt" as well
		["$translucent"] = 1,
		["$vertexcolor"] = 1
	} )

	mat_Mul = Material("pp/mul")
	mat_Add = Material("pp/add")
	mat_Add:SetTexture("$basetexture", exampleRT)
	mat_Add:SetVector("$color2", Vector(10, 10, 10))
end )

function SWEP:DoHolo()
end

local blured
// ПОЙНТ ТЫ НУБ ПОЛНЫЙ
--local hg_blur_holo = GetConVar("hg_blur_holo") or CreateClientConVar("hg_blur_holo", "1", true, false, "Disable this if holo blur makes your fps cry.", 0, 1)

local invcolor = Color(0,0,0,0)
hook.Add("PostDrawTranslucentRenderables","stencil-test-holo2",function()
	local ply = not LocalPlayer():Alive() and LocalPlayer():GetNWEntity("spect",LocalPlayer()) or LocalPlayer()
	if not IsValid(ply) then return end
	local self = ply.GetActiveWeapon and ply:GetActiveWeapon() or nil
	if not IsValid(self) or not self.ishgwep or not self.GetWeaponEntity or not IsValid(self:GetWeaponEntity()) then return end

	local models = self.holomodels
	if not models and not self.internalholo then return end
	local tr, pos, ang = self:GetTrace()
	local view = render.GetViewSetup()
	local eyePos = view.origin
	local hitPos = eyePos + ang:Forward() * 2624
	
	if blured ~= self.holo then
		// МОЙ ДРУГ ТОЛЬКО С ПРОЦЕССОРОМ НЕ МОГ ИГРАТЬ НОРМАЛЬНО С ГОЛОГРАФАМИ!!!!
		// ТЫ ОЧЕНЬ ПЛОХОЙ!!! И НУЫЫЫЫЫ																							|\_/|
		// Короче я пофиксил какашку, теперь блюр один раз на изменение текстуры, теперь смешных приколов фпс падений не будет. |'.'|
		// ПЛЫВ ПЛЫВ ПЛЫВ																										|	|
		// ЭТО САМЫЙ БОЛЬШОЙ КОМЕНТАРИЙ ХЕХЕХЕХЕХЕЕХ																		   	|___|
		render.PushRenderTarget( exampleRT )
			render.OverrideAlphaWriteEnable( true, true )

			render.ClearDepth()
			render.Clear( 0, 0, 0, 0 )	

			DisableClipping(true)

				cam.Start2D()
					surface.SetDrawColor(255, 255, 255, 150)
					surface.SetMaterial(self.holo)
					surface.DrawTexturedRect(0, 0, 1024, 1024)
					render.BlurRenderTarget(exampleRT, 1, 1, 6)

					for i = 1, 2 do
						render.SetMaterial(mat_Add)
						render.DrawScreenQuad()
					end--]]
				cam.End2D()

			DisableClipping(false)

			render.OverrideAlphaWriteEnable( false )
		render.PopRenderTarget()

		blured = self.holo
	end

	if models or self.internalholo then
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.ClearStencil()
		
		-- Enable stencils
		render.SetStencilEnable( true )
		-- Set everything up everything draws to the stencil buffer instead of the screen
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
		render.SetStencilPassOperation( STENCIL_REPLACE )

		render.SetBlend(0)
		local mdl
		if models then
			for model in pairs(models) do
				if not IsValid(model) then continue end
				model:DrawModel()
				mdl = model
			end
		else
			local zoom, anga = self:GetZoomPos(vector_origin, view, view.origin)
			local sightpos, _ = LocalToWorld(self.internalholo, angle_zero, zoom, anga)
			
			render.SetColorMaterial()
			render.DrawSphere(sightpos, self.internalholosize, 5, 5, invcolor)
		end

		render.SetBlend(1)

		render.SetStencilCompareFunction( STENCIL_EQUAL )
		--render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )
		render.PushFilterMag(TEXFILTER.ANISOTROPIC)
		render.PushFilterMin(TEXFILTER.ANISOTROPIC)

		cam.Start2D()
			local x,y = hitPos:ToScreen().x,hitPos:ToScreen().y
			local m = Matrix()
			local w,h = ScrW(),ScrH()
			vechuy[1] = w / 2
			vechuy[2] = h / 2
			local center = vechuy

			m:Translate( center )
			anghuy[2] = ang[3] - 0 - view.angles[3]
			m:Rotate( anghuy )
			m:Translate( -center )

			local size = 18
			local distToSight = IsValid(mdl) and mdl:GetPos():Distance(view.origin) or 1
			--print(distToSight)
			size = size * math.Remap(view.fov,75,100,1.8,1)
			size = size * math.Remap(distToSight,6,14,1.2,0.9)
			--size = size * 
			--render.OverrideBlend( true,BLEND_DST_COLOR,BLEND_ONE,BLENDFUNC_ADD )
			--	surface.SetDrawColor(255,255,255,15)
			--	surface.SetMaterial(customMaterial)
			--	surface.DrawTexturedRectRotatedPoint(x,y,size * 2 * self.holo_size,size * 2 * self.holo_size,-anghuy[2],-0,0)
			--render.OverrideBlend( false )

			surface.SetDrawColor(self.colorholo or color_white)
			surface.SetMaterial(self.holo)
			surface.DrawTexturedRectRotatedPoint(x,y,size * 2 * self.holo_size,size * 2 * self.holo_size,-anghuy[2],-0,0)

		cam.End2D()
		render.PopFilterMag()
		render.PopFilterMin()

		-- Let everything render normally again
		render.SetStencilEnable( false )

	end

end)

hook.Add("RenderScreenspaceEffects","stencil-test-holo2",function()
	--[[local ply = not LocalPlayer():Alive() and LocalPlayer():GetNWEntity("spect",LocalPlayer()) or LocalPlayer()
	local self = ply.GetActiveWeapon and ply:GetActiveWeapon() or nil
	if not IsValid(self) or not self.GetWeaponEntity or not IsValid(self:GetWeaponEntity()) then return end

	local att = self:GetMuzzleAtt(nil,true,false)
	local models = self.holomodels
	if not models then return end
	local view = render.GetViewSetup()
	local eyePos = view.origin
	local hitPos = eyePos + att.Ang:Forward() * 2624

	if models then
		render.SetStencilWriteMask( 0xFF )
		render.SetStencilTestMask( 0xFF )
		render.SetStencilReferenceValue( 0 )
		render.SetStencilCompareFunction( STENCIL_ALWAYS )
		render.SetStencilPassOperation( STENCIL_KEEP )
		render.SetStencilFailOperation( STENCIL_KEEP )
		render.SetStencilZFailOperation( STENCIL_KEEP )
		render.ClearStencil()
		
		-- Enable stencils
		render.SetStencilEnable( true )
		-- Set everything up everything draws to the stencil buffer instead of the screen
		render.SetStencilReferenceValue( 1 )
		render.SetStencilCompareFunction( STENCIL_NOTEQUAL )
		render.SetStencilPassOperation( STENCIL_REPLACE )
		
		for model in pairs(models) do
			if not IsValid(model) then continue end
			model:DrawModel()
		end

		render.SetStencilCompareFunction( STENCIL_EQUAL )

		render.SetStencilEnable( false )

	end--]]

end)

hook.Add("PostDrawOpaqueRenderables","stencil-test-holo",function()
	--wtf teplak??!???
	if true then return end
	render.SetStencilWriteMask( 0xFF )
	render.SetStencilTestMask( 0xFF )
	render.SetStencilReferenceValue( 0 )
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	render.SetStencilPassOperation( STENCIL_KEEP )
	render.SetStencilFailOperation( STENCIL_KEEP )
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.ClearStencil()

	-- Enable stencils
	render.SetStencilEnable( true )
	-- Set the reference value to 1. This is what the compare function tests against
	render.SetStencilReferenceValue( 1 )
	-- Always draw everything
	render.SetStencilCompareFunction( STENCIL_ALWAYS )
	
	render.SetStencilZFailOperation( STENCIL_KEEP )
	render.SetStencilPassOperation( STENCIL_REPLACE )

	-- Draw our entities. They will draw as normal
	for _, ent in player.Iterator() do
		ent:DrawModel()
	end
	
	-- Now, only draw things that have their pixels set to 1. This is the hidden parts of the stencil tests.
	render.SetStencilCompareFunction( STENCIL_EQUAL )
	-- Flush the screen. This will draw teal over all hidden sections of the stencil tests
	
	render.ClearBuffersObeyStencil( 0, 148, 133, 255, false )

	-- Let everything render normally again
	render.SetStencilEnable( false )

end)
