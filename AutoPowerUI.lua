local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")

local autoPower, antiAFK = false, false

-- Functions
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
local function stopAttack() autoPower=false end

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
local function stopAFK() antiAFK=false end

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "atk_gui"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,200,0,50)
container.Position = UDim2.new(0.5,-100,0.5,-125)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,10)

-- Dropdown function
local function createDropdown(title, buttons)
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(0,180,0,30)
    mainBtn.Position = UDim2.new(0,10,0,#container:GetChildren()*35-35)
    mainBtn.Text = title.." ▼"
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 18
    mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
    mainBtn.BorderSizePixel = 0
    mainBtn.AutoButtonColor = true
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,6)

    local subButtons = {}
    for i,b in ipairs(buttons) do
        local btn = Instance.new("TextButton", container)
        btn.Size = UDim2.new(0,160,0,30)
        btn.Position = UDim2.new(0,20,0, mainBtn.Position.Y.Offset + 30*i)
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

        -- Resize container
        local totalHeight = 50
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("TextButton") and child.Visible then
                totalHeight = math.max(totalHeight, child.Position.Y.Offset + child.Size.Y.Offset + 10)
            end
        end
        container.Size = UDim2.new(container.Size.X.Scale, container.Size.X.Offset, 0, totalHeight)
    end)
end

-- Create dropdowns
createDropdown("Main", {
    {Text="Attack: OFF", Func=function(btn)
        if autoPower then stopAttack(); btn.Text="Attack: OFF" else startAttack(); btn.Text="Attack: ON" end
    end},
    {Text="AFK: OFF", Func=function(btn)
        if antiAFK then stopAFK(); btn.Text="AFK: OFF" else startAFK(); btn.Text="AFK: ON" end
    end}
})

createDropdown("Farm", {
    -- future buttons
})

-- Dragging
local dragging, dragInput, dragStart, startPos = false,nil,nil,nil
container.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = container.Position
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
        local delta = input.Position - dragStart
        container.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Toggle GUI
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
