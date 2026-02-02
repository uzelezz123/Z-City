ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Radio"
ENT.Author = "Deka"
ENT.Category = "ZCity Other" -- deka/uzelezz/salat - shit
ENT.Spawnable = true
ENT.Model = "models/props/cs_office/radio.mdl"
ENT.IconOverride = "vgui/wep_jack_hmcd_walkietalkie"

playingents = playingents or {}

function ENT:SetupDataTables()
	self:NetworkVar("String", 1, "TextureURL")
	if SERVER then
		self:SetTextureURL("")
	end
end

function ENT:Use(activator, caller)
    if IsValid(caller) and caller:IsPlayer() then
        caller:SetNWEntity("Radio", self)
        net.Start("RadioURLInput")
        net.WriteEntity(self)
        net.Send(caller)
    end
end

function ENT:PlayURL(url,timespend)
    timespend = timespend or 0
    if IsValid(self.sound) then
        self.sound:Stop()
    end

    sound.PlayURL(url, "3d noblock", function(station)
        if IsValid(station) then
            self.sound = station
            self.sound:SetPos(self:GetPos())
            self.sound:Play()
            if not station:IsBlockStreamed() then
                self.sound:SetTime(timespend)
            end
            playingents[self:EntIndex()][3] = station
        else
            print("Unable to play the sound.")
        end
    end)
end

function ENT:OnRemove()
    if CLIENT then
        playingents[self:EntIndex()] = nil
    end
    if self.sound and IsValid(self.sound) then
        self.sound:Stop()
        self.sound = nil
    end
end