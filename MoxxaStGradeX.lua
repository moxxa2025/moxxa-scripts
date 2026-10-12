--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║      MoxxaStGradeX v5.0 - TRUE MAXIMAL EDITION               ║
    ║   ALL Features | Working Farm | Working Attack | Working ESP ║
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

local LocalPlayer = Players.LocalPlayer

--============================================================
-- CONFIG
--============================================================
local Config = {
    ScriptName     = "MoxxaStGradeX",
    Version        = "5.0.0-MAX",
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
    -- Farm
    AutoFarmLevel     = false,
    AutoFarmMastery   = false,
    AutoFarmBoss      = false,
    AutoFarmChest     = false,
    AutoCompleteQuest = false,
    AutoFish          = false,
    -- Fruit
    AutoCollect       = false,
    AutoStore         = false,
    AutoRoll          = false,
    -- Combat
    AutoRaid          = false,
    AutoHaki          = false,
    AutoKen           = false,
    FastAttack        = false,
    GodMode           = false,
    AntiRagdoll       = false,
    InfiniteEnergy    = false,
    -- Sea
    AutoMirage        = false,
    AutoSeaBeast      = false,
    AutoTerror        = false,
    -- ESP
    ESPPlayers        = false,
    ESPMobs           = false,
    ESPBosses         = false,
    ESPFruits         = false,
    ESPChests         = false,
    -- Movement
    WSApply           = false,
    WalkSpeed         = 400,
    JumpPower         = 50,
    Fly               = false,
    FlySpeed          = 300,
    -- Stats
    AutoStatMelee     = false,
    AutoStatDef       = false,
    AutoStatSword     = false,
    AutoStatGun       = false,
    AutoStatFruit     = false,
    -- Graphics
    FPSUnlocked       = false,
    ShadowOff         = false,
    LowPoly           = false,
    RemoveFX          = false,
    -- Misc
    AntiAFK           = true,
    -- Runtime
    CurrentTarget     = nil,
    BossName          = "Auto (Any Boss)",
    MasteryType       = "Sword",
    StartTime         = tick(),
    MonitorConn       = nil,
}

--============================================================
-- UTIL (safe)
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
    local c = LocalPlayer.Character
    if not c or not c.Parent then return nil end
    local hrp = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return nil end
    return c, hrp, hum
end

function Util.getData()
    local ok, d = pcall(function() return LocalPlayer:FindFirstChild("Data") end)
    return ok and d or nil
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
    local info = TweenInfo.new(dur, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local t = TweenService:Create(hrp, info, {CFrame = targetCF})
    t:Play()
    return t
end

-- Attack: 3 method
function Util.attack()
    local char = LocalPlayer.Character
    if not char then return end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    local commE = Util.getCommE()
    if commE then
        pcall(function() commE:FireServer("Attack") end)
        pcall(function() commE:FireServer() end)
    end
end

function Util.fireTouch(p1, p2)
    pcall(function()
        firetouchinterest(p1, p2, 0)
        firetouchinterest(p1, p2, 1)
    end)
end

function Util.safeInvoke(remote, ...)
    if not remote then return end
    pcall(function() remote:InvokeServer(...) end)
end

--============================================================
-- SPLASH (safe)
--============================================================
local function showSplash()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then
        pcall(function() pg = LocalPlayer:WaitForChild("PlayerGui", 5) end)
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
    sub.Size = UDim2.fromScale(0.75, 0.05)
    sub.Position = UDim2.fromScale(0.5, 0.56)
    sub.AnchorPoint = Vector2.new(0.5, 0.5)
    sub.BackgroundTransparency = 1
    sub.Font = Enum.Font.Gotham
    sub.Text = "TRUE MAXIMAL v" .. Config.Version
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
    local bc = Instance.new("UICorner", bar)
    bc.CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(0, 1)
    fill.BackgroundColor3 = Color3.fromRGB(190, 120, 255)
    fill.BorderSizePixel = 0
    fill.Parent = bar
    local fc = Instance.new("UICorner", fill)
    fc.CornerRadius = UDim.new(1, 0)

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
-- PERFORMANCE MONITOR (KEMBALI!)
--============================================================
local Monitor = {}

function Monitor.start()
    if State.MonitorConn then return end

    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MoxxaMonitor"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.Parent = pg

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
        v.Text = "—"
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

    State.MonitorConn = RunService.Heartbeat:Connect(function()
        -- FPS
        local ft = Stats.FrameTime()
        local fps = ft > 0 and math.floor(1 / ft) or 60
        lblFPS.Text = tostring(fps)

        -- Ping
        local okP, p = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        lblPing.Text = okP and string.format("%.0f ms", p) or "N/A"

        -- Memory
        local okM, m = pcall(function() return Stats:GetTotalMemoryUsageMb() end)
        lblMem.Text = okM and string.format("%.1f", m) or "N/A"

        -- CPU (est)
        lblCPU.Text = string.format("%.1f", math.clamp(ft * 1000, 0, 100))

        -- Players
        lblPl.Text = tostring(#Players:GetPlayers())

        -- Uptime
        local up = tick() - State.StartTime
        lblUpt.Text = string.format("%02d:%02d", math.floor(up / 60), math.floor(up % 60))

        -- Level
        lblLvl.Text = tostring(Util.getLevel())

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
-- ESP (Highlight based)
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
    if target:FindFirstChild("MoxxaESP_HL") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "MoxxaESP_HL"
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = target
    hl:SetAttribute("MoxxaESP", true)
    hl.Parent = target
end

local function applyTag(target, color, text)
    if not target or not target.Parent then return end
    if target:FindFirstChild("MoxxaESP_NT") then return end
    local bb = Instance.new("BillboardGui")
    bb.Name = "MoxxaESP_NT"
    bb.Size = UDim2.fromOffset(200, 34)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = target
    bb:SetAttribute("MoxxaESP", true)
    bb.Parent = target

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text or target.Name
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextScaled = true
    lbl.Parent = bb
end

function ESP.refresh()
    ESP.clear()

    if State.ESPPlayers then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                applyESP(p.Character, Color3.fromRGB(60, 180, 255))
                applyTag(p.Character, Color3.fromRGB(60, 180, 255), "[P] " .. p.Name)
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
                    or n:find("expert") or n:find("queen") or n:find("dough")
                if State.ESPBosses and isBoss then
                    applyESP(v, Color3.fromRGB(255, 220, 0))
                    applyTag(v, Color3.fromRGB(255, 220, 0), "[BOSS] " .. v.Name)
                elseif State.ESPMobs and not isBoss then
                    applyESP(v, Color3.fromRGB(255, 80, 80))
                    applyTag(v, Color3.fromRGB(255, 80, 80), v.Name)
                end
            end
        end
    end

    if State.ESPFruits then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Tool") and v:FindFirstChild("Handle") then
                applyESP(v.Handle, Color3.fromRGB(255, 100, 220))
                applyTag(v.Handle, Color3.fromRGB(255, 100, 220), "[FRUIT] " .. v.Name)
            end
        end
    end

    if State.ESPChests then
        for _, v in ipairs(Workspace:GetDescendants()) do
            if v:IsA("Model") and v.Name:lower():find("chest") then
                local part = v:FindFirstChild("HumanoidRootPart") or v:FindFirstChildWhichIsA("BasePart")
                if part then
                    applyESP(v, Color3.fromRGB(120, 255, 120))
                    applyTag(v, Color3.fromRGB(120, 255, 120), "[CHEST] " .. v.Name)
                end
            end
        end
    end
end

--============================================================
-- ENEMY FINDERS
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
-- KILL LOOP (kill sampai mati)
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
local Modules = {}

function Modules.AutoFarmLevel()
    Util.notify("Farm", "Auto Farm Level: START", 2)
    while State.AutoFarmLevel do
        local _, hrp = Util.getChar()
        if hrp then
            local enemy = findNearestEnemy(hrp, nil)
            if enemy then
                State.CurrentTarget = enemy.Name
                killEnemy(enemy)
            else
                task.wait(1)
            end
        else
            task.wait(1)
        end
        task.wait(0.2)
    end
    Util.notify("Farm", "Auto Farm Level: STOP", 2)
end

function Modules.AutoFarmMastery()
    Util.notify("Farm", "Auto Mastery: START", 2)
    while State.AutoFarmMastery do
        local _, hrp = Util.getChar()
        if hrp then
            local enemy = findNearestEnemy(hrp, nil)
            if enemy then killEnemy(enemy) end
        end
        task.wait(0.3)
    end
    Util.notify("Farm", "Auto Mastery: STOP", 2)
end

function Modules.AutoFarmBoss()
    Util.notify("Farm", "Auto Boss: START", 2)
    while State.AutoFarmBoss do
        local _, hrp = Util.getChar()
        if hrp then
            local boss = findNearestBoss(hrp, State.BossName)
            if boss then killEnemy(boss) else task.wait(2) end
        else
            task.wait(1)
        end
    end
    Util.notify("Farm", "Auto Boss: STOP", 2)
end

function Modules.AutoFarmChest()
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

function Modules.AutoCompleteQuest()
    while State.AutoCompleteQuest do
        task.wait(3)
        Util.safeInvoke(Util.getCommF(), "CompleteQuest")
    end
end

function Modules.AutoCollectFruit()
    Util.notify("Fruit", "Auto Collect: START", 2)
    while State.AutoCollect do
        task.wait(0.8)
        local _, hrp = Util.getChar()
        if hrp then
            for _, v in ipairs(Workspace:GetDescendants()) do
                if not State.AutoCollect then break end
                if v:IsA("Tool") and v:FindFirstChild("Handle") and v.Parent then
                    local h = v.Handle
                    Util.tweenTo(CFrame.new(h.Position + Vector3.new(0, 3, 0)))
                    task.wait(0.5)
                    Util.fireTouch(h, hrp)
                end
            end
        end
    end
    Util.notify("Fruit", "Auto Collect: STOP", 2)
end

function Modules.AutoStore()
    while State.AutoStore do
        task.wait(5)
        local c = Util.getCommF()
        if c then
            for _, r in ipairs({"Common","Uncommon","Rare","Legendary","Mythical"}) do
                Util.safeInvoke(c, "StoreFruit", r)
            end
        end
    end
end

function Modules.AutoRoll()
    local cd = 0
    while State.AutoRoll do
        task.wait(1)
        if tick() >= cd then
            Util.safeInvoke(Util.getCommF(), "Cousin", "Buy")
            cd = tick() + 3
        end
    end
end

function Modules.AutoRaid()
    local cd = 0
    while State.AutoRaid do
        task.wait(2)
        if tick() >= cd then
            local c = Util.getCommF()
            Util.safeInvoke(c, "BlackBeardReward", "Microchip", "2")
            task.wait(0.5)
            Util.safeInvoke(c, "Raid", "Start")
            cd = tick() + 10
        end
    end
end

function Modules.AutoHaki()
    local cd = 0
    while State.AutoHaki do
        task.wait(1)
        if tick() >= cd then
            Util.safeInvoke(Util.getCommF(), "Buso")
            cd = tick() + 2
        end
    end
end

function Modules.AutoKen()
    while State.AutoKen do
        task.wait(0.2)
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("Ken") then
            Util.safeInvoke(Util.getCommF(), "Ken")
        end
    end
end

function Modules.GodMode()
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

function Modules.AntiRagdoll()
    while State.AntiRagdoll do
        task.wait(0.5)
        local char, hrp = Util.getChar()
        if char and hrp then
            pcall(function()
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:ChangeState(Enum.HumanoidStateType.GettingUp) end
                hrp.Anchored = false
            end)
        end
    end
end

function Modules.InfiniteEnergy()
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

function Modules.EnableFastAttack()
    task.spawn(function()
        while State.FastAttack do
            task.wait(0.2)
            local char = LocalPlayer.Character
            if char then
                for _, v in ipairs(char:GetDescendants()) do
                    if v:IsA("Animation") then pcall(function() v:Destroy() end) end
                end
            end
        end
    end)
end

function Modules.WalkSpeedLoop()
    RunService.RenderStepped:Connect(function()
        if not State.WSApply then return end
        local _, _, hum = Util.getChar()
        if hum then pcall(function() hum.WalkSpeed = State.WalkSpeed end) end
    end)
end

function Modules.StartFly()
    task.spawn(function()
        local _, hrp, hum = Util.getChar()
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
            if not State.Fly or not hrp.Parent then
                pcall(function() bg:Destroy(); bgGyro:Destroy() end)
                conn:Disconnect()
                return
            end
            local cam = Workspace.CurrentCamera
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            bg.Velocity = dir.Magnitude > 0 and (dir.Unit * State.FlySpeed) or Vector3.zero
            bgGyro.CFrame = cam.CFrame
            hum.PlatformStand = true
        end)
    end)
end

function Modules.AutoMirage()
    while State.AutoMirage do
        task.wait(2)
        for _, v in ipairs(Workspace:GetDescendants()) do
            if not State.AutoMirage then break end
            local n = v.Name:lower()
            if (n:find("mirage") or n:find("gear")) and v:IsA("BasePart") then
                Util.tweenTo(v.CFrame * CFrame.new(0, 5, 0))
                Util.notify("Mirage", "Detected: " .. v.Name, 2)
                break
            end
        end
    end
end

function Modules.AutoSeaBeast()
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

function Modules.AutoStat(statName)
    while true do
        task.wait(1)
        local active =
            (statName == "Melee" and State.AutoStatMelee) or
            (statName == "Defense" and State.AutoStatDef) or
            (statName == "Sword" and State.AutoStatSword) or
            (statName == "Gun" and State.AutoStatGun) or
            (statName == "Demon Fruit" and State.AutoStatFruit)
        if not active then break end
        Util.safeInvoke(Util.getCommF(), "AddPoint", statName, 1)
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
-- TELEPORT COORDS
--============================================================
local IslandCoords = {
    -- First Sea
    ["Starter Island"]  = CFrame.new(1000, 10, 1000),
    ["Marine Fort"]     = CFrame.new(-250, 10, 500),
    ["Middle Town"]     = CFrame.new(-600, 10, 300),
    ["Jungle"]          = CFrame.new(-1200, 10, 300),
    ["Desert"]          = CFrame.new(-1350, 30, -100),
    ["Frozen Village"]  = CFrame.new(-100, 10, -1100),
    ["Marine Ford"]     = CFrame.new(4500, 30, -2500),
    ["Skylands"]        = CFrame.new(-5000, 500, -3000),
    ["Prison"]          = CFrame.new(5300, 500, 500),
    -- Second Sea
    ["Kingdom of Rose"] = CFrame.new(-450, 100, 600),
    ["Cafe"]            = CFrame.new(-380, 100, 320),
    ["Green Zone"]      = CFrame.new(-560, 100, 1100),
    ["Cursed Ship"]     = CFrame.new(-1500, 50, 200),
    ["Ice Castle"]      = CFrame.new(-500, 100, -1500),
    ["Forgotten Island"]= CFrame.new(300, 50, -1500),
    ["Mirage Island"]   = CFrame.new(-5000, 50, -5000),
    -- Third Sea
    ["Port Town"]        = CFrame.new(-280, 100, 3000),
    ["Hydra Island"]     = CFrame.new(500, 100, 3000),
    ["Great Tree"]       = CFrame.new(2500, 100, 2000),
    ["Floating Turtle"]  = CFrame.new(2000, 500, 100),
    ["Haunted Castle"]   = CFrame.new(-5000, 100, 5000),
    ["Castle on the Sea"]= CFrame.new(-400, 100, -5000),
    ["Kitsune Island"]   = CFrame.new(-1500, 100, 1000),
    ["Mansion"]          = CFrame.new(-9000, 100, 2000),
    ["Tiki Outpost"]     = CFrame.new(-1000, 100, -3000),
    ["Cake Land"]        = CFrame.new(-500, 100, -1500),
    -- Special
    ["Dressrosa"]        = CFrame.new(-150, 30, 4500),
}

function Modules.Teleport(name)
    if type(name) == "table" then name = name[1] end
    local cf = IslandCoords[name]
    if not cf then
        Util.notify("Travel", "Island tidak ditemukan: " .. tostring(name), 3)
        return
    end
    Util.tweenTo(cf, Config.TweenSpeed)
    Util.notify("Travel", "→ " .. name, 2)
end

--============================================================
-- UI
--============================================================
local function loadRayfield()
    local urls = {
        "https://sirius.menu/rayfield",
        "https://raw.githubusercontent.com/shlexsoftworks/Rayfield/main/source.lua",
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
    local Rayfield = loadRayfield()
    if not Rayfield then
        Util.notify("MoxxaStGradeX", "UI gagal load. Cek koneksi.", 5)
        return
    end

    local Window = Rayfield:CreateWindow({
        Name = "MoxxaStGradeX v" .. Config.Version,
        LoadingTitle = "MoxxaStGradeX",
        LoadingSubtitle = "TRUE MAXIMAL",
        Theme = "DarkBlue",
        ConfigurationSaving = { Enabled = false },
        KeySystem = false,
    })

    local function tab(n) return Window:CreateTab(n, 4483362458) end

    -- FARM
    local FarmTab = tab("Farm")
    FarmTab:CreateSection("Auto Farm")
    FarmTab:CreateToggle({ Name = "Auto Farm Level", CurrentValue = false, Flag = "AFarm",
        Callback = function(v) State.AutoFarmLevel = v; if v then task.spawn(Modules.AutoFarmLevel) end end })
    FarmTab:CreateToggle({ Name = "Auto Farm Mastery", CurrentValue = false, Flag = "AMastery",
        Callback = function(v) State.AutoFarmMastery = v; if v then task.spawn(Modules.AutoFarmMastery) end end })
    FarmTab:CreateToggle({ Name = "Auto Complete Quest", CurrentValue = false, Flag = "AComplete",
        Callback = function(v) State.AutoCompleteQuest = v; if v then task.spawn(Modules.AutoCompleteQuest) end end })
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
        Callback = function(v) State.AutoFarmBoss = v; if v then task.spawn(Modules.AutoFarmBoss) end end })
    FarmTab:CreateSection("Auto Chest")
    FarmTab:CreateToggle({ Name = "Auto Farm Chest", CurrentValue = false, Flag = "AChest",
        Callback = function(v) State.AutoFarmChest = v; if v then task.spawn(Modules.AutoFarmChest) end end })

    -- COMBAT
    local CombatTab = tab("Combat")
    CombatTab:CreateSection("Attack")
    CombatTab:CreateToggle({ Name = "Fast Attack (Hapus Animasi)", CurrentValue = false, Flag = "FastAtk",
        Callback = function(v) State.FastAttack = v; if v then Modules.EnableFastAttack() end end })
    CombatTab:CreateToggle({ Name = "Auto Haki (Buso)", CurrentValue = false, Flag = "AHaki",
        Callback = function(v) State.AutoHaki = v; if v then task.spawn(Modules.AutoHaki) end end })
    CombatTab:CreateToggle({ Name = "Auto Ken (Observation)", CurrentValue = false, Flag = "AKen",
        Callback = function(v) State.AutoKen = v; if v then task.spawn(Modules.AutoKen) end end })
    CombatTab:CreateToggle({ Name = "God Mode (Infinite HP)", CurrentValue = false, Flag = "GMode",
        Callback = function(v) State.GodMode = v; if v then task.spawn(Modules.GodMode) end end })
    CombatTab:CreateToggle({ Name = "Anti-Ragdoll", CurrentValue = false, Flag = "AntiRag",
        Callback = function(v) State.AntiRagdoll = v; if v then task.spawn(Modules.AntiRagdoll) end end })
    CombatTab:CreateToggle({ Name = "Infinite Energy", CurrentValue = false, Flag = "InfE",
        Callback = function(v) State.InfiniteEnergy = v; if v then task.spawn(Modules.InfiniteEnergy) end end })
    CombatTab:CreateSection("Raid")
    CombatTab:CreateToggle({ Name = "Auto Raid (Buy + Start)", CurrentValue = false, Flag = "ARaid",
        Callback = function(v) State.AutoRaid = v; if v then task.spawn(Modules.AutoRaid) end end })
    CombatTab:CreateButton({ Name = "Buy Microchip",
        Callback = function() Util.safeInvoke(Util.getCommF(), "BlackBeardReward", "Microchip", "2") end })

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
    EspTab:CreateButton({ Name = "Refresh ESP Manual", Callback = function() ESP.refresh() end })
    EspTab:CreateButton({ Name = "Clear ESP", Callback = function() ESP.clear() end })

    -- TRAVEL
    local TravelTab = tab("Travel")
    TravelTab:CreateSection("First Sea")
    TravelTab:CreateDropdown({
        Name = "First Sea Islands",
        Options = {"Starter Island","Marine Fort","Middle Town","Jungle","Desert",
                   "Frozen Village","Marine Ford","Skylands","Prison"},
        Flag = "TP1", Callback = function(o) Modules.Teleport(o) end,
    })
    TravelTab:CreateSection("Second Sea")
    TravelTab:CreateDropdown({
        Name = "Second Sea Islands",
        Options = {"Kingdom of Rose","Cafe","Green Zone","Cursed Ship",
                   "Ice Castle","Forgotten Island","Mirage Island"},
        Flag = "TP2", Callback = function(o) Modules.Teleport(o) end,
    })
    TravelTab:CreateSection("Third Sea")
    TravelTab:CreateDropdown({
        Name = "Third Sea Islands",
        Options = {"Port Town","Hydra Island","Great Tree","Floating Turtle",
                   "Haunted Castle","Castle on the Sea","Kitsune Island",
                   "Mansion","Tiki Outpost","Cake Land"},
        Flag = "TP3", Callback = function(o) Modules.Teleport(o) end,
    })
    TravelTab:CreateSection("Special")
    TravelTab:CreateButton({ Name = "Dressrosa", Callback = function() Modules.Teleport("Dressrosa") end })
    TravelTab:CreateButton({ Name = "Mirage Island", Callback = function() Modules.Teleport("Mirage Island") end })

    -- FRUIT
    local FruitTab = tab("Fruit")
    FruitTab:CreateToggle({ Name = "Auto Collect Fruit", Flag = "ACollect", CurrentValue = false,
        Callback = function(v) State.AutoCollect = v; if v then task.spawn(Modules.AutoCollectFruit) end end })
    FruitTab:CreateToggle({ Name = "Auto Store Fruit", Flag = "AStore", CurrentValue = false,
        Callback = function(v) State.AutoStore = v; if v then task.spawn(Modules.AutoStore) end end })
    FruitTab:CreateToggle({ Name = "Auto Roll (Cousin)", Flag = "ARoll", CurrentValue = false,
        Callback = function(v) State.AutoRoll = v; if v then task.spawn(Modules.AutoRoll) end end })

    -- SEA EVENTS
    local SeaTab = tab("Sea Events")
    SeaTab:CreateToggle({ Name = "Auto Mirage Island", Flag = "AMirage", CurrentValue = false,
        Callback = function(v) State.AutoMirage = v; if v then task.spawn(Modules.AutoMirage) end end })
    SeaTab:CreateToggle({ Name = "Auto Sea Beast / Terror Shark", Flag = "ASea", CurrentValue = false,
        Callback = function(v) State.AutoSeaBeast = v; if v then task.spawn(Modules.AutoSeaBeast) end end })
    SeaTab:CreateToggle({ Name = "Auto Fish", Flag = "AFish", CurrentValue = false,
        Callback = function(v) State.AutoFish = v; if v then task.spawn(Modules.AutoFish) end end })

    -- STATS
    local StatTab = tab("Stats")
    StatTab:CreateSection("Auto Stat")
    StatTab:CreateToggle({ Name = "Auto Melee", Flag = "ASMelee", CurrentValue = false,
        Callback = function(v) State.AutoStatMelee = v; if v then task.spawn(Modules.AutoStat, "Melee") end end })
    StatTab:CreateToggle({ Name = "Auto Defense", Flag = "ASDef", CurrentValue = false,
        Callback = function(v) State.AutoStatDef = v; if v then task.spawn(Modules.AutoStat, "Defense") end end })
    StatTab:CreateToggle({ Name = "Auto Sword", Flag = "ASSword", CurrentValue = false,
        Callback = function(v) State.AutoStatSword = v; if v then task.spawn(Modules.AutoStat, "Sword") end end })
    StatTab:CreateToggle({ Name = "Auto Gun", Flag = "ASGun", CurrentValue = false,
        Callback = function(v) State.AutoStatGun = v; if v then task.spawn(Modules.AutoStat, "Gun") end end })
    StatTab:CreateToggle({ Name = "Auto Blox Fruit", Flag = "ASFruit", CurrentValue = false,
        Callback = function(v) State.AutoStatFruit = v; if v then task.spawn(Modules.AutoStat, "Demon Fruit") end end })

    -- MOVEMENT
    local MoveTab = tab("Movement")
    MoveTab:CreateSlider({ Name = "WalkSpeed", Range = {16, 1000}, Increment = 1, Suffix = " spd",
        CurrentValue = 400, Flag = "WS", Callback = function(v) State.WalkSpeed = v end })
    MoveTab:CreateToggle({ Name = "Apply WalkSpeed", Flag = "WSApply", CurrentValue = false,
        Callback = function(v) State.WSApply = v; if v then Modules.WalkSpeedLoop() end end })
    MoveTab:CreateSlider({ Name = "JumpPower", Range = {50, 500}, Increment = 1, Suffix = " jp",
        CurrentValue = 50, Flag = "JP",
        Callback = function(v)
            State.JumpPower = v
            local _, _, hum = Util.getChar()
            if hum then hum.UseJumpPower = true; hum.JumpPower = v end
        end })
    MoveTab:CreateToggle({ Name = "Fly (WASD + Space/Ctrl)", Flag = "Fly", CurrentValue = false,
        Callback = function(v) State.Fly = v; if v then Modules.StartFly() end end })
    MoveTab:CreateSlider({ Name = "Fly Speed", Range = {50, 1000}, Increment = 10, Suffix = " spd",
        CurrentValue = 300, Flag = "FlySpd", Callback = function(v) State.FlySpeed = v end })

    -- GRAPHICS
    local VisTab = tab("Graphics")
    VisTab:CreateSection("Performance")
    VisTab:CreateToggle({ Name = "FPS Unlocker", Flag = "FPSUnlock", CurrentValue = false,
        Callback = function(v) State.FPSUnlocked = v; if v then Modules.UnlockFPS() end end })
    VisTab:CreateToggle({ Name = "Remove Particles / Textures", Flag = "RemoveFX", CurrentValue = false,
        Callback = function(v) State.RemoveFX = v; Modules.ToggleFX(not v) end })
    VisTab:CreateToggle({ Name = "Disable Shadows", Flag = "NoShadow", CurrentValue = false,
        Callback = function(v)
            State.ShadowOff = v
            pcall(function()
                Lighting.GlobalShadows = not v
                Lighting.ShadowSoftness = v and 1 or 0.2
            end)
        end })
    VisTab:CreateToggle({ Name = "Low Poly / Minecraft Mode", Flag = "LowPoly", CurrentValue = false,
        Callback = function(v) State.LowPoly = v; Modules.LowPoly(v) end })
    VisTab:CreateSlider({ Name = "Render Distance", Range = {50, 2000}, Increment = 10, Suffix = " studs",
        CurrentValue = 500, Flag = "RenderDist",
        Callback = function(v)
            pcall(function()
                LocalPlayer.CameraMaxZoomDistance = v
                LocalPlayer.CameraMinZoomDistance = math.min(10, v)
            end)
        end })

    -- MONITOR
    local MonTab = tab("Monitor")
    MonTab:CreateSection("Live Performance")
    MonTab:CreateLabel("FPS, Ping, CPU, Memory overlay di kiri-atas.")
    MonTab:CreateToggle({ Name = "Show Performance Monitor", Flag = "ShowMon", CurrentValue = true,
        Callback = function(v) if v then Monitor.start() else Monitor.stop() end end })
    MonTab:CreateSlider({ Name = "Refresh Rate", Range = {0.1, 2}, Increment = 0.1, Suffix = "s",
        CurrentValue = 0.5, Flag = "MonRate", Callback = function(v) Config.MonitorRate = v end })
    MonTab:CreateButton({ Name = "Restart Monitor",
        Callback = function() Monitor.stop(); task.wait(0.3); Monitor.start() end })
    MonTab:CreateButton({ Name = "Print Server Info",
        Callback = function()
            print("[Moxxa] JobId:", game.JobId)
            print("[Moxxa] PlaceId:", game.PlaceId)
            print("[Moxxa] Players:", #Players:GetPlayers())
        end })

    -- MISC
    local MiscTab = tab("Misc")
    MiscTab:CreateToggle({ Name = "Anti-AFK", Flag = "AntiAFK", CurrentValue = true,
        Callback = function(v) State.AntiAFK = v end })
    MiscTab:CreateButton({ Name = "Server Hop (Low Players)", Callback = function() Modules.ServerHop() end })
    MiscTab:CreateButton({ Name = "Rejoin Server",
        Callback = function()
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
        end })
    MiscTab:CreateButton({ Name = "Clear ESP", Callback = function() ESP.clear() end })
    MiscTab:CreateLabel("MoxxaStGradeX v" .. Config.Version)
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
LocalPlayer.Idled:Connect(function()
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
    pcall(loadUI)
    task.wait(0.5)
    pcall(Monitor.start)
end)