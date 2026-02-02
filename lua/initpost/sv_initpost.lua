

timer.Simple(1, function()
    -- function GAMEMODE:PlayerSay( ply, text, teamonly ) // commands and shit get called about here

    --     local txt = {text}
    --     hook.Run("HG_PlayerSay", ply, txt) // our shit gets called later
    --     text = isstring(txt[1]) and txt[1] or text // checks to see if shit hits the ceiling

	-- 	hook.Run("PostPlayerSay", ply, text)
    --     return text
    -- end
    
    hook.Add("HG_PlayerSay", "OwOmove", function(ply, txt)
        //txt[1] = "huy"
    end)
end)

--[[---------------------------------------------------------
	Name: gamemode:ScalePlayerDamage( ply, hitgroup, dmginfo )
	Desc: Scale the damage based on being shot in a hitbox
		 Return true to not take damage
-----------------------------------------------------------]]
function GAMEMODE:ScalePlayerDamage( ply, hitgroup, dmginfo )
    do return end
	-- More damage if we're shot in the head
	if ( hitgroup == HITGROUP_HEAD ) then

		dmginfo:ScaleDamage( 2 )

	end

	-- Less damage if we're shot in the arms or legs
	if ( hitgroup == HITGROUP_LEFTARM ||
		 hitgroup == HITGROUP_RIGHTARM ||
		 hitgroup == HITGROUP_LEFTLEG ||
		 hitgroup == HITGROUP_RIGHTLEG ||
		 hitgroup == HITGROUP_GEAR ) then

		dmginfo:ScaleDamage( 0.25 )

	end

end