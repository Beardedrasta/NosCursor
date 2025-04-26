NosCursor = CreateFrame("Frame", nil, UIParent)
NosCursor:RegisterEvent("ADDON_LOADED")

NosCursor.hover = CreateFrame("Frame", "NosCursorFrame", UIParent)
--NosCursor.settings = CreateFrame("Frame", "NosCursorConfig", UIParent)
NosCursor.modules = {}
NosCursor.api = {}
NosCursor.env = {}
NosCursor.config = {
    --Mouse Tracker
    rotate = 0,
    rgb = 0,
    customcolor = 1,
    mousecolor = { 0, 0.6, 1, 1 },
    hovertexture = 9,
    width = 20,
    height = 20,
    --Trail
    rainbowtrail = 0,
    customcolortrail = 1,
    customtrailcolor = { 0, 0.6, 1, 1 },
    maxtrails = 50,
    maxtrailsize = 30,
    mintrailsize = 1,
    dottexture = 8,
}
NosCursor.textures = {
    "Interface\\AddOns\\NosCursor\\Media\\Circle",
    "Interface\\AddOns\\NosCursor\\Media\\CircleFull",
    "Interface\\AddOns\\NosCursor\\Media\\Star 1",
    "Interface\\AddOns\\NosCursor\\Media\\Swirl",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 1",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 2",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 3",
    "Interface\\AddOns\\NosCursor\\Media\\Glow 1",
    "Interface\\AddOns\\NosCursor\\Media\\Glow Reversed",
    "Interface\\AddOns\\NosCursor\\Media\\Glow",
    "Interface\\AddOns\\NosCursor\\Media\\Ring 1",
    "Interface\\AddOns\\NosCursor\\Media\\Ring 2",
    "Interface\\AddOns\\NosCursor\\Media\\Ring 3",
    "Interface\\AddOns\\NosCursor\\Media\\Ring 4",
    "Interface\\AddOns\\NosCursor\\Media\\Ring Soft 1",
    "Interface\\AddOns\\NosCursor\\Media\\Ring Soft 2",
    "Interface\\AddOns\\NosCursor\\Media\\Ring Soft 3",
    "Interface\\AddOns\\NosCursor\\Media\\Ring Soft 4",
    "Interface\\AddOns\\NosCursor\\Media\\Sphere Edge 2",
}

NosCursor.trailtextures = {
    "Interface\\AddOns\\NosCursor\\Media\\CircleCluster",
    "Interface\\AddOns\\NosCursor\\Media\\Star 1",
    "Interface\\AddOns\\NosCursor\\Media\\Swirl",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 1",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 2",
    "Interface\\AddOns\\NosCursor\\Media\\Cross 3",
    "Interface\\AddOns\\NosCursor\\Media\\Glow 1",
    "Interface\\AddOns\\NosCursor\\Media\\Glow",
}

NosCursor.L = NosCursor_Locale[GetLocale()] or NosCursor_Locale["enUS"]


NosCursor:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "NosCursor" then
        if not NosCursorDB then NosCursorDB = {} end
        if NosCursorDB then
            for var, data in pairs(NosCursorDB) do
                NosCursor.config[var] = data
            end
        end

        NosCursorDB = NosCursor.config
        this:UnregisterEvent("ADDON_LOADED")
        --NosCursor:Initialize()
    end
end)

NosCursor.updateFrame = CreateFrame("Frame", nil, UIParent)

function NosCursor:GetEnvironment()
    for name, func in pairs(NosCursor.api) do
        self.env[name] = func
    end

    local _G = getfenv(0)
    self.env._G = _G
    self.env.C = self.config
    self.env.L = self.L
    self.env.NosCursor = self

    setmetatable(self.env, { __index = _G })
    return self.env
end
