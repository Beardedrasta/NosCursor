local config = NosCursor.config
local settings = NosCursor.settings


settings:RegisterEvent("PLAYER_ENTERING_WORLD")
settings:SetScript("OnEvent", function()
    if NosCursorDB then
        for var, data in pairs(NosCursorDB) do
            config[var] = data
        end
    end

    NosCursorDB = config
end)

SLASH_NOSCURSOR1, SLASH_NOSCURSOR2 = "/noscursor", "nc"
SlashCmdList["NOSCURSOR"] = function(msg, editbox)

    local function display(msg)
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end

    if (msg == "" or msg == nil) then
        display("Nos |cff1a9fc0Cursor|r:")
        display("   /nc width |cffcccccc - Icon Width")
        display("   /nc height |cffcccccc - Icon Height")
        display("   /nc rgb <value> |cffcccccc - Enabled RGB animation (true) Enabled (false) Disabled")
        return
    end

    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if strlower(cmd) == "width" then
        if tonumber(args) then
            config.width = tonumber(args)
            NosCursorDB = config
            NosCursor.UpdateDisplay()
            display("Nos |cff1a9fc0Cursor|r: |cffffddcc Width: " .. config.width)
        end
    elseif strlower(cmd) == "height" then
        if tonumber(args) then
            config.height = tonumber(args)
            NosCursorDB = config
            NosCursor.UpdateDisplay()
            display("Nos |cff1a9fc0Cursor|r: |cffffddcc Width: " .. config.height)
        end
    elseif strlower(cmd) == "rgb" then
        config.rgb = config.rgb == 1 and 0 or 1
        NosCursorDB = config
        NosCursor.UpdateDisplay()
        display("Nos |cff1a9fc0Cursor|r: |cffffddcc Rgb: " .. config.rgb)
    end
end
