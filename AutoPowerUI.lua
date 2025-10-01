-- Load the Cute Hub UI
local hub = loadstring(game:HttpGet("https://raw.githubusercontent.com/quteeeee/etuchub/refs/heads/main/Cute%20Hub"))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local autoPower, antiAFK = false, false

-- Wait for the hub container (replace "hubFrame" with actual container name if different)
local gui = player:WaitForChild("PlayerGui")
local container
repeat
    container = gui:FindFirstChild("hubFrame") -- check the real name inside Cute Hub
    task.wait()
until container

-- Helper function to create buttons
local function createButton(text, posY, func)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,150,0,30)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.Text = text
    btn.Parent = container
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    btn.MouseButton1Click:Connect(function() func(btn) end)
    return btn
end

-- Attack button
local attackBtn = createButton("Attack: OFF", 50, function(btn)
    if autoPower then
        autoPower=false
        btn.Text="Attack: OFF"
    else
        autoPower=true
        btn.Text="Attack: ON"
        task.spawn(function()
            while autoPower do
                r:FireServer({})
                task.wait()
            end
        end)
    end
end)

-- Anti-AFK button
local afkBtn = createButton("AFK: OFF", 90, function(btn)
    if antiAFK then
        antiAFK=false
        btn.Text="AFK: OFF"
    else
        antiAFK=true
        btn.Text="AFK: ON"
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

-- Dragging the hub
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

-- Toggle GUI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        container.Parent.Enabled = not container.Parent.Enabled
    end
end)
