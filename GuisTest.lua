function createInfoGui(config)
    config = config or {}

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then return tbl[key] end
        end
        return nil
    end

    -- ========= CustomWindow =========
    local cw = pick(config, "CustomWindow", "customWindow") or {}

    local windowColor          = pick(cw, "WindowColor", "windowColor")             or Color3.fromRGB(30, 30, 35)
    local windowTransparency   = pick(cw, "WindowTransparency", "windowTransparency")
    if windowTransparency == nil then windowTransparency = 0 end
    local headerColor          = pick(cw, "HeaderColor", "headerColor")             or Color3.fromRGB(35, 35, 42)
    local headerTransparency   = pick(cw, "HeaderTransparency", "headerTransparency")
    if headerTransparency == nil then headerTransparency = 0 end
    local borderColor          = pick(cw, "BorderColor", "borderColor")             or Color3.fromRGB(65, 65, 75)
    local borderThickness      = pick(cw, "BorderThickness", "borderThickness") or 1
    local borderTransparency   = pick(cw, "BorderTransparency", "borderTransparency")
    if borderTransparency == nil then borderTransparency = 0.15 end
    local cornerRadius         = pick(cw, "CornerRadius", "cornerRadius") or 8
    local accentColor          = pick(cw, "AccentColor", "accentColor")             or Color3.fromRGB(90, 145, 255)
    local titleColor           = pick(cw, "TitleColor", "titleColor")               or Color3.fromRGB(245, 245, 248)
    local shadowColor          = pick(cw, "ShadowColor", "shadowColor")             or Color3.new(0, 0, 0)
    local shadowTransparency   = pick(cw, "ShadowTransparency", "shadowTransparency")
    if shadowTransparency == nil then shadowTransparency = 0.65 end
    local toggleColor          = pick(cw, "ToggleColor", "toggleColor")             or Color3.fromRGB(48, 48, 58)
    local toggleTextColor      = pick(cw, "ToggleTextColor", "toggleTextColor")     or Color3.fromRGB(210, 210, 220)
    local scrollbarColor       = pick(cw, "ScrollbarColor", "scrollbarColor")       or accentColor
    local lineTextColor        = pick(cw, "LineTextColor", "lineTextColor")         or Color3.fromRGB(255, 255, 255)

    -- ========= Основные настройки окна =========
    local guiName   = pick(config, "Name", "name") or "CustomWindow"
    local title     = pick(config, "Title", "title") or "Window"
    local width     = pick(config, "Width", "width") or 200
    local scale     = pick(config, "Scale", "scale") or 1
    local position  = pick(config, "Position", "position") or UDim2.new(0.05, 0, 0.15, 0)
    local textSize  = pick(config, "TextSize", "textSize") or 14
    local font      = pick(config, "Font", "font") or Enum.Font.GothamMedium
    local titleFont = pick(config, "TitleFont", "titleFont") or Enum.Font.GothamSemibold

    local defaultOutlineColor = pick(config, "OutlineColor", "outlineColor") or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize  = pick(config, "OutlineSize", "outlineSize")

    -- ========= AutoSize =========
    -- Enabled = true             → динамический рост по контенту, верхняя граница = MaxSize
    -- Enabled = false            → фиксированная высота = MaxSize
    -- WindowEdge = true          → игнорит MaxSize, тянется до низа экрана (EDGE_MARGIN)
    -- WindowEdgeWithMaxSize = true (только при WindowEdge = true)
    --                              → максимум = min(MaxSize, доступная_высота_до_низа)
    local autoSizeCfg        = pick(config, "AutoSize", "autoSize") or {}
    local autoSizeEnabled    = pick(autoSizeCfg, "Enabled", "enabled")
    if autoSizeEnabled == nil then autoSizeEnabled = true end
    local autoSizeMaxSize    = pick(autoSizeCfg, "MaxSize", "maxSize") or 500
    local autoSizeWindowEdge = pick(autoSizeCfg, "WindowEdge", "windowEdge")
    if autoSizeWindowEdge == nil then autoSizeWindowEdge = false end
    local autoSizeWindowEdgeWithMaxSize =
        pick(autoSizeCfg, "WindowEdgeWithMaxSize", "windowEdgeWithMaxSize")
    if autoSizeWindowEdgeWithMaxSize == nil then autoSizeWindowEdgeWithMaxSize = false end

    -- ========= Константы =========
    local headerHeight  = 32
    local bottomPadding = 3
    local linePadding   = 2
    local EDGE_MARGIN   = 12      -- физические пиксели

    local tweenTime     = pick(config, "TweenTime", "tweenTime") or 0.22
    local tweenInfo     = TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local lineFadeInfo  = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    -- ========= Создание GUI =========
    local screen = CoreGui:FindFirstChild(guiName)
    if screen then screen:Destroy() end

    screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, width, 0, headerHeight)
    frame.Position = position
    frame.BackgroundColor3 = windowColor
    frame.BackgroundTransparency = windowTransparency
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Name = "Border"
    frameStroke.Color = borderColor
    frameStroke.Thickness = borderThickness
    frameStroke.Transparency = borderTransparency
    frameStroke.Parent = frame

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = scale
    uiScale.Parent = frame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.BackgroundColor3 = shadowColor
    shadow.BackgroundTransparency = shadowTransparency
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, cornerRadius + 1)
    shadowCorner.Parent = shadow

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.BackgroundColor3 = headerColor
    header.BackgroundTransparency = headerTransparency
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 2
    header.Parent = frame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, cornerRadius)
    headerCorner.Parent = header

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Position = UDim2.new(0, 7, 0.5, -7)
    accent.Size = UDim2.fromOffset(3, 14)
    accent.BackgroundColor3 = accentColor
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
    titleLabel.TextColor3 = titleColor
    titleLabel.Font = titleFont
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
    toggle.BackgroundColor3 = toggleColor
    toggle.BackgroundTransparency = 0.15
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = "⌃"
    toggle.TextColor3 = toggleTextColor
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 15
    toggle.ZIndex = 4
    toggle.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle

    -- ======== Скроллящийся контейнер ========
    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "Container"
    scrolling.Position = UDim2.new(0, 0, 0, headerHeight)
    scrolling.Size = UDim2.new(1, 0, 1, -headerHeight)
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.ScrollBarThickness = 0
    scrolling.ScrollBarImageColor3 = scrollbarColor
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

    local labels = {}
    local lineData = {}
    local creationCounter = 0

    local collapsed = pick(config, "Collapsed", "collapsed") == true
    local activeTween

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    -- ======== Scale-aware helpers ========
    local function getScale()
        local s = uiScale.Scale
        return (s and s > 0) and s or 1
    end

    local function getContentHeightLogical()
        return layout.AbsoluteContentSize.Y / getScale()
    end

    -- Эффективная максимальная высота окна (в логических юнитах).
    -- Минимум = headerHeight (чтобы хедер всегда влезал).
    local function getEffectiveMaxHeightLogical()
        -- WindowEdgeWithMaxSize работает ТОЛЬКО когда WindowEdge = true
        if autoSizeWindowEdge then
            local screenH = screen.AbsoluteSize.Y
            local yPos    = frame.AbsolutePosition.Y
            local edgeAvailable = (screenH - yPos - EDGE_MARGIN) / getScale()

            -- Не даём уйти ниже headerHeight — иначе хедер пропадёт
            edgeAvailable = math.max(edgeAvailable, headerHeight)

            if autoSizeWindowEdgeWithMaxSize then
                -- Комбинированный режим: учитываем и MaxSize, и край экрана
                return math.min(autoSizeMaxSize, edgeAvailable)
            else
                -- Чистый WindowEdge: игнорит MaxSize
                return edgeAvailable
            end
        else
            -- WindowEdge выключен — WindowEdgeWithMaxSize игнорируется
            return autoSizeMaxSize
        end
    end

    local function isEdgeMode()
        -- Активен ли режим "прилипания к низу экрана" (нужно для drag/screen-resize)
        return autoSizeWindowEdge
    end

    -- ======== Обновление размера ========
    local function updateFrameSize(animate)
        local targetHeight

        if collapsed then
            targetHeight = headerHeight
        else
            local contentH = getContentHeightLogical()
            local desired  = headerHeight + contentH + bottomPadding

            if autoSizeEnabled then
                local maxH = getEffectiveMaxHeightLogical()
                targetHeight = math.min(desired, maxH)
            else
                targetHeight = autoSizeMaxSize
            end
        end

        -- Полоса прокрутки
        if not collapsed then
            local contentH   = getContentHeightLogical()
            local availableH = targetHeight - headerHeight
            if contentH > availableH + 1 then
                scrolling.ScrollBarThickness = 4
            else
                scrolling.ScrollBarThickness = 0
            end
        else
            scrolling.ScrollBarThickness = 0
        end

        if activeTween then activeTween:Cancel() activeTween = nil end

        if animate and not (isEdgeMode() and dragging) then
            activeTween = TweenService:Create(
                frame, tweenInfo, { Size = UDim2.new(0, width, 0, targetHeight) }
            )
            activeTween:Play()
        else
            frame.Size = UDim2.new(0, width, 0, targetHeight)
        end
    end

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not collapsed then
            updateFrameSize(true)
        end
    end)

    screen:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        if isEdgeMode() and not collapsed then
            updateFrameSize(false)
        end
    end)

    -- ======== Вспомогательные ========
    local function setContentTransparency(transparency, instant)
        for _, label in pairs(labels) do
            if instant then
                label.TextTransparency = transparency
            else
                TweenService:Create(label, tweenInfo, { TextTransparency = transparency }):Play()
            end

            local stroke = label:FindFirstChild("Outline")
            if stroke then
                if instant then
                    stroke.Transparency = transparency
                else
                    TweenService:Create(stroke, tweenInfo, { Transparency = transparency }):Play()
                end
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
            stroke.Color = data.outlineColor or defaultOutlineColor
            stroke.Thickness = data.outlineSize
            stroke.Transparency = collapsed and 1 or 0
        elseif stroke then
            stroke:Destroy()
        end
    end

    local function updateOrder()
        local explicit, withoutOrder = {}, {}
        for _, data in pairs(lineData) do
            if data.order ~= nil then table.insert(explicit, data)
            else table.insert(withoutOrder, data) end
        end

        table.sort(explicit, function(a, b)
            if a.order == b.order then return a.created < b.created end
            return a.order < b.order
        end)
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

    local function setLine(data)
        if not data or not data.id then return end

        local id = data.id
        local label = labels[id]
        local isNew = label == nil

        if isNew then
            creationCounter = creationCounter + 1

            label = Instance.new("TextLabel")
            label.Name = id
            label.Size = UDim2.new(1, 0, 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.TextWrapped = true
            label.BackgroundTransparency = 1
            label.Font = font
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.TextTransparency = 1
            label.Parent = scrolling

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft   = UDim.new(0, 8)
            padding.PaddingRight  = UDim.new(0, 8)
            padding.PaddingTop    = UDim.new(0, 1)
            padding.PaddingBottom = UDim.new(0, 1)
            padding.Parent = label

            labels[id] = label
            lineData[id] = {
                id = id,
                text = "",
                color = lineTextColor,
                outlineColor = defaultOutlineColor,
                outlineSize = defaultOutlineSize,
                order = nil,
                created = creationCounter,
            }
        end

        local saved = lineData[id]

        if data.text          ~= nil then saved.text          = data.text end
        if data.color         ~= nil then saved.color         = data.color end
        if data.outlineColor  ~= nil then saved.outlineColor  = data.outlineColor end
        if data.outlineSize   ~= nil then saved.outlineSize   = data.outlineSize == false and nil or data.outlineSize end
        if data.order         ~= nil then saved.order         = data.order == false and nil or data.order end

        label.Text = saved.text
        label.TextColor3 = saved.color
        applyOutline(label, saved)

        if isNew and not collapsed then
            local stroke = label:FindFirstChild("Outline")
            if stroke then stroke.Transparency = 1 end

            TweenService:Create(label, lineFadeInfo, { TextTransparency = 0 }):Play()
            if stroke then
                TweenService:Create(stroke, lineFadeInfo, { Transparency = 0 }):Play()
            end
        end

        task.defer(function()
            if not collapsed then
                updateFrameSize(true)
            end
        end)
    end

    local function setText(lines)
        if not lines then return end
        for _, data in ipairs(lines) do setLine(data) end
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

    for _, data in ipairs(pick(config, "Lines", "lines") or {}) do
        setLine(data)
    end

    updateOrder()
    if collapsed then setContentTransparency(1, true) end
    updateFrameSize(false)

    task.defer(function()
        if not collapsed then
            updateFrameSize(false)
        end
    end)

    -- ======== Drag ========
    local function updateDrag(input)
        if not dragging or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
        if isEdgeMode() and not collapsed then
            updateFrameSize(false)
        end
    end

    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then updateDrag(input) end
    end)

    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = accentColor,
            TextColor3 = Color3.new(1, 1, 1),
        }):Play()
    end)

    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = toggleColor,
            TextColor3 = toggleTextColor,
        }):Play()
    end)

    toggle.MouseButton1Click:Connect(function()
        setCollapsed(not collapsed, true)
    end)

    -- ======== API ========
    local api = {}

    function api:SetText(lines) setText(lines) end

    function api:RemoveLine(id)
        local label = labels[id]
        if label then
            label:Destroy()
            labels[id] = nil
            lineData[id] = nil
            updateOrder()
            updateFrameSize(true)
            task.defer(function()
                if not collapsed then updateFrameSize(true) end
            end)
        end
    end

    function api:Clear()
        for _, label in pairs(labels) do
            label:Destroy()
        end
        labels, lineData = {}, {}
        updateOrder()
        updateFrameSize(true)
        task.defer(function()
            if not collapsed then updateFrameSize(true) end
        end)
    end

    function api:Visible(state) screen.Enabled = state end

    function api:SetScale(value)
        uiScale.Scale = value or 1
        updateFrameSize(true)
        task.defer(function()
            if not collapsed then updateFrameSize(true) end
        end)
    end

    function api:SetPosition(value) if value then frame.Position = value end end
    function api:SetTitle(newTitle)
        title = tostring(newTitle)
        titleLabel.Text = title
    end

    function api:Collapse(state) setCollapsed(state, true) end
    function api:Toggle() setCollapsed(not collapsed, true) end
    function api:IsCollapsed() return collapsed end

    -- ======== Runtime setters ========
    function api:SetAutoSize(cfg)
        if type(cfg) ~= "table" then return end
        local e = pick(cfg, "Enabled", "enabled")
        if e ~= nil then autoSizeEnabled = e == true end
        local m = pick(cfg, "MaxSize", "maxSize")
        if m ~= nil then autoSizeMaxSize = tonumber(m) or autoSizeMaxSize end
        local w = pick(cfg, "WindowEdge", "windowEdge")
        if w ~= nil then autoSizeWindowEdge = w == true end
        local wm = pick(cfg, "WindowEdgeWithMaxSize", "windowEdgeWithMaxSize")
        if wm ~= nil then autoSizeWindowEdgeWithMaxSize = wm == true end
        updateFrameSize(true)
    end

    function api:SetAutoSizeEnabled(v)
        autoSizeEnabled = v == true
        updateFrameSize(true)
    end

    function api:SetMaxSize(v)
        autoSizeMaxSize = tonumber(v) or autoSizeMaxSize
        updateFrameSize(true)
    end

    function api:SetWindowEdge(v)
        autoSizeWindowEdge = v == true
        updateFrameSize(true)
    end

    function api:SetWindowEdgeWithMaxSize(v)
        autoSizeWindowEdgeWithMaxSize = v == true
        updateFrameSize(true)
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "WindowColor", "windowColor")
        if v ~= nil then windowColor = v; frame.BackgroundColor3 = v end
        v = pick(tbl, "WindowTransparency", "windowTransparency")
        if v ~= nil then windowTransparency = v; frame.BackgroundTransparency = v end

        v = pick(tbl, "HeaderColor", "headerColor")
        if v ~= nil then headerColor = v; header.BackgroundColor3 = v end
        v = pick(tbl, "HeaderTransparency", "headerTransparency")
        if v ~= nil then headerTransparency = v; header.BackgroundTransparency = v end

        v = pick(tbl, "BorderColor", "borderColor")
        if v ~= nil then borderColor = v; frameStroke.Color = v end
        v = pick(tbl, "BorderThickness", "borderThickness")
        if v ~= nil then borderThickness = v; frameStroke.Thickness = v end
        v = pick(tbl, "BorderTransparency", "borderTransparency")
        if v ~= nil then borderTransparency = v; frameStroke.Transparency = v end

        v = pick(tbl, "CornerRadius", "cornerRadius")
        if v ~= nil then
            cornerRadius = v
            corner.CornerRadius = UDim.new(0, v)
            headerCorner.CornerRadius = UDim.new(0, v)
            shadowCorner.CornerRadius = UDim.new(0, v + 1)
        end

        v = pick(tbl, "AccentColor", "accentColor")
        if v ~= nil then accentColor = v; accent.BackgroundColor3 = v end

        v = pick(tbl, "TitleColor", "titleColor")
        if v ~= nil then titleColor = v; titleLabel.TextColor3 = v end

        v = pick(tbl, "ShadowColor", "shadowColor")
        if v ~= nil then shadowColor = v; shadow.BackgroundColor3 = v end
        v = pick(tbl, "ShadowTransparency", "shadowTransparency")
        if v ~= nil then shadowTransparency = v; shadow.BackgroundTransparency = v end

        v = pick(tbl, "ToggleColor", "toggleColor")
        if v ~= nil then toggleColor = v; toggle.BackgroundColor3 = v end
        v = pick(tbl, "ToggleTextColor", "toggleTextColor")
        if v ~= nil then toggleTextColor = v; toggle.TextColor3 = v end

        v = pick(tbl, "ScrollbarColor", "scrollbarColor")
        if v ~= nil then scrollbarColor = v; scrolling.ScrollBarImageColor3 = v end

        v = pick(tbl, "LineTextColor", "lineTextColor")
        if v ~= nil then lineTextColor = v end
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

    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then return tbl[key] end
        end
        return nil
    end

    local name           = pick(config, "Name", "name") or "GhostRoomESP"
    local center         = pick(config, "Center", "center")
    local offset         = pick(config, "Offset", "offset") or Vector3.new(0, 3, 0)
    local baseTextSize   = pick(config, "TextSize", "textSize") or 20
    local textSize       = baseTextSize
    local baseSize       = pick(config, "Size", "size") or UDim2.new(0, 300, 0, 0)
    local size           = baseSize
    local defaultOutlineColor = pick(config, "OutlineColor", "outlineColor") or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize  = pick(config, "OutlineSize", "outlineSize")

    -- CustomWindow-стиль
    local cw = pick(config, "CustomWindow", "customWindow") or {}

    -- ShowWindow: приоритет у CustomWindow
    local showWindow = false
    local swConfig = pick(config, "ShowWindow", "showWindow")
    local swCustom = pick(cw, "ShowWindow", "showWindow")
    if swCustom ~= nil then
        showWindow = swCustom == true
    elseif swConfig ~= nil then
        showWindow = swConfig == true
    end

    local windowBackground             = pick(cw, "WindowColor", "windowColor")             or Color3.fromRGB(30, 30, 35)
    local windowBackgroundTransparency = pick(cw, "WindowTransparency", "windowTransparency")
    if windowBackgroundTransparency == nil then windowBackgroundTransparency = 0.15 end
    local windowBorderColor            = pick(cw, "BorderColor", "borderColor")             or Color3.fromRGB(65, 65, 75)
    local windowBorderThickness        = pick(cw, "BorderThickness", "borderThickness") or 1
    local windowBorderTransparency     = pick(cw, "BorderTransparency", "borderTransparency")
    if windowBorderTransparency == nil then windowBorderTransparency = 0.15 end
    local windowCorner                 = pick(cw, "CornerRadius", "cornerRadius") or 8
    local windowPadding                = pick(cw, "Padding", "padding") or 8

    local sizeTweenInfo = TweenInfo.new(
        pick(config, "TweenTime", "tweenTime") or 0.22,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local billboard, container, windowFrame
    local labels, lineData = {}, {}
    local creationCounter = 0
    local currentAdornee
    local isActive = true
    local activeSizeTween

    local pendingOrder, pendingData = {}, {}

    local function resolveAdornee(target)
        if not target then return nil end
        if target:IsA("Model") then
            target = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        end
        if not target or not target:IsA("BasePart") then return nil end
        return target
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
        elseif stroke then
            stroke:Destroy()
        end
    end

    local function updateOrder()
        local explicit, withoutOrder = {}, {}
        for _, data in pairs(lineData) do
            if data.order ~= nil then table.insert(explicit, data)
            else table.insert(withoutOrder, data) end
        end
        table.sort(explicit, function(a, b)
            if a.order == b.order then return a.created < b.created end
            return a.order < b.order
        end)
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
        if not container then return end
        local p = showWindow and windowPadding or 0
        container.Position = UDim2.new(0, p, 0, p)
        container.Size     = UDim2.new(1, -p * 2, 1, -p * 2)
        if windowFrame then windowFrame.Visible = showWindow end
    end

    local function updateSize(animate)
        if not billboard then return end
        local layout = container and container:FindFirstChildOfClass("UIListLayout")
        local layoutHeight = layout and layout.AbsoluteContentSize.Y or 0
        local extra = showWindow and (windowPadding * 2) or 0
        local autoHeight = math.max(textSize + extra, layoutHeight + extra)

        local targetHeight
        if size.Y.Offset and size.Y.Offset > 0 then
            targetHeight = size.Y.Offset
        else
            targetHeight = autoHeight
        end

        local targetSize = UDim2.new(size.X.Scale, size.X.Offset, 0, targetHeight)

        if activeSizeTween then activeSizeTween:Cancel() activeSizeTween = nil end
        if animate then
            activeSizeTween = TweenService:Create(billboard, sizeTweenInfo, { Size = targetSize })
            activeSizeTween:Play()
        else
            billboard.Size = targetSize
        end
    end

    local function createBillboard()
        local adornee = resolveAdornee(center)
        if not adornee then return false end
        currentAdornee = adornee

        billboard = Instance.new("BillboardGui")
        billboard.Name = name
        billboard.Adornee = adornee
        billboard.Size = size
        billboard.StudsOffset = offset
        billboard.AlwaysOnTop = true
        billboard.Enabled = isActive
        billboard.Parent = adornee

        windowFrame = Instance.new("Frame")
        windowFrame.Name = "Window"
        windowFrame.Size = UDim2.new(1, 0, 1, 0)
        windowFrame.Position = UDim2.new(0, 0, 0, 0)
        windowFrame.BackgroundColor3 = windowBackground
        windowFrame.BackgroundTransparency = windowBackgroundTransparency
        windowFrame.BorderSizePixel = 0
        windowFrame.Visible = showWindow
        windowFrame.ZIndex = 0
        windowFrame.Parent = billboard

        local wc = Instance.new("UICorner")
        wc.CornerRadius = UDim.new(0, windowCorner)
        wc.Parent = windowFrame

        local ws = Instance.new("UIStroke")
        ws.Name = "Border"
        ws.Color = windowBorderColor
        ws.Thickness = windowBorderThickness
        ws.Transparency = windowBorderTransparency
        ws.Parent = windowFrame

        container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = 1
        container.Parent = billboard

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        layout.Parent = container

        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateSize(true)
        end)

        applyWindowLayout()
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
            label.TextWrapped = true
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.Parent = container

            labels[id] = label
            lineData[id] = {
                id = id, text = "", color = Color3.fromRGB(255, 255, 255),
                outlineColor = defaultOutlineColor, outlineSize = defaultOutlineSize,
                order = nil, created = creationCounter,
            }
        end

        local saved = lineData[id]
        if data.text         ~= nil then saved.text         = data.text end
        if data.color        ~= nil then saved.color        = data.color end
        if data.outlineColor ~= nil then saved.outlineColor = data.outlineColor end
        if data.outlineSize  ~= nil then saved.outlineSize  = data.outlineSize == false and nil or data.outlineSize end
        if data.order        ~= nil then saved.order        = data.order == false and nil or data.order end

        label.Text = saved.text
        label.TextColor3 = saved.color
        applyOutline(label, saved)
    end

    local function setText(lines)
        if not lines then return end
        for _, data in ipairs(lines) do setLine(data) end
        updateOrder()
        updateSize(true)
    end

    for _, data in ipairs(pick(config, "Lines", "lines") or {}) do setLine(data) end
    if billboard then updateOrder() updateSize(false) end

    local api = {}

    function api:SetText(lines) setText(lines) end

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
        for _, label in pairs(labels) do
            label:Destroy()
        end
        labels, lineData = {}, {}
        pendingOrder, pendingData = {}, {}
        updateOrder()
        updateSize(true)
    end

    function api:Visible(state)
        isActive = state
        if billboard then billboard.Enabled = state end
    end

    function api:SetCenter(newCenter)
        local adornee = resolveAdornee(newCenter)
        if not adornee then return end
        center = newCenter
        currentAdornee = adornee
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

    function api:SetOffset(newOffset)
        if not newOffset then return end
        offset = newOffset
        if billboard then billboard.StudsOffset = newOffset end
    end

    -- Единый параметр: число-множитель (и окно, и текст)
    function api:SetSize(value)
        if type(value) ~= "number" then return end
        local scaleFactor = math.max(value, 0.1)

        textSize = baseTextSize * scaleFactor

        size = UDim2.new(
            baseSize.X.Scale,
            baseSize.X.Offset * scaleFactor,
            baseSize.Y.Scale,
            baseSize.Y.Offset * scaleFactor
        )

        for _, label in pairs(labels) do
            label.TextSize = textSize
            label.Size = UDim2.new(1, 0, 0, 0)
        end

        if billboard then
            billboard.Size = size
            updateSize(true)
        end
    end

    function api:ShowWindow(state)
        showWindow = state == true
        if billboard then
            applyWindowLayout()
            updateSize(true)
        end
    end

    function api:IsWindowShown() return showWindow end

    function api:Remove()
        if activeSizeTween then activeSizeTween:Cancel() activeSizeTween = nil end
        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
            windowFrame = nil
        end
        labels, lineData = {}, {}
        pendingOrder, pendingData = {}, {}
    end

        function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end
        local v
        v = pick(tbl, "WindowColor", "windowColor")
        if v ~= nil then
            windowBackground = v
            if windowFrame then windowFrame.BackgroundColor3 = v end
        end
        v = pick(tbl, "WindowTransparency", "windowTransparency")
        if v ~= nil then
            windowBackgroundTransparency = v
            if windowFrame then windowFrame.BackgroundTransparency = v end
        end
        v = pick(tbl, "BorderColor", "borderColor")
        if v ~= nil then
            windowBorderColor = v
            if windowFrame then
                local ws = windowFrame:FindFirstChild("Border")
                if ws then ws.Color = v end
            end
        end
        v = pick(tbl, "BorderThickness", "borderThickness")
        if v ~= nil then
            windowBorderThickness = v
            if windowFrame then
                local ws = windowFrame:FindFirstChild("Border")
                if ws then ws.Thickness = v end
            end
        end
        v = pick(tbl, "BorderTransparency", "borderTransparency")
        if v ~= nil then
            windowBorderTransparency = v
            if windowFrame then
                local ws = windowFrame:FindFirstChild("Border")
                if ws then ws.Transparency = v end
            end
        end
        v = pick(tbl, "CornerRadius", "cornerRadius")
        if v ~= nil then
            windowCorner = v
            if windowFrame then
                local wc = windowFrame:FindFirstChildOfClass("UICorner")
                if wc then wc.CornerRadius = UDim.new(0, v) end
            end
        end
    end

    return api
end

local function createRadar(config)
    config = config or {}

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    -- Регистронезависимый "getter"
    local function pick(tbl, ...)
        if type(tbl) ~= "table" then return nil end
        for _, key in ipairs({...}) do
            if tbl[key] ~= nil then
                return tbl[key]
            end
        end
        return nil
    end

    -- ========= CustomWindow =========
    local cw = pick(config, "CustomWindow", "customWindow") or {}

    local BackgroundColor    = pick(cw, "WindowColor", "windowColor")               or pick(config, "BackgroundColor", "backgroundColor") or Color3.fromRGB(10, 10, 15)
    local BackTransparency   = pick(cw, "WindowTransparency", "windowTransparency") or 0
    local BorderColor        = pick(cw, "BorderColor", "borderColor")               or pick(config, "BorderColor", "borderColor") or Color3.fromRGB(80, 80, 90)
    local BorderThickness    = pick(cw, "BorderThickness", "borderThickness") or 4
    local BorderTransparency = pick(cw, "BorderTransparency", "borderTransparency") or 0
    local CornerRadius       = pick(cw, "CornerRadius", "cornerRadius") or 16
    local TitleColor         = pick(cw, "TitleColor", "titleColor")                 or Color3.fromRGB(235, 235, 235)
    local TitleTransparency  = pick(cw, "TitleTransparency", "titleTransparency")   or 0
    local RadarColor         = pick(cw, "RadarColor", "radarColor")                 or Color3.fromRGB(5, 5, 8)
    local RadarTransparency  = pick(cw, "RadarTransparency", "radarTransparency")   or 0
    local GridColor          = pick(cw, "GridColor", "gridColor")                   or Color3.fromRGB(70, 70, 80)
    local CrosshairColor     = pick(cw, "CrosshairColor", "crosshairColor")         or Color3.fromRGB(45, 45, 50)

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

    local WINDOW_SIZE  = 220
    local WINDOW_HEIGHT = 260
    local RADAR_SIZE   = 190
    local BORDER_SIZE  = BorderThickness

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
    frame.BackgroundColor3 = BackgroundColor
    frame.BackgroundTransparency = BackTransparency
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, CornerRadius)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = BorderColor
    frameStroke.Thickness = BORDER_SIZE
    frameStroke.Transparency = BorderTransparency
    frameStroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 4)
    title.Size = UDim2.new(1, -24, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.Text = Title
    title.TextColor3 = TitleColor
    title.TextTransparency = TitleTransparency
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then

            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    title.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local radar = Instance.new("Frame")
    radar.Name = "Radar"
    radar.Size = UDim2.fromOffset(RADAR_SIZE, RADAR_SIZE)
    radar.Position = UDim2.new(
        0.5,
        -RADAR_SIZE / 2,
        0,
        42
    )
    radar.BackgroundColor3 = RadarColor
    radar.BackgroundTransparency = RadarTransparency
    radar.BorderSizePixel = 0
    radar.ClipsDescendants = true
    radar.Parent = frame

    local radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radar

    local radarStroke = Instance.new("UIStroke")
    radarStroke.Color = BorderColor
    radarStroke.Thickness = 3
    radarStroke.Transparency = BorderTransparency
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
        stroke.Color = GridColor
        stroke.Thickness = 1
        stroke.Transparency = transparency or 0
        stroke.Parent = circle

        return circle
    end

    createCircle(0.66, 0)
    createCircle(0.42, 0)

    local horizontalLine = Instance.new("Frame")
    horizontalLine.BackgroundColor3 = CrosshairColor
    horizontalLine.BackgroundTransparency = 0.35
    horizontalLine.BorderSizePixel = 0
    horizontalLine.AnchorPoint = Vector2.new(0, 0.5)
    horizontalLine.Position = UDim2.new(0, 0, 0.5, 0)
    horizontalLine.Size = UDim2.new(1, 0, 0, 1)
    horizontalLine.Parent = radar

    local verticalLine = Instance.new("Frame")
    verticalLine.BackgroundColor3 = CrosshairColor
    verticalLine.BackgroundTransparency = 0.35
    verticalLine.BorderSizePixel = 0
    verticalLine.AnchorPoint = Vector2.new(0.5, 0)
    verticalLine.Position = UDim2.new(0.5, 0, 0, 0)
    verticalLine.Size = UDim2.new(0, 1, 1, 0)
    verticalLine.Parent = radar

    local targetObjects = {}

    local function getRoot(target)
        if not target then
            return nil
        end

        if target:IsA("Player") then
            return target.Character
                and (
                    target.Character:FindFirstChild("HumanoidRootPart")
                    or target.Character.PrimaryPart
                )
        end

        if target:IsA("Model") then
            return target:FindFirstChild("HumanoidRootPart")
                or target.PrimaryPart
                or target:FindFirstChildWhichIsA("BasePart")
        end

        if target:IsA("BasePart") then
            return target
        end

        return nil
    end

    local function ensureText(old)
        if old.text then
            return old.text
        end

        old.text = Instance.new("TextLabel")
        old.text.Name = "Text"
        old.text.BackgroundTransparency = 1
        old.text.AnchorPoint = Vector2.new(0.5, 1)
        old.text.Position = UDim2.new(0.5, 0, 0, -4)
        old.text.Size = UDim2.fromOffset(140, 18)
        old.text.Font = Enum.Font.Gotham
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
        point.Size = UDim2.fromOffset(
            data.size or 8,
            data.size or 8
        )
        point.Parent = radar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = point

        local obj = {
            point = point,
            text = nil,
            data = data,
        }

        if data.text ~= nil then
            local tl = ensureText(obj)
            tl.Text = tostring(data.text)
            tl.TextColor3 = data.color or Color3.new(1, 1, 1)
        end

        targetObjects[data.id] = obj
    end

    local function setTarget(data)
        if not data or not data.id then
            return
        end

        local old = targetObjects[data.id]

        if not old then
            targets[data.id] = data
            createTarget(data)
            return
        end

        local saved = old.data

        for key, value in pairs(data) do
            saved[key] = value
        end

        old.point.BackgroundColor3 =
            saved.color or Color3.new(1, 1, 1)

        local pointSize = saved.size or 8

        old.point.Size = UDim2.fromOffset(
            pointSize,
            pointSize
        )

        if saved.text ~= nil then
            local tl = ensureText(old)
            tl.Text = tostring(saved.text)
            tl.TextColor3 = saved.color or Color3.new(1, 1, 1)
        end

        if saved.visible == false then
            old.point.Visible = false
        end

        targets[data.id] = saved
    end

    if config.Targets then
        for _, data in ipairs(config.Targets) do
            setTarget(data)
        end
    end

    local function getCenterPosition()
        local root = getRoot(Center)

        if root then
            return root.Position + CenterOffset
        end

        if typeof(Center) == "Vector3" then
            return Center + CenterOffset
        end

        if typeof(Center) == "CFrame" then
            return Center.Position + CenterOffset
        end

        return nil
    end

    local function updateTarget(id, object)
        local data = object.data
        local targetRoot = getRoot(data.target)
        local centerPosition = getCenterPosition()

        if not targetRoot
            or not centerPosition
            or data.visible == false then

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

        if not camera then
            return
        end

        local forward = Vector3.new(
            camera.CFrame.LookVector.X,
            0,
            camera.CFrame.LookVector.Z
        )

        local right = Vector3.new(
            camera.CFrame.RightVector.X,
            0,
            camera.CFrame.RightVector.Z
        )

        if forward.Magnitude < 0.001
            or right.Magnitude < 0.001 then
            return
        end

        forward = forward.Unit
        right = right.Unit

        local x = offset:Dot(right)
        local y = offset:Dot(forward)

        local normalizedDistance = distance / Size

        if normalizedDistance > 1 then
            normalizedDistance = 1
        end

        local direction = Vector2.new(x, y)

        if direction.Magnitude > 0 then
            direction =
                direction.Unit * normalizedDistance
        end

        object.point.Position = UDim2.new(
            0.5 + direction.X * 0.5,
            0,
            0.5 - direction.Y * 0.5,
            0
        )

        if object.text then
            object.text.Visible = normalizedDistance < EDGE_TEXT_HIDE_THRESHOLD
        end
    end

    local renderName = Name .. "_RadarUpdate"

    RunService:BindToRenderStep(
        renderName,
        Enum.RenderPriority.Camera.Value + 1,
        function()
            if not enabled then
                return
            end

            for id, object in pairs(targetObjects) do
                updateTarget(id, object)
            end
        end
    )

    local api = {}

    function api:Set(
        listOrId,
        target,
        text,
        color,
        pointSize,
        visible
    )
        if type(listOrId) == "table" then
            for _, data in ipairs(listOrId) do
                setTarget(data)
            end

            return
        end

        setTarget({
            id = listOrId,
            target = target,
            text = text,
            color = color,
            size = pointSize,
            visible = visible,
        })
    end

    function api:SetTitle(newTitle)
        title.Text = tostring(newTitle)
    end

    function api:SetCenter(newCenter)
        Center = newCenter
    end

    function api:SetCenterOffset(newOffset)
        CenterOffset = newOffset or Vector3.zero
    end

    function api:SetRange(value)
        Range = math.max(
            tonumber(value) or Range,
            0
        )
    end

    function api:SetSize(value)
        Size = math.max(
            tonumber(value) or Size,
            0.01
        )
    end

    function api:RemoveTarget(id)
        targets[id] = nil

        local object = targetObjects[id]

        if object then
            object.point:Destroy()
            targetObjects[id] = nil
        end
    end

    function api:Clear()
        for id, object in pairs(targetObjects) do
            object.point:Destroy()
            targetObjects[id] = nil
            targets[id] = nil
        end
    end

    function api:Visible(state)
        enabled = state ~= false
        gui.Enabled = enabled
    end

    function api:SetScale(value)
        Scale = tonumber(value) or Scale
        scaleObject.Scale = Scale
    end

    function api:SetPosition(value)
        Position = value
        frame.Position = value
    end

    function api:Remove()
        RunService:UnbindFromRenderStep(renderName)
        gui:Destroy()
    end

        function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "WindowColor", "windowColor")
        if v ~= nil then BackgroundColor = v; frame.BackgroundColor3 = v end
        v = pick(tbl, "WindowTransparency", "windowTransparency")
        if v ~= nil then BackTransparency = v; frame.BackgroundTransparency = v end

        v = pick(tbl, "BorderColor", "borderColor")
        if v ~= nil then
            BorderColor = v
            frameStroke.Color = v
            radarStroke.Color = v
        end
        v = pick(tbl, "BorderThickness", "borderThickness")
        if v ~= nil then BorderThickness = v; frameStroke.Thickness = v end
        v = pick(tbl, "BorderTransparency", "borderTransparency")
        if v ~= nil then
            BorderTransparency = v
            frameStroke.Transparency = v
            radarStroke.Transparency = v
        end

        v = pick(tbl, "CornerRadius", "cornerRadius")
        if v ~= nil then
            CornerRadius = v
            frameCorner.CornerRadius = UDim.new(0, v)
        end

        v = pick(tbl, "TitleColor", "titleColor")
        if v ~= nil then TitleColor = v; title.TextColor3 = v end
        v = pick(tbl, "TitleTransparency", "titleTransparency")
        if v ~= nil then TitleTransparency = v; title.TextTransparency = v end

        v = pick(tbl, "RadarColor", "radarColor")
        if v ~= nil then RadarColor = v; radar.BackgroundColor3 = v end
        v = pick(tbl, "RadarTransparency", "radarTransparency")
        if v ~= nil then RadarTransparency = v; radar.BackgroundTransparency = v end

        v = pick(tbl, "GridColor", "gridColor")
        if v ~= nil then
            GridColor = v
            for _, child in ipairs(radar:GetChildren()) do
                if child:IsA("Frame") then
                    local s = child:FindFirstChildOfClass("UIStroke")
                    if s then s.Color = v end
                end
            end
        end

        v = pick(tbl, "CrosshairColor", "crosshairColor")
        if v ~= nil then
            CrosshairColor = v
            horizontalLine.BackgroundColor3 = v
            verticalLine.BackgroundColor3 = v
        end
    end

    return api
end

return {
    createInfoGui = createInfoGui,
    createInfoText = createInfoText,
    createRadar = createRadar
}
