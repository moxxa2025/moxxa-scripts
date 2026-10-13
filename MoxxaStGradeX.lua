--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║      MoxxaStGradeX v5.1 FINAL - Clean & Fixed Edition        ║
    ║      50+ Features | Working Monitor | Anti-Bug UI            ║
    ║              For Educational Purpose Only                    ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

--============================================================
-- SERVICES
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

local LP = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local Config = {
    ScriptName     = "MoxxaStGradeX",
    Version        = "5.1.0-FINAL",
    TweenSpeed     = 320,
    HoverHeight    = 15,
    AttackInterval = 0.05,
    KillTimeout    = 20,
    ScanRadius     = 3000,
    Notify         = true,
    MonitorRate    = 0.5,
}

--============================================================
-- STATE
--============================================================
local State = {
    AutoFarmLevel     = false,
    AutoFarmMastery   = false,
    AutoFarmBoss      = false,
    AutoFarmChest     = false,
    AutoCompleteQuest = false,
    AutoFish          = false,
    AutoCollect       = false,
    AutoStore         = false,
    AutoRoll          = false,
    AutoRaid          = false,
    AutoHaki          = false,
    AutoKen           = false,
    FastAttack        = false,
    GodMode           = false,
    AntiRagdoll       = false,
    InfiniteEnergy    = false,
    AutoMirage        = false,
    AutoSeaBeast      = false,
    ESPPlayers        = false,
    ESPMobs           = false,
    ESPBosses         = false,
    ESPFruits         = false,
    ESPChests         = false,
    WSApply           = false,
    WalkSpeed         = 400,
    JumpPower         = 50,
    Fly               = false,
    FlySpeed          = 300,
    AutoStatMelee     = false,
    AutoStatDef       = false,
    AutoStatSword     = false,
    AutoStatGun       = false,
    AutoStatFruit     = false,
    FPSUnlocked       = false,
    ShadowOff         = false,
    LowPoly           = false,
    RemoveFX          = false,
    AntiAFK           = true,
    BossName          = "Auto (Any Boss)",
    StartTime         = tick(),
    MonitorConn       = nil,
    MonitorGui        = nil,
}

--============================================================
-- UTILITIES
--============================================================
local Util = {}

function Util.notify(title, text, dur)
    if not Config.Notify then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(title or ""),
            Text = tostring(text or ""),
            Duration = dur or 3,
        })
    end)
end

function Util.getChar()
    local c = LP.Character
    if not c or not c.Parent then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    return c, hrp, hum
end

function Util.getData()
    return LP:FindFirstChild("Data")
end

function Util.getLevel()
    local d = Util.getData()
    if d and d:FindFirstChild("Level") then
        local ok, v = pcall(function() return d.Level.Value end)
        if ok then return v end
    end
    return 1
end

function Util.getCommF()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if not r then return nil end
    return r:FindFirstChild("CommF_")
end

function Util.getCommE()
    local r = ReplicatedStorage:FindFirstChild("Remotes")
    if not r then return nil end
    return r:FindFirstChild("CommE")
end

function Util.safeHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then return res end
    return nil
end

function Util.tweenTo(targetCF, speed)
    local _, hrp = Util.getChar()
    if not hrp then return false end
    speed = speed or Config.TweenSpeed
    local dist = (hrp.Position - targetCF.Position).Magnitude
    local dur = math.max(dist / speed, 0.05)
    local info = TweenInfo.new(dur, Enum.EasingStyle.Linear)
    local t = TweenService:Create(hrp, info, {CFrame = targetCF})
    t:Play()
    return t
end

function Util.attack()
    local c = LP.Character
    if not c then return end
    local tool = c:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    local ce = Util.getCommE()
    if ce then
        pcall(function() ce:FireServer("Attack") end)
        pcall(function() ce:FireServer() end)
    end
end

function Util.fireTouch(p1, p2)
    pcall(function()
        firetouchinterest(p1, p2, 0)
        firetouchinterest(p1, p2, 1)
    end)
end

function Util.inv(rem, ...)
    if not rem then return end
    pcall(function() rem:InvokeServer(...) end)
end

--============================================================
-- SPLASH (text only, NO IMAGE = anti ContentId nil crash)
--============================================================
local function showSplash()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then
        pcall(function() pg = LP:WaitForChild("PlayerGui", 5) end)
    end
    if not pg then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxxaSplash"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.Parent = pg

    local bg = Instance.new("Frame")
    bg.Size = UDim2.fromScale(1, 1)
    bg.BackgroundColor3 = Color3.fromRGB(8, 6, 18)
    bg.BorderSizePixel = 0
    bg.Parent = gui

    local glow = Instance.new("Frame")
    glow.Size = UDim2.fromScale(0.5, 0.5)
    glow.Position = UDim2.fromScale(0.5, 0.5)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.BackgroundColor3 = Color3.fromRGB(120, 60, 220)
    glow.BackgroundTransparency = 0.9
    glow.BorderSizePixel = 0
    glow.Parent = bg
    Instance.new("UICorner", glow).CornerRadius = UDim.new(1, 0)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.fromScale(0.85, 0.1)
    title.Position = UDim2.fromScale(0.5, 0.45)
    title.AnchorPoint = Vector2.new(0.5, 0.5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "MoxxaStGradeX"
    title.TextColor3 = Color3.fromRGB(190, 120, 255)
    title.TextScaled = true
    title.TextTransparency = 1
    title.Parent = bg

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.fromScale(0.7, 0.05)
    sub.Position = UDim2.fromScale(0.5, 0.56)
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "FINAL Edition v" .. Config.Version
    sub.TextColor3 = Color3.fromRGB(160, 160, 190)
    sub.TextScaled = true
    sub.TextTransparency = 1
    sub.Parent = bg

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromScale(0.5, 0.008)
    bar.Position = UDim2.fromScale(0.5, 0.65)
    bar.AnchorPoint = Vector2.new(0.5, 0.5)
    bar.BackgroundColor3 = Color3.fromRGB(40, 30, 60)
    bar.BorderSizePixel = 0
    bar.Parent = bg
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Color3.fromRGB(190, 120, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    TweenService:Create(title, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    TweenService:Create(sub, TweenInfo.new(0.8), {TextTransparency = 0}):Play()
    TweenService:Create(fill, TweenInfo.new(2.5, Enum.EasingStyle.Quad), {Size = UDim2.fromScale(1, 1)}):Play()

    task.delay(3, function()
        TweenService:Create(title, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(sub, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
        TweenService:Create(bg, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
        task.wait(0.6)
        pcall(function() gui:Destroy() end)
    end)
end

--============================================================
-- MONITOR (FIXED - beneran update nilai)
--============================================================
local Monitor = {}

function Monitor.start()
    if State.MonitorConn then return end
    if State.MonitorGui and State.MonitorGui.Parent then return end

    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxxaMonitor"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = pg
    State.MonitorGui = gui

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 250, 0, 200)
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
    title.Text = "▸ Moxxa Monitor v" .. Config.Version
    title.TextColor3 = Color3.fromRGB(190, 130, 255)
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = main

    local function row(y, txt, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(0.55, 0, 0, 20)
        l.Position = UDim2.new(0, 14, 0, y)
        l.BackgroundTransparency = 1
        l.Font = Enum.Font.Gotham
        l.Text = txt
        l.TextColor3 = Color3.fromRGB(180, 180, 195)
        l.TextSize = 13
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = main

        local v = Instance.new("TextLabel")
        v.Size = UDim2.new(0.4, 0, 0, 20)
        v.Position = UDim2.new(0.58, 0, 0, y)
        v.BackgroundTransparency = 1
        v.Font = Enum.Font.GothamBold
        v.Text = "0"
        v.TextColor3 = color
        v.TextSize = 13
        v.TextXAlignment = Enum.TextXAlignment.Right
        v.Parent = main
        return v
    end

    local lblFPS   = row(38,  "FPS",           Color3.fromRGB(120, 255, 180))
    local lblPing  = row(60,  "Ping",          Color3.fromRGB(255, 220, 120))
    local lblMem   = row(82,  "Memory (MB)",   Color3.fromRGB(140, 200, 255))
    local lblCPU   = row(104, "CPU (%)",       Color3.fromRGB(255, 150, 150))
    local lblPl    = row(126, "Players",       Color3.fromRGB(190, 150, 255))
    local lblUpt   = row(148, "Uptime",        Color3.fromRGB(180, 180, 200))
    local lblLvl   = row(170, "Level",         Color3.fromRGB(255, 200, 100))

    -- Drag
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
            local d = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- UPDATE LOOP (guaranteed running)
    State.MonitorConn = task.spawn(function()
        while gui.Parent do
            local ok, err = pcall(function()
                -- FPS
                local ft = Stats.FrameTime()
                local fps = (ft and ft > 0) and math.floor(1 / ft) or 60
                lblFPS.Text = tostring(fps)

                -- Ping
                local pingOk, ping = pcall(function()
                    return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                lblPing.Text = pingOk and string.format("%.0f ms", ping) or "N/A"

                -- Memory
                local memOk, mem = pcall(function() return Stats:GetTotalMemoryUsageMb() end)
                lblMem.Text = memOk and string.format("%.1f", mem) or "N/A"

                -- CPU (est)
                local cpu = math.clamp((ft or 0.016) * 1000, 0, 100)
                lblCPU.Text = string.format("%.1f", cpu)

                -- Players
                lblPl.Text = tostring(#Players:GetPlayers())

                -- Uptime
                local up = tick() - State.StartTime
                lblUpt.Text = string.format("%02d:%02d", math.floor(up/60), math.floor(up%60))

                -- Level
                lblLvl.Text = tostring(Util.getLevel())
            end)
            if not ok then
                warn("[Moxxa Monitor] Error:", err)
            end
            task.wait(Config.MonitorRate)
        end
    end)
end

function Monitor.stop()
    if State.MonitorConn then
        pcall(function() task.cancel(State.MonitorConn) end)
        State.MonitorConn = nil
    end
    if State.MonitorGui then
        pcall(function() State.MonitorGui:Destroy() end)
        State.MonitorGui = nil
    end
end

--============================================================
-- ESP
--============================================================
local ESP = {}

function ESP.clear()
    for _, gui in ipairs(Workspace:GetDescendants()) do
        if (gui:IsA("Highlight") or gui:IsA("BillboardGui"))
        and gui:GetAttribute("MoxxaESP") then
            pcall(function() gui:Destroy() end)
        end
    end
end

local function applyESP(target, color)
    if not target or not target.Parent then return end
    if target:FindFirstChild("MoxxaHL") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "MoxxaHL"
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = target
    hl:SetAttribute("MoxxaESP", true)
    hl.Parent = target
end

function ESP.refresh()
    ESP.clear()

    if State.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character then
                applyESP(p.Character, Color3.fromRGB(60, 180, 255))
            end
        end
    end

    if State.ESPMobs or State.ESPBosses then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart")
            and v:FindFirstChildOfClass("Humanoid")
            and not Players:GetPlayerFromCharacter(v) then
                local n = v.Name:lower()
                local isBoss = v:GetAttribute("Boss")
                    or n:find("boss") or n:find("king") or n:find("lord")
                    or n:find("expert") or n:find("queen")
                if State.ESPBosses and isBoss then
                    applyESP(v, Color3.fromRGB(255, 220, 0))
                elseif State.ESPMobs and not isBoss then
                    applyESP(v, Color3.fromRGB(255, 80, 80))
                end
            end
        end
    end

    if State.ESPFruits then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                applyESP(v.Handle, Color3.fromRGB(255, 100, 220))
            end
        end
    end

    if State.ESPChests then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("chest") then
                local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    applyESP(v, Color3.fromRGB(120, 255, 120))
                end
            end
        end
    end
end

--============================================================
-- FINDERS
--============================================================
local function isEnemy(model)
    if not model or not model.Parent then return false end
    if Players:GetPlayerFromCharacter(model) then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return false end
    if hum.Health <= 0 then return false end
    return true, hum, hrp
end

local function findNearestEnemy(hrp, filter)
    local nearest, dist = nil, math.huge
    for _, v in ipairs(Workspace:GetDescendants()) do
        local ok, hum, vhrp = isEnemy(v)
        if ok then
            local match = true
            if filter and filter ~= "" then
                match = v.Name:lower():find(filter:lower()) ~= nil
            end
            if match then
                local d = (vhrp.Position - hrp.Position).Magnitude
                if d < dist and d < Config.ScanRadius then
                    dist = d
                    nearest = v
                end
            end
        end
    end
    return nearest
end

local function findNearestBoss(hrp, bossName)
    local nearest, dist = nil, math.huge
    for _, v in ipairs(Workspace:GetDescendants()) do
        local ok, hum, vhrp = isEnemy(v)
        if ok then
            local n = v.Name:lower()
            local isBoss = v:GetAttribute("Boss")
                or n:find("boss") or n:find("king") or n:find("lord")
                or n:find("expert") or n:find("queen")
            if isBoss then
                local match = true
                if bossName and bossName ~= "Auto (Any Boss)" then
                    match = n:find(bossName:lower()) ~= nil
                end
                if match then
                    local d = (vhrp.Position - hrp.Position).Magnitude
                    if d < dist and d < Config.ScanRadius then
                        dist = d
                        nearest = v
                    end
                end
            end
        end
    end
    return nearest
end

--============================================================
-- KILL LOOP
--============================================================
local function killEnemy(enemy)
    if not enemy or not enemy.Parent then return false end
    local hum = enemy:FindFirstChildOfClass("Humanoid")
    local ehrp = enemy:FindFirstChild("HumanoidRootPart")
    if not hum or not ehrp then return false end

    local startT = tick()
    while true do
        if not enemy.Parent or not ehrp.Parent then return true end
        if hum.Health <= 0 then return true end
        if tick() - startT > Config.KillTimeout then return false end
        if not (State.AutoFarmLevel or State.AutoFarmMastery or State.AutoFarmBoss or State.AutoSeaBeast) then
            return false
        end

        local _, myHrp = Util.getChar()
        if not myHrp then return false end

        local dist = (ehrp.Position - myHrp.Position).Magnitude
        if dist > 25 then
            Util.tweenTo(ehrp.CFrame * CFrame.new(0, Config.HoverHeight, 0))
            task.wait(0.1)
        else
            pcall(function()
                myHrp.CFrame = ehrp.CFrame * CFrame.new(0, Config.HoverHeight, 0)
            end)
        end

        Util.attack()
        Util.attack()
        Util.attack()
        task.wait(Config.AttackInterval)
    end
end

--============================================================
-- MODULES
--============================================================
local M = {}

function M.AutoFarmLevel()
    while State.AutoFarmLevel do
        local _, hrp = Util.getChar()
        if hrp then
            local enemy = findNearestEnemy(hrp, nil)
            if enemy then killEnemy(enemy) else task.wait(1) end
        else task.wait(1) end
        task.wait(0.2)
    end
end

function M.AutoFarmMastery()
    while State.AutoFarmMastery do
        local _, hrp = Util.getChar()
        if hrp then
            local enemy = findNearestEnemy(hrp, nil)
            if enemy then killEnemy(enemy) end
        end
        task.wait(0.3)
    end
end

function M.AutoFarmBoss()
    while State.AutoFarmBoss do
        local _, hrp = Util.getChar()
        if hrp then
            local boss = findNearestBoss(hrp, State.BossName)
            if boss then killEnemy(boss) else task.wait(2) end
        else task.wait(1) end
    end
end

function M.AutoFarmChest()
    while State.AutoFarmChest do
        task.wait(1)
        local _, hrp = Util.getChar()
        if hrp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if not State.AutoFarmChest then break end
                if v:IsA("Model") and v.Name:lower():find("chest") then
                    local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                    if part then
                        Util.tweenTo(part.CFrame * CFrame.new(0, 3, 0))
                        task.wait(0.5)
                        Util.fireTouch(part, hrp)
                    end
                end
            end
        end
    end
end

function M.AutoCompleteQuest()
    while State.AutoCompleteQuest do
        task.wait(3)
        Util.inv(Util.getCommF(), "CompleteQuest")
    end
end

function M.AutoCollectFruit()
    while State.AutoCollect do
        task.wait(0.8)
        local _, hrp = Util.getChar()
        if hrp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if not State.AutoCollect then break end
                if v:IsA("Tool") and v:FindFirstChild("Handle") and v.Parent then
                    Util.tweenTo(CFrame.new(v.Handle.Position + Vector3.new(0,3,0)))
                    task.wait(0.5)
                    Util.fireTouch(v.Handle, hrp)
                end
            end
        end
    end
end

function M.AutoStore()
    while State.AutoStore do
        task.wait(5)
        local c = Util.getCommF()
        if c then
            for _, r in ipairs({"Common","Uncommon","Rare","Legendary","Mythical"}) do
                Util.inv(c, "StoreFruit", r)
            end
        end
    end
end

function M.AutoRoll()
    local cd = 0
    while State.AutoRoll do
        task.wait(1)
        if tick() >= cd then
            Util.inv(Util.getCommF(), "Cousin", "Buy")
            cd = tick() + 3
        end
    end
end

function M.AutoRaid()
    local cd = 0
    while State.AutoRaid do
        task.wait(2)
        if tick() >= cd then
            local c = Util.getCommF()
            Util.inv(c, "BlackBeardReward", "Microchip", "2")
            task.wait(0.5)
            Util.inv(c, "Raid", "Start")
            cd = tick() + 10
        end
    end
end

function M.AutoHaki()
    while State.AutoHaki do
        task.wait(1)
        Util.inv(Util.getCommF(), "Buso")
    end
end

function M.AutoKen()
    while State.AutoKen do
        task.wait(0.3)
        local c = LP.Character
        if c and not c:FindFirstChild("Ken") then
            Util.inv(Util.getCommF(), "Ken")
        end
    end
end

function M.GodMode()
    while State.GodMode do
        task.wait(0.2)
        local _, _, hum = Util.getChar()
        if hum then
            pcall(function()
                hum.MaxHealth = math.huge
                hum.Health = math.huge
            end)
        end
    end
end

function M.AntiRagdoll()
    while State.AntiRagdoll do
        task.wait(0.5)
        local c, h = Util.getChar()
        if c and h then
            pcall(function()
                local hum = c:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                h.Anchored = false
            end)
        end
    end
end

function M.InfiniteEnergy()
    while State.InfiniteEnergy do
        task.wait(0.5)
        local d = Util.getData()
        if d then
            pcall(function()
                if d:FindFirstChild("Energy") then
                    d.Energy.Value = d.Energy.MaxValue or 100
                end
            end)
        end
    end
end

function M.FastAttack()
    while State.FastAttack do
        task.wait(0.2)
        local c = LP.Character
        if c then
            for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("Animation") then pcall(function() v:Destroy() end) end
            end
        end
    end
end

function M.WalkSpeedLoop()
    RunService.RenderStepped:Connect(function()
        if not State.WSApply then return end
        local _, _, hum = Util.getChar()
        if hum then pcall(function() hum.WalkSpeed = State.WalkSpeed end) end
    end)
end

function M.Fly()
    task.spawn(function()
        local _, hrp, hum = Util.getChar()
        if not hrp or not hum then State.Fly = false; return end
        local bg = Instance.new("BodyVelocity")
        bg.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bg.Velocity = Vector3.zero
        bg.Parent = hrp
        local gy = Instance.new("BodyGyro")
        gy.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        gy.P = 10000
        gy.Parent = hrp
        local conn = RunService.RenderStepped:Connect(function()
            if not State.Fly or not hrp.Parent then
                pcall(function() bg:Destroy(); gy:Destroy() end)
                conn:Disconnect()
                return
            end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            bg.Velocity = dir.Magnitude > 0 and (dir.Unit * State.FlySpeed) or Vector3.zero
            gy.CFrame = cam.CFrame
            hum.PlatformStand = true
        end)
    end)
end

function M.AutoMirage()
    while State.AutoMirage do
        task.wait(2)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not State.AutoMirage then break end
            local n = v.Name:lower()
            if (n:find("mirage") or n:find("gear")) and v:IsA("BasePart") then
                Util.tweenTo(v.CFrame * CFrame.new(0, 5, 0))
                Util.notify("Mirage", "Found: " .. v.Name, 2)
                break
            end
        end
    end
end

function M.AutoSeaBeast()
    while State.AutoSeaBeast do
        task.wait(1)
        local _, hrp = Util.getChar()
        if hrp then
            local t = findNearestEnemy(hrp, "seabeast")
                  or findNearestEnemy(hrp, "terrorshark")
                  or findNearestEnemy(hrp, "shark")
            if t then killEnemy(t) end
        end
    end
end

function M.AutoFish()
    while State.AutoFish do
        task.wait(1)
        local c = LP.Character
        if c then
            for _, v in ipairs(c:GetChildren()) do
                if v:IsA("Tool") and v.Name:lower():find("rod") then
                    pcall(function() v:Activate() end)
                end
            end
        end
    end
end

function M.AutoStat(statName)
    while true do
        task.wait(1)
        local active =
            (statName == "Melee" and State.AutoStatMelee) or
            (statName == "Defense" and State.AutoStatDef) or
            (statName == "Sword" and State.AutoStatSword) or
            (statName == "Gun" and State.AutoStatGun) or
            (statName == "Demon Fruit" and State.AutoStatFruit)
        if not active then break end
        Util.inv(Util.getCommF(), "AddPoint", statName, 1)
    end
end

function M.UnlockFPS()
    pcall(function() setfpscap(999) end)
end

function M.ToggleFX(enabled)
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then
            pcall(function() v.Enabled = enabled end)
        end
    end
end

function M.LowPoly(enable)
    if not enable then return end
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

function M.ServerHop()
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
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP)
                end)
                return
            end
        end
    end
    Util.notify("ServerHop", "No suitable server.", 3)
end

--============================================================
-- ISLAND COORDS
--============================================================
local IslandCoords = {
    ["Starter Island"]  = CFrame.new(1000, 10, 1000),
    ["Marine Fort"]     = CFrame.new(-250, 10, 500),
    ["Middle Town"]     = CFrame.new(-600, 10, 300),
    ["Jungle"]          = CFrame.new(-1200, 10, 300),
    ["Desert"]          = CFrame.new(-1350, 30, -100),
    ["Frozen Village"]  = CFrame.new(-100, 10, -1100),
    ["Marine Ford"]     = CFrame.new(4500, 30, -2500),
    ["Skylands"]        = CFrame.new(-5000, 500, -3000),
    ["Prison"]          = CFrame.new(5300, 500, 500),
    ["Kingdom of Rose"] = CFrame.new(-450, 100, 600),
    ["Cafe"]            = CFrame.new(-380, 100, 320),
    ["Green Zone"]      = CFrame.new(-560, 100, 1100),
    ["Cursed Ship"]     = CFrame.new(-1500, 50, 200),
    ["Ice Castle"]      = CFrame.new(-500, 100, -1500),
    ["Forgotten Island"]= CFrame.new(300, 50, -1500),
    ["Mirage Island"]   = CFrame.new(-5000, 50, -5000),
    ["Port Town"]       = CFrame.new(-280, 100, 3000),
    ["Hydra Island"]    = CFrame.new(500, 100, 3000),
    ["Great Tree"]      = CFrame.new(2500, 100, 2000),
    ["Floating Turtle"] = CFrame.new(2000, 500, 100),
    ["Haunted Castle"]  = CFrame.new(-5000, 100, 5000),
    ["Castle on the Sea"]= CFrame.new(-400, 100, -5000),
    ["Kitsune Island"]  = CFrame.new(-1500, 100, 1000),
    ["Mansion"]         = CFrame.new(-9000, 100, 2000),
    ["Tiki Outpost"]    = CFrame.new(-1000, 100, -3000),
    ["Cake Land"]       = CFrame.new(-500, 100, -1500),
    ["Dressrosa"]       = CFrame.new(-150, 30, 4500),
}

function M.Teleport(name)
    if type(name) == "table" then name = name[1] end
    local cf = IslandCoords[name]
    if not cf then
        Util.notify("Travel", "Island not found: " .. tostring(name), 3)
        return
    end
    Util.tweenTo(cf, Config.TweenSpeed)
    Util.notify("Travel", "→ " .. name, 2)
end

--============================================================
-- UI (Rayfield + fallback + timeout)
--============================================================
local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/shlexsoftworks/Rayfield/main/source.lua",
        "https://raw.githubusercontent.com/Footagesus/Rayfield/main/source.lua",
    }
    for _, u in ipairs(urls) do
        local src = Util.safeHttpGet(u)
        if src and #src > 1000 then
            local fn = loadstring(src)
            if fn then
                local ok, res = pcall(fn)
                if ok and res then return res end
            end
        end
        task.wait(0.3)
    end
    return nil
end

local function loadUI()
    Util.notify("MoxxaStGradeX", "Loading UI...", 3)
    local Rayfield = loadRayfield()
    if not Rayfield then
        Util.notify("❌ GAGAL", "Rayfield tidak bisa load. Cek koneksi.", 6)
        return false
    end

    local Window = Rayfield:CreateWindow({
        Name = "MoxxaStGradeX v" .. Config.Version,
        LoadingTitle = "MoxxaStGradeX",
        LoadingSubtitle = "FINAL Edition",
        Theme = "DarkBlue",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    local function tab(n) return Window:CreateTab(n, 4483362458) end

    -- FARM
    local FarmTab = tab("Farm")
    FarmTab:CreateSection("Auto Farm")
    FarmTab:CreateToggle({ Name = "Auto Farm Level", CurrentValue = false, Flag = "AFarm",
        Callback = function(v) State.AutoFarmLevel = v; if v then task.spawn(M.AutoFarmLevel) end end })
    FarmTab:CreateToggle({ Name = "Auto Farm Mastery", CurrentValue = false, Flag = "AMastery",
        Callback = function(v) State.AutoFarmMastery = v; if v then task.spawn(M.AutoFarmMastery) end end })
    FarmTab:CreateToggle({ Name = "Auto Complete Quest", CurrentValue = false, Flag = "AComplete",
        Callback = function(v) State.AutoCompleteQuest = v; if v then task.spawn(M.AutoCompleteQuest) end end })
    FarmTab:CreateToggle({ Name = "Auto Farm Chest", CurrentValue = false, Flag = "AChest",
        Callback = function(v) State.AutoFarmChest = v; if v then task.spawn(M.AutoFarmChest) end end })
    FarmTab:CreateSection("Auto Boss")
    FarmTab:CreateDropdown({
        Name = "Boss Target",
        Options = {
            "Auto (Any Boss)", "Saber Expert", "Greybeard", "The Gorilla King",
            "Bobby", "Yeti", "King Snowman", "Don Swan", "Order", "Cursed Captain",
            "Cake Queen", "Diamond", "Jeremy", "Fajita", "Khao", "Stone",
            "Hydra Leader", "Island Empress", "Tyrant", "Kitsune", "Dough King",
        },
        CurrentOption = {"Auto (Any Boss)"}, Flag = "BossTarget",
        Callback = function(opt) State.BossName = type(opt) == "table" and opt[1] or opt end,
    })
    FarmTab:CreateToggle({ Name = "Auto Farm Boss", CurrentValue = false, Flag = "ABoss",
        Callback = function(v) State.AutoFarmBoss = v; if v then task.spawn(M.AutoFarmBoss) end end })

    -- COMBAT
    local CombatTab = tab("Combat")
    CombatTab:CreateSection("Attack")
    CombatTab:CreateToggle({ Name = "Fast Attack", CurrentValue = false, Flag = "FastAtk",
        Callback = function(v) State.FastAttack = v; if v then task.spawn(M.FastAttack) end end })
    CombatTab:CreateToggle({ Name = "Auto Haki (Buso)", CurrentValue = false, Flag = "AHaki",
        Callback = function(v) State.AutoHaki = v; if v then task.spawn(M.AutoHaki) end end })
    CombatTab:CreateToggle({ Name = "Auto Ken (Observation)", CurrentValue = false, Flag = "AKen",
        Callback = function(v) State.AutoKen = v; if v then task.spawn(M.AutoKen) end end })
    CombatTab:CreateToggle({ Name = "God Mode (Infinite HP)", CurrentValue = false, Flag = "GMode",
        Callback = function(v) State.GodMode = v; if v then task.spawn(M.GodMode) end end })
    CombatTab:CreateToggle({ Name = "Anti-Ragdoll", CurrentValue = false, Flag = "AntiRag",
        Callback = function(v) State.AntiRagdoll = v; if v then task.spawn(M.AntiRagdoll) end end })
    CombatTab:CreateToggle({ Name = "Infinite Energy", CurrentValue = false, Flag = "InfE",
        Callback = function(v) State.InfiniteEnergy = v; if v then task.spawn(M.InfiniteEnergy) end end })
    CombatTab:CreateSection("Raid")
    CombatTab:CreateToggle({ Name = "Auto Raid", CurrentValue = false, Flag = "ARaid",
        Callback = function(v) State.AutoRaid = v; if v then task.spawn(M.AutoRaid) end end })
    CombatTab:CreateButton({ Name = "Buy Microchip",
        Callback = function() Util.inv(Util.getCommF(), "BlackBeardReward", "Microchip", "2") end })

    -- ESP
    local EspTab = tab("ESP")
    EspTab:CreateSection("Wallhack")
    EspTab:CreateToggle({ Name = "ESP Players", Flag = "ESPPl", CurrentValue = false,
        Callback = function(v) State.ESPPlayers = v; ESP.refresh() end })
    EspTab:CreateToggle({ Name = "ESP Mobs", Flag = "ESPMb", CurrentValue = false,
        Callback = function(v) State.ESPMobs = v; ESP.refresh() end })
    EspTab:CreateToggle({ Name = "ESP Bosses", Flag = "ESPBoss", CurrentValue = false,
        Callback = function(v) State.ESPBosses = v; ESP.refresh() end })
    EspTab:CreateToggle({ Name = "ESP Fruits", Flag = "ESPFr", CurrentValue = false,
        Callback = function(v) State.ESPFruits = v; ESP.refresh() end })
    EspTab:CreateToggle({ Name = "ESP Chests", Flag = "ESPChest", CurrentValue = false,
        Callback = function(v) State.ESPChests = v; ESP.refresh() end })
    EspTab:CreateButton({ Name = "Refresh ESP", Callback = function() ESP.refresh() end })
    EspTab:CreateButton({ Name = "Clear ESP", Callback = function() ESP.clear() end })

    -- TRAVEL
    local TravelTab = tab("Travel")
    TravelTab:CreateSection("First Sea")
    TravelTab:CreateDropdown({
        Name = "First Sea", Options = {
            "Starter Island","Marine Fort","Middle Town","Jungle","Desert",
            "Frozen Village","Marine Ford","Skylands","Prison"
        }, Flag = "TP1", Callback = function(o) M.Teleport(o) end,
    })
    TravelTab:CreateSection("Second Sea")
    TravelTab:CreateDropdown({
        Name = "Second Sea", Options = {
            "Kingdom of Rose","Cafe","Green Zone","Cursed Ship",
            "Ice Castle","Forgotten Island","Mirage Island"
        }, Flag = "TP2", Callback = function(o) M.Teleport(o) end,
    })
    TravelTab:CreateSection("Third Sea")
    TravelTab:CreateDropdown({
        Name = "Third Sea", Options = {
            "Port Town","Hydra Island","Great Tree","Floating Turtle",
            "Haunted Castle","Castle on the Sea","Kitsune Island",
            "Mansion","Tiki Outpost","Cake Land"
        }, Flag = "TP3", Callback = function(o) M.Teleport(o) end,
    })
    TravelTab:CreateButton({ Name = "Dressrosa", Callback = function() M.Teleport("Dressrosa") end })

    -- FRUIT
    local FruitTab = tab("Fruit")
    FruitTab:CreateToggle({ Name = "Auto Collect Fruit", Flag = "ACollect", CurrentValue = false,
        Callback = function(v) State.AutoCollect = v; if v then task.spawn(M.AutoCollectFruit) end end })
    FruitTab:CreateToggle({ Name = "Auto Store Fruit", Flag = "AStore", CurrentValue = false,
        Callback = function(v) State.AutoStore = v; if v then task.spawn(M.AutoStore) end end })
    FruitTab:CreateToggle({ Name = "Auto Roll (Cousin)", Flag = "ARoll", CurrentValue = false,
        Callback = function(v) State.AutoRoll = v; if v then task.spawn(M.AutoRoll) end end })

    -- SEA
    local SeaTab = tab("Sea Events")
    SeaTab:CreateToggle({ Name = "Auto Mirage Island", Flag = "AMirage", CurrentValue = false,
        Callback = function(v) State.AutoMirage = v; if v then task.spawn(M.AutoMirage) end end })
    SeaTab:CreateToggle({ Name = "Auto Sea Beast / Terror", Flag = "ASea", CurrentValue = false,
        Callback = function(v) State.AutoSeaBeast = v; if v then task.spawn(M.AutoSeaBeast) end end })
    SeaTab:CreateToggle({ Name = "Auto Fish", Flag = "AFish", CurrentValue = false,
        Callback = function(v) State.AutoFish = v; if v then task.spawn(M.AutoFish) end end })

    -- STATS
    local StatTab = tab("Stats")
    StatTab:CreateSection("Auto Stat")
    StatTab:CreateToggle({ Name = "Auto Melee", Flag = "ASM", CurrentValue = false,
        Callback = function(v) State.AutoStatMelee = v; if v then task.spawn(M.AutoStat, "Melee") end end })
    StatTab:CreateToggle({ Name = "Auto Defense", Flag = "ASD", CurrentValue = false,
        Callback = function(v) State.AutoStatDef = v; if v then task.spawn(M.AutoStat, "Defense") end end })
    StatTab:CreateToggle({ Name = "Auto Sword", Flag = "ASS", CurrentValue = false,
        Callback = function(v) State.AutoStatSword = v; if v then task.spawn(M.AutoStat, "Sword") end end })
    StatTab:CreateToggle({ Name = "Auto Gun", Flag = "ASG", CurrentValue = false,
        Callback = function(v) State.AutoStatGun = v; if v then task.spawn(M.AutoStat, "Gun") end end })
    StatTab:CreateToggle({ Name = "Auto Blox Fruit", Flag = "ASF", CurrentValue = false,
        Callback = function(v) State.AutoStatFruit = v; if v then task.spawn(M.AutoStat, "Demon Fruit") end end })

    -- MOVEMENT
    local MoveTab = tab("Movement")
    MoveTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 1000}, Increment = 1, Suffix = " spd",
        CurrentValue = 400, Flag = "WS", Callback = function(v) State.WalkSpeed = v end })
    MoveTab:CreateToggle({ Name = "Apply WalkSpeed", Flag = "WSApply", CurrentValue = false,
        Callback = function(v) State.WSApply = v end })
    MoveTab:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 1, Suffix = " jp",
        CurrentValue = 50, Flag = "JP", Callback = function(v)
            State.JumpPower = v
            local _, _, hum = Util.getChar()
            if hum then hum.UseJumpPower = true; hum.JumpPower = v end
        end })
    MoveTab:CreateToggle({ Name = "Fly (WASD + Space/Ctrl)", Flag = "Fly", CurrentValue = false,
        Callback = function(v) State.Fly = v; if v then M.Fly() end end })
    MoveTab:CreateSlider({ Name = "Fly Speed", Range = {50, 1000}, Increment = 10, Suffix = " spd",
        CurrentValue = 300, Flag = "FlySpd", Callback = function(v) State.FlySpeed = v end })

    -- GRAPHICS
    local VisTab = tab("Graphics")
    VisTab:CreateToggle({ Name = "FPS Unlocker", Flag = "FPSU", CurrentValue = false,
        Callback = function(v) State.FPSUnlocked = v; if v then M.UnlockFPS() end end })
    VisTab:CreateToggle({ Name = "Remove Particles", Flag = "NoFX", CurrentValue = false,
        Callback = function(v) State.RemoveFX = v; M.ToggleFX(not v) end })
    VisTab:CreateToggle({ Name = "Disable Shadows", Flag = "NoShadow", CurrentValue = false,
        Callback = function(v)
            State.ShadowOff = v
            pcall(function() Lighting.GlobalShadows = not v end)
        end })
    VisTab:CreateToggle({ Name = "Low Poly Mode", Flag = "LowPoly", CurrentValue = false,
        Callback = function(v) State.LowPoly = v; M.LowPoly(v) end })
    VisTab:CreateSlider({ Name = "Render Distance", Range = {50, 2000}, Increment = 10, Suffix = " studs",
        CurrentValue = 500, Flag = "RenderDist",
        Callback = function(v)
            pcall(function()
                LP.CameraMaxZoomDistance = v
                LP.CameraMinZoomDistance = math.min(10, v)
            end)
        end })

    -- MONITOR
    local MonTab = tab("Monitor")
    MonTab:CreateSection("Live Performance")
    MonTab:CreateLabel("FPS, Ping, CPU, Memory di kiri-atas.")
    MonTab:CreateToggle({ Name = "Show Monitor", Flag = "ShowMon", CurrentValue = true,
        Callback = function(v) if v then Monitor.start() else Monitor.stop() end end })
    MonTab:CreateSlider({ Name = "Refresh Rate", Range = {0.1, 2}, Increment = 0.1, Suffix = "s",
        CurrentValue = 0.5, Flag = "MonRate", Callback = function(v) Config.MonitorRate = v end })
    MonTab:CreateButton({ Name = "Restart Monitor",
        Callback = function() Monitor.stop(); task.wait(0.3); Monitor.start() end })

    -- MISC
    local MiscTab = tab("Misc")
    MiscTab:CreateToggle({ Name = "Anti-AFK", Flag = "AAFK", CurrentValue = true,
        Callback = function(v) State.AntiAFK = v end })
    MiscTab:CreateButton({ Name = "Server Hop", Callback = function() M.ServerHop() end })
    MiscTab:CreateButton({ Name = "Rejoin Server",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
            end)
        end })
    MiscTab:CreateLabel("MoxxaStGradeX v" .. Config.Version)

    return true
end

--============================================================
-- ESP AUTO REFRESH
--============================================================
task.spawn(function()
    while true do
        task.wait(3)
        if State.ESPPlayers or State.ESPMobs or State.ESPBosses
        or State.ESPFruits or State.ESPChests then
            pcall(ESP.refresh)
        end
    end
end)

--============================================================
-- ANTI-AFK
--============================================================
LP.Idled:Connect(function()
    if not State.AntiAFK then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--============================================================
-- BOOT
--============================================================
task.spawn(function()
    showSplash()
    task.wait(3.5)
    Util.notify(Config.ScriptName, "Loaded v" .. Config.Version, 4)
    local ok = pcall(loadUI)
    if ok then
        task.wait(0.5)
        pcall(Monitor.start)
    end
end)