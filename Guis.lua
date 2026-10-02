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
        if screen then
            screen:Destroy()
        end
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

    local function updateSize()
        if not billboard then
            return
        end

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

    local function setLine(data)
        if not data or not data.id then
            return
        end

        if not billboard or not billboard.Parent then
            if not createBillboard() then
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
            billboard.Enabled = isActive
        else
            createBillboard()
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
            container = nil
        end

        labels = {}
        lineData = {}
    end

    return api
end

function createRadar(config)
    config = config or {}

    local guiName = config.Name or "CustomRadar"
    local title = config.Title or "Radar"
    local position = config.Position or UDim2.new(0.03, 0, 0.3, 0)
    local size = config.Size or 220
    local scale = config.Scale or 1
    local range = config.Range or 100

    local backgroundColor = config.BackgroundColor or Color3.fromRGB(10, 10, 15)
    local borderColor = config.BorderColor or Color3.fromRGB(80, 80, 90)
    local centerColor = config.CenterColor or Color3.fromRGB(255, 255, 255)

    local coreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")

    local localPlayer = Players.LocalPlayer

    local parent = (gethui and gethui()) or coreGui

    local old = parent:FindFirstChild(guiName)
    if old then
        old:Destroy()
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.Parent = parent

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, size, 0, size + 32)
    frame.Position = position
    frame.BackgroundColor3 = backgroundColor
    frame.BackgroundTransparency = 0.08
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screen

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, 10)
    frameCorner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = borderColor
    stroke.Thickness = 1
    stroke.Transparency = 0.2
    stroke.Parent = frame

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
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = frame

    local titlePadding = Instance.new("UIPadding")
    titlePadding.PaddingLeft = UDim.new(0, 8)
    titlePadding.Parent = titleLabel

    local radar = Instance.new("Frame")
    radar.Name = "Radar"
    radar.Size = UDim2.new(0, size, 0, size)
    radar.Position = UDim2.new(0, 0, 0, 32)
    radar.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
    radar.BackgroundTransparency = 0.15
    radar.BorderSizePixel = 0
    radar.ClipsDescendants = true
    radar.Parent = frame

    local radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radar

    local radarStroke = Instance.new("UIStroke")
    radarStroke.Color = borderColor
    radarStroke.Thickness = 2
    radarStroke.Parent = radar

    local centerX = size / 2
    local centerY = size / 2

    -- Круги дистанции

    local function createCircle(scaleValue)
        local circle = Instance.new("Frame")
        circle.Name = "RangeCircle"
        circle.Size = UDim2.new(scaleValue, 0, scaleValue, 0)
        circle.Position = UDim2.new(
            (1 - scaleValue) / 2,
            0,
            (1 - scaleValue) / 2,
            0
        )
        circle.BackgroundTransparency = 1
        circle.BorderSizePixel = 0
        circle.ZIndex = 1
        circle.Parent = radar

        local circleStroke = Instance.new("UIStroke")
        circleStroke.Color = Color3.fromRGB(70, 70, 80)
        circleStroke.Thickness = 1
        circleStroke.Transparency = 0.65
        circleStroke.Parent = circle

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = circle

        return circle
    end

    createCircle(0.5)
    createCircle(0.75)

    -- Центральный крест

    local vertical = Instance.new("Frame")
    vertical.Name = "Vertical"
    vertical.Size = UDim2.new(0, 1, 0, size)
    vertical.Position = UDim2.new(0.5, 0, 0, 0)
    vertical.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    vertical.BackgroundTransparency = 0.6
    vertical.BorderSizePixel = 0
    vertical.ZIndex = 2
    vertical.Parent = radar

    local horizontal = Instance.new("Frame")
    horizontal.Name = "Horizontal"
    horizontal.Size = UDim2.new(1, 0, 0, 1)
    horizontal.Position = UDim2.new(0, 0, 0.5, 0)
    horizontal.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    horizontal.BackgroundTransparency = 0.6
    horizontal.BorderSizePixel = 0
    horizontal.ZIndex = 2
    horizontal.Parent = radar

    -- Центральная точка игрока

    local centerDot = Instance.new("Frame")
    centerDot.Name = "LocalPlayer"
    centerDot.Size = UDim2.new(0, 8, 0, 8)
    centerDot.Position = UDim2.new(0.5, -4, 0.5, -4)
    centerDot.BackgroundColor3 = centerColor
    centerDot.BorderSizePixel = 0
    centerDot.ZIndex = 10
    centerDot.Parent = radar

    local centerCorner = Instance.new("UICorner")
    centerCorner.CornerRadius = UDim.new(1, 0)
    centerCorner.Parent = centerDot

    local targets = {}

    local function resolvePosition(target)
        if not target then
            return nil
        end

        if typeof(target) == "Instance" then
            if target:IsA("Player") then
                local character = target.Character

                if not character then
                    return nil
                end

                local root = character:FindFirstChild("HumanoidRootPart")
                    or character.PrimaryPart

                return root and root.Position or nil
            end

            if target:IsA("Model") then
                local root = target.PrimaryPart
                    or target:FindFirstChild("HumanoidRootPart")
                    or target:FindFirstChildWhichIsA("BasePart")

                return root and root.Position or nil
            end

            if target:IsA("BasePart") then
                return target.Position
            end
        end

        return nil
    end

    local function createTarget(data)
        local dot = Instance.new("Frame")
        dot.Name = data.id
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Size = UDim2.new(0, data.size or 8, 0, data.size or 8)
        dot.BackgroundColor3 = data.color or Color3.fromRGB(255, 80, 80)
        dot.BorderSizePixel = 0
        dot.ZIndex = 8
        dot.Parent = radar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = dot

        local label

        if config.ShowDistance then
            label = Instance.new("TextLabel")
            label.Name = "Distance"
            label.AnchorPoint = Vector2.new(0.5, 1)
            label.Position = UDim2.new(0.5, 0, 0, -3)
            label.Size = UDim2.new(0, 60, 0, 14)
            label.BackgroundTransparency = 1
            label.TextColor3 = data.color or Color3.fromRGB(255, 255, 255)
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 11
            label.Text = ""
            label.ZIndex = 9
            label.Parent = dot
        end

        data.dot = dot
        data.label = label

        targets[data.id] = data
    end

    local function updateTarget(data)
        local dot = data.dot

        if not dot then
            return
        end

        if data.visible == false then
            dot.Visible = false
            return
        end

        local targetPosition = resolvePosition(data.target)

        if not targetPosition then
            dot.Visible = false
            return
        end

        local character = localPlayer.Character

        if not character then
            dot.Visible = false
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart")

        if not root then
            dot.Visible = false
            return
        end

        local localPosition = root.Position
        local difference = targetPosition - localPosition

        local flatDifference = Vector3.new(
            difference.X,
            0,
            difference.Z
        )

        local distance = flatDifference.Magnitude

        if distance < 0.01 then
            dot.Position = UDim2.new(0.5, 0, 0.5, 0)
            dot.Visible = true
            return
        end

        -- Направление камеры по горизонтали

        local camera = workspace.CurrentCamera

        if not camera then
            dot.Visible = false
            return
        end

        local look = camera.CFrame.LookVector
        local right = camera.CFrame.RightVector

        local flatLook = Vector3.new(look.X, 0, look.Z)
        local flatRight = Vector3.new(right.X, 0, right.Z)

        if flatLook.Magnitude < 0.01 or flatRight.Magnitude < 0.01 then
            dot.Visible = false
            return
        end

        flatLook = flatLook.Unit
        flatRight = flatRight.Unit

        local direction = flatDifference.Unit

        -- X = влево/вправо
        -- Y = вперёд/назад

        local x = direction:Dot(flatRight)
        local y = direction:Dot(flatLook)

        local normalizedDistance = math.min(distance / range, 1)

        local radius = size * 0.5 - 10

        local screenX = centerX + x * radius * normalizedDistance
        local screenY = centerY - y * radius * normalizedDistance

        dot.Position = UDim2.new(
            0,
            screenX,
            0,
            screenY
        )

        dot.Visible = true

        if data.label then
            data.label.Text = string.format("%dm", math.floor(distance))
        end
    end

    local function setTarget(data)
        if not data or not data.id then
            return
        end

        local id = data.id
        local saved = targets[id]

        if not saved then
            saved = {
                id = id,
                target = data.target,
                color = data.color or Color3.fromRGB(255, 80, 80),
                size = data.size or 8,
                visible = data.visible ~= false,
            }

            createTarget(saved)
        else
            if data.target ~= nil then
                saved.target = data.target
            end

            if data.color ~= nil then
                saved.color = data.color
                saved.dot.BackgroundColor3 = data.color

                if saved.label then
                    saved.label.TextColor3 = data.color
                end
            end

            if data.size ~= nil then
                saved.size = data.size

                saved.dot.Size = UDim2.new(
                    0,
                    data.size,
                    0,
                    data.size
                )
            end

            if data.visible ~= nil then
                saved.visible = data.visible
            end
        end

        if saved.dot then
            saved.dot.BackgroundColor3 = saved.color
            saved.dot.Size = UDim2.new(
                0,
                saved.size,
                0,
                saved.size
            )
        end
    end

    local function setTargets(list)
        if not list then
            return
        end

        for _, data in ipairs(list) do
            setTarget(data)
        end
    end

    setTargets(config.Targets)

    local bindName = "RadarUpdate_" .. guiName

    RunService:BindToRenderStep(
        bindName,
        Enum.RenderPriority.Camera.Value + 1,
        function()
            if not screen.Enabled then
                return
            end

            for _, data in pairs(targets) do
                updateTarget(data)
            end
        end
    )

    local api = {}

    function api:Set(list)
        setTargets(list)
    end

    function api:RemoveTarget(id)
        local data = targets[id]

        if not data then
            return
        end

        if data.dot then
            data.dot:Destroy()
        end

        targets[id] = nil
    end

    function api:Clear()
        for id, data in pairs(targets) do
            if data.dot then
                data.dot:Destroy()
            end

            targets[id] = nil
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

    function api:SetRange(value)
        if value then
            range = value
        end
    end

    function api:Remove()
        RunService:UnbindFromRenderStep(bindName)

        if screen then
            screen:Destroy()
        end

        targets = {}
    end

    return api
end

return {
    createInfoGui = createInfoGui,
    createInfoText = createInfoText,
    createRadar = createRadar
}
