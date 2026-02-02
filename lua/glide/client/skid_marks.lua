-- Class to manage the quads for skid marks/tire roll marks
local SkidHandler = Glide.SkidHandler or {}

Glide.SkidHandler = SkidHandler
SkidHandler.__index = SkidHandler

function SkidHandler.Instantiate( maxPieces, materialPath )
    return setmetatable( {
        material = Material( materialPath ),
        maxPieces = maxPieces,
        lastQuadIndex = 0,
        quadCount = 0,
        quads = {}
    }, SkidHandler )
end

function SkidHandler:Destroy()
    self.pieces = nil
    self.material = nil
    setmetatable( self, nil )
end

local RealTime = RealTime
local TraceLine = util.TraceLine

local Config = Glide.Config

local ray = {}
local traceData = { mask = MASK_NPCWORLDSTATIC, output = ray }

function SkidHandler:AddPiece( lastQuadId, pos, forward, normal, width, strength )
    traceData.start = pos + normal * 10
    traceData.endpos = pos - normal * 10
    TraceLine( traceData )

    if not ray.Hit then return end

    local quads = self.quads
    local i = self.lastQuadIndex + 1

    if i > self.maxPieces then i = 1 end
    if i > self.quadCount then self.quadCount = i end

    self.lastQuadIndex = i

    normal = ray.HitNormal
    pos = ray.HitPos + normal
    forward:Normalize()

    local right = normal:Cross( forward )
    local lastQuad = quads[lastQuadId]

    quads[i] = {
        pos + right * width,                -- [1] 1st vertex
        pos - right * width,                -- [2] 2nd vertex
        lastQuad and lastQuad[2] or pos,    -- [3] 3rd vertex
        lastQuad and lastQuad[1] or pos,    -- [4] 4th vertex
        55 + 200 * strength,                -- [5] Alpha
        RealTime() + Config.skidmarkTimeLimit -- [6] Lifetime
    }

    return i
end

local Min = math.min
local SetMaterial = render.SetMaterial
local DrawQuad = render.DrawQuad

local color = Color( 255, 255, 255 )

function SkidHandler:Draw( t )
    SetMaterial( self.material )

    local quads = self.quads
    local q, timeLeft

    for i = 1, self.quadCount do
        q = quads[i]
        timeLeft = q[6] - t

        if timeLeft > 0 then
            color.a = q[5] * Min( timeLeft * 0.5, 1 )
            DrawQuad( q[1], q[2], q[3], q[4], color )
        end
    end
end

-----

local skidMarkHandler = Glide.skidMarkHandler
local tireRollHandler = Glide.tireRollHandler

function Glide.AddSkidMarkPiece( lastQuadId, pos, forward, normal, width, strength )
    if skidMarkHandler then
        return skidMarkHandler:AddPiece( lastQuadId, pos, forward, normal, width, strength )
    end
end

function Glide.AddTireRollPiece( lastQuadId, pos, forward, normal, width, strength )
    if tireRollHandler then
        return tireRollHandler:AddPiece( lastQuadId, pos, forward, normal, width, strength )
    end
end

function Glide.DestroySkidMarkMeshes()
    if Glide.skidMarkHandler then
        Glide.skidMarkHandler:Destroy()
        Glide.PrintDev( "Skid mark mesh has been destroyed." )
    end

    if Glide.tireRollHandler then
        Glide.tireRollHandler:Destroy()
        Glide.PrintDev( "Tire roll mesh has been destroyed." )
    end

    Glide.tireRollHandler = nil
    Glide.skidMarkHandler = nil

    skidMarkHandler = nil
    tireRollHandler = nil
end

function Glide.SetupSkidMarkMeshes()
    Glide.DestroySkidMarkMeshes()

    -- Mesh handler for skid marks
    if Config.maxSkidMarkPieces > 0 then
        skidMarkHandler = SkidHandler.Instantiate( Config.maxSkidMarkPieces, "glide/skidmarks/skid_asphalt" )

        Glide.skidMarkHandler = skidMarkHandler
        Glide.PrintDev( "Initialized skid mark mesh with %d max. quads.", skidMarkHandler.maxPieces )
    end

    -- Mesh handler for tire roll marks
    if Config.maxTireRollPieces > 0 then
        tireRollHandler = SkidHandler.Instantiate( Config.maxTireRollPieces, "glide/skidmarks/roll_dirt" )

        Glide.tireRollHandler = tireRollHandler
        Glide.PrintDev( "Initialized tire roll mesh with %d max. quads.", tireRollHandler.maxPieces )
    end
end

hook.Add( "PreCleanupMap", "Glide.RemoveSkidMarkMeshes", Glide.DestroySkidMarkMeshes )
hook.Add( "PostCleanupMap", "Glide.RecreateSkidMarkMeshes", Glide.SetupSkidMarkMeshes )

local SetBlend = render.SetBlend
local SetColorModulation = render.SetColorModulation

hook.Add( "PreDrawTranslucentRenderables", "Glide.RenderSkidMarks", function( isDrawDepth, isDrawSkybox, isDraw3DSkybox )
    if isDrawDepth or isDrawSkybox or isDraw3DSkybox then return end

    SetBlend( 1 )
    SetColorModulation( 1, 1, 1 )

    local t = RealTime()

    if skidMarkHandler then
        skidMarkHandler:Draw( t )
    end

    if tireRollHandler then
        tireRollHandler:Draw( t )
    end
end )
