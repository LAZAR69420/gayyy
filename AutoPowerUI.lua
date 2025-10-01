local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack", 5)
local autoPower, antiAFK = false, false

-- Load Rayfield Library using the new SiriusSoftwareLtd GitHub raw source
local Rayfield
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end)
if success then
    Rayfield = result
    print("Rayfield library loaded successfully from SiriusSoftwareLtd repo")
else
    warn("Failed to load Rayfield library: " .. tostring(result))
    return -- Exit if library fails to load
end

-- Create Rayfield Window with SecureMode to bypass potential UI issues
local Window
success, err = pcall(function()
    Window = Rayfield:CreateWindow({
        Name = "CuteHub UI",
        LoadingTitle = "CuteHub Interface",
        LoadingSubtitle = "by xAI",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "CuteHub",
            FileName = "CuteHubConfig"
        },
        KeySystem = false,
        SecureMode = true -- Enable to reduce UI detection/conflicts (disable if not needed)
    })
end)
if not success then
    warn("Failed to create Rayfield window: " .. tostring(err) .. ". UI creation aborted. Try disabling TopbarPlus or a different Rayfield source. Functionality may still work via toggles.")
    Window = nil -- Ensure Window is nil if creation fails
else
    print("Rayfield window created successfully")
end

-- Create Main Tab only if Window exists
local MainTab
if Window then
    success, err = pcall(function()
        MainTab = Window:CreateTab("Main Controls", nil)
    end)
    if not success then
        warn("Failed to create MainTab: " .. tostring(err))
        MainTab = nil
    end
end

-- Attack Toggle only if MainTab exists
local AttackToggle
if MainTab then
    success, err = pcall(function()
        AttackToggle = MainTab:CreateToggle({
            Name = "Auto Attack",
            CurrentValue = false,
            Flag = "AttackToggle",
            Callback = function(Value)
                autoPower = Value
                print("Auto Attack set to: " .. tostring(Value))
                if Value then
                    task.spawn(function()
                        while autoPower do
                            if r then
                                local fireSuccess, fireErr = pcall(function()
                                    r:FireServer({})
                                end)
                                if not fireSuccess then
                                    warn("Failed to fire PlayerClickAttack: " .. tostring(fireErr))
                                    autoPower = false
                                    if AttackToggle then AttackToggle:Set(false) end
                                end
                            else
                                warn("PlayerClickAttack remote not found")
                                autoPower = false
                                if AttackToggle then AttackToggle:Set(false) end
                                break
                            end
                            task.wait(0.1) -- Prevent excessive firing/lag
                        end
                    end)
                end
            end
        })
    end)
    if not success then
        warn("Failed to create AttackToggle: " .. tostring(err))
    end
end

-- AFK Toggle only if MainTab exists
local AFKToggle
if MainTab then
    success, err = pcall(function()
        AFKToggle = MainTab:CreateToggle({
            Name = "Anti AFK",
            CurrentValue = false,
            Flag = "AFKToggle",
            Callback = function(Value)
                antiAFK = Value
                print("Anti AFK set to: " .. tostring(Value))
                if Value then
                    task.spawn(function()
                        while antiAFK do
                            local char = player.Character
                            if char and char:FindFirstChild("Humanoid") then
                                char.Humanoid:Move(Vector3.new(0, 0, 0))
                                print("Anti AFK movement simulated")
                            else
                                warn("Character or Humanoid not found for Anti AFK")
                            end
                            task.wait(30)
                        end
                    end)
                end
            end
        })
    end)
    if not success then
        warn("Failed to create AFKToggle: " .. tostring(err))
    end
end

-- Toggle UI with Left Control using UserInputService
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if Window and Window.Toggle then
            Window:Toggle()
            print("UI Toggled via Left Control")
        elseif Window and Window.MainFrame then
            Window.MainFrame.Visible = not Window.MainFrame.Visible
            print("UI Toggled via MainFrame visibility")
        else
            warn("UI toggle failed: No valid Window or MainFrame")
        end
    end
end)

-- Notify on successful load if Window exists
if Window then
    success, err = pcall(function()
        Rayfield:Notify({
            Title = "CuteHub UI",
            Content = "Loaded successfully! Press Left Control to toggle visibility.",
            Duration = 5,
            Image = nil
        })
    end)
    if not success then
        warn("Notification failed: " .. tostring(err))
    end
end

-- Load saved configuration if Rayfield and LoadConfiguration exist
if Rayfield and Rayfield.LoadConfiguration then
    Rayfield:LoadConfiguration()
    print("Configuration loaded")
end
