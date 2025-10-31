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

local button = Instance.new("TextButton")
button.Parent = gui
button.Size = UDim2.new(0, 100, 0, 50)
button.Position = UDim2.new(0.5, -50, 0.5, 20)
button.Text = "CFRAME LOCK"
button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
button.TextColor3 = Color3.fromRGB(0, 0, 0)
button.BorderSizePixel = 0
button.Font = Enum.Font.GothamBold

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
			local look = cameraPivot.LookVector
			local x, y, z = cameraPivot:ToOrientation()
			local newPivot = CFrame.new(HRP.Position) * CFrame.Angles(0, y, 0)
			HRP:PivotTo(newPivot)
		end)
	end
end

button.Activated:Connect(function()
	if not cam then return end
	toggle_loop_lock()
end)
