local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

if _G.__SBX_AddonLoaded then
    return
end
_G.__SBX_AddonLoaded = true

local function safeCall(fn)
    local ok, result = pcall(fn)
    return ok, result
end

local function environmentReport()
    local env = getgenv and getgenv() or _G
    local report = {
        executor = env and (env.identifyexecutor and env.identifyexecutor()) or "Unknown",
        hasLogger = env and (env.logger or env.envLogger or env.__logger) and true or false,
        canClipboard = env and env.setclipboard and true or false
    }
    return report
end

local function notify(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SBX_Addon_" .. HttpService:GenerateGUID(false):gsub("%p", ""):sub(1, 8)
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.Size = UDim2.new(0, 250, 0, 36)
    frame.Position = UDim2.new(1, -270, 1, -110)
    frame.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local label = Instance.new("TextLabel")
    label.Parent = frame
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, -12, 1, 0)
    label.Position = UDim2.new(0, 6, 0, 0)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextColor3 = Color3.fromRGB(238, 244, 255)
    label.Text = text

    task.delay(3, function()
        if gui then
            gui:Destroy()
        end
    end)
end

local function protectionLayer()
    local okHttp = safeCall(function()
        return HttpService:GenerateGUID(false)
    end)
    if not okHttp then
        notify("HttpService unavailable")
        return false
    end

    local report = environmentReport()
    if report.hasLogger then
        notify("Notice: environment logger detected!")
    end

    notify("Protection layer placed!")
    return true
end

protectionLayer()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local theme = {
    bg = Color3.fromRGB(14, 16, 24),
    panel = Color3.fromRGB(22, 26, 38),
    panelAlt = Color3.fromRGB(30, 36, 54),
    soft = Color3.fromRGB(38, 44, 64),
    stroke = Color3.fromRGB(54, 64, 90),
    text = Color3.fromRGB(238, 244, 255),
    muted = Color3.fromRGB(162, 175, 200),
    accent = Color3.fromRGB(92, 210, 160),
    accentDark = Color3.fromRGB(68, 186, 138),
    blue = Color3.fromRGB(92, 150, 255),
    danger = Color3.fromRGB(230, 90, 110)
}

local function create(className, props)
    local inst = Instance.new(className)
    for key, value in pairs(props or {}) do
        inst[key] = value
    end
    return inst
end

local function tween(inst, duration, props)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(inst, info, props)
    t:Play()
    return t
end

local function setHover(button, normal, hover)
    local normalGetter = type(normal) == "function" and normal or function()
        return normal
    end
    local hoverGetter = type(hover) == "function" and hover or function()
        return hover
    end
    button.MouseEnter:Connect(function()
        tween(button, 0.15, { BackgroundColor3 = hoverGetter() })
    end)
    button.MouseLeave:Connect(function()
        tween(button, 0.2, { BackgroundColor3 = normalGetter() })
    end)
end

local function pulseClick(button, pressedColor)
    local original = button.BackgroundColor3
    tween(button, 0.08, { BackgroundColor3 = pressedColor or theme.panelAlt, Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, math.max(0, button.Size.Y.Offset - 2)) })
    task.delay(0.1, function()
        if button then
            tween(button, 0.12, { BackgroundColor3 = original, Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, button.Size.Y.Scale, button.Size.Y.Offset + 2) })
        end
    end)
end

local function playClickSound(parent)
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://139421450430380"
    sound.Volume = 0.3
    sound.PlayOnRemove = true
    sound.Parent = parent
    sound:Destroy()
end

local function attachClickFeedback(button, pressedColor)
    button.MouseButton1Click:Connect(function()
        playClickSound(button)
        pulseClick(button, pressedColor)
    end)
end

local function formatNumber(num)
    local str = tostring(num or 0)
    return str:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

local function formatDate(iso)
    if not iso or type(iso) ~= "string" then
        return "Unknown"
    end
    local y, m, d = iso:match("^(%d+)%-(%d+)%-(%d+)")
    if not y then
        return "Unknown"
    end
    return string.format("%s/%s/%s", m, d, y)
end

if _G.__ScriptSearcherLoaded then
    local dupGui = Instance.new("ScreenGui")
    dupGui.Name = "SBX_Duplicate"
    dupGui.ResetOnSpawn = false
    dupGui.IgnoreGuiInset = true
    dupGui.Parent = CoreGui

    local note = Instance.new("TextLabel")
    note.Parent = dupGui
    note.Size = UDim2.new(0, 240, 0, 36)
    note.Position = UDim2.new(1, -260, 1, -70)
    note.BackgroundColor3 = theme.panel
    note.Text = "Script Searcher already running"
    note.TextColor3 = theme.text
    note.Font = Enum.Font.GothamSemibold
    note.TextSize = 12
    note.BackgroundTransparency = 0.1
    note.BorderSizePixel = 0
    Instance.new("UICorner", note).CornerRadius = UDim.new(0, 8)

    task.delay(2.5, function()
        dupGui:Destroy()
    end)
    return
end

_G.__ScriptSearcherLoaded = true

local connections = {}
local function hook(signal, fn)
    local conn = signal:Connect(fn)
    table.insert(connections, conn)
    return conn
end

local guiName = "SBX_" .. HttpService:GenerateGUID(false):gsub("%p", ""):sub(1, 12)
local screenGui = create("ScreenGui", {
    Name = guiName,
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    Parent = CoreGui
})

local mainFrame = create("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 940, 0, 580),
    Position = UDim2.new(0.5, -470, 0.5, -290),
    BackgroundColor3 = theme.bg,
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true
})
create("UICorner", { Parent = mainFrame, CornerRadius = UDim.new(0, 18) })
create("UIStroke", { Parent = mainFrame, Color = theme.stroke, Thickness = 1, Transparency = 0.4 })

tween(mainFrame, 0.35, { BackgroundTransparency = 0 })

local header = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(1, 0, 0, 60),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0
})
create("UICorner", { Parent = header, CornerRadius = UDim.new(0, 18) })
create("UIStroke", { Parent = header, Color = theme.stroke, Thickness = 1, Transparency = 0.5 })

local title = create("TextLabel", {
    Parent = header,
    Text = "Script Searcher",
    Font = Enum.Font.GothamBold,
    TextSize = 20,
    TextColor3 = theme.text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 18),
    Size = UDim2.new(0.55, 0, 0, 24),
    TextXAlignment = Enum.TextXAlignment.Left
})

local headerRight = create("Frame", {
    Parent = header,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -240, 0, 18),
    Size = UDim2.new(0, 220, 0, 24)
})

create("UIListLayout", {
    Parent = headerRight,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center
})

local attribution = create("TextLabel", {
    Parent = headerRight,
    Text = "Powered by ScriptBlox.com",
    Font = Enum.Font.GothamMedium,
    TextSize = 11,
    TextColor3 = theme.accent,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Right
})

local dragHandle = create("TextButton", {
    Parent = header,
    Text = "",
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0)
})

local dragging = false
local dragStart
local startPos

hook(dragHandle.InputBegan, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

hook(dragHandle.InputEnded, function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

hook(UserInputService.InputChanged, function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local toggleButton = create("TextButton", {
    Parent = screenGui,
    Text = "Hide UI",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panel,
    Size = UDim2.new(0, 120, 0, 38),
    BorderSizePixel = 0
})
create("UICorner", { Parent = toggleButton, CornerRadius = UDim.new(0, 10) })
create("UIStroke", { Parent = toggleButton, Color = theme.stroke, Thickness = 1, Transparency = 0.5 })
setHover(toggleButton, theme.panel, theme.panelAlt)
attachClickFeedback(toggleButton, theme.panelAlt)

local togglePositions = {
    { label = "Bottom Left", position = UDim2.new(0, 20, 1, -70), anchor = Vector2.new(0, 1) },
    { label = "Bottom Right", position = UDim2.new(1, -20, 1, -70), anchor = Vector2.new(1, 1) },
    { label = "Top Left", position = UDim2.new(0, 20, 0, 20), anchor = Vector2.new(0, 0) },
    { label = "Top Right", position = UDim2.new(1, -20, 0, 20), anchor = Vector2.new(1, 0) }
}
local toggleIndex = 1

local function applyTogglePosition()
    local option = togglePositions[toggleIndex]
    toggleButton.AnchorPoint = option.anchor
    toggleButton.Position = option.position
end

applyTogglePosition()

local openSize = mainFrame.Size
local openPosition = mainFrame.Position
local isOpen = true

local function setOpen(state)
    if state then
        mainFrame.Visible = true
        mainFrame.Size = UDim2.new(openSize.X.Scale, openSize.X.Offset, 0, 0)
        mainFrame.Position = UDim2.new(openPosition.X.Scale, openPosition.X.Offset, openPosition.Y.Scale, openPosition.Y.Offset + 160)
        tween(mainFrame, 0.25, { Size = openSize, Position = openPosition, BackgroundTransparency = 0 })
        toggleButton.Text = "Hide UI"
    else
        local closeTween = tween(mainFrame, 0.2, { Size = UDim2.new(openSize.X.Scale, openSize.X.Offset, 0, 0), Position = UDim2.new(openPosition.X.Scale, openPosition.X.Offset, openPosition.Y.Scale, openPosition.Y.Offset + 160), BackgroundTransparency = 1 })
        closeTween.Completed:Wait()
        mainFrame.Visible = false
        toggleButton.Text = "Open UI"
    end
    isOpen = state
end

hook(toggleButton.MouseButton1Click, function()
    setOpen(not isOpen)
end)

local keybindOptions = {
    Enum.KeyCode.RightShift,
    Enum.KeyCode.LeftAlt,
    Enum.KeyCode.RightControl
}
local keybindIndex = 1
local currentKeybind = keybindOptions[keybindIndex]

hook(UserInputService.InputBegan, function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == currentKeybind then
        setOpen(not isOpen)
    end
end)

local searchBar = create("Frame", {
    Parent = mainFrame,
    Position = UDim2.new(0, 20, 0, 72),
    Size = UDim2.new(1, -40, 0, 48),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0
})
create("UICorner", { Parent = searchBar, CornerRadius = UDim.new(0, 12) })
create("UIStroke", { Parent = searchBar, Color = theme.stroke, Thickness = 1, Transparency = 0.6 })

local searchBox = create("TextBox", {
    Parent = searchBar,
    PlaceholderText = "Search scripts (admin, fps, farm...)",
    Text = "",
    ClearTextOnFocus = false,
    Font = Enum.Font.Gotham,
    TextSize = 14,
    TextColor3 = theme.text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, 0),
    Size = UDim2.new(1, -360, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

local searchActions = create("Frame", {
    Parent = searchBar,
    BackgroundTransparency = 1,
    Position = UDim2.new(1, -340, 0, 9),
    Size = UDim2.new(0, 330, 0, 30)
})

create("UIListLayout", {
    Parent = searchActions,
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Right,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8)
})

local searchButton = create("TextButton", {
    Parent = searchActions,
    Text = "Search",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(18, 20, 28),
    BackgroundColor3 = theme.accent,
    Size = UDim2.new(0, 70, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = searchButton, CornerRadius = UDim.new(0, 8) })

local trendingButton = create("TextButton", {
    Parent = searchActions,
    Text = "Trending",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(0, 78, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = trendingButton, CornerRadius = UDim.new(0, 8) })

local byGameButton = create("TextButton", {
    Parent = searchActions,
    Text = "By Game",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panelAlt,
    Size = UDim2.new(0, 74, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = byGameButton, CornerRadius = UDim.new(0, 8) })

local clearButton = create("TextButton", {
    Parent = searchActions,
    Text = "Clear",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panelAlt,
    Size = UDim2.new(0, 60, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = clearButton, CornerRadius = UDim.new(0, 8) })

setHover(searchButton, theme.accent, theme.accentDark)
setHover(trendingButton, function()
    return currentMode == "trending" and theme.blue or theme.soft
end, theme.panelAlt)
setHover(byGameButton, function()
    return filterState.placeId and theme.blue or theme.panelAlt
end, theme.soft)
setHover(clearButton, theme.panelAlt, theme.soft)
attachClickFeedback(searchButton, theme.accentDark)
attachClickFeedback(trendingButton, theme.panelAlt)
attachClickFeedback(byGameButton, theme.soft)
attachClickFeedback(clearButton, theme.panelAlt)

local filtersFrame = create("Frame", {
    Parent = mainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 0, 128),
    Size = UDim2.new(1, -40, 0, 96)
})

local filterOptions = {
    { key = "verified", label = "Verified" },
    { key = "universal", label = "Universal" },
    { key = "key", label = "Key System" },
    { key = "keyless", label = "Keyless" },
    { key = "patched", label = "Not Patched" }
}

local filterState = {
    verified = false,
    universal = false,
    key = false,
    keyless = false,
    patched = false,
    mode = "free",
    sortBy = "updatedAt",
    strict = true,
    placeId = nil
}

local filterGrid = create("UIGridLayout", {
    Parent = filtersFrame,
    FillDirection = Enum.FillDirection.Horizontal,
    CellSize = UDim2.new(0, 140, 0, 30),
    CellPadding = UDim2.new(0, 10, 0, 10),
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    SortOrder = Enum.SortOrder.LayoutOrder
})

local function makeToggle(parent, text, initial)
    local button = create("TextButton", {
        Parent = parent,
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = theme.text,
        BackgroundColor3 = initial and theme.blue or theme.soft,
        Size = UDim2.new(0, 140, 0, 30),
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    create("UICorner", { Parent = button, CornerRadius = UDim.new(0, 7) })
    return button
end

local toggleButtons = {}
for _, option in ipairs(filterOptions) do
    local btn = makeToggle(filtersFrame, option.label, filterState[option.key])
    toggleButtons[option.key] = btn
end

local modeDropdown = create("TextButton", {
    Parent = filtersFrame,
    Text = "Mode: free",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(0, 140, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = modeDropdown, CornerRadius = UDim.new(0, 7) })

local sortButton = create("TextButton", {
    Parent = filtersFrame,
    Text = "Sort: updated",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(0, 140, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = sortButton, CornerRadius = UDim.new(0, 7) })

local strictButton = create("TextButton", {
    Parent = filtersFrame,
    Text = "Strict: on",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.blue,
    Size = UDim2.new(0, 140, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = strictButton, CornerRadius = UDim.new(0, 7) })

local refreshButton = create("TextButton", {
    Parent = filtersFrame,
    Text = "Refresh",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panelAlt,
    Size = UDim2.new(0, 140, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = refreshButton, CornerRadius = UDim.new(0, 7) })

setHover(modeDropdown, function()
    return filterState.mode == "free" and theme.soft or theme.blue
end, theme.panelAlt)
setHover(sortButton, function()
    return theme.soft
end, theme.panelAlt)
setHover(strictButton, function()
    return filterState.strict and theme.blue or theme.soft
end, theme.accentDark)
setHover(refreshButton, theme.panelAlt, theme.soft)
attachClickFeedback(modeDropdown, theme.panelAlt)
attachClickFeedback(sortButton, theme.panelAlt)
attachClickFeedback(strictButton, theme.accentDark)
attachClickFeedback(refreshButton, theme.soft)

local listFrame = create("ScrollingFrame", {
    Parent = mainFrame,
    Size = UDim2.new(1, -320, 1, -268),
    Position = UDim2.new(0, 20, 0, 240),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 6,
    ScrollBarImageColor3 = theme.soft,
    BackgroundTransparency = 1
})

local listLayout = create("UIListLayout", {
    Parent = listFrame,
    Padding = UDim.new(0, 12),
    SortOrder = Enum.SortOrder.LayoutOrder
})

local detailPanel = create("Frame", {
    Parent = mainFrame,
    Size = UDim2.new(0, 260, 1, -268),
    Position = UDim2.new(1, -280, 0, 240),
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0
})
create("UICorner", { Parent = detailPanel, CornerRadius = UDim.new(0, 14) })
create("UIStroke", { Parent = detailPanel, Color = theme.stroke, Thickness = 1, Transparency = 0.3 })

local detailTitle = create("TextLabel", {
    Parent = detailPanel,
    Text = "Select a script",
    Font = Enum.Font.GothamBold,
    TextSize = 16,
    TextColor3 = theme.text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 16),
    Size = UDim2.new(1, -24, 0, 24),
    TextXAlignment = Enum.TextXAlignment.Left
})

local detailGame = create("TextLabel", {
    Parent = detailPanel,
    Text = "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.muted,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 40),
    Size = UDim2.new(1, -24, 0, 18),
    TextXAlignment = Enum.TextXAlignment.Left
})

local detailStats = create("TextLabel", {
    Parent = detailPanel,
    Text = "",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.muted,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 0, 58),
    Size = UDim2.new(1, -24, 0, 18),
    TextXAlignment = Enum.TextXAlignment.Left
})

local settingsHeight = 132

local detailBox = create("TextBox", {
    Parent = detailPanel,
    Text = "Pick a script to preview its code here.",
    Font = Enum.Font.Code,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panelAlt,
    Position = UDim2.new(0, 12, 0, 84),
    Size = UDim2.new(1, -24, 1, -(settingsHeight + 210)),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    ClearTextOnFocus = false,
    MultiLine = true
})
create("UICorner", { Parent = detailBox, CornerRadius = UDim.new(0, 10) })

local detailButtons = create("Frame", {
    Parent = detailPanel,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 12, 1, -(settingsHeight + 104)),
    Size = UDim2.new(1, -24, 0, 92)
})

create("UIListLayout", {
    Parent = detailButtons,
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 6)
})

local detailCopy = create("TextButton", {
    Parent = detailButtons,
    Text = "Copy Script",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = Color3.fromRGB(18, 20, 28),
    BackgroundColor3 = theme.accent,
    Size = UDim2.new(1, 0, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = detailCopy, CornerRadius = UDim.new(0, 8) })

local detailRaw = create("TextButton", {
    Parent = detailButtons,
    Text = "Copy Raw Script",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(1, 0, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = detailRaw, CornerRadius = UDim.new(0, 8) })

local detailExecute = create("TextButton", {
    Parent = detailButtons,
    Text = "Execute",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.panelAlt,
    Size = UDim2.new(1, 0, 0, 30),
    BorderSizePixel = 0
})
create("UICorner", { Parent = detailExecute, CornerRadius = UDim.new(0, 8) })

setHover(detailCopy, theme.accent, theme.accentDark)
setHover(detailRaw, theme.soft, theme.panelAlt)
setHover(detailExecute, theme.panelAlt, theme.soft)
attachClickFeedback(detailCopy, theme.accentDark)
attachClickFeedback(detailRaw, theme.panelAlt)
attachClickFeedback(detailExecute, theme.soft)

local settingsPanel = create("Frame", {
    Parent = detailPanel,
    BackgroundColor3 = theme.panelAlt,
    Position = UDim2.new(0, 12, 1, -(settingsHeight + 8)),
    Size = UDim2.new(1, -24, 0, settingsHeight),
    BorderSizePixel = 0
})
create("UICorner", { Parent = settingsPanel, CornerRadius = UDim.new(0, 10) })
create("UIStroke", { Parent = settingsPanel, Color = theme.stroke, Thickness = 1, Transparency = 0.5 })

local settingsTitle = create("TextLabel", {
    Parent = settingsPanel,
    Text = "Script Settings",
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    TextColor3 = theme.text,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 8),
    Size = UDim2.new(1, -20, 0, 18),
    TextXAlignment = Enum.TextXAlignment.Left
})

local settingsButtons = create("Frame", {
    Parent = settingsPanel,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 10, 0, 32),
    Size = UDim2.new(1, -20, 1, -40)
})

create("UIListLayout", {
    Parent = settingsButtons,
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    VerticalAlignment = Enum.VerticalAlignment.Top,
    Padding = UDim.new(0, 6)
})

local togglePositionButton = create("TextButton", {
    Parent = settingsButtons,
    Text = "Hide Button: Bottom Left",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(1, 0, 0, 28),
    BorderSizePixel = 0
})
create("UICorner", { Parent = togglePositionButton, CornerRadius = UDim.new(0, 8) })

local keybindButton = create("TextButton", {
    Parent = settingsButtons,
    Text = "Keybind: RightShift",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(1, 0, 0, 28),
    BorderSizePixel = 0
})
create("UICorner", { Parent = keybindButton, CornerRadius = UDim.new(0, 8) })

local deleteButton = create("TextButton", {
    Parent = settingsButtons,
    Text = "Delete UI",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.danger,
    Size = UDim2.new(1, 0, 0, 28),
    BorderSizePixel = 0
})
create("UICorner", { Parent = deleteButton, CornerRadius = UDim.new(0, 8) })

setHover(togglePositionButton, theme.soft, theme.panelAlt)
setHover(keybindButton, theme.soft, theme.panelAlt)
setHover(deleteButton, theme.danger, Color3.fromRGB(250, 110, 130))
attachClickFeedback(togglePositionButton, theme.panelAlt)
attachClickFeedback(keybindButton, theme.panelAlt)
attachClickFeedback(deleteButton, Color3.fromRGB(250, 110, 130))

local footer = create("Frame", {
    Parent = mainFrame,
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 20, 1, -36),
    Size = UDim2.new(1, -40, 0, 26)
})

local pageLabel = create("TextLabel", {
    Parent = footer,
    Text = "Page 1",
    Font = Enum.Font.Gotham,
    TextSize = 13,
    TextColor3 = theme.muted,
    BackgroundTransparency = 1,
    Size = UDim2.new(0, 200, 1, 0),
    TextXAlignment = Enum.TextXAlignment.Left
})

local statusLabel = create("TextLabel", {
    Parent = footer,
    Text = "Ready",
    Font = Enum.Font.Gotham,
    TextSize = 12,
    TextColor3 = theme.muted,
    BackgroundTransparency = 1,
    Size = UDim2.new(0.5, 0, 1, 0),
    Position = UDim2.new(0.5, -60, 0, 0),
    TextXAlignment = Enum.TextXAlignment.Center
})

local prevButton = create("TextButton", {
    Parent = footer,
    Text = "Prev",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundColor3 = theme.soft,
    Size = UDim2.new(0, 70, 1, 0),
    Position = UDim2.new(1, -160, 0, 0),
    BorderSizePixel = 0
})
create("UICorner", { Parent = prevButton, CornerRadius = UDim.new(0, 6) })

local nextButton = create("TextButton", {
    Parent = footer,
    Text = "Next",
    Font = Enum.Font.GothamBold,
    TextSize = 12,
    TextColor3 = Color3.fromRGB(18, 20, 28),
    BackgroundColor3 = theme.accent,
    Size = UDim2.new(0, 70, 1, 0),
    Position = UDim2.new(1, -80, 0, 0),
    BorderSizePixel = 0
})
create("UICorner", { Parent = nextButton, CornerRadius = UDim.new(0, 6) })

setHover(prevButton, theme.soft, theme.panelAlt)
setHover(nextButton, theme.accent, theme.accentDark)
attachClickFeedback(prevButton, theme.panelAlt)
attachClickFeedback(nextButton, theme.accentDark)

local loader = create("Frame", {
    Parent = mainFrame,
    BackgroundColor3 = Color3.fromRGB(10, 12, 18),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    ZIndex = 20,
    Visible = false
})
create("UICorner", { Parent = loader, CornerRadius = UDim.new(0, 18) })

local loaderSpinner = create("ImageLabel", {
    Parent = loader,
    Image = "rbxassetid://6031091002",
    BackgroundTransparency = 1,
    ImageColor3 = theme.accent,
    Size = UDim2.new(0, 50, 0, 50),
    Position = UDim2.new(0.5, -25, 0.5, -40),
    ZIndex = 21
})

local loaderText = create("TextLabel", {
    Parent = loader,
    Text = "Loading scripts...",
    Font = Enum.Font.GothamMedium,
    TextSize = 13,
    TextColor3 = theme.muted,
    BackgroundTransparency = 1,
    Position = UDim2.new(0.5, -100, 0.5, 18),
    Size = UDim2.new(0, 200, 0, 20),
    ZIndex = 21
})

local loaderSpin = hook(RunService.RenderStepped, function(dt)
    if loader.Visible then
        loaderSpinner.Rotation = (loaderSpinner.Rotation + dt * 220) % 360
    end
end)

local function showLoader(state)
    if state then
        loader.Visible = true
        loader.BackgroundTransparency = 0.35
    else
        loader.Visible = false
        loader.BackgroundTransparency = 1
    end
end

local function clearList()
    for _, child in ipairs(listFrame:GetChildren()) do
        if child:IsA("Frame") then
            child:Destroy()
        end
    end
end

local function updateCanvas()
    task.wait()
    listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
end

local selectedStroke
local currentSlug

local function rawUrl(data)
    if data and data.slug then
        return "https://scriptblox.com/api/script/raw/" .. HttpService:UrlEncode(data.slug)
    end
    return ""
end

local function updateDetail(data)
    currentSlug = data and data.slug or nil
    detailTitle.Text = data and data.title or "Select a script"
    detailGame.Text = data and ("Game: " .. ((data.game and data.game.name) or "Unknown")) or ""
    local posted = data and formatDate(data.createdAt) or "Unknown"
    detailStats.Text = data and string.format("Views: %s  •  %s  •  Posted: %s", formatNumber(data.views), data.verified and "Verified" or "Community", posted) or ""
    detailBox.Text = data and (data.script or "Loading script...") or "Pick a script to preview its code here."
end

local function loadRawScript(data)
    if data.script or not data.slug then
        updateDetail(data)
        return
    end
    detailBox.Text = "Loading script..."
    local ok, resp = pcall(function()
        return game:HttpGet(rawUrl(data))
    end)
    if ok then
        local decoded = HttpService:JSONDecode(resp)
        if decoded and decoded.script then
            if type(decoded.script) == "table" and decoded.script.script then
                data.script = decoded.script.script
            elseif type(decoded.script) == "string" then
                data.script = decoded.script
            end
        end
    end
    updateDetail(data)
end

local function makeCard(scriptData)
    local card = create("Frame", {
        Parent = listFrame,
        BackgroundColor3 = theme.panel,
        Size = UDim2.new(1, 0, 0, 0),
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    create("UICorner", { Parent = card, CornerRadius = UDim.new(0, 12) })
    local stroke = create("UIStroke", { Parent = card, Color = theme.stroke, Thickness = 1, Transparency = 0.5 })
    card.BackgroundTransparency = 1
    tween(card, 0.2, { BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 118) })

    local titleLabel = create("TextLabel", {
        Parent = card,
        Text = scriptData.title or "Untitled",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = theme.text,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 12),
        Size = UDim2.new(1, -200, 0, 22),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local gameLabel = create("TextLabel", {
        Parent = card,
        Text = "Game: " .. ((scriptData.game and scriptData.game.name) or "Unknown"),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.muted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 38),
        Size = UDim2.new(1, -200, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local infoLabel = create("TextLabel", {
        Parent = card,
        Text = string.format("Views: %s • %s • Posted: %s", formatNumber(scriptData.views), scriptData.verified and "Verified" or "Community", formatDate(scriptData.createdAt)),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.muted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 58),
        Size = UDim2.new(1, -200, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local statusText = create("TextLabel", {
        Parent = card,
        Text = string.format("Type: %s • Key: %s • Patched: %s", scriptData.scriptType or "N/A", scriptData.key and "Yes" or "No", scriptData.isPatched and "Yes" or "No"),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = theme.muted,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, 78),
        Size = UDim2.new(1, -200, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local buttonStack = create("Frame", {
        Parent = card,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -150, 0, 18),
        Size = UDim2.new(0, 130, 0, 80)
    })

    local viewButton = create("TextButton", {
        Parent = buttonStack,
        Text = "Copy",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(18, 20, 28),
        BackgroundColor3 = theme.accent,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0
    })
    create("UICorner", { Parent = viewButton, CornerRadius = UDim.new(0, 8) })

    local executeButton = create("TextButton", {
        Parent = buttonStack,
        Text = "Execute",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = theme.text,
        BackgroundColor3 = theme.soft,
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 40),
        BorderSizePixel = 0
    })
    create("UICorner", { Parent = executeButton, CornerRadius = UDim.new(0, 8) })

    setHover(viewButton, theme.accent, theme.accentDark)
    setHover(executeButton, theme.soft, theme.panelAlt)

    hook(viewButton.MouseButton1Click, function()
        if setclipboard then
            setclipboard(scriptData.script or detailBox.Text or "")
        end
    end)

    hook(executeButton.MouseButton1Click, function()
        local source = scriptData.script or detailBox.Text
        if loadstring and source and source ~= "" then
            local fn = loadstring(source)
            if fn then
                fn()
            end
        end
    end)

    local selectButton = create("TextButton", {
        Parent = card,
        BackgroundTransparency = 1,
        Text = "",
        Size = UDim2.new(1, -160, 1, 0),
        Position = UDim2.new(0, 0, 0, 0)
    })

    hook(selectButton.MouseEnter, function()
        tween(card, 0.15, { BackgroundColor3 = theme.panelAlt })
    end)
    hook(selectButton.MouseLeave, function()
        tween(card, 0.2, { BackgroundColor3 = theme.panel })
    end)

    hook(selectButton.MouseButton1Click, function()
        playClickSound(card)
        pulseClick(card, theme.panelAlt)
        if selectedStroke then
            selectedStroke.Color = theme.stroke
            selectedStroke.Transparency = 0.5
        end
        selectedStroke = stroke
        stroke.Color = theme.accent
        stroke.Transparency = 0
        updateDetail(scriptData)
        loadRawScript(scriptData)
    end)

    updateCanvas()
end

local currentPage = 1
local lastQuery = ""
local totalPages = 1
local currentMode = "fetch"

local function buildQuery(baseUrl)
    local params = {}
    if filterState.verified then table.insert(params, "verified=1") end
    if filterState.universal then table.insert(params, "universal=1") end
    if filterState.key then table.insert(params, "key=1") end
    if filterState.keyless then table.insert(params, "key=0") end
    if filterState.patched then table.insert(params, "patched=0") end
    if filterState.mode then table.insert(params, "mode=" .. filterState.mode) end
    if filterState.sortBy then table.insert(params, "sortBy=" .. filterState.sortBy) end
    if filterState.strict ~= nil then table.insert(params, "strict=" .. tostring(filterState.strict)) end
    if filterState.placeId then table.insert(params, "placeId=" .. tostring(filterState.placeId)) end
    table.insert(params, "page=" .. tostring(currentPage))
    table.insert(params, "max=20")

    if #params > 0 then
        return baseUrl .. "?" .. table.concat(params, "&")
    end
    return baseUrl
end

local function fetchScripts()
    clearList()
    listFrame.CanvasPosition = Vector2.new(0, 0)
    statusLabel.Text = "Loading..."
    pageLabel.Text = "Page " .. currentPage
    showLoader(true)

    local url
    if currentMode == "trending" then
        url = "https://scriptblox.com/api/script/trending"
    elseif currentMode == "search" and lastQuery ~= "" then
        url = buildQuery("https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(lastQuery))
    else
        url = buildQuery("https://scriptblox.com/api/script/fetch")
    end

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        showLoader(false)
        statusLabel.Text = "Request failed"
        return
    end

    local data = HttpService:JSONDecode(response)
    local result = data.result or {}
    local scripts = result.scripts or {}
    totalPages = result.totalPages or 1

    if #scripts == 0 then
        showLoader(false)
        statusLabel.Text = "No results"
        return
    end

    for _, scriptData in ipairs(scripts) do
        makeCard(scriptData)
    end

    pageLabel.Text = string.format("Page %d of %d", currentPage, totalPages)
    statusLabel.Text = string.format("Loaded %d scripts", #scripts)
    showLoader(false)
end

local function refreshLayout()
    local viewport = workspace.CurrentCamera.ViewportSize
    local isMobile = viewport.X < 820
    local width = math.clamp(viewport.X * 0.94, 520, 1020)
    local height = math.clamp(viewport.Y * 0.92, 520, 760)
    mainFrame.Size = UDim2.new(0, width, 0, height)
    if not dragging then
        mainFrame.Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2)
    end

    local contentTop = isMobile and 270 or 240
    local contentBottom = 50
    local sideWidth = isMobile and math.clamp(width * 0.42, 200, 260) or math.clamp(width * 0.3, 240, 300)

    listFrame.Size = UDim2.new(1, -(sideWidth + 40), 1, -(contentTop + contentBottom))
    listFrame.Position = UDim2.new(0, 20, 0, contentTop)

    detailPanel.Size = UDim2.new(0, sideWidth, 1, -(contentTop + contentBottom))
    detailPanel.Position = UDim2.new(1, -sideWidth - 20, 0, contentTop)

    footer.Position = UDim2.new(0, 20, 1, -36)

    local actionWidth = isMobile and 260 or 330
    searchActions.Position = UDim2.new(1, -actionWidth - 10, 0, 9)
    searchActions.Size = UDim2.new(0, actionWidth, 0, 30)
    searchBox.Size = UDim2.new(1, -(actionWidth + 30), 1, 0)

    local columns = isMobile and 2 or 4
    local cellWidth = math.floor((width - 80 - (columns - 1) * 10) / columns)
    filterGrid.CellSize = UDim2.new(0, math.max(cellWidth, 120), 0, 30)

    openSize = mainFrame.Size
    openPosition = mainFrame.Position
end

hook(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), refreshLayout)

hook(searchButton.MouseButton1Click, function()
    lastQuery = searchBox.Text or ""
    currentPage = 1
    currentMode = "search"
    filterState.placeId = nil
    fetchScripts()
end)

hook(searchBox.FocusLost, function(enterPressed)
    if enterPressed then
        lastQuery = searchBox.Text or ""
        currentPage = 1
        currentMode = "search"
        filterState.placeId = nil
        fetchScripts()
    end
end)

hook(trendingButton.MouseButton1Click, function()
    lastQuery = ""
    currentPage = 1
    currentMode = "trending"
    filterState.placeId = nil
    fetchScripts()
end)

hook(byGameButton.MouseButton1Click, function()
    lastQuery = ""
    currentPage = 1
    currentMode = "fetch"
    filterState.placeId = game.PlaceId
    fetchScripts()
end)

hook(clearButton.MouseButton1Click, function()
    searchBox.Text = ""
    lastQuery = ""
    currentPage = 1
    currentMode = "fetch"
    filterState.placeId = nil
    fetchScripts()
end)

hook(refreshButton.MouseButton1Click, function()
    fetchScripts()
end)

hook(prevButton.MouseButton1Click, function()
    if currentPage > 1 then
        currentPage -= 1
        fetchScripts()
    end
end)

hook(nextButton.MouseButton1Click, function()
    if currentPage < totalPages then
        currentPage += 1
        fetchScripts()
    end
end)

local sortOptions = {
    { key = "updatedAt", label = "updated" },
    { key = "createdAt", label = "created" },
    { key = "views", label = "views" },
    { key = "likeCount", label = "likes" }
}
local sortIndex = 1

for key, button in pairs(toggleButtons) do
    hook(button.MouseButton1Click, function()
        if key == "key" and filterState.keyless then
            filterState.keyless = false
            toggleButtons.keyless.BackgroundColor3 = theme.soft
        elseif key == "keyless" and filterState.key then
            filterState.key = false
            toggleButtons.key.BackgroundColor3 = theme.soft
        end
        filterState[key] = not filterState[key]
        button.BackgroundColor3 = filterState[key] and theme.blue or theme.soft
        currentPage = 1
        fetchScripts()
    end)
end

hook(modeDropdown.MouseButton1Click, function()
    filterState.mode = filterState.mode == "free" and "paid" or "free"
    modeDropdown.Text = "Mode: " .. filterState.mode
    currentPage = 1
    fetchScripts()
end)

hook(sortButton.MouseButton1Click, function()
    sortIndex = sortIndex % #sortOptions + 1
    filterState.sortBy = sortOptions[sortIndex].key
    sortButton.Text = "Sort: " .. sortOptions[sortIndex].label
    currentPage = 1
    fetchScripts()
end)

hook(strictButton.MouseButton1Click, function()
    filterState.strict = not filterState.strict
    strictButton.Text = filterState.strict and "Strict: on" or "Strict: off"
    strictButton.BackgroundColor3 = filterState.strict and theme.blue or theme.soft
    currentPage = 1
    fetchScripts()
end)

hook(detailCopy.MouseButton1Click, function()
    if setclipboard then
        setclipboard(detailBox.Text or "")
    end
end)

hook(detailRaw.MouseButton1Click, function()
    if setclipboard then
        setclipboard(rawUrl({ slug = currentSlug }))
    end
end)

hook(detailExecute.MouseButton1Click, function()
    if loadstring and detailBox.Text and detailBox.Text ~= "" then
        local fn = loadstring(detailBox.Text)
        if fn then
            fn()
        end
    end
end)

hook(togglePositionButton.MouseButton1Click, function()
    toggleIndex = toggleIndex % #togglePositions + 1
    local option = togglePositions[toggleIndex]
    togglePositionButton.Text = "Hide Button: " .. option.label
    applyTogglePosition()
end)

hook(keybindButton.MouseButton1Click, function()
    keybindIndex = keybindIndex % #keybindOptions + 1
    currentKeybind = keybindOptions[keybindIndex]
    keybindButton.Text = "Keybind: " .. currentKeybind.Name
end)

hook(deleteButton.MouseButton1Click, function()
    _G.__ScriptSearcherLoaded = nil
    for _, conn in ipairs(connections) do
        pcall(function()
            conn:Disconnect()
        end)
    end
    screenGui:Destroy()
end)

local notify = create("Frame", {
    Parent = screenGui,
    BackgroundColor3 = theme.panel,
    BorderSizePixel = 0,
    Size = UDim2.new(0, 180, 0, 34),
    Position = UDim2.new(1, -200, 1, -60),
    BackgroundTransparency = 1
})
create("UICorner", { Parent = notify, CornerRadius = UDim.new(0, 8) })
create("UIStroke", { Parent = notify, Color = theme.stroke, Thickness = 1, Transparency = 0.6 })

local notifyText = create("TextLabel", {
    Parent = notify,
    Text = "Made by vezekk",
    Font = Enum.Font.GothamMedium,
    TextSize = 12,
    TextColor3 = theme.text,
    BackgroundTransparency = 1,
    Size = UDim2.new(1, -10, 1, 0),
    Position = UDim2.new(0, 5, 0, 0)
})

tween(notify, 0.25, { BackgroundTransparency = 0.1 })

task.delay(4, function()
    tween(notify, 0.25, { BackgroundTransparency = 1 })
    task.delay(0.4, function()
        if notify then
            notify:Destroy()
        end
    end)
end)

refreshLayout()
fetchScripts()
