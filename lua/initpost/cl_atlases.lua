
local atlas_list = "zcity/neurotrauma/AfflictionIcons.png"
local atlas_list2 = "zcity/neurotrauma/AfflictionIcons2.png"
local atlas_list3 = "zcity/neurotrauma/MainIconsAtlas.png"

local mater = Material(atlas_list)
local mater2 = Material(atlas_list2)
local mater3 = Material(atlas_list3)

local tex1 = mater:GetTexture("$basetexture")
local tex2 = mater2:GetTexture("$basetexture")
local tex3 = mater3:GetTexture("$basetexture")

local function getAtlas(texture, x, y, amt, name)
	local mat = CreateMaterial(name, "UnlitGeneric", {
		["$translucent"] = 1,
		["$vertexalpha"] = 1,
		["$vertexcolor"] = 1,
		["$basetexture"] = texture
	})
	mat:SetTexture("$basetexture", texture)
	mat:SetMatrix("$basetexturetransform", Matrix(
		{
			{1 / amt, 0, 0, x / amt},
			{0,	1 / amt, 0, y / amt},
			{0,	0, 1, 0},
			{0, 0, 0, 1}
		}
	))

	return mat
end

local pale = getAtlas(tex1, 0, 0, 8, "pale")
local concussion = getAtlas(tex1, 1, 0, 8, "concussion")
local lung_failure = getAtlas(tex1, 3, 0, 8, "lung_failure")
local arterial_bleeding = getAtlas(tex1, 3, 3, 8, "arterial_bleeding")
local cardiac_arrest = getAtlas(tex1, 0, 1, 8, "cardiac_arrest")
local beheaded = getAtlas(tex1, 4, 6, 8, "beheaded")
local bleeding = getAtlas(tex3, 7, 5, 8, "bleeding")
local fracture = getAtlas(tex1, 6, 2, 8, "fracture")
local blunt = getAtlas(tex2, 4, 0, 8, "blunt")
local lightheaded = getAtlas(tex2, 0, 0, 8, "lightheaded")
local pain = getAtlas(tex1, 7, 2, 8, "pain")

local color_red_yellow = Color(200, 255, 0, 255)
local color_white = Color(255, 255, 255, 255)
local color_red = Color(200, 0, 0, 255)

local afflictions = {
	--			name					material			color				should change color?
	[1]		=	{"bleeding",			bleeding,			color_red_yellow,	true},
	[2]		=	{"concussion",			concussion,			color_white,		false},
	[3]		=	{"lung_failure",		lung_failure,		color_red,			false},
	[4]		=	{"arterial_bleeding",	arterial_bleeding,	color_red,			false},
	[5]		=	{"cardiac_arrest",		cardiac_arrest,		color_red,			false},
	[6]		=	{"beheaded",			beheaded,			color_red,			false},
	[7]		=	{"pale",				pale,			    color_white,	    false},
	[8]		=	{"lfracture",			fracture,			color_red,	    	true},
	[9]		=	{"lblunt",				blunt,				color_red,	    	true},
	[10]	=	{"afracture",			fracture,			color_red,	    	true},
	[11]	=	{"ablunt",				blunt,				color_red,	    	true},
	[12]	=	{"lightheaded",			lightheaded,		color_white,	    false},
	[13]	=	{"pain",				pain,				color_red,	    	true},
}

hg.afflictions = {}
for i = 1, #afflictions do
	hg.afflictions[afflictions[i][1]] = i
end

function hg.DrawAffliction(x, y, w, h, amt, index_or_name, alpha, text)
	local index = isnumber(index_or_name) and index_or_name or hg.afflictions[index_or_name]
	local affliction = afflictions[index]

	if not affliction then return end

	local r, g, b, a = affliction[3]:Unpack()
	if affliction[4] then g = math.max((1 - amt) - 0.2, 0) * 255 end
	if alpha then a = alpha end
	
	surface.SetDrawColor(r, g, b, a)
	surface.SetMaterial(affliction[2])
	surface.DrawTexturedRect(x, y, w, h)

	local cx, cy = input.GetCursorPos()

	if cx > x and cx < x + w and cy > y and cy < y + h then
		surface.SetFont("HomigradFontSmall")
		surface.SetTextColor(255, 255, 255, a)
		local txt = text or affliction[1]
		local w1, h1 = surface.GetTextSize(txt)
		surface.SetTextPos(x + w * 0.5 - w1 * 0.5, y + h + h1 * 0.5)
		surface.DrawText(txt)
	end
end