-- Roblox Auto Power + Anti AFK UI
-- Draggable, toggleable, blue background, visible AFK button

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
container.Size = UDim2.new(0,240,0,40)
container.Position = UDim2.new(0.5,-120,0.5,-20)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BorderSizePixel = 0

local uicorner = Instance.new("UICorner", container)
uicorner.CornerRadius = UDim.new(0,12)

-- Layout for stacking buttons
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0,5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Dropdowns
local allDropdowns = {}

local function createDropdown(name, buttons)
    local dropButton = Instance.new("TextButton", container)
    dropButton.Size = UDim2.new(1, -20, 0, 30)
    dropButton.Text = name .. " ▶"
    dropButton.Font = Enum.Font.SourceSans
    dropButton.TextSize = 18
    dropButton.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropButton.TextColor3 = Color3.fromRGB(255,255,255)
    dropButton.BorderSizePixel = 0
    local dropCorner = Instance.new("UICorner", dropButton)
    dropCorner.CornerRadius = UDim.new(0,6)

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(1, -20, 0, #buttons * 35)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,100,220)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    local dropCorner2 = Instance.new("UICorner", dropFrame)
    dropCorner2.CornerRadius = UDim.new(0,6)

    local frameLayout = Instance.new("UIListLayout", dropFrame)
    frameLayout.SortOrder = Enum.SortOrder.LayoutOrder
    frameLayout.Padding = UDim.new(0,5)

    -- Create buttons inside dropdown
    for i,b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0,6)
        btn.AutoButtonColor = true

        btn.MouseButton1Click:Connect(function()
            local newText = b.Func(btn)
            if newText then btn.Text = newText end
        end)
    end

    dropButton.MouseButton1Click:Connect(function()
        local isOpen = dropFrame.Visible
        dropFrame.Visible = not isOpen
        dropButton.Text = name .. (isOpen and " ▶" or " ▼")
    end)
end

-- Main dropdown
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

-- Farm dropdown (empty for now)
createDropdown("Farm", {})

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
