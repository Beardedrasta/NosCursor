setfenv(1, NosCursor:GetEnvironment())
local hover = NosCursor.hover
local mouseTextures = NosCursor.textures
local trailTextures = NosCursor.trailtextures

local trailPool = {}
local activeTrail = {}
local maxTrails = C.maxtrails
local FADE_DURATION = maxTrails * 0.005

function CreateTrailDot()
    local texture = trailTextures[C.dottexture]
    local max, min = C.maxtrailsize, C.mintrailsize
    local dot = CreateFrame("Frame", "NosCursorTrail", UIParent)
    SetSize(dot, max, max)
    dot:SetFrameStrata("TOOLTIP")

    dot.texture = dot:CreateTexture(nil, "ARTWORK")
    dot.texture:SetAllPoints(dot)
    dot.texture:SetTexture(texture)
    dot.texture:SetBlendMode("ADD")


    dot:Hide()
    dot.spawnTime = 0
    return dot
end

function UpdateTrailPool()
    for i = 1, table.getn(trailPool) do
        if trailPool[i] then
            trailPool[i]:Hide()
            trailPool[i] = nil
        end
    end


    trailPool = {}
    maxTrails = C.maxtrails 
    FADE_DURATION = maxTrails * 0.005

    for i = 1, maxTrails do
        trailPool[i] = CreateTrailDot()
    end


    activeTrail = {}
end

for i = 1, maxTrails do
    trailPool[i] = CreateTrailDot()
end

local function GetTrailSize(index)
    local max, min = C.maxtrailsize, C.mintrailsize
    local normalized = (index - 1) / (maxTrails - 1)
    return min + (max - min) * (1 - normalized)
end

function UpdateDisplay()
    hover:SetWidth(C.width)
    hover:SetHeight(C.height)

    NosCursor.updateFrame:Hide()
    NosCursor.updateFrame:SetScript("OnUpdate", nil)

    if C.rgb == 1 then
        Rain(hover.texture)
    elseif C.customcolor == 1 then
        hover.texture:SetVertexColor(unpack(C.mousecolor))
    else
        hover.texture:SetVertexColor(1, 1, 1)
    end

    hover.texture:SetTexture(mouseTextures[C.hovertexture])
end

hover:SetWidth(C.width)
hover:SetHeight(C.height)
hover:SetFrameStrata("TOOLTIP")
hover:SetAlpha(1)

hover.texture = hover:CreateTexture(nil, "OVERLAY")
hover.texture:SetAllPoints(hover)
hover.texture:SetTexture(mouseTextures[C.hovertexture])


local function RandomColor()
    return math.random(), math.random(), math.random()
end

local rotation = 0
local ROTATE_SPEED = 2 * math.pi
local lastX, lastY = nil, nil
hover:SetScript("OnUpdate", function()
    local x, y = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    x = x / uiScale
    y = y / uiScale

    this:ClearAllPoints()
    this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

    if C.rotate == 1 then
        rotation = rotation + (arg1 or 0.01) * ROTATE_SPEED
        if rotation > 2 * math.pi then
            rotation = rotation - 2 * math.pi
        end

        local cos, sin = math.cos(rotation), math.sin(rotation)
        local w, h = 0.5, 0.5
        hover.texture:SetTexCoord(
            0.5 + cos * -w - sin * -h, 0.5 + sin * -w + cos * -h, -- UL
            0.5 + cos * w - sin * -h, 0.5 + sin * w + cos * -h, -- UR
            0.5 + cos * -w - sin * h, 0.5 + sin * -w + cos * h, -- LL
            0.5 + cos * w - sin * h, 0.5 + sin * w + cos * h  -- LR
        )
    end


    if not lastX or not lastY or lastX ~= x or lastY ~= y then
        local nextDot = nil
        for i = 1, maxTrails do
            if not trailPool[i]:IsShown() then
                nextDot = trailPool[i]
                break
            end
        end

        if nextDot then
            nextDot:ClearAllPoints()
            nextDot:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
            nextDot.spawnTime = GetTime()
            nextDot:SetAlpha(1)
            nextDot:Show()
            if C.rainbowtrail == 1 then
                local r, g, b = RandomColor()
                nextDot.texture:SetVertexColor(r, g, b)
            elseif C.customcolortrail == 1 then
                nextDot.texture:SetVertexColor(unpack(C.customtrailcolor))
            else
                nextDot.texture:SetVertexColor(0, 0.6, 0.6, 1)
            end
            table.insert(activeTrail, 1, nextDot)
        end
    end
    lastX, lastY = x, y

    local now = GetTime()
    local i = 1
    while i <= table.getn(activeTrail) do
        local dot = activeTrail[i]
        local elapsed = now - dot.spawnTime
        local alpha = 1 - (elapsed / FADE_DURATION)

        if alpha <= 0 then
            dot:Hide()
            table.remove(activeTrail, i)
        else
            dot:SetAlpha(alpha)
            local size = GetTrailSize(i)
            dot:SetWidth(size)
            dot:SetHeight(size)
            i = i + 1
        end
    end
end)

hover:RegisterEvent("PLAYER_ENTERING_WORLD")
hover:SetScript("OnEvent", function()
    UpdateDisplay()
    UpdateTrailPool()
end)
