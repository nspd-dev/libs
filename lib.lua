--[[
    Phantom UI Library
    A sleek, modular UI library for Roblox
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

-- Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
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
        Parent = ScreenGui,
    })
    
    -- Title Bar
    local TitleBar = CreateElement("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Parent = MainFrame,
    })
    
    local TitleLabel = CreateElement("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 1, 0),
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
        Parent = MainFrame,
    })
    
    local TabLayout = CreateElement("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = TabContainer,
    })
    
    -- Content Container
    local ContentContainer = CreateElement("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, 0, 1, -55),
        Position = UDim2.new(0, 0, 0, 55),
        BackgroundTransparency = 1,
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
    
    -- CreateTab Method
    function Window:CreateTab(config)
        local Tab = {}
        Tab.Sections = {Left = {}, Right = {}}
        Tab.Name = config.Name or "Tab"
        
        -- Tab Button
        local TabButton = CreateElement("TextButton", {
            Name = "TabButton",
            Size = UDim2.new(0, 80, 1, 0),
            BackgroundColor3 = Theme.Header,
            BorderSizePixel = 0,
            Text = Tab.Name,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Code,
            TextSize = 12,
            AutoButtonColor = false,
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
            Name = "TabContent",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = ContentContainer,
        })
        
        -- Left and Right Columns
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
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        function Tab:CreateSection(config)
            local Section = {}
            Section.Name = config.Name or "Section"
            Section.Side = config.Side or "Left"
            
            local Parent = Section.Side == "Left" and LeftColumn or RightColumn
            
            -- Section Frame
            local SectionFrame = CreateElement("Frame", {
                Name = "Section",
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 1,
                BorderColor3 = Theme.Border,
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
                Dropdown.Default = config.Default or Dropdown.Options[1]
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
                    local targetSize = Dropdown.Open and (20 + #Dropdown.Options * 20) or 20
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, targetSize)}, 0.2)
                    DropdownIcon.Text = Dropdown.Open and "-" or "+"
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown:Toggle()
                end)
                
                for _, option in ipairs(Dropdown.Options) do
                    local OptionButton = CreateElement("TextButton", {
                        Name = "Option",
                        Size = UDim2.new(1, 0, 0, 20),
                        BackgroundColor3 = Theme.Background,
                        BorderSizePixel = 0,
                        Text = tostring(option),
                        TextColor3 = Theme.Text,
                        Font = Enum.Font.Code,
                        TextSize = 10,
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
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind:Set(input.KeyCode)
                            Keybind.Listening = false
                            KeybindButton.TextColor3 = Theme.Accent
                        end
                    elseif input.KeyCode == Keybind.Value then
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
            
            table.insert(Tab.Sections[Section.Side], Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        for _, t in ipairs(Window.Tabs) do
            local button = TabContainer:FindFirstChild("TabButton")
            for _, btn in ipairs(TabContainer:GetChildren()) do
                if btn:IsA("TextButton") and btn.Text == t.Name then
                    local indicator = btn:FindFirstChild("Indicator")
                    if t == tab then
                        Tween(btn, {TextColor3 = Theme.Text})
                        if indicator then
                            Tween(indicator, {BackgroundTransparency = 0})
                        end
                    else
                        Tween(btn, {TextColor3 = Theme.TextDark})
                        if indicator then
                            Tween(indicator, {BackgroundTransparency = 1})
                        end
                    end
                end
            end
            
            local content = ContentContainer:FindFirstChild("TabContent")
            for _, cnt in ipairs(ContentContainer:GetChildren()) do
                if cnt.Name == "TabContent" then
                    cnt.Visible = false
                end
            end
        end
        
        for _, cnt in ipairs(ContentContainer:GetChildren()) do
            if cnt.Name == "TabContent" then
                local leftCol = cnt:FindFirstChild("LeftColumn")
                if leftCol and #leftCol:GetChildren() > 1 then
                    for _, section in ipairs(leftCol:GetChildren()) do
                        if section:IsA("Frame") and section.Name == "Section" then
                            local header = section:FindFirstChild("Header")
                            if header then
                                local title = header:FindFirstChild("Title")
                                if title and title.Text == tab.Sections.Left[1].Name then
                                    cnt.Visible = true
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
        
        Window.CurrentTab = tab
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return Phantom
