--[[
    Phantom UI Library v2.3
    CHANGES:
    • Tabs moved inside the window (no longer outside)
    • Replaced basic RGB sliders color picker with full-featured color picker
      (hue slider + SV square + alpha slider + preview)
    Theme: Dark Mode with Pink Accents
]]
local Phantom = {}
Phantom.__index = Phantom

-- Services
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")
local HttpService      = game:GetService("HttpService")

-- Theme
local Theme = {
    Background         = Color3.fromRGB(15,  15,  15),
    BackgroundSecondary= Color3.fromRGB(20,  20,  20),
    Border             = Color3.fromRGB(50,  50,  50),
    BorderDark         = Color3.fromRGB(35,  35,  35),
    Header             = Color3.fromRGB(18,  18,  18),
    Accent             = Color3.fromRGB(255,105, 180),
    AccentDark         = Color3.fromRGB(180, 75, 130),
    Text               = Color3.fromRGB(220,220,220),
    TextDark           = Color3.fromRGB(150,150,150),
    SliderFill         = Color3.fromRGB(255,105,180),
    ToggleActive       = Color3.fromRGB(255,105,180),
}

local function CreateElement(class, props)
    local e = Instance.new(class)
    for k,v in pairs(props or {}) do e[k] = v end
    return e
end

local function Tween(obj, props, duration)
    duration = duration or 0.2
    local ti = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

function Phantom:CreateWindow(config)
    local Window = {}
    Window.Tabs        = {}
    Window.CurrentTab  = nil
    Window.Flags       = {}
    Window.UIVisible   = true
    Window.MenuBind    = Enum.KeyCode.RightShift

    local ScreenGui = CreateElement("ScreenGui", {
        Name = "PhantomUI_"..math.random(1000,9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ────────────────────────────────────────────────────────────────
    -- Main Window
    -- ────────────────────────────────────────────────────────────────
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 520),
        Position = UDim2.new(0.5, -350, 0.5, -260),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })

    -- Title Bar (taller to give more breathing room)
    local TitleBar = CreateElement("Frame", {
        Size = UDim2.new(1,0,0,32),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = MainFrame,
    })

    CreateElement("TextLabel", {
        Size = UDim2.new(1,-80,1,0),
        Position = UDim2.new(0,8,0,0),
        BackgroundTransparency = 1,
        Text = config.Name or "Phantom",
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code,
        TextSize = 14,
        ZIndex = 6,
        Parent = TitleBar,
    })

    -- Dragging
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    TitleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Tab Bar (now INSIDE the window, below title)
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1,0,0,30),
        Position = UDim2.new(0,0,0,32),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = MainFrame,
    })

    CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
        Parent = TabContainer,
    })

    CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0,8),
        PaddingTop = UDim.new(0,4),
        Parent = TabContainer,
    })

    -- Content area (shifted down)
    local ContentContainer = CreateElement("Frame", {
        Size = UDim2.new(1,0,1,-62),
        Position = UDim2.new(0,0,0,62),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainFrame,
    })

    -- Toggle UI
    UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Window.MenuBind then
            Window.UIVisible = not Window.UIVisible
            MainFrame.Visible = Window.UIVisible
        end
    end)

    function Window:ToggleUI()
        Window.UIVisible = not Window.UIVisible
        MainFrame.Visible = Window.UIVisible
    end

    -- ────────────────────────────────────────────────────────────────
    -- Tab Creation
    -- ────────────────────────────────────────────────────────────────
    function Window:CreateTab(config)
        local Tab = {}
        Tab.Name = config.Name or "Tab"
        Tab.Sections = {Left = {}, Right = {}}

        local TabButton = CreateElement("TextButton", {
            Size = UDim2.new(0,80,0,22),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Code,
            TextSize = 12,
            AutoButtonColor = false,
            ZIndex = 5,
            Parent = TabContainer,
        })

        local Indicator = CreateElement("Frame", {
            Size = UDim2.new(1,0,0,2),
            Position = UDim2.new(0,0,1,-2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 6,
            Parent = TabButton,
        })

        local TabContent = CreateElement("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentContainer,
        })

        -- Two-column layout
        local Left = CreateElement("ScrollingFrame", {
            Size = UDim2.new(0.5,-8,1,-12),
            Position = UDim2.new(0,6,0,6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0,0,0,0),
            Parent = TabContent,
        })

        CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0,8),
            Parent = Left,
        })

        local Right = CreateElement("ScrollingFrame", {
            Size = UDim2.new(0.5,-8,1,-12),
            Position = UDim2.new(0.5,2,0,6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(0,0,0,0),
            Parent = TabContent,
        })

        CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0,8),
            Parent = Right,
        })

        Tab.Button    = TabButton
        Tab.Indicator = Indicator
        Tab.Content   = TabContent
        Tab.Left      = Left
        Tab.Right     = Right

        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        function Tab:CreateSection(secConfig)
            local Section = {}
            local side = secConfig.Side == "Right" and "Right" or "Left"
            local parent = side == "Left" and Left or Right

            local frame = CreateElement("Frame", {
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.BackgroundSecondary,
                BorderColor3 = Theme.Border,
                BorderSizePixel = 1,
                Parent = parent,
            })

            CreateElement("Frame", {    -- inner border effect
                Size = UDim2.new(1,-2,1,-2),
                Position = UDim2.new(0,1,0,1),
                BackgroundTransparency = 1,
                BorderColor3 = Theme.BorderDark,
                BorderSizePixel = 1,
                Parent = frame,
            })

            local title = CreateElement("TextLabel", {
                Size = UDim2.new(1,-12,0,22),
                BackgroundTransparency = 1,
                Text = secConfig.Name or "Section",
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Code,
                TextSize = 12,
                Parent = frame,
            })

            local content = CreateElement("Frame", {
                Size = UDim2.new(1,0,0,0),
                Position = UDim2.new(0,0,0,22),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = frame,
            })

            CreateElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,4),
                Parent = content,
            })

            CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0,6),
                PaddingRight = UDim.new(0,6),
                PaddingTop = UDim.new(0,4),
                PaddingBottom = UDim.new(0,6),
                Parent = content,
            })

            -- ────────────────────────────────────────────────
            --   New Color Picker (wheel + sliders)
            -- ────────────────────────────────────────────────
            function Section:AddColorPicker(cpConfig)
                local cp = {}
                cp.Name = cpConfig.Name or "Color"
                cp.Value = cpConfig.Default or Theme.Accent
                cp.Transparency = cpConfig.DefaultTransparency or 0
                cp.Callback = cpConfig.Callback or function()end
                cp.Flag = cpConfig.Flag
                cp.Open = false

                local container = CreateElement("Frame", {
                    Size = UDim2.new(1,0,0,22),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = content,
                })

                local btn = CreateElement("TextButton", {
                    Size = UDim2.new(1,0,0,22),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = container,
                })

                CreateElement("TextLabel", {
                    Size = UDim2.new(1,-28,1,0),
                    BackgroundTransparency = 1,
                    Text = cp.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = btn,
                })

                local preview = CreateElement("Frame", {
                    Size = UDim2.new(0,20,0,16),
                    Position = UDim2.new(1,-24,0,3),
                    BackgroundColor3 = cp.Value,
                    BackgroundTransparency = cp.Transparency,
                    BorderColor3 = Theme.Border,
                    BorderSizePixel = 1,
                    Parent = btn,
                })

                -- ── Picker Panel ─────────────────────────────────────
                local panel = CreateElement("Frame", {
                    Size = UDim2.new(1,0,0,0),
                    Position = UDim2.new(0,0,0,22),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderColor3 = Theme.BorderDark,
                    BorderSizePixel = 1,
                    Parent = container,
                })

                local pad = CreateElement("UIPadding", {
                    PaddingLeft = UDim.new(0,8),
                    PaddingRight = UDim.new(0,8),
                    PaddingTop = UDim.new(0,8),
                    PaddingBottom = UDim.new(0,8),
                    Parent = panel,
                })

                -- Color wheel + SV square
                local wheelSize = 110
                local wheel = CreateElement("ImageLabel", {
                    Size = UDim2.new(0,wheelSize,0,wheelSize),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://143336155", -- classic color wheel
                    Parent = panel,
                })

                local wheelPicker = CreateElement("Frame", {
                    Size = UDim2.new(0,8,0,8),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    BorderSizePixel = 1,
                    Parent = wheel,
                })

                local square = CreateElement("Frame", {
                    Size = UDim2.new(0,wheelSize,0,wheelSize),
                    Position = UDim2.new(0,wheelSize+12,0,0),
                    BackgroundColor3 = Color3.new(1,0,0),
                    BorderSizePixel = 0,
                    Parent = panel,
                })

                CreateElement("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
                        ColorSequenceKeypoint.new(1, Color3.new(1,1,1)),
                    },
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0,0),
                        NumberSequenceKeypoint.new(1,1),
                    },
                    Rotation = 90,
                    Parent = square,
                })

                local squarePicker = CreateElement("Frame", {
                    Size = UDim2.new(0,8,0,8),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    BorderSizePixel = 1,
                    Parent = square,
                })

                -- Hue slider (vertical)
                local hueSlider = CreateElement("Frame", {
                    Size = UDim2.new(0,12,0,wheelSize),
                    Position = UDim2.new(0,wheelSize*2+24,0,0),
                    BackgroundColor3 = Color3.new(1,0,0),
                    BorderSizePixel = 0,
                    Parent = panel,
                })

                local hueGradient = CreateElement("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0,   0  )),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0  )),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,   255, 0  )),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,   255, 255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,   0,   255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0,   255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0,   0  )),
                    },
                    Rotation = 90,
                    Parent = hueSlider,
                })

                local hueMarker = CreateElement("Frame", {
                    Size = UDim2.new(1,4,0,4),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    Parent = hueSlider,
                })

                -- Alpha slider
                local alphaSlider = CreateElement("Frame", {
                    Size = UDim2.new(1,0,0,12),
                    Position = UDim2.new(0,0,wheelSize+12,0),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderSizePixel = 0,
                    Parent = panel,
                })

                local checker = CreateElement("ImageLabel", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://149064630", -- checkerboard
                    ImageColor3 = Color3.new(0.7,0.7,0.7),
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0,16,0,16),
                    Parent = alphaSlider,
                })

                local alphaFill = CreateElement("Frame", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundColor3 = cp.Value,
                    BorderSizePixel = 0,
                    Parent = alphaSlider,
                })

                CreateElement("UIGradient", {
                    Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0,0),
                        NumberSequenceKeypoint.new(1,1),
                    },
                    Parent = alphaFill,
                })

                local alphaMarker = CreateElement("Frame", {
                    Size = UDim2.new(0,4,1,4),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    Parent = alphaSlider,
                })

                -- Current color preview
                local finalPreview = CreateElement("Frame", {
                    Size = UDim2.new(0,80,0,24),
                    Position = UDim2.new(1,-88,wheelSize+20,0),
                    BackgroundColor3 = cp.Value,
                    BackgroundTransparency = cp.Transparency,
                    BorderColor3 = Theme.Border,
                    Parent = panel,
                })

                local hue, sat, val = 0, 1, 1   -- initial HSV
                local alpha = cp.Transparency

                local function updateFromHSV()
                    local color = Color3.fromHSV(hue, sat, val)
                    cp.Value = color
                    preview.BackgroundColor3 = color
                    finalPreview.BackgroundColor3 = color
                    alphaFill.BackgroundColor3 = color
                    finalPreview.BackgroundTransparency = alpha
                    preview.BackgroundTransparency = alpha

                    if cp.Flag then
                        Window.Flags[cp.Flag] = color
                        Window.Flags[cp.Flag.."_trans"] = alpha
                    end
                    cp.Callback(color, alpha)
                end

                -- Wheel dragging
                local wheelDragging = false
                wheel.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then wheelDragging = true end
                end)
                wheel.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then wheelDragging = false end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if not wheelDragging then return end
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                    local mp = i.Position - wheel.AbsolutePosition
                    local cx, cy = mp.X - wheelSize/2, mp.Y - wheelSize/2
                    local dist = math.sqrt(cx*cx + cy*cy)
                    if dist > wheelSize/2 then
                        local angle = math.atan2(cy, cx)
                        cx = math.cos(angle) * wheelSize/2
                        cy = math.sin(angle) * wheelSize/2
                    end

                    wheelPicker.Position = UDim2.new(0.5, cx, 0.5, cy)

                    hue = (math.atan2(cy, cx) + math.pi) / (math.pi * 2)
                    hue = (hue + 1) % 1

                    square.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    updateFromHSV()
                end)

                -- Square dragging (S & V)
                local squareDragging = false
                square.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then squareDragging = true end
                end)
                square.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then squareDragging = false end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if not squareDragging then return end
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement then return end

                    local mp = i.Position - square.AbsolutePosition
                    sat = math.clamp(mp.X / wheelSize, 0, 1)
                    val = 1 - math.clamp(mp.Y / wheelSize, 0, 1)

                    squarePicker.Position = UDim2.new(0, sat*wheelSize, 0, (1-val)*wheelSize)
                    updateFromHSV()
                end)

                -- Hue slider
                local hueDragging = false
                hueSlider.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end
                end)
                hueSlider.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if not hueDragging then return end
                    local relY = math.clamp((i.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                    hue = relY
                    hueMarker.Position = UDim2.new(0.5,0,0, relY * hueSlider.AbsoluteSize.Y)
                    square.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    updateFromHSV()
                end)

                -- Alpha slider
                local alphaDragging = false
                alphaSlider.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = true end
                end)
                alphaSlider.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = false end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if not alphaDragging then return end
                    local relX = math.clamp((i.Position.X - alphaSlider.AbsolutePosition.X) / alphaSlider.AbsoluteSize.X, 0, 1)
                    alpha = 1 - relX
                    alphaMarker.Position = UDim2.new(0, relX * alphaSlider.AbsoluteSize.X, 0.5, 0)
                    updateFromHSV()
                end)

                -- Toggle open/close
                btn.MouseButton1Click:Connect(function()
                    cp.Open = not cp.Open
                    local h = cp.Open and (wheelSize + 50) or 22
                    Tween(container, {Size = UDim2.new(1,0,0,h)}, 0.18)
                end)

                -- Initialize
                local r,g,b = cp.Value.R, cp.Value.G, cp.Value.B
                hue, sat, val = Color3.toHSV(cp.Value)
                alpha = cp.Transparency

                wheelPicker.Position = UDim2.new(0.5, math.cos((hue*math.pi*2)-math.pi)*wheelSize/2, 0.5, math.sin((hue*math.pi*2)-math.pi)*wheelSize/2)
                squarePicker.Position = UDim2.new(0, sat*wheelSize, 0, (1-val)*wheelSize)
                hueMarker.Position = UDim2.new(0.5,0,0, hue * hueSlider.AbsoluteSize.Y)
                alphaMarker.Position = UDim2.new(0, (1-alpha) * alphaSlider.AbsoluteSize.X, 0.5, 0)
                square.BackgroundColor3 = Color3.fromHSV(hue,1,1)

                updateFromHSV()

                return cp
            end

            -- You can keep your other controls (Toggle, Slider, Dropdown, etc.) the same
            -- ... (add them back here if needed)

            return Section
        end

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.defer(function() Window:SelectTab(Tab) end)
        end

        return Tab
    end

    function Window:SelectTab(tab)
        for _, t in ipairs(Window.Tabs) do
            local active = t == tab
            Tween(t.Button,    {TextColor3 = active and Theme.Text or Theme.TextDark}, 0.15)
            Tween(t.Indicator, {BackgroundTransparency = active and 0 or 1}, 0.15)
            t.Content.Visible = active
        end
        Window.CurrentTab = tab
    end

    -- Settings tab (example)
    task.defer(function()
        local st = Window:CreateTab({Name = "Settings"})

        local sec = st:CreateSection({Name = "Appearance", Side = "Left"})

        sec:AddColorPicker({
            Name = "Accent Color",
            Default = Theme.Accent,
            Callback = function(c)
                Theme.Accent = c
                Theme.SliderFill = c
                Theme.ToggleActive = c
                -- You can add more live updates here if wanted
            end
        })
    end)

    return Window
end

return Phantom
