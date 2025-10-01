-- Roblox Auto Power + Anti AFK UI
-- Draggable GUI with Dropdowns
-- Toggle GUI with Left Control
-- Designed for GitHub repository use

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")

-- States
local autoPower, antiAFK = false, false

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

local function stopAttack()
    autoPower = false
end

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

local function stopAFK()
    antiAFK = false
end

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "atk_gui"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,200,0,0)
container.Position = UDim2.new(0.5,-100,0.5,-125)
container.BackgroundTransparency = 1

-- Dropdown Creation Function
local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(1,0,0,30)
    frame.Position = UDim2.new(0,0,0,#container:GetChildren() * 35)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local drop = Instance.new("TextButton", frame)
    drop.Size = UDim2.new(1,0,1,0)
    drop.Text = name .. " ▼"
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 18
    drop.BackgroundTransparency = 0.1
    drop.AutoButtonColor = true

    local dropFrame = Instance.new("Frame", frame)
    dropFrame.Size = UDim2.new(1,0,#buttons * 30,0)
    dropFrame.Position = UDim2.new(0,0,1,0)
    dropFrame.BackgroundTransparency = 1
    dropFrame.Visible = false

    for i, b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1) * 30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundTransparency = 0.1
        btn.AutoButtonColor = true
        btn.MouseButton1Click:Connect(b.Func)
    end

    drop.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
    end)
end

-- Dropdowns
createDropdown("Main", {
    {Text = "Attack: OFF", Func = function()
        if autoPower then
            stopAttack()
        else
            startAttack()
        end
    end},
    {Text = "AFK: OFF", Func = function()
        if antiAFK then
            stopAFK()
        else
            startAFK()
        end
    end}
})

createDropdown("Farm", {
    -- Add more buttons here later
})

-- Dragging
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
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

-- Toggle GUI with LeftControl
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
