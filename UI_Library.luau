local Library, ScreenGui = { Toggle = true, FirstTab = nil, TabCount = 0, ColorTable = {} }
local textures, isTopBarEnabled, UserInputService, resizing, DraggingGUI, Mouse, DraggingSlider =
	{
		Y = "rbxasset://textures/StudioUIEditor/icon_resize4.png",
		X = "rbxasset://textures/StudioUIEditor/icon_resize2.png",
		CornerTLBR = "rbxasset://textures/StudioUIEditor/icon_resize3.png",
		CornerBLTR = "rbxasset://textures/StudioUIEditor/icon_resize1.png",
	}, true
local gs = game.GetService
local rs = gs(game, "RunService")
local function BlockCameraRotation()
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		local fixedcams = {}
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			local Camera = workspace.CurrentCamera
			if not table.find(fixedcams, Camera) then
				table.insert(fixedcams, Camera)
				local CurrentCameraCF = Camera.CFrame
				-- local CFRot = Camera.CFrame.Rotation
				-- RunService:BindToRenderStep("BC", Enum.RenderPriority.Input.Value - 1, function()
				-- 	if not (DraggingGUI or resizing) then
				-- 		pcall(RunService.UnbindFromRenderStep, RunService, "BC")
				-- 		return
				-- 	end
				-- 	Camera.CFrame = CFRot + Camera.CFrame.Position
				-- end)

				while DraggingGUI or resizing do
					Camera.CFrame = CurrentCameraCF
					rs.Heartbeat:Wait()
				end
			end
		end)
		local Camera = workspace.CurrentCamera
		if not table.find(fixedcams, Camera) then
			table.insert(fixedcams, Camera)
			local CurrentCameraCF = Camera.CFrame
			-- local CFRot = Camera.CFrame.Rotation
			-- RunService:BindToRenderStep("BC", Enum.RenderPriority.Input.Value - 1, function()
			-- 	if not (DraggingGUI or resizing) then
			-- 		pcall(RunService.UnbindFromRenderStep, RunService, "BC")
			-- 		return
			-- 	end
			-- 	Camera.CFrame = CFRot + Camera.CFrame.Position
			-- end)
			coroutine.wrap(function()
				while DraggingGUI or resizing do
					Camera.CFrame = CurrentCameraCF
					rs.Heartbeat:Wait()
				end
			end)()
		end
		-- Camera.CFrame = CFRot + Camera.CFrame.Position
		-- RunService.Heartbeat:Wait()
	end
end
local function MakeDraggable(ClickObject, Object)
	local DragInput
	local DragStart
	local StartPosition

	ClickObject.InputBegan:Connect(function(Input)
		if
			not resizing
			and (
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			)
		then
			DraggingGUI = true
			DragStart = Input.Position
			StartPosition = Object.Position

			BlockCameraRotation()

			Input.Changed:Connect(function()
				if Input.UserInputState == Enum.UserInputState.End then
					DraggingGUI = false
				end
			end)
		end
	end)

	ClickObject.InputChanged:Connect(function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseMovement
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			DragInput = Input
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if Input == DragInput and DraggingGUI then
			local Delta = Input.Position - DragStart
			Object.Position = UDim2.new(
				StartPosition.X.Scale + (Object.Position.X.Offset + Delta.X) / workspace.CurrentCamera.ViewportSize.X,
				StartPosition.X.Offset,
				StartPosition.Y.Scale + (Object.Position.Y.Offset + Delta.Y) / workspace.CurrentCamera.ViewportSize.Y,
				StartPosition.Y.Offset
			)
		end
	end)
end
local function inRange(n1, n2, range)
	return n1 > n2 - range / 2 and n1 < n2 + range / 2
end
local function MakeResizeable(Object)
	local moving = false
	local oldMousePos = Vector2.zero

	local xL = false
	local xR = false
	local yT = false
	local yB = false
	local prevMouseIcon = Mouse.Icon
	UserInputService.InputBegan:Connect(function(input)
		if
			not DraggingGUI
			and (
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local mLocation = UserInputService:GetMouseLocation()
			if isTopBarEnabled then
				mLocation = mLocation - Vector2.new(0, 36)
			end
			local absPos = Object.AbsolutePosition
			local absSize = Object.AbsoluteSize

			xR = inRange(mLocation.X, absPos.X + absSize.X, 10)
				and inRange(mLocation.Y, absPos.Y + absSize.Y / 2, absSize.Y + 10)
			xL = not xR
				and inRange(mLocation.X, absPos.X, 10)
				and inRange(mLocation.Y, absPos.Y + absSize.Y / 2, absSize.Y + 10)
			yB = inRange(mLocation.Y, absPos.Y + absSize.Y, 10)
				and inRange(mLocation.X, absPos.X + absSize.X / 2, absSize.X + 10)
			yT = inRange(mLocation.Y, absPos.Y, 10) and inRange(mLocation.X, absPos.X + absSize.X / 2, absSize.X + 10)

			if yB or yT or xR or xL then
				Mouse.Icon = (xR or xL) and not (yB or yT) and textures.X
					or (yB or yT) and not (xR or xL) and textures.Y
					or ((yT and xL) or (yB and xR)) and textures.CornerTLBR
					or ((yB and xL) or (yT and xR)) and textures.CornerBLTR
				resizing = true
				moving = true
				oldMousePos = mLocation
				BlockCameraRotation()
			end
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if
			moving
			and (
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			)
		then
			local mLocation = UserInputService:GetMouseLocation()
			if isTopBarEnabled then
				mLocation = mLocation - Vector2.new(0, 36)
			end
			if xR then
				local Delta = mLocation - oldMousePos
				Object.Size = Object.Size
					+ UDim2.fromScale((Object.Size.X.Offset + Delta.X) / workspace.CurrentCamera.ViewportSize.X)
			elseif xL then
				local Delta = mLocation - oldMousePos
				Object.Size = Object.Size
					- UDim2.fromScale((Object.Size.X.Offset + Delta.X) / workspace.CurrentCamera.ViewportSize.X)
			end

			if yT then
				local Delta = mLocation - oldMousePos
				Object.Size = Object.Size
					- UDim2.fromScale(0, (Object.Size.Y.Offset + Delta.Y) / workspace.CurrentCamera.ViewportSize.Y)
			elseif yB then
				local Delta = mLocation - oldMousePos
				Object.Size = Object.Size
					+ UDim2.fromScale(0, (Object.Size.Y.Offset + Delta.Y) / workspace.CurrentCamera.ViewportSize.Y)
			end

			oldMousePos = mLocation
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if
			(input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
			and resizing
		then
			moving = false
			xL = false
			xR = false
			yT = false
			yB = false
			resizing = false
			Mouse.Icon = prevMouseIcon
		end
	end)
end

local function randomString()
	local randomarray = {}
	for i = 1, math.random(10, 20) do
		randomarray[i] = string.char(math.random(32, 126))
	end
	return table.concat(randomarray)
end

function Library:CreateWindow(NameWindow, WholeConfigName)
	local MethodContainer = {}
	local Folder = game:GetObjects("rbxassetid://7141683860")[1]
	ScreenGui = Folder.Bracket:Clone()
	ScreenGui.DisplayOrder = 1e3
	ScreenGui.OnTopOfCoreBlur = true
	local MainFrame
	MainFrame = ScreenGui.Main
	MainFrame.Active = true

	local Holder = MainFrame.Holder
	local Topbar = MainFrame.Topbar
	local TContainer = Holder.TContainer
	local TBContainer = Holder.TBContainer.Holder

	Topbar.WindowName.Text = NameWindow
	WholeConfigName = getfenv()[WholeConfigName] or _G[WholeConfigName] or shared[WholeConfigName] or {}
	if not WholeConfigName.GUI_COLOR then
		WholeConfigName.GUI_COLOR = Color3.fromRGB()
	end
	if WholeConfigName.GUI_XY_SCALE_POSITION then
		MainFrame.Position =
			UDim2.fromScale(WholeConfigName.GUI_XY_SCALE_POSITION[1], WholeConfigName.GUI_XY_SCALE_POSITION[2])
	end
	if WholeConfigName.GUI_XY_SCALE_SIZE then
		MainFrame.Size = UDim2.fromScale(WholeConfigName.GUI_XY_SCALE_SIZE[1], WholeConfigName.GUI_XY_SCALE_SIZE[2])
	else
		local cameraconnection
		workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
			if cameraconnection then
				cameraconnection:Disconnect()
			end
			cameraconnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
				MainFrame.Size = UDim2.fromScale(
					500 / workspace.CurrentCamera.ViewportSize.X,
					540 / workspace.CurrentCamera.ViewportSize.Y
				)
			end)
		end)
		cameraconnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			MainFrame.Size = UDim2.fromScale(
				500 / workspace.CurrentCamera.ViewportSize.X,
				540 / workspace.CurrentCamera.ViewportSize.Y
			)
		end)
		MainFrame.Size =
			UDim2.fromScale(500 / workspace.CurrentCamera.ViewportSize.X, 540 / workspace.CurrentCamera.ViewportSize.Y)
	end
	UserInputService = gs(game, "UserInputService")
	MakeDraggable(Topbar, MainFrame)
	local players = gs(game, "Players")
	local client = players.LocalPlayer
	while not client do
		players.ChildAdded:Wait()
		client = players.LocalPlayer
	end
	Mouse = client:GetMouse()
	MakeResizeable(MainFrame)
	local function CloseAll()
		for _, Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				Tab.Visible = false
			end
		end
	end
	local function ResetAll()
		for _, TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.BackgroundTransparency = 1
			end
		end
		for _, TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				TabButton.Size = UDim2.new(0, 480 / Library.TabCount, 1, 0)
			end
		end
		for _, Pallete in pairs(ScreenGui:GetChildren()) do
			if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
				Pallete.Visible = false
			end
		end
	end
	local function KeepFirst()
		for _, Tab in pairs(TContainer:GetChildren()) do
			if Tab:IsA("ScrollingFrame") then
				if Tab.Name == Library.FirstTab .. " T" then
					Tab.Visible = true
				else
					Tab.Visible = false
				end
			end
		end
		for _, TabButton in pairs(TBContainer:GetChildren()) do
			if TabButton:IsA("TextButton") then
				if TabButton.Name == Library.FirstTab .. " TB" then
					TabButton.BackgroundTransparency = 0
				else
					TabButton.BackgroundTransparency = 1
				end
			end
		end
	end
	local function Toggle(State)
		if State then
			MainFrame.Visible = true
		else
			for _, Pallete in pairs(ScreenGui:GetChildren()) do
				if Pallete:IsA("Frame") and Pallete.Name ~= "Main" then
					Pallete.Visible = false
				end
			end
			ScreenGui.ToolTip.Visible = false
			MainFrame.Visible = false
		end
		Library.Toggle = State
	end
	local function ChangeColor(Color)
		if WholeConfigName then
			WholeConfigName.GUI_COLOR = Color
		end
		for i, v in pairs(Library.ColorTable) do
			if v.BackgroundColor3 ~= Color3.fromRGB(50, 50, 50) then
				v.BackgroundColor3 = Color
			end
		end
	end

	function MethodContainer:Toggle(State)
		Toggle(State)
	end

	function MethodContainer:ChangeColor(Color)
		ChangeColor(Color)
	end

	function MethodContainer:SetBackground(ImageId)
		WholeConfigName.GUI_WALLPAPER = ImageId
		Holder.Image = "rbxassetid://" .. ImageId
	end

	function MethodContainer:SetBackgroundColor(Color)
		WholeConfigName.GUI_WALLPAPER_COLOR = Color
		Holder.ImageColor3 = Color
	end
	function MethodContainer:SetBackgroundTransparency(Transparency)
		WholeConfigName.GUI_WALLPAPER_TRANSPARENCY = Transparency
		Holder.ImageTransparency = Transparency
	end

	function MethodContainer:SetTileOffset(Offset)
		Holder.TileSize = UDim2.new(0, Offset, 0, Offset)
	end
	function MethodContainer:SetTileScale(Scale)
		WholeConfigName.GUI_WALLPAPER_SCALE = Scale
		Holder.TileSize = UDim2.new(Scale, 0, Scale, 0)
	end

	rs.RenderStepped:Connect(function()
		if Library.Toggle then
			ScreenGui.ToolTip.Position =
				UDim2.new(0, UserInputService:GetMouseLocation().X + 10, 0, UserInputService:GetMouseLocation().Y - 5)
		end
	end)

	function MethodContainer:CreateTab(NameTab)
		local TabInit = {}
		local Tab = Folder.Tab:Clone()
		local TabButton = Folder.TabButton:Clone()

		Tab.Name = NameTab .. " T"
		Tab.Parent = TContainer

		TabButton.Name = NameTab .. " TB"
		TabButton.Parent = TBContainer
		TabButton.Title.Text = NameTab
		TabButton.BackgroundColor3 = WholeConfigName.GUI_COLOR

		table.insert(Library.ColorTable, TabButton)
		Library.TabCount = Library.TabCount + 1
		if Library.TabCount == 1 then
			Library.FirstTab = NameTab
		end

		CloseAll()
		ResetAll()
		KeepFirst()

		TabButton.MouseButton1Click:Connect(function()
			CloseAll()
			ResetAll()
			Tab.Visible = true
			TabButton.BackgroundTransparency = 0
		end)

		local function GetSide(Longest)
			if Longest then
				if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
					return Tab.LeftSide
				else
					return Tab.RightSide
				end
			else
				if Tab.LeftSide.ListLayout.AbsoluteContentSize.Y > Tab.RightSide.ListLayout.AbsoluteContentSize.Y then
					return Tab.RightSide
				else
					return Tab.LeftSide
				end
			end
		end

		Tab.LeftSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if GetSide(true).Name == Tab.LeftSide.Name then
				Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.LeftSide.ListLayout.AbsoluteContentSize.Y + 15)
			else
				Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.RightSide.ListLayout.AbsoluteContentSize.Y + 15)
			end
		end)
		Tab.RightSide.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if GetSide(true).Name == Tab.LeftSide.Name then
				Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.LeftSide.ListLayout.AbsoluteContentSize.Y + 15)
			else
				Tab.CanvasSize = UDim2.new(0, 0, 0, Tab.RightSide.ListLayout.AbsoluteContentSize.Y + 15)
			end
		end)

		function TabInit:CreateSection(NameSection)
			local SectionInit = {}
			local Section = Folder.Section:Clone()
			Section.Name = NameSection .. " S"
			Section.Parent = GetSide(false)

			Section.Title.Text = NameSection
			Section.Title.Size = UDim2.new(0, Section.Title.TextBounds.X + 10, 0, 2)

			Section.Container.ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section.Size = UDim2.new(1, 0, 0, Section.Container.ListLayout.AbsoluteContentSize.Y + 15)
			end)

			function SectionInit:CreateLabel(NameLabel, RichText)
				local LabelInit = {}
				local Label = Folder.Label:Clone()
				Label.Name = NameLabel .. " L"
				Label.Parent = Section.Container
				if RichText then
					Label.RichText = RichText
				end
				Label.Text = NameLabel
				Label.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y)
				function LabelInit:UpdateText(Text)
					Label.Text = Text
					Label.Size = UDim2.new(1, -10, 0, Label.TextBounds.Y)
				end
				function LabelInit:Remove()
					Label:Destroy()
					Label = nil
				end
				return LabelInit
			end
			function SectionInit:CreateButton(NameButton, CallbackButton)
				local ButtonInit = {}
				local Button = Folder.Button:Clone()
				Button.Name = NameButton .. " B"
				Button.Parent = Section.Container
				Button.Title.Text = NameButton
				Button.Size = UDim2.new(1, -10, 0, Button.Title.TextBounds.Y + 5)
				table.insert(Library.ColorTable, Button)

				Button.MouseButton1Down:Connect(function()
					Button.BackgroundColor3 = WholeConfigName.GUI_COLOR
				end)

				Button.MouseButton1Up:Connect(function()
					Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end)

				Button.MouseLeave:Connect(function()
					Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
				end)

				Button.MouseButton1Click:Connect(CallbackButton)

				function ButtonInit:AddToolTip(NameToolTip)
					if tostring(NameToolTip):gsub(" ", "") ~= "" then
						Button.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = NameToolTip
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						Button.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end

				return ButtonInit
			end
			function SectionInit:CreateTextBox(NameTextBox, PlaceHolder, NumbersOnly, CallbackTextBox, NonEditable)
				local TextBoxInit = {}
				local TextBox = Folder.TextBox:Clone()
				TextBox.Name = NameTextBox .. " T"
				TextBox.Parent = Section.Container
				TextBox.Title.Text = NameTextBox
				if NonEditable then
					TextBox.Background.Input.TextEditable = false
					TextBox.Background.Input.Text = PlaceHolder
				end
				TextBox.Background.Input.PlaceholderText = PlaceHolder
				TextBox.Title.Size = UDim2.new(1, 0, 0, TextBox.Title.TextBounds.Y + 5)
				TextBox.Size = UDim2.new(1, -10, 0, TextBox.Title.TextBounds.Y + 25)
				if CallbackTextBox then
					TextBox.Background.Input.FocusLost:Connect(function()
						if NumbersOnly and not tonumber(TextBox.Background.Input.Text) then
							CallbackTextBox(tonumber(TextBox.Background.Input.Text))
						else
							CallbackTextBox(TextBox.Background.Input.Text)
						end
					end)
				end
				function TextBoxInit:SetValue(String)
					if CallbackTextBox then
						CallbackTextBox(String)
					end
					TextBox.Background.Input.Text = String
				end
				function TextBoxInit:AddToolTip(NameToolTip)
					if tostring(NameToolTip):gsub(" ", "") ~= "" then
						TextBox.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = NameToolTip
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						TextBox.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end
				return TextBoxInit
			end
			function SectionInit:CreateToggle(NameToggle, Default, CallbackToggle)
				local ToggleInit = {}
				local Toggle = Folder.Toggle:Clone()
				Toggle.Name = NameToggle .. " T"
				Toggle.Parent = Section.Container
				Toggle.Title.Text = NameToggle
				Toggle.Size = UDim2.new(1, -10, 0, Toggle.Title.TextBounds.Y + 5)

				table.insert(Library.ColorTable, Toggle.Toggle)
				local ToggleState = false

				local function SetState(State)
					if State then
						Toggle.Toggle.BackgroundColor3 = WholeConfigName.GUI_COLOR
					else
						Toggle.Toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
					end
					ToggleState = State
					if CallbackToggle then
						CallbackToggle(State)
					end
				end

				Toggle.MouseButton1Click:Connect(function()
					ToggleState = not ToggleState
					SetState(ToggleState)
				end)
				if Default then
					coroutine.wrap(SetState)(Default)
				end
				function ToggleInit:AddToolTip(NameToolTip)
					if tostring(NameToolTip):gsub(" ", "") ~= "" then
						Toggle.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = NameToolTip
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						Toggle.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end
				function ToggleInit:SetState(State)
					SetState(State)
				end
				function ToggleInit:GetState()
					return ToggleState
				end

				function ToggleInit:CreateKeybind(Bind, CallbackKeybind)
					local KeybindInit = {}
					Bind = Bind or "NONE"

					local WaitingForBind = false
					local Selected = Bind
					local Blacklist = {
						W = true,
						A = true,
						S = true,
						D = true,
						Slash = true,
						Tab = true,
						Backspace = true,
						Escape = true,
						Space = true,
						Delete = true,
						Unknown = true,
						Backquote = true,
					}

					Toggle.Keybind.Visible = true
					Toggle.Keybind.Text = "[ " .. Bind .. " ]"

					Toggle.Keybind.MouseButton1Click:Connect(function()
						Toggle.Keybind.Text = "[ ... ]"
						WaitingForBind = true
					end)

					Toggle.Keybind:GetPropertyChangedSignal("TextBounds"):Connect(function()
						Toggle.Keybind.Size = UDim2.new(0, Toggle.Keybind.TextBounds.X, 1, 0)
						Toggle.Title.Size = UDim2.new(1, -Toggle.Keybind.Size.X.Offset - 15, 1, 0)
					end)

					UserInputService.InputBegan:Connect(function(Input)
						if WaitingForBind and Input.UserInputType == Enum.UserInputType.Keyboard then
							local Key = Input.KeyCode.Name
							if not Blacklist[Key] then
								Toggle.Keybind.Text = "[ " .. Key .. " ]"
								Selected = Key
								CallbackKeybind(Key)
							else
								Toggle.Keybind.Text = "[ NONE ]"
								Selected = "NONE"
							end
							WaitingForBind = false
						elseif Input.UserInputType == Enum.UserInputType.Keyboard then
							local Key = Input.KeyCode.Name
							if Key == Selected then
								ToggleState = not ToggleState
								SetState(ToggleState)

								CallbackKeybind(Key)
							end
						end
					end)

					function KeybindInit:SetBind(Key)
						Toggle.Keybind.Text = "[ " .. Key .. " ]"
						Selected = Key
					end

					function KeybindInit:GetBind()
						return Selected
					end

					return KeybindInit
				end
				return ToggleInit
			end
			function SectionInit:CreateSlider(NameSlider, Min, Max, Default, Precise, CallbackSlider)
				local SliderInit = {}
				local Slider = Folder.Slider:Clone()
				Slider.Name = NameSlider .. " S"
				Slider.Parent = Section.Container

				Slider.Title.Text = NameSlider
				Slider.Slider.Bar.Size = UDim2.new(Min / Max, 0, 1, 0)
				Slider.Slider.Bar.BackgroundColor3 = WholeConfigName.GUI_COLOR
				Slider.Value.PlaceholderText = tostring(Min / Max)
				Slider.Title.Size = UDim2.new(1, 0, 0, Slider.Title.TextBounds.Y + 5)
				Slider.Size = UDim2.new(1, -10, 0, Slider.Title.TextBounds.Y + 15)
				table.insert(Library.ColorTable, Slider.Slider.Bar)

				local GlobalSliderValue = 0

				local function Sliding(Input)
					local Position = UDim2.new(
						math.clamp(
							(Input.Position.X - Slider.Slider.AbsolutePosition.X) / Slider.Slider.AbsoluteSize.X,
							0,
							1
						),
						0,
						1,
						0
					)
					Slider.Slider.Bar.Size = Position

					local SliderValue = tonumber(
						("%.2f"):format(
							Precise and math.floor(((Position.X.Scale * Max) / Max) * (Max - Min) + Min)
								or ((Position.X.Scale * Max) / Max) * (Max - Min) + Min
						)
					)
					GlobalSliderValue = SliderValue
					Slider.Value.PlaceholderText = tostring(SliderValue)
					CallbackSlider(GlobalSliderValue)
				end
				local function SetValue(Value)
					GlobalSliderValue = Value
					Slider.Slider.Bar.Size = UDim2.fromScale((Value - Min) / (Max - Min), 1)
					Slider.Value.PlaceholderText = Value
					CallbackSlider(Value)
				end
				if Default then
					coroutine.wrap(SetValue)(Default)
				end
				Slider.Value.FocusLost:Connect(function()
					if not tonumber(Slider.Value.Text) then
						Slider.Value.Text = GlobalSliderValue
					elseif Slider.Value.Text == "" or tonumber(Slider.Value.Text) <= Min then
						Slider.Value.Text = Min
					elseif Slider.Value.Text == "" or tonumber(Slider.Value.Text) >= Max then
						Slider.Value.Text = Max
					end

					GlobalSliderValue = Slider.Value.Text
					Slider.Slider.Bar.Size = UDim2.fromScale((Slider.Value.Text - Min) / (Max - Min), 1)
					Slider.Value.PlaceholderText = Slider.Value.Text
					CallbackSlider(tonumber(Slider.Value.Text))
					Slider.Value.Text = ""
				end)

				Slider.InputBegan:Connect(function(Input)
					if
						DraggingSlider == nil
						and (
							Input.UserInputType == Enum.UserInputType.MouseButton1
							or Input.UserInputType == Enum.UserInputType.Touch
						)
					then
						Sliding(Input)
						DraggingSlider = NameSlider
					end
				end)

				Slider.InputEnded:Connect(function(Input)
					if
						DraggingSlider == NameSlider
						and (
							Input.UserInputType == Enum.UserInputType.MouseButton1
							or Input.UserInputType == Enum.UserInputType.Touch
						)
					then
						DraggingSlider = nil
					end
				end)

				UserInputService.InputBegan:Connect(function(Input)
					if Input.KeyCode == Enum.KeyCode.LeftControl then
						Slider.Value.ZIndex = 4
					end
				end)

				UserInputService.InputEnded:Connect(function(Input)
					if Input.KeyCode == Enum.KeyCode.LeftControl then
						Slider.Value.ZIndex = 3
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if
						DraggingSlider == NameSlider
						and (
							Input.UserInputType == Enum.UserInputType.MouseMovement
							or Input.UserInputType == Enum.UserInputType.Touch
						)
					then
						Sliding(Input)
					end
				end)

				function SliderInit:AddToolTip(NameToolTip)
					if tostring(NameToolTip):gsub(" ", "") ~= "" then
						Slider.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = NameToolTip
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						Slider.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end

				function SliderInit:SetValue(Value)
					SetValue(Value)
				end

				function SliderInit:GetValue()
					return GlobalSliderValue
				end

				return SliderInit
			end
			function SectionInit:CreateDropdown(DropdownName, ColoredOptions)
				local DropdownInit = {}
				local Dropdown = Folder.Dropdown:Clone()
				Dropdown.Name = DropdownName .. " D"
				Dropdown.Parent = Section.Container

				Dropdown.Title.Text = DropdownName
				Dropdown.Title.Size = UDim2.new(1, 0, 0, Dropdown.Title.TextBounds.Y + 5)
				Dropdown.Container.Position = UDim2.new(0, 0, 0, Dropdown.Title.TextBounds.Y + 5)
				Dropdown.Size = UDim2.new(1, -10, 0, Dropdown.Title.TextBounds.Y + 25)

				local DropdownToggle = false
				local function DropdownToggler()
					DropdownToggle = not DropdownToggle
					if DropdownToggle then
						Dropdown.Size = UDim2.new(
							1,
							-10,
							0,
							Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y
								+ Dropdown.Title.TextBounds.Y
								+ 30
						)
						Dropdown.Container.Holder.Visible = true
					else
						Dropdown.Size = UDim2.new(1, -10, 0, Dropdown.Title.TextBounds.Y + 25)
						Dropdown.Container.Holder.Visible = false
					end
				end
				Dropdown.MouseButton1Click:Connect(function()
					DropdownToggler()
				end)
				function DropdownInit:AddToolTip(ToolTipName)
					if tostring(ToolTipName):gsub(" ", "") ~= "" then
						Dropdown.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = ToolTipName
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						Dropdown.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end
				function DropdownInit:AddOption(OptionName, CallbackOption, InitialState)
					local OptionInit = {}
					local Option = Folder.Option:Clone()
					Option.Name = OptionName
					local CurrentState = DropdownToggle or nil
					if CurrentState then
						DropdownToggler()
					end
					Option.Parent = Dropdown.Container.Holder.Container

					Option.Title.Text = OptionName
					if ColoredOptions then
						Option.Title.TextColor3 = InitialState and Color3.fromRGB(0, 255, 0)
							or Color3.fromRGB(255, 0, 0)
					end
					Option.BackgroundColor3 = WholeConfigName.GUI_COLOR
					Option.Size = UDim2.new(1, 0, 0, Option.Title.TextBounds.Y + 5)
					Dropdown.Container.Holder.Size =
						UDim2.new(1, -5, 0, Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y)
					if CurrentState then
						DropdownToggler()
					end
					table.insert(Library.ColorTable, Option)

					Option.MouseButton1Down:Connect(function()
						Option.BackgroundTransparency = 0
					end)

					Option.MouseButton1Up:Connect(function()
						Option.BackgroundTransparency = 1
					end)

					Option.MouseLeave:Connect(function()
						Option.BackgroundTransparency = 1
					end)

					function OptionInit:SetOption()
						if ColoredOptions then
							Option.Title.TextColor3 = Option.Title.TextColor3 == Color3.fromRGB(0, 255, 0)
									and Color3.fromRGB(255, 0, 0)
								or Color3.fromRGB(0, 255, 0)
						end
						Dropdown.Container.Value.Text = OptionName
						CallbackOption(OptionName)
					end

					Option.MouseButton1Click:Connect(function()
						OptionInit:SetOption()
					end)

					return OptionInit
				end
				function DropdownInit:ClearOptions()
					for _, Option in ipairs(Dropdown.Container.Holder.Container:GetChildren()) do
						if Option:IsA("TextButton") then
							Option:Destroy()
						end
					end
					Dropdown.Container.Holder.Size =
						UDim2.new(1, -5, 0, Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y)
					Dropdown.Size = UDim2.new(
						1,
						-10,
						0,
						Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y
							+ Dropdown.Title.TextBounds.Y
							+ 30
					)
				end

				function DropdownInit:RemoveOption(OptionName)
					for _, Option in pairs(Dropdown.Container.Holder.Container:GetChildren()) do
						if Option:IsA("TextButton") and Option.Name:find(OptionName) then
							Option:Destroy()
							Dropdown.Container.Holder.Size = UDim2.new(
								1,
								-5,
								0,
								Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y
							)
							if DropdownToggle then
								Dropdown.Size = UDim2.new(
									1,
									-10,
									0,
									Dropdown.Container.Holder.Container.ListLayout.AbsoluteContentSize.Y
										+ Dropdown.Title.TextBounds.Y
										+ 30
								)
							end
						end
					end
				end
				return DropdownInit
			end
			function SectionInit:CreateColorpicker(NameColorpicker, Default, CallbackColorpicker)
				local ColorpickerInit = {}
				local Colorpicker = Folder.Colorpicker:Clone()
				local Pallete = Folder.Pallete:Clone()

				Colorpicker.Name = NameColorpicker .. " CP"
				Colorpicker.Parent = Section.Container
				Colorpicker.Title.Text = NameColorpicker
				Colorpicker.Size = UDim2.new(1, -10, 0, Colorpicker.Title.TextBounds.Y + 5)

				Pallete.Name = NameColorpicker .. " P"
				Pallete.Parent = ScreenGui

				local ColorTable = {
					Hue = 1,
					Saturation = 0,
					Value = 0,
				}
				local ColorRender
				local HueRender
				local ColorpickerRender

				local function UpdateColor()
					Colorpicker.Color.BackgroundColor3 =
						Color3.fromHSV(ColorTable.Hue, ColorTable.Saturation, ColorTable.Value)
					Pallete.GradientPallete.BackgroundColor3 = Color3.fromHSV(ColorTable.Hue, 1, 1)
					Pallete.Input.InputBox.PlaceholderText = "RGB: "
						.. math.round(Colorpicker.Color.BackgroundColor3.R * 255)
						.. ","
						.. math.round(Colorpicker.Color.BackgroundColor3.G * 255)
						.. ","
						.. math.round(Colorpicker.Color.BackgroundColor3.B * 255)
					CallbackColorpicker(Colorpicker.Color.BackgroundColor3)
				end
				if Default then
					ColorTable.Hue, ColorTable.Saturation, ColorTable.Value = Default:ToHSV()
					coroutine.wrap(UpdateColor)()
				end
				Colorpicker.MouseButton1Click:Connect(function()
					if Pallete.Visible then
						Pallete.Visible = false
						ColorpickerRender:Disconnect()
						ColorpickerRender = nil
					else
						ColorpickerRender = rs.RenderStepped:Connect(function()
							Pallete.Position = UDim2.new(
								0,
								Colorpicker.Color.AbsolutePosition.X - 129,
								0,
								Colorpicker.Color.AbsolutePosition.Y + 52
							)
						end)
						Pallete.Visible = true
					end
				end)

				Pallete.GradientPallete.InputBegan:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						if ColorRender then
							ColorRender:Disconnect()
							ColorRender = nil
						end
						ColorRender = rs.RenderStepped:Connect(function()
							local Mouse = UserInputService:GetMouseLocation()
							local ColorX = math.clamp(
								Mouse.X - Pallete.GradientPallete.AbsolutePosition.X,
								0,
								Pallete.GradientPallete.AbsoluteSize.X
							) / Pallete.GradientPallete.AbsoluteSize.X
							local ColorY = math.clamp(
								(Mouse.Y - 37) - Pallete.GradientPallete.AbsolutePosition.Y,
								0,
								Pallete.GradientPallete.AbsoluteSize.Y
							) / Pallete.GradientPallete.AbsoluteSize.Y
							Pallete.GradientPallete.Dot.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorTable.Saturation = ColorX
							ColorTable.Value = 1 - ColorY
							UpdateColor()
						end)
					end
				end)

				Pallete.GradientPallete.InputEnded:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						if ColorRender then
							ColorRender:Disconnect()
							ColorRender = nil
						end
					end
				end)

				Pallete.ColorSlider.InputBegan:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						if HueRender then
							HueRender:Disconnect()
							HueRender = nil
						end
						HueRender = rs.RenderStepped:Connect(function()
							local Mouse = UserInputService:GetMouseLocation()
							local HueX = math.clamp(
								Mouse.X - Pallete.ColorSlider.AbsolutePosition.X,
								0,
								Pallete.ColorSlider.AbsoluteSize.X
							) / Pallete.ColorSlider.AbsoluteSize.X
							ColorTable.Hue = 1 - HueX
							UpdateColor()
						end)
					end
				end)

				Pallete.ColorSlider.InputEnded:Connect(function(Input)
					if
						Input.UserInputType == Enum.UserInputType.MouseButton1
						or Input.UserInputType == Enum.UserInputType.Touch
					then
						if HueRender then
							HueRender:Disconnect()
							HueRender = nil
						end
					end
				end)

				function ColorpickerInit:UpdateColor(Color)
					local Hue, Saturation, Value = Color:ToHSV()
					Colorpicker.Color.BackgroundColor3 = Color3.fromHSV(Hue, Saturation, Value)
					Pallete.GradientPallete.BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)
					Pallete.Input.InputBox.PlaceholderText = "RGB: "
						.. math.round(Colorpicker.Color.BackgroundColor3.R * 255)
						.. ","
						.. math.round(Colorpicker.Color.BackgroundColor3.G * 255)
						.. ","
						.. math.round(Colorpicker.Color.BackgroundColor3.B * 255)
					ColorTable = {
						Hue = Hue,
						Saturation = Saturation,
						Value = Value,
					}
					CallbackColorpicker(Color)
				end

				Pallete.Input.InputBox.FocusLost:Connect(function(Enter)
					if Enter then
						local ColorString = Pallete.Input.InputBox.Text:gsub(" ", ""):split(",")
						ColorpickerInit:UpdateColor(Color3.fromRGB(ColorString[1], ColorString[2], ColorString[3]))
						Pallete.Input.InputBox.Text = ""
					end
				end)

				function ColorpickerInit:AddToolTip(Name)
					if tostring(Name):gsub(" ", "") ~= "" then
						Colorpicker.MouseEnter:Connect(function()
							ScreenGui.ToolTip.Text = Name
							ScreenGui.ToolTip.Size =
								UDim2.new(0, ScreenGui.ToolTip.TextBounds.X + 5, 0, ScreenGui.ToolTip.TextBounds.Y + 5)
							ScreenGui.ToolTip.Visible = true
						end)

						Colorpicker.MouseLeave:Connect(function()
							ScreenGui.ToolTip.Visible = false
						end)
					end
				end

				return ColorpickerInit
			end
			return SectionInit
		end
		return TabInit
	end
	local cg = gs(game, "CoreGui")
	local finder, globalcontainer = loadstring(
		game:HttpGet("https://raw.githubusercontent.com/lua-u/SomeHub/main/UniversalMethodFinder.luau", true)
	)()

	finder({
		ghui = '(...):find("get") and ((...):find("hui") or (...):find("hid") and (...):find("gui"))',
		protgui = '(...):find("protect") and (...):find("gui") and not (...):find("un")',
	})

	if globalcontainer.ghui then
		ScreenGui.Name = randomString()
		ScreenGui.Parent = globalcontainer.ghui()
	elseif globalcontainer.protgui and not (is_sirhurt_closure or (syn and DrawingImmediate)) then
		ScreenGui.Name = randomString()
		globalcontainer.protgui(ScreenGui)
		ScreenGui.Parent = cg
	elseif cg:FindFirstChild("RobloxGui") then
		ScreenGui.Parent = cg.RobloxGui
	else
		ScreenGui.Name = randomString()
		ScreenGui.Parent = cg
	end
	return MethodContainer, MainFrame, ScreenGui
end
return Library
