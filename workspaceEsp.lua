function createWorkspaceEsp(config)
    config = config or {}
    local name = config.Name or "GhostRoomESP"
    local center = config.Center 
    local offset = config.Offset or Vector3.new(0, 3, 0)
    local textSize = config.TextSize or 20
    local lines = config.Lines or {}

    if not center then
        error("createGhostRoomEsp: Center is required")
    end

    local adornee = center
    if adornee:IsA("Model") then
        adornee = adornee.PrimaryPart or adornee:FindFirstChildWhichIsA("BasePart")
    end
    if not adornee or not adornee:IsA("BasePart") then
        error("createGhostRoomEsp: Center must contain a BasePart")
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Adornee = adornee
    billboard.Size = UDim2.new(0, 300, 0, 50)
    billboard.StudsOffset = offset
    billboard.AlwaysOnTop = true
    billboard.Parent = adornee

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, 0)
    container.BackgroundTransparency = 1
    container.Parent = billboard

    local layout = Instance.new("UIListLayout", container)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)

    local labels = {}

    local function setText(linesTable)
        if type(linesTable) ~= "table" then return end
        for order, item in ipairs(linesTable) do
            local id = tostring(item.id or item.key or order)
            local text = item.text or ""
            local color = item.color or Color3.fromRGB(255, 255, 255)
            local lbl = labels[id]
            if not lbl then
                lbl = Instance.new("TextLabel", container)
                lbl.Name = id
                lbl.Size = UDim2.new(1, 0, 0, 20)
                lbl.BackgroundTransparency = 1
                lbl.Font = Enum.Font.SourceSansBold
                lbl.TextSize = textSize
                lbl.TextXAlignment = Enum.TextXAlignment.Center
                labels[id] = lbl
            end
            lbl.Text = text
            lbl.TextColor3 = color
            lbl.LayoutOrder = order
        end
    end

    setText(lines)

    local api = {
        SetText = function(self, newLines)
            for _, lbl in pairs(labels) do
                lbl:Destroy()
            end
            labels = {}
            setText(newLines)
        end,

        RemoveLine = function(self, key)
            key = tostring(key)
            local lbl = labels[key]
            if lbl then
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
        end,

        Visible = function(self, state)
            billboard.Enabled = state
        end,

        SetCenter = function(self, newCenter)
            local newAdornee = newCenter
            if newAdornee:IsA("Model") then
                newAdornee = newAdornee.PrimaryPart or newAdornee:FindFirstChildWhichIsA("BasePart")
            end
            if newAdornee and newAdornee:IsA("BasePart") then
                billboard.Adornee = newAdornee
                billboard.Parent = newAdornee  -- переносим в нового родителя
            else
                warn("SetCenter: invalid center object")
            end
        end,

        SetOffset = function(self, newOffset)
            billboard.StudsOffset = newOffset
        end,

        Remove = function(self)
            billboard:Destroy()
        end
    }

    return api
end
