--if not util.IsBinaryModuleInstalled("mysqloo") then return end

hg.db = hg.db or {}

function hg.db.Connect()
    local standart_tbl = {
            dbmodule = "sqlite",
            hostname = "your_MySQLServerAddres",
            username = "your_username",
            password = "your_password",
            database = "your_db",
            port = 3306
        }

    if not file.Exists("zbattle/sql.json","DATA") then file.Write("zbattle/sql.json", util.TableToJSON(standart_tbl,true)) end
    local cfg = file.Exists("zbattle/sql.json","DATA") and 
        util.JSONToTable(file.Read("zbattle/sql.json","DATA")) or 
        standart_tbl

    local dbmodule = cfg.dbmodule
    local hostname = cfg.hostname
    local username = cfg.username
    local password = cfg.password
    local database = cfg.database
    local port = cfg.port

    mysql:SetModule(dbmodule)
    mysql:Connect(hostname, username, password, database, port)
end

hook.Add("InitPostEntity", "zbDatabaseConnect", function()
	hg.db.Connect()
end)

--zb.db.Connect()

hook.Add("DatabaseConnected", "DB_Think", function()
    --print("asd")
	timer.Create("zbDatabaseThink", 0.5, 0, function()
		mysql:Think()
	end)
end)