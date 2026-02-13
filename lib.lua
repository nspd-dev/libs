--[[
    Phantom UI Library v2.4 – Full controls + modern color picker
    Tabs inside window, dark theme, pink accent
]]
local Phantom = {}
Phantom.__index = Phantom

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")

local Theme = {
    Background         = Color3.fromRGB(15,15,15),
    BackgroundSecondary= Color3.fromRGB(22,22,22),
    Border             = Color3.fromRGB(45,45,45),
    BorderDark         = Color3.fromRGB(32,32,32),
    Header             = Color3.fromRGB(18,18,18),
    Accent             = Color3.fromRGB(236, 94, 168), -- nice hot pink
    Text               = Color3.fromRGB(225,225,225),
    TextDark           = Color3.fromRGB(160,160,160),
}

local function elem(class, props)
    local i = Instance.new(class)
    for k,v in pairs(props or {}) do i[k] = v end
    return i
end

local function tween(obj, props, dur)
    dur = dur or 0.18
    local ti = TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, ti, props)
    t:Play()
    return t
end

function Phantom:CreateWindow(cfg)
    local win = setmetatable({}, Phantom)
    win.Tabs       = {}
    win.Flags      = {}
    win.UIVisible  = true
    win.MenuKey    = Enum.KeyCode.RightShift

    local sg = elem("ScreenGui", {
        Name = "Phantom_"..math.random(10000,99999),
        ResetOnSpawn = false,
        Parent = (function()
            local s,e = pcall(function() return CoreGui end)
            return s and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
        end)()
    })

    local main = elem("Frame", {
        Name = "Main",
        Size = UDim2.new(0,680,0,510),
        Position = UDim2.new(0.5,-340,0.5,-255),
        BackgroundColor3 = Theme.Background,
        BorderColor3 = Theme.Border,
        BorderSizePixel = 1,
        ClipsDescendants = true,
        Parent = sg,
    })

    -- Title bar
    local titlebar = elem("Frame", {
        Size = UDim2.new(1,0,0,32),
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Parent = main,
    })

    elem("TextLabel", {
        Size = UDim2.new(1,-10,1,0),
        Position = UDim2.new(0,8,0,0),
        BackgroundTransparency = 1,
        Text = cfg.Name or "Phantom",
        TextColor3 = Theme.Text,
        Font = Enum.Font.Code,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titlebar,
    })

    -- Dragging
    local drag, dragInput, dragStart, startPos
    titlebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then drag = false end
            end)
        end
    end)

    titlebar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if drag and input == dragInput then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Tab bar
    local tabbar = elem("Frame", {
        Size = UDim2.new(1,0,0,30),
        Position = UDim2.new(0,0,0,32),
        BackgroundColor3 = Theme.BackgroundSecondary,
        BorderSizePixel = 0,
        Parent = main,
    })

    elem("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
        Parent = tabbar,
    })

    elem("UIPadding", {
        PaddingLeft = UDim.new(0,10),
        PaddingTop = UDim.new(0,4),
        Parent = tabbar,
    })

    -- Content area
    local content = elem("Frame", {
        Size = UDim2.new(1,0,1,-62),
        Position = UDim2.new(0,0,0,62),
        BackgroundTransparency = 1,
        Parent = main,
    })

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == win.MenuKey then
            win.UIVisible = not win.UIVisible
            main.Visible = win.UIVisible
        end
    end)

    function win:CreateTab(tabcfg)
        local tab = {}
        tab.Name = tabcfg.Name or "Tab"
        tab.Sections = {Left={}, Right={}}

        local btn = elem("TextButton", {
            Size = UDim2.new(0, tab.Name:len()*8 + 30, 0, 22),
            BackgroundTransparency = 1,
            Text = tab.Name,
            TextColor3 = Theme.TextDark,
            Font = Enum.Font.Code,
            TextSize = 13,
            AutoButtonColor = false,
            Parent = tabbar,
        })

        local ind = elem("Frame", {
            Size = UDim2.new(1,0,0,2),
            Position = UDim2.new(0,0,1,-2),
            BackgroundColor3 = Theme.Accent,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = btn,
        })

        local page = elem("Frame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Visible = false,
            Parent = content,
        })

        local left = elem("ScrollingFrame", {
            Size = UDim2.new(0.5, -8, 1, -12),
            Position = UDim2.new(0,6,0,6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = page,
        })

        elem("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,7), Parent = left})

        local right = elem("ScrollingFrame", {
            Size = UDim2.new(0.5, -8, 1, -12),
            Position = UDim2.new(0.5,2,0,6),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            CanvasSize = UDim2.new(),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = page,
        })

        elem("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,7), Parent = right})

        tab.Button = btn
        tab.Indicator = ind
        tab.Page = page
        tab.LeftContainer = left
        tab.RightContainer = right

        btn.MouseButton1Click:Connect(function()
            for _, t in win.Tabs do
                local is = t == tab
                tween(t.Button,     {TextColor3 = is and Theme.Text or Theme.TextDark})
                tween(t.Indicator,  {BackgroundTransparency = is and 0 or 1})
                t.Page.Visible = is
            end
        end)

        function tab:CreateSection(secfg)
            local sec = {}
            local side = (secfg.Side or "Left"):lower() == "right" and "Right" or "Left"
            local cont = side == "Left" and left or right

            local frame = elem("Frame", {
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.BackgroundSecondary,
                BorderColor3 = Theme.Border,
                BorderSizePixel = 1,
                Parent = cont,
            })

            elem("UIPadding", {
                PaddingLeft = UDim.new(0,8),
                PaddingRight = UDim.new(0,8),
                PaddingTop = UDim.new(0,6),
                PaddingBottom = UDim.new(0,6),
                Parent = frame,
            })

            elem("TextLabel", {
                Size = UDim2.new(1,0,0,18),
                BackgroundTransparency = 1,
                Text = secfg.Name or "Section",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Code,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = frame,
            })

            local items = elem("Frame", {
                Size = UDim2.new(1,0,0,0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = frame,
            })

            elem("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0,5),
                Parent = items,
            })

            local function addBase(name, height)
                local f = elem("Frame", {
                    Size = UDim2.new(1,0,0,height or 20),
                    BackgroundTransparency = 1,
                    Parent = items,
                })

                elem("TextLabel", {
                    Size = UDim2.new(0.6,0,1,0),
                    BackgroundTransparency = 1,
                    Text = name,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = f,
                })

                return f
            end

            function sec:AddToggle(tcfg)
                local tog = {}
                tog.Value = tcfg.Default or false

                local f = addBase(tcfg.Name, 18)
                local box = elem("Frame", {
                    Size = UDim2.new(0,14,0,14),
                    Position = UDim2.new(1,-18,0.5,-7),
                    BackgroundColor3 = Theme.Background,
                    BorderColor3 = Theme.Border,
                    Parent = f,
                })

                local fill = elem("Frame", {
                    Size = UDim2.new(1,-4,1,-4),
                    Position = UDim2.new(0,2,0,2),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    BackgroundTransparency = tog.Value and 0 or 1,
                    Parent = box,
                })

                local btn = elem("TextButton", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = f,
                })

                function tog:Set(v)
                    tog.Value = v
                    tween(fill, {BackgroundTransparency = v and 0 or 1}, 0.12)
                    win.Flags[tcfg.Flag] = v
                    if tcfg.Callback then tcfg.Callback(v) end
                end

                btn.MouseButton1Click:Connect(function() tog:Set(not tog.Value) end)
                tog:Set(tog.Value)

                return tog
            end

            function sec:AddSlider(scfg)
                local s = {}
                s.Value = scfg.Default or scfg.Min or 0

                local f = addBase(scfg.Name, 32)
                local valLabel = elem("TextLabel", {
                    Size = UDim2.new(0.4,0,0,14),
                    Position = UDim2.new(0.6,0,0,0),
                    BackgroundTransparency = 1,
                    Text = tostring(s.Value),
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = f,
                })

                local bg = elem("Frame", {
                    Size = UDim2.new(1,0,0,4),
                    Position = UDim2.new(0,0,0,18),
                    BackgroundColor3 = Theme.BorderDark,
                    BorderSizePixel = 0,
                    Parent = f,
                })

                local fill = elem("Frame", {
                    Size = UDim2.new(0,0,1,0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = bg,
                })

                local hit = elem("TextButton", {
                    Size = UDim2.new(1,0,0,20),
                    Position = UDim2.new(0,0,0,12),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = f,
                })

                local dragging = false

                function s:Set(v)
                    v = math.clamp(math.round(v), scfg.Min or 0, scfg.Max or 100)
                    s.Value = v
                    local p = (v - (scfg.Min or 0)) / ((scfg.Max or 100) - (scfg.Min or 0))
                    tween(fill, {Size = UDim2.new(p,0,1,0)})
                    valLabel.Text = tostring(v)
                    win.Flags[scfg.Flag] = v
                    if scfg.Callback then scfg.Callback(v) end
                end

                hit.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        local p = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0,1)
                        s:Set((scfg.Min or 0) + p * ((scfg.Max or 100) - (scfg.Min or 0)))
                    end
                end)

                hit.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)

                UserInputService.InputChanged:Connect(function(i)
                    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                        local p = math.clamp((i.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0,1)
                        s:Set((scfg.Min or 0) + p * ((scfg.Max or 100) - (scfg.Min or 0)))
                    end
                end)

                s:Set(s.Value)
                return s
            end

            function sec:AddDropdown(dcfg)
                local dd = {}
                dd.Value = dcfg.Default or (dcfg.Options and dcfg.Options[1])
                dd.Open = false

                local f = addBase(dcfg.Name, 24)

                local val = elem("TextLabel", {
                    Size = UDim2.new(0.4,0,1,0),
                    Position = UDim2.new(0.6,0,0,0),
                    BackgroundTransparency = 1,
                    Text = dd.Value,
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = f,
                })

                local arrow = elem("TextLabel", {
                    Size = UDim2.new(0,16,1,0),
                    Position = UDim2.new(1,-20,0,0),
                    BackgroundTransparency = 1,
                    Text = "▼",
                    TextColor3 = Theme.TextDark,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    Parent = f,
                })

                local list = elem("Frame", {
                    Size = UDim2.new(1,0,0,0),
                    Position = UDim2.new(0,0,1,0),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderColor3 = Theme.Border,
                    BorderSizePixel = 1,
                    ClipsDescendants = true,
                    Visible = false,
                    Parent = f,
                })

                local ll = elem("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Parent = list})

                function dd:Set(v)
                    dd.Value = v
                    val.Text = tostring(v)
                    win.Flags[dcfg.Flag] = v
                    if dcfg.Callback then dcfg.Callback(v) end
                end

                f.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dd.Open = not dd.Open
                        local h = dd.Open and (math.min(#dcfg.Options, 8) * 22 + 4) or 0
                        tween(f, {Size = UDim2.new(1,0,0,24 + h)})
                        tween(arrow, {Rotation = dd.Open and 180 or 0})
                        list.Visible = dd.Open
                    end
                end)

                for _, opt in ipairs(dcfg.Options or {}) do
                    local b = elem("TextButton", {
                        Size = UDim2.new(1,0,0,22),
                        BackgroundTransparency = 1,
                        Text = "  "..tostring(opt),
                        TextColor3 = Theme.Text,
                        Font = Enum.Font.Code,
                        TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = list,
                    })

                    b.MouseButton1Click:Connect(function()
                        dd:Set(opt)
                        dd.Open = false
                        tween(f, {Size = UDim2.new(1,0,0,24)})
                        tween(arrow, {Rotation = 0})
                        list.Visible = false
                    end)

                    b.MouseEnter:Connect(function() tween(b, {BackgroundTransparency = 0.85}) end)
                    b.MouseLeave:Connect(function() tween(b, {BackgroundTransparency = 1}) end)
                end

                dd:Set(dd.Value)
                return dd
            end

            function sec:AddKeybind(kcfg)
                local kb = {}
                kb.Value = kcfg.Default or Enum.KeyCode.Unknown

                local f = addBase(kcfg.Name, 20)

                local btn = elem("TextButton", {
                    Size = UDim2.new(0,50,0,18),
                    Position = UDim2.new(1,-54,0.5,-9),
                    BackgroundColor3 = Theme.Background,
                    BorderColor3 = Theme.Border,
                    Text = kb.Value.Name or "...",
                    TextColor3 = Theme.Accent,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    Parent = f,
                })

                local listening = false

                btn.MouseButton1Click:Connect(function()
                    listening = true
                    btn.Text = "..."
                    btn.TextColor3 = Theme.Text
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                        kb.Value = input.KeyCode
                        btn.Text = input.KeyCode.Name
                        btn.TextColor3 = Theme.Accent
                        listening = false
                        win.Flags[kcfg.Flag] = kb.Value
                        if kcfg.Callback then kcfg.Callback() end
                    end
                end)

                win.Flags[kcfg.Flag] = kb.Value
                return kb
            end

            function sec:AddButton(bcfg)
                local b = elem("TextButton", {
                    Size = UDim2.new(1,0,0,24),
                    BackgroundColor3 = Theme.Header,
                    BorderColor3 = Theme.Border,
                    Text = bcfg.Name or "Button",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    Parent = items,
                })

                b.MouseEnter:Connect(function() tween(b, {BackgroundColor3 = Theme.Border}) end)
                b.MouseLeave:Connect(function() tween(b, {BackgroundColor3 = Theme.Header}) end)

                b.MouseButton1Click:Connect(bcfg.Callback or function() end)
                return b
            end

            function sec:AddLabel(lcfg)
                elem("TextLabel", {
                    Size = UDim2.new(1,0,0,16),
                    BackgroundTransparency = 1,
                    Text = lcfg.Text or "",
                    TextColor3 = Theme.TextDark,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = items,
                })
            end

            -- ────────────────────────────────────────────────
            --   Color Picker with wheel (same as previous)
            -- ────────────────────────────────────────────────
            function sec:AddColorPicker(cpCfg)
                local cp = {}
                cp.Value = cpCfg.Default or Color3.fromRGB(255,100,180)
                cp.Transparency = cpCfg.DefaultTransparency or 0

                local container = elem("Frame", {
                    Size = UDim2.new(1,0,0,22),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = items,
                })

                local button = elem("TextButton", {
                    Size = UDim2.new(1,0,0,22),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = container,
                })

                elem("TextLabel", {
                    Size = UDim2.new(1,-30,1,0),
                    BackgroundTransparency = 1,
                    Text = cpCfg.Name or "Color",
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.Code,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = button,
                })

                local preview = elem("Frame", {
                    Size = UDim2.new(0,20,0,16),
                    Position = UDim2.new(1,-26,0.5,-8),
                    BackgroundColor3 = cp.Value,
                    BackgroundTransparency = cp.Transparency,
                    BorderColor3 = Theme.Border,
                    BorderSizePixel = 1,
                    Parent = button,
                })

                local panelHeight = 148
                local panel = elem("Frame", {
                    Size = UDim2.new(1,0,0,0),
                    Position = UDim2.new(0,0,1,0),
                    BackgroundColor3 = Theme.BackgroundSecondary,
                    BorderColor3 = Theme.Border,
                    BorderSizePixel = 1,
                    Parent = container,
                })

                local wheel = elem("ImageLabel", {
                    Size = UDim2.new(0,110,0,110),
                    Position = UDim2.new(0,10,0,10),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://143336155",
                    Parent = panel,
                })

                local wheelDot = elem("Frame", {
                    Size = UDim2.new(0,10,0,10),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    BorderSizePixel = 2,
                    Parent = wheel,
                })

                local square = elem("Frame", {
                    Size = UDim2.new(0,110,0,110),
                    Position = UDim2.new(0,130,0,10),
                    BackgroundColor3 = Color3.new(1,0,0),
                    Parent = panel,
                })

                elem("UIGradient", {
                    Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1)),
                    Transparency = NumberSequence.new(0,1),
                    Rotation = 90,
                    Parent = square,
                })

                local squareDot = elem("Frame", {
                    Size = UDim2.new(0,10,0,10),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    BorderSizePixel = 2,
                    Parent = square,
                })

                local hueBar = elem("Frame", {
                    Size = UDim2.new(0,14,0,110),
                    Position = UDim2.new(0,250,0,10),
                    BackgroundColor3 = Color3.new(1,0,0),
                    Parent = panel,
                })

                elem("UIGradient", {
                    Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255,0,0)),
                    },
                    Rotation = 90,
                    Parent = hueBar,
                })

                local hueDot = elem("Frame", {
                    Size = UDim2.new(1,6,0,6),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    Parent = hueBar,
                })

                local alphaBar = elem("Frame", {
                    Size = UDim2.new(0,110,0,14),
                    Position = UDim2.new(0,10,0,130),
                    BackgroundColor3 = Color3.new(1,1,1),
                    Parent = panel,
                })

                elem("ImageLabel", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://149064630",
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0,16,0,16),
                    Parent = alphaBar,
                })

                local alphaFill = elem("Frame", {
                    Size = UDim2.new(1,0,1,0),
                    BackgroundColor3 = cp.Value,
                    Parent = alphaBar,
                })

                elem("UIGradient", {
                    Transparency = NumberSequence.new(0,1),
                    Parent = alphaFill,
                })

                local alphaDot = elem("Frame", {
                    Size = UDim2.new(0,6,1,6),
                    AnchorPoint = Vector2.new(0.5,0.5),
                    BackgroundColor3 = Color3.new(1,1,1),
                    BorderColor3 = Color3.new(0,0,0),
                    Parent = alphaBar,
                })

                local hue, sat, value = Color3.toHSV(cp.Value)
                local alpha = cp.Transparency

                local function updateColor()
                    local c = Color3.fromHSV(hue, sat, value)
                    cp.Value = c
                    preview.BackgroundColor3 = c
                    preview.BackgroundTransparency = alpha
                    alphaFill.BackgroundColor3 = c
                    win.Flags[cpCfg.Flag] = c
                    win.Flags[cpCfg.Flag .. "_trans"] = alpha
                    if cpCfg.Callback then cpCfg.Callback(c, alpha) end
                end

                -- Wheel logic (simplified)
                local wheelConn; wheelConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if not wheel:IsDescendantOf(game) then wheelConn:Disconnect() return end

                    local mp = input.Position - wheel.AbsolutePosition
                    local cx, cy = mp.X - 55, mp.Y - 55
                    local dist = math.sqrt(cx*cx + cy*cy)
                    if dist > 55 then
                        local ang = math.atan2(cy, cx)
                        cx = math.cos(ang) * 55
                        cy = math.sin(ang) * 55
                    end
                    wheelDot.Position = UDim2.new(0.5, cx, 0.5, cy)

                    hue = ((math.atan2(cy, cx) + math.pi) / (math.pi*2)) % 1
                    square.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    updateColor()
                end)

                -- Square logic (S/V)
                local sqConn; sqConn = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                    if not square:IsDescendantOf(game) then sqConn:Disconnect() return end

                    local mp = input.Position - square.AbsolutePosition
                    sat = math.clamp(mp.X / 110, 0, 1)
                    value = 1 - math.clamp(mp.Y / 110, 0, 1)
                    squareDot.Position = UDim2.new(0, sat*110, 0, (1-value)*110)
                    updateColor()
                end)

                -- Hue bar
                local hueDragging = false
                hueBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = true end end)
                hueBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then hueDragging = false end end)

                UserInputService.InputChanged:Connect(function(i)
                    if not hueDragging then return end
                    local y = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y) / hueBar.AbsoluteSize.Y, 0, 1)
                    hue = y
                    hueDot.Position = UDim2.new(0.5,0,0, y * hueBar.AbsoluteSize.Y)
                    square.BackgroundColor3 = Color3.fromHSV(hue,1,1)
                    updateColor()
                end)

                -- Alpha bar
                local alphaDragging = false
                alphaBar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = true end end)
                alphaBar.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then alphaDragging = false end end)

                UserInputService.InputChanged:Connect(function(i)
                    if not alphaDragging then return end
                    local x = math.clamp((i.Position.X - alphaBar.AbsolutePosition.X) / alphaBar.AbsoluteSize.X, 0, 1)
                    alpha = 1 - x
                    alphaDot.Position = UDim2.new(0, x * alphaBar.AbsoluteSize.X, 0.5, 0)
                    updateColor()
                end)

                -- Toggle
                button.MouseButton1Click:Connect(function()
                    local open = panel.Size.Y.Offset > 0
                    tween(panel, {Size = UDim2.new(1,0,0, open and 0 or panelHeight)})
                end)

                -- Init positions
                local wx = math.cos((hue * math.pi * 2) - math.pi) * 55
                local wy = math.sin((hue * math.pi * 2) - math.pi) * 55
                wheelDot.Position = UDim2.new(0.5, wx, 0.5, wy)
                squareDot.Position = UDim2.new(0, sat*110, 0, (1-value)*110)
                hueDot.Position = UDim2.new(0.5,0,0, hue * 110)
                alphaDot.Position = UDim2.new(0, (1-alpha)*110, 0.5, 0)
                square.BackgroundColor3 = Color3.fromHSV(hue,1,1)

                updateColor()

                return cp
            end

            table.insert(tab.Sections[side], sec)
            return sec
        end

        table.insert(win.Tabs, tab)

        if #win.Tabs == 1 then
            task.defer(function() win.Tabs[1].Button:InputObject() end) -- auto select first
        end

        return tab
    end

    return win
end

return Phantom
