local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local r = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PlayerClickAttack", 5)
local HeroUseSkill = ReplicatedStorage.Remotes.HeroUseSkill
local autoPower, antiAFK, skillSpamActive = false, false, false

-- Load Rayfield Library
local Rayfield
local success, result = pcall(function()
    return loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua', true))()
end)
if success then
    Rayfield = result
    print("Rayfield library loaded successfully")
else
    warn("Failed to load Rayfield library: " .. tostring(result))
    return
end

-- Create Rayfield Window
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
        SecureMode = true
    })
end)
if not success then
    warn("Failed to create Rayfield window: " .. tostring(err))
    Window = nil
else
    print("Rayfield window created successfully")
end

-- Create Main Tab
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

-- Function to wait for character
local function waitForCharacter()
    local char = player.Character
    while not char or not char:FindFirstChild("Humanoid") do
        char = player.CharacterAdded:Wait()
    end
    return true
end

-- Auto Attack Toggle
if MainTab then
    local AttackToggle
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
                            task.wait(0.1)
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

-- Anti AFK Toggle
if MainTab then
    local AFKToggle
    success, err = pcall(function()
        AFKToggle = MainTab:CreateToggle({
            Name = "Anti AFK",
            CurrentValue = false,
            Flag = "AFKToggle",
            Callback = function(Value)
                antiAFK = Value
                print("Anti AFK set to: " .. tostring(Value))
                if Value then
                    local co = coroutine.create(function()
                        while antiAFK do
                            if waitForCharacter() then
                                pcall(function()
                                    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                                    task.wait(0.1)
                                    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                                end)
                                print("Anti AFK simulated click")
                            end
                            task.wait(60) -- every 60 seconds
                        end
                    end)
                    coroutine.resume(co)
                end
            end
        })
    end)
    if not success then
        warn("Failed to create AFKToggle: " .. tostring(err))
    end
end

-- Skill Spam Toggle
if MainTab then
    local SkillSpamToggle
    success, err = pcall(function()
        SkillSpamToggle = MainTab:CreateToggle({
            Name = "Toggle Skill Spam",
            CurrentValue = false,
            Flag = "SkillSpamToggle",
            Callback = function(Value)
                skillSpamActive = Value
                print("Skill Spam set to: " .. tostring(Value))
                if Value then
                    task.spawn(function()
                        while skillSpamActive do
                            if HeroUseSkill then
                                local fireSuccess, fireErr = pcall(function()
                                    HeroUseSkill:FireServer({
                                        heroGuid = "f587d23f-e41e-411c-9d6f-bee66b6c7e71",
                                        attackType = 1,
                                        userId = 9505262071,
                                        enemyGuid = "c390ec90-8b18-4b6e-a3bf-751060bb42e8"
                                    })
                                end)
                                if not fireSuccess then
                                    warn("Failed to fire HeroUseSkill: " .. tostring(fireErr))
                                    skillSpamActive = false
                                    if SkillSpamToggle then SkillSpamToggle:Set(false) end
                                    break
                                end
                            else
                                warn("HeroUseSkill remote not found")
                                skillSpamActive = false
                                if SkillSpamToggle then SkillSpamToggle:Set(false) end
                                break
                            end
                            task.wait(0.01) -- Very fast spam (10ms delay)
                        end
                    end)
                end
            end
        })
    end)
    if not success then
        warn("Failed to create SkillSpamToggle: " .. tostring(err))
    end
end

-- Toggle UI with Left Control
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        if Window and Window.Toggle then
            Window:Toggle()
        elseif Window and Window.MainFrame then
            Window.MainFrame.Visible = not Window.MainFrame.Visible
        else
            warn("UI toggle failed")
        end
    end
end)

-- Notify load success
if Window then
    pcall(function()
        Rayfield:Notify({
            Title = "CuteHub UI",
            Content = "Loaded successfully! Press Left Control to toggle visibility.",
            Duration = 5,
            Image = nil
        })
    end)
end

-- Load saved configuration
if Rayfield and Rayfield.LoadConfiguration then
    Rayfield:LoadConfiguration()
    print("Configuration loaded")
end
