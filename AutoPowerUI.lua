local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")

local autoPower, antiAFK = false, false

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

local function stopAttack()
    autoPower = false
end

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

local function stopAFK()
    antiAFK = false
end

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "atk_gui"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,250,0,120)
container.Position = UDim2.new(0.5,-125,0.5,-60)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BorderSizePixel = 0
local uicorner = Instance.new("UICorner", container)
uicorner.CornerRadius = UDim.new(0,12)

-- Main Dropdown Button
local mainBtn = Instance.new("TextButton", container)
mainBtn.Size = UDim2.new(1,-20,0,30)
mainBtn.Position = UDim2.new(0,10,0,10)
mainBtn.Text = "Main ▼"
mainBtn.Font = Enum.Font.SourceSans
mainBtn.TextSize = 18
mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
mainBtn.BorderSizePixel = 0
mainBtn.AutoButtonColor = true
local mainCorner = Instance.new("UICorner", mainBtn)
mainCorner.CornerRadius = UDim.new(0,6)

-- Sub-buttons inside dropdown
local attackBtn = Instance.new("TextButton", container)
attackBtn.Size = UDim2.new(1,-40,0,30)
attackBtn.Position = UDim2.new(0,20,0,50)
attackBtn.Text = "Attack: OFF"
attackBtn.Font = Enum.Font.SourceSans
attackBtn.TextSize = 16
attackBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
attackBtn.TextColor3 = Color3.fromRGB(255,255,255)
attackBtn.BorderSizePixel = 0
local attackCorner = Instance.new("UICorner", attackBtn)
attackCorner.CornerRadius = UDim.new(0,6)
attackBtn.Visible = false

local afkBtn = Instance.new("TextButton", container)
afkBtn.Size = UDim2.new(1,-40,0,30)
afkBtn.Position = UDim2.new(0,20,0,90)
afkBtn.Text = "AFK: OFF"
afkBtn.Font = Enum.Font.SourceSans
afkBtn.TextSize = 16
afkBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
afkBtn.TextColor3 = Color3.fromRGB(255,255,255)
afkBtn.BorderSizePixel = 0
local afkCorner = Instance.new("UICorner", afkBtn)
afkCorner.CornerRadius = UDim.new(0,6)
afkBtn.Visible = false

-- Toggle dropdown visibility
mainBtn.MouseButton1Click:Connect(function()
    attackBtn.Visible = not attackBtn.Visible
    afkBtn.Visible = not afkBtn.Visible
    mainBtn.Text = "Main " .. (attackBtn.Visible and "▲" or "▼")
end)

-- Button functions
attackBtn.MouseButton1Click:Connect(function()
    if autoPower then stopAttack(); attackBtn.Text="Attack: OFF"
    else startAttack(); attackBtn.Text="Attack: ON" end
end)

afkBtn.MouseButton1Click:Connect(function()
    if antiAFK then stopAFK(); afkBtn.Text="AFK: OFF"
    else startAFK(); afkBtn.Text="AFK: ON" end
end)

-- Dragging
local dragging, dragInput, dragStart, startPos = false,nil,nil,nil
container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle GUI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
