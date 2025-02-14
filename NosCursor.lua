local config = NosCursor.config
local hover = NosCursor.hover
local rain = NosCursor.rain
local textures = NosCursor.textures

function NosCursor.UpdateDisplay()
    hover:SetWidth(config.width)
    hover:SetHeight(config.height)

    if config.rgb == 1 then
        rain(hover.texture)
    else
        NosCursor.updateFrame:Hide()
        NosCursor.updateFrame:SetScript("OnUpdate", nil)
        hover.texture:SetVertexColor(1, 1, 1)
    end
end

hover:SetWidth(config.width)
hover:SetHeight(config.height)
hover:SetFrameStrata("TOOLTIP")

-- Attach a texture to that frame
hover.texture = hover:CreateTexture(nil, "OVERLAY")
hover.texture:SetAllPoints(hover)
hover.texture:SetTexture(textures[1])

hover:SetScript("OnUpdate", function(self, elapsed)
    local x, y = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    x = x / uiScale
    y = y / uiScale

    this:ClearAllPoints()
    --this:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end)

hover:RegisterEvent("PLAYER_ENTERING_WORLD")
hover:SetScript("OnEvent", function()
    NosCursor.UpdateDisplay()
end)