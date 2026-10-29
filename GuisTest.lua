function createInfoGui(config)
    config = config or {}

    local TweenService     = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui          = game:GetService("CoreGui")
    local TextService      = game:GetService("TextService")
    local HttpService      = game:GetService("HttpService")

    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then return tbl[key] end
        end
        return nil
    end

    -- ========= CustomWindow =========
    local cw = pick(config, "CustomWindow", "customWindow") or {}

    local bg            = pick(cw, "Background", "background") or {}
    local topbar        = pick(cw, "Topbar", "topbar") or {}
    local topbarLine    = pick(cw, "TopbarLine", "topbarLine") or {}
    local titleCfg      = pick(cw, "Title", "title") or {}
    local borderCfg     = pick(cw, "Border", "border") or {}
    local cornerCfg     = pick(cw, "Corner", "corner") or {}
    local shadowCfg     = pick(cw, "Shadow", "shadow") or {}
    local lineToggleCfg = pick(cw, "LineToggle", "lineToggle") or {}
    local scrollbarCfg  = pick(cw, "Scrollbar", "scrollbar") or {}
    local lineTextCfg   = pick(cw, "LineText", "lineText") or {}
    local fontCfg       = pick(cw, "Font", "font") or {}

    -- ========= Основные =========
    local guiName   = pick(config, "Name", "name") or "CustomWindow"
    local title     = pick(config, "Title", "title") or "Window"
    local width     = pick(config, "Width", "width") or 200
    local scale     = pick(config, "Scale", "scale") or 1
    local position  = pick(config, "Position", "position") or UDim2.new(0.05, 0, 0.15, 0)
    local textSize  = pick(config, "TextSize", "textSize") or 14

    local reload    = pick(config, "Reload", "reload")
    if reload == nil then reload = true end

    -- ========= Настройки авто-размера =========
    local autoSizeCfg        = pick(config, "AutoSize", "autoSize") or {}
    local autoSizeEnabled    = pick(autoSizeCfg, "Enabled", "enabled")
    if autoSizeEnabled == nil then autoSizeEnabled = true end
    local autoSizeMaxSize    = pick(autoSizeCfg, "MaxSize", "maxSize") or 500
    local autoSizeWindowEdge = pick(autoSizeCfg, "WindowEdge", "windowEdge")
    if autoSizeWindowEdge == nil then autoSizeWindowEdge = false end
    local autoSizeWindowEdgeWithMaxSize = pick(autoSizeCfg, "WindowEdgeWithMaxSize", "windowEdgeWithMaxSize")
    if autoSizeWindowEdgeWithMaxSize == nil then autoSizeWindowEdgeWithMaxSize = false end
    
    local autoSizeSide       = pick(autoSizeCfg, "side", "Side") or "down"

    -- ========= Сохранение позиции =========
    local savePosCfg = pick(config, "SavePos", "savePos") or {}
    local savePosEnabled = pick(savePosCfg, "enabled", "Enabled") == true
    local savePosId = pick(savePosCfg, "id", "Id", "ID")
    local saveFileName = "FinaleleleGuiPositions.json"
    local saveData = {}

    local function loadSaveData()
        if not savePosId then return end
        if isfile and readfile and isfile(saveFileName) then
            local success, result = pcall(function()
                return HttpService:JSONDecode(readfile(saveFileName))
            end)
            if success and type(result) == "table" then
                saveData = result
            end
        end
    end

    local function saveDataToFile()
        if not savePosId then return end
        if writefile then
            pcall(function()
                writefile(saveFileName, HttpService:JSONEncode(saveData))
            end)
        end
    end

    loadSaveData()
    if savePosEnabled and savePosId and saveData[savePosId] then
        local pos = saveData[savePosId]
        if type(pos) == "table" and pos.XScale then
            position = UDim2.new(pos.XScale, pos.XOffset, pos.YScale, pos.YOffset)
        end
    end

    local headerHeight  = 32
    local bottomPadding = 3
    local linePadding   = 2
    local EDGE_MARGIN   = 12

    local tweenTime     = pick(config, "TweenTime", "tweenTime") or 0.22
    local tweenInfo     = TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local lineFadeInfo  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, old in ipairs(CoreGui:GetChildren()) do
        if old.Name == guiName and old:IsA("ScreenGui") then
            if old:GetAttribute("Reload") == true then
                old:Destroy()
            end
        end
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen:SetAttribute("Reload", reload)
    screen.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, width, 0, headerHeight)
    frame.Position = position
    frame.BackgroundColor3 = pick(bg, "color", "Color") or Color3.fromRGB(30, 30, 35)
    frame.BackgroundTransparency = pick(bg, "transparency", "Transparency") or 0
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = screen

    -- Настройка AnchorPoint с сохранением визуального Top-Left
    if autoSizeSide == "up" then
        frame.AnchorPoint = Vector2.new(0, 1)
        frame.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + headerHeight)
    elseif autoSizeSide == "left" then
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.Position = UDim2.new(position.X.Scale, position.X.Offset + width, position.Y.Scale, position.Y.Offset)
    else
        frame.AnchorPoint = Vector2.new(0, 0)
        frame.Position = position
    end

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, pick(cornerCfg, "radius", "Radius") or 8)
    corner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Name = "Border"
    frameStroke.Color = pick(borderCfg, "color", "Color") or Color3.fromRGB(65, 65, 75)
    frameStroke.Thickness = pick(borderCfg, "thickness", "Thickness") or 1
    frameStroke.Transparency = pick(borderCfg, "transparency", "Transparency") or 0.15
    frameStroke.Parent = frame

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = scale
    uiScale.Parent = frame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.BackgroundColor3 = pick(shadowCfg, "color", "Color") or Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = pick(shadowCfg, "transparency", "Transparency") or 0.65
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, (pick(cornerCfg, "radius", "Radius") or 8) + 1)
    shadowCorner.Parent = shadow

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.BackgroundColor3 = pick(topbar, "color", "Color") or Color3.fromRGB(35, 35, 42)
    header.BackgroundTransparency = pick(topbar, "transparency", "Transparency") or 0
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 2
    header.Parent = frame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, pick(cornerCfg, "radius", "Radius") or 8)
    headerCorner.Parent = header

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Position = UDim2.new(0, 7, 0.5, -7)
    accent.Size = UDim2.fromOffset(3, 14)
    accent.BackgroundColor3 = pick(topbarLine, "color", "Color") or Color3.fromRGB(90, 145, 255)
    accent.BorderSizePixel = 0
    accent.ZIndex = 3
    accent.Parent = header

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Position = UDim2.new(0, 17, 0, 0)
    titleLabel.Size = UDim2.new(1, -51, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = pick(titleCfg, "color", "Color") or Color3.fromRGB(245, 245, 248)
    titleLabel.Font = pick(fontCfg, "title", "Title") or Enum.Font.GothamSemibold
    titleLabel.TextSize = textSize + 2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 3
    titleLabel.Parent = header

    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position = UDim2.new(1, -7, 0.5, 0)
    toggle.Size = UDim2.fromOffset(24, 24)
    toggle.BackgroundColor3 = pick(lineToggleCfg, "color", "Color") or Color3.fromRGB(48, 48, 58)
    toggle.BackgroundTransparency = 0.15
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = "⌃"
    toggle.TextColor3 = pick(lineToggleCfg, "textColor", "TextColor") or Color3.fromRGB(210, 210, 220)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 15
    toggle.ZIndex = 4
    toggle.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle

    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "Container"
    scrolling.Position = UDim2.new(0, 0, 0, headerHeight)
    scrolling.Size = UDim2.new(1, 0, 1, -headerHeight)
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.ScrollBarThickness = 0
    scrolling.ScrollBarImageColor3 = pick(scrollbarCfg, "color", "Color") or pick(topbarLine, "color", "Color") or Color3.fromRGB(90, 145, 255)
    scrolling.ScrollBarImageTransparency = 0.3
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
    scrolling.ElasticBehavior = Enum.ElasticBehavior.Never
    scrolling.Parent = frame

    if Enum.AutomaticSize then
        scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
    end

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, linePadding)
    layout.Parent = scrolling

    local labels, lineData = {}, {}
    local creationCounter = 0
    local collapsed = pick(config, "Collapsed", "collapsed") == true
    local activeTween
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function getScale() local s = uiScale.Scale return (s and s > 0) and s or 1 end
    local function getContentHeightLogical() return layout.AbsoluteContentSize.Y / getScale() end

    local function getEffectiveMaxHeightLogical()
        if autoSizeWindowEdge then
            local screenH = screen.AbsoluteSize.Y
            local yPos    = frame.AbsolutePosition.Y
            local edgeAvailable = (screenH - yPos - EDGE_MARGIN) / getScale()
            edgeAvailable = math.max(edgeAvailable, headerHeight)
            if autoSizeWindowEdgeWithMaxSize then
                return math.min(autoSizeMaxSize, edgeAvailable)
            else
                return edgeAvailable
            end
        else
            return autoSizeMaxSize
        end
    end

    local function isEdgeMode() return autoSizeWindowEdge end

    -- Вычисление ширины текста для режимов left/right
    local function getMaxTextWidth()
        local maxW = 0
        for _, ui in pairs(labels) do
            local text = ui.text.Text
            if text == "" then text = " " end
            local tSize = TextService:GetTextSize(text, textSize, ui.text.Font, Vector2.new(10000, 10000))
            local extra = 0
            local saved = lineData[ui.frame.Name]
            if saved and saved.toggle then extra = 34 end
            maxW = math.max(maxW, tSize.X + extra)
        end
        return maxW + 20 -- +20 на отступы
    end

    local function updateFrameSize(animate)
        local targetHeight = headerHeight
        local targetWidth = width

        if not collapsed then
            local contentH = getContentHeightLogical()
            local desired  = headerHeight + contentH + bottomPadding
            if autoSizeEnabled then
                targetHeight = math.min(desired, getEffectiveMaxHeightLogical())
            else
                targetHeight = autoSizeMaxSize
            end

            -- Расширение по горизонтали
            if autoSizeSide == "left" or autoSizeSide == "right" then
                targetWidth = math.max(width, getMaxTextWidth())
            end
        end

        if not collapsed then
            local contentH   = getContentHeightLogical()
            local availableH = targetHeight - headerHeight
            scrolling.ScrollBarThickness = (contentH > availableH + 1) and 4 or 0
        else
            scrolling.ScrollBarThickness = 0
        end

        if activeTween then activeTween:Cancel() activeTween = nil end
        local targetSize = UDim2.new(0, targetWidth, 0, targetHeight)
        
        if animate and not (isEdgeMode() and dragging) then
            activeTween = TweenService:Create(frame, tweenInfo, { Size = targetSize })
            activeTween:Play()
        else
            frame.Size = targetSize
        end
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not collapsed then updateFrameSize(true) end
    end)

    screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isEdgeMode() and not collapsed then updateFrameSize(false) end
    end)

    local function setContentTransparency(transparency, instant)
        for _, ui in pairs(labels) do
            if instant then ui.text.TextTransparency = transparency
            else TweenService:Create(ui.text, tweenInfo, { TextTransparency = transparency }):Play() end
            local stroke = ui.text:FindFirstChild("Outline")
            if stroke then
                if instant then stroke.Transparency = transparency
                else TweenService:Create(stroke, tweenInfo, { Transparency = transparency }):Play() end
            end
        end
    end

    local function applyOutline(label, data)
        local stroke = label:FindFirstChild("Outline")
        if data.outlineSize then
            if not stroke then
                stroke = Instance.new("UIStroke")
                stroke.Name = "Outline"
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                stroke.Parent = label
            end
            stroke.Color = data.outlineColor or Color3.fromRGB(255, 255, 255)
            stroke.Thickness = data.outlineSize
            stroke.Transparency = collapsed and 1 or 0
        elseif stroke then
            stroke:Destroy()
        end
    end

    local function updateOrder()
        local explicit, withoutOrder = {}, {}
        for _, data in pairs(lineData) do
            if data.order ~= nil then table.insert(explicit, data) else table.insert(withoutOrder, data) end
        end
        table.sort(explicit, function(a, b) if a.order == b.order then return a.created < b.created end return a.order < b.order end)
        table.sort(withoutOrder, function(a, b) return a.created < b.created end)

        local used = {}
        for _, data in ipairs(explicit) do
            local order = math.max(1, math.floor(data.order))
            while used[order] do order = order + 1 end
            used[order] = true
            labels[data.id].frame.LayoutOrder = order
        end
        local current = 1
        for _, data in ipairs(withoutOrder) do
            while used[current] do current = current + 1 end
            used[current] = true
            labels[data.id].frame.LayoutOrder = current
            current = current + 1
        end
    end

    local renderLine
    renderLine = function(id)
        local ui = labels[id]
        local saved = lineData[id]
        if not ui or not saved then return end

        ui.text.Text = saved.text.text or ""
        ui.text.TextColor3 = saved.text.color or pick(lineTextCfg, "color", "Color") or Color3.fromRGB(255, 255, 255)
        
        if saved.text.font then
            ui.text.Font = saved.text.font
        else
            ui.text.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
        end

        applyOutline(ui.text, saved.text)

        if saved.toggle then
            ui.track.Visible = true
            local isLeft = (saved.toggle.side == "left")
            if isLeft then
                ui.track.Position = UDim2.new(0, 0, 0.5, -7)
                ui.text.Position = UDim2.new(0, 34, 0, 0)
                ui.text.Size = UDim2.new(1, -34, 0, 0)
            else
                ui.track.Position = UDim2.new(1, -28, 0.5, -7)
                ui.text.Position = UDim2.new(0, 0, 0, 0)
                ui.text.Size = UDim2.new(1, -34, 0, 0)
            end

            local isActive = saved.toggle.value == true
            local trackStroke = ui.track:FindFirstChildOfClass("UIStroke")

            if isActive then
                ui.track.BackgroundColor3 = saved.toggle.enabledColor or saved.toggle.color or Color3.fromRGB(70, 130, 180)
                if trackStroke then trackStroke.Color = saved.toggle.outlineColor or saved.toggle.color or Color3.fromRGB(70, 130, 180) end
            else
                ui.track.BackgroundColor3 = saved.toggle.disabledColor or Color3.fromRGB(200, 200, 200)
                if trackStroke then trackStroke.Color = saved.toggle.outlineColor or Color3.fromRGB(150, 150, 150) end
            end

            local targetPos = isActive and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5)
            TweenService:Create(ui.knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()

            if saved.toggle.image then
                ui.knob.BackgroundTransparency = 1
                ui.knob.Image = saved.toggle.image
                ui.knob.ImageColor3 = Color3.new(1, 1, 1)
            else
                ui.knob.BackgroundTransparency = 0
                ui.knob.Image = ""
                ui.knob.BackgroundColor3 = Color3.new(1, 1, 1)
            end
        else
            ui.track.Visible = false
            ui.text.Position = UDim2.new(0, 0, 0, 0)
            ui.text.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    local function setLine(data)
        if not data or not data.id then return end
        local id = data.id
        local ui = labels[id]
        local isNew = ui == nil

        if isNew then
            creationCounter = creationCounter + 1

            local lineFrame = Instance.new("Frame")
            lineFrame.Name = id
            lineFrame.Size = UDim2.new(1, 0, 0, 0)
            lineFrame.AutomaticSize = Enum.AutomaticSize.Y
            lineFrame.BackgroundTransparency = 1
            lineFrame.Parent = scrolling

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft   = UDim.new(0, 8)
            padding.PaddingRight  = UDim.new(0, 8)
            padding.PaddingTop    = UDim.new(0, 2)
            padding.PaddingBottom = UDim.new(0, 2)
            padding.Parent = lineFrame

            local label = Instance.new("TextLabel")
            label.Name = "Text"
            label.Size = UDim2.new(1, 0, 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.TextWrapped = true
            label.BackgroundTransparency = 1
            label.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.TextTransparency = 1
            label.Parent = lineFrame

            local track = Instance.new("Frame")
            track.Name = "ToggleTrack"
            track.Size = UDim2.fromOffset(28, 14)
            track.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            track.BorderSizePixel = 0
            track.Visible = false
            track.Parent = lineFrame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local trackStroke = Instance.new("UIStroke")
            trackStroke.Thickness = 1
            trackStroke.Color = Color3.fromRGB(150, 150, 150)
            trackStroke.Parent = track

            local knob = Instance.new("ImageButton")
            knob.Name = "ToggleKnob"
            knob.Size = UDim2.fromOffset(10, 10)
            knob.Position = UDim2.new(0, 2, 0.5, -5)
            knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            knob.BorderSizePixel = 0
            knob.AutoButtonColor = false
            knob.Parent = track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local function onToggleClick()
                local s = lineData[id]
                if s and s.toggle then
                    s.toggle.value = not (s.toggle.value or false)
                    renderLine(id)
                    if s.toggle.callback then
                        s.toggle.callback(s.toggle.value)
                    end
                end
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    onToggleClick()
                end
            end)

            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    onToggleClick()
                end
            end)

            labels[id] = { frame = lineFrame, text = label, track = track, knob = knob }
            lineData[id] = {
                id = id,
                text = { text = "", color = pick(lineTextCfg, "color", "Color") or Color3.fromRGB(255, 255, 255) },
                toggle = nil,
                order = nil, created = creationCounter,
            }
        end

        local saved = lineData[id]

        if type(saved.text) ~= "table" then
            saved.text = {
                text = tostring(saved.text or ""),
                color = saved.color or pick(lineTextCfg, "color", "Color") or Color3.fromRGB(255, 255, 255),
            }
        end

        if data.text ~= nil then
            if type(data.text) == "string" then
                saved.text.text = data.text
            elseif type(data.text) == "table" then
                for k, v in pairs(data.text) do saved.text[k] = v end
            end
        end

        if data.color ~= nil then saved.text.color = data.color end
        if data.outlineColor ~= nil then saved.text.outlineColor = data.outlineColor end
        if data.outlineSize ~= nil then saved.text.outlineSize = data.outlineSize == false and nil or data.outlineSize end
        if data.order ~= nil then saved.order = data.order == false and nil or data.order end
        if data.text and data.text.font ~= nil then saved.text.font = data.text.font end

        if data.toggle ~= nil then
            if saved.toggle == nil then saved.toggle = { value = false, side = "right" } end
            for k, v in pairs(data.toggle) do
                saved.toggle[k] = v
            end
        end

        renderLine(id)

        if isNew and not collapsed then
            local stroke = ui and ui.text:FindFirstChild("Outline")
            if stroke then stroke.Transparency = 1 end
            TweenService:Create(labels[id].text, lineFadeInfo, { TextTransparency = 0 }):Play()
            if stroke then TweenService:Create(stroke, lineFadeInfo, { Transparency = 0 }):Play() end
        end

        task.defer(function() if not collapsed then updateFrameSize(true) end end)
    end

    local function applyGlobalPatch(patch)
        if type(patch) ~= "table" then return end
        for id, saved in pairs(lineData) do
            if type(saved.text) ~= "table" then
                saved.text = {
                    text = tostring(saved.text or ""),
                    color = saved.color or pick(lineTextCfg, "color", "Color") or Color3.fromRGB(255, 255, 255),
                }
            end

            if patch.text ~= nil then
                if type(patch.text) == "string" then
                    saved.text.text = patch.text
                elseif type(patch.text) == "table" then
                    for k, v in pairs(patch.text) do saved.text[k] = v end
                end
            end
            if patch.color ~= nil then saved.text.color = patch.color end
            if patch.outlineColor ~= nil then saved.text.outlineColor = patch.outlineColor end
            if patch.outlineSize ~= nil then saved.text.outlineSize = patch.outlineSize == false and nil or patch.outlineSize end
            if patch.order ~= nil then saved.order = patch.order == false and nil or patch.order end
            if patch.text and patch.text.font ~= nil then saved.text.font = patch.text.font end
            
            if patch.toggle ~= nil then
                if saved.toggle == nil then saved.toggle = { value = false, side = "right" } end
                for k, v in pairs(patch.toggle) do saved.toggle[k] = v end
            end
            renderLine(id)
        end
    end

    local function setText(lines)
        if not lines then return end

        if lines.id then
            setLine(lines)
        elseif #lines > 0 and type(lines[1]) == "table" then
            for _, data in ipairs(lines) do
                if type(data) == "table" then
                    if data.id then
                        setLine(data)
                    else
                        applyGlobalPatch(data)
                    end
                end
            end
        else
            applyGlobalPatch(lines)
        end

        updateOrder()
        updateFrameSize(true)
        if not collapsed then setContentTransparency(0, false) end
    end

    local function setCollapsed(state, animate)
        collapsed = state == true
        toggle.Text = collapsed and "⌄" or "⌃"
        if collapsed then setContentTransparency(1, not animate) end
        updateFrameSize(animate)
        if not collapsed then setContentTransparency(0, not animate) end
    end

    for _, data in ipairs(pick(config, "Lines", "lines") or {}) do setLine(data) end
    updateOrder()
    if collapsed then setContentTransparency(1, true) end
    updateFrameSize(false)
    task.defer(function() if not collapsed then updateFrameSize(false) end end)

    if savePosId then
        local saveDebounce = false
        frame:GetPropertyChangedSignal("Position"):Connect(function()
            if saveDebounce then return end
            saveDebounce = true
            task.delay(1, function()
                local p = frame.Position
                saveData[savePosId] = {
                    XScale = p.X.Scale, XOffset = p.X.Offset,
                    YScale = p.Y.Scale, YOffset = p.Y.Offset
                }
                saveDataToFile()
                saveDebounce = false
            end)
        end)
    end

    local function updateDrag(input)
        if not dragging or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        if isEdgeMode() and not collapsed then updateFrameSize(false) end
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then updateDrag(input) end
    end)

    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = pick(topbarLine, "color", "Color") or Color3.fromRGB(90, 145, 255),
            TextColor3 = Color3.new(1, 1, 1)
        }):Play()
    end)
    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = pick(lineToggleCfg, "color", "Color") or Color3.fromRGB(48, 48, 58),
            TextColor3 = pick(lineToggleCfg, "textColor", "TextColor") or Color3.fromRGB(210, 210, 220)
        }):Play()
    end)
    toggle.MouseButton1Click:Connect(function() setCollapsed(not collapsed, true) end)

    local api = {}

    function api:SetLine(lines) setText(lines) end

    function api:RemoveLine(id)
        local ui = labels[id]
        if ui then
            ui.frame:Destroy()
            labels[id] = nil
            lineData[id] = nil
            updateOrder()
            updateFrameSize(true)
            task.defer(function() if not collapsed then updateFrameSize(true) end end)
        end
    end

    function api:Clear()
        for _, ui in pairs(labels) do ui.frame:Destroy() end
        labels, lineData = {}, {}
        updateOrder()
        updateFrameSize(true)
        task.defer(function() if not collapsed then updateFrameSize(true) end end)
    end

    function api:Visible(state) screen.Enabled = state end
    function api:Collapse(state) setCollapsed(state, true) end
    function api:Toggle() setCollapsed(not collapsed, true) end
    function api:IsCollapsed() return collapsed end
    function api:GetLines()
        local list = {}
        for id, _ in pairs(lineData) do table.insert(list, id) end
        table.sort(list)
        return list
    end

    function api:SetParameter(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "Title", "title")
        if v ~= nil then title = tostring(v) titleLabel.Text = title end

        v = pick(tbl, "Width", "width")
        if v ~= nil then
            width = v
            updateFrameSize(true)
        end

        v = pick(tbl, "Scale", "scale")
        if v ~= nil then
            uiScale.Scale = v or 1
            updateFrameSize(true)
            task.defer(function() if not collapsed then updateFrameSize(true) end end)
        end

        v = pick(tbl, "Position", "position")
        if v ~= nil then frame.Position = v end

        v = pick(tbl, "TextSize", "textSize")
        if v ~= nil then
            textSize = v
            titleLabel.TextSize = textSize + 2
            for _, ui in pairs(labels) do ui.text.TextSize = textSize end
            updateFrameSize(true)
        end

        v = pick(tbl, "Collapsed", "collapsed")
        if v ~= nil then setCollapsed(v == true, true) end

        v = pick(tbl, "TweenTime", "tweenTime")
        if v ~= nil then
            tweenTime = v
            tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end

    function api:SetAutoSize(tbl)
        if type(tbl) ~= "table" then return end

        local v = pick(tbl, "Enabled", "enabled")
        if v ~= nil then autoSizeEnabled = v == true end

        v = pick(tbl, "MaxSize", "maxSize")
        if v ~= nil then autoSizeMaxSize = tonumber(v) or autoSizeMaxSize end

        v = pick(tbl, "WindowEdge", "windowEdge")
        if v ~= nil then autoSizeWindowEdge = v == true end

        v = pick(tbl, "WindowEdgeWithMaxSize", "windowEdgeWithMaxSize")
        if v ~= nil then autoSizeWindowEdgeWithMaxSize = v == true end

        v = pick(tbl, "side", "Side")
        if v ~= nil then
            local newSide = tostring(v):lower()
            if newSide ~= autoSizeSide then
                -- Исправленный расчет позиции при смене стороны (не смешиваем Scale и Offset)
                local oldAnchor = frame.AnchorPoint
                local pos = frame.Position
                local sizeX = frame.Size.X.Offset
                local sizeY = frame.Size.Y.Offset
                
                local tlScaleX = pos.X.Scale
                local tlOffsetX = pos.X.Offset - oldAnchor.X * sizeX
                
                local tlScaleY = pos.Y.Scale
                local tlOffsetY = pos.Y.Offset - oldAnchor.Y * sizeY
                
                autoSizeSide = newSide
                local newAnchor = Vector2.new(0, 0)
                if autoSizeSide == "up" then newAnchor = Vector2.new(0, 1)
                elseif autoSizeSide == "left" then newAnchor = Vector2.new(1, 0) end
                
                frame.AnchorPoint = newAnchor
                frame.Position = UDim2.new(
                    tlScaleX, 
                    tlOffsetX + newAnchor.X * sizeX,
                    tlScaleY, 
                    tlOffsetY + newAnchor.Y * sizeY
                )
            end
        end

        updateFrameSize(true)
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end

        local newBg = pick(tbl, "Background", "background")
        if newBg then
            local c = pick(newBg, "color", "Color")
            if c then bg.color = c frame.BackgroundColor3 = c end
            local t = pick(newBg, "transparency", "Transparency")
            if t then bg.transparency = t frame.BackgroundTransparency = t end
        end

        local newTopbar = pick(tbl, "Topbar", "topbar")
        if newTopbar then
            local c = pick(newTopbar, "color", "Color")
            if c then topbar.color = c header.BackgroundColor3 = c end
            local t = pick(newTopbar, "transparency", "Transparency")
            if t then topbar.transparency = t header.BackgroundTransparency = t end
        end

        local newTopbarLine = pick(tbl, "TopbarLine", "topbarLine")
        if newTopbarLine then
            local c = pick(newTopbarLine, "color", "Color")
            if c then topbarLine.color = c accent.BackgroundColor3 = c end
        end

        local newTitleCfg = pick(tbl, "Title", "title")
        if newTitleCfg then
            local c = pick(newTitleCfg, "color", "Color")
            if c then titleCfg.color = c titleLabel.TextColor3 = c end
        end

        local newBorderCfg = pick(tbl, "Border", "border")
        if newBorderCfg then
            local c = pick(newBorderCfg, "color", "Color")
            if c then borderCfg.color = c frameStroke.Color = c end
            local th = pick(newBorderCfg, "thickness", "Thickness")
            if th then borderCfg.thickness = th frameStroke.Thickness = th end
            local t = pick(newBorderCfg, "transparency", "Transparency")
            if t then borderCfg.transparency = t frameStroke.Transparency = t end
        end

        local newCornerCfg = pick(tbl, "Corner", "corner")
        if newCornerCfg then
            local r = pick(newCornerCfg, "radius", "Radius")
            if r then
                cornerCfg.radius = r
                corner.CornerRadius = UDim.new(0, r)
                headerCorner.CornerRadius = UDim.new(0, r)
                shadowCorner.CornerRadius = UDim.new(0, r + 1)
            end
        end

        local newShadowCfg = pick(tbl, "Shadow", "shadow")
        if newShadowCfg then
            local c = pick(newShadowCfg, "color", "Color")
            if c then shadowCfg.color = c shadow.BackgroundColor3 = c end
            local t = pick(newShadowCfg, "transparency", "Transparency")
            if t then shadowCfg.transparency = t shadow.BackgroundTransparency = t end
        end

        local newLineToggleCfg = pick(tbl, "LineToggle", "lineToggle")
        if newLineToggleCfg then
            local c = pick(newLineToggleCfg, "color", "Color")
            if c then lineToggleCfg.color = c toggle.BackgroundColor3 = c end
            local tc = pick(newLineToggleCfg, "textColor", "TextColor")
            if tc then lineToggleCfg.textColor = tc toggle.TextColor3 = tc end
        end

        local newScrollbarCfg = pick(tbl, "Scrollbar", "scrollbar")
        if newScrollbarCfg then
            local c = pick(newScrollbarCfg, "color", "Color")
            if c then scrollbarCfg.color = c scrolling.ScrollBarImageColor3 = c end
        end

        local newLineTextCfg = pick(tbl, "LineText", "lineText")
        if newLineTextCfg then
            local c = pick(newLineTextCfg, "color", "Color")
            if c then lineTextCfg.color = c end
        end

        local newFontCfg = pick(tbl, "Font", "font")
        if newFontCfg then
            local f = pick(newFontCfg, "text", "Text")
            if f then
                fontCfg.text = f
                for id, ui in pairs(labels) do 
                    if not lineData[id].text.font then
                        ui.text.Font = f 
                    end
                end
            end
            local tf = pick(newFontCfg, "title", "Title")
            if tf then fontCfg.title = tf titleLabel.Font = tf end
        end
    end

    function api:Remove()
        if activeTween then activeTween:Cancel() activeTween = nil end
        if screen then screen:Destroy() screen = nil end
    end

    return api
end

function createInfoText(config)
    config = config or {}

    local TweenService = game:GetService("TweenService")
    local RunService   = game:GetService("RunService")
    local TextService  = game:GetService("TextService")

    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then return tbl[key] end
        end
        return nil
    end

    -- ========= CustomWindow =========
    local cw = pick(config, "CustomWindow", "customWindow") or {}
    local bg        = pick(cw, "Background", "background") or {}
    local borderCfg = pick(cw, "Border", "border") or {}
    local cornerCfg = pick(cw, "Corner", "corner") or {}
    local paddingCfg = pick(cw, "Padding", "padding") or {}
    local fontCfg   = pick(cw, "Font", "font") or {}

    -- ========= Основные =========
    local name         = pick(config, "Name", "name")         or "GhostRoomESP"
    local center       = pick(config, "Center", "center")
    local offset       = pick(config, "Offset", "offset")     or Vector3.new(0, 3, 0)
    local baseTextSize = pick(config, "TextSize", "textSize") or 20
    local textSize     = baseTextSize
    local defaultOutlineColor = pick(config, "OutlineColor", "outlineColor") or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize  = pick(config, "OutlineSize", "outlineSize")
    local zIndex = pick(config, "ZIndex", "zIndex") or 1

    -- Ширина
    local widthCfg = pick(config, "Width", "width") or {}
    local widthAuto = true 
    local wa = pick(widthCfg, "auto", "Auto")
    if wa ~= nil then widthAuto = wa == true end
    local widthSize = pick(widthCfg, "size", "Size") or 300

    -- Настройки масштабирования
    local constantCfg = pick(config, "ConstantSize", "constantSize")
    local constantEnabled = false
    local minScale = 0.1
    local maxScale = 1.5
    local studs = 5
    
    if type(constantCfg) == "table" then
        local ce = pick(constantCfg, "enabled", "Enabled")
        if ce ~= nil then constantEnabled = ce == true end
        local ms = pick(constantCfg, "MinScale", "minScale")
        if ms ~= nil then minScale = tonumber(ms) or minScale end
        local mxs = pick(constantCfg, "MaxScale", "maxScale")
        if mxs ~= nil then maxScale = tonumber(mxs) or maxScale end
        local st = pick(constantCfg, "studs", "Studs")
        if st ~= nil then studs = tonumber(st) or studs end
    elseif type(constantCfg) == "boolean" then
        constantEnabled = constantCfg
    end

    local showWindow = false
    local swConfig = pick(config, "ShowWindow", "showWindow")
    local swCustom = pick(cw, "ShowWindow", "showWindow")
    if swCustom ~= nil then showWindow = swCustom == true
    elseif swConfig ~= nil then showWindow = swConfig == true end

    local sizeTweenInfo = TweenInfo.new(
        pick(config, "TweenTime", "tweenTime") or 0.22,
        Enum.EasingStyle.Quint, Enum.EasingDirection.Out
    )

    local billboard, container, windowFrame
    local uiScale
    local windowCornerObj, windowStrokeObj
    local labels, lineData = {}, {}
    local creationCounter = 0
    local isActive = true
    local activeSizeTween
    local pendingOrder, pendingData = {}, {}
    local basePixelSize = Vector2.new(100, 50)

    local function getPadding() return pick(paddingCfg, "value", "Value") or 8 end

    local function resolveAdornee(target)
        if not target then return nil end
        if target:IsA("Model") or target:IsA("BasePart") or target:IsA("Attachment") then
            return target
        end
        return nil
    end

    local function applyOutline(label, data)
        local stroke = label:FindFirstChild("Outline")
        if data.outlineSize then
            if not stroke then
                stroke = Instance.new("UIStroke")
                stroke.Name = "Outline"
                stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
                stroke.Parent = label
            end
            stroke.Color = data.outlineColor or defaultOutlineColor
            stroke.Thickness = data.outlineSize
            stroke.Transparency = 0
        elseif stroke then stroke:Destroy() end
    end

    local function updateOrder()
        local explicit, withoutOrder = {}, {}
        for _, data in pairs(lineData) do
            if data.order ~= nil then table.insert(explicit, data) else table.insert(withoutOrder, data) end
        end
        table.sort(explicit, function(a, b) if a.order == b.order then return a.created < b.created end return a.order < b.order end)
        table.sort(withoutOrder, function(a, b) return a.created < b.created end)
        local used = {}
        for _, data in ipairs(explicit) do
            local order = math.max(1, math.floor(data.order))
            while used[order] do order = order + 1 end
            used[order] = true
            labels[data.id].LayoutOrder = order
        end
        local current = 1
        for _, data in ipairs(withoutOrder) do
            while used[current] do current = current + 1 end
            used[current] = true
            labels[data.id].LayoutOrder = current
            current = current + 1
        end
    end

    local function applyWindowLayout()
        if windowFrame then windowFrame.Visible = showWindow end
    end

    local function measureContent()
        local p = showWindow and getPadding() or 0
        local spacing = 2
        local maxW = 0
        local totalH = 0
        local count = 0

        local fixedW = 300
        if typeof(widthSize) == "UDim2" then
            fixedW = widthSize.X.Offset
        elseif type(widthSize) == "number" then
            fixedW = widthSize
        end

        for _, label in pairs(labels) do
            if label and label.Parent then
                local text = label.Text
                if text == "" then text = " " end
                
                local bounds = Vector2.new(10000, 10000)
                if not widthAuto then
                    bounds = Vector2.new(fixedW - p * 2, 10000)
                end

                local tSize = TextService:GetTextSize(
                    text,
                    label.TextSize,
                    label.Font,
                    bounds
                )
                
                local textW = widthAuto and tSize.X or (fixedW - p * 2)
                
                local strokePad = 0
                local outline = label:FindFirstChild("Outline")
                if outline then strokePad = outline.Thickness end

                maxW = math.max(maxW, textW + strokePad * 2)
                totalH = totalH + tSize.Y + strokePad * 2 + spacing
                count = count + 1
            end
        end

        if count > 0 then totalH = totalH - spacing end
        local finalW = widthAuto and (maxW + p * 2) or fixedW
        return Vector2.new(finalW, totalH + p * 2)
    end

    local function applyDynamicSize()
        if not billboard or not billboard.Adornee or not constantEnabled then return end
        
        local camera = workspace.CurrentCamera
        if not camera then return end

        local adornee = billboard.Adornee
        local adorneePos
        if adornee:IsA("Model") then
            local primary = adornee.PrimaryPart or adornee:FindFirstChild("HumanoidRootPart") or adornee:FindFirstChildWhichIsA("BasePart")
            if primary then 
                adorneePos = primary.Position 
            else 
                local success, pivot = pcall(function() return adornee:GetPivot().Position end)
                if success then adorneePos = pivot else return end
            end
        elseif adornee:IsA("BasePart") then
            adorneePos = adornee.Position
        elseif adornee:IsA("Attachment") then
            adorneePos = adornee.WorldPosition
        else
            return
        end

        -- ВАЖНО: Расстояние считается напрямую от позиции камеры (Spectate работает корректно)
        local distance = (camera.CFrame.Position - adorneePos).Magnitude
        distance = math.max(distance, 0.1)
        
        local dropPerStud = 0.05 / math.max(studs, 0.01)
        local fraction = math.clamp(distance * dropPerStud, 0, 1)
        
        local scaleFactor = maxScale - (maxScale - minScale) * fraction
        
        if scaleFactor <= 0.01 then
            billboard.Enabled = false
        else
            billboard.Enabled = isActive
            if uiScale then uiScale.Scale = scaleFactor end
            billboard.Size = UDim2.fromOffset(basePixelSize.X * scaleFactor, basePixelSize.Y * scaleFactor)
        end
    end

    local function updateSize(animate)
        if not billboard then return end
        basePixelSize = measureContent()

        if container then
            container.Size = UDim2.fromOffset(basePixelSize.X, basePixelSize.Y)
        end

        if not constantEnabled then
            billboard.Enabled = isActive
            if uiScale then uiScale.Scale = 1 end
            local targetSize = UDim2.fromOffset(basePixelSize.X, basePixelSize.Y)
            if activeSizeTween then activeSizeTween:Cancel() activeSizeTween = nil end
            if animate then
                activeSizeTween = TweenService:Create(billboard, sizeTweenInfo, { Size = targetSize })
                activeSizeTween:Play()
            else
                billboard.Size = targetSize
            end
        else
            applyDynamicSize()
        end
    end

    local function createBillboard()
        local adornee = resolveAdornee(center)
        if not adornee then return false end

        billboard = Instance.new("BillboardGui")
        billboard.Name = name
        billboard.Adornee = adornee
        billboard.Size = UDim2.new(0, 100, 0, 100)
        billboard.StudsOffset = offset
        billboard.AlwaysOnTop = true
        billboard.Enabled = isActive
        billboard.Parent = adornee

        -- Фон
        windowFrame = Instance.new("Frame")
        windowFrame.Name = "Window"
        windowFrame.Size = UDim2.new(1, 0, 1, 0)
        windowFrame.BackgroundColor3 = pick(bg, "color", "Color") or Color3.fromRGB(30, 30, 35)
        windowFrame.BackgroundTransparency = pick(bg, "transparency", "Transparency") or 0.15
        windowFrame.BorderSizePixel = 0
        windowFrame.Visible = showWindow
        windowFrame.ZIndex = zIndex
        windowFrame.Parent = billboard

        windowCornerObj = Instance.new("UICorner")
        windowCornerObj.CornerRadius = UDim.new(0, pick(cornerCfg, "radius", "Radius") or 8)
        windowCornerObj.Parent = windowFrame

        windowStrokeObj = Instance.new("UIStroke")
        windowStrokeObj.Name = "Border"
        windowStrokeObj.Color = pick(borderCfg, "color", "Color") or Color3.fromRGB(65, 65, 75)
        windowStrokeObj.Thickness = pick(borderCfg, "thickness", "Thickness") or 1
        windowStrokeObj.Transparency = pick(borderCfg, "transparency", "Transparency") or 0.15
        windowStrokeObj.Parent = windowFrame

        -- Контейнер с текстом
        container = Instance.new("Frame")
        container.Name = "Container"
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = zIndex + 1
        container.Parent = billboard 

        uiScale = Instance.new("UIScale")
        uiScale.Parent = container

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Parent = container

        applyWindowLayout()
        updateSize(false)
        return true
    end

    local setLine
    local function flushPending()
        if #pendingOrder == 0 then return end
        local savedOrder, savedData = pendingOrder, pendingData
        pendingOrder, pendingData = {}, {}
        for _, id in ipairs(savedOrder) do
            if savedData[id] then setLine(savedData[id]) end
        end
    end

    local function renderTextLine(id)
        local label = labels[id]
        local saved = lineData[id]
        if not label or not saved then return end
        
        label.Text = saved.text.text or ""
        label.TextColor3 = saved.text.color or Color3.fromRGB(255, 255, 255)
        
        -- Поддержка кастомного шрифта для строки
        if saved.text.font then
            label.Font = saved.text.font
        else
            label.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
        end

        applyOutline(label, saved.text)
    end

    setLine = function(data)
        if not data or not data.id then return end
        if not billboard or not billboard.Parent then
            if not createBillboard() then
                if not pendingData[data.id] then table.insert(pendingOrder, data.id) end
                pendingData[data.id] = data
                return
            end
            flushPending()
        end

        local id = data.id
        local label = labels[id]
        if not label then
            creationCounter = creationCounter + 1
            label = Instance.new("TextLabel")
            label.Name = id
            label.Size = UDim2.new(1, 0, 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.TextWrapped = not widthAuto
            label.BackgroundTransparency = 1
            label.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.ZIndex = zIndex + 2
            label.Parent = container

            labels[id] = label
            lineData[id] = {
                id = id, text = { text = "", color = Color3.fromRGB(255, 255, 255), outlineColor = defaultOutlineColor, outlineSize = defaultOutlineSize },
                order = nil, created = creationCounter,
            }
        end

        local saved = lineData[id]

        if type(saved.text) ~= "table" then
            saved.text = {
                text = tostring(saved.text or ""),
                color = saved.color or Color3.fromRGB(255, 255, 255),
                outlineColor = saved.outlineColor or defaultOutlineColor,
                outlineSize = saved.outlineSize
            }
        end

        if data.text ~= nil then
            if type(data.text) == "string" then
                saved.text.text = data.text
            elseif type(data.text) == "table" then
                for k, v in pairs(data.text) do saved.text[k] = v end
            end
        end

        if data.color ~= nil then saved.text.color = data.color end
        if data.outlineColor ~= nil then saved.text.outlineColor = data.outlineColor end
        if data.outlineSize ~= nil then saved.text.outlineSize = data.outlineSize == false and nil or data.outlineSize end
        if data.order ~= nil then saved.order = data.order == false and nil or data.order end
        if data.text and data.text.font ~= nil then saved.text.font = data.text.font end -- Кастомный шрифт

        renderTextLine(id)
        updateSize(true)
    end

    local function applyGlobalPatch(patch)
        if type(patch) ~= "table" then return end
        for id, saved in pairs(lineData) do
            if type(saved.text) ~= "table" then
                saved.text = {
                    text = tostring(saved.text or ""),
                    color = saved.color or Color3.fromRGB(255, 255, 255),
                    outlineColor = saved.outlineColor or defaultOutlineColor,
                    outlineSize = saved.outlineSize
                }
            end
            if patch.text ~= nil then
                if type(patch.text) == "string" then saved.text.text = patch.text
                elseif type(patch.text) == "table" then for k, v in pairs(patch.text) do saved.text[k] = v end end
            end
            if patch.color ~= nil then saved.text.color = patch.color end
            if patch.outlineColor ~= nil then saved.text.outlineColor = patch.outlineColor end
            if patch.outlineSize ~= nil then saved.text.outlineSize = patch.outlineSize == false and nil or patch.outlineSize end
            if patch.order ~= nil then saved.order = patch.order == false and nil or patch.order end
            if patch.text and patch.text.font ~= nil then saved.text.font = patch.text.font end
            renderTextLine(id)
        end
    end

    local function setText(lines)
        if not lines then return end
        if lines.id then
            setLine(lines)
        elseif #lines > 0 and type(lines[1]) == "table" then
            for _, data in ipairs(lines) do
                if type(data) == "table" then
                    if data.id then setLine(data) else applyGlobalPatch(data) end
                end
            end
        else
            applyGlobalPatch(lines)
        end
        updateOrder()
        updateSize(true)
    end

    for _, data in ipairs(pick(config, "Lines", "lines") or {}) do setLine(data) end
    if billboard then updateOrder() updateSize(false) end

    -- ===== Динамический размер окна =====
    local renderName = "InfoText_" .. name .. "_" .. tostring(math.random(1000, 9999))
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        if not billboard or not billboard.Parent or not billboard.Adornee then return end
        if constantEnabled then
            applyDynamicSize()
        end
    end)

    local api = {}

    function api:SetLine(lines) setText(lines) end

    function api:RemoveLine(id)
        pendingData[id] = nil
        local label = labels[id]
        if label then
            label:Destroy()
            labels[id] = nil
            lineData[id] = nil
            updateOrder()
            updateSize(true)
        end
    end

    function api:Clear()
        for _, label in pairs(labels) do label:Destroy() end
        labels, lineData = {}, {}
        pendingOrder, pendingData = {}, {}
        updateOrder()
        updateSize(true)
    end

    function api:Visible(state) 
        isActive = state 
        if billboard then 
            if constantEnabled then
                applyDynamicSize()
            else
                billboard.Enabled = isActive 
            end
        end 
    end

    function api:ShowWindow(state)
        showWindow = state == true
        if billboard then applyWindowLayout() updateSize(true) end
    end

    function api:IsWindowShown() return showWindow end

    function api:SetParameter(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "Center", "center")
        if v ~= nil then
            local adornee = resolveAdornee(v)
            if adornee then
                center = v
                if billboard then
                    billboard.Adornee = adornee
                    billboard.Parent = adornee
                    billboard.Enabled = isActive
                else
                    createBillboard()
                    flushPending()
                    updateOrder()
                    updateSize(false)
                end
            end
        end

        v = pick(tbl, "Offset", "offset")
        if v ~= nil then
            offset = v
            if billboard then billboard.StudsOffset = v end
        end

        v = pick(tbl, "Width", "width")
        if type(v) == "table" then
            local newWa = pick(v, "auto", "Auto")
            if newWa ~= nil then widthAuto = newWa == true end
            local ws = pick(v, "size", "Size")
            if ws ~= nil then widthSize = ws end

            for _, label in pairs(labels) do
                label.TextWrapped = not widthAuto
            end
            updateSize(true)
        end

        v = pick(tbl, "TextSize", "textSize")
        if v ~= nil then
            baseTextSize = v
            textSize = baseTextSize
            for _, label in pairs(labels) do
                label.TextSize = textSize
            end
            updateSize(true)
        end

        v = pick(tbl, "ShowWindow", "showWindow")
        if v ~= nil then api:ShowWindow(v) end

        v = pick(tbl, "ZIndex", "zIndex")
        if v ~= nil then
            zIndex = tonumber(v) or zIndex
            if windowFrame then windowFrame.ZIndex = zIndex end
            if container   then container.ZIndex   = zIndex + 1 end
            for _, label in pairs(labels) do label.ZIndex = zIndex + 2 end
        end

        v = pick(tbl, "ConstantSize", "constantSize")
        if type(v) == "table" then
            local ce = pick(v, "enabled", "Enabled")
            if ce ~= nil then constantEnabled = ce == true end
            local ms = pick(v, "MinScale", "minScale")
            if ms ~= nil then minScale = tonumber(ms) or minScale end
            local mxs = pick(v, "MaxScale", "maxScale")
            if mxs ~= nil then maxScale = tonumber(mxs) or maxScale end
            local st = pick(v, "studs", "Studs")
            if st ~= nil then studs = tonumber(st) or studs end
            
            if not constantEnabled then updateSize(true) else applyDynamicSize() end
        elseif type(v) == "boolean" then
            constantEnabled = v
            if not constantEnabled then updateSize(true) else applyDynamicSize() end
        end

        v = pick(tbl, "OutlineColor", "outlineColor")
        if v ~= nil then
            defaultOutlineColor = v
            for id, data in pairs(lineData) do
                if data.text.outlineSize then
                    data.text.outlineColor = v
                    applyOutline(labels[id], data.text)
                end
            end
        end

        v = pick(tbl, "OutlineSize", "outlineSize")
        if v ~= nil then
            defaultOutlineSize = v
            for id, data in pairs(lineData) do
                if data.text.outlineSize ~= nil then
                    data.text.outlineSize = v
                    applyOutline(labels[id], data.text)
                end
            end
        end

        v = pick(tbl, "TweenTime", "tweenTime")
        if v ~= nil then
            sizeTweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        end
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end

        local newBg = pick(tbl, "Background", "background")
        if newBg then
            local c = pick(newBg, "color", "Color")
            if c then bg.color = c if windowFrame then windowFrame.BackgroundColor3 = c end end
            local t = pick(newBg, "transparency", "Transparency")
            if t then bg.transparency = t if windowFrame then windowFrame.BackgroundTransparency = t end end
        end

        local newBorderCfg = pick(tbl, "Border", "border")
        if newBorderCfg then
            local c = pick(newBorderCfg, "color", "Color")
            if c then borderCfg.color = c if windowStrokeObj then windowStrokeObj.Color = c end end
            local th = pick(newBorderCfg, "thickness", "Thickness")
            if th then borderCfg.thickness = th if windowStrokeObj then windowStrokeObj.Thickness = th end end
            local t = pick(newBorderCfg, "transparency", "Transparency")
            if t then borderCfg.transparency = t if windowStrokeObj then windowStrokeObj.Transparency = t end end
        end

        local newCornerCfg = pick(tbl, "Corner", "corner")
        if newCornerCfg then
            local r = pick(newCornerCfg, "radius", "Radius")
            if r then cornerCfg.radius = r if windowCornerObj then windowCornerObj.CornerRadius = UDim.new(0, r) end end
        end

        local newFontCfg = pick(tbl, "Font", "font")
        if newFontCfg then
            local f = pick(newFontCfg, "text", "Text")
            if f then
                fontCfg.text = f
                for id, label in pairs(labels) do 
                    if not lineData[id].text.font then
                        label.Font = f 
                    end
                end
            end
        end
    end

    function api:Remove()
        if activeSizeTween then activeSizeTween:Cancel() activeSizeTween = nil end
        RunService:UnbindFromRenderStep(renderName)
        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
            windowFrame = nil
            uiScale = nil
            windowCornerObj = nil
            windowStrokeObj = nil
        end
        labels, lineData = {}, {}
        pendingOrder, pendingData = {}, {}
    end

    return api
end

function createRadar(config)
    config = config or {}

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local CoreGui          = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then return tbl[key] end
        end
        return nil
    end

    -- ========= CustomWindow =========
    local cw = pick(config, "CustomWindow", "customWindow") or {}

    local bg           = pick(cw, "Background", "background") or {}
    local borderCfg    = pick(cw, "Border", "border") or {}
    local cornerCfg    = pick(cw, "Corner", "corner") or {}
    local titleCfg     = pick(cw, "Title", "title") or {}
    local radarCfg     = pick(cw, "Radar", "radar") or {}
    local gridCfg      = pick(cw, "Grid", "grid") or {}
    local crosshairCfg = pick(cw, "Crosshair", "crosshair") or {}
    local fontCfg      = pick(cw, "Font", "font") or {}

    -- ========= Основные =========
    local Name         = pick(config, "Name", "name")         or "CustomRadar"
    local Title        = pick(config, "Title", "title")       or "Radar"
    local Position     = pick(config, "Position", "position") or UDim2.new(0.03, 0, 0.3, 0)
    local Size         = math.max(tonumber(pick(config, "Size", "size")) or 100, 0.01)
    local Scale        = tonumber(pick(config, "Scale", "scale")) or 1
    local Range        = math.max(tonumber(pick(config, "Range", "range")) or 100, 0)
    local Center       = pick(config, "Center", "center") or Players.LocalPlayer
    local CenterOffset = pick(config, "CenterOffset", "centerOffset") or Vector3.zero
    local EDGE_TEXT_HIDE_THRESHOLD = tonumber(pick(config, "TextHideThreshold", "textHideThreshold")) or 0.95

    local enabled = true
    local targets = {}
    local WINDOW_SIZE, WINDOW_HEIGHT = 220, 260
    local RADAR_SIZE  = 190

    local gui = Instance.new("ScreenGui")
    gui.Name = Name
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = (gethui and gethui()) or CoreGui

    local scaleObject = Instance.new("UIScale")
    scaleObject.Scale = Scale
    scaleObject.Parent = gui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromOffset(WINDOW_SIZE, WINDOW_HEIGHT)
    frame.Position = Position
    frame.BackgroundColor3 = pick(bg, "color", "Color") or Color3.fromRGB(10, 10, 15)
    frame.BackgroundTransparency = pick(bg, "transparency", "Transparency") or 0
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, pick(cornerCfg, "radius", "Radius") or 16)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = pick(borderCfg, "color", "Color") or Color3.fromRGB(80, 80, 90)
    frameStroke.Thickness = pick(borderCfg, "thickness", "Thickness") or 4
    frameStroke.Transparency = pick(borderCfg, "transparency", "Transparency") or 0
    frameStroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 4)
    title.Size = UDim2.new(1, -24, 0, 28)
    title.Font = pick(fontCfg, "title", "Title") or Enum.Font.GothamBold
    title.Text = Title
    title.TextColor3 = pick(titleCfg, "color", "Color") or Color3.fromRGB(235, 235, 235)
    title.TextTransparency = pick(titleCfg, "transparency", "Transparency") or 0
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    local radar = Instance.new("Frame")
    radar.Name = "Radar"
    radar.Size = UDim2.fromOffset(RADAR_SIZE, RADAR_SIZE)
    radar.Position = UDim2.new(0.5, -RADAR_SIZE / 2, 0, 42)
    radar.BackgroundColor3 = pick(radarCfg, "color", "Color") or Color3.fromRGB(5, 5, 8)
    radar.BackgroundTransparency = pick(radarCfg, "transparency", "Transparency") or 0
    radar.BorderSizePixel = 0
    radar.ClipsDescendants = true
    radar.Parent = frame

    local radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radar

    local radarStroke = Instance.new("UIStroke")
    radarStroke.Color = pick(borderCfg, "color", "Color") or Color3.fromRGB(80, 80, 90)
    radarStroke.Thickness = 3
    radarStroke.Transparency = pick(borderCfg, "transparency", "Transparency") or 0
    radarStroke.Parent = radar

    local function createCircle(csize, transparency)
        local circle = Instance.new("Frame")
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(csize, 0, csize, 0)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.Parent = radar
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle
        local stroke = Instance.new("UIStroke")
        stroke.Color = pick(gridCfg, "color", "Color") or Color3.fromRGB(70, 70, 80)
        stroke.Thickness = 1
        stroke.Transparency = transparency or 0
        stroke.Parent = circle
    end

    createCircle(0.66, 0)
    createCircle(0.42, 0)

    local horizontalLine = Instance.new("Frame")
    horizontalLine.BackgroundColor3 = pick(crosshairCfg, "color", "Color") or Color3.fromRGB(45, 45, 50)
    horizontalLine.BackgroundTransparency = 0.35
    horizontalLine.BorderSizePixel = 0
    horizontalLine.AnchorPoint = Vector2.new(0, 0.5)
    horizontalLine.Position = UDim2.new(0, 0, 0.5, 0)
    horizontalLine.Size = UDim2.new(1, 0, 0, 1)
    horizontalLine.Parent = radar

    local verticalLine = Instance.new("Frame")
    verticalLine.BackgroundColor3 = pick(crosshairCfg, "color", "Color") or Color3.fromRGB(45, 45, 50)
    verticalLine.BackgroundTransparency = 0.35
    verticalLine.BorderSizePixel = 0
    verticalLine.AnchorPoint = Vector2.new(0.5, 0)
    verticalLine.Position = UDim2.new(0.5, 0, 0, 0)
    verticalLine.Size = UDim2.new(0, 1, 1, 0)
    verticalLine.Parent = radar

    local targetObjects = {}

    local function getRoot(target)
        if not target then return nil end
        if target:IsA("Player") then
            return target.Character and (target.Character:FindFirstChild("HumanoidRootPart") or target.Character.PrimaryPart)
        end
        if target:IsA("Model") then
            return target:FindFirstChild("HumanoidRootPart") or target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        end
        if target:IsA("BasePart") then return target end
        return nil
    end

    local function ensureText(old)
        if old.text then return old.text end
        old.text = Instance.new("TextLabel")
        old.text.Name = "Text"
        old.text.BackgroundTransparency = 1
        old.text.AnchorPoint = Vector2.new(0.5, 1)
        old.text.Position = UDim2.new(0.5, 0, 0, -4)
        old.text.Size = UDim2.fromOffset(140, 18)
        old.text.Font = pick(fontCfg, "text", "Text") or Enum.Font.Gotham
        old.text.TextSize = 13
        old.text.TextXAlignment = Enum.TextXAlignment.Center
        old.text.ZIndex = 11
        old.text.Parent = old.point
        return old.text
    end

    local function createTarget(data)
        local point = Instance.new("Frame")
        point.Name = tostring(data.id)
        point.AnchorPoint = Vector2.new(0.5, 0.5)
        point.BackgroundColor3 = data.color or Color3.new(1, 1, 1)
        point.BorderSizePixel = 0
        point.ZIndex = 10
        point.Size = UDim2.fromOffset(data.size or 8, data.size or 8)
        point.Parent = radar
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = point
        local obj = { point = point, text = nil, data = data }
        if data.text ~= nil then
            local tl = ensureText(obj)
            tl.Text = tostring(data.text)
            tl.TextColor3 = data.color or Color3.new(1, 1, 1)
        end
        targetObjects[data.id] = obj
    end

    if config.Targets then
        for _, data in ipairs(config.Targets) do
            local finalData = {
                id      = data.id,
                target  = data.target,
                text    = data.text,
                color   = data.color or Color3.new(1, 1, 1),
                size    = data.size or 8,
                visible = data.visible ~= false,
            }
            targets[data.id] = finalData
            createTarget(finalData)
        end
    end

    local function getCenterPosition()
        local root = getRoot(Center)
        if root then return root.Position + CenterOffset end
        if typeof(Center) == "Vector3" then return Center + CenterOffset end
        if typeof(Center) == "CFrame" then return Center.Position + CenterOffset end
        return nil
    end

    local function updateTarget(id, object)
        local data = object.data
        local targetRoot = getRoot(data.target)
        local centerPosition = getCenterPosition()
        if not targetRoot or not centerPosition or data.visible == false then
            object.point.Visible = false
            if object.text then object.text.Visible = false end
            return
        end
        local offset = targetRoot.Position - centerPosition
        local distance = offset.Magnitude
        if distance > Range then
            object.point.Visible = false
            if object.text then object.text.Visible = false end
            return
        end
        object.point.Visible = true
        if distance < 0.01 then
            object.point.Position = UDim2.new(0.5, 0, 0.5, 0)
            if object.text then object.text.Visible = true end
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        local forward = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
        local right   = Vector3.new(camera.CFrame.RightVector.X, 0, camera.CFrame.RightVector.Z)
        if forward.Magnitude < 0.001 or right.Magnitude < 0.001 then return end
        forward = forward.Unit right = right.Unit
        local x = offset:Dot(right)
        local y = offset:Dot(forward)
        local normalizedDistance = distance / Size
        if normalizedDistance > 1 then normalizedDistance = 1 end
        local direction = Vector2.new(x, y)
        if direction.Magnitude > 0 then direction = direction.Unit * normalizedDistance end
        object.point.Position = UDim2.new(0.5 + direction.X * 0.5, 0, 0.5 - direction.Y * 0.5, 0)
        if object.text then object.text.Visible = normalizedDistance < EDGE_TEXT_HIDE_THRESHOLD end
    end

    local renderName = Name .. "_RadarUpdate"
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        if not enabled then return end
        for id, object in pairs(targetObjects) do updateTarget(id, object) end
    end)

    local api = {}

    function api:Set(listOrData)
        if type(listOrData) ~= "table" then return end

        local function applyOne(data)
            if not data or not data.id then return end

            local id = data.id
            local old = targetObjects[id]

            local finalData = {
                id      = id,
                target  = data.target,
                text    = data.text,
                color   = data.color or Color3.new(1, 1, 1),
                size    = data.size or 8,
                visible = data.visible ~= false,
            }

            if not old then
                targets[id] = finalData
                createTarget(finalData)
                return
            end

            old.data = finalData
            targets[id] = finalData

            old.point.BackgroundColor3 = finalData.color
            old.point.Size = UDim2.fromOffset(finalData.size, finalData.size)

            if finalData.text ~= nil then
                local tl = ensureText(old)
                tl.Text = tostring(finalData.text)
                tl.TextColor3 = finalData.color
            elseif old.text then
                old.text:Destroy()
                old.text = nil
            end

            if finalData.visible == false then
                old.point.Visible = false
            end
        end

        if listOrData.id then
            applyOne(listOrData)
        else
            for _, data in ipairs(listOrData) do
                applyOne(data)
            end
        end
    end

    function api:RemoveTarget(id)
        targets[id] = nil
        local object = targetObjects[id]
        if object then object.point:Destroy() targetObjects[id] = nil end
    end

    function api:Clear()
        for id, object in pairs(targetObjects) do
            object.point:Destroy()
            targetObjects[id] = nil
            targets[id] = nil
        end
    end

    function api:Visible(state) enabled = state ~= false gui.Enabled = enabled end

    function api:SetParameter(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "Title", "title")
        if v ~= nil then Title = tostring(v) title.Text = Title end

        v = pick(tbl, "Position", "position")
        if v ~= nil then Position = v frame.Position = v end

        v = pick(tbl, "Scale", "scale")
        if v ~= nil then Scale = tonumber(v) or Scale scaleObject.Scale = Scale end

        v = pick(tbl, "Size", "size")
        if v ~= nil then Size = math.max(tonumber(v) or Size, 0.01) end

        v = pick(tbl, "Range", "range")
        if v ~= nil then Range = math.max(tonumber(v) or Range, 0) end

        v = pick(tbl, "Center", "center")
        if v ~= nil then Center = v end

        v = pick(tbl, "CenterOffset", "centerOffset")
        if v ~= nil then CenterOffset = v or Vector3.zero end

        v = pick(tbl, "TextHideThreshold", "textHideThreshold")
        if v ~= nil then EDGE_TEXT_HIDE_THRESHOLD = tonumber(v) or EDGE_TEXT_HIDE_THRESHOLD end
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end

        local newBg = pick(tbl, "Background", "background")
        if newBg then
            local c = pick(newBg, "color", "Color")
            if c then bg.color = c frame.BackgroundColor3 = c end
            local t = pick(newBg, "transparency", "Transparency")
            if t then bg.transparency = t frame.BackgroundTransparency = t end
        end

        local newBorderCfg = pick(tbl, "Border", "border")
        if newBorderCfg then
            local c = pick(newBorderCfg, "color", "Color")
            if c then borderCfg.color = c frameStroke.Color = c radarStroke.Color = c end
            local th = pick(newBorderCfg, "thickness", "Thickness")
            if th then borderCfg.thickness = th frameStroke.Thickness = th end
            local t = pick(newBorderCfg, "transparency", "Transparency")
            if t then borderCfg.transparency = t frameStroke.Transparency = t radarStroke.Transparency = t end
        end

        local newCornerCfg = pick(tbl, "Corner", "corner")
        if newCornerCfg then
            local r = pick(newCornerCfg, "radius", "Radius")
            if r then cornerCfg.radius = r frameCorner.CornerRadius = UDim.new(0, r) end
        end

        local newTitleCfg = pick(tbl, "Title", "title")
        if newTitleCfg then
            local c = pick(newTitleCfg, "color", "Color")
            if c then titleCfg.color = c title.TextColor3 = c end
            local t = pick(newTitleCfg, "transparency", "Transparency")
            if t then titleCfg.transparency = t title.TextTransparency = t end
        end

        local newRadarCfg = pick(tbl, "Radar", "radar")
        if newRadarCfg then
            local c = pick(newRadarCfg, "color", "Color")
            if c then radarCfg.color = c radar.BackgroundColor3 = c end
            local t = pick(newRadarCfg, "transparency", "Transparency")
            if t then radarCfg.transparency = t radar.BackgroundTransparency = t end
        end

        local newGridCfg = pick(tbl, "Grid", "grid")
        if newGridCfg then
            local c = pick(newGridCfg, "color", "Color")
            if c then
                gridCfg.color = c
                for _, child in ipairs(radar:GetChildren()) do
                    if child:IsA("Frame") then
                        local s = child:FindFirstChildOfClass("UIStroke")
                        if s then s.Color = c end
                    end
                end
            end
        end

        local newCrosshairCfg = pick(tbl, "Crosshair", "crosshair")
        if newCrosshairCfg then
            local c = pick(newCrosshairCfg, "color", "Color")
            if c then
                crosshairCfg.color = c
                horizontalLine.BackgroundColor3 = c
                verticalLine.BackgroundColor3 = c
            end
        end

        local newFontCfg = pick(tbl, "Font", "font")
        if newFontCfg then
            local f = pick(newFontCfg, "text", "Text")
            if f then
                fontCfg.text = f
                for _, obj in pairs(targetObjects) do if obj.text then obj.text.Font = f end end
            end
            local tf = pick(newFontCfg, "title", "Title")
            if tf then fontCfg.title = tf title.Font = tf end
        end
    end

    function api:Remove()
        RunService:UnbindFromRenderStep(renderName)
        gui:Destroy()
    end

    return api
end

return {
    createInfoGui  = createInfoGui,
    createInfoText = createInfoText,
    createRadar = createRadar
}
