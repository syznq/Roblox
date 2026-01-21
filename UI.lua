-- aight lil skid since you wanted the UI source so badly, here you go but remember the license, im watching you
local lib = {
    RainbowColorValue = 0,
    HueSelectionPosition = 0,
    toggledui = false
}

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local ContentProvider = game:GetService("ContentProvider")

local PresetColor = Color3.fromRGB(44, 120, 224)
local CloseBind = Enum.KeyCode.RightControl

local function RandomString()
    local Length = math.random(5, 15)
    local Array = {}
    for i = 1, Length do
        Array[i] = string.char(math.random(97, 122))
    end
    return table.concat(Array)
end

local ui = Instance.new("ScreenGui")
ui.Name = RandomString()
ui.Parent = game.CoreGui
ui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ui.ResetOnSpawn = false
ui.IgnoreGuiInset = true

coroutine.wrap(function()
    while ui and ui.Parent do
        if ui.Parent ~= game.CoreGui then
            ui.Parent = game.CoreGui
        end
        task.wait(1)
    end
end)()

local function CreateLoadingScreen()
    local LoadGui = Instance.new("ScreenGui")
    LoadGui.Name = "LoadingScreen"
    LoadGui.Parent = game.CoreGui
    LoadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    LoadGui.IgnoreGuiInset = true

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = LoadGui
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    MainFrame.BorderSizePixel = 0

    local Credit = Instance.new("TextLabel")
    Credit.Name = "Credit"
    Credit.Parent = MainFrame
    Credit.Size = UDim2.new(1, 0, 0, 50)
    Credit.Position = UDim2.new(0, 0, 0.5, -25)
    Credit.BackgroundTransparency = 1
    Credit.Text = "vezekk#0 made this script"
    Credit.TextColor3 = PresetColor
    Credit.Font = Enum.Font.GothamBold
    Credit.TextSize = 24.000

    local Spinner = Instance.new("Frame")
    Spinner.Name = "Spinner"
    Spinner.Parent = MainFrame
    Spinner.Size = UDim2.new(0, 50, 0, 50)
    Spinner.Position = UDim2.new(0.5, -25, 0.4, -25)
    Spinner.BackgroundColor3 = PresetColor
    Spinner.Rotation = 0
    Spinner.Visible = false
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Spinner

    local TweenInfoData = TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, -1, true)
    local TextTween = TweenService:Create(Credit, TweenInfoData, {TextTransparency = 0.5, TextStrokeTransparency = 0.5})
    TextTween:Play()

    task.wait(1.5)
    
    local OutTween = TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1})
    OutTween:Play()
    OutTween.Completed:Wait()
    LoadGui:Destroy()
end

coroutine.wrap(CreateLoadingScreen)()

coroutine.wrap(function()
    while true do
        task.wait()
        lib.RainbowColorValue = lib.RainbowColorValue + 1 / 255
        lib.HueSelectionPosition = lib.HueSelectionPosition + 1

        if lib.RainbowColorValue >= 1 then
            lib.RainbowColorValue = 0
        end

        if lib.HueSelectionPosition >= 80 then
            lib.HueSelectionPosition = 0
        end
    end
end)()

local function MakeDraggable(topbarobject, object)
    local Dragging = false
    local DragStart = nil
    local StartPosition = nil

    local function Update(input)
        local Delta = input.Position - DragStart
        local pos = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
        object.Position = pos
    end

    topbarobject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = input.Position
            
            if object.AnchorPoint ~= Vector2.new(0,0) then
                StartPosition = UDim2.fromOffset(object.AbsolutePosition.X, object.AbsolutePosition.Y)
                object.AnchorPoint = Vector2.new(0,0)
                object.Position = StartPosition
            else
                StartPosition = object.Position
            end
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if Dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            Update(input)
        end
    end)
end

function lib:Window(text, preset, closebind)
    CloseBind = closebind or Enum.KeyCode.RightControl
    PresetColor = preset or Color3.fromRGB(44, 120, 224)
    
    local fs = false
    
    local Main = Instance.new("Frame")
    local TabHold = Instance.new("Frame")
    local TabHoldLayout = Instance.new("UIListLayout")
    local Title = Instance.new("TextLabel")
    local TabFolder = Instance.new("Folder")
    local DragFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")

    Main.Name = RandomString()
    Main.Parent = ui
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0)
    Main.ClipsDescendants = true
    Main.Visible = true

    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    TabHold.Name = RandomString()
    TabHold.Parent = Main
    TabHold.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TabHold.BorderSizePixel = 0
    TabHold.Size = UDim2.new(0, 130, 0, 319)
    TabHold.Position = UDim2.new(0, 0, 0, 41)
    TabHold.ClipsDescendants = false
    
    local TabHoldCorner = Instance.new("UICorner")
    TabHoldCorner.CornerRadius = UDim.new(0, 8)
    TabHoldCorner.Parent = TabHold
    
    local TabHoldPadding = Instance.new("UIPadding")
    TabHoldPadding.PaddingTop = UDim.new(0, 10)
    TabHoldPadding.Parent = TabHold

    TabHoldLayout.Name = "TabHoldLayout"
    TabHoldLayout.Parent = TabHold
    TabHoldLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabHoldLayout.Padding = UDim.new(0, 5)

    Title.Name = "Title"
    Title.Parent = Main
    Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Title.BackgroundTransparency = 1.000
    Title.Size = UDim2.new(1, 0, 0, 41)
    Title.Font = Enum.Font.GothamBold
    Title.Text = "   " .. text
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16.000
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = Title
    
    DragFrame.Name = "DragFrame"
    DragFrame.Parent = Title
    DragFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    DragFrame.BackgroundTransparency = 1
    DragFrame.Size = UDim2.new(1, 0, 1, 0)

    Main:TweenSize(UDim2.new(0, 560, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)

    MakeDraggable(DragFrame, Main)

    UserInputService.InputBegan:Connect(function(io, p)
        if io.KeyCode == CloseBind then
            if lib.toggledui == false then
                Main:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)
                lib.toggledui = true
                task.wait(.6)
                Main.Visible = false
            else
                Main.Visible = true
                Main:TweenSize(UDim2.new(0, 560, 0, 360), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)
                lib.toggledui = false
            end
        end
    end)

    TabFolder.Name = RandomString()
    TabFolder.Parent = Main

    function lib:ChangePresetColor(toch)
        PresetColor = toch
    end

    function lib:Notification(texttitle, textdesc, textbtn)
        local NotificationHold = Instance.new("TextButton")
        local NotificationFrame = Instance.new("Frame")
        local OkayBtn = Instance.new("TextButton")
        local NotificationTitle = Instance.new("TextLabel")
        local NotificationDesc = Instance.new("TextLabel")

        NotificationHold.Name = "NotificationHold"
        NotificationHold.Parent = ui
        NotificationHold.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        NotificationHold.BackgroundTransparency = 1.000
        NotificationHold.BorderSizePixel = 0
        NotificationHold.Size = UDim2.new(1, 0, 1, 0)
        NotificationHold.AutoButtonColor = false
        NotificationHold.Font = Enum.Font.SourceSans
        NotificationHold.Text = ""
        NotificationHold.ZIndex = 100

        TweenService:Create(NotificationHold, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()

        NotificationFrame.Name = "NotificationFrame"
        NotificationFrame.Parent = NotificationHold
        NotificationFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        NotificationFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        NotificationFrame.BorderSizePixel = 0
        NotificationFrame.ClipsDescendants = true
        NotificationFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        NotificationFrame.Size = UDim2.new(0, 0, 0, 0)

        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotificationFrame

        NotificationFrame:TweenSize(UDim2.new(0, 300, 0, 180), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)

        OkayBtn.Name = "OkayBtn"
        OkayBtn.Parent = NotificationFrame
        OkayBtn.BackgroundColor3 = PresetColor
        OkayBtn.Position = UDim2.new(0.5, -50, 0.8, -15)
        OkayBtn.Size = UDim2.new(0, 100, 0, 30)
        OkayBtn.AutoButtonColor = false
        OkayBtn.Font = Enum.Font.GothamBold
        OkayBtn.Text = textbtn or "Okay"
        OkayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        OkayBtn.TextSize = 14.000

        local OkayCorner = Instance.new("UICorner")
        OkayCorner.CornerRadius = UDim.new(0, 6)
        OkayCorner.Parent = OkayBtn

        NotificationTitle.Name = "NotificationTitle"
        NotificationTitle.Parent = NotificationFrame
        NotificationTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NotificationTitle.BackgroundTransparency = 1.000
        NotificationTitle.Position = UDim2.new(0, 20, 0, 20)
        NotificationTitle.Size = UDim2.new(1, -40, 0, 30)
        NotificationTitle.Font = Enum.Font.GothamBold
        NotificationTitle.Text = texttitle
        NotificationTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        NotificationTitle.TextSize = 18.000
        NotificationTitle.TextXAlignment = Enum.TextXAlignment.Left

        NotificationDesc.Name = "NotificationDesc"
        NotificationDesc.Parent = NotificationFrame
        NotificationDesc.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        NotificationDesc.BackgroundTransparency = 1.000
        NotificationDesc.Position = UDim2.new(0, 20, 0, 60)
        NotificationDesc.Size = UDim2.new(1, -40, 0, 80)
        NotificationDesc.Font = Enum.Font.Gotham
        NotificationDesc.Text = textdesc
        NotificationDesc.TextColor3 = Color3.fromRGB(180, 180, 180)
        NotificationDesc.TextSize = 14.000
        NotificationDesc.TextWrapped = true
        NotificationDesc.TextXAlignment = Enum.TextXAlignment.Left
        NotificationDesc.TextYAlignment = Enum.TextYAlignment.Top

        OkayBtn.MouseEnter:Connect(function()
            TweenService:Create(OkayBtn, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(PresetColor.R * 255 - 20, PresetColor.G * 255 - 20, PresetColor.B * 255 - 20)}):Play()
        end)

        OkayBtn.MouseLeave:Connect(function()
            TweenService:Create(OkayBtn, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = PresetColor}):Play()
        end)

        OkayBtn.MouseButton1Click:Connect(function()
            NotificationFrame:TweenSize(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .6, true)
            task.wait(0.4)
            NotificationHold:Destroy()
        end)
    end

    local tabhold = {}

    function tabhold:Tab(text)
        local TabBtn = Instance.new("TextButton")
        local TabTitle = Instance.new("TextLabel")
        local TabBtnIndicator = Instance.new("Frame")

        TabBtn.Name = "TabBtn"
        TabBtn.Parent = TabHold
        TabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.BackgroundTransparency = 1.000
        TabBtn.Size = UDim2.new(0, 110, 0, 30)
        TabBtn.Font = Enum.Font.SourceSans
        TabBtn.Text = ""
        TabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        TabBtn.TextSize = 14.000

        TabTitle.Name = "TabTitle"
        TabTitle.Parent = TabBtn
        TabTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabTitle.BackgroundTransparency = 1.000
        TabTitle.Size = UDim2.new(1, 0, 1, 0)
        TabTitle.Font = Enum.Font.Gotham
        TabTitle.Text = text
        TabTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabTitle.TextSize = 13.000
        TabTitle.TextXAlignment = Enum.TextXAlignment.Center

        TabBtnIndicator.Name = "TabBtnIndicator"
        TabBtnIndicator.Parent = TabBtn
        TabBtnIndicator.BackgroundColor3 = PresetColor
        TabBtnIndicator.BorderSizePixel = 0
        TabBtnIndicator.Position = UDim2.new(0, 0, 1, -3)
        TabBtnIndicator.Size = UDim2.new(0, 0, 0, 3)

        local TabBtnIndCorner = Instance.new("UICorner")
        TabBtnIndCorner.CornerRadius = UDim.new(0, 2)
        TabBtnIndCorner.Parent = TabBtnIndicator

        coroutine.wrap(function()
            while task.wait() do
                TabBtnIndicator.BackgroundColor3 = PresetColor
            end
        end)()

        local Tab = Instance.new("ScrollingFrame")
        local TabLayout = Instance.new("UIListLayout")

        Tab.Name = "Tab"
        Tab.Parent = TabFolder
        Tab.Active = true
        Tab.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        Tab.BackgroundTransparency = 1.000
        Tab.BorderSizePixel = 0
        Tab.Position = UDim2.new(0.23, 0, 0.11, 0)
        Tab.Size = UDim2.new(0.77, 0, 0.89, 0)
        Tab.CanvasSize = UDim2.new(0, 0, 0, 0)
        Tab.ScrollBarThickness = 4
        Tab.ScrollBarImageColor3 = Color3.fromRGB(50,50,50)
        Tab.Visible = false

        TabLayout.Name = "TabLayout"
        TabLayout.Parent = Tab
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 8)

        if fs == false then
            fs = true
            TabBtnIndicator.Size = UDim2.new(1, 0, 0, 3)
            TabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            Tab.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            for i, v in next, TabFolder:GetChildren() do
                if v.Name == "Tab" then
                    v.Visible = false
                end
                Tab.Visible = true
            end
            for i, v in next, TabHold:GetChildren() do
                if v.Name == "TabBtn" then
                    v.TabBtnIndicator:TweenSize(UDim2.new(0, 0, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TabBtnIndicator:TweenSize(UDim2.new(1, 0, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TweenService:Create(v.TabTitle, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(TabTitle, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                end
            end
        end)

        local tabcontent = {}

        function tabcontent:Button(text, callback)
            local Button = Instance.new("TextButton")
            local ButtonCorner = Instance.new("UICorner")
            local ButtonTitle = Instance.new("TextLabel")

            Button.Name = "Button"
            Button.Parent = Tab
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.Size = UDim2.new(1, -10, 0, 35)
            Button.AutoButtonColor = false
            Button.Font = Enum.Font.SourceSans
            Button.Text = ""
            Button.TextColor3 = Color3.fromRGB(0, 0, 0)
            Button.TextSize = 14.000

            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button

            ButtonTitle.Name = "ButtonTitle"
            ButtonTitle.Parent = Button
            ButtonTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ButtonTitle.BackgroundTransparency = 1.000
            ButtonTitle.Position = UDim2.new(0, 10, 0, 0)
            ButtonTitle.Size = UDim2.new(1, -10, 1, 0)
            ButtonTitle.Font = Enum.Font.Gotham
            ButtonTitle.Text = text
            ButtonTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            ButtonTitle.TextSize = 14.000
            ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left

            Button.MouseButton1Click:Connect(function()
                TweenService:Create(Button, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
                task.wait(0.1)
                TweenService:Create(Button, TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                pcall(callback)
            end)

            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Toggle(text,default, callback)
            local toggled = false

            local Toggle = Instance.new("TextButton")
            local ToggleCorner = Instance.new("UICorner")
            local ToggleTitle = Instance.new("TextLabel")
            local ToggleOuter = Instance.new("Frame")
            local ToggleInner = Instance.new("Frame")

            Toggle.Name = "Toggle"
            Toggle.Parent = Tab
            Toggle.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Toggle.Size = UDim2.new(1, -10, 0, 35)
            Toggle.AutoButtonColor = false
            Toggle.Font = Enum.Font.SourceSans
            Toggle.Text = ""
            Toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
            Toggle.TextSize = 14.000

            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = Toggle

            ToggleTitle.Name = "ToggleTitle"
            ToggleTitle.Parent = Toggle
            ToggleTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleTitle.BackgroundTransparency = 1.000
            ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
            ToggleTitle.Size = UDim2.new(1, -50, 1, 0)
            ToggleTitle.Font = Enum.Font.Gotham
            ToggleTitle.Text = text
            ToggleTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            ToggleTitle.TextSize = 14.000
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left

            ToggleOuter.Name = "ToggleOuter"
            ToggleOuter.Parent = Toggle
            ToggleOuter.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ToggleOuter.Position = UDim2.new(1, -40, 0.5, -10)
            ToggleOuter.Size = UDim2.new(0, 35, 0, 20)
            
            local OuterCorner = Instance.new("UICorner")
            OuterCorner.CornerRadius = UDim.new(1, 0)
            OuterCorner.Parent = ToggleOuter

            ToggleInner.Name = "ToggleInner"
            ToggleInner.Parent = ToggleOuter
            ToggleInner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleInner.Position = UDim2.new(0, 2, 0.5, -6)
            ToggleInner.Size = UDim2.new(0, 16, 0, 12)
            
            local InnerCorner = Instance.new("UICorner")
            InnerCorner.CornerRadius = UDim.new(1, 0)
            InnerCorner.Parent = ToggleInner

            local function UpdateToggle()
                if toggled then
                    TweenService:Create(ToggleInner, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 17, 0.5, -6)}):Play()
                    TweenService:Create(ToggleOuter, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = PresetColor}):Play()
                else
                    TweenService:Create(ToggleInner, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
                    TweenService:Create(ToggleOuter, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
                end
            end

            Toggle.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateToggle()
                pcall(callback, toggled)
            end)

            if default then
                toggled = true
                UpdateToggle()
            end

            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Slider(text, min, max, start, callback)
            local dragging = false
            local Slider = Instance.new("Frame")
            local SliderCorner = Instance.new("UICorner")
            local SliderTitle = Instance.new("TextLabel")
            local SliderValue = Instance.new("TextLabel")
            local SlideFrame = Instance.new("Frame")
            local CurrentValueFrame = Instance.new("Frame")
            local SlideCircle = Instance.new("ImageButton")

            Slider.Name = "Slider"
            Slider.Parent = Tab
            Slider.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Slider.Size = UDim2.new(1, -10, 0, 50)

            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = Slider

            SliderTitle.Name = "SliderTitle"
            SliderTitle.Parent = Slider
            SliderTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderTitle.BackgroundTransparency = 1.000
            SliderTitle.Position = UDim2.new(0, 10, 0, 5)
            SliderTitle.Size = UDim2.new(1, -20, 0, 20)
            SliderTitle.Font = Enum.Font.Gotham
            SliderTitle.Text = text
            SliderTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            SliderTitle.TextSize = 13.000
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left

            SliderValue.Name = "SliderValue"
            SliderValue.Parent = Slider
            SliderValue.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SliderValue.BackgroundTransparency = 1.000
            SliderValue.Size = UDim2.new(1, -20, 0, 20)
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.Text = tostring(start)
            SliderValue.TextColor3 = PresetColor
            SliderValue.TextSize = 13.000
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right

            SlideFrame.Name = "SlideFrame"
            SlideFrame.Parent = Slider
            SlideFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            SlideFrame.BorderSizePixel = 0
            SlideFrame.Position = UDim2.new(0, 10, 0, 30)
            SlideFrame.Size = UDim2.new(1, -20, 0, 8)
            
            local SlideCorner = Instance.new("UICorner")
            SlideCorner.CornerRadius = UDim.new(1, 0)
            SlideCorner.Parent = SlideFrame

            CurrentValueFrame.Name = "CurrentValueFrame"
            CurrentValueFrame.Parent = SlideFrame
            CurrentValueFrame.BackgroundColor3 = PresetColor
            CurrentValueFrame.BorderSizePixel = 0
            CurrentValueFrame.Size = UDim2.new((start or 0) / max, 0, 1, 0)
            
            local ValCorner = Instance.new("UICorner")
            ValCorner.CornerRadius = UDim.new(1, 0)
            ValCorner.Parent = CurrentValueFrame

            SlideCircle.Name = "SlideCircle"
            SlideCircle.Parent = SlideFrame
            SlideCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SlideCircle.Position = UDim2.new((start or 0) / max, -8, 0.5, -8)
            SlideCircle.Size = UDim2.new(0, 16, 0, 16)
            SlideCircle.ZIndex = 2
            SlideCircle.Image = ""

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = SlideCircle

            coroutine.wrap(function()
                while task.wait() do
                    CurrentValueFrame.BackgroundColor3 = PresetColor
                    SliderValue.TextColor3 = PresetColor
                end
            end)()

            local function move(input)
                local pos = math.clamp((input.Position.X - SlideFrame.AbsolutePosition.X) / SlideFrame.AbsoluteSize.X, 0, 1)
                CurrentValueFrame:TweenSize(UDim2.new(pos, 0, 1, 0), "Out", "Sine", 0.1, true)
                SlideCircle:TweenPosition(UDim2.new(pos, -8, 0.5, -8), "Out", "Sine", 0.1, true)
                local value = math.floor(((pos) * max) + min)
                SliderValue.Text = tostring(value)
                pcall(callback, value)
            end

            SlideCircle.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                end
            end)
            SlideCircle.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            SlideFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    move(input)
                end
            end)
            
            SlideFrame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    move(input)
                end
            end)
            
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Dropdown(text, list, callback)
            local droptog = false
            local framesize = 0

            local Dropdown = Instance.new("Frame")
            local DropdownCorner = Instance.new("UICorner")
            local DropdownBtn = Instance.new("TextButton")
            local DropdownTitle = Instance.new("TextLabel")
            local ArrowImg = Instance.new("ImageLabel")
            local DropItemHolder = Instance.new("ScrollingFrame")
            local DropLayout = Instance.new("UIListLayout")

            Dropdown.Name = "Dropdown"
            Dropdown.Parent = Tab
            Dropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Dropdown.ClipsDescendants = true
            Dropdown.Size = UDim2.new(1, -10, 0, 35)
            
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = Dropdown

            DropdownBtn.Name = "DropdownBtn"
            DropdownBtn.Parent = Dropdown
            DropdownBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownBtn.BackgroundTransparency = 1.000
            DropdownBtn.Size = UDim2.new(1, 0, 0, 35)
            DropdownBtn.Font = Enum.Font.SourceSans
            DropdownBtn.Text = ""
            DropdownBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
            DropdownBtn.TextSize = 14.000
            DropdownBtn.ZIndex = 2

            DropdownTitle.Name = "DropdownTitle"
            DropdownTitle.Parent = DropdownBtn
            DropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            DropdownTitle.BackgroundTransparency = 1.000
            DropdownTitle.Position = UDim2.new(0, 10, 0, 0)
            DropdownTitle.Size = UDim2.new(1, -40, 1, 0)
            DropdownTitle.Font = Enum.Font.Gotham
            DropdownTitle.Text = text
            DropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            DropdownTitle.TextSize = 14.000
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.ZIndex = 2

            ArrowImg.Name = "ArrowImg"
            ArrowImg.Parent = DropdownTitle
            ArrowImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ArrowImg.BackgroundTransparency = 1.000
            ArrowImg.Position = UDim2.new(1, -25, 0.5, -10)
            ArrowImg.Size = UDim2.new(0, 20, 0, 20)
            ArrowImg.Image = "http://www.roblox.com/asset/?id=6034818375"
            ArrowImg.ZIndex = 2

            DropItemHolder.Name = "DropItemHolder"
            DropItemHolder.Parent = Dropdown
            DropItemHolder.Active = true
            DropItemHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            DropItemHolder.BorderSizePixel = 0
            DropItemHolder.Position = UDim2.new(0, 0, 0, 35)
            DropItemHolder.Size = UDim2.new(1, 0, 0, 0)
            DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropItemHolder.ScrollBarThickness = 3
            DropItemHolder.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
            DropItemHolder.ClipsDescendants = true
            DropItemHolder.ZIndex = 3

            DropLayout.Name = "DropLayout"
            DropLayout.Parent = DropItemHolder
            DropLayout.SortOrder = Enum.SortOrder.LayoutOrder

            DropdownBtn.MouseButton1Click:Connect(function()
                if droptog == false then
                    droptog = true
                    Dropdown:TweenSize(UDim2.new(1, -10, 0, 150), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    DropItemHolder:TweenSize(UDim2.new(1, 0, 1, -35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TweenService:Create(ArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180}):Play()
                    task.wait(0.2)
                    Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
                else
                    droptog = false
                    Dropdown:TweenSize(UDim2.new(1, -10, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    DropItemHolder:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TweenService:Create(ArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                    task.wait(0.2)
                    Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
                end
            end)

            for i, v in next, list do
                local Item = Instance.new("TextButton")

                Item.Name = "Item"
                Item.Parent = DropItemHolder
                Item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                Item.Size = UDim2.new(1, 0, 0, 30)
                Item.AutoButtonColor = false
                Item.Font = Enum.Font.Gotham
                Item.Text = v
                Item.TextColor3 = Color3.fromRGB(255, 255, 255)
                Item.TextSize = 14.000
                Item.ZIndex = 3

                Item.MouseEnter:Connect(function()
                    TweenService:Create(Item, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = PresetColor}):Play()
                    Item.TextColor3 = Color3.fromRGB(255,255,255)
                end)

                Item.MouseLeave:Connect(function()
                    TweenService:Create(Item, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                end)

                Item.MouseButton1Click:Connect(function()
                    droptog = false
                    DropdownTitle.Text = text .. " : " .. v
                    pcall(callback, v)
                    Dropdown:TweenSize(UDim2.new(1, -10, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    DropItemHolder:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TweenService:Create(ArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                    task.wait(0.2)
                    Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
                end)
            end
            
            DropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)
            end)
            DropItemHolder.CanvasSize = UDim2.new(0, 0, 0, DropLayout.AbsoluteContentSize.Y)
            
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Label(text)
            local Label = Instance.new("TextButton")
            local LabelCorner = Instance.new("UICorner")
            local LabelTitle = Instance.new("TextLabel")

            Label.Name = "Label"
            Label.Parent = Tab
            Label.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Label.Size = UDim2.new(1, -10, 0, 30)
            Label.AutoButtonColor = false
            Label.Font = Enum.Font.SourceSans
            Label.Text = ""
            Label.TextColor3 = Color3.fromRGB(0, 0, 0)
            Label.TextSize = 14.000

            LabelCorner.CornerRadius = UDim.new(0, 6)
            LabelCorner.Parent = Label

            LabelTitle.Name = "LabelTitle"
            LabelTitle.Parent = Label
            LabelTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            LabelTitle.BackgroundTransparency = 1.000
            LabelTitle.Position = UDim2.new(0, 10, 0, 0)
            LabelTitle.Size = UDim2.new(1, -20, 1, 0)
            LabelTitle.Font = Enum.Font.GothamBold
            LabelTitle.Text = text
            LabelTitle.TextColor3 = PresetColor
            LabelTitle.TextSize = 13.000
            LabelTitle.TextXAlignment = Enum.TextXAlignment.Left

            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Textbox(text, disapper, callback)
            local Textbox = Instance.new("Frame")
            local TextboxCorner = Instance.new("UICorner")
            local TextboxTitle = Instance.new("TextLabel")
            local TextboxFrame = Instance.new("Frame")
            local TextboxFrameCorner = Instance.new("UICorner")
            local TextBox = Instance.new("TextBox")

            Textbox.Name = "Textbox"
            Textbox.Parent = Tab
            Textbox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Textbox.ClipsDescendants = true
            Textbox.Size = UDim2.new(1, -10, 0, 35)

            TextboxCorner.CornerRadius = UDim.new(0, 6)
            TextboxCorner.Parent = Textbox

            TextboxTitle.Name = "TextboxTitle"
            TextboxTitle.Parent = Textbox
            TextboxTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextboxTitle.BackgroundTransparency = 1.000
            TextboxTitle.Position = UDim2.new(0, 10, 0, 0)
            TextboxTitle.Size = UDim2.new(1, -110, 1, 0)
            TextboxTitle.Font = Enum.Font.Gotham
            TextboxTitle.Text = text
            TextboxTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextboxTitle.TextSize = 14.000
            TextboxTitle.TextXAlignment = Enum.TextXAlignment.Left

            TextboxFrame.Name = "TextboxFrame"
            TextboxFrame.Parent = Textbox
            TextboxFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
            TextboxFrame.Position = UDim2.new(1, -100, 0.5, -12)
            TextboxFrame.Size = UDim2.new(0, 90, 0, 24)

            TextboxFrameCorner.CornerRadius = UDim.new(0, 4)
            TextboxFrameCorner.Parent = TextboxFrame

            TextBox.Parent = TextboxFrame
            TextBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.BackgroundTransparency = 1.000
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.Text = ""
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.TextSize = 13.000
            TextBox.PlaceholderText = "Type here..."
            TextBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)

            TextBox.FocusLost:Connect(function(ep)
                if ep then
                    if #TextBox.Text > 0 then
                        pcall(callback, TextBox.Text)
                        if disapper then
                            TextBox.Text = ""
                        end
                    end
                end
            end)
            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
        end

        function tabcontent:Bind(text, keypreset, callback)
            local binding = false
            local Key = keypreset.Name
            local Bind = Instance.new("TextButton")
            local BindCorner = Instance.new("UICorner")
            local BindTitle = Instance.new("TextLabel")
            local BindText = Instance.new("TextLabel")

            Bind.Name = "Bind"
            Bind.Parent = Tab
            Bind.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Bind.Size = UDim2.new(1, -10, 0, 35)
            Bind.AutoButtonColor = false
            Bind.Font = Enum.Font.SourceSans
            Bind.Text = ""
            Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
            Bind.TextSize = 14.000

            BindCorner.CornerRadius = UDim.new(0, 6)
            BindCorner.Parent = Bind

            BindTitle.Name = "BindTitle"
            BindTitle.Parent = Bind
            BindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            BindTitle.BackgroundTransparency = 1.000
            BindTitle.Position = UDim2.new(0, 10, 0, 0)
            BindTitle.Size = UDim2.new(1, -100, 1, 0)
            BindTitle.Font = Enum.Font.Gotham
            BindTitle.Text = text
            BindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
            BindTitle.TextSize = 14.000
            BindTitle.TextXAlignment = Enum.TextXAlignment.Left

            BindText.Name = "BindText"
            BindText.Parent = Bind
            BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            BindText.BackgroundTransparency = 1.000
            BindText.Size = UDim2.new(1, -10, 1, 0)
            BindText.Font = Enum.Font.GothamBold
            BindText.Text = "[" .. Key .. "]"
            BindText.TextColor3 = PresetColor
            BindText.TextSize = 13.000
            BindText.TextXAlignment = Enum.TextXAlignment.Right

            Tab.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)

            Bind.MouseButton1Click:Connect(function()
                BindText.Text = "[...]"
                binding = true
                local inputwait = UserInputService.InputBegan:Wait()
                if inputwait.KeyCode.Name ~= "Unknown" then
                    BindText.Text = "[" .. inputwait.KeyCode.Name .. "]"
                    Key = inputwait.KeyCode.Name
                    binding = false
                else
                    binding = false
                    BindText.Text = "[" .. Key .. "]"
                end
            end)

            UserInputService.InputBegan:Connect(function(current, gameProcessed)
                if not gameProcessed then
                    if current.KeyCode.Name == Key and binding == false then
                        pcall(callback)
                    end
                end
            end)
        end

        return tabcontent
    end

    -- AUTOMATICALLY ADD SETTINGS TAB AT THE END --
    do
        local SettingsTabBtn = Instance.new("TextButton")
        local SettingsTabTitle = Instance.new("TextLabel")
        local SettingsTabIndicator = Instance.new("Frame")

        SettingsTabBtn.Name = "TabBtn"
        SettingsTabBtn.Parent = TabHold
        SettingsTabBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SettingsTabBtn.BackgroundTransparency = 1.000
        SettingsTabBtn.Size = UDim2.new(0, 110, 0, 30)
        SettingsTabBtn.LayoutOrder = 999 -- Force to end
        SettingsTabBtn.Font = Enum.Font.SourceSans
        SettingsTabBtn.Text = ""
        SettingsTabBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        SettingsTabBtn.TextSize = 14.000

        SettingsTabTitle.Name = "TabTitle"
        SettingsTabTitle.Parent = SettingsTabBtn
        SettingsTabTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        SettingsTabTitle.BackgroundTransparency = 1.000
        SettingsTabTitle.Size = UDim2.new(1, 0, 1, 0)
        SettingsTabTitle.Font = Enum.Font.Gotham
        SettingsTabTitle.Text = "Settings"
        SettingsTabTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
        SettingsTabTitle.TextSize = 13.000
        SettingsTabTitle.TextXAlignment = Enum.TextXAlignment.Center

        SettingsTabIndicator.Name = "TabBtnIndicator"
        SettingsTabIndicator.Parent = SettingsTabBtn
        SettingsTabIndicator.BackgroundColor3 = PresetColor
        SettingsTabIndicator.BorderSizePixel = 0
        SettingsTabIndicator.Position = UDim2.new(0, 0, 1, -3)
        SettingsTabIndicator.Size = UDim2.new(0, 0, 0, 3)

        local SettingsTabIndCorner = Instance.new("UICorner")
        SettingsTabIndCorner.CornerRadius = UDim.new(0, 2)
        SettingsTabIndCorner.Parent = SettingsTabIndicator

        coroutine.wrap(function()
            while task.wait() do
                SettingsTabIndicator.BackgroundColor3 = PresetColor
            end
        end)()

        local SettingsTab = Instance.new("ScrollingFrame")
        local SettingsTabLayout = Instance.new("UIListLayout")

        SettingsTab.Name = "Tab"
        SettingsTab.Parent = TabFolder
        SettingsTab.Active = true
        SettingsTab.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        SettingsTab.BackgroundTransparency = 1.000
        SettingsTab.BorderSizePixel = 0
        SettingsTab.Position = UDim2.new(0.23, 0, 0.11, 0)
        SettingsTab.Size = UDim2.new(0.77, 0, 0.89, 0)
        SettingsTab.CanvasSize = UDim2.new(0, 0, 0, 0)
        SettingsTab.ScrollBarThickness = 4
        SettingsTab.ScrollBarImageColor3 = Color3.fromRGB(50,50,50)
        SettingsTab.Visible = false

        SettingsTabLayout.Name = "TabLayout"
        SettingsTabLayout.Parent = SettingsTab
        SettingsTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        SettingsTabLayout.Padding = UDim.new(0, 8)

        SettingsTabBtn.MouseButton1Click:Connect(function()
            for i, v in next, TabFolder:GetChildren() do
                if v.Name == "Tab" then
                    v.Visible = false
                end
                SettingsTab.Visible = true
            end
            for i, v in next, TabHold:GetChildren() do
                if v.Name == "TabBtn" then
                    v.TabBtnIndicator:TweenSize(UDim2.new(0, 0, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    SettingsTabIndicator:TweenSize(UDim2.new(1, 0, 0, 3), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                    TweenService:Create(v.TabTitle, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(150, 150, 150)}):Play()
                    TweenService:Create(SettingsTabTitle, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                end
            end
        end)

        -- 1. UI THEME DROPDOWN
        local ThemeDropdown = Instance.new("Frame")
        local ThemeDropdownCorner = Instance.new("UICorner")
        local ThemeDropdownBtn = Instance.new("TextButton")
        local ThemeDropdownTitle = Instance.new("TextLabel")
        local ThemeArrowImg = Instance.new("ImageLabel")
        local ThemeDropItemHolder = Instance.new("ScrollingFrame")
        local ThemeDropLayout = Instance.new("UIListLayout")

        ThemeDropdown.Name = "Dropdown"
        ThemeDropdown.Parent = SettingsTab
        ThemeDropdown.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ThemeDropdown.ClipsDescendants = true
        ThemeDropdown.Size = UDim2.new(1, -10, 0, 35)
        
        ThemeDropdownCorner.CornerRadius = UDim.new(0, 6)
        ThemeDropdownCorner.Parent = ThemeDropdown

        ThemeDropdownBtn.Name = "DropdownBtn"
        ThemeDropdownBtn.Parent = ThemeDropdown
        ThemeDropdownBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ThemeDropdownBtn.BackgroundTransparency = 1.000
        ThemeDropdownBtn.Size = UDim2.new(1, 0, 0, 35)
        ThemeDropdownBtn.Font = Enum.Font.SourceSans
        ThemeDropdownBtn.Text = ""
        ThemeDropdownBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        ThemeDropdownBtn.TextSize = 14.000
        ThemeDropdownBtn.ZIndex = 2

        ThemeDropdownTitle.Name = "DropdownTitle"
        ThemeDropdownTitle.Parent = ThemeDropdownBtn
        ThemeDropdownTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ThemeDropdownTitle.BackgroundTransparency = 1.000
        ThemeDropdownTitle.Position = UDim2.new(0, 10, 0, 0)
        ThemeDropdownTitle.Size = UDim2.new(1, -40, 1, 0)
        ThemeDropdownTitle.Font = Enum.Font.Gotham
        ThemeDropdownTitle.Text = "UI Theme"
        ThemeDropdownTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        ThemeDropdownTitle.TextSize = 14.000
        ThemeDropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
        ThemeDropdownTitle.ZIndex = 2

        ThemeArrowImg.Name = "ArrowImg"
        ThemeArrowImg.Parent = ThemeDropdownTitle
        ThemeArrowImg.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ThemeArrowImg.BackgroundTransparency = 1.000
        ThemeArrowImg.Position = UDim2.new(1, -25, 0.5, -10)
        ThemeArrowImg.Size = UDim2.new(0, 20, 0, 20)
        ThemeArrowImg.Image = "http://www.roblox.com/asset/?id=6034818375"
        ThemeArrowImg.ZIndex = 2

        ThemeDropItemHolder.Name = "DropItemHolder"
        ThemeDropItemHolder.Parent = ThemeDropdown
        ThemeDropItemHolder.Active = true
        ThemeDropItemHolder.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        ThemeDropItemHolder.BorderSizePixel = 0
        ThemeDropItemHolder.Position = UDim2.new(0, 0, 0, 35)
        ThemeDropItemHolder.Size = UDim2.new(1, 0, 0, 0)
        ThemeDropItemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
        ThemeDropItemHolder.ScrollBarThickness = 3
        ThemeDropItemHolder.ScrollBarImageColor3 = Color3.fromRGB(60,60,60)
        ThemeDropItemHolder.ClipsDescendants = true
        ThemeDropItemHolder.ZIndex = 3

        ThemeDropLayout.Name = "DropLayout"
        ThemeDropLayout.Parent = ThemeDropItemHolder
        ThemeDropLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local themedroptog = false

        ThemeDropdownBtn.MouseButton1Click:Connect(function()
            if themedroptog == false then
                themedroptog = true
                ThemeDropdown:TweenSize(UDim2.new(1, -10, 0, 150), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                ThemeDropItemHolder:TweenSize(UDim2.new(1, 0, 1, -35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                TweenService:Create(ThemeArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 180}):Play()
                task.wait(0.2)
                SettingsTab.CanvasSize = UDim2.new(0, 0, 0, SettingsTabLayout.AbsoluteContentSize.Y + 20)
            else
                themedroptog = false
                ThemeDropdown:TweenSize(UDim2.new(1, -10, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                ThemeDropItemHolder:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                TweenService:Create(ThemeArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                task.wait(0.2)
                SettingsTab.CanvasSize = UDim2.new(0, 0, 0, SettingsTabLayout.AbsoluteContentSize.Y + 20)
            end
        end)

        local Themes = {
            {Name = "Blue", Color = Color3.fromRGB(44, 120, 224)},
            {Name = "Red", Color = Color3.fromRGB(255, 0, 0)},
            {Name = "Green", Color = Color3.fromRGB(0, 255, 0)},
            {Name = "Purple", Color3.fromRGB(150, 0, 255)},
            {Name = "Orange", Color = Color3.fromRGB(255, 165, 0)},
            {Name = "White", Color = Color3.fromRGB(255, 255, 255)},
            {Name = "Black", Color = Color3.fromRGB(0, 0, 0)}
        }

        for i, t in next, Themes do
            local Item = Instance.new("TextButton")

            Item.Name = "Item"
            Item.Parent = ThemeDropItemHolder
            Item.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Item.Size = UDim2.new(1, 0, 0, 30)
            Item.AutoButtonColor = false
            Item.Font = Enum.Font.Gotham
            Item.Text = t.Name
            Item.TextColor3 = Color3.fromRGB(255, 255, 255)
            Item.TextSize = 14.000
            Item.ZIndex = 3

            Item.MouseEnter:Connect(function()
                TweenService:Create(Item, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = PresetColor}):Play()
                Item.TextColor3 = Color3.fromRGB(255,255,255)
            end)

            Item.MouseLeave:Connect(function()
                TweenService:Create(Item, TweenInfo.new(.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
            end)

            Item.MouseButton1Click:Connect(function()
                themedroptog = false
                ThemeDropdownTitle.Text = "UI Theme : " .. t.Name
                lib:ChangePresetColor(t.Color)
                ThemeDropdown:TweenSize(UDim2.new(1, -10, 0, 35), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                ThemeDropItemHolder:TweenSize(UDim2.new(1, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, .2, true)
                TweenService:Create(ThemeArrowImg, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Rotation = 0}):Play()
                task.wait(0.2)
                SettingsTab.CanvasSize = UDim2.new(0, 0, 0, SettingsTabLayout.AbsoluteContentSize.Y + 20)
            end)
        end
        
        ThemeDropLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            ThemeDropItemHolder.CanvasSize = UDim2.new(0, 0, 0, ThemeDropLayout.AbsoluteContentSize.Y)
        end)
        ThemeDropItemHolder.CanvasSize = UDim2.new(0, 0, 0, ThemeDropLayout.AbsoluteContentSize.Y)


        -- 2. UI TOGGLE KEYBIND
        local binding_key = false
        local Key = CloseBind.Name
        local Bind = Instance.new("TextButton")
        local BindCorner = Instance.new("UICorner")
        local BindTitle = Instance.new("TextLabel")
        local BindText = Instance.new("TextLabel")

        Bind.Name = "Bind"
        Bind.Parent = SettingsTab
        Bind.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Bind.Size = UDim2.new(1, -10, 0, 35)
        Bind.AutoButtonColor = false
        Bind.Font = Enum.Font.SourceSans
        Bind.Text = ""
        Bind.TextColor3 = Color3.fromRGB(0, 0, 0)
        Bind.TextSize = 14.000

        BindCorner.CornerRadius = UDim.new(0, 6)
        BindCorner.Parent = Bind

        BindTitle.Name = "BindTitle"
        BindTitle.Parent = Bind
        BindTitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BindTitle.BackgroundTransparency = 1.000
        BindTitle.Position = UDim2.new(0, 10, 0, 0)
        BindTitle.Size = UDim2.new(1, -100, 1, 0)
        BindTitle.Font = Enum.Font.Gotham
        BindTitle.Text = "UI Toggle Key"
        BindTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        BindTitle.TextSize = 14.000
        BindTitle.TextXAlignment = Enum.TextXAlignment.Left

        BindText.Name = "BindText"
        BindText.Parent = Bind
        BindText.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        BindText.BackgroundTransparency = 1.000
        BindText.Size = UDim2.new(1, -10, 1, 0)
        BindText.Font = Enum.Font.GothamBold
        BindText.Text = "[" .. Key .. "]"
        BindText.TextColor3 = PresetColor
        BindText.TextSize = 13.000
        BindText.TextXAlignment = Enum.TextXAlignment.Right

        SettingsTab.CanvasSize = UDim2.new(0, 0, 0, SettingsTabLayout.AbsoluteContentSize.Y + 20)

        Bind.MouseButton1Click:Connect(function()
            BindText.Text = "[...]"
            binding_key = true
            local inputwait = UserInputService.InputBegan:Wait()
            if inputwait.KeyCode.Name ~= "Unknown" then
                BindText.Text = "[" .. inputwait.KeyCode.Name .. "]"
                Key = inputwait.KeyCode.Name
                
                if Enum.KeyCode[Key] then
                    CloseBind = Enum.KeyCode[Key]
                else
                    warn("Invalid Keycode for UI Toggle")
                end
                binding_key = false
            else
                binding_key = false
                BindText.Text = "[" .. Key .. "]"
            end
        end)

        
        coroutine.wrap(function()
            while task.wait() do
                BindText.TextColor3 = PresetColor
            end
        end)()
    end

    return tabhold
end
return lib
