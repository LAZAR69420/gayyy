-- Cute Hub style UI with Attack + AFK buttons + Farm dropdown
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
container.Size = UDim2.new(0,500,0,50) -- wider to fit multiple dropdowns
container.Position = UDim2.new(0.5,-250,0.5,-25)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Function to create a dropdown
local function createDropdown(name, posX)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0,200,0,35)
    btn.Position = UDim2.new(0,posX,0,7)
    btn.Text = name .. " ▶"
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0,200,0,70)
    frame.Position = UDim2.new(0,posX + 205,0,0) -- to the right of the button
    frame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Visible = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    return btn, frame
end

-- Create Main dropdown
local mainBtn, mainFrame = createDropdown("Main", 10)

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

-- Main dropdown toggle
mainBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
    mainBtn.Text = "Main " .. (mainFrame.Visible and "▼" or "▶")
end)

-- Create Farm dropdown (to the right of Main)
local farmBtn, farmFrame = createDropdown("Farm", 225)

-- Example button inside Farm dropdown
local farmExampleBtn = Instance.new("TextButton", farmFrame)
farmExampleBtn.Size = UDim2.new(1,-20,0,30)
farmExampleBtn.Position = UDim2.new(0,10,0,5)
farmExampleBtn.Text = "Farm Action"
farmExampleBtn.Font = Enum.Font.SourceSans
farmExampleBtn.TextSize = 16
farmExampleBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
farmExampleBtn.TextColor3 = Color3.fromRGB(255,255,255)
farmExampleBtn.BorderSizePixel = 0
farmExampleBtn.AutoButtonColor = true
Instance.new("UICorner", farmExampleBtn).CornerRadius = UDim.new(0,6)

farmBtn.MouseButton1Click:Connect(function()
    farmFrame.Visible = not farmFrame.Visible
    farmBtn.Text = "Farm " .. (farmFrame.Visible and "▼" or "▶")
end)

-- Dragging logic
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
