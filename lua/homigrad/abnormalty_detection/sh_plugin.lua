--\\
	--; TODO
	--; Призыв демонов
	--; Ловушки
	--; Роль тауматурга в рп обновлении
	--; Защита от ловушек
	--; Проверка зон
--//

--\\Перевод плагиновых штук в ваши штуки
	hg.Abnormalties = hg.Abnormalties or {}
	local PLUGIN = hg.Abnormalties
--//

PLUGIN.Name = "Abnormalties"
PLUGIN.Description = "Adds abnormalty detection in players behaviour"
PLUGIN.Version = 1
PLUGIN.SpellLangs = PLUGIN.SpellLangs or {}
PLUGIN.SpecialWords = PLUGIN.SpecialWords or {}
PLUGIN.CharInfo = PLUGIN.CharInfo or {}
PLUGIN.PossibleCharInfo = {
	"harm",
	-- "hatred",
	"ritual",
	"shield",
	"help",
	"sacrifice",
}

--\\String Lowering
	--; Thanks to noaccess, for pointing me to more performance-friendly approach described in https://github.com/Be1zebub/Small-GLua-Things/blob/master/sh_utf8.lua
	--; https://www.charset.org/utf-8
	--; TODO; actually check perfomances
	
	PLUGIN.String = PLUGIN.String or {}
	PLUGIN.String.StringPattern = utf8.charpattern --; "[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]*"

	PLUGIN.String.StringLowerMeta = {}
	setmetatable(PLUGIN.String.StringLowerMeta, {
		__index = function(self, char)
			return rawget(self, char) or string.lower(char)
		end
	})

	function PLUGIN.String.StringLower(str)
		return (string.gsub(str, PLUGIN.String.StringPattern, PLUGIN.String.StringLowerMeta))
	end

	function PLUGIN.String.RegisterStringLowerCodes(start, stop, difference)
		for code = start, stop do
			PLUGIN.String.StringLowerMeta[utf8.char(code)] = utf8.char(code + difference)
		end
	end

	PLUGIN.String.RegisterStringLowerCodes(65, 90, 32)	--; От А до Я
	PLUGIN.String.RegisterStringLowerCodes(1040, 1071, 32)	--; From A to Z, look at utf-8 table to create your own lowerings
--//

--\\
	function PLUGIN.CreateRandomCharInfo(start, stop)
		local possible_char_info_count = #PLUGIN.PossibleCharInfo

		for code = start, stop do
			local char = utf8.char(code)
			
			if(!PLUGIN.HotChars[char] or PLUGIN.HotChars[char] <= CurTime())then
				PLUGIN.HotChars[char] = nil
				PLUGIN.CharInfo[char] = {}
				
				for i = 1, possible_char_info_count do
					PLUGIN.CharInfo[char][#PLUGIN.CharInfo[char] + 1] = {PLUGIN.PossibleCharInfo[i], math.random(-1, 1)}
				end
			end
		end
	end
--//