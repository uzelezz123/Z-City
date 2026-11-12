CRIMXP = CRIMXP or {}

CRIMXP.Config = {
	BaseKillXP = 100,
	HeadshotBonus = 50,
	MeleeBonus = 50,
	LongshotBonus = 25,
	LongshotDist = 1550,
	AssistXP = 30,
	AssistFraction = 0.25,
	BotKillXP = 0.5,
	MultikillWindow = 6,
	MultikillBonus = {25, 50, 75, 100},
	StreakEvery = 5,
	StreakBonus = 50,
	FractureBaseKill = 150,
	FractureHeadshot = 75,
	FractureMelee = 75,
	FractureLongshot = 40,
	FractureAssist = 50,
	FractureMultikillBonus = {50, 100, 150, 200},
	FractureStreakBonus = 100,
	FractureLevelUpBonus = 250,
	FractureBotKill = 0.5,
	VictimLevelScale = 0.02,
	VictimLevelScaleCap = 0.5,
	XPBase = 500,
	XPGrowth = 1.1,
	MaxLevel = 100,
}

CRIMXP.Ranks = {
	{level = 1, name = "Civilian", color = Color(200, 200, 200)},
	{level = 5, name = "Crook", color = Color(120, 255, 120)},
	{level = 10, name = "Thug", color = Color(255, 220, 80)},
	{level = 15, name = "Gangster", color = Color(255, 180, 40)},
	{level = 20, name = "Hustler", color = Color(255, 150, 40)},
	{level = 27, name = "Hitman", color = Color(255, 110, 40)},
	{level = 35, name = "Enforcer", color = Color(255, 70, 40)},
	{level = 45, name = "Assassin", color = Color(255, 40, 70)},
	{level = 55, name = "Underboss", color = Color(220, 40, 255)},
	{level = 70, name = "Crime Lord", color = Color(160, 60, 255)},
	{level = 85, name = "Kingpin", color = Color(100, 100, 255)},
	{level = 100, name = "Godfather", color = Color(255, 255, 120)},
}

CRIMXP.Net = {
	Kill = "hg_crimxp_kill",
	Assist = "hg_crimxp_assist",
	Death = "hg_crimxp_death",
	LevelUp = "hg_crimxp_levelup",
}

function CRIMXP.GetRank(level)
	local rank = CRIMXP.Ranks[1]
	for i = 1, #CRIMXP.Ranks do
		if level >= CRIMXP.Ranks[i].level then rank = CRIMXP.Ranks[i] end
	end
	return rank.name, rank.color
end

function CRIMXP.XPForLevel(level)
	return math.floor(CRIMXP.Config.XPBase * CRIMXP.Config.XPGrowth ^ (level - 1))
end

function CRIMXP.LevelForXP(xp)
	xp = math.max(math.floor(xp or 0), 0)
	local level, remaining = 1, xp
	while level < CRIMXP.Config.MaxLevel do
		local need = CRIMXP.XPForLevel(level)
		if remaining < need then break end
		remaining = remaining - need
		level = level + 1
	end
	if level >= CRIMXP.Config.MaxLevel then return CRIMXP.Config.MaxLevel, 0, 0 end
	return level, remaining, CRIMXP.XPForLevel(level)
end

function CRIMXP.TotalXPForLevel(level)
	level = math.Clamp(math.floor(tonumber(level) or 1), 1, CRIMXP.Config.MaxLevel)

	local total = 0
	for i = 1, level - 1 do
		total = total + CRIMXP.XPForLevel(i)
	end

	return total
end

local PLAYER = FindMetaTable("Player")

function PLAYER:GetCrimeLevel() return self:GetNWInt("hg_crime_level", 1) end
function PLAYER:GetCrimeXP() return self:GetNWInt("hg_crime_xp", 0) end
function PLAYER:GetCrimeKills() return self:GetNWInt("hg_crime_kills", 0) end
function PLAYER:GetCrimeDeaths() return self:GetNWInt("hg_crime_deaths", 0) end
function PLAYER:GetCrimeStreak() return self:GetNWInt("hg_crime_streak", 0) end
function PLAYER:GetCrimeBestStreak() return self:GetNWInt("hg_crime_beststreak", 0) end
function PLAYER:GetFracture() return self:GetNWInt("hg_crime_fracture", 0) end
