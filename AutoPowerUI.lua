-- CuteHub Right-Expanding Dropdown UI
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local autoPower, antiAFK = false, false

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CuteHubCustomUI"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,250,0,100)
container.Position = UDim2.new(0.5,-125,0.5,-50)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Function to create dropdown that expands RIGHT
local function createDropdown(title, posY, buttonData)
    -- Main button
    local mainBtn = Instance.new("TextButton", container)
    mainBtn.Size = UDim2.new(0,200,0,35)
    mainBtn.Position = UDim2.new(0,10,0,posY)
    mainBtn.Text = title.." ▼"
    mainBtn.Font = Enum.Font.SourceSans
    mainBtn.TextSize = 18
    mainBtn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    mainBtn.TextColor3 = Color3.fromRGB(255,255,255)
    mainBtn.BorderSizePixel = 0
    mainBtn.AutoButtonColor = true
    Instance.new("UICorner", mainBtn).CornerRadius = UDim.new(0,8)

    -- Dropdown frame (to the right of main button)
    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0,150,#buttonData*35 + 10)
    dropFrame.Position = UDim2.new(0, mainBtn.Position.X.Offset + mainBtn.Size.X.Offset + 5, 0, posY)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)

    -- Buttons inside dropdown
    for i,b in ipairs(buttonData) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,-20,0,30)
        btn.Position = UDim2.new(0,10,0,(i-1)*35 + 5)
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
        dropFrame.Visible = not dropFrame.Visible
        mainBtn.Text = title .. (dropFrame.Visible and " ▲" or " ▼")
    end)
end

-- Main dropdown
createDropdown("Main", 7, {
    {Text="Attack: OFF", Func=function()
        if autoPower then
            autoPower=false
            return
        else
            autoPower=true
            task.spawn(function()
                while autoPower do
                    r:FireServer({})
                    task.wait()
                end
            end)
        end
    end},
    {Text="AFK: OFF", Func=function()
        if antiAFK then
            antiAFK=false
            return
        else
            antiAFK=true
            task.spawn(function()
                while antiAFK do
                    local char=player.Character
                    if char and char:FindFirstChild("Humanoid") then
                        char.Humanoid:Move(Vector3.new(0,0,0))
                    end
                    task.wait(30)
                end
            end)
        end
    end}
})

-- Farm dropdown below Main
createDropdown("Farm", 52, {
    {Text="Farm Action", Func=function()
        print("Farm clicked!")
    end}
})

-- Dragging logic
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

-- Toggle UI with Left Control
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
