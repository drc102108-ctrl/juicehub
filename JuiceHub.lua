--[[
	===========================================================
	
  JUICE HUB  —  WalkSpeed · JumpPower · Sticky Head
	============================================================
	 • Toggle GUI: RightControl (edit TOGGLE_KEY below)
	 • Drag the window by its title bar
	 • Sliding switches, live value labels, respawn-safe
	 • Sticky Head pulls the nearest player's head to yours
	   (Pull Strength = force, Stickiness = damping)
	============================================================
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ================= CONFIG =================
local TOGGLE_KEY = Enum.KeyCode.RightControl
local DEFAULT_WALK = 16
local DEFAULT_JUMP = 50
local DEFAULT_PULL = 2.0
local DEFAULT_STICKY = 2.0
local ACCENT = Color3.fromRGB(0, 170, 255)   -- accent color for switches
local BG     = Color3.fromRGB(18, 18, 22)    -- window background
local PANEL  = Color3.fromRGB(28, 28, 34)    -- row background
local TEXT   = Color3.fromRGB(240, 240, 245)

-- ================ STATE ==================
local walkSpeed = DEFAULT_WALK
local jumpPower = DEFAULT_JUMP
local walkEnabled = false
local jumpEnabled = false

local stickyEnabled = false
local pullStrength = DEFAULT_PULL
local stickiness = DEFAULT_STICKY

local humanoid

-- ================ CHARACTER ==============
local function setupCharacter(character)
	humanoid = character:WaitForChild("Humanoid")
	humanoid.UseJumpPower = true

	if walkEnabled then
		humanoid.WalkSpeed = walkSpeed
	end
	if jumpEnabled then
		humanoid.JumpPower = jumpPower
	end
end

if player.Character then
	setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

-- ============ UI HELPERS =================
local function round(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function stroke(obj, thickness, color, transparency)
	local s = Instance.new("UIStroke")
	s.Thickness = thickness
	s.Color = color
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = obj
	return s
end

-- Slide switch: pill with a knob that tweens between sides
local function makeSwitch(parent)
	local holder = Instance.new("TextButton")
	holder.Name = "Switch"
	holder.Size = UDim2.new(0, 46, 0, 24)
	holder.BackgroundColor3 = Color3.fromRGB(55, 55, 62)
	holder.Text = ""
	holder.AutoButtonColor = false
	holder.Parent = parent
	round(holder, 12)
	stroke(holder, 1, Color3.fromRGB(255, 255, 255), 0.85)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 18, 0, 18)
	knob.Position = UDim2.new(0, 3, 0.5, -9)
	knob.BackgroundColor3 = Color#.fromRGB(200, 200, 205)
	knob.Parent = holder
	round(knob, 9)

	local state = false
	local offPos = UDim2.new(0, 3, 0.5, -9)
	local onPos  = UDim2.new(1, -21, 0.5, -9)

	holder.MouseButton1Click:Connect(function()
		state = not state
		local props
		if state then
			props = { Position = onPos, BackgroundColor3 = Color3.fromRGB(255, 255, 255) }
			TweenService:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = ACCENT }):Play()
		else
			props = { Position = offPos, BackgroundColor3 = Color#.fromRGB(200, 200, 205) }
			TweenService:Create(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundColor3 = Color3.fromRGB(55, 55, 62) }):Play()
		end
		TweenService:Create(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
	end)

	return holder, function()
		return state
	end
end

-- ================= WINDOW =================
local gui = Instance.new("ScreenGui")
gui.Name = "JuiceHub"
gui.ResetOnSpawn = false

-- executors can write to CoreGui; Studio/local scripts fall back to PlayerGui
local ok = pcall(function()
	gui.Parent = game:GetService("CoreGui")
end)
if not ok then
	gui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 340, 0, 372)
frame.Position = UDim2.new(0.5, -170, 0.5, -186)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
round(frame, 12)
stroke(frame, 1.5, Color3.fromRGB(255, 255, 255), 0.85)

-- Title bar (also the drag handle)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 44)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
round(titleBar, 12)

-- mask bottom corners of title bar so it looks clipped into the window
local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 14)
titleMask.Position = UDim2.new(0, 0, 1, -14)
titleMask.BackgroundColor3 = PANEL
titleMask.BorderSizePixel = 0
titleMask.Parent = titleBar

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 30, 1, 0)
icon.Position = UDim2.new(0, 12, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "⚡"
icon.TextSize = 20
icon.TextColor3 = ACCENT
icon.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Position = UDim2.new(0, 44, 0, 0)
title.BackgroundTransparency = 1
title.Text = "JUICE HUB"
title.TextColor3 = TEXT
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color#.fromRGB(45, 45, 52)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar
round(closeBtn, 8)

-- ---------- ROW BUILDER ----------
local function makeRow(order, labelText, defaultText, withSwitch)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -24, 0, 48)
	row.Position = UDim2.new(0, 12, 0, 56 + (order - 1) * 58)
	row.BackgroundColor3 = PANEL
	row.BorderSizePixel = 0
	row.Parent = frame
	round(row, 10)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -140, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextColor3 = TEXT
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0, 52, 0, 30)
	box.Position = UDim2.new(1, -110, 0.5, -15)
	box.BackgroundColor3 = Color#.fromRGB(40, 40, 47)
	box.Text = defaultText
	box.TextColor3 = TEXT
	box.TextSize = 14
	box.Font = Enum.Font.GothamBold
	box.PlaceholderText = defaultText
	box.ClearTextOnFocus = false
	box.Parent = row
	round(box, 8)
	stroke(box, 1, Color#.fromRGB(255, 255, 255), 0.88)

	local rowTable = { row = row, label = label, box = box }

	if withSwitch then
		local sw, getState = makeSwitch(row)
		sw.Position = UDim2.new(1, -44, 0.5, -12)
		rowTable.getState = getState
	end

	return rowTable
end

local walkRow   = makeRow(1, "WalkSpeed", tostring(DEFAULT_WALK), true)
local jumpRow   = makeRow(2, "JumpPower", tostring(DEFAULT_JUMP), true)
local stickyRow = makeRow(3, "Sticky Head", "", true)
local pullRow   = makeRow(4, "Pull Strength", string.format("%.1f", DEFAULT_PULL), false)
local stick2Row = makeRow(5, "Stickiness", string.format("%.1f", DEFAULT_STICKY), false)

pullRow.label.Text = "Pull Strength: " .. string.format("%.1f", pullStrength)
stick2Row.label.Text = "Stickiness: " .. string.format("%.1f", stickiness)

-- ---------- FOOTER ----------
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 22)
footer.Position = UDim2.new(0, 12, 1, -30)
footer.BackgroundTransparency = 1
footer.Text = "[" .. TOGGLE_KEY.Name .. "] to hide  •  drag title bar to move"
footer.TextColor3 = Color3.fromRGB(150, 150, 158)
footer.TextSize = 11
footer.Font = Enum.Font.Gotham
footer.Parent = frame

-- ============ VALUE LOGIC ================
local function clampValue(box, default)
	local num = tonumber(box.Text) or default
	num = math.clamp(math.floor(num), 1, 100)
	box.Text = tostring(num)
	return num
end

local function clampFloat(box, default, decimals)
	local num = tonumber(box.Text) or default
	num = math.clamp(num, 0.1, 10)
	box.Text = string.format("%." .. decimals .. "f", num)
	return num
end

walkRow.box.FocusLost:Connect(function()
	walkSpeed = clampValue(walkRow.box, DEFAULT_WALK)
	walkRow.label.Text = "WalkSpeed: " .. walkSpeed

	if walkEnabled and humanoid then
		humanoid.WalkSpeed = walkSpeed
	end
end)

jumpRow.box.FocusLost:Connect(function()
	jumpPower = clampValue(jumpRow.box, DEFAULT_JUMP)
	jumpRow.label.Text = "JumpPower: " .. jumpPower

	if jumpEnabled and humanoid then
		humanoid.JumpPower = jumpPower
	end
end)

pullRow.box.FocusLost:Connect(function()
	pullStrength = clampFloat(pullRow.box, DEFAULT_PULL, 1)
	pullRow.label.Text = "Pull Strength: " .. string.format("%.1f", pullStrength)
end)

stick2Row.box.FocusLost:Connect(function()
	stickiness = clampFloat(stick2Row.box, DEFAULT_STICKY, 1)
	stick2Row.label.Text = "Stickiness: " .. string.format("%.1f", stickiness)
end)

-- ============ STICKY HEAD LOGIC ==========
local function cleanupSticky()
	for _, other in ipairs(Players:GetPlayers()) do
		local oc = other.Character
		local oh = oc and oc:FindFirstChild("Head")
		if oh then
			local bp = oh:FindFirstChild("StickyBP")
			if bp then
				bp:Destroy()
			end
		end
	end
end

RunService.RenderStepped:Connect(function()
	if not stickyEnabled then return end

	local char = player.Character
	local myHead = char and char:FindFirstChild("Head")
	if not myHead then return end

	-- nearest alive player's head
	local nearest, nearestDist
	for _, other in ipairs(Players:GetPlayers()) do
		if other ~= player then
			local oc = other.Character
			local oh = oc and oc:FindFirstChild("Head")
			local ohum = oc and oc:FindFirstChildOfClass("Humanoid")
			if oh and ohum and ohum.Health > 0 then
				local d = (myHead.Position - oh.Position).Magnitude
				if d <= 500 and (not nearestDist or d < nearestDist) then
					nearestDist = d
					nearest = oh
				end
			end
		end
	end

	if nearest then
		local bp = nearest:FindFirstChild("StickyBP")
		if not bp then
			bp = Instance.new("BodyPosition")
			bp.Name = "StickyBP"
			bp.Parent = nearest
		end
		bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bp.P = 5000 * pullStrength
		bp.D = 400 * stickiness
		bp.Position = myHead.Position
	end
end)

-- ============ SWITCH WIRING ==============
-- The switch flips its own state internally; we read it right after the click.
local function wireSwitch(row, setEnabled, applyOn, applyOff)
	local holder = row.row:FindFirstChild("Switch", true)
	holder.MouseButton1Click:Connect(function()
		task.defer(function()
			local enabled = row.getState()
			setEnabled(enabled)
			if enabled then
				applyOn()
			else
				applyOff()
			end
		end)
	end)
end

wireSwitch(walkRow, function(v) walkEnabled = v end,
	function()
		if humanoid then humanoid.WalkSpeed = walkSpeed end
	end,
	function()
		if humanoid then humanoid.WalkSpeed = DEFAULT_WALK end
	end)

wireSwitch(jumpRow, function(v) jumpEnabled = v end,
	function()
		if humanoid then humanoid.JumpPower = jumpPower end
	end,
	function()
		if humanoid then humanoid.JumpPower = DEFAULT_JUMP end
	end)

wireSwitch(stickyRow, function(v) stickyEnabled = v end,
	function()
		-- turns on; the RenderStepped loop takes over
	end,
	function()
		cleanupSticky()
	end)

-- ============ DRAGGING ===================
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- ============ CLOSE + TOGGLE KEY =========
closeBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == TOGGLE_KEY then
		frame.Visible = not frame.Visible
	end
end)

print("[JuiceHub] loaded — press " .. TOGGLE_KEY.Name .. " to toggle the GUI")
