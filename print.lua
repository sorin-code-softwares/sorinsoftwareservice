--// Simple "BOO" Popup — 3 Seconds
--// Creates a big centered text that auto-removes

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BooPopup"
ScreenGui.Parent = game:GetService("CoreGui")

local Text = Instance.new("TextLabel")
Text.Parent = ScreenGui
Text.Size = UDim2.new(1, 0, 1, 0)
Text.Position = UDim2.new(0, 0, 0, 0)
Text.BackgroundTransparency = 1
Text.Text = "BUUUH!!!"
Text.TextColor3 = Color3.fromRGB(255, 0, 0)
Text.TextStrokeTransparency = 0.2
Text.TextStrokeColor3 = Color3.new(0, 0, 0)
Text.Font = Enum.Font.GothamBlack
Text.TextScaled = true

-- Fade-in (optional)
Text.TextTransparency = 1
for i = 1, 10 do
    Text.TextTransparency = 1 - (i / 10)
    task.wait(0.03)
end

-- Wait 3 seconds
task.wait(3)

-- Fade-out
for i = 1, 10 do
    Text.TextTransparency = i / 10
    task.wait(0.03)
end

ScreenGui:Destroy()
