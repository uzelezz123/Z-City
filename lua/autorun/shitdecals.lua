
-- // new blood

game.AddDecal("Normal.Blood21", {
    "effects/droplets/drop1_1",
    "effects/droplets/drop2_1",
    "effects/droplets/drop3_1",
    "effects/droplets/drop4_1",
    "effects/droplets/drop6_1",
    "effects/droplets/drop7_1",
    "effects/droplets/drop8_1",
    "effects/droplets/drop9_1",
    "effects/droplets/drop10_1",
    "effects/droplets/drop11_1",
})

game.AddDecal("Normal.Blood22", {
    "effects/droplets/drop1_2",
    "effects/droplets/drop2_2",
    "effects/droplets/drop3_2",
    "effects/droplets/drop4_2",
    "effects/droplets/drop6_2",
    "effects/droplets/drop7_2",
    "effects/droplets/drop8_2",
    "effects/droplets/drop9_2",
    "effects/droplets/drop10_2",
    "effects/droplets/drop11_2",
})

game.AddDecal("Normal.Blood23", {
    "effects/droplets/drop1_3",
    "effects/droplets/drop2_3",
    "effects/droplets/drop3_3",
    "effects/droplets/drop4_3",
    "effects/droplets/drop6_3",
    "effects/droplets/drop7_3",
    "effects/droplets/drop8_3",
    "effects/droplets/drop9_3",
    "effects/droplets/drop10_3",
    "effects/droplets/drop11_3",
})

game.AddDecal("Normal.Blood24", {
    "effects/droplets/drop1_4",
    "effects/droplets/drop2_4",
    "effects/droplets/drop3_4",
    "effects/droplets/drop4_4",
    "effects/droplets/drop6_4",
    "effects/droplets/drop7_4",
    "effects/droplets/drop8_4",
    "effects/droplets/drop9_4",
    "effects/droplets/drop10_4",
    "effects/droplets/drop11_4",
})

game.AddDecal("Normal.Blood25", {
    "effects/droplets/drop1_5",
    "effects/droplets/drop2_5",
    "effects/droplets/drop3_5",
    "effects/droplets/drop4_5",
    "effects/droplets/drop6_5",
    "effects/droplets/drop7_5",
    "effects/droplets/drop8_5",
    "effects/droplets/drop9_5",
    "effects/droplets/drop10_5",
    "effects/droplets/drop11_5",
})

game.AddDecal("Arterial.Blood21", {
    "effects/droplets/drop12_1",
})

game.AddDecal("Arterial.Blood22", {
    "effects/droplets/drop12_2",
})

game.AddDecal("Arterial.Blood23", {
    "effects/droplets/drop12_3",
})

game.AddDecal("Arterial.Blood24", {
    "effects/droplets/drop12_4",
})

game.AddDecal("Arterial.Blood25", {
    "effects/droplets/drop12_5",
})

-- // old blood

game.AddDecal("Normal.Blood1", {
    "decals/z_blood1",
    "decals/z_blood2",
    "decals/z_blood3",
    "decals/z_blood4",
    "decals/z_blood5",
    "decals/z_blood6",
    "decals/z_blood7",
    "decals/z_blood8",
    "decals/z_blood9",
    "decals/z_blood10",
})

game.AddDecal("Arterial.Blood1", {
    "decals/arterial_blood1",
    "decals/arterial_blood2",
    "decals/arterial_blood3",
    "decals/arterial_blood4",
    "decals/arterial_blood5",
    "decals/arterial_blood6",
    "decals/arterial_blood7",
    "decals/arterial_blood8",
    "decals/arterial_blood9",
    "decals/arterial_blood10",
})

-- // head'n shoulders

game.AddDecal("Water.Blood", "effects/smoke_b")

if CLIENT then
    local func = function()
		for i = 1, 5 do
			for j = 1, 11 do
				local mat = Material("effects/droplets/drop"..j.."_"..i)
				
				mat:SetFloat("$decalscale", i * 0.07)
			end
		end

        /*
            "DecalModulate"
            {
            "$basetexture" "effects/droplets/drop13"

            "$decalscale" "0.02"
            "$decalscalevariation" "0.02"
            "$decal" "1" 
            "$nocull" "1"
            "$translucent" "1"


            "$vertexcolor" "1"
            "$vertexalpha" "1"
            }
        */
    end
    
    hook.Add("InitPostEntity", "decalFunc", function()
        func()
    end)

    func()
end
