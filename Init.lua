NosCursor = {}
NosCursor.updateFrame = CreateFrame("Frame", nil, UIParent)

local function rain(texture)
    local t = 0;
    local i = 0;
    local p = 0;
    local c = 128;
    local w = 127;
    local m = 180;
    local r, g, b;
    local hz = (math.pi * 2) / m

    NosCursor.updateFrame:Hide()

    NosCursor.updateFrame:SetScript("OnUpdate", function(_, elapsed)
        t = t + arg1
        if t > 0.1 then
            i = i + 1
            r = (math.sin((hz * i) + 0 + p) * w + c) / 255
            g = (math.sin((hz * i) + 2 + p) * w + c) / 255
            b = (math.sin((hz * i) + 4 + p) * w + c) / 255
            if i > m then
                i = i - m
            end
            texture:SetVertexColor(r, g, b)
            t = 0
        end
    end)

    NosCursor.updateFrame:Show()
end

local config = {
    width = 42,
    height = 42,
    rgb = 1,
}

local textures = {
    "Interface\\AddOns\\NosCursor\\Media\\Circle",
}

local hover = CreateFrame("Frame", "NosCursorFrame", UIParent)
local settings = CreateFrame("Frame")


NosCursor.config = config
NosCursor.settings = settings
NosCursor.textures = textures
NosCursor.hover = hover
NosCursor.rain = rain