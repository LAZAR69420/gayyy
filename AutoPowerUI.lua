-- AutoPower + Anti AFK UI for Roblox
-- Draggable GUI with horizontal dropdowns
-- Main and Farm dropdowns close together
-- Blue background
-- Toggle GUI with Left Control

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
local function stopAttack() autoPower = false end

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

-- GUI Setup
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "atk_gui"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 450, 0, 100) -- width enough for horizontal buttons, height fits dropdowns
container.Position = UDim2.new(0.5, -225, 0.5, -50)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)

-- Dropdown creator (horizontal)
local function createHorizontalDropdown(title, buttons, yOffset)
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(0, 180, 0, 30)
    mainBtn.Position = UDim2.new(0, 10, 0, yOffset or 10)
    mainBtn.Text = title.." ▼"
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 18
    mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
    mainBtn.BorderSizePixel = 0
    mainBtn.AutoButtonColor = true
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,6)

    -- Dropdown frame
    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0,0,0,30)
    dropFrame.Position = UDim2.new(0, mainBtn.Position.X.Offset + mainBtn.Size.X.Offset, 0, mainBtn.Position.Y.Offset)
    dropFrame.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", dropFrame)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0,5)

    local subButtons = {}
    for i, b in ipairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(0,120,0,30)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        btn.Visible = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        btn.MouseButton1Click:Connect(b.Func)
        table.insert(subButtons, btn)
    end

    local open = false
    mainBtn.MouseButton1Click:Connect(function()
        open = not open
        for _, btn in ipairs(subButtons) do
            btn.Visible = open
        end
        mainBtn.Text = title.." "..(open and "▲" or "▼")

        -- resize container width to fit buttons if open
        if open then
            local totalWidth = mainBtn.Position.X.Offset + mainBtn.Size.X.Offset + #subButtons*(120 + 5) + 10
            container.Size = UDim2.new(0, totalWidth, container.Size.Y.Scale, container.Size.Y.Offset)
        else
            container.Size = UDim2.new(0, 450, container.Size.Y.Scale, container.Size.Y.Offset)
        end
    end)
end

-- Create dropdowns with fixed Y offsets
createHorizontalDropdown("Main", {
    {Text="Attack: OFF", Func=function(btn)
        if autoPower then stopAttack(); btn.Text="Attack: OFF"
        else startAttack(); btn.Text="Attack: ON" end
    end},
    {Text="AFK: OFF", Func=function(btn)
        if antiAFK then stopAFK(); btn.Text="AFK: OFF"
        else startAFK(); btn.Text="AFK: ON" end
    end}
}, 10)

createHorizontalDropdown("Farm", {
    -- future buttons here
}, 50)

-- Dragging
local dragging, dragInput, dragStart, startPos = false,nil,nil,nil
container.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
container.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput=input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then
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
