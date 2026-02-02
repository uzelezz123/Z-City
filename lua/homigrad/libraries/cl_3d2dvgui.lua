--[[
	
3D2D VGUI Wrapper
Copyright (c) 2015-2017 Alexander Overvoorde, Matt Stevens

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]--

local origin = Vector(0, 0, 0)
local angle = Angle(0, 0, 0)
local normal = Vector(0, 0, 0)
local scale = 0
local maxrange = 0

-- Helper functions

local function getCursorPos()
	local view = render.GetViewSetup(true)
	local x,y = input.GetCursorPos()
	--gui.ScreenToVector(x,y)
	local dir = util.AimVector(view.angles,view.fov,x,y,ScrW(),ScrH())
	
	local p = util.IntersectRayWithPlane(view.origin, dir, origin, normal)

	-- if there wasn't an intersection, don't calculate anything.
	if not p then return end
	if WorldToLocal(view.origin, Angle(0,0,0), origin, angle).z < 0 then return end
	
	if maxrange > 0 then
		if p:Distance(LocalPlayer():EyePos()) > maxrange then
			return
		end
	end

	local pos = WorldToLocal(p, Angle(0,0,0), origin, angle)
	
	return pos.x, -pos.y
end
vgui.getCursorPos3D2D = getCursorPos

local function getParents(pnl)
	local parents = {}
	local parent = pnl:GetParent()
	while parent do
		table.insert(parents, parent)
		parent = parent:GetParent()
	end
	return parents
end

local function absolutePanelPos(pnl)
	local x, y = pnl:GetPos()
	local parents = getParents(pnl)
	
	for _, parent in ipairs(parents) do
		local px, py = parent:GetPos()
		x = x + px
		y = y + py
	end
	
	return x, y
end

local function pointInsidePanel(pnl, x, y)
	local px, py = absolutePanelPos(pnl)
	local sx, sy = pnl:GetSize()

	if not x or not y then return end

	x = x / scale
	y = y / scale

	return pnl:IsVisible() and x >= px and y >= py and x <= px + sx and y <= py + sy
end

-- Input

local inputWindows = {}
local usedpanel = {}

local function isMouseOver(pnl)
	return pointInsidePanel(pnl, getCursorPos())
end

local function postPanelEvent(pnl, event, ...)
	if not IsValid(pnl) or not pnl:IsVisible() or not pointInsidePanel(pnl, getCursorPos()) then return false end

	local handled = false
	
	for i, child in pairs(table.Reverse(pnl:GetChildren())) do
		if not child:IsMouseInputEnabled() then continue end
		
		if postPanelEvent(child, event, ...) then
			handled = true
			break
		end
	end
	
	if not handled and pnl[event] then
		pnl[event](pnl, ...)
		usedpanel[pnl] = {...}
		return true
	else
		return false
	end
end

-- Always have issue, but less
local function checkHover(pnl, x, y, found)
	if not (x and y) then
		x, y = getCursorPos()
	end

	local validchild = false
	for c, child in pairs(table.Reverse(pnl:GetChildren())) do
		if not child:IsMouseInputEnabled() then continue end
		
		local check = checkHover(child, x, y, found or validchild)

		if check then
			validchild = true
		end
	end

	if found then
		if pnl.Hovered then
			pnl.Hovered = false
			if pnl.OnCursorExited then pnl:OnCursorExited() end
		end
	else
		if not validchild and pointInsidePanel(pnl, x, y) then
			pnl.Hovered = true
			if pnl.OnCursorEntered then pnl:OnCursorEntered() end

			return true
		else
			pnl.Hovered = false
			if pnl.OnCursorExited then pnl:OnCursorExited() end
		end
	end

	return false
end

-- Mouse input
local lmbdown,rmbdown
local lmbpressed,rmbpressed
hook.Add("SetupMove", "VGUI3D2DMousePress", function(ply,mv,cmd)
	local LMB = input.IsMouseDown(MOUSE_LEFT)
	local RMB = input.IsMouseDown(MOUSE_RIGHT)
	
	lmbpressed = false
	rmbpressed = false
	if LMB then
		if not lmbdown then
			lmbpressed = true
		end
		lmbdown = true
	else
		lmbdown = false
	end

	if RMB then
		if not rmbdown then
			rmbpressed = true
		end
		rmbdown = true
	else
		rmbdown = false
	end

	if lmbpressed or rmbpressed then
		for pnl in pairs(inputWindows) do
			if IsValid(pnl) then
				origin = pnl.Origin
				scale = pnl.Scale
				angle = pnl.Angle
				normal = pnl.Normal

				local key = lmbpressed and MOUSE_LEFT or MOUSE_RIGHT
				
				postPanelEvent(pnl, "OnMousePressed", key)
			end
		end
	end

	local LMB = input.WasMouseReleased(MOUSE_LEFT)
	local RMB = input.WasMouseReleased(MOUSE_RIGHT)
	if LMB or RMB then
		for pnl, key in pairs(usedpanel) do
			if IsValid(pnl) then
				origin = pnl.Origin
				scale = pnl.Scale
				angle = pnl.Angle
				normal = pnl.Normal

				if pnl["OnMouseReleased"] then
					pnl["OnMouseReleased"](pnl, key[1])
				end

				usedpanel[pnl] = nil
			end
		end
	end
end)
is3d2d = false
function vgui.Start3D2D(pos, ang, res)
	origin = pos
	scale = res
	angle = ang
	normal = ang:Up()
	maxrange = 0
	
	cam.Start3D2D(pos, ang, res)
	is3d2d = true
end

function vgui.MaxRange3D2D(range)
	maxrange = isnumber(range) and range or 0
end

function vgui.IsPointingPanel(pnl)
	origin = pnl.Origin
	scale = pnl.Scale
	angle = pnl.Angle
	normal = pnl.Normal

	return pointInsidePanel(pnl, getCursorPos())
end

local Panel = FindMetaTable("Panel")
function Panel:Paint3D2D()
	if not self:IsValid() then return end
	
	-- Add it to the list of windows to receive input
	inputWindows[self] = true

	-- Override gui.MouseX and gui.MouseY for certain stuff
	local oldMouseX = gui.MouseX
	local oldMouseY = gui.MouseY
	local cx, cy = getCursorPos()
	
	function gui.MouseX()
		return (cx or 0) / scale
	end
	function gui.MouseY()
		return (cy or 0) / scale
	end
	
	--surface.DrawRect(gui.MouseX() - 5,gui.MouseY() - 5,10,10)

	-- Override think of DFrame's to correct the mouse pos by changing the active orientation
	if self.Think then
		if not self.OThink then
			self.OThink = self.Think
			
			self.Think = function()
				origin = self.Origin
				scale = self.Scale
				angle = self.Angle
				normal = self.Normal
				
				self:OThink()
			end
		end
	end
	
	-- Update the hover state of controls
	local _, tab = checkHover(self)
	
	-- Store the orientation of the window to calculate the position outside the render loop
	self.Origin = origin
	self.Scale = scale
	self.Angle = angle
	self.Normal = normal
	
	-- Draw it manually
	self:SetPaintedManually(false)
		self:PaintManual()
	self:SetPaintedManually(true)

	gui.MouseX = oldMouseX
	gui.MouseY = oldMouseY
end

function vgui.End3D2D()
	cam.End3D2D()
	is3d2d = false
end