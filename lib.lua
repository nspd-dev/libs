--[[
    Phantom UI Library v3.0
    Complete remake with properly centered tabs
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
    Border = Color3.fromRGB(45, 45, 45),
    Header = Color3.fromRGB(20, 20, 20),
    Accent = Color3.fromRGB(255, 105, 180),
    AccentDark = Color3.fromRGB(180, 75, 130),
    Text = Color3.fromRGB(220, 220, 220),
    TextDark = Color3.fromRGB(150, 150, 150),
    SliderFill = Color3.fromRGB(255, 105, 180),
    ToggleActive = Color3.fromRGB(255, 105, 180),
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
    
    -- Main Frame
    local MainFrame = CreateElement("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 650, 0, 500),
        Position = UDim2.new(0.5, -325, 0.5, -250),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 1,
        BorderColor3 = Theme.Border,
        ClipsDescendants = true,
        Parent = ScreenGui,
    })
    
    -- Title Bar
    local TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Phantom",
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Code,
        TextSize = 14,
        Parent = TitleBar,
    })
    
    -- Tab Container
    local TabContainer = CreateElement("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame,
    })
    
    local TabLayout = CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = TabContainer,
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -55),
        Position = UDim2.new(0, 0, 0, 55),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
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
            Size = UDim2.new(0, 80, 1, 0),
            BackgroundColor3 = Theme.Header,
            BorderSizePixel = 0,
            Text = Tab.Name,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Code,
            TextSize = 12,
            AutoButtonColor = false,
            LayoutOrder = Tab.LayoutOrder,
            Parent = TabContainer,
        })
        
        local TabIndicator = CreateElement("Frame", {
            Name = "Indicator",
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = TabButton,
        })
        
        -- Tab Content
        local TabContent = CreateElement("Frame", {
            Name = "TabContent_" .. Tab.Name,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentContainer,
        })
        
        -- Left Column
        local LeftColumn = CreateElement("Frame", {
            Name = "LeftColumn",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0, 5, 0, 0),
            BackgroundTransparency = 1,
            Parent = TabContent,
        })
        
        local LeftLayout = CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = LeftColumn,
        })
        
        -- Right Column
        local RightColumn = CreateElement("Frame", {
            Name = "RightColumn",
            Size = UDim2.new(0.5, -5, 1, 0),
            Position = UDim2.new(0.5, 0, 0, 0),
            BackgroundTransparency = 1,
            Parent = TabContent,
        })
        
        local RightLayout = CreateElement("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = RightColumn,
        })
        
        Tab.LeftColumn = LeftColumn
        Tab.RightColumn = RightColumn
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
            
            local Parent = Section.Side == "Left" and LeftColumn or RightColumn
            
            -- Section Frame
            local SectionFrame = CreateElement("Frame", {
                Name = "Section_" .. Section.Name,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 1,
                BorderColor3 = Theme.Border,
                LayoutOrder = Section.LayoutOrder,
                Parent = Parent,
            })
            
            -- Section Header
            local SectionHeader = CreateElement("Frame", {
                Name = "Header",
                Size = UDim2.new(1, 0, 0, 25),
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            })
            
            local SectionTitle = CreateElement("TextLabel", {
                Name = "Title",
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                Text = Section.Name,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Font = Enum.Font.Code,
                TextSize = 12,
                Parent = SectionHeader,
            })
            
            -- Section Content
            local SectionContent = CreateElement("Frame", {
                Name = "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 25),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = SectionFrame,
            })
            
            local ContentLayout = CreateElement("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4),
                Parent = SectionContent,
            })
            
            local ContentPadding = CreateElement("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
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
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local ToggleBox = CreateElement("Frame", {
                    Name = "Box",
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 0, 0.5, -6),
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
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 18, 0, 0),
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
                    Tween(ToggleIndicator, {BackgroundTransparency = value and 0 or 1}, 0.15)
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
                    Size = UDim2.new(1, 0, 0, 35),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local SliderLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, 0, 0, 15),
                    BackgroundTransparency = 1,
                    Text = Slider.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = SliderFrame,
                })
                
                local SliderBg = CreateElement("Frame", {
                    Name = "Background",
                    Size = UDim2.new(1, 0, 0, 4),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Border,
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
                
                local SliderValue = CreateElement("TextLabel", {
                    Name = "Value",
                    Size = UDim2.new(1, 0, 0, 12),
                    Position = UDim2.new(0, 0, 0, 23),
                    BackgroundTransparency = 1,
                    Text = tostring(Slider.Value),
                    TextColor3 = Theme.Accent,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Font = Enum.Font.Code,
                    TextSize = 10,
                    Parent = SliderFrame,
                })
                
                local SliderButton = CreateElement("TextButton", {
                    Size = UDim2.new(1, 0, 0, 15),
                    Position = UDim2.new(0, 0, 0, 15),
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
                    Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
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
                    BorderColor3 = Theme.Border,
                    Text = "",
                    Parent = DropdownFrame,
                })
                
                local DropdownLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -25, 1, 0),
                    Position = UDim2.new(0, 5, 0, 0),
                    BackgroundTransparency = 1,
                    Text = Dropdown.Name .. ": " .. tostring(Dropdown.Value),
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
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
                    TextSize = 14,
                    Parent = DropdownButton,
                })
                
                local DropdownContent = CreateElement("Frame", {
                    Name = "Content",
                    Size = UDim2.new(1, 0, 0, 0),
                    Position = UDim2.new(0, 0, 0, 20),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Parent = DropdownFrame,
                })
                
                local DropdownLayout = CreateElement("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = DropdownContent,
                })
                
                function Dropdown:Set(value)
                    Dropdown.Value = value
                    DropdownLabel.Text = Dropdown.Name .. ": " .. tostring(value)
                    if Dropdown.Flag then
                        Window.Flags[Dropdown.Flag] = value
                    end
                    Dropdown.Callback(value)
                end
                
                function Dropdown:Toggle()
                    Dropdown.Open = not Dropdown.Open
                    local targetSize = Dropdown.Open and (20 + math.min(#Dropdown.Options, 6) * 20) or 20
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2)
                    DropdownIcon.Text = Dropdown.Open and "-" or "+"
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                for i, option in ipairs(Dropdown.Options) do
                    local OptionButton = CreateElement("TextButton", {
                        Name = "Option",
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3 = Theme.Background,
                        BorderSizePixel = 0,
                        Text = tostring(option),
                        TextColor3 = Theme.Text,
                        Font = Enum.Font.Code,
                        TextSize = 10,
                        LayoutOrder = i,
                        Parent = DropdownContent,
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Theme.Header}, 0.1)
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        Tween(OptionButton, {BackgroundColor3 = Theme.Background}, 0.1)
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
                Keybind.Mode = config.Mode or "Toggle" -- Toggle or Hold
                
                local KeybindFrame = CreateElement("Frame", {
                    Name = "Keybind",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Parent = SectionContent,
                })
                
                local KeybindLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -50, 1, 0),
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
                    Size = UDim2.new(0, 45, 0, 18),
                    Position = UDim2.new(1, -45, 0, 1),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Text = Keybind.Value.Name,
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 9,
                    Parent = KeybindFrame,
                })
                
                function Keybind:Set(key)
                    Keybind.Value = key
                    KeybindButton.Text = key.Name
                    if Keybind.Flag then
                        Window.Flags[Keybind.Flag] = key
                    end
                end
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                    KeybindButton.TextColor3 = Theme.Text
                end)
                
                -- Global keybind listener
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind:Set(input.KeyCode)
                            Keybind.Listening = false
                            KeybindButton.TextColor3 = Theme.Accent
                        end
                    else
                        if input.KeyCode == Keybind.Value then
                            if Keybind.Mode == "Toggle" then
                                Keybind.Callback()
                            end
                        end
                    end
                end)
                
                -- Hold mode support
                if Keybind.Mode == "Hold" then
                    UserInputService.InputBegan:Connect(function(input)
                        if input.KeyCode == Keybind.Value and not Keybind.Listening then
                            Keybind.Callback(true)
                        end
                    end)
                    
                    UserInputService.InputEnded:Connect(function(input)
                        if input.KeyCode == Keybind.Value and not Keybind.Listening then
                            Keybind.Callback(false)
                        end
                    end)
                end
                
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
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Theme.Header,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Text = Button.Name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 11,
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
                    Size = UDim2.new(1, 0, 0, 15),
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
            
            -- AddColorPicker
            function Section:AddColorPicker(config)
                local ColorPicker = {}
                ColorPicker.Name = config.Name or "Color"
                ColorPicker.Default = config.Default or Color3.fromRGB(255, 105, 180)
                ColorPicker.Flag = config.Flag
                ColorPicker.Callback = config.Callback or function() end
                ColorPicker.Value = ColorPicker.Default
                ColorPicker.Open = false
                
                local PickerFrame = CreateElement("Frame", {
                    Name = "ColorPicker",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    ClipsDescendants = false,
                    Parent = SectionContent,
                })
                
                local PickerLabel = CreateElement("TextLabel", {
                    Name = "Label",
                    Size = UDim2.new(1, -28, 1, 0),
                    BackgroundTransparency = 1,
                    Text = ColorPicker.Name,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = PickerFrame,
                })
                
                local ColorDisplay = CreateElement("TextButton", {
                    Name = "Display",
                    Size = UDim2.new(0, 20, 0, 14),
                    Position = UDim2.new(1, -20, 0, 3),
                    BackgroundColor3 = ColorPicker.Value,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Text = "",
                    ZIndex = 5,
                    Parent = PickerFrame,
                })
                
                -- Color Picker Popup
                local PickerPopup = CreateElement("Frame", {
                    Name = "Popup",
                    Size = UDim2.new(0, 200, 0, 150),
                    Position = UDim2.new(1, 5, 0, 0),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    Visible = false,
                    ZIndex = 10,
                    Parent = PickerFrame,
                })
                
                local PopupPadding = CreateElement("UIPadding", {
                    PaddingLeft = UDim.new(0, 8),
                    PaddingRight = UDim.new(0, 8),
                    PaddingTop = UDim.new(0, 8),
                    PaddingBottom = UDim.new(0, 8),
                    Parent = PickerPopup,
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
                        Size = UDim2.new(1, 0, 0, 30),
                        Position = UDim2.new(0, 0, 0, (i-1) * 35),
                        BackgroundTransparency = 1,
                        ZIndex = 11,
                        Parent = PickerPopup,
                    })
                    
                    local SliderLabel = CreateElement("TextLabel", {
                        Size = UDim2.new(0, 12, 0, 14),
                        BackgroundTransparency = 1,
                        Text = name,
                        TextColor3 = Theme.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Font = Enum.Font.Code,
                        TextSize = 11,
                        ZIndex = 11,
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
                        TextSize = 10,
                        ZIndex = 11,
                        Parent = SliderFrame,
                    })
                    
                    local SliderBg = CreateElement("Frame", {
                        Size = UDim2.new(1, -45, 0, 4),
                        Position = UDim2.new(0, 18, 0, 18),
                        BackgroundColor3 = Theme.Border,
                        BorderSizePixel = 0,
                        ZIndex = 11,
                        Parent = SliderFrame,
                    })
                    
                    local SliderFill = CreateElement("Frame", {
                        Size = UDim2.new(startColor[i] / 255, 0, 1, 0),
                        BackgroundColor3 = Theme.Accent,
                        BorderSizePixel = 0,
                        ZIndex = 11,
                        Parent = SliderBg,
                    })
                    
                    local SliderButton = CreateElement("TextButton", {
                        Size = UDim2.new(1, -45, 0, 14),
                        Position = UDim2.new(0, 18, 0, 14),
                        BackgroundTransparency = 1,
                        Text = "",
                        ZIndex = 12,
                        Parent = SliderFrame,
                    })
                    
                    sliders[i] = {
                        Value = startColor[i],
                        Fill = SliderFill,
                        Label = SliderValue,
                        Background = SliderBg,
                        Button = SliderButton,
                    }
                end
                
                -- Preview box
                local PreviewBox = CreateElement("Frame", {
                    Size = UDim2.new(1, 0, 0, 30),
                    Position = UDim2.new(0, 0, 0, 110),
                    BackgroundColor3 = ColorPicker.Value,
                    BorderSizePixel = 1,
                    BorderColor3 = Theme.Border,
                    ZIndex = 11,
                    Parent = PickerPopup,
                })
                
                local function UpdateColor()
                    local r = sliders[1].Value / 255
                    local g = sliders[2].Value / 255
                    local b = sliders[3].Value / 255
                    local color = Color3.new(r, g, b)
                    
                    ColorPicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    PreviewBox.BackgroundColor3 = color
                    
                    if ColorPicker.Flag then
                        Window.Flags[ColorPicker.Flag] = color
                    end
                    
                    ColorPicker.Callback(color)
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
                
                -- Toggle popup
                ColorDisplay.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    PickerPopup.Visible = ColorPicker.Open
                end)
                
                -- Close when clicking outside
                UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        if ColorPicker.Open then
                            local mousePos = input.Position
                            local popupPos = PickerPopup.AbsolutePosition
                            local popupSize = PickerPopup.AbsoluteSize
                            
                            if mousePos.X < popupPos.X or mousePos.X > popupPos.X + popupSize.X or
                               mousePos.Y < popupPos.Y or mousePos.Y > popupPos.Y + popupSize.Y then
                                local displayPos = ColorDisplay.AbsolutePosition
                                local displaySize = ColorDisplay.AbsoluteSize
                                
                                if mousePos.X < displayPos.X or mousePos.X > displayPos.X + displaySize.X or
                                   mousePos.Y < displayPos.Y or mousePos.Y > displayPos.Y + displaySize.Y then
                                    ColorPicker.Open = false
                                    PickerPopup.Visible = false
                                end
                            end
                        end
                    end
                end)
                
                function ColorPicker:Set(color)
                    ColorPicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    PreviewBox.BackgroundColor3 = color
                    
                    -- Update sliders
                    sliders[1].Value = math.floor(color.R * 255)
                    sliders[2].Value = math.floor(color.G * 255)
                    sliders[3].Value = math.floor(color.B * 255)
                    
                    for i, slider in ipairs(sliders) do
                        slider.Label.Text = tostring(slider.Value)
                        slider.Fill.Size = UDim2.new(slider.Value / 255, 0, 1, 0)
                    end
                    
                    if ColorPicker.Flag then
                        Window.Flags[ColorPicker.Flag] = color
                    end
                    ColorPicker.Callback(color)
                end
                
                ColorPicker:Set(ColorPicker.Default)
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
        name = name or "default"
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
        
        local success = pcall(function()
            writefile("phantom_" .. name .. ".json", HttpService:JSONEncode(config))
        end)
        return success
    end
    
    function Window:LoadConfig(name)
        name = name or "default"
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
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Phantom
