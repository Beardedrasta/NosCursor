NosCursor = CreateFrame("Frame", "NosCursorFrame", UIParent)

NosCursor:SetWidth(42)
NosCursor:SetHeight(42)
NosCursor:SetFrameStrata("TOOLTIP")

local Texture = NosCursor:CreateTexture(nil, "OVERLAY")
Texture:SetAllPoints(NosCursor)
Texture:SetTexture("Interface\\AddOns\\NosCursor\\Media\\Circle")

NosCursor:SetScript("OnUpdate", function(self, elapsed)
    local x, y = GetCursorPosition()
    local uiScale = UIParent:GetEffectiveScale()
    x = x / uiScale
    y = y / uiScale

    this:ClearAllPoints()
    --this:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
    this:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)
end)