-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local guiService = game:GetService("GuiService")

-- Variables
local aimlockEnabled = false
local espEnabled = false

-- Create GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 250, 0, 180)
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Create Rounded Corners
local function createRoundedCorner(parent)
    local cornerFrame = Instance.new("Frame", parent)
    cornerFrame.Size = UDim2.new(1, 0, 1, 0)
    cornerFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    cornerFrame.BorderSizePixel = 0
    local cornerRadius = Instance.new("UICorner")
    cornerRadius.CornerRadius = UDim.new(0, 10)
    cornerRadius.Parent = cornerFrame
    return cornerFrame
end

local roundedFrame = createRoundedCorner(mainFrame)

-- Title
local titleLabel = Instance.new("TextLabel", roundedFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Text = "Aimlock Script"
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextScaled = true
titleLabel.BorderSizePixel = 0

-- Aimlock Label
local aimlockLabel = Instance.new("TextLabel", roundedFrame)
aimlockLabel.Size = UDim2.new(1, 0, 0, 30)
aimlockLabel.Position = UDim2.new(0, 0, 0.2, 0)
aimlockLabel.Text = "Aimlock: Disabled"
aimlockLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimlockLabel.TextColor3 = Color3.new(1, 1, 1)
aimlockLabel.Font = Enum.Font.SourceSans
aimlockLabel.TextScaled = true
aimlockLabel.BorderSizePixel = 0

-- ESP Label
local espLabel = Instance.new("TextLabel", roundedFrame)
espLabel.Size = UDim2.new(1, 0, 0, 30)
espLabel.Position = UDim2.new(0, 0, 0.4, 0)
espLabel.Text = "ESP: Disabled"
espLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espLabel.TextColor3 = Color3.new(1, 1, 1)
espLabel.Font = Enum.Font.SourceSans
espLabel.TextScaled = true
espLabel.BorderSizePixel = 0

-- Create Toggle Buttons
local function createToggleButton(name, position)
    local button = Instance.new("TextButton", roundedFrame)
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = position
    button.Text = name
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSans
    button.TextScaled = true
    button.BorderSizePixel = 0
    return button
end

local aimlockButton = createToggleButton("Toggle Aimlock (Q)", UDim2.new(0, 0, 0.6, 0))
local espButton = createToggleButton("Toggle ESP (E)", UDim2.new(0, 0, 0.8, 0))

screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
roundedFrame.Visible = true

-- Notification Function
local function notify(title, text)
    guiService:SetCore("SendNotification", {
        Title = title;
        Text = text;
        Duration = 2;
    })
end

-- Aimlock Functionality
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Wall Check Function
local function isWallBetween(target)
    local startPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
    local endPos = target.Character.HumanoidRootPart.Position
    local ray = Ray.new(startPos, (endPos - startPos).Unit * (startPos - endPos).Magnitude)

    local hitPart = workspace:FindPartOnRay(ray, game.Players.LocalPlayer.Character)
    return hitPart and hitPart:IsA("Part")
end

-- Tracers
local function drawTracer(startPos, target)
    local line = Instance.new("LineHandleAdornment")
    line.Color3 = Color3.fromRGB(0, 255, 0) -- Tracer color
    line.Thickness = 2
    line.Parent = workspace
    line.Adornee = workspace

    line.WorldPosition = (startPos + target.Position) / 2 -- Midpoint
    line.Length = (target.Position - startPos).Magnitude
    return line
end

-- Tracking Loop
RunService.RenderStepped:Connect(function()
    if aimlockEnabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not isWallBetween(targetPlayer) then
                -- Draw tracer to the target
                drawTracer(game.Players.LocalPlayer.Character.HumanoidRootPart.Position, targetPlayer.Character.HumanoidRootPart)

                -- Aim at the target player
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPlayer.Character.HumanoidRootPart.Position) -- Uncomment this line to teleport
            end
        end
    end
end)

-- Button Functionality
aimlockButton.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    aimlockLabel.Text = "Aimlock: " .. (aimlockEnabled and "Enabled" or "Disabled")
    notify("Aimlock", aimlockEnabled and "Enabled" or "Disabled")
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espLabel.Text = "ESP: " .. (espEnabled and "Enabled" or "Disabled")
    notify("ESP", espEnabled and "Enabled" or "Disabled")
end)

-- ESP Functionality
local function createESP(player)
    local espBox = Instance.new("BoxHandleAdornment")
    espBox.Size = player.Character.HumanoidRootPart.Size * 1.2
    espBox.Color3 = Color3.fromRGB(255, 0, 0)
    espBox.AlwaysOnTop = true
    espBox.ZIndex = 10
    espBox.Adornee = player.Character.HumanoidRootPart
    espBox.Parent = player.Character.HumanoidRootPart
end

-- ESP Loop
RunService.RenderStepped:Connect(function()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESP(player)
            end
        end
    end
end)

-- GUI Toggle Functionality
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.M then  -- Set to M key for GUI toggle
            roundedFrame.Visible = not roundedFrame.Visible  -- Toggle GUI visibility
        end
    end
end)

screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
roundedFrame.Visible = true
