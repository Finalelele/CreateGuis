function createWorkspaceEsp(config)
    config = config or {}
    local name = config.Name or "GhostRoomESP"
    local center = config.Center
    local offset = config.Offset or Vector3.new(0, 3, 0)
    local textSize = config.TextSize or 20
    local lines = config.Lines or {}
    local size = config.Size or UDim2.new(0, 300, 0, 50)

    local billboard = nil
    local container = nil
    local labels = {}
    local currentAdornee = nil
    local isActive = false

    local function createBillboard(adornee)
        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
            labels = {}
        end

        if not adornee then
            isActive = false
            return
        end

        local newAdornee = adornee
        if newAdornee:IsA("Model") then
            newAdornee = newAdornee.PrimaryPart or newAdornee:FindFirstChildWhichIsA("BasePart")
        end
        if not newAdornee or not newAdornee:IsA("BasePart") then
            warn("createWorkspaceEsp: Center must contain a BasePart")
            isActive = false
            return
        end

        currentAdornee = newAdornee
        isActive = true

        billboard = Instance.new("BillboardGui")
        billboard.Name = name
        billboard.Adornee = newAdornee
        billboard.Size = size
        billboard.StudsOffset = offset
        billboard.AlwaysOnTop = true
        billboard.Parent = newAdornee

        container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = billboard

        local layout = Instance.new("UIListLayout", container)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)

        labels = {}
        if lines and #lines > 0 then
            setText(lines)
        end
    end

    local function setText(linesTable)
        if not container then return end
        if type(linesTable) ~= "table" then return end
        
        for _, lbl in pairs(labels) do
            lbl:Destroy()
        end
        labels = {}

        for order, item in ipairs(linesTable) do
            local id = tostring(item.id or item.key or order)
            local text = item.text or ""
            local color = item.color or Color3.fromRGB(255, 255, 255)
            local lbl = Instance.new("TextLabel", container)
            lbl.Name = id
            lbl.Size = UDim2.new(1, 0, 0, 20)
            lbl.BackgroundTransparency = 1
            lbl.Font = Enum.Font.SourceSansBold
            lbl.TextSize = textSize
            lbl.TextXAlignment = Enum.TextXAlignment.Center
            lbl.Text = text
            lbl.TextColor3 = color
            lbl.LayoutOrder = order
            labels[id] = lbl
        end
    end

    if center then
        createBillboard(center)
    end

    local api = {
        SetText = function(self, newLines)
            lines = newLines
            if isActive then
                setText(newLines)
            end
        end,

        RemoveLine = function(self, key)
            if not container then return end
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
            if billboard then
                billboard.Enabled = state
            end
        end,

        SetCenter = function(self, newCenter)
            createBillboard(newCenter)
            if billboard then
                billboard.Enabled = true
            end
        end,

        SetOffset = function(self, newOffset)
            offset = newOffset
            if billboard then
                billboard.StudsOffset = newOffset
            end
        end,

        SetSize = function(self, newSize)
            size = newSize
            if billboard then
                billboard.Size = newSize
            end
        end,

        Remove = function(self)
            if billboard then
                billboard:Destroy()
                billboard = nil
                container = nil
                labels = {}
                isActive = false
            end
        end
    }

    return api
end

return createWorkspaceEsp
