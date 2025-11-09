-- SorinHub Blacklist Notice
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local StarterGui = game:GetService("StarterGui")

local info = (_G and _G.SorinBlacklistInfo) or {}
local appealUrl = info.appealUrl or "https://discord.gg/XC5hpQQvMX"
local reasonText = info.reason or "No reason provided."
local timestamp = info.timestamp
local robloxName = info.robloxName or "Unknown user"
local clientId = info.clientId or "?"

local function formatTimestamp(isoString)
    if type(isoString) ~= "string" or #isoString == 0 then
        return "Not recorded"
    end
    local ok, dt = pcall(function()
        return DateTime.fromIsoDateTime(isoString)
    end)
    if not ok then
        return isoString
    end
    local localDt = dt:ToLocalTime()
    local datePart = localDt:FormatUniversalTime("LL", "en-us")
    local timePart = localDt:FormatUniversalTime("LT", "en-us")
    return string.format("%s - %s (your time)", datePart, timePart)
end

local function notify(title, text)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 6
        })
    end)
end

local function setClipboardSafe(value)
    if typeof(setclipboard) == "function" then
        local ok = pcall(setclipboard, value)
        if ok then return true end
    end
    local clipboardLib = rawget(_G, "Clipboard")
    if typeof(clipboardLib) == "table" and typeof(clipboardLib.set) == "function" then
        local ok = pcall(clipboardLib.set, value)
        if ok then return true end
    end
    if typeof((syn or {}).write_clipboard) == "function" then
        local ok = pcall((syn or {}).write_clipboard, value)
        if ok then return true end
    end
    return false
end

local function openUrlInBrowser(url)
    if typeof(url) ~= "string" or #url == 0 then
        return false
    end
    if GuiService and GuiService.OpenBrowserWindow then
        local ok = pcall(function()
            GuiService:OpenBrowserWindow(url)
        end)
        if ok then
            return true
        end
    end
    if typeof((syn or {}).open_url) == "function" then
        local ok = pcall((syn or {}).open_url, url)
        if ok then
            return true
        end
    end
    return false
end

local formattedTimestamp = formatTimestamp(timestamp)

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SorinBlacklistNotice"
screenGui.ResetOnSpawn = false
screenGui.Parent = CoreGui

local container = Instance.new("Frame")
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.Size = UDim2.new(0, 520, 0, 260)
container.Position = UDim2.new(0.5, 0, 0.5, 0)
container.AnchorPoint = Vector2.new(0.5, 0.5)
container.BorderSizePixel = 0
container.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = container

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Color = Color3.fromRGB(255, 85, 85)
stroke.Parent = container

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.fromRGB(255, 85, 85)
title.TextScaled = true
title.Size = UDim2.new(1, -20, 0, 42)
title.Position = UDim2.new(0, 10, 0, 12)
title.Text = "Access revoked for " .. tostring(robloxName)
title.Parent = container

local infoLabel = Instance.new("TextLabel")
infoLabel.BackgroundTransparency = 1
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
infoLabel.TextSize = 18
infoLabel.Size = UDim2.new(1, -20, 0, 90)
infoLabel.Position = UDim2.new(0, 10, 0, 60)
infoLabel.Text = string.format("Reason:\n%s\n\nWhen: %s\nHWID: %s", tostring(reasonText), tostring(formattedTimestamp), tostring(clientId))
infoLabel.Parent = container

local buttonHolder = Instance.new("Frame")
buttonHolder.BackgroundTransparency = 1
buttonHolder.Size = UDim2.new(1, -20, 0, 60)
buttonHolder.Position = UDim2.new(0, 10, 0, 160)
buttonHolder.Parent = container

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Padding = UDim.new(0, 12)
layout.Parent = buttonHolder

local function makeButton(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.5, -10, 1, 0)
    btn.AutoButtonColor = true
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Parent = buttonHolder
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function()
        callback()
    end)
    return btn
end

makeButton("Copy Discord Link", function()
    local copied = setClipboardSafe(appealUrl)
    if copied then
        notify("Copied", "Invite link copied to your clipboard.")
    else
        notify("Clipboard", "Copy failed - please copy manually: " .. appealUrl)
    end
end)

makeButton("Open Discord", function()
    local opened = openUrlInBrowser(appealUrl)
    if opened then
        notify("Discord", "We opened your browser with the invite.")
    else
        notify("Discord", "Browser open blocked - use the copied invite.")
    end
end)

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.TextColor3 = Color3.fromRGB(200, 200, 200)
footer.TextSize = 14
footer.Font = Enum.Font.Gotham
footer.Text = "Need help? Join our Discord and open an appeal ticket."
footer.Size = UDim2.new(1, -20, 0, 24)
footer.Position = UDim2.new(0, 10, 1, -28)
footer.Parent = container

local copiedAuto = setClipboardSafe(appealUrl)
if copiedAuto then
    notify("SorinHub", "Appeal link copied to your clipboard.")
end

task.delay(0.5, function()
    local opened = openUrlInBrowser(appealUrl)
    if not opened then
        warn("[SorinHub] Unable to open browser automatically. Invite link is on your clipboard.")
    end
end)
