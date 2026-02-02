--\\Перевод плагиновых штук в ваши штуки
hg.Abnormalties = hg.Abnormalties or {}
local PLUGIN = hg.Abnormalties
--//

PLUGIN.SpecialWords = PLUGIN.SpecialWords or {}
local sw = PLUGIN.SpecialWords
sw["ритуал"] = {ritual = 4, shield = -4}
sw["кровь"] = {harm = 3, help = -4}
sw["смерть"] = {harm = 3, sacrifice = 3, help = -4}
sw["жертва"] = {sacrifice = 5, help = -4}
sw["помощь"] = {help = 5, harm = -4}
sw["щит"] = {shield = 2, harm = -2}
sw["привет"] = {shield = 2, harm = -2, help = 2}
sw["ноте"] = {ritual = 4}

sw["ritual"] = sw["ритуал"]
sw["blood"] = sw["кровь"]
sw["death"] = sw["смерть"]
sw["sacrifice"] = sw["жертва"]
sw["help"] = sw["помощь"]
sw["shield"] = sw["щит"]