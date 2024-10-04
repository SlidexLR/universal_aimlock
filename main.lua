local aimlockEnabled = false
local espEnabled = false
local tracersEnabled = false
local teamCheckEnabled = true
local wallCheckEnabled = true
local targetModel = nil
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local guiService = game:GetService("StarterGui")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- Display a notification that the script is running
guiService:SetCore("SendNotification", {
    Title = "Aimlock Script";
    Text = "Script is now running!";
    Duration = 5;
})

-- Create GUI for toggling features
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
local aimlockButton = Instance.new("TextButton", screenGui)
local espButton = Instance.new("TextButton", screenGui)
local tracersButton = Instance.new("TextButton", screenGui)
local teamCheckButton = Instance.new("TextButton", screenGui)
local wallCheckButton = Instance.new("TextButton", screenGui)

-- Styling the buttons
aimlockButton.Size = UDim2.new(0, 100, 0, 50)
aimlockButton.Position = UDim2.new(0, 10, 0, 10)
aimlockButton.Text = "Aimlock (Q)"
aimlockButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)

espButton.Size = UDim2.new(0, 100, 0, 50)
espButton.Position = UDim2.new(0, 10, 0, 70)
espButton.Text = "ESP (P)"
espButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)

tracersButton.Size = UDim2.new(0, 100, 0, 50)
tracersButton.Position = UDim2.new(0, 10, 0, 130)
tracersButton.Text = "Tracers (T)"
tracersButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)

teamCheckButton.Size = UDim2.new(0, 120, 0, 50)
teamCheckButton.Position = UDim2.new(0, 10, 0, 190)
teamCheckButton.Text = "Team Check (C)"
teamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)

wallCheckButton.Size = UDim2.new(0, 120, 0, 50)
wallCheckButton.Position = UDim2.new(0, 10, 0, 250)
wallCheckButton.Text = "Wall Check (W)"
wallCheckButton.BackgroundColor3 = Color3.fromRGB(170, 85, 255)

-- Function to create ESP
local function toggleESP(enabled)
    for _, model in pairs(workspace:GetChildren()) do
        local humanoid = model:FindFirstChild("Humanoid")
        local rootPart = model:FindFirstChild("HumanoidRootPart")
        if humanoid and rootPart and model ~= player.Character then
            if enabled then
                if not rootPart:FindFirstChild("ESPBox") then
                    local espBox = Instance.new("BoxHandleAdornment")
                    espBox.Name = "ESPBox"
                    espBox.Adornee = rootPart
                    espBox.Size = rootPart.Size
                    espBox.Color3 = Color3.fromRGB(255, 0, 0)
                    espBox.AlwaysOnTop = true
                    espBox.ZIndex = 5
                    espBox.Transparency = 0.7
                    espBox.Parent = rootPart
                end
            else
                if rootPart:FindFirstChild("ESPBox") then
                    rootPart:FindFirstChild("ESPBox"):Destroy()
                end
            end
        end
    end
end

-- Toggle features using buttons
aimlockButton.MouseButton1Click:Connect(function()
    aimlockEnabled = not aimlockEnabled
    guiService:SetCore("SendNotification", {
        Title = "Aimlock";
        Text = aimlockEnabled and "Aimlock Enabled" or "Aimlock Disabled";
        Duration = 2;
    })
end)

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    toggleESP(espEnabled)
    guiService:SetCore("SendNotification", {
        Title = "ESP";
        Text = espEnabled and "ESP Enabled" or "ESP Disabled";
        Duration = 2;
    })
end)

-- Key input for toggling aimlock
userInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Q then
        aimlockEnabled = not aimlockEnabled
        guiService:SetCore("SendNotification", {
            Title = "Aimlock";
            Text = aimlockEnabled and "Aimlock Enabled" or "Aimlock Disabled";
            Duration = 2;
        })
    end
end)

-- Team and Wall Checks
local function isTeammate(model)
    local playerTeam = player.Team
    local targetPlayer = game.Players:GetPlayerFromCharacter(model)
    if teamCheckEnabled and targetPlayer and targetPlayer.Team == playerTeam then
        return true
    end
    return false
end

local function isVisible(part)
    if not wallCheckEnabled then
        return true
    end
    local origin = workspace.CurrentCamera.CFrame.Position
    local direction = (part.Position - origin).unit * (part.Position - origin).magnitude
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {player.Character}
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

-- Aimlock functionality
runService.RenderStepped:Connect(function()
    if aimlockEnabled then
        local closestModel = nil
        local shortestDistance = math.huge

        for _, model in pairs(workspace:GetChildren()) do
            local humanoid = model:FindFirstChild("Humanoid")
            local rootPart = model:FindFirstChild("HumanoidRootPart")
            if humanoid and rootPart and model ~= player.Character and not isTeammate(model) and isVisible(rootPart) then
                local screenPosition, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
                if onScreen then
                    local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPosition.X, screenPosition.Y)).magnitude
                    if distance < shortestDistance then
                        closestModel = model
                        shortestDistance = distance
                    end
                end
            end
        end

        if closestModel then
            local rootPart = closestModel.HumanoidRootPart
            local camera = workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, rootPart.Position)
        end
    end
end)
