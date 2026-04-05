-- =========================================================================
-- AUTOBLOCK DETECTOR V17 [GROUP RANK SECURED]
-- =========================================================================

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- [ SECURITY CONFIGURATION ] --
local GROUP_ID = 9434941
local MIN_RANK = 13

-- Verify Group Rank
local success, rank = pcall(function()
	return LocalPlayer:GetRankInGroup(GROUP_ID)
end)

if not success or rank < MIN_RANK then
	warn("Autoblock Detector: Authorization Denied. Required Rank: " .. MIN_RANK)
	return -- Stops the script from loading for unauthorized users
end

-- [ TOOL CONFIGURATION ] --
local BAIT_ANIM_ID = "rbxassetid://83802329098847"

-- LOGGING THRESHOLDS
local T_RED = 250 
local T_ORANGE = 350 
local SCAN_TIMEOUT = 1.5 

local THEME = {
	BG = Color3.fromRGB(12, 12, 13),
	ACCENT = Color3.fromRGB(0, 140, 255),
	ALERT = Color3.fromRGB(255, 40, 40),
	SUS = Color3.fromRGB(255, 140, 0),
	OFF = Color3.fromRGB(20, 20, 22),
	TEXT = Color3.fromRGB(220, 220, 220)
}

-- =========================================================================
-- 1. GUI INITIALIZATION
-- =========================================================================
local MAX_RANGE = 30 
local currentKeybind = Enum.KeyCode.F
local isBinding = false

local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "V17_AutoblockDetector"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 420)
Main.Position = UDim2.new(0.75, 0, 0.4, 0)
Main.BackgroundColor3 = THEME.BG
Main.BorderSizePixel = 0
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(5, 5, 6)
Title.Text = "  AUTOBLOCK DETECTOR V17"
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Instance.new("UICorner", Title)

local dragging, dragStart, startPos
Title.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
	local delta = i.Position - dragStart
	Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local KeyBtn = Instance.new("TextButton", Main)
KeyBtn.Size = UDim2.new(0.9, 0, 0, 50) 
KeyBtn.Position = UDim2.new(0.05, 0, 0, 50)
KeyBtn.BackgroundColor3 = THEME.OFF
KeyBtn.Text = "SET TRIGGER\n(CURRENT: " .. currentKeybind.Name .. ")"
KeyBtn.TextColor3 = Color3.new(1, 1, 1)
KeyBtn.Font = Enum.Font.GothamBold
KeyBtn.TextSize = 13
Instance.new("UICorner", KeyBtn)

KeyBtn.MouseButton1Click:Connect(function() 
	isBinding = true 
	KeyBtn.Text = "LISTENING: PRESS ANY KEY"
	KeyBtn.BackgroundColor3 = THEME.ACCENT 
end)

UserInputService.InputBegan:Connect(function(i, proc)
	if isBinding then
		if i.UserInputType == Enum.UserInputType.Keyboard or i.UserInputType.Name:find("MouseButton") then
			currentKeybind = i.KeyCode ~= Enum.KeyCode.Unknown and i.KeyCode or i.UserInputType
			KeyBtn.Text = "SET TRIGGER\n(CURRENT: " .. (currentKeybind.Name or tostring(currentKeybind)) .. ")"
			KeyBtn.BackgroundColor3 = THEME.OFF
			isBinding = false
		end
		return 
	end
end)

local RangeDisp = Instance.new("TextLabel", Main)
RangeDisp.Size = UDim2.new(1, 0, 0, 20)
RangeDisp.Position = UDim2.new(0, 0, 0, 110)
RangeDisp.BackgroundTransparency = 1
RangeDisp.Text = "Range Limit: 30 Studs"
RangeDisp.TextColor3 = THEME.TEXT
RangeDisp.Font = Enum.Font.GothamMedium
RangeDisp.TextSize = 11

local SliderB = Instance.new("Frame", Main)
SliderB.Size = UDim2.new(0.8, 0, 0, 4)
SliderB.Position = UDim2.new(0.1, 0, 0, 135)
SliderB.BackgroundColor3 = THEME.OFF

local Knob = Instance.new("Frame", SliderB)
Knob.Size = UDim2.new(0, 14, 0, 14)
Knob.Position = UDim2.new(0.26, -7, 0.5, -7)
Knob.BackgroundColor3 = THEME.ACCENT
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

local sDragging = false
Knob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = true end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sDragging = false end end)
RunService.RenderStepped:Connect(function() if sDragging then
	local p = math.clamp((UserInputService:GetMouseLocation().X - SliderB.AbsolutePosition.X) / SliderB.AbsoluteSize.X, 0, 1)
	Knob.Position = UDim2.new(p, -7, 0.5, -7)
	MAX_RANGE = math.floor(5 + (p * 95))
	RangeDisp.Text = "Range Limit: " .. MAX_RANGE .. " Studs"
end end)

local T_Bait = Instance.new("TextLabel", Main)
T_Bait.Size = UDim2.new(0.43, 0, 0, 30)
T_Bait.Position = UDim2.new(0.05, 0, 0, 155)
T_Bait.BackgroundColor3 = THEME.OFF
T_Bait.Text = "BAIT FIRED"
T_Bait.TextColor3 = Color3.fromRGB(60,60,65)
T_Bait.Font = Enum.Font.GothamBold
T_Bait.TextSize = 10
Instance.new("UICorner", T_Bait)

local T_Logged = Instance.new("TextLabel", Main)
T_Logged.Size = UDim2.new(0.43, 0, 0, 30)
T_Logged.Position = UDim2.new(0.52, 0, 0, 155)
T_Logged.BackgroundColor3 = THEME.OFF
T_Logged.Text = "FLAGGED"
T_Logged.TextColor3 = Color3.fromRGB(60,60,65)
T_Logged.Font = Enum.Font.GothamBold
T_Logged.TextSize = 10
Instance.new("UICorner", T_Logged)

local Scroll = Instance.new("ScrollingFrame", Main)
Scroll.Size = UDim2.new(0, 290, 0, 205)
Scroll.Position = UDim2.new(0.05, 0, 0, 195)
Scroll.BackgroundColor3 = Color3.fromRGB(5,5,6)
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
local Layout = Instance.new("UIListLayout", Scroll)

local function WriteLog(user, result)
	local l = Instance.new("TextLabel", Scroll)
	l.Size = UDim2.new(1, -10, 0, 24)
	l.BackgroundTransparency = 1
	
	local timeStr = (typeof(result) == "number") and (math.floor(result).."ms") or result
	local isFlag = (typeof(result) == "number") and result > 0
	
	l.TextColor3 = THEME.TEXT
	if isFlag then
		if result <= T_RED then l.TextColor3 = THEME.ALERT
		elseif result <= T_ORANGE then l.TextColor3 = THEME.SUS end
	end
	
	l.Text = string.format(" %s %s » %s", (l.TextColor3 == THEME.ALERT and "!" or l.TextColor3 == THEME.SUS and "?" or ">"), user, timeStr)
	l.Font = Enum.Font.Code
	l.TextSize = 10
	l.TextXAlignment = Enum.TextXAlignment.Left
	Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
	task.defer(function() Scroll.CanvasPosition = Vector2.new(0, Scroll.CanvasSize.Y.Offset) end)
end

-- =========================================================================
-- 2. PRECISION LAZY DETECTION
-- =========================================================================
local baitAnim = Instance.new("Animation")
baitAnim.AnimationId = BAIT_ANIM_ID

local function Flash(lbl, col)
	lbl.BackgroundColor3 = col lbl.TextColor3 = Color3.new(1,1,1)
	task.delay(0.25, function() lbl.BackgroundColor3 = THEME.OFF lbl.TextColor3 = Color3.fromRGB(60,60,65) end)
end

local function FindSuspect()
	local closest, bestDist = nil, MAX_RANGE
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end
	
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (p.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude
			if dist <= bestDist then bestDist = dist closest = p end
		end
	end
	return closest
end

local function DoBait()
	local target = FindSuspect()
	local animator = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") and LocalPlayer.Character.Humanoid:FindFirstChildOfClass("Animator")
	
	if not animator then return end
	if not target then
		WriteLog("System", "Nobody In Range")
		return
	end

	Flash(T_Bait, THEME.ACCENT)

	local tAnimator = target.Character:FindFirstChildOfClass("Humanoid"):FindFirstChildOfClass("Animator")
	if not tAnimator then return end

	local initial = {}
	for _, tr in ipairs(tAnimator:GetPlayingAnimationTracks()) do
		initial[tr.Animation.AnimationId] = true
	end

	local startTime = os.clock()
	local tr = animator:LoadAnimation(baitAnim)
	tr.Priority = Enum.AnimationPriority.Action4
	tr:Play(0, 0.00001, 1)

	local foundTime = 0
	local detected = false
	local conn
	
	conn = tAnimator.AnimationPlayed:Connect(function(new)
		if not initial[new.Animation.AnimationId] then
			local prio = new.Priority
			if prio ~= Enum.AnimationPriority.Core and prio ~= Enum.AnimationPriority.Idle then
				foundTime = (os.clock() - startTime) * 1000
				detected = true
				if foundTime <= T_ORANGE then
					Flash(T_Logged, (foundTime <= T_RED and THEME.ALERT or THEME.SUS))
				end
				conn:Disconnect()
			end
		end
	end)

	task.wait(SCAN_TIMEOUT)
	if conn then conn:Disconnect() end
	tr:Stop() tr:Destroy()

	if detected then
		WriteLog(target.Name, foundTime)
	else
		WriteLog(target.Name, "No Reaction")
	end
end

UserInputService.InputBegan:Connect(function(i, proc)
	if proc or isBinding then return end
	if i.KeyCode == currentKeybind or i.UserInputType == currentKeybind then
		DoBait()
	end
end)

print("Autoblock Detector Authorized & Loaded.")