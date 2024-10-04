local aimlockEnabled = false
local espEnabled = false
local tracersEnabled = false
local teamCheckEnabled = true
local wallCheckEnabled = true
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local guiService = game:GetService("StarterGui")

-- Create GUI for toggling features
local screenGui = Instance.new("ScreenGui", player.PlayerGui)
screenGui.Name = "AimlockGui"
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 200, 0, 300)
frame.Position = UDim2.new(0.5, -100, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Visible = false  -- Initially hide the GUI

local toggleGuiButton = Instance.new("TextButton", screenGui)
toggleGuiButton.Size = UDim2.new(0, 200, 0, 50)
toggleGuiButton.Position = UDim2.new(0.5, -100, 0, 10)
toggleGuiButton.Text = "Toggle GUI"
toggleGuiButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local aimlockButton = Instance.new("TextButton", frame)
aimlockButton.Size = UDim2.new(1, 0, 0, 50)
aimlockButton.Position = UDim2.new(0, 0, 0, 50)
aimlockButton.Text = "Aimlock (Q)"
aimlockButton.BackgroundColor3 = Color3.fromRGB(255, 85, 85)

local espButton = Instance.new("TextButton", frame)
espButton.Size = UDim2.new(1, 0, 0, 50)
espButton.Position = UDim2.new(0, 0, 0, 100)
espButton.Text = "ESP (P)"
espButton.BackgroundColor3 = Color3.fromRGB(85, 170, 255)

local tracersButton = Instance.new("TextButton", frame)
tracersButton.Size = UDim2.new(1, 0, 0, 50)
tracersButton.Position = UDim2.new(0, 0, 0, 150)
tracersButton.Text = "Tracers (T)"
tracersButton.BackgroundColor3 = Color3.fromRGB(85, 255, 85)

local teamCheckButton = Instance.new("TextButton", frame)
teamCheckButton.Size = UDim2.new(1, 0, 0, 50)
teamCheckButton.Position = UDim2.new(0, 0, 0, 200)
teamCheckButton.Text = "Team Check (C)"
teamCheckButton.BackgroundColor3 = Color3.fromRGB(255, 170, 0)

local wallCheckButton = Instance.new("TextButton", frame)
wallCheckButton.Size = UDim2.new(1, 0, 0, 50)
wallCheckButton.Position = UDim2.new(0, 0, 0, 250)
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

tracersButton.MouseButton1Click:Connect(function()
    tracersEnabled = not tracersEnabled
    guiService:SetCore("SendNotification", {
        Title = "Tracers";
        Text = tracersEnabled and "Tracers Enabled" or "Tracers Disabled";
        Duration = 2;
    })
end)

teamCheckButton.MouseButton1Click:Connect(function()
    teamCheckEnabled = not teamCheckEnabled
    guiService:SetCore("SendNotification", {
        Title = "Team Check";
        Text = teamCheckEnabled and "Team Check Enabled" or "Team Check Disabled";
        Duration = 2;
    })
end)

wallCheckButton.MouseButton1Click:Connect(function()
    wallCheckEnabled = not wallCheckEnabled
    guiService:SetCore("SendNotification", {
        Title = "Wall Check";
        Text = wallCheckEnabled and "Wall Check Enabled" or "Wall Check Disabled";
        Duration = 2;
    })
end)

-- Function to toggle GUI visibility
toggleGuiButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
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
