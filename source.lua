if _G.c_lock_present and _G.c_lock_present == true then return end
_G.c_lock_present = true

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local info_tween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local SELF = Players.LocalPlayer
local cam = workspace.CurrentCamera

local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
local success = pcall(function()
	gui.Parent = CoreGui
end)
if not success then
	gui.Parent = SELF:WaitForChild("PlayerGui")
end

local function makeDraggable(UIItem)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	UIItem.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = UIItem.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
			input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			UIItem.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local button = Instance.new("TextButton")
--local config_frame = Instance.new("Frame")
--local config_layout = Instance.new("UIListLayout")
--local config_toggle = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.5, -50, 0.5, 250)
button.Text = "CFRAME LOCK"
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold
--config_frame.Parent = gui
--config_frame.Size = UDim2.new(0, 250, 0, 250)
--config_frame.AnchorPoint = Vector2.new(0.5, 0.5)
--config_frame.Position = UDim2.new(0.5, 0, 0.75, 0)
--config_frame.Visible = false
--config_layout.Parent = config_frame
--config_layout.Padding = UDim.new(0, 10)
--config_layout.FillDirection = Enum.FillDirection.Vertical
--config_layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
--config_layout.VerticalAlignment = Enum.VerticalAlignment.Top
--config_layout.SortOrder = Enum.SortOrder.LayoutOrder
--config_toggle.Visible = true
--config_toggle.Parent = config_frame
--config_toggle.AnchorPoint = Vector2.new(0, 1)
--config_toggle.Text = "Configuration"

--local function add_configuration(name, variable, callback)
--	local configcontain = Instance.new("Frame")
--	local textBox = Instance.new("TextBox")
--	local config_name = Instance.new("TextLabel")
--	configcontain.Parent = config_frame
--	configcontain.Size = UDim2.new(0, 200, 0, 50)
--	configcontain.Position = UDim2.new(0, 25, 0, 25)
--	configcontain.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
--	configcontain.BorderSizePixel = 0
--	configcontain.Visible = false
--	config_name.Parent = configcontain
--	config_name.Position = UDim2.new(0, 0, 0, 0)
--	config_name.Size = UDim2.new(0.5, 0, 1, 0)
--	config_name.Text = name
--	config_name.TextColor3 = Color3.fromRGB(0, 0, 0)
--	config_name.BackgroundTransparency = 1
--	config_name.BorderSizePixel = 0
--	textBox.Parent = configcontain
--	textBox.Size = UDim2.new(0.5, 0, 1, 0)
--	textBox.Position = UDim2.new(0, 1, 0, 0)
--	textBox.AnchorPoint = Vector2.new(1, 0)
--	textBox.BackgroundTransparency = 1
--	textBox.TextScaled = true
--	textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
--	textBox.FocusLost:Connect(function()
--		callback(textBox.Text)
--	end)
--end

makeDraggable(button)

local lock_connection

local function toggle_loop_lock()
	if lock_connection then
		lock_connection:Disconnect()
		lock_connection = nil
	else
		lock_connection = RunService.RenderStepped:Connect(function()
			if not cam then return end
			local character = SELF.Character
			local HRP = character:FindFirstChild("HumanoidRootPart") :: BasePart
			if not character or not HRP then return end
			local cameraPivot = cam.CFrame
			local look = cam.LookVector
			local yaw = math.atan2(look.X, look.Z)
			local newPivot = CFrame.new(HRP.Position) * CFrame.Angles(0, yaw, 0)
			HRP:PivotTo(newPivot)
		end)
	end
end

button.Activated:Connect(function()
	if not cam then return end
	toggle_loop_lock()
end)
