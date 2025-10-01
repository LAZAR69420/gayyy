local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")

local autoPower, antiAFK = false, false

local function startAttack() if autoPower then return end autoPower=true task.spawn(function() while autoPower do r:FireServer({}) task.wait() end end) end
local function stopAttack() autoPower=false end
local function startAFK() if antiAFK then return end antiAFK=true task.spawn(function() while antiAFK do local c=player.Character if c and c:FindFirstChild("Humanoid") then c.Humanoid:Move(Vector3.new(0,0,0)) end task.wait(30) end end) end
local function stopAFK() antiAFK=false end

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name="atk_gui"
gui.ResetOnSpawn=false
gui.Enabled=true

local container = Instance.new("Frame", gui)
container.Size=UDim2.new(0,400,0,150)
container.Position=UDim2.new(0.5,-200,0.5,-75)
container.BackgroundColor3=Color3.fromRGB(0,120,255)
container.BackgroundTransparency=0.2
container.BorderSizePixel=0
Instance.new("UICorner", container).CornerRadius=UDim.new(0,10)

-- Function to create horizontal dropdowns
local function createDropdown(title, yOffset, buttons)
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size=UDim2.new(0,120,0,30)
    mainBtn.Position=UDim2.new(0,10,yOffset,0)
    mainBtn.Text=title.." ▼"
    mainBtn.Font=Enum.Font.SourceSans
    mainBtn.TextSize=18
    mainBtn.BackgroundColor3=Color3.fromRGB(0,90,200)
    mainBtn.TextColor3=Color3.fromRGB(255,255,255)
    mainBtn.BorderSizePixel=0
    mainBtn.AutoButtonColor=true
    Instance.new("UICorner", mainBtn).CornerRadius=UDim.new(0,6)

    -- Create dropdown frame that expands to the right
    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size=UDim2.new(0,#buttons*130,0,#buttons*35)
    dropFrame.Position=UDim2.new(0, mainBtn.Position.X.Offset + mainBtn.Size.X.Offset + 5, 0, mainBtn.Position.Y.Offset)
    dropFrame.BackgroundColor3=Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency=0.1
    dropFrame.BorderSizePixel=0
    dropFrame.Visible=false
    Instance.new("UICorner", dropFrame).CornerRadius=UDim.new(0,6)

    for i, b in ipairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size=UDim2.new(0,120,0,30)
        btn.Position=UDim2.new(0,(i-1)*125,0,0)
        btn.Text=b.Text
        btn.Font=Enum.Font.SourceSans
        btn.TextSize=16
        btn.BackgroundColor3=Color3.fromRGB(0,120,255)
        btn.TextColor3=Color3.fromRGB(255,255,255)
        btn.BorderSizePixel=0
        btn.AutoButtonColor=true
        Instance.new("UICorner", btn).CornerRadius=UDim.new(0,6)
        btn.MouseButton1Click:Connect(function() b.Func(btn) end)
    end

    mainBtn.MouseButton1Click:Connect(function()
        dropFrame.Visible=not dropFrame.Visible
        mainBtn.Text=title.." "..(dropFrame.Visible and "▲" or "▼")
    end)
end

-- Main dropdown
createDropdown("Main",10,{
    {Text="Attack: OFF", Func=function(btn)
        if autoPower then stopAttack(); btn.Text="Attack: OFF" else startAttack(); btn.Text="Attack: ON" end
    end},
    {Text="AFK: OFF", Func=function(btn)
        if antiAFK then stopAFK(); btn.Text="AFK: OFF" else startAFK(); btn.Text="AFK: ON" end
    end}
})

-- Farm dropdown (empty for now)
createDropdown("Farm",60,{
    -- Add buttons later
})

-- Dragging
local dragging, dragInput, dragStart, startPos=false,nil,nil,nil
container.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 then
        dragging=true
        dragStart=input.Position
        startPos=container.Position
        input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
container.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end end)
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
        gui.Enabled=not gui.Enabled
    end
end)
