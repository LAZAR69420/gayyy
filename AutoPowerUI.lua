local function createDropdown(name, buttons)
    local frame = Instance.new("Frame", container)
    frame.Size = UDim2.new(0,150,0,30) -- fixed width for button
    frame.Position = UDim2.new(0,0,0,#container:GetChildren() * 35)
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

    local drop = Instance.new("TextButton", frame)
    drop.Size = UDim2.new(1,0,1,0)
    drop.Text = name .. " ▶" -- arrow points right
    drop.Font = Enum.Font.SourceSans
    drop.TextSize = 18
    drop.BackgroundTransparency = 0.1
    drop.AutoButtonColor = true

    -- dropdown frame goes to the RIGHT instead of down
    local dropFrame = Instance.new("Frame", frame)
    dropFrame.Size = UDim2.new(0,150,0,#buttons * 30)
    dropFrame.Position = UDim2.new(1,0,0,0) -- to the right of button
    dropFrame.BackgroundTransparency = 0.35
    dropFrame.BorderSizePixel = 0
    dropFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    dropFrame.Visible = false

    for i, b in pairs(buttons) do
        local btn = Instance.new("TextButton", dropFrame)
        btn.Size = UDim2.new(1,0,0,30)
        btn.Position = UDim2.new(0,0,(i-1) * 30,0)
        btn.Text = b.Text
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 16
        btn.BackgroundTransparency = 0.1
        btn.AutoButtonColor = true
        btn.MouseButton1Click:Connect(b.Func)
    end

    drop.MouseButton1Click:Connect(function()
        dropFrame.Visible = not dropFrame.Visible
        drop.Text = name .. (dropFrame.Visible and " ▼" or " ▶") -- toggle arrow
    end)
end

