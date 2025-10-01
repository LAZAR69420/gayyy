-- CuteHub Style UI with Main + Farm Dropdowns (Right Expansion)
-- Author: YourName
-- GitHub: https://github.com/YourGitHubUsername/YourRepoName

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack")
local autoPower, antiAFK = false, false

-- =======================
-- ScreenGui
-- =======================
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

-- =======================
-- Dropdown Creation Function (Right Expansion)
-- =======================
local function createDropdown(parent, title, posY, buttons)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0,200,0,35)
    btn.Position = UDim2.new(0,10,0,posY)
    btn.Text = title .. " ▼"
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 18
    btn.BackgroundColor3 = Color3.fromRGB(0,90,200)
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = true
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(0,150,#buttons*35,0) -- width 150
    frame.Position = UDim2.new(0,220,posY) -- to the right of main button
    frame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Visible = false
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

    for i,b in ipairs(buttons) do
        local bBtn = Instance.new("TextButton", frame)
        bBtn.Size = UDim2.new(1,-20,0,30)
        bBtn.Position = UDim2.new(0,10,0,(i-1)*35 + 5)
        bBtn.Text = b.Text
        bBtn.Font = Enum.Font.SourceSans
        bBtn.TextSize = 16
        bBtn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        bBtn.TextColor3 = Color3.fromRGB(255,255,255)
        bBtn.BorderSizePixel = 0
        bBtn.AutoButtonColor = true
        Instance.new("UICorner", bBtn).CornerRadius = UDim.new(0,6)
        bBtn.MouseButton1Click:Connect(b.Func)
    end

    btn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
        btn.Text = title .. (frame.Visible and " ▲" or " ▼")
    end)
end

-- =======================
-- Main Dropdown
-- =======================
createDropdown(container, "Main", 7, {
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

-- =======================
-- Farm Dropdown (Below Main)
-- =======================
createDropdown(container, "Farm", 52, {  -- positioned below Main
    {Text="Farm Action", Func=function()
        print("Farm button clicked!") -- placeholder
    end}
})

-- =======================
-- Dragging
-- =======================
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

-- =======================
-- Toggle UI with Left Control
-- =======================
UserInputService.InputBegan:Connect(function(input,gp)
    if gp then return end
    if input.KeyCode==Enum.KeyCode.LeftControl then
        gui.Enabled = not gui.Enabled
    end
end)
