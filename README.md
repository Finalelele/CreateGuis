# CreateGuis
loadstring(game:HttpGet("https://raw.githubusercontent.com/Finalelele/CreateGuis/refs/heads/main/GuisTest.lua?t="..tick()))()

loadstring(game:HttpGet("https://raw.githubusercontent.com/Finalelele/CreateGuis/refs/heads/main/Guis.lua?t="..tick()))()

# CreateGuis

Customizable, animated windows for Roblox: **Info Gui** (draggable window with lines and toggles), **Info Text Gui** (billboard text above an object) and **Radar**.

> **Notes**
> - Every key accepts both `PascalCase` and `camelCase` (`Title` / `title`, `AutoSize` / `autoSize`, `enabled` / `Enabled`).
> - Parameters shown as `a|b|c` mean you have to pick one of the listed values.
> - `SavePos` uses executor file functions (`isfile`, `readfile`, `writefile`).

## Loading

```lua
local Guis = loadstring(game:HttpGet("https://raw.githubusercontent.com/Finalelele/CreateGuis/refs/heads/main/Guis.lua?t="..tick()))()
```

`Guis` contains `createInfoGui`, `createInfoText`, `createRadar` and `Presets`.

---

# Info Gui

## How to create info gui

Short example:

```lua
local InfoGui = Guis.createInfoGui({
	Name = "InfoGui",
	Title = "Example",
	Size = {x = 200, y = 500},
	Scale = 1,
	AutoSize = {enabled = true},
	SavePos = {enabled = false, id = "InfoGui"},
	Position = UDim2.new(0.05, 0, 0.15, 0),
	Lines = {
		{id = "example", text = {text = "example text"}},
	}
})
```

### Parameters

```
Name         = string                       (window core name), default: "CustomWindow"
Title        = string                       (text in the title bar), default: "Window"
Reload       = true|false                   (if true, this window is destroyed and replaced when a window
                                             with the same Name is created again), default: true
Size         = UDim2.new(...) or {x = number, y = number}
                                            (window size in pixels: x = width, y = max height;
                                             with AutoSize the window grows with content up to y),
                                            default: {x = 200, y = 500}
Scale        = number                       (UI scale of the whole window), default: 1
Position     = UDim2.new(...) or {x = number, y = number}
                                            (window position; {x, y} are pixel offsets),
                                            default: UDim2.new(0.05, 0, 0.15, 0)
TextSize     = number                       (lines text size, title is TextSize + 2), default: 14
TweenTime    = number                       (seconds, window resize animation), default: 0.22
Collapsed    = true|false                   (start collapsed), default: false

AutoSize = {
	enabled            = true|false         (window fits its content), default: true
	side               = "down"|"up"|"left"|"right"
	                                        (direction the window grows to), default: "down"
	WindowEdge         = true|false         (limit growth by the screen edge), default: false
	WindowEdgeWithSize = true|false         (with WindowEdge: also never exceed Size), default: false
}

SavePos = {
	enabled = true|false                    (load/save window position and collapsed state), default: false
	id      = string                        (unique id of the saved entry, required for saving)
}

Lines        = { line, line, ... }          (see "Line parameters" below)
CustomWindow = { ... }                      (colors / style, see "CustomWindow styling and presets")
```

### Line parameters

```lua
Lines = {
	{
		id = "example 1",                   -- string (unique id, used to change/remove this line)

		text = {                            -- string or table. {text = "..."} is the same as "..."
			text = "example text",          -- string (line text), default: ""
			color = Color3.fromRGB(255, 255, 255),  -- Color3 (text color), default: LineText color
			font = Enum.Font.GothamMedium,  -- Enum.Font (text font), default: Enum.Font.GothamMedium
			outlineColor = Color3.fromRGB(255, 255, 255), -- Color3 (text outline color), default: white
			outlineSize = 1,                -- number|false (text outline thickness), default: none
		},

		-- shortcuts, same as the same keys inside text = {...}
		color = Color3.fromRGB(255, 255, 255),
		outlineColor = Color3.fromRGB(255, 255, 255),
		outlineSize = 1,

		order = 1,                          -- number|false (position in the list. Lines without order
		                                    -- fill the free positions in creation order. false = reset)

		toggle = {                          -- optional: adds a pill toggle to the line
			value = false,                  -- true|false (current state), default: false
			side = "right",                 -- "left"|"right" (toggle position), default: "right"
			callback = function(value) end, -- function (called on click with the new value)
			enabledColor = Color3.fromRGB(70, 140, 255),  -- Color3 (alias: color), default: accent color
			disabledColor = Color3.fromRGB(40, 45, 62),   -- Color3, default: dark gray
			outlineColor = Color3.fromRGB(88, 95, 120),   -- Color3 (track outline, both states)
			image = "rbxassetid://0",       -- string (image for the knob), default: none
		},
	},
}
```

Minimal line with a toggle:

```lua
{id = "example toggle", text = {text = "example text"}, toggle = {value = false, callback = function(value) print(value) end}}
```

## How to change info gui

### Lines

```lua
InfoGui:SetLine({id = "example", text = {text = "new text"}})           -- creates the line or updates only the given fields
InfoGui:SetLine({
	{id = "example 1", text = {text = "example text 1"}},
	{id = "example 2", text = {text = "example text 2"}},
})                                                                       -- several lines at once
InfoGui:SetLine({color = Color3.fromRGB(255, 255, 255)})                 -- no id: applies the fields to ALL existing lines
InfoGui:SetLine({id = "example toggle", toggle = {value = true}})        -- changes toggle state from code (callback is NOT called)
```

```lua
:SetLine(lines)        -- create / update one line, a list of lines, or all lines (see above)
:RemoveLine("example") -- remove a line by id
:Clear()               -- remove all lines
:GetLines()            -- returns a sorted table with all line ids
```

### Window parameters

```lua
:SetParameter({Title = "example"})          -- change title text
:SetParameter({Size = {x = 250, y = 400}})  -- change size (UDim2 or {x, y})
:SetParameter({Scale = 1.2})                -- change scale (animated)
:SetParameter({Position = UDim2.new(0.5, 0, 0.5, 0)}) -- change position (UDim2 or {x, y})
:SetParameter({TextSize = 16})              -- change text size
:SetParameter({Collapsed = true})           -- collapse|expand (true|false)
:SetParameter({TweenTime = 0.3})            -- change resize animation time
```

Several parameters can be changed in one call: `:SetParameter({Title = "example", Scale = 1.1})`.

### Auto size

```lua
:SetAutoSize({enabled = true|false})
:SetAutoSize({side = "down"|"up"|"left"|"right"})
:SetAutoSize({WindowEdge = true|false})
:SetAutoSize({WindowEdgeWithSize = true|false})
```

### Other functions

```lua
:Visible(true|false)       -- show / hide the window (animated)
:Collapse(true|false)      -- collapse / expand the window
:Toggle()                  -- switch between collapsed and expanded
:IsCollapsed()             -- returns true|false
:SetCustomWindow({...})    -- change style on the fly (smooth color transitions), see CustomWindow section
:ApplyPreset(Guis.Presets.Red) -- same as :SetCustomWindow
:Remove()                  -- destroy the window
```

---

# Info Text Gui

Billboard text attached to a part / model / attachment. Great for ESP.

## How to create info text gui

Short example:

```lua
local InfoText = Guis.createInfoText({
	Name = "InfoText",
	Center = workspace.ExamplePart,
	Offset = Vector3.new(0, 3, 0),
	TextSize = 20,
	ShowWindow = false,
	Width = {auto = true, size = 300},
	ConstantSize = {enabled = false},
	Lines = {
		{id = "example", text = {text = "example text"}},
	}
})
```

### Parameters

```
Name         = string                       (billboard name), default: "GhostRoomESP"
Center       = Model|BasePart|Attachment    (object the text is attached to).
                                            If it is nil the lines are kept and shown as soon as you set it
                                            with :SetParameter({Center = ...})
Offset       = Vector3                      (studs offset from Center), default: Vector3.new(0, 3, 0)
TextSize     = number                       (text size), default: 20
OutlineColor = Color3                       (default outline color of all lines), default: white
OutlineSize  = number                       (default outline thickness of all lines), default: none
ZIndex       = number                       (render order), default: 1
TweenTime    = number                       (seconds, resize animation), default: 0.22
ShowWindow   = true|false                   (draw the background window behind the text), default: false

Width = {
	auto = true|false                       (true: width fits the text, false: fixed width + text wrapping), default: true
	size = number                           (fixed width in pixels, used when auto = false), default: 300
}

ConstantSize = true|false  or  {            (text scales with distance, so it stays readable far away)
	enabled  = true|false                   default: false
	MinScale = number                       (scale at max distance), default: 0.1
	MaxScale = number                       (scale when close), default: 1.5
	studs    = number                       (shrink speed: MinScale is reached at studs * 20 distance;
	                                         bigger value = slower shrinking), default: 5
}

Lines        = { line, line, ... }          (see below)
CustomWindow = { ... }                      (see "CustomWindow styling and presets")
```

### Line parameters

```lua
Lines = {
	{
		id = "example 1",                   -- string (unique id, used to change/remove this line)

		text = {                            -- string or table
			text = "example text",          -- string (line text), default: ""
			color = Color3.fromRGB(255, 255, 255),  -- Color3 (text color), default: white
			font = Enum.Font.GothamMedium,  -- Enum.Font, default: Enum.Font.GothamMedium
			outlineColor = Color3.fromRGB(255, 255, 255), -- Color3, default: OutlineColor
			outlineSize = 1,                -- number|false, default: OutlineSize
		},

		-- shortcuts, same as the same keys inside text = {...}
		color = Color3.fromRGB(255, 255, 255),
		outlineColor = Color3.fromRGB(255, 255, 255),
		outlineSize = 1,

		order = 1,                          -- number|false (position in the list, false = reset)
	},
}
```

## How to change info text gui

### Lines

```lua
:SetLine({id = "example", text = {text = "new text"}})   -- create / update one line
:SetLine({ {id = "example 1", text = "example text 1"}, {id = "example 2", text = "example text 2"} }) -- several lines
:SetLine({color = Color3.fromRGB(255, 255, 255)})        -- no id: applies the fields to ALL existing lines
:RemoveLine("example")                                   -- remove a line by id
:Clear()                                                 -- remove all lines
```

### Parameters

```lua
:SetParameter({Center = workspace.ExamplePart})           -- attach to another object
:SetParameter({Offset = Vector3.new(0, 4, 0)})            -- change offset
:SetParameter({Width = {auto = false, size = 250}})       -- change width mode / fixed width
:SetParameter({TextSize = 18})                            -- change text size
:SetParameter({ShowWindow = true})                        -- show|hide the background window
:SetParameter({ZIndex = 2})                               -- change render order
:SetParameter({ConstantSize = {enabled = true, MinScale = 0.2, MaxScale = 1.5, studs = 5}}) -- or ConstantSize = true|false
:SetParameter({OutlineColor = Color3.fromRGB(0, 0, 0)})   -- change default outline color
:SetParameter({OutlineSize = 1})                          -- change default outline thickness
:SetParameter({TweenTime = 0.3})                          -- change resize animation time
```

### Other functions

```lua
:Visible(true|false)       -- show / hide the whole text
:ShowWindow(true|false)    -- show / hide the background window (animated)
:IsWindowShown()           -- returns true|false
:SetCustomWindow({...})    -- change style on the fly, see CustomWindow section
:ApplyPreset(Guis.Presets.Green) -- same as :SetCustomWindow
:Remove()                  -- destroy the billboard
```

---

# Radar

## How to create radar

Short example:

```lua
local Radar = Guis.createRadar({
	Name = "Radar",
	Title = "Radar",
	Position = UDim2.new(0.03, 0, 0.3, 0),
	Scale = 1,
	Size = 100,
	Range = 100,
	Center = game.Players.LocalPlayer,
	Targets = {
		{id = "example", target = workspace.ExamplePart, text = "example text"},
	}
})
```

### Parameters

```
Name         = string                       (window core name), default: "CustomRadar"
Title        = string                       (text in the title bar), default: "Radar"
Position     = UDim2.new(...)               (window position), default: UDim2.new(0.03, 0, 0.3, 0)
Scale        = number                       (UI scale), default: 1
Size         = number                       (distance in studs that equals the radar radius.
                                             Targets farther than this are pinned to the radar edge), default: 100
Range        = number                       (max distance in studs, targets farther than this are hidden), default: 100
Center       = Player|Model|BasePart|Vector3|CFrame
                                            (what the radar is centered on), default: LocalPlayer
CenterOffset = Vector3                      (offset added to the center position), default: Vector3.zero
TextHideThreshold = number 0-1              (hide target text when the target is closer to the edge than this),
                                            default: 0.95
Animated     = true|false                   (rotating sweep line, alias: Sweep), default: true
SweepSpeed   = number                       (sweep rotation speed, degrees per second), default: 110

Targets      = { target, target, ... }      (see below)
CustomWindow = { ... }                      (see "CustomWindow styling and presets")
```

### Target parameters

```lua
Targets = {
	{
		id = "example 1",                   -- string (unique id, used to change/remove the target)
		target = workspace.ExamplePart,     -- Player|Model|BasePart (the object to track)
		text = "example text",              -- string (label above the point), default: none
		color = Color3.fromRGB(255, 255, 255), -- Color3 (point and label color), default: white
		size = 8,                           -- number (point size in pixels), default: 8
		visible = true,                     -- true|false (show the point), default: true
	},
}
```

## How to change radar

### Targets

```lua
:Set({id = "example", target = workspace.ExamplePart, text = "new text", color = Color3.fromRGB(255, 0, 0)}) -- add or update one target
:Set({
	{id = "example 1", target = workspace.ExamplePart1},
	{id = "example 2", target = workspace.ExamplePart2},
})                                                                      -- several targets at once
:RemoveTarget("example")                                                -- remove a target by id
:Clear()                                                                -- remove all targets
```

> `:Set` replaces the whole target. Fields you do not pass go back to their defaults, so always pass `target` again (and `text` / `color` / `size` if you want to keep them).

### Parameters

```lua
:SetParameter({Title = "example"})                        -- change title text
:SetParameter({Position = UDim2.new(0.5, 0, 0.5, 0)})     -- change position (animated)
:SetParameter({Scale = 1.2})                              -- change scale (animated)
:SetParameter({Size = 150})                               -- change radar radius in studs
:SetParameter({Range = 200})                              -- change max visible distance
:SetParameter({Center = workspace.ExamplePart})           -- change radar center
:SetParameter({CenterOffset = Vector3.new(0, 0, 0)})      -- change center offset
:SetParameter({TextHideThreshold = 0.9})                  -- change text hide threshold
:SetParameter({Animated = true|false})                    -- turn the sweep line on|off
:SetParameter({SweepSpeed = 150})                         -- change sweep speed
```

### Other functions

```lua
:Visible(true|false)       -- show / hide the radar (animated)
:SetCustomWindow({...})    -- change style on the fly, see CustomWindow section
:ApplyPreset(Guis.Presets.Blue) -- same as :SetCustomWindow
:Remove()                  -- destroy the radar
```

---

# CustomWindow styling and presets

Every window accepts a `CustomWindow` table. It is optional, anything you skip uses the default value. You can pass it on creation or change it any time with `:SetCustomWindow({...})` (partial tables are fine, colors change smoothly).

```lua
local InfoGui = Guis.createInfoGui({
	Title = "Example",
	CustomWindow = {
		Background = {color = Color3.fromRGB(14, 17, 26), transparency = 0.08},
		Accent = {color = Color3.fromRGB(70, 140, 255)},
	}
})

InfoGui:SetCustomWindow({Accent = {color = Color3.fromRGB(255, 66, 84)}})
```

## CustomWindow keys

`Info Gui` (`I`), `Info Text Gui` (`T`), `Radar` (`R`) show where a key is used.

| Key | Fields | Default | Used in |
|---|---|---|---|
| `Background` | `color`, `transparency` | `(14,17,26)`, `0.08` (Info Text: `0.15`, Radar: `(12,14,22)`, `0.08`) | I T R |
| `Topbar` | `color`, `transparency` | `(22,26,38)`, `0.2` | I |
| `TopbarLine` | `color` (accent bar in the title) | accent color | I R |
| `Accent` | `color` (main accent: toggles, hovers, sweep) | `(70,140,255)` | I R |
| `Title` | `color` (Radar also: `transparency`) | `(245,247,255)` | I R |
| `Border` | `color`, `thickness`, `transparency` | `(70,85,125)`, `1` (Radar: `1.5`), `0.2` | I T R |
| `Corner` | `radius` | `10` (Info Text: `8`, Radar: `14`) | I T R |
| `Shadow` | `color`, `transparency`, `size` (glow width in pixels) | black, `0.55` (Info Text: `0.6`), `30` | I T R |
| `LineToggle` | `color`, `textColor` (collapse button) | `(40,46,66)`, `(215,220,235)` | I |
| `Scrollbar` | `color` | accent color | I |
| `LineText` | `color` (default line text color) | `(235,238,248)` | I |
| `Font` | `title`, `text` (`Enum.Font`) | `GothamSemibold`, `GothamMedium` | I T R |
| `ToggleImage` | `opened`, `collapsed` (asset ids for the collapse button arrow) | text arrows | I |
| `Padding` | `value` (space around the text in the window) | `8` | T |
| `ShowWindow` | `true|false` (draw the background window) | `false` | T |
| `Radar` | `color`, `transparency`, `sweep` (`true|false`) | `(6,8,14)`, `0.1`, `true` | R |
| `Grid` | `color` (radar rings) | `(70,80,105)` | R |
| `Crosshair` | `color` (radar cross lines) | `(60,68,90)` | R |
| `Depth` | `{strength = number}` or `number` or `false` (gradients, top shine and light edge, `false` / `0` = flat) | `{strength = 1}` | I T R |

Tip: for a glassy look keep `Background.transparency` around `0.2 - 0.4` and use the same color for `Accent` and `Shadow.color`.
