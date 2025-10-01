-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local HeroMoveToEnemyPos = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HeroMoveToEnemyPos")

local autoPower, antiAFK = false, false

-- ScreenGui
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CuteHubCustomUI"
gui.ResetOnSpawn = false
gui.Enabled = true

-- Main container (big enough for multiple dropdowns)
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 470, 0, 50) -- wider for two dropdowns
container.Position = UDim2.new(0.5, -235, 0.5, -25)
container.BackgroundTransparency = 0.1
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Helper function to create dropdowns
local function createDropdown(name, posX)
    local dropBtn = Instance.new("TextButton", container)
    dropBtn.Size = UDim2.new(0, 200, 0, 35)
    dropBtn.Position = UDim2.new(0, posX, 0, 7)
    dropBtn.Text = name .. " ▼"
    dropBtn.Font = Enum.Font.SourceSans
    dropBtn.TextSize = 18
    dropBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropBtn.BorderSizePixel = 0
    dropBtn.AutoButtonColor = true
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0,8)

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0, 200, 0, 100)
    dropFrame.Position = UDim2.new(0, posX + 205, 0, 7) -- expand to the right
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)

    dropBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        dropBtn.Text = name .. (dropFrame.Visible and " ▲" or " ▼")
    end)

    return dropFrame
end

-- Main dropdown
local mainFrame = createDropdown("Main", 10)

-- Attack button
local attackBtn = Instance.new("TextButton", mainFrame)
attackBtn.Size = UDim2.new(1,-20,0,30)
attackBtn.Position = UDim2.new(0,10,0,5)
attackBtn.Text = "Attack: OFF"
attackBtn.Font = Enum.Font.SourceSans
attackBtn.TextSize = 16
attackBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BorderSizePixel = 0
attackBtn.AutoButtonColor = true
Instance.new("UICorner", attackBtn).CornerRadius = UDim.new(0,6)

attackBtn.MouseButton1Click:Connect(function()
    if autoPower then
        autoPower=false
        attackBtn.Text="Attack: OFF"
    else
        autoPower=true
        attackBtn.Text="Attack: ON"
        task.spawn(function()
            while autoPower do
                r:FireServer({})
                task.wait()
            end
        end)
    end
end)

-- AFK button
local afkBtn = Instance.new("TextButton", mainFrame)
afkBtn.Size = UDim2.new(1,-20,0,30)
afkBtn.Position = UDim2.new(0,10,0,40)
afkBtn.Text = "AFK: OFF"
afkBtn.Font = Enum.Font.SourceSans
afkBtn.TextSize = 16
afkBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
afkBtn.TextColor3 = Color3.fromRGB(255,255,255)
afkBtn.BorderSizePixel = 0
afkBtn.AutoButtonColor = true
Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0,6)

afkBtn.MouseButton1Click:Connect(function()
    if antiAFK then
        antiAFK=false
        afkBtn.Text="AFK: OFF"
    else
        antiAFK=true
        afkBtn.Text="AFK: ON"
        task.spawn(function()
            while antiAFK do
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid:Move(Vector3.new(0,0,0))
                end
                task.wait(30)
            end
        end)
    end
end)

-- Farm dropdown
local farmFrame = createDropdown("Farm", 225) -- moved to the right of Main

local farmBtn = Instance.new("TextButton", farmFrame)
farmBtn.Size = UDim2.new(1,-20,0,30)
farmBtn.Position = UDim2.new(0,10,0,5)
farmBtn.Text = "Hit From Anywhere"
farmBtn.Font = Enum.Font.SourceSans
farmBtn.TextSize = 16
farmBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
farmBtn.TextColor3 = Color3.fromRGB(255,255,255)
farmBtn.BorderSizePixel = 0
farmBtn.AutoButtonColor = true
Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0,6)

farmBtn.MouseButton1Click:Connect(function()
    firesignal(HeroMoveToEnemyPos.OnClientEvent, {
        attackTarget = "ae774160-697a-4774-aff3-0ead77618da3",
        userId = player.UserId,
        heroTagetPosInfos = {
            ["ba0e5f73-ff79-4208-b3ba-13904c2ed514"] = Vector3.new(146, -52, -100),
