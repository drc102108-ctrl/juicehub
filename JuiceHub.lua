--[[
    JUICE HUB

    Categories:
      General
      Football Fusion
      Menu controls

    Magnet functionality has been completely removed.
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ================= CONFIG =================

local TOGGLE_KEY = Enum.KeyCode.RightBracket

local DEFAULT_WALK = 16
local DEFAULT_JUMP = 50
local DEFAULT_PULL = 2
local DEFAULT_STICKY = 2
local DEFAULT_LAUNCH = 50

local DEFAULT_FOOTBALL_SIZE = 5
local DEFAULT_JUMP_BOOST = 0
local DEFAULT_ANGLE = 0
local DEFAULT_QUICK_TP = 5
local QUICK_TP_KEY = Enum.KeyCode.F

local ACCENT = Color3.fromRGB(0, 170, 255)
local BG = Color3.fromRGB(18, 18, 22)
local PANEL = Color3.fromRGB(28, 28, 34)
local PANEL_HOVER = Color3.fromRGB(35, 35, 42)
local TEXT = Color3.fromRGB(240, 240, 245)
local MUTED = Color3.fromRGB(150, 150, 158)

-- ================= STATE ==================

local walkSpeed = DEFAULT_WALK
local jumpPower = DEFAULT_JUMP
local walkEnabled = false
local jumpEnabled = false

local stickyEnabled = false
local pullStrength = DEFAULT_PULL
local stickiness = DEFAULT_STICKY

local launchPower = DEFAULT_LAUNCH

local footballSizeEnabled = false
local footballSize = DEFAULT_FOOTBALL_SIZE

local jumpBoostEnabled = false
local jumpBoostAmount = DEFAULT_JUMP_BOOST

local angleEnabled = false
local angleAmount = DEFAULT_ANGLE

local quickTPEnabled = false
local quickTPSpeed = DEFAULT_QUICK_TP

local humanoid
local rootPart

-- ================= CHARACTER =================

local function setupCharacter(character)
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")

    humanoid.UseJumpPower = true

    if walkEnabled then
        humanoid.WalkSpeed = walkSpeed
    end

    if jumpEnabled then
        humanoid.JumpPower = jumpPower
    end
end

if player.Character then
    task.spawn(setupCharacter, player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- ================= UI HELPERS =================

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

local function tween(obj, info, props)
    return TweenService:Create(obj, info, props)
end

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
    knob.BackgroundColor3 = Color3.fromRGB(200, 200, 205)
    knob.Parent = holder
    round(knob, 9)

    local state = false
    local offPos = UDim2.new(0, 3, 0.5, -9)
    local onPos = UDim2.new(1, -21, 0.5, -9)

    local function setState(value)
        state = value

        if state then
            tween(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = ACCENT
            }):Play()

            tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = onPos,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        else
            tween(holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(55, 55, 62)
            }):Play()

            tween(knob, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = offPos,
                BackgroundColor3 = Color3.fromRGB(200, 200, 205)
            }):Play()
        end
    end

    holder.MouseButton1Click:Connect(function()
        setState(not state)
    end)

    return holder, function()
        return state
    end, setState
end

-- ================= GUI =================

local gui = Instance.new("ScreenGui")
gui.Name = "ShadowTestHub"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ok = pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)

if not ok then
    gui.Parent = player:WaitForChild("PlayerGui")
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 410, 0, 510)
frame.Position = UDim2.new(0.5, -205, 0.5, -255)
frame.BackgroundColor3 = BG
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
round(frame, 14)
stroke(frame, 1.5, Color3.fromRGB(255, 255, 255), 0.86)

-- ================= TITLE BAR =================

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 48)
titleBar.BackgroundColor3 = PANEL
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
round(titleBar, 14)

local titleMask = Instance.new("Frame")
titleMask.Size = UDim2.new(1, 0, 0, 14)
titleMask.Position = UDim2.new(0, 0, 1, -14)
titleMask.BackgroundColor3 = PANEL
titleMask.BorderSizePixel = 0
titleMask.Parent = titleBar

local icon = Instance.new("TextLabel")
icon.Size = UDim2.new(0, 32, 1, 0)
icon.Position = UDim2.new(0, 12, 0, 0)
icon.BackgroundTransparency = 1
icon.Text = "⚡"
icon.TextSize = 20
icon.TextColor3 = ACCENT
icon.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -100, 1, 0)
title.Position = UDim2.new(0, 48, 0, 0)
title.BackgroundTransparency = 1
title.Text = "SHADOW TEST HUB"
title.TextColor3 = TEXT
title.TextSize = 15
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = titleBar
round(closeBtn, 8)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(75, 45, 50)
    }):Play()
end)

closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, TweenInfo.new(0.12), {
        BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    }):Play()
end)

-- ================= CATEGORY BAR =================

local categoryBar = Instance.new("Frame")
categoryBar.Size = UDim2.new(1, -24, 0, 42)
categoryBar.Position = UDim2.new(0, 12, 0, 58)
categoryBar.BackgroundTransparency = 1
categoryBar.Parent = frame

local generalTab = Instance.new("TextButton")
generalTab.Size = UDim2.new(0.5, -5, 1, 0)
generalTab.Position = UDim2.new(0, 0, 0, 0)
generalTab.BackgroundColor3 = ACCENT
generalTab.Text = "⚙  General"
generalTab.TextColor3 = TEXT
generalTab.TextSize = 13
generalTab.Font = Enum.Font.GothamBold
generalTab.AutoButtonColor = false
generalTab.Parent = categoryBar
round(generalTab, 9)

local footballTab = Instance.new("TextButton")
footballTab.Size = UDim2.new(0.5, -5, 1, 0)
footballTab.Position = UDim2.new(0.5, 5, 0, 0)
footballTab.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
footballTab.Text = "🏈  Football Fusion"
footballTab.TextColor3 = MUTED
footballTab.TextSize = 13
footballTab.Font = Enum.Font.GothamBold
footballTab.AutoButtonColor = false
footballTab.Parent = categoryBar
round(footballTab, 9)

-- ================= PAGE CONTAINERS =================

local function makePage()
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -24, 1, -144)
    page.Position = UDim2.new(0, 12, 0, 108)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = ACCENT
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    return page
end

local generalPage = makePage()
local footballPage = makePage()
generalPage.Visible = true

-- ================= ROW BUILDER =================

local function makeRow(parent, labelText, defaultText, withSwitch)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = parent
    round(row, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -150, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = TEXT
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 62, 0, 30)
    box.Position = UDim2.new(1, -116, 0.5, -15)
    box.BackgroundColor3 = Color3.fromRGB(40, 40, 47)
    box.Text = defaultText
    box.TextColor3 = TEXT
    box.TextSize = 13
    box.Font = Enum.Font.GothamBold
    box.PlaceholderText = defaultText
    box.ClearTextOnFocus = false
    box.Parent = row
    round(box, 8)
    stroke(box, 1, Color3.fromRGB(255, 255, 255), 0.88)

    local data = {
        row = row,
        label = label,
        box = box
    }

    if withSwitch then
        local sw, getState, setState = makeSwitch(row)
        sw.Position = UDim2.new(1, -48, 0.5, -12)
        data.getState = getState
        data.setState = setState
    end

    return data
end

local function makeButtonRow(parent, labelText, buttonText)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = parent
    round(row, 10)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = TEXT
    label.TextSize = 13
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 64, 0, 28)
    button.Position = UDim2.new(1, -76, 0.5, -14)
    button.BackgroundColor3 = ACCENT
    button.Text = buttonText
    button.TextColor3 = TEXT
    button.TextSize = 12
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = false
    button.Parent = row
    round(button, 8)

    return {
        row = row,
        label = label,
        button = button
    }
end

-- ================= GENERAL =================

local walkRow = makeRow(generalPage, "Walk Speed", tostring(DEFAULT_WALK), true)
local jumpRow = makeRow(generalPage, "Jump Power", tostring(DEFAULT_JUMP), true)
local stickyRow = makeRow(generalPage, "Sticky", "", true)
local pullRow = makeRow(generalPage, "Pull Strength", tostring(DEFAULT_PULL), false)
local stickinessRow = makeRow(generalPage, "Stickiness", tostring(DEFAULT_STICKY), false)
local launchPowerRow = makeRow(generalPage, "Launch Power", tostring(DEFAULT_LAUNCH), false)
local launchRow = makeButtonRow(generalPage, "Launch", "GO")

-- ================= FOOTBALL FUSION =================

local footballSizeRow = makeRow(
    footballPage,
    "Football Size",
    tostring(DEFAULT_FOOTBALL_SIZE),
    true
)

local jumpBoostRow = makeRow(
    footballPage,
    "Jump Boost",
    tostring(DEFAULT_JUMP_BOOST),
    true
)

local angleRow = makeRow(
    footballPage,
    "Angle Enhancer",
    tostring(DEFAULT_ANGLE),
    true
)

local quickTPRow = makeRow(
    footballPage,
    "Quick TP",
    tostring(DEFAULT_QUICK_TP),
    true
)

local info = Instance.new("TextLabel")
info.Size = UDim2.new(1, -8, 0, 50)
info.BackgroundTransparency = 1
info.Text = "Quick TP: press F\nFootball settings apply to Football parts."
info.TextColor3 = MUTED
info.TextSize = 11
info.Font = Enum.Font.Gotham
info.TextWrapped = true
info.TextXAlignment = Enum.TextXAlignment.Left
info.Parent = footballPage

-- ================= FOOTER =================

local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -24, 0, 20)
footer.Position = UDim2.new(0, 12, 1, -27)
footer.BackgroundTransparency = 1
footer.Text = "[" .. TOGGLE_KEY.Name .. "] hide/show  •  drag title bar"
footer.TextColor3 = MUTED
footer.TextSize = 10
footer.Font = Enum.Font.Gotham
footer.Parent = frame

-- ================= CATEGORY SWITCHING =================

local function showPage(page)
    generalPage.Visible = page == generalPage
    footballPage.Visible = page == footballPage

    local generalOn = page == generalPage

    tween(generalTab, TweenInfo.new(0.15), {
        BackgroundColor3 = generalOn and ACCENT or Color3.fromRGB(40, 40, 47)
    }):Play()

    tween(footballTab, TweenInfo.new(0.15), {
        BackgroundColor3 = not generalOn and ACCENT or Color3.fromRGB(40, 40, 47)
    }):Play()

    generalTab.TextColor3 = generalOn and TEXT or MUTED
    footballTab.TextColor3 = not generalOn and TEXT or MUTED
end

generalTab.MouseButton1Click:Connect(function()
    showPage(generalPage)
end)

footballTab.MouseButton1Click:Connect(function()
    showPage(footballPage)
end)

-- ================= VALUE HELPERS =================

local function clampNumber(box, default, minValue, maxValue, decimals)
    local value = tonumber(box.Text) or default
    value = math.clamp(value, minValue, maxValue)

    if decimals == 0 then
        value = math.floor(value + 0.5)
        box.Text = tostring(value)
    else
        value = math.floor(value * 10 + 0.5) / 10
        box.Text = (value % 1 == 0) and tostring(value) or string.format("%.1f", value)
    end

    return value
end

-- ================= GENERAL VALUE EVENTS =================

walkRow.box.FocusLost:Connect(function()
    walkSpeed = clampNumber(walkRow.box, DEFAULT_WALK, 1, 100, 0)
    if walkEnabled and humanoid then
        humanoid.WalkSpeed = walkSpeed
    end
end)

jumpRow.box.FocusLost:Connect(function()
    jumpPower = clampNumber(jumpRow.box, DEFAULT_JUMP, 0, 200, 1)
    if jumpEnabled and humanoid then
        humanoid.JumpPower = jumpPower
    end
end)

pullRow.box.FocusLost:Connect(function()
    pullStrength = clampNumber(pullRow.box, DEFAULT_PULL, 0.1, 10, 1)
end)

stickinessRow.box.FocusLost:Connect(function()
    stickiness = clampNumber(stickinessRow.box, DEFAULT_STICKY, 0.1, 10, 1)
end)

launchPowerRow.box.FocusLost:Connect(function()
    launchPower = clampNumber(launchPowerRow.box, DEFAULT_LAUNCH, 1, 500, 1)
end)

-- ================= FOOTBALL VALUE EVENTS =================

footballSizeRow.box.FocusLost:Connect(function()
    footballSize = clampNumber(
        footballSizeRow.box,
        DEFAULT_FOOTBALL_SIZE,
        1,
        15,
        0
    )
end)

jumpBoostRow.box.FocusLost:Connect(function()
    jumpBoostAmount = clampNumber(
        jumpBoostRow.box,
        DEFAULT_JUMP_BOOST,
        0,
        50,
        0
    )
end)

angleRow.box.FocusLost:Connect(function()
    angleAmount = clampNumber(
        angleRow.box,
        DEFAULT_ANGLE,
        0,
        50,
        0
    )
end)

quickTPRow.box.FocusLost:Connect(function()
    quickTPSpeed = clampNumber(
        quickTPRow.box,
        DEFAULT_QUICK_TP,
        0,
        50,
        0
    )
end)

-- ================= LAUNCH =================

launchRow.button.MouseButton1Click:Connect(function()
    local character = player.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")

    if hrp then
        hrp.AssemblyLinearVelocity =
            hrp.CFrame.LookVector * launchPower
            + Vector3.new(0, launchPower, 0)
    end
end)

-- ================= SWITCH WIRING =================

walkRow.setState(false)
jumpRow.setState(false)
stickyRow.setState(false)
footballSizeRow.setState(false)
jumpBoostRow.setState(false)
angleRow.setState(false)
quickTPRow.setState(false)

walkRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        walkEnabled = walkRow.getState()

        if humanoid then
            humanoid.WalkSpeed = walkEnabled and walkSpeed or DEFAULT_WALK
        end
    end)
end)

jumpRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        jumpEnabled = jumpRow.getState()

        if humanoid then
            humanoid.JumpPower = jumpEnabled and jumpPower or DEFAULT_JUMP
        end
    end)
end)

stickyRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        stickyEnabled = stickyRow.getState()
    end)
end)

footballSizeRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        footballSizeEnabled = footballSizeRow.getState()
    end)
end)

jumpBoostRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        jumpBoostEnabled = jumpBoostRow.getState()
    end)
end)

angleRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        angleEnabled = angleRow.getState()
    end)
end)

quickTPRow.row.Switch.MouseButton1Click:Connect(function()
    task.defer(function()
        quickTPEnabled = quickTPRow.getState()
    end)
end)

-- ================= FOOTBALL SIZE =================

local function applyFootballSize(ball)
    if not footballSizeEnabled then
        return
    end

    if ball:IsA("BasePart") and ball.Name == "Football" then
        ball.CanCollide = false
        ball.Size = Vector3.new(
            footballSize,
            footballSize,
            footballSize
        )
    end
end

for _, obj in ipairs(workspace:GetDescendants()) do
    applyFootballSize(obj)
end

workspace.DescendantAdded:Connect(function(obj)
    task.defer(function()
        applyFootballSize(obj)
    end)
end)

-- ================= JUMP BOOST =================

local jumpConnection

local function connectJumpBoost()
    if jumpConnection then
        jumpConnection:Disconnect()
        jumpConnection = nil
    end

    if not humanoid then
        return
    end

    jumpConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping
            and jumpBoostEnabled then

            task.wait(0.01)

            if rootPart then
                rootPart.AssemblyLinearVelocity =
                    Vector3.new(
                        rootPart.AssemblyLinearVelocity.X,
                        rootPart.AssemblyLinearVelocity.Y + jumpBoostAmount,
                        rootPart.AssemblyLinearVelocity.Z
                    )
            end
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait()
    connectJumpBoost()
end)

connectJumpBoost()

-- ================= ANGLE ENHANCER =================

local shiftLockWasActive = false
local angleUsed = false

RunService.RenderStepped:Connect(function()
    local shiftLockActive =
        UIS.MouseBehavior == Enum.MouseBehavior.LockCenter

    if shiftLockActive then
        shiftLockWasActive = true
    elseif shiftLockWasActive then
        shiftLockWasActive = false
    end
end)

local angleConnection

local function connectAngle()
    if angleConnection then
        angleConnection:Disconnect()
        angleConnection = nil
    end

    if not humanoid then
        return
    end

    angleConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping
            and angleEnabled
            and shiftLockWasActive
            and not angleUsed then

            angleUsed = true

            task.wait(0.01)

            if rootPart then
                rootPart.AssemblyLinearVelocity =
                    Vector3.new(
                        rootPart.AssemblyLinearVelocity.X,
                        rootPart.AssemblyLinearVelocity.Y + angleAmount,
                        rootPart.AssemblyLinearVelocity.Z
                    )
            end

            task.delay(0.1, function()
                angleUsed = false
            end)
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait()
    connectAngle()
end)

connectAngle()

-- ================= QUICK TP =================

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == QUICK_TP_KEY and quickTPEnabled then
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            hrp.CFrame = hrp.CFrame + hrp.CFrame.LookVector * quickTPSpeed
        end
    end
end)

-- ================= STICKY =================

local function cleanupSticky()
    for _, other in ipairs(Players:GetPlayers()) do
        local character = other.Character
        local head = character and character:FindFirstChild("Head")

        if head then
            local bp = head:FindFirstChild("StickyBP")
            if bp then
                bp:Destroy()
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    if not stickyEnabled then
        return
    end

    local character = player.Character
    local myHead = character and character:FindFirstChild("Head")

    if not myHead then
        return
    end

    local nearest
    local nearestDist

    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player then
            local otherCharacter = other.Character
            local otherHead = otherCharacter and otherCharacter:FindFirstChild("Head")
            local otherHumanoid = otherCharacter and otherCharacter:FindFirstChildOfClass("Humanoid")

            if otherHead
                and otherHumanoid
                and otherHumanoid.Health > 0 then

                local distance =
                    (myHead.Position - otherHead.Position).Magnitude

                if distance <= 500
                    and (not nearestDist or distance < nearestDist) then

                    nearestDist = distance
                    nearest = otherHead
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

-- ================= DRAGGING =================

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

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
    if dragging
        and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then

        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ================= CLOSE + TOGGLE =================

closeBtn.MouseButton1Click:Connect(function()
    cleanupSticky()
    gui:Destroy()
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then
        return
    end

    if input.KeyCode == TOGGLE_KEY then
        frame.Visible = not frame.Visible
    end
end)

-- Make sure the current character gets the football movement listeners too.
-- This also handles the case where the GUI starts after the character already exists.
task.spawn(function()
    local character = player.Character or player.CharacterAdded:Wait()
    character:WaitForChild("Humanoid")
    character:WaitForChild("HumanoidRootPart")
    task.wait()
    connectJumpBoost()
    connectAngle()
end)

print("[Shadow Test Hub] loaded - press " .. TOGGLE_KEY.Name .. " to toggle")

print("[JuiceHub] loaded — press " .. TOGGLE_KEY.Name .. " to toggle the GUI")
