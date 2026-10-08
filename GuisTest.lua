function createInfoGui(config)
    config = config or {}

    local TweenService       = game:GetService("TweenService")
    local UserInputService   = game:GetService("UserInputService")
    local CoreGui            = game:GetService("CoreGui")

    local guiName = config.Name or "CustomWindow"
    local title   = config.Title or "Window"
    local width   = config.Width or 200
    local scale   = config.Scale or 1
    local position= config.Position or UDim2.new(0.05, 0, 0.15, 0)
    local textSize= config.TextSize or 14

    local defaultOutlineColor = config.outlineColor or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize  = config.outlineSize

    local headerHeight  = 32
    local bottomPadding = 7
    local linePadding   = 2

    local expandedBackground = Color3.fromRGB(30, 30, 35)
    local headerBackground   = Color3.fromRGB(35, 35, 42)
    local borderColor        = Color3.fromRGB(65, 65, 75)
    local accentColor        = config.AccentColor or Color3.fromRGB(90, 145, 255)

    local tweenInfo = TweenInfo.new(
        config.TweenTime or 0.22,
        Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out
    )

    -- Отдельный tween для плавного появления строк
    local lineFadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

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
    titleLabel.TextSize = textSize + 1
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

    -- ⬇⬇⬇ ФИКС: правильный размер контейнера + не обрезаем содержимое
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

    local labels         = {}
    local lineData       = {}
    local creationCounter= 0

    local collapsed = config.Collapsed == true
    local activeTween
    local contentHeight = 0

    local function getContentHeight()
        local count = 0
        for _ in pairs(labels) do count = count + 1 end
        if count <= 0 then return 0 end
        return count * textSize + math.max(0, count - 1) * linePadding
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
            -- если строка только что создана — прозрачность выставим вручную при fade-in
            stroke.Transparency = collapsed and 1 or 0
        elseif stroke then
            stroke:Destroy()
        end
    end

    local function updateOrder()
        local explicit      = {}
        local withoutOrder  = {}

        for _, data in pairs(lineData) do
            if data.order ~= nil then
                table.insert(explicit, data)
            else
                table.insert(withoutOrder, data)
            end
        end

        table.sort(explicit, function(a, b)
            if a.order == b.order then return a.created < b.created end
            return a.order < b.order
        end)

        table.sort(withoutOrder, function(a, b)
            return a.created < b.created
        end)

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
            label.Size = UDim2.new(1, 0, 0, textSize)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.TextTransparency = 1  -- стартуем невидимыми → потом fade-in
            label.Parent = container

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft  = UDim.new(0, 8)
            padding.PaddingRight = UDim.new(0, 8)
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

        if data.text         ~= nil then saved.text = data.text end
        if data.color        ~= nil then saved.color = data.color end
        if data.outlineColor ~= nil then saved.outlineColor = data.outlineColor end
        if data.outlineSize  ~= nil then
            saved.outlineSize = data.outlineSize == false and nil or data.outlineSize
        end
        if data.order        ~= nil then
            saved.order = data.order == false and nil or data.order
        end

        label.Text = saved.text
        label.TextColor3 = saved.color
        applyOutline(label, saved)

        -- ⬇⬇⬇ FADE-IN для новой строки
        if isNew and not collapsed then
            local stroke = label:FindFirstChild("Outline")
            if stroke then stroke.Transparency = 1 end

            TweenService:Create(label, lineFadeInfo, { TextTransparency = 0 }):Play()
            if stroke then
                TweenService:Create(stroke, lineFadeInfo, { Transparency = 0 }):Play()
            end
        end
    end

    local function setText(lines)
        if not lines then return end

        for _, data in ipairs(lines) do
            setLine(data)
        end

        updateOrder()
        updateFrameSize(true)  -- плавное изменение размера окна
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

    -- ==== drag ====
    local dragging, dragInput, dragStart, startPos

    local function updateDrag(input)
        if not dragging or not dragStart or not startPos then return end
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
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

    function api:SetText(lines) setText(lines) end

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

    function api:Visible(state) screen.Enabled = state end
    function api:SetScale(value) uiScale.Scale = value or 1 end
    function api:SetPosition(value) if value then frame.Position = value end end
    function api:SetTitle(newTitle) title = tostring(newTitle); titleLabel.Text = title end
    function api:Collapse(state) setCollapsed(state, true) end
    function api:Toggle() setCollapsed(not collapsed, true) end
    function api:IsCollapsed() return collapsed end

    function api:Remove()
        if activeTween then activeTween:Cancel(); activeTween = nil end
        if screen then screen:Destroy(); screen = nil end
    end

    return api
end

function createInfoText(config)
    config = config or {}

    local name = config.Name or "GhostRoomESP"
    local center = config.Center
    local offset = config.Offset or Vector3.new(0, 3, 0)
    local textSize = config.TextSize or 20
    local size = config.Size or UDim2.new(0, 300, 0, 50)
    local defaultOutlineColor = config.outlineColor or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize = config.outlineSize

    local billboard
    local container
    local labels = {}
    local lineData = {}
    local creationCounter = 0
    local currentAdornee
    local isActive = true

    -- Строки, которые ещё не удалось отрисовать (нет валидного adornee)
    local pendingOrder = {}   -- массив id в порядке поступления
    local pendingData  = {}   -- id -> data

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
        local explicit     = {}
        local withoutOrder = {}

        for _, data in pairs(lineData) do
            if data.order ~= nil then
                table.insert(explicit, data)
            else
                table.insert(withoutOrder, data)
            end
        end

        table.sort(explicit, function(a, b)
            if a.order == b.order then return a.created < b.created end
            return a.order < b.order
        end)

        table.sort(withoutOrder, function(a, b)
            return a.created < b.created
        end)

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

    local function updateSize()
        if not billboard then return end

        local count = 0
        for _ in pairs(labels) do count = count + 1 end

        local height = math.max(
            20,
            count * textSize + math.max(0, count - 1) * 2
        )

        billboard.Size = UDim2.new(
            size.X.Scale,
            size.X.Offset,
            0,
            height
        )
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

        container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboard

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        layout.Parent = container

        return true
    end

    local setLine  -- forward declaration

    local function flushPending()
        if #pendingOrder == 0 then return end

        local savedOrder = pendingOrder
        local savedData  = pendingData
        pendingOrder = {}
        pendingData  = {}

        for _, id in ipairs(savedOrder) do
            local data = savedData[id]
            if data then
                setLine(data)
            end
        end
    end

    setLine = function(data)
        if not data or not data.id then return end

        if not billboard or not billboard.Parent then
            if not createBillboard() then
                -- Откладываем — отрисуем, когда появится валидный adornee
                if not pendingData[data.id] then
                    table.insert(pendingOrder, data.id)
                end
                pendingData[data.id] = data
                return
            end

            -- Только что создали билборд — проливаем то, что накопилось
            flushPending()
        end

        local id = data.id
        local label = labels[id]

        if not label then
            creationCounter = creationCounter + 1

            label = Instance.new("TextLabel")
            label.Name = id
            label.Size = UDim2.new(1, 0, 0, textSize)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Center
            label.TextYAlignment = Enum.TextYAlignment.Center
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

        if data.text         ~= nil then saved.text = data.text end
        if data.color        ~= nil then saved.color = data.color end
        if data.outlineColor ~= nil then saved.outlineColor = data.outlineColor end
        if data.outlineSize  ~= nil then
            saved.outlineSize = data.outlineSize == false and nil or data.outlineSize
        end
        if data.order        ~= nil then
            saved.order = data.order == false and nil or data.order
        end

        label.Text = saved.text
        label.TextColor3 = saved.color

        applyOutline(label, saved)
    end

    local function setText(lines)
        if not lines then return end

        for _, data in ipairs(lines) do
            setLine(data)
        end

        updateOrder()
        updateSize()
    end

    for _, data in ipairs(config.Lines or {}) do
        setLine(data)
    end

    if billboard then
        updateOrder()
        updateSize()
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
            updateSize()
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
            updateSize()
        end
    end

    function api:SetOffset(newOffset)
        if not newOffset then return end
        offset = newOffset
        if billboard then
            billboard.StudsOffset = newOffset
        end
    end

    function api:SetSize(newSize)
        if not newSize then return end
        size = newSize
        if billboard then
            updateSize()
        end
    end

    function api:Remove()
        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
        end

        labels = {}
        lineData = {}
        pendingOrder = {}
        pendingData = {}
    end

    return api
end

return {
    createInfoGui = createInfoGui,
    createInfoText = createInfoText,
    createRadar = createRadar
}
