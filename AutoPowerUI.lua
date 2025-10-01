-- Roblox Auto Power + Anti AFK UI
-- Draggable GUI with Dropdowns
-- Toggle GUI with Left Control
-- GitHub ready

-- Services
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
gui.Name = "AutoUI"
gui.ResetOnSpawn = false
gui.Enabled = true

local container = Instance.new("Frame", gui)
container.Size = UDim2.new(0, 250, 0, 50)
container.Position = UDim2.new(0.5, -125, 0.5, -125)
container.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
container.BackgroundTransparency = 0.2
container.BorderSizePixel = 0
local bgCorner = Instance.new("UICorner", container)
bgCorner.CornerRadius = UDim.new(0, 10)

-- Dropdown creation function
local allDropdowns = {}
local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0, 150, 0, 30)
    frame.Position = UDim2.new(0, 10, 0, #allDropdowns*40 + 10)
    frame.BackgroundColor3 = Color3.fromRGB(0,90,200)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0,6)

    local dropBtn = Instance.new("TextButton", frame)
    dropBtn.Size = UDim2.new(1,0,1,0)
    dropBtn.Text = name .. " ▶"
    dropBtn.Font = Enum.Font.SourceSans
    dropBtn.TextSize = 18
    dropBtn.BackgroundTransparency = 1
    dropBtn.TextColor3 = Color3.fromRGB(255,255,255)
    dropBtn.AutoButtonColor = true

    local dropFrame = Instance.new("Frame", container)
    dropFrame.Size = UDim2.new(0, 150, 0, #buttons*30)
    dropFrame.Position = UDim2.new(0, 160, 0, #allDropdowns*40 + 10)
    dropFrame.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
    dropFrame.BackgroundTransparency = 0.1
    dropFrame.BorderSizePixel = 0
    dropFrame.Visible = false

    for i,b in ipairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1)*30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundColor3 = Color3.fromRGB(0,120,255)
        btn.TextColor3 = Color3.fromRGB(25
