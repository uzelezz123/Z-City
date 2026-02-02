include( "shared.lua" )

DEFINE_BASECLASS( "base_glide_car" )

--- Implement this base class function.
function ENT:AllowFirstPersonMuffledSound()
    return false
end

--- Implement this base class function.
function ENT:AllowWindSound()
    return true, 1
end

local POSE_DATA = {
    ["ValveBiped.Bip01_L_Thigh"] = Angle( -10, -3, 0 ),
    ["ValveBiped.Bip01_L_Calf"] = Angle( -15, 50, 10 ),
    ["ValveBiped.Bip01_R_Thigh"] = Angle( 10, -3, 0 ),
    ["ValveBiped.Bip01_R_Calf"] = Angle( 15, 50, -10 )
}

local DRIVER_POSE_DATA = {
    ["ValveBiped.Bip01_L_UpperArm"] = Angle( -8, 10, 0 ),
    ["ValveBiped.Bip01_R_UpperArm"] = Angle( 10, 8, 5 ),

    ["ValveBiped.Bip01_L_Thigh"] = Angle( -5, 2, 0 ),
    ["ValveBiped.Bip01_L_Calf"] = Angle( -20, 60, 0 ),
    ["ValveBiped.Bip01_R_Thigh"] = Angle( 5, 2, 0 ),
    ["ValveBiped.Bip01_R_Calf"] = Angle( 20, 60, 0 )
}

local FrameTime = FrameTime
local ExpDecayAngle = Glide.ExpDecayAngle

--- Implement this base class function.
function ENT:GetSeatBoneManipulations( seatIndex )
    if seatIndex > 1 then
        return POSE_DATA
    end

    local decay = 5
    local dt = FrameTime()
    local resting = self:GetVelocity():Length() < 50

    local thigh = DRIVER_POSE_DATA["ValveBiped.Bip01_L_Thigh"]
    local calf = DRIVER_POSE_DATA["ValveBiped.Bip01_L_Calf"]

    thigh[1] = ExpDecayAngle( thigh[1], resting and -30 or -5, decay, dt )
    thigh[2] = ExpDecayAngle( thigh[2], resting and 55 or 2, decay, dt )
    thigh[3] = ExpDecayAngle( thigh[3], resting and -5 or 0, decay, dt )

    calf[1] = ExpDecayAngle( calf[1], resting and 0 or -20, decay, dt )
    calf[2] = ExpDecayAngle( calf[2], resting and -25 or 60, decay, dt )

    return DRIVER_POSE_DATA
end
