
local allowedchars = {
	"ах",
	"АХ",
	"гхх",
	"ГХ",
	"АААХХХ",
}

local audible_pain = {
	"АААААГХ..БЛЯ.. БОЛЬНО.",
	"Я БОЛЬШЕ НЕ МОГУ ЭТО ТЕРПЕТЬ!",
    "Пусть это ПРЕКРАТИТСЯ, пусть прекратится, ПУСТЬ ПРЕКРАТИТСЯ",
    "Почему ЭТО НЕ ПРЕКРАЩАЕТСЯ",
    "Вырубите меня. ПОЖАЛУЙСТА",
    "Зачем я родился, чтобы чувствовать это, зачем...",
    "Я сделаю что угодно, чтобы это прекратилось... ЧТО УГОДНО.",
    "Это не жизнь, это ПЫТКА",
    "Мне уже плевать, просто ОСТАНОВИТЕ БОЛЬ",
    "Ничего не важно, КРОМЕ ТОГО, ЧТОБЫ ЭТО ПРЕКРАТИЛОСЬ...",
    "Каждая секунда — это вечность в ОГНЕ.",
    "СМЕРТЬ БЫЛА БЫ МИЛОСЕРДИЕМ СЕЙЧАС...",
    "Хоть бы одно мгновение без боли..",
	"МНЕ БЫ СЕЙЧАС ОБЕЗБОЛИВАЮЩЕЕ. БЛЯТЬ.",
}

local sharp_pain = {
	"АААХХ",
	"АААХ",
	"ААааАХ",
	"ААааАХ",
	"ААааАААГХ",
	"ААааАХ",
	"ААаАааХ",
	"АААААааХ",
	"ААааАХХХХ",
	"ААаАА",
	"АААААа",
	"ААААаАААаааагхх",
	"АААааАа",
	"АааААагхф",
	"ааАааАафф",
	"аааххх",
	"АААааГХХХ",
	"АААааААХХ",
	"АААааАААААаГХХХХ",
	"АААааАААААаГХАААХХХ",
	"АААааАААААаГХХААААААХХ",
	"АААааАААААаГХХХХ",
	"АААааАААааАААаГХХХХ",
	"АААааАААааАААаАААААААГХХХХ",
	"АААааАААААаГХХХХ",
	"АААааАААААААААХХХ",
	"АААааАААААаГХАаааХХ",
	"АААааАААААаАаааааААААХХ",
	"АААааАААААаААААААААДГХХХХ",
	"АААааАААааАААаАААААААААААГГГГГГАГХХХХ",
	"АААааАААааАААаААААААААААААААААААХ",
}

hg.sharp_pain = sharp_pain

local random_phrase = {
	"Здесь как-то прохладно...",
	"Всё кажется слишком тихим...",
	"Дышать сейчас на удивление приятно.",
	"А что, если эта тишина навсегда?",
	"Почему ничего не происходит?",
}

local fear_hurt_ironic = {
	"Спорю, в этом есть урок... если я выживу.",
	"Мой будущий биограф в эту часть не поверит.",
	"М-да, тупой способ откинуться.",
	"По крайней мере, моя жизнь не была скучной.",
	"Заметка на будущее: Больше так никогда не делать.",
	"Не самый худший день, чтобы умереть.",
}

local fear_phrases = {
	"Всё ведь не так плохо... правда?",
	"Я не хочу так умирать.",
	"Неужели это и есть конец?",
	"Дело дрянь.",
	"Неужели это правда конец?",
	"Я не хочу умирать вот так.",
	"Хотел бы я, чтобы был выход.",
	"Я сожалею о стольких вещах.",
	"Это не может быть концом.",
	"Не верится, что это происходит со мной.",
	"Надо было отнестись к этому серьезнее.",
	"А что, если я не справлюсь..?",
	"Всё хуже, чем я думал.",
	"Это так несправедливо.",
	"Я пока не могу сдаться.",
	"Никогда не думал, что всё будет так.",
	"Надо было слушать инстинкты.",
	"Дыши. Просто дыши.",
	"Руки холодные. Руки не дрожат.",
}

local is_aimed_at_phrases = {
    "О Боже. Это конец.",
    "Не. Двигайся.",
    "Неужели так я и умру?",
    "Надо было бежать. Почему я не побежал?",
    "Пожалуйста, не нажимай на курок. Пожалуйста.",
    "Я вижу палец на спусковом крючке.",
    "Я не хочу умирать. Только не так.",
    "Если я буду умолять, станет ли хуже?",
    "Это не может быть реальностью. Это не может быть правдой.",
    "Помогите мне. Пожалуйста. Кто-нибудь.",
    "Я не хочу умереть в таком месте.",
    "Я не хочу, чтобы моей последней мыслью был страх.",
    "Я не хочу умирать.",
}

local near_death_poetic = {
	"Пытаюсь встать... но просто не могу...",
	"Дыхание — лишь мелкие глотки пустоты...",
	"Уже не понимаю, открыты мои глаза или нет...",
	"Последнее, что я почувствую на вкус — моя кровь и медь.",
	"Взгляд соскальзывает с предметов.",
	"Не могу вспомнить, как стоять на ногах.",
	"Всё эхом отдается в черепе.",
	"Моргание длится слишком долго.",
	"Пальцы не могут ничего сжать.",
	"Легкие отказываются наполняться.",
	"Сожаления теперь бессмысленны.",
}

local near_death_positive = {
	"Я не хочу умирать.",
	"Я должен выжить.",
	"Шанс всё еще есть.",
	"Я не позволю страху победить.",
	"Еще одна попытка.",
	"Я отказываюсь здесь умирать.",
	"Так... надо всё обдумать.",
	"Просто не двигайся. От движений только хуже.",
	"Дыши медленно. Паника не поможет.",
	"Всё не кончено, пока не кончено.",
	"Боль — это просто сигнал. Игнорируй её.",
	"Если это конец... по крайней мере, это будет быстро.",
	"Я переживал и худшее. Наверное.",
	"Не так я себе это представлял.",
}

local broken_limb = {
	"БЛЯТЬ. БЛЯ. ОНА ТОЧНО СЛОМАНА!",
	"Я ЧУВСТВУЮ, КАК ДВИГАЮТСЯ ОСКОЛКИ КОСТИ!",
	"ОНА НАХЕР СЛОМАНА. КАЖЕТСЯ..",
	"Больно даже думать об этом. Точно перелом.",
	"Не думаю, что она должна здесь гнуться.",
	"О боже. Она хрустнула.",
	"Не вижу открытого перелома, но чувствую, что я что-то сломал",
}

local dislocated_limb = {
	"Да, она не должна так выгибаться.",
	"Мне нужно вправить эту кость обратно.",
	"Нет... Мне нужно поставить её на место.",
	"Там просто очень больно. Возможно, нужен врач.",
	"У меня конечность не на месте.",
}

local hungry_a_bit = {
    "Мгх, я голоден...",
    "Еда бы сейчас не помешала...",
    "Есть хочется...",
    "Надо бы чего-нибудь перекусить.",
}

local very_hungry = {
    "Мой желудок... Угх...",
    "Если я не поем, мне станет еще хуже...",
    "Желудок... Черт... Меня тошнит",
}

local after_unconscious = {
    "Что случилось? Больно...",
	"Где я? Почему так больно...",
	"Я-я думал, что умру...",
	"Моя голова... Что произошло?",
	"Я что, только что чуть не умер?",
	"Ощущение, будто я умер.",
	"Небеса меня не забрали?",
	"Ох-х бля... голова раскалывается...",
	"Ох, встать сейчас будет сложно... но я должен...",
	"Я вообще не узнаю это место... или узнаю?",
	"Я не хочу пережить это КОГДА-ЛИБО ЕЩЕ!",
}

local slight_braindamage_phraselist = {
	"Я не понимаю...",
	"В этом нет смысла...",
	"Где я?",
	"А? Что это..?",
	"Я не знаю, что происходит...",
	"Эй?",
	"Угххх оххх...      а...",
	"Что... происходит?",
}

local braindamage_phraselist = {
	"Бббее.. гддеа мгх?!",
	"Бммэээ... мехк...",
	"Мм--хххх. Ммм?",
	"Гхмгх уххх...",
	"Ахгг...мг?",
	"Хггхх... Д-Дммх.",
	"Лмммпхф, мп-хф!",
	"Поооммоооггии...",
	"Нгхх... Гмх?",
	"Ггг... Бгх..",
	"Бхрхраин.",
}

local cold_phraselist = {
	"Становится очень холодно..",
	"Слишком холодно для меня.",
	"Я дрожу, черт возьми, чувак.",
	"Тут снаружи экстремально свежо..",
	"Нужно чем-то согреться...",
	"Мне довольно холодно...",
	"Меня тошнит от этого холода, бля."
}

local freezing_phraselist = {
	"Я.. н-не.. не чувствую с-своего т-тела..",
	"Я не.. ч-чувствую ног...",
	"Я ч-чертовски з-замерз..",
	"М-мне кажет-тся, мое лицо онем-мело..",
	"Холодн-но..",
	"Я.. ничего н-не чув-вствую..",
}

local numb_phraselist = {
	"Уже не.. холодно..",
	"Почему... кажется, что тепло..?",
	"Думаю, я в порядке... Думаю...",
	"Наконец-то тепло...",
	"Мне снова тепло... Каким-то образом...",
	"Я же только что замерзал... Откуда взялось это тепло..?",
}

local hot_phraselist = {
	"Я такой потный..",
	"Эта жара меня убивает..",
	"Моя одежда пропиталась потом, черт.",
	"Мой пот пипец воняет. Надо бы остыть...",
	"Немного жарковато, бля, чувак.",
	"Я перегреваюсь, реально плохо...",
	"Почему здесь так жарко?",
}

local heatstroke_phraselist = {
	"МНЕ НУЖНА ВОДА!!",
	"Пожалуйста... воды...",
	"Голова кружится... Бляя-",
	"МОЯ ГОЛОВА!- Больно..",
	"Голова раскалывается..",
}

local heatvomit_phraselist = {
	"Эта жара..- Меня сейчас вырвет-",
	"Уггххх... Я сейчас блевану-",
	"Бляя.. Оугхх.. Я не чувствую-"
}

local hg_showthoughts = ConVarExists("hg_showthoughts") and GetConVar("hg_showthoughts") or CreateClientConVar("hg_showthoughts", "1", true, true, "Toggle thoughts of your character", 0, 1)

function string.Random(length)
	local length = tonumber(length)

    if length < 1 then return end

    local result = {}

    for i = 1, length do
        result[i] = allowedchars[math.random(#allowedchars)]
    end

    return table.concat(result)
end

function hg.nothing_happening(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear < -0.6
end

function hg.fearful(ply)
	if not IsValid(ply) then return end

	return ply.organism and ply.organism.fear > 0.5
end

function hg.likely_to_phrase(ply)
	local org = ply.organism

	local pain = org.pain
	local brain = org.brain
	local blood = org.blood
	local fear = org.fear
	local temperature = org.temperature
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone - CurTime()) < -3)

	return (broken_dislocated) and 5
		or (pain > 65) and 5
		or (temperature < 31 and 0.5)
		or (temperature > 38 and 0.5)
		or (blood < 3000 and 0.3)
		--or (fear > 0.5 and 0.7)
		or (brain > 0.1 and brain * 5)
		or (fear < -0.5 and 0.05)
		or -0.1
end

function IsAimedAt(ply)
    return ply.aimed_at or 0
end

local function get_status_message(ply)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end

	local nomessage = hook.Run("HG_CanThoughts", ply) --ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"
	if nomessage ~= nil and nomessage == false then return "" end

    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism
	
	if not org or not org.brain then return "" end

	local pain = org.pain
	local brain = org.brain
	local temperature = org.temperature
	local blood = org.blood
	local hungry = org.hungry
	local broken_dislocated = org.just_damaged_bone and ((org.just_damaged_bone + 3 - CurTime()) < -3)

	if broken_dislocated and org.just_damaged_bone then
		org.just_damaged_bone = nil
	end
	
	local broken_notify = (org.rarm == 1) or (org.larm == 1) or (org.rleg == 1) or (org.lleg == 1)
	local dislocated_notify = (org.rarm == 0.5) or (org.larm == 0.5) or (org.rleg == 0.5) or (org.lleg == 0.5)
	local after_unconscious_notify = org.after_otrub

	if not isnumber(pain) then return "" end

	local str = ""

	local most_wanted_phraselist
	
	if temperature < 35 then
		most_wanted_phraselist = temperature > 31 and cold_phraselist or (temperature < 28 and numb_phraselist or freezing_phraselist)
	elseif temperature > 38 then
		most_wanted_phraselist = temperature < 40 and hot_phraselist or heatstroke_phraselist
	end

	if not most_wanted_phraselist and hungry and hungry > 25 and math.random(3) == 1 then
		most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
	end

	if (blood < 3100) or (pain > 75) or (broken_dislocated) or (broken_notify) or (dislocated_notify) then
		if pain > 75 and (broken_dislocated) then
			most_wanted_phraselist = math.random(2) == 1 and audible_pain or (broken_notify and broken_limb or dislocated_limb)
		elseif pain > 75 then
			most_wanted_phraselist = audible_pain
		elseif broken_dislocated then
			most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
		end

		if pain > 100 then
			most_wanted_phraselist = sharp_pain
		end

		if not most_wanted_phraselist then
			if (broken_dislocated_notify) and (blood < 3100) then
				most_wanted_phraselist = blood < 2900 and (near_death_poetic) or (math.random(2) == 1 and (broken_notify and broken_limb or dislocated_limb) or near_death_poetic)
			--elseif(broken_dislocated_notify)then
				--most_wanted_phraselist = (broken_notify and broken_limb or dislocated_limb)
			elseif(blood < 3100)then
				most_wanted_phraselist = near_death_poetic
			end
		end
	elseif after_unconscious_notify then
		most_wanted_phraselist = after_unconscious
	elseif hg.nothing_happening(ply) then
		most_wanted_phraselist = random_phrase

		if hungry and hungry > 25 and math.random(5) == 1 then
			most_wanted_phraselist = hungry > 45 and very_hungry or hungry_a_bit
		end
	elseif hg.fearful(ply) then
		most_wanted_phraselist = ((IsAimedAt(ply) > 0.9) and is_aimed_at_phrases or (math.random(10) == 1 and fear_hurt_ironic or fear_phrases))
	end

	if brain > 0.1 then
		most_wanted_phraselist = brain < 0.2 and slight_braindamage_phraselist or braindamage_phraselist
	end
	
	if most_wanted_phraselist then
		str = most_wanted_phraselist[math.random(#most_wanted_phraselist)]

		return str
	else
		return ""
	end
end

local allowedlist_types = {
	heatvomit = heatvomit_phraselist,
}

function hg.get_phraselist(ply, type)
	if not IsValid(ply) then
		if CLIENT then
			ply = lply
		else
			return
		end
	end
	
	local nomessage = ply.PlayerClassName == "Gordon" || ply.PlayerClassName == "Combine"

	if nomessage then return "" end
    if ply:GetInfoNum("hg_showthoughts", 1) == 0 then return "" end

	local org = ply.organism	
	if not org or not org.brain then return "" end

	if not isstring(type) or not allowedlist_types[type] then return "" end

	local needed_list = allowedlist_types[type]

	local str = needed_list[math.random(#needed_list)]
	return str
end

function hg.get_status_message(ply)
	local txt = get_status_message(ply)

	return txt
end
