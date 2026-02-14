--[[
    Phantom UI Library v4.0
    Style: Abyss Dev Access - Compact Terminal UI
    Dark background, monospace font, dense layout, thin borders
    Two-column split layout with section labels
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

-- ===== THEME =====
local Theme = {
    -- Backgrounds
    Background        = Color3.fromRGB(10, 10, 12),
    BackgroundAlt     = Color3.fromRGB(15, 15, 18),
    BackgroundItem    = Color3.fromRGB(12, 12, 14),

    -- Borders
    Border            = Color3.fromRGB(45, 45, 55),
    BorderLight       = Color3.fromRGB(60, 60, 72),

    -- Text
    Text              = Color3.fromRGB(200, 200, 210),
    TextDim           = Color3.fromRGB(110, 110, 125),
    TextAccent        = Color3.fromRGB(110, 140, 255),   -- blue-ish for active toggle names

    -- Accents
    AccentBlue        = Color3.fromRGB(90, 110, 235),    -- slider fill / blue elements
    AccentPink        = Color3.fromRGB(220, 80, 160),    -- pink slider / color swatch
    AccentPurple      = Color3.fromRGB(130, 80, 220),    -- color picker swatch

    -- Tab
    TabActive         = Color3.fromRGB(200, 200, 210),
    TabInactive       = Color3.fromRGB(100, 100, 115),
    TabBg             = Color3.fromRGB(10, 10, 12),

    -- Checkbox
    CheckboxBg        = Color3.fromRGB(18, 18, 22),
    CheckboxBorder    = Color3.fromRGB(55, 55, 68),
    CheckboxActive    = Color3.fromRGB(90, 110, 235),

    -- Slider
    SliderBg          = Color3.fromRGB(25, 25, 32),
    SliderFill        = Color3.fromRGB(80, 105, 225),

    -- Dropdown / Keybind button
    ElementBg         = Color3.fromRGB(14, 14, 18),
    ElementBorder     = Color3.fromRGB(45, 45, 58),
    KeybindBg         = Color3.fromRGB(20, 20, 26),

    -- Divider
    Divider           = Color3.fromRGB(38, 38, 48),
}

-- ===== CONSTANTS =====
local FONT           = Enum.Font.Code         -- monospace
local FONT_SIZE_SM   = 10
local FONT_SIZE_MD   = 11
local FONT_SIZE_LG   = 13
local ITEM_HEIGHT    = 20                     -- row height for most items
local SLIDER_HEIGHT  = 30
local SECTION_GAP    = 4                      -- gap between section header and first item
local ITEM_GAP       = 1                      -- gap between rows within a section
local SECTION_LABEL_H= 22                     -- height of section label row

-- ===== UTILITIES =====
local function Make(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        obj[k] = v
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Tween(obj, props, dur)
    local info = TweenInfo.new(dur or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function HLine(parent, yPos)
    Make("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, yPos),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
    }, parent)
end

-- ===== MAIN LIBRARY =====
function Phantom:CreateWindow(config)
    local Window = {}
    Window.Tabs      = {}
    Window.CurrentTab = nil
    Window.Flags     = {}
    Window.UIVisible = true
    Window.MenuBind  = Enum.KeyCode.RightShift
    Window.Title     = config.Name or "Phantom UI"
    Window.Subtitle  = config.Subtitle or "v4.0"

    local W  = config.Width  or 500
    local H  = config.Height or 550
    local HALF = math.floor(W / 2) -- column split point

    -- ScreenGui
    local ScreenGui = Make("ScreenGui", {
        Name            = "PhantomUI_" .. math.random(1000,9999),
        ResetOnSpawn    = false,
        ZIndexBehavior  = Enum.ZIndexBehavior.Sibling,
    })
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if not ok then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- Main Frame (outer border)
    local MainFrame = Make("Frame", {
        Name              = "Main",
        Size              = UDim2.new(0, W, 0, H),
        Position          = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3  = Theme.Background,
        BorderSizePixel   = 1,
        BorderColor3      = Theme.Border,
        ClipsDescendants  = true,
        Parent            = ScreenGui,
    })

    -- ── Title Bar ──────────────────────────────────────────────────────────
    local TitleBar = Make("Frame", {
        Name             = "TitleBar",
        Size             = UDim2.new(1, 0, 0, 22),
        BackgroundColor3 = Theme.BackgroundAlt,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })

    Make("TextLabel", {
        Size               = UDim2.new(1, -8, 1, 0),
        Position           = UDim2.new(0, 6, 0, 0),
        BackgroundTransparency = 1,
        Text               = Window.Title .. " | " .. Window.Subtitle,
        TextColor3         = Theme.TextDim,
        TextXAlignment     = Enum.TextXAlignment.Left,
        Font               = FONT,
        TextSize           = FONT_SIZE_SM,
        Parent             = TitleBar,
    })

    -- Thin line under title bar
    HLine(MainFrame, 22)

    -- ── Tab Bar ────────────────────────────────────────────────────────────
    local TabBar = Make("Frame", {
        Name             = "TabBar",
        Size             = UDim2.new(1, 0, 0, 22),
        Position         = UDim2.new(0, 0, 0, 23),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel  = 0,
        Parent           = MainFrame,
    })

    local TabLayout = Make("UIListLayout", {
        FillDirection      = Enum.FillDirection.Horizontal,
        SortOrder          = Enum.SortOrder.LayoutOrder,
        Padding            = UDim.new(0, 0),
        VerticalAlignment  = Enum.VerticalAlignment.Center,
        Parent             = TabBar,
    })

    -- Thin line under tab bar
    HLine(MainFrame, 45)

    -- ── Body (two columns) ─────────────────────────────────────────────────
    local BodyFrame = Make("Frame", {
        Name             = "Body",
        Size             = UDim2.new(1, 0, 1, -46),
        Position         = UDim2.new(0, 0, 0, 46),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent           = MainFrame,
    })

    -- Vertical divider between columns
    Make("Frame", {
        Name             = "VDivider",
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(0, HALF, 0, 0),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel  = 0,
        Parent           = BodyFrame,
    })

    -- ── Drag logic ──────────────────────────────────────────────────────────
    do
        local dragging, dragInput, dragStart, startPos
        TitleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging  = true
                dragStart = inp.Position
                startPos  = MainFrame.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then dragging = false end
                end)
            end
        end)
        TitleBar.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = inp
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if inp == dragInput and dragging then
                local d = inp.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end)
    end

    -- Toggle UI visibility
    UserInputService.InputBegan:Connect(function(inp, gp)
        if not gp and inp.KeyCode == Window.MenuBind then
            Window:ToggleUI()
        end
    end)

    function Window:ToggleUI()
        Window.UIVisible = not Window.UIVisible
        MainFrame.Visible = Window.UIVisible
    end

    -- ── SelectTab ──────────────────────────────────────────────────────────
    function Window:SelectTab(tab)
        for _, t in ipairs(Window.Tabs) do
            local active = (t == tab)
            t.Content.Visible = active
            Tween(t.Button, {TextColor3 = active and Theme.TabActive or Theme.TabInactive}, 0.1)
            -- show/hide underline indicator
            Tween(t.Indicator, {BackgroundTransparency = active and 0 or 1}, 0.1)
        end
        Window.CurrentTab = tab
    end

    -- ── CreateTab ──────────────────────────────────────────────────────────
    function Window:CreateTab(cfg)
        local Tab    = {}
        Tab.Name     = cfg.Name or "Tab"
        Tab.Sections = { Left = {}, Right = {} }

        -- Tab button
        local TabBtn = Make("TextButton", {
            Name             = "Tab_" .. Tab.Name,
            Size             = UDim2.new(0, 80, 1, 0),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel  = 0,
            Text             = Tab.Name,
            TextColor3       = Theme.TabInactive,
            Font             = FONT,
            TextSize         = FONT_SIZE_MD,
            AutoButtonColor  = false,
            LayoutOrder      = #Window.Tabs + 1,
            Parent           = TabBar,
        })

        -- Active underline
        local TabIndicator = Make("Frame", {
            Name             = "Ind",
            Size             = UDim2.new(1, 0, 0, 1),
            Position         = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = Theme.AccentBlue,
            BorderSizePixel  = 0,
            BackgroundTransparency = 1,
            Parent           = TabBtn,
        })

        -- Right border separator between tabs
        Make("Frame", {
            Size             = UDim2.new(0, 1, 1, 0),
            Position         = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Theme.Divider,
            BorderSizePixel  = 0,
            Parent           = TabBtn,
        })

        -- Tab content frame (full body)
        local TabContent = Make("Frame", {
            Name                  = "Content_" .. Tab.Name,
            Size                  = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency= 1,
            Visible               = false,
            Parent                = BodyFrame,
        })

        -- Left scroll frame
        local LeftScroll = Make("ScrollingFrame", {
            Name                  = "Left",
            Size                  = UDim2.new(0, HALF, 1, 0),
            Position              = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency= 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = Theme.Border,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            Parent                = TabContent,
        })

        Make("UIPadding", {
            PaddingTop    = UDim.new(0, 6),
            PaddingLeft   = UDim.new(0, 0),
            PaddingRight  = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 6),
            Parent        = LeftScroll,
        })

        local LeftLayout = Make("UIListLayout", {
            SortOrder          = Enum.SortOrder.LayoutOrder,
            Padding            = UDim.new(0, 0),
            Parent             = LeftScroll,
        })

        -- Right scroll frame
        local RightScroll = Make("ScrollingFrame", {
            Name                  = "Right",
            Size                  = UDim2.new(0, W - HALF - 1, 1, 0),
            Position              = UDim2.new(0, HALF + 1, 0, 0),
            BackgroundTransparency= 1,
            BorderSizePixel       = 0,
            ScrollBarThickness    = 2,
            ScrollBarImageColor3  = Theme.Border,
            CanvasSize            = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize   = Enum.AutomaticSize.Y,
            Parent                = TabContent,
        })

        Make("UIPadding", {
            PaddingTop    = UDim.new(0, 6),
            PaddingLeft   = UDim.new(0, 0),
            PaddingRight  = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 6),
            Parent        = RightScroll,
        })

        local RightLayout = Make("UIListLayout", {
            SortOrder          = Enum.SortOrder.LayoutOrder,
            Padding            = UDim.new(0, 0),
            Parent             = RightScroll,
        })

        Tab.Button    = TabBtn
        Tab.Indicator = TabIndicator
        Tab.Content   = TabContent
        Tab.LeftScroll  = LeftScroll
        Tab.RightScroll = RightScroll

        TabBtn.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        TabBtn.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {TextColor3 = Theme.Text}, 0.08)
            end
        end)
        TabBtn.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabBtn, {TextColor3 = Theme.TabInactive}, 0.08)
            end
        end)

        -- ── CreateSection ──────────────────────────────────────────────────
        function Tab:CreateSection(scfg)
            local Section  = {}
            Section.Name   = scfg.Name or "Section"
            Section.Side   = scfg.Side or "Left"

            local ColScroll = Section.Side == "Left" and Tab.LeftScroll or Tab.RightScroll
            local ColLayout = Section.Side == "Left" and LeftLayout or RightLayout
            local ColList   = Section.Side == "Left" and Tab.Sections.Left or Tab.Sections.Right

            -- Section wrapper (auto-sizes)
            local SectionWrap = Make("Frame", {
                Name          = "Sec_" .. Section.Name,
                Size          = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                LayoutOrder   = #ColList + 1,
                Parent        = ColScroll,
            })

            -- Section label (flush, no border, just text)
            local SectionLabel = Make("TextLabel", {
                Name               = "SecLabel",
                Size               = UDim2.new(1, 0, 0, SECTION_LABEL_H),
                BackgroundTransparency = 1,
                Text               = Section.Name,
                TextColor3         = Theme.Text,
                TextXAlignment     = Enum.TextXAlignment.Left,
                Font               = FONT,
                TextSize           = FONT_SIZE_MD,
                Parent             = SectionWrap,
            })
            Make("UIPadding", {
                PaddingLeft = UDim.new(0, 8),
                Parent      = SectionLabel,
            })

            -- Thin line under section label
            local SepLine = Make("Frame", {
                Name             = "Sep",
                Size             = UDim2.new(1, 0, 0, 1),
                Position         = UDim2.new(0, 0, 0, SECTION_LABEL_H - 1),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel  = 0,
                Parent           = SectionWrap,
            })

            -- Content list inside section
            local SectionContent = Make("Frame", {
                Name          = "SContent",
                Size          = UDim2.new(1, 0, 0, 0),
                Position      = UDim2.new(0, 0, 0, SECTION_LABEL_H),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent        = SectionWrap,
            })

            Make("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding   = UDim.new(0, ITEM_GAP),
                Parent    = SectionContent,
            })

            -- Track layout order
            local itemOrder = 0
            local function NextOrder()
                itemOrder = itemOrder + 1
                return itemOrder
            end

            -- ── Helpers for item rows ────────────────────────────────────

            -- Base row frame (full width, fixed height)
            local function MakeRow(h, pad)
                local row = Make("Frame", {
                    Size                  = UDim2.new(1, 0, 0, h or ITEM_HEIGHT),
                    BackgroundTransparency = 1,
                    BorderSizePixel       = 0,
                    LayoutOrder           = NextOrder(),
                    Parent                = SectionContent,
                })
                if pad ~= false then
                    Make("UIPadding", {
                        PaddingLeft  = UDim.new(0, 8),
                        PaddingRight = UDim.new(0, 6),
                        Parent       = row,
                    })
                end
                return row
            end

            -- Small checkbox (like in the image: □ with filled inner square when active)
            local function MakeCheckbox(parent, xOff, yOff, size)
                size = size or 9
                local box = Make("Frame", {
                    Size             = UDim2.new(0, size, 0, size),
                    Position         = UDim2.new(0, xOff, 0.5, -math.floor(size/2)),
                    BackgroundColor3 = Theme.CheckboxBg,
                    BorderSizePixel  = 1,
                    BorderColor3     = Theme.CheckboxBorder,
                    Parent           = parent,
                })
                local fill = Make("Frame", {
                    Size                  = UDim2.new(1, -2, 1, -2),
                    Position              = UDim2.new(0, 1, 0, 1),
                    BackgroundColor3      = Theme.CheckboxActive,
                    BackgroundTransparency= 1,
                    BorderSizePixel       = 0,
                    Parent               = box,
                })
                return box, fill
            end

            -- ── AddToggle ─────────────────────────────────────────────────
            function Section:AddToggle(tcfg)
                local Toggle      = {}
                Toggle.Name       = tcfg.Name or "Toggle"
                Toggle.Flag       = tcfg.Flag
                Toggle.Default    = tcfg.Default or false
                Toggle.Callback   = tcfg.Callback or function() end
                Toggle.Value      = Toggle.Default
                Toggle.Highlighted = tcfg.Highlighted or false

                local row = MakeRow(ITEM_HEIGHT)

                local cbBox, cbFill = MakeCheckbox(row, 0, 0, 9)

                local lbl = Make("TextLabel", {
                    Size               = UDim2.new(1, -50, 1, 0),
                    Position           = UDim2.new(0, 14, 0, 0),
                    BackgroundTransparency = 1,
                    Text               = Toggle.Name,
                    TextColor3         = Toggle.Highlighted and Theme.TextAccent or Theme.Text,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = row,
                })

                -- Optional keybind button on right
                local keybindLabel = nil
                if tcfg.Keybind then
                    keybindLabel = Make("TextButton", {
                        Size             = UDim2.new(0, 24, 0, 14),
                        Position         = UDim2.new(1, -24, 0.5, -7),
                        BackgroundColor3 = Theme.KeybindBg,
                        BorderSizePixel  = 1,
                        BorderColor3     = Theme.ElementBorder,
                        Text             = tcfg.Keybind,
                        TextColor3       = Theme.TextDim,
                        Font             = FONT,
                        TextSize         = FONT_SIZE_SM,
                        AutoButtonColor  = false,
                        Parent           = row,
                    })
                end

                -- Click button over whole row
                local btn = Make("TextButton", {
                    Size                  = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency= 1,
                    Text                  = "",
                    Parent                = row,
                })

                function Toggle:Set(v)
                    Toggle.Value = v
                    Tween(cbFill, {BackgroundTransparency = v and 0 or 1}, 0.1)
                    Tween(lbl, {TextColor3 = (Toggle.Highlighted or v) and Theme.TextAccent or Theme.Text}, 0.1)
                    if Toggle.Flag then Window.Flags[Toggle.Flag] = v end
                    Toggle.Callback(v)
                end

                btn.MouseButton1Click:Connect(function() Toggle:Set(not Toggle.Value) end)
                Toggle:Set(Toggle.Default)
                return Toggle
            end

            -- ── AddSlider ─────────────────────────────────────────────────
            function Section:AddSlider(scfg)
                local Slider    = {}
                Slider.Name     = scfg.Name or "Slider"
                Slider.Min      = scfg.Min  or 0
                Slider.Max      = scfg.Max  or 100
                Slider.Default  = scfg.Default or Slider.Min
                Slider.Flag     = scfg.Flag
                Slider.Callback = scfg.Callback or function() end
                Slider.Value    = Slider.Default
                Slider.Color    = scfg.Color or "blue"   -- "blue" or "pink"

                -- Label row
                local labelRow = MakeRow(16)
                Make("TextLabel", {
                    Size               = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = Slider.Name,
                    TextColor3         = Theme.TextDim,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = labelRow,
                })

                -- Slider bar row
                local barRow = MakeRow(16, false)
                Make("UIPadding", { PaddingLeft = UDim.new(0,0), PaddingRight = UDim.new(0,0), Parent = barRow })

                local fillColor = Slider.Color == "pink" and Theme.AccentPink or Theme.SliderFill

                local track = Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 14),
                    Position         = UDim2.new(0, 0, 0.5, -7),
                    BackgroundColor3 = Theme.SliderBg,
                    BorderSizePixel  = 0,
                    ClipsDescendants = true,
                    Parent           = barRow,
                })

                local fill = Make("Frame", {
                    Size             = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = fillColor,
                    BorderSizePixel  = 0,
                    Parent           = track,
                })

                local valLbl = Make("TextLabel", {
                    Size               = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = "0/0",
                    TextColor3         = Theme.Text,
                    TextXAlignment     = Enum.TextXAlignment.Center,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    ZIndex             = 2,
                    Parent             = track,
                })

                local sliderBtn = Make("TextButton", {
                    Size                  = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency= 1,
                    Text                  = "",
                    ZIndex                = 3,
                    Parent                = track,
                })

                local draggingSlider = false

                local function UpdateSlider(input)
                    local pct = math.clamp(
                        (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X,
                        0, 1
                    )
                    local v = Slider.Min + (Slider.Max - Slider.Min) * pct
                    Slider:Set(math.floor(v + 0.5))
                end

                function Slider:Set(v)
                    v = math.clamp(math.floor(v + 0.5), Slider.Min, Slider.Max)
                    Slider.Value = v
                    local pct = (v - Slider.Min) / (Slider.Max - Slider.Min)
                    Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.08)
                    valLbl.Text = v .. "/" .. Slider.Max
                    if Slider.Flag then Window.Flags[Slider.Flag] = v end
                    Slider.Callback(v)
                end

                sliderBtn.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = true
                        UpdateSlider(inp)
                    end
                end)
                sliderBtn.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                        draggingSlider = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(inp)
                    end
                end)

                Slider:Set(Slider.Default)
                return Slider
            end

            -- ── AddDropdown ───────────────────────────────────────────────
            function Section:AddDropdown(dcfg)
                local DD        = {}
                DD.Name         = dcfg.Name or "Dropdown"
                DD.Options      = dcfg.Options or {}
                DD.Default      = dcfg.Default or (DD.Options[1] or "None")
                DD.Flag         = dcfg.Flag
                DD.Callback     = dcfg.Callback or function() end
                DD.Value        = DD.Default
                DD.Open         = false

                -- The outer container will grow when open
                local container = Make("Frame", {
                    Name          = "DD_" .. DD.Name,
                    Size          = UDim2.new(1, 0, 0, ITEM_HEIGHT),
                    AutomaticSize = Enum.AutomaticSize.None,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    LayoutOrder   = NextOrder(),
                    Parent        = SectionContent,
                })

                -- Label row (name, shown above if present)
                if dcfg.ShowLabel ~= false and dcfg.Label then
                    Make("TextLabel", {
                        Size               = UDim2.new(1, -8, 0, 14),
                        Position           = UDim2.new(0, 8, 0, 0),
                        BackgroundTransparency = 1,
                        Text               = dcfg.Label,
                        TextColor3         = Theme.TextDim,
                        TextXAlignment     = Enum.TextXAlignment.Left,
                        Font               = FONT,
                        TextSize           = FONT_SIZE_SM,
                        Parent             = container,
                    })
                    container.Size = UDim2.new(1, 0, 0, ITEM_HEIGHT + 14)
                end

                local yStart = (dcfg.Label and 14) or 0

                -- Main button row
                local btnRow = Make("TextButton", {
                    Size             = UDim2.new(1, 0, 0, ITEM_HEIGHT),
                    Position         = UDim2.new(0, 0, 0, yStart),
                    BackgroundColor3 = Theme.ElementBg,
                    BorderSizePixel  = 0,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = container,
                })

                Make("UIPadding", { PaddingLeft = UDim.new(0,8), PaddingRight = UDim.new(0,4), Parent = btnRow })

                local valLbl = Make("TextLabel", {
                    Size               = UDim2.new(1, -20, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = tostring(DD.Value),
                    TextColor3         = Theme.Text,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = btnRow,
                })

                Make("TextLabel", {
                    Size               = UDim2.new(0, 16, 1, 0),
                    Position           = UDim2.new(1, -16, 0, 0),
                    BackgroundTransparency = 1,
                    Text               = "+",
                    TextColor3         = Theme.TextDim,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_LG,
                    Name               = "Arrow",
                    Parent             = btnRow,
                })

                -- Bottom border line for the button
                Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    Position         = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = Theme.Divider,
                    BorderSizePixel  = 0,
                    Parent           = btnRow,
                })

                -- Options list
                local optList = Make("Frame", {
                    Name          = "OptList",
                    Size          = UDim2.new(1, 0, 0, 0),
                    Position      = UDim2.new(0, 0, 0, yStart + ITEM_HEIGHT),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Parent        = container,
                })

                Make("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding   = UDim.new(0, 0),
                    Parent    = optList,
                })

                for i, opt in ipairs(DD.Options) do
                    local optBtn = Make("TextButton", {
                        Size             = UDim2.new(1, 0, 0, ITEM_HEIGHT),
                        BackgroundColor3 = Theme.Background,
                        BorderSizePixel  = 0,
                        Text             = "",
                        AutoButtonColor  = false,
                        LayoutOrder      = i,
                        Parent           = optList,
                    })
                    Make("UIPadding", { PaddingLeft = UDim.new(0,8), Parent = optBtn })
                    local optLbl = Make("TextLabel", {
                        Size               = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text               = tostring(opt),
                        TextColor3         = Theme.TextDim,
                        TextXAlignment     = Enum.TextXAlignment.Left,
                        Font               = FONT,
                        TextSize           = FONT_SIZE_SM,
                        Parent             = optBtn,
                    })
                    Make("Frame", {
                        Size             = UDim2.new(1, 0, 0, 1),
                        Position         = UDim2.new(0, 0, 1, -1),
                        BackgroundColor3 = Theme.Divider,
                        BorderSizePixel  = 0,
                        Parent           = optBtn,
                    })

                    optBtn.MouseEnter:Connect(function()
                        Tween(optLbl, {TextColor3 = Theme.Text}, 0.08)
                    end)
                    optBtn.MouseLeave:Connect(function()
                        Tween(optLbl, {TextColor3 = Theme.TextDim}, 0.08)
                    end)
                    optBtn.MouseButton1Click:Connect(function()
                        DD:Set(opt)
                        DD:Close()
                    end)
                end

                local baseH = yStart + ITEM_HEIGHT
                local openH  = baseH + math.min(#DD.Options, 6) * ITEM_HEIGHT

                function DD:Set(v)
                    DD.Value = v
                    valLbl.Text = tostring(v)
                    if DD.Flag then Window.Flags[DD.Flag] = v end
                    DD.Callback(v)
                end

                function DD:Open()
                    DD.Open = true
                    Tween(container, {Size = UDim2.new(1, 0, 0, openH)}, 0.15)
                    local arrow = btnRow:FindFirstChild("Arrow")
                    if arrow then arrow.Text = "-" end
                end

                function DD:Close()
                    DD.Open = false
                    Tween(container, {Size = UDim2.new(1, 0, 0, baseH)}, 0.15)
                    local arrow = btnRow:FindFirstChild("Arrow")
                    if arrow then arrow.Text = "+" end
                end

                function DD:Toggle()
                    if DD.Open then DD:Close() else DD:Open() end
                end

                btnRow.MouseButton1Click:Connect(function() DD:Toggle() end)
                DD:Set(DD.Default)
                return DD
            end

            -- ── AddKeybind ─────────────────────────────────────────────────
            function Section:AddKeybind(kcfg)
                local KB        = {}
                KB.Name         = kcfg.Name or "Keybind"
                KB.Default      = kcfg.Default or Enum.KeyCode.Unknown
                KB.Flag         = kcfg.Flag
                KB.Callback     = kcfg.Callback or function() end
                KB.Value        = KB.Default
                KB.Listening    = false

                local row = MakeRow(ITEM_HEIGHT)

                local lbl = Make("TextLabel", {
                    Size               = UDim2.new(1, -34, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = KB.Name,
                    TextColor3         = Theme.Text,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = row,
                })

                local kbBtn = Make("TextButton", {
                    Size             = UDim2.new(0, 28, 0, 14),
                    Position         = UDim2.new(1, -28, 0.5, -7),
                    BackgroundColor3 = Theme.KeybindBg,
                    BorderSizePixel  = 1,
                    BorderColor3     = Theme.ElementBorder,
                    Text             = KB.Value.Name,
                    TextColor3       = Theme.TextDim,
                    Font             = FONT,
                    TextSize         = FONT_SIZE_SM,
                    AutoButtonColor  = false,
                    Parent           = row,
                })

                function KB:Set(key)
                    KB.Value   = key
                    kbBtn.Text = key.Name
                    if KB.Flag then Window.Flags[KB.Flag] = key end
                end

                kbBtn.MouseButton1Click:Connect(function()
                    KB.Listening    = true
                    kbBtn.Text      = "..."
                    kbBtn.TextColor3= Theme.Text
                end)

                UserInputService.InputBegan:Connect(function(inp, gp)
                    if KB.Listening then
                        if inp.UserInputType == Enum.UserInputType.Keyboard then
                            KB:Set(inp.KeyCode)
                            KB.Listening     = false
                            kbBtn.TextColor3 = Theme.TextDim
                        end
                    elseif inp.KeyCode == KB.Value and not gp then
                        KB.Callback()
                    end
                end)

                KB:Set(KB.Default)
                return KB
            end

            -- ── AddButton ─────────────────────────────────────────────────
            function Section:AddButton(bcfg)
                local Btn    = {}
                Btn.Name     = bcfg.Name or "Button"
                Btn.Callback = bcfg.Callback or function() end

                local row = MakeRow(ITEM_HEIGHT)
                Make("UIPadding", { PaddingLeft = UDim.new(0,0), PaddingRight = UDim.new(0,0), Parent = row })

                local btnFrame = Make("TextButton", {
                    Size             = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.ElementBg,
                    BorderSizePixel  = 0,
                    Text             = Btn.Name,
                    TextColor3       = Theme.TextDim,
                    Font             = FONT,
                    TextSize         = FONT_SIZE_SM,
                    AutoButtonColor  = false,
                    Parent           = row,
                })

                Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 1),
                    Position         = UDim2.new(0, 0, 1, -1),
                    BackgroundColor3 = Theme.Divider,
                    BorderSizePixel  = 0,
                    Parent           = btnFrame,
                })

                btnFrame.MouseEnter:Connect(function()
                    Tween(btnFrame, {TextColor3 = Theme.Text}, 0.08)
                end)
                btnFrame.MouseLeave:Connect(function()
                    Tween(btnFrame, {TextColor3 = Theme.TextDim}, 0.08)
                end)
                btnFrame.MouseButton1Click:Connect(function()
                    Btn.Callback()
                end)

                return Btn
            end

            -- ── AddLabel ─────────────────────────────────────────────────
            function Section:AddLabel(lcfg)
                local Lbl  = {}
                Lbl.Text   = lcfg.Text or ""

                local row = MakeRow(ITEM_HEIGHT)
                local lbl = Make("TextLabel", {
                    Size               = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = Lbl.Text,
                    TextColor3         = Theme.TextDim,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = row,
                })

                function Lbl:Set(t)
                    Lbl.Text = t
                    lbl.Text = t
                end

                return Lbl
            end

            -- ── AddColorPicker (swatch style like image) ──────────────────
            function Section:AddColorPicker(cpcfg)
                local CP      = {}
                CP.Name       = cpcfg.Name or "Color"
                CP.Default    = cpcfg.Default or Color3.fromRGB(130, 80, 220)
                CP.Flag       = cpcfg.Flag
                CP.Callback   = cpcfg.Callback or function() end
                CP.Value      = CP.Default

                local row = MakeRow(ITEM_HEIGHT)

                local lbl = Make("TextLabel", {
                    Size               = UDim2.new(1, -32, 1, 0),
                    BackgroundTransparency = 1,
                    Text               = CP.Name,
                    TextColor3         = Theme.Text,
                    TextXAlignment     = Enum.TextXAlignment.Left,
                    Font               = FONT,
                    TextSize           = FONT_SIZE_SM,
                    Parent             = row,
                })

                local swatch = Make("TextButton", {
                    Size             = UDim2.new(0, 28, 0, 12),
                    Position         = UDim2.new(1, -28, 0.5, -6),
                    BackgroundColor3 = CP.Value,
                    BorderSizePixel  = 0,
                    Text             = "",
                    AutoButtonColor  = false,
                    Parent           = row,
                })

                function CP:Set(c)
                    CP.Value              = c
                    swatch.BackgroundColor3 = c
                    if CP.Flag then Window.Flags[CP.Flag] = c end
                    CP.Callback(c)
                end

                CP:Set(CP.Default)
                return CP
            end

            -- ── AddSeparator ─────────────────────────────────────────────
            function Section:AddSeparator()
                local row = Make("Frame", {
                    Size             = UDim2.new(1, 0, 0, 8),
                    BackgroundTransparency = 1,
                    BorderSizePixel  = 0,
                    LayoutOrder      = NextOrder(),
                    Parent           = SectionContent,
                })
                Make("Frame", {
                    Size             = UDim2.new(1, -16, 0, 1),
                    Position         = UDim2.new(0, 8, 0.5, 0),
                    BackgroundColor3 = Theme.Divider,
                    BorderSizePixel  = 0,
                    Parent           = row,
                })
            end

            -- Trailing divider line after section
            local endLine = Make("Frame", {
                Name             = "EndLine",
                Size             = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Divider,
                BorderSizePixel  = 0,
                LayoutOrder      = 9999,
                Parent           = SectionWrap,
            })
            -- We position it at the bottom automatically via AutomaticSize

            table.insert(ColList, Section)
            return Section
        end

        table.insert(Window.Tabs, Tab)

        if #Window.Tabs == 1 then
            task.defer(function() Window:SelectTab(Tab) end)
        end

        return Tab
    end

    -- ── Save / Load ────────────────────────────────────────────────────────
    function Window:SaveConfig(name)
        name = name or "default"
        local cfg = {}
        for flag, value in pairs(Window.Flags) do
            if type(value) == "Color3" then
                cfg[flag] = {value.R, value.G, value.B}
            elseif type(value) == "EnumItem" then
                cfg[flag] = tostring(value)
            else
                cfg[flag] = value
            end
        end
        return pcall(function()
            writefile("phantom_" .. name .. ".json", HttpService:JSONEncode(cfg))
        end)
    end

    function Window:LoadConfig(name)
        name = name or "default"
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile("phantom_" .. name .. ".json"))
        end)
        if ok then
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

-- ======================================================================
-- DEMO USAGE (mirrors original, adapted to new API)
-- ======================================================================

local Window = Phantom:CreateWindow({
    Name     = "Phantom UI",
    Subtitle = "abyss edition",
    Width    = 500,
    Height   = 540,
})

-- ── Main Tab ────────────────────────────────────────────────────────────
local MainTab = Window:CreateTab({ Name = "main" })

-- Left column
local LegitSection = MainTab:CreateSection({ Name = "legit", Side = "Left" })

LegitSection:AddToggle({
    Name = "aimbot", Keybind = "M2", Default = false,
    Callback = function(v) print("aimbot:", v) end
})
LegitSection:AddToggle({
    Name = "visible check", Default = false,
    Callback = function(v) print("visible check:", v) end
})
LegitSection:AddToggle({
    Name = "apply prediction", Default = false,
    Callback = function(v) print("apply prediction:", v) end
})
LegitSection:AddSlider({
    Name = "smoothing [mouse]", Min = 0, Max = 20, Default = 0,
    Callback = function(v) print("smoothing:", v) end
})
LegitSection:AddDropdown({
    Name = "hitbox priority", Options = {"Head","Body","Limbs"}, Default = "Head",
    Callback = function(v) print("hitbox:", v) end
})
LegitSection:AddDropdown({
    Name = "mode", Options = {"Camera","Cursor","Memory"}, Default = "Camera",
    Callback = function(v) print("mode:", v) end
})

local BulletSection = MainTab:CreateSection({ Name = "bullet redirection", Side = "Left" })

BulletSection:AddToggle({
    Name = "silent aim", Default = false, Highlighted = true,
    Callback = function(v) print("silent aim:", v) end
})
BulletSection:AddToggle({
    Name = "apply prediction", Default = false,
    Callback = function(v) print("prediction:", v) end
})
BulletSection:AddToggle({
    Name = "custom prediction", Default = false,
    Callback = function(v) print("custom pred:", v) end
})
BulletSection:AddSlider({
    Name = "value", Min = 0, Max = 99, Default = 75,
    Callback = function(v) print("value:", v) end
})
BulletSection:AddToggle({
    Name = "visible check", Default = false,
    Callback = function(v) print("vis check:", v) end
})
BulletSection:AddSlider({
    Name = "randomization", Min = 0, Max = 100, Default = 0,
    Callback = function(v) print("randomization:", v) end
})
BulletSection:AddDropdown({
    Name = "hitbox priority", Options = {"Head","Body","Limbs"}, Default = "Head",
    Callback = function(v) print("hitbox:", v) end
})

local TriggerSection = MainTab:CreateSection({ Name = "trigger bot", Side = "Left" })

TriggerSection:AddToggle({
    Name = "enabled", Keybind = "M", Default = false,
    Callback = function(v) print("triggerbot:", v) end
})
TriggerSection:AddSlider({
    Name = "delay", Min = 0, Max = 5, Default = 0,
    Callback = function(v) print("delay:", v) end
})

-- Right column
local FOVSection = MainTab:CreateSection({ Name = "drawing field of view", Side = "Right" })

FOVSection:AddToggle({ Name = "aimbot fov", Default = false, Callback = function(v) print("fov:", v) end })
FOVSection:AddColorPicker({ Name = "", Default = Color3.fromRGB(110, 90, 230) })
FOVSection:AddSlider({
    Name = "size", Min = 0, Max = 250, Default = 100,
    Callback = function(v) print("fov size:", v) end
})
FOVSection:AddToggle({ Name = "silent aim fov", Default = false, Callback = function(v) print("slient fov:", v) end })
FOVSection:AddColorPicker({ Name = "", Default = Color3.fromRGB(220, 70, 140) })
FOVSection:AddSlider({
    Name = "size", Min = 0, Max = 250, Default = 100, Color = "pink",
    Callback = function(v) print("slient fov size:", v) end
})
FOVSection:AddDropdown({
    Name = "style", Options = {"Outline","Fill","Dashed"}, Default = "Outline",
    Callback = function(v) print("style:", v) end
})
FOVSection:AddDropdown({
    Name = "position", Options = {"Mouse","Camera","Fixed"}, Default = "Mouse",
    Callback = function(v) print("position:", v) end
})

-- ── Rage Tab ────────────────────────────────────────────────────────────
local RageTab = Window:CreateTab({ Name = "rage" })

local RageAimSection = RageTab:CreateSection({ Name = "aimbot", Side = "Left" })
RageAimSection:AddToggle({ Name = "enabled", Keybind = "M2", Default = false })
RageAimSection:AddDropdown({ Name = "hitbox", Options = {"Head","Chest","Pelvis","Nearest"}, Default = "Head" })
RageAimSection:AddSlider({ Name = "fov", Min = 0, Max = 360, Default = 180 })
RageAimSection:AddToggle({ Name = "auto fire", Default = false, Highlighted = true })
RageAimSection:AddToggle({ Name = "resolver", Default = false })

local AntiaimSection = RageTab:CreateSection({ Name = "anti-aim", Side = "Right" })
AntiaimSection:AddToggle({ Name = "enabled", Default = false })
AntiaimSection:AddDropdown({ Name = "pitch", Options = {"Down","Up","Fake"}, Default = "Down" })
AntiaimSection:AddDropdown({ Name = "yaw", Options = {"Backwards","Sideways","Spin"}, Default = "Backwards" })
AntiaimSection:AddSlider({ Name = "spin speed", Min = 1, Max = 20, Default = 5 })

-- ── Settings Tab ────────────────────────────────────────────────────────
local SettingsTab = Window:CreateTab({ Name = "settings" })

local CfgSection = SettingsTab:CreateSection({ Name = "config", Side = "Left" })
CfgSection:AddButton({ Name = "save config", Callback = function()
    Window:SaveConfig("default")
    print("Config saved")
end})
CfgSection:AddButton({ Name = "load config", Callback = function()
    Window:LoadConfig("default")
    print("Config loaded")
end})

local MenuSection = SettingsTab:CreateSection({ Name = "menu", Side = "Right" })
MenuSection:AddKeybind({ Name = "toggle ui", Default = Enum.KeyCode.RightShift, Callback = function() Window:ToggleUI() end })
MenuSection:AddLabel({ Text = "press right shift to toggle" })
MenuSection:AddButton({ Name = "destroy ui", Callback = function() Window:Destroy() end })

-- Startup notification
pcall(function()
    game.StarterGui:SetCore("SendNotification", {
        Title    = "Phantom UI";
        Text     = "Loaded! Right Shift to toggle.";
        Duration = 5;
    })
end)

print("[Phantom UI v4.0] Loaded — Right Shift to toggle")
