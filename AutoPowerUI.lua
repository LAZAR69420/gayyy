-- Roblox Auto Power + Anti AFK UI
-- Draggable UI with Dropdowns
-- Toggle GUI with Left Control
-- Blue background
-- Fixed: AFK button visible

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
container.Size = UDim2.new(0,220,0,40)
container.Position = UDim2.new(0.5,-110,0.5,-20)
container.BackgroundColor3 = Color3.fromRGB(0,120,255) -- bright blue background
container.BorderSizePixel = 0

local uicorner = Instance.new("UICorner", container)
uicorner.CornerRadius = UDim.new(0,10)

-- Dropdown handling
local allDropdowns = {}

local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0,200,0,30)
    frame.Position = UDim2.new(0,0,#container:GetChildren()*35,0)
    frame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    frame.BorderSizePixel = 0
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0,8)

    local drop = Instance.new("TextButton", frame)
    drop.Size = UDim2.new(1,0,1,0)
    drop.Text = name .. " ▶"
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 18
    drop.BackgroundTransparency = 1
    drop.TextColor3 = Color3.fromRGB(255,255,255)

    local dropFrame = Instance.new("Frame", frame)
    dropFrame.Size = UDim2.new(0,200,0,#buttons*30)
    dropFrame.Position = UDim2.new(1,5,0,0)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,100,220)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = true -- default visible so AFK button shows
    local dropCorner = Instance.new("UICorner", dropFrame)
    dropCorner.CornerRadius = UDim.new(0,8)

    table.insert(allDropdowns, {Button=drop, Frame=dropFrame, Name=name})

    for i,b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1)*30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.BorderSizePixel = 0
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0,6)
        btn.AutoButtonColor = true

        btn.MouseButton1Click:Connect(function()
            local newText = b.Func(btn)
            if newText then btn.Text = newText end
        end)
    end

    drop.MouseButton1Click:Connect(function()
        local isOpen = dropFrame.Visible
        for _, dd in ipairs(allDropdowns) do
            dd.Frame.Visible = false
            dd.Button.Text = dd.Name .. " ▶"
        end
        dropFrame.Visible = not isOpen
        drop.Text = name .. (dropFrame.Visible and " ▼" or " ▶")
    end)
end

-- Create Main Dropdown with both buttons
createDropdown("Main", {
    {Text="Attack: OFF", Func=function()
        if autoPower then stopAttack() return "Attack: OFF"
        else startAttack() return "Attack: ON" end
    end},
    {Text="AFK: OFF", Func=function()
        if antiAFK then stopAFK() return "AFK: OFF"
        else startAFK() return "AFK: ON" end
    end}
})

createDropdown("Farm", {
    -- add more buttons later
})

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
