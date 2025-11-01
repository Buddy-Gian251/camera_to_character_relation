-- making scripts is my hobby
-- nicehouse10000e

if _G.c_lock_present and _G.c_lock_present == true then return end
_G.c_lock_present = true

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local info_tween = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local SELF = Players.LocalPlayer
local cam = workspace.CurrentCamera

local PARENT
do
	local success, result = pcall(function()
		if gethui and typeof(gethui) == "function" then -- gethui is not available in studio environments
			return gethui()
		elseif CoreGui:FindFirstChild("RobloxGui") then
			return CoreGui
		else
			return SELF:WaitForChild("PlayerGui")
		end
	end)
	PARENT = (success and result) or SELF:WaitForChild("PlayerGui")
end
print("PARENT: "..PARENT:GetFullName())
task.wait()
local gui = Instance.new("ScreenGui")
gui.Name = "CFrameLockUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 9999
gui.Enabled = true
gui.Parent = PARENT

local currently_dragged = {}

local message = function(title, text, ptime, icon, button1, button2)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = ptime or 3,
			Icon = icon,
			Button1 = button1,
			Button2 = button2
		})
	end)
end

local adjust_layout = function(object, adjust_x, adjust_y)
	local layout = object:FindFirstChildWhichIsA("UIListLayout") or object:FindFirstChildWhichIsA("UIGridLayout")
	local padding = object:FindFirstChildWhichIsA("UIPadding")
	if not layout then
		warn("Layout adjusting error: No UIListLayout or UIGridLayout found inside " .. object.Name)
		return
	end
	local updateCanvasSize = function()
		task.wait()
		local absContentSize = layout.AbsoluteContentSize

		local padX, padY = 0, 0
		if padding then
			padX = (padding.PaddingLeft.Offset + padding.PaddingRight.Offset)
			padY = (padding.PaddingTop.Offset + padding.PaddingBottom.Offset)
		end
		local totalX = absContentSize.X + padX + 10
		local totalY = absContentSize.Y + padY + 10

		if adjust_x and adjust_y then
			object.CanvasSize = UDim2.new(0, totalX, 0, totalY)
		elseif adjust_x then
			object.CanvasSize = UDim2.new(0, totalX, object.CanvasSize.Y.Scale, object.CanvasSize.Y.Offset)
		elseif adjust_y then
			object.CanvasSize = UDim2.new(object.CanvasSize.X.Scale, object.CanvasSize.X.Offset, 0, totalY)
		end
	end
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	object.ChildAdded:Connect(updateCanvasSize)
	object.ChildRemoved:Connect(updateCanvasSize)
	updateCanvasSize()
end

local make_draggable = function(UIItem, y_draggable, x_draggable)
	local dragging = false
	local dragStart = nil
	local startPos = nil
	local holdStartTime = nil
	local holdConnection = nil
	UIItem.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
			input.UserInputType == Enum.UserInputType.Touch then
			holdStartTime = tick()
			dragStart = input.Position
			startPos = UIItem.Position
			holdConnection = RunService.RenderStepped:Connect(function()
				if not dragging and (tick() - holdStartTime) >= 1 then
					message("Drag feature", "you can now drag "..(UIItem.Name or "this UI").." anywhere.", 2)
					dragging = true
					currently_dragged[UIItem] = true
					holdConnection:Disconnect()
					holdConnection = nil
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if holdConnection then
						holdConnection:Disconnect()
						holdConnection = nil
					end
					if dragging then
						dragging = false
						task.delay(0.5, function()
							currently_dragged[UIItem] = nil
						end)
					end
				end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
			input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart

			local newXOffset = x_draggable ~= false and (startPos.X.Offset + delta.X) or startPos.X.Offset
			local newYOffset = y_draggable ~= false and (startPos.Y.Offset + delta.Y) or startPos.Y.Offset

			UIItem.Position = UDim2.new(
				startPos.X.Scale, newXOffset,
				startPos.Y.Scale, newYOffset
			)
		end
	end)
end

local lock_button = Instance.new("TextButton")
local fake_lag_button = Instance.new("TextButton")
local config_frame = Instance.new("ScrollingFrame")
local config_toggle = Instance.new("TextButton")
local config_layout = Instance.new("UIListLayout")
lock_button.Parent = gui
lock_button.Size = UDim2.new(0, 100, 0, 50)
lock_button.Position = UDim2.new(0.5, -50, 0.5, 20)
lock_button.Text = "CFRAME LOCK"
lock_button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
lock_button.TextColor3 = Color3.fromRGB(0, 0, 0)
lock_button.BorderSizePixel = 0
lock_button.Font = Enum.Font.GothamBold
fake_lag_button.Parent = gui
fake_lag_button.Size = UDim2.new(0, 100, 0, 50)
fake_lag_button.Position = UDim2.new(0.5, -50, 0.5, 60)
fake_lag_button.Text = "FAKE LAG"
fake_lag_button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
fake_lag_button.TextColor3 = Color3.fromRGB(0, 0, 0)
fake_lag_button.BorderSizePixel = 0
fake_lag_button.Font = Enum.Font.GothamBold
config_frame.Parent = gui
config_frame.Visible = true
config_frame.Position = UDim2.new(0.5, -50, 0.5, 100)
config_frame.Size = UDim2.new(0, 200, 0, 250)
config_frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
config_frame.BorderSizePixel = 0
config_toggle.Parent = gui
config_toggle.Visible = true
config_toggle.Position = UDim2.new(0.5, -50, 0.5, -140)
config_toggle.Size = UDim2.new(0, 100, 0, 50)
config_toggle.Text = "CONFIG"
config_toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
config_toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
config_toggle.BorderSizePixel = 0
config_toggle.Font = Enum.Font.GothamBold
config_layout.Parent = config_frame
config_layout.SortOrder = Enum.SortOrder.LayoutOrder
config_layout.Padding = UDim.new(0, 10)
config_layout.VerticalAlignment = Enum.VerticalAlignment.Top
config_layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
config_layout.FillDirection = Enum.FillDirection.Vertical
config_layout.HorizontalFlex = Enum.UIFlexAlignment.None
config_layout.VerticalFlex = Enum.UIFlexAlignment.None

make_draggable(lock_button,true,true)
make_draggable(fake_lag_button,true,true)
make_draggable(config_frame,true,true)
make_draggable(config_toggle,true,true)
adjust_layout(config_frame,false,true)

local freezeDuration = 0.20
local lagRate = 10

local fl_config_minimized = false
local lock_connection
local fake_lag_enabled = false
local fake_lag_cf
local fakeLagConnection
local fake_lag_thread

local create_config_button = function(name, variable, callback)
	local config__main = Instance.new("Frame")
	local config__title = Instance.new("TextLabel")
	local config__editable :TextButton
	if typeof(variable) == "boolean" then
		config__editable = Instance.new("TextButton")
	elseif typeof(variable) == "number" then
		config__editable = Instance.new("TextBox")
	elseif typeof(variable) == "string" then
		config__editable = Instance.new("TextBox")
	else
		config__editable = Instance.new("TextLabel") -- fallback to read-only
	end
	config__main.Parent = config_frame
	config__main.Size = UDim2.new(1, 0, 0, 30)
	config__title.Parent = config__main
	config__title.Visible = true
	config__title.Position = UDim2.new(0, 0, 0, 0)
	config__title.Text = tostring(name)
	config__title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	config__title.Size = UDim2.new(0.5, 0, 1, 0)
	config__title.Font = Enum.Font.GothamBold
	config__title.TextColor3 = Color3.fromRGB(0, 0, 0)
	config__title.TextScaled = true
	config__title.TextXAlignment = Enum.TextXAlignment.Left
	config__editable.Parent = config__main
	config__editable.Visible = true
	config__editable.Position = UDim2.new(0.5, 0, 0, 0)
	config__editable.Text = tostring(variable)
	config__editable.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	config__editable.Size = UDim2.new(0.5, 0, 1, 0)
	config__editable.Font = Enum.Font.GothamBold
	config__editable.TextColor3 = Color3.fromRGB(0, 0, 0)
	config__editable.TextScaled = true
	config__editable.TextXAlignment = Enum.TextXAlignment.Left
	if config__editable:IsA("TextBox") then
		config__editable.PlaceholderText = tostring(variable)
		config__editable.FocusLost:Connect(function(enterpress)
			local newtxt = config__editable.Text
			if newtxt and newtxt ~= "" and (callback and typeof(callback) == "function") then
				callback(newtxt)
			end
		end)
	elseif config__editable:IsA("TextButton") then
		config__editable.MouseButton1Click:Connect(function()
			if (callback and typeof(callback) == "function") then
				callback()
			end
		end)
	end
end

local tween_object = function(object,tweeninfo,properties)
	if not object or object == nil then return end
	if not properties or typeof(properties) ~= "table" or properties == {} then return end
	if not tweeninfo then
		tweeninfo = TweenInfo.new(1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut)
	end

	local tween = TweenService:Create(object,tweeninfo,properties)
	tween:Play()
end

local toggle_fake_lag = function()
	local character = SELF.Character
	if not character then return end
	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end
	
	fake_lag_enabled = not fake_lag_enabled
	
	if fake_lag_enabled then
		message("Fake Lag", "Enabled", 3)
		local unfreezeDuration = freezeDuration / lagRate
		local frozen = false
		local storedCF = HRP.CFrame
		local timer = 0
		fakeLagConnection = RunService.PreRender:Connect(function(dt)
			if not HRP or not HRP.Parent then
				if fakeLagConnection then
					fakeLagConnection:Disconnect()
					fakeLagConnection = nil
				end
				fake_lag_enabled = false
				return
			end
			timer += dt
			if frozen then
				HRP.CFrame = storedCF
				if timer >= freezeDuration then
					timer = 0
					frozen = false
				end
			else
				storedCF = HRP.CFrame
				if timer >= unfreezeDuration then
					timer = 0
					frozen = true
				end
			end
		end)
	else
		if fakeLagConnection then
			fakeLagConnection:Disconnect()
			fakeLagConnection = nil
		end
		message("Fake Lag", "Disabled", 3)
	end
end

local toggle_loop_lock = function()
	if lock_connection then
		lock_connection:Disconnect()
		lock_connection = nil
	else
		lock_connection = RunService.PreRender:Connect(function()
			if not cam then return end
			local character = SELF.Character
			local HRP = character:FindFirstChild("HumanoidRootPart")
			if not character or not HRP then return end
			local cameraPivot = cam.CFrame
			local look = cameraPivot.LookVector
			local x, y, z = cameraPivot:ToOrientation()
			local newPivot = CFrame.new(HRP.Position) * CFrame.Angles(0, y, 0)
			HRP:PivotTo(newPivot)
		end)
	end
end

create_config_button("lag interval", freezeDuration, function(new_value)
	freezeDuration = tonumber(new_value)
end)

create_config_button("lag rate", lagRate, function(new_value)
	lagRate = tonumber(new_value)
end)

lock_button.Activated:Connect(function()
	if next(currently_dragged) then return end
	if not cam then return end
	toggle_loop_lock()
end)

fake_lag_button.Activated:Connect(function()
	if next(currently_dragged) then return end
	toggle_fake_lag()
end)

config_toggle.Activated:Connect(function()
	if next(currently_dragged) then return end
	config_frame.Visible = not config_frame.Visible
end)
