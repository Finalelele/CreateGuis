function createInfoGui(config)
    local guiName = config.Name or "CustomWindow"
    local coreGui = game:GetService("CoreGui")
    local screen = coreGui:FindFirstChild(guiName)
    if not screen then
        screen = Instance.new("ScreenGui", coreGui)
        screen.Name = guiName
        screen.ResetOnSpawn = false
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame", screen)
        frame.Name = "MainFrame"
        frame.Size = UDim2.new(0, config.Width or 200, 0, 0)
        frame.Position = config.Position or UDim2.new(0.05, 0, 0.15, 0)
        frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.Draggable = true
        frame.AutomaticSize = Enum.AutomaticSize.Y

        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        local uiScale = Instance.new("UIScale")
        uiScale.Name = "WindowScale"
        uiScale.Scale = config.Scale or 1
        uiScale.Parent = frame

        local topBar = Instance.new("Frame", frame)
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 35)
        topBar.BackgroundTransparency = 1

        local title = Instance.new("TextLabel", topBar)
        title.Size = UDim2.new(1, -35, 1, 0)
        title.Position = UDim2.new(0, 12, 0, 0)
        title.Text = config.Title or "Window"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.Font = Enum.Font.SourceSansBold
        title.TextSize = config.TextSize or 17
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.BackgroundTransparency = 1

        local container = Instance.new("Frame", frame)
        container.Name = "Container"
        container.Position = UDim2.new(0, 0, 0, 35)
        container.Size = UDim2.new(1, 0, 0, 0)
        container.AutomaticSize = Enum.AutomaticSize.Y
        container.BackgroundTransparency = 1

        local padding = Instance.new("UIPadding", container)
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.PaddingBottom = UDim.new(0, 10)

        local layout = Instance.new("UIListLayout", container)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 4)

        local toggleBtn = Instance.new("TextButton", topBar)
        toggleBtn.Size = UDim2.new(0, 25, 0, 25)
        toggleBtn.Position = UDim2.new(1, -28, 0, 5)
        toggleBtn.Text = "-"
        toggleBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        toggleBtn.BackgroundTransparency = 1
        toggleBtn.Font = Enum.Font.SourceSansBold
        toggleBtn.TextSize = 18

        toggleBtn.MouseButton1Click:Connect(function()
            container.Visible = not container.Visible
            toggleBtn.Text = container.Visible and "-" or "+"
        end)
    end

    local frame = screen:FindFirstChild("MainFrame")
    local container = frame and frame:FindFirstChild("Container")
    if not frame or not container then
        return
    end

    local uiScale = frame:FindFirstChild("WindowScale")
    if uiScale then
        uiScale.Scale = config.Scale or 1
    end

    local labels = {}
    for _, child in ipairs(container:GetChildren()) do
        if child:IsA("TextLabel") then
            labels[child.Name] = child
        end
    end

    local window = {}

    function window:SetText(lines)
        if type(lines) ~= "table" then
            return
        end
        for order, item in ipairs(lines) do
            if type(item) ~= "table" then
                continue
            end
            local id = tostring(item.id or item.key or order)
            local text = item.text or item.value or ""
            local color = item.color or item.Color
            local lbl = labels[id]
            if not lbl then
                lbl = Instance.new("TextLabel", container)
                lbl.Name = id
                lbl.Size = UDim2.new(1, 0, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextSize = config.TextSize or 14
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                labels[id] = lbl
            end
            lbl.Text = tostring(text)
            lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)
            if not lbl:GetAttribute("InitializedOrder") then
                lbl.LayoutOrder = order
                lbl:SetAttribute("InitializedOrder", true)
            end
        end
    end

    function window:RemoveLine(key)
        key = tostring(key)
        local lbl = labels[key]
        if lbl and lbl.Parent == container then
            lbl:Destroy()
            labels[key] = nil
            local order = 1
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("TextLabel") then
                    child.LayoutOrder = order
                    order = order + 1
                end
            end
        end
    end

    function window:Visible(state)
        if screen then
            screen.Enabled = state
        end
    end

    function window:SetScale(scale)
        scale = tonumber(scale) or 1
        scale = math.max(scale, 0.1)
        local currentScale = frame:FindFirstChild("WindowScale")
        if currentScale then
            currentScale.Scale = scale
        end
    end

    function window:Remove()
        if screen then
            screen:Destroy()
        end
    end

    if config.Lines then
        window:SetText(config.Lines)
    end
    return window
end
