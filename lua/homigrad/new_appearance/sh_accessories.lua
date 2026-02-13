--
hg = hg or {}

local bandanamat = Material("mats_jack_gmod_sprites/respirator_vignette.png")

hg.Accessories = {
	["none"] = {},

    ["eyeglasses"] = {
        model = "models/captainbigbutt/skeyler/accessories/glasses01.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = { Vector(3,-2.9,0), Angle(0,-70,-90), .9},
        fempos = {Vector(2.1,-2.7,0),Angle(0,-70,-90),.8},
        skin = 0,
        norender = true,
        placement = "face",
        name = "Glasses"
    },

    ["bugeye sunglasses"] = {
        model = "models/captainbigbutt/skeyler/accessories/glasses04.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.2,-3.3,0),Angle(0,-70,-90),.9},
        fempos = {Vector(2.2,-3.3,0),Angle(0,-70,-90),.8},
        skin = 0,
        norender = true,
        placement = "face",
        name = "Bugeye Sunglasses"
    },

    ["aviators"] = {
        model = "models/arctic_nvgs/aviators.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.7,0,0),Angle(0,-80,-90),1},
        fempos = {Vector(0.25,0,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "face",
        bPointShop = true,
        price = 5000,
        vpos = Vector(0,0,0),
        name = "Aviators"
    },

    ["nerd glasses"] = {
        model = "models/gmod_tower/klienerglasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-2.2,0),Angle(0,-80,-90),1},
        fempos = {Vector(2.5,-2.5,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "face",
        bPointShop = true,
        price = 1000,
        name = "Nerd Glasses"
    },

    ["headphones"] = {
        model = "models/gmod_tower/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.6,-1,0),Angle(0,-80,-90),.85},
        fempos = {Vector(2.4,-1,0),Angle(0,-85,-90),.8},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Headphones"
    },

    ["baseball cap"] = {
        model = "models/gmod_tower/jaseballcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0,0),Angle(0,-75,-90), 1.12},
        fempos = {Vector(4,-0.1,0),Angle(0,-75,-90), 1.125},
        skin = 0,
        norender = true,
        placement = "head",
        name = "Baseball Cap"
    },

    ["fedora"] = {
        model = "models/captainbigbutt/skeyler/hats/fedora.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.5,-0.2,0),Angle(0,-80,-90), 0.7},
        fempos = {Vector(4.5,-0.2,0),Angle(0,-75,-90), 0.7},
        skin = 0,
        norender = true,
        placement = "head",
        name = "Fedora"
    },

    ["stetson"] = {
        model = "models/captainbigbutt/skeyler/hats/cowboyhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(6.2,0.6,0),Angle(0,-60,-90), 0.7},
        fempos = {Vector(5.2,0.5,0),Angle(0,-65,-90), 0.65},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Stetson"
    },

    ["straw hat"] = {
        model = "models/captainbigbutt/skeyler/hats/strawhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5.2,-0.4,0),Angle(0,-70,-90), 0.85},
        fempos = {Vector(4.5,-0.5,0),Angle(0,-75,-90), 0.8},
        skin = 0,
        norender = true,
        placement = "head",
        name = "Straw Hat"
    },

    ["sun hat"] = {
        model = "models/captainbigbutt/skeyler/hats/sunhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.2,2,0),Angle(0,-90,-90), 0.8},
        fempos = {Vector(3.4,2,0),Angle(0,-90,-90), 0.75},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Sun Hat"
    },

    ["bling cap"] = {
        model = "models/captainbigbutt/skeyler/hats/zhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.9,0.1,0),Angle(0,-80,-90), 0.75},
        fempos = {Vector(3.5,0.2,0),Angle(-10,-80,-90), 0.75},
        skin = 0,
        norender = true,
        placement = "head"
    },

    ["top hat"] = {
        model = "models/player/items/humans/top_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0,-1.5,0),Angle(0,-80,-90), 1},
        fempos = {Vector(-0.8,-1.8,0),Angle(0,-80,-90), 1},
        skin = 0,
        norender = true,
        placement = "head",
        name = "Top Hat (waffle)"
    },

    ["backpack"] = {
        model = "models/makka12/bag/jag.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-3,0,0),Angle(0,90,90),.75},
        fempos = {Vector(-3,-1,0),Angle(0,90,90),.6},
        skin = 0,
        norender = false,
        placement = "spine",
        name = "Backpack"
    },

    ["backpack hellokitty"] = {
        model = "models/gleb/backpack_pink.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine",
        bPointShop = true,
        price = 4000,
        vpos = Vector(0,0,0),
        name = "HelloKitty Backpack"
    },

    ["kickme sticker"] = {
        model = "models/gleb/kickme.mdl",
        bone = "ValveBiped.Bip01_Pelvis",
        malepos = {Vector(0,4,-6.8),Angle(-75,-90,0),1},
        fempos = {Vector(0,4,-5.8),Angle(-65,-90,0),1},
        skin = 0,
        norender = false,
        placement = "spine",
        bonemerge = true,
        bPointShop = true,
        price = 2500,
        name = "KickMe Sticker"
    },

    ["nerd tooths"] = {
        model = "models/gleb/nerd.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.3,-0.4,0),Angle(0,-85,-90),1},
        fempos = {Vector(1.9,-0.8,0),Angle(0,-85,-90),.95},
        skin = 0,
        norender = true,
        placement = "spine",
        bonemerge = true,
        bPointShop = true,
        price = 2500,
        name = "Nerd Teeth"
    },

    ["purse"] = {
        model = "models/props_c17/BriefCase001a.mdl",
        bone = "ValveBiped.Bip01_Spine1",
        malepos = {Vector(-7,1,7),Angle(0,90,100),.5},
        fempos = {Vector(-7,0,7),Angle(0,90,100),.5},
        skin = 0,
        norender = false,
        placement = "spine",
        name = "Purse"
    },
    --CAPS
    ["zcity cap"] = {
        model = "models/gleb/zcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1500,
        name = "ZCITY Baseball Cap"
    },

    ["gray cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        name = "Grey Baseball Cap"
    },

    ["light gray cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
        name = "Light Gray Baseball Cap"
    },

    ["white cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 3,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "White Baseball Cap"
    },

    ["green cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.5,0.1),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 4,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Green Baseball Cap"
    },

    ["dark green cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 5,
        norender = true,
        placement = "head",
        name = "Dark Green Baseball Cap"
    },

    ["brown cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 6,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Brown Baseball Cap"
    },

    ["blue cap"] = {
        model = "models/modified/hat07.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(5,0.4,0),Angle(180,105,90),1},
        fempos = {Vector(3.5,0.2,0),Angle(180,105,90),1},
        skin = 7,
        norender = true,
        placement = "head",
        name = "Blue Baseball Cap"
    },
    -- FaceMasks
    ["bandana"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        bSetColor = true,
        vecColorOveride = Vector(0.2,0.2,0.2),
        norender = true,
        placement = "face",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 1000,
        name = "Bandana"
    },

    ["bandana colorable"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        bSetColor = true,
        norender = true,
        placement = "face",
        ScreenSpaceEffects = function()
            -- DrawColorModify(AviatorColor)
            surface.SetMaterial(bandanamat)
            surface.SetDrawColor(255,255,255)
            surface.DrawTexturedRect(-1,0,ScrW()*1.01,ScrH()*1.2)
         end,
        bPointShop = true,
        vpos = Vector(0,0,63),
        price = 4500,
        name = "Bandana colorable"
    },

	-- cs stuff
    ["arctic_balaclava"] = {
        model = "models/d/balaklava/arctic_reference.mdl",
        femmodel = "models/distac/feminine_mask.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1.1},
        fempos = {Vector(-1,-0.8,0),Angle(180,105,90),1.05},
        skin = 0,
        norender = true,
        disallowinappearance = true,
        bonemerge = true,
        name = "Arctic Balaclava"
    },

    ["phoenix_balaclava"] = {
        model = "models/d/balaklava/phoenix_balaclava.mdl",
        femmodel = "models/distac/feminine_mask.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,-0.95,0),Angle(180,100,90),0.95},
        fempos = {Vector(-0.6,-0.6,0),Angle(180,100,90),0.95},
        skin = 0,
        norender = true,
        disallowinappearance = true,
        bonemerge = true,
        name = "Phoenix Balaclava"
    },
   	--[[
	["hood_balaclava"] = {
        model = "models/balaclava_hood/balaclava_hood.mdl",
        femmodel = "models/distac/feminine_mask.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-27,-5,0),Angle(180,100,90),1},
		fempos = {Vector(-0.6,-0.6,0),Angle(180,100,90),0.95},
        skin = 0,
        norender = true,
		placement = "head",
		vpos = Vector(-45,-45,0),
        name = "Hood Balaclava"
    },
	]]
    ["terrorist_band"] = {
        model = "models/distac/band_team.mdl",
        femmodel = "models/distac/band_team_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,-0.95,0),Angle(180,100,90),0.95},
        fempos = {Vector(-0.6,-0.6,0),Angle(180,100,90),0.95},
        skin = 0,
        disallowinappearance = true,
        bonemerge = true,
        needcoolRender = true,
        flex = true,
        name = "Terrorist Armband"
    },

    -- scarfs
    ["white scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 0,
        norender = false,
        vpos = Vector(0,0,20),
        placement = "torso",
        name = "White Scarf"
    },

    ["gray scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 1,
        norender = false,
        vpos = Vector(0,0,20),
        placement = "torso",
        name = "Gray Scarf"
    },

    ["black scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 2,
        norender = false,
        placement = "torso",
        bPointShop = true,
        vpos = Vector(0,0,20),
        price = 1000,
        name = "Black Scarf"
    },

    ["blue scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 3,
        norender = false,
        placement = "torso",
        bPointShop = true,
        vpos = Vector(0,0,20),
        price = 1000,
        name = "Blue Scarf"
    },

    ["red scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 4,
        norender = false,
        placement = "torso",
        bPointShop = true,
        vpos = Vector(0,0,20),
        price = 1000,
        name = "Red Scarf"
    },

    ["green scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 5,
        norender = false,
        placement = "torso",
        bPointShop = true,
        vpos = Vector(0,0,20),
        price = 1000,
        name = "Green Scarf"
    },

    ["pink scarf"] = {
        model = "models/sal/acc/fix/scarf01.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-18,8,0),Angle(0,75,90),1},
        fempos = {Vector(-18,5.5,0),Angle(0,80,90),.9},
        skin = 6,
        norender = false,
        placement = "torso",
        bPointShop = true,
        vpos = Vector(0,0,20),
        price = 1000,
        name = "Pink Scarf"
    },
    -- earmuffs
    ["red earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 0,
        norender = true,
        placement = "ears",
        bPointShop = true,
        price = 1000,
        name = "Red Earmuffs"
    },

    ["pink earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 1,
        norender = true,
        bPointShop = true,
        price = 1000,
        name = "Pink Earmuffs"
    },

    ["green earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 2,
        norender = true,
        placement = "ears",
        bPointShop = true,
        price = 1000,
        name = "Green Earmuffs"
    },

    ["yellow earmuffs"] = {
        model = "models/modified/headphones.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2.8,-1,0),Angle(180,105,90),1},
        fempos = {Vector(1.8,-1,0),Angle(180,105,90),0.95},
        skin = 3,
        norender = true,
        placement = "ears",
        bPointShop = true,
        price = 1000,
        name = "Yellow Earmuffs"
    },
    -- fedoras

    ["gray fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Gray Fedora"
    },

    ["black fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Black Fedora"
    },

    ["white fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "White Fedora"
    },

    ["beige fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 3,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Beige Fedora"
    },

    ["black/red fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 5,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Black-n-Red Fedora"
    },

    ["blue fedora"] = {
        model = "models/modified/hat01_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        fempos = {Vector(3,0.2,0),Angle(180,105,90),1},
        skin = 7,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Blue Fedora"
    },
    -- beanies
    ["striped beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Striped Beanie"
    },
    ["periwinkle beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 1,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Periwinkle Beanie"
    },

    ["fuschia beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,105,90),1},
        skin = 2,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Fuschia Beanie"
    },

    ["white beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,100,90),1},
        skin = 3,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "White Beanie"
    },

    ["gray beanie"] = {
        model = "models/modified/hat03.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4,0,0),Angle(180,105,90),1},
        fempos = {Vector(3.8,0.2,0),Angle(180,100,90),1},
        skin = 4,
        norender = true,
        placement = "head",
        bPointShop = true,
        price = 1000,
        name = "Gray Beanie"
    },
    -- backpacks
    ["large red backpack"] = {
        model = "models/modified/backpack_1.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5.2,0),Angle(0,80,90),1},
        fempos = {Vector(-8,4,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine",
        bPointShop = true,
        price = 1000,
        name = "Large Red Backpack"
    },

    ["large gray backpack"] = {
        model = "models/modified/backpack_1.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,5.2,0),Angle(0,80,90),1},
        fempos = {Vector(-8,4,0),Angle(0,80,90),0.9},
        skin = 1,
        norender = false,
        placement = "spine",
        bPointShop = true,
        price = 1000,
        name = "Large Gray Backpack"
    },

    ["medium backpack"] = {
        model = "models/modified/backpack_3.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,4,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 0,
        norender = false,
        placement = "spine",
        bPointShop = true,
        price = 1000,
        name = "Medium Backpack"
    },

    ["medium gray backpack"] = {
        model = "models/modified/backpack_3.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(-7.5,4,0),Angle(0,80,90),1},
        fempos = {Vector(-8,3,0),Angle(0,80,90),0.9},
        skin = 1,
        norender = false,
        placement = "spine",
        bPointShop = true,
        price = 1000,
        name = "Medium Gray Backpack"
    },

    ["monokl"] = {
        model = "models/distac/monokl.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.05,-4.8,-1.3),Angle(180,100,90),1},
        fempos = {Vector(-1,-0.8,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        bPointShop = true,
        price = 2000,
        vpos = Vector(0,0,69),
        name = "Monocle"
    },

    ["china hat"] = {
        model = "models/distac/china_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(4.5,-0.35,0),Angle(180,100,90),1},
        fempos = {Vector(3,-0.8,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        bPointShop = true,
        isdpoint = false,
        price = 2500,
        vpos = Vector(0,0,0),
        name = "China Hat"
    },

    ["helicopter cap"] = {
        model = "models/distac/cap_helecopterkid.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-70,-13.5,0),Angle(180,100,90),1.1},
        fempos = {Vector(-63,-18.5,0),Angle(180,105,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        bPointShop = true,
        isdpoint = false,
        price = 2500,
        vpos = Vector(0,0,69),
        name = "Helicopter Baseball Cap"
    },

    ["welding glasses"] = {
        model = "models/distac/glassis_welding glasses.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        bPointShop = true,
        isdpoint = false,
        price = 2500,
        vpos = Vector(0,0,69),
        name = "Welding Glasses"
    },

    ["big glasses"] = {
        model = "models/distac/big_ahhh_glassis.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        bPointShop = true,
        isdpoint = false,
        price = 2000,
        vpos = Vector(0,0,69),
        name = "Big Glasses"
    },

    ["glasses with nose"] = {
        model = "models/distac/glasses_with_mustache.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        bPointShop = true,
        price = 2500,
        vpos = Vector(0,0,69),
        name = "ОЧКИ С УСАМИ МЕМ"
    },

    ["glasses fmf"] = {
        model = "models/distac/street_kid_fmf.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        flex = true,
        bPointShop = true,
        price = 3000,
        vpos = Vector(0,0,69),
        name = "FMF Glasses"
    },

    ["warmcap"] = {
        model = "models/distac/warmcap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,-0.95,0),Angle(180,100,90),1},
        fempos = {Vector(0,0,0),Angle(0,0,0),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        flex = true,
        bPointShop = true,
        price = 2600,
        vpos = Vector(0,0,69),
        name = "Warmcap"
    },
    -- SCUGS!!!
    ["slugcat"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "0",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Survivor"
    },
    ["slugcat monk"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.6,5,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "1",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Monk"
    },
    ["slugcat gourmand"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "2",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Gourmand"
    },
    ["slugcat arti"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "3",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Artificer"
    },
    ["slugcat rivulet"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "4",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat WetMouse"
    },
    ["slugcat speermaster"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "5",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Spearmaster"
    },
    ["slugcat saint"] = {
        model = "models/salat_port/slugcat_figure.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "spine",
        bodygroups = "6",
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,0),
        name = "Slugcat Saint"
    },
    ["pinklizard"] = {
        model = "models/zcity/lizard.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(2,1,-6),Angle(100,0,0),1},
        fempos = {Vector(1,0,-5),Angle(70,180,180),1},
        skin = 0,
        placement = "spine",
        bPointShop = true,
        price = 1, -- for those who notices :3
        vpos = Vector(0,0,0),
        name = "Pink Lizard"
    },
    ["headband"] = {
        model = "models/distac/headband.mdl",
        femmodel = "models/distac/headband_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 3500,
        vpos = Vector(0,0,69),
        name = "Headband"
    },
    ["occluder"] = {
        model = "models/distac/occluder.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = true,
        bonemerge = true,
        placement = "face",
        bPointShop = true,
        isdpoint = false,
        price = 1200,
        vpos = Vector(0,0,69),
        name = "Occluder"
    },
    ["shapka ushanka"] = {
        model = "models/distac/shapka_ushanka.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        bPointShop = true,
        price = 2300,
        vpos = Vector(0,0,69),
        name = "Ushanka"
    },
    ["cap gop"] = {
        model = "models/distac/cap_gop.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "head",
        bPointShop = true,
        price = 2300,
        vpos = Vector(0,0,69),
        name = "Cap God"
    },
    ["glasses viktor"] = {
        model = "models/distac/viktor.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        bPointShop = true,
        isdpoint = false,
        price = 1350,
        vpos = Vector(0,0,69),
        name = "Viktor Glasses"
    },
    ["glasses folding"] = {
        model = "models/distac/folding.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        norender = true,
        bonemerge = true,
        placement = "face",
        bPointShop = true,
        price = 1350,
        vpos = Vector(0,0,69),
        name = "Folding Glasses"
    },
    ["headband kamikadze"] = {
        model = "models/distac/headband.mdl",
        femmodel = "models/distac/headband_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        placement = "head",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        isdpoint = false,
        price = 750,
        vpos = Vector(0,0,69),
        name = "Kamikaze Headband"
    },
    ["mfdoom mask"] = {
        model = "models/distac/mfdoom.mdl",
        femmodel = "models/distac/mfdoom.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        placement = "face",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 2500,
        vpos = Vector(0,0,69),
        name = "MF Doom Mask"
    },
    -- ["anon mask"] = {
    --     model = "models/rawjesus/wear/anon.mdl",
    --     femmodel = "models/rawjesus/wear/anon.mdl",
    --     bone = "ValveBiped.Bip01_Head1",
    --     malepos = {Vector(0,-0.8,0),Angle(180,100,90),1},
    --     fempos = {Vector(-1.2,-0.8,0),Angle(180,100,90),1},
    --     skin = 0,
    --     placement = "face",
    --     norender = true,
    --     bonemerge = true,
    --     bPointShop = true,
    --     price = 6500,
    --     vpos = Vector(0,0,0),
    --     name = "Anonymous Mask"
    -- },
    -- ["hockey mask"] = {
    --     model = "models/rawjesus/wear/jason.mdl",
    --     femmodel = "models/rawjesus/wear/jason.mdl",
    --     bone = "ValveBiped.Bip01_Head1",
    --     malepos = {Vector(0.5,-0.8,0),Angle(180,100,90),1},
    --     fempos = {Vector(-0.5,-0.8,0),Angle(180,100,90),1},
    --     skin = 0,
    --     placement = "face",
    --     norender = true,
    --     bonemerge = true,
    --     bPointShop = true,
    --     price = 7500,
    --     vpos = Vector(0,0,0),
    --     name = "Hockey Mask"
    -- },

    ["hood"] = {
        model = "models/distac/kapishon2.mdl",
        femmodel = "models/distac/kapishon2_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = function(ent) 
            local colthes = IsValid(ent) and ent.GetNWString and ent:GetNWString("Colthesmain","normal") or ""
            --print(colthes == "cold" and 0 or 1)
            return colthes == "cold" and 0 or 1
        end,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
        bPointShop = true,
        price = 850,
        vpos = Vector(0,0,69),
        name = "Hood"
    },

    ["christmas hat"] = {
        model = "models/grinchfox/head_wear/christmas_hat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.5,0),Angle(180,90,90),1},
        fempos = {Vector(0.2,0,0),Angle(180,90,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
        name = "Christmas Hat"
    },
    ["cap deeper"] = {
        model = "models/grinchfox/head_wear/caphat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 7,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 850,
        vpos = Vector(0,0,5),
        name = "Deeper Cap"
    },

    ["cap nurse"] = {
        model = "models/grinchfox/head_wear/caphat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 9,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 750,
        vpos = Vector(0,0,5),
        name = "Nurse Cap"
    },

	["cap payot"] = {
        model = "models/grinchfox/head_wear/jewhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 4000,
        vpos = Vector(0,0,5),
        name = "Payot Cap"
    },

	["burger king crown"] = {
        model = "models/roblox_assets/burger_king_crown.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(7.8,-0.1,0),Angle(-90,-80,-90),0.7},
        fempos = {Vector(7.8,-0.1,0),Angle(-90,-80,-90),0.7},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 99999999, -- не должно быть видно в поинтшопе типо нельзя купить (пасхалка)
        vpos = Vector(0,0,5),
        name = "Burger King Crown"
    },

    ["deal glasses"] = {
        model = "models/grinchfox/head_wear/dealglasses_fix.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.5,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.5,0),Angle(0,-90,-90),1.1},
        skin = 0,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 7331,
        vpos = Vector(0,0,5),
        name = "DealGlasses™"
    },

    ["cool glasses"] = {
        model = "models/grinchfox/head_wear/fancyglasses2.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 0,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 4000,
        vpos = Vector(0,0,5),
        name = "Fancy Glasses"
    },

    ["retro glasses"] = {
        model = "models/grinchfox/head_wear/fancyglasses3.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.6,0.2,0),Angle(0,-90,-90),1.1},
        fempos = {Vector(-0.5,.2,0),Angle(0,-90,-90),1.1},
        skin = 0,
        placement = "face",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 2500,
        vpos = Vector(0,0,5),
        name = "Retro Glasses"
    },

    ["tophat white"] = {
        model = "models/grinchfox/head_wear/tophat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(2,0.4,0),Angle(0,-95,-90),1},
        fempos = {Vector(1,0.1,0),Angle(0,-95,-90),1},
        skin = 1,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 1700,
        vpos = Vector(0,0,5),
        name = "White Tophat"
    },

    ["bandana groove"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 3,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        isdpoint = false,
        price = 1400,
        vpos = Vector(0,0,63),
        name = "Groove Bandana"
    },

    ["bandana crips"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 1,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        isdpoint = false,
        price = 1400,
        vpos = Vector(0,0,63),
        name = "Crips Bandana"
    },

    ["bandana white"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 0,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        isdpoint = false,
        price = 1100,
        vpos = Vector(0,0,63),
        name = "White Bandana"
    },

    ["bandana ghost"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 10,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        price = 2500,
        vpos = Vector(0,0,63),
        name = "Ghost Bandana"
    },

    ["bandana hm"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 11,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        price = 1100,
        vpos = Vector(0,0,63),
        name = "HM Bandana"
    },

    ["bandana evil"] = {
        model = "models/fix/grinchfox/gangwrap/gangwrap.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-63.5,-12,0),Angle(90,10,0),1},
        fempos = {Vector(-63.6,-12,0),Angle(90,10,0),1},
        skin = 5,
        placement = "face",
        norender = true,
        bonemerge = false,
        bSetColor = false,
        bPointShop = true,
        price = 1500,
        vpos = Vector(0,0,63),
        name = "Evil (evil) Bandana"
    },

    ["baseball hub"] = {
        model = "models/grinchfox/head_wear/baseballhat.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1,0.4,0),Angle(0,-95,-90),1.1},
        fempos = {Vector(0,0.1,0),Angle(0,-95,-90),1},
        skin = 6,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = false,
        bPointShop = true,
        price = 1750,
        vpos = Vector(0,0,5),
        name = "Baseball Hat"
    },

    ["leather bag"] = {
        model = "models/distac/bag.mdl",
        femmodel = "models/distac/bagf.mdl",
        bone = "ValveBiped.Bip01_Spine4",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 1,
        norender = false,
        placement = "torso",
        bonemerge = true,
        bPointShop = true,
        isdpoint = false,
        price = 1550,
        vpos = Vector(0,0,42),
        name = "Leather Bag"
    },

    ["starglassis"] = {
        model = "models/distac/starglassis.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(-64,-0.3,0),Angle(180,90,90),1},
        fempos = {Vector(-64,-0.3,0),Angle(180,90,90),1},
        skin = 0,
        placement = "face",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 2000,
        vpos = Vector(0,0,69),
        name = "Star Glassis"
    },

    ["cap brain"] = {
        model = "models/distac/cap_brain.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.5,1.5,0),Angle(180,80,90),1},
        fempos = {Vector(0.5,1.5,0),Angle(180,80,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 2000,
        vpos = Vector(0,0,0),
        name = "Brain Cap"
    },

    ["coolPro headphone"] = {
        model = "models/distac/headphone.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 2500,
        vpos = Vector(0,0,69),
        name = "Headphones coolPro"
    },

    ["medieval hood"] = {
        model = "models/distac/kapishom_m.mdl",
        femmodel = "models/distac/kapishom_f.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(0.2,4.8,0),Angle(0,90,90),1},
        fempos = {Vector(-1.2,3.5,0),Angle(0,90,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bSetColor = true,
        bPointShop = true,
        price = 950,
        vpos = Vector(0,0,69),
        name = "Medieval hood"
    },

    ["cap cool"] = {
        model = "models/distac/cap_brain.mdl",
        bone = "ValveBiped.Bip01_Head1",
        malepos = {Vector(1.5,1.5,0),Angle(180,80,90),1},
        fempos = {Vector(0.5,1.5,0),Angle(180,80,90),1},
        skin = 0,
        placement = "head",
        norender = true,
        bonemerge = true,
        bPointShop = true,
        price = 2000,
        vpos = Vector(0,0,0),
        SubMat = "distac/41/cap_fire",
        name = "Cool Cap"
    },
}

hook.Add("Think","RemoveME",function()
    hg.PointShop = hg.PointShop or {}

    local PLUGIN = hg.PointShop

    PLUGIN.Items = {}

    for k, acces in pairs(hg.Accessories) do
        if not acces.bPointShop then continue end

        PLUGIN:CreateItem( k, string.NiceName( acces.name or k ), acces.model, acces.bodygroups, acces.skin, acces.vpos or Vector(0,0,0), acces.price, acces.isdpoint, {[0] = acces.SubMat} )
    end

    hook.Remove( "Think", "RemoveME" )
end)

