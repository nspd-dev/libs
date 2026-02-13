-- Phantom UI Library (Single-File, Loadstring Compatible)
-- High-performance, modular, OOP-style Roblox UI framework
-- Theme: Dark + Hot Pink accents (exactly matching "abyss dev access" style)

local Phantom = {}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- ScreenGui (CoreGui protected where possible)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Phantom"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999

if syn and syn.protect_gui then
	syn.protect_gui(ScreenGui)
	ScreenGui.Parent = game:GetService("CoreGui")
elseif gethui then
	ScreenGui.Parent = gethui()
else
	ScreenGui.Parent = player:FindFirstChildWhichIsA("PlayerGui") or player.PlayerGui
end

-- Theme (exact colors from reference)
local Theme = {
	Background = Color3.fromRGB(15, 15, 15),
	Background2 = Color3.fromRGB(20, 20, 20),
	Accent = Color3.fromRGB(255, 105, 180),      -- hot pink
	AccentDark = Color3.fromRGB(180, 50, 100),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(170, 170, 170),
	Border = Color3.fromRGB(40, 40, 40),
	BorderAccent = Color3.fromRGB(80, 30, 60),
}

-- Utility tween
local function Tween(obj, props, time, style)
	style = style or Enum.EasingStyle.Quart
	TweenService:Create(obj, TweenInfo.new(time or 0.25, style), props):Play()
end

-- Main library table
function Phantom:CreateWindow(cfg)
	local Window = {
		Name = cfg.Name or "Phantom",
		Flags = {},
		Tabs = {},
		CurrentTab = nil,
	}

	-- Main frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, 680, 0, 520)
	MainFrame.Position = UDim2.new(0.5, -340, 0.5, -260)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 8)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.BorderAccent
	MainStroke.Thickness = 1.5
	MainStroke.Parent = MainFrame

	-- Title bar
	local TitleBar = Instance.new("Frame")
	TitleBar.Size = UDim2.new(1, 0, 0, 42)
	TitleBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	TitleBar.BorderSizePixel = 0
	TitleBar.Parent = MainFrame

	local TitleCorner = Instance.new("UICorner")
	TitleCorner.CornerRadius = UDim.new(0, 8)
	TitleCorner.Parent = TitleBar

	local TitleText = Instance.new("TextLabel")
	TitleText.Size = UDim2.new(1, -20, 1, 0)
	TitleText.Position = UDim2.new(0, 15, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Text = Window.Name
	TitleText.TextColor3 = Theme.Text
	TitleText.TextSize = 18
	TitleText.Font = Enum.Font.Code
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Parent = TitleBar

	-- Dragging
	local dragging, dragInput, dragStart, startPos
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
		end
	end)
	TitleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	-- Tabs bar
	local TabsBar = Instance.new("Frame")
	TabsBar.Size = UDim2.new(1, 0, 0, 34)
	TabsBar.Position = UDim2.new(0, 0, 0, 42)
	TabsBar.BackgroundColor3 = Theme.Background2
	TabsBar.BorderSizePixel = 0
	TabsBar.Parent = MainFrame

	local TabsLayout = Instance.new("UIListLayout")
	TabsLayout.FillDirection = Enum.FillDirection.Horizontal
	TabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabsLayout.Padding = UDim.new(0, 4)
	TabsLayout.Parent = TabsBar

	local TabsContainer = Instance.new("Frame")
	TabsContainer.Size = UDim2.new(1, 0, 1, -76)
	TabsContainer.Position = UDim2.new(0, 0, 0, 76)
	TabsContainer.BackgroundTransparency = 1
	TabsContainer.Parent = MainFrame

	-- Create a new tab
	function Window:CreateTab(cfg)
		local Tab = {
			Name = cfg.Name or "Tab",
			Sections = {},
		}

		-- Tab button
		local TabButton = Instance.new("TextButton")
		TabButton.Size = UDim2.new(0, 120, 1, 0)
		TabButton.BackgroundColor3 = Theme.Background2
		TabButton.BorderSizePixel = 0
		TabButton.Text = Tab.Name:upper()
		TabButton.TextColor3 = Theme.TextDim
		TabButton.TextSize = 15
		TabButton.Font = Enum.Font.Code
		TabButton.Parent = TabsBar

		local TabBtnCorner = Instance.new("UICorner")
		TabBtnCorner.CornerRadius = UDim.new(0, 6)
		TabBtnCorner.Parent = TabButton

		-- Content frame (hidden until selected)
		local Content = Instance.new("Frame")
		Content.Size = UDim2.new(1, 0, 1, 0)
		Content.BackgroundTransparency = 1
		Content.Visible = false
		Content.Parent = TabsContainer

		-- Left & Right columns
		local Left = Instance.new("ScrollingFrame")
		Left.Size = UDim2.new(0.5, -12, 1, 0)
		Left.Position = UDim2.new(0, 10, 0, 0)
		Left.BackgroundTransparency = 1
		Left.ScrollBarThickness = 3
		Left.ScrollBarImageColor3 = Theme.Accent
		Left.BorderSizePixel = 0
		Left.Parent = Content

		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.Padding = UDim.new(0, 12)
		LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftLayout.Parent = Left

		local Right = Instance.new("ScrollingFrame")
		Right.Size = UDim2.new(0.5, -12, 1, 0)
		Right.Position = UDim2.new(0.5, 2, 0, 0)
		Right.BackgroundTransparency = 1
		Right.ScrollBarThickness = 3
		Right.ScrollBarImageColor3 = Theme.Accent
		Right.BorderSizePixel = 0
		Right.Parent = Content

		local RightLayout = Instance.new("UIListLayout")
		RightLayout.Padding = UDim.new(0, 12)
		RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RightLayout.Parent = Right

		Tab.Content = Content
		Tab.LeftColumn = Left
		Tab.RightColumn = Right

		-- Auto-resize scrolling frames
		local function UpdateScroll(frame, layout)
			layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
			end)
		end
		UpdateScroll(Left, LeftLayout)
		UpdateScroll(Right, RightLayout)

		-- Create section
		function Tab:CreateSection(cfg)
			local Section = {
				Name = cfg.Name or "Section",
				Side = (cfg.Side or "Left"):lower(),
			}

			local Column = (Section.Side == "left") and Left or Right

			local SectionFrame = Instance.new("Frame")
			SectionFrame.BackgroundColor3 = Theme.Background2
			SectionFrame.BorderSizePixel = 0
			SectionFrame.Size = UDim2.new(1, 0, 0, 30)
			SectionFrame.Parent = Column

			local SecCorner = Instance.new("UICorner")
			SecCorner.CornerRadius = UDim.new(0, 6)
			SecCorner.Parent = SectionFrame

			local SecStroke = Instance.new("UIStroke")
			SecStroke.Color = Theme.Border
			SecStroke.Thickness = 1
			SecStroke.Parent = SectionFrame

			-- Title (embedded in top border style)
			local TitleFrame = Instance.new("Frame")
			TitleFrame.Size = UDim2.new(1, 0, 0, 26)
			TitleFrame.BackgroundColor3 = Theme.Background2
			TitleFrame.BorderSizePixel = 0
			TitleFrame.Parent = SectionFrame

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Size = UDim2.new(1, -20, 1, 0)
			TitleLabel.Position = UDim2.new(0, 12, 0, 0)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Text = Section.Name:upper()
			TitleLabel.TextColor3 = Theme.Accent
			TitleLabel.TextSize = 13
			TitleLabel.Font = Enum.Font.Code
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.Parent = TitleFrame

			local TitleLine = Instance.new("Frame")
			TitleLine.Size = UDim2.new(1, 0, 0, 1)
			TitleLine.Position = UDim2.new(0, 0, 1, 0)
			TitleLine.BackgroundColor3 = Theme.BorderAccent
			TitleLine.BorderSizePixel = 0
			TitleLine.Parent = TitleFrame

			-- Content area
			local ContentFrame = Instance.new("Frame")
			ContentFrame.Size = UDim2.new(1, 0, 1, -26)
			ContentFrame.Position = UDim2.new(0, 0, 0, 26)
			ContentFrame.BackgroundTransparency = 1
			ContentFrame.Parent = SectionFrame

			local ContentLayout = Instance.new("UIListLayout")
			ContentLayout.Padding = UDim.new(0, 8)
			ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ContentLayout.Parent = ContentFrame

			local ContentPadding = Instance.new("UIPadding")
			ContentPadding.PaddingLeft = UDim.new(0, 12)
			ContentPadding.PaddingRight = UDim.new(0, 12)
			ContentPadding.PaddingTop = UDim.new(0, 8)
			ContentPadding.PaddingBottom = UDim.new(0, 8)
			ContentPadding.Parent = ContentFrame

			-- Auto size
			ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionFrame.Size = UDim2.new(1, 0, 0, ContentLayout.AbsoluteContentSize.Y + 34)
			end)

			-- Element creators
			function Section:AddToggle(cfg)
				local Toggle = {
					Name = cfg.Name or "Toggle",
					Flag = cfg.Flag,
					Callback = cfg.Callback or function() end,
					Value = cfg.Default or false,
				}

				if Toggle.Flag then Window.Flags[Toggle.Flag] = Toggle.Value end

				local ToggleFrame = Instance.new("Frame")
				ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
				ToggleFrame.BackgroundTransparency = 1
				ToggleFrame.Parent = ContentFrame

				-- Checkbox
				local CheckBox = Instance.new("Frame")
				CheckBox.Size = UDim2.new(0, 20, 0, 20)
				CheckBox.BackgroundColor3 = Theme.Border
				CheckBox.BorderSizePixel = 0
				CheckBox.Parent = ToggleFrame

				local CheckCorner = Instance.new("UICorner")
				CheckCorner.CornerRadius = UDim.new(0, 4)
				CheckCorner.Parent = CheckBox

				local CheckStroke = Instance.new("UIStroke")
				CheckStroke.Color = Theme.Accent
				CheckStroke.Thickness = 1.5
				CheckStroke.Transparency = 1
				CheckStroke.Parent = CheckBox

				local CheckMark = Instance.new("TextLabel")
				CheckMark.Size = UDim2.new(1, 0, 1, 0)
				CheckMark.BackgroundTransparency = 1
				CheckMark.Text = "✓"
				CheckMark.TextColor3 = Theme.Accent
				CheckMark.TextSize = 18
				CheckMark.Font = Enum.Font.Code
				CheckMark.Visible = false
				CheckMark.Parent = CheckBox

				-- Label
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, -30, 1, 0)
				Label.Position = UDim2.new(0, 28, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Text = Toggle.Name
				Label.TextColor3 = Theme.Text
				Label.TextSize = 14
				Label.Font = Enum.Font.Code
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = ToggleFrame

				-- Button
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(1, 0, 1, 0)
				Button.BackgroundTransparency = 1
				Button.Text = ""
				Button.Parent = ToggleFrame

				local function Set(val)
					Toggle.Value = val
					if Toggle.Flag then Window.Flags[Toggle.Flag] = val end

					if val then
						Tween(CheckBox, {BackgroundColor3 = Theme.Accent}, 0.2)
						CheckMark.Visible = true
						Tween(CheckStroke, {Transparency = 0}, 0.2)
					else
						Tween(CheckBox, {BackgroundColor3 = Theme.Border}, 0.2)
						CheckMark.Visible = false
						Tween(CheckStroke, {Transparency = 1}, 0.2)
					end
					Toggle.Callback(val)
				end

				Button.MouseButton1Click:Connect(function()
					Set(not Toggle.Value)
				end)

				Set(Toggle.Value) -- initial state
				return Toggle
			end

			function Section:AddSlider(cfg)
				local Slider = {
					Name = cfg.Name or "Slider",
					Min = cfg.Min or 0,
					Max = cfg.Max or 100,
					Value = cfg.Default or cfg.Min or 0,
					Flag = cfg.Flag,
					Callback = cfg.Callback or function() end,
				}

				if Slider.Flag then Window.Flags[Slider.Flag] = Slider.Value end

				local SliderFrame = Instance.new("Frame")
				SliderFrame.Size = UDim2.new(1, 0, 0, 42)
				SliderFrame.BackgroundTransparency = 1
				SliderFrame.Parent = ContentFrame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(1, 0, 0, 16)
				Label.BackgroundTransparency = 1
				Label.Text = Slider.Name
				Label.TextColor3 = Theme.Text
				Label.TextSize = 14
				Label.Font = Enum.Font.Code
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = SliderFrame

				-- Bar
				local Bar = Instance.new("Frame")
				Bar.Size = UDim2.new(1, 0, 0, 6)
				Bar.Position = UDim2.new(0, 0, 0, 22)
				Bar.BackgroundColor3 = Theme.Border
				Bar.Parent = SliderFrame

				local BarCorner = Instance.new("UICorner")
				BarCorner.CornerRadius = UDim.new(1, 0)
				BarCorner.Parent = Bar

				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new(0, 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.Parent = Bar

				local FillCorner = Instance.new("UICorner")
				FillCorner.CornerRadius = UDim.new(1, 0)
				FillCorner.Parent = Fill

				-- Value text
				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Size = UDim2.new(0, 60, 0, 16)
				ValueLabel.Position = UDim2.new(1, -60, 0, 0)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Text = tostring(math.floor(Slider.Value)) .. "/" .. tostring(Slider.Max)
				ValueLabel.TextColor3 = Theme.TextDim
				ValueLabel.TextSize = 13
				ValueLabel.Font = Enum.Font.Code
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = SliderFrame

				-- Draggable area
				local Hitbox = Instance.new("TextButton")
				Hitbox.Size = UDim2.new(1, 0, 1, 0)
				Hitbox.BackgroundTransparency = 1
				Hitbox.Text = ""
				Hitbox.Parent = Bar

				local dragging = false

				local function Update(val)
					val = math.clamp(val, Slider.Min, Slider.Max)
					Slider.Value = val
					if Slider.Flag then Window.Flags[Slider.Flag] = val end

					local percent = (val - Slider.Min) / (Slider.Max - Slider.Min)
					Fill.Size = UDim2.new(percent, 0, 1, 0)
					ValueLabel.Text = math.floor(val) .. "/" .. Slider.Max
					Slider.Callback(val)
				end

				Hitbox.MouseButton1Down:Connect(function() dragging = true end)
				UserInputService.InputEnded:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
				end)
				UserInputService.InputChanged:Connect(function(i)
					if not dragging or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
					local relX = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					Update(Slider.Min + relX * (Slider.Max - Slider.Min))
				end)

				Update(Slider.Value)
				return Slider
			end

			function Section:AddDropdown(cfg)
				local Dropdown = {
					Name = cfg.Name or "Dropdown",
					Options = cfg.Options or {},
					Value = cfg.Default or (cfg.Options and cfg.Options[1]) or "",
					Flag = cfg.Flag,
					Callback = cfg.Callback or function() end,
				}

				if Dropdown.Flag then Window.Flags[Dropdown.Flag] = Dropdown.Value end

				local DropFrame = Instance.new("Frame")
				DropFrame.Size = UDim2.new(1, 0, 0, 32)
				DropFrame.BackgroundTransparency = 1
				DropFrame.Parent = ContentFrame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(0.6, 0, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = Dropdown.Name
				Label.TextColor3 = Theme.Text
				Label.TextSize = 14
				Label.Font = Enum.Font.Code
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = DropFrame

				-- Selected box
				local Selected = Instance.new("TextButton")
				Selected.Size = UDim2.new(0.4, 0, 1, 0)
				Selected.Position = UDim2.new(0.6, 0, 0, 0)
				Selected.BackgroundColor3 = Theme.Background
				Selected.Text = Dropdown.Value
				Selected.TextColor3 = Theme.Text
				Selected.TextSize = 14
				Selected.Font = Enum.Font.Code
				Selected.Parent = DropFrame

				local SelCorner = Instance.new("UICorner")
				SelCorner.CornerRadius = UDim.new(0, 4)
				SelCorner.Parent = Selected

				local SelStroke = Instance.new("UIStroke")
				SelStroke.Color = Theme.Border
				SelStroke.Thickness = 1
				SelStroke.Parent = Selected

				local Arrow = Instance.new("TextLabel")
				Arrow.Size = UDim2.new(0, 24, 1, 0)
				Arrow.Position = UDim2.new(1, -24, 0, 0)
				Arrow.BackgroundTransparency = 1
				Arrow.Text = "+"
				Arrow.TextColor3 = Theme.Accent
				Arrow.TextSize = 20
				Arrow.Font = Enum.Font.Code
				Arrow.Parent = Selected

				-- List
				local List = Instance.new("Frame")
				List.BackgroundColor3 = Theme.Background2
				List.BorderSizePixel = 0
				List.Visible = false
				List.ZIndex = 100
				List.Parent = DropFrame

				local ListCorner = Instance.new("UICorner")
				ListCorner.CornerRadius = UDim.new(0, 6)
				ListCorner.Parent = List

				local ListStroke = Instance.new("UIStroke")
				ListStroke.Color = Theme.BorderAccent
				ListStroke.Thickness = 1
				ListStroke.Parent = List

				local ListLayout = Instance.new("UIListLayout")
				ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ListLayout.Padding = UDim.new(0, 1)
				ListLayout.Parent = List

				local function BuildList()
					for _, child in ipairs(List:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					for _, opt in ipairs(Dropdown.Options) do
						local Btn = Instance.new("TextButton")
						Btn.Size = UDim2.new(1, 0, 0, 28)
						Btn.BackgroundColor3 = Theme.Background2
						Btn.Text = opt
						Btn.TextColor3 = Theme.Text
						Btn.TextSize = 14
						Btn.Font = Enum.Font.Code
						Btn.Parent = List

						Btn.MouseButton1Click:Connect(function()
							Dropdown.Value = opt
							Selected.Text = opt
							if Dropdown.Flag then Window.Flags[Dropdown.Flag] = opt end
							Dropdown.Callback(opt)
							List.Visible = false
							Arrow.Text = "+"
						end)
					end
					List.Size = UDim2.new(1, 0, 0, #Dropdown.Options * 28 + 10)
				end

				BuildList()

				Selected.MouseButton1Click:Connect(function()
					List.Visible = not List.Visible
					Arrow.Text = List.Visible and "–" or "+"
				end)

				-- Close on outside click (simple)
				Selected.InputBegan:Connect(function(i)
					if i.UserInputType == Enum.UserInputType.MouseButton1 then
						task.wait()
						local conn; conn = UserInputService.InputBegan:Connect(function(i2)
							if i2.UserInputType == Enum.UserInputType.MouseButton1 then
								if not List.Visible then return end
								local mouse = UserInputService:GetMouseLocation()
								local abs = List.AbsolutePosition
								local size = List.AbsoluteSize
								if not (mouse.X >= abs.X and mouse.X <= abs.X + size.X and
										mouse.Y >= abs.Y and mouse.Y <= abs.Y + size.Y) then
									List.Visible = false
									Arrow.Text = "+"
								end
								conn:Disconnect()
							end
						end)
					end
				end)

				return Dropdown
			end

			function Section:AddKeybind(cfg)
				local Keybind = {
					Name = cfg.Name or "Keybind",
					Value = cfg.Default or Enum.KeyCode.Unknown,
					Flag = cfg.Flag,
					Callback = cfg.Callback or function() end,
				}

				if Keybind.Flag then Window.Flags[Keybind.Flag] = Keybind.Value end

				local Frame = Instance.new("Frame")
				Frame.Size = UDim2.new(1, 0, 0, 24)
				Frame.BackgroundTransparency = 1
				Frame.Parent = ContentFrame

				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(0.65, 0, 1, 0)
				Label.BackgroundTransparency = 1
				Label.Text = Keybind.Name
				Label.TextColor3 = Theme.Text
				Label.TextSize = 14
				Label.Font = Enum.Font.Code
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Frame

				local Box = Instance.new("TextButton")
				Box.Size = UDim2.new(0, 80, 0, 22)
				Box.Position = UDim2.new(1, -85, 0.5, -11)
				Box.BackgroundColor3 = Theme.Background
				Box.Text = Keybind.Value.Name or "NONE"
				Box.TextColor3 = Theme.TextDim
				Box.TextSize = 13
				Box.Font = Enum.Font.Code
				Box.Parent = Frame

				local BoxCorner = Instance.new("UICorner")
				BoxCorner.CornerRadius = UDim.new(0, 4)
				BoxCorner.Parent = Box

				local listening = false

				Box.MouseButton1Click:Connect(function()
					if listening then return end
					listening = true
					Box.Text = "..."
					local conn
					conn = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Keybind.Value = input.KeyCode
							Box.Text = input.KeyCode.Name
							if Keybind.Flag then Window.Flags[Keybind.Flag] = input.KeyCode end
							Keybind.Callback(input.KeyCode)
							listening = false
							conn:Disconnect()
						end
					end)
				end)

				return Keybind
			end

			return Section
		end

		-- Tab switching
		TabButton.MouseButton1Click:Connect(function()
			if Window.CurrentTab then
				Window.CurrentTab.Content.Visible = false
			end
			Content.Visible = true
			Window.CurrentTab = Tab

			-- Simple active tab highlight
			for _, btn in ipairs(TabsBar:GetChildren()) do
				if btn:IsA("TextButton") then
					btn.TextColor3 = (btn == TabButton) and Theme.Accent or Theme.TextDim
				end
			end
		end)

		table.insert(Window.Tabs, Tab)

		-- Auto-select first tab
		if #Window.Tabs == 1 then
			TabButton.MouseButton1Click:Wait()
		end

		return Tab
	end

	return Window
end

return Phantom
