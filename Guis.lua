function createInfoGui(config)
    config = config or {}

    local guiName = config.Name or "CustomWindow"
    local title = config.Title or "Window"
    local width = config.Width or 200
    local scale = config.Scale or 1
    local position = config.Position or UDim2.new(0.05, 0, 0.15, 0)
    local textSize = config.TextSize or 14
    local defaultOutlineColor = config.outlineColor or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize = config.outlineSize

    local coreGui = game:GetService("CoreGui")
    local screen = coreGui:FindFirstChild(guiName)

    if screen then
        screen:Destroy()
    end

    screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = coreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, width, 0, 0)
    frame.Position = position
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.AutomaticSize = Enum.AutomaticSize.Y
    frame.Parent = screen

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = scale
    uiScale.Parent = frame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Size = UDim2.new(1, 0, 0, 30)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.TextSize = textSize + 1
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 8)
    titlePadding.Parent = titleLabel

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Position = UDim2.new(0, 0, 0, 30)
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = container

    local labels = {}
    local lineData = {}
    local creationCounter = 0

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

        for id, data in pairs(lineData) do
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

        if not label then
            creationCounter = creationCounter + 1

            label = Instance.new("TextLabel")
            label.Name = id
            label.Size = UDim2.new(1, 0, 0, textSize)
            label.BackgroundTransparency = 1
            label.Font = Enum.Font.SourceSans
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft = UDim.new(0, 8)
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
    end

    for _, data in ipairs(config.Lines or {}) do
        setLine(data)
    end

    updateOrder()

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

    function api:Remove()
        screen:Destroy()
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
    local isActive = false

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

        for id, data in pairs(lineData) do
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

    local function updateSize()
        local count = 0

        for _ in pairs(labels) do
            count = count + 1
        end

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

        if not adornee then
            return
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

        container = Instance.new("Frame")
        container.Name = "Container"
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboard

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        layout.Parent = container
    end

    local function setLine(data)
        if not data or not data.id then
            return
        end

        if not billboard or not billboard.Parent then
            createBillboard()

            if not billboard then
                return
            end
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

        if not adornee then
            return
        end

        center = newCenter
        currentAdornee = adornee

        if billboard then
            billboard.Adornee = adornee
            billboard.Parent = adornee
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

    function api:SetSize(newSize)
        if not newSize then
            return
        end

        size = newSize

        if billboard then
            updateSize()
        end
    end

    function api:Remove()
        if billboard then
            billboard:Destroy()
            billboard = nil
        end

        labels = {}
        lineData = {}
    end

    return api
end

return {
    createInfoGui = createInfoGui,
    createInfoText = createInfoText
}
