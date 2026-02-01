-- // [OPEN SOURCE] \\ --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

ReplicatedFirst:RemoveDefaultLoadingScreen()

local MINIMUM_LOAD_TIME = 5
local FADE_IN_DURATION = 1.0
local FADE_OUT_DURATION = 1.4
local TYPEWRITER_SPEED = 0.045
local TIP_INTERVAL = 3.5

local SPINNER_RADIUS = 32
local SPINNER_DOTS = 6
local SPINNER_DOT_SIZE = 6
local SPINNER_SPEED = 0.8

local PARTICLE_COUNT = 15
local PARTICLE_MIN_SIZE = 2
local PARTICLE_MAX_SIZE = 4
local PARTICLE_MIN_SPEED = 20
local PARTICLE_MAX_SPEED = 35

local Color = {
    Void        = Color3.fromRGB(3, 3, 5),
    Deep        = Color3.fromRGB(8, 8, 10),
    Soft        = Color3.fromRGB(15, 15, 18),
    DarkGray    = Color3.fromRGB(35, 35, 40),
    MidGray     = Color3.fromRGB(80, 80, 85),
    SoftGray    = Color3.fromRGB(120, 120, 125),
    LightGray   = Color3.fromRGB(180, 180, 185),
    OffWhite    = Color3.fromRGB(235, 235, 240),
    White       = Color3.fromRGB(255, 255, 255),
    Track       = Color3.fromRGB(25, 25, 28),
}

local Tips = {
    "NEVER tell anyone your secrets.",
    "If you tell people your secrets, they'll use it against you",
    "Let the past be the past, even if it's hard to see it go away.",
    "Never let anyone hold you down.",
    "Out of 15 million other sperms, you were the chosen one to be born. Remember that.",
}

local Easing = {
    Out     = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    InOut   = TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut),
    Soft    = TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Fade    = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
}


local gameName = "Loading"
local hiddenGuis = {}
local particlesActive = true
local spinnerActive = true
local displayedPercent = 0
local targetPercent = 0
local spinnerAngle = 0

local spinnerConnection
local percentConnection


local function fetchGameName()
    local success, info = pcall(function()
        return MarketplaceService:GetProductInfo(game.PlaceId)
    end)
    
    if success and info and info.Name then
        gameName = info.Name
    end
end

local function hideOtherUIs(excludeName)
    for _, gui in ipairs(playerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name ~= excludeName and gui.Enabled then
            hiddenGuis[gui] = true
            gui.Enabled = false
        end
    end
end

local function restoreHiddenUIs()
    for gui in pairs(hiddenGuis) do
        if gui and gui.Parent then
            gui.Enabled = true
        end
    end
    table.clear(hiddenGuis)
end

local function tween(instance, properties, tweenInfo)
    tweenInfo = tweenInfo or Easing.Out
    local t = TweenService:Create(instance, tweenInfo, properties)
    t:Play()
    return t
end

local function typewriter(label, text)
    label.Text = ""
    for i = 1, #text do
        if not label.Parent then return end
        label.Text = string.sub(text, 1, i)
        task.wait(TYPEWRITER_SPEED)
    end
end

local function gatherAssets()
    local assets = {}
    local sources = {
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        workspace
    }
    
    for _, source in ipairs(sources) do
        pcall(function()
            for _, descendant in ipairs(source:GetDescendants()) do
                local validType = descendant:IsA("Decal")
                    or descendant:IsA("Texture")
                    or descendant:IsA("Sound")
                    or descendant:IsA("Animation")
                    or descendant:IsA("MeshPart")
                    or descendant:IsA("ImageLabel")
                
                if validType then
                    table.insert(assets, descendant)
                end
            end
        end)
    end
    
    return assets
end


local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(1, 0)
    corner.Parent = parent
    return corner
end

local function createFrame(properties)
    local frame = Instance.new("Frame")
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = properties.Transparency or 0
    frame.BackgroundColor3 = properties.Color or Color.Void
    frame.Size = properties.Size or UDim2.new(1, 0, 1, 0)
    frame.Position = properties.Position or UDim2.new(0, 0, 0, 0)
    frame.AnchorPoint = properties.Anchor or Vector2.new(0, 0)
    frame.Name = properties.Name or "Frame"
    frame.Parent = properties.Parent
    return frame
end

local function createLabel(properties)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = properties.Text or ""
    label.TextColor3 = properties.Color or Color.White
    label.TextSize = properties.Size or 14
    label.Font = properties.Font or Enum.Font.Gotham
    label.TextXAlignment = properties.AlignX or Enum.TextXAlignment.Center
    label.TextTransparency = properties.Transparency or 0
    label.TextWrapped = properties.Wrapped or false
    label.Size = properties.FrameSize or UDim2.new(0.8, 0, 0, 30)
    label.Position = properties.Position or UDim2.new(0.5, 0, 0.5, 0)
    label.AnchorPoint = properties.Anchor or Vector2.new(0.5, 0.5)
    label.Name = properties.Name or "Label"
    label.Parent = properties.Parent
    return label
end

task.spawn(fetchGameName)


local screen = Instance.new("ScreenGui")
screen.Name = "secret"
screen.IgnoreGuiInset = true
screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screen.DisplayOrder = 9999
screen.Parent = playerGui

hideOtherUIs(screen.Name)

local background = createFrame({
    Name = "Background",
    Color = Color.Void,
    Transparency = 1,
    Parent = screen
})

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color.Soft),
    ColorSequenceKeypoint.new(0.5, Color.Void),
    ColorSequenceKeypoint.new(1, Color.Soft),
})
gradient.Rotation = 90
gradient.Parent = background

local particleLayer = createFrame({
    Name = "Particles",
    Transparency = 1,
    Parent = background
})
particleLayer.ClipsDescendants = true

local content = createFrame({
    Name = "Content",
    Transparency = 1,
    Parent = background
})

local spinnerContainer = createFrame({
    Name = "Spinner",
    Size = UDim2.new(0, SPINNER_RADIUS * 2 + 20, 0, SPINNER_RADIUS * 2 + 20),
    Position = UDim2.new(0.5, 0, 0.38, 0),
    Anchor = Vector2.new(0.5, 0.5),
    Transparency = 1,
    Parent = content
})

local orbitalRing = createFrame({
    Name = "Ring",
    Size = UDim2.new(0, SPINNER_RADIUS * 2, 0, SPINNER_RADIUS * 2),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Anchor = Vector2.new(0.5, 0.5),
    Transparency = 1,
    Parent = spinnerContainer
})

local ringStroke = Instance.new("UIStroke")
ringStroke.Color = Color.DarkGray
ringStroke.Thickness = 1
ringStroke.Transparency = 0.7
ringStroke.Parent = orbitalRing
createCorner(orbitalRing)

local spinnerDots = {}
for i = 1, SPINNER_DOTS do
    local dot = createFrame({
        Name = "Dot" .. i,
        Size = UDim2.new(0, SPINNER_DOT_SIZE, 0, SPINNER_DOT_SIZE),
        Color = Color.White,
        Anchor = Vector2.new(0.5, 0.5),
        Parent = spinnerContainer
    })
    createCorner(dot)
    
    table.insert(spinnerDots, {
        instance = dot,
        baseAngle = (i - 1) * (math.pi * 2 / SPINNER_DOTS)
    })
end

local centerDot = createFrame({
    Name = "Center",
    Size = UDim2.new(0, 8, 0, 8),
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Anchor = Vector2.new(0.5, 0.5),
    Color = Color.White,
    Parent = spinnerContainer
})
createCorner(centerDot)

local titleLabel = createLabel({
    Name = "Title",
    Text = "",
    Color = Color.White,
    Size = 38,
    Font = Enum.Font.GothamBlack,
    FrameSize = UDim2.new(0.8, 0, 0, 50),
    Position = UDim2.new(0.5, 0, 0.54, 0),
    Anchor = Vector2.new(0.5, 0),
    Parent = content
})

local statusLabel = createLabel({
    Name = "Status",
    Text = "[!] Loading script assets...",
    Color = Color.SoftGray,
    Size = 15,
    Transparency = 1,
    FrameSize = UDim2.new(0.8, 0, 0, 25),
    Position = UDim2.new(0.5, 0, 0.60, 0),
    Anchor = Vector2.new(0.5, 0),
    Parent = content
})

local progressTrack = createFrame({
    Name = "ProgressTrack",
    Size = UDim2.new(0.30, 0, 0, 3),
    Position = UDim2.new(0.5, 0, 0.70, 0),
    Anchor = Vector2.new(0.5, 0.5),
    Color = Color.Track,
    Parent = content
})
createCorner(progressTrack)

local progressFill = createFrame({
    Name = "ProgressFill",
    Size = UDim2.new(0, 0, 1, 0),
    Color = Color.White,
    Parent = progressTrack
})
createCorner(progressFill)

local percentLabel = createLabel({
    Name = "Percent",
    Text = "0%",
    Color = Color.MidGray,
    Size = 12,
    Font = Enum.Font.GothamMedium,
    Transparency = 1,
    FrameSize = UDim2.new(0.2, 0, 0, 20),
    Position = UDim2.new(0.5, 0, 0.74, 0),
    Anchor = Vector2.new(0.5, 0),
    Parent = content
})

local tipLabel = createLabel({
    Name = "Tip",
    Text = "",
    Color = Color.DarkGray,
    Size = 13,
    Transparency = 1,
    Wrapped = true,
    FrameSize = UDim2.new(0.5, 0, 0, 30),
    Position = UDim2.new(0.5, 0, 0.85, 0),
    Parent = content
})

local creditLine = createFrame({
    Name = "CreditLine",
    Size = UDim2.new(0, 60, 0, 1),
    Position = UDim2.new(1, -20, 1, -38),
    Anchor = Vector2.new(1, 0),
    Color = Color.DarkGray,
    Transparency = 1,
    Parent = content
})

local creditLabel = createLabel({
    Name = "Credit",
    Text = "Made by Vezekk",
    Color = Color.DarkGray,
    Size = 11,
    AlignX = Enum.TextXAlignment.Right,
    Transparency = 1,
    FrameSize = UDim2.new(0, 150, 0, 20),
    Position = UDim2.new(1, -20, 1, -15),
    Anchor = Vector2.new(1, 1),
    Parent = content
})

local function spawnParticle()
    if not particlesActive then return end
    
    local size = math.random(PARTICLE_MIN_SIZE, PARTICLE_MAX_SIZE)
    local opacity = math.random(5, 20) / 100
    
    local particle = createFrame({
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(math.random() * 0.8 + 0.1, 0, 1.05, 0),
        Color = Color.White,
        Transparency = 1 - opacity,
        Parent = particleLayer
    })
    createCorner(particle)
    
    local duration = math.random(PARTICLE_MIN_SPEED, PARTICLE_MAX_SPEED) / 8
    local drift = (math.random() - 0.5) * 0.15
    local targetX = particle.Position.X.Scale + drift
    
    local floatTween = tween(particle, {
        Position = UDim2.new(targetX, 0, -0.05, 0)
    }, TweenInfo.new(duration, Enum.EasingStyle.Linear))
    
    floatTween.Completed:Once(function()
        particle:Destroy()
    end)
end

local function updateSpinner(deltaTime)
    if not spinnerActive then return end
    
    spinnerAngle = spinnerAngle + (math.pi * 2 * SPINNER_SPEED * deltaTime)
    
    for _, dot in ipairs(spinnerDots) do
        local angle = spinnerAngle + dot.baseAngle
        local x = math.cos(angle) * SPINNER_RADIUS
        local y = math.sin(angle) * SPINNER_RADIUS
        
        dot.instance.Position = UDim2.new(0.5, x, 0.5, y)
        
        local fade = (math.sin(angle) + 1) / 2
        dot.instance.BackgroundTransparency = 0.1 + (1 - fade) * 0.6
        
        local scale = 0.8 + fade * 0.4
        dot.instance.Size = UDim2.new(0, SPINNER_DOT_SIZE * scale, 0, SPINNER_DOT_SIZE * scale)
    end
    
    local pulse = (math.sin(spinnerAngle * 1.5) + 1) / 2
    centerDot.BackgroundTransparency = 0.2 + pulse * 0.3
end

local function updatePercent(deltaTime)
    if displayedPercent < targetPercent then
        local step = (targetPercent - displayedPercent) * math.min(deltaTime * 8, 1)
        displayedPercent = displayedPercent + step
        
        if targetPercent - displayedPercent < 0.5 then
            displayedPercent = targetPercent
        end
        
        percentLabel.Text = math.floor(displayedPercent) .. "%"
    end
end

local function setProgress(percent, status)
    percent = math.clamp(percent, 0, 1)
    targetPercent = percent * 100
    
    tween(progressFill, { Size = UDim2.new(percent, 0, 1, 0) })
    
    if status then
        statusLabel.Text = status
    end
end

local function rotateTip()
    local index = math.random(1, #Tips)
    
    tween(tipLabel, { TextTransparency = 1 }, Easing.Fade)
    task.wait(0.4)
    
    tipLabel.Text = Tips[index]
    
    tween(tipLabel, { TextTransparency = 0.5 }, Easing.Fade)
end

local function fadeIn()
    tween(background, { BackgroundTransparency = 0 }, 
        TweenInfo.new(FADE_IN_DURATION, Enum.EasingStyle.Quint))
    
    task.wait(0.4)
    
    tween(statusLabel, { TextTransparency = 0 }, Easing.Soft)
    tween(percentLabel, { TextTransparency = 0 }, Easing.Soft)
    
    task.wait(0.2)
    
    tween(creditLabel, { TextTransparency = 0.6 }, TweenInfo.new(1.2))
    tween(creditLine, { BackgroundTransparency = 0.7 }, TweenInfo.new(1.2))
    
    task.wait(0.3)
    
    typewriter(titleLabel, gameName)
end

local function fadeOut()
    particlesActive = false
    spinnerActive = false
    
    statusLabel.Text = "[!] Thanks for using my script :)"
    setProgress(1)
    
    task.wait(0.6)
    
    local fadeInfo = TweenInfo.new(FADE_OUT_DURATION, Enum.EasingStyle.Quint)
    
    tween(background, { BackgroundTransparency = 1 }, fadeInfo)
    tween(ringStroke, { Transparency = 1 }, fadeInfo)
    
    for _, descendant in ipairs(screen:GetDescendants()) do
        if descendant:IsA("TextLabel") then
            tween(descendant, { TextTransparency = 1 }, fadeInfo)
        elseif descendant:IsA("Frame") then
            tween(descendant, { BackgroundTransparency = 1 }, fadeInfo)
        end
    end
    
    task.wait(FADE_OUT_DURATION)
    
    if spinnerConnection then
        spinnerConnection:Disconnect()
    end
    
    if percentConnection then
        percentConnection:Disconnect()
    end
    
    restoreHiddenUIs()
    screen:Destroy()
end

local function run()
    local startTime = tick()
    
    spinnerConnection = RunService.RenderStepped:Connect(updateSpinner)
    percentConnection = RunService.Heartbeat:Connect(updatePercent)
    --[[ remove the comment if you want particles or not, (NOT MINE, CREDS TO ???)
    task.spawn(function()
        while particlesActive and screen.Parent do
            spawnParticle()
            task.wait(0.25)
        end
    end)
    ]]
    
    task.spawn(function()
        while particlesActive and screen.Parent do
            rotateTip()
            task.wait(TIP_INTERVAL)
        end
    end)
    
    task.wait(0.1)
    fadeIn()
    
    setProgress(0.05, "Discovering")
    local assets = gatherAssets()
    
    if #assets > 0 then
        local loaded = 0
        local total = #assets
        
        setProgress(0.08, "Loading")
        
        ContentProvider:PreloadAsync(assets, function()
            loaded = loaded + 1
            setProgress(0.08 + (loaded / total) * 0.82)
        end)
    else
        for i = 1, 25 do
            setProgress(0.08 + (i / 25) * 0.82, "Preparing")
            task.wait(0.12)
        end
    end
    
    setProgress(0.92, "[!] Loaded!")
    
    local elapsed = tick() - startTime
    if elapsed < MINIMUM_LOAD_TIME then
        local remaining = MINIMUM_LOAD_TIME - elapsed
        local steps = math.ceil(remaining / 0.08)
        
        for i = 1, steps do
            setProgress(0.92 + (i / steps) * 0.08)
            task.wait(0.08)
        end
    end
    
    fadeOut()
end

run()
