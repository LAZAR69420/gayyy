-- Cute Hub style UI with Attack + AFK buttons
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
local uic = Instance.new("UICorner", container)
uic.CornerRadius = UDim.new(0,12)

-- Dropdown button
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

-- Dropdown frame (to the right)
local dropFrame = Instance.new("Frame", container)
dropFrame.Size = UDim2.new(0,200,0,70)
dropFrame.Position = UDim2.new(1,5,0,0) -- to the right
dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
dropFrame.BackgroundTransparency = 0.1
dropFrame.BorderSizePixel = 0
dropFrame.Visible = false
Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)

-- Attack button
local attackBtn = Instance.new("TextButton", dropFrame)
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
local afkBtn = Instance.new("TextButton", dropFrame)
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

-- Toggle dropdown
mainBtn.MouseButton1Click:Connect(function()
    dropFrame.Visible = not dropFrame.Visible
    mainBtn.Text = "Main " .. (dropFrame.Visible and "▲" or "▼")
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
