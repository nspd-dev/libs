--[[
    Phantom UI Library v2.3
    FIXED: Tab positioning - tabs now fully contained within menu frame
    Theme: Dark Mode with Pink Accents
]]

local Phantom = {}
Phantom.__index = Phantom

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    BackgroundSecondary = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(50, 50, 50),
    BorderDark = Color3.fromRGB(35, 35, 35),
    Header = Color3.fromRGB(18, 18, 18),
    Accent = Color3.fromRGB(255, 105, 180),
    AccentDark = Color3.fromRGB(180, 75, 130),
    Text = Color3.fromRGB(220, 220, 220),
    TextDark = Color3.fromRGB(150, 150, 150),
    SliderFill = Color3.fromRGB(255, 105, 180),
    ToggleActive = Color3.fromRGB(255, 105, 180),
}

-- Config Storage
local ConfigSystem = {
    CurrentConfig = "default",
    Configs = {},
}

-- Utility Functions
local function CreateElement(class, properties)
    local element = Instance.new(class)
    for prop, value in pairs(properties) do
        element[prop] = value
    end
    return element
end

local function Tween(object, properties, duration)
    duration = duration or 0.2
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Main Library
function Phantom:CreateWindow(config)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.Flags = {}
    Window.UIVisible = true
    Window.MenuBind = Enum.KeyCode.RightShift
    
    -- Create ScreenGui
    local ScreenGui = CreateElement("ScreenGui", {
        Name = "PhantomUI_" .. math.random(1000, 9999),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    
    -- Try to parent to CoreGui, fallback to PlayerGui
    local success = pcall(function()
        ScreenGui.Parent = CoreGui
    end)
    if not success then
        ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
    end
    
    -- Main Frame - FIXED: ClipsDescendants = true to contain tabs
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 700, 0, 520),
        Position = UDim2.new(0.5, -350, 0.5, -260),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border,
        ClipsDescendants = true,  -- CHANGED: true instead of false
        Parent = ScreenGui,
    })
    
    -- Inset border effect
    local InnerBorder = CreateElement("Frame", {
        Name = "InnerBorder",
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundTransparency = 1,
        BorderSizePixel = 1,
        BorderColor3 = Theme.BorderDark,
        ZIndex = 2,
        Parent = MainFrame,
    })
    
    -- Title Bar
    local TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = MainFrame,
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Phantom",
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code,
        TextSize = 13,
        ZIndex = 3,
        Parent = TitleBar,
    })
    
    local TitleBarBorder = CreateElement("Frame", {
        Name = "Border",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TitleBar,
    })
    
    -- Tab Container - FIXED: ClipsDescendants = true to prevent overflow
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 0, 26),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        ClipsDescendants = true,  -- CHANGED: true instead of false
        ZIndex = 3,
        Parent = MainFrame,
    })
    
    local TabContainerPadding = CreateElement("UIPadding", {
        PaddingLeft = UDim.new(0, 4),
        PaddingTop = UDim.new(0, 2),
        PaddingRight = UDim.new(0, 4),  -- ADDED: right padding
        Parent = TabContainer,
    })
    
    local TabLayout = CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabContainer,
    })
    
    local TabBorder = CreateElement("Frame", {
        Name = "Border",
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = TabContainer,
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -54),
        Position = UDim2.new(0, 0, 0, 54),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 1,
        Parent = MainFrame,
    })
    
    -- Make draggable
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
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Menu Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.MenuBind then
            Window:ToggleUI()
        end
    end)
    
    -- ToggleUI Method
    function Window:ToggleUI()
        Window.UIVisible = not Window.UIVisible
        MainFrame.Visible = Window.UIVisible
    end
    
    -- CreateTab Method
    function Window:CreateTab(config)
        local Tab = {}
        Tab.Sections = {Left = {}, Right = {}}
        Tab.Name = config.Name or "Tab"
        Tab.LayoutOrder = #Window.Tabs + 1
        
        -- Tab Button
        local TabButton = CreateElement("TextButton", {
            Name = "TabButton_" .. Tab.Name,
            Size = UDim2.new(0, 75, 0, 22),
            BackgroundTransparency = 1,
            Text = Tab.Name,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Code,
            TextSize = 11,
            AutoButtonColor = false,
            LayoutOrder = Tab.LayoutOrder,
            ZIndex = 4,
            Parent = TabContainer,
        })
        
        local TabIndicator = CreateElement("Frame", {
            Name = "Indicator",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            ZIndex = 4,
            Parent = TabButton,
        })
        
        -- Tab Content
        local TabContent = CreateElement("Frame", {
            Name = "TabContent_" .. Tab.Name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ZIndex = 1,
            Parent = ContentContainer,
        })
        
        -- ScrollingFrame for Left Column
        local LeftScroll = CreateElement("ScrollingFrame", {
            Name = "LeftScroll",
            Size = UDim2.new(0.5, -8, 1, -8),
            Position = UDim2.new(0, 6, 0, 6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 1,
            Parent = TabContent,
        })
        
        local LeftLayout = CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftScroll,
        })
        
        -- ScrollingFrame for Right Column
        local RightScroll = CreateElement("ScrollingFrame", {
            Name = "RightScroll",
            Size = UDim2.new(0.5, -8, 1, -8),
            Position = UDim2.new(0.5, 2, 0, 6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ZIndex = 1,
            Parent = TabContent,
        })
        
        local RightLayout = CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RightScroll,
        })
        
        Tab.LeftScroll = LeftScroll
        Tab.RightScroll = RightScroll
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Indicator = TabIndicator
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        function Tab:CreateSection(config)
            local Section = {}
            Section.Name = config.Name or "Section"
            Section.Side = config.Side or "Left"
            Section.LayoutOrder = config.Side == "Left" and #Tab.Sections.Left + 1 or #Tab.Sections.Right + 1
            
            local Parent = Section.Side == "Left" and LeftScroll or RightScroll
            
            -- Section Frame with inset border
            local SectionFrame = CreateElement("Frame", {
                Name = "Section_" .. Section.Name,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.BackgroundSecondary,
                BorderSizePixel = 1,
                BorderColor3 = Theme.Border,
                LayoutOrder = Section.LayoutOrder,
                Parent = Parent,
            })
            
            -- Inner border for inset effect
            local SectionInnerBorder = CreateElement("Frame", {
                Name = "InnerBorder",
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundTransparency = 1,
                BorderSizePixel = 1,
                BorderColor3 = Theme.BorderDark,
                Parent = SectionFrame,
            })
            
            -- Section Header
            local SectionHeader = CreateElement("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            })
            
            local SectionTitle = CreateElement("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -12, 1, 0),
                Position = UDim2.new(0, 6, 0, 0),
                BackgroundTransparency = 1,
                Text = Section.Name,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Code,
                TextSize = 11,
                Parent = SectionHeader,
            })
            
            local HeaderBorder = CreateElement("Frame", {
                Name = "Border",
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Theme.BorderDark,
                BorderSizePixel = 0,
                Parent = SectionHeader,
            })
            
            -- Section Content
            local SectionContent = CreateElement("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 24),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            })
            
            local ContentLayout = CreateElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 3),
                Parent = SectionContent,
            })
            
            local ContentPadding = CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 6),
                PaddingRight = UDim.new(0, 6),
                PaddingTop = UDim.new(0, 4),
                PaddingBottom = UDim.new(0, 6),
                Parent = SectionContent,
            })
            
            -- AddToggle
            function Section:AddToggle(config)
                local Toggle = {}
                Toggle.Name = config.Name or "Toggle"
                Toggle.Flag = config.Flag
                Toggle.Default = config.Default or false
                Toggle.Callback = config.Callback or function() end
                Toggle.Value = Toggle.Default
                
                local ToggleFrame = CreateElement("Frame", {
                    Name = "Toggle",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local ToggleBox = CreateElement("Frame", {
                    Name = "Box",
                    Size = UDim2.new(0, 11, 0, 11),
                    Position = UDim2.new(0, 0, 0.5, -5.5),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Parent = ToggleFrame,
                })
                
                local ToggleIndicator = CreateElement("Frame", {
                    Name = "Indicator",
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundColor3 = Theme.ToggleActive,
                    BorderSizePixel = 0,
                    BackgroundTransparency = 1,
                    Parent = ToggleBox,
                })
                
                local ToggleLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -18, 1, 0),
                    Position = UDim2.new(0, 16, 0, 0),
                    BackgroundTransparency = 1,
                    Text = Toggle.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = ToggleFrame,
                })
                
                local ToggleButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = ToggleFrame,
                })
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    Tween(ToggleIndicator, {BackgroundTransparency = value and 0 or 1}, 0.12)
                    if Toggle.Flag then
                        Window.Flags[Toggle.Flag] = value
                    end
                    Toggle.Callback(value)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle:Set(not Toggle.Value)
                end)
                
                Toggle:Set(Toggle.Default)
                return Toggle
            end
            
            -- AddSlider
            function Section:AddSlider(config)
                local Slider = {}
                Slider.Name = config.Name or "Slider"
                Slider.Min = config.Min or 0
                Slider.Max = config.Max or 100
                Slider.Default = config.Default or Slider.Min
                Slider.Flag = config.Flag
                Slider.Callback = config.Callback or function() end
                Slider.Value = Slider.Default
                
                local SliderFrame = CreateElement("Frame", {
                    Name = "Slider",
                    Size = UDim2.new(1, 0, 0, 32),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local SliderLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(0.65, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = Slider.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = SliderFrame,
                })
                
                local SliderValue = CreateElement("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0.35, 0, 0, 14),
                    Position = UDim2.new(0.65, 0, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(Slider.Value) .. "/" .. tostring(Slider.Max),
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = SliderFrame,
                })
                
                local SliderBg = CreateElement("Frame", {
                    Name = "Background",
                    Size = UDim2.new(1, 0, 0, 3),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Theme.BorderDark,
                    BorderSizePixel = 0,
                    Parent = SliderFrame,
                })
                
                local SliderFill = CreateElement("Frame", {
                    Name = "Fill",
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Parent = SliderBg,
                })
                
                local SliderButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = SliderFrame,
                })
                
                local dragging = false
                
                function Slider:Set(value)
                    value = math.clamp(value, Slider.Min, Slider.Max)
                    value = math.floor(value + 0.5)
                    Slider.Value = value
                    
                    local percent = (value - Slider.Min) / (Slider.Max - Slider.Min)
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.08)
                    SliderValue.Text = string.format("%d/%d", value, Slider.Max)
                    
                    if Slider.Flag then
                        Window.Flags[Slider.Flag] = value
                    end
                    Slider.Callback(value)
                end
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                    local value = Slider.Min + (Slider.Max - Slider.Min) * pos
                    Slider:Set(value)
                end
                
                SliderButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                Slider:Set(Slider.Default)
                return Slider
            end
            
            -- AddDropdown
            function Section:AddDropdown(config)
                local Dropdown = {}
                Dropdown.Name = config.Name or "Dropdown"
                Dropdown.Options = config.Options or {}
                Dropdown.Default = config.Default or (Dropdown.Options[1] or "None")
                Dropdown.Flag = config.Flag
                Dropdown.Callback = config.Callback or function() end
                Dropdown.Value = Dropdown.Default
                Dropdown.Open = false
                
                local DropdownFrame = CreateElement("Frame", {
                    Name = "Dropdown",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = SectionContent,
                })
                
                local DropdownButton = CreateElement("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.BorderDark,
                    Text = "",
                    Parent = DropdownFrame,
                })
                
                local DropdownLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = Dropdown.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = DropdownButton,
                })
                
                local DropdownValue = CreateElement("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(0, 60, 1, 0),
                    Position = UDim2.new(1, -85, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(Dropdown.Value),
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.Code,
                    TextSize = 9,
                    Parent = DropdownButton,
                })
                
                local DropdownIcon = CreateElement("TextLabel", {
                    Name = "Icon",
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -20, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "+",
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 13,
                    Parent = DropdownButton,
                })
                
                local DropdownContent = CreateElement("Frame", {
                    Name = "Content",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Background,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.BorderDark,
                    Parent = DropdownFrame,
                })
                
                local DropdownLayout = CreateElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownContent,
                })
                
                function Dropdown:Set(value)
                    Dropdown.Value = value
                    DropdownValue.Text = tostring(value)
                    if Dropdown.Flag then
                        Window.Flags[Dropdown.Flag] = value
                    end
                    Dropdown.Callback(value)
                end
                
                function Dropdown:Toggle()
                    Dropdown.Open = not Dropdown.Open
                    local targetSize = Dropdown.Open and (20 + math.min(#Dropdown.Options, 6) * 18) or 20
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.15)
                    DropdownIcon.Text = Dropdown.Open and "-" or "+"
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                for i, option in ipairs(Dropdown.Options) do
                    local OptionButton = CreateElement("TextButton", {
                        Name = "Option",
                        Size = UDim2.new(1, 0, 0, 18),
                        BackgroundColor3 = Theme.BackgroundSecondary,
                        BorderSizePixel = 0,
                        Text = "  " .. tostring(option),
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.Code,
                        TextSize = 9,
                        LayoutOrder = i,
                        Parent = DropdownContent,
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Theme.Header}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Theme.BackgroundSecondary}, 0.1)
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown:Set(option)
                        Dropdown:Toggle()
                    end)
                end
                
                Dropdown:Set(Dropdown.Default)
                return Dropdown
            end
            
            -- AddKeybind
            function Section:AddKeybind(config)
                local Keybind = {}
                Keybind.Name = config.Name or "Keybind"
                Keybind.Default = config.Default or Enum.KeyCode.Unknown
                Keybind.Flag = config.Flag
                Keybind.Callback = config.Callback or function() end
                Keybind.Value = Keybind.Default
                Keybind.Listening = false
                
                local KeybindFrame = CreateElement("Frame", {
                    Name = "Keybind",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local KeybindLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -48, 1, 0),
                    BackgroundTransparency = 1,
                    Text = Keybind.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = KeybindFrame,
                })
                
                local KeybindButton = CreateElement("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(0, 44, 0, 16),
                    Position = UDim2.new(1, -44, 0, 1),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.BorderDark,
                    Text = Keybind.Value.Name:sub(1, 1),
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 9,
                    Parent = KeybindFrame,
                })
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name:sub(1, 1)
                    if Keybind.Flag then
                        Window.Flags[Keybind.Flag] = key
                    end
                end
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.TextColor3 = Theme.Text
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind:Set(input.KeyCode)
                            Keybind.Listening = false
                            KeybindButton.TextColor3 = Theme.Accent
                        end
                    elseif input.KeyCode == Keybind.Value and not gameProcessed then
                        Keybind.Callback()
                    end
                end)
                
                Keybind:Set(Keybind.Default)
                return Keybind
            end
            
            -- AddButton
            function Section:AddButton(config)
                local Button = {}
                Button.Name = config.Name or "Button"
                Button.Callback = config.Callback or function() end
                
                local ButtonFrame = CreateElement("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.BorderDark,
                    Text = Button.Name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = SectionContent,
                })
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Border}, 0.1)
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Theme.Header}, 0.1)
                end)
                
                ButtonFrame.MouseButton1Click:Connect(function()
                    Button.Callback()
                end)
                
                return Button
            end
            
            -- AddLabel
            function Section:AddLabel(config)
                local Label = {}
                Label.Text = config.Text or "Label"
                
                local LabelFrame = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 14),
                    BackgroundTransparency = 1,
                    Text = Label.Text,
                    TextColor3 = Theme.TextDark,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = SectionContent,
                })
                
                function Label:Set(text)
                    Label.Text = text
                    LabelFrame.Text = text
                end
                
                return Label
            end
            
            -- AddColorPicker (Full RGB + Transparency)
            function Section:AddColorPicker(config)
                local ColorPicker = {}
                ColorPicker.Name = config.Name or "Color"
                ColorPicker.Default = config.Default or Color3.fromRGB(255, 105, 180)
                ColorPicker.DefaultTransparency = config.DefaultTransparency or 0
                ColorPicker.Flag = config.Flag
                ColorPicker.Callback = config.Callback or function() end
                ColorPicker.Value = ColorPicker.Default
                ColorPicker.Transparency = ColorPicker.DefaultTransparency
                ColorPicker.Open = false
                
                local PickerFrame = CreateElement("Frame", {
                    Name = "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = SectionContent,
                })
                
                local PickerButton = CreateElement("TextButton", {
                    Name = "Button",
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = PickerFrame,
                })
                
                local PickerLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -24, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ColorPicker.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = PickerButton,
                })
                
                local ColorDisplay = CreateElement("Frame", {
                    Name = "Display",
                    Size = UDim2.new(0, 20, 0, 14),
                    Position = UDim2.new(1, -20, 0, 2),
                    BackgroundColor3 = ColorPicker.Value,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    BackgroundTransparency = ColorPicker.Transparency,
                    Parent = PickerButton,
                })
                
                -- Expanded Picker Content
                local PickerContent = CreateElement("Frame", {
                    Name = "PickerContent",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 18),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.BorderDark,
                    Parent = PickerFrame,
                })
                
                local ContentPadding = CreateElement("UIPadding", {
                    PaddingLeft = UDim.new(0, 6),
                    PaddingRight = UDim.new(0, 6),
                    PaddingTop = UDim.new(0, 6),
                    PaddingBottom = UDim.new(0, 6),
                    Parent = PickerContent,
                })
                
                -- RGB Sliders
                local sliders = {}
                local sliderNames = {"R", "G", "B"}
                local startColor = {
                    math.floor(ColorPicker.Value.R * 255),
                    math.floor(ColorPicker.Value.G * 255),
                    math.floor(ColorPicker.Value.B * 255)
                }
                
                for i, name in ipairs(sliderNames) do
                    local SliderFrame = CreateElement("Frame", {
                        Name = name .. "Slider",
                        Size = UDim2.new(1, 0, 0, 28),
                        Position = UDim2.new(0, 0, 0, (i-1) * 30),
                        BackgroundTransparency = 1,
                        Parent = PickerContent,
                    })
                    
                    local SliderLabel = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 12, 0, 14),
                        BackgroundTransparency = 1,
                        Text = name,
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.Code,
                        TextSize = 10,
                        Parent = SliderFrame,
                    })
                    
                    local SliderValue = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 30, 0, 14),
                        Position = UDim2.new(1, -30, 0, 0),
                        BackgroundTransparency = 1,
                        Text = tostring(startColor[i]),
                        TextColor3 = Theme.Accent,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Font = Enum.Font.Code,
                        TextSize = 9,
                        Parent = SliderFrame,
                    })
                    
                    local SliderBg = CreateElement("Frame", {
                        Size = UDim2.new(1, -45, 0, 3),
                        Position = UDim2.new(0, 15, 0, 16),
                        BackgroundColor3 = Theme.BorderDark,
                        BorderSizePixel = 0,
                        Parent = SliderFrame,
                    })
                    
                    local SliderFill = CreateElement("Frame", {
                        Size = UDim2.new(startColor[i] / 255, 0, 1, 0),
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        Parent = SliderBg,
                    })
                    
                    local SliderButton = CreateElement("TextButton", {
                        Size = UDim2.new(1, -45, 0, 12),
                        Position = UDim2.new(0, 15, 0, 12),
                        BackgroundTransparency = 1,
                        Text = "",
                        Parent = SliderFrame,
                    })
                    
                    sliders[i] = {
                        Frame = SliderFrame,
                        Value = startColor[i],
                        Fill = SliderFill,
                        Label = SliderValue,
                        Background = SliderBg,
                        Button = SliderButton,
                    }
                end
                
                -- Transparency Slider
                local TransFrame = CreateElement("Frame", {
                    Name = "TransSlider",
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 90),
                    BackgroundTransparency = 1,
                    Parent = PickerContent,
                })
                
                local TransLabel = CreateElement("TextLabel", {
                    Size = UDim2.new(0, 18, 0, 14),
                    BackgroundTransparency = 1,
                    Text = "A",
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = TransFrame,
                })
                
                local TransValue = CreateElement("TextLabel", {
                    Size = UDim2.new(0, 30, 0, 14),
                    Position = UDim2.new(1, -30, 0, 0),
                    BackgroundTransparency = 1,
                    Text = tostring(math.floor((1 - ColorPicker.Transparency) * 100)) .. "%",
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.Code,
                    TextSize = 9,
                    Parent = TransFrame,
                })
                
                local TransBg = CreateElement("Frame", {
                    Size = UDim2.new(1, -45, 0, 3),
                    Position = UDim2.new(0, 15, 0, 16),
                    BackgroundColor3 = Theme.BorderDark,
                    BorderSizePixel = 0,
                    Parent = TransFrame,
                })
                
                local TransFill = CreateElement("Frame", {
                    Size = UDim2.new(1 - ColorPicker.Transparency, 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = TransBg,
                })
                
                local TransButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, -45, 0, 12),
                    Position = UDim2.new(0, 15, 0, 12),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = TransFrame,
                })
                
                local function UpdateColor()
                    local r = sliders[1].Value / 255
                    local g = sliders[2].Value / 255
                    local b = sliders[3].Value / 255
                    local color = Color3.new(r, g, b)
                    
                    ColorPicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    ColorDisplay.BackgroundTransparency = ColorPicker.Transparency
                    
                    if ColorPicker.Flag then
                        Window.Flags[ColorPicker.Flag] = color
                        Window.Flags[ColorPicker.Flag .. "_transparency"] = ColorPicker.Transparency
                    end
                    
                    ColorPicker.Callback(color, ColorPicker.Transparency)
                end
                
                -- RGB Slider Logic
                for i, slider in ipairs(sliders) do
                    local dragging = false
                    
                    local function UpdateSlider(input)
                        local pos = math.clamp((input.Position.X - slider.Background.AbsolutePosition.X) / slider.Background.AbsoluteSize.X, 0, 1)
                        local value = math.floor(pos * 255)
                        slider.Value = value
                        slider.Label.Text = tostring(value)
                        Tween(slider.Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                        UpdateColor()
                    end
                    
                    slider.Button.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            UpdateSlider(input)
                        end
                    end)
                    
                    slider.Button.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)
                    
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input)
                        end
                    end)
                end
                
                -- Transparency Slider Logic
                local transDragging = false
                
                local function UpdateTransparency(input)
                    local pos = math.clamp((input.Position.X - TransBg.AbsolutePosition.X) / TransBg.AbsoluteSize.X, 0, 1)
                    ColorPicker.Transparency = 1 - pos
                    TransValue.Text = tostring(math.floor(pos * 100)) .. "%"
                    Tween(TransFill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.05)
                    UpdateColor()
                end
                
                TransButton.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        transDragging = true
                        UpdateTransparency(input)
                    end
                end)
                
                TransButton.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        transDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if transDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateTransparency(input)
                    end
                end)
                
                -- Toggle Picker
                PickerButton.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    local targetSize = ColorPicker.Open and 142 or 18
                    Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2)
                end)
                
                UpdateColor()
                return ColorPicker
            end
            
            table.insert(Tab.Sections[Section.Side], Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        -- Auto-select first tab
        if #Window.Tabs == 1 then
            task.defer(function()
                Window:SelectTab(Tab)
            end)
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        for _, t in ipairs(Window.Tabs) do
            if t == tab then
                Tween(t.Button, {TextColor3 = Theme.Text}, 0.15)
                Tween(t.Indicator, {BackgroundTransparency = 0}, 0.15)
                t.Content.Visible = true
            else
                Tween(t.Button, {TextColor3 = Theme.TextDark}, 0.15)
                Tween(t.Indicator, {BackgroundTransparency = 1}, 0.15)
                t.Content.Visible = false
            end
        end
        
        Window.CurrentTab = tab
    end
    
    -- Save/Load Config Functions
    function Window:SaveConfig(name)
        name = name or ConfigSystem.CurrentConfig
        local config = {}
        
        for flag, value in pairs(Window.Flags) do
            if type(value) == "Color3" then
                config[flag] = {value.R, value.G, value.B}
            elseif type(value) == "EnumItem" then
                config[flag] = tostring(value)
            else
                config[flag] = value
            end
        end
        
        ConfigSystem.Configs[name] = config
        local success = pcall(function()
            writefile("phantom_" .. name .. ".json", HttpService:JSONEncode(config))
        end)
        return success
    end
    
    function Window:LoadConfig(name)
        name = name or ConfigSystem.CurrentConfig
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("phantom_" .. name .. ".json"))
        end)
        
        if success then
            for flag, value in pairs(data) do
                Window.Flags[flag] = value
            end
            return true
        end
        return false
    end
    
    function Window:GetConfigs()
        local configs = {"default"}
        local success, files = pcall(function()
            return listfiles(".")
        end)
        
        if success then
            for _, file in ipairs(files) do
                local name = file:match("phantom_(.+)%.json")
                if name and name ~= "default" then
                    table.insert(configs, name)
                end
            end
        end
        
        return configs
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Create Settings Tab
    task.defer(function()
        local SettingsTab = Window:CreateTab({Name = "Settings"})
        
        local ConfigSection = SettingsTab:CreateSection({Name = "Configuration", Side = "Left"})
        
        local configDropdown = ConfigSection:AddDropdown({
            Name = "Config",
            Options = {"default"},
            Default = "default",
            Flag = "selected_config"
        })
        
        ConfigSection:AddButton({
            Name = "Save Config",
            Callback = function()
                local configName = Window.Flags["selected_config"] or "default"
                if Window:SaveConfig(configName) then
                    print("[Phantom] Config saved:", configName)
                else
                    print("[Phantom] Failed to save config")
                end
            end
        })
        
        ConfigSection:AddButton({
            Name = "Load Config",
            Callback = function()
                local configName = Window.Flags["selected_config"] or "default"
                if Window:LoadConfig(configName) then
                    print("[Phantom] Config loaded:", configName)
                else
                    print("[Phantom] Failed to load config")
                end
            end
        })
        
        ConfigSection:AddButton({
            Name = "Refresh Configs",
            Callback = function()
                print("[Phantom] Configs refreshed")
            end
        })
        
        local MenuSection = SettingsTab:CreateSection({Name = "Menu", Side = "Left"})
        
        MenuSection:AddKeybind({
            Name = "Menu Bind",
            Default = Enum.KeyCode.RightShift,
            Callback = function()
                -- This will be updated when changed
            end,
            Flag = "menu_keybind"
        })
        
        MenuSection:AddLabel({Text = "Press Right Shift to toggle"})
        
        MenuSection:AddButton({
            Name = "Toggle UI",
            Callback = function()
                Window:ToggleUI()
            end
        })
        
        local ThemeSection = SettingsTab:CreateSection({Name = "Theme", Side = "Right"})
        
        ThemeSection:AddColorPicker({
            Name = "Accent Color",
            Default = Theme.Accent,
            DefaultTransparency = 0,
            Flag = "accent_color",
            Callback = function(color, transparency)
                Theme.Accent = color
                Theme.SliderFill = color
                Theme.ToggleActive = color
                print("[Phantom] Accent color changed")
            end
        })
        
        ThemeSection:AddLabel({Text = "Customize UI appearance"})
    end)
    
    return Window
end

return Phantom
