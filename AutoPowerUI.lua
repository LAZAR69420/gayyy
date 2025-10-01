-- Cute Hub style UI with Attack + AFK + Farm HeroSkillHarm button
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local autoPower, antiAFK = false, false

-- ScreenGui
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CuteHubCustomUI"
gui.ResetOnSpawn = false
gui.Enabled = true

-- Main container
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,250,0,50)
container.Position = UDim2.new(0.5,-125,0.5,-25)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Main Dropdown button
local mainBtn = Instance.new("TextButton", container)
mainBtn.Size = UDim2.new(0,200,0,35)
mainBtn.Position = UDim2.new(0,10,0,7)
mainBtn.Text = "Main ▼"
mainBtn.Font = Enum.Font.SourceSans
mainBtn.TextSize = 18
mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
mainBtn.BorderSizePixel = 0
mainBtn.AutoButtonColor = true
Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,8)

-- Main dropdown frame (to the right)
local mainDrop = Instance.new("Frame", container)
mainDrop.Size = UDim2.new(0,200,0,70)
mainDrop.Position = UDim2.new(1,5,0,0)
mainDrop.BackgroundColor3 = Color3.fromRGB(0,90,200)
mainDrop.BackgroundTransparency = 0.1
mainDrop.BorderSizePixel = 0
mainDrop.Visible = false
Instance.new("UICorner", mainDrop).CornerRadius = UDim.new(0,8)

-- Attack button
local attackBtn = Instance.new("TextButton", mainDrop)
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
local afkBtn = Instance.new("TextButton", mainDrop)
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

-- Toggle Main dropdown
mainBtn.MouseButton1Click:Connect(function()
    mainDrop.Visible = not mainDrop.Visible
    mainBtn.Text = "Main " .. (mainDrop.Visible and "▲" or "▼")
end)

-- Farm dropdown button
local farmBtn = Instance.new("TextButton", container)
farmBtn.Size = UDim2.new(0,200,0,35)
farmBtn.Position = UDim2.new(0,10,0,50)
farmBtn.Text = "Farm ▼"
farmBtn.Font = Enum.Font.SourceSans
farmBtn.TextSize = 18
farmBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
farmBtn.TextColor3 = Color3.fromRGB(255,255,255)
farmBtn.BorderSizePixel = 0
farmBtn.AutoButtonColor = true
Instance.new("UICorner", farmBtn).CornerRadius = UDim.new(0,8)

-- Farm dropdown frame (to the right)
local farmDrop = Instance.new("Frame", container)
farmDrop.Size = UDim2.new(0,200,0,40)
farmDrop.Position = UDim2.new(1,5,0,50)
farmDrop.BackgroundColor3 = Color3.fromRGB(0,90,200)
farmDrop.BackgroundTransparency = 0.1
farmDrop.BorderSizePixel = 0
farmDrop.Visible = false
Instance.new("UICorner", farmDrop).CornerRadius = UDim.new(0,8)

-- HeroSkillHarm button
local heroBtn = Instance.new("TextButton", farmDrop)
heroBtn.Size = UDim2.new(1,-20,0,30)
heroBtn.Position = UDim2.new(0,10,0,5)
heroBtn.Text = "Hero Skill Harm"
heroBtn.Font = Enum.Font.SourceSans
heroBtn.TextSize = 16
heroBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
heroBtn.TextColor3 = Color3.fromRGB(255,255,255)
heroBtn.BorderSizePixel = 0
heroBtn.AutoButtonColor = true
Instance.new("UICorner", heroBtn).CornerRadius = UDim.new(0,6)

heroBtn.MouseButton1Click:Connect(function()
    local HeroSkillHarm = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HeroSkillHarm")
    HeroSkillHarm:FireServer({
        harmIndex = 9007199254740991,
        isSkill = false,
        heroGuid = "c1ce73a8-7298-4628-8dc6-71acf61e8256",
        skillId = 200001
    })
end)

-- Toggle Farm dropdown
farmBtn.MouseButton1Click:Connect(function()
    farmDrop.Visible = not farmDrop.Visible
    farmBtn.Text = "Farm " .. (farmDrop.Visible and "▲" or "▼")
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
