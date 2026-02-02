
if not util.IsBinaryModuleInstalled("mysqloo") then return end

hg.EarlyAccess = hg.EarlyAccess or {}
local PLUGIN = hg.EarlyAccess
PLUGIN.PlayerInstances = PLUGIN.PlayerInstances or {}

hook.Add("DatabaseConnected", "EarlyAccessCreateData", function()
	local query

	query = mysql:Create("hg_betatesters")
		query:Create("steamid", "VARCHAR(20) NOT NULL")
		query:Create("steam_name", "VARCHAR(32) NOT NULL")
		query:PrimaryKey("steamid")
	query:Execute()

    PLUGIN.Active = true
end)
local VerficationTable = {}
local STEAMIDs = {}

if file.Exists("zcity/verification.json","DATA") then 
    VerficationTable = util.JSONToTable(file.Read("zcity/verification.json","DATA"))
    STEAMIDs={}
    timer.Simple(0,function()
        for Z,T in pairs(VerficationTable) do 
            STEAMIDs[T]=true 
        end
    end)
end

hook.Add("PlayerInitialSpawn","AddInWL",function(ply)
    if STEAMIDs[ply:SteamID64()] then
        local name = ply:Name()
	    local steamID64 = ply:SteamID64()

        if not PLUGIN.Active then
            PLUGIN.PlayerInstances[steamID64] = {}
            return
        end 

	    local query = mysql:Select("hg_betatesters")
	    	query:Where("steamid", steamID64)
	    	query:Callback(function(result)
	    		if (IsValid(ply) and istable(result) and #result > 0) then
	    			local updateQuery = mysql:Update("hg_betatesters")
	    				updateQuery:Update("steam_name", name)
	    				updateQuery:Where("steamid", steamID64)
	    			updateQuery:Execute()

	    			PLUGIN.PlayerInstances[steamID64] = true
	    		else
	    			local insertQuery = mysql:Insert("hg_betatesters")
	    				insertQuery:Insert("steamid", steamID64)
	    				insertQuery:Insert("steam_name", name)
	    			insertQuery:Execute()

	    			PLUGIN.PlayerInstances[steamID64] = true
	    		end
	    	end)
	    query:Execute()
    end
end)

local plyMeta = FindMetaTable("Player")

function plyMeta:EA_HasAccess()
    local steamid = self:SteamID64()
    return PLUGIN.PlayerInstances[steamid] or false
end