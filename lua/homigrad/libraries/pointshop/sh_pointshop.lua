--
hg.PointShop = hg.PointShop or {}

local PLUGIN = hg.PointShop

PLUGIN.Items = PLUGIN.Items or {}

function PLUGIN:CreateItem( uid, strName, strModel, strBodyGroups, iSkin, vecPos, intPrice, bIsDPoints, tData, fCallback, fov )
    PLUGIN.Items[uid] = {
        ID = uid,
        NAME = strName,
        MDL = strModel or "models/dav0r/hoverball.mdl",
        BODYGROUP = strBodyGroups or "00000",
        SKIN = iSkin or 0,
        VPos = vecPos or Vector(0,0,0),
        PRICE = intPrice,
        ISDONATE = bIsDPoints or false,
        DATA = tData or {},
        CALLBACK = fCallback or nil,
        FOV = fov or 15
    }
end

--PLUGIN:CreateItem("test_item_1","TEST ITEM","models/dav0r/hoverball.mdl",Vector(0,0,0),100)
--PLUGIN:CreateItem("hat","TEST ITEM","models/dav0r/hoverball.mdl",Vector(0,0,0),100)

if SERVER then
    --Player(2):PS_AddItem( "test_item_1" )
end

if CLIENT then
    local callbacks = {}

    net.Receive("hg_pointshop_net",function()
        LocalPlayer().PS_MyItensens = net.ReadTable()
        --print(callbacks[#callbacks])
        if callbacks[#callbacks] then
            callbacks[#callbacks](LocalPlayer().PS_MyItensens)
            callbacks[#callbacks] = nil
        end
    end)

    function PLUGIN:SendNET(strFunc,tVars,callback)
        net.Start( "hg_pointshop_net" )
            net.WriteString( strFunc )
            net.WriteTable( tVars or {} )
        net.SendToServer()

        if callback then
            callbacks[#callbacks + 1] = callback
        end
    end 

    local plyMeta = FindMetaTable("Player")

    function plyMeta:PS_HasItem( uid )
        local pointshopVars = LocalPlayer().PS_MyItensens
        return pointshopVars.items[ uid ]
    end

    net.Receive("hg_pointshop_send_notificate",function()
        local txt = net.ReadString()
        sound.PlayURL("https://www.myinstants.com/media/sounds/short-notice.mp3","mono",function() Derma_Message(txt, "Result", "OK") end)
    end)
end

hook.Add("Think","ZPointshopLoaded",function()
    hook.Run("ZPointshopLoaded")
    hook.Remove("Think","ZPointshopLoaded")
end)