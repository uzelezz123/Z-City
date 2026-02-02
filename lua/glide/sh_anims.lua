local IsValid = IsValid
local LocalPlayer = LocalPlayer
local NormalizeAngle = math.NormalizeAngle

local EntityMeta = FindMetaTable( "Entity" )
local getTable = EntityMeta.GetTable

hook.Add( "UpdateAnimation", "Glide.OverridePlayerAnim", function( ply )
    local vehicle = ply:GlideGetVehicle()
    if not IsValid( vehicle ) then return end
    if not vehicle.UpdatePlayerPoseParameters then return end

    -- Workarond to fix head angles
    if CLIENT then
        local parent = ply:GetParent()

        if IsValid( parent ) then
            local ang = parent:WorldToLocalAngles( ply:EyeAngles() )

            -- For other clients, EyeAngles seems to have
            -- "local-to-world" applied twice somehow
            if ply ~= LocalPlayer() then
                ang = parent:WorldToLocalAngles( ang )
            end

            ang[2] = NormalizeAngle( ang[2] - 90 )

            ply:SetPoseParameter( "head_pitch", ang[1] )
            ply:SetPoseParameter( "head_yaw", ang[2] )
        end
    end

    local updated = vehicle:UpdatePlayerPoseParameters( ply )

    if updated then
        GAMEMODE:GrabEarAnimation( ply )

        if CLIENT then
            GAMEMODE:MouthMoveAnimation( ply )
        end
    end

    return false
end )

local holdTypeSequences = {
    ["pistol"] = "sit_pistol",
    ["smg"] = "sit_smg1",
    ["grenade"] = "sit_grenade",
    ["ar2"] = "sit_ar2",
    ["shotgun"] = "sit_shotgun",
    ["rpg"] = "sit_rpg",
    ["physgun"] = "sit_physgun",
    ["crossbow"] = "sit_crossbow",
    ["melee"] = "sit_melee",
    ["slam"] = "sit_slam",
    ["fist"] = "sit_fist",
    ["camera"] = "sit_camera",
    ["passive"] = "sit_passive"
}

hook.Add( "CalcMainActivity", "Glide.OverridePlayerActivity", function( ply )
    local vehicle = ply:GlideGetVehicle()

    local vehTbl = getTable( vehicle )
    if not vehTbl then return end
    if not vehTbl.GetPlayerSitSequence then return end

    local plyTbl = getTable( ply )
    if plyTbl.m_bWasNoclipping then
        plyTbl.m_bWasNoclipping = nil
        ply:AnimResetGestureSlot( 6 ) -- GESTURE_SLOT_CUSTOM

        if CLIENT then
            ply:SetIK( true )
        end
    end

    local anim = vehicle:GetPlayerSitSequence( ply:GlideGetSeatIndex() )

    plyTbl.CalcIdeal = 47 -- ACT_STAND
    plyTbl.CalcSeqOverride = ply:LookupSequence( anim )

    -- We only apply a sit sequence when the vehicle actually uses one.
    if anim == "sit" and ply:GetAllowWeaponsInVehicle() then
        local activeWep = ply:GetActiveWeapon()

        if not IsValid( activeWep ) then
            return plyTbl.CalcIdeal, plyTbl.CalcSeqOverride
        end

        local holdType = activeWep:GetHoldType()
        local sitSequence = holdTypeSequences[holdType]

        -- Not every hold type has a corresponding sit sequence.
        if sitSequence then
            local sequenceID = ply:LookupSequence( sitSequence )

            if sequenceID ~= -1 then
                plyTbl.CalcIdeal = 1970 -- ACT_HL2MP_SIT
                plyTbl.CalcSeqOverride = sequenceID
            end
        end
    end

    return plyTbl.CalcIdeal, plyTbl.CalcSeqOverride
end )

if not CLIENT then return end

function Glide.ApplyBoneManipulations( ply, pose )
    local max = ply:GetBoneCount() - 1
    local name

    for i = 0, max do
        name = ply:GetBoneName( i )

        if name and pose[name] then
            ply:ManipulateBoneAngles( i, pose[name], false )
        end
    end

    ply.GlideHasPose = true
end

function Glide.ResetBoneManipulations( ply )
    if not ply.GlideHasPose then return end

    local max = ply:GetBoneCount() - 1
    local zeroAng = Angle()

    for i = 0, max do
        ply:ManipulateBoneAngles( i, zeroAng, false )
    end

    ply.GlideHasPose = nil
end

local ApplyBoneManipulations = Glide.ApplyBoneManipulations

hook.Add( "PrePlayerDraw", "Glide.ManipulatePlayerBones", function( ply )
    do return end
    local vehicle = ply:GlideGetVehicle()

    if IsValid( vehicle ) and vehicle.GetSeatBoneManipulations then
        local pose = vehicle:GetSeatBoneManipulations( ply:GlideGetSeatIndex() )

        if pose then
            ApplyBoneManipulations( ply, pose )
        end

    elseif ply.GlideHasPose then
        Glide.ResetBoneManipulations( ply )
    end
end )
