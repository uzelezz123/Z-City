include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_heli" )

--- Override the base class `OnUpdateMisc` function.
---
--- I'm using this instead of `OnUpdateSounds` because
--- `OnUpdateSounds` is not called while the engine is off.
function ENT:OnUpdateMisc()
    BaseClass.OnUpdateMisc( self )

    local sounds = self.sounds

    if self:GetFiringMinigun() then
        if not sounds.minigunFire then
            local minigunFire = self:CreateLoopingSound( "minigunFire", self.MinigunFireLoop, 85, self )
            minigunFire:PlayEx( 1.0, 100 )

            if self.MinigunSpinLoop ~= "" then
                local minigunSpin = self:CreateLoopingSound( "minigunSpin", self.MinigunSpinLoop, 85, self )
                minigunSpin:PlayEx( 0.5, 100 )
            end
        end

    elseif sounds.minigunFire then
        sounds.minigunFire:Stop()
        sounds.minigunFire = nil

        if sounds.minigunSpin then
            sounds.minigunSpin:Stop()
            sounds.minigunSpin = nil
        end

        self:EmitSound( self.MinigunFireStop, 85, 100, 1.0 )

        if self.MinigunSpinStop ~= "" then
            self:EmitSound( self.MinigunSpinStop, 85, 100, 0.6 )
        end
    end
end

--- Override the base class `OnDeactivateMisc` function.
function ENT:OnDeactivateMisc()
    local sounds = self.sounds

    if sounds.minigunFire then
        sounds.minigunFire:Stop()
        sounds.minigunFire = nil

        if sounds.minigunSpin then
            sounds.minigunSpin:Stop()
            sounds.minigunSpin = nil
        end
    end
end
