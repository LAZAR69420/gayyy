-- Roblox Auto Power + Anti AFK UI
-- Draggable UI with Dropdowns
-- Toggle GUI with Left Control
-- Blue background
-- AFK button visible

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
container.Size = UDim2.new(0,240,0,60)
container.Position = UDim2.new(0.5,-120,0.5,-30)
container.BackgroundColor3 = Color3.fromRGB(0,120,255) -- main blue background
container.BorderSizePixel = 0

local uicorner = Instance.new("UICorner", container)
uicorner.CornerRadius = UDim.new(0,12)

-- Dropdown handling
local allDropdowns = {}

local function createDropdown(name, buttons)
    local dropButton = Instance.new("TextButton", container)
    dropButton.Size = UDim2.new(0,220,0,30)
    dropButton.Position = UDim2.new(0,10,#container:GetChildren()*35 - 30,0)
    dropButton.Text = name .. " ▶"
    dropButton.Font = Enum.Font.SourceSans
    dropButton.TextSize = 18
    dropButton.BackgroundColor3 = Color3.fromRGB(0,90,200)
    dropButton.TextColor3 = Color3.fromRGB(255,255,255)
    dropButton.BorderSizePixel = 0
    dropButton.AutoButtonColor = true
    local dropCorner = Instance.new("UICorner", dropButton)
    dropCorner.CornerRadius = UDim.new(0,8)

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0,150,#buttons*30)
    dropFrame.Position = UDim2.new(0,220,0,dropButton.Position.Y.Offset)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0,100,220)
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false
    local dropCorner2 = Instance.new("UICorner", dropFrame)
    dropCorner2.CornerRadius = UDim.new(0,8)

    for i,b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1)*30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = true
        local btnCorner = Instance.new("UICorner", btn)
        btnCorner.CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(function()
            local newText = b.Func(btn)
            if newText then btn.Text = newText end
        end)
    end

    dropButton.MouseButton1Click:Connect(function()
        local isOpen = dropFrame.Visible
        for _, dd in pairs(allDropdowns) do
            dd.Frame.Visible = false
            dd.Button.Text = dd.Name .. " ▶"
        end
        dropFrame.Visible = not isOpen
        dropButton.Text = name .. (dropFrame.Visible and " ▼" or " ▶")
    end)

    table.insert(allDropdowns, {Button=dropButton, Frame=dropFrame, Name=name})
end

-- Main Dropdown
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

-- Farm Dropdown (empty for now)
createDropdown("Farm", {})

-- Dragging
local dragging, dragInp
