-- Store all dropdown frames globally
local allDropdowns = {}

local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0,150,0,30)
    frame.Position = UDim2.new(0,0,0,#container:GetChildren() * 35)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local drop = Instance.new("TextButton", frame)
    drop.Size = UDim2.new(1,0,1,0)
    drop.Text = name .. " ▶" -- arrow points right when closed
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 18
    drop.BackgroundTransparency = 0.1
    drop.AutoButtonColor = true

    local dropFrame = Instance.new("Frame", frame)
    dropFrame.Size = UDim2.new(0,150,0,#buttons * 30)
    dropFrame.Position = UDim2.new(1,0,0,0) -- appear to the right
    dropFrame.BackgroundTransparency = 0.35
    dropFrame.BorderSizePixel = 0
    dropFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dropFrame.Visible = false

    -- Store dropdown in global list
    table.insert(allDropdowns, {Button = drop, Frame = dropFrame, Name = name})

    for i, b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1) * 30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundTransparency = 0.1
        btn.AutoButtonColor = true

        -- wrap button logic with text updates
        btn.MouseButton1Click:Connect(function()
            local newText = b.Func(btn) -- pass button to function
            if newText then
                btn.Text = newText -- update button text dynamically
            end
        end)
    end

    drop.MouseButton1Click:Connect(function()
        local isOpen = dropFrame.Visible

        -- Close all other dropdowns
        for _, dd in ipairs(allDropdowns) do
            dd.Frame.Visible = false
            dd.Button.Text = dd.Name .. " ▶"
        end

        -- Toggle this dropdown
        dropFrame.Visible = not isOpen
        drop.Text = name .. (dropFrame.Visible and " ▼" or " ▶")
    end)
end

-- Dropdowns
createDropdown("Main", {
    {Text = "Attack: OFF", Func = function(btn)
        if autoPower then
            stopAttack()
            return "Attack: OFF"
        else
            startAttack()
            return "Attack: ON"
        end
    end},
    {Text = "AFK: OFF", Func = function(btn)
        if antiAFK then
            stopAFK()
            return "AFK: OFF"
        else
            startAFK()
            return "AFK: ON"
        end
    end}
})
