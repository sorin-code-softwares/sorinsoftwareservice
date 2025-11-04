-- SorinESP v2.3 (TeamColor ESP + Range + Auto Reload)
-- Author: SorinSoftware Services | scripts.sorinservice.online/sorin/ESP.lua
-- Discord: endofcircuit (sorinuser06) / in your EH Discord Server :)

if getgenv().SorinESP_Active then
    warn("[SorinESP] Already running.")
    return
end
getgenv().SorinESP_Active = true

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local SORIN_UI_URL = "https://raw.githubusercontent.com/sorinservice/script-libary/refs/heads/main/SorinUI.lua"

--// Shared Config
local DEFAULT_CONFIG = {
    Enabled = true,
    ShowDistance = true,
    ShowTool = true,
    MaxDistance = 2500
}

local sharedConfig = getgenv().SorinESP_Config
if type(sharedConfig) ~= "table" then
    sharedConfig = {}
    getgenv().SorinESP_Config = sharedConfig
end

for key, value in pairs(DEFAULT_CONFIG) do
    if sharedConfig[key] == nil then
        sharedConfig[key] = value
    end
end

sharedConfig.Enabled = sharedConfig.Enabled == true
sharedConfig.ShowDistance = sharedConfig.ShowDistance ~= false
sharedConfig.ShowTool = sharedConfig.ShowTool ~= false
sharedConfig.MaxDistance = math.clamp(tonumber(sharedConfig.MaxDistance) or DEFAULT_CONFIG.MaxDistance, 100, 5000)

local Config = sharedConfig

--------------------------------------------------------------------
-- UI Library hookup
--------------------------------------------------------------------
local SorinUILib = getgenv().SorinUILib

if not SorinUILib then
    local hasFile = typeof(isfile) == "function" and typeof(readfile) == "function"
    local fileSource

    local function loadLibraryFromSource(src, origin)
        if type(src) ~= "string" or src == "" then
            return false
        end
        local success, libOrErr = pcall(function()
            return loadstring(src)()
        end)
        if success and type(libOrErr) == "table" then
            SorinUILib = libOrErr
            getgenv().SorinUILib = SorinUILib
            return true
        end
        warn(string.format("[SorinESP] SorinUI konnte nicht geladen werden (%s): %s", origin or "unbekannt", tostring(libOrErr)))
        return false
    end

    if hasFile then
        local okRead, content = pcall(readfile, "SorinUI.lua")
        if okRead and type(content) == "string" then
            fileSource = content
        end
    end

    if not (fileSource and loadLibraryFromSource(fileSource, "Datei")) then
        local function fetchRemote()
            local requestFunc = (syn and syn.request)
                or (http and type(http) == "table" and http.request)
                or http_request
                or request
                or (http and type(http) == "table" and http.Request)
            if requestFunc then
                local okReq, response = pcall(requestFunc, {
                    Url = SORIN_UI_URL,
                    Method = "GET"
                })
                if okReq and type(response) == "table" then
                    local body = response.Body or response.body
                    local status = response.StatusCode or response.Status
                    if (status == nil or status == 200) and type(body) == "string" and body ~= "" then
                        return body
                    end
                end
            end

            local okHttpGet, body = pcall(function()
                return game:HttpGet(SORIN_UI_URL)
            end)
            if okHttpGet and type(body) == "string" and body ~= "" then
                return body
            end

            return nil
        end

        local remoteSource = fetchRemote()
        if remoteSource and loadLibraryFromSource(remoteSource, "Remote") then
            if hasFile and typeof(writefile) == "function" then
                pcall(writefile, "SorinUI.lua", remoteSource)
            end
        end
    end

    if not SorinUILib then
        warn("[SorinESP] SorinUI.lua konnte nicht geladen werden. UI Features deaktiviert.")
    end
end

local UIControls = {}

local function applyEnabled(value, source)
    local newValue = value == true
    Config.Enabled = newValue
    if UIControls.Enabled and source ~= "ui" then
        UIControls.Enabled:Set(newValue, true)
    end
end

local function applyShowDistance(value, source)
    local newValue = value ~= false
    Config.ShowDistance = newValue
    if UIControls.ShowDistance and source ~= "ui" then
        UIControls.ShowDistance:Set(newValue, true)
    end
end

local function applyShowTool(value, source)
    local newValue = value ~= false
    Config.ShowTool = newValue
    if UIControls.ShowTool and source ~= "ui" then
        UIControls.ShowTool:Set(newValue, true)
    end
end

local function applyMaxDistance(value, source)
    local numeric = tonumber(value) or Config.MaxDistance
    numeric = math.clamp(numeric, 100, 5000)
    Config.MaxDistance = numeric
    if UIControls.MaxDistance and source ~= "ui" then
        UIControls.MaxDistance:Set(numeric, true)
    end
end

applyEnabled(Config.Enabled, "init")
applyShowDistance(Config.ShowDistance, "init")
applyShowTool(Config.ShowTool, "init")
applyMaxDistance(Config.MaxDistance, "init")

local SorinESPWindow

if SorinUILib then
    local previousWindow = getgenv().SorinESP_UIWindow
    if previousWindow and type(previousWindow) == "table" then
        pcall(function()
            if previousWindow.Destroy then
                previousWindow:Destroy()
            end
        end)
    end

    local window = SorinUILib.new({
        Name = "SorinESP_UI",
        Title = "Sorin ESP",
        Position = UDim2.new(0.05, 0, 0.15, 0),
        Size = UDim2.new(0, 260, 0, 320)
    })

    SorinESPWindow = window
    getgenv().SorinESP_UIWindow = window

    window:AddLabel("Passe die ESP Optionen live an. F4 toggelt weiterhin schnell.")

    UIControls.Enabled = window:AddToggle({
        Label = "ESP aktiv",
        Default = Config.Enabled,
        Callback = function(value)
            applyEnabled(value, "ui")
        end
    })

    UIControls.ShowDistance = window:AddToggle({
        Label = "Distanz anzeigen",
        Default = Config.ShowDistance,
        Callback = function(value)
            applyShowDistance(value, "ui")
        end
    })

    UIControls.ShowTool = window:AddToggle({
        Label = "Tool anzeigen",
        Default = Config.ShowTool,
        Callback = function(value)
            applyShowTool(value, "ui")
        end
    })

    UIControls.MaxDistance = window:AddSlider({
        Label = "Max Distance",
        Min = 100,
        Max = 5000,
        Step = 50,
        Default = Config.MaxDistance,
        Callback = function(value)
            applyMaxDistance(value, "ui")
        end
    })

    applyEnabled(Config.Enabled, "sync")
    applyShowDistance(Config.ShowDistance, "sync")
    applyShowTool(Config.ShowTool, "sync")
    applyMaxDistance(Config.MaxDistance, "sync")
end

local OUTLINE_COLOR = Color3.fromRGB(255, 255, 255)
local FILL_TRANSPARENCY = 0.75
local OUTLINE_TRANSPARENCY = 0.15

--------------------------------------------------------------------
-- ESP Core
--------------------------------------------------------------------
local ESP_POOL = {}

local function createESP(player)
    if not player.Character then return end
    if ESP_POOL[player] then return end

    local highlight = Instance.new("Highlight")
    highlight.FillTransparency = FILL_TRANSPARENCY
    highlight.OutlineTransparency = OUTLINE_TRANSPARENCY
    highlight.Adornee = player.Character
    highlight.FillColor = player.Team and player.Team.TeamColor.Color or Color3.fromRGB(160, 120, 255)
    highlight.OutlineColor = OUTLINE_COLOR
    highlight.Parent = player.Character

    local tag = Drawing.new("Text")
    tag.Center = true
    tag.Outline = true
    tag.Size = 14
    tag.Visible = false

    ESP_POOL[player] = {Highlight = highlight, Tag = tag}
end

local function destroyESP(player)
    local entry = ESP_POOL[player]
    if not entry then return end
    if entry.Highlight then entry.Highlight:Destroy() end
    if entry.Tag then entry.Tag:Remove() end
    ESP_POOL[player] = nil
end

--------------------------------------------------------------------
-- Utility
--------------------------------------------------------------------
local function getDistance(player)
    local char = player.Character
    local lchar = LocalPlayer.Character
    if not (char and lchar) then return math.huge end
    local hrp, lhrp = char:FindFirstChild("HumanoidRootPart"), lchar:FindFirstChild("HumanoidRootPart")
    if not (hrp and lhrp) then return math.huge end
    return (hrp.Position - lhrp.Position).Magnitude
end

local function getTool(player)
    local char = player.Character
    if not char then return "" end
    local tool = char:FindFirstChildOfClass("Tool")
    return tool and tool.Name or ""
end

local function refreshESP(player)
    -- create if missing or character respawned
    if not player.Character then return end
    if ESP_POOL[player] and ESP_POOL[player].Highlight and ESP_POOL[player].Highlight.Parent == player.Character then
        return
    end
    destroyESP(player)
    createESP(player)
end

--------------------------------------------------------------------
-- Player lifecycle / auto reload
--------------------------------------------------------------------
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.4)
        refreshESP(p)
    end)
    p.CharacterRemoving:Connect(function()
        destroyESP(p)
    end)
end)

Players.PlayerRemoving:Connect(destroyESP)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        refreshESP(p)
    end
end

--------------------------------------------------------------------
-- Render
--------------------------------------------------------------------
RunService.RenderStepped:Connect(function()
    if not Config.Enabled then
        for _, e in pairs(ESP_POOL) do
            e.Highlight.Enabled = false
            e.Tag.Visible = false
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        refreshESP(player)
        local entry = ESP_POOL[player]
        if not entry then continue end

        local char = player.Character
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (head and hum and hum.Health > 0) then
            entry.Tag.Visible = false
            entry.Highlight.Enabled = false
            continue
        end

        local distance = getDistance(player)
        if distance > Config.MaxDistance then
            entry.Highlight.Enabled = false
            entry.Tag.Visible = false
            continue
        end

        local color = player.Team and player.Team.TeamColor and player.Team.TeamColor.Color or Color3.fromRGB(160, 120, 255)
        entry.Highlight.FillColor = color
        entry.Highlight.Enabled = true
        entry.Highlight.Adornee = char

        local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
        if onScreen then
            local textLines = {
                player.DisplayName,
                "@" .. player.Name
            }

            if Config.ShowTool then
                local tool = getTool(player)
                if tool ~= "" then
                    table.insert(textLines, tool)
                end
            end

            if Config.ShowDistance then
                table.insert(textLines, string.format("%.0fm", distance))
            end

            entry.Tag.Text = table.concat(textLines, "\n")
            entry.Tag.Color = color
            entry.Tag.Position = Vector2.new(pos.X, pos.Y)
            entry.Tag.Visible = true
        else
            entry.Tag.Visible = false
        end
    end
end)

--------------------------------------------------------------------
-- F4 toggle
--------------------------------------------------------------------
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F4 then
        applyEnabled(not Config.Enabled, "keybind")
        warn("[SorinESP] Toggled:", Config.Enabled)
    end
end)


print ("SorinESP loaded successfully")
print ("Toggle ESP with 'F4'")

