-- Cute Hub style UI with Main and Farm dropdowns
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local autoPower, antiAFK = false, false

-- ScreenGui
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "CuteHubCustomUI"
gui.ResetOnSpawn = false
gui.Enabled = true

-- Main container
local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0,250,0,100)
container.Position = UDim2.new(0.5,-125,0.5,-50)
container.BackgroundColor3 = Color3.fromRGB(0,120,255)
container.BackgroundTransparency = 0.1
container.BorderSizePixel = 0
Instance.new("UICorner", container).CornerRadius = UDim.new(0,12)

-- Function to create dropdown
local function createDropdown(parent, name, width, buttons, yOffset)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,width,0,35)
    btn.Position = UDim2.new(0,10,0,yOffset)
    btn.Text = name .. " ▼"
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local dropFrame = Instance.new("Frame", parent)
    dropFrame.Size = UDim2.new(0,width,0,#buttons*35)
    dropFrame.Position = UDim2.new(1,5,0,yOffset)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    Instance.new("UICorner", dropFrame).CornerRadius = UDim.new(0,8)

    for i,b in pairs(buttons) do
        local subBtn = Instance.new("TextButton", dropFrame)
        subBtn.Size = UDim2.new(1,-20,0,30)
        subBtn.Position = UDim2.new(0,10,0,(i-1)*35 + 5)
        subBtn.Text = b.Text
        subBtn.Font = Enum.Font.SourceSans
        subBtn.TextSize = 16
        subBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        subBtn.TextColor3 = Color3.fromRGB(255,255,255)
        subBtn.BorderSizePixel = 0
        subBtn.AutoButtonColor = true
        Instance.new("UICorner", subBtn).CornerRadius = UDim.new(0,6)

        subBtn.MouseButton1Click:Connect(function()
            if b.Func then b.Func(subBtn) end
        end)
    end

    btn.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        btn.Text = name .. (dropFrame.Visible and " ▲" or " ▼")
    end)

    return {Button=btn, Frame=dropFrame}
end

-- Main dropdown at top
createDropdown(container, "Main", 200, {
    {Text="Attack: OFF", Func=function(subBtn)
        local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
        if autoPower then
            autoPower=false
            subBtn.Text="Attack: OFF"
        else
            autoPower=true
            subBtn.Text="Attack: ON"
            task.spawn(function()
                while autoPower do
                    r:FireServer({})
                    task.wait()
                end
            end)
        end
    end},
    {Text="AFK: OFF", Func=function(subBtn)
        if antiAFK then
            antiAFK=false
            subBtn.Text="AFK: OFF"
        else
            antiAFK=true
            subBtn.Text="AFK: ON"
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
    end}
}, 5)

-- Farm dropdown below Main
createDropdown(container, "Farm", 200, {
    {Text="Hero Skill", Func=function()
        local HeroSkillHarm = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("HeroSkillHarm")
        HeroSkillHarm:FireServer({
            harmIndex = 100000,
            isSkill = false,
            heroGuid = "c1ce73a8-7298-4628-8dc6-71acf61e8256",
            skillId = 200001
        })
    end}
}, 50) -- yOffset is below Main button

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
