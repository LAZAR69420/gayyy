local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))() local Players = game:GetService("Players") local UserInputService = game:GetService("UserInputService") local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack") local autoPower, antiAFK = false, false

-- Create Rayfield Window local Window = Rayfield:CreateWindow({ Name = "CuteHub UI", LoadingTitle = "CuteHub Interface", LoadingSubtitle = "by xAI", ConfigurationSaving = { Enabled = true, FolderName = "CuteHub", FileName = "CuteHubConfig" }, KeySystem = false })

-- Create Main Tab local MainTab = Window:CreateTab("Main Controls", nil)

-- Attack Toggle local AttackToggle = MainTab:CreateToggle({ Name = "Auto Attack", CurrentValue = false, Flag = "AttackToggle", Callback = function(Value) autoPower = Value if Value then task.spawn(function() while autoPower do r:FireServer({}) task.wait() end end) end end })

-- AFK Toggle local AFKToggle = MainTab:CreateToggle({ Name = "Anti AFK", CurrentValue = false, Flag = "AFKToggle", Callback = function(Value) antiAFK = Value if Value then task.spawn(function() while antiAFK do local char = player.Character if char and char:FindFirstChild("Humanoid") then char.Humanoid:Move(Vector3.new(0, 0, 0)) end task.wait(30) end end) end end })

-- Keybind to toggle UI visibility local UIToggleKeybind = MainTab:CreateKeybind({ Name = "Toggle UI", CurrentKeybind = "LeftControl", HoldToInteract = false, Flag = "UIToggleKeybind", Callback = function() Window:Toggle() end })

-- Notify on UI load Rayfield:Notify("CuteHub UI", "UI loaded successfully! Use Left Control to toggle visibility.", nil)
