local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")

local autoPower, antiAFK = false, false

-- Attack / AFK functions
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

-- GUI Setup
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

-- Dropdown creation function
local dropdowns = {}
local function createDropdown(name, buttons)
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(1,-20,0,30)
    mainBtn.Position = UDim2.new(0,10,0,10 + #dropdowns*35)
    mainBtn.Text = name.." ▶"
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 18
    mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
    mainBtn.BorderSizePixel = 0
    mainBtn.AutoButtonColor = true
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,6)

    local subFrame = Instance.new("Frame", container)
    subFrame.Size = UDim2.new(0,150,#buttons*30)
    subFrame.Position = UDim2.new(1,0,0,mainBtn.Position.Y.Offset)
    subFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    subFrame.BackgroundTransparency = 0.1
    subFrame.Visible = false

    for i, b in ipairs(buttons) do
        local btn = Instance.new("TextButton", subFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1)*30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
        btn.MouseButton1Click:Connect(b.Func)
    end

    mainBtn.MouseButton1Click:Connect(function()
        subFrame.Visible = not subFrame.Visible
        mainBtn.Text = name.." "..(subFrame.Visible and "▼" or "▶")
    end)

    table.insert(dropdowns, {Main = mainBtn, Sub = subFrame})
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

-- Example: add more dropdowns for future buttons
createDropdown("Farm", {
    -- Add buttons here later
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

-- Toggle GUI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
