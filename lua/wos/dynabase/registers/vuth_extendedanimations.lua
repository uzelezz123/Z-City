wOS.DynaBase:RegisterSource({
	Name = "ZCity | Vuthakral's Extended Player Animations",
	Type =  WOS_DYNABASE.EXTENSION,
	Male = "models/xdreanims/m_anm_slot_042.mdl",
	Female = "models/xdreanims/f_anm_slot_042.mdl",
	Zombie = "models/xdreanims/m_anm_slot_042.mdl",
})

hook.Add( "PreLoadAnimations", "DynaBaseRegisterVuthExtensions", function( gender )
	if gender == WOS_DYNABASE.MALE then
		IncludeModel( "models/xdreanims/m_anm_slot_042.mdl" )
	elseif gender == WOS_DYNABASE.FEMALE then
		IncludeModel( "models/xdreanims/f_anm_slot_042.mdl" )
	elseif gender == WOS_DYNABASE.ZOMBIE then
		IncludeModel( "models/xdreanims/m_anm_slot_042.mdl" )
	end
end )

hook.Add( "InitLoadAnimations", "DynaBaseLoadVuthExtensions", function()
	wOS.DynaBase:RegisterSource({
		Name = "ZCity | Vuthakral's Extended Player Animations",
		Type =  WOS_DYNABASE.EXTENSION,
		Male = "models/xdreanims/m_anm_slot_042.mdl",
		Female = "models/xdreanims/f_anm_slot_042.mdl",
		Zombie = "models/xdreanims/m_anm_slot_042.mdl",
	})
end )