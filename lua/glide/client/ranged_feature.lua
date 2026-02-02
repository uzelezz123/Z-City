--[[
    A utility class used to automatically create/destroy
    sounds/lights/particle emitters depending on:

    - The local player's distance from the entity
    - The `Entity:IsDormant` state
    - The result from the "test" function (if set)
]]
local RangedFeature = Glide.RangedFeature or {}

RangedFeature.__index = RangedFeature
Glide.RangedFeature = RangedFeature

function Glide.CreateRangedFeature( ent, distance, bias )
    bias = bias or 100

    local activateDist = distance - bias
    local deactivateDist = distance + bias

    return setmetatable( {
        ent = ent,
        isActive = false,
        lastDistance = 0,

        activateDist = activateDist * activateDist,
        deactivateDist = deactivateDist * deactivateDist
    }, RangedFeature )
end

function RangedFeature:SetActivateCallback( callback )
    self.onActivate = callback
end

function RangedFeature:SetDeactivateCallback( callback )
    self.onDeactivate = callback
end

function RangedFeature:SetUpdateCallback( callback )
    self.onUpdate = callback
end

function RangedFeature:SetTestCallback( callback )
    self.testFunc = callback
end

function RangedFeature:Activate()
    self.isActive = true

    if self.onActivate then
        self.ent[self.onActivate]( self.ent )
    end
end

function RangedFeature:Deactivate()
    self.isActive = false

    if self.onDeactivate then
        self.ent[self.onDeactivate]( self.ent )
    end
end

function RangedFeature:Destroy()
    self:Deactivate()
    setmetatable( self, nil )
end

local GetLocalViewLocation = Glide.GetLocalViewLocation

function RangedFeature:Think()
    local ent = self.ent
    local dist = ent:GetPos():DistToSqr( GetLocalViewLocation() )
    local isDormant = ent:IsDormant()
    local passedTest = true

    self.lastDistance = dist

    if self.testFunc then
        passedTest = ent[self.testFunc]( ent )
    end

    if self.isActive then
        if dist > self.deactivateDist or isDormant or not passedTest then
            self:Deactivate()
        end

    elseif dist < self.activateDist and not isDormant and passedTest then
        self:Activate()
    end

    if self.isActive and self.onUpdate then
        ent[self.onUpdate]( ent )
    end
end
