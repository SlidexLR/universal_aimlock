-- Services
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local guiService = game:GetService("GuiService")

-- Variables
local aimlockEnabled = false
local wallCheckEnabled = false
local teamCheckEnabled = false
local espEnabled = false

-- Create GUI
local screenGui = Instance.new("ScreenGui")
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Text = "Aimlock Script"
titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
titleLabel.TextColor3 = Color3.new(1, 1, 1)

local aimlockLabel = Instance.new("TextLabel", frame)
aimlockLabel.Size = UDim2.new(1, 0, 0, 30)
aimlockLabel.Position = UDim2.new(0, 0, 0.2, 0)
aimlockLabel.Text = "Aimlock: Disabled"
aimlockLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
aimlockLabel.TextColor3 = Color3.new(1, 1, 1)

local espLabel = Instance.new("TextLabel", frame)
espLabel.Size = UDim2.new(1, 0, 0, 30)
espLabel.Position = UDim2.new(0, 0, 0.4, 0)
espLabel.Text = "ESP: Disabled"
espLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
espLabel.TextColor3 = Color3.new(1, 1, 1)

screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
frame.Visible = true

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
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local distance = (character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
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

-- Tracking Loop
RunService.RenderStepped:Connect(function()
    if aimlockEnabled then
        local targetPlayer = getClosestPlayer()
        if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if not wallCheckEnabled or not isWallBetween(targetPlayer) then
                -- Aim at the target player
                local targetPos = targetPlayer.Character.HumanoidRootPart.Position
                local direction = (targetPos - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).unit
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(targetPos) * CFrame.Angles(0, math.atan2(direction.X, direction.Z), 0)
            end
        end
    end
end)

-- GUI and Aimlock Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not gameProcessedEvent then  -- Check if the game has processed this input
        if input.KeyCode == Enum.KeyCode.M then  -- Set to M key for GUI toggle
            frame.Visible = not frame.Visible  -- Toggle GUI visibility
        elseif input.KeyCode == Enum.KeyCode.Q then  -- Set to Q key for aimlock toggle
            aimlockEnabled = not aimlockEnabled
            aimlockLabel.Text = "Aimlock: " .. (aimlockEnabled and "Enabled" or "Disabled")
            notify("Aimlock", aimlockEnabled and "Enabled" or "Disabled")
        elseif input.KeyCode == Enum.KeyCode.E then  -- Set to E key for ESP toggle
            espEnabled = not espEnabled
            espLabel.Text = "ESP: " .. (espEnabled and "Enabled" or "Disabled")
            notify("ESP", espEnabled and "Enabled" or "Disabled")
        end
    end
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
