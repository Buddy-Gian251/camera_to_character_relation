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

local PARENT
do
	local success, result = pcall(function()
		if gethui then
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

local lock_button = Instance.new("TextButton")
local fake_lag_button = Instance.new("TextButton")
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

makeDraggable(fake_lag_button)
makeDraggable(lock_button)

local lock_connection
local fake_lag__velocity_restore = Vector3.new(0, 0, 0)
local fake_lag_enabled = false
local fake_lag_cf
local fakeLagConnection
local fake_lag_thread

local function toggle_fake_lag()
	local character = SELF.Character
	if not character then return end
	local HRP = character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	fake_lag_enabled = not fake_lag_enabled

	if fake_lag_enabled then
		-- print("Fake lag: ON")

		fake_lag_thread = task.spawn(function()
			local frozen = false
			local storedCF = HRP.CFrame

			while fake_lag_enabled and character and HRP do
				if frozen then
					storedCF = HRP.CFrame
				else
					local freezeCF = storedCF
					local elapsed = 0

					while fake_lag_enabled and elapsed < 0.1 do
						HRP.CFrame = freezeCF
						elapsed += RunService.Heartbeat:Wait()
					end
				end

				frozen = not frozen
				task.wait(0.1)
			end
		end)
	else
		-- print("Fake lag: OFF")
	end
end

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
			local look = cameraPivot.LookVector
			local x, y, z = cameraPivot:ToOrientation()
			local newPivot = CFrame.new(HRP.Position) * CFrame.Angles(0, y, 0)
			HRP:PivotTo(newPivot)
		end)
	end
end

lock_button.Activated:Connect(function()
	if not cam then return end
	toggle_loop_lock()
end)

fake_lag_button.Activated:Connect(toggle_fake_lag)
