--[[

    Короче говоря это тест кода от дипсика, ввиду того что я не особо хорош в кодинге и аспектах луа в гаррисе, я решил подтянуть его для этой задачи
    и сделать файл максимально совместимым со всеми возможными аддонами на зсити
    буду тестить и решать возникающие проблемы на ходу. всем кто читает большой привет, поразбираетесь со мной.

]]

-- Дополнение для ZCity Appearance

-- Убеждаемся, что глобальные таблицы существуют (на случай, если файл загрузится до оригинала)
hg.Appearance = hg.Appearance or {}
hg.PointShop = hg.PointShop or {}
-- НЕ переопределяем PLUGIN.Items

hg.Appearance.MenuPerf = hg.Appearance.MenuPerf or {
    showcaseCols = 15,
    allFacemapsCols = 15,
    allFacemapsHeaderGapFactor = 0.43,
    clothesCols = 4,
    facemapCols = 3
}

-- === ВАЖНО: Инициализация таблицы для хранения слотов лица ===
hg.Appearance.ModelFaceSlots = hg.Appearance.ModelFaceSlots or {}
-- ============================================================


-- Добавление новых моделей
local function AddCustomModels()
    -- Убеждаемся, что таблицы существуют
    hg.Appearance.PlayerModels = hg.Appearance.PlayerModels or { [1] = {}, [2] = {} }
    local PlayerModels = hg.Appearance.PlayerModels

    -- Вспомогательная функция (можно взять из оригинала или объявить свою)
    local function AppAddModel(strName, strMdl, bFemale, tSubmaterialSlots)
        PlayerModels[bFemale and 2 or 1][strName] = {
            mdl = strMdl,
            submatSlots = tSubmaterialSlots,
            sex = bFemale
        }
    end

    -- НОВЫЕ МУЖСКИЕ МОДЕЛИ
    AppAddModel( "Male 10", "models/zcity/m/male_10.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })


    AppAddModel( "Male Cohrt", "models/zcity/m/cohrt.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Cheaple", "models/zcity/m/cheaple.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Eli", "models/zcity/m/eli.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Barney", "models/zcity/m/barney.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Bill", "models/zcity/m/bill.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Travis", "models/zcity/m/travis.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male JohnWick", "models/zcity/m/johnwick.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Male Leet", "models/zcity/m/leet.mdl", false, {
	    main = "models/humans/male/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    -- НОВЫЕ ЖЕНСКИЕ МОДЕЛИ
    AppAddModel( "Female Mossman", "models/zcity/f/mossman.mdl", true, {
	    main = "models/humans/female/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Female Zoey", "models/zcity/f/zoey.mdl", true, {
	    main = "models/humans/female/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel( "Female BlackMesa", "models/zcity/f/scientist_female.mdl", true, {
	    main = "models/humans/female/group01/players_sheet", 
	    pants = "distac/gloves/pants", 
	    boots = "distac/gloves/cross", 
	    hands = "distac/gloves/hands"
    })

    AppAddModel("Female Rochelle", "models/zcity/f/rochelle.mdl", true, {
	    main = "models/humans/female/group01/players_sheet",
	    pants = "distac/gloves/pants",
	    boots = "distac/gloves/cross",
	    hands = "distac/gloves/hands"
    })

    -- Обновляем вспомогательную таблицу FuckYouModels (если она используется)
    hg.Appearance.FuckYouModels = hg.Appearance.FuckYouModels or { {}, {} }
    for name, tbl in pairs(PlayerModels[1]) do
        hg.Appearance.FuckYouModels[1][tbl.mdl] = tbl
    end
    for name, tbl in pairs(PlayerModels[2]) do
        hg.Appearance.FuckYouModels[2][tbl.mdl] = tbl
    end
end

-- Добавление новой одежды
local function AddCustomClothes()
    hg.Appearance.Clothes = hg.Appearance.Clothes or { [1] = {}, [2] = {} }
    hg.Appearance.ClothesDesc = hg.Appearance.ClothesDesc or {}

    -- Новая мужская одежда
    local maleClothes = {
        femboy = "models/humans/modern/male/sheet_29",
        yellowjacket = "models/humans/modern/male/sheet_01",
        obh = "models/humans/modern/male/sheet_02",
        --plaidblue = "models/humans/modern/male/sheet_03",
        bebra = "models/humans/modern/male/sheet_04",
        bloody = "models/humans/modern/male/sheet_05",
        coolskeleton = "models/humans/modern/male/sheet_08",
        --igotwood = "models/humans/modern/male/sheet_09",
        ftptop = "models/humans/modern/male/sheet_10",
        --orangetop = "models/humans/modern/male/sheet_11",
        brownjacket = "models/humans/modern/male/sheet_12",
        doralover = "models/humans/modern/male/sheet_13",
        gosling = "models/humans/modern/male/sheet_14",
        dawnofthedead = "models/humans/modern/male/sheet_16",
        corkers = "models/humans/modern/male/sheet_17",
        blackjacket = "models/humans/modern/male/sheet_18",
        adidas = "models/humans/modern/male/sheet_19",
        fur = "models/humans/modern/male/sheet_20",
        leatherjacket = "models/humans/modern/male/sheet_21",
        micah = "models/humans/modern/male/sheet_22",
        whitejacket = "models/humans/modern/male/sheet_23",
        furblack = "models/humans/modern/male/sheet_24",
        greenjacket = "models/humans/modern/male/sheet_25",
        nike = "models/humans/modern/male/sheet_26",
        jeansjacket = "models/humans/modern/male/sheet_27",
        puffer = "models/humans/modern/male/sheet_28",
        stripedjacket = "models/humans/modern/male/sheet_30",
        blackhoodie1 = "models/humans/modern/male/sheet_31",
        adidassheet = "models/humans/slav/adidas_sheet",
	    stoneisland = "models/humans/slav/sheet_si",

	    shirtmale = "models/humans/slav/shirtmale",
		sportsm = "models/humans/slav/sports_sheet",

		autumn01m = "models/humans/slav/octo/autumn01_sheet",
		autumn02m = "models/humans/slav/octo/autumn02_sheet",
		autumn03m = "models/humans/slav/octo/autumn03_sheet",
		autumn04m = "models/humans/slav/octo/autumn04_sheet",
		autumn06m = "models/humans/slav/octo/autumn06_sheet",
		autumn08m = "models/humans/slav/octo/autumn08_sheet",
		autumn09m = "models/humans/slav/octo/autumn09_sheet",
		autumn10m = "models/humans/slav/octo/autumn10_sheet",
		autumn11m = "models/humans/slav/octo/autumn11_sheet",
		autumn12m = "models/humans/slav/octo/autumn12_sheet",

		halloween19m = "models/humans/slav/octo/halloween19_sheet",
		halloween20m = "models/humans/slav/octo/halloween20_sheet",
		halloween22m = "models/humans/slav/octo/halloween22_sheet",
		halloween24m = "models/humans/slav/octo/halloween24_sheet",
		halloween28m = "models/humans/slav/octo/halloween28_sheet",
		halloween29m = "models/humans/slav/octo/halloween29_sheet",
		halloween30m = "models/humans/slav/octo/halloween30_sheet",
		halloween31m = "models/humans/slav/octo/halloween31_sheet",
		halloween32m = "models/humans/slav/octo/halloween32_sheet",

		hobo1m = "models/humans/slav/octo/hobo1_sheet",
		hobo2m = "models/humans/slav/octo/hobo2_sheet",
		hobo3m = "models/humans/slav/octo/hobo3_sheet",
		hobo4m = "models/humans/slav/octo/hobo4_sheet",
		hobo5m = "models/humans/slav/octo/hobo5_sheet",
		hobo6m = "models/humans/slav/octo/hobo6_sheet",

		sport1m = "models/humans/slav/octo/sport1_sheet",
		sport2m = "models/humans/slav/octo/sport2_sheet",
		sport3m = "models/humans/slav/octo/sport3_sheet",
		sport4m = "models/humans/slav/octo/sport4_sheet",
		sport5m = "models/humans/slav/octo/sport5_sheet",
		sport6m = "models/humans/slav/octo/sport6_sheet",
		sport7m = "models/humans/slav/octo/sport7_sheet",
		sport8m = "models/humans/slav/octo/sport8_sheet",
		sport9m = "models/humans/slav/octo/sport9_sheet",
		sport10m = "models/humans/slav/octo/sport10_sheet",
		sport11m = "models/humans/slav/octo/sport11_sheet",
		sport12m = "models/humans/slav/octo/sport12_sheet",
		sport13m = "models/humans/slav/octo/sport13_sheet",
		sport14m = "models/humans/slav/octo/sport14_sheet",
		sport15m = "models/humans/slav/octo/sport15_sheet",

		standart1m = "models/humans/slav/octo/standart1_sheet",
		standart2m = "models/humans/slav/octo/standart2_sheet",
		standart3m = "models/humans/slav/octo/standart3_sheet",
		standart4m = "models/humans/slav/octo/standart4_sheet",
		standart5m = "models/humans/slav/octo/standart5_sheet",
		standart6m = "models/humans/slav/octo/standart6_sheet",
		standart7m = "models/humans/slav/octo/standart7_sheet",
		standart8m = "models/humans/slav/octo/standart8_sheet",
		standart9m = "models/humans/slav/octo/standart9_sheet",
		standart10m = "models/humans/slav/octo/standart10_sheet",
		standart11m = "models/humans/slav/octo/standart11_sheet",
		standart12m = "models/humans/slav/octo/standart12_sheet",
		standart13m = "models/humans/slav/octo/standart13_sheet",
		standart14m = "models/humans/slav/octo/standart14_sheet",
		standart15m = "models/humans/slav/octo/standart15_sheet",
		standart16m = "models/humans/slav/octo/standart16_sheet",
		standart17m = "models/humans/slav/octo/standart17_sheet",
		standart18m = "models/humans/slav/octo/standart18_sheet",
		standart19m = "models/humans/slav/octo/standart19_sheet",
		standart20m = "models/humans/slav/octo/standart20_sheet",
		standart21m = "models/humans/slav/octo/standart21_sheet",
		standart22m = "models/humans/slav/octo/standart22_sheet",
		standart23m = "models/humans/slav/octo/standart23_sheet",

		suit1m = "models/humans/slav/octo/suit1_sheet",
		suit2m = "models/humans/slav/octo/suit2_sheet",
		suit3m = "models/humans/slav/octo/suit3_sheet",
		suit4m = "models/humans/slav/octo/suit4_sheet",
		suit5m = "models/humans/slav/octo/suit5_sheet",
		suit6m = "models/humans/slav/octo/suit6_sheet",
		suit7m = "models/humans/slav/octo/suit7_sheet",
		suit8m = "models/humans/slav/octo/suit8_sheet",

		winter9m = "models/humans/slav/octo/winter9_sheet",
		winter17m = "models/humans/slav/octo/winter17_sheet",
		winter19m = "models/humans/slav/octo/winter19_sheet",
		winter20m = "models/humans/slav/octo/winter20_sheet",
		winter21m = "models/humans/slav/octo/winter21_sheet",
		winter22m = "models/humans/slav/octo/winter22_sheet",
		winter23m = "models/humans/slav/octo/winter23_sheet",
		winter28m = "models/humans/slav/octo/winter28_sheet",
		winter29m = "models/humans/slav/octo/winter29_sheet",
		winter32m = "models/humans/slav/octo/winter32_sheet",
		winter41m = "models/humans/slav/octo/winter41_sheet",
		winter44m = "models/humans/slav/octo/winter44_sheet",
		winter48m = "models/humans/slav/octo/winter48_sheet",

		desertm = "models/humans/slav/desert",
		gunsmith1m = "models/humans/slav/gunsmith1",
		gunsmith2m = "models/humans/slav/gunsmith2",
		multim = "models/humans/slav/multi",
		woodlandm = "models/humans/slav/woodland",

		dbgclothes_1m = "models/humans/slav/dobrogradstuff/clothes/advanced_leon",
		dbgclothes_2m = "models/humans/slav/dobrogradstuff/clothes/afganka",
		dbgclothes_3m = "models/humans/slav/dobrogradstuff/clothes/alfred_clothes_mrthepro",
		dbgclothes_4m = "models/humans/slav/dobrogradstuff/clothes/american_texture_deadkennedy",
		dbgclothes_5m = "models/humans/slav/dobrogradstuff/clothes/american_texture_zeeke",
		dbgclothes_6m = "models/humans/slav/dobrogradstuff/clothes/anotherrad",
		dbgclothes_7m = "models/humans/slav/dobrogradstuff/clothes/baker1",
		dbgclothes_8m = "models/humans/slav/dobrogradstuff/clothes/baker2",
		dbgclothes_9m = "models/humans/slav/dobrogradstuff/clothes/baker3",
		dbgclothes_10m = "models/humans/slav/dobrogradstuff/clothes/blackjacket",
		dbgclothes_11m = "models/humans/slav/dobrogradstuff/clothes/blackjacketwithgoldbuckle",
		dbgclothes_12m = "models/humans/slav/dobrogradstuff/clothes/bobr_2",
		dbgclothes_13m = "models/humans/slav/dobrogradstuff/clothes/carmine_clothes_belch",
		dbgclothes_14m = "models/humans/slav/dobrogradstuff/clothes/casu",
		dbgclothes_15m = "models/humans/slav/dobrogradstuff/clothes/casual",
		dbgclothes_16m = "models/humans/slav/dobrogradstuff/clothes/chillfm",
		dbgclothes_17m = "models/humans/slav/dobrogradstuff/clothes/clotheth_rama",
		dbgclothes_18m = "models/humans/slav/dobrogradstuff/clothes/darkgreenjacket",
		dbgclothes_19m = "models/humans/slav/dobrogradstuff/clothes/dp_sport_jacket",
		dbgclothes_20m = "models/humans/slav/dobrogradstuff/clothes/dpsport_1",
		dbgclothes_21m = "models/humans/slav/dobrogradstuff/clothes/dpsport_b",
		dbgclothes_22m = "models/humans/slav/dobrogradstuff/clothes/evrei",
		dbgclothes_23m = "models/humans/slav/dobrogradstuff/clothes/fedor_clothes",
		dbgclothes_24m = "models/humans/slav/dobrogradstuff/clothes/foo_clothes",
		dbgclothes_25m = "models/humans/slav/dobrogradstuff/clothes/forest",
		dbgclothes_26m = "models/humans/slav/dobrogradstuff/clothes/green_clothes_zeeke",
		dbgclothes_27m = "models/humans/slav/dobrogradstuff/clothes/hoodbiker",
		dbgclothes_28m = "models/humans/slav/dobrogradstuff/clothes/hoodsport",
		dbgclothes_29m = "models/humans/slav/dobrogradstuff/clothes/irish_adidas",
		dbgclothes_30m = "models/humans/slav/dobrogradstuff/clothes/irish_jacket",
		dbgclothes_31m = "models/humans/slav/dobrogradstuff/clothes/irish_mallan",
		dbgclothes_32m = "models/humans/slav/dobrogradstuff/clothes/irish_moran",
		dbgclothes_33m = "models/humans/slav/dobrogradstuff/clothes/irish_oreily1",
		dbgclothes_34m = "models/humans/slav/dobrogradstuff/clothes/irish_oreily2",
		dbgclothes_35m = "models/humans/slav/dobrogradstuff/clothes/jaket_polkovnik",
		dbgclothes_36m = "models/humans/slav/dobrogradstuff/clothes/jaketmaniakdjon",
		dbgclothes_37m = "models/humans/slav/dobrogradstuff/clothes/jenssuitblue",
		dbgclothes_38m = "models/humans/slav/dobrogradstuff/clothes/jenssuitgreen",
		dbgclothes_39m = "models/humans/slav/dobrogradstuff/clothes/jiletbr",
		dbgclothes_40m = "models/humans/slav/dobrogradstuff/clothes/jimmy_clothes_belch",
		dbgclothes_41m = "models/humans/slav/dobrogradstuff/clothes/kennet_sheet",
		dbgclothes_42m = "models/humans/slav/dobrogradstuff/clothes/lqdirector",
		dbgclothes_43m = "models/humans/slav/dobrogradstuff/clothes/memphis_flov_cloth",
		dbgclothes_44m = "models/humans/slav/dobrogradstuff/clothes/mikel_red_odejka",
		dbgclothes_45m = "models/humans/slav/dobrogradstuff/clothes/nikebelch",
		dbgclothes_46m = "models/humans/slav/dobrogradstuff/clothes/nirvanabelch",
		dbgclothes_47m = "models/humans/slav/dobrogradstuff/clothes/nsbomber",
		dbgclothes_48m = "models/humans/slav/dobrogradstuff/clothes/oi",
		dbgclothes_49m = "models/humans/slav/dobrogradstuff/clothes/pidjack1",
		dbgclothes_50m = "models/humans/slav/dobrogradstuff/clothes/pidjackw",
		dbgclothes_51m = "models/humans/slav/dobrogradstuff/clothes/piter_clothes_zeeke",
		dbgclothes_52m = "models/humans/slav/dobrogradstuff/clothes/rigocchisuit",
		dbgclothes_53m = "models/humans/slav/dobrogradstuff/clothes/rosc_bomber",
		dbgclothes_54m = "models/humans/slav/dobrogradstuff/clothes/rosc_redshirt",
		dbgclothes_55m = "models/humans/slav/dobrogradstuff/clothes/ser",
		dbgclothes_56m = "models/humans/slav/dobrogradstuff/clothes/sharp_bomber",
		dbgclothes_57m = "models/humans/slav/dobrogradstuff/clothes/sounds_of_the_ground_no_logo",
		dbgclothes_58m = "models/humans/slav/dobrogradstuff/clothes/stanli_clothes_belch",
		dbgclothes_59m = "models/humans/slav/dobrogradstuff/clothes/sweater151",
		dbgclothes_60m = "models/humans/slav/dobrogradstuff/clothes/vincenzosuit",
		dbgclothes_61m = "models/humans/slav/dobrogradstuff/clothes/whynot",
		dbgclothes_62m = "models/humans/slav/dobrogradstuff/clothes/wolker",
		dbgclothes_63m = "models/humans/slav/dobrogradstuff/clothes/xv_bluesuit_bandizam",
		dbgclothes_64m = "models/humans/slav/dobrogradstuff/clothes/xv_greensuit_bandizam",
		dbgclothes_65m = "models/humans/slav/dobrogradstuff/clothes/xv_puhovik_bandizam",
		dbgclothes_66m = "models/humans/slav/dobrogradstuff/clothes/xv_tacsheet_bandizam",
		dbgclothes_67m = "models/humans/slav/dobrogradstuff/clothes/xv_tacsuitnic_bandizam",
		dbgclothes_68m = "models/humans/slav/dobrogradstuff/clothes/xv_tolstovka_bandizam",
		dbgclothes_69m = "models/humans/slav/dobrogradstuff/clothes/zeeke",
		dbgclothes_70m = "models/humans/slav/dobrogradstuff/clothes/nrider_suit",

		trap_sheet_m2 = "models/humans/slav/trap_sheet_2",
		trap_sheet_m8 = "models/humans/slav/trap_sheet_8",
		trap_sheet_m9 = "models/humans/slav/trap_sheet_9",
		trap_sheet_m10 = "models/humans/slav/trap_sheet_10",
		trap_sheet_m11 = "models/humans/slav/trap_sheet_11",



		epstein = "models/humans/slav/epstein",
		epstein1 = "models/humans/slav/epstein1",


    }
    for id, path in pairs(maleClothes) do
        hg.Appearance.Clothes[1][id] = path
        hg.Appearance.ClothesDesc[id] = hg.Appearance.ClothesDesc[id] or { desc = "from zcity content." }
    end

    -- Новая женская одежда
    local femaleClothes = {
        shirt1fem = "models/humans/modern/female/sheet_01",
        shirt2fem = "models/humans/modern/female/sheet_02",
        shirt3fem = "models/humans/modern/female/sheet_03",
        pastelcolortopfem = "models/humans/modern/female/sheet_04",
        coloredtopfem = "models/humans/modern/female/sheet_05",
        streetwearfem = "models/humans/modern/female/sheet_06",
        policefem = "models/humans/modern/female/sheet_07",
        bluejacketfem = "models/humans/modern/female/sheet_08",
        greentopfem = "models/humans/modern/female/sheet_09",
        playeboyfem = "models/humans/modern/female/sheet_10",
        kittytopfem = "models/humans/modern/female/sheet_11",
        redtopfem = "models/humans/modern/female/sheet_12",
        purpletopfem = "models/humans/modern/female/sheet_13",
        coatfem = "models/humans/modern/female/sheet_14",
        leatherjacketfem = "models/humans/modern/female/sheet_15",
	    turtleneckfem = "models/roscoe/dogge1",
	    formalshirtfem = "models/roscoe/dogge2",
	    halloween3 = "models/humans/slav/octo/halloween3_sheet_women",
	    halloween7 = "models/humans/slav/octo/halloween7_sheet_women",
	    halloween8 = "models/humans/slav/octo/halloween8_sheet_women",
	    halloween11 = "models/humans/slav/octo/halloween11_sheet_women",
	    halloween13 = "models/humans/slav/octo/halloween13_sheet_women",
	    halloween14 = "models/humans/slav/octo/halloween14_sheet_women",
	    halloween15 = "models/humans/slav/octo/halloween15_sheet_women",
	    halloween16 = "models/humans/slav/octo/halloween16_sheet_women",
	    halloween17 = "models/humans/slav/octo/halloween17_sheet_women",
	    halloween18 = "models/humans/slav/octo/halloween18_sheet_women",
	    winter2 = "models/humans/slav/octo/winter2_sheet_woman",
	    winter4 = "models/humans/slav/octo/winter4_sheet_woman",
	    winter5 = "models/humans/slav/octo/winter5_sheet_woman",
	    winter6 = "models/humans/slav/octo/winter6_sheet_woman",
	    winter7 = "models/humans/slav/octo/winter7_sheet_woman",
	    winter8 = "models/humans/slav/octo/winter8_sheet_woman",
	    winter9 = "models/humans/slav/octo/winter9_sheet_woman",
	    winter10 = "models/humans/slav/octo/winter10_sheet_woman",
	    winter12 = "models/humans/slav/octo/winter12_sheet_woman",
	    winter13 = "models/humans/slav/octo/winter13_sheet_woman",
	    winter15 = "models/humans/slav/octo/winter15_sheet_woman",
	    winter16 = "models/humans/slav/octo/winter16_sheet_woman",
	    winter17 = "models/humans/slav/octo/winter17_sheet_woman",

		dksclothes6f = "models/humans/slav/dksclothes6",
		bluecheckshirtf = "models/humans/slav/dobrogradstuff/clothes/bluecheckshirt",

    }
    for id, path in pairs(femaleClothes) do
        hg.Appearance.Clothes[2][id] = path
        hg.Appearance.ClothesDesc[id] = hg.Appearance.ClothesDesc[id] or { desc = "from zcity content." }
    end

    -- Добавьте описания, которых нет в основном цикле (например, с ссылками)
    --hg.Appearance.ClothesDesc.adidassheet = { desc = "adidas clothes from workshop" }
    -- ... и так далее
    hg.Appearance.ClothesDesc.femboy = { desc = "from zcity content." }
    hg.Appearance.ClothesDesc.yellowjacket = { desc = "from zcity content." }
    hg.Appearance.ClothesDesc.obh = { desc = "from zcity content." }
    --plaidblue = {desc = "from zcity content."},
    hg.Appearance.ClothesDesc.bebra = { desc = "from zcity content." }
    hg.Appearance.ClothesDesc.bloody = { desc = "from zcity content." }
    hg.Appearance.ClothesDesc.coolskeleton = { desc = "from zcity content." }
    --igotwood = {desc = "from zcity content."},
    hg.Appearance.ClothesDesc.ftptop = {
		desc = "from zcity content."
	}
    --orangetop = {desc = "from zcity content."},
    hg.Appearance.ClothesDesc.brownjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.doralover = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.gosling = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.dawnofthedead = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.corkers = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.blackjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.adidas = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.fur = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.leatherjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.micah = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.whitejacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.furblack = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.greenjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.nike = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.jeansjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.puffer = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.stripedjacket = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.blackhoodie1 = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.shirt1fem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.shirt2fem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.shirt3fem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.pastelcolortopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.coloredtopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.streetwearfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.policefem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.bluejacketfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.greentopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.playeboyfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.kittytopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.redtopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.purpletopfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.coatfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.leatherjacketfem = {
		desc = "from zcity content."
	}
    hg.Appearance.ClothesDesc.adidassheet = {
		desc = "adidas clothes from workshop"
	}
	hg.Appearance.ClothesDesc.stoneisland = {
		desc = "stone island clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.turtleneckfem = {
		desc = "turtleneck clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.formalshirtfem = {
		desc = "formal shirt clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween3 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween7 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween8 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween11 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween13 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween14 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween15 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween16 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween17 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween18 = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter2 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter4 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter5 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter6 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter7 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter8 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter9 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter10 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter12 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter13 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter15 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter16 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.winter17 = {
		desc = "winter clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.shirtmale = {
		desc = "by flada"
	}

	hg.Appearance.ClothesDesc.autumn01m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn02m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn03m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn04m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn06m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn08m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn09m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn10m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn11m = {
		desc = "autumn clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.autumn12m = {
		desc = "autumn clothes from dobrograd content"
	}

	hg.Appearance.ClothesDesc.halloween19m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween20m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween22m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween24m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween28m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween29m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween30m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween31m = {
		desc = "halloween clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.halloween32m = {
		desc = "halloween clothes from dobrograd content"
	}

	hg.Appearance.ClothesDesc.hobo1m = {
		desc = "hobo clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.hobo2m = {
		desc = "hobo clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.hobo3m = {
		desc = "hobo clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.hobo4m = {
		desc = "hobo clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.hobo5m = {
		desc = "hobo clothes from dobrograd content"
	}
	hg.Appearance.ClothesDesc.hobo6m = {
		desc = "hobo clothes from dobrograd content"
	}

	-- Эти описания меня заебали, их никто не читает, а строчки кода они жрут нереально, скроллить становится трудно. Не буду больше их писать >:(


end

-- Добавление новых Facemaps
local function AddCustomFacemaps()
    hg.Appearance.FacemapsSlots = hg.Appearance.FacemapsSlots or {}
    hg.Appearance.FacemapsModels = hg.Appearance.FacemapsModels or {}

	hg.Appearance.MultiFacemaps = hg.Appearance.MultiFacemaps or {}

    --[[local function AddFacemap(matOverride, strName, matMaterial, model)
        hg.Appearance.FacemapsSlots[matOverride] = hg.Appearance.FacemapsSlots[matOverride] or {}
        hg.Appearance.FacemapsSlots[matOverride][strName] = matMaterial
        if model then
            hg.Appearance.FacemapsModels[model] = matOverride
        end
    end
	]]

	local FacemapSlotModels = {}

	    local function AddFacemap(matOverride, strName, matMaterial, model)
        hg.Appearance.FacemapsSlots[matOverride] = hg.Appearance.FacemapsSlots[matOverride] or {}
        hg.Appearance.FacemapsSlots[matOverride][strName] = matMaterial

		local targetModels = {}
        if model then
            model = string.lower(model)
			hg.Appearance.FacemapsModels[model] = matOverride


			hg.Appearance.ModelFaceSlots[model] = hg.Appearance.ModelFaceSlots[model] or {}
			hg.Appearance.ModelFaceSlots[model][matOverride] = true

			FacemapSlotModels[matOverride] = FacemapSlotModels[matOverride] or {}
			FacemapSlotModels[matOverride][model] = true
			targetModels = FacemapSlotModels[matOverride]
		elseif FacemapSlotModels[matOverride] then
				targetModels = FacemapSlotModels[matOverride]
		end

		for modelPath, _ in pairs(targetModels) do
			hg.Appearance.MultiFacemaps[modelPath] = hg.Appearance.MultiFacemaps[modelPath] or {}
			hg.Appearance.MultiFacemaps[modelPath][strName] = hg.Appearance.MultiFacemaps[modelPath][strName] or {}
			hg.Appearance.MultiFacemaps[modelPath][strName][matOverride] = matMaterial
		end


    end




	--[[ МОДИФИЦИРОВАННЫЙ ВАРИАНТ ДЛЯ РАБОТЫ С МЕНЮ КАСТОМИЗАЦИИ, ОН СЕЙЧАС ОТКЛЮЧЕН, Я ХОЧУ НАЙТИ ДРУГОЙ СПОСОБ ДОСТАВКИ НЕСКОЛЬКИХ ТЕКСТУР БЕЗ ЛОМАНИЯ ТАБЛИЦЫ
	
	hg.Appearance.FacemapsSlots = hg.Appearance.FacemapsSlots or {}
    hg.Appearance.FacemapsModels = hg.Appearance.FacemapsModels or {}

    local function AddFacemap(matOverride, strName, matMaterial, model)
		hg.Appearance.FacemapsSlots[matOverride] = hg.Appearance.FacemapsSlots[matOverride] or {}
		hg.Appearance.FacemapsSlots[matOverride][strName] = matMaterial

		if model then
			-- Добавляем слот в список для этой модели
			hg.Appearance.ModelFaceSlots[model] = hg.Appearance.ModelFaceSlots[model] or {}
			hg.Appearance.ModelFaceSlots[model][matOverride] = true
		end
	end
	]]

	AddFacemap("models/humans/male/group01/ted_facemap","Face 11 (New)","models/humans/modern/male/male_02/facemap_01")

	AddFacemap("models/humans/male/group01/joe_facemap","Face 10 (New)","models/humans/modern/male/male_03/facemap_03")
	AddFacemap("models/humans/male/group01/joe_facemap","Face 11 (New)","models/humans/modern/male/male_03/facemap_04")
	AddFacemap("models/humans/male/group01/joe_facemap","Face 12 (New)","models/humans/modern/male/male_03/facemap_06")

	AddFacemap("models/humans/male/group01/eric_facemap","Face 10 (New)","models/humans/modern/male/male_04/facemap_01")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 11 (New)","models/humans/modern/male/male_04/facemap_02")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 12 (New)","models/humans/modern/male/male_04/facemap_03")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 13 (New)","models/humans/modern/male/male_04/facemap_04")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 14 (New)","models/characters/citizen/male/facemaps/eric_facemap")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 15 (New)","models/humans/slav/dobrogradstuff/lacharro_face")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 16 (New)","models/humans/slav/dobrogradstuff/mikel_red")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 17 (New)","models/humans/slav/dobrogradstuff/serface")
	AddFacemap("models/humans/male/group01/eric_facemap","Face 18 (New)","models/humans/slav/dobrogradstuff/xv_simonrus_bandizam")

	AddFacemap("models/humans/male/group01/art_facemap","Face 10 (New)","models/humans/modern/male/male_05/facemap_05")
	AddFacemap("models/humans/male/group01/art_facemap","Face 11 (New)","models/humans/slav/art/art_facemap1")
	AddFacemap("models/humans/male/group01/art_facemap","Face 12 (New)","models/humans/slav/art/art_facemap2")
	AddFacemap("models/humans/male/group01/art_facemap","Face 13 (New)","models/humans/slav/art/art_facemap3")
	AddFacemap("models/humans/male/group01/art_facemap","Face 14 (New)","models/humans/slav/art/art_facemap4")

	AddFacemap("models/humans/male/group01/sandro_facemap","Face 11 (New)","models/humans/modern/male/male_06/facemap_02")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 12 (New)","models/humans/modern/male/male_06/facemap_03")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 13 (New)","models/humans/modern/male/male_06/facemap_04")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 14 (New)","models/humans/modern/male/male_06/facemap_05")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 15 (New)","models/characters/citizen/male/facemaps/sandro_facemap6")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 16 (New)","models/humans/slav/tanned_facemap")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 17 (New)","models/humans/slav/dobrogradstuff/american_face_zeeke")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 18 (New)","models/humans/slav/dobrogradstuff/golovastik")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 19 (New)","models/humans/slav/dobrogradstuff/golovastik_nordd1")
	--AddFacemap("models/humans/male/group01/sandro_facemap","Face 20 (New)","models/humans/slav/dobrogradstuff/gromface")
	AddFacemap("models/humans/male/group01/sandro_facemap","Face 20 (New)","models/humans/slav/dobrogradstuff/xv_shirnymark_father")

	AddFacemap("models/humans/male/group01/mike_facemap","Face 9 (New)","models/humans/modern/male/male_07/facemap_01")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 10 (New)","models/humans/slav/dobrogradstuff/american_face_old_male07")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 11 (New)","models/humans/slav/dobrogradstuff/harley_face_belch")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 12 (New)","models/humans/slav/dobrogradstuff/lybitelpivasa")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 13 (New)","models/humans/slav/dobrogradstuff/xv_erik_susig")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 14 (New)","models/humans/slav/dobrogradstuff/xv_greg_bandizam")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 15 (New)","models/humans/slav/dobrogradstuff/xv_nikitashevchuk_bandizam")
	AddFacemap("models/humans/male/group01/mike_facemap","Face 16 (New)","models/humans/slav/dobrogradstuff/facenr07")
	
	AddFacemap("models/humans/male/group01/vance_facemap","Face 10 (New)","models/humans/modern/male/male_08/facemap_02")
	AddFacemap("models/humans/male/group01/vance_facemap","Face 11 (New)","models/characters/citizen/male/facemaps/vance_facemap")
	AddFacemap("models/humans/male/group01/vance_facemap","Face 12 (New)","models/humans/slav/dobrogradstuff/american_face_deadkennedy")
	AddFacemap("models/humans/male/group01/vance_facemap","Face 13 (New)","models/humans/slav/dobrogradstuff/bobr_1")
	AddFacemap("models/humans/male/group01/vance_facemap","Face 14 (New)","models/humans/slav/dobrogradstuff/xv_nicholas_bandizam")

	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 12 (New)","models/humans/modern/male/male_09/facemap_01")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 13 (New)","models/humans/modern/male/male_09/facemap_02")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 14 (New)","models/humans/modern/male/male_09/facemap_04")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 15 (New)","models/characters/citizen/male/facemaps/erdim_facemap")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 16 (New)","models/humans/slav/dobrogradstuff/advanced_aller")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 17 (New)","models/humans/slav/dobrogradstuff/ash")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 18 (New)","models/humans/slav/dobrogradstuff/carmine_face_belch")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 19 (New)","models/humans/slav/dobrogradstuff/face_rama")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 20 (New)","models/humans/slav/dobrogradstuff/facemap_kolchak")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 21 (New)","models/humans/slav/dobrogradstuff/golova_stick")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 22 (New)","models/humans/slav/dobrogradstuff/sergey")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 23 (New)","models/humans/slav/dobrogradstuff/vepran")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 24 (New)","models/humans/slav/dobrogradstuff/nrider_face")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 25 (New)","models/humans/slav/dobrogradstuff/facenr0901")
	AddFacemap("models/humans/male/group01/erdim_cylmap","Face 26 (New)","models/humans/slav/dobrogradstuff/facenr0902")


    -- Facemaps для существующих моделей (ДОБАВЛЕНИЕ, а не замена)
    -- ВАЖНО: Убедитесь, что `male02facemap` совпадает с тем, что в оригинале.
    -- Лучше использовать точное название материала, как в оригинале.
    --AddFacemap("models/humans/male/group01/ted_facemap", "Face 11 (New)", "models/humans/modern/male/male_02/facemap_01")
    --AddFacemap("models/humans/male/group01/joe_facemap", "Face 10 (New)", "models/humans/modern/male/male_03/facemap_03")
    -- ... и так далее для всех новых лиц существующих моделей ...

    -- ИСПРАВЛЕНИЕ ВАШЕЙ ОШИБКИ С FEMALE_06/07
    -- Не комментируйте старые модели! Оставьте как есть, а поверх добавьте новые.
    -- Вместо:
    --[[
    local female05facemap = "models/humans/female/group01/naomi_facemap" -- Этой строки не было в оригинале!
    AddFacemap(female05facemap, "Default", "", "models/zcity/f/female_07.mdl")
    ]]
    -- Нужно сделать так:
    -- Сначала убедитесь, что старые фейсмапы загружены (из оригинального файла).
    -- А ЗАТЕМ добавьте новые для тех же моделей:
    AddFacemap("models/humans/female/group01/naomi_facemap", "Face 7", "models/bloo_ltcom_zel/citizens/facemaps/naomi_facemap_new", "models/zcity/f/female_06.mdl") -- female 05 (07)
    --AddFacemap("models/humans/female/group01/lakeetra_facemap", "Face 7", "models/bloo_ltcom_zel/citizens/facemaps/lakeetra_facemap_new", "models/zcity/f/female_06.mdl") -- female 06

    -- Facemaps для НОВЫХ моделей женщин
    local mossmanfacemap = "models/mossman/mossman_face"
	local mossmanhair = "models/mossman/mossman_hair"
	AddFacemap(mossmanfacemap,"Default","","models/zcity/f/mossman.mdl") -- Mossman
	AddFacemap(mossmanhair,"Default","","models/zcity/f/mossman.mdl")
	AddFacemap(mossmanfacemap,"Face 1","models/humans/slav/mossman/mossman_face")
	AddFacemap(mossmanhair,"Face 1","models/humans/slav/mossman/mossman_hair")
	AddFacemap(mossmanfacemap,"Face 2","models/humans/slav/mossman/mossman_goth_face")
	AddFacemap(mossmanhair,"Face 2","models/humans/slav/mossman/mossman_goth_hair")

	local zoeyfacemap = "models/humans/slav/zoey/zoey_head"
	local zoeyhair = "models/humans/slav/zoey/zoey_hair"
	AddFacemap(zoeyfacemap,"Default","","models/zcity/f/zoey.mdl") -- Zoey
	AddFacemap(zoeyhair,"Default","","models/zcity/f/zoey.mdl")
	AddFacemap(zoeyfacemap,"Face 1","models/humans/slav/zoey/zoey_head_freckles")
	AddFacemap(zoeyhair,"Face 1","models/humans/slav/zoey/zoey_hair")
	AddFacemap(zoeyfacemap,"Face 2","models/humans/slav/zoey/zoey_head_goth")
	AddFacemap(zoeyhair,"Face 2","models/humans/slav/zoey/zoey_hair_dark")
	AddFacemap(zoeyfacemap,"Face 3","models/humans/slav/zoey/zoey_head_light")
	AddFacemap(zoeyhair,"Face 3","models/humans/slav/zoey/zoey_hair_dark")
	AddFacemap(zoeyfacemap,"Face 4","models/humans/slav/zoey/zoey_head_makeup")
	AddFacemap(zoeyhair,"Face 4","models/humans/slav/zoey/zoey_hair")
	AddFacemap(zoeyfacemap,"Face 4","models/humans/slav/zoey/zoey_head_eyes")
	AddFacemap(zoeyhair,"Face 4","models/humans/slav/zoey/zoey_hair")

	local femalebmsfacemap = "models/humans/slav/blackmesa/base_female/base_f_d"
	local femalebmshair = "models/humans/slav/blackmesa/hair_trans_blonde"
	AddFacemap(femalebmsfacemap, "Default", "", "models/zcity/f/scientist_female.mdl") -- female black mesa
	AddFacemap(femalebmshair, "Default", "", "models/zcity/f/scientist_female.mdl")
	AddFacemap(femalebmsfacemap, "Face 1", "models/humans/slav/blackmesa/base_female/base_f_02_d")
	AddFacemap(femalebmshair, "Face 1", "models/humans/slav/blackmesa/hair_trans_grey")
	AddFacemap(femalebmsfacemap, "Face 2", "models/humans/slav/blackmesa/base_female/base_f_03_d")
	AddFacemap(femalebmshair, "Face 2", "models/humans/slav/blackmesa/hair_trans_brown")
	AddFacemap(femalebmsfacemap, "Face 3", "models/humans/slav/blackmesa/base_female/base_f_04_d")
	AddFacemap(femalebmshair, "Face 3", "models/humans/slav/blackmesa/hair_trans_blonde2")
	AddFacemap(femalebmsfacemap, "Face 4", "models/humans/slav/blackmesa/base_female/base_f_05_d")
	AddFacemap(femalebmshair, "Face 4", "models/humans/slav/blackmesa/hair_trans_black")
	AddFacemap(femalebmsfacemap, "Face 5", "models/humans/slav/blackmesa/base_female/base_f_06_d")
	AddFacemap(femalebmshair, "Face 5", "models/humans/slav/blackmesa/hair_trans")
	AddFacemap(femalebmsfacemap, "Face 6", "models/humans/slav/blackmesa/base_female/base_f_07_d")
	AddFacemap(femalebmshair, "Face 6", "models/humans/slav/blackmesa/hair_trans_black")
	AddFacemap(femalebmsfacemap, "Face Mia", "models/humans/slav/blackmesa/base_female/base_f_mia_d")
	AddFacemap(femalebmshair, "Face Mia", "models/humans/slav/blackmesa/hair_trans_black")
	AddFacemap(femalebmsfacemap, "Face Wendy", "models/humans/slav/blackmesa/base_female/base_f_wendy_d")
	AddFacemap(femalebmshair, "Face Wendy", "models/humans/slav/blackmesa/hair_trans_grey2")
	AddFacemap(femalebmsfacemap, "Face Edith", "models/humans/slav/blackmesa/base_female/base_f_edith_d")
	AddFacemap(femalebmshair, "Face Edith", "models/humans/slav/blackmesa/hair_trans_red")

	local rochellefacemap = "models/humans/slav/rochelletrs/trs_rochelle_head"
	AddFacemap(rochellefacemap, "Default", "", "models/zcity/f/rochelle.mdl") -- Rochelle
	AddFacemap(rochellefacemap, "Face 1", "models/humans/slav/rochelletrs/trs_rochelle_head_1")
	AddFacemap(rochellefacemap, "Face 2", "models/humans/slav/rochelletrs/trs_rochelle_head_2")
	AddFacemap(rochellefacemap, "Face 3", "models/humans/slav/rochelletrs/trs_rochelle_head_3")
	AddFacemap(rochellefacemap, "Face 4", "models/humans/slav/rochelletrs/trs_rochelle_head_4")
	AddFacemap(rochellefacemap, "Face 5", "models/humans/slav/rochelletrs/trs_rochelle_head_5")
    -- ... и так далее для Zoey, BlackMesa, Rochelle, Cohrt, Cheaple, и т.д.


	-- для новых моделей мужчин

	local male10facemap = "models/humans/male/group01/cub_facemap"
	AddFacemap(male10facemap,"Default","","models/zcity/m/male_10.mdl") -- male 10
	AddFacemap(male10facemap,"Face 1","models/humans/male/group02/cub_facemap")
	AddFacemap(male10facemap,"Face 2","models/humans/male/group03/cub_facemap")
	AddFacemap(male10facemap,"Face 3","models/humans/male/group03m/cub_facemap")

	local cohrtfacemap = "models/humans/slav/cohrt/cohrt"
	AddFacemap(cohrtfacemap, "Default", "","models/zcity/m/cohrt.mdl") -- Cohrt
	AddFacemap(cohrtfacemap, "Face 1", "models/humans/slav/cohrt/cohrt")

	local cheaplefacemap = "models/gregrogers/warren/gregrogers_warren_facemap"
	AddFacemap(cheaplefacemap, "Default", "","models/zcity/m/cheaple.mdl") -- Cheaple
	AddFacemap(cheaplefacemap, "Face 1", "models/gregrogers/warren/gregrogers_warren_facemap_g02")
	AddFacemap(cheaplefacemap, "Face 2", "models/gregrogers/warren/gregrogers_warren_facemap_g03")
	AddFacemap(cheaplefacemap, "Face 3", "models/gregrogers/warren/gregrogers_warren_facemap_g03m")

	local elifacemap = "models/eli/eli_tex4z"
	AddFacemap(elifacemap, "Default", "","models/zcity/m/eli.mdl") -- Eli
	AddFacemap(elifacemap, "Face 1", "models/gang_ballas_boss/gang_ballas_boss_face")
	AddFacemap(elifacemap, "Face 2", "models/humans/slav/eli/eli_headz")

	local barneyfacemap = "models/humans/slav/barney/barneyface"
	AddFacemap(barneyfacemap, "Default", "","models/zcity/m/barney.mdl") -- Barney
	AddFacemap(barneyfacemap, "Face 1", "models/humans/slav/barney/donaldface")

	local billcig = "models/humans/slav/bill/bill_head"
	local billhairs = "models/humans/slav/bill/bill_hairs"
	local billhairs2 = "models/humans/slav/bill/bill_hairs2"
	local billbeard = "models/humans/slav/bill/bill_hair"
	local billface = "models/humans/slav/bill/bill_head_nohat"
	AddFacemap(billcig, "Default", "","models/zcity/m/bill.mdl") -- Bill
	AddFacemap(billhairs, "Default", "","models/zcity/m/bill.mdl")
	AddFacemap(billhairs2, "Default", "","models/zcity/m/bill.mdl")
	AddFacemap(billbeard, "Default", "","models/zcity/m/bill.mdl")
	AddFacemap(billface, "Default", "","models/zcity/m/bill.mdl")

	AddFacemap(billcig, "No Cig", "null")
	AddFacemap(billhairs, "No Cig", "models/humans/slav/bill/bill_hairs")
	AddFacemap(billhairs2, "No Cig", "models/humans/slav/bill/bill_hairs2")
	AddFacemap(billbeard, "No Cig", "models/humans/slav/bill/bill_hair")
	AddFacemap(billface, "No Cig", "models/humans/slav/bill/bill_head_nohat")

	AddFacemap(billcig, "Young", "models/humans/slav/bill/bill_head")
	AddFacemap(billhairs, "Young", "models/humans/slav/bill/bill_hairs_young")
	AddFacemap(billhairs2, "Young", "models/humans/slav/bill/bill_hairs_young2")
	AddFacemap(billbeard, "Young", "models/humans/slav/bill/bill_hair_young")
	AddFacemap(billface, "Young", "models/humans/slav/bill/bill_head_young_nohat")

	AddFacemap(billcig, "Young No Beard", "models/humans/slav/bill/bill_head")
	AddFacemap(billhairs, "Young No Beard", "models/humans/slav/bill/bill_hairs_young")
	AddFacemap(billhairs2, "Young No Beard", "models/humans/slav/bill/bill_hairs_young2")
	AddFacemap(billbeard, "Young No Beard", "null")
	AddFacemap(billface, "Young No Beard", "models/humans/slav/bill/bill_head_young_nohat")

	AddFacemap(billcig, "Young No Cig", "null")
	AddFacemap(billhairs, "Young No Cig", "models/humans/slav/bill/bill_hairs_young")
	AddFacemap(billhairs2, "Young No Cig", "models/humans/slav/bill/bill_hairs_young2")
	AddFacemap(billbeard, "Young No Cig", "models/humans/slav/bill/bill_hair_young")
	AddFacemap(billface, "Young No Cig", "models/humans/slav/bill/bill_head_young_nohat")

	AddFacemap(billcig, "Young No Beard No Cig", "null")
	AddFacemap(billhairs, "Young No Beard No Cig", "models/humans/slav/bill/bill_hairs_young")
	AddFacemap(billhairs2, "Young No Beard No Cig", "models/humans/slav/bill/bill_hairs_young2")
	AddFacemap(billbeard, "Young No Beard No Cig", "null")
	AddFacemap(billface, "Young No Beard No Cig", "models/humans/slav/bill/bill_head_young_nohat")


	local travisfacemap = "models/humans/slav/travis/trav_facemap"
	AddFacemap(travisfacemap, "Default", "","models/zcity/m/travis.mdl") -- Travis
	AddFacemap(travisfacemap, "Face 1", "models/humans/slav/travis/trav_facemap1")
	AddFacemap(travisfacemap, "Face 2", "models/humans/slav/travis/trav_facemap2")

	local johnwickfacemap = "models/humans/slav/johnwick/wick_head"
	AddFacemap(johnwickfacemap, "Default", "","models/zcity/m/johnwick.mdl") -- John Wick

	local leetfacemap = "models/cstrike/t_leet"
	AddFacemap(leetfacemap, "Default", "","models/zcity/m/leet.mdl") -- Leet




end

-- Добавление новых Bodygroups (Перчаток)
local function AddCustomBodygroups()
    -- Эту функцию можно оставить почти как у вас, но с важными изменениями.
    -- ВАМ НУЖНО ИСПРАВИТЬ ПРОБЛЕМУ С ПЕРЧАТКАМИ, как вы сами поняли.
    -- Для этого нужно убедиться, что строковые ID (например, "reggloves_FIN_F") существуют в модели `models/zcity/gloves/degloves.mdl`.
    -- Вероятно, вам нужно перекомпилировать модели перчаток с правильными названиями тел.
    -- Или найти способ, как в оригинале (без .smd).

    -- Убеждаемся, что структура существует
    hg.Appearance.Bodygroups = hg.Appearance.Bodygroups or { HANDS = { [1] = { ["None"] = {"hands", false} }, [2] = { ["None"] = {"hands", false} } } }

    -- Функция добавления (адаптированная)
    local function AppAddBodygroup(strBodyGroup, strName, strStringID, bFemale, bPointShop, bDonateOnly, fCost, psModel, psBodygroups, psSubmats, psStrNameOveride)
        local pointShopID = "Standard_BodyGroups_" .. (psStrNameOveride or strName)
        -- Убеждаемся, что все вложенные таблицы существуют
        hg.Appearance.Bodygroups[strBodyGroup] = hg.Appearance.Bodygroups[strBodyGroup] or {}
        hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] = hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1] or {}
        hg.Appearance.Bodygroups[strBodyGroup][bFemale and 2 or 1][strName] = {
            strStringID,
            bPointShop,
            ID = pointShopID
        }
        -- Убеждаемся, что PLUGIN и его метод существуют
        if hg.PointShop and hg.PointShop.CreateItem then
            hg.PointShop:CreateItem(pointShopID, string.NiceName(strName), psModel or "models/zcity/gloves/degloves.mdl", psBodygroups, 0, Vector(0, 0, 0), fCost, bDonateOnly, psSubmats or {})
        else
            print("[CustomAppearance] Ошибка: hg.PointShop:CreateItem не найден!")
        end
    end

    -- Добавляем все перчатки (можно оставить как у вас)
    	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves", "reggloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 0)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Gloves fingerless", "reggloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 1)
	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet", "sceletgloves_FIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 0, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Skilet fingerless", "sceletgloves_outFIN_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 1, {
		[0] = "distac/gloves/sceletgloves"
	})

	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter", "wingloves_FIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 2, nil, "Bikers")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Winter fingerless", "wingloves_outFIN_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 3, nil, "Bikers fingerless")
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers gloves", "biker_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 5)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_M", false, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Bikers wool", "bikerwool_gloves_F", true, true, true, 399, "models/zcity/gloves/degloves.mdl", 6, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_glove_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Wool fingerless", "wool_gloves_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 7, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_M", false, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)
	AppAddBodygroup("HANDS", "Mitten wool", "mittenwool_F", true, true, true, 300, "models/zcity/gloves/degloves.mdl", 8, nil)
    -- ... и так далее
end

-- Вызов всех функций добавления
-- Лучше всего вызывать их в хуке, чтобы быть уверенным, что основные таблицы уже созданы.
hook.Add("Initialize", "CustomAppearance_Init", function()
    AddCustomModels()
    AddCustomClothes()
    AddCustomFacemaps()
    -- Bodygroups лучше добавлять, когда точно загружен PointShop
end)

-- Для Bodygroups используем хук, который есть в оригинале
hook.Add("ZPointshopLoaded", "CustomAppearance_AddBodygroups", function()
    AddCustomBodygroups()
end)

print("[ZCityAppearanceMod] Дополнение загружено!")

