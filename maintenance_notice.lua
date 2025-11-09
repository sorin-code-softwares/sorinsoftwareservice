-- SorinHub Maintenance Notice Script
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local message = (_G and _G.SorinMaintenanceMessage) or "SorinHub is undergoing a maintenance and is currently not usable."

local function buildOverlay(text)
    local gui = Instance.new("ScreenGui")
    gui.Name = "SorinMaintenanceFallback"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = CoreGui

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(0.45, 0, 0.18, 0)
    holder.Position = UDim2.new(0.5, 0, 0.35, 0)
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    holder.BackgroundTransparency = 0.05
    holder.BorderSizePixel = 0
    holder.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0.35, -10)
    title.Position = UDim2.new(0, 10, 0, 10)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = "SorinHub Maintenance"
    title.Parent = holder

    local body = Instance.new("TextLabel")
    body.Size = UDim2.new(1, -20, 0.65, -10)
    body.Position = UDim2.new(0, 10, 0.35, 0)
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Gotham
    body.TextScaled = true
    body.TextWrapped = true
    body.TextColor3 = Color3.fromRGB(235, 235, 235)
    body.Text = text
    body.Parent = holder

    return gui
end

local overlay
local ok, err = pcall(function()
    overlay = buildOverlay(message)
end)

if not ok then
    warn("[SorinHub] Failed to build maintenance overlay:", err)
end

task.delay(10, function()
    if overlay then overlay:Destroy() end
end)
