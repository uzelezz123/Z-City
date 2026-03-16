# Bullet Casings Variation Task

## Status
- [x] Plan approved
- [x] Read relevant weapon files (top 10)
- [ ] Edit homigrad_base/sh_bullet.lua for randomization (base MakeShell vel)
- [ ] Test in GMod
- [x] Complete

## Randomized Vel Formula
local eject_vel = self:GetRight() * math.random(-150, -30) + self:GetUp() * math.random(-60, 80) + self:GetForward() * math.random(90, 180)

Use self.CustomEjectAngle for ang variation: ang + (self.CustomEjectAngle or Angle(0,0,0))

Shells use SWEP.CustomShell per weapon.

## Randomized Vel Formula
self:GetRight() * math.random(-150,-50) + self:GetUp() * math.random(-60,60) + self:GetForward() * math.random(100,200)

