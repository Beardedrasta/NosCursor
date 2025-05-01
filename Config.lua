local config = NosCursor.config
-- settings:RegisterEvent("PLAYER_ENTERING_WORLD")
-- settings:SetScript("OnEvent", function()
--     if NosCursorDB then
--         for var, data in pairs(NosCursorDB) do
--             config[var] = data
--         end
--     end

--     NosCursorDB = config
-- end)

SLASH_NOSCURSOR1, SLASH_NOSCURSOR2 = "/noscursor", "/nc"
SlashCmdList["NOSCURSOR"] = function(msg, editbox)
    local function display(msg)
        DEFAULT_CHAT_FRAME:AddMessage(msg)
    end

    if (msg == "" or msg == nil) then
        display("Nos |cff1a9fc0Cursor|r:")
        display("   /nc config |cffcccccc - Open the new NosCursor Config Options")
        return
    end

    local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

    if strlower(cmd) == "config" then
        if NosCursor.settings:IsShown() then
            NosCursor.settings:Hide()
        else
            NosCursor.settings:Show()
        end
    end
end

setfenv(1, NosCursor:GetEnvironment())

local max_height = 800
local settings = CreateFrame("Frame", "NosCursorConfig", UIParent) --NosCursor.settings
settings:Hide()
NosCursor.settings = settings

table.insert(UISpecialFrames, "NosCursorConfig")
settings:SetScript("OnHide", function()
    UpdateDisplay()
end)

settings:SetPoint("CENTER", UIParent, "CENTER", -200, 32)
settings:SetWidth(260)
settings:SetHeight(max_height)
settings:SetMovable(true)
settings:EnableMouse(true)
settings:RegisterForDrag("LeftButton")
settings:SetScript("OnDragStart", function() this:StartMoving() end)
settings:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
settings:SetFrameStrata("DIALOG")

settings:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
settings:SetBackdropColor(0.25, 0.25, 0.25, 1)

settings.container = CreateFrame("Frame", "NosCursorConfigContainer", settings)

settings.title = CreateFrame("Frame", "NosCursorConfigContainerTitle", settings)
settings.title:SetPoint("TOP", settings, "TOP", 0, -5)
settings.title:SetWidth(settings:GetWidth() - 9)
settings.title:SetHeight(20)

settings.title.tex = settings.title:CreateTexture(nil, "LOW")
settings.title.tex:SetTexture("Interface\\Tooltips\\UI-Tooltip-Background")
settings.title.tex:SetVertexColor(0, 0, 0, 1)
settings.title.tex:SetAllPoints()

settings.title.text = settings.title:CreateFontString(nil, "HIGH", "GameFontNormal")
settings.title.text:SetText(L["config"]["title"])
settings.title.text:SetPoint("CENTER", 0, 0)

settings.close = CreateFrame("Button", nil, settings)
SetSize(settings.close, 16, 16)
settings.close:SetPoint("RIGHT", settings.title, "RIGHT", -4, 0)
settings.close:SetFrameLevel(settings.title:GetFrameLevel() + 3)

settings.close:SetNormalTexture("Interface\\AddOns\\NosCursor\\Media\\close")
settings.close:SetHighlightTexture("Interface\\Tooltips\\UI-Tooltip-Background")
settings.close:GetHighlightTexture():SetVertexColor(1, 0, 0, 1)
settings.close:SetScript("OnClick", function()
    settings:Hide()
end)

local function RecalculateContainerHeight()
    local totalHeight = 20 -- start with some top spacing

    for _, frame in pairs(settings.category) do
        if frame:IsShown() then
            totalHeight = totalHeight + frame:GetHeight() + 22 -- 22 = spacing between categories
        end
    end

    settings.container:SetHeight(totalHeight)

    if totalHeight + 60 < max_height then
        settings:SetHeight(totalHeight + 60)
    else
        settings:SetHeight(totalHeight + 60)
    end
end

settings.Load = function(self)
    if settings.category then
        for _, frame in pairs(settings.category) do
            if frame.button then frame.button:Hide() frame.button:SetParent(nil) end
            if frame.title then frame.title:Hide() frame.title:SetParent(nil) end
            frame:Hide()
            frame:SetParent(nil)
        end
    end
    settings.category = {}
    --DEFAULT_CHAT_FRAME:AddMessage("Settings Loaded")
    max_height = math.min(UIParent:GetHeight() / UIParent:GetScale() * 0.75, 400)
    settings:SetHeight(max_height)
    --settings.container:SetHeight(max_height - 20)

    settings.container:SetWidth(settings:GetWidth() - 20)
    settings.container:SetHeight(max_height - 60)
    settings.container:ClearAllPoints()
    settings.container:SetPoint("TOP", settings, "TOP", 0, -40)
    settings.container:Show()

    settings.variables = settings.variables or {}

    local topspace = 20
    local required_height = topspace
    local entrysize = 22
    local previous = nil

    local gui = {
        ["Mouse Tracker"] = {
            { type = "toggle", key = "rotate",       label = "Rotate",        tooltip = "Enable Rotation on the mouse tracker\nReload to reset texture position" },
            { type = "toggle", key = "rgb",          label = "RGB",           tooltip = "Enable RGB coloration on the mouse tracker" },
            { type = "toggle", key = "customcolor",  label = "Custom Color",  tooltip = "Enable custom coloration on the mouse tracker" },
            { type = "color",  key = "mousecolor",   label = "Color Select",  tooltip = "Set mouse tracker custom color" },
            { type = "select", key = "width",        label = "Width",         min = 8,                                                                           max = 64,                        tooltip = "Set the Width of the mouse tracker" },
            { type = "select", key = "height",       label = "Height",        min = 8,                                                                           max = 64,                        tooltip = "Set the Width of the mouse tracker" },
            { type = "select", key = "hovertexture", label = "Hover Texture", values = NosCursor.textures,                                                       tooltip = "Select hover texture" },
        },
        ["Trail"] = {
            { type = "toggle", key = "rainbowtrail",     label = "Rainbow",      tooltip = "Enable rainbow coloration on the trail" },
            { type = "toggle", key = "customcolortrail", label = "Custom Color", tooltip = "Enable custom coloration on the trail" },
            { type = "color",  key = "customtrailcolor", label = "Color Select", tooltip = "Set trail custom color" },
            { type = "select", key = "maxtrails",        label = "Length",       min = 10,                                          max = 100, tooltip = "Set the length of the trail" },
            { type = "select", key = "maxtrailsize",        label = "Max Size",       min = 20,                                          max = 40, tooltip = "Set the size of the beggning of the trial (Large end)" },
            { type = "select", key = "mintrailsize",        label = "Min Size",       min = 1,                                          max = 20, tooltip = "Set the size of the end of the trial (Small end)" },
            { type = "select", key = "dottexture", label = "Hover Texture", values = NosCursor.trailtextures,                                                       tooltip = "Select trail texture" },
        },
    }

    for cat, entries in pairs(gui) do
        settings.category = settings.category or {}
        local entry, spacing = 1, 22
        local height = 0

        local frame = settings.category[cat] or CreateFrame("Frame", nil, settings.container)
        settings.category[cat] = frame
        frame:SetWidth(settings:GetWidth() - 20)
        frame:SetHeight(table.getn(entries) * 22 + 30)

        if not previous then
            frame:SetPoint("TOPLEFT", settings.container, "TOPLEFT", spacing, -spacing - topspace)
            frame:SetPoint("TOPRIGHT", settings.container, "TOPRIGHT", -spacing, -spacing - topspace)
        else
            frame:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -spacing)
            frame:SetPoint("TOPRIGHT", previous, "BOTTOMRIGHT", 0, -spacing)
        end

        previous = frame

        local minimize = function(anchor, maximize)
            local parent = anchor or this.parent

            if maximize then
                local height = parent.minimize or parent:GetHeight()
                parent.minimize = height
            end

            if not parent.minimize then
                local height = parent:GetHeight()
                parent.minimize = height
                parent:SetHeight(1)

                for button in pairs(parent.buttons) do
                    button:Hide()
                end

                parent.button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
                parent.button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
                parent.button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
                parent.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                parent:SetAlpha(0)

                RecalculateContainerHeight()
            else
                local height = parent.minimize
                parent.minimize = nil
                parent:SetHeight(height)

                for button in pairs(parent.buttons) do button:Show() end
                parent.button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
                parent.button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
                parent.button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled")
                parent.button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                parent:SetAlpha(1)

                RecalculateContainerHeight()
            end
        end

        frame.button = frame.button or CreateFrame("Button", nil, settings.container)
        frame.button:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, entrysize - 4)
        frame.button:SetWidth(22)
        frame.button:SetHeight(22)
        frame.button.parent = frame
        frame.button:SetScript("OnClick", minimize)


        frame.title = frame.title or
            CreateFrame("Button", nil, settings.container)
        frame.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, entrysize - 4)
        frame.title:SetWidth(200)
        frame.title:SetHeight(entrysize)
        frame.title.parent = frame
        frame.title:SetScript("OnClick", minimize)

        frame:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 8,
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })

        frame:SetBackdropColor(.1, .1, .1, 1)
        frame:SetBackdropBorderColor(.2, .2, .2, 1)

        frame.text = frame.text or
            frame.title:CreateFontString(nil, "HIGH", "GameFontHighlightSmall")
        frame.text:SetJustifyH("LEFT")
        frame.text:SetAllPoints()
        frame.text:SetText(cat)

        frame.buttons = frame.buttons or {}
        frame.buttonsByKey = frame.buttonsByKey or {}
        for i, opt in ipairs(entries) do
            if opt.type == "toggle" then
                local btn = CreateFrame("CheckButton", "NosCursorConfig" .. i, frame, "OptionsCheckButtonTemplate")
                --btn:SetPoint("TOPLEFT", frame, "TOPLEFT", mod(entry, 2) == 1 and 17 or 17 + 200, math.ceil(entry / 2 - 1) * -entrysize - spacing / 2) -- TWO row system
                btn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -17, -(i * entrysize) + 11) -- ONE row system
                btn:SetHeight(24)
                btn:SetWidth(24)
                btn:SetChecked(config[opt.key] == 1 and true or nil)


                --frame.buttons[btn] = true
                frame.buttons[btn] = true
                frame.buttonsByKey[opt.key] = btn

                btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                btn.label:SetText(opt.label)
                btn.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -(i * entrysize) + 4)

                if config["rgb"] == 1 and frame.buttonsByKey["customcolor"] then
                    --frame.buttonsByKey["customcolor"]:Disable()
                end
                if config["customcolor"] == 1 and frame.buttonsByKey["rgb"] then
                    --frame.buttonsByKey["rgb"]:Disable()
                end


                -- if mod(entry, 2) == 1 then
                --     height = height + entrysize  -- TWO row system
                -- end

                height = height + entrysize

                local title = opt.label
                local description = opt.tooltip
                btn:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(title, nil, nil, nil, nil, true)
                    GameTooltip:AddLine(description, 1, 1, 1, 1)
                    GameTooltip:Show()
                end)

                btn:SetScript("OnHide", function()
                    GameTooltip:Hide()
                end)

                local key = opt.key
                btn:SetScript("OnClick", function()
                    local checked = btn:GetChecked()
                    config[key] = checked and 1 or 0
                    NosCursorDB[key] = config[key]

                    if key == "rgb" then
                        local other = frame.buttonsByKey["customcolor"]
                        if other then
                            if checked then
                                DisableButton(other)
                            else
                                EnableButton(other)
                            end
                        end
                    elseif key == "customcolor" then
                        local other = frame.buttonsByKey["rgb"]
                        if other then
                            if checked then
                                DisableButton(other)
                            else
                                EnableButton(other)
                            end
                        end
                    end

                    UpdateDisplay()
                end)

                entry = entry + 1
            elseif opt.type == "color" then
                local colorButton = CreateFrame("Button", "NosCursorColorPicker" .. i, frame)
                colorButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -(i * entrysize) + 9)
                SetSize(colorButton, 17, 17)

                colorButton.backdrop = CreateFrame("Frame", nil, colorButton)
                colorButton.backdrop:SetAllPoints()
                colorButton.backdrop:SetBackdrop({
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    edgeSize = 9,
                    insets = { left = 3, right = 3, top = 3, bottom = 3 }
                })

                frame.buttons[colorButton] = true
                frame.buttonsByKey[opt.key] = colorButton

                colorButton.texture = colorButton:CreateTexture(nil, "OVERLAY")
                colorButton.texture:SetPoint("TOPLEFT", colorButton, 2, -3)
                colorButton.texture:SetPoint("BOTTOMRIGHT", colorButton, -2, 3)
                colorButton.texture:SetTexture(unpack(config[opt.key] or { 1, 1, 1, 1 }))

                colorButton.label = colorButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                colorButton.label:SetText(opt.label)
                colorButton.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -(i * entrysize) + 4)

                height = height + entrysize + 5

                local key = opt.key
                local function OpenColorPicker()
                    local color = config[key]
                    if type(color) ~= "table" then
                        color = { 1, 1, 1 } -- default white
                    end
                    local r, g, b = unpack(color)

                    ColorPickerFrame.func = function()
                        local newR, newG, newB = ColorPickerFrame:GetColorRGB()
                        config[key] = { newR, newG, newB }
                        NosCursorDB[key] = config[key]
                        colorButton.texture:SetTexture(newR, newG, newB)
                        UpdateDisplay()
                    end

                    ColorPickerFrame.cancelFunc = function()
                        -- If you want to do something when canceled (optional)
                    end

                    ColorPickerFrame:SetColorRGB(r, g, b)
                    ColorPickerFrame:Hide() -- You must hide before showing again
                    ColorPickerFrame:Show()
                end

                colorButton:SetScript("OnClick", OpenColorPicker)

                local title = opt.label
                local description = opt.tooltip
                colorButton:SetScript("OnEnter", function()
                    GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                    GameTooltip:SetText(title, nil, nil, nil, nil, true)
                    GameTooltip:AddLine(description, 1, 1, 1, 1)
                    GameTooltip:Show()
                end)

                colorButton:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                end)

                entry = entry + 1
            elseif opt.type == "select" then
                local input = CreateFrame("Frame", nil, frame)
                input:SetHeight(24)
                input:SetWidth(opt.values and 112 or 54)
                input:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -17, -(i * entrysize) + 11)
                input:SetBackdrop({
                    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true,
                    tileSize = 8,
                    edgeSize = 16,
                    insets = { left = 3, right = 3, top = 3, bottom = 3 }
                })
                input:SetBackdropColor(.2, .2, .2, 1)
                input:SetBackdropBorderColor(.4, .4, .4, 1)

                input.key = opt.key
                input.min = opt.min
                input.max = opt.max
                input.values = opt.values

                input.preview = CreateFrame("Frame", nil, frame)
                input.preview:SetHeight(20)
                input.preview:SetWidth(20)
                input.preview:SetPoint("RIGHT", input, "LEFT", -24, 0)

                input.preview.texture = input.preview:CreateTexture(nil, "ARTWORK")
                input.preview.texture:SetAllPoints(input.preview)
                input.preview.texture:SetTexture("") -- empty at start
                input.preview:Hide()

                input.caption = input:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                input.caption:SetPoint("CENTER", input, "CENTER", 0, 0)

                input.label = input:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                input.label:SetText(opt.min and opt.label or "")
                input.label:SetPoint("TOPLEFT", frame, "TOPLEFT", 17, -(i * entrysize) + 4)

                local function UpdateInput()
                    local value = config[input.key]

                    if input.values then
                        -- texture picker
                        local texturePath = input.values[value]
                        if texturePath then
                            input.preview.texture:SetTexture(texturePath)
                            input.preview:Show()
                            local name
                            local s, e = string.find(texturePath, "Media\\")
                            if s then
                                name = string.sub(texturePath, e + 1)
                            else
                                name = "Unknown"
                            end
                            input.caption:SetText(name)
                        else
                            input.preview:Hide()
                            input.caption:SetText("None")
                        end
                    else
                        -- number picker
                        input.caption:SetText(value)
                        input.preview:Hide()
                    end
                end

                input.left = CreateFrame("Button", nil, input)
                input.left:SetPoint("LEFT", input, "LEFT", 1, 0)
                input.left:SetWidth(18)
                input.left:SetHeight(18)
                input.left:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
                input.left:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
                input.left:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                input.left:SetScript("OnClick", function()
                    local value = config[input.key] or (input.min or 1)

                    if input.values then
                        value = value - 1
                        if value < 1 then
                            value = table.getn(input.values)
                        end
                    elseif input.min and input.max then
                        value = value - 1
                        if value < input.min then
                            value = input.max
                        end
                    end
                    config[input.key] = value
                    NosCursorDB[input.key] = value
                    UpdateInput()
                    UpdateDisplay()
                    if input.key == "maxtrails" then
                        UpdateTrailPool()
                    end
                end)

                input.right = CreateFrame("Button", nil, input)
                input.right:SetPoint("RIGHT", input, "RIGHT", -1, 0)
                input.right:SetWidth(18)
                input.right:SetHeight(18)
                input.right:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
                input.right:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
                input.right:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
                input.right:SetScript("OnClick", function()
                    local value = config[input.key] or (input.min or 1)
                    if input.values then
                        value = value + 1
                        if value > table.getn(input.values) then
                            value = 1
                        end
                    elseif input.min and input.max then
                        value = value + 1
                        if value > input.max then
                            value = input.min
                        end
                    end

                    config[input.key] = value
                    NosCursorDB[input.key] = value
                    UpdateInput()
                    UpdateDisplay()
                    if input.key == "maxtrails" or input.key == "dottexture" then
                        UpdateTrailPool()
                    end
                end)

                UpdateInput()

                frame.buttons[input] = true
                frame.buttonsByKey[opt.key] = input

                height = height + entrysize
            end
        end

        minimize(frame, true)

        height = height + spacing
        frame:SetHeight(height)
        required_height = required_height + height + spacing
    end


    settings.container:SetHeight(required_height)

    if required_height < max_height then
        settings:SetHeight(required_height + 50)
        settings.container:SetParent(settings)
        settings.container:ClearAllPoints()
        settings.container:SetPoint("CENTER", settings, 0, 20)
        settings.container:SetWidth(260 - 20)
    elseif required_height > max_height then
        settings:SetHeight(required_height + 50)
        settings.container:SetParent(settings)
        settings.container:ClearAllPoints()
        settings.container:SetPoint("CENTER", settings, 0, 20)
        settings.container:SetWidth(260 - 20)
    end
end

function DisableButton(button)
    button:Disable()
    button:GetNormalTexture():SetDesaturated(true)
    button:GetPushedTexture():SetDesaturated(true)
    button:GetHighlightTexture():SetAlpha(0) -- Hide highlight glow
end

function EnableButton(button)
    button:Enable()
    button:GetNormalTexture():SetDesaturated(false)
    button:GetPushedTexture():SetDesaturated(false)
    button:GetHighlightTexture():SetAlpha(1) -- Restore highlight glow
end

settings:SetScript("OnShow", function()
    for k, v in pairs(NosCursorDB) do
        config[k] = v
    end

    settings:Load()
end)

settings:RegisterEvent("PLAYER_ENTERING_WORLD")
settings:SetScript("OnEvent", function()
    settings:Load()
end)
