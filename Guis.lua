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

local function createRadar(config)
    config = config or {}

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local CoreGui = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService") -- Добавлено для перетаскивания

    local Name = config.Name or "CustomRadar"
    local Title = config.Title or "Radar"
    local Position = config.Position or UDim2.new(0.03, 0, 0.3, 0)

    local Size = config.Size or 100
    local Scale = config.Scale or 1
    local Range = (config.Range or 100) / 2 

    local Center = config.Center or Players.LocalPlayer
    local CenterOffset = config.CenterOffset or Vector3.zero

    local BackgroundColor = config.BackgroundColor or Color3.fromRGB(10, 10, 15)
    local BorderColor = config.BorderColor or Color3.fromRGB(80, 80, 90)

    local enabled = true
    local targets = {}

    local WINDOW_SIZE = 220
    local WINDOW_HEIGHT = 260 
    local RADAR_SIZE = 200
    local BORDER_SIZE = 3

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

    -- =========================================================
    -- НАЧАЛО БЛОКА ПЕРЕТАСКИВАНИЯ
    -- =========================================================
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    -- Слушаем клики по заголовку (title)
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    -- =========================================================
    -- КОНЕЦ БЛОКА ПЕРЕТАСКИВАНИЯ
    -- =========================================================

    local radar = Instance.new("Frame")
    radar.Name = "Radar"
    radar.Size = UDim2.fromOffset(RADAR_SIZE, RADAR_SIZE)
    radar.Position = UDim2.new(0.5, -RADAR_SIZE / 2, 0, 40) 
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

    local function createCircle(size, transparency)
        local circle = Instance.new("Frame")
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(size, 0, size, 0)
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

    local function createTarget(data)
        local point = Instance.new("Frame")
        point.Name = tostring(data.id)
        point.AnchorPoint = Vector2.new(0.5, 0.5)
        point.BackgroundColor3 = data.color or Color3.new(1, 1, 1)
        point.BorderSizePixel = 0
        point.Size = UDim2.fromOffset(data.size or 8, data.size or 8)
        point.Parent = radar

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(1, 0)
        corner.Parent = point

        local textLabel

        if data.text ~= nil then
            textLabel = Instance.new("TextLabel")
            textLabel.Name = "Text"
            textLabel.BackgroundTransparency = 1
            textLabel.AnchorPoint = Vector2.new(0.5, 1)
            textLabel.Position = UDim2.new(0.5, 0, 0, -4)
            textLabel.Size = UDim2.fromOffset(140, 18)
            textLabel.Font = Enum.Font.Gotham
            textLabel.Text = tostring(data.text)
            textLabel.TextColor3 = data.color or Color3.new(1, 1, 1)
            textLabel.TextSize = 13
            textLabel.TextXAlignment = Enum.TextXAlignment.Center
            textLabel.Parent = point
        end

        targetObjects[data.id] = {
            point = point,
            text = textLabel,
            data = data,
        }
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

        old.point.BackgroundColor3 = saved.color or Color3.new(1, 1, 1)

        local pointSize = saved.size or 8
        old.point.Size = UDim2.fromOffset(pointSize, pointSize)

        if saved.text ~= nil then
            if not old.text then
                old.text = Instance.new("TextLabel")
                old.text.Name = "Text"
                old.text.BackgroundTransparency = 1
                old.text.AnchorPoint = Vector2.new(0.5, 1)
                old.text.Position = UDim2.new(0.5, 0, 0, -4)
                old.text.Size = UDim2.fromOffset(140, 18)
                old.text.Font = Enum.Font.Gotham
                old.text.TextSize = 13
                old.text.TextXAlignment = Enum.TextXAlignment.Center
                old.text.Parent = old.point
            end

            old.text.Text = tostring(saved.text)
            old.text.TextColor3 = saved.color or Color3.new(1, 1, 1)
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

        if not targetRoot or not centerPosition or data.visible == false then
            object.point.Visible = false
            return
        end

        local offset = targetRoot.Position - centerPosition
        local distance = offset.Magnitude

        if distance > Range then
            object.point.Visible = false
            return
        end

        object.point.Visible = true

        if distance < 0.01 then
            object.point.Position = UDim2.new(0.5, 0, 0.5, 0)
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

        if forward.Magnitude < 0.001 or right.Magnitude < 0.001 then
            return
        end

        forward = forward.Unit
        right = right.Unit

        local x = offset:Dot(right)
        local y = offset:Dot(forward)

        local normalizedDistance = distance / Size

        local maxDistance = 1

        if normalizedDistance > maxDistance then
            normalizedDistance = maxDistance
        end

        local direction = Vector2.new(x, y)

        if direction.Magnitude > 0 then
            direction = direction.Unit * normalizedDistance
        end

        object.point.Position = UDim2.new(
            0.5 + direction.X * 0.5,
            0,
            0.5 - direction.Y * 0.5,
            0
        )
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

    function api:Set(listOrId, target, text, color, pointSize, visible)
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
        Range = (tonumber(value) or (Range * 2)) / 2
    end

    function api:SetSize(value)
        Size = math.max(tonumber(value) or Size, 0.01)
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
