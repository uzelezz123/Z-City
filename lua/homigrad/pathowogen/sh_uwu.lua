-- hiiii haiii halloooo :3 >w<

local function check(self, ent, ply)
	if not ply:ZCTools_GetAccess() then return false end
	if ( !IsValid( ent ) ) then return false end
	if ( ent:IsPlayer() ) then return true end
	local pEnt = hg.RagdollOwner( ent )
	if ( ent:IsRagdoll() ) and pEnt and pEnt:IsPlayer() and pEnt:Alive() then return true end
end

properties.Add( "furrify", {
	MenuLabel = "Furrify :3", -- Name to display on the context menu
	Order = 10, -- The order to display this property relative to other properties
	MenuIcon = "vgui/entities/npc_nukude_proto_h", -- The icon to display next to the property

	Filter = check,
	Action = function( self, ent ) -- The action to perform upon using the property ( Clientside )
		self:MsgStart()
			net.WriteEntity( ent )
		self:MsgEnd()
	end,
	Receive = function( self, length, ply ) -- The action to perform upon using the property ( Serverside )
		local ent = net.ReadEntity()

		if not self:Filter(ent, ply) then return end
		ent = hg.RagdollOwner(ent) or ent

		hg.Furrify(ent)
		print(tostring(ply:Nick() or ply) .." has turned ".. tostring(ent:Nick() or ent) .." into a furry ")
	end
} )

if CLIENT then
	local sw = ScrW()

	local bluewhite = Color(187, 187, 255)

	surface.CreateFont("ZB_ProotOSHUD", {
		font = "Ari-W9500",
		size = ScreenScale(25),
		extended = true,
		weight = 400,
	})

	local function DrawTextAndShadow(txt, font, x, y, color, alignX, alignY)
		draw.SimpleText(txt, font, x + 2, y + 2, color_black, alignX, alingY)
		draw.SimpleText(txt, font, x, y, color, alignX, alingY)
	end

	local LastBlink = 0
	local BlinkDelay = 0

	hook.Add("RenderScreenspaceEffects", "furbot", function()
		if LocalPlayer().PlayerClassName != "furry" then
			if IsValid(hg.matrix) then
				hg.matrix:Close()
			end
			return
		end

		local org = LocalPlayer().organism
		if org.otrub and !IsValid(hg.matrix) then
			vgui.Create("ZB_Matrix")
		elseif !org.otrub and IsValid(hg.matrix) then
			hg.matrix:Close()
		end

		for i = 1, sw / 4 do
			surface.SetDrawColor(0, 0, 0, 50)
			surface.DrawRect(0, i * 4, sw, 2)
		end

		if IsValid(hg.furload) and hg.furload.alpha >= 255 then return end

		local Status = "NOMINAL"

		local damageSum = 0

		damageSum = damageSum + org.lleg * 3
		damageSum = damageSum + org.rleg * 3
		damageSum = damageSum + org.larm * 3
		damageSum = damageSum + org.larm * 3

		damageSum = damageSum + (org.llegdislocation and 2 or 0)
		damageSum = damageSum + (org.rlegdislocation and 2 or 0)
		damageSum = damageSum + (org.larmdislocation and 2 or 0)
		damageSum = damageSum + (org.larmdislocation and 2 or 0)


		damageSum = damageSum + (5000 - org.blood) / 500

		damageSum = damageSum + org.pelvis
		damageSum = damageSum + org.brain * 10

		if damageSum >= 10 then
			Status = "CRITICAL"
		elseif damageSum >= 7 then
			Status = "Heavy damage"
		elseif damageSum >= 4 then
			Status = "Moderate damage"
		elseif damageSum >= 2 then
			Status = "Minor damage"
		elseif damageSum > 0 then
			Status = "Minimal damage"
		end

		DrawTextAndShadow("System status: " .. Status, "ZB_ProotOSMedium", sw * 0.01, sh * 0.96, bluewhite, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		local Emoticon = "OwO"

		if BlinkDelay > CurTime() then
			Emoticon = "-w-"
		elseif LastBlink < CurTime() then
			Emoticon = "-w-"
			LastBlink = CurTime() + math.Rand(5, 10)
			BlinkDelay = CurTime() + 0.5
		elseif org.consciousness < 0.8 then
			Emoticon = "@w@"
		elseif org.pain > 30 then
			Emoticon = ">w<"
		elseif org.pain > 5 then
			Emoticon = "QwQ"
		elseif org.analgesia > 0.5 then
			Emoticon = "^w^"
		end

		DrawTextAndShadow(Emoticon, "ZB_ProotOSHUD", sw * 0.045, sh * 0.89, bluewhite, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end)
end