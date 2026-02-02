-- Стартер, ну чтобы в сандбоксе мы не страдали.
ZBox = ZBox or {}
ZBox.Plugins = ZBox.Plugins or {}

function ZBox.StartAll()
    for k,plugin in pairs(ZBox.Plugins) do
        for name, hok in pairs(plugin.Hooks) do
            --print(name,plugin.Name .. "_" .. name)
            hook.Add(name,plugin.Name .. "_" .. name, hok )
        end
    end
    timer.Simple(1,function()
        hook.Run("ZBox_Start")
    end)
end
ZBox.Maps = {
    ["rp_truenorth_v1a"] = true,
}
-- hook.Add("InitPostEntity","InitZBOX",function()
    -- if engine.ActiveGamemode() == "sandbox" and ZBox.Maps[game.GetMap()] then
        -- ZBox.StartAll()
    -- end
-- end)


function ZBox.DisableAll()
    for k,plugin in pairs(ZBox.Plugins) do
        for name, hok in pairs(plugin.Hooks) do
            hook.Remove(name,plugin.Name .. "_" .. name )
        end
    end
    timer.Simple(1,function()
        hook.Run("ZBox_Disable")
    end)
end
