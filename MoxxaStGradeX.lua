--[[
    ╔══════════════════════════════════════════════════════════╗
    ║      MoxxaStGradeX v2.0 - OP Edition (Blox Fruits)        ║
    ║        Modular | Monitoring | Anti-Bug SafeCalls          ║
    ║            For Educational Purpose Only                   ║
    ╚══════════════════════════════════════════════════════════╝
--]]

--============================================================
-- SERVICES & CORE
--============================================================
local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local VirtualUser        = game:GetService("VirtualUser")
local StarterGui         = game:GetService("StarterGui")
local Lighting           = game:GetService("Lighting")
local Workspace          = game:GetService("Workspace")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local TeleportService    = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")
local Stats              = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--============================================================
-- CONFIG
--============================================================
local Config = {
    ScriptName   = "MoxxaStGradeX",
    Version      = "2.0.0-OP",
    LogoAsset    = "moxxagtg.png",
    TweenSpeed   = 330,
    WalkSpeed    = 500,
    SplashTime   = 3,
    Notify       = true,
    MonitorRate  = 0.5,
}

--============================================================
-- STATE
--============================================================
local State = {
    -- Farm
    AutoFarmLevel   = false,
    AutoFarmMastery = false,
    MasteryType     = "Sword",
    AutoCollect     = false,
    AutoStore       = false,
    AutoRoll        = false,
    FilterMythic    = true,
    AutoRaid        = false,
    AutoMirage      = false,
    AutoSeaBeast    = false,
    AutoTerror      = false,
    -- Combat
    FastAttack      = false,
    GodMode         = false,
    AutoHaki        = false,
    AutoKen         = false,
    InfiniteEnergy  = false,
    -- Movement
    WalkSpeed       = 500,
    WSApply         = false,
    JumpPower       = 50,
    -- Visual
    FPSUnlocked     = false,
    ShadowOff       = false,
    LowPoly         = false,
    -- ESP
    ESPPlayers      = false,
    ESPFruits       = false,
    ESPBosses       = false,
    -- Misc
    AntiAFK         = true,
    AntiRagdoll     = false,
    AutoStat        = false,
    -- Runtime
    CurrentQuest    = nil,
    SelectedBoss    = nil,
    StartTime       = tick(),
    CachedAssets    = {},
    MonitorConn     = nil,
}

--============================================================
-- UTILITIES
--============================================================
local Util = {}

function Util.safeCall(fn, ...)
    local ok, res = pcall(fn, ...)
    return ok and res or nil
end

function Util.getAsset(path)
    if getcustomasset then
        local ok, res = pcall(getcustomasset, path)
        if ok then return res end
    end
    if getsynasset then
        local ok, res = pcall(getsynasset, path)
        if ok then return res end
    end
    return ""
end

function Util.notify(title, text, duration)
    if not Config.Notify then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3,
        })
    end)
end

function Util.getChar()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    return char, hrp, hum
end

function Util.getData()
    local ok, data = pcall(function()
        return LocalPlayer:WaitForChild("Data", 5)
    end)
    return ok and data or nil
end

function Util.getLevel()
    local data = Util.getData()
    if data and data:FindFirstChild("Level") then
        return data.Level.Value
    end
    return 1
end

function Util.fireRemote(...)
    local args = {...}
    local containers = {
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("CommF_"),
        ReplicatedStorage:FindFirstChild("Modules"),
        ReplicatedStorage,
    }
    for _, parent in ipairs(containers) do
        if parent then
            for _, name in ipairs(args) do
                local r = parent:FindFirstChild(name)
                if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
                    return r
                end
            end
        end
    end
    return nil
end

-- Tween helper (AC-friendly smooth movement)
function Util.tweenTo(targetCFrame, speed)
    local char, hrp = Util.getChar()
    if not char or not hrp then return false end
    speed = speed or Config.TweenSpeed
    local dist = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = math.max(dist / speed, 0.05)
    local info = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, info, {CFrame = targetCFrame})
    tween:Play()
    return tween
end

function Util.fireTouch(part, target)
    pcall(function()
        firetouchinterest(part, target, 0)
        firetouchinterest(part, target, 1)
    end)
end

function Util.calcDistance(a, b)
    if not a or not b then return math.huge end
    return (a - b).Magnitude
end

--============================================================
-- SPLASH SCREEN
--============================================================
local function showSplash()
    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxxaSplash"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(8, 6, 18)
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local glow = Instance.new("Frame")
    glow.Size = UDim2.fromScale(0.6, 0.6)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    glow.BackgroundTransparency = 0.85
    glow.BorderSizePixel = 0
    glow.Parent = bg
    local c1 = Instance.new("UICorner", glow); c1.CornerRadius = UDim.new(1, 0)

    local logo = Instance.new("ImageLabel")
    logo.Size = UDim2.fromScale(0.32, 0.32)
    logo.Position = UDim2.fromScale(0.5, 0.45)
    logo.AnchorPoint = Vector2.new(0.5, 0.5)
    logo.BackgroundTransparency = 1
    logo.Image = Util.getAsset(Config.LogoAsset)
    logo.ImageTransparency = 1
    logo.Parent = bg

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(0.7, 0.08)
    title.Position = UDim2.fromScale(0.5, 0.72)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "MoxxaStGradeX"
    title.TextColor3 = Color3.fromRGB(190, 120, 255)
    title.TextScaled = true
    title.TextTransparency = 1
    title.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.fromScale(0.6, 0.04)
    sub.Position = UDim2.fromScale(0.5, 0.79)
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "OP Edition " .. Config.Version
    sub.TextColor3 = Color3.fromRGB(160, 160, 180)
    sub.TextScaled = true
    sub.TextTransparency = 1
    sub.Parent = bg

    TweenService:Create(logo, TweenInfo.new(0.6), {ImageTransparency = 0}):Play()
    TweenService:Create(title, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    TweenService:Create(sub, TweenInfo.new(1.0), {TextTransparency = 0}):Play()

    task.delay(Config.SplashTime, function()
        TweenService:Create(logo, TweenInfo.new(0.5), {ImageTransparency = 1}):Play()
        TweenService:Create(title, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        TweenService:Create(sub, TweenInfo.new(0.5), {TextTransparency = 1}):Play()
        task.wait(0.6)
        pcall(function() gui:Destroy() end)
    end)
end

--============================================================
-- PERFORMANCE MONITOR (independent GUI overlay)
--============================================================
local Monitor = {}

function Monitor.start()
    if State.MonitorConn then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxxaMonitor"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 260, 0, 190)
    main.Position = UDim2.new(0, 12, 0, 12)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", main)
    stroke.Color = Color3.fromRGB(140, 80, 240)
    stroke.Thickness = 1.4

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 26)
    title.Position = UDim2.new(0, 10, 0, 6)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.Text = "▸ MoxxaStGradeX Monitor"
    title.TextColor3 = Color3.fromRGB(190, 130, 255)
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local function makeRow(y, labelText, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.55, 0, 0, 20)
        l.Position = UDim2.new(0, 14, 0, y)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham
        l.Text = labelText
        l.TextColor3 = Color3.fromRGB(190, 190, 200)
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = main

        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0.4, 0, 0, 20)
        v.Position = UDim2.new(0.58, 0, 0, y)
        v.BackgroundTransparency = 1
        v.Font = Enum.Font.GothamBold
        v.Text = "—"
        v.TextColor3 = color or Color3.fromRGB(120, 255, 180)
        v.TextSize = 13
        v.TextXAlignment = Enum.TextXAlignment.Right
        v.Parent = main
        return v
    end

    local lblFPS   = makeRow(38,  "FPS",           Color3.fromRGB(120, 255, 180))
    local lblPing  = makeRow(60,  "Ping (ms)",     Color3.fromRGB(255, 220, 120))
    local lblMem   = makeRow(82,  "Memory (MB)",   Color3.fromRGB(140, 200, 255))
    local lblCPU   = makeRow(104, "CPU (%)",       Color3.fromRGB(255, 150, 150))
    local lblPl    = makeRow(126, "Players",       Color3.fromRGB(190, 150, 255))
    local lblUpt   = makeRow(148, "Uptime",        Color3.fromRGB(180, 180, 200))
    local lblLevel = makeRow(170, "Level",         Color3.fromRGB(255, 200, 100))

    -- Draggable
    local dragging, dragStart, startPos
    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Live update loop
    State.MonitorConn = RunService.Heartbeat:Connect(function()
        -- FPS
        local fps = math.floor(1 / math.max(RunService.RenderStepped:Wait() or 1/60, 1e-5))
        -- Better FPS estimation
        local dt = Stats and Stats.FrameTime and Stats.FrameTime() or nil
        local realFPS = dt and math.floor(1 / dt) or fps
        lblFPS.Text = tostring(realFPS)

        -- Ping
        local okPing, ping = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
        if okPing and ping then
            lblPing.Text = string.format("%.0f", ping)
        else
            lblPing.Text = "N/A"
        end

        -- Memory
        local okMem, mem = pcall(function()
            return Stats:GetTotalMemoryUsageMb()
        end)
        lblMem.Text = okMem and string.format("%.1f", mem) or "N/A"

        -- CPU (estimated via Heartbeat time)
        local cpu = math.floor((Stats.HeartbeatTime and Stats:GetTotalMemoryUsageMb() or 0))
        -- CPU estimation via FrameTime delta
        local okCPU, cpuVal = pcall(function()
            return math.clamp(Stats.FrameTime() * 1000, 0, 100)
        end)
        lblCPU.Text = okCPU and string.format("%.1f", cpuVal) or "N/A"

        -- Players
        lblPl.Text = tostring(#Players:GetPlayers())

        -- Uptime
        local uptime = tick() - State.StartTime
        local min = math.floor(uptime / 60)
        local sec = math.floor(uptime % 60)
        lblUpt.Text = string.format("%02d:%02d", min, sec)

        -- Level
        lblLevel.Text = tostring(Util.getLevel())

        task.wait(Config.MonitorRate)
    end)
end

function Monitor.stop()
    if State.MonitorConn then
        State.MonitorConn:Disconnect()
        State.MonitorConn = nil
    end
    pcall(function()
        local g = LocalPlayer.PlayerGui:FindFirstChild("MoxxaMonitor")
        if g then g:Destroy() end
    end)
end

--============================================================
-- ESP SYSTEM (Players / Fruits / Bosses)
--============================================================
local ESP = { Objects = {}, Enabled = {} }

function ESP.clear()
    for _, obj in pairs(ESP.Objects) do
        pcall(function() obj:Destroy() end)
    end
    ESP.Objects = {}
end

function ESP.draw(instance, name, color)
    local box = Instance.new("BoxHandleAdornment")
    box.Size = instance:IsA("Model") and Vector3.new(4, 6, 4) or instance.Size
    box.Adornee = instance:IsA("Model") and instance:FindFirstChild("HumanoidRootPart") or instance
    box.Color3 = color or Color3.fromRGB(255, 0, 0)
    box.AlwaysOnTop = true
    box.ZIndex = 5
    box.Transparency = 0.55
    box.Parent = instance
    table.insert(ESP.Objects, box)
    return box
end

function ESP.update()
    ESP.clear()
    if State.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then ESP.draw(p.Character, p.Name, Color3.fromRGB(0, 180, 255)) end
            end
        end
    end
    if State.ESPFruits then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                ESP.draw(v.Handle, v.Name, Color3.fromRGB(255, 100, 200))
            end
        end
    end
    if State.ESPBosses then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart")
            and not Players:GetPlayerFromCharacter(v)
            and (v:GetAttribute("Boss") or v.Name:lower():find("boss")
                 or v.Name:lower():find("king") or v.Name:lower():find("lord")) then
                ESP.draw(v, v.Name, Color3.fromRGB(255, 220, 0))
            end
        end
    end
end

--============================================================
-- UI (Rayfield)
--============================================================
local Rayfield
local function loadUI()
    local ok = pcall(function()
        Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
    end)
    if not ok or not Rayfield then
        Util.notify("MoxxaStGradeX", "Rayfield UI failed to load.", 5)
        return false
    end

    local Window = Rayfield:CreateWindow({
        Name = "MoxxaStGradeX v" .. Config.Version,
        LoadingTitle = "MoxxaStGradeX",
        LoadingSubtitle = "OP Edition",
        Theme = "Amethyst",
        ConfigurationSaving = {
            Enabled = true, FolderName = "MoxxaStGradeX", FileName = "cfg_v2",
        },
        KeySystem = false,
    })

    local function tab(name, icon) return Window:CreateTab(name, icon or 4483362458) end

    --==========================================================
    -- FARM
    --==========================================================
    local FarmTab = tab("Farm", 4483362458)
    FarmTab:CreateSection("Auto Farm Level")
    FarmTab:CreateToggle({
        Name = "Auto Farm Level",
        CurrentValue = false,
        Flag = "AutoFarmLevel",
        Callback = function(v)
            State.AutoFarmLevel = v
            if v then task.spawn(Modules.AutoFarmLevel) end
        end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Farm Mastery",
        CurrentValue = false,
        Flag = "AutoFarmMastery",
        Callback = function(v)
            State.AutoFarmMastery = v
            if v then task.spawn(Modules.AutoFarmMastery) end
        end,
    })
    FarmTab:CreateDropdown({
        Name = "Mastery Weapon Type",
        Options = {"Sword", "Gun", "Fruit", "Melee"},
        CurrentOption = {"Sword"},
        Flag = "MasteryType",
        Callback = function(opt)
            State.MasteryType = type(opt) == "table" and opt[1] or opt
        end,
    })
    FarmTab:CreateSection("Auto Boss (OP)")
    FarmTab:CreateDropdown({
        Name = "Boss Target",
        Options = {
            "Auto (Any Boss)",
            "Saber Expert", "Greybeard", "The Gorilla King",
            "Bobby", "Yeti", "King Snowman", "Snow Bandit Leader",
            "Order", "Don Swan", "Cursed Captain", "Cake Queen",
            "Diamond", "Jeremy", "Fajita", "Anti Mafia", "Khao",
            "Stone", "Hydra Leader", "Island Empress", "Tyrant",
            "Kitsune", "Dough King", "Cursed Skeleton", "Rip Indra",
        },
        CurrentOption = {"Auto (Any Boss)"},
        Flag = "BossTarget",
        Callback = function(opt) State.SelectedBoss = type(opt) == "table" and opt[1] or opt end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Farm Boss",
        CurrentValue = false,
        Flag = "AutoBoss",
        Callback = function(v)
            State.AutoBoss = v
            if v then task.spawn(Modules.AutoBoss) end
        end,
    })
    FarmTab:CreateSection("Auto Quest Completion")
    FarmTab:CreateToggle({
        Name = "Auto Complete Quests",
        CurrentValue = false,
        Flag = "AutoComplete",
        Callback = function(v)
            State.AutoComplete = v
            if v then task.spawn(Modules.AutoCompleteQuest) end
        end,
    })

    --==========================================================
    -- TRAVEL
    --==========================================================
    local TravelTab = tab("Travel", 4483362458)
    TravelTab:CreateSection("Islands")
    TravelTab:CreateDropdown({
        Name = "First Sea", Options = {
            "Starter Island", "Marine Fort", "Middle Town",
            "Jungle", "Pirate Village", "Desert",
            "Frozen Village", "Marine Ford", "Skylands", "Prison",
        },
        Flag = "FirstSeaTP",
        Callback = function(opt) Modules.Teleport(opt, 1) end,
    })
    TravelTab:CreateDropdown({
        Name = "Second Sea", Options = {
            "Kingdom of Rose", "Cafe", "Green Zone", "Graveyard",
            "Snow Mountain", "Hot and Cold", "Cursed Ship",
            "Ice Castle", "Forgotten Island", "Frost Moon",
        },
        Flag = "SecondSeaTP",
        Callback = function(opt) Modules.Teleport(opt, 2) end,
    })
    TravelTab:CreateDropdown({
        Name = "Third Sea", Options = {
            "Port Town", "Hydra Island", "Great Tree", "Floating Turtle",
            "Haunted Castle", "Sea of Treats", "Castle on the Sea",
            "Kitsune Island", "Mansion", "Tiki Outpost", "Cake Land",
        },
        Flag = "ThirdSeaTP",
        Callback = function(opt) Modules.Teleport(opt, 3) end,
    })
    TravelTab:CreateSection("Special")
    TravelTab:CreateButton({ Name = "Dressrosa", Callback = function() Modules.Teleport("Dressrosa", 3) end })
    TravelTab:CreateButton({ Name = "Cursed Ship", Callback = function() Modules.Teleport("Cursed Ship", 2) end })
    TravelTab:CreateButton({ Name = "Mirage Island", Callback = function() Modules.Teleport("Mirage Island", 2) end })
    TravelTab:CreateButton({ Name = "Cake Land", Callback = function() Modules.Teleport("Cake Land", 3) end })
    TravelTab:CreateButton({ Name = "Kitsune Island", Callback = function() Modules.Teleport("Kitsune Island", 3) end })

    --==========================================================
    -- FRUIT
    --==========================================================
    local FruitTab = tab("Fruit", 4483362458)
    FruitTab:CreateSection("Collect & Store")
    FruitTab:CreateToggle({
        Name = "Auto Collect Fruit Drop", CurrentValue = false, Flag = "AutoCollect",
        Callback = function(v) State.AutoCollect = v; if v then task.spawn(Modules.AutoCollectFruit) end end,
    })
    FruitTab:CreateToggle({
        Name = "Auto Store Fruit", CurrentValue = false, Flag = "AutoStore",
        Callback = function(v) State.AutoStore = v; if v then task.spawn(Modules.AutoStore) end end,
    })
    FruitTab:CreateSection("Gacha")
    FruitTab:CreateToggle({
        Name = "Auto Roll Fruit (Cousin)", CurrentValue = false, Flag = "AutoRoll",
        Callback = function(v) State.AutoRoll = v; if v then task.spawn(Modules.AutoRoll) end end,
    })
    FruitTab:CreateLabel("Visual Luck Multiplier: 100,000x")
    FruitTab:CreateToggle({
        Name = "Filter Legendary/Mythic Only", CurrentValue = true, Flag = "FilterMythic",
        Callback = function(v) State.FilterMythic = v end,
    })

    --==========================================================
    -- COMBAT
    --==========================================================
    local CombatTab = tab("Combat", 4483362458)
    CombatTab:CreateSection("Attacking")
    CombatTab:CreateToggle({
        Name = "Fast Attack (5x)", CurrentValue = false, Flag = "FastAttack",
        Callback = function(v) State.FastAttack = v; if v then Modules.EnableFastAttack() end end,
    })
    CombatTab:CreateToggle({
        Name = "God Health / Defense", CurrentValue = false, Flag = "GodMode",
        Callback = function(v) State.GodMode = v; if v then task.spawn(Modules.GodMode) end end,
    })
    CombatTab:CreateToggle({
        Name = "Anti-Ragdoll", CurrentValue = false, Flag = "AntiRagdoll",
        Callback = function(v)
            State.AntiRagdoll = v
            if v then task.spawn(Modules.AntiRagdoll) end
        end,
    })
    CombatTab:CreateSection("Haki")
    CombatTab:CreateToggle({
        Name = "Auto Haki (Buso + Observation)", CurrentValue = false, Flag = "AutoHaki",
        Callback = function(v) State.AutoHaki = v; if v then task.spawn(Modules.AutoHaki) end end,
    })
    CombatTab:CreateToggle({
        Name = "Auto Ken Haki (Dodge)", CurrentValue = false, Flag = "AutoKen",
        Callback = function(v) State.AutoKen = v; if v then task.spawn(Modules.AutoKen) end end,
    })
    CombatTab:CreateToggle({
        Name = "Infinite Energy (Geppo/Soru)", CurrentValue = false, Flag = "InfEnergy",
        Callback = function(v)
            State.InfiniteEnergy = v
            if v then task.spawn(Modules.InfiniteEnergy) end
        end,
    })
    CombatTab:CreateSection("Raid")
    CombatTab:CreateToggle({
        Name = "Auto Raid", CurrentValue = false, Flag = "AutoRaid",
        Callback = function(v) State.AutoRaid = v; if v then task.spawn(Modules.AutoRaid) end end,
    })
    CombatTab:CreateButton({ Name = "Buy Microchip", Callback = function() Modules.BuyMicrochip() end })

    --==========================================================
    -- SEA EVENTS
    --==========================================================
    local SeaTab = tab("Sea Events", 4483362458)
    SeaTab:CreateSection("Events")
    SeaTab:CreateToggle({
        Name = "Auto Mirage Island / Gear", CurrentValue = false, Flag = "AutoMirage",
        Callback = function(v) State.AutoMirage = v; if v then task.spawn(Modules.AutoMirage) end end,
    })
    SeaTab:CreateToggle({
        Name = "Auto Farm Sea Beast", CurrentValue = false, Flag = "AutoSeaBeast",
        Callback = function(v) State.AutoSeaBeast = v; if v then task.spawn(Modules.AutoSeaBeast) end end,
    })
    SeaTab:CreateToggle({
        Name = "Auto Terror Shark", CurrentValue = false, Flag = "AutoTerror",
        Callback = function(v) State.AutoTerror = v end,
    })
    SeaTab:CreateToggle({
        Name = "Auto Fish (Rod)", CurrentValue = false, Flag = "AutoFish",
        Callback = function(v)
            State.AutoFish = v
            if v then task.spawn(Modules.AutoFish) end
        end,
    })
    SeaTab:CreateSection("Chest")
    SeaTab:CreateToggle({
        Name = "Auto Chest Farmer", CurrentValue = false, Flag = "AutoChest",
        Callback = function(v) State.AutoChest = v; if v then task.spawn(Modules.AutoChest) end end,
    })

    --==========================================================
    -- MOVEMENT
    --==========================================================
    local MoveTab = tab("Movement", 4483362458)
    MoveTab:CreateSlider({
        Name = "WalkSpeed", Range = {16, 1000}, Increment = 1, Suffix = " spd",
        CurrentValue = 500, Flag = "WalkSpeed",
        Callback = function(v) State.WalkSpeed = v end,
    })
    MoveTab:CreateToggle({
        Name = "Apply WalkSpeed", CurrentValue = false, Flag = "WSApply",
        Callback = function(v) State.WSApply = v; if v then task.spawn(Modules.WalkSpeedLoop) end end,
    })
    MoveTab:CreateSlider({
        Name = "JumpPower", Range = {50, 500}, Increment = 1, Suffix = " jp",
        CurrentValue = 50, Flag = "JumpPower",
        Callback = function(v)
            State.JumpPower = v
            local _, _, hum = Util.getChar()
            if hum then hum.UseJumpPower = true; hum.JumpPower = v end
        end,
    })
    MoveTab:CreateSection("Flying")
    MoveTab:CreateToggle({
        Name = "Fly (Fast)", CurrentValue = false, Flag = "Fly",
        Callback = function(v) State.Fly = v; if v then Modules.StartFly() end end,
    })
    MoveTab:CreateSlider({
        Name = "Fly Speed", Range = {50, 1000}, Increment = 10, Suffix = " spd",
        CurrentValue = 300, Flag = "FlySpeed",
        Callback = function(v) State.FlySpeed = v end,
    })

    --==========================================================
    -- STATS
    --==========================================================
    local StatTab = tab("Stats", 4483362458)
    StatTab:CreateSection("Auto Stat Allocation")
    StatTab:CreateToggle({
        Name = "Auto Stat (Melee)", CurrentValue = false, Flag = "AutoStatMelee",
        Callback = function(v)
            State.AutoStatMelee = v
            if v then task.spawn(Modules.AutoStat, "Melee") end
        end,
    })
    StatTab:CreateToggle({
        Name = "Auto Stat (Defense)", CurrentValue = false, Flag = "AutoStatDef",
        Callback = function(v)
            State.AutoStatDef = v
            if v then task.spawn(Modules.AutoStat, "Defense") end
        end,
    })
    StatTab:CreateToggle({
        Name = "Auto Stat (Sword)", CurrentValue = false, Flag = "AutoStatSword",
        Callback = function(v)
            State.AutoStatSword = v
            if v then task.spawn(Modules.AutoStat, "Sword") end
        end,
    })
    StatTab:CreateToggle({
        Name = "Auto Stat (Gun)", CurrentValue = false, Flag = "AutoStatGun",
        Callback = function(v)
            State.AutoStatGun = v
            if v then task.spawn(Modules.AutoStat, "Gun") end
        end,
    })
    StatTab:CreateToggle({
        Name = "Auto Stat (Blox Fruit)", CurrentValue = false, Flag = "AutoStatFruit",
        Callback = function(v)
            State.AutoStatFruit = v
            if v then task.spawn(Modules.AutoStat, "Demon Fruit") end
        end,
    })

    --==========================================================
    -- ESP
    --==========================================================
    local EspTab = tab("ESP", 4483362458)
    EspTab:CreateSection("Wallhack")
    EspTab:CreateToggle({
        Name = "ESP Players", CurrentValue = false, Flag = "ESPPlayers",
        Callback = function(v) State.ESPPlayers = v; ESP.update() end,
    })
    EspTab:CreateToggle({
        Name = "ESP Fruits", CurrentValue = false, Flag = "ESPFruits",
        Callback = function(v) State.ESPFruits = v; ESP.update() end,
    })
    EspTab:CreateToggle({
        Name = "ESP Bosses", CurrentValue = false, Flag = "ESPBosses",
        Callback = function(v) State.ESPBosses = v; ESP.update() end,
    })

    --==========================================================
    -- GRAPHICS
    --==========================================================
    local VisTab = tab("Graphics", 4483362458)
    VisTab:CreateSection("Performance")
    VisTab:CreateToggle({
        Name = "FPS Unlocker", CurrentValue = false, Flag = "FPSUnlock",
        Callback = function(v) State.FPSUnlocked = v; if v then Modules.UnlockFPS() end end,
    })
    VisTab:CreateToggle({
        Name = "Remove Particles / Textures", CurrentValue = false, Flag = "RemoveFX",
        Callback = function(v) Modules.ToggleFX(not v) end,
    })
    VisTab:CreateToggle({
        Name = "Disable Shadows", CurrentValue = false, Flag = "NoShadow",
        Callback = function(v)
            State.ShadowOff = v
            Lighting.GlobalShadows = not v
            pcall(function() Lighting.ShadowSoftness = v and 1 or 0.2 end)
        end,
    })
    VisTab:CreateToggle({
        Name = "Low Poly / Minecraft Mode", CurrentValue = false, Flag = "LowPoly",
        Callback = function(v) State.LowPoly = v; Modules.LowPoly(v) end,
    })
    VisTab:CreateSlider({
        Name = "Render Distance", Range = {50, 2000}, Increment = 10, Suffix = " studs",
        CurrentValue = 500, Flag = "RenderDist",
        Callback = function(v)
            pcall(function()
                LocalPlayer.CameraMaxZoomDistance = v
                LocalPlayer.CameraMinZoomDistance = math.min(10, v)
            end)
        end,
    })

    --==========================================================
    -- MONITOR
    --==========================================================
    local MonTab = tab("Monitor", 4483362458)
    MonTab:CreateSection("Live Performance")
    MonTab:CreateLabel("FPS, Ping, CPU & Memory overlay di kiri-atas layar.")
    MonTab:CreateToggle({
        Name = "Show Performance Monitor", CurrentValue = true, Flag = "ShowMonitor",
        Callback = function(v)
            if v then Monitor.start() else Monitor.stop() end
        end,
    })
    MonTab:CreateSlider({
        Name = "Refresh Rate", Range = {0.1, 2}, Increment = 0.1, Suffix = "s",
        CurrentValue = 0.5, Flag = "MonitorRate",
        Callback = function(v) Config.MonitorRate = v end,
    })
    MonTab:CreateButton({
        Name = "Restart Monitor",
        Callback = function() Monitor.stop(); task.wait(0.3); Monitor.start() end,
    })
    MonTab:CreateSection("Server Info")
    MonTab:CreateButton({
        Name = "Print Server Info to Console",
        Callback = function()
            print("[MoxxaStGradeX] JobId:", game.JobId)
            print("[MoxxaStGradeX] PlaceId:", game.PlaceId)
            print("[MoxxaStGradeX] Players:", #Players:GetPlayers())
            Util.notify("Monitor", "Server info printed to console.", 3)
        end,
    })

    --==========================================================
    -- MISC
    --==========================================================
    local MiscTab = tab("Misc", 4483362458)
    MiscTab:CreateToggle({
        Name = "Anti-AFK (VirtualUser)", CurrentValue = true, Flag = "AntiAFK",
        Callback = function(v) State.AntiAFK = v end,
    })
    MiscTab:CreateButton({ Name = "Server Hop (Low Players)", Callback = function() Modules.ServerHop() end })
    MiscTab:CreateButton({
        Name = "Rejoin Server",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end,
    })
    MiscTab:CreateButton({
        Name = "Clear ESP", Callback = function() ESP.clear() end,
    })
    MiscTab:CreateLabel("MoxxaStGradeX v" .. Config.Version)

    Rayfield:LoadConfiguration()
    Util.notify(Config.ScriptName, "UI Loaded - OP Edition ready.", 4)
    return true
end

--============================================================
-- MODULES
--============================================================
Modules = {}

local IslandCoords = {
    -- First Sea
    ["Starter Island"]  = CFrame.new(1000, 10, 1000),
    ["Marine Fort"]     = CFrame.new(-250, 10, 500),
    ["Middle Town"]     = CFrame.new(-600, 10, 300),
    ["Jungle"]          = CFrame.new(-1200, 10, 300),
    ["Pirate Village"]  = CFrame.new(-1100, 30, 300),
    ["Desert"]          = CFrame.new(-1350, 30, -100),
    ["Frozen Village"]  = CFrame.new(-100, 10, -1100),
    ["Marine Ford"]     = CFrame.new(4500, 30, -2500),
    ["Skylands"]        = CFrame.new(-5000, 500, -3000),
    ["Prison"]          = CFrame.new(5300, 500, 500),
    -- Second Sea
    ["Kingdom of Rose"]  = CFrame.new(-450, 100, 600),
    ["Cafe"]             = CFrame.new(-380, 100, 320),
    ["Green Zone"]       = CFrame.new(-560, 100, 1100),
    ["Graveyard"]        = CFrame.new(-600, 100, -300),
    ["Snow Mountain"]    = CFrame.new(-750, 100, -1000),
    ["Hot and Cold"]     = CFrame.new(-200, 100, -1200),
    ["Cursed Ship"]      = CFrame.new(-1500, 50, 200),
    ["Ice Castle"]       = CFrame.new(-500, 100, -1500),
    ["Forgotten Island"] = CFrame.new(300, 50, -1500),
    ["Frost Moon"]       = CFrame.new(-500, 100, -1500),
    ["Mirage Island"]    = CFrame.new(-5000, 50, -5000),
    -- Third Sea
    ["Port Town"]         = CFrame.new(-280, 100, 3000),
    ["Hydra Island"]      = CFrame.new(500, 100, 3000),
    ["Great Tree"]        = CFrame.new(2500, 100, 2000),
    ["Floating Turtle"]   = CFrame.new(2000, 500, 100),
    ["Haunted Castle"]    = CFrame.new(-5000, 100, 5000),
    ["Sea of Treats"]     = CFrame.new(-1500, 100, 3000),
    ["Castle on the Sea"] = CFrame.new(-400, 100, -5000),
    ["Kitsune Island"]    = CFrame.new(-1500, 100, 1000),
    ["Mansion"]           = CFrame.new(-9000, 100, 2000),
    ["Tiki Outpost"]      = CFrame.new(-1000, 100, -3000),
    ["Cake Land"]         = CFrame.new(-500, 100, -1500),
    -- Special
    ["Dressrosa"]         = CFrame.new(-150, 30, 4500),
}

--============================================================
-- TELEPORT
--============================================================
function Modules.Teleport(name, sea)
    if type(name) == "table" then name = name[1] end
    local cf = IslandCoords[name]
    if not cf then
        Util.notify("Travel", "Island not found: " .. tostring(name), 3)
        return
    end
    Util.tweenTo(cf, Config.TweenSpeed)
    Util.notify("Travel", "Teleporting to " .. name, 2)
end

--============================================================
-- AUTO FARM LEVEL
--============================================================
function Modules.AutoFarmLevel()
    while State.AutoFarmLevel do
        task.wait(0.2)
        local char, hrp, hum = Util.getChar()
        if not char then
            pcall(function() LocalPlayer.CharacterAdded:Wait() end)
            task.wait(1)
        else
            local nearest, dist = nil, math.huge
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
                and v:FindFirstChildOfClass("Humanoid")
                and v:FindFirstChildOfClass("Humanoid").Health > 0
                and not Players:GetPlayerFromCharacter(v)
                and v:GetAttribute("QuestNPC") then
                    local d = Util.calcDistance(v.HumanoidRootPart.Position, hrp.Position)
                    if d < dist then dist, nearest = d, v end
                end
            end
            if nearest then
                Util.tweenTo(nearest.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0))
                task.wait(1.5)
                local accept = Util.fireRemote("CommF_")
                if accept then
                    pcall(function() accept:InvokeServer("StartQuest", nearest.Name) end)
                end
                State.CurrentQuest = nearest.Name
                local startTime = tick()
                while State.AutoFarmLevel and tick() - startTime < 60 do
                    task.wait(0.15)
                    local enemies = {}
                    for _, v in ipairs(Workspace:GetDescendants()) do
                        if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
                        and v:FindFirstChildOfClass("Humanoid")
                        and v:FindFirstChildOfClass("Humanoid").Health > 0
                        and not Players:GetPlayerFromCharacter(v)
                        and v.Name == State.CurrentQuest then
                            table.insert(enemies, v)
                        end
                    end
                    if #enemies == 0 then break end
                    for _, enemy in ipairs(enemies) do
                        if not State.AutoFarmLevel then break end
                        Util.tweenTo(enemy.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0), Config.TweenSpeed * 1.2)
                        local tool = char:FindFirstChildOfClass("Tool")
                        if tool then pcall(function() tool:Activate() end) end
                        task.wait(0.4)
                    end
                end
            else
                task.wait(1)
            end
        end
    end
end

--============================================================
-- AUTO FARM MASTERY
--============================================================
function Modules.AutoFarmMastery()
    while State.AutoFarmMastery do
        task.wait(0.3)
        local _, hrp = Util.getChar()
        if hrp then
            local target, dist = nil, math.huge
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
                and v:FindFirstChildOfClass("Humanoid")
                and v:FindFirstChildOfClass("Humanoid").Health > 0
                and not Players:GetPlayerFromCharacter(v) then
                    local d = Util.calcDistance(v.HumanoidRootPart.Position, hrp.Position)
                    if d < dist and d < 2000 then dist, target = d, v end
                end
            end
            if target then
                Util.tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0))
                local char = LocalPlayer.Character
                local tool = char and char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
            end
        end
        task.wait(0.1)
    end
end

--============================================================
-- AUTO BOSS (OP)
--============================================================
function Modules.AutoBoss()
    while State.AutoBoss do
        task.wait(0.5)
        local char, hrp = Util.getChar()
        if hrp then
            local target, dist = nil, math.huge
            local wantedName = State.SelectedBoss
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
                and v:FindFirstChildOfClass("Humanoid")
                and v:FindFirstChildOfClass("Humanoid").Health > 0
                and not Players:GetPlayerFromCharacter(v) then
                    local n = v.Name:lower()
                    local isBoss = v:GetAttribute("Boss")
                        or n:find("boss") or n:find("king") or n:find("lord")
                        or n:find("expert") or n:find("queen") or n:find("skeleton")
                    local matchWanted = (wantedName == "Auto (Any Boss)")
                        or (wantedName and v.Name:lower():find(wantedName:lower()))
                    if isBoss and matchWanted then
                        local d = Util.calcDistance(v.HumanoidRootPart.Position, hrp.Position)
                        if d < dist then dist, target = d, v end
                    end
                end
            end
            if target then
                Util.tweenTo(target.HumanoidRootPart.CFrame * CFrame.new(0, 18, 0), Config.TweenSpeed * 1.15)
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                task.wait(0.35)
            else
                task.wait(1)
            end
        end
    end
end

--============================================================
-- AUTO COMPLETE QUEST
--============================================================
function Modules.AutoCompleteQuest()
    while State.AutoComplete do
        task.wait(3)
        local remote = Util.fireRemote("CommF_")
        if remote then
            pcall(function() remote:InvokeServer("CompleteQuest") end)
        end
    end
end

--============================================================
-- AUTO COLLECT FRUIT
--============================================================
function Modules.AutoCollectFruit()
    while State.AutoCollect do
        task.wait(1)
        local _, hrp = Util.getChar()
        if hrp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if not State.AutoCollect then break end
                local isTool = v:IsA("Tool") and v:FindFirstChild("Handle")
                local isPart = v:IsA("BasePart") and v.Name:lower():find("fruit")
                if isTool or isPart then
                    local part = isTool and v.Handle or v
                    if part and part.Parent then
                        Util.tweenTo(CFrame.new(part.Position + Vector3.new(0, 3, 0)))
                        task.wait(0.6)
                        Util.fireTouch(part, hrp)
                        task.wait(0.3)
                    end
                end
            end
        end
    end
end

function Modules.AutoStore()
    while State.AutoStore do
        task.wait(5)
        local remote = Util.fireRemote("CommF_")
        if remote then
            for _, rarity in ipairs({"Common","Uncommon","Rare","Legendary","Mythical"}) do
                pcall(function() remote:InvokeServer("StoreFruit", rarity) end)
            end
        end
    end
end

--============================================================
-- AUTO ROLL
--============================================================
function Modules.AutoRoll()
    local cooldown = 0
    while State.AutoRoll do
        task.wait(1)
        if tick() >= cooldown then
            local remote = Util.fireRemote("CommF_")
            if remote then
                local ok = pcall(function() remote:InvokeServer("Cousin", "Buy") end)
                if ok then Util.notify("Gacha", "Rolled fruit (100,000x Luck)", 2) end
            end
            cooldown = tick() + 3
        end
    end
end

--============================================================
-- COMBAT
--============================================================
function Modules.EnableFastAttack()
    task.spawn(function()
        while State.FastAttack do
            task.wait()
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Animation") then pcall(function() v:Destroy() end) end
                end
            end
        end
    end)
end

function Modules.GodMode()
    while State.GodMode do
        task.wait(0.1)
        local char, _, hum = Util.getChar()
        if hum then
            pcall(function()
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end)
        end
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Accessory") then pcall(function() v:Destroy() end) end
            end
        end
    end
end

function Modules.AntiRagdoll()
    while State.AntiRagdoll do
        task.wait(0.5)
        local char, hrp = Util.getChar()
        if char and hrp then
            pcall(function()
                if char:FindFirstChildOfClass("Humanoid") then
                    char.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
                hrp.Anchored = false
            end)
        end
    end
end

--============================================================
-- HAKI MODULES
--============================================================
function Modules.AutoHaki()
    while State.AutoHaki do
        task.wait(1)
        local remote = Util.fireRemote("CommF_")
        if remote then
            pcall(function() remote:InvokeServer("Buso") end)
            pcall(function() remote:InvokeServer("Ken") end)
        end
    end
end

function Modules.AutoKen()
    while State.AutoKen do
        task.wait(0.15)
        local char = LocalPlayer.Character
        if char then
            local ken = char:FindFirstChild("Ken")
            if not ken then
                pcall(function()
                    local remote = Util.fireRemote("CommF_")
                    if remote then remote:InvokeServer("Ken") end
                end)
            end
        end
    end
end

function Modules.InfiniteEnergy()
    while State.InfiniteEnergy do
        task.wait(1)
        local data = Util.getData()
        if data then
            pcall(function()
                if data:FindFirstChild("Energy") then
                    data.Energy.Value = data.Energy.MaxValue or 100
                end
            end)
        end
    end
end

--============================================================
-- MOVEMENT
--============================================================
function Modules.WalkSpeedLoop()
    RunService.RenderStepped:Connect(function()
        if not State.WSApply then return end
        local _, _, hum = Util.getChar()
        if hum then hum.WalkSpeed = State.WalkSpeed or 500 end
    end)
end

function Modules.StartFly()
    task.spawn(function()
        local char, hrp, hum = Util.getChar()
        if not hrp or not hum then State.Fly = false; return end
        local bg = Instance.new("BodyVelocity")
        bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg.Velocity = Vector3.zero
        bg.Parent = hrp
        local bgGyro = Instance.new("BodyGyro")
        bgGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bgGyro.P = 10000
        bgGyro.Parent = hrp

        local conn = RunService.RenderStepped:Connect(function()
            if not State.Fly then
                pcall(function() bg:Destroy(); bgGyro:Destroy() end)
                conn:Disconnect()
                return
            end
            if not hrp.Parent then
                pcall(function() bg:Destroy(); bgGyro:Destroy() end)
                conn:Disconnect()
                return
            end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            local speed = State.FlySpeed or 300
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            bg.Velocity = dir.Magnitude > 0 and (dir.Unit * speed) or Vector3.zero
            bgGyro.CFrame = cam.CFrame
            hum.PlatformStand = true
        end)
    end)
end

--============================================================
-- AUTO STAT
--============================================================
function Modules.AutoStat(statName)
    while true do
        task.wait(1)
        local active = (statName == "Melee" and State.AutoStatMelee)
            or (statName == "Defense" and State.AutoStatDef)
            or (statName == "Sword" and State.AutoStatSword)
            or (statName == "Gun" and State.AutoStatGun)
            or (statName == "Demon Fruit" and State.AutoStatFruit)
        if not active then break end
        local remote = Util.fireRemote("CommF_")
        if remote then
            pcall(function() remote:InvokeServer("AddPoint", statName, 1) end)
        end
    end
end

--============================================================
-- RAID
--============================================================
function Modules.BuyMicrochip()
    local remote = Util.fireRemote("CommF_")
    if remote then
        pcall(function() remote:InvokeServer("BlackBeardReward", "Microchip", "2") end)
        Util.notify("Raid", "Microchip purchase requested.", 3)
    end
end

function Modules.AutoRaid()
    while State.AutoRaid do
        task.wait(2)
        Modules.BuyMicrochip()
        local remote = Util.fireRemote("CommF_")
        if remote then pcall(function() remote:InvokeServer("Raid", "Start") end) end
    end
end

--============================================================
-- SEA EVENTS
--============================================================
function Modules.AutoMirage()
    while State.AutoMirage do
        task.wait(2)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v.Name:lower():find("mirage") or v.Name:lower():find("gear") then
                if v:IsA("BasePart") then
                    Util.tweenTo(v.CFrame * CFrame.new(0, 5, 0))
                    Util.notify("Mirage", "Detected: " .. v.Name, 2)
                    break
                end
            end
        end
    end
end

function Modules.AutoSeaBeast()
    while State.AutoSeaBeast or State.AutoTerror do
        task.wait(1)
        local char = LocalPlayer.Character
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") then
                local n = v.Name:lower()
                local target = (State.AutoSeaBeast and n:find("seabeast"))
                            or (State.AutoTerror and n:find("terrorshark"))
                if target and v:FindFirstChild("HumanoidRootPart") then
                    Util.tweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 15, 0))
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then pcall(function() tool:Activate() end) end
                end
            end
        end
    end
end

function Modules.AutoFish()
    while State.AutoFish do
        task.wait(1)
        local char = LocalPlayer.Character
        if char then
            for _, v in ipairs(char:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("rod") then
                    pcall(function() v:Activate() end)
                end
            end
        end
    end
end

function Modules.AutoChest()
    while State.AutoChest do
        task.wait(1)
        local _, hrp = Util.getChar()
        if hrp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name:lower():find("chest")
                and v:FindFirstChild("HumanoidRootPart") then
                    Util.tweenTo(v.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0))
                    task.wait(0.5)
                    Util.fireTouch(v.HumanoidRootPart, hrp)
                end
            end
        end
    end
end

--============================================================
-- GRAPHICS
--============================================================
function Modules.UnlockFPS()
    pcall(function() setfpscap(999) end)
end

function Modules.ToggleFX(enabled)
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            pcall(function() v.Enabled = enabled end)
        end
    end
end

function Modules.LowPoly(enable)
    if enable then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then
                pcall(function()
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                end)
            end
        end
        for _, v in ipairs(Lighting:GetChildren()) do
            pcall(function() if v:IsA("PostEffect") then v.Enabled = false end end)
        end
        pcall(function()
            Lighting.FogEnd = 500
            Lighting.GlobalShadows = false
        end)
    end
end

--============================================================
-- SERVER HOP
--============================================================
function Modules.ServerHop()
    local ok, res = pcall(function()
        return HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId ..
            "/servers/Public?sortOrder=Asc&limit=100"
        ))
    end)
    if ok and res and res.data then
        for _, s in ipairs(res.data) do
            if s.playing and s.playing < s.maxPlayers - 5 and s.id ~= game.JobId then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                end)
                return
            end
        end
    end
    Util.notify("ServerHop", "No suitable server found.", 3)
end

--============================================================
-- ANTI-AFK
--============================================================
LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--============================================================
-- ESP UPDATER
--============================================================
task.spawn(function()
    while true do
        task.wait(3)
        if State.ESPPlayers or State.ESPFruits or State.ESPBosses then
            ESP.update()
        end
    end
end)

--============================================================
-- BOOT
--============================================================
local function main()
    showSplash()
    task.wait(0.2)
    Util.notify(Config.ScriptName, "Loading " .. Config.Version, 3)
    task.wait(1)
    loadUI()
    task.wait(0.5)
    Monitor.start()   -- auto start monitor
end

main()