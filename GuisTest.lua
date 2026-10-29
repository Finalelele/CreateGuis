local TweenService = game:GetService("TweenService")

local Fx = {}
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

function Fx.pick(tbl, ...)
    if type(tbl) ~= "table" then return nil end
    for _, key in ipairs({...}) do
        if tbl[key] ~= nil then return tbl[key] end
    end
    return nil
end
local pick = Fx.pick

function Fx.copy(t)
    local out = {}
    if type(t) == "table" then
        for k, v in pairs(t) do out[k] = v end
    end
    return out
end

function Fx.lighten(c, a) return c:Lerp(WHITE, a) end

function Fx.depthStrength(cw)
    local d = pick(cw, "Depth", "depth")
    if d == false then return 0 end
    if type(d) == "number" then return math.clamp(d, 0, 2) end
    if type(d) == "table" then
        if pick(d, "enabled", "Enabled") == false then return 0 end
        return math.clamp(tonumber(pick(d, "strength", "Strength")) or 1, 0, 2)
    end
    return 1
end

function Fx.shade(strength, amount)
    local v = math.clamp(1 - amount * strength, 0, 1)
    return ColorSequence.new(WHITE, Color3.new(v, v, v))
end

local function tween(obj, info, props, instant)
    if not obj then return end
    if instant then
        for k, v in pairs(props) do obj[k] = v end
    else
        TweenService:Create(obj, info, props):Play()
    end
end

function Fx.newShadow(parent, cfg, z)
    local pad = tonumber(pick(cfg, "size", "Size")) or 24
    local s = Instance.new("ImageLabel")
    s.Name = "Shadow"
    s.AnchorPoint = Vector2.new(0.5, 0.5)
    s.Position = UDim2.new(0.5, 0, 0.5, 4)
    s.Size = UDim2.new(1, pad * 2, 1, pad * 2)
    s.BackgroundTransparency = 1
    s.Image = "rbxassetid://6014261993"
    s.ScaleType = Enum.ScaleType.Slice
    s.SliceCenter = Rect.new(49, 49, 450, 450)
    s.ImageColor3 = pick(cfg, "color", "Color") or BLACK
    s.ImageTransparency = pick(cfg, "transparency", "Transparency") or 0.55
    s.ZIndex = z or 0
    s.Active = false
    s.Parent = parent
    return s
end

function Fx.addBorderGradient(stroke, color, strength)
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Parent = stroke
    local obj = { gradient = g }
    function obj.set(c, s)
        g.Color = ColorSequence.new(c:Lerp(WHITE, 0.4), c:Lerp(BLACK, 0.15))
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, math.clamp(0.7 * s, 0, 1)),
        })
    end
    obj.set(color, strength)
    return obj
end

-- ИСПРАВЛЕНИЕ 1: Добавлен аргумент radius для скругления Sheen и Gloss
function Fx.addDepth(body, strength, z, radius)
    local parts = {}
    local r = radius or 8

    local grad = Instance.new("UIGradient")
    grad.Rotation = 90
    grad.Parent = body

    local sheen = Instance.new("Frame")
    sheen.Name = "Sheen"
    sheen.Size = UDim2.new(1, 0, 0.5, 0)
    sheen.BackgroundColor3 = WHITE
    sheen.BorderSizePixel = 0
    sheen.Active = false
    sheen.ZIndex = z or 1
    sheen.Parent = body
    
    local sheenCorner = Instance.new("UICorner")
    sheenCorner.CornerRadius = UDim.new(0, r)
    sheenCorner.Parent = sheen

    local sg = Instance.new("UIGradient")
    sg.Rotation = 90
    sg.Parent = sheen

    local gloss = Instance.new("Frame")
    gloss.Name = "Gloss"
    gloss.Size = UDim2.new(1, -24, 0, 1)
    gloss.Position = UDim2.new(0, 12, 0, 0)
    gloss.BackgroundColor3 = WHITE
    gloss.BorderSizePixel = 0
    gloss.Active = false
    gloss.ZIndex = 10
    gloss.Parent = body
    local gg = Instance.new("UIGradient")
    gg.Parent = gloss

    parts.sheen, parts.gloss, parts.grad = sheen, gloss, grad

    function parts.update(s)
        grad.Color = Fx.shade(s, 0.30)
        sg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1 - math.clamp(0.12 * s, 0, 1)),
            NumberSequenceKeypoint.new(1, 1),
        })
        gg.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 1 - math.clamp(0.5 * s, 0, 1)),
            NumberSequenceKeypoint.new(1, 1),
        })
    end
    parts.update(strength)
    return parts
end


--====================================================================
--  createInfoGui
--====================================================================
function createInfoGui(config)
    config = config or {}

    local UserInputService = game:GetService("UserInputService")
    local CoreGui          = game:GetService("CoreGui")
    local HttpService      = game:GetService("HttpService")
    local TextService      = game:GetService("TextService")

    local function resolveUDim2(val, default)
        if typeof(val) == "UDim2" then return val end
        if type(val) == "table" then
            if val.x ~= nil and val.y ~= nil then
                return UDim2.fromOffset(val.x, val.y)
            elseif val.XScale ~= nil and val.YScale ~= nil then
                return UDim2.new(val.XScale, val.XOffset or 0, val.YScale, val.YOffset or 0)
            end
        end
        return default
    end

    local cw = pick(config, "CustomWindow", "customWindow") or {}
    local function sub(...) return Fx.copy(pick(cw, ...)) end

    local bg            = sub("Background", "background")
    local topbar        = sub("Topbar", "topbar")
    local topbarLine    = sub("TopbarLine", "topbarLine")
    local titleCfg      = sub("Title", "title")
    local borderCfg     = sub("Border", "border")
    local cornerCfg     = sub("Corner", "corner")
    local shadowCfg     = sub("Shadow", "shadow")
    local lineToggleCfg = sub("LineToggle", "lineToggle")
    local scrollbarCfg  = sub("Scrollbar", "scrollbar")
    local lineTextCfg   = sub("LineText", "lineText")
    local fontCfg       = sub("Font", "font")
    local accentCfg     = sub("Accent", "accent")
    local toggleImageCfg = sub("ToggleImage", "toggleImage")
    local depth         = Fx.depthStrength(cw)

    local function accentColor()
        return pick(accentCfg, "color", "Color") or pick(topbarLine, "color", "Color") or Color3.fromRGB(70, 140, 255)
    end
    local function cBg()     return pick(bg, "color", "Color") or Color3.fromRGB(14, 17, 26) end
    local function tBg()     return pick(bg, "transparency", "Transparency") or 0.08 end
    local function cTop()    return pick(topbar, "color", "Color") or Color3.fromRGB(22, 26, 38) end
    local function tTop()    return pick(topbar, "transparency", "Transparency") or 0.2 end
    local function cBorder() return pick(borderCfg, "color", "Color") or Color3.fromRGB(70, 85, 125) end
    local function tBorder() return pick(borderCfg, "transparency", "Transparency") or 0.2 end
    local function radius()  return pick(cornerCfg, "radius", "Radius") or 10 end
    local function lineTextColor() return pick(lineTextCfg, "color", "Color") or Color3.fromRGB(235, 238, 248) end
    local function tShadow() return pick(shadowCfg, "transparency", "Transparency") or 0.55 end

    local guiName   = pick(config, "Name", "name") or "CustomWindow"
    local title     = pick(config, "Title", "title") or "Window"
    local size      = resolveUDim2(pick(config, "Size", "size"), UDim2.fromOffset(200, 500))
    local scale     = pick(config, "Scale", "scale") or 1
    local position  = resolveUDim2(pick(config, "Position", "position"), UDim2.new(0.05, 0, 0.15, 0))
    local textSize  = pick(config, "TextSize", "textSize") or 14

    local reload    = pick(config, "Reload", "reload")
    if reload == nil then reload = true end

    local autoSizeCfg        = pick(config, "AutoSize", "autoSize") or {}
    local autoSizeEnabled    = pick(autoSizeCfg, "Enabled", "enabled")
    if autoSizeEnabled == nil then autoSizeEnabled = true end
    local autoSizeWindowEdge = pick(autoSizeCfg, "WindowEdge", "windowEdge")
    if autoSizeWindowEdge == nil then autoSizeWindowEdge = false end
    local autoSizeWindowEdgeWithSize = pick(autoSizeCfg, "WindowEdgeWithSize", "windowEdgeWithSize")
    if autoSizeWindowEdgeWithSize == nil then autoSizeWindowEdgeWithSize = false end

    local autoSizeSide = pick(autoSizeCfg, "side", "Side") or "down"
    local isHorizontal = (autoSizeSide == "left" or autoSizeSide == "right")

    local savePosCfg = pick(config, "SavePos", "savePos") or {}
    local savePosEnabled = pick(savePosCfg, "enabled", "Enabled") == true
    local savePosId = pick(savePosCfg, "id", "Id", "ID")
    local saveFileName = "FinaleleleGuiPositions.json"
    local saveData = {}

    local function loadSaveData()
        if not savePosId then return end
        if isfile and readfile and isfile(saveFileName) then
            local success, result = pcall(function() return HttpService:JSONDecode(readfile(saveFileName)) end)
            if success and type(result) == "table" then saveData = result end
        end
    end

    local function saveDataToFile()
        if not savePosId then return end
        if writefile then
            pcall(function() writefile(saveFileName, HttpService:JSONEncode(saveData)) end)
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

    local TRACK_W, TRACK_H, KNOB_H = 34, 18, 14

    local tweenTime    = pick(config, "TweenTime", "tweenTime") or 0.22
    local tweenInfo    = TweenInfo.new(tweenTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local lineFadeInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local quickInfo    = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    for _, old in ipairs(CoreGui:GetChildren()) do
        if old.Name == guiName and old:IsA("ScreenGui") then
            if old:GetAttribute("Reload") == true then old:Destroy() end
        end
    end

    local connections = {}
    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(connections, c)
        return c
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = guiName
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen:SetAttribute("Reload", reload)
    screen.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.fromOffset(size.X.Offset, headerHeight)
    frame.Position = position
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = screen

    if autoSizeSide == "up" then
        frame.AnchorPoint = Vector2.new(0, 1)
        frame.Position = UDim2.new(position.X.Scale, position.X.Offset, position.Y.Scale, position.Y.Offset + headerHeight)
    elseif autoSizeSide == "left" then
        frame.AnchorPoint = Vector2.new(1, 0)
        frame.Position = UDim2.new(position.X.Scale, position.X.Offset + size.X.Offset, position.Y.Scale, position.Y.Offset)
    else
        frame.AnchorPoint = Vector2.new(0, 0)
        frame.Position = position
    end

    local uiScale = Instance.new("UIScale")
    uiScale.Scale = scale
    uiScale.Parent = frame

    local shadow = Fx.newShadow(frame, shadowCfg, 0)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, 0)
    body.BackgroundColor3 = cBg()
    body.BackgroundTransparency = tBg()
    body.BorderSizePixel = 0
    body.Active = true
    body.ClipsDescendants = true
    body.ZIndex = 1
    body.Parent = frame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius())
    corner.Parent = body

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Name = "Border"
    frameStroke.Color = WHITE
    frameStroke.Thickness = pick(borderCfg, "thickness", "Thickness") or 1
    frameStroke.Transparency = tBorder()
    frameStroke.Parent = body
    local borderGrad = Fx.addBorderGradient(frameStroke, cBorder(), depth)

    local depthParts = Fx.addDepth(body, depth, 1, radius())

    local header = Instance.new("Frame")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, headerHeight)
    header.BackgroundColor3 = cTop()
    header.BackgroundTransparency = tTop()
    header.BorderSizePixel = 0
    header.Active = true
    header.ZIndex = 3
    header.ClipsDescendants = true
    header.Parent = body

    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, radius())
    headerCorner.Parent = header

    local headerGrad = Instance.new("UIGradient")
    headerGrad.Rotation = 90
    headerGrad.Color = Fx.shade(depth, 0.22)
    headerGrad.Parent = header

    local sep = Instance.new("Frame")
    sep.Name = "Separator"
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Position = UDim2.new(0, 0, 1, -1)
    sep.BackgroundColor3 = WHITE
    sep.BackgroundTransparency = 0.9
    sep.BorderSizePixel = 0
    sep.ZIndex = 4
    sep.Parent = header

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.Position = UDim2.new(0, 8, 0.5, -7)
    accent.Size = UDim2.fromOffset(3, 14)
    accent.BackgroundColor3 = accentColor()
    accent.BorderSizePixel = 0
    accent.ZIndex = 4
    accent.Parent = header

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(1, 0)
    accentCorner.Parent = accent

    local accentGrad = Instance.new("UIGradient")
    accentGrad.Rotation = 90
    accentGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(170, 170, 170))
    accentGrad.Parent = accent

    local accentGlow = Instance.new("UIStroke")
    accentGlow.Color = accentColor()
    accentGlow.Thickness = 3
    accentGlow.Transparency = 0.72
    accentGlow.Parent = accent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Position = UDim2.new(0, 18, 0, 0)
    titleLabel.Size = UDim2.new(1, -56, 1, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = pick(titleCfg, "color", "Color") or Color3.fromRGB(245, 247, 255)
    titleLabel.Font = pick(fontCfg, "title", "Title") or Enum.Font.GothamSemibold
    titleLabel.TextSize = textSize + 2
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextYAlignment = Enum.TextYAlignment.Center
    titleLabel.ZIndex = 4
    titleLabel.Parent = header

    local function toggleBaseColor() return pick(lineToggleCfg, "color", "Color") or Color3.fromRGB(40, 46, 66) end
    local function toggleTextColor() return pick(lineToggleCfg, "textColor", "TextColor") or Color3.fromRGB(215, 220, 235) end

    local toggle = Instance.new("TextButton")
    toggle.Name = "Toggle"
    toggle.AnchorPoint = Vector2.new(1, 0.5)
    toggle.Position = UDim2.new(1, -8, 0.5, 0)
    toggle.Size = UDim2.fromOffset(28, 20)
    toggle.BackgroundColor3 = toggleBaseColor()
    toggle.BackgroundTransparency = 0.1
    toggle.BorderSizePixel = 0
    toggle.AutoButtonColor = false
    toggle.Text = ""
    toggle.ZIndex = 5
    toggle.Parent = header

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle

    local toggleGrad = Instance.new("UIGradient")
    toggleGrad.Rotation = 90
    toggleGrad.Color = Fx.shade(1, 0.3)
    toggleGrad.Parent = toggle

    local toggleStroke = Instance.new("UIStroke")
    toggleStroke.Color = WHITE
    toggleStroke.Transparency = 0.86
    toggleStroke.Thickness = 1
    toggleStroke.Parent = toggle

    local toggleScale = Instance.new("UIScale")
    toggleScale.Parent = toggle

    local arrow = Instance.new("ImageLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(1, 0, 1, 0)
    arrow.BackgroundTransparency = 1
    arrow.ZIndex = 6
    arrow.Parent = toggle

    local arrowText = Instance.new("TextLabel")
    arrowText.Name = "ArrowText"
    arrowText.Size = UDim2.new(1, 0, 1, 0)
    arrowText.BackgroundTransparency = 1
    arrowText.Text = "⌃"
    arrowText.TextColor3 = toggleTextColor()
    arrowText.Font = Enum.Font.GothamBold
    arrowText.TextSize = 15
    arrowText.ZIndex = 7
    arrowText.Parent = toggle

    local scrolling = Instance.new("ScrollingFrame")
    scrolling.Name = "Container"
    scrolling.Position = UDim2.new(0, 0, 0, headerHeight)
    scrolling.Size = UDim2.new(1, 0, 1, -headerHeight)
    scrolling.BackgroundTransparency = 1
    scrolling.BorderSizePixel = 0
    scrolling.ScrollBarThickness = 0
    scrolling.ScrollBarImageColor3 = pick(scrollbarCfg, "color", "Color") or accentColor()
    scrolling.ScrollBarImageTransparency = 0.3
    scrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrolling.ElasticBehavior = Enum.ElasticBehavior.Never
    scrolling.ZIndex = 2
    scrolling.Parent = body

    if Enum.AutomaticSize then
        if isHorizontal then
            scrolling.ScrollingDirection = Enum.ScrollingDirection.XY
            scrolling.AutomaticCanvasSize = Enum.AutomaticSize.XY
        else
            scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
            scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
        end
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
    local function getContentWidthLogical() return layout.AbsoluteContentSize.X / getScale() end

    local function getEffectiveMaxSize()
        local maxX = size.X.Offset
        local maxY = size.Y.Offset

        if autoSizeWindowEdge then
            local screenSize = screen.AbsoluteSize
            local absPos = frame.AbsolutePosition

            if autoSizeSide == "down" then
                local edgeAvailable = (screenSize.Y - absPos.Y - EDGE_MARGIN) / getScale()
                maxY = autoSizeWindowEdgeWithSize and math.min(size.Y.Offset, edgeAvailable) or edgeAvailable
            elseif autoSizeSide == "up" then
                local topY = frame.AbsolutePosition.Y - frame.AbsoluteSize.Y
                local edgeAvailable = (topY - EDGE_MARGIN) / getScale()
                maxY = autoSizeWindowEdgeWithSize and math.min(size.Y.Offset, edgeAvailable) or edgeAvailable
            elseif autoSizeSide == "right" then
                local edgeAvailable = (screenSize.X - absPos.X - EDGE_MARGIN) / getScale()
                maxX = autoSizeWindowEdgeWithSize and math.min(size.X.Offset, edgeAvailable) or edgeAvailable
            elseif autoSizeSide == "left" then
                local leftX = frame.AbsolutePosition.X - frame.AbsoluteSize.X
                local edgeAvailable = (leftX - EDGE_MARGIN) / getScale()
                maxX = autoSizeWindowEdgeWithSize and math.min(size.X.Offset, edgeAvailable) or edgeAvailable
            end
        end
        return math.max(maxX, 50), math.max(maxY, headerHeight)
    end

    local function isEdgeMode() return autoSizeWindowEdge end

    local function updateFrameSize(animate)
        local targetWidth = size.X.Offset
        local targetHeight = size.Y.Offset

        local contentW = getContentWidthLogical()
        local contentH = getContentHeightLogical()
        local maxX, maxY = getEffectiveMaxSize()

        if collapsed then
            targetHeight = headerHeight
            -- ИСПРАВЛЕНИЕ 2: Не сжимать окно по X при сворачивании
            targetWidth = frame.Size.X.Offset 
            
            -- ИСПРАВЛЕНИЕ 3: Фикс накопления глоу (тени) при сворачивании
            if shadow then
                local pad = pick(shadowCfg, "size", "Size") or 24
                shadow.ScaleType = Enum.ScaleType.Stretch
                shadow.Size = UDim2.new(1, pad * 2, 0, targetHeight + pad * 2)
            end
        else
            if autoSizeEnabled then
                if isHorizontal then
                    local titleWidth = TextService:GetTextSize(titleLabel.Text, titleLabel.TextSize, titleLabel.Font, Vector2.new(10000, 10000)).X
                    local minW = titleWidth + 66
                    targetWidth = math.max(minW, math.min(contentW + 20, maxX))
                    targetHeight = math.clamp(headerHeight + contentH + bottomPadding, headerHeight, maxY)
                else
                    targetWidth = maxX
                    targetHeight = math.clamp(headerHeight + contentH + bottomPadding, headerHeight, maxY)
                end
            else
                targetWidth = maxX
                targetHeight = maxY
            end

            if shadow then
                local pad = pick(shadowCfg, "size", "Size") or 24
                shadow.ScaleType = Enum.ScaleType.Slice
                shadow.Size = UDim2.new(1, pad * 2, 1, pad * 2)
            end
        end

        if not collapsed then
            local availableW = targetWidth
            local availableH = targetHeight - headerHeight
            local needVert = (contentH > availableH + 1)
            local needHoriz = (contentW > availableW + 1)
            if isHorizontal then
                scrolling.ScrollBarThickness = (needVert or needHoriz) and 4 or 0
            else
                scrolling.ScrollBarThickness = needVert and 4 or 0
            end
        else
            scrolling.ScrollBarThickness = 0
        end

        if activeTween then activeTween:Cancel() activeTween = nil end
        local targetSize = UDim2.fromOffset(targetWidth, targetHeight)

        if animate and not (isEdgeMode() and dragging) then
            activeTween = TweenService:Create(frame, tweenInfo, { Size = targetSize })
            activeTween:Play()
        else
            frame.Size = targetSize
        end
    end

    connect(layout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
        if not collapsed then updateFrameSize(true) end
    end)

    connect(screen:GetPropertyChangedSignal("AbsoluteSize"), function()
        if isEdgeMode() and not collapsed then updateFrameSize(false) end
    end)

    local function setContentTransparency(transparency, instant)
        for _, ui in pairs(labels) do
            tween(ui.text, tweenInfo, { TextTransparency = transparency }, instant)
            local stroke = ui.text:FindFirstChild("Outline")
            if stroke then tween(stroke, tweenInfo, { Transparency = transparency }, instant) end
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
    renderLine = function(id, instant)
        local ui = labels[id]
        local saved = lineData[id]
        if not ui or not saved then return end

        ui.text.Text = saved.text.text or ""
        tween(ui.text, quickInfo, { TextColor3 = saved.text.color or lineTextColor() }, instant)

        if saved.text.font then
            ui.text.Font = saved.text.font
        else
            ui.text.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
        end

        applyOutline(ui.text, saved.text)

        if saved.toggle then
            local t = saved.toggle
            local active = t.value == true
            local left = (t.side == "left")

            ui.padding.PaddingLeft   = UDim.new(0, left and (8 + TRACK_W + 8) or 8)
            ui.padding.PaddingRight  = UDim.new(0, left and 8 or (8 + TRACK_W + 8))
            ui.padding.PaddingTop    = UDim.new(0, 5)
            ui.padding.PaddingBottom = UDim.new(0, 5)

            ui.track.Visible = true
            ui.glow.Visible = true
            local trackPos = left and UDim2.new(0, -(TRACK_W + 8), 0.5, -TRACK_H / 2)
                or UDim2.new(1, 8, 0.5, -TRACK_H / 2)
            ui.track.Position = trackPos
            ui.glow.Position = UDim2.new(trackPos.X.Scale, trackPos.X.Offset + TRACK_W / 2, trackPos.Y.Scale, trackPos.Y.Offset + TRACK_H / 2)

            ui.text.Position = UDim2.new(0, 0, 0, 0)
            ui.text.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)

            local onColor  = t.enabledColor or t.color or accentColor()
            local offColor = t.disabledColor or Color3.fromRGB(40, 45, 62)
            local strokeColor = t.outlineColor or (active and Fx.lighten(onColor, 0.35) or Color3.fromRGB(88, 95, 120))

            tween(ui.track, quickInfo, { BackgroundColor3 = active and onColor or offColor }, instant)
            tween(ui.trackStroke, quickInfo, { Color = strokeColor, Transparency = active and 0.3 or 0.15 }, instant)
            tween(ui.shine, quickInfo, { BackgroundTransparency = active and 0.55 or 0.8 }, instant)
            ui.glow.ImageColor3 = onColor
            tween(ui.glow, quickInfo, { ImageTransparency = active and 0.6 or 1 }, instant)

            local kw = (ui.pressed == true) and (KNOB_H + 4) or KNOB_H
            local kpos = active and UDim2.new(1, -(kw + 2), 0.5, -KNOB_H / 2) or UDim2.new(0, 2, 0.5, -KNOB_H / 2)
            tween(ui.knob, TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = kpos, Size = UDim2.fromOffset(kw, KNOB_H) }, instant)

            if t.image then
                ui.knob.BackgroundTransparency = 1
                ui.knob.Image = t.image
                ui.knob.ImageColor3 = WHITE
            else
                ui.knob.BackgroundTransparency = 0
                ui.knob.Image = ""
                ui.knob.BackgroundColor3 = WHITE
            end
        else
            ui.padding.PaddingLeft   = UDim.new(0, 8)
            ui.padding.PaddingRight  = UDim.new(0, 8)
            ui.padding.PaddingTop    = UDim.new(0, 3)
            ui.padding.PaddingBottom = UDim.new(0, 3)
            ui.track.Visible = false
            ui.glow.Visible = false
            ui.text.Position = UDim2.new(0, 0, 0, 0)
            ui.text.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
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
            lineFrame.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
            lineFrame.AutomaticSize = isHorizontal and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y
            lineFrame.BackgroundColor3 = WHITE
            lineFrame.BackgroundTransparency = 1
            lineFrame.BorderSizePixel = 0
            lineFrame.Parent = scrolling

            local lineCorner = Instance.new("UICorner")
            lineCorner.CornerRadius = UDim.new(0, 6)
            lineCorner.Parent = lineFrame

            local padding = Instance.new("UIPadding")
            padding.PaddingLeft   = UDim.new(0, 8)
            padding.PaddingRight  = UDim.new(0, 8)
            padding.PaddingTop    = UDim.new(0, 3)
            padding.PaddingBottom = UDim.new(0, 3)
            padding.Parent = lineFrame

            local glow = Instance.new("ImageLabel")
            glow.Name = "ToggleGlow"
            glow.AnchorPoint = Vector2.new(0.5, 0.5)
            glow.Size = UDim2.fromOffset(TRACK_W + 22, TRACK_H + 22)
            glow.BackgroundTransparency = 1
            glow.Image = "rbxassetid://6014261993"
            glow.ScaleType = Enum.ScaleType.Slice
            glow.SliceCenter = Rect.new(49, 49, 450, 450)
            glow.ImageTransparency = 1
            glow.Visible = false
            glow.ZIndex = 0
            glow.Parent = lineFrame

            local label = Instance.new("TextLabel")
            label.Name = "Text"
            label.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
            label.AutomaticSize = isHorizontal and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y
            label.TextWrapped = not isHorizontal
            label.BackgroundTransparency = 1
            label.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium
            label.TextSize = textSize
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextYAlignment = Enum.TextYAlignment.Center
            label.TextTransparency = 1
            label.ZIndex = 1
            label.Parent = lineFrame

            local track = Instance.new("Frame")
            track.Name = "ToggleTrack"
            track.Size = UDim2.fromOffset(TRACK_W, TRACK_H)
            track.BackgroundColor3 = Color3.fromRGB(40, 45, 62)
            track.BorderSizePixel = 0
            track.Visible = false
            track.ZIndex = 2
            track.Parent = lineFrame

            local trackCorner = Instance.new("UICorner")
            trackCorner.CornerRadius = UDim.new(1, 0)
            trackCorner.Parent = track

            local trackGrad = Instance.new("UIGradient")
            trackGrad.Rotation = 90
            trackGrad.Color = Fx.shade(1, 0.38)
            trackGrad.Parent = track

            local trackStroke = Instance.new("UIStroke")
            trackStroke.Thickness = 1
            trackStroke.Color = Color3.fromRGB(88, 95, 120)
            trackStroke.Parent = track

            local shine = Instance.new("Frame")
            shine.Name = "Shine"
            shine.Size = UDim2.new(1, -12, 0, 1)
            shine.Position = UDim2.new(0, 6, 0, 2)
            shine.BackgroundColor3 = WHITE
            shine.BackgroundTransparency = 0.8
            shine.BorderSizePixel = 0
            shine.Active = false
            shine.Parent = track
            local shineGrad = Instance.new("UIGradient")
            shineGrad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(0.5, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            shineGrad.Parent = shine

            local knob = Instance.new("ImageButton")
            knob.Name = "ToggleKnob"
            knob.Size = UDim2.fromOffset(KNOB_H, KNOB_H)
            knob.Position = UDim2.new(0, 2, 0.5, -KNOB_H / 2)
            knob.BackgroundColor3 = WHITE
            knob.BorderSizePixel = 0
            knob.AutoButtonColor = false
            knob.Parent = track

            local knobCorner = Instance.new("UICorner")
            knobCorner.CornerRadius = UDim.new(1, 0)
            knobCorner.Parent = knob

            local knobGrad = Instance.new("UIGradient")
            knobGrad.Rotation = 90
            knobGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255), Color3.fromRGB(200, 206, 222))
            knobGrad.Parent = knob

            local knobStroke = Instance.new("UIStroke")
            knobStroke.Color = BLACK
            knobStroke.Transparency = 0.72
            knobStroke.Thickness = 1
            knobStroke.Parent = knob

            local function onDown(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                    local s = lineData[id]
                    local u = labels[id]
                    if s and s.toggle and u then
                        u.pressed = true
                        s.toggle.value = not (s.toggle.value or false)
                        renderLine(id)
                        if s.toggle.callback then
                            s.toggle.callback(s.toggle.value)
                        end
                    end
                end
            end
            track.InputBegan:Connect(onDown)
            knob.InputBegan:Connect(onDown)

            lineFrame.MouseEnter:Connect(function()
                local s = lineData[id]
                if s and s.toggle then
                    lineFrame.BackgroundColor3 = accentColor()
                    TweenService:Create(lineFrame, TweenInfo.new(0.12), { BackgroundTransparency = 0.9 }):Play()
                end
            end)
            lineFrame.MouseLeave:Connect(function()
                TweenService:Create(lineFrame, TweenInfo.new(0.18), { BackgroundTransparency = 1 }):Play()
            end)

            labels[id] = {
                frame = lineFrame, text = label, track = track, knob = knob,
                glow = glow, trackStroke = trackStroke, shine = shine,
                padding = padding, pressed = false,
            }
            lineData[id] = {
                id = id,
                text = { text = "", color = lineTextColor() },
                toggle = nil,
                order = nil, created = creationCounter,
            }
        end

        local saved = lineData[id]

        if type(saved.text) ~= "table" then
            saved.text = {
                text = tostring(saved.text or ""),
                color = saved.color or lineTextColor(),
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
        if type(data.text) == "table" and data.text.font ~= nil then saved.text.font = data.text.font end

        if data.toggle ~= nil then
            if saved.toggle == nil then saved.toggle = { value = false, side = "right" } end
            for k, v in pairs(data.toggle) do saved.toggle[k] = v end
        end

        renderLine(id, isNew)

        if isNew and not collapsed then
            local ui2 = labels[id]
            local stroke = ui2 and ui2.text:FindFirstChild("Outline")
            if stroke then stroke.Transparency = 1 end
            TweenService:Create(ui2.text, lineFadeInfo, { TextTransparency = 0 }):Play()
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
                    color = saved.color or lineTextColor(),
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
            if type(patch.text) == "table" and patch.text.font ~= nil then saved.text.font = patch.text.font end

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
                    if data.id then setLine(data) else applyGlobalPatch(data) end
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
        
        local imgOpened = pick(toggleImageCfg, "opened", "Opened")
        local imgCollapsed = pick(toggleImageCfg, "collapsed", "Collapsed")

        if collapsed then
            if imgCollapsed then
                arrow.Image = imgCollapsed
                arrowText.Visible = false
            else
                arrow.Image = ""
                arrowText.Text = "⌄"
                arrowText.Visible = true
            end
        else
            if imgOpened then
                arrow.Image = imgOpened
                arrowText.Visible = false
            else
                arrow.Image = ""
                arrowText.Text = "⌃"
                arrowText.Visible = true
            end
        end

        if collapsed then setContentTransparency(1, not animate) end
        updateFrameSize(animate)
        if not collapsed then setContentTransparency(0, not animate) end
    end

    local function playIntro()
        body.BackgroundTransparency = 1
        header.BackgroundTransparency = 1
        frameStroke.Transparency = 1
        shadow.ImageTransparency = 1
        depthParts.sheen.BackgroundTransparency = 1
        depthParts.gloss.BackgroundTransparency = 1
        uiScale.Scale = scale * 0.92

        local fade = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(uiScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = scale })
        tween(body, fade, { BackgroundTransparency = tBg() })
        tween(header, fade, { BackgroundTransparency = tTop() })
        tween(frameStroke, fade, { Transparency = tBorder() })
        tween(shadow, fade, { ImageTransparency = tShadow() })
        tween(depthParts.sheen, fade, { BackgroundTransparency = 0 })
        tween(depthParts.gloss, fade, { BackgroundTransparency = 0 })
    end

    local function playOutro(done)
        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(uiScale, ti, { Scale = scale * 0.94 })
        tween(body, ti, { BackgroundTransparency = 1 })
        tween(header, ti, { BackgroundTransparency = 1 })
        tween(frameStroke, ti, { Transparency = 1 })
        tween(shadow, ti, { ImageTransparency = 1 })
        tween(depthParts.sheen, ti, { BackgroundTransparency = 1 })
        tween(depthParts.gloss, ti, { BackgroundTransparency = 1 })
        setContentTransparency(1, false)
        task.delay(0.24, done)
    end

    for _, data in ipairs(pick(config, "Lines", "lines") or {}) do setLine(data) end
    updateOrder()
    
    local initImgOpened = pick(toggleImageCfg, "opened", "Opened")
    local initImgCollapsed = pick(toggleImageCfg, "collapsed", "Collapsed")
    if collapsed then
        if initImgCollapsed then arrow.Image = initImgCollapsed arrowText.Visible = false
        else arrowText.Text = "⌄" end
    else
        if initImgOpened then arrow.Image = initImgOpened arrowText.Visible = false
        else arrowText.Text = "⌃" end
    end

    if collapsed then setContentTransparency(1, true) end
    updateFrameSize(false)
    task.defer(function() if not collapsed then updateFrameSize(false) end end)
    playIntro()

    connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            for id, ui in pairs(labels) do
                if ui.pressed then
                    ui.pressed = false
                    renderLine(id)
                end
            end
        end
    end)

    if savePosId then
        local saveDebounce = false
        connect(frame:GetPropertyChangedSignal("Position"), function()
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

    connect(header.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(header.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    connect(UserInputService.InputChanged, function(input)
        if input == dragInput then updateDrag(input) end
    end)

    local hoverInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    connect(toggle.MouseEnter, function()
        tween(toggle, hoverInfo, { BackgroundColor3 = accentColor(), BackgroundTransparency = 0.02 })
        tween(arrowText, hoverInfo, { TextColor3 = WHITE })
        tween(toggleStroke, hoverInfo, { Transparency = 0.6 })
    end)
    connect(toggle.MouseLeave, function()
        tween(toggle, hoverInfo, { BackgroundColor3 = toggleBaseColor(), BackgroundTransparency = 0.1 })
        tween(arrowText, hoverInfo, { TextColor3 = toggleTextColor() })
        tween(toggleStroke, hoverInfo, { Transparency = 0.86 })
        tween(toggleScale, hoverInfo, { Scale = 1 })
    end)
    connect(toggle.MouseButton1Down, function()
        tween(toggleScale, TweenInfo.new(0.08), { Scale = 0.86 })
    end)
    connect(toggle.MouseButton1Up, function()
        tween(toggleScale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    end)
    connect(toggle.MouseButton1Click, function() setCollapsed(not collapsed, true) end)

    local api = {}
    local visToken = 0

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

    function api:Visible(state)
        if not screen then return end
        visToken = visToken + 1
        local my = visToken
        if state then
            screen.Enabled = true
            playIntro()
            if not collapsed then setContentTransparency(0, false) end
        else
            playOutro(function()
                if my == visToken and screen then screen.Enabled = false end
            end)
        end
    end

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

        v = pick(tbl, "Size", "size")
        if v ~= nil then
            size = resolveUDim2(v, size)
            updateFrameSize(true)
        end

        v = pick(tbl, "Scale", "scale")
        if v ~= nil then
            scale = v or 1
            tween(uiScale, tweenInfo, { Scale = scale })
            task.delay(tweenTime + 0.05, function() if not collapsed then updateFrameSize(true) end end)
        end

        v = pick(tbl, "Position", "position")
        if v ~= nil then
            frame.Position = resolveUDim2(v, frame.Position)
        end

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

        v = pick(tbl, "WindowEdge", "windowEdge")
        if v ~= nil then autoSizeWindowEdge = v == true end

        v = pick(tbl, "WindowEdgeWithSize", "windowEdgeWithSize")
        if v ~= nil then autoSizeWindowEdgeWithSize = v == true end

        v = pick(tbl, "side", "Side")
        if v ~= nil then
            local newSide = tostring(v):lower()
            if newSide ~= autoSizeSide then
                local oldAnchor = frame.AnchorPoint
                local pos = frame.Position
                local sizeX = frame.Size.X.Offset
                local sizeY = frame.Size.Y.Offset

                local tlScaleX = pos.X.Scale
                local tlOffsetX = pos.X.Offset - oldAnchor.X * sizeX
                local tlScaleY = pos.Y.Scale
                local tlOffsetY = pos.Y.Offset - oldAnchor.Y * sizeY

                autoSizeSide = newSide
                isHorizontal = (autoSizeSide == "left" or autoSizeSide == "right")

                local newAnchor = Vector2.new(0, 0)
                if autoSizeSide == "up" then newAnchor = Vector2.new(0, 1)
                elseif autoSizeSide == "left" then newAnchor = Vector2.new(1, 0) end

                frame.AnchorPoint = newAnchor
                frame.Position = UDim2.new(
                    tlScaleX, tlOffsetX + newAnchor.X * sizeX,
                    tlScaleY, tlOffsetY + newAnchor.Y * sizeY
                )

                if isHorizontal then
                    scrolling.ScrollingDirection = Enum.ScrollingDirection.XY
                    scrolling.AutomaticCanvasSize = Enum.AutomaticSize.XY
                else
                    scrolling.ScrollingDirection = Enum.ScrollingDirection.Y
                    scrolling.AutomaticCanvasSize = Enum.AutomaticSize.Y
                end

                for id, ui in pairs(labels) do
                    ui.frame.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
                    ui.frame.AutomaticSize = isHorizontal and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y
                    ui.text.TextWrapped = not isHorizontal
                    ui.text.AutomaticSize = isHorizontal and Enum.AutomaticSize.XY or Enum.AutomaticSize.Y
                    ui.text.Size = isHorizontal and UDim2.new(0, 0, 0, 0) or UDim2.new(1, 0, 0, 0)
                    renderLine(id, true)
                end
            end
        end

        updateFrameSize(true)
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end
        local oldLineColor = lineTextColor()

        local n = pick(tbl, "Background", "background")
        if n then
            local c = pick(n, "color", "Color")
            if c then bg.color = c tween(body, tweenInfo, { BackgroundColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then bg.transparency = t tween(body, tweenInfo, { BackgroundTransparency = t }) end
        end

        n = pick(tbl, "Topbar", "topbar")
        if n then
            local c = pick(n, "color", "Color")
            if c then topbar.color = c tween(header, tweenInfo, { BackgroundColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then topbar.transparency = t tween(header, tweenInfo, { BackgroundTransparency = t }) end
        end

        local accentChanged = false
        n = pick(tbl, "TopbarLine", "topbarLine")
        if n then
            local c = pick(n, "color", "Color")
            if c then topbarLine.color = c accentChanged = true end
        end
        n = pick(tbl, "Accent", "accent")
        if n then
            local c = pick(n, "color", "Color")
            if c then accentCfg.color = c accentChanged = true end
        end
        if accentChanged then
            local ac = accentColor()
            tween(accent, tweenInfo, { BackgroundColor3 = ac })
            tween(accentGlow, tweenInfo, { Color = ac })
            if not pick(scrollbarCfg, "color", "Color") then
                tween(scrolling, tweenInfo, { ScrollBarImageColor3 = ac })
            end
            for id, _ in pairs(labels) do renderLine(id) end
        end

        n = pick(tbl, "Title", "title")
        if n then
            local c = pick(n, "color", "Color")
            if c then titleCfg.color = c tween(titleLabel, tweenInfo, { TextColor3 = c }) end
        end

        n = pick(tbl, "Border", "border")
        if n then
            local c = pick(n, "color", "Color")
            if c then borderCfg.color = c end
            local th = pick(n, "thickness", "Thickness")
            if th then borderCfg.thickness = th frameStroke.Thickness = th end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then borderCfg.transparency = t tween(frameStroke, tweenInfo, { Transparency = t }) end
            borderGrad.set(cBorder(), depth)
        end

        n = pick(tbl, "Corner", "corner")
        if n then
            local r = pick(n, "radius", "Radius")
            if r then cornerCfg.radius = r corner.CornerRadius = UDim.new(0, r) headerCorner.CornerRadius = UDim.new(0, r) end
        end

        n = pick(tbl, "Shadow", "shadow")
        if n then
            local c = pick(n, "color", "Color")
            if c then shadowCfg.color = c tween(shadow, tweenInfo, { ImageColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then shadowCfg.transparency = t tween(shadow, tweenInfo, { ImageTransparency = t }) end
            local sz = pick(n, "size", "Size")
            if sz then shadowCfg.size = sz shadow.Size = UDim2.new(1, sz * 2, 1, sz * 2) end
        end

        n = pick(tbl, "LineToggle", "lineToggle")
        if n then
            local c = pick(n, "color", "Color")
            if c then lineToggleCfg.color = c tween(toggle, tweenInfo, { BackgroundColor3 = c }) end
            local tc = pick(n, "textColor", "TextColor")
            if tc then lineToggleCfg.textColor = tc tween(arrowText, tweenInfo, { TextColor3 = tc }) end
        end

        n = pick(tbl, "Scrollbar", "scrollbar")
        if n then
            local c = pick(n, "color", "Color")
            if c then scrollbarCfg.color = c tween(scrolling, tweenInfo, { ScrollBarImageColor3 = c }) end
        end

        n = pick(tbl, "LineText", "lineText")
        if n then
            local c = pick(n, "color", "Color")
            if c then
                lineTextCfg.color = c
                for id, saved in pairs(lineData) do
                    if saved.text.color == oldLineColor then saved.text.color = c end
                    renderLine(id)
                end
            end
        end

        n = pick(tbl, "Font", "font")
        if n then
            local f = pick(n, "text", "Text")
            if f then
                fontCfg.text = f
                for id, ui in pairs(labels) do
                    if not lineData[id].text.font then ui.text.Font = f end
                end
            end
            local tf = pick(n, "title", "Title")
            if tf then fontCfg.title = tf titleLabel.Font = tf end
        end

        n = pick(tbl, "ToggleImage", "toggleImage")
        if n then
            toggleImageCfg = n
            setCollapsed(collapsed, false)
        end

        if pick(tbl, "Depth", "depth") ~= nil then
            depth = Fx.depthStrength(tbl)
            depthParts.update(depth)
            headerGrad.Color = Fx.shade(depth, 0.22)
            borderGrad.set(cBorder(), depth)
        end
    end
    api.ApplyPreset = api.SetCustomWindow

    function api:Remove()
        if activeTween then activeTween:Cancel() activeTween = nil end
        for _, c in ipairs(connections) do c:Disconnect() end
        connections = {}
        if screen then screen:Destroy() screen = nil end
    end

    return api
end

--====================================================================
--  createInfoText
--====================================================================
function createInfoText(config)
    config = config or {}

    local RunService  = game:GetService("RunService")
    local TextService = game:GetService("TextService")

    local cw = pick(config, "CustomWindow", "customWindow") or {}
    local function sub(...) return Fx.copy(pick(cw, ...)) end

    local bg         = sub("Background", "background")
    local borderCfg  = sub("Border", "border")
    local cornerCfg  = sub("Corner", "corner")
    local paddingCfg = sub("Padding", "padding")
    local fontCfg    = sub("Font", "font")
    local shadowCfg  = sub("Shadow", "shadow")
    local depth      = Fx.depthStrength(cw)

    local function cBg()     return pick(bg, "color", "Color") or Color3.fromRGB(14, 17, 26) end
    local function tBg()     return pick(bg, "transparency", "Transparency") or 0.15 end
    local function cBorder() return pick(borderCfg, "color", "Color") or Color3.fromRGB(70, 85, 125) end
    local function tBorder() return pick(borderCfg, "transparency", "Transparency") or 0.2 end
    local function radius()  return pick(cornerCfg, "radius", "Radius") or 8 end
    local function tShadow() return pick(shadowCfg, "transparency", "Transparency") or 0.6 end

    local name         = pick(config, "Name", "name")         or "GhostRoomESP"
    local center       = pick(config, "Center", "center")
    local offset       = pick(config, "Offset", "offset")     or Vector3.new(0, 3, 0)
    local baseTextSize = pick(config, "TextSize", "textSize") or 20
    local textSize     = baseTextSize
    local defaultOutlineColor = pick(config, "OutlineColor", "outlineColor") or Color3.fromRGB(255, 255, 255)
    local defaultOutlineSize  = pick(config, "OutlineSize", "outlineSize")
    local zIndex = pick(config, "ZIndex", "zIndex") or 1

    local widthCfg = pick(config, "Width", "width") or {}
    local widthAuto = true
    local wa = pick(widthCfg, "auto", "Auto")
    if wa ~= nil then widthAuto = wa == true end
    local widthSize = pick(widthCfg, "size", "Size") or 300

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

    local billboard, container, windowFrame, shadowObj
    local uiScale
    local windowCornerObj, windowStrokeObj, borderGrad, depthParts
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

    local function applyWindowLayout(animate)
        if not windowFrame then return end
        local gt = showWindow and 0 or 1
        local st = showWindow and tShadow() or 1
        tween(windowFrame, sizeTweenInfo, { GroupTransparency = gt }, not animate)
        tween(shadowObj, sizeTweenInfo, { ImageTransparency = st }, not animate)
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

                local tSize = TextService:GetTextSize(text, label.TextSize, label.Font, bounds)
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
            if primary then adorneePos = primary.Position
            else
                local success, pivot = pcall(function() return adornee:GetPivot().Position end)
                if success then adorneePos = pivot else return end
            end
        elseif adornee:IsA("BasePart") then adorneePos = adornee.Position
        elseif adornee:IsA("Attachment") then adorneePos = adornee.WorldPosition
        else return end

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
        if container then container.Size = UDim2.fromOffset(basePixelSize.X, basePixelSize.Y) end

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
        billboard.ClipsDescendants = false
        billboard.Parent = adornee

        shadowObj = Fx.newShadow(billboard, shadowCfg, zIndex)
        shadowObj.ImageTransparency = 1

        windowFrame = Instance.new("CanvasGroup")
        windowFrame.Name = "Window"
        windowFrame.Size = UDim2.new(1, 0, 1, 0)
        windowFrame.BackgroundColor3 = cBg()
        windowFrame.BackgroundTransparency = tBg()
        windowFrame.BorderSizePixel = 0
        windowFrame.GroupTransparency = 1
        windowFrame.ZIndex = zIndex + 1
        windowFrame.Parent = billboard

        windowCornerObj = Instance.new("UICorner")
        windowCornerObj.CornerRadius = UDim.new(0, radius())
        windowCornerObj.Parent = windowFrame

        windowStrokeObj = Instance.new("UIStroke")
        windowStrokeObj.Name = "Border"
        windowStrokeObj.Color = WHITE
        windowStrokeObj.Thickness = pick(borderCfg, "thickness", "Thickness") or 1
        windowStrokeObj.Transparency = tBorder()
        windowStrokeObj.Parent = windowFrame
        borderGrad = Fx.addBorderGradient(windowStrokeObj, cBorder(), depth)

        depthParts = Fx.addDepth(windowFrame, depth, 1, radius())

        container = Instance.new("Frame")
        container.Name = "Container"
        container.AnchorPoint = Vector2.new(0.5, 0.5)
        container.Position = UDim2.new(0.5, 0, 0.5, 0)
        container.BackgroundTransparency = 1
        container.ZIndex = zIndex + 2
        container.Parent = billboard

        uiScale = Instance.new("UIScale")
        uiScale.Parent = container

        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 2)
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Parent = container

        applyWindowLayout(true)
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
        TweenService:Create(label, TweenInfo.new(0.15), { TextColor3 = saved.text.color or Color3.fromRGB(255, 255, 255) }):Play()

        if saved.text.font then label.Font = saved.text.font
        else label.Font = pick(fontCfg, "text", "Text") or Enum.Font.GothamMedium end

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
            label.TextColor3 = (data.color or (type(data.text) == "table" and data.text.color)) or Color3.fromRGB(255, 255, 255)
            label.ZIndex = zIndex + 3
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
            if type(data.text) == "string" then saved.text.text = data.text
            elseif type(data.text) == "table" then for k, v in pairs(data.text) do saved.text[k] = v end end
        end

        if data.color ~= nil then saved.text.color = data.color end
        if data.outlineColor ~= nil then saved.text.outlineColor = data.outlineColor end
        if data.outlineSize ~= nil then saved.text.outlineSize = data.outlineSize == false and nil or data.outlineSize end
        if data.order ~= nil then saved.order = data.order == false and nil or data.order end
        if type(data.text) == "table" and data.text.font ~= nil then saved.text.font = data.text.font end

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
            if type(patch.text) == "table" and patch.text.font ~= nil then saved.text.font = patch.text.font end
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

    local renderName = "InfoText_" .. name .. "_" .. tostring(math.random(1000, 9999))
    RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 1, function()
        if not billboard or not billboard.Parent or not billboard.Adornee then return end
        if constantEnabled then applyDynamicSize() end
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
            if constantEnabled then applyDynamicSize()
            else billboard.Enabled = isActive end
        end
    end

    function api:ShowWindow(state)
        showWindow = state == true
        if billboard then applyWindowLayout(true) updateSize(true) end
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
            for _, label in pairs(labels) do label.TextWrapped = not widthAuto end
            updateSize(true)
        end

        v = pick(tbl, "TextSize", "textSize")
        if v ~= nil then
            baseTextSize = v
            textSize = baseTextSize
            for _, label in pairs(labels) do label.TextSize = textSize end
            updateSize(true)
        end

        v = pick(tbl, "ShowWindow", "showWindow")
        if v ~= nil then api:ShowWindow(v) end

        v = pick(tbl, "ZIndex", "zIndex")
        if v ~= nil then
            zIndex = tonumber(v) or zIndex
            if shadowObj then shadowObj.ZIndex = zIndex end
            if windowFrame then windowFrame.ZIndex = zIndex + 1 end
            if container then container.ZIndex = zIndex + 2 end
            for _, label in pairs(labels) do label.ZIndex = zIndex + 3 end
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
        if v ~= nil then sizeTweenInfo = TweenInfo.new(v, Enum.EasingStyle.Quint, Enum.EasingDirection.Out) end
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end

        local n = pick(tbl, "Background", "background")
        if n then
            local c = pick(n, "color", "Color")
            if c then bg.color = c tween(windowFrame, sizeTweenInfo, { BackgroundColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then bg.transparency = t tween(windowFrame, sizeTweenInfo, { BackgroundTransparency = t }) end
        end

        n = pick(tbl, "Border", "border")
        if n then
            local c = pick(n, "color", "Color")
            if c then borderCfg.color = c end
            local th = pick(n, "thickness", "Thickness")
            if th then borderCfg.thickness = th if windowStrokeObj then windowStrokeObj.Thickness = th end end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then borderCfg.transparency = t tween(windowStrokeObj, sizeTweenInfo, { Transparency = t }) end
            if borderGrad then borderGrad.set(cBorder(), depth) end
        end

        n = pick(tbl, "Corner", "corner")
        if n then
            local r = pick(n, "radius", "Radius")
            if r then cornerCfg.radius = r if windowCornerObj then windowCornerObj.CornerRadius = UDim.new(0, r) end end
        end

        n = pick(tbl, "Shadow", "shadow")
        if n then
            local c = pick(n, "color", "Color")
            if c then shadowCfg.color = c tween(shadowObj, sizeTweenInfo, { ImageColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then
                shadowCfg.transparency = t
                if showWindow then tween(shadowObj, sizeTweenInfo, { ImageTransparency = t }) end
            end
            local sz = pick(n, "size", "Size")
            if sz then shadowCfg.size = sz if shadowObj then shadowObj.Size = UDim2.new(1, sz * 2, 1, sz * 2) end end
        end

        n = pick(tbl, "Padding", "padding")
        if n then
            local pv = pick(n, "value", "Value")
            if pv then paddingCfg.value = pv updateSize(true) end
        end

        n = pick(tbl, "Font", "font")
        if n then
            local f = pick(n, "text", "Text")
            if f then
                fontCfg.text = f
                for id, label in pairs(labels) do
                    if not lineData[id].text.font then label.Font = f end
                end
                updateSize(true)
            end
        end

        if pick(tbl, "Depth", "depth") ~= nil then
            depth = Fx.depthStrength(tbl)
            if depthParts then depthParts.update(depth) end
            if borderGrad then borderGrad.set(cBorder(), depth) end
        end
    end
    api.ApplyPreset = api.SetCustomWindow

    function api:Remove()
        if activeSizeTween then activeSizeTween:Cancel() activeSizeTween = nil end
        RunService:UnbindFromRenderStep(renderName)
        if billboard then
            billboard:Destroy()
            billboard = nil
            container = nil
            windowFrame = nil
            shadowObj = nil
            uiScale = nil
            windowCornerObj = nil
            windowStrokeObj = nil
            borderGrad = nil
            depthParts = nil
        end
        labels, lineData = {}, {}
        pendingOrder, pendingData = {}, {}
    end

    return api
end


--====================================================================
--  createRadar
--====================================================================
function createRadar(config)
    config = config or {}

    local Players          = game:GetService("Players")
    local RunService       = game:GetService("RunService")
    local CoreGui          = game:GetService("CoreGui")
    local UserInputService = game:GetService("UserInputService")

    local cw = pick(config, "CustomWindow", "customWindow") or {}
    local function sub(...) return Fx.copy(pick(cw, ...)) end

    local bg           = sub("Background", "background")
    local borderCfg    = sub("Border", "border")
    local cornerCfg    = sub("Corner", "corner")
    local titleCfg     = sub("Title", "title")
    local radarCfg     = sub("Radar", "radar")
    local gridCfg      = sub("Grid", "grid")
    local crosshairCfg = sub("Crosshair", "crosshair")
    local fontCfg      = sub("Font", "font")
    local shadowCfg    = sub("Shadow", "shadow")
    local accentCfg    = sub("Accent", "accent")
    local topbarLine   = sub("TopbarLine", "topbarLine")
    local depth        = Fx.depthStrength(cw)

    local function accentColor()
        return pick(accentCfg, "color", "Color") or pick(topbarLine, "color", "Color") or Color3.fromRGB(70, 140, 255)
    end
    local function cBg()     return pick(bg, "color", "Color") or Color3.fromRGB(12, 14, 22) end
    local function tBg()     return pick(bg, "transparency", "Transparency") or 0.08 end
    local function cBorder() return pick(borderCfg, "color", "Color") or Color3.fromRGB(70, 85, 125) end
    local function tBorder() return pick(borderCfg, "transparency", "Transparency") or 0.2 end
    local function cRadar()  return pick(radarCfg, "color", "Color") or Color3.fromRGB(6, 8, 14) end
    local function tRadar()  return pick(radarCfg, "transparency", "Transparency") or 0.1 end
    local function cGrid()   return pick(gridCfg, "color", "Color") or Color3.fromRGB(70, 80, 105) end
    local function cCross()  return pick(crosshairCfg, "color", "Color") or Color3.fromRGB(60, 68, 90) end
    local function tShadow() return pick(shadowCfg, "transparency", "Transparency") or 0.55 end

    local Name         = pick(config, "Name", "name")         or "CustomRadar"
    local Title        = pick(config, "Title", "title")       or "Radar"
    local Position     = pick(config, "Position", "position") or UDim2.new(0.03, 0, 0.3, 0)
    local Size         = math.max(tonumber(pick(config, "Size", "size")) or 100, 0.01)
    local Scale        = tonumber(pick(config, "Scale", "scale")) or 1
    local Range        = math.max(tonumber(pick(config, "Range", "range")) or 100, 0)
    local Center       = pick(config, "Center", "center") or Players.LocalPlayer
    local CenterOffset = pick(config, "CenterOffset", "centerOffset") or Vector3.zero
    local EDGE_TEXT_HIDE_THRESHOLD = tonumber(pick(config, "TextHideThreshold", "textHideThreshold")) or 0.95

    local sweepEnabled = pick(config, "Sweep", "sweep")
    if sweepEnabled == nil then sweepEnabled = pick(radarCfg, "sweep", "Sweep") end
    if sweepEnabled == nil then sweepEnabled = true end
    local sweepSpeed = tonumber(pick(config, "SweepSpeed", "sweepSpeed")) or 110

    local enabled = true
    local targets = {}
    local WINDOW_SIZE, WINDOW_HEIGHT = 220, 260
    local RADAR_SIZE = 190
    local tinfo = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local connections = {}
    local function connect(signal, fn)
        local c = signal:Connect(fn)
        table.insert(connections, c)
        return c
    end

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
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = false
    frame.Parent = gui

    local introScale = Instance.new("UIScale")
    introScale.Parent = frame

    local shadow = Fx.newShadow(frame, shadowCfg, 0)

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.Size = UDim2.new(1, 0, 1, 0)
    body.BackgroundColor3 = cBg()
    body.BackgroundTransparency = tBg()
    body.BorderSizePixel = 0
    body.Active = true
    body.ClipsDescendants = true
    body.ZIndex = 1
    body.Parent = frame

    local frameCorner = Instance.new("UICorner")
    frameCorner.CornerRadius = UDim.new(0, pick(cornerCfg, "radius", "Radius") or 14)
    frameCorner.Parent = body

    local frameStroke = Instance.new("UIStroke")
    frameStroke.Color = WHITE
    frameStroke.Thickness = pick(borderCfg, "thickness", "Thickness") or 1.5
    frameStroke.Transparency = tBorder()
    frameStroke.Parent = body
    local frameBorderGrad = Fx.addBorderGradient(frameStroke, cBorder(), depth)

    local depthParts = Fx.addDepth(body, depth, 1, pick(cornerCfg, "radius", "Radius") or 14)

    local accentBar = Instance.new("Frame")
    accentBar.Name = "Accent"
    accentBar.Position = UDim2.fromOffset(12, 11)
    accentBar.Size = UDim2.fromOffset(3, 14)
    accentBar.BackgroundColor3 = accentColor()
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 4
    accentBar.Parent = body
    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(1, 0)
    abCorner.Parent = accentBar
    local abGlow = Instance.new("UIStroke")
    abGlow.Color = accentColor()
    abGlow.Thickness = 3
    abGlow.Transparency = 0.72
    abGlow.Parent = accentBar

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Position = UDim2.fromOffset(22, 4)
    title.Size = UDim2.new(1, -34, 0, 28)
    title.Font = pick(fontCfg, "title", "Title") or Enum.Font.GothamBold
    title.Text = Title
    title.TextColor3 = pick(titleCfg, "color", "Color") or Color3.fromRGB(240, 243, 252)
    title.TextTransparency = pick(titleCfg, "transparency", "Transparency") or 0
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 4
    title.Parent = body

    local titleSep = Instance.new("Frame")
    titleSep.Size = UDim2.new(1, -24, 0, 1)
    titleSep.Position = UDim2.fromOffset(12, 34)
    titleSep.BackgroundColor3 = WHITE
    titleSep.BackgroundTransparency = 0.9
    titleSep.BorderSizePixel = 0
    titleSep.ZIndex = 3
    titleSep.Parent = body

    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end

    connect(title.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    connect(title.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    connect(UserInputService.InputChanged, function(input)
        if input == dragInput and dragging then update(input) end
    end)

    local radar = Instance.new("Frame")
    radar.Name = "Radar"
    radar.Size = UDim2.fromOffset(RADAR_SIZE, RADAR_SIZE)
    radar.Position = UDim2.new(0.5, -RADAR_SIZE / 2, 0, 46)
    radar.BackgroundColor3 = cRadar()
    radar.BackgroundTransparency = tRadar()
    radar.BorderSizePixel = 0
    radar.ClipsDescendants = true
    radar.ZIndex = 2
    radar.Parent = body

    local radarCorner = Instance.new("UICorner")
    radarCorner.CornerRadius = UDim.new(1, 0)
    radarCorner.Parent = radar

    local radarStroke = Instance.new("UIStroke")
    radarStroke.Color = WHITE
    radarStroke.Thickness = 2.5
    radarStroke.Transparency = tBorder()
    radarStroke.Parent = radar
    local radarBorderGrad = Fx.addBorderGradient(radarStroke, cBorder(), depth)

    local radarDepth = Fx.addDepth(radar, depth * 0.8, 1, 100)

    local gridStrokes = {}
    local function createCircle(csize, transparency)
        local circle = Instance.new("Frame")
        circle.BackgroundTransparency = 1
        circle.Size = UDim2.new(csize, 0, csize, 0)
        circle.Position = UDim2.new(0.5, 0, 0.5, 0)
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        circle.ZIndex = 2
        circle.Parent = radar
        local cr = Instance.new("UICorner")
        cr.CornerRadius = UDim.new(1, 0)
        cr.Parent = circle
        local stroke = Instance.new("UIStroke")
        stroke.Color = cGrid()
        stroke.Thickness = 1
        stroke.Transparency = transparency or 0
        stroke.Parent = circle
        table.insert(gridStrokes, stroke)
    end

    createCircle(0.84, 0.55)
    createCircle(0.66, 0.35)
    createCircle(0.42, 0.2)

    local crossLines = {}
    local function createCross(horizontal)
        local line = Instance.new("Frame")
        line.BackgroundColor3 = cCross()
        line.BackgroundTransparency = 0.2
        line.BorderSizePixel = 0
        line.ZIndex = 2
        if horizontal then
            line.AnchorPoint = Vector2.new(0, 0.5)
            line.Position = UDim2.new(0, 0, 0.5, 0)
            line.Size = UDim2.new(1, 0, 0, 1)
        else
            line.AnchorPoint = Vector2.new(0.5, 0)
            line.Position = UDim2.new(0.5, 0, 0, 0)
            line.Size = UDim2.new(0, 1, 1, 0)
        end
        line.Parent = radar
        local g = Instance.new("UIGradient")
        g.Rotation = horizontal and 0 or 90
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.9),
            NumberSequenceKeypoint.new(0.5, 0.1),
            NumberSequenceKeypoint.new(1, 0.9),
        })
        g.Parent = line
        table.insert(crossLines, line)
    end
    createCross(true)
    createCross(false)

    local sweepHolder = Instance.new("Frame")
    sweepHolder.Name = "Sweep"
    sweepHolder.BackgroundTransparency = 1
    sweepHolder.Size = UDim2.new(1, 0, 1, 0)
    sweepHolder.ZIndex = 3
    sweepHolder.Visible = sweepEnabled
    sweepHolder.Parent = radar

    local sweepLines = {}
    local TRAIL = 12
    for i = 0, TRAIL - 1 do
        local h = Instance.new("Frame")
        h.BackgroundTransparency = 1
        h.Size = UDim2.new(1, 0, 1, 0)
        h.Rotation = -i * 3
        h.ZIndex = 3
        h.Parent = sweepHolder

        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(0.5, 0)
        line.Position = UDim2.new(0.5, 0, 0, 0)
        line.Size = UDim2.new(0, i == 0 and 2 or 6, 0.5, 0)
        line.BackgroundColor3 = accentColor()
        line.BackgroundTransparency = (i == 0) and 0.1 or (0.55 + (i / TRAIL) * 0.45)
        line.BorderSizePixel = 0
        line.ZIndex = 3
        line.Parent = h
        table.insert(sweepLines, line)
    end

    local centerDot = Instance.new("Frame")
    centerDot.AnchorPoint = Vector2.new(0.5, 0.5)
    centerDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    centerDot.Size = UDim2.fromOffset(6, 6)
    centerDot.BackgroundColor3 = accentColor()
    centerDot.BorderSizePixel = 0
    centerDot.ZIndex = 6
    centerDot.Parent = radar
    local cdCorner = Instance.new("UICorner")
    cdCorner.CornerRadius = UDim.new(1, 0)
    cdCorner.Parent = centerDot
    local cdGlow = Instance.new("UIStroke")
    cdGlow.Color = accentColor()
    cdGlow.Thickness = 3
    cdGlow.Transparency = 0.6
    cdGlow.Parent = centerDot

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
        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(1, 0)
        pc.Parent = point
        local glow = Instance.new("UIStroke")
        glow.Color = data.color or Color3.new(1, 1, 1)
        glow.Thickness = 2.5
        glow.Transparency = 0.6
        glow.Parent = point
        local obj = { point = point, text = nil, data = data, glow = glow }
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
        if sweepEnabled then
            sweepHolder.Rotation = (os.clock() * sweepSpeed) % 360
        end
        for id, object in pairs(targetObjects) do updateTarget(id, object) end
    end)

    local function playIntro()
        body.BackgroundTransparency = 1
        frameStroke.Transparency = 1
        shadow.ImageTransparency = 1
        depthParts.sheen.BackgroundTransparency = 1
        depthParts.gloss.BackgroundTransparency = 1
        introScale.Scale = 0.9
        local fade = TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        tween(introScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        tween(body, fade, { BackgroundTransparency = tBg() })
        tween(frameStroke, fade, { Transparency = tBorder() })
        tween(shadow, fade, { ImageTransparency = tShadow() })
        tween(depthParts.sheen, fade, { BackgroundTransparency = 0 })
        tween(depthParts.gloss, fade, { BackgroundTransparency = 0 })
    end

    local function playOutro(done)
        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        tween(introScale, ti, { Scale = 0.94 })
        tween(body, ti, { BackgroundTransparency = 1 })
        tween(frameStroke, ti, { Transparency = 1 })
        tween(shadow, ti, { ImageTransparency = 1 })
        tween(depthParts.sheen, ti, { BackgroundTransparency = 1 })
        tween(depthParts.gloss, ti, { BackgroundTransparency = 1 })
        task.delay(0.24, done)
    end
    playIntro()

    local api = {}
    local visToken = 0

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

            tween(old.point, TweenInfo.new(0.15), {
                BackgroundColor3 = finalData.color,
                Size = UDim2.fromOffset(finalData.size, finalData.size),
            })
            tween(old.glow, TweenInfo.new(0.15), { Color = finalData.color })

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
            for _, data in ipairs(listOrData) do applyOne(data) end
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

    function api:Visible(state)
        state = state ~= false
        visToken = visToken + 1
        local my = visToken
        if state then
            enabled = true
            gui.Enabled = true
            playIntro()
        else
            enabled = false
            playOutro(function()
                if my == visToken then gui.Enabled = false end
            end)
        end
    end

    function api:SetParameter(tbl)
        if type(tbl) ~= "table" then return end
        local v

        v = pick(tbl, "Title", "title")
        if v ~= nil then Title = tostring(v) title.Text = Title end

        v = pick(tbl, "Position", "position")
        if v ~= nil then Position = v tween(frame, tinfo, { Position = v }) end

        v = pick(tbl, "Scale", "scale")
        if v ~= nil then Scale = tonumber(v) or Scale tween(scaleObject, tinfo, { Scale = Scale }) end

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

        v = pick(tbl, "Sweep", "sweep")
        if v ~= nil then sweepEnabled = v == true sweepHolder.Visible = sweepEnabled end

        v = pick(tbl, "SweepSpeed", "sweepSpeed")
        if v ~= nil then sweepSpeed = tonumber(v) or sweepSpeed end
    end

    function api:SetCustomWindow(tbl)
        if type(tbl) ~= "table" then return end

        local n = pick(tbl, "Background", "background")
        if n then
            local c = pick(n, "color", "Color")
            if c then bg.color = c tween(body, tinfo, { BackgroundColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then bg.transparency = t tween(body, tinfo, { BackgroundTransparency = t }) end
        end

        n = pick(tbl, "Border", "border")
        if n then
            local c = pick(n, "color", "Color")
            if c then borderCfg.color = c end
            local th = pick(n, "thickness", "Thickness")
            if th then borderCfg.thickness = th frameStroke.Thickness = th end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then
                borderCfg.transparency = t
                tween(frameStroke, tinfo, { Transparency = t })
                tween(radarStroke, tinfo, { Transparency = t })
            end
            frameBorderGrad.set(cBorder(), depth)
            radarBorderGrad.set(cBorder(), depth)
        end

        n = pick(tbl, "Corner", "corner")
        if n then
            local r = pick(n, "radius", "Radius")
            if r then cornerCfg.radius = r frameCorner.CornerRadius = UDim.new(0, r) end
        end

        n = pick(tbl, "Title", "title")
        if n then
            local c = pick(n, "color", "Color")
            if c then titleCfg.color = c tween(title, tinfo, { TextColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then titleCfg.transparency = t title.TextTransparency = t end
        end

        n = pick(tbl, "Radar", "radar")
        if n then
            local c = pick(n, "color", "Color")
            if c then radarCfg.color = c tween(radar, tinfo, { BackgroundColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then radarCfg.transparency = t tween(radar, tinfo, { BackgroundTransparency = t }) end
            local sw = pick(n, "sweep", "Sweep")
            if sw ~= nil then sweepEnabled = sw == true sweepHolder.Visible = sweepEnabled end
        end

        n = pick(tbl, "Grid", "grid")
        if n then
            local c = pick(n, "color", "Color")
            if c then
                gridCfg.color = c
                for _, s in ipairs(gridStrokes) do tween(s, tinfo, { Color = c }) end
            end
        end

        n = pick(tbl, "Crosshair", "crosshair")
        if n then
            local c = pick(n, "color", "Color")
            if c then
                crosshairCfg.color = c
                for _, l in ipairs(crossLines) do tween(l, tinfo, { BackgroundColor3 = c }) end
            end
        end

        local accentChanged = false
        n = pick(tbl, "TopbarLine", "topbarLine")
        if n then
            local c = pick(n, "color", "Color")
            if c then topbarLine.color = c accentChanged = true end
        end
        n = pick(tbl, "Accent", "accent")
        if n then
            local c = pick(n, "color", "Color")
            if c then accentCfg.color = c accentChanged = true end
        end
        if accentChanged then
            local ac = accentColor()
            tween(accentBar, tinfo, { BackgroundColor3 = ac })
            tween(abGlow, tinfo, { Color = ac })
            tween(centerDot, tinfo, { BackgroundColor3 = ac })
            tween(cdGlow, tinfo, { Color = ac })
            for _, l in ipairs(sweepLines) do tween(l, tinfo, { BackgroundColor3 = ac }) end
        end

        n = pick(tbl, "Shadow", "shadow")
        if n then
            local c = pick(n, "color", "Color")
            if c then shadowCfg.color = c tween(shadow, tinfo, { ImageColor3 = c }) end
            local t = pick(n, "transparency", "Transparency")
            if t ~= nil then shadowCfg.transparency = t tween(shadow, tinfo, { ImageTransparency = t }) end
            local sz = pick(n, "size", "Size")
            if sz then shadowCfg.size = sz shadow.Size = UDim2.new(1, sz * 2, 1, sz * 2) end
        end

        n = pick(tbl, "Font", "font")
        if n then
            local f = pick(n, "text", "Text")
            if f then
                fontCfg.text = f
                for _, obj in pairs(targetObjects) do if obj.text then obj.text.Font = f end end
            end
            local tf = pick(n, "title", "Title")
            if tf then fontCfg.title = tf title.Font = tf end
        end

        if pick(tbl, "Depth", "depth") ~= nil then
            depth = Fx.depthStrength(tbl)
            depthParts.update(depth)
            radarDepth.update(depth * 0.8)
            frameBorderGrad.set(cBorder(), depth)
            radarBorderGrad.set(cBorder(), depth)
        end
    end
    api.ApplyPreset = api.SetCustomWindow

    function api:Remove()
        RunService:UnbindFromRenderStep(renderName)
        for _, c in ipairs(connections) do c:Disconnect() end
        connections = {}
        gui:Destroy()
    end

    return api
end


--====================================================================
--  Presets: готовые CustomWindow в стиле Blue Oblivion
--====================================================================
local Presets = {}

function Presets.Make(accent, deep, opts)
    opts = opts or {}
    local glass = opts.transparency or 0.3
    return {
        Background = { color = deep, transparency = glass },
        Topbar     = { color = deep:Lerp(accent, 0.12), transparency = math.clamp(glass + 0.07, 0, 1) },
        TopbarLine = { color = accent },
        Accent     = { color = accent },
        Title      = { color = WHITE:Lerp(accent, 0.12) },
        Border     = { color = accent, thickness = 1, transparency = 0.25 },
        Corner     = { radius = 12 },
        Shadow     = { color = accent, transparency = 0.72, size = 26 },
        LineToggle = { color = deep:Lerp(accent, 0.2), textColor = WHITE:Lerp(accent, 0.2) },
        Scrollbar  = { color = accent },
        LineText   = { color = Color3.fromRGB(218, 224, 240):Lerp(accent, 0.08) },
        Font       = { title = Enum.Font.BuilderSansBold, text = Enum.Font.BuilderSansMedium },
        Radar      = { color = deep:Lerp(BLACK, 0.3), transparency = glass * 0.6 },
        Grid       = { color = accent:Lerp(deep, 0.55) },
        Crosshair  = { color = accent:Lerp(deep, 0.6) },
        Padding    = { value = 9 },
        Depth      = { strength = 1 },
    }
end

Presets.Blue  = Presets.Make(Color3.fromRGB(56, 128, 255), Color3.fromRGB(8, 12, 26))
Presets.Green = Presets.Make(Color3.fromRGB(46, 230, 130), Color3.fromRGB(6, 20, 15))
Presets.Red   = Presets.Make(Color3.fromRGB(255, 66, 84),  Color3.fromRGB(24, 8, 12))

return {
    createInfoGui  = createInfoGui,
    createInfoText = createInfoText,
    createRadar    = createRadar,
    Presets        = Presets,
}
