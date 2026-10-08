function createInfoGui(config)
    config = config or {}

    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local CoreGui = game:GetService("CoreGui")

    local guiName = config.Name or "CustomWindow"
    local title = config.Title or "Window"
    local width = config.Width or 200
    local scale = config.Scale or 1
    local position = config.Position or UDim2.new(0.05, 0, 0.15, 0)
    local textSize = config.TextSize or 14

    local defaultOutlineColor = config.outlineColor or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize = config.outlineSize

    local headerHeight = 32
    local bottomPadding = 7
    local linePadding = 2

    local expandedBackground = Color3.fromRGB(30, 30, 35)
    local headerBackground = Color3.fromRGB(35, 35, 42)
    local borderColor = Color3.fromRGB(65, 65, 75)
    local accentColor = config.AccentColor or Color3.fromRGB(90, 145, 255)

    local tweenInfo = TweenInfo.new(
        config.TweenTime or 0.22,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local lineFadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    local screen = CoreGui:FindFirstChild(guiName)

    if screen then
        screen:Destroy()
    end

    screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, width, 0, headerHeight)
    frame.Position = position
    frame.BackgroundColor3 = expandedBackground
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.ClipsDescendants = true
    frame.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Name = "Border"
    frameStroke.Color = borderColor
    frameStroke.Thickness = 1
    frameStroke.Transparency = 0.15
    frameStroke.Parent = frame

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = scale
    uiScale.Parent = frame

    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
    shadow.Size = UDim2.new(1, 6, 1, 6)
    shadow.BackgroundColor3 = Color3.new(0, 0, 0)
    shadow.BackgroundTransparency = 0.65
    shadow.BorderSizePixel = 0
    shadow.ZIndex = -1
    shadow.Parent = frame

    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 9)
    shadowCorner.Parent = shadow

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.BackgroundColor3 = headerBackground
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 2
    header.Parent = frame

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 8)
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
    titleLabel.TextColor3 = Color3.fromRGB(245, 245, 248)
    titleLabel.Font = Enum.Font.GothamSemibold
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
    toggle.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
    toggle.BackgroundTransparency = 0.15
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = "⌃"
    toggle.TextColor3 = Color3.fromRGB(210, 210, 220)
    toggle.Font = Enum.Font.GothamBold
    toggle.TextSize = 15
    toggle.ZIndex = 4
    toggle.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = toggle

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Position = UDim2.new(0, 0, 0, headerHeight)
    container.Size = UDim2.new(1, 0, 1, -headerHeight)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, linePadding)
    layout.Parent = container

    local labels = {}
    local lineData = {}
    local creationCounter = 0

    local collapsed = config.Collapsed == true
    local activeTween
    local contentHeight = 0

    -- Исправлено: теперь высота берется из UIListLayout, что позволяет учитывать перенос строк
    local function getContentHeight()
        local layout = container:FindFirstChildOfClass("UIListLayout")
        if not layout then
            return 0
        end
        return layout.AbsoluteContentSize.Y
    end

    local function getExpandedHeight()
        return headerHeight + contentHeight + bottomPadding
    end

    local function setContentTransparency(transparency, instant)
        for _, label in pairs(labels) do
            if instant then
                label.TextTransparency = transparency
            else
                TweenService:Create(label, tweenInfo, {
                    TextTransparency = transparency
                }):Play()
            end

            local stroke = label:FindFirstChild("Outline")

            if stroke then
                if instant then
                    stroke.Transparency = transparency
                else
                    TweenService:Create(stroke, tweenInfo, {
                        Transparency = transparency
                    }):Play()
                end
            end
        end
    end

    local function updateFrameSize(animate)
        contentHeight = getContentHeight()

        local targetHeight = collapsed and headerHeight or getExpandedHeight()

        if activeTween then
            activeTween:Cancel()
            activeTween = nil
        end

        if animate then
            activeTween = TweenService:Create(
                frame,
                tweenInfo,
                { Size = UDim2.new(0, width, 0, targetHeight) }
            )

            activeTween:Play()
        else
            frame.Size = UDim2.new(0, width, 0, targetHeight)
        end
    end

    -- Автоматическое обновление размера окна при изменении высоты контента (из-за переноса строк)
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if not collapsed then
            updateFrameSize(true)
        end
    end)

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
        local explicit = {}
        local withoutOrder = {}

        for _, data in pairs(lineData) do
            if data.order ~= nil then
                table.insert(explicit, data)
            else
                table.insert(withoutOrder, data)
            end
        end

        table.sort(explicit, function(a, b)
            if a.order == b.order then
                return a.created < b.created
            end
            return a.order < b.order
        end)

        table.sort(withoutOrder, function(a, b)
            return a.created < b.created
        end)

        local used = {}

        for _, data in ipairs(explicit) do
            local order = math.max(1, math.floor(data.order))

            while used[order] do
                order = order + 1
            end

            used[order] = true
            labels[data.id].LayoutOrder = order
        end

        local current = 1

        for _, data in ipairs(withoutOrder) do
            while used[current] do
                current = current + 1
            end

            used[current] = true
            labels[data.id].LayoutOrder = current
            current = current + 1
        end
    end

    local function setLine(data)
        if not data or not data.id then
            return
        end

        local id = data.id
        local label = labels[id]
        local isNew = label == nil

        if isNew then
            creationCounter = creationCounter + 1

            label = Instance.new("TextLabel")
            label.Name = id
            -- Исправлено: высота теперь автоматическая (0), чтобы TextWrapped работал корректно
            label.Size = UDim2.new(1, 0, 0, 0)
            label.AutomaticSize = Enum.AutomaticSize.Y
            label.TextWrapped = true
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.GothamMedium
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Top
            label.TextTransparency = 1
            label.Parent = container

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
            padding.PaddingTop = UDim.new(0, 2)
            padding.PaddingBottom = UDim.new(0, 2)
            padding.Parent = label

            labels[id] = label

            lineData[id] = {
                id = id,
                text = "",
                color = Color3.fromRGB(255, 255, 255),
                outlineColor = defaultOutlineColor,
                outlineSize = defaultOutlineSize,
                order = nil,
                created = creationCounter
            }
        end

        local saved = lineData[id]

        if data.text ~= nil then
            saved.text = data.text
        end

        if data.color ~= nil then
            saved.color = data.color
        end

        if data.outlineColor ~= nil then
            saved.outlineColor = data.outlineColor
        end

        if data.outlineSize ~= nil then
            saved.outlineSize = data.outlineSize == false and nil or data.outlineSize
        end

        if data.order ~= nil then
            saved.order = data.order == false and nil or data.order
        end

        label.Text = saved.text
        label.TextColor3 = saved.color

        applyOutline(label, saved)

        if isNew and not collapsed then
            local stroke = label:FindFirstChild("Outline")

            if stroke then
                stroke.Transparency = 1
            end

            TweenService:Create(label, lineFadeInfo, {
                TextTransparency = 0
            }):Play()

            if stroke then
                TweenService:Create(stroke, lineFadeInfo, {
                    Transparency = 0
                }):Play()
            end
        end
    end

    local function setText(lines)
        if not lines then
            return
        end

        for _, data in ipairs(lines) do
            setLine(data)
        end

        updateOrder()
        updateFrameSize(true)

        if not collapsed then
            setContentTransparency(0, false)
        end
    end

    local function setCollapsed(state, animate)
        collapsed = state == true

        toggle.Text = collapsed and "⌄" or "⌃"

        if collapsed then
            setContentTransparency(1, not animate)
        end

        updateFrameSize(animate)

        if not collapsed then
            setContentTransparency(0, not animate)
        end
    end

    for _, data in ipairs(config.Lines or {}) do
        setLine(data)
    end

    updateOrder()
    contentHeight = getContentHeight()

    if collapsed then
        setContentTransparency(1, true)
    end

    updateFrameSize(false)

    local dragging = false
    local dragInput
    local dragStart
    local startPos

    local function updateDrag(input)
        if not dragging or not dragStart or not startPos then
            return
        end

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end

    header.InputBegan:Connect(function(input)
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

    header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then

            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput then
            updateDrag(input)
        end
    end)

    toggle.MouseEnter:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = accentColor,
            TextColor3 = Color3.new(1, 1, 1)
        }):Play()
    end)

    toggle.MouseLeave:Connect(function()
        TweenService:Create(toggle, TweenInfo.new(0.12), {
            BackgroundColor3 = Color3.fromRGB(48, 48, 58),
            TextColor3 = Color3.fromRGB(210, 210, 220)
        }):Play()
    end)

    toggle.MouseButton1Click:Connect(function()
        setCollapsed(not collapsed, true)
    end)

    local api = {}

    function api:SetText(lines)
        setText(lines)
    end

    function api:RemoveLine(id)
        local label = labels[id]

        if label then
            label:Destroy()
            labels[id] = nil
            lineData[id] = nil

            updateOrder()
            updateFrameSize(true)
        end
    end

    function api:Visible(state)
        screen.Enabled = state
    end

    function api:SetScale(value)
        uiScale.Scale = value or 1
    end

    function api:SetPosition(value)
        if value then
            frame.Position = value
        end
    end

    function api:SetTitle(newTitle)
        title = tostring(newTitle)
        titleLabel.Text = title
    end

    function api:Collapse(state)
        setCollapsed(state, true)
    end

    function api:Toggle()
        setCollapsed(not collapsed, true)
    end

    function api:IsCollapsed()
        return collapsed
    end

    function api:Remove()
        if activeTween then
            activeTween:Cancel()
            activeTween = nil
        end

        if screen then
            screen:Destroy()
            screen = nil
        end
    end

    return api
end

function createInfoText(config)
    config = config or {}

    local TweenService = game:GetService("TweenService")

    local name = config.Name or "GhostRoomESP"
    local center = config.Center
    local offset = config.Offset or Vector3.new(0, 3, 0)
    local baseTextSize = config.TextSize or 20
    local textSize = baseTextSize
    local size = config.Size or UDim2.new(0, 300, 0, 0)
    local baseSize = size -- Сохраняем базовый размер для масштабирования
    local defaultOutlineColor = config.outlineColor or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize = config.outlineSize

    -- ShowWindow: рисует фон под текстом
    local showWindow = config.ShowWindow == true

    -- Стиль окна — захардкожен так же, как в createInfoGui
    local windowBackground          = Color3.fromRGB(30, 30, 35)
    local windowBorderColor         = Color3.fromRGB(65, 65, 75)
    local windowBorderThickness     = 1
    local windowBorderTransparency  = 0.15
    local windowBackgroundTransparency = 0.15
    local windowPadding             = 8
    local windowCorner              = 8

    local sizeTweenInfo = TweenInfo.new(
        config.TweenTime or 0.22,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    local billboard
    local container
    local windowFrame
    local labels = {}
    local lineData = {}
    local creationCounter = 0
    local currentAdornee
    local isActive = true
    local activeSizeTween

    local pendingOrder = {}
    local pendingData = {}

    local function resolveAdornee(target)
        if not target then
            return nil
        end

        if target:IsA("Model") then
            target = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
        end

        if not target or not target:IsA("BasePart") then
            return nil
        end

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
        local explicit = {}
        local withoutOrder = {}

        for _, data in pairs(lineData) do
            if data.order ~= nil then
                table.insert(explicit, data)
            else
                table.insert(withoutOrder, data)
            end
        end

        table.sort(explicit, function(a, b)
            if a.order == b.order then
                return a.created < b.created
            end
            return a.order < b.order
        end)

        table.sort(withoutOrder, function(a, b)
            return a.created < b.created
        end)

        local used = {}

        for _, data in ipairs(explicit) do
            local order = math.max(1, math.floor(data.order))

            while used[order] do
                order = order + 1
            end

            used[order] = true
            labels[data.id].LayoutOrder = order
        end

        local current = 1

        for _, data in ipairs(withoutOrder) do
            while used[current] do
                current = current + 1
            end

            used[current] = true
            labels[data.id].LayoutOrder = current
            current = current + 1
        end
    end

    local function applyWindowLayout()
        if not container then
            return
        end

        local p = showWindow and windowPadding or 0

        container.Position = UDim2.new(0, p, 0, p)
        container.Size = UDim2.new(1, -p * 2, 1, -p * 2)

        if windowFrame then
            windowFrame.Visible = showWindow
        end
    end

    local function updateSize(animate)
        if not billboard then
            return
        end

        -- Исправлено: высота берется из UIListLayout
        local layout = container and container:FindFirstChildOfClass("UIListLayout")
        local layoutHeight = layout and layout.AbsoluteContentSize.Y or 0

        local extra = showWindow and (windowPadding * 2) or 0

        local autoHeight = math.max(
            textSize + extra,
            layoutHeight + extra
        )

        local targetHeight
        if size.Y.Offset and size.Y.Offset > 0 then
            targetHeight = size.Y.Offset
        else
            targetHeight = autoHeight
        end

        local targetSize = UDim2.new(
            size.X.Scale,
            size.X.Offset,
            0,
            targetHeight
        )

        if activeSizeTween then
            activeSizeTween:Cancel()
            activeSizeTween = nil
        end

        if animate then
            activeSizeTween = TweenService:Create(
                billboard,
                sizeTweenInfo,
                { Size = targetSize }
            )
            activeSizeTween:Play()
        else
            billboard.Size = targetSize
        end
    end

    local function createBillboard()
        local adornee = resolveAdornee(center)

        if not adornee then
            return false
        end

        currentAdornee = adornee

        billboard = Instance.new("BillboardGui")
        billboard.Name = name
        billboard.Adornee = adornee
        billboard.Size = size
        billboard.StudsOffset = offset
        billboard.AlwaysOnTop = true
        billboard.Enabled = isActive
        billboard.Parent = adornee

        -- Фон/обводка окна (тот же стиль, что и у createInfoGui)
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

        -- Автоматическое обновление размера при изменении контента
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            updateSize(true)
        end)

        applyWindowLayout()

        return true
    end

    local setLine

    local function flushPending()
        if #pendingOrder == 0 then
            return
        end

        local savedOrder = pendingOrder
        local savedData = pendingData
        pendingOrder = {}
        pendingData = {}

        for _, id in ipairs(savedOrder) do
            local data = savedData[id]
            if data then
                setLine(data)
            end
        end
    end

    setLine = function(data)
        if not data or not data.id then
            return
        end

        if not billboard or not billboard.Parent then
            if not createBillboard() then
                if not pendingData[data.id] then
                    table.insert(pendingOrder, data.id)
                end
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
            -- Исправлено: автоматическая высота и перенос строк
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
                id = id,
                text = "",
                color = Color3.fromRGB(255, 255, 255),
                outlineColor = defaultOutlineColor,
                outlineSize = defaultOutlineSize,
                order = nil,
                created = creationCounter
            }
        end

        local saved = lineData[id]

        if data.text ~= nil then
            saved.text = data.text
        end

        if data.color ~= nil then
            saved.color = data.color
        end

        if data.outlineColor ~= nil then
            saved.outlineColor = data.outlineColor
        end

        if data.outlineSize ~= nil then
            saved.outlineSize = data.outlineSize == false and nil or data.outlineSize
        end

        if data.order ~= nil then
            saved.order = data.order == false and nil or data.order
        end

        label.Text = saved.text
        label.TextColor3 = saved.color

        applyOutline(label, saved)
    end

    local function setText(lines)
        if not lines then
            return
        end

        for _, data in ipairs(lines) do
            setLine(data)
        end

        updateOrder()
        updateSize(true)
    end

    for _, data in ipairs(config.Lines or {}) do
        setLine(data)
    end

    if billboard then
        updateOrder()
        updateSize(false)
    end

    local api = {}

    function api:SetText(lines)
        setText(lines)
    end

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

    function api:Visible(state)
        isActive = state

        if billboard then
            billboard.Enabled = state
        end
    end

    function api:SetCenter(newCenter)
        local adornee = resolveAdornee(newCenter)

        if not adornee then
            return
        end

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
        if not newOffset then
            return
        end

        offset = newOffset

        if billboard then
            billboard.StudsOffset = newOffset
        end
    end

    -- SetSize:
    --   число  -> множитель текста и размера окна (1 = дефолт)
    --   UDim2  -> размер окна билборда (при этом текст масштабируется пропорционально ширине)
    function api:SetSize(newSize)
        if newSize == nil then
            return
        end

        if type(newSize) == "number" then
            local scale = math.max(newSize, 0.1)
            textSize = baseTextSize * scale

            if not baseSize then
                baseSize = size
            end

            size = UDim2.new(
                baseSize.X.Scale,
                baseSize.X.Offset * scale,
                baseSize.Y.Scale,
                baseSize.Y.Offset * scale
            )

            for _, label in pairs(labels) do
                label.TextSize = textSize
                label.Size = UDim2.new(1, 0, 0, 0)
            end

            updateSize(true)
        elseif typeof(newSize) == "UDim2" then
            -- Вычисляем коэффициент масштабирования текста на основе изменения ширины
            if size.X.Offset > 0 and newSize.X.Offset > 0 then
                local ratio = newSize.X.Offset / size.X.Offset
                textSize = textSize * ratio
                baseTextSize = baseTextSize * ratio

                for _, label in pairs(labels) do
                    label.TextSize = textSize
                    label.Size = UDim2.new(1, 0, 0, 0)
                end
            elseif size.X.Scale > 0 and newSize.X.Scale > 0 then
                local ratio = newSize.X.Scale / size.X.Scale
                textSize = textSize * ratio
                baseTextSize = baseTextSize * ratio

                for _, label in pairs(labels) do
                    label.TextSize = textSize
                    label.Size = UDim2.new(1, 0, 0, 0)
                end
            end

            size = newSize

            if billboard then
                updateSize(true)
            end
        end
    end

    function api:ShowWindow(state)
        showWindow = state == true

        if billboard then
            applyWindowLayout()
            updateSize(true)
        end
    end

    function api:IsWindowShown()
        return showWindow
    end

    function api:Remove()
        if activeSizeTween then
            activeSizeTween:Cancel()
            activeSizeTween = nil
        end

        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
            windowFrame = nil
        end

        labels = {}
        lineData = {}
        pendingOrder = {}
        pendingData = {}
    end

    return api
end

local function createRadar(config)
    config = config or {}

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local Name = config.Name or "CustomRadar"
    local Title = config.Title or "Radar"
    local Position = config.Position or UDim2.new(0.03, 0, 0.3, 0)

    local Size = math.max(tonumber(config.Size) or 100, 0.01)
    local Scale = tonumber(config.Scale) or 1
    local Range = math.max(tonumber(config.Range) or 100, 0)

    local Center = config.Center or Players.LocalPlayer
    local CenterOffset = config.CenterOffset or Vector3.zero

    local BackgroundColor = config.BackgroundColor or Color3.fromRGB(10, 10, 15)
    local BorderColor = config.BorderColor or Color3.fromRGB(80, 80, 90)

    local EDGE_TEXT_HIDE_THRESHOLD = tonumber(config.TextHideThreshold) or 0.95

    local enabled = true
    local targets = {}

    local WINDOW_SIZE = 220
    local WINDOW_HEIGHT = 260
    local RADAR_SIZE = 190
    local BORDER_SIZE = 4

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
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 16)
    frameCorner.Parent = frame

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = BorderColor
    frameStroke.Thickness = BORDER_SIZE
    frameStroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(12, 4)
    title.Size = UDim2.new(1, -24, 0, 28)
    title.Font = Enum.Font.GothamBold
    title.Text = Title
    title.TextColor3 = Color3.fromRGB(235, 235, 235)
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
    radar.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    radar.BorderSizePixel = 0
    radar.ClipsDescendants = true
    radar.Parent = frame

    local radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radar

    local radarStroke = Instance.new("UIStroke")
    radarStroke.Color = BorderColor
    radarStroke.Thickness = 3
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
        stroke.Color = Color3.fromRGB(70, 70, 80)
        stroke.Thickness = 1
        stroke.Transparency = transparency or 0
        stroke.Parent = circle

        return circle
    end

    createCircle(0.66, 0)
    createCircle(0.42, 0)

    local horizontalLine = Instance.new("Frame")
    horizontalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
    horizontalLine.BackgroundTransparency = 0.35
    horizontalLine.BorderSizePixel = 0
    horizontalLine.AnchorPoint = Vector2.new(0, 0.5)
    horizontalLine.Position = UDim2.new(0, 0, 0.5, 0)
    horizontalLine.Size = UDim2.new(1, 0, 0, 1)
    horizontalLine.Parent = radar

    local verticalLine = Instance.new("Frame")
    verticalLine.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
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
        old.text.ZIndex = 11                       -- поверх точки и обводки круга
        old.text.Parent = old.point

        return old.text
    end

    local function createTarget(data)
        local point = Instance.new("Frame")
        point.Name = tostring(data.id)
        point.AnchorPoint = Vector2.new(0.5, 0.5)
        point.BackgroundColor3 = data.color or Color3.new(1, 1, 1)
        point.BorderSizePixel = 0
        point.ZIndex = 10                          -- поверх обводки круга
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

    return api
end

return {
    createInfoGui = createInfoGui,
    createInfoText = createInfoText,
    createRadar = createRadar
}
