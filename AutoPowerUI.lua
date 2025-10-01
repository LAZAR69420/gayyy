-- Cute Hub Custom UI
-- AutoPower + AntiAFK + Hit From Anywhere
-- Draggable GUI with Dropdowns
-- Toggle GUI with Left Control
-- Designed for GitHub repository

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local HeroMoveToEnemyPos = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HeroMoveToEnemyPos")

-- States
local autoPower, antiAFK, autoFarm = false, false, false

-- Attack Functions
local function startAttack()
    if autoPower then return end
    autoPower = true
    task.spawn(function()
        while autoPower do
            r:FireServer({})
            task.wait()
        end
    end)
end
local function stopAttack() autoPower = false end

-- Anti AFK Functions
local function startAFK()
    if antiAFK then return end
    antiAFK = true
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
local function stopAFK() antiAFK = false end

-- AutoFarm Function
local function startFarm()
    if autoFarm then return end
    autoFarm = true
    task.spawn(function()
        while autoFarm do
            if HeroMoveToEnemyPos then
                pcall(function()
                    firesignal(HeroMoveToEnemyPos.OnClientEvent, {
                        attackTarget = "ae774160-697a-4774-aff3-0ead77618da3",
                        userId = player.UserId,
                        heroTagetPosInfos = {
                            ["ba0e5f73-ff79-4208-b3ba-13904c2ed514"] = Vector3.new(146, -52, -100),
                            ["f66029e9-6e7b-4cdb-8f5b-cb1bb592509c"] = Vector3.new(142, -52, -113),
                            ["8ef2229d-c027-492a-998c-639fff40143d"] = Vector3.new(151, -52, -113),
                            ["ce73c134-4f9f-4f53-b848-fbdb3d004304"] = Vector3.new(153, -52, -105),
                            ["fb9a551d-2c2d-4d2d-8daf-4b77e0fea4af"] = Vector3.new(139, -52, -106)
                        }
                    })
                end)
            end
            task.wait(0.5)
        end
    end)
end
local function stopFarm() autoFarm = false end

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CuteHubCustomUI"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 470, 0, 50)
container.Position = UDim2.new(0.5, -235, 0.5, -25)
container.BackgroundTransparency = 0.1
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Helper function for dropdowns
local function createDropdown(name, posX)
    local dropBtn = Instance.new("TextButton", container)
    dropBtn.Size = UDim2.new(0, 200, 0, 35)
    dropBtn.Position = UDim2.new(0, posX, 0, 7)
    dropBtn.Text = name .. " ▶"
    dropBtn.Font = Enum.Font.SourceSans
    dropBtn.TextSize = 18
    dropBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropBtn.BorderSizePixel = 0
    dropBtn.AutoButtonColor = true
    Instance.new("UICorner", dropBtn).CornerRadius = UDim.new(0,8)

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0, 200, 0, 35)
    dropFrame.Position = UDim2.new(0, posX + 205, 0, 7)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)

    dropBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        dropBtn.Text = name .. (dropFrame.Visible and " ▼" or " ▶")
    end)

    return dropFrame
end

-- Main Dropdown
local mainFrame = createDropdown("Main", 10)

local attackBtn = Instance.new("TextButton", mainFrame)
attackBtn.Size = UDim2.new(1,0,0.5,0)
attackBtn.Position = UDim2.new(0,0,0,0)
attackBtn.Text = "Attack: OFF"
attackBtn.Font = Enum.Font.SourceSans
attackBtn.TextSize = 16
attackBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BorderSizePixel = 0
attackBtn.AutoButtonColor = true
Instance.new("UICorner", attackBtn).CornerRadius = UDim.new(0,6)
attackBtn.MouseButton1Click:Connect(function()
    if autoPower then stopAttack(); attackBtn.Text="Attack: OFF"
    else startAttack(); attackBtn.Text="Attack: ON" end
end)

local afkBtn = Instance.new("TextButton", mainFrame)
afkBtn.Size = UDim2.new(1,0,0.5,0)
afkBtn.Position = UDim2.new(0,0,0.5,0)
afkBtn.Text = "AFK: OFF"
afkBtn.Font = Enum.Font.SourceSans
afkBtn.TextSize = 16
afkBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
afkBtn.TextColor3 = Color3.fromRGB(255,255,255)
afkBtn.BorderSizePixel = 0
afkBtn.AutoButtonColor = true
Instance.new("UICorner", afkBtn).CornerRadius = UDim.new(0,6)
afkBtn.MouseButton1Click:Connect(function()
    if antiAFK then stopAFK(); afkBtn.Text="AFK: OFF"
    else startAFK(); afkBtn.Text="AFK: ON" end
end)

-- Farm Dropdown
local farmFrame = createDropdown("Farm", 225)

local farmBtn = Instance.new("TextButton", farmFrame)
farmBtn.Size = UDim2.new(1,0,1,0)
farmBtn.Position = UDim2.new(0,0,0,0)
farmBtn.Text = "Hit From Anywhere: OFF"
farmBtn.Font = Enum.Font.SourceSans
farmBtn.TextSize = 16
farmBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
farmBtn.TextColor3 = Color3.fromRGB(255,255,255)
farmBtn.BorderSizePixel = 0
farmBtn.AutoButtonColor = true
Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0,6)
farmBtn.MouseButton1Click:Connect(function()
    if autoFarm then stopFarm(); farmBtn.Text="Hit From Anywhere: OFF"
    else startFarm(); farmBtn.Text="Hit From Anywhere: ON" end
end)

-- Dragging
local dragging, dragInput, dragStart, startPos=false,nil,nil,nil
container.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=input.Position
        startPos=container.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
container.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then
        local delta=input.Position-dragStart
        container.Position=UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset+delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset+delta.Y
        )
    end
end)

-- Toggle UI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
