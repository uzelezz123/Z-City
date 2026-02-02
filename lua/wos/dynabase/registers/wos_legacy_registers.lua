//  These are a bunch of legacy functions to register addons that don't have integrated support for animation management
// This is not how  you should be doing your registers. See other addons

local function GenericRegister( data )
    wOS.DynaBase:RegisterSource({
        Name = data.Name,
        Type =  ( data.Extension and WOS_DYNABASE.EXTENSION ) or WOS_DYNABASE.REANIMATION,
        Male = ( data.Male and "models/xdreanims/m_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
        Female = ( data.Female and "models/xdreanims/f_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
        Zombie = ( data.Zombie and "models/xdreanims/z_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
    })

    hook.Add( "PreLoadAnimations", "wOS.DynaBase.Mount" .. data.Name, function( gender )
        if gender == WOS_DYNABASE.MALE and data.Male then
            IncludeModel( "models/xdreanims/m_anm_slot_" .. data.BaseSlot .. ".mdl" )
        elseif gender == WOS_DYNABASE.FEMALE and data.Female then
            IncludeModel( "models/xdreanims/f_anm_slot_" .. data.BaseSlot .. ".mdl" )
        elseif gender == WOS_DYNABASE.ZOMBIE and data.Zombie then
            IncludeModel( "models/xdreanims/z_anm_slot_" .. data.BaseSlot .. ".mdl" )  
        end
    end )
end

local tbl = {
    ['2261825706'] = {
        Name = "CSGO Reanimations",
        BaseSlot = '046',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2143589929'] = {
        Name = "Two-Hand Pistol Reanimations",
        BaseSlot = '002',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2493356270'] = {
        Name = "Ironight Reanimations",
        BaseSlot = '011',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2737372889'] = {
        Name = "COD Zombie Reanimations",
        BaseSlot = '035',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2432553338'] = {
        Name = "Combine Passive Reanimations",
        BaseSlot = '018',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2424958167'] = {
        Name = "Drip Idle Reanimations",
        BaseSlot = '019',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2348399590'] = {
        Name = "Cut Fist Reanimations",
        BaseSlot = '016',
        Male = true,
        Female = true,
        Zombie = true,
    },
    ['2169293226'] = {
        Name = "Radio Chatter Reanimations",
        BaseSlot = '038',
        Male = true,
        Female = true,
        Zombie = true,
    },   
    ['2148772437'] = {
        Name = "Reduced Breath Reanimations",
        BaseSlot = '029',
        Male = true,
        Female = true,
        Zombie = true,
    },  
    ['2903472153'] = {
        Name = "Human Realm Reanimations",
        BaseSlot = '039',
        Male = true,
        Female = true,
        Zombie = true,
    },  
    ['2918092137'] = {
        Name = "COD Modern Warfare Reanimations",
        BaseSlot = '046',
        Male = true,
        Female = false,
        Zombie = false,
    }, 
    ['2791673215'] = {
        Name = "CODIW Idle Reanimations",
        BaseSlot = '030',
        Male = true,
        Female = true,
        Zombie = true,
    }, 
    ['2792431263'] = {
        Name = "CODIW Last Stand Extension",
        BaseSlot = '040',
        Extension = true,
        Male = true,
        Female = true,
        Zombie = true,
    }, 
    ['2912631064'] = {
        Name = "Feminine Sitting Reanimations",
        BaseSlot = '015',
        Male = false,
        Female = true,
        Zombie = false,
    },  
    ['2742793067'] = {
        Name = "TF2 Laughing Reanimations",
        BaseSlot = '031',
        Male = true,
        Female = true,
        Zombie = false,
    },  
    ['2891284985'] = {
        Name = "SadCat Dance Reanimations",
        BaseSlot = '027',
        Male = true,
        Female = true,
        Zombie = false,
    },  
    ['2895861489'] = {
        Name = "Zero Two Dance Reanimations",
        BaseSlot = '013',
        Male = true,
        Female = true,
        Zombie = false,
    },  
    ['2892723717'] = {
        Name = "KDA Dance Reanimations",
        BaseSlot = '026',
        Male = true,
        Female = true,
        Zombie = false,
    },  
}

// Workshop addon  check  first because that's the most reliable
local op_table = table.Copy( tbl )
for _, addon in ipairs( engine.GetAddons() ) do
    if not addon.mounted then continue  end
    if addon.wsid == "2247494212" then //have to hardcode this cause Yongli needs to do an update..
        wOS.DynaBase:RegisterSource({
            Name = "Sword Art Extension",
            Type =  WOS_DYNABASE.EXTENSION,
            Shared = "models/player/wiltos/anim_extension_mod18.mdl",
        })

        hook.Add( "PreLoadAnimations", "wOS.DynaBase.MountSwordArt", function( gender )
            if gender != WOS_DYNABASE.SHARED then return end
            IncludeModel( "models/player/wiltos/anim_extension_mod18.mdl" )
        end )
    end
    if not op_table[addon.wsid] then continue end
    GenericRegister( op_table[addon.wsid] )
    op_table[addon.wsid] = nil
end

// Now for the longer version we have to do for servers.
for _, data in pairs( op_table ) do
    local base_path = "models/xdreanims/f_anm_slot_" .. data.BaseSlot .. ".mdl" //They happen to all have female so we'll use that
    if !file.Exists(base_path, "GAME") then continue end
    GenericRegister( data )
end

if CLIENT then
    hook.Add( "wOS.DynaBase.PopulateHelperFunctions", "wOS.DynaBase.LEgacyAddHelper", function( parent ) 
        local download_butt = vgui.Create( "DButton", parent )
        download_butt:SetSize( parent:GetWide(), parent:GetTall()*0.0625 )
        download_butt:Dock( TOP )
        download_butt:SetText( "Create User Mounts from Legacy Addon (Will overwrite mounts with the same name!)" )
        download_butt.DoClick = function(pan) 
            for wsid, data in pairs( tbl ) do
                local ndata = {
                    Name = data.Name,
                    Male = ( data.Male and "models/xdreanims/m_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
                    Female = ( data.Female and "models/xdreanims/f_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
                    Zombie = ( data.Zombie and "models/xdreanims/z_anm_slot_" .. data.BaseSlot .. ".mdl" ) or nil,
                }
                wOS.DynaBase:CreateUserMount( ndata )
            end
            chat.AddText( color_white, "[", Color( 0, 175, 255 ), "wOS-DynaBase", color_white, "] All legacy mounts regardless of subscription status have been added!" )
            parent:ReloadAddons()
        end
    end )
end