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

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "atk_gui"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 200, 0, 0)
container.Position = UDim2.new(0.5,-100,0.5,-125)
container.BackgroundTransparency = 1 -- fully transparent container
container.BorderSizePixel = 0

-- Background Frame behind all buttons
local bgFrame = Instance.new("Frame", container)
bgFrame.Size = UDim2.new(1, 0, 1, 0)
bgFrame.Position = UDim2.new(0,0,0,0)
bgFrame.BackgroundColor3 = Color3.fromRGB(0,120,255) -- blue background
bgFrame.BackgroundTransparency = 0.1
bgFrame.BorderSizePixel = 0
bgFrame.ZIndex = 0 -- ensures it is behind buttons
local bgCorner = Instance.new("UICorner", bgFrame)
bgCorner.CornerRadius = UDim.new(0,10)

-- Dropdowns
local allDropdowns = {}

local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0, 150, 0, 30)
    frame.Position = UDim2.new(0, 0, 0, #container:GetChildren() * 35)
    frame.BackgroundTransparency = 1 -- fully transparent frame
    frame.BorderSizePixel = 0

    local drop = Instance.new("TextButton", frame)
    drop.Size = UDim2.new(1,0,1,0)
    drop.Text = name .. " ▶"
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 18
    drop.BackgroundTransparency = 0 -- visible button
    drop.BackgroundColor3 = Color3.fromRGB(0,90,200)
    drop.TextColor3 = Color3.fromRGB(255,255,255)
    drop.AutoButtonColor = true
    local dropCorner = Instance.new("UICorner", drop)
    dropCorner.CornerRadius = UDim.new(0,6)

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0,150,0,#buttons * 30)
    dropFrame.Position = UDim2.new(1,0,0,0) -- expand to right
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    dropFrame.ZIndex = 1 -- above background

    table.insert(allDropdowns, {Button = drop, Frame = dropFrame, Name = name})

    for i, b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1)*30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundTransparency = 0 -- visible button
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.AutoButtonColor = true
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0,6)
        btn.ZIndex = 2 -- above background

        btn.MouseButton1Click:Connect(function()
            local newText = b.Func(btn)
            if newText then
                btn.Text = newText
            end
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

-- Create Dropdowns
createDropdown("Main", {
    {Text = "Attack: OFF", Func = function()
        if autoPower then stopAttack(); return "Attack: OFF"
        else startAttack(); return "Attack: ON" end
    end},
    {Text = "AFK: OFF", Func = function()
        if antiAFK then stopAFK(); return "AFK: OFF"
        else startAFK(); return "AFK: ON" end
    end}
})

createDropdown("Farm", {})

-- Dragging
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
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

-- Toggle GUI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
