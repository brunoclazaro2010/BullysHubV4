if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)

pcall(function()
    local _origCG = collectgarbage
    hookfunction(_origCG, newcclosure(function(opt, ...)
        return _origCG("count")
    end))
end)
getgenv().collectgarbage = function(opt, ...) return gcinfo() end
pcall(function() _G.collectgarbage = getgenv().collectgarbage end)
local privateBuild = false

local SharedState = {
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
}

do
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end

    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched = patched + 1
                    end
                end
            end
        end
    end
    print("bk's so tuff boi")
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local IS_MOBILE = isMobile()


local FileName = "wxrldzPublic_v1.json" 
local DefaultConfig = {
    UIVisible = {
        StealerPanel = false,
        Settings = false,
    },
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        MobileControls = {X = 0.9, Y = 0.4},
        MobileBtn_TP = {X = 0.5, Y = 0.4},
        MobileBtn_CL = {X = 0.5, Y = 0.4},
        MobileBtn_SP = {X = 0.5, Y = 0.4},
        MobileBtn_IV = {X = 0.5, Y = 0.4},
        MobileBtn_UI = {X = 0.5, Y = 0.4},
        JobJoiner = {X = 0.5, Y = 0.85},
        StealerPanel = {X = 0.72, Y = 0.05},
        InvisMiniPanel = {X = 0.58, Y = 0.17},
    },
    TpSettings = {
        Tool           = "Flying Carpet",
        Speed          = 2, 
        TpKey          = "T",
        CloneKey       = "V",
        TpOnLoad       = false,
        MinGenForTp    = "",
        CarpetSpeedKey = "Q",
        InfiniteJump   = false,
        TpSpeed        = 2.0,
    },
    StealSpeed   = 20,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = false,
    PlayerESP    = true,


    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    UILocked     = false,
    HideAdminPanel = false,
    HideAutoSteal = false,
    MobileDesync = false,
    CompactAutoSteal = false,
    AutoKickOnSteal = false,
    AntiStealEnabled = false,
    AntiStealBuyList = {},
    AntiStealBuyCount = 4,
    AntiStealWalkBackAfter = 3,
    DeleteSlotCount = 3,
    InstantSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    DisableClickToAPOnMoby = false,
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    AutoResetOnBalloon = false,
    RemoveDesyncOnClone = false,
    AutoDesyncOnJoin = false,
    AdminPanelScale = 1.0,
    AdminListSize = 4,
    AutoWalkSpeedFPS = 0,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = false,
    AutoTPOnFailedSteal = false,
    AutoKickOnSteal = false,
    AntiStealEnabled = false,
    AntiStealBuyList = {},
    AntiStealBuyCount = 4,
    AntiStealWalkBackAfter = 3,
    DeleteSlotCount = 3,
    AutoTPPriority = true,
    KickKey = "",
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    DuelBaseESP = true,
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    DisableProximitySpamOnMoby = false,
    DisableClickToAPOnKawaifu = false,
    DisableProximitySpamOnKawaifu = false,
    HideKawaifuFromPanel = false,
    AutoStealSpeed = false,
    FloatKey = "G",
    ShowJobJoiner = true,
    JobJoinerKey = "J",
    AutoStealMinGen = "",
    AutoBuyMinGen = "",
    AutoTpOnReset = false,
    HideAdminPanel = false,
    HideAutoSteal = false,
    MobileDesync = false,
    Blacklist = {},
    FPSBoost = false,
    MutationESP = false,
    ThemePreset = "Cyan",
    ThemeBg = "Dark",
    ThemeText = "White",
    ThemeFont = "Gotham",
    ThemeFontBold = false,
    UIOutlines = true,
    UIAccentLines = true,
    HudTransparency = 0.06,
    HudSparkles = true,
    HideInvisPanel = false,
}


local Config = DefaultConfig

if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
        if decoded.UIVisible then
            for k, v in pairs(DefaultConfig.UIVisible) do
                if decoded.UIVisible[k] == nil then decoded.UIVisible[k] = v end
            end
        end
        Config = decoded
    end)
end
Config.ProximityAP = false
-- Apply hide states on load
task.defer(function()
    if Config.HideAdminPanel then
        local adUI = PlayerGui:FindFirstChild("wxrldzAdminPanel")
        if adUI then adUI.Enabled = false end
    end
    if Config.HideAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = false end
    end
    if Config.MobileDesync then
        local ok = pcall(function() raknet.desync(true) end)
        if ok then mobileDesyncActive = true end
    end
end)

function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do toSave[k] = v end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end

local HighlightName = "KaWaifu_NeonHighlight"
function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
    _G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false

_G.RecoveryInProgress = false
function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = getControls()

function kickPlayer()
    game:Shutdown()
end

function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    _G.isWalkingForward = true
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            _G.isWalkingForward = false
            return
        end
        hum:Move(lookVector, false)
    end)
end

local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "DesyncESP"
ESPFolder.Parent = Workspace

local anchorHighlight = nil
local serverPosition = nil
local positionUpdateConnection = nil
local desyncActive = false
local desyncHooksAdded = false
local mobileDesyncActive = false

function createDesyncESP()
    if anchorHighlight then 
        if anchorHighlight.highlight then anchorHighlight.highlight:Destroy() end
        if anchorHighlight.billboard then anchorHighlight.billboard:Destroy() end
        if anchorHighlight.part then anchorHighlight.part:Destroy() end
        if anchorHighlight.ringParts then
            for _, part in ipairs(anchorHighlight.ringParts) do
                if part.dot then part.dot:Destroy() end
            end
        end
        if anchorHighlight.vfxConn then anchorHighlight.vfxConn:Disconnect() end
        anchorHighlight = nil 
    end
    
    local part = Instance.new("Part")
    part.Name = "ServerPositionMarker"
    part.Size = Vector3.new(2, 5, 2)
    part.Anchored = true
    part.CanCollide = false
    part.Transparency = 1
    part.Parent = ESPFolder
    
    local ringParts = {}
    local attachments = {}
    
    local function makeSparks(parent)
        local att = Instance.new("Attachment")
        att.Parent = parent
        local sparks = Instance.new("ParticleEmitter")
        sparks.Color = ColorSequence.new(Color3.fromRGB(0, 200, 255))
        sparks.LightEmission = 1
        sparks.LightInfluence = 0
        sparks.Size = NumberSequence.new(0.1, 0.3)
        sparks.Lifetime = NumberRange.new(0.1, 0.3)
        sparks.Rate = 0
        sparks.Speed = NumberRange.new(5, 20)
        sparks.SpreadAngle = Vector2.new(180, 180)
        sparks.RotSpeed = NumberRange.new(-360, 360)
        sparks.Rotation = NumberRange.new(0, 360)
        sparks.Parent = att
        return att
    end
    
    local function makeRingDot(px, py, pz, sz, col, sparksSize)
        local dot = Instance.new("Part")
        dot.Anchored = true
        dot.CanCollide = false
        dot.CanTouch = false
        dot.CanQuery = false
        dot.CastShadow = false
        dot.Size = Vector3.new(sz, sz, sz)
        dot.Shape = Enum.PartType.Ball
        dot.Material = Enum.Material.Neon
        dot.Color = col
        dot.Transparency = 0
        dot.CFrame = CFrame.new(px, py, pz)
        dot.Parent = ESPFolder
        
        local att = Instance.new("Attachment")
        att.Parent = dot
        
        local em = Instance.new("ParticleEmitter")
        em.Color = ColorSequence.new(col)
        em.LightEmission = 1
        em.LightInfluence = 0
        em.Size = sparksSize
        em.Lifetime = NumberRange.new(0.1, 0.2)
        em.Rate = 10
        em.Speed = NumberRange.new(1, 5)
        em.SpreadAngle = Vector2.new(180, 180)
        em.Parent = att
        
        table.insert(attachments, att)
        return dot
    end
    
    local PI2 = math.pi * 2
    local OUTER_RADIUS = 5
    local INNER_RADIUS = 3   
    local GROUND_OFFSET = 3
    local OUTER_SPEED = 1.2
    local INNER_SPEED = 1.8
    local SPARK_INTERVAL = 0.3
    
    local rCount = 32
    local iCount = 20
    local gy = part.Position.Y - GROUND_OFFSET
    local outerCol = Color3.fromRGB(0, 100, 255)
    local innerCol = Color3.fromRGB(150, 210, 255)
    local ringSizeOuter = NumberSequence.new(1, 1.2)
    local ringSizeInner = NumberSequence.new(1, 1.2) 

    for i = 1, rCount do
        local a = (i / rCount) * PI2
        local dot = makeRingDot(
            part.Position.X + math.cos(a) * OUTER_RADIUS, 
            gy, 
            part.Position.Z + math.sin(a) * OUTER_RADIUS, 
            0.3, 
            outerCol, 
            ringSizeOuter
        )
        table.insert(ringParts, {dot = dot, baseAngle = a, isOuter = true})
    end

    for i = 1, iCount do
        local a = (i / iCount) * PI2
        local dot = makeRingDot(
            part.Position.X + math.cos(a) * INNER_RADIUS, 
            gy, 
            part.Position.Z + math.sin(a) * INNER_RADIUS, 
            0.2,
            innerCol, 
            ringSizeInner
        )
        table.insert(ringParts, {dot = dot, baseAngle = a, isOuter = false})
    end
    
    for i = 1, 3 do
        local sparkAtt = makeSparks(part)
        table.insert(attachments, sparkAtt)
    end
    
    local highlight = Instance.new('Highlight')
    highlight.Name = 'ServerPosHighlight'
    highlight.FillColor = Color3.fromRGB(0, 150, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.1
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = desyncActive
    highlight.Adornee = part
    highlight.Parent = ESPFolder
    
    local billboard = Instance.new('BillboardGui')
    billboard.Name = 'ServerPosGUI'
    billboard.Size = UDim2.new(0, 100, 0, 30)
    billboard.StudsOffset = Vector3.new(0, 6.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Enabled = desyncActive
    billboard.Parent = part
    
    local frame = Instance.new('Frame')
    frame.Name = 'Background'
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new('UICorner')
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local stroke = Instance.new('UIStroke')
    stroke.Color = Color3.fromRGB(0, 200, 255)
    stroke.Thickness = 2
    stroke.Parent = frame
    
    local posText = Instance.new('TextLabel')
    posText.Name = 'PositionText'
    posText.Size = UDim2.new(1, 0, 1, 0)
    posText.BackgroundTransparency = 1
    posText.Text = "SERVER POS"
    posText.TextColor3 = Color3.fromRGB(0, 200, 255)
    posText.Font = Enum.Font.GothamBlack
    posText.TextSize = 14
    posText.TextStrokeTransparency = 0.5
    posText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    posText.Parent = billboard
    
    for _, entry in ipairs(ringParts) do
        if entry.dot then
            entry.dot.Transparency = desyncActive and 0 or 1
        end
    end
    
    local sparkTimer = 0
    local vfxConn = RunService.Heartbeat:Connect(function(dt)
        if not desyncActive or not anchorHighlight then return end
        
        local t = tick()
        local pulse = math.abs(math.sin(t * 2))
        local pos = part.Position
        local gy = pos.Y - GROUND_OFFSET
        
        local fillG = math.floor(40 + pulse * 30)
        local fillB = math.floor(160 + pulse * 60)
        local outG = math.floor(100 + pulse * 60)
        
        highlight.FillColor = Color3.fromRGB(0, fillG, fillB)
        highlight.OutlineColor = Color3.fromRGB(0, outG, 255)
        highlight.OutlineTransparency = pulse * 0.3
        
        for _, entry in ipairs(ringParts) do
            if entry.dot and entry.dot.Parent then
                local radius = entry.isOuter and OUTER_RADIUS or INNER_RADIUS
                local speed = entry.isOuter and OUTER_SPEED or INNER_SPEED
                local a = entry.baseAngle + t * speed
                local wave = math.abs(math.sin(t * 5 + entry.baseAngle)) * 0.2
                local bright = math.abs(math.sin(t * 6 + entry.baseAngle)) * 0.4
                
                entry.dot.CFrame = CFrame.new(
                    pos.X + math.cos(a) * radius, 
                    gy + wave, 
                    pos.Z + math.sin(a) * radius
                )
                entry.dot.Transparency = bright
                
                if entry.isOuter then
                    local r = math.floor(80 + pulse * 60)
                    entry.dot.Color = Color3.fromRGB(0, r, 255)
                else
                    local r = math.floor(120 + pulse * 60)
                    local g = math.floor(180 + pulse * 40)
                    entry.dot.Color = Color3.fromRGB(r, g, 255)
                end
            end
        end
        
        sparkTimer = sparkTimer + dt
        if sparkTimer >= SPARK_INTERVAL then
            sparkTimer = 0
            local numAtts = #attachments
            if numAtts > 0 then
                local bursts = math.random(2, 5)
                for b = 1, bursts do
                    local pick = attachments[math.random(1, numAtts)]
                    if pick and pick.Parent then
                        local emitter = pick:FindFirstChildOfClass("ParticleEmitter")
                        if emitter then
                            emitter:Emit(math.random(8, 25))
                        end
                    end
                end
            end
        end
    end)
    
    anchorHighlight = {
        part = part,
        highlight = highlight,
        billboard = billboard,
        posText = posText,
        ringParts = ringParts,
        attachments = attachments,
        vfxConn = vfxConn
    }
    
    return anchorHighlight
end

function updateESP()
    if not desyncActive then return end
    
    if anchorHighlight and anchorHighlight.part and serverPosition then
        anchorHighlight.part.CFrame = CFrame.new(serverPosition)
        
        local character = LocalPlayer.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local currentPos = hrp.Position
                local serverPos = serverPosition
                local desyncDistance = (currentPos - serverPos).Magnitude
                
                if anchorHighlight.posText then
                    anchorHighlight.posText.Text = string.format("SERVER POS\n%.1f studs", desyncDistance)
                end
            end
        end
    end
end

function setupPositionTracking(hrp)
    if positionUpdateConnection then
        positionUpdateConnection:Disconnect()
    end
    
    serverPosition = hrp.Position
    
    positionUpdateConnection = hrp:GetPropertyChangedSignal("Position"):Connect(function()
        task.wait(0.15)
        local char = LocalPlayer.Character
        if char then
            local currentHRP = char:FindFirstChild("HumanoidRootPart")
            if currentHRP then
                serverPosition = currentHRP.Position
            end
        end
    end)
end

function initializeESP()
    ESPFolder:ClearAllChildren()
    
    createDesyncESP()
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            setupPositionTracking(hrp)
            if anchorHighlight and anchorHighlight.part then
                anchorHighlight.part.CFrame = CFrame.new(serverPosition)
            end
        end
    end
    updateESPVisibility()
end

function updateESPVisibility()
    if not anchorHighlight then return end
    
    if anchorHighlight.highlight then
        anchorHighlight.highlight.Enabled = desyncActive
    end
    
    if anchorHighlight.billboard then
        anchorHighlight.billboard.Enabled = desyncActive
    end
    
    if anchorHighlight.ringParts then
        for _, entry in ipairs(anchorHighlight.ringParts) do
            if entry.dot then
                entry.dot.Transparency = desyncActive and 0 or 1
            end
        end
    end
end

function send(packet)
    if packet.PacketId == 0x1B then
        local b = packet.AsBuffer
        buffer.writeu32(b, 1, 0xFFFFFFFF)
        buffer.writeu32(b, 5, 0xFFFFFFFF)
        buffer.writeu32(b, 9, 0xFFFFFFFF)
        packet:SetData(b)
    end
end

function recv(packet)
    if packet.PacketId == 0x86 then
        return false
    end
end

function enableDesync()
    if desyncActive then return end

    desyncActive = true
    raknet.add_send_hook(send)
    raknet.add_send_hook(recv)
    desyncHooksAdded = true

    updateESPVisibility()
end

function disableDesync()
    if not desyncActive then return end
    pcall(function()
        raknet.remove_send_hook(send)
        raknet.remove_send_hook(recv)
        raknet.remove_recv_hook(recv)
    end)
    desyncActive = false
    desyncHooksAdded = false
    updateESPVisibility()
end

local _isCloning = false
local _cloneCooldownEnd = 0
local _lastCloneTime = 0
function instantClone()
    if _isCloning then return end
    if tick() < _cloneCooldownEnd then return end
    _isCloning = true
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        local quantumCloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or character:FindFirstChild("Quantum Cloner")
        if not quantumCloner then return end
        if quantumCloner.Parent == LocalPlayer.Backpack then
            humanoid:EquipTool(quantumCloner)
        end
        if tick() - _lastCloneTime >= 10 then _lastCloneTime = tick() end
        quantumCloner:Activate()
        task.wait(0.1)
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local toolsFrames = playerGui:FindFirstChild("ToolsFrames")
        if toolsFrames then
            local qcGui = toolsFrames:FindFirstChild("QuantumCloner")
            if qcGui then
                local tpBtn = qcGui:FindFirstChild("TeleportToClone")
                if tpBtn then
                    firesignal(tpBtn.MouseButton1Up)
                end
            end
        end
    end)
    if Config.RemoveDesyncOnClone then
        disableDesync()
    else
        enableDesync()
    end
    task.wait(0.3)
    _isCloning = false
    _cloneCooldownEnd = 0
end

if LocalPlayer.Character then
    initializeESP()
    if Config.AutoDesyncOnJoin then
        task.spawn(function() task.wait(1); enableDesync() end)
    end
end

RunService.RenderStepped:Connect(function()
    updateESP()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    initializeESP()
    if Config.AutoDesyncOnJoin then
        task.spawn(function() task.wait(0.5); enableDesync() end)
    end
end)

function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 5

    local bestPromptSameLevel = nil
    local shortestDistSameLevel = math.huge

    local bestPromptFallback = nil
    local shortestDistFallback = math.huge
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, obj in ipairs(plots:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if maxY and part.Position.Y > maxY then
                else
                    local distance = (hrp.Position - part.Position).Magnitude
                    local yDifference = math.abs(playerY - part.Position.Y)

                    if distance < shortestDistFallback then
                        shortestDistFallback = distance
                        bestPromptFallback = obj
                    end

                    if yDifference <= Y_THRESHOLD then
                        if distance < shortestDistSameLevel then
                            shortestDistSameLevel = distance
                            bestPromptSameLevel = obj
                        end
                    end
                end
            end
        end
    end

    local targetPrompt = bestPromptSameLevel or bestPromptFallback

    if targetPrompt then
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        else
            targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end

local _THEME_PRESETS = {
    {name="Cyan",   accent=Color3.fromRGB(0,   210, 255), accent2=Color3.fromRGB(130,  0, 255), text=Color3.fromRGB(180,240,255), textSec=Color3.fromRGB(70,140,170)},
    {name="Purple", accent=Color3.fromRGB(180,  0, 255),  accent2=Color3.fromRGB(0,  150, 255), text=Color3.fromRGB(220,200,255), textSec=Color3.fromRGB(110,90,160)},
    {name="Green",  accent=Color3.fromRGB(0,   220, 110), accent2=Color3.fromRGB(0,  180, 255), text=Color3.fromRGB(200,255,210), textSec=Color3.fromRGB(80,150,90)},
    {name="Red",    accent=Color3.fromRGB(255,  50,  80), accent2=Color3.fromRGB(255, 130,  0), text=Color3.fromRGB(255,220,220), textSec=Color3.fromRGB(160,90,90)},
    {name="Orange", accent=Color3.fromRGB(255, 145,   0), accent2=Color3.fromRGB(255,  50, 80), text=Color3.fromRGB(255,245,220), textSec=Color3.fromRGB(145,125,90)},
    {name="Pink",   accent=Color3.fromRGB(255,  55, 180), accent2=Color3.fromRGB(180,   0,255), text=Color3.fromRGB(255,210,240), textSec=Color3.fromRGB(160,90,140)},
    {name="Gold",   accent=Color3.fromRGB(255, 205,  50), accent2=Color3.fromRGB(255, 120,  0), text=Color3.fromRGB(255,248,210), textSec=Color3.fromRGB(150,130,80)},
    {name="White",  accent=Color3.fromRGB(230, 235, 255), accent2=Color3.fromRGB(160, 170,255), text=Color3.fromRGB(240,240,240), textSec=Color3.fromRGB(90,100,130)},
}
local _THEME_MAP = {}
for _, t in ipairs(_THEME_PRESETS) do _THEME_MAP[t.name] = t end

local _BG_PRESETS = {
    {name="Dark",   bg=Color3.fromRGB(3,3,13),   surface=Color3.fromRGB(6,8,24),   highlight=Color3.fromRGB(14,16,40)},
    {name="Black",  bg=Color3.fromRGB(0,0,0),     surface=Color3.fromRGB(6,6,6),    highlight=Color3.fromRGB(16,16,16)},
    {name="Navy",   bg=Color3.fromRGB(3,6,20),    surface=Color3.fromRGB(5,10,32),  highlight=Color3.fromRGB(10,18,52)},
    {name="Deep",   bg=Color3.fromRGB(8,3,20),    surface=Color3.fromRGB(12,5,30),  highlight=Color3.fromRGB(20,8,52)},
    {name="Slate",  bg=Color3.fromRGB(12,14,18),  surface=Color3.fromRGB(18,20,28), highlight=Color3.fromRGB(28,30,42)},
    {name="Carbon", bg=Color3.fromRGB(10,10,10),  surface=Color3.fromRGB(16,16,16), highlight=Color3.fromRGB(26,26,26)},
}
local _BG_MAP = {}
for _, t in ipairs(_BG_PRESETS) do _BG_MAP[t.name] = t end

local _TEXT_PRESETS = {
    {name="White",  primary=Color3.fromRGB(240,240,240), secondary=Color3.fromRGB(90,100,130)},
    {name="Warm",   primary=Color3.fromRGB(255,245,220), secondary=Color3.fromRGB(145,125,90)},
    {name="Blue",   primary=Color3.fromRGB(195,215,255), secondary=Color3.fromRGB(90,110,160)},
    {name="Cyan",   primary=Color3.fromRGB(180,240,255), secondary=Color3.fromRGB(70,140,170)},
    {name="Green",  primary=Color3.fromRGB(200,255,210), secondary=Color3.fromRGB(80,150,90)},
    {name="Purple", primary=Color3.fromRGB(220,200,255), secondary=Color3.fromRGB(110,90,160)},
}
local _TEXT_MAP = {}
for _, t in ipairs(_TEXT_PRESETS) do _TEXT_MAP[t.name] = t end

local _FONT_PRESETS = {
    {name="Gotham",  face=Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)},
    {name="Nunito",  face=Font.new("rbxasset://fonts/families/Nunito.json",    Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)},
    {name="Ubuntu",  face=Font.new("rbxasset://fonts/families/Ubuntu.json",    Enum.FontWeight.Medium, Enum.FontStyle.Normal)},
    {name="Builder", face=Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)},
    {name="Arimo",   face=Font.new("rbxasset://fonts/families/Arimo.json",     Enum.FontWeight.Medium, Enum.FontStyle.Normal)},
    {name="Jura",    face=Font.new("rbxasset://fonts/families/Jura.json",      Enum.FontWeight.Medium, Enum.FontStyle.Normal)},
}
local _FONT_MAP = {}
for _, t in ipairs(_FONT_PRESETS) do _FONT_MAP[t.name] = t end

local Theme = {
    Background      = Color3.fromRGB(3, 3, 13),
    Surface         = Color3.fromRGB(6, 8, 24),
    SurfaceHighlight= Color3.fromRGB(14, 16, 40),
    Accent1         = Color3.fromRGB(0, 210, 255),
    Accent2         = Color3.fromRGB(180, 0, 255),
    TextPrimary     = Color3.fromRGB(240, 240, 240),
    TextSecondary   = Color3.fromRGB(90, 100, 130),
    Success         = Color3.fromRGB(30, 150, 90),
    Error           = Color3.fromRGB(255, 60, 80),
}
do -- apply all saved theme presets before UI is built
    local _pt = _THEME_MAP[Config.ThemePreset]
    if _pt then
        Theme.Accent1 = _pt.accent; Theme.Accent2 = _pt.accent2
        if _pt.text then Theme.TextPrimary = _pt.text end
        if _pt.textSec then Theme.TextSecondary = _pt.textSec end
    end
    local _bg = _BG_MAP[Config.ThemeBg]
    if _bg then Theme.Background = _bg.bg; Theme.Surface = _bg.surface; Theme.SurfaceHighlight = _bg.highlight end
end

local PRIORITY_LIST = {
    "Headless Horseman", "Strawberry Elephant", "Meowl", "Skibidi Toilet", "Griffin",
    "La Supreme Combinasion", "Dragon Gingerini", "Love Love Bear", "Signore Carapace",
    "Ginger Gerat", "Antonio", "Dragon Cannelloni", "Hydra Dragon Cannelloni",
    "Cerberus", "Ketupat Bros", "Dug Dug Dug",
    "La Casa Boo", "Rosey and Teddy", "Foxini Lanternini", "Fishino Clownino", "Celestial Pegasus",
    "Fortunu and Cashuru", "Cooki and Milki", "La Food Combinasion", "Reinito Sleighito",
    "Capitano Moby", "Spooky and Pumpky", "Fragrama and Chocrama", "Cloverat Clapat",
    "Los Sekolahs", "Festive 67", "Garama and Madundung", "Popcuru and Fizzuru",
    "Burguro and Fryuro", "La Secret Combinasion", "La Taco Combinasion",
    "Ketchuru and Musturu", "Lavadorito Spinito", "Tang Tang Keletang",
}
local _plSaveFile = "PriorityList.json"
local function _plSave() pcall(function() if writefile then writefile(_plSaveFile, HttpService:JSONEncode({priorityList=PRIORITY_LIST})) end end) end
do
    local _ok, _raw = pcall(function() if isfile and isfile(_plSaveFile) and readfile then return HttpService:JSONDecode(readfile(_plSaveFile)) end end)
    if _ok and type(_raw) == "table" and _raw.priorityList and type(_raw.priorityList) == "table" and #_raw.priorityList > 0 then
        PRIORITY_LIST = _raw.priorityList
    end
end

function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

function CreateGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   Theme.Accent1),
        ColorSequenceKeypoint.new(0.4, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, Color3.fromRGB(80, 0, 200)),
        ColorSequenceKeypoint.new(1,   Theme.Accent1),
    }
    g.Rotation = 0
    task.spawn(function()
        while g.Parent do
            g.Rotation = (g.Rotation + 0.2) % 360
            task.wait(0.05)
        end
    end)
    return g
end

function CreateAuroraBackground(parent) end 

function ApplyViewportUIScale(targetFrame, designWidth, designHeight, minScale, maxScale)
    if not targetFrame then return end
    if not IS_MOBILE then return end
    local existing = targetFrame:FindFirstChildOfClass("UIScale")
    if existing then existing:Destroy() end
    local sc = Instance.new("UIScale")
    sc.Parent = targetFrame
    SharedState.MobileScaleObjects[targetFrame] = sc
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    else
        sc.Scale = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    end
end

SharedState.RefreshMobileScale = function()
    local s = math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1)
    for frame, sc in pairs(SharedState.MobileScaleObjects) do
        if frame and frame.Parent and sc and sc.Parent == frame then
            sc.Scale = s
        else
            SharedState.MobileScaleObjects[frame] = nil
        end
    end
end

function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamMedium
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamMedium
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)

    MakeDraggable(restoreBtn, restoreBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startAbsX, startAbsY

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startAbsX = target.AbsolutePosition.X
            startAbsY = target.AbsolutePosition.Y

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent and target.Parent.AbsoluteSize or Vector2.new(1920, 1080)
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            local parentSize = (target.Parent and target.Parent.AbsoluteSize) or Vector2.new(1920, 1080)
            local sz = target.AbsoluteSize
            local m = 40
            local newX = math.clamp(startAbsX + delta.X, -(sz.X - m), parentSize.X - m)
            local newY = math.clamp(startAbsY + delta.Y, -(sz.Y - m), parentSize.Y - m)
            target.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

function MakeResizable(handle, panel, minPx, maxPx)
    local dragStartY = nil
    local startW, startH
    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStartY = input.Position.Y
            startW = panel.AbsoluteSize.X
            startH = panel.AbsoluteSize.Y
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragStartY then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position.Y - dragStartY
            local ratio = math.clamp(1 + delta / math.max(startH, 1), 0.4, 3.0)
            local newW = math.round(startW * ratio)
            local newH = math.round(startH * ratio)
            if minPx then newW = math.max(newW, minPx); newH = math.max(newH, minPx) end
            if maxPx then newW = math.min(newW, maxPx); newH = math.min(newH, maxPx) end
            panel.Size = UDim2.new(0, newW, 0, newH)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStartY = nil
        end
    end)
end

-- Clamp a frame so it can never sit outside the screen bounds.
-- Safe to call at any time; defers one frame so AbsoluteSize is valid.
local function ClampFrameToScreen(frame)
    task.spawn(function()
        task.wait()
        if not frame or not frame.Parent then return end
        local parentSize = frame.Parent.AbsoluteSize
        local sz = frame.AbsoluteSize
        local m = 40 -- minimum pixels that must stay on screen
        local px = math.clamp(frame.AbsolutePosition.X, -(sz.X - m), parentSize.X - m)
        local py = math.clamp(frame.AbsolutePosition.Y, -(sz.Y - m), parentSize.Y - m)
        frame.Position = UDim2.new(0, px, 0, py)
    end)
end
-- Re-clamp whenever the frame resizes (e.g. UIScale change, panel expanding)
local _clampedFrames = {}
local function RegisterClamp(frame)
    if _clampedFrames[frame] then return end
    _clampedFrames[frame] = true
    ClampFrameToScreen(frame)
    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        ClampFrameToScreen(frame)
    end)
end

function ShowNotification(title, text)
    local existing = PlayerGui:FindFirstChild("wxrldzNotif")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "wxrldzNotif"; sg.ResetOnSpawn = false; sg.DisplayOrder = 999

    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 290, 0, 54)
    f.Position = UDim2.new(0.5, -145, 0, 80)
    f.BackgroundColor3 = Color3.fromRGB(6, 6, 12)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 4)

    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1; stroke.Color = Theme.Accent1; stroke.Transparency = 1

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 1, -12); bar.Position = UDim2.new(0, 5, 0, 6)
    bar.BackgroundColor3 = Theme.Accent1; bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -22, 0, 18); t1.Position = UDim2.new(0, 16, 0, 7)
    t1.BackgroundTransparency = 1; t1.Text = title:upper()
    t1.Font = Enum.Font.GothamMedium; t1.TextSize = 11
    t1.TextColor3 = Theme.Accent1; t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextTransparency = 1

    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -22, 0, 15); t2.Position = UDim2.new(0, 16, 0, 27)
    t2.BackgroundTransparency = 1; t2.Text = text
    t2.Font = Enum.Font.GothamMedium; t2.TextSize = 10
    t2.TextColor3 = Theme.TextSecondary; t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextTransparency = 1

    local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(f,      fadeIn, {BackgroundTransparency = 0.12}):Play()
    TweenService:Create(stroke, fadeIn, {Transparency = 0.75}):Play()
    TweenService:Create(bar,    fadeIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(t1,     fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(t2,     fadeIn, {TextTransparency = 0}):Play()

    task.delay(2, function()
        if not sg.Parent then return end
        local fadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(f,      fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke, fadeOut, {Transparency = 1}):Play()
        TweenService:Create(bar,    fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(t1,     fadeOut, {TextTransparency = 1}):Play()
        local last = TweenService:Create(t2, fadeOut, {TextTransparency = 1})
        last:Play(); last.Completed:Wait()
        if sg.Parent then sg:Destroy() end
    end)
end

function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

function stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end

    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
        end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end


local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    xrayEnabled = false,
    antiRagdollMode = Config.AntiRagdoll or 0,
    floatActive = false,
    isTpMoving = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    xrayDescConn = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel

local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then
        -- Kill residual velocity so player doesn't slide after turning boost off
        local _c = LocalPlayer.Character
        local _hrp = _c and _c:FindFirstChild("HumanoidRootPart")
        if _hrp then
            _hrp.AssemblyLinearVelocity = Vector3.new(0, _hrp.AssemblyLinearVelocity.Y, 0)
        end
        return
    end

    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end

    Connections.carpetSpeedConnection = RunService.Heartbeat:Connect(function()
    carpetSpeedConnection = Connections.carpetSpeedConnection
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local toolName = Config.TpSettings.Tool
        local hasTool = c:FindFirstChild(toolName)

        if not hasTool then
            local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tb then hum:EquipTool(tb) end
        end

        if hasTool then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * 140,
                    hrp.AssemblyLinearVelocity.Y,
                    md.Z * 140
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

-- Number keys 1-9 while carpet boost is active: exit boost and equip that hotbar slot
do
    local _numKeyCodes = {
        [Enum.KeyCode.One]=1,[Enum.KeyCode.Two]=2,[Enum.KeyCode.Three]=3,
        [Enum.KeyCode.Four]=4,[Enum.KeyCode.Five]=5,[Enum.KeyCode.Six]=6,
        [Enum.KeyCode.Seven]=7,[Enum.KeyCode.Eight]=8,[Enum.KeyCode.Nine]=9,
    }
    UserInputService.InputBegan:Connect(function(input, gp)
        local slot = _numKeyCodes[input.KeyCode]
        if not slot then return end
        if not carpetSpeedEnabled then return end
        -- Turn off boost so heartbeat stops force-equipping carpet
        setCarpetSpeed(false)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = "OFF"
            _carpetStatusLabel.TextColor3 = Theme.Error
        end
        -- Equip the tool at the pressed slot number from the backpack
        task.defer(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChild("Humanoid")
            if not hum then return end
            local tools = {}
            for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if item:IsA("Tool") then table.insert(tools, item) end
            end
            if tools[slot] then
                hum:EquipTool(tools[slot])
            end
        end)
    end)
end

local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    if Connections.infiniteJumpMobileConnection then Connections.infiniteJumpMobileConnection:Disconnect(); Connections.infiniteJumpMobileConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    local function doJump()
        local now = tick()
        if now - JumpData.lastJumpTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        JumpData.lastJumpTime = now
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z)
    end

    -- PC: poll Space key
    Connections.infiniteJumpConnection = RunService.Heartbeat:Connect(function()
        infiniteJumpConnection = Connections.infiniteJumpConnection
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        doJump()
    end)

    -- Mobile: hook JumpRequest (fires when mobile jump button is tapped)
    Connections.infiniteJumpMobileConnection = UserInputService.JumpRequest:Connect(function()
        if not infiniteJumpEnabled then return end
        doJump()
    end)
end
if infiniteJumpEnabled then setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

local function isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

local function enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
local function disableXray()
    XrayState.xrayEnabled = false
    xrayEnabled = XrayState.xrayEnabled
    if Connections.xrayDescConn then Connections.xrayDescConn:Disconnect(); Connections.xrayDescConn = nil end
    xrayDescConn = Connections.xrayDescConn
    for part, val in pairs(XrayState.originalTransparency) do
        if part and part.Parent then part.LocalTransparencyModifier = val end
    end
    XrayState.originalTransparency = {}
    originalTransparency = XrayState.originalTransparency
end

if Config.XrayEnabled then
    enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end


local function startAntiRagdoll(mode)
    stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        stopAntiRagdollV2()
    end
    if mode == 0 then return end

    Connections.antiRagdollConn = RunService.Heartbeat:Connect(function()
    antiRagdollConn = Connections.antiRagdollConn
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if isRagdolled() then
            pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hrp.AssemblyLinearVelocity = Vector3.zero
            if Workspace.CurrentCamera.CameraSubject ~= hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BallSocketConstraint") or obj.Name:find("RagdollAttachment") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local AntiRagdollV2Data = {
    antiRagdollConns = {},
}
local antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

local cleanRagdollV2Scheduled = false
local function cleanRagdollV2(char)
    if not char then return end
    local carpetEquipped = false
    pcall(function()
        local toolName = Config.TpSettings.Tool or "Flying Carpet"
        local tool = char:FindFirstChild(toolName)
        if tool then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
            if not carpetEquipped then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
        end
    end)
    local descendants = char:GetDescendants()
    for _, d in ipairs(descendants) do
        if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
            or d:IsA("HingeConstraint")
            or (d:IsA("Attachment") and (d.Name == "A" or d.Name == "B")) then
            d:Destroy()
        elseif (d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and not carpetEquipped then
            d:Destroy()
        end
    end
    for _, d in ipairs(descendants) do
        if d:IsA("Motor6D") then d.Enabled = true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation and track.Animation.Name:lower() or ""
                if n:find("rag") or n:find("fall") or n:find("hurt") or n:find("down") then
                    track:Stop(0)
                end
            end
        end
    end
    task.defer(function()
        pcall(function()
            local pm = LocalPlayer:FindFirstChild("PlayerScripts")
            if pm then pm = pm:FindFirstChild("PlayerModule") end
            if pm then require(pm):GetControls():Enable() end
        end)
    end)
end
local function cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then cleanRagdollV2(char) end
    end)
end
local function isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end

local function hookAntiRagV2(char)
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end

    local lastVel = Vector3.new(0, 0, 0)

    local c1 = hum.StateChanged:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            local carpetActive = false
            pcall(function()
                local toolName = Config.TpSettings.Tool or "Flying Carpet"
                local tool = char:FindFirstChild(toolName)
                if tool and hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            carpetActive = true
                        end
                    end
                end
            end)
            if not carpetActive then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanRagdollV2(char)
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            pcall(function()
                local pm = LocalPlayer:FindFirstChild("PlayerScripts")
                if pm then pm = pm:FindFirstChild("PlayerModule") end
                if pm then require(pm):GetControls():Enable() end
            end)
        end
    end)
    table.insert(antiRagdollConns, c1)

    local c2 = char.DescendantAdded:Connect(function(desc)
        if isRagdollRelatedDescendant(desc) then
            cleanRagdollV2Debounced(char)
        end
    end)
    table.insert(antiRagdollConns, c2)

    pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg then
            local net = pkg:FindFirstChild("Net")
            if net then
                local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    local c3 = applyImp.OnClientEvent:Connect(function()
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                        end
                    end)
                    table.insert(antiRagdollConns, c3)
                end
            end
        end
    end)

    local c4 = RunService.Heartbeat:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            cleanRagdollV2(char)
            local vel = hrp.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                hrp.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, 15)
            end
        end
        lastVel = hrp.AssemblyLinearVelocity
    end)
    table.insert(antiRagdollConns, c4)

    cleanRagdollV2(char)
end

local function stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end

local function startAntiRagdollV2(enabled)
    stopAntiRagdoll()
    stopAntiRagdollV2()
    if not enabled then
        return
    end

    local char = LocalPlayer.Character
    if char then task.spawn(function() hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() hookAntiRagV2(c) end)
    end)
end

if antiRagdollMode > 0 then startAntiRagdoll(antiRagdollMode) end
if Config.AntiRagdollV2 then startAntiRagdollV2(true) end

do
    local plotBeam = nil
    local plotBeamAttachment0 = nil
    local plotBeamAttachment1 = nil

    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if text:find(LocalPlayer.DisplayName:lower(), 1, true) or text:find(LocalPlayer.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function createPlotBeam()
        if not Config.LineToBase then return end
        local myPlot = findMyPlot()
        if not myPlot or not myPlot.Parent then return end
        local character = LocalPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        plotBeamAttachment0 = hrp:FindFirstChild("PlotBeamAttach_Player") or Instance.new("Attachment")
        plotBeamAttachment0.Name = "PlotBeamAttach_Player"
        plotBeamAttachment0.Position = Vector3.new(0, 0, 0)
        plotBeamAttachment0.Parent = hrp
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart or not plotPart.Parent then return end
        plotBeamAttachment1 = plotPart:FindFirstChild("PlotBeamAttach_Plot") or Instance.new("Attachment")
        plotBeamAttachment1.Name = "PlotBeamAttach_Plot"
        plotBeamAttachment1.Position = Vector3.new(0, 5, 0)
        plotBeamAttachment1.Parent = plotPart
        plotBeam = hrp:FindFirstChild("PlotBeam") or Instance.new("Beam")
        plotBeam.Name = "PlotBeam"
        plotBeam.Attachment0 = plotBeamAttachment0
        plotBeam.Attachment1 = plotBeamAttachment1
        plotBeam.FaceCamera = true
        plotBeam.LightEmission = 1
        plotBeam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
        plotBeam.Transparency = NumberSequence.new(0)
        plotBeam.Width0 = 0.7
        plotBeam.Width1 = 0.7
        plotBeam.TextureMode = Enum.TextureMode.Wrap
        plotBeam.TextureSpeed = 0
        plotBeam.Parent = hrp
    end

    local function resetPlotBeam()
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        if plotBeamAttachment1 then pcall(function() plotBeamAttachment1:Destroy() end) end
        plotBeam = nil
        plotBeamAttachment0 = nil
        plotBeamAttachment1 = nil
    end

    task.spawn(function()
        local checkCounter = 0
        RunService.Heartbeat:Connect(function()
            if not Config.LineToBase then return end
            checkCounter = checkCounter + 1
            if checkCounter >= 30 then
                checkCounter = 0
                if not plotBeam or not plotBeam.Parent or not plotBeamAttachment0 or not plotBeamAttachment0.Parent then
                    pcall(createPlotBeam)
                end
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.LineToBase and character then
            pcall(createPlotBeam)
        end
    end)

    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.2)
            if Config.LineToBase then createPlotBeam() end
        end)
    end

    _G.createPlotBeam = createPlotBeam
    _G.resetPlotBeam = resetPlotBeam
end

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils = require(Utils:WaitForChild("NumberUtils"))

    local autoStealEnabled = true

    if Config.DefaultToPriority and Config.DefaultToHighest then Config.DefaultToHighest = false end
    if Config.DefaultToPriority and Config.DefaultToNearest then Config.DefaultToNearest = false end
    if Config.DefaultToHighest and Config.DefaultToNearest then Config.DefaultToNearest = false end
    if not Config.DefaultToPriority and not Config.DefaultToHighest and not Config.DefaultToNearest then
        Config.DefaultToHighest = true
    end

    local stealNearestEnabled = false
    local stealHighestEnabled = false
    local stealPriorityEnabled = false

    if Config.DefaultToNearest then
        stealNearestEnabled = true
        Config.StealNearest = true; Config.StealHighest = false; Config.StealPriority = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToHighest then
        stealHighestEnabled = true
        Config.StealHighest = true; Config.StealNearest = false; Config.StealPriority = false
        Config.AutoTPPriority = false
    elseif Config.DefaultToPriority then
        stealPriorityEnabled = true
        Config.StealPriority = true; Config.StealNearest = false; Config.StealHighest = false
        Config.AutoTPPriority = true
    else
        stealNearestEnabled = Config.StealNearest
        stealHighestEnabled = Config.StealHighest
        stealPriorityEnabled = Config.StealPriority
        if Config.StealPriority then Config.AutoTPPriority = true
        elseif Config.StealNearest then Config.AutoTPPriority = true
        elseif Config.StealHighest then Config.AutoTPPriority = false end
    end

    local selectedTargetIndex = 1
    local selectedTargetUID = nil
    local allAnimalsCache = {}
    local PromptCache = {}
    local StealTimes = {}
    local STEAL_CD = 0
    local petButtons = {}
    local instantStealEnabled = true
    local instantStealReady = false
    local instantStealDidInit = false
    local _autoStealPaused = false

    local AnimalModels = ReplicatedStorage:WaitForChild("Models"):WaitForChild("Animals")
    local AnimalAnimations = ReplicatedStorage:WaitForChild("Animations"):WaitForChild("Animals")

    local function getMinGenValue()
        if not Config.AutoStealMinGen or Config.AutoStealMinGen == "" then return 0 end
        
        local str = Config.AutoStealMinGen:upper():gsub("%s+", "")
        local num = tonumber(str:match("%d+%.?%d*"))
        if not num then return 0 end
        
        if str:find("M") then
            return num * 1000000
        elseif str:find("K") then
            return num * 1000
        elseif str:find("B") then
            return num * 1000000000
        else
            return num
        end
    end

    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots"); if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot); if not plot then return false end
        local channel = Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "Instance" then return owner == LocalPlayer end
            end
        end
        return false
    end

    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None" then return "" end
        local f = ""
        if mutationName == "Cursed" then f = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
        elseif mutationName == "Gold" then f = "<font color='rgb(255,215,0)'>Gold</font>"
        elseif mutationName == "Diamond" then f = "<font color='rgb(0,255,255)'>Diamond</font>"
        elseif mutationName == "YinYang" then f = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
        elseif mutationName == "Candy" then f = "<font color='rgb(255,105,180)'>Candy</font>"
        elseif mutationName == "Divine" then f = "<font color='rgb(255,255,255)'>Divine</font>"
        elseif mutationName == "Rainbow" then
            local cols = {"rgb(255,0,0)","rgb(255,127,0)","rgb(255,255,0)","rgb(0,255,0)","rgb(0,0,255)","rgb(75,0,130)","rgb(148,0,211)"}
            for i = 1, #mutationName do f = f.."<font color='"..cols[(i-1)%#cols+1].."'>"..mutationName:sub(i,i).."</font>" end
        else f = mutationName end
        return "<font weight='800'>"..f.." </font>"
    end

    local function get_all_pets()
        local out = {}
        local minGen = getMinGenValue()
        for _, a in ipairs(allAnimalsCache) do
            if a.genValue >= 1 and not isMyBaseAnimal(a) then
                if minGen == 0 or a.genValue >= minGen then
                    table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                        owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a})
                end
            end
        end
        if stealPriorityEnabled then
            local priorityIndex = {}
            for i, pName in ipairs(PRIORITY_LIST) do
                priorityIndex[pName:lower()] = i
            end
            table.sort(out, function(a, b)
                local ai = priorityIndex[a.petName:lower()] or math.huge
                local bi = priorityIndex[b.petName:lower()] or math.huge
                if ai ~= bi then return ai < bi end
                return a.mpsValue > b.mpsValue
            end)
        else
            table.sort(out, function(a, b) return a.mpsValue > b.mpsValue end)
        end
        return out
    end

    local function preparePrompt(prompt)
        pcall(function()
            prompt.HoldDuration = -9e9
            prompt.MaxActivationDistance = 9e9
            prompt.RequiresLineOfSight = false
            prompt.Enabled = false
        end)
    end

    local function instantSteal(prompt)
        if not prompt then return end
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
            return
        end
        pcall(function()
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
        end)
    end

    local function executeSteal(prompt)
        local now = os.clock()
        if StealTimes[prompt] and (now - StealTimes[prompt]) < STEAL_CD then return end
        StealTimes[prompt] = now
        instantSteal(prompt)
    end

    local function findPromptForAnimal(animalData)
        if not animalData then return nil end
        local cached = PromptCache[animalData.uid]
        if cached and cached.Parent then return cached end
        local plots = Workspace:FindFirstChild("Plots"); if not plots then return nil end
        local plot = plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        local ch = Synchronizer:Get(plot.Name)
        if not ch then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local attach = spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        for _, p in ipairs(attach:GetChildren()) do
                            if p:IsA("ProximityPrompt") then
                                PromptCache[animalData.uid] = p
                                preparePrompt(p)
                                return p
                            end
                        end
                    end
                end
            end
            return nil
        end
        local al = ch:Get("AnimalList"); if not al then return nil end
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == animalData.slot then
                local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot)); break
                end
            end
        end
        if not foundPodium then foundPodium = podiums:FindFirstChild(animalData.slot) end
        if foundPodium then
            local base = foundPodium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") then
                            PromptCache[animalData.uid] = p
                            preparePrompt(p)
                            return p
                        end
                    end
                end
                local startPos = spawn.Position
                local slotX, slotZ = startPos.X, startPos.Z
                local nearestPrompt, minDist = nil, math.huge
                for _, desc in pairs(plot:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.ActionText == "Steal" then
                        local part = desc.Parent
                        local promptPos = nil
                        if part and part:IsA("BasePart") then promptPos = part.Position
                        elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then promptPos = part.Parent.Position end
                        if promptPos then
                            local checkStartY = startPos.Y
                            if brainrotName:find("la secret combinasion") then checkStartY = startPos.Y - 5 end
                            local horizontalDist = math.sqrt((promptPos.X - slotX)^2 + (promptPos.Z - slotZ)^2)
                            if horizontalDist < 5 and promptPos.Y > checkStartY then
                                local yDist = promptPos.Y - checkStartY
                                if yDist < minDist then minDist = yDist; nearestPrompt = desc end
                            end
                        end
                    end
                end
                if nearestPrompt then
                    PromptCache[animalData.uid] = nearestPrompt
                    preparePrompt(nearestPrompt)
                    return nearestPrompt
                end
            end
        end
        return nil
    end

    task.spawn(function()
        while task.wait(1) do
            for uid, p in pairs(PromptCache) do
                if p and p.Parent then preparePrompt(p)
                else PromptCache[uid] = nil end
            end
        end
    end)

    local function buildViewport(vpContainer, animalName)
        if not AnimalModels then return end
        local tmpl = AnimalModels:FindFirstChild(animalName)
        if not tmpl then return end
        local vp = Instance.new("ViewportFrame")
        vp.Size = UDim2.new(1, 0, 1, 0)
        vp.Position = UDim2.new(0, 0, 0, 0)
        vp.BackgroundTransparency = 1
        vp.BorderSizePixel = 0
        vp.LightColor = Color3.fromRGB(255, 255, 255)
        vp.LightDirection = Vector3.new(-1, -2, -1)
        vp.Ambient = Color3.fromRGB(180, 180, 180)
        vp.Parent = vpContainer
        local clone = tmpl:Clone()
        local wm = Instance.new("WorldModel"); wm.Parent = vp
        clone.Parent = wm
        if clone.PrimaryPart then clone.PrimaryPart.Anchored = true end
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Anchored = true; d.CanCollide = false
                d.CastShadow = false; d.Massless = true
            end
        end
        local ok, bbCF, bbSize = pcall(function() return clone:GetBoundingBox() end)
        if not ok then bbCF = clone:GetPivot(); bbSize = Vector3.new(4, 4, 4) end
        local sz = math.max(bbSize.X, bbSize.Y, bbSize.Z)
        local fov = 50
        local dist = (sz * 0.5) / math.tan(math.rad(fov * 0.5)) * 0.85
        local modelCF = (clone.PrimaryPart and clone.PrimaryPart.CFrame) or clone:GetPivot()
        local offset = (modelCF.LookVector + Vector3.new(0, 0.25, 0)).Unit
        local cam = Instance.new("Camera")
        cam.FieldOfView = fov
        cam.CFrame = CFrame.new(bbCF.Position + offset * (dist + sz * 0.5), bbCF.Position)
        cam.Parent = vp; vp.CurrentCamera = cam
        if not AnimalAnimations then return end
        local animFolder = AnimalAnimations:FindFirstChild(animalName)
        local idleAnim = animFolder and (
            animFolder:FindFirstChild("Idle") or
            animFolder:FindFirstChild("idle") or
            (animFolder:GetChildren()[1])
        )
        if not idleAnim then return end
        local animCtrl = clone:FindFirstChildWhichIsA("AnimationController", true)
        if not animCtrl then
            animCtrl = Instance.new("AnimationController"); animCtrl.Parent = clone
        end
        local animator = animCtrl:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator"); animator.Parent = animCtrl
        end
        local track = animator:LoadAnimation(idleAnim)
        track.Looped = true; track:Play(0)
        if track.Length > 0 then track.TimePosition = os.clock() % track.Length end
        task.spawn(function()
            while vp.Parent do
                task.wait(1)
                pcall(function()
                    if track.Length > 0 then
                        local t = os.clock() % track.Length
                        if math.abs(t - track.TimePosition) > 0.05 then track.TimePosition = t end
                    end
                end)
            end
        end)
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoStealUI"; screenGui.ResetOnSpawn = false; screenGui.DisplayOrder = 999; screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.6 or 1
    frame.Size = UDim2.new(0, 270 * mobileScale, 0, 510 * mobileScale)
    local _savedAutoStealPos = Config.Positions and Config.Positions.AutoSteal
    if IS_MOBILE and (not _savedAutoStealPos or (_savedAutoStealPos.X == 0.02 and _savedAutoStealPos.Y == 0.35)) then
        -- Default: center below unlock buttons (unlock ends ~Y=138px)
        task.defer(function()
            task.wait()
            local vp = workspace.CurrentCamera.ViewportSize
            local fw = frame.AbsoluteSize.X
            frame.Position = UDim2.new(0, (vp.X - fw) / 2, 0, 142)
        end)
    else
        frame.Position = UDim2.new(_savedAutoStealPos.X, 0, _savedAutoStealPos.Y, 0)
    end
    frame.BackgroundColor3 = Theme.Background; frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Active = true; frame.Parent = screenGui
    SharedState.AutoStealFrame = frame

    AddMobileMinimize(frame, "AUTO STEAL")
    RegisterClamp(frame)

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    CreateAuroraBackground(frame)
    local _ab = Instance.new("Frame", screenGui); _ab.BackgroundTransparency = 1; _ab.BorderSizePixel = 0; _ab.ZIndex = 100
    Instance.new("UICorner", _ab).CornerRadius = UDim.new(0, 8)
    local mainStroke = Instance.new("UIStroke", _ab); mainStroke.Color = Color3.fromRGB(0, 210, 255); mainStroke.Thickness = 1; mainStroke.Transparency = 0.7
    local function _absync()
        _ab.Size = UDim2.new(0, frame.AbsoluteSize.X, 0, frame.AbsoluteSize.Y)
        _ab.Position = UDim2.new(0, frame.AbsolutePosition.X, 0, frame.AbsolutePosition.Y)
        _ab.Visible = frame.Visible
    end
    _absync()
    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_absync)
    frame:GetPropertyChangedSignal("Position"):Connect(_absync)
    frame:GetPropertyChangedSignal("Visible"):Connect(_absync)

    do -- stars
        local _stars = {
            {0.07,0.04,1,0.55,2.0},{0.23,0.09,2,0.35,3.2},{0.61,0.06,1,0.70,2.5},{0.84,0.12,1,0.40,4.1},{0.45,0.03,2,0.60,3.7},
            {0.92,0.20,1,0.30,2.8},{0.14,0.18,1,0.65,5.0},{0.50,0.15,2,0.45,2.3},{0.76,0.28,1,0.50,3.5},{0.32,0.22,1,0.75,4.6},
            {0.05,0.35,2,0.40,2.1},{0.68,0.38,1,0.55,3.0},{0.88,0.42,1,0.30,4.8},{0.40,0.44,2,0.65,2.7},{0.19,0.50,1,0.45,3.9},
            {0.55,0.52,1,0.70,5.0},{0.79,0.55,2,0.35,2.2},{0.30,0.60,1,0.60,3.3},{0.10,0.65,1,0.50,4.0},{0.63,0.62,2,0.40,2.9},
            {0.94,0.68,1,0.55,3.6},{0.47,0.70,1,0.30,2.4},{0.22,0.75,2,0.70,4.5},{0.72,0.72,1,0.45,3.1},{0.38,0.80,1,0.60,2.6},
            {0.85,0.78,2,0.35,5.0},{0.15,0.85,1,0.55,3.8},{0.56,0.82,1,0.40,2.2},{0.02,0.90,2,0.65,4.3},{0.70,0.88,1,0.50,3.0},
            {0.42,0.92,1,0.30,2.7},{0.90,0.95,2,0.70,4.7},{0.26,0.96,1,0.45,3.5},{0.60,0.96,1,0.55,2.0},{0.80,0.30,1,0.40,3.2},
            {0.35,0.32,2,0.65,4.4},{0.52,0.38,1,0.50,2.8},{0.17,0.42,1,0.30,5.0},{0.96,0.50,2,0.60,3.7},{0.44,0.58,1,0.45,2.3},
            {0.08,0.12,1,0.55,4.2},{0.74,0.18,2,0.35,3.0},{0.29,0.48,1,0.70,2.6},{0.66,0.76,1,0.40,4.9},{0.48,0.22,2,0.60,3.4},
        }
        for _, s in ipairs(_stars) do
            local _d = Instance.new("Frame", frame)
            _d.Size = UDim2.new(0, s[3], 0, s[3])
            _d.Position = UDim2.new(s[1], 0, s[2], 0)
            _d.AnchorPoint = Vector2.new(0.5, 0.5)
            _d.BackgroundColor3 = Color3.fromRGB(220, 235, 255)
            _d.BackgroundTransparency = s[4]
            _d.BorderSizePixel = 0; _d.ZIndex = 1
            Instance.new("UICorner", _d).CornerRadius = UDim.new(1, 0)
            TweenService:Create(_d, TweenInfo.new(s[5], Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                {BackgroundTransparency = math.min(s[4] + 0.45, 0.95)}):Play()
        end
    end

    -- Top accent bar
    local _asAccent = Instance.new("Frame", frame)
    _asAccent.Size = UDim2.new(1, 0, 0, 4); _asAccent.Position = UDim2.new(0, 0, 0, 0)
    _asAccent.BackgroundColor3 = Color3.fromRGB(0, 200, 255); _asAccent.BorderSizePixel = 0; _asAccent.ZIndex = 5
    Instance.new("UICorner", _asAccent).CornerRadius = UDim.new(0, 8)
    SharedState.AutoStealAccentBar = _asAccent

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 46); header.Position = UDim2.new(0, 0, 0, 3); header.BackgroundTransparency = 1
    header.Active = true
    MakeDraggable(header, frame, "AutoSteal")
    do
        local _rh = Instance.new("TextButton", header)
        _rh.Size = UDim2.new(0, 22, 0, 22); _rh.Position = UDim2.new(1, -26, 0.5, -11)
        _rh.BackgroundColor3 = Color3.fromRGB(18, 20, 28); _rh.Text = "↕"
        _rh.Font = Enum.Font.GothamMedium; _rh.TextSize = 11
        _rh.TextColor3 = Color3.fromRGB(0, 200, 255); _rh.ZIndex = 10
        Instance.new("UICorner", _rh).CornerRadius = UDim.new(1, 0)
        MakeResizable(_rh, frame)
    end

    local _asTitleA = Instance.new("TextLabel", header)
    _asTitleA.Size = UDim2.new(0, 46, 1, 0); _asTitleA.Position = UDim2.new(0, 14, 0, 0)
    _asTitleA.BackgroundTransparency = 1; _asTitleA.Text = "AUTO"
    _asTitleA.Font = Enum.Font.GothamBold; _asTitleA.TextSize = 15
    _asTitleA.TextColor3 = Color3.fromRGB(220, 225, 240); _asTitleA.TextXAlignment = Enum.TextXAlignment.Left

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0, 70, 1, 0); titleLabel.Position = UDim2.new(0, 56, 0, 0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "STEAL"
    titleLabel.Font = Enum.Font.GothamBold; titleLabel.TextSize = 15
    titleLabel.TextColor3 = Color3.fromRGB(0, 200, 255); titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Header separator
    local _asHSep = Instance.new("Frame", frame)
    _asHSep.Size = UDim2.new(1, -20, 0, 1); _asHSep.Position = UDim2.new(0, 10, 0, 49)
    _asHSep.BackgroundColor3 = Color3.fromRGB(25, 28, 40); _asHSep.BorderSizePixel = 0

    if IS_MOBILE then
        local menuToggleBtn = Instance.new("TextButton", header)
        menuToggleBtn.Size = UDim2.new(0, 70, 0, 26)
        menuToggleBtn.Position = UDim2.new(1, -74, 0.5, -13)
        menuToggleBtn.BackgroundColor3 = Theme.Accent1
        menuToggleBtn.Text = "MENU"; menuToggleBtn.Font = Enum.Font.GothamMedium
        menuToggleBtn.TextSize = 11; menuToggleBtn.TextColor3 = Color3.new(0, 0, 0)
        Instance.new("UICorner", menuToggleBtn).CornerRadius = UDim.new(1, 0)
        menuToggleBtn.MouseButton1Click:Connect(function()
            if settingsGui then
                settingsGui.Enabled = not settingsGui.Enabled
                if not Config.UIVisible then Config.UIVisible = {} end
                Config.UIVisible.Settings = settingsGui.Enabled
                SaveConfig()
            end
        end)
    end

    -- Thin divider under header (already have _asHSep above, skip duplicate)
    local _hdiv = Instance.new("Frame", frame)
    _hdiv.Size = UDim2.new(0, 0, 0, 0); _hdiv.BackgroundTransparency = 1; _hdiv.BorderSizePixel = 0

    -- Target card
    local targetPanel = Instance.new("Frame", frame)
    targetPanel.Size = UDim2.new(1, -16, 0, 44); targetPanel.Position = UDim2.new(0, 8, 0, 86)
    targetPanel.BackgroundColor3 = Color3.fromRGB(14, 15, 22); targetPanel.BackgroundTransparency = 0
    targetPanel.BorderSizePixel = 0
    Instance.new("UICorner", targetPanel).CornerRadius = UDim.new(0, 6)
    local _tpStroke = Instance.new("UIStroke", targetPanel)
    _tpStroke.Color = Color3.fromRGB(0, 200, 255); _tpStroke.Thickness = 1; _tpStroke.Transparency = 0.6

    local targetHeader = Instance.new("TextLabel", targetPanel)
    targetHeader.Size = UDim2.new(1, -16, 0, 13); targetHeader.Position = UDim2.new(0, 8, 0, 5)
    targetHeader.BackgroundTransparency = 1; targetHeader.Text = "CURRENT TARGET"
    targetHeader.Font = Enum.Font.GothamMedium; targetHeader.TextSize = 9
    targetHeader.TextColor3 = Theme.TextSecondary; targetHeader.TextXAlignment = Enum.TextXAlignment.Left
    targetHeader.TextTransparency = 0.4

    local targetLabel = Instance.new("TextLabel", targetPanel)
    targetLabel.Size = UDim2.new(1, -16, 0, 18); targetLabel.Position = UDim2.new(0, 8, 0, 22)
    targetLabel.BackgroundTransparency = 1; targetLabel.Font = Enum.Font.GothamMedium; targetLabel.TextSize = 12
    targetLabel.TextColor3 = Theme.TextPrimary; targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextTruncate = Enum.TextTruncate.AtEnd; targetLabel.Text = ""

    -- Mode pills (horizontal) — admin panel style
    local nearestBtn = Instance.new("TextButton", frame)
    nearestBtn.Size = UDim2.new(0.31, -3, 0, 28); nearestBtn.Position = UDim2.new(0.01, 0, 0, 52)
    nearestBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26); nearestBtn.BorderSizePixel = 0
    nearestBtn.Text = "NEAREST"; nearestBtn.Font = Enum.Font.GothamMedium
    nearestBtn.TextSize = 10; nearestBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 6)
    local _nStroke = Instance.new("UIStroke", nearestBtn); _nStroke.Color = Color3.fromRGB(0, 200, 255); _nStroke.Transparency = 0.5; _nStroke.Thickness = 1

    local highestBtn = Instance.new("TextButton", frame)
    highestBtn.Size = UDim2.new(0.31, -3, 0, 28); highestBtn.Position = UDim2.new(0.34, 0, 0, 52)
    highestBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26); highestBtn.BorderSizePixel = 0
    highestBtn.Text = "HIGHEST"; highestBtn.Font = Enum.Font.GothamMedium
    highestBtn.TextSize = 10; highestBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    Instance.new("UICorner", highestBtn).CornerRadius = UDim.new(0, 6)
    local _hStroke = Instance.new("UIStroke", highestBtn); _hStroke.Color = Color3.fromRGB(0, 200, 255); _hStroke.Transparency = 0.5; _hStroke.Thickness = 1

    local priorityBtn = Instance.new("TextButton", frame)
    priorityBtn.Size = UDim2.new(0.31, -3, 0, 28); priorityBtn.Position = UDim2.new(0.67, 0, 0, 52)
    priorityBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26); priorityBtn.BorderSizePixel = 0
    priorityBtn.Text = "PRIORITY"; priorityBtn.Font = Enum.Font.GothamMedium
    priorityBtn.TextSize = 10; priorityBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
    Instance.new("UICorner", priorityBtn).CornerRadius = UDim.new(0, 6)
    local _pStroke = Instance.new("UIStroke", priorityBtn); _pStroke.Color = Color3.fromRGB(0, 200, 255); _pStroke.Transparency = 0.5; _pStroke.Thickness = 1

    -- Brainrots label
    local selectLabel = Instance.new("TextLabel", frame)
    selectLabel.Size = UDim2.new(1, -16, 0, 14); selectLabel.Position = UDim2.new(0, 8, 0, 136)
    selectLabel.BackgroundTransparency = 1; selectLabel.Text = "AVAILABLE BRAINROTS"
    selectLabel.Font = Enum.Font.GothamMedium; selectLabel.TextSize = 9
    selectLabel.TextColor3 = Color3.fromRGB(65, 70, 95); selectLabel.TextXAlignment = Enum.TextXAlignment.Left

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, -16, 1, -234); listFrame.Position = UDim2.new(0, 8, 0, 153)
    listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ScrollBarImageTransparency = 1; listFrame.ScrollBarThickness = 0
    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0, 3); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Bottom container
    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1, -16, 0, 76); toggleBtnContainer.Position = UDim2.new(0, 8, 1, -84)
    toggleBtnContainer.BackgroundTransparency = 1

    local customizePriorityBtn = Instance.new("TextButton", toggleBtnContainer)
    customizePriorityBtn.Size = UDim2.new(1, 0, 0, 26); customizePriorityBtn.Position = UDim2.new(0, 0, 0, 0)
    customizePriorityBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26); customizePriorityBtn.BorderSizePixel = 0
    customizePriorityBtn.BackgroundTransparency = 0
    customizePriorityBtn.Text = "CUSTOMIZE PRIORITY"; customizePriorityBtn.Font = Enum.Font.GothamMedium
    customizePriorityBtn.TextSize = 10; customizePriorityBtn.TextColor3 = Theme.Accent1
    Instance.new("UICorner", customizePriorityBtn).CornerRadius = UDim.new(0, 6)
    local _cpStroke = Instance.new("UIStroke", customizePriorityBtn)
    _cpStroke.Color = Theme.Accent1; _cpStroke.Thickness = 1; _cpStroke.Transparency = 0.55
    customizePriorityBtn.Visible = not IS_MOBILE
    customizePriorityBtn.MouseButton1Click:Connect(function()
        if _G._togglePriorityPopup then _G._togglePriorityPopup() end
    end)

    local enableBtn = Instance.new("TextButton", toggleBtnContainer)
    enableBtn.Size = UDim2.new(1, 0, 0, 38); enableBtn.Position = UDim2.new(0, 0, 0, 36)
    enableBtn.BackgroundColor3 = Theme.Accent1; enableBtn.BorderSizePixel = 0
    enableBtn.Text = "ENABLED"; enableBtn.Font = Enum.Font.GothamMedium
    enableBtn.TextSize = 13; enableBtn.TextColor3 = Color3.fromRGB(5, 5, 10)
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 8)

    local function updateUI(enabled, allPets)
        autoStealEnabled = enabled
        enableBtn.Text = enabled and "ENABLED" or "DISABLED"
        enableBtn.BackgroundColor3 = enabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)

        nearestBtn.BackgroundColor3 = stealNearestEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        nearestBtn.TextColor3 = stealNearestEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
        _nStroke.Transparency = stealNearestEnabled and 1 or 0.5

        highestBtn.BackgroundColor3 = stealHighestEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        highestBtn.TextColor3 = stealHighestEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
        _hStroke.Transparency = stealHighestEnabled and 1 or 0.5

        priorityBtn.BackgroundColor3 = stealPriorityEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        priorityBtn.TextColor3 = stealPriorityEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
        _pStroke.Transparency = stealPriorityEnabled and 1 or 0.5

        enableBtn.TextColor3 = enabled and Color3.fromRGB(5, 5, 10) or Theme.TextPrimary

        if selectedTargetUID and allPets then
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then selectedTargetIndex = i; break end
            end
        end

        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            petButtons = {}
            if allPets and #allPets > 0 then
                for i = 1, #allPets do
                    local petData = allPets[i]
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 40); btn.BackgroundColor3 = Theme.Surface
                    btn.BackgroundTransparency = 1
                    btn.Text = ""; btn.Parent = listFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
                    local bStroke = Instance.new("UIStroke", btn)
                    bStroke.Color = Theme.Accent1; bStroke.Thickness = 1; bStroke.Transparency = 1

                    local MUT_COLORS_UI = {
                        Cursed = Color3.fromRGB(200, 0, 0), Gold = Color3.fromRGB(255, 215, 0),
                        Diamond = Color3.fromRGB(0, 255, 255), YinYang = Color3.fromRGB(220, 220, 220),
                        Rainbow = Color3.fromRGB(255, 100, 200), Lava = Color3.fromRGB(255, 100, 20),
                        Candy = Color3.fromRGB(255, 105, 180), Divine = Color3.fromRGB(255, 255, 255)
                    }
                    local hasMut = petData.mutation and petData.mutation ~= "None"
                    local barCol = hasMut and (MUT_COLORS_UI[petData.mutation] or Color3.fromRGB(210, 130, 255)) or Theme.Accent2

                    local vpContainer = Instance.new("Frame", btn)
                    vpContainer.Size = UDim2.new(0, 38, 0, 38)
                    vpContainer.Position = UDim2.new(0, 1, 0.5, -19)
                    vpContainer.BackgroundColor3 = Color3.fromRGB(14, 14, 14)
                    vpContainer.BackgroundTransparency = 0.3
                    vpContainer.BorderSizePixel = 0
                    vpContainer.ClipsDescendants = true
                    Instance.new("UICorner", vpContainer).CornerRadius = UDim.new(0, 5)
                    local vpStroke = Instance.new("UIStroke", vpContainer)
                    vpStroke.Color = barCol; vpStroke.Thickness = 1.5; vpStroke.Transparency = 0.3

                    task.spawn(buildViewport, vpContainer, petData.petName)

                    local rankLabel = Instance.new("TextLabel", btn)
                    rankLabel.Size = UDim2.new(0, 22, 0, 14); rankLabel.Position = UDim2.new(0, 43, 0, 3)
                    rankLabel.BackgroundTransparency = 1; rankLabel.Text = "#"..i
                    rankLabel.Font = Enum.Font.GothamMedium; rankLabel.TextSize = 10
                    rankLabel.TextXAlignment = Enum.TextXAlignment.Left

                    local infoLabel = Instance.new("TextLabel", btn)
                    infoLabel.Size = UDim2.new(1, -46, 0, 16); infoLabel.Position = UDim2.new(0, 43, 0, 15)
                    infoLabel.BackgroundTransparency = 1; infoLabel.RichText = true
                    infoLabel.Text = formatMutationText(petData.mutation).."<font weight='700'>"..petData.petName.."</font>"
                    infoLabel.Font = Enum.Font.GothamMedium; infoLabel.TextSize = 11
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.TextTruncate = Enum.TextTruncate.AtEnd

                    local mpsLabel = Instance.new("TextLabel", btn)
                    mpsLabel.Size = UDim2.new(1, -46, 0, 12); mpsLabel.Position = UDim2.new(0, 43, 0, 3)
                    mpsLabel.BackgroundTransparency = 1
                    mpsLabel.Text = petData.mpsText
                    mpsLabel.Font = Enum.Font.GothamMedium; mpsLabel.TextSize = 9
                    mpsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                    mpsLabel.TextXAlignment = Enum.TextXAlignment.Right; mpsLabel.TextTruncate = Enum.TextTruncate.AtEnd

                    -- Blacklist indicator
                    local ownerPlr = Players:FindFirstChild(petData.owner or "")
                    local ownerBL = ownerPlr and Config.Blacklist and Config.Blacklist[tostring(ownerPlr.UserId)] ~= nil
                    if ownerBL then
                        local blStroke = Instance.new("UIStroke", btn)
                        blStroke.Color = Color3.fromRGB(220, 40, 40)
                        blStroke.Thickness = 2
                        blStroke.Transparency = 0
                        local blBadge = Instance.new("TextLabel", btn)
                        blBadge.Size = UDim2.new(0, 26, 0, 20)
                        blBadge.Position = UDim2.new(1, -29, 0.5, -10)
                        blBadge.BackgroundColor3 = Color3.fromRGB(180, 20, 20)
                        blBadge.BackgroundTransparency = 0
                        blBadge.Text = "BL"
                        blBadge.Font = Enum.Font.GothamBold
                        blBadge.TextSize = 14
                        blBadge.TextColor3 = Color3.fromRGB(255, 180, 180)
                        blBadge.BorderSizePixel = 0
                        Instance.new("UICorner", blBadge).CornerRadius = UDim.new(0, 4)
                        local blBadgeStroke = Instance.new("UIStroke", blBadge)
                        blBadgeStroke.Color = Color3.fromRGB(255, 60, 60)
                        blBadgeStroke.Thickness = 1.5
                        blBadgeStroke.Transparency = 0
                    end

                    petButtons[i] = {button=btn, stroke=bStroke, rank=rankLabel, info=infoLabel, bar=vpStroke, uid=petData.uid}

                    btn.MouseButton1Click:Connect(function()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid
                        stealNearestEnabled = false; stealHighestEnabled = false; stealPriorityEnabled = false
                        Config.StealNearest = false; Config.StealHighest = false; Config.StealPriority = false
                        SaveConfig()
                        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
                    end)
                end
            end
            SharedState.ListNeedsRedraw = false
        end

        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end

        for i, pb in ipairs(petButtons) do
            local sel = (pb.uid == selectedTargetUID)
            pb.stroke.Transparency = sel and 0 or 1
            pb.button.BackgroundColor3 = sel and Theme.SurfaceHighlight or Theme.Surface
            pb.button.BackgroundTransparency = sel and 0.5 or 1
            pb.rank.TextColor3 = sel and Theme.Accent1 or Theme.TextSecondary
            pb.info.TextColor3 = sel and Theme.TextPrimary or Theme.TextSecondary
        end

        local ct = allPets and allPets[selectedTargetIndex]
        SharedState.SelectedPetData = ct
        if enabled then
            targetLabel.Text = ct and string.format("%s (%s)", ct.petName, ct.mpsText) or "Searching..."
        else
            targetLabel.Text = "Disabled"
        end
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end

    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)

    SharedState.UpdateAutoStealUI = function()
        updateUI(autoStealEnabled, get_all_pets())
    end

    enableBtn.MouseButton1Click:Connect(function()
        autoStealEnabled = not autoStealEnabled
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    nearestBtn.MouseButton1Click:Connect(function()
        stealNearestEnabled = not stealNearestEnabled
        if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig(); SharedState.ListNeedsRedraw = true; updateUI(autoStealEnabled, get_all_pets())
    end)

    highestBtn.MouseButton1Click:Connect(function()
        stealHighestEnabled = not stealHighestEnabled
        if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig(); SharedState.ListNeedsRedraw = true; updateUI(autoStealEnabled, get_all_pets())
    end)

    priorityBtn.MouseButton1Click:Connect(function()
        stealPriorityEnabled = not stealPriorityEnabled
        if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        SaveConfig(); SharedState.ListNeedsRedraw = true; updateUI(autoStealEnabled, get_all_pets())
    end)

    local lastAnimalData = {}
    local function getAnimalHash(al)
        if not al then return "" end
        local h = ""
        for slot, d in pairs(al) do if type(d) == "table" then h = h..tostring(slot)..tostring(d.Index)..tostring(d.Mutation) end end
        return h
    end

    local function scanSinglePlot(plot)
        local changed = false
        pcall(function()
            local ch = Synchronizer:Get(plot.Name); if not ch then return end
            local al = ch:Get("AnimalList")
            local hash = getAnimalHash(al)
            if lastAnimalData[plot.Name] == hash then return end
            lastAnimalData[plot.Name] = hash; changed = true
            for i = #allAnimalsCache, 1, -1 do if allAnimalsCache[i].plot == plot.Name then table.remove(allAnimalsCache, i) end end
            local owner = ch:Get("Owner")
            if not owner or not Players:FindFirstChild(owner.Name) then return end
            local ownerName = owner.Name or "Unknown"
            if not al then return end
            for slot, ad in pairs(al) do
                if type(ad) == "table" then
                    local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                    if aInfo then
                        local mut = ad.Mutation or "None"
                        if mut == "Yin Yang" then mut = "YinYang" end
                        local traits = (ad.Traits and #ad.Traits > 0) and table.concat(ad.Traits, ", ") or "None"
                        local gv = AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil)
                        local gt = "$"..NumberUtils:ToString(gv).."/s"
                        table.insert(allAnimalsCache, {
                            name = aInfo.DisplayName or aName, genText = gt, genValue = gv,
                            mutation = mut, traits = traits, owner = ownerName,
                            plot = plot.Name, slot = tostring(slot), uid = plot.Name.."_"..tostring(slot)
                        })
                    end
                end
            end
        end)
        if changed then
            table.sort(allAnimalsCache, function(a, b) return a.genValue > b.genValue end)
            SharedState.ListNeedsRedraw = true
            if not hasShownPriorityAlert and Config.AlertsEnabled then
                task.spawn(function()
                    local foundPriorityPet = nil
                    for i = 1, #PRIORITY_LIST do
                        local searchName = PRIORITY_LIST[i]:lower()
                        for _, pet in ipairs(allAnimalsCache) do
                            if pet.name and pet.name:lower() == searchName then foundPriorityPet = pet; break end
                        end
                        if foundPriorityPet then break end
                    end
                    if foundPriorityPet then
                        local ownerUsername = foundPriorityPet.owner
                        local ownerPlayer = nil
                        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                        if plot then
                            local ok, ch = pcall(function() return Synchronizer:Get(plot.Name) end)
                            if ok and ch then
                                local owner = ch:Get("Owner")
                                if owner then
                                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                                        ownerPlayer = owner; ownerUsername = owner.Name
                                    elseif type(owner) == "table" and owner.Name then
                                        ownerUsername = owner.Name; ownerPlayer = Players:FindFirstChild(owner.Name)
                                    end
                                end
                            end
                        end
                        if not ownerPlayer and ownerUsername then ownerPlayer = Players:FindFirstChild(ownerUsername) end
                        ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                    end
                end)
            end
        end
    end

    local function setupPlotListener(plot)
        local ch, retries = nil, 0
        while not ch and retries < 50 do
            local ok, r = pcall(function() return Synchronizer:Get(plot.Name) end)
            if ok and r then ch = r; break else retries = retries + 1; task.wait(0.1) end
        end
        if not ch then return end
        scanSinglePlot(plot)
        plot.DescendantAdded:Connect(function() task.wait(0.1); scanSinglePlot(plot) end)
        plot.DescendantRemoving:Connect(function() task.wait(0.1); scanSinglePlot(plot) end)
        task.spawn(function() while plot.Parent do task.wait(5); scanSinglePlot(plot) end end)
    end

    local plots = Workspace:WaitForChild("Plots", 8)
    if plots then
        for _, p in ipairs(plots:GetChildren()) do setupPlotListener(p) end
        plots.ChildAdded:Connect(function(p) task.wait(0.5); setupPlotListener(p) end)
        plots.ChildRemoved:Connect(function(p)
            lastAnimalData[p.Name] = nil
            for i = #allAnimalsCache, 1, -1 do if allAnimalsCache[i].plot == p.Name then table.remove(allAnimalsCache, i) end end
            SharedState.ListNeedsRedraw = true
            for uid in pairs(PromptCache) do
                if uid:find(p.Name, 1, true) then PromptCache[uid] = nil end
            end
            for prompt in pairs(StealTimes) do
                if not prompt.Parent then StealTimes[prompt] = nil end
            end
        end)
    end

    local duelBaseHighlights = {}
    local duelBaseBillboards = {}

    local function clearDuelBaseVisuals()
        for _, h in pairs(duelBaseHighlights) do if h and h.Parent then h:Destroy() end end
        duelBaseHighlights = {}
        for _, b in pairs(duelBaseBillboards) do if b and b.Parent then b:Destroy() end end
        duelBaseBillboards = {}
    end

    local function createDuelBaseMarker(plot, sign)
        local plotName = plot.Name
        if duelBaseHighlights[plotName] then return end
        local highlight = Instance.new("Highlight")
        highlight.Name = "DuelBaseHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
        highlight.FillTransparency = 0.7; highlight.OutlineTransparency = 0.3
        highlight.Adornee = plot; highlight.Parent = plot
        duelBaseHighlights[plotName] = highlight
        local bb = Instance.new("BillboardGui")
        bb.Name = "DuelBaseMarker"
        bb.Size = UDim2.new(0, 180, 0, 40)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.ResetOnSpawn = false
        bb.Adornee = sign; bb.Parent = sign
        local bbFrame = Instance.new("Frame", bb)
        bbFrame.Size = UDim2.new(1, 0, 1, 0)
        bbFrame.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        bbFrame.BackgroundTransparency = 0.3; bbFrame.BorderSizePixel = 0
        Instance.new("UICorner", bbFrame).CornerRadius = UDim.new(0, 4)
        local stroke = Instance.new("UIStroke", bbFrame)
        stroke.Color = Color3.fromRGB(255, 0, 0); stroke.Thickness = 2
        local label = Instance.new("TextLabel", bbFrame)
        label.Size = UDim2.new(1, 0, 1, 0); label.BackgroundTransparency = 1
        label.Text = "DUEL BASE"; label.Font = Enum.Font.GothamMedium; label.TextSize = 18
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.TextStrokeTransparency = 0; label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        duelBaseBillboards[plotName] = bb
    end

    task.spawn(function()
        while true do
            task.wait(1)
            if not Config.DuelBaseESP then
                clearDuelBaseVisuals()
            else
                local Plots = Workspace:FindFirstChild("Plots")
                if Plots then
                    for _, plot in ipairs(Plots:GetChildren()) do
                        local sign = plot:FindFirstChild("PlotSign")
                        if sign then
                            local textLabel = sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
                            local baseText = textLabel and textLabel.Text or nil
                            if baseText and baseText ~= "Empty Base" then
                                local nickname = baseText:match("^(.-)'") or baseText
                                local ownerPlayer = nil
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.DisplayName == nickname or p.Name == nickname then ownerPlayer = p; break end
                                end
                                if ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true then
                                    if Config.DuelBaseESP then createDuelBaseMarker(plot, sign) end
                                else
                                    local plotName = plot.Name
                                    if duelBaseHighlights[plotName] then duelBaseHighlights[plotName]:Destroy(); duelBaseHighlights[plotName] = nil end
                                    if duelBaseBillboards[plotName] then duelBaseBillboards[plotName]:Destroy(); duelBaseBillboards[plotName] = nil end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local hasShownPriorityAlert = false

    local function ShowPriorityAlert(brainrotName, genText, mutation, ownerUsername)
        if not Config.AlertsEnabled then return end
        if hasShownPriorityAlert then return end
        local ownerPlayer = ownerUsername and Players:FindFirstChild(ownerUsername) or nil
        local isInDuel = ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true or false
        local duelStatusText = isInDuel and "IN DUEL" or "NOT IN DUEL"
        local duelStatusColor = isInDuel and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        local mutationColors = {
            ["rainbow"] = Color3.fromRGB(255, 0, 255), ["bloodrot"] = Color3.fromRGB(139, 0, 0),
            ["candy"] = Color3.fromRGB(255, 105, 180), ["radioactive"] = Color3.fromRGB(0, 255, 0),
            ["cursed"] = Color3.fromRGB(255, 50, 50), ["gold"] = Color3.fromRGB(255, 215, 0),
            ["diamond"] = Color3.fromRGB(0, 255, 255), ["yinyang"] = Color3.fromRGB(255, 255, 255),
            ["lava"] = Color3.fromRGB(255, 100, 20)
        }
        local normalizedMutation = mutation and mutation:gsub("%s+", ""):lower() or ""
        local color = mutationColors[normalizedMutation] or Color3.fromRGB(0, 170, 255)
        local existing = PlayerGui:FindFirstChild("wxrldzPriorityAlert")
        if existing then existing:Destroy() end
        local alertGui = Instance.new("ScreenGui")
        alertGui.Name = "wxrldzPriorityAlert"; alertGui.ResetOnSpawn = false
        alertGui.DisplayOrder = 999; alertGui.Parent = PlayerGui
        hasShownPriorityAlert = true
        local alertFrame = Instance.new("Frame")
        alertFrame.Size = UDim2.new(0, 400, 0, 60)
        alertFrame.Position = UDim2.new(0.5, 0, 0, -70)
        alertFrame.AnchorPoint = Vector2.new(0.5, 0)
        alertFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
        alertFrame.BackgroundTransparency = 0; alertFrame.BorderSizePixel = 0
        alertFrame.Parent = alertGui
        Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 4)
        local glowStroke = Instance.new("UIStroke", alertFrame)
        glowStroke.Name = "GlowStroke"; glowStroke.Thickness = 3
        glowStroke.Color = color; glowStroke.Transparency = 1
        local innerGlow = Instance.new("Frame", alertFrame)
        innerGlow.Name = "InnerGlow"
        innerGlow.Size = UDim2.new(1, 6, 1, 6); innerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        innerGlow.AnchorPoint = Vector2.new(0.5, 0.5); innerGlow.BackgroundColor3 = color
        innerGlow.BackgroundTransparency = 1; innerGlow.ZIndex = 0
        Instance.new("UICorner", innerGlow).CornerRadius = UDim.new(0, 4)
        local accentBar = Instance.new("Frame", alertFrame)
        accentBar.Size = UDim2.new(0, 4, 1, -12); accentBar.Position = UDim2.new(0, 8, 0, 6)
        accentBar.BackgroundColor3 = color; accentBar.BorderSizePixel = 0
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 4)
        local nameLabel = Instance.new("TextLabel", alertFrame)
        nameLabel.Size = UDim2.new(1, -30, 0.55, 0); nameLabel.Position = UDim2.new(0, 20, 0, 6)
        nameLabel.BackgroundTransparency = 1; nameLabel.Text = brainrotName.." - "..genText
        nameLabel.Font = Enum.Font.GothamMedium; nameLabel.TextSize = 18
        nameLabel.TextColor3 = color; nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextStrokeTransparency = 0; nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        local genLabel = Instance.new("TextLabel", alertFrame)
        genLabel.Size = UDim2.new(1, -30, 0.4, 0); genLabel.Position = UDim2.new(0, 20, 0.55, 0)
        genLabel.BackgroundTransparency = 1; genLabel.Text = duelStatusText
        genLabel.Font = Enum.Font.GothamMedium; genLabel.TextSize = 17
        genLabel.TextColor3 = duelStatusColor; genLabel.TextXAlignment = Enum.TextXAlignment.Center
        genLabel.TextStrokeColor3 = color; genLabel.TextStrokeTransparency = 1
        TweenService:Create(alertFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 15)
        }):Play()
        if Config.AlertSoundID and Config.AlertSoundID ~= "" then
            local sound = Instance.new("Sound")
            sound.SoundId = Config.AlertSoundID; sound.Volume = 0.5
            sound.Parent = alertFrame; sound:Play()
            TweenService:Create(glowStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
            TweenService:Create(innerGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.85}):Play()
            task.delay(0.4, function()
                TweenService:Create(glowStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.6}):Play()
                TweenService:Create(innerGlow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 1}):Play()
            end)
            sound.Ended:Connect(function() sound:Destroy() end)
        end
        task.delay(4, function()
            TweenService:Create(alertFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -70)
            }):Play()
            task.wait(0.35); alertGui:Destroy()
        end)
    end

    task.spawn(function()
        task.wait(0.5)
        while true do
            task.wait(0.5)
            if not hasShownPriorityAlert and Config.AlertsEnabled and #allAnimalsCache > 0 then
                local foundPriorityPet = nil
                for i = 1, #PRIORITY_LIST do
                    local searchName = PRIORITY_LIST[i]:lower()
                    for _, pet in ipairs(allAnimalsCache) do
                        if pet.name and pet.name:lower() == searchName then foundPriorityPet = pet; break end
                    end
                    if foundPriorityPet then break end
                end
                if foundPriorityPet then
                    local ownerUsername = foundPriorityPet.owner
                    local ownerPlayer = nil
                    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                    if plot then
                        local ok, ch = pcall(function() return Synchronizer:Get(plot.Name) end)
                        if ok and ch then
                            local owner = ch:Get("Owner")
                            if owner then
                                if typeof(owner) == "Instance" and owner:IsA("Player") then
                                    ownerPlayer = owner; ownerUsername = owner.Name
                                elseif type(owner) == "table" and owner.Name then
                                    ownerUsername = owner.Name; ownerPlayer = Players:FindFirstChild(owner.Name)
                                end
                            end
                        end
                    end
                    if not ownerPlayer and ownerUsername then ownerPlayer = Players:FindFirstChild(ownerUsername) end
                    ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            if autoStealEnabled then
                local pets = get_all_pets()
                if #pets > 0 then
                    local function applySelection(newIndex)
                        if newIndex and newIndex >= 1 and newIndex <= #pets and selectedTargetIndex ~= newIndex then
                            selectedTargetIndex = newIndex
                            selectedTargetUID = pets[newIndex].uid
                            SharedState.ListNeedsRedraw = false
                            updateUI(autoStealEnabled, pets)
                        end
                    end
                    if stealPriorityEnabled then
                        local foundPrioIndex = nil
                        for _, pName in ipairs(PRIORITY_LIST) do
                            local searchName = pName:lower()
                            for i, p in ipairs(pets) do
                                if p.petName and p.petName:lower() == searchName and p.owner ~= LocalPlayer.Name then foundPrioIndex = i; break end
                            end
                            if foundPrioIndex then break end
                        end
                        if not foundPrioIndex then
                            for i, p in ipairs(pets) do
                                if p.owner ~= LocalPlayer.Name then foundPrioIndex = i; break end
                            end
                        end
                        applySelection(foundPrioIndex or 1)
                    elseif stealNearestEnabled then
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bestIndex, bestDist = nil, math.huge
                            for i, p in ipairs(pets) do
                                local targetPart = p.animalData and findAdorneeGlobal(p.animalData)
                                if targetPart and targetPart:IsA("BasePart") then
                                    local d = (hrp.Position - targetPart.Position).Magnitude
                                    if d < bestDist then bestDist = d; bestIndex = i end
                                end
                            end
                            applySelection(bestIndex or 1)
                        else
                            applySelection(1)
                        end
                    elseif stealHighestEnabled then
                        applySelection(1)
                    end
                end
            end
        end
    end)

    local INSTANT_STEAL_RADIUS = 60
    local INSTANT_STEAL_COOLDOWN = 0
    local lastInstantStealTime = 0
    local function isMyPlot_Instant(plotName)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(plotName)
        if not plot then return false end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return false end
        local yb = sign:FindFirstChild("YourBase")
        return yb and yb:IsA("BillboardGui") and yb.Enabled
    end
    local function findNearestPrompt_Instant()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, math.huge end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil, math.huge end
        local bestPrompt, bestDist = nil, math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            if isMyPlot_Instant(plot.Name) then continue end
            local plotDist = math.huge
            pcall(function() plotDist = (plot:GetPivot().Position - hrp.Position).Magnitude end)
            if plotDist > INSTANT_STEAL_RADIUS + 40 then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, pod in ipairs(podiums:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if not spawn then continue end
                local dist = (spawn.Position - hrp.Position).Magnitude
                if dist > INSTANT_STEAL_RADIUS or dist >= bestDist then continue end
                local att = spawn:FindFirstChild("PromptAttachment")
                if not att then continue end
                local prompt = att:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.Parent and prompt.Enabled then
                    bestPrompt = prompt; bestDist = dist
                end
            end
        end
        return bestPrompt, bestDist
    end
    local function executeInstantSteal(prompt)
        if not prompt then return end
        local now = os.clock()
        if now - lastInstantStealTime < INSTANT_STEAL_COOLDOWN then return end
        lastInstantStealTime = now
        instantSteal(prompt)
    end

    SharedState.PauseAutoSteal = function()
        _autoStealPaused = true
    end

    SharedState.ResumeAutoSteal = function()
        _autoStealPaused = false
        instantStealReady = true
        instantStealDidInit = true
    end

    RunService.Heartbeat:Connect(function()
        if not autoStealEnabled or _autoStealPaused then return end
        if instantStealEnabled then
            if not instantStealDidInit then
                instantStealDidInit = true
                task.spawn(function()
                    if not game:IsLoaded() then game.Loaded:Wait() end
                    task.wait(0.5)
                    instantStealReady = true
                end)
            end
            if instantStealReady then
                if stealNearestEnabled then
                    local prompt, dist = findNearestPrompt_Instant()
                    if prompt and dist <= INSTANT_STEAL_RADIUS then executeInstantSteal(prompt) end
                else
                    local pets = get_all_pets()
                    if #pets > 0 then
                        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
                        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
                        local tp = pets[selectedTargetIndex]
                        if tp and not isMyBaseAnimal(tp.animalData) then
                            local pr = PromptCache[tp.uid]
                            if not pr or not pr.Parent then pr = findPromptForAnimal(tp.animalData) end
                            if pr then executeInstantSteal(pr) end
                        end
                    end
                end
            end
            return
        end

        local pets = get_all_pets()
        if #pets == 0 then return end
        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end

        local tp = pets[selectedTargetIndex]
        if not tp or isMyBaseAnimal(tp.animalData) then return end

        local pr = PromptCache[tp.uid]
        if not pr or not pr.Parent then pr = findPromptForAnimal(tp.animalData) end
        if not pr then return end

        executeSteal(pr)
    end)

    SharedState.FireStealOnTarget = function(animalData)
        if not animalData then return false end
        local pr = PromptCache[animalData.uid]
        if not pr or not pr.Parent then pr = findPromptForAnimal(animalData) end
        if pr then instantSteal(pr); return true end
        return false
    end

    SharedState.InstantStealToggleFunc = function()
        instantStealEnabled = not instantStealEnabled
        if not instantStealEnabled then
            instantStealReady = false
            instantStealDidInit = false
        end
        Config.InstantSteal = instantStealEnabled
        SaveConfig()
        if SharedState._isUpdateBtn then SharedState._isUpdateBtn() end
    end

    task.spawn(function() while task.wait(0.5) do updateUI(autoStealEnabled, get_all_pets()) end end)
    task.delay(1, function() SharedState.ListNeedsRedraw = true; updateUI(autoStealEnabled, get_all_pets()) end)
    task.spawn(function() while true do SharedState.AllAnimalsCache = allAnimalsCache; task.wait(0.5) end end)

    local beamFolder = Instance.new("Folder", Workspace)
    beamFolder.Name = "wxrldzTracers"
    local currentBeam, currentAtt0, currentAtt1 = nil, nil, nil

    local function updateTracer()
        if not autoStealEnabled or not Config.TracerEnabled then
            if currentBeam then currentBeam:Destroy(); currentBeam = nil end
            if currentAtt0 then currentAtt0:Destroy(); currentAtt0 = nil end
            if currentAtt1 then currentAtt1:Destroy(); currentAtt1 = nil end
            return
        end
        local best, targetPart = nil, nil
        if Config.LineToBase then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local plotsList = Workspace:FindFirstChild("Plots")
                if plotsList then
                    for _, plot in ipairs(plotsList:GetChildren()) do
                        local ok, ch = pcall(function() return Synchronizer:Get(plot.Name) end)
                        if ok and ch then
                            local owner = ch:Get("Owner")
                            local ownerId = (typeof(owner) == "Instance" and owner:IsA("Player")) and owner.UserId or (type(owner) == "table" and owner.UserId)
                            if ownerId == LocalPlayer.UserId then
                                local plotPos = plot:FindFirstChild("Base") and plot.Base:FindFirstChild("Spawn")
                                if plotPos and plotPos:IsA("BasePart") then targetPart = plotPos; break end
                            end
                        end
                    end
                end
            end
        else
            local pets = get_all_pets()
            if #pets == 0 then if currentBeam then currentBeam.Enabled = false end; return end
            if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
            if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
            best = pets[selectedTargetIndex] or pets[1]
            targetPart = findAdorneeGlobal(best.animalData)
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and targetPart then
            if not currentAtt0 or currentAtt0.Parent ~= hrp then
                if currentAtt0 then currentAtt0:Destroy() end
                currentAtt0 = Instance.new("Attachment", hrp)
            end
            if not currentAtt1 or currentAtt1.Parent ~= targetPart then
                if currentAtt1 then currentAtt1:Destroy() end
                currentAtt1 = Instance.new("Attachment", targetPart)
            end
            if not currentBeam then
                currentBeam = Instance.new("Beam", beamFolder)
                currentBeam.FaceCamera = true; currentBeam.Width0 = 0.8; currentBeam.Width1 = 0.8
                currentBeam.TextureMode = Enum.TextureMode.Static; currentBeam.TextureSpeed = 3
            end
            currentBeam.Attachment0 = currentAtt0; currentBeam.Attachment1 = currentAtt1; currentBeam.Enabled = true
            local MUT_COLORS_TRACE = {
                Cursed = Color3.fromRGB(200, 0, 0), Gold = Color3.fromRGB(255, 215, 0),
                Diamond = Color3.fromRGB(0, 255, 255), YinYang = Color3.fromRGB(220, 220, 220),
                Rainbow = Color3.fromRGB(255, 100, 200), Lava = Color3.fromRGB(255, 100, 20),
                Candy = Color3.fromRGB(255, 105, 180), Divine = Color3.fromRGB(255, 255, 255)
            }
            local col = Config.LineToBase and Theme.Accent2 or ((best and best.mutation and MUT_COLORS_TRACE[best.mutation]) or Theme.Accent1)
            currentBeam.Color = ColorSequence.new(col)
        else
            if currentBeam then currentBeam.Enabled = false end
        end
    end

    RunService.Heartbeat:Connect(updateTracer)
end)

task.spawn(function()
    local COOLDOWNS = {
        rocket = 120, ragdoll = 30, balloon = 30, inverse = 60,
        nightvision = 60, jail = 60, tiny = 60, jumpscare = 60, morph = 60
    }
    local ALL_COMMANDS = {
        "balloon", "inverse", "jail", "jumpscare", "morph",
        "nightvision", "ragdoll", "rocket", "tiny"
    }

    local activeCooldowns = {}
    SharedState.AdminButtonCache = {}
    SharedState.BalloonedPlayers = SharedState.BalloonedPlayers or {}

    local playerRows = {}
    local playerRowsByUserId = {}
    local addingPlayers = {}

    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "wxrldzAdminPanel"
    adminGui.ResetOnSpawn = false
    adminGui.DisplayOrder = 999
    adminGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.ClipsDescendants = false
    frame.Size = UDim2.new(0, 340, 0, 162)
    frame.Position = UDim2.new(Config.Positions.AdminPanel.X, 0, Config.Positions.AdminPanel.Y, 0)
    frame.BorderSizePixel = 0
    frame.BackgroundColor3 = Color3.fromRGB(4, 5, 11)
    frame.BackgroundTransparency = 0.04
    frame.Active = not IS_MOBILE
    frame.Parent = adminGui

    local _adminSizeLimit = Instance.new("UISizeConstraint", frame)
    _adminSizeLimit.MinSize = Vector2.new(340, 162)
    _adminSizeLimit.MaxSize = Vector2.new(340, 580)
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local _frameStroke = Instance.new("UIStroke", frame)
    _frameStroke.Color = Color3.fromRGB(0, 200, 255)
    _frameStroke.Thickness = 1
    _frameStroke.Transparency = 0.72
    _frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local adminUIScale = Instance.new("UIScale", frame)
    adminUIScale.Scale = IS_MOBILE and math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1) or math.clamp(Config.AdminPanelScale or 1.0, 0.7, 1.2)
    if IS_MOBILE then SharedState.MobileScaleObjects[frame] = adminUIScale end
    RegisterClamp(frame)
    adminGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if adminGui.Enabled then ClampFrameToScreen(frame) end
    end)

    -- Subtle dot pattern background
    do local _dots={{0.15,0.07},{0.72,0.04},{0.38,0.17},{0.87,0.13},{0.06,0.41},{0.94,0.37},{0.28,0.61},{0.76,0.57},{0.52,0.78},{0.11,0.87},{0.89,0.83},{0.46,0.94}} for _,d in ipairs(_dots) do local _dt=Instance.new("Frame",frame); _dt.Size=UDim2.new(0,2,0,2); _dt.Position=UDim2.new(d[1],0,d[2],0); _dt.AnchorPoint=Vector2.new(0.5,0.5); _dt.BackgroundColor3=Color3.fromRGB(0,180,255); _dt.BackgroundTransparency=0.78; _dt.BorderSizePixel=0; _dt.ZIndex=1; Instance.new("UICorner",_dt).CornerRadius=UDim.new(1,0); TweenService:Create(_dt,TweenInfo.new(2+(_dt.Position.X.Scale*2.5),Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=0.95}):Play() end end

    -- Left accent bar (animated glow)
    local _leftBar = Instance.new("Frame", frame)
    _leftBar.Size = UDim2.new(0, 4, 1, -16); _leftBar.Position = UDim2.new(0, 0, 0, 8)
    _leftBar.BackgroundColor3 = Theme.Accent1; _leftBar.BorderSizePixel = 0; _leftBar.ZIndex = 5
    Instance.new("UICorner", _leftBar).CornerRadius = UDim.new(1, 0)
    SharedState.AdminAccentBar = _leftBar
    TweenService:Create(_leftBar, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = Theme.Accent2}):Play()

    -- Header (48px tall)
    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 48)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundTransparency = 1

    do
        local _dragStartPos, _dragStartAbs, _dragging, _dragInput
        header.InputBegan:Connect(function(input)
            if Config.UILocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                _dragging = true
                _dragStartPos = input.Position
                _dragStartAbs = frame.AbsolutePosition
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        _dragging = false
                        local parentSize = frame.Parent.AbsoluteSize
                        Config.Positions.AdminPanel = {
                            X = frame.AbsolutePosition.X / parentSize.X,
                            Y = frame.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end)
            end
        end)
        header.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                _dragInput = input
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if input == _dragInput and _dragging then
                local delta = input.Position - _dragStartPos
                local vp = workspace.CurrentCamera.ViewportSize
                local fs = frame.AbsoluteSize
                local newX = math.clamp(_dragStartAbs.X + delta.X, 0, vp.X - fs.X)
                local newY = math.clamp(_dragStartAbs.Y + delta.Y, 0, vp.Y - fs.Y)
                frame.Position = UDim2.new(0, newX, 0, newY)
            end
        end)
    end

    do
        local _rh = Instance.new("TextButton", header)
        _rh.ZIndex = 10
        _rh.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
        _rh.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        _rh.TextSize = 11; _rh.Size = UDim2.new(0, 22, 0, 22)
        _rh.TextColor3 = Color3.fromRGB(0, 200, 255); _rh.Text = "↕"
        _rh.Position = UDim2.new(1, -26, 0.5, -11)
        Instance.new("UICorner", _rh).CornerRadius = UDim.new(1, 0)
        local _rsStroke = Instance.new("UIStroke", _rh)
        _rsStroke.Color = Color3.fromRGB(0, 200, 255); _rsStroke.Thickness = 1; _rsStroke.Transparency = 0.6
        local _rsStartY, _rsStartScale
        _rh.InputBegan:Connect(function(input)
            if Config.UILocked then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                _rsStartY = input.Position.Y; _rsStartScale = adminUIScale.Scale
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not _rsStartY then return end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                adminUIScale.Scale = math.clamp(_rsStartScale + (input.Position.Y - _rsStartY) / 250, 0.7, 1.2)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if _rsStartY then
                    Config.AdminPanelScale = adminUIScale.Scale; SaveConfig()
                end
                _rsStartY = nil
            end
        end)
    end

    -- Title: ◈ prefix + ADMIN (white) + PANEL (cyan)
    local _iconPfx = Instance.new("TextLabel", header)
    _iconPfx.Size = UDim2.new(0, 20, 1, 0); _iconPfx.Position = UDim2.new(0, 10, 0, 0)
    _iconPfx.BackgroundTransparency = 1; _iconPfx.Text = "◈"
    _iconPfx.Font = Enum.Font.GothamBold; _iconPfx.TextSize = 14
    _iconPfx.TextColor3 = Theme.Accent1
    SharedState.AdminIconPfx = _iconPfx
    TweenService:Create(_iconPfx, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = Theme.Accent2}):Play()

    local _titleA = Instance.new("TextLabel", header)
    _titleA.Font = Enum.Font.GothamBold; _titleA.TextXAlignment = Enum.TextXAlignment.Left
    _titleA.TextSize = 14; _titleA.Size = UDim2.new(0, 54, 1, 0)
    _titleA.Text = "ADMIN"; _titleA.TextColor3 = Color3.fromRGB(210, 215, 235)
    _titleA.BackgroundTransparency = 1; _titleA.Position = UDim2.new(0, 30, 0, 0)

    local _titleB = Instance.new("TextLabel", header)
    _titleB.Font = Enum.Font.GothamBold; _titleB.TextXAlignment = Enum.TextXAlignment.Left
    _titleB.TextSize = 14; _titleB.Size = UDim2.new(0, 60, 1, 0)
    _titleB.Text = "PANEL"; _titleB.TextColor3 = Color3.fromRGB(0, 200, 255)
    _titleB.BackgroundTransparency = 1; _titleB.Position = UDim2.new(0, 82, 0, 0)

    -- REFRESH: circular icon button
    local refreshBtn = Instance.new("TextButton", header)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(10, 12, 20)
    refreshBtn.Font = Enum.Font.GothamMedium; refreshBtn.TextSize = 16
    refreshBtn.Size = UDim2.new(0, 28, 0, 28)
    refreshBtn.TextColor3 = Color3.fromRGB(0, 200, 255); refreshBtn.Text = "↺"
    refreshBtn.Position = UDim2.new(1, -62, 0.5, -14)
    refreshBtn.BorderSizePixel = 0; refreshBtn.AutoButtonColor = false
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(1, 0)
    local refreshStroke = Instance.new("UIStroke", refreshBtn)
    refreshStroke.Color = Color3.fromRGB(0, 200, 255); refreshStroke.Transparency = 0.55; refreshStroke.Thickness = 1
    refreshBtn.MouseEnter:Connect(function() refreshBtn.BackgroundColor3 = Theme.Accent1; refreshBtn.TextColor3 = Color3.fromRGB(5, 5, 10); refreshStroke.Transparency = 1 end)
    refreshBtn.MouseLeave:Connect(function() refreshBtn.BackgroundColor3 = Color3.fromRGB(10, 12, 20); refreshBtn.TextColor3 = Theme.Accent1; refreshStroke.Transparency = 0.55 end)

    -- Header bottom separator
    local _hSep = Instance.new("Frame", frame)
    _hSep.Size = UDim2.new(1, -14, 0, 1); _hSep.Position = UDim2.new(0, 7, 0, 48)
    _hSep.BackgroundColor3 = Color3.fromRGB(14, 16, 26); _hSep.BorderSizePixel = 0

    -- Segmented control card: [◉ PROX] | [⊕ CLICK] | [⚡ SPAM]
    local ctrlRow = Instance.new("Frame", frame)
    ctrlRow.Size = UDim2.new(1, -16, 0, 30); ctrlRow.Position = UDim2.new(0, 8, 0, 55)
    ctrlRow.BackgroundColor3 = Color3.fromRGB(9, 10, 17); ctrlRow.BorderSizePixel = 0
    Instance.new("UICorner", ctrlRow).CornerRadius = UDim.new(0, 7)
    local _ctrlStr = Instance.new("UIStroke", ctrlRow)
    _ctrlStr.Color = Color3.fromRGB(20, 24, 40); _ctrlStr.Thickness = 1; _ctrlStr.Transparency = 0

    local _cdiv1 = Instance.new("Frame", ctrlRow); _cdiv1.Size = UDim2.new(0,1,0.6,0); _cdiv1.Position = UDim2.new(0.333,0,0.2,0); _cdiv1.BackgroundColor3 = Color3.fromRGB(22,26,42); _cdiv1.BorderSizePixel = 0
    local _cdiv2 = Instance.new("Frame", ctrlRow); _cdiv2.Size = UDim2.new(0,1,0.6,0); _cdiv2.Position = UDim2.new(0.666,0,0.2,0); _cdiv2.BackgroundColor3 = Color3.fromRGB(22,26,42); _cdiv2.BorderSizePixel = 0

    local proxBtn = Instance.new("TextButton", ctrlRow)
    proxBtn.Name = "ProximityAPButton"
    proxBtn.Size = UDim2.new(0.333, 0, 1, 0); proxBtn.Position = UDim2.new(0, 0, 0, 0)
    proxBtn.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Color3.fromRGB(9, 10, 17)
    proxBtn.BackgroundTransparency = ProximityAPActive and 0 or 1
    proxBtn.Font = Enum.Font.GothamMedium; proxBtn.TextSize = 9
    proxBtn.TextColor3 = ProximityAPActive and Color3.fromRGB(4, 4, 10) or Theme.Accent1
    proxBtn.Text = "◉ PROX"; proxBtn.BorderSizePixel = 0; proxBtn.AutoButtonColor = false
    Instance.new("UICorner", proxBtn).CornerRadius = UDim.new(0, 7)
    local proxBtnStroke = Instance.new("UIStroke", proxBtn); proxBtnStroke.Thickness = 0
    SharedState.ProximityAPButton = proxBtn
    SharedState.ProximityAPButtonStroke = proxBtnStroke
    SharedState.AdminProxBtn = proxBtn

    local clickAPBtn = Instance.new("TextButton", ctrlRow)
    clickAPBtn.Size = UDim2.new(0.333, 0, 1, 0); clickAPBtn.Position = UDim2.new(0.333, 0, 0, 0)
    clickAPBtn.BackgroundColor3 = Config.ClickToAP and Theme.Accent1 or Color3.fromRGB(9, 10, 17)
    clickAPBtn.BackgroundTransparency = Config.ClickToAP and 0 or 1
    clickAPBtn.Font = Enum.Font.GothamMedium; clickAPBtn.TextSize = 9
    clickAPBtn.TextColor3 = Config.ClickToAP and Color3.fromRGB(4, 4, 10) or Theme.Accent1
    clickAPBtn.Text = "⊕ CLICK"; clickAPBtn.BorderSizePixel = 0; clickAPBtn.AutoButtonColor = false
    Instance.new("UICorner", clickAPBtn).CornerRadius = UDim.new(0, 7)
    local clickAPBtnStroke = Instance.new("UIStroke", clickAPBtn); clickAPBtnStroke.Thickness = 0
    local function updateClickAPButton()
        clickAPBtn.BackgroundColor3 = Config.ClickToAP and Theme.Accent1 or Color3.fromRGB(9, 10, 17)
        clickAPBtn.BackgroundTransparency = Config.ClickToAP and 0 or 1
        clickAPBtn.TextColor3 = Config.ClickToAP and Color3.fromRGB(4, 4, 10) or Theme.Accent1
    end
    SharedState.UpdateClickAPButton = updateClickAPButton
    clickAPBtn.MouseButton1Click:Connect(function()
        Config.ClickToAP = not Config.ClickToAP; SaveConfig(); updateClickAPButton()
        ShowNotification("CLICK TO AP", Config.ClickToAP and "ENABLED" or "DISABLED")
    end)

    local spamBaseBtn = Instance.new("TextButton", ctrlRow)
    spamBaseBtn.Size = UDim2.new(0.334, 0, 1, 0); spamBaseBtn.Position = UDim2.new(0.666, 0, 0, 0)
    spamBaseBtn.BackgroundColor3 = Color3.fromRGB(9, 10, 17); spamBaseBtn.BackgroundTransparency = 1
    spamBaseBtn.Font = Enum.Font.GothamMedium; spamBaseBtn.TextSize = 9
    spamBaseBtn.TextColor3 = Color3.fromRGB(175, 135, 255); spamBaseBtn.Text = "⚡ SPAM"
    spamBaseBtn.BorderSizePixel = 0; spamBaseBtn.AutoButtonColor = false
    Instance.new("UICorner", spamBaseBtn).CornerRadius = UDim.new(0, 7)
    local _spamStroke = Instance.new("UIStroke", spamBaseBtn); _spamStroke.Thickness = 0

    -- Range slider
    local sliderRow = Instance.new("Frame", frame)
    sliderRow.Size = UDim2.new(1, -16, 0, 26); sliderRow.Position = UDim2.new(0, 8, 0, 91)
    sliderRow.BackgroundColor3 = Color3.fromRGB(8, 9, 16); sliderRow.BorderSizePixel = 0
    Instance.new("UICorner", sliderRow).CornerRadius = UDim.new(0, 7)
    local _slrStr = Instance.new("UIStroke", sliderRow)
    _slrStr.Color = Color3.fromRGB(18, 22, 36); _slrStr.Thickness = 1; _slrStr.Transparency = 0

    local _sliderLabel = Instance.new("TextLabel", sliderRow)
    _sliderLabel.Size = UDim2.new(0, 58, 1, 0); _sliderLabel.Position = UDim2.new(0, 8, 0, 0)
    _sliderLabel.BackgroundTransparency = 1; _sliderLabel.Text = "RANGE"
    _sliderLabel.Font = Enum.Font.GothamMedium; _sliderLabel.TextSize = 9
    _sliderLabel.TextColor3 = Color3.fromRGB(70, 80, 120); _sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

    local proxSliderBg = Instance.new("Frame", sliderRow)
    proxSliderBg.Size = UDim2.new(1, -88, 0, 3); proxSliderBg.Position = UDim2.new(0, 68, 0.5, -1)
    proxSliderBg.BackgroundColor3 = Color3.fromRGB(18, 22, 38); proxSliderBg.BorderSizePixel = 0
    Instance.new("UICorner", proxSliderBg).CornerRadius = UDim.new(1, 0)
    local proxFill = Instance.new("Frame", proxSliderBg)
    proxFill.BackgroundColor3 = Theme.Accent1; proxFill.Size = UDim2.new(0, 0, 1, 0); proxFill.BorderSizePixel = 0
    Instance.new("UICorner", proxFill).CornerRadius = UDim.new(1, 0)
    local proxKnob = Instance.new("Frame", proxSliderBg)
    proxKnob.AnchorPoint = Vector2.new(0.5, 0.5); proxKnob.Size = UDim2.new(0, 13, 0, 13)
    proxKnob.Position = UDim2.new(0, 0, 0.5, 0); proxKnob.BackgroundColor3 = Theme.Accent1; proxKnob.BorderSizePixel = 0
    Instance.new("UICorner", proxKnob).CornerRadius = UDim.new(1, 0)
    local _kStr = Instance.new("UIStroke", proxKnob); _kStr.Color = Color3.fromRGB(255,255,255); _kStr.Thickness = 1; _kStr.Transparency = 0.7

    local _proxValLabel = Instance.new("TextLabel", sliderRow)
    _proxValLabel.Size = UDim2.new(0, 28, 1, 0); _proxValLabel.Position = UDim2.new(1, -30, 0, 0)
    _proxValLabel.BackgroundTransparency = 1; _proxValLabel.Font = Enum.Font.GothamMedium
    _proxValLabel.TextSize = 9; _proxValLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
    _proxValLabel.TextXAlignment = Enum.TextXAlignment.Right

    local function updateProxSlider(val)
        local min, max = 5, 50
        val = math.clamp(val, min, max)
        Config.ProximityRange = val; SaveConfig()
        local pct = (val - min) / (max - min)
        proxFill.Size = UDim2.new(pct, 0, 1, 0)
        proxKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        _proxValLabel.Text = math.floor(val)
        ShowNotification("PROXIMITY RANGE", string.format("%.1f", val) .. " studs")
    end
    updateProxSlider(Config.ProximityRange)

    local pDragging = false
    proxSliderBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pDragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            pDragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if pDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = i.Position.X
            local r = proxSliderBg.AbsolutePosition.X
            local w = proxSliderBg.AbsoluteSize.X
            local p = (x - r) / w
            updateProxSlider(5 + (p * 45))
        end
    end)

    local proxViz = nil
    local function updateProxViz()
        if ProximityAPActive then
            if not proxViz then
                proxViz = Instance.new("Part")
                proxViz.Name = "wxrldzProxViz"
                proxViz.Anchored = true; proxViz.CanCollide = false
                proxViz.Shape = Enum.PartType.Cylinder
                proxViz.Color = Theme.Accent1; proxViz.Transparency = 0.6
                proxViz.CastShadow = false
                proxViz.Parent = Workspace
            end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                proxViz.Size = Vector3.new(0.5, Config.ProximityRange * 2, Config.ProximityRange * 2)
                proxViz.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
            end
        else
            if proxViz then proxViz:Destroy(); proxViz = nil end
        end
    end
    RunService.Heartbeat:Connect(updateProxViz)

    local function updateProximityAPButton()
        if SharedState.ProximityAPButton then
            SharedState.ProximityAPButton.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Color3.fromRGB(9, 10, 17)
            SharedState.ProximityAPButton.BackgroundTransparency = ProximityAPActive and 0 or 1
            SharedState.ProximityAPButton.TextColor3 = ProximityAPActive and Color3.fromRGB(4, 4, 10) or Theme.Accent1
        end
    end
    SharedState.updateProximityAPButton = updateProximityAPButton

    proxBtn.MouseButton1Click:Connect(function()
        ProximityAPActive = not ProximityAPActive
        updateProximityAPButton()
        ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
    end)

    -- Tab bar (sliding pill style)
    local adminCurrentTab = "Players"
    local tabBg = Instance.new("Frame", frame)
    tabBg.Size = UDim2.new(1, -16, 0, 30); tabBg.Position = UDim2.new(0, 8, 0, 123)
    tabBg.BackgroundColor3 = Color3.fromRGB(8, 9, 16); tabBg.BorderSizePixel = 0
    Instance.new("UICorner", tabBg).CornerRadius = UDim.new(0, 8)
    local _tabStr = Instance.new("UIStroke", tabBg)
    _tabStr.Color = Color3.fromRGB(18, 22, 36); _tabStr.Thickness = 1; _tabStr.Transparency = 0

    local _tabPill = Instance.new("Frame", tabBg)
    _tabPill.Size = UDim2.new(0.5, -4, 1, -6); _tabPill.Position = UDim2.new(0, 3, 0, 3)
    _tabPill.BackgroundColor3 = Theme.Accent1; _tabPill.BackgroundTransparency = 0.82; _tabPill.BorderSizePixel = 0
    Instance.new("UICorner", _tabPill).CornerRadius = UDim.new(0, 6)
    local _tpStr = Instance.new("UIStroke", _tabPill)
    _tpStr.Color = Color3.fromRGB(0, 200, 255); _tpStr.Thickness = 1; _tpStr.Transparency = 0.45

    local playersTabBtn = Instance.new("TextButton", tabBg)
    playersTabBtn.Size = UDim2.new(0.5, 0, 1, 0); playersTabBtn.Position = UDim2.new(0, 0, 0, 0)
    playersTabBtn.BackgroundTransparency = 1; playersTabBtn.Text = "PLAYERS"
    playersTabBtn.Font = Enum.Font.GothamMedium; playersTabBtn.TextSize = 10
    playersTabBtn.TextColor3 = Color3.fromRGB(0, 200, 255); playersTabBtn.BorderSizePixel = 0

    local blacklistTabBtn = Instance.new("TextButton", tabBg)
    blacklistTabBtn.Size = UDim2.new(0.5, 0, 1, 0); blacklistTabBtn.Position = UDim2.new(0.5, 0, 0, 0)
    blacklistTabBtn.BackgroundTransparency = 1; blacklistTabBtn.Text = "BLACKLISTED"
    blacklistTabBtn.Font = Enum.Font.GothamMedium; blacklistTabBtn.TextSize = 10
    blacklistTabBtn.TextColor3 = Color3.fromRGB(50, 55, 85); blacklistTabBtn.BorderSizePixel = 0

    local _listScaleSteps = {0.55, 0.70, 0.85, 1.0}
    local _listScaleVal = _listScaleSteps[math.clamp(Config.AdminListSize or 4, 1, 4)]

    local listFrame = Instance.new("Frame", frame)
    listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0
    listFrame.Size = UDim2.new(1, -16, 0, 0)
    listFrame.AutomaticSize = Enum.AutomaticSize.Y
    listFrame.Position = UDim2.new(0, 8, 0, 162)
    local _listUIScale = Instance.new("UIScale", listFrame)
    _listUIScale.Scale = _listScaleVal
    _G._adminListUIScale = _listUIScale
    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0, 5); layout.SortOrder = Enum.SortOrder.LayoutOrder
    local _listPad = Instance.new("UIPadding", listFrame)
    _listPad.PaddingTop = UDim.new(0, 4); _listPad.PaddingBottom = UDim.new(0, 8)

    local blacklistFrame = Instance.new("Frame", frame)
    blacklistFrame.BackgroundTransparency = 1; blacklistFrame.BorderSizePixel = 0
    blacklistFrame.Size = UDim2.new(1, -16, 0, 0)
    blacklistFrame.AutomaticSize = Enum.AutomaticSize.Y
    blacklistFrame.Position = UDim2.new(0, 8, 0, 162); blacklistFrame.Visible = false
    local _blUIScale = Instance.new("UIScale", blacklistFrame)
    _blUIScale.Scale = _listScaleVal
    _G._adminBLUIScale = _blUIScale
    local blacklistLayout = Instance.new("UIListLayout", blacklistFrame)
    blacklistLayout.Padding = UDim.new(0, 5); blacklistLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local _blPad = Instance.new("UIPadding", blacklistFrame)
    _blPad.PaddingTop = UDim.new(0, 4); _blPad.PaddingBottom = UDim.new(0, 8)

    local function isBlacklisted(plr)
        return Config.Blacklist and Config.Blacklist[tostring(plr.UserId)] ~= nil
    end

    local rebuildBlacklistFrame
    local updatePanelHeight

    local function switchAdminTab(tab)
        adminCurrentTab = tab
        if tab == "Players" then
            listFrame.Visible = true; blacklistFrame.Visible = false
            playersTabBtn.TextColor3 = Theme.Accent1
            blacklistTabBtn.TextColor3 = Color3.fromRGB(50, 55, 85)
            TweenService:Create(_tabPill, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 3, 0, 3), BackgroundColor3 = Theme.Accent1}):Play()
            _tpStr.Color = Theme.Accent1
        else
            listFrame.Visible = false; blacklistFrame.Visible = true
            blacklistTabBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
            playersTabBtn.TextColor3 = Color3.fromRGB(50, 55, 85)
            TweenService:Create(_tabPill, TweenInfo.new(0.18, Enum.EasingStyle.Quart), {Position = UDim2.new(0.5, 1, 0, 3), BackgroundColor3 = Color3.fromRGB(200, 50, 50)}):Play()
            _tpStr.Color = Color3.fromRGB(220, 60, 60)
            if rebuildBlacklistFrame then rebuildBlacklistFrame() end
        end
        if updatePanelHeight then updatePanelHeight() end
    end
    playersTabBtn.MouseButton1Click:Connect(function() switchAdminTab("Players") end)
    blacklistTabBtn.MouseButton1Click:Connect(function() switchAdminTab("Blacklisted") end)

    rebuildBlacklistFrame = function()
        for _, c in ipairs(blacklistFrame:GetChildren()) do
            if not c:IsA("UIListLayout") then c:Destroy() end
        end
        local entries = {}
        for uidStr, name in pairs(Config.Blacklist or {}) do
            local uid = tonumber(uidStr)
            if uid and Players:GetPlayerByUserId(uid) then
                table.insert(entries, {uidStr = uidStr, name = name})
            end
        end
        table.sort(entries, function(a, b) return a.name < b.name end)
        if #entries == 0 then
            local emptyLbl = Instance.new("TextLabel", blacklistFrame)
            emptyLbl.Size = UDim2.new(1, 0, 0, 40)
            emptyLbl.BackgroundTransparency = 1
            emptyLbl.Text = "No blacklisted players in this server"
            emptyLbl.Font = Enum.Font.GothamMedium
            emptyLbl.TextSize = 11
            emptyLbl.TextColor3 = Color3.fromRGB(70, 75, 100)
            emptyLbl.TextXAlignment = Enum.TextXAlignment.Center
            return
        end
        for _, entry in ipairs(entries) do
            local uidStr, savedName = entry.uidStr, entry.name
            local uid = tonumber(uidStr)

            local row = Instance.new("Frame", blacklistFrame)
            row.Size = UDim2.new(1, -2, 0, 72)
            row.BackgroundColor3 = Color3.fromRGB(16, 9, 9)
            row.BackgroundTransparency = 0
            row.BorderSizePixel = 0
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
            local rowStroke = Instance.new("UIStroke", row)
            rowStroke.Color = Color3.fromRGB(180, 40, 40)
            rowStroke.Thickness = 1
            rowStroke.Transparency = 0.4

            local _leftBar = Instance.new("Frame", row)
            _leftBar.Size = UDim2.new(0, 3, 0.7, 0)
            _leftBar.Position = UDim2.new(0, 0, 0.15, 0)
            _leftBar.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            _leftBar.BorderSizePixel = 0
            Instance.new("UICorner", _leftBar).CornerRadius = UDim.new(1, 0)

            local nameLabel = Instance.new("TextLabel", row)
            nameLabel.Size = UDim2.new(1, -90, 0, 20)
            nameLabel.Position = UDim2.new(0, 12, 0, 6)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 13
            nameLabel.TextColor3 = Color3.fromRGB(230, 200, 200)
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            nameLabel.Text = savedName

            local subLabel = Instance.new("TextLabel", row)
            subLabel.Size = UDim2.new(1, -16, 0, 13)
            subLabel.Position = UDim2.new(0, 12, 0, 24)
            subLabel.BackgroundTransparency = 1
            subLabel.Font = Enum.Font.GothamMedium
            subLabel.TextSize = 8
            subLabel.TextXAlignment = Enum.TextXAlignment.Left
            subLabel.TextTruncate = Enum.TextTruncate.AtEnd
            subLabel.TextColor3 = Color3.fromRGB(120, 70, 70)
            subLabel.Text = "ID: " .. uidStr .. " — offline"

            -- AP emoji buttons
            local apCont = Instance.new("Frame", row)
            apCont.Size = UDim2.new(0, 108, 0, 24)
            apCont.Position = UDim2.new(0, 8, 1, -32)
            apCont.BackgroundTransparency = 1
            for i, def in ipairs({{icon="🚀",cmd="rocket"},{icon="🏃",cmd="ragdoll"},{icon="🔒",cmd="jail"},{icon="🎈",cmd="balloon"}}) do
                local b = Instance.new("TextButton", apCont)
                b.Size = UDim2.new(0, 24, 0, 24)
                b.Position = UDim2.new(0, (i-1)*26, 0, 0)
                b.AutoButtonColor = false
                b.Text = def.icon
                b.TextSize = 13
                b.TextColor3 = Theme.TextPrimary
                b.Font = Enum.Font.GothamMedium
                b.BackgroundColor3 = Color3.fromRGB(30, 15, 15)
                b.BorderSizePixel = 0
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                local bStroke = Instance.new("UIStroke", b)
                bStroke.Color = Color3.fromRGB(180, 40, 40)
                bStroke.Transparency = 0.4
                bStroke.Thickness = 1
                local capturedCmd = def.cmd
                local capturedIcon = def.icon
                local capturedUid = uid
                b.MouseButton1Click:Connect(function()
                    local lp = Players:GetPlayerByUserId(capturedUid)
                    if not lp or not lp.Parent then ShowNotification("ADMIN", savedName .. " not in server"); return end
                    local fn = _G.runAdminCommand
                    if fn then
                        if fn(lp, capturedCmd) then
                            ShowNotification("ADMIN", "Sent " .. capturedCmd .. " to " .. lp.Name)
                        else
                            ShowNotification("ADMIN", "Failed: " .. capturedCmd)
                        end
                    end
                end)
            end

            -- TRIGGER ALL button
            local trigBtn = Instance.new("TextButton", row)
            trigBtn.Size = UDim2.new(0, 80, 0, 24)
            trigBtn.Position = UDim2.new(0, 120, 1, -32)
            trigBtn.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
            trigBtn.TextColor3 = Color3.fromRGB(255, 180, 180)
            trigBtn.Font = Enum.Font.GothamMedium
            trigBtn.TextSize = 9
            trigBtn.Text = "TRIGGER ALL"
            trigBtn.BorderSizePixel = 0
            Instance.new("UICorner", trigBtn).CornerRadius = UDim.new(0, 5)
            local _trigStroke = Instance.new("UIStroke", trigBtn)
            _trigStroke.Color = Color3.fromRGB(200, 50, 50)
            _trigStroke.Transparency = 0.3
            _trigStroke.Thickness = 1
            local capturedUid2 = uid
            local BL_ALL_COMMANDS = {"balloon","inverse","jail","jumpscare","morph","nightvision","ragdoll","rocket","tiny"}
            trigBtn.MouseButton1Click:Connect(function()
                local lp = Players:GetPlayerByUserId(capturedUid2)
                if not lp or not lp.Parent then ShowNotification("ADMIN", savedName .. " not in server"); return end
                local fn = _G.runAdminCommand
                if not fn then ShowNotification("ADMIN", "Admin not ready"); return end
                local count = 0
                for _, cmd in ipairs(BL_ALL_COMMANDS) do
                    local capturedCmd = cmd
                    task.delay(count * 0.15, function()
                        if lp and lp.Parent then fn(lp, capturedCmd) end
                    end)
                    count = count + 1
                end
                ShowNotification("ADMIN", "Triggered ALL on " .. lp.Name)
            end)

            -- UNBLACKLIST button
            local unblBtn = Instance.new("TextButton", row)
            unblBtn.Size = UDim2.new(0, 78, 0, 22)
            unblBtn.Position = UDim2.new(1, -86, 0, 6)
            unblBtn.BackgroundColor3 = Color3.fromRGB(80, 15, 15)
            unblBtn.TextColor3 = Color3.fromRGB(255, 150, 150)
            unblBtn.Font = Enum.Font.GothamMedium
            unblBtn.TextSize = 9
            unblBtn.Text = "✕ UNBLACKLIST"
            unblBtn.BorderSizePixel = 0
            Instance.new("UICorner", unblBtn).CornerRadius = UDim.new(0, 5)
            local _unblStroke = Instance.new("UIStroke", unblBtn)
            _unblStroke.Color = Color3.fromRGB(200, 50, 50)
            _unblStroke.Transparency = 0.3
            _unblStroke.Thickness = 1
            local capturedUidStr = uidStr
            unblBtn.MouseButton1Click:Connect(function()
                Config.Blacklist[capturedUidStr] = nil
                SaveConfig()
                ShowNotification("BLACKLIST", "Removed from blacklist")
                rebuildBlacklistFrame()
                -- Re-add to Players tab if they're still in server
                local plrObj = Players:GetPlayerByUserId(tonumber(capturedUidStr))
                if plrObj then pcall(addPlayer, plrObj) end
            end)

            -- Update status label (in server / offline)
            task.spawn(function()
                while row.Parent do
                    task.wait(2)
                    local lp = Players:GetPlayerByUserId(uid)
                    if lp and lp.Parent then
                        nameLabel.Text = lp.DisplayName
                        subLabel.Text = "(@" .. lp.Name .. ") IN SERVER"
                    else
                        subLabel.Text = "ID: " .. uidStr .. " — offline"
                    end
                end
            end)
        end
    end

    local function getAdminPanelSortKey(plr)
        if not plr or not plr.Parent then return 3, 9999, "" end
        local stealing = plr:GetAttribute("Stealing")
        local brainrotName = plr:GetAttribute("StealingIndex")
        if not stealing then return 3, 9999, plr.Name or "" end
        if brainrotName then
            for i, pName in ipairs(PRIORITY_LIST) do
                if pName == brainrotName then return 1, i, plr.Name or "" end
            end
            return 2, 9999, plr.Name or ""
        end
        return 2, 9999, plr.Name or ""
    end

    local function sortAdminPanelList()
        local rows = {}
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "" then
                local plr = Players:FindFirstChild(child.Name)
                if plr then table.insert(rows, {row = child, plr = plr}) end
            end
        end
        table.sort(rows, function(a, b)
            local t1, p1, n1 = getAdminPanelSortKey(a.plr)
            local t2, p2, n2 = getAdminPanelSortKey(b.plr)
            if t1 ~= t2 then return t1 < t2 end
            if p1 ~= p2 then return p1 < p2 end
            return (n1 or "") < (n2 or "")
        end)
        for i, entry in ipairs(rows) do
            entry.row.LayoutOrder = i
        end
    end

    local function fireClick(button)
        if not button or not button.Parent then return end
        if firesignal then
            firesignal(button.MouseButton1Click)
            firesignal(button.MouseButton1Down)
            firesignal(button.Activated)
        else
            local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
            local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + 58
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end
    end
    _G.fireClick = fireClick

    local function runAdminCommand(targetPlayer, commandName)
        if not targetPlayer or not targetPlayer.Parent then return false end
        local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
        if not realAdminGui then return false end
        local contentScroll = realAdminGui.AdminPanel:WaitForChild("Content"):WaitForChild("ScrollingFrame")
        local cmdBtn = contentScroll:FindFirstChild(commandName)
        if not cmdBtn then return false end
        fireClick(cmdBtn)
        task.wait(0.05)
        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
        local playerBtn = profilesScroll:FindFirstChild(targetPlayer.Name)
        if not playerBtn then return false end
        fireClick(playerBtn)
        return true
    end
    _G.runAdminCommand = runAdminCommand

    local isOnCooldown
    local function getNextAvailableCommand()
        local priorityCommands = {"ragdoll", "balloon", "rocket", "jail"}
        local otherCommands = {}
        for _, cmd in ipairs(ALL_COMMANDS) do
            local isPriority = false
            for _, pc in ipairs(priorityCommands) do
                if cmd == pc then isPriority = true; break end
            end
            if not isPriority then table.insert(otherCommands, cmd) end
        end
        for _, cmd in ipairs(priorityCommands) do
            if not isOnCooldown(cmd) then return cmd end
        end
        for _, cmd in ipairs(otherCommands) do
            if not isOnCooldown(cmd) then return cmd end
        end
        return nil
    end

    isOnCooldown = function(cmd)
        local adminGui = PlayerGui:FindFirstChild("AdminPanel")
        if adminGui then
            local content = adminGui:FindFirstChild("AdminPanel")
            if content then
                local scrollFrame = content:FindFirstChild("Content")
                if scrollFrame then
                    local scrollingFrame = scrollFrame:FindFirstChild("ScrollingFrame")
                    if scrollingFrame then
                        local cmdButton = scrollingFrame:FindFirstChild(cmd)
                        if cmdButton then
                            local timerLabel = cmdButton:FindFirstChild("Timer")
                            if timerLabel then return timerLabel.Visible end
                        end
                    end
                end
            end
        end
        if not activeCooldowns[cmd] then return false end
        return (tick() - activeCooldowns[cmd]) < (COOLDOWNS[cmd] or 0)
    end

    local function setGlobalVisualCooldown(cmd)
        if SharedState.AdminButtonCache[cmd] then
            for _, b in ipairs(SharedState.AdminButtonCache[cmd]) do
                if b and b.Parent then
                    b.BackgroundColor3 = Theme.Error
                    task.delay(COOLDOWNS[cmd] or 5, function()
                        if b and b.Parent then
                            local hasBallooned = (cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                            b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                        end
                    end)
                end
            end
        end
    end

    local function updateBalloonButtons()
        local hasBallooned = false
        for _, _ in pairs(SharedState.BalloonedPlayers) do hasBallooned = true; break end
        if SharedState.AdminButtonCache and SharedState.AdminButtonCache["balloon"] then
            for _, b in ipairs(SharedState.AdminButtonCache["balloon"]) do
                if b and b.Parent then
                    b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                end
            end
        end
    end

    local function triggerAll(plr)
        if not plr or not plr.Parent then return end
        if isBlacklisted(plr) then return end
        local count = 0
        for _, cmd in ipairs(ALL_COMMANDS) do
            if not isOnCooldown(cmd) then
                task.delay(count * 0.1, function()
                    if not plr or not plr.Parent then return end
                    if runAdminCommand(plr, cmd) then
                        activeCooldowns[cmd] = tick()
                        setGlobalVisualCooldown(cmd)
                        if cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            updateBalloonButtons()
                        end
                    end
                end)
                count = count + 1
            end
        end
    end

    local function rayToCubeIntersect(rayOrigin, rayDirection, cubeCenter, cubeSize)
        local halfSize = cubeSize / 2
        local minBounds = cubeCenter - Vector3.new(halfSize, halfSize, halfSize)
        local maxBounds = cubeCenter + Vector3.new(halfSize, halfSize, halfSize)
        if rayDirection.X == 0 then rayDirection = Vector3.new(0.0001, rayDirection.Y, rayDirection.Z) end
        if rayDirection.Y == 0 then rayDirection = Vector3.new(rayDirection.X, 0.0001, rayDirection.Z) end
        if rayDirection.Z == 0 then rayDirection = Vector3.new(rayDirection.X, rayDirection.Y, 0.0001) end
        local tmin = (minBounds.X - rayOrigin.X) / rayDirection.X
        local tmax = (maxBounds.X - rayOrigin.X) / rayDirection.X
        if tmin > tmax then tmin, tmax = tmax, tmin end
        local tymin = (minBounds.Y - rayOrigin.Y) / rayDirection.Y
        local tymax = (maxBounds.Y - rayOrigin.Y) / rayDirection.Y
        if tymin > tymax then tymin, tymax = tymax, tymin end
        if tmin > tymax or tymin > tmax then return false end
        if tymin > tmin then tmin = tymin end
        if tymax < tmax then tmax = tymax end
        local tzmin = (minBounds.Z - rayOrigin.Z) / rayDirection.Z
        local tzmax = (maxBounds.Z - rayOrigin.Z) / rayDirection.Z
        if tzmin > tzmax then tzmin, tzmax = tzmax, tzmin end
        if tmin > tzmax or tzmin > tmax then return false end
        return true
    end

    local highlight = Instance.new("Highlight", game:GetService("CoreGui"))
    highlight.FillColor = Theme.Accent1
    highlight.FillTransparency = 0.3
    highlight.OutlineColor = Theme.Accent1
    highlight.OutlineTransparency = 0
    highlight.Adornee = nil
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

    RunService.RenderStepped:Connect(function()
        if Config.ClickToAP then
            local camera = Workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local hitboxSize = 8
            local bestPlayer, bestDistance = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
                    local hrp = p.Character.HumanoidRootPart
                    if rayToCubeIntersect(ray.Origin, ray.Direction, hrp.Position, hitboxSize) then
                        local distance = (ray.Origin - hrp.Position).Magnitude
                        if distance < bestDistance then bestDistance = distance; bestPlayer = p end
                    end
                end
            end
            local newAdornee = bestPlayer and bestPlayer.Character or nil
            if highlight.Adornee ~= newAdornee then highlight.Adornee = newAdornee end
        else
            highlight.Adornee = nil
        end
    end)

    UserInputService.InputBegan:Connect(function(inp, g)
        if not g and inp.UserInputType == Enum.UserInputType.MouseButton1 and Config.ClickToAP then
            local camera = Workspace.CurrentCamera
            local mousePos = UserInputService:GetMouseLocation()
            local ray = camera:ViewportPointToRay(mousePos.X, mousePos.Y)
            local hitboxSize = 8
            local bestPlayer, bestDistance = nil, math.huge
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
                    local hrp = p.Character.HumanoidRootPart
                    if rayToCubeIntersect(ray.Origin, ray.Direction, hrp.Position, hitboxSize) then
                        local distance = (ray.Origin - hrp.Position).Magnitude
                        if distance < bestDistance then bestDistance = distance; bestPlayer = p end
                    end
                end
            end
            if bestPlayer then
                if isBlacklisted(bestPlayer) then return end
                local hasAnyAvailable = false
                for _, cmd in ipairs(ALL_COMMANDS) do
                    if not isOnCooldown(cmd) then hasAnyAvailable = true; break end
                end
                if hasAnyAvailable then
                    if Config.ClickToAPSingleCommand then
                        local nextCmd = getNextAvailableCommand()
                        if nextCmd then
                            if runAdminCommand(bestPlayer, nextCmd) then
                                activeCooldowns[nextCmd] = tick()
                                setGlobalVisualCooldown(nextCmd)
                                if nextCmd == "balloon" then
                                    SharedState.BalloonedPlayers[bestPlayer.UserId] = true
                                    updateBalloonButtons()
                                end
                                ShowNotification("CLICK AP", "Sent " .. nextCmd .. " to " .. bestPlayer.Name)
                            else
                                ShowNotification("CLICK AP", "Failed to send " .. nextCmd .. " to " .. bestPlayer.Name)
                            end
                        else
                            ShowNotification("CLICK AP", "All commands on cooldown")
                        end
                    else
                        triggerAll(bestPlayer)
                        ShowNotification("CLICK AP", "Triggered on " .. bestPlayer.Name)
                    end
                else
                    local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
                    if realAdminGui then
                        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
                        local playerBtn = profilesScroll:FindFirstChild(bestPlayer.Name)
                        if playerBtn then fireClick(playerBtn); ShowNotification("CLICK AP", "Selected " .. bestPlayer.Name) end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.2)
            if ProximityAPActive then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Parent then
                            local dist = (p.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                            if dist <= Config.ProximityRange then
                                do local hasAnyAvailable = false
                                    for _, cmd in ipairs(ALL_COMMANDS) do
                                        if not isOnCooldown(cmd) then hasAnyAvailable = true; break end
                                    end
                                    if hasAnyAvailable then triggerAll(p) end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local removePlayer

    local function createPlayerRow(plr)
        if not plr or not plr.Parent then return nil end

        local row = Instance.new("TextButton")
        row.Name = plr.Name
        row.LayoutOrder = 0
        row.Size = UDim2.new(1, -2, 0, 58)
        row.BackgroundColor3 = Color3.fromRGB(10, 11, 18)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = listFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Color3.fromRGB(18, 22, 36)
        rowStroke.Thickness = 1; rowStroke.Transparency = 1

        -- Left accent bar
        local _rowAccent = Instance.new("Frame", row)
        _rowAccent.Name = "LeftAccent"
        _rowAccent.Size = UDim2.new(0, 3, 0.6, 0); _rowAccent.Position = UDim2.new(0, 0, 0.2, 0)
        _rowAccent.BackgroundColor3 = Color3.fromRGB(0, 200, 255); _rowAccent.BorderSizePixel = 0
        Instance.new("UICorner", _rowAccent).CornerRadius = UDim.new(1, 0)

        row.MouseEnter:Connect(function()
            row.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
            row.BackgroundTransparency = 0.7
            rowStroke.Color = isBlacklisted(plr) and Color3.fromRGB(180, 40, 40) or Theme.Accent1
            rowStroke.Transparency = 0.35
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundTransparency = 1
            rowStroke.Transparency = 1
        end)

        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        end)
        local headshot = Instance.new("ImageLabel", row)
        headshot.Size = UDim2.new(0, 36, 0, 36); headshot.Position = UDim2.new(0, 9, 0.5, -18)
        headshot.BackgroundColor3 = Color3.fromRGB(10, 12, 20); headshot.Image = ok and img or ""
        Instance.new("UICorner", headshot).CornerRadius = UDim.new(0, 7)
        local headshotStroke = Instance.new("UIStroke", headshot)
        headshotStroke.Color = Theme.Accent1; headshotStroke.Thickness = 1.5; headshotStroke.Transparency = 0.35

        local dName = Instance.new("TextLabel", row)
        dName.Size = UDim2.new(1, -148, 0, 17); dName.Position = UDim2.new(0, 53, 0, 6)
        dName.BackgroundTransparency = 1; dName.Text = plr.DisplayName
        dName.Font = Enum.Font.GothamBold; dName.TextSize = 13
        dName.TextColor3 = Color3.fromRGB(215, 220, 240)
        dName.TextXAlignment = Enum.TextXAlignment.Left; dName.TextTruncate = Enum.TextTruncate.AtEnd

        local uName = Instance.new("TextLabel", row)
        uName.Size = UDim2.new(1, -148, 0, 13); uName.Position = UDim2.new(0, 53, 0, 23)
        uName.BackgroundTransparency = 1; uName.Text = "@" .. plr.Name
        uName.Font = Enum.Font.GothamMedium; uName.TextSize = 9
        uName.TextColor3 = Theme.Accent1
        uName.TextXAlignment = Enum.TextXAlignment.Left; uName.TextTruncate = Enum.TextTruncate.AtEnd

        local function updateStealLabel()
            if not row.Parent then return end
            local stealing = plr:GetAttribute("Stealing")
            local brainrotName = plr:GetAttribute("StealingIndex")
            if stealing then
                uName.Text = (brainrotName or "STEALING")
                uName.TextColor3 = Color3.fromRGB(255, 65, 100)
                uName.TextStrokeTransparency = 1
                uName.Font = Enum.Font.GothamMedium; uName.TextSize = 9
                uName.Size = UDim2.new(1, -148, 0, 13); uName.Position = UDim2.new(0, 53, 0, 23)
                _rowAccent.BackgroundColor3 = Color3.fromRGB(255, 55, 55)
            else
                uName.Text = "@" .. plr.Name
                uName.TextColor3 = Theme.Accent1
                uName.TextStrokeTransparency = 1
                uName.Font = Enum.Font.GothamMedium; uName.TextSize = 9
                uName.Size = UDim2.new(1, -148, 0, 13); uName.Position = UDim2.new(0, 53, 0, 23)
                _rowAccent.BackgroundColor3 = Theme.Accent1
            end
        end

        updateStealLabel()

        task.spawn(function()
            while row.Parent do
                task.wait(0.5)
                if not plr or not plr.Parent or not Players:FindFirstChild(plr.Name) then
                    pcall(removePlayer, plr)
                    break
                end
                pcall(updateStealLabel)
            end
        end)

        -- Command buttons (4 in a row, right side)
        local btnCont = Instance.new("Frame", row)
        btnCont.Size = UDim2.new(0, 120, 0, 34); btnCont.Position = UDim2.new(1, -125, 0.5, -17)
        btnCont.BackgroundTransparency = 1; btnCont.ZIndex = 10

        local buttonsDef = {
            {icon = "🚀", cmd = "rocket"},
            {icon = "🏃", cmd = "ragdoll"},
            {icon = "🔒", cmd = "jail"},
            {icon = "🎈", cmd = "balloon"}
        }

        for i, def in ipairs(buttonsDef) do
            local b = Instance.new("TextButton", btnCont)
            b.Size = UDim2.new(0, 28, 0, 28); b.Position = UDim2.new(0, (i-1)*31, 0, 0)
            b.AutoButtonColor = false; b.Text = def.icon; b.TextSize = 16
            b.TextColor3 = Theme.TextPrimary; b.Font = Enum.Font.GothamMedium
            b.ZIndex = 11; b.Active = true
            b.BackgroundColor3 = Color3.fromRGB(14, 16, 26); b.BackgroundTransparency = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
            local bStroke = Instance.new("UIStroke", b)
            bStroke.Color = Color3.fromRGB(22, 28, 50); bStroke.Thickness = 1; bStroke.Transparency = 0; bStroke.ZIndex = 12

            b.MouseEnter:Connect(function()
                if not isOnCooldown(def.cmd) then
                    b.BackgroundColor3 = Color3.fromRGB(20, 24, 40)
                    bStroke.Color = Theme.Accent1; bStroke.Transparency = 0.4
                end
            end)
            b.MouseLeave:Connect(function()
                if not isOnCooldown(def.cmd) then
                    b.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
                    bStroke.Color = Color3.fromRGB(22, 28, 50); bStroke.Transparency = 0
                end
            end)

            if not SharedState.AdminButtonCache[def.cmd] then SharedState.AdminButtonCache[def.cmd] = {} end
            table.insert(SharedState.AdminButtonCache[def.cmd], b)

            task.spawn(function()
                while b and b.Parent do
                    task.wait(0.05)
                    local cd = isOnCooldown(def.cmd)
                    local balloon = (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                    if cd or balloon then
                        b.BackgroundColor3 = Theme.Error; bStroke.Color = Theme.Error; bStroke.Transparency = 0.2
                    else
                        b.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
                        bStroke.Color = Color3.fromRGB(22, 28, 50); bStroke.Transparency = 0
                    end
                    if b.Text ~= def.icon then
                        b.Text = def.icon; b.TextSize = 16
                        b.TextColor3 = Theme.TextPrimary; b.Font = Enum.Font.GothamMedium
                    end
                end
            end)

            b.MouseButton1Click:Connect(function()
                if not plr or not plr.Parent then return end
                if isBlacklisted(plr) then ShowNotification("ADMIN", plr.Name .. " is blacklisted"); return end
                ShowNotification("ADMIN", "Attempting " .. def.cmd .. " on " .. plr.Name)
                if runAdminCommand(plr, def.cmd) then
                    activeCooldowns[def.cmd] = tick(); setGlobalVisualCooldown(def.cmd)
                    if def.cmd == "balloon" then
                        SharedState.BalloonedPlayers[plr.UserId] = true
                        for _, btn in ipairs(SharedState.AdminButtonCache["balloon"] or {}) do
                            if btn and btn.Parent then btn.BackgroundColor3 = Theme.Error end
                        end
                    end
                    ShowNotification("ADMIN", "Sent " .. def.cmd .. " to " .. plr.Name)
                else
                    ShowNotification("ADMIN", "Failed to send " .. def.cmd .. " to " .. plr.Name)
                end
            end)
        end

        -- Hover highlight overlay
        local rowHighlight = Instance.new("Frame", row)
        rowHighlight.Name = "BLHighlight"; rowHighlight.Size = UDim2.new(1,0,1,0)
        rowHighlight.BackgroundColor3 = isBlacklisted(plr) and Color3.fromRGB(180,30,30) or Theme.Accent1
        rowHighlight.BackgroundTransparency = 1; rowHighlight.BorderSizePixel = 0; rowHighlight.ZIndex = 1
        Instance.new("UICorner", rowHighlight).CornerRadius = UDim.new(0, 8)
        row.MouseEnter:Connect(function()
            rowHighlight.BackgroundColor3 = isBlacklisted(plr) and Color3.fromRGB(180,30,30) or Theme.Accent1
            rowHighlight.BackgroundTransparency = 0.9
        end)
        row.MouseLeave:Connect(function() rowHighlight.BackgroundTransparency = 1 end)
        row.MouseButton1Click:Connect(function()
            if not plr or not plr.Parent then return end
            if isBlacklisted(plr) then ShowNotification("ADMIN", plr.Name .. " is blacklisted — use Blacklisted tab to AP"); return end
            local hasAnyAvailable = false
            for _, cmd in ipairs(ALL_COMMANDS) do
                if not isOnCooldown(cmd) then hasAnyAvailable = true; break end
            end
            if hasAnyAvailable then triggerAll(plr); ShowNotification("ADMIN", "Triggered ALL on " .. plr.Name) end
        end)

        -- BL tag button
        local blBtn = Instance.new("TextButton", row)
        blBtn.Name = "BLBtn"
        blBtn.Size = UDim2.new(0, 38, 0, 18); blBtn.Position = UDim2.new(0, 53, 1, -21)
        blBtn.ZIndex = 12; blBtn.AutoButtonColor = false
        blBtn.BackgroundColor3 = isBlacklisted(plr) and Color3.fromRGB(140, 20, 20) or Color3.fromRGB(14, 16, 26)
        blBtn.TextColor3 = isBlacklisted(plr) and Color3.fromRGB(255, 170, 170) or Theme.Accent1
        blBtn.Font = Enum.Font.GothamMedium; blBtn.TextSize = 10
        blBtn.Text = isBlacklisted(plr) and "UNBL" or "BL"
        blBtn.BorderSizePixel = 0; blBtn.Active = true
        Instance.new("UICorner", blBtn).CornerRadius = UDim.new(0, 4)
        blBtn.MouseButton1Click:Connect(function()
            if not plr then return end
            local uidStr = tostring(plr.UserId)
            if Config.Blacklist[uidStr] then
                Config.Blacklist[uidStr] = nil; SaveConfig()
                ShowNotification("BLACKLIST", plr.Name .. " removed from blacklist")
                pcall(addPlayer, plr)
            else
                Config.Blacklist[uidStr] = plr.Name; SaveConfig()
                ShowNotification("BLACKLIST", plr.Name .. " added to blacklist")
                -- Remove from Players tab
                pcall(removePlayer, plr)
            end
        end)

        -- TP tag button
        local tpBtn = Instance.new("TextButton", row)
        tpBtn.Name = "TPBtn"
        tpBtn.Size = UDim2.new(0, 38, 0, 18); tpBtn.Position = UDim2.new(0, 95, 1, -21)
        tpBtn.ZIndex = 12; tpBtn.AutoButtonColor = false
        tpBtn.BackgroundColor3 = Color3.fromRGB(14, 16, 26)
        tpBtn.TextColor3 = Theme.Accent1
        tpBtn.Font = Enum.Font.GothamMedium; tpBtn.TextSize = 10; tpBtn.Text = "TP"
        tpBtn.BorderSizePixel = 0; tpBtn.Active = true
        Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
        local tpStroke = Instance.new("UIStroke", tpBtn)
        tpStroke.Color = Theme.Accent1; tpStroke.Thickness = 1; tpStroke.Transparency = 0.45
        tpBtn.MouseButton1Click:Connect(function()
            if _G.tpToPlayerBase then _G.tpToPlayerBase(plr)
            else ShowNotification("TP", "TP not ready yet") end
        end)

        return row
    end

    removePlayer = function(plr)
        if not plr then return end
        local userId = plr.UserId
        local entry = playerRowsByUserId[userId]
        local row = (entry and entry.row) or playerRows[plr]

        if row then
            if row.Parent then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent and buttons[i]:IsDescendantOf(row) then
                            table.remove(buttons, i)
                        end
                    end
                end
                row:Destroy()
            end
        end

        playerRows[plr] = nil
        if userId then
            playerRowsByUserId[userId] = nil
            if SharedState.BalloonedPlayers then
                SharedState.BalloonedPlayers[userId] = nil
            end
        end
    end

    local function addPlayer(plr)
        if not plr or not plr.Parent then return end
        if plr == LocalPlayer then return end
        if not Players:FindFirstChild(plr.Name) then return end
        if playerRowsByUserId[plr.UserId] then return end
        if addingPlayers[plr.UserId] then return end
        if isBlacklisted(plr) then return end

        addingPlayers[plr.UserId] = true
        local row = createPlayerRow(plr)
        if row then
            playerRows[plr] = row
            playerRowsByUserId[plr.UserId] = {player = plr, row = row}
            sortAdminPanelList()
        end
        addingPlayers[plr.UserId] = nil
    end

    spamBaseBtn.MouseButton1Click:Connect(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then ShowNotification("SPAM OWNER", "No character found"); return end

        local nearestPlot, nearestDist = nil, math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local yourBase = sign:FindFirstChild("YourBase")
                    if not yourBase or not yourBase.Enabled then
                        local signPos = nil
                        if sign:IsA("BasePart") then
                            signPos = sign.Position
                        elseif sign.PrimaryPart then
                            signPos = sign.PrimaryPart.Position
                        else
                            local part = sign:FindFirstChildWhichIsA("BasePart", true)
                            signPos = part and part.Position
                        end
                        if signPos then
                            local dist = (hrp.Position - signPos).Magnitude
                            if dist < nearestDist then nearestDist = dist; nearestPlot = plot end
                        end
                    end
                end
            end
        end

        if not nearestPlot then ShowNotification("SPAM OWNER", "No nearby base found"); return end

        local targetPlayer = nil
        local ok, ch = pcall(function() return Synchronizer:Get(nearestPlot.Name) end)
        if ok and ch then
            local owner = ch:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    targetPlayer = owner
                elseif type(owner) == "table" and owner.Name then
                    targetPlayer = Players:FindFirstChild(owner.Name)
                end
            end
        end

        if not targetPlayer then
            local sign = nearestPlot:FindFirstChild("PlotSign")
            local textLabel = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if textLabel then
                local nickname = textLabel.Text and textLabel.Text:match("^(.-)'") or textLabel.Text
                if nickname then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p.DisplayName == nickname or p.Name == nickname then targetPlayer = p; break end
                    end
                end
            end
        end

        if not targetPlayer or targetPlayer == LocalPlayer then
            ShowNotification("SPAM OWNER", "Owner not found or is you"); return
        end

        spamBaseBtn.BackgroundColor3 = Color3.fromRGB(120, 80, 220)
        spamBaseBtn.BackgroundTransparency = 0
        spamBaseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ShowNotification("SPAM OWNER", "Spamming " .. targetPlayer.DisplayName)

        task.spawn(function()
            local cmdCount = 0
            for _, cmd in ipairs(ALL_COMMANDS) do
                if not targetPlayer or not targetPlayer.Parent then break end
                local success, result = pcall(function() return runAdminCommand(targetPlayer, cmd) end)
                if success and result then cmdCount = cmdCount + 1 end
                task.wait(0.15)
            end
            task.wait(0.2)
            spamBaseBtn.BackgroundColor3 = Color3.fromRGB(9, 10, 17)
            spamBaseBtn.BackgroundTransparency = 1
            spamBaseBtn.TextColor3 = Color3.fromRGB(175, 135, 255)
            ShowNotification("SPAM OWNER", "Sent " .. cmdCount .. " commands to " .. (targetPlayer and targetPlayer.DisplayName or "?"))
        end)
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        local toRemove = {}
        for userId, entry in pairs(playerRowsByUserId) do
            table.insert(toRemove, entry.player)
        end
        for _, plr in ipairs(toRemove) do
            pcall(removePlayer, plr)
        end

        playerRows = {}
        playerRowsByUserId = {}
        addingPlayers = {}
        SharedState.AdminButtonCache = {}
        SharedState.BalloonedPlayers = {}

        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        task.wait(0.1)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then addPlayer(p) end
        end
        sortAdminPanelList()
        ShowNotification("ADMIN PANEL", "Completely refreshed - " .. (#Players:GetPlayers() - 1) .. " players found")
    end)

    Players.PlayerAdded:Connect(function(plr)
        task.wait(0.2)
        if plr and plr.Parent then addPlayer(plr) end
    end)

    Players.PlayerRemoving:Connect(function(plr)
        pcall(removePlayer, plr)
    end)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then addPlayer(p) end
    end
    sortAdminPanelList()

    task.spawn(function()
        while listFrame and listFrame.Parent do
            task.wait(0.5)
            pcall(sortAdminPanelList)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            local currentPlayerIds = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Parent then currentPlayerIds[p.UserId] = p end
            end
            for userId, entry in pairs(playerRowsByUserId) do
                if not currentPlayerIds[userId] or not entry.player or not entry.player.Parent then
                    pcall(removePlayer, entry.player)
                end
            end
            for userId, p in pairs(currentPlayerIds) do
                if not playerRowsByUserId[userId] then addPlayer(p) end
            end
        end
    end)

    local _headerH = 162
    updatePanelHeight = function()
        task.defer(function()
            local absContentH
            if adminCurrentTab == "Blacklisted" then
                absContentH = blacklistLayout.AbsoluteContentSize.Y
            else
                absContentH = layout.AbsoluteContentSize.Y
            end
            -- AbsoluteContentSize is already scaled by both adminUIScale and _listUIScale.
            -- To get logical frame height: divide by adminUIScale only (list scale is baked in).
            local panelScale = adminUIScale.Scale
            local contentLogical = absContentH / panelScale
            local vp = workspace.CurrentCamera.ViewportSize
            local maxLogical = (vp.Y - 30) / panelScale
            local newH = math.min(_headerH + contentLogical + 12, maxLogical)
            frame.Size = UDim2.new(0, 340, 0, math.max(newH, _headerH + 30))
        end)
    end
    layout.Changed:Connect(updatePanelHeight)
    blacklistLayout.Changed:Connect(updatePanelHeight)
    updatePanelHeight()
end)

do
    local stealerGui = Instance.new("ScreenGui")
    stealerGui.Name = "wxrldzStealerPanel"
    stealerGui.ResetOnSpawn = false
    stealerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    stealerGui.DisplayOrder = 999
    stealerGui.Enabled = Config.UIVisible and Config.UIVisible.StealerPanel or false
    stealerGui.Parent = PlayerGui

    local spFrame = Instance.new("Frame")
    spFrame.Size = UDim2.new(0, 215, 0, 44)
    spFrame.Position = UDim2.new(Config.Positions.StealerPanel.X, 0, Config.Positions.StealerPanel.Y, 0)
    spFrame.BackgroundColor3 = Theme.Background
    spFrame.BackgroundTransparency = 0
    spFrame.BorderSizePixel = 0
    spFrame.ClipsDescendants = false
    spFrame.Active = false
    spFrame.Parent = stealerGui
    if IS_MOBILE then
        local _spScale = Instance.new("UIScale", spFrame)
        _spScale.Scale = 0.72
    end
    Instance.new("UICorner", spFrame).CornerRadius = UDim.new(0, 8)
    local _spStroke = Instance.new("UIStroke", spFrame)
    _spStroke.Color = Theme.Accent1
    _spStroke.Thickness = 1
    _spStroke.Transparency = 0.7

    local _spAccent = Instance.new("Frame", spFrame)
    _spAccent.Size = UDim2.new(1, 0, 0, 4)
    _spAccent.Position = UDim2.new(0, 0, 0, 0)
    _spAccent.BackgroundColor3 = Theme.Accent1
    _spAccent.BorderSizePixel = 0
    Instance.new("UICorner", _spAccent).CornerRadius = UDim.new(0, 8)
    SharedState.StealerPanelAccentBar = _spAccent

    local spHeader = Instance.new("Frame", spFrame)
    spHeader.Size = UDim2.new(1, 0, 0, 36)
    spHeader.Position = UDim2.new(0, 0, 0, 3)
    spHeader.BackgroundTransparency = 1
    spHeader.Active = true
    MakeDraggable(spHeader, spFrame, "StealerPanel")
    RegisterClamp(spFrame)
    stealerGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if stealerGui.Enabled then ClampFrameToScreen(spFrame) end
    end)

    local _spTitle = Instance.new("TextLabel", spHeader)
    _spTitle.Size = UDim2.new(1, -80, 1, 0)
    _spTitle.Position = UDim2.new(0, 10, 0, 0)
    _spTitle.BackgroundTransparency = 1
    _spTitle.Text = "STEALERS"
    _spTitle.Font = Enum.Font.GothamBold
    _spTitle.TextSize = 13
    _spTitle.TextColor3 = Theme.Accent1
    _spTitle.TextXAlignment = Enum.TextXAlignment.Left

    local _spCount = Instance.new("TextLabel", spHeader)
    _spCount.Size = UDim2.new(0, 24, 0, 18)
    _spCount.Position = UDim2.new(0, 80, 0.5, -9)
    _spCount.BackgroundColor3 = Theme.SurfaceHighlight
    _spCount.BackgroundTransparency = 0.3
    _spCount.Text = "0"
    _spCount.Font = Enum.Font.GothamBold
    _spCount.TextSize = 10
    _spCount.TextColor3 = Theme.Accent1
    _spCount.BorderSizePixel = 0
    Instance.new("UICorner", _spCount).CornerRadius = UDim.new(1, 0)

    local _spClose = Instance.new("TextButton", spHeader)
    _spClose.Size = UDim2.new(0, 20, 0, 20)
    _spClose.Position = UDim2.new(1, -24, 0.5, -10)
    _spClose.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    _spClose.Text = "×"
    _spClose.Font = Enum.Font.GothamBold
    _spClose.TextSize = 14
    _spClose.TextColor3 = Theme.Accent1
    _spClose.BorderSizePixel = 0
    _spClose.AutoButtonColor = false
    _spClose.Active = true
    Instance.new("UICorner", _spClose).CornerRadius = UDim.new(1, 0)
    _spClose.MouseButton1Click:Connect(function()
        stealerGui.Enabled = false
        if not Config.UIVisible then Config.UIVisible = {} end
        Config.UIVisible.StealerPanel = false
        SaveConfig()
    end)

    local _spSep = Instance.new("Frame", spFrame)
    _spSep.Size = UDim2.new(1, -16, 0, 1)
    _spSep.Position = UDim2.new(0, 8, 0, 39)
    _spSep.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    _spSep.BorderSizePixel = 0

    local spList = Instance.new("Frame", spFrame)
    spList.Size = UDim2.new(1, 0, 0, 0)
    spList.Position = UDim2.new(0, 0, 0, 42)
    spList.BackgroundTransparency = 1
    spList.BorderSizePixel = 0

    local spLayout = Instance.new("UIListLayout", spList)
    spLayout.Padding = UDim.new(0, 4)
    spLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local spPad = Instance.new("UIPadding", spList)
    spPad.PaddingLeft = UDim.new(0, 6)
    spPad.PaddingRight = UDim.new(0, 6)
    spPad.PaddingTop = UDim.new(0, 4)
    spPad.PaddingBottom = UDim.new(0, 6)

    local _spEmpty = Instance.new("TextLabel", spList)
    _spEmpty.Size = UDim2.new(1, 0, 0, 28)
    _spEmpty.BackgroundTransparency = 1
    _spEmpty.Text = "No stealers detected"
    _spEmpty.Font = Enum.Font.GothamMedium
    _spEmpty.TextSize = 11
    _spEmpty.TextColor3 = Color3.fromRGB(60, 65, 90)
    _spEmpty.TextXAlignment = Enum.TextXAlignment.Center

    local function updateSpSize()
        local h = spLayout.AbsoluteContentSize.Y + 14
        spFrame.Size = UDim2.new(0, 215, 0, 44 + math.max(h, 36))
        spList.Size = UDim2.new(1, 0, 0, math.max(h, 36))
    end
    spLayout.Changed:Connect(updateSpSize)

    local function spIsBlacklisted(plr)
        return Config.Blacklist and Config.Blacklist[tostring(plr.UserId)] ~= nil
    end

    local stealerRows = {}

    local function createStealerRow(plr, petName)
        if stealerRows[plr.UserId] then return end
        local bl = spIsBlacklisted(plr)

        local row = Instance.new("Frame", spList)
        row.Name = tostring(plr.UserId)
        row.Size = UDim2.new(1, 0, 0, bl and 38 or 54)
        row.BackgroundColor3 = bl and Color3.fromRGB(50, 10, 10) or Color3.fromRGB(14, 16, 26)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.LayoutOrder = bl and 1000 or 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

        local _rowAccent = Instance.new("Frame", row)
        _rowAccent.Size = UDim2.new(0, 3, 1, -8)
        _rowAccent.Position = UDim2.new(0, 0, 0, 4)
        _rowAccent.BackgroundColor3 = bl and Color3.fromRGB(220, 60, 60) or Theme.Accent1
        _rowAccent.BorderSizePixel = 0
        Instance.new("UICorner", _rowAccent).CornerRadius = UDim.new(0, 4)

        -- Avatar headshot
        local _avatar = Instance.new("ImageLabel", row)
        _avatar.Size = UDim2.new(0, 36, 0, 36)
        _avatar.Position = UDim2.new(0, 6, 0.5, -18)
        _avatar.BackgroundColor3 = Color3.fromRGB(20, 22, 32)
        _avatar.BorderSizePixel = 0
        _avatar.Image = ""
        Instance.new("UICorner", _avatar).CornerRadius = UDim.new(0, 5)
        local _avatarStroke = Instance.new("UIStroke", _avatar)
        _avatarStroke.Color = bl and Color3.fromRGB(200, 50, 50) or Theme.Accent1
        _avatarStroke.Thickness = 1
        _avatarStroke.Transparency = 0.4
        task.spawn(function()
            local ok, img = pcall(function()
                return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and img and _avatar.Parent then _avatar.Image = img end
        end)

        local _rowName = Instance.new("TextLabel", row)
        _rowName.Size = UDim2.new(1, -90, 0, 16)
        _rowName.Position = UDim2.new(0, 48, 0, 4)
        _rowName.BackgroundTransparency = 1
        _rowName.Text = plr.Name
        _rowName.Font = Enum.Font.GothamBold
        _rowName.TextSize = 11
        _rowName.TextColor3 = bl and Color3.fromRGB(255, 100, 100) or Theme.TextPrimary
        _rowName.TextXAlignment = Enum.TextXAlignment.Left
        _rowName.TextTruncate = Enum.TextTruncate.AtEnd

        local _tpBtn = Instance.new("TextButton", row)
        _tpBtn.Size = UDim2.new(0, 34, 0, 18)
        _tpBtn.Position = UDim2.new(1, -38, 0, 4)
        _tpBtn.BackgroundColor3 = Color3.fromRGB(10, 30, 50)
        _tpBtn.Text = "TP"
        _tpBtn.Font = Enum.Font.GothamBold
        _tpBtn.TextSize = 10
        _tpBtn.TextColor3 = Theme.Accent1
        _tpBtn.BorderSizePixel = 0
        _tpBtn.AutoButtonColor = false
        _tpBtn.Active = true
        Instance.new("UICorner", _tpBtn).CornerRadius = UDim.new(0, 5)
        local _tpStroke = Instance.new("UIStroke", _tpBtn)
        _tpStroke.Color = Theme.Accent1; _tpStroke.Thickness = 1; _tpStroke.Transparency = 0.5
        _tpBtn.MouseButton1Click:Connect(function()
            if not plr or not plr.Parent then ShowNotification("TP", "Player left"); return end
            if _G.tpToPlayerBase then _G.tpToPlayerBase(plr) end
        end)

        local _rowPet = Instance.new("TextLabel", row)
        _rowPet.Size = UDim2.new(1, -50, 0, 11)
        _rowPet.Position = UDim2.new(0, 48, 0, 21)
        _rowPet.BackgroundTransparency = 1
        _rowPet.Text = petName or "Unknown"
        _rowPet.Font = Enum.Font.GothamMedium
        _rowPet.TextSize = 9
        _rowPet.TextColor3 = Color3.fromRGB(80, 140, 180)
        _rowPet.TextXAlignment = Enum.TextXAlignment.Left
        _rowPet.TextTruncate = Enum.TextTruncate.AtEnd

        if bl then
            local _blBadge = Instance.new("TextLabel", row)
            _blBadge.Size = UDim2.new(1, -16, 0, 18)
            _blBadge.Position = UDim2.new(0, 8, 1, -22)
            _blBadge.BackgroundColor3 = Color3.fromRGB(90, 15, 15)
            _blBadge.BackgroundTransparency = 0.1
            _blBadge.Text = "BLACKLISTED — cannot AP"
            _blBadge.Font = Enum.Font.GothamBold
            _blBadge.TextSize = 9
            _blBadge.TextColor3 = Color3.fromRGB(255, 100, 100)
            _blBadge.BorderSizePixel = 0
            Instance.new("UICorner", _blBadge).CornerRadius = UDim.new(0, 4)
        else
            -- Individual command buttons row
            local cmdDefs = {
                {icon="🚀", cmd="rocket"},
                {icon="🏃", cmd="ragdoll"},
                {icon="🔒", cmd="jail"},
                {icon="🎈", cmd="balloon"},
            }
            local btnW = 22
            local btnGap = 3
            for i, def in ipairs(cmdDefs) do
                local cb = Instance.new("TextButton", row)
                cb.Size = UDim2.new(0, btnW, 0, 20)
                cb.Position = UDim2.new(0, 48 + (i-1)*(btnW+btnGap), 0, 33)
                cb.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
                cb.Text = def.icon
                cb.TextSize = 13
                cb.Font = Enum.Font.GothamMedium
                cb.BorderSizePixel = 0
                cb.AutoButtonColor = false
                cb.Active = true
                Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5)
                local cbStroke = Instance.new("UIStroke", cb)
                cbStroke.Color = Theme.Accent1
                cbStroke.Thickness = 1
                cbStroke.Transparency = 0.6
                cb.MouseEnter:Connect(function()
                    cbStroke.Transparency = 0.1
                    cb.BackgroundColor3 = Color3.fromRGB(25, 28, 45)
                end)
                cb.MouseLeave:Connect(function()
                    cbStroke.Transparency = 0.6
                    cb.BackgroundColor3 = Color3.fromRGB(18, 20, 30)
                end)
                cb.MouseButton1Click:Connect(function()
                    if not plr or not plr.Parent then return end
                    if spIsBlacklisted(plr) then ShowNotification("STEALERS", plr.Name .. " is blacklisted"); return end
                    local fn = _G.runAdminCommand
                    if fn and fn(plr, def.cmd) then
                        ShowNotification("STEALERS", def.cmd .. " → " .. plr.Name)
                    end
                end)
            end

            -- Trigger All button
            local _allBtn = Instance.new("TextButton", row)
            local allX = 48 + #cmdDefs * (btnW + btnGap) + 4
            _allBtn.Size = UDim2.new(1, -(allX + 8), 0, 20)
            _allBtn.Position = UDim2.new(0, allX, 0, 33)
            _allBtn.BackgroundColor3 = Color3.fromRGB(50, 10, 10)
            _allBtn.Text = "ALL"
            _allBtn.Font = Enum.Font.GothamBold
            _allBtn.TextSize = 9
            _allBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
            _allBtn.BorderSizePixel = 0
            _allBtn.AutoButtonColor = false
            _allBtn.Active = true
            Instance.new("UICorner", _allBtn).CornerRadius = UDim.new(0, 5)
            local _allStroke = Instance.new("UIStroke", _allBtn)
            _allStroke.Color = Color3.fromRGB(220, 60, 60)
            _allStroke.Thickness = 1
            _allStroke.Transparency = 0.4
            _allBtn.MouseButton1Click:Connect(function()
                if not plr or not plr.Parent then return end
                if spIsBlacklisted(plr) then ShowNotification("STEALERS", plr.Name .. " is blacklisted"); return end
                local fn = _G.runAdminCommand
                if fn then
                    local cmds = {"balloon","inverse","jail","jumpscare","morph","nightvision","ragdoll","rocket","tiny"}
                    for i, cmd in ipairs(cmds) do
                        task.delay((i-1)*0.1, function()
                            if plr and plr.Parent then fn(plr, cmd) end
                        end)
                    end
                    ShowNotification("STEALERS", "ALL triggered on " .. plr.Name)
                end
            end)
        end

        stealerRows[plr.UserId] = row
        _spEmpty.Visible = false
        updateSpSize()
    end

    local function removeStealerRow(userId)
        local row = stealerRows[userId]
        if row and row.Parent then row:Destroy() end
        stealerRows[userId] = nil
        local hasAny = false
        for _ in pairs(stealerRows) do hasAny = true; break end
        _spEmpty.Visible = not hasAny
        _spCount.Text = tostring(hasAny and (function() local c=0; for _ in pairs(stealerRows) do c=c+1 end; return c end)() or 0)
        updateSpSize()
    end

    local stealingPlayers = {}
    local playerConns = {}

    local function onStealerAdded(plr)
        if plr == LocalPlayer then return end
        local function check()
            local stealing = plr:GetAttribute("Stealing")
            local petName = plr:GetAttribute("StealingIndex") or "Unknown"
            if stealing and not stealingPlayers[plr.UserId] then
                stealingPlayers[plr.UserId] = true
                local c = 0; for _ in pairs(stealerRows) do c = c + 1 end
                _spCount.Text = tostring(c + 1)
                createStealerRow(plr, petName)
            elseif not stealing and stealingPlayers[plr.UserId] then
                stealingPlayers[plr.UserId] = nil
                removeStealerRow(plr.UserId)
            end
        end
        local conn = plr:GetAttributeChangedSignal("Stealing"):Connect(check)
        playerConns[plr.UserId] = conn
        check()
    end

    local function onStealerRemoved(plr)
        if playerConns[plr.UserId] then
            playerConns[plr.UserId]:Disconnect()
            playerConns[plr.UserId] = nil
        end
        stealingPlayers[plr.UserId] = nil
        removeStealerRow(plr.UserId)
    end

    for _, plr in ipairs(Players:GetPlayers()) do
        task.spawn(onStealerAdded, plr)
    end
    Players.PlayerAdded:Connect(onStealerAdded)
    Players.PlayerRemoving:Connect(onStealerRemoved)

    _G.toggleStealerPanel = function()
        stealerGui.Enabled = not stealerGui.Enabled
        if not Config.UIVisible then Config.UIVisible = {} end
        Config.UIVisible.StealerPanel = stealerGui.Enabled
        SaveConfig()
    end
end

local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100)
}

local BASES_HIGH = {
    [1] = Vector3.new(-476.474853515625, 20.732906341552734, 220.94090270996094), [5] = Vector3.new(-342.5367126464844, 20.69801902770996, 221.44737243652344),
    [2] = Vector3.new(-476.5684814453125, 20.70664405822754, 113.77315521240234), [6] = Vector3.new(-342.8604736328125, 20.669641494750977, 113.41409301757812),
    [3] = Vector3.new(-476.8675842285156, 20.74148178100586, 6.178487777709961),  [7] = Vector3.new(-342.42108154296875, 20.687667846679688, 6.249461650848389),
    [4] = Vector3.new(-476.6324768066406, 20.744949340820312, -101.07275390625),  [8] = Vector3.new(-342.7937927246094, 20.748071670532227, -99.73458862304688)
}

local CLONE_POSITIONS_FLOOR = {
    Vector3.new(-476, -4, 221), Vector3.new(-476, -4, 114),
    Vector3.new(-476, -4, 7),   Vector3.new(-476, -4, -100),
    Vector3.new(-342, -4, -100),Vector3.new(-342, -4, 6),
    Vector3.new(-342, -4, 114), Vector3.new(-342, -4, 220)
}

local FACE_TARGETS = {
    Vector3.new(-519, -3, 221), Vector3.new(-519, -3, 114),
    Vector3.new(-518, -3, 7),   Vector3.new(-519, -3, -100),
    Vector3.new(-301, -3, -100),Vector3.new(-301, -3, 7),
    Vector3.new(-302, -3, 114), Vector3.new(-300, -3, 220)
}

task.spawn(function()
    local plotLabels = {}
    for i = 1, 8 do
        local bp = BASES_LOW[i]
        if not bp then continue end
        local part = Instance.new("Part")
        part.Size = Vector3.new(1, 1, 1)
        part.Anchored = true
        part.CanCollide = false
        part.Transparency = 1
        part.Position = Vector3.new(bp.X, 35, bp.Z)
        part.Parent = workspace

        local bb = Instance.new("BillboardGui", part)
        bb.Size = UDim2.new(0, 60, 0, 40)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 0, 0)
        bb.AlwaysOnTop = false
        bb.ResetOnSpawn = false

        local lbl = Instance.new("TextLabel", bb)
        lbl.Size = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = tostring(i)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 28
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeTransparency = 0
        lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        table.insert(plotLabels, part)
    end
end)

local TeleportData = {
    bodyController = nil,
}
local bodyController = TeleportData.bodyController
local floatActive = State.floatActive

task.spawn(function()
    local plr = LocalPlayer
    if not plr then return end
    _G.FloatEnabled = _G.FloatEnabled or false
    local floatPlatform = nil
    local function getHRP()
        local c = plr.Character
        if not c then return end
        return c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso")
    end
    local stopFloat
    local function startFloat()
        if floatPlatform then floatPlatform:Destroy() end
        floatPlatform = Instance.new("Part")
        floatPlatform.Size = Vector3.new(6, 1, 6)
        floatPlatform.Anchored = true
        floatPlatform.CanCollide = true
        floatPlatform.Transparency = 1
        floatPlatform.Parent = workspace
        task.spawn(function()
            while _G.FloatEnabled and floatPlatform do
                if plr:GetAttribute("Stealing") then
                    stopFloat()
                    if _G.updateFloatPanelToggle then
                        pcall(function() _G.updateFloatPanelToggle(false) end)
                    end
                    break
                end
                local hrp = getHRP()
                if hrp then
                    floatPlatform.Position = hrp.Position - Vector3.new(0, 3, 0)
                end
                task.wait(0.05)
            end
        end)
    end
    stopFloat = function()
        _G.FloatEnabled = false
        if floatPlatform then
            floatPlatform:Destroy()
            floatPlatform = nil
        end
        if _G.updateMovementPanelFloatVisual then pcall(_G.updateMovementPanelFloatVisual, false) end
    end
    _G.enableFloat = function()
        _G.FloatEnabled = true
        startFloat()
        if _G.updateMovementPanelFloatVisual then pcall(_G.updateMovementPanelFloatVisual, true) end
    end
    _G.disableFloat = function()
        stopFloat()
        if _G.updateMovementPanelFloatVisual then pcall(_G.updateMovementPanelFloatVisual, false) end
    end
    plr.CharacterAdded:Connect(function()
        if _G.FloatEnabled then
            stopFloat()
            if _G.updateFloatPanelToggle then
                pcall(function() _G.updateFloatPanelToggle(false) end)
            end
        end
    end)
    if IS_MOBILE then
        UserInputService.JumpRequest:Connect(function()
            if _G.FloatEnabled then
                stopFloat()
                if _G.updateFloatPanelToggle then
                    pcall(function() _G.updateFloatPanelToggle(false) end)
                end
            end
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == (Enum.KeyCode[Config.FloatKey] or Enum.KeyCode.G) then
        if _G.FloatEnabled then
            if _G.disableFloat then pcall(_G.disableFloat) end
        else
            if _G.enableFloat then pcall(_G.enableFloat) end
        end
        if _G.updateMovementPanelFloatVisual then pcall(_G.updateMovementPanelFloatVisual, _G.FloatEnabled) end
        ShowNotification("FLOAT", _G.FloatEnabled and "ENABLED" or "DISABLED")
    end
end)

function getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
end

-- TP to a player's base using carpet logic (called from admin panel TP button)
_G.tpToPlayerBase = function(plr)
    if not plr or not plr.Parent then
        ShowNotification("TP", "Player not in server"); return
    end
    task.spawn(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end

        -- Find the player's plot by searching all text in Workspace.Plots
        local targetBasePos = nil
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            local searchNames = {plr.DisplayName:lower(), plr.Name:lower()}
            for _, plot in ipairs(Plots:GetChildren()) do
                local found = false
                for _, desc in ipairs(plot:GetDescendants()) do
                    if (desc:IsA("TextLabel") or desc:IsA("TextBox")) and desc.Text ~= "" then
                        local txt = desc.Text:lower()
                        for _, nm in ipairs(searchNames) do
                            if nm ~= "" and txt:find(nm, 1, true) then
                                found = true; break
                            end
                        end
                    end
                    if found then break end
                end
                if found then
                    -- Get a reference position from the plot's parts
                    local refPos = nil
                    for _, p in ipairs(plot:GetDescendants()) do
                        if p:IsA("BasePart") then refPos = p.Position; break end
                    end
                    if refPos then
                        local idx = getClosestBaseIdx(refPos)
                        local isHigh = refPos.Y > 10
                        targetBasePos = isHigh and BASES_HIGH[idx] or BASES_LOW[idx]
                    end
                    break
                end
            end
        end
        -- Fallback: closest base to player's character
        if not targetBasePos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local pos = plr.Character.HumanoidRootPart.Position
            local idx = getClosestBaseIdx(pos)
            local isHigh = pos.Y > 10
            targetBasePos = isHigh and BASES_HIGH[idx] or BASES_LOW[idx]
        end
        if not targetBasePos then
            ShowNotification("TP", "Base not found for " .. plr.Name); return
        end

        -- Equip carpet
        local carpetName = (Config.TpSettings and Config.TpSettings.Tool) or "Flying Carpet"
        local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
        if carpet then hum:EquipTool(carpet) end
        task.wait(0.01)

        -- Jump to height
        local targetHeight = math.max(targetBasePos.Y, 50)
        local jumpStart = tick()
        while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 3 do
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 550, hrp.AssemblyLinearVelocity.Z)
            RunService.Heartbeat:Wait()
        end

        -- TP to base position
        for i = 1, 10 do
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            if (hrp.Position - targetBasePos).Magnitude > 3 then
                hrp.CFrame = CFrame.new(targetBasePos)
                task.wait(0.05)
            end
        end

        -- Move to front entrance of base
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetBasePos - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        hrp.CFrame = CFrame.new(bestSpot)
        task.wait(0.05)

        -- Face into the base
        local bestFace = FACE_TARGETS[1]
        local minFaceDist = math.huge
        for _, v in ipairs(FACE_TARGETS) do
            local d = (hrp.Position - v).Magnitude
            if d < minFaceDist then minFaceDist = d; bestFace = v end
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))
        ShowNotification("TP", "TP'd to " .. plr.Name .. "'s base")
    end)
end

local isTpMoving = State.isTpMoving

_G._isTargetPlotUnlocked = function(plotName)
    local ok, res = pcall(function()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local targetPlot = plots:FindFirstChild(plotName)
        if not targetPlot then return false end
        local unlockFolder = targetPlot:FindFirstChild("Unlock")
        if not unlockFolder then return true end
        local unlockItems = {}
        for _, item in pairs(unlockFolder:GetChildren()) do
            local pos = nil
            if item:IsA("Model") then pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then pos = item.Position end
            if pos then table.insert(unlockItems, {Object = item, Height = pos.Y}) end
        end
        table.sort(unlockItems, function(a, b) return a.Height < b.Height end)
        if #unlockItems == 0 then return true end
        local floor1Door = unlockItems[1].Object
        for _, desc in ipairs(floor1Door:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then return false end
        end
        for _, child in ipairs(floor1Door:GetChildren()) do
            if child:IsA("ProximityPrompt") and child.Enabled then return false end
        end
        return true
    end)
    return ok and res or false
end

local lastKnownPetPositions = {}

local function runAutoSnipe()
    if State.isTpMoving then return end

    if State.carpetSpeedEnabled then
        setCarpetSpeed(false)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = "OFF"
            _carpetStatusLabel.TextColor3 = Theme.Error
        end
    end

    if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
    local targetPetData = SharedState.SelectedPetData.animalData
    if not targetPetData then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then return end

    -- If already on the pet, skip the TP and fire instantly
    local targetPart = findAdorneeGlobal(targetPetData)
    local exactPos
    if targetPart then
        exactPos = targetPart.Position
        lastKnownPetPositions[targetPetData.uid] = exactPos
    else
        -- Pet may be mid-steal (removed from plot) — use last known position
        exactPos = lastKnownPetPositions[targetPetData.uid]
    end

    if exactPos and (hrp.Position - exactPos).Magnitude < 20 then
        if SharedState.FireStealOnTarget then
            SharedState.FireStealOnTarget(targetPetData)
        end
        return
    end

    State.isTpMoving = true
    isTpMoving = State.isTpMoving

    if not exactPos then
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        return
    end
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")

    if carpet then hum:EquipTool(carpet) end
    task.wait(0.01)
    local isSecondFloor = exactPos.Y > 10
    local plotIndex = getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]

    local minHeight = 50
    local targetHeight = math.max(targetBasePos.Y, minHeight)

    local _tpSpeedCfg = {
        [1]   = { yVel = 75,  walkTime = 0.70, waitWalk = 0.70, waitClone = 0.40 },
        [1.5] = { yVel = 110, walkTime = 0.62, waitWalk = 0.62, waitClone = 0.34 },
        [2]   = { yVel = 150, walkTime = 0.55, waitWalk = 0.55, waitClone = 0.28 },
        [2.5] = { yVel = 200, walkTime = 0.47, waitWalk = 0.48, waitClone = 0.23 },
        [3]   = { yVel = 260, walkTime = 0.40, waitWalk = 0.42, waitClone = 0.18 },
        [3.5] = { yVel = 335, walkTime = 0.34, waitWalk = 0.36, waitClone = 0.15 },
        [4]   = { yVel = 420, walkTime = 0.28, waitWalk = 0.30, waitClone = 0.12 },
    }
    local _spd = _tpSpeedCfg[math.clamp(math.floor((Config.TpSettings.TpSpeed or 2) * 2 + 0.5) / 2, 1, 4)]

    local jumpStart = tick()
    while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 3 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, _spd.yVel, hrp.AssemblyLinearVelocity.Z)
        RunService.Heartbeat:Wait()
    end

    for i = 1, 10 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        if (hrp.Position - targetBasePos).Magnitude > 3 then
            hrp.CFrame = CFrame.new(targetBasePos)
            task.wait(0.05)
        end
    end

    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (exactPos - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        hrp.CFrame = CFrame.new(bestSpot)
        task.wait(0.05)
    end

    local bestFace = FACE_TARGETS[1]
    local minFaceDist = math.huge
    for _, v in ipairs(FACE_TARGETS) do
        local d = (hrp.Position - v).Magnitude
        if d < minFaceDist then
            minFaceDist = d
            bestFace = v
        end
    end

    task.wait(0.01)
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))

    local targetPlotUnlocked = _G._isTargetPlotUnlocked(targetPetData.plot)

    if targetPlotUnlocked and not isSecondFloor then
        pcall(function()
            local directChar = LocalPlayer.Character
            if not directChar then return end
            local directHRP = directChar:FindFirstChild("HumanoidRootPart")
            local directHumanoid = directChar:FindFirstChildOfClass("Humanoid")
            if not directHRP or not directHumanoid then return end
            local bp = LocalPlayer:FindFirstChild("Backpack")
            if bp then
                local c = bp:FindFirstChild(Config.TpSettings.Tool or "Flying Carpet")
                if c then directHumanoid:EquipTool(c) end
            end
            directHRP.AssemblyLinearVelocity = Vector3.zero
            directHRP.AssemblyAngularVelocity = Vector3.zero
            local _fd = (Vector3.new(targetBasePos.X, 0, targetBasePos.Z) - Vector3.new(exactPos.X, 0, exactPos.Z))
            if _fd.Magnitude < 0.1 then _fd = Vector3.new(1, 0, 0) end
            _fd = _fd.Unit * 3
            local frontPos = Vector3.new(exactPos.X + _fd.X, directHRP.Position.Y, exactPos.Z + _fd.Z)
            directHRP.CFrame = CFrame.lookAt(frontPos, Vector3.new(exactPos.X, directHRP.Position.Y, exactPos.Z))
            directHRP.AssemblyLinearVelocity = Vector3.zero
            directHRP.AssemblyAngularVelocity = Vector3.zero
        end)
        if SharedState.FireStealOnTarget then SharedState.FireStealOnTarget(targetPetData) end
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        return
    end

    if isSecondFloor or not targetPlotUnlocked then
        walkForward(_spd.walkTime)
        task.wait(_spd.waitWalk)
        local posBeforeClone = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or hrp.Position
        instantClone()
        task.wait(_spd.waitClone)

        local newChar, newHRP, newHumanoid
        local cloneTimeout = os.clock() + 3
        while os.clock() < cloneTimeout do
            newChar = LocalPlayer.Character
            if newChar then
                newHRP = newChar:FindFirstChild("HumanoidRootPart")
                if newHRP and (newHRP.Position - posBeforeClone).Magnitude > 0.3 then
                    break
                end
            end
            task.wait()
        end
        if not newChar then newChar = LocalPlayer.CharacterAdded:Wait() end
        newHRP = newChar and newChar:WaitForChild("HumanoidRootPart", 3)
        newHumanoid = newChar and newChar:WaitForChild("Humanoid", 3)
        local distMoved = newHRP and (newHRP.Position - posBeforeClone).Magnitude or 0
        if distMoved < 0.3 or not newHRP or not newHumanoid then
            State.isTpMoving = false
            isTpMoving = State.isTpMoving
            return
        end

        -- Fire steal immediately on spawn — fireproximityprompt ignores distance
        if SharedState.FireStealOnTarget then SharedState.FireStealOnTarget(targetPetData) end

        local inPlotRadius = false
        local plotsFolder = Workspace:FindFirstChild("Plots")
        if plotsFolder then
            local pos = newHRP.Position
            for _, plot in ipairs(plotsFolder:GetChildren()) do
                pcall(function()
                    local plotPos = plot:GetPivot().Position
                    local xDist = math.abs(pos.X - plotPos.X)
                    local zDist = math.abs(pos.Z - plotPos.Z)
                    if xDist < 23 and zDist < 23 then
                        inPlotRadius = true
                    end
                end)
                if inPlotRadius then break end
            end
        end

        if inPlotRadius then
            if SharedState.FireStealOnTarget then SharedState.FireStealOnTarget(targetPetData) end
            pcall(function()
                local bp = LocalPlayer:FindFirstChild("Backpack")
                if bp then
                    local c = bp:FindFirstChild(Config.TpSettings.Tool or "Flying Carpet")
                    if c then newHumanoid:EquipTool(c) end
                end
            end)

            local itemPos = (targetPart and targetPart.Parent and targetPart.Position) or exactPos
            local itemHeight = itemPos.Y
            local targetY = newHRP.Position.Y
            if itemHeight > 23.15 then
                targetY = 21
            elseif itemHeight >= 11 and itemHeight <= 23.15 then
                targetY = 14.5
            elseif itemHeight >= -6.9 and itemHeight <= 8.9 then
                targetY = -4
            end

            local _fd2 = (Vector3.new(targetBasePos.X, 0, targetBasePos.Z) - Vector3.new(itemPos.X, 0, itemPos.Z))
            if _fd2.Magnitude < 0.1 then _fd2 = Vector3.new(1, 0, 0) end
            _fd2 = _fd2.Unit * 3
            local holdX, holdY, holdZ = itemPos.X + _fd2.X, targetY, itemPos.Z + _fd2.Z
            local lookTarget = Vector3.new(itemPos.X, holdY, itemPos.Z)
            for i = 1, 10 do
                newHRP.AssemblyLinearVelocity = Vector3.zero
                newHRP.AssemblyAngularVelocity = Vector3.zero
                newHRP.CFrame = CFrame.lookAt(Vector3.new(holdX, holdY, holdZ), lookTarget)
                newHRP.AssemblyLinearVelocity = Vector3.zero
                newHRP.AssemblyAngularVelocity = Vector3.zero
                if SharedState.FireStealOnTarget then SharedState.FireStealOnTarget(targetPetData) end
                RunService.Heartbeat:Wait()
            end

            if inPlotRadius and newHRP and itemHeight > 23.15 then
                task.wait(0.05)
                if _G.enableFloat then
                    pcall(_G.enableFloat)
                end
            end
        end
    end

    State.isTpMoving = false
    isTpMoving = State.isTpMoving
end

local resetFlyingItems = { "Flying Carpet", "Cupid's Wings", "Broom" }

local function resetFindAndEquipFlying(character)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    local equipped = humanoid:FindFirstChildOfClass("Tool")
    for _, itemName in ipairs(resetFlyingItems) do
        local item = backpack:FindFirstChild(itemName)
        if item and (item:IsA("Tool") or item:IsA("HopperBin")) then
            if equipped then equipped.Parent = backpack end
            humanoid:EquipTool(item)
            return
        end
    end
end


local function executeReset()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")
    if not (humanoid and root) then return end
    resetFindAndEquipFlying(character)
    root.CFrame = CFrame.new(0, 5000, 0)
    _G.AntiDieDisabled = true
    humanoid.Health = 0
    LocalPlayer.CharacterAdded:Wait()
    _G.AntiDieDisabled = false
end

task.spawn(function()
    local balloonPhrase = 'ran "balloon" on you'
    local lastReset = 0
    while true do
        task.wait(1)
        if not Config.AutoResetOnBalloon then continue end
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
            if txt and string.find(txt, balloonPhrase) then
                if tick() - lastReset > 10 then
                    lastReset = tick()
                    executeReset()
                end
                break
            end
        end
    end
end)


UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if UserInputService:GetFocusedTextBox() then return end

    local tpKey = Enum.KeyCode[Config.TpSettings.TpKey] or Enum.KeyCode.T
    local cloneKey = Enum.KeyCode[Config.TpSettings.CloneKey] or Enum.KeyCode.V

    if input.KeyCode == tpKey then
        runAutoSnipe()
    end

    if input.KeyCode == cloneKey then
        task.spawn(instantClone)
    end
    
    if input.KeyCode == (Enum.KeyCode[Config.TpSettings.CarpetSpeedKey] or Enum.KeyCode.Q) then
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = carpetSpeedEnabled and "ON" or "OFF"
            _carpetStatusLabel.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.Error
        end
        ShowNotification("CARPET SPEED", carpetSpeedEnabled and ("ON  |  "..Config.TpSettings.Tool.."  |  140") or "OFF")
    end

    if input.KeyCode == (Enum.KeyCode[Config.StealSpeedKey] or Enum.KeyCode.Z) then
        if SharedState.StealSpeedToggleFunc then
            SharedState.StealSpeedToggleFunc()
        end
    end

    if input.KeyCode == (Enum.KeyCode[Config.ResetKey] or Enum.KeyCode.X) then
        executeReset()
    end
    
    if pcall(function() return input.KeyCode == (Enum.KeyCode[Config.RagdollSelfKey] or Enum.KeyCode.R) end) and input.KeyCode == (Enum.KeyCode[Config.RagdollSelfKey] or Enum.KeyCode.R) then
        task.spawn(function()
            if _G.runAdminCommand then
                if _G.runAdminCommand(LocalPlayer, "ragdoll") then
                    ShowNotification("RAGDOLL SELF", "Triggered")
                else
                    ShowNotification("RAGDOLL SELF", "Failed")
                end
            else
                ShowNotification("RAGDOLL SELF", "Function not available")
            end
        end)
    end

end)

local settingsGui = UI.settingsGui


settingsGui = Instance.new("ScreenGui")
settingsGui.Name = "SettingsUI"; settingsGui.ResetOnSpawn = false; settingsGui.DisplayOrder = 999
settingsGui.Parent = PlayerGui; settingsGui.Enabled = Config.UIVisible and Config.UIVisible.Settings or false

local sFrame = Instance.new("Frame")
sFrame.Size = UDim2.new(0, 420, 0, 420)
sFrame.Position = UDim2.new(Config.Positions.Settings.X, 0, Config.Positions.Settings.Y, 0)
sFrame.BackgroundColor3 = Theme.Background; sFrame.BackgroundTransparency = 0
sFrame.BorderSizePixel = 0; sFrame.ClipsDescendants = true; sFrame.Active = not IS_MOBILE; sFrame.Parent = settingsGui

ApplyViewportUIScale(sFrame, 420, 420, 0.45, 0.85)
AddMobileMinimize(sFrame, "SETTINGS")
RegisterClamp(sFrame)
settingsGui:GetPropertyChangedSignal("Enabled"):Connect(function()
    if settingsGui.Enabled then ClampFrameToScreen(sFrame) end
end)

Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 4)
CreateAuroraBackground(sFrame)
local _ab = Instance.new("Frame", settingsGui); _ab.BackgroundTransparency = 1; _ab.BorderSizePixel = 0; _ab.ZIndex = 100
Instance.new("UICorner", _ab).CornerRadius = UDim.new(0, 4)
local sStroke = Instance.new("UIStroke", _ab); sStroke.Color = Color3.fromRGB(0, 210, 255); sStroke.Thickness = 1; sStroke.Transparency = 0.8
local function _absync()
    _ab.Size = UDim2.new(0, sFrame.AbsoluteSize.X, 0, sFrame.AbsoluteSize.Y)
    _ab.Position = UDim2.new(0, sFrame.AbsolutePosition.X, 0, sFrame.AbsolutePosition.Y)
    _ab.Visible = sFrame.Visible
end
_absync()
sFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_absync)
sFrame:GetPropertyChangedSignal("Position"):Connect(_absync)
sFrame:GetPropertyChangedSignal("Visible"):Connect(_absync)

do local _stars={{0.07,0.04,1,0.55,2.0},{0.23,0.09,2,0.35,3.2},{0.61,0.06,1,0.70,2.5},{0.84,0.12,1,0.40,4.1},{0.45,0.03,2,0.60,3.7},{0.92,0.20,1,0.30,2.8},{0.14,0.18,1,0.65,5.0},{0.50,0.15,2,0.45,2.3},{0.76,0.28,1,0.50,3.5},{0.32,0.22,1,0.75,4.6},{0.05,0.35,2,0.40,2.1},{0.68,0.38,1,0.55,3.0},{0.88,0.42,1,0.30,4.8},{0.40,0.44,2,0.65,2.7},{0.19,0.50,1,0.45,3.9},{0.55,0.52,1,0.70,5.0},{0.79,0.55,2,0.35,2.2},{0.30,0.60,1,0.60,3.3},{0.10,0.65,1,0.50,4.0},{0.63,0.62,2,0.40,2.9},{0.94,0.68,1,0.55,3.6},{0.47,0.70,1,0.30,2.4},{0.22,0.75,2,0.70,4.5},{0.72,0.72,1,0.45,3.1},{0.38,0.80,1,0.60,2.6},{0.85,0.78,2,0.35,5.0},{0.15,0.85,1,0.55,3.8},{0.56,0.82,1,0.40,2.2},{0.02,0.90,2,0.65,4.3},{0.70,0.88,1,0.50,3.0},{0.42,0.92,1,0.30,2.7},{0.90,0.95,2,0.70,4.7},{0.26,0.96,1,0.45,3.5},{0.60,0.96,1,0.55,2.0},{0.80,0.30,1,0.40,3.2},{0.35,0.32,2,0.65,4.4},{0.52,0.38,1,0.50,2.8},{0.17,0.42,1,0.30,5.0},{0.96,0.50,2,0.60,3.7},{0.44,0.58,1,0.45,2.3},{0.08,0.12,1,0.55,4.2},{0.74,0.18,2,0.35,3.0},{0.29,0.48,1,0.70,2.6},{0.66,0.76,1,0.40,4.9},{0.48,0.22,2,0.60,3.4}}; for _,s in ipairs(_stars) do local _d=Instance.new("Frame",sFrame); _d.Size=UDim2.new(0,s[3],0,s[3]); _d.Position=UDim2.new(s[1],0,s[2],0); _d.AnchorPoint=Vector2.new(0.5,0.5); _d.BackgroundColor3=Color3.fromRGB(220,235,255); _d.BackgroundTransparency=s[4]; _d.BorderSizePixel=0; _d.ZIndex=1; Instance.new("UICorner",_d).CornerRadius=UDim.new(1,0); TweenService:Create(_d,TweenInfo.new(s[5],Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=math.min(s[4]+0.45,0.95)}):Play() end end

local sHeader = Instance.new("Frame", sFrame)
sHeader.Size = UDim2.new(1,0,0,40); sHeader.BackgroundTransparency = 1
MakeDraggable(sHeader, sFrame, "Settings")
do local _rh = Instance.new("TextButton", sHeader); _rh.Size = UDim2.new(0,20,0,20); _rh.Position = UDim2.new(1,-24,0,10); _rh.BackgroundColor3 = Theme.SurfaceHighlight; _rh.Text = "↙"; _rh.Font = Enum.Font.GothamMedium; _rh.TextSize = 12; _rh.TextColor3 = Theme.Accent1; _rh.ZIndex = 10; Instance.new("UICorner", _rh).CornerRadius = UDim.new(1,0); MakeResizable(_rh, sFrame, 380, 640) end
local sTitle = Instance.new("TextLabel", sHeader)
sTitle.Size = UDim2.new(1,-20,1,0); sTitle.Position = UDim2.new(0,15,0,0)
sTitle.BackgroundTransparency = 1; sTitle.Text = "SETTINGS"
sTitle.Font = Enum.Font.GothamMedium; sTitle.TextSize = 16
sTitle.TextColor3 = Theme.TextPrimary; sTitle.TextXAlignment = Enum.TextXAlignment.Left

local sList = Instance.new("ScrollingFrame", sFrame)
sList.Size = UDim2.new(1,-20,1,-78); sList.Position = UDim2.new(0,10,0,73)
sList.BackgroundTransparency = 1; sList.BorderSizePixel = 0
sList.ScrollBarThickness = IS_MOBILE and 4 or 2; sList.ScrollBarImageColor3 = Theme.Accent1
sList.ScrollingEnabled = true
sList.ElasticBehavior = Enum.ElasticBehavior.Always
sList.ScrollingDirection = Enum.ScrollingDirection.Y

local sLayout = Instance.new("UIListLayout", sList)
sLayout.Padding = UDim.new(0,8); sLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Tab bar
local tabBtns = {}
local tabContainers = {}
local activeTabName = "General"
local curTabContainer
local updateSettingsCanvasSize
local function setActiveTab(name)
    activeTabName = name
    for n, c in pairs(tabContainers) do c.Visible = (n == name) end
    for n, b in pairs(tabBtns) do
        b.BackgroundColor3 = (n == name) and Theme.Accent1 or Theme.SurfaceHighlight
        b.TextColor3 = (n == name) and Color3.new(0,0,0) or Theme.TextPrimary
    end
    task.defer(function() if updateSettingsCanvasSize then updateSettingsCanvasSize() end end)
end
do
    local tabBar = Instance.new("Frame", sFrame)
    tabBar.Size = UDim2.new(1, -20, 0, 26)
    tabBar.Position = UDim2.new(0, 10, 0, 44)
    tabBar.BackgroundTransparency = 1
    local tbl = Instance.new("UIListLayout", tabBar)
    tbl.FillDirection = Enum.FillDirection.Horizontal
    tbl.Padding = UDim.new(0, 4)
    tbl.SortOrder = Enum.SortOrder.LayoutOrder
    local tabNames = {"General","Auto TP","Carpet","Movement","ESP","Auto Steal"}
    for i, tName in ipairs(tabNames) do
        local tb = Instance.new("TextButton", tabBar)
        tb.Size = UDim2.new(0, 52, 1, 0)
        tb.BackgroundColor3 = (i==1) and Theme.Accent1 or Theme.SurfaceHighlight
        tb.Text = tName; tb.Font = Enum.Font.GothamMedium; tb.TextSize = 9
        tb.TextColor3 = (i==1) and Color3.new(0,0,0) or Theme.TextPrimary
        Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 4)
        tb.MouseButton1Click:Connect(function() setActiveTab(tName) end)
        tabBtns[tName] = tb
        local cont = Instance.new("Frame", sList)
        cont.Size = UDim2.new(1, 0, 0, 0); cont.AutomaticSize = Enum.AutomaticSize.Y
        cont.BackgroundTransparency = 1; cont.Visible = (i == 1)
        local cl = Instance.new("UIListLayout", cont)
        cl.Padding = UDim.new(0, 8); cl.SortOrder = Enum.SortOrder.LayoutOrder
        tabContainers[tName] = cont
    end
end
curTabContainer = tabContainers["General"]

local function CreateToggleSwitch(parent, initialState, callback)
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,20); sw.Position = UDim2.new(1,-50,0.5,-10)
    sw.BackgroundColor3 = initialState and Theme.Accent1 or Theme.SurfaceHighlight
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0); sw.Parent = parent
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = initialState and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0); dot.Parent = sw
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = sw
    local isOn = initialState
    local function SetState(s)
        isOn = s
        local tp = isOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        local tc = isOn and Theme.Accent1 or Theme.SurfaceHighlight
        TweenService:Create(dot, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position=tp}):Play()
        TweenService:Create(sw,  TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3=tc}):Play()
    end
    btn.MouseButton1Click:Connect(function() callback(not isOn, SetState) end)
    return {Set=SetState, Container=sw}
end

local function CreateRow(text, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,height or 30); row.BackgroundColor3 = Theme.Surface
    row.BackgroundTransparency = 0.4
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium; lbl.TextColor3 = Theme.TextPrimary
    lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = curTabContainer; return row
end

local function CreateSectionHeader(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = sList
    
    local accent = Instance.new("Frame", row)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 4, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent1
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.TextSecondary
    lbl.TextSize = 10
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1, -80, 0, 1)
    line.Position = UDim2.new(0, 75, 0.5, 0)
    line.BackgroundColor3 = Theme.Accent1
    line.BackgroundTransparency = 0.85
    line.BorderSizePixel = 0
    
    return row
end

local espToggleRef = {enabled=true, setFn=nil}
local playerESPToggleRef = {setFn=nil}
local mutationESPToggleRef = {setFn=nil}
do 
curTabContainer = tabContainers["Auto TP"]
local rAutoTPLoad = CreateRow("Auto TP on Script Load")
CreateToggleSwitch(rAutoTPLoad, Config.TpSettings.TpOnLoad, function(ns, set)
    set(ns); Config.TpSettings.TpOnLoad = ns; SaveConfig()
    ShowNotification("AUTO TP ON LOAD", ns and "ENABLED" or "DISABLED")
end)
local rAutoSnipeOnReset = CreateRow("Auto TP On Reset")
CreateToggleSwitch(rAutoSnipeOnReset, Config.AutoSnipeOnReset or false, function(ns, set)
    set(ns)
    Config.AutoTpOnReset = ns
    SaveConfig()
    ShowNotification("AUTO SNIPE ON RESET", ns and "ENABLED" or "DISABLED")
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if Config.AutoTpOnReset then
        runAutoSnipe()
    end
end)


local rMinGen = CreateRow("Min Gen for Auto TP")
local minGenBox = Instance.new("TextBox", rMinGen)
minGenBox.Size = UDim2.new(0, 100, 0, 24)
minGenBox.Position = UDim2.new(1, -110, 0.5, -12)
minGenBox.BackgroundColor3 = Theme.SurfaceHighlight
minGenBox.Text = tostring(Config.TpSettings.MinGenForTp or "")
minGenBox.Font = Enum.Font.GothamMedium
minGenBox.TextSize = 11
minGenBox.TextColor3 = Theme.TextPrimary
minGenBox.PlaceholderText = "e.g. 5k, 1m, 1b"
Instance.new("UICorner", minGenBox).CornerRadius = UDim.new(0, 4)
minGenBox.FocusLost:Connect(function()
    local raw = minGenBox.Text:gsub("%s", "")
    Config.TpSettings.MinGenForTp = (raw == "" and "" or raw)
    SaveConfig()
    ShowNotification("MIN GEN FOR TP", Config.TpSettings.MinGenForTp == "" and "No minimum" or "Min: " .. (Config.TpSettings.MinGenForTp or ""))
end)

curTabContainer = tabContainers["Auto Steal"]
local rAutoStealMinGen = CreateRow("Auto Steal Min Gen")
local autoStealMinGenBox = Instance.new("TextBox", rAutoStealMinGen)
autoStealMinGenBox.Size = UDim2.new(0, 100, 0, 24)
autoStealMinGenBox.Position = UDim2.new(1, -110, 0.5, -12)
autoStealMinGenBox.BackgroundColor3 = Theme.SurfaceHighlight
autoStealMinGenBox.Text = tostring(Config.AutoStealMinGen or "")
autoStealMinGenBox.Font = Enum.Font.GothamMedium
autoStealMinGenBox.TextSize = 11
autoStealMinGenBox.TextColor3 = Theme.TextPrimary
autoStealMinGenBox.PlaceholderText = "e.g. 5k, 1m, 1b"
Instance.new("UICorner", autoStealMinGenBox).CornerRadius = UDim.new(0, 4)

autoStealMinGenBox.FocusLost:Connect(function()
    local raw = autoStealMinGenBox.Text:gsub("%s", "")
    Config.AutoStealMinGen = (raw == "" and "" or raw)
    SaveConfig()
    ShowNotification("AUTO STEAL MIN GEN", Config.AutoStealMinGen == "" and "No minimum" or "Min: " .. (Config.AutoStealMinGen or ""))
    if SharedState and SharedState.ListNeedsRedraw ~= nil then
        SharedState.ListNeedsRedraw = true
    end
end)

local rAutoBuyMinGen = CreateRow("Auto Buy Min Gen")
local abMinBox = Instance.new("TextBox", rAutoBuyMinGen)
abMinBox.Size = UDim2.new(0, 100, 0, 24)
abMinBox.Position = UDim2.new(1, -110, 0.5, -12)
abMinBox.BackgroundColor3 = Theme.SurfaceHighlight
abMinBox.Text = tostring(Config.AutoBuyMinGen or "")
abMinBox.Font = Enum.Font.GothamMedium
abMinBox.TextSize = 11
abMinBox.TextColor3 = Theme.TextPrimary
abMinBox.PlaceholderText = "e.g. 5k, 1m, 1b"
Instance.new("UICorner", abMinBox).CornerRadius = UDim.new(0, 4)
abMinBox.FocusLost:Connect(function()
    local raw = abMinBox.Text:gsub("%s", "")
    Config.AutoBuyMinGen = (raw == "" and "" or raw)
    _abLockedBest = nil
    SaveConfig()
    ShowNotification("AUTO BUY MIN GEN", Config.AutoBuyMinGen == "" and "No minimum" or "Min: " .. Config.AutoBuyMinGen)
end)

curTabContainer = tabContainers["ESP"]

local rTrace = CreateRow("Tracer Best Brainrot")
CreateToggleSwitch(rTrace, Config.TracerEnabled, function(ns, set)
    set(ns); Config.TracerEnabled = ns; SaveConfig()
    ShowNotification("TRACER", ns and "ENABLED" or "DISABLED")
end)

local rLineToBase = CreateRow("Line to base")
CreateToggleSwitch(rLineToBase, Config.LineToBase, function(ns, set)
    set(ns); Config.LineToBase = ns; SaveConfig()
    if not ns and _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
    ShowNotification("LINE TO BASE", ns and "ENABLED" or "DISABLED")
end)

local rXray = CreateRow("X-Ray")
CreateToggleSwitch(rXray, Config.XrayEnabled, function(ns, set)
    set(ns); Config.XrayEnabled = ns; if ns then enableXray() else disableXray() end; SaveConfig()
    ShowNotification("X-RAY", ns and "ENABLED" or "DISABLED")
end)

curTabContainer = tabContainers["Auto TP"]
local toolOptions = {"Flying Carpet", "Cupid's Wings", "Santa's Sleigh", "Witch's Broom"}
local toolSwitches = {}
for _, toolName in ipairs(toolOptions) do
    local r = CreateRow(toolName)
    local ts = CreateToggleSwitch(r, Config.TpSettings.Tool==toolName, function(rs, set)
        if rs then
            Config.TpSettings.Tool=toolName; SaveConfig(); set(true)
            for n, sw in pairs(toolSwitches) do if n~=toolName then sw.Set(false) end end
            ShowNotification("TP TOOL", toolName)
        else
            set(Config.TpSettings.Tool==toolName)
        end
    end)
    toolSwitches[toolName] = ts
end

local rTpSpeed = CreateRow("TP Speed (1-4) (Recommended 3)")
do
    local _tpspVal = Config.TpSettings.TpSpeed or 2.0
    local _tpspDisplay = Instance.new("TextLabel", rTpSpeed)
    _tpspDisplay.Size = UDim2.new(0, 36, 0, 24); _tpspDisplay.Position = UDim2.new(1, -90, 0.5, -12)
    _tpspDisplay.BackgroundColor3 = Color3.fromRGB(14, 16, 26); _tpspDisplay.BorderSizePixel = 0
    _tpspDisplay.Font = Enum.Font.GothamBold; _tpspDisplay.TextSize = 12
    _tpspDisplay.TextColor3 = Theme.Accent1; _tpspDisplay.BackgroundTransparency = 0
    _tpspDisplay.Text = string.format("%.1f", _tpspVal)
    Instance.new("UICorner", _tpspDisplay).CornerRadius = UDim.new(0, 6)
    local _tspStroke = Instance.new("UIStroke", _tpspDisplay)
    _tspStroke.Color = Theme.Accent1; _tspStroke.Thickness = 1; _tspStroke.Transparency = 0.6

    local function makeArrow(label, xOff, delta)
        local b = Instance.new("TextButton", rTpSpeed)
        b.Size = UDim2.new(0, 22, 0, 24); b.Position = UDim2.new(1, xOff, 0.5, -12)
        b.BackgroundColor3 = Color3.fromRGB(14, 16, 26); b.BorderSizePixel = 0
        b.Font = Enum.Font.GothamBold; b.TextSize = 13
        b.TextColor3 = Theme.Accent1; b.Text = label; b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
        local bs = Instance.new("UIStroke", b); bs.Color = Theme.Accent1; bs.Thickness = 1; bs.Transparency = 0.6
        b.MouseButton1Click:Connect(function()
            _tpspVal = math.clamp(math.floor((_tpspVal + delta) * 10 + 0.5) / 10, 1.0, 4.0)
            _tpspDisplay.Text = string.format("%.1f", _tpspVal)
            Config.TpSettings.TpSpeed = _tpspVal; SaveConfig()
            ShowNotification("TP SPEED", string.format("%.1f → %d velocity", _tpspVal, math.floor(_tpspVal * 100)))
        end)
    end
    makeArrow("▼", -52, -0.5)
    makeArrow("▲", -26, 0.5)
end

local rBind = CreateRow("TP Keybind")
local bBind = Instance.new("TextButton", rBind)
bBind.Size=UDim2.new(0,60,0,24); bBind.Position=UDim2.new(1,-70,0.5,-12)
bBind.BackgroundColor3=Theme.SurfaceHighlight; bBind.Text=Config.TpSettings.TpKey
bBind.Font=Enum.Font.GothamMedium; bBind.TextColor3=Theme.TextPrimary; bBind.TextSize=12
Instance.new("UICorner",bBind).CornerRadius=UDim.new(1, 0)
bBind.MouseButton1Click:Connect(function()
    bBind.Text="..."; bBind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.TpKey=inp.KeyCode.Name; bBind.Text=inp.KeyCode.Name
            bBind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("TP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rBindClone = CreateRow("Auto Clone Keybind")
local bBindClone = Instance.new("TextButton", rBindClone)
bBindClone.Size=UDim2.new(0,60,0,24); bBindClone.Position=UDim2.new(1,-70,0.5,-12)
bBindClone.BackgroundColor3=Theme.SurfaceHighlight; bBindClone.Text=Config.TpSettings.CloneKey
bBindClone.Font=Enum.Font.GothamMedium; bBindClone.TextColor3=Theme.TextPrimary; bBindClone.TextSize=12
Instance.new("UICorner",bBindClone).CornerRadius=UDim.new(1, 0)
bBindClone.MouseButton1Click:Connect(function()
    bBindClone.Text="..."; bBindClone.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CloneKey=inp.KeyCode.Name; bBindClone.Text=inp.KeyCode.Name
            bBindClone.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CLONE KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

curTabContainer = tabContainers["Carpet"]
local rCarpetBind = CreateRow("Carpet Speed Keybind")
local bCarpet = Instance.new("TextButton", rCarpetBind)
bCarpet.Size=UDim2.new(0,60,0,24); bCarpet.Position=UDim2.new(1,-70,0.5,-12)
bCarpet.BackgroundColor3=Theme.SurfaceHighlight; bCarpet.Text=Config.TpSettings.CarpetSpeedKey
bCarpet.Font=Enum.Font.GothamMedium; bCarpet.TextColor3=Theme.TextPrimary; bCarpet.TextSize=12
Instance.new("UICorner",bCarpet).CornerRadius=UDim.new(1, 0)
bCarpet.MouseButton1Click:Connect(function()
    bCarpet.Text="..."; bCarpet.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CarpetSpeedKey=inp.KeyCode.Name; bCarpet.Text=inp.KeyCode.Name
            bCarpet.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CARPET SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rRagdollSelf = CreateRow("Ragdoll Self Keybind")
local bRagdollSelf = Instance.new("TextButton", rRagdollSelf)
bRagdollSelf.Size=UDim2.new(0,60,0,24); bRagdollSelf.Position=UDim2.new(1,-70,0.5,-12)
bRagdollSelf.BackgroundColor3=Theme.SurfaceHighlight; bRagdollSelf.Text=Config.RagdollSelfKey ~= "" and Config.RagdollSelfKey or "NONE"
bRagdollSelf.Font=Enum.Font.GothamMedium; bRagdollSelf.TextColor3=Theme.TextPrimary; bRagdollSelf.TextSize=12
Instance.new("UICorner",bRagdollSelf).CornerRadius=UDim.new(1, 0)
bRagdollSelf.MouseButton1Click:Connect(function()
    bRagdollSelf.Text="..."; bRagdollSelf.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.RagdollSelfKey=inp.KeyCode.Name; bRagdollSelf.Text=inp.KeyCode.Name
            bRagdollSelf.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("RAGDOLL SELF KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rCarpetStatus = CreateRow("Carpet Speed Status")
local carpetStatusLbl = Instance.new("TextLabel", rCarpetStatus)
carpetStatusLbl.Size=UDim2.new(0,50,0,20); carpetStatusLbl.Position=UDim2.new(1,-60,0.5,-10)
carpetStatusLbl.BackgroundTransparency=1
carpetStatusLbl.Text=carpetSpeedEnabled and "ON" or "OFF"
carpetStatusLbl.TextColor3=carpetSpeedEnabled and Theme.Success or Theme.Error
carpetStatusLbl.Font=Enum.Font.GothamMedium; carpetStatusLbl.TextSize=13
carpetStatusLbl.TextXAlignment=Enum.TextXAlignment.Right
_carpetStatusLabel = carpetStatusLbl
SharedState._carpetStatusLabel = carpetStatusLbl


curTabContainer = tabContainers["Movement"]
local rInfJump = CreateRow("Infinite Jump")
CreateToggleSwitch(rInfJump, infiniteJumpEnabled, function(ns, set)
    set(ns); setInfiniteJump(ns)
    ShowNotification("INFINITE JUMP", ns and "ENABLED" or "DISABLED")
end)

local rStealSpeedKey = CreateRow("Steal Speed Keybind")
local bStealSpeedKey = Instance.new("TextButton", rStealSpeedKey)
bStealSpeedKey.Size=UDim2.new(0,60,0,24); bStealSpeedKey.Position=UDim2.new(1,-70,0.5,-12)
bStealSpeedKey.BackgroundColor3=Theme.SurfaceHighlight; bStealSpeedKey.Text=Config.StealSpeedKey
bStealSpeedKey.Font=Enum.Font.GothamMedium; bStealSpeedKey.TextColor3=Theme.TextPrimary; bStealSpeedKey.TextSize=12
Instance.new("UICorner",bStealSpeedKey).CornerRadius=UDim.new(1, 0)
bStealSpeedKey.MouseButton1Click:Connect(function()
    bStealSpeedKey.Text="..."; bStealSpeedKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.StealSpeedKey=inp.KeyCode.Name; bStealSpeedKey.Text=inp.KeyCode.Name
            bStealSpeedKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("STEAL SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

pcall(function()
local rFloatKey = CreateRow("Float Keybind")
local bFloatKey = Instance.new("TextButton", rFloatKey)
bFloatKey.Size=UDim2.new(0,60,0,24); bFloatKey.Position=UDim2.new(1,-70,0.5,-12)
bFloatKey.BackgroundColor3=Theme.SurfaceHighlight; bFloatKey.Text=Config.FloatKey
bFloatKey.Font=Enum.Font.GothamMedium; bFloatKey.TextColor3=Theme.TextPrimary; bFloatKey.TextSize=12
Instance.new("UICorner",bFloatKey).CornerRadius=UDim.new(1, 0)
bFloatKey.MouseButton1Click:Connect(function()
    bFloatKey.Text="..."; bFloatKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.FloatKey=inp.KeyCode.Name; bFloatKey.Text=inp.KeyCode.Name
            bFloatKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("FLOAT KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
end)
curTabContainer = tabContainers["Auto Steal"]
local rAdminListSize = CreateRow("Player List Size (1=Small, 4=Full)")
do
    local _als = math.clamp(Config.AdminListSize or 4, 1, 4)
    local _alSteps = {0.55, 0.70, 0.85, 1.0}
    local _alCont = Instance.new("Frame", rAdminListSize)
    _alCont.Size = UDim2.new(0, 108, 0, 24); _alCont.Position = UDim2.new(1, -118, 0.5, -12)
    _alCont.BackgroundTransparency = 1
    local _alBtns = {}
    for i = 1, 4 do
        local b = Instance.new("TextButton", _alCont)
        b.Size = UDim2.new(0.22, 0, 1, 0); b.Position = UDim2.new((i-1)*0.26, 0, 0, 0)
        b.BackgroundColor3 = (i == _als) and Theme.Accent1 or Theme.SurfaceHighlight
        b.Text = tostring(i); b.TextColor3 = (i == _als) and Color3.new(0,0,0) or Theme.TextPrimary
        b.Font = Enum.Font.GothamMedium; b.TextSize = 12; b.BorderSizePixel = 0
        Instance.new("UICorner", b).CornerRadius = UDim.new(1, 0)
        b.MouseButton1Click:Connect(function()
            _als = i; Config.AdminListSize = i; SaveConfig()
            for idx, btn in ipairs(_alBtns) do
                btn.BackgroundColor3 = (idx==i) and Theme.Accent1 or Theme.SurfaceHighlight
                btn.TextColor3 = (idx==i) and Color3.new(0,0,0) or Theme.TextPrimary
            end
            local sc = _alSteps[i]
            if _G._adminListUIScale then _G._adminListUIScale.Scale = sc end
            if _G._adminBLUIScale then _G._adminBLUIScale.Scale = sc end
            ShowNotification("LIST SIZE", "Set to " .. tostring(i))
        end)
        table.insert(_alBtns, b)
    end
end

local rAutoUnlock = CreateRow("Auto Unlock on Steal")
CreateToggleSwitch(rAutoUnlock, Config.AutoUnlockOnSteal, function(ns, set)
    set(ns); Config.AutoUnlockOnSteal = ns; SaveConfig()
    ShowNotification("AUTO UNLOCK", ns and "ENABLED" or "DISABLED")
end)

local rShowUnlockHUD = CreateRow("Show Unlock Buttons HUD")
CreateToggleSwitch(rShowUnlockHUD, Config.ShowUnlockButtonsHUD, function(ns, set)
    set(ns); Config.ShowUnlockButtonsHUD = ns; SaveConfig()
    if _G._unlockContainer then
        _G._unlockContainer.Visible = ns
    end
end)
curTabContainer = tabContainers["General"]
local arV1SetRef, arV2SetRef = {}, {}
local rAr = CreateRow("Anti-Ragdoll V1")
CreateToggleSwitch(rAr, Config.AntiRagdoll > 0, function(ns, set)
    arV1SetRef.fn = set
    if ns and Config.AntiRagdollV2 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V2 FIRST")
        return
    end
    set(ns)
    local mode = ns and 1 or 0
    Config.AntiRagdoll = mode
    if ns then
        Config.AntiRagdollV2 = false
        if arV2SetRef.fn then arV2SetRef.fn(false) end
    end
    SaveConfig()
    startAntiRagdoll(mode)
    if ns then startAntiRagdollV2(false) end
    ShowNotification("ANTI-RAGDOLL V1", ns and "ENABLED" or "DISABLED")
end)
local rArV2 = CreateRow("Anti-Ragdoll V2")
CreateToggleSwitch(rArV2, Config.AntiRagdollV2, function(ns, set)
    arV2SetRef.fn = set
    if ns and Config.AntiRagdoll > 0 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V1 FIRST")
        return
    end
    set(ns)
    Config.AntiRagdollV2 = ns
    if ns then
        Config.AntiRagdoll = 0
        SaveConfig()
        if arV1SetRef.fn then arV1SetRef.fn(false) end
        startAntiRagdoll(0)
        startAntiRagdollV2(true)
    else
        SaveConfig()
        startAntiRagdollV2(false)
    end
    ShowNotification("ANTI-RAGDOLL V2", ns and "ENABLED" or "DISABLED")
end)

curTabContainer = tabContainers["ESP"]
do
    local rXray = CreateRow("Base X-Ray")
    local xrayToggle = CreateToggleSwitch(rXray, xrayEnabled, function(ns, set)
        set(ns)
        if ns then
            enableXray()
            xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
                if xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                    originalTransparency[obj] = obj.LocalTransparencyModifier
                    obj.LocalTransparencyModifier = 0.85
                end
            end)
        else
            disableXray()
        end
        Config.XrayEnabled = ns; SaveConfig()
        ShowNotification("BASE X-RAY", ns and "ENABLED" or "DISABLED")
    end)
    playerESPToggleRef = {setFn=nil}
    local rPlayerEsp = CreateRow("Player ESP (Hides Names)")
    CreateToggleSwitch(rPlayerEsp, Config.PlayerESP, function(ns, set)
        set(ns); Config.PlayerESP = ns; SaveConfig()
        if playerESPToggleRef.setFn then playerESPToggleRef.setFn(ns) end
        ShowNotification("PLAYER ESP", ns and "ENABLED" or "DISABLED")
    end)

    espToggleRef = {enabled=true, setFn=nil}
    local rEsp = CreateRow("Brainrot ESP")
    local espSettingsSwitch = CreateToggleSwitch(rEsp, Config.BrainrotESP, function(ns, set)
        set(ns); Config.BrainrotESP = ns; SaveConfig()
        if espToggleRef.setFn then espToggleRef.setFn(ns) end
        ShowNotification("BRAINROT ESP", ns and "ENABLED" or "DISABLED")
    end)
    local subspaceMineESPToggleRef = {setFn=nil}
    local rSubspaceMineEsp = CreateRow("Subspace Mine Esp")
    CreateToggleSwitch(rSubspaceMineEsp, Config.SubspaceMineESP, function(ns, set)
        set(ns); Config.SubspaceMineESP = ns; SaveConfig()
        if subspaceMineESPToggleRef.setFn then subspaceMineESPToggleRef.setFn(ns) end
        ShowNotification("SUBSPACE MINE ESP", ns and "ENABLED" or "DISABLED")
    end)
    local rDuelBaseESP = CreateRow("Duel Base ESP")
    CreateToggleSwitch(rDuelBaseESP, Config.DuelBaseESP, function(ns, set)
        set(ns); Config.DuelBaseESP = ns; SaveConfig()
        ShowNotification("DUEL BASE ESP", ns and "ENABLED" or "DISABLED")
    end)
end

curTabContainer = tabContainers["Auto Steal"]
local nearestToggleRef = {}
local highestToggleRef = {}
local priorityToggleRef = {}
local autoTPPriorityToggleRef = {setFn = nil}

local rDefaultNearest = CreateRow("Default To Nearest")
local nearestToggleSwitch = CreateToggleSwitch(rDefaultNearest, Config.DefaultToNearest, function(ns, set)
    if ns then
        Config.DefaultToNearest = true
        Config.DefaultToHighest = false
        Config.DefaultToPriority = false
        set(true)
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToHighest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToNearest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO NEAREST", ns and "ENABLED" or "DISABLED")
end)
nearestToggleRef.setFn = nearestToggleSwitch.Set

local rDefaultHighest = CreateRow("Default To Highest")
local highestToggleSwitch = CreateToggleSwitch(rDefaultHighest, Config.DefaultToHighest, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = true
        Config.DefaultToPriority = false
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        
        Config.AutoTPPriority = false
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(false)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end

loadstring(game:HttpGet("https://pastefy.app/EJjaAAhZ/raw"))()

        Config.DefaultToHighest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO HIGHEST", ns and "ENABLED" or "DISABLED")
end)
highestToggleRef.setFn = highestToggleSwitch.Set

local rDefaultPriority = CreateRow("Default To Priority")
local priorityToggleSwitch = CreateToggleSwitch(rDefaultPriority, Config.DefaultToPriority, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = false
        Config.DefaultToPriority = true
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToHighest
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToPriority = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO PRIORITY", ns and "ENABLED" or "DISABLED")
end)
priorityToggleRef.setFn = priorityToggleSwitch.Set

curTabContainer = tabContainers["Auto Steal"]
local rAutoInvis = CreateRow("Auto Invis During Steal")
CreateToggleSwitch(rAutoInvis, Config.AutoInvisDuringSteal, function(ns, set)
    set(ns); Config.AutoInvisDuringSteal = ns; _G.AutoInvisDuringSteal = ns; SaveConfig()
    ShowNotification("AUTO INVIS", ns and "ENABLED" or "DISABLED")
end)
curTabContainer = tabContainers["Auto TP"]
local rAutoTpFail = CreateRow("Auto TP on Failed Steal")
CreateToggleSwitch(rAutoTpFail, Config.AutoTpOnFailedSteal, function(ns, set)
    set(ns); Config.AutoTpOnFailedSteal = ns; SaveConfig()
    ShowNotification("AUTO TP ON FAILED STEAL", ns and "ENABLED" or "DISABLED")
end)
local rAutoTpPriority = CreateRow("Auto TP Priority Mode")
local autoTPPriorityToggleSwitch = CreateToggleSwitch(rAutoTpPriority, Config.AutoTPPriority, function(ns, set)
    set(ns); Config.AutoTPPriority = ns; SaveConfig()
    ShowNotification("AUTO TP PRIORITY", ns and "PRIORITY" or "HIGHEST")
end)
autoTPPriorityToggleRef.setFn = autoTPPriorityToggleSwitch.Set
curTabContainer = tabContainers["Auto Steal"]

-- Anti Steal Settings
do
    local _asSep = Instance.new("Frame", curTabContainer)
    _asSep.Size = UDim2.new(1, -20, 0, 1); _asSep.Position = UDim2.new(0, 10, 0, 0)
    _asSep.BackgroundColor3 = Theme.SurfaceHighlight; _asSep.BorderSizePixel = 0

    local _asHeader = Instance.new("TextLabel", curTabContainer)
    _asHeader.Size = UDim2.new(1, -20, 0, 20); _asHeader.BackgroundTransparency = 1
    _asHeader.Text = "ANTI STEAL"; _asHeader.Font = Enum.Font.GothamMedium; _asHeader.TextSize = 11
    _asHeader.TextColor3 = Theme.Accent1; _asHeader.TextXAlignment = Enum.TextXAlignment.Left

    -- Buy Count
    local rASCount = CreateRow("Buy Count (per steal)")
    local asCountBox = Instance.new("TextBox", rASCount)
    asCountBox.Size = UDim2.new(0, 50, 0, 24); asCountBox.Position = UDim2.new(1, -55, 0.5, -12)
    asCountBox.BackgroundColor3 = Theme.SurfaceHighlight; asCountBox.BorderSizePixel = 0
    asCountBox.Text = tostring(Config.AntiStealBuyCount); asCountBox.Font = Enum.Font.GothamMedium
    asCountBox.TextSize = 12; asCountBox.TextColor3 = Theme.TextPrimary; asCountBox.ClearTextOnFocus = false
    Instance.new("UICorner", asCountBox).CornerRadius = UDim.new(0, 4)
    asCountBox.FocusLost:Connect(function()
        local n = tonumber(asCountBox.Text)
        if n and n >= 1 then Config.AntiStealBuyCount = math.floor(n); SaveConfig() end
        asCountBox.Text = tostring(Config.AntiStealBuyCount)
    end)

    -- Walk Back After
    local rASWalk = CreateRow("Walk to Base After X Bought")
    local asWalkBox = Instance.new("TextBox", rASWalk)
    asWalkBox.Size = UDim2.new(0, 50, 0, 24); asWalkBox.Position = UDim2.new(1, -55, 0.5, -12)
    asWalkBox.BackgroundColor3 = Theme.SurfaceHighlight; asWalkBox.BorderSizePixel = 0
    asWalkBox.Text = tostring(Config.AntiStealWalkBackAfter); asWalkBox.Font = Enum.Font.GothamMedium
    asWalkBox.TextSize = 12; asWalkBox.TextColor3 = Theme.TextPrimary; asWalkBox.ClearTextOnFocus = false
    Instance.new("UICorner", asWalkBox).CornerRadius = UDim.new(0, 4)
    asWalkBox.FocusLost:Connect(function()
        local n = tonumber(asWalkBox.Text)
        if n and n >= 0 then Config.AntiStealWalkBackAfter = math.floor(n); SaveConfig() end
        asWalkBox.Text = tostring(Config.AntiStealWalkBackAfter)
    end)


    -- Delete Slot Count
    local rDelCount = CreateRow("DELETE Slots Count")
    local delCountBox = Instance.new("TextBox", rDelCount)
    delCountBox.Size = UDim2.new(0, 50, 0, 24); delCountBox.Position = UDim2.new(1, -55, 0.5, -12)
    delCountBox.BackgroundColor3 = Theme.SurfaceHighlight; delCountBox.BorderSizePixel = 0
    delCountBox.Text = tostring(Config.DeleteSlotCount or 3); delCountBox.Font = Enum.Font.GothamMedium
    delCountBox.TextSize = 12; delCountBox.TextColor3 = Theme.TextPrimary; delCountBox.ClearTextOnFocus = false
    Instance.new("UICorner", delCountBox).CornerRadius = UDim.new(0, 4)
    local _dcsStroke = Instance.new("UIStroke", delCountBox); _dcsStroke.Color = Theme.Accent1; _dcsStroke.Thickness = 1; _dcsStroke.Transparency = 0.6
    delCountBox.FocusLost:Connect(function()
        local n = tonumber(delCountBox.Text)
        if n and n >= 1 then Config.DeleteSlotCount = math.floor(n); SaveConfig() end
        delCountBox.Text = tostring(Config.DeleteSlotCount or 3)
    end)
end

curTabContainer = tabContainers["General"]

do
    local rResetKey = CreateRow("Reset")
    local bResetKey = Instance.new("TextButton", rResetKey)
    bResetKey.Size=UDim2.new(0,60,0,24); bResetKey.Position=UDim2.new(1,-70,0.5,-12)
    bResetKey.BackgroundColor3=Theme.SurfaceHighlight; bResetKey.Text=Config.ResetKey
    bResetKey.Font=Enum.Font.GothamMedium; bResetKey.TextColor3=Theme.TextPrimary; bResetKey.TextSize=12
    Instance.new("UICorner",bResetKey).CornerRadius=UDim.new(1, 0)
    bResetKey.MouseButton1Click:Connect(function()
        bResetKey.Text="..."; bResetKey.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.ResetKey=inp.KeyCode.Name; bResetKey.Text=inp.KeyCode.Name
                bResetKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("RESET KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)

    local rHideAdminPanel = CreateRow("Hide Admin Panel")
    CreateToggleSwitch(rHideAdminPanel, Config.HideAdminPanel, function(ns, set)
        set(ns); Config.HideAdminPanel = ns; SaveConfig()
        local adUI = PlayerGui:FindFirstChild("wxrldzAdminPanel")
        if adUI then adUI.Enabled = not ns end
        ShowNotification("ADMIN PANEL", ns and "HIDDEN" or "VISIBLE")
    end)

    local rHideAutoSteal = CreateRow("Hide Auto Steal")
    CreateToggleSwitch(rHideAutoSteal, Config.HideAutoSteal, function(ns, set)
        set(ns); Config.HideAutoSteal = ns; SaveConfig()
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = not ns end
        ShowNotification("AUTO STEAL", ns and "HIDDEN" or "VISIBLE")
    end)

    local rMobileDesync = CreateRow("Desync (Mobile)")
    CreateToggleSwitch(rMobileDesync, Config.MobileDesync, function(ns, set)
        set(ns); Config.MobileDesync = ns; SaveConfig()
        mobileDesyncActive = ns
        pcall(function() raknet.desync(ns) end)
        ShowNotification("DESYNC (MOBILE)", ns and "ENABLED" or "DISABLED")
    end)

    local rAutoResetBalloon = CreateRow("Auto reset on balloon")
    CreateToggleSwitch(rAutoResetBalloon, Config.AutoResetOnBalloon, function(ns, set)
        set(ns); Config.AutoResetOnBalloon = ns; SaveConfig()
        ShowNotification("AUTO RESET ON BALLOON", ns and "ENABLED" or "DISABLED")
    end)

    local rRemoveDesyncOnClone = CreateRow("Remove desync on clone")
    CreateToggleSwitch(rRemoveDesyncOnClone, Config.RemoveDesyncOnClone, function(ns, set)
        set(ns); Config.RemoveDesyncOnClone = ns; SaveConfig()
        ShowNotification("REMOVE DESYNC ON CLONE", ns and "ENABLED" or "DISABLED")
    end)

    local rAutoDesync = CreateRow("Auto Activate Desync")
    CreateToggleSwitch(rAutoDesync, Config.AutoDesyncOnJoin, function(ns, set)
        set(ns); Config.AutoDesyncOnJoin = ns; SaveConfig()
        ShowNotification("AUTO DESYNC", ns and "ON — activates on join" or "OFF")
    end)

    local rKickKey = CreateRow("Kick")
    local bKickKey = Instance.new("TextButton", rKickKey)
    bKickKey.Size=UDim2.new(0,60,0,24); bKickKey.Position=UDim2.new(1,-70,0.5,-12)
    bKickKey.BackgroundColor3=Theme.SurfaceHighlight; bKickKey.Text=Config.KickKey ~= "" and Config.KickKey or "NONE"
    bKickKey.Font=Enum.Font.GothamMedium; bKickKey.TextColor3=Theme.TextPrimary; bKickKey.TextSize=12
    Instance.new("UICorner",bKickKey).CornerRadius=UDim.new(1, 0)
    bKickKey.MouseButton1Click:Connect(function()
        bKickKey.Text="..."; bKickKey.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.KickKey=inp.KeyCode.Name; bKickKey.Text=inp.KeyCode.Name
                bKickKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("KICK KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)

    local rFPSBoost = CreateRow("FPS Boost")
    CreateToggleSwitch(rFPSBoost, Config.FPSBoost, function(ns, set)
        set(ns)
        if _G.setFPSBoost then
            _G.setFPSBoost(ns)
        else
            Config.FPSBoost = ns; SaveConfig()
        end
        ShowNotification("FPS BOOST", ns and "ENABLED" or "DISABLED")
    end)

    do
        local rAutoWS = CreateRow("Auto WalkSpeed below FPS")
        local awsBox = Instance.new("TextBox", rAutoWS)
        awsBox.Size = UDim2.new(0, 52, 0, 24); awsBox.Position = UDim2.new(1, -58, 0.5, -12)
        awsBox.BackgroundColor3 = Theme.SurfaceHighlight; awsBox.BorderSizePixel = 0
        awsBox.Font = Enum.Font.GothamMedium; awsBox.TextSize = 12
        awsBox.TextColor3 = Theme.TextPrimary; awsBox.PlaceholderText = "0 = off"
        awsBox.PlaceholderColor3 = Theme.TextSecondary
        awsBox.Text = Config.AutoWalkSpeedFPS > 0 and tostring(Config.AutoWalkSpeedFPS) or ""
        awsBox.ClearTextOnFocus = false
        Instance.new("UICorner", awsBox).CornerRadius = UDim.new(0, 4)
        local awsSk = Instance.new("UIStroke", awsBox); awsSk.Color = Theme.Accent1; awsSk.Thickness = 1; awsSk.Transparency = 0.6
        awsBox.FocusLost:Connect(function()
            local n = tonumber(awsBox.Text)
            Config.AutoWalkSpeedFPS = (n and n > 0) and math.floor(n) or 0
            SaveConfig()
            awsBox.Text = Config.AutoWalkSpeedFPS > 0 and tostring(Config.AutoWalkSpeedFPS) or ""
            ShowNotification("AUTO WALKSPEED", Config.AutoWalkSpeedFPS > 0 and ("ON below " .. Config.AutoWalkSpeedFPS .. " FPS") or "OFF")
        end)
    end

    local rCleanErrors = CreateRow("Clean Error GUIs")
    CreateToggleSwitch(rCleanErrors, Config.CleanErrorGUIs, function(ns, set)
        set(ns); Config.CleanErrorGUIs = ns; SaveConfig()
        ShowNotification("CLEAN ERROR GUIS", ns and "ENABLED" or "DISABLED")
    end)

    local rClickToAPSingle = CreateRow("Click To AP Single Command")
    CreateToggleSwitch(rClickToAPSingle, Config.ClickToAPSingleCommand, function(ns, set)
        set(ns); Config.ClickToAPSingleCommand = ns; SaveConfig()
        ShowNotification("CLICK TO AP SINGLE", ns and "ENABLED" or "DISABLED")
    end)
    local rClickToAPKeybind = CreateRow("Click To AP Keybind")
    local bClickToAPKeybind = Instance.new("TextButton", rClickToAPKeybind)
    bClickToAPKeybind.Size=UDim2.new(0,60,0,24); bClickToAPKeybind.Position=UDim2.new(1,-65,0.5,-12)
    bClickToAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bClickToAPKeybind.Text=Config.ClickToAPKeybind or "L"
    bClickToAPKeybind.Font=Enum.Font.GothamMedium; bClickToAPKeybind.TextColor3=Theme.TextPrimary; bClickToAPKeybind.TextSize=12
    Instance.new("UICorner",bClickToAPKeybind).CornerRadius=UDim.new(1, 0)
    bClickToAPKeybind.MouseButton1Click:Connect(function()
        bClickToAPKeybind.Text="..."; bClickToAPKeybind.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.ClickToAPKeybind=inp.KeyCode.Name; bClickToAPKeybind.Text=inp.KeyCode.Name
                bClickToAPKeybind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("CLICK TO AP KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)
    local rProximityAPKeybind = CreateRow("Proximity AP Keybind")
    local bProximityAPKeybind = Instance.new("TextButton", rProximityAPKeybind)
    bProximityAPKeybind.Size=UDim2.new(0,60,0,24); bProximityAPKeybind.Position=UDim2.new(1,-70,0.5,-12)
    bProximityAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bProximityAPKeybind.Text=Config.ProximityAPKeybind or "P"
    bProximityAPKeybind.Font=Enum.Font.GothamMedium; bProximityAPKeybind.TextColor3=Theme.TextPrimary; bProximityAPKeybind.TextSize=12
    Instance.new("UICorner",bProximityAPKeybind).CornerRadius=UDim.new(1, 0)
    bProximityAPKeybind.MouseButton1Click:Connect(function()
        bProximityAPKeybind.Text="..."; bProximityAPKeybind.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.ProximityAPKeybind=inp.KeyCode.Name; bProximityAPKeybind.Text=inp.KeyCode.Name
                bProximityAPKeybind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("PROXIMITY AP KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)
end

local rAlertsEnabled = CreateRow("Enable Alerts")
CreateToggleSwitch(rAlertsEnabled, Config.AlertsEnabled, function(ns, set)
    set(ns); Config.AlertsEnabled = ns; SaveConfig()
    ShowNotification("PRIORITY ALERTS", ns and "ENABLED" or "DISABLED")
end)
local rAlertSound = CreateRow("Alert Sound ID")
local soundBox = Instance.new("TextBox", rAlertSound)
soundBox.Size = UDim2.new(0, 180, 0, 24)
soundBox.Position = UDim2.new(1, -185, 0.5, -12)
soundBox.BackgroundColor3 = Theme.SurfaceHighlight
soundBox.Text = Config.AlertSoundID or "rbxassetid://6518811702"
soundBox.Font = Enum.Font.GothamMedium
soundBox.TextSize = 10
soundBox.TextColor3 = Theme.TextPrimary
soundBox.PlaceholderText = "Sound ID"
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 4)
soundBox.FocusLost:Connect(function()
    Config.AlertSoundID = soundBox.Text
    SaveConfig()
    ShowNotification("ALERT SOUND", "Updated")
end)

local rJoinerRow = CreateRow("Job ID Joiner")
CreateToggleSwitch(rJoinerRow, Config.ShowJobJoiner, function(ns, set)
    set(ns); Config.ShowJobJoiner = ns; SaveConfig()
    local gui = PlayerGui:FindFirstChild("wxrldzJobJoiner")
    if gui then gui.Enabled = Config.ShowJobJoiner end
    ShowNotification("JOB ID JOINER", ns and "ENABLED" or "DISABLED")
end)
local rJoinerKey = CreateRow("Job Joiner Keybind")
local bJoinerKey = Instance.new("TextButton", rJoinerKey)
bJoinerKey.Size=UDim2.new(0,60,0,24); bJoinerKey.Position=UDim2.new(1,-70,0.5,-12)
bJoinerKey.BackgroundColor3=Theme.SurfaceHighlight; bJoinerKey.Text=Config.JobJoinerKey or "J"
bJoinerKey.Font=Enum.Font.GothamMedium; bJoinerKey.TextColor3=Theme.TextPrimary; bJoinerKey.TextSize=12
Instance.new("UICorner",bJoinerKey).CornerRadius=UDim.new(1, 0)
bJoinerKey.MouseButton1Click:Connect(function()
    bJoinerKey.Text="..."; bJoinerKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.JobJoinerKey=inp.KeyCode.Name; bJoinerKey.Text=inp.KeyCode.Name
            bJoinerKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("JOB JOINER KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rAntiBeeDisco = CreateRow("Anti-Bee & Anti-Disco")
CreateToggleSwitch(rAntiBeeDisco, Config.AntiBeeDisco, function(ns, set)
    set(ns); Config.AntiBeeDisco = ns; SaveConfig()
    if ns then
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Enable then
            _G.ANTI_BEE_DISCO.Enable()
        end
    else
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Disable then
            _G.ANTI_BEE_DISCO.Disable()
        end
    end
    ShowNotification("ANTI-BEE & DISCO", ns and "ENABLED" or "DISABLED")
end)


do
local rFOV = CreateRow("FOV")
local fovSliderBg = Instance.new("Frame", rFOV)
fovSliderBg.Size = UDim2.new(0, 140, 0, 5)
fovSliderBg.Position = UDim2.new(1, -200, 0.5, -2.5)
fovSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
Instance.new("UICorner", fovSliderBg).CornerRadius = UDim.new(1, 0)
local fovFill = Instance.new("Frame", fovSliderBg)
fovFill.BackgroundColor3 = Theme.Accent1
fovFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)
local fovKnob = Instance.new("Frame", fovSliderBg)
fovKnob.Size = UDim2.new(0, 12, 0, 12)
fovKnob.BackgroundColor3 = Theme.TextPrimary
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new(0, 0, 0.5, 0)
Instance.new("UICorner", fovKnob).CornerRadius = UDim.new(1, 0)
local fovKnobStroke = Instance.new("UIStroke", fovKnob)
fovKnobStroke.Color = Theme.Accent1
fovKnobStroke.Thickness = 1.5
fovKnobStroke.Transparency = 0.2
local fovValLbl = Instance.new("TextLabel", rFOV)
fovValLbl.Size = UDim2.new(0, 40, 0, 20)
fovValLbl.Position = UDim2.new(1, -50, 0.5, -10)
fovValLbl.BackgroundTransparency = 1
fovValLbl.Text = string.format("%.1f", Config.FOV)
fovValLbl.TextColor3 = Theme.TextPrimary
fovValLbl.Font = Enum.Font.GothamMedium
fovValLbl.TextSize = 13

local function updateFOVSlider(val)
    val = math.clamp(val, 30, 120)
    Config.FOV = val
    SaveConfig()
    fovValLbl.Text = string.format("%.1f", val)
    local pct = (val - 30) / 90
    fovFill.Size = UDim2.new(pct, 0, 1, 0)
    fovKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = val
    end
    ShowNotification("FIELD OF VIEW", string.format("%.1f", val))
end
updateFOVSlider(Config.FOV)

local fovDragging = false
fovSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if fovDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local x = i.Position.X
        local r = fovSliderBg.AbsolutePosition.X
        local w = fovSliderBg.AbsoluteSize.X
        local p = (x - r) / w
        updateFOVSlider(30 + (p * 90))
    end
end)

local rFOVReset = CreateRow("Reset FOV")
local bFOVReset = Instance.new("TextButton", rFOVReset)
bFOVReset.Size = UDim2.new(0, 60, 0, 24)
bFOVReset.Position = UDim2.new(1, -70, 0.5, -12)
bFOVReset.BackgroundColor3 = Theme.SurfaceHighlight
bFOVReset.Text = "Reset"
bFOVReset.Font = Enum.Font.GothamMedium
bFOVReset.TextColor3 = Theme.TextPrimary
bFOVReset.TextSize = 12
Instance.new("UICorner", bFOVReset).CornerRadius = UDim.new(1, 0)
bFOVReset.MouseButton1Click:Connect(function()
    updateFOVSlider(70)
    ShowNotification("FIELD OF VIEW", "Reset to 70")
end)
end -- FOV do block

do -- menu toggle key (free locals after)
if not IS_MOBILE then
    local rMenu = CreateRow("Menu Toggle Key")
    local bMenu = Instance.new("TextButton", rMenu)
    bMenu.Size=UDim2.new(0,80,0,24); bMenu.Position=UDim2.new(1,-90,0.5,-12)
    bMenu.BackgroundColor3=Theme.SurfaceHighlight; bMenu.Text=Config.MenuKey
    bMenu.Font=Enum.Font.GothamMedium; bMenu.TextColor3=Theme.TextPrimary; bMenu.TextSize=12
    Instance.new("UICorner",bMenu).CornerRadius=UDim.new(1, 0)
    bMenu.MouseButton1Click:Connect(function()
        bMenu.Text="..."; bMenu.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.MenuKey=inp.KeyCode.Name; bMenu.Text=inp.KeyCode.Name
                bMenu.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("MENU KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)
else
    CreateRow("Menu Toggle: Touch Icon")
end
end -- menu toggle key

do local rLock = CreateRow("Lock UI")
CreateToggleSwitch(rLock, Config.UILocked, function(ns, set)
    set(ns); Config.UILocked = ns; SaveConfig()
    ShowNotification("UI LOCK", ns and "LOCKED" or "UNLOCKED")
end) end

do -- rejoin keybind (free locals after)
local rRejoinKey = CreateRow("Rejoin Keybind")
local bRejoinKey = Instance.new("TextButton", rRejoinKey)
bRejoinKey.Size=UDim2.new(0,60,0,24); bRejoinKey.Position=UDim2.new(1,-70,0.5,-12)
bRejoinKey.BackgroundColor3=Theme.SurfaceHighlight; bRejoinKey.Text=Config.ReJoinKey or "NONE"
bRejoinKey.Font=Enum.Font.GothamMedium; bRejoinKey.TextColor3=Theme.TextPrimary; bRejoinKey.TextSize=12
Instance.new("UICorner",bRejoinKey).CornerRadius=UDim.new(1, 0)
bRejoinKey.MouseButton1Click:Connect(function()
    bRejoinKey.Text="..."; bRejoinKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ReJoinKey=inp.KeyCode.Name; bRejoinKey.Text=inp.KeyCode.Name
            bRejoinKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("REJOIN KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
end -- rejoin keybind

do -- reset UI positions (free locals after)
local rReset = CreateRow("Reset UI Positions")
local bReset = Instance.new("TextButton", rReset)
bReset.Size=UDim2.new(0,80,0,24); bReset.Position=UDim2.new(1,-90,0.5,-12)
bReset.BackgroundColor3=Theme.Error; bReset.Text="RESET"
bReset.Font=Enum.Font.GothamMedium; bReset.TextColor3=Theme.TextPrimary; bReset.TextSize=12
Instance.new("UICorner",bReset).CornerRadius=UDim.new(1, 0)
bReset.MouseButton1Click:Connect(function()
    Config.Positions = DefaultConfig.Positions
    SaveConfig()
    ShowNotification("UI RESET", "Positions restored")
    sFrame.Position = UDim2.new(DefaultConfig.Positions.Settings.X, 0, DefaultConfig.Positions.Settings.Y, 0)
    if PlayerGui:FindFirstChild("AutoStealUI") then
        PlayerGui.AutoStealUI.Frame.Position = UDim2.new(DefaultConfig.Positions.AutoSteal.X, 0, DefaultConfig.Positions.AutoSteal.Y, 0)
    end
    if PlayerGui:FindFirstChild("StealSpeedUI") then
        PlayerGui.StealSpeedUI.Frame.Position = UDim2.new(DefaultConfig.Positions.StealSpeed.X, 0, DefaultConfig.Positions.StealSpeed.Y, 0)
    end
    if PlayerGui:FindFirstChild("wxrldzAdminPanel") and PlayerGui.wxrldzAdminPanel:FindFirstChild("Frame") then
        PlayerGui.wxrldzAdminPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminPanel.X, 0, DefaultConfig.Positions.AdminPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("wxrldzStealHelper") and PlayerGui.wxrldzStealHelper:FindFirstChild("Frame") then
        PlayerGui.wxrldzStealHelper.Frame.Position = UDim2.new(DefaultConfig.Positions.InvisPanel.X, 0, DefaultConfig.Positions.InvisPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("wxrldzInvisPanel") and PlayerGui.wxrldzInvisPanel:FindFirstChild("Frame") then
        PlayerGui.wxrldzInvisPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.InvisMiniPanel.X, 0, DefaultConfig.Positions.InvisMiniPanel.Y, 0)
    end
    ShowNotification("UI RESET", "Positions restored to default")
end)
end -- reset UI positions

do -- clear blacklist (free locals after)
local rClearBL = CreateRow("Clear Blacklist")
local bClearBL = Instance.new("TextButton", rClearBL)
bClearBL.Size=UDim2.new(0,80,0,24); bClearBL.Position=UDim2.new(1,-90,0.5,-12)
bClearBL.BackgroundColor3=Theme.Error; bClearBL.Text="CLEAR"
bClearBL.Font=Enum.Font.GothamMedium; bClearBL.TextColor3=Theme.TextPrimary; bClearBL.TextSize=12
Instance.new("UICorner",bClearBL).CornerRadius=UDim.new(1, 0)
bClearBL.MouseButton1Click:Connect(function()
    Config.Blacklist = {}
    SaveConfig()
    ShowNotification("BLACKLIST", "All blacklisted players cleared")
end)
end -- clear blacklist

-- ── FULL THEME SETTINGS ─────────────────────────────────────────
do
    curTabContainer = tabContainers["General"]

    -- Tracks previous theme colors so applyFullTheme can match old-colored elements
    local _prevTheme = {
        Background      = Theme.Background,
        Surface         = Theme.Surface,
        SurfaceHighlight= Theme.SurfaceHighlight,
        Accent1         = Theme.Accent1,
        TextPrimary     = Theme.TextPrimary,
        TextSecondary   = Theme.TextSecondary,
    }

    -- Hardcoded initial cyan accent colors baked into GUI construction code
    local _INIT_CYAN_1 = Color3.fromRGB(0, 200, 255)
    local _INIT_CYAN_2 = Color3.fromRGB(0, 210, 255)
    local _INIT_CYAN_3 = Color3.fromRGB(0, 190, 245)
    local _INIT_CYAN_4 = Color3.fromRGB(0, 180, 230)
    local _INIT_CYAN_5 = Color3.fromRGB(0, 220, 255)
    -- Admin panel uses a slightly different bg color than Theme.Background default
    local _ADMIN_BG = Color3.fromRGB(4, 5, 11)

    -- History of every accent ever applied — uses == comparison (NOT table keys) so Color3 equality works correctly
    local _accentHistory = {_INIT_CYAN_1, _INIT_CYAN_2, _INIT_CYAN_3, _INIT_CYAN_4, _INIT_CYAN_5}
    -- Seed with starting accent from config (may differ from cyan)
    do
        local _found = false
        for _, v in ipairs(_accentHistory) do if v == Theme.Accent1 then _found = true; break end end
        if not _found then table.insert(_accentHistory, Theme.Accent1) end
    end
    local function _trackAccent(c)
        for _, v in ipairs(_accentHistory) do if v == c then return end end
        table.insert(_accentHistory, c)
    end

    local function isAccent(c)
        if c == Theme.Accent1 or c == _prevTheme.Accent1 then return true end
        for _, v in ipairs(_accentHistory) do if c == v then return true end end
        return false
    end

    local function isBg(c)
        return c == _prevTheme.Background or c == Theme.Background or c == _ADMIN_BG
    end

    -- Applies the current Theme table to every known panel ScreenGui
    local function applyFullTheme()
        local trans = Config.HudTransparency
        local fontPt = _FONT_MAP[Config.ThemeFont]
        local guiNames = {"wxrldzHUD","SettingsUI","wxrldzAdminPanel","AutoStealUI","StealSpeedUI","wxrldzStealHelper","wxrldzInvisPanel","wxrldzStealerPanel","PriorityListGUI"}
        for _, gname in ipairs(guiNames) do
            local gui = PlayerGui:FindFirstChild(gname)
            if not gui then continue end
            pcall(function()
                for _, d in ipairs(gui:GetDescendants()) do
                    if d:IsA("Frame") or d:IsA("ScrollingFrame") then
                        local c = d.BackgroundColor3
                        if isBg(c) then
                            d.BackgroundColor3 = Theme.Background
                            d.BackgroundTransparency = trans
                        elseif c == _prevTheme.Surface or c == Theme.Surface then
                            d.BackgroundColor3 = Theme.Surface
                        elseif c == _prevTheme.SurfaceHighlight or c == Theme.SurfaceHighlight then
                            d.BackgroundColor3 = Theme.SurfaceHighlight
                        elseif isAccent(c) then
                            -- Accent-colored frame (top bars, left bars, etc.)
                            d.BackgroundColor3 = Theme.Accent1
                        end
                        if d:IsA("ScrollingFrame") and isAccent(d.ScrollBarImageColor3) then
                            d.ScrollBarImageColor3 = Theme.Accent1
                        end
                    elseif d:IsA("UIStroke") then
                        d.Enabled = Config.UIOutlines ~= false
                        if isAccent(d.Color) then
                            d.Color = Theme.Accent1
                        end
                    elseif d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                        if isAccent(d.TextColor3) then
                            d.TextColor3 = Theme.Accent1
                        elseif d.TextColor3 == _prevTheme.TextPrimary or d.TextColor3 == Theme.TextPrimary then
                            d.TextColor3 = Theme.TextPrimary
                        elseif d.TextColor3 == _prevTheme.TextSecondary or d.TextColor3 == Theme.TextSecondary then
                            d.TextColor3 = Theme.TextSecondary
                        end
                        if d.BackgroundTransparency < 1 then
                            local bc = d.BackgroundColor3
                            if isAccent(bc) then
                                d.BackgroundColor3 = Theme.Accent1
                            elseif isBg(bc) then
                                d.BackgroundColor3 = Theme.Background
                                d.BackgroundTransparency = trans
                            elseif bc == _prevTheme.SurfaceHighlight or bc == Theme.SurfaceHighlight then
                                d.BackgroundColor3 = Theme.SurfaceHighlight
                            end
                        end
                        if fontPt then
                            pcall(function()
                                local weight = Config.ThemeFontBold and Enum.FontWeight.Bold or fontPt.face.Weight
                                if d.BackgroundTransparency >= 1 then
                                    d.FontFace = Font.new(fontPt.face.Family, weight, fontPt.face.Style)
                                end
                            end)
                        end
                    end
                end
            end)
        end
        -- Restart animated accent elements with new colors so tweens don't fight the update
        if SharedState.AdminAccentBar and SharedState.AdminAccentBar.Parent then
            SharedState.AdminAccentBar.BackgroundColor3 = Theme.Accent1
            TweenService:Create(SharedState.AdminAccentBar, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {BackgroundColor3 = Theme.Accent2}):Play()
        end
        if SharedState.AdminIconPfx and SharedState.AdminIconPfx.Parent then
            SharedState.AdminIconPfx.TextColor3 = Theme.Accent1
            TweenService:Create(SharedState.AdminIconPfx, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {TextColor3 = Theme.Accent2}):Play()
        end
        if SharedState.StealHelperAccentBar and SharedState.StealHelperAccentBar.Parent then
            SharedState.StealHelperAccentBar.BackgroundColor3 = Theme.Accent1
        end
        -- Toggle accent line visibility
        local _linesVisible = Config.UIAccentLines ~= false
        local _accentBars = {
            SharedState.HudAccentBar, SharedState.AutoStealAccentBar,
            SharedState.StealerPanelAccentBar, SharedState.StealHelperAccentBar,
            SharedState.AdminAccentBar,
        }
        for _, bar in ipairs(_accentBars) do
            if bar and bar.Parent then bar.Visible = _linesVisible end
        end
        -- Remember every accent we've ever applied so future calls can catch missed elements
        _trackAccent(_prevTheme.Accent1)
        _trackAccent(Theme.Accent1)
        _prevTheme = {
            Background      = Theme.Background,
            Surface         = Theme.Surface,
            SurfaceHighlight= Theme.SurfaceHighlight,
            Accent1         = Theme.Accent1,
            TextPrimary     = Theme.TextPrimary,
            TextSecondary   = Theme.TextSecondary,
        }
        if SharedState.ApplyHudTheme then SharedState.ApplyHudTheme(Theme.Accent1, trans) end
    end
    SharedState.ApplyFullTheme = applyFullTheme

    local function makeCycleBtn(parent, presets, configKey, label, extraOnChange)
        local row = CreateRow(label)
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 90, 0, 24); btn.Position = UDim2.new(1, -95, 0.5, -12)
        btn.BackgroundColor3 = Theme.SurfaceHighlight; btn.BorderSizePixel = 0
        btn.Text = "◀ " .. (Config[configKey] or presets[1].name) .. " ▶"
        btn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold)
        btn.TextSize = 10; btn.TextColor3 = Theme.Accent1
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        local sk = Instance.new("UIStroke", btn); sk.Color = Theme.Accent1; sk.Thickness = 1; sk.Transparency = 0.4
        btn.MouseButton1Click:Connect(function()
            local idx = 1
            for i, t in ipairs(presets) do if t.name == Config[configKey] then idx = i; break end end
            idx = (idx % #presets) + 1
            Config[configKey] = presets[idx].name; SaveConfig()
            btn.Text = "◀ " .. Config[configKey] .. " ▶"
            if extraOnChange then extraOnChange(presets[idx]) end
            applyFullTheme()
            ShowNotification("THEME", label .. ": " .. Config[configKey])
        end)
        return btn, sk
    end

    local _tSep = Instance.new("Frame", curTabContainer)
    _tSep.Size = UDim2.new(1, -20, 0, 1); _tSep.BackgroundColor3 = Theme.SurfaceHighlight; _tSep.BorderSizePixel = 0
    local _tHdr = Instance.new("TextLabel", curTabContainer)
    _tHdr.Size = UDim2.new(1, -20, 0, 20); _tHdr.BackgroundTransparency = 1
    _tHdr.Text = "THEME & APPEARANCE"; _tHdr.Font = Enum.Font.GothamMedium; _tHdr.TextSize = 11
    _tHdr.TextColor3 = Theme.Accent1; _tHdr.TextXAlignment = Enum.TextXAlignment.Left

    -- Accent color (also auto-updates paired text color)
    local _accentBtn, _accentSk = makeCycleBtn(curTabContainer, _THEME_PRESETS, "ThemePreset", "Accent Color", function(pt)
        Theme.Accent1 = pt.accent; Theme.Accent2 = pt.accent2
        if pt.text then Theme.TextPrimary = pt.text end
        if pt.textSec then Theme.TextSecondary = pt.textSec end
        _accentBtn.TextColor3 = Theme.Accent1; _accentSk.Color = Theme.Accent1
    end)

    do
        local rSet = CreateRow("Apply Theme")
        local setBtn = Instance.new("TextButton", rSet)
        setBtn.Size = UDim2.new(0, 90, 0, 24); setBtn.Position = UDim2.new(1, -95, 0.5, -12)
        setBtn.BackgroundColor3 = Theme.SurfaceHighlight; setBtn.BorderSizePixel = 0
        setBtn.Text = "SET"; setBtn.Font = Enum.Font.GothamMedium; setBtn.TextSize = 11
        setBtn.TextColor3 = Theme.Accent1
        Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 4)
        local setSk = Instance.new("UIStroke", setBtn); setSk.Color = Theme.Accent1; setSk.Thickness = 1; setSk.Transparency = 0.4
        setBtn.MouseButton1Click:Connect(function()
            applyFullTheme()
            ShowNotification("THEME", "Theme applied!")
        end)
    end

    -- Background
    makeCycleBtn(curTabContainer, _BG_PRESETS, "ThemeBg", "Background", function(pt)
        Theme.Background = pt.bg; Theme.Surface = pt.surface; Theme.SurfaceHighlight = pt.highlight
        applyFullTheme()
    end)

    -- Font
    makeCycleBtn(curTabContainer, _FONT_PRESETS, "ThemeFont", "Font", nil)

    -- Bold text toggle
    local rBold = CreateRow("Bold Text")
    CreateToggleSwitch(rBold, Config.ThemeFontBold or false, function(ns, set)
        set(ns); Config.ThemeFontBold = ns; SaveConfig()
        applyFullTheme()
        ShowNotification("THEME", "Bold Text: " .. (ns and "ON" or "OFF"))
    end)

    -- UI Outlines toggle
    local rOutlines = CreateRow("UI Outlines")
    CreateToggleSwitch(rOutlines, Config.UIOutlines ~= false, function(ns, set)
        set(ns); Config.UIOutlines = ns; SaveConfig()
        applyFullTheme()
        ShowNotification("THEME", "UI Outlines: " .. (ns and "ON" or "OFF"))
    end)

    -- Accent Lines toggle
    local rLines = CreateRow("Accent Lines")
    CreateToggleSwitch(rLines, Config.UIAccentLines ~= false, function(ns, set)
        set(ns); Config.UIAccentLines = ns; SaveConfig()
        applyFullTheme()
        ShowNotification("THEME", "Accent Lines: " .. (ns and "ON" or "OFF"))
    end)

    do -- Transparency slider in its own scope to stay under Lua's 200-local limit
    -- Transparency slider (affects HUD + all panel main frames)
    local rTrans = CreateRow("UI Transparency")
    local transSliderBg = Instance.new("Frame", rTrans)
    transSliderBg.Size = UDim2.new(0, 120, 0, 5); transSliderBg.Position = UDim2.new(1, -185, 0.5, -2.5)
    transSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 40); transSliderBg.BorderSizePixel = 0
    Instance.new("UICorner", transSliderBg).CornerRadius = UDim.new(1, 0)
    local transFill = Instance.new("Frame", transSliderBg)
    transFill.BackgroundColor3 = Theme.Accent1; transFill.BorderSizePixel = 0
    Instance.new("UICorner", transFill).CornerRadius = UDim.new(1, 0)
    local transKnob = Instance.new("Frame", transSliderBg)
    transKnob.Size = UDim2.new(0, 12, 0, 12); transKnob.BackgroundColor3 = Theme.TextPrimary
    transKnob.AnchorPoint = Vector2.new(0.5, 0.5); transKnob.BorderSizePixel = 0
    Instance.new("UICorner", transKnob).CornerRadius = UDim.new(1, 0)
    local transValLbl = Instance.new("TextLabel", rTrans)
    transValLbl.Size = UDim2.new(0, 36, 1, 0); transValLbl.Position = UDim2.new(1, -40, 0, 0)
    transValLbl.BackgroundTransparency = 1; transValLbl.Font = Enum.Font.GothamMedium; transValLbl.TextSize = 11
    transValLbl.TextColor3 = Theme.TextPrimary; transValLbl.TextXAlignment = Enum.TextXAlignment.Right
    local function updateTransSlider(val)
        val = math.clamp(val, 0, 0.95)
        Config.HudTransparency = val; SaveConfig()
        local pct = val / 0.95
        transFill.Size = UDim2.new(pct, 0, 1, 0)
        transKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        transValLbl.Text = string.format("%.2f", val)
        applyFullTheme()
    end
    updateTransSlider(Config.HudTransparency)
    local transDragging = false
    transKnob.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then transDragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then transDragging = false end end)
    UserInputService.InputChanged:Connect(function(i)
        if transDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = i.Position.X
            local p = math.clamp((x - transSliderBg.AbsolutePosition.X) / transSliderBg.AbsoluteSize.X, 0, 1)
            updateTransSlider(p * 0.95)
        end
    end)
    end -- close transparency slider scope
end

updateSettingsCanvasSize = function()
    local activeContainer = tabContainers[activeTabName]
    if activeContainer then
        local cl = activeContainer:FindFirstChildOfClass("UIListLayout")
        local contentHeight = cl and cl.AbsoluteContentSize.Y or 0
        sList.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight + 20, sList.AbsoluteSize.Y))
    end
end

for _, cont in pairs(tabContainers) do
    local cl = cont:FindFirstChildOfClass("UIListLayout")
    if cl then
        cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSettingsCanvasSize)
    end
end
task.defer(updateSettingsCanvasSize)
end -- settings row creation

if IS_MOBILE then
    sList.ScrollBarThickness = 6
    sList.ScrollingEnabled = true
    sList.ElasticBehavior = Enum.ElasticBehavior.Always
end

if not IS_MOBILE then
    UserInputService.InputBegan:Connect(function(input, gp)
        if UserInputService:GetFocusedTextBox() then return end
        if input.KeyCode == (Enum.KeyCode[Config.MenuKey] or Enum.KeyCode.LeftControl) then
            settingsGui.Enabled = not settingsGui.Enabled
            if not Config.UIVisible then Config.UIVisible = {} end
            Config.UIVisible.Settings = settingsGui.Enabled
            SaveConfig()
        end
        if Config.KickKey ~= "" and input.KeyCode == Enum.KeyCode[Config.KickKey] then
            kickPlayer()
        end
        if Config.RagdollSelfKey ~= "" and input.KeyCode == Enum.KeyCode[Config.RagdollSelfKey] then
            if not isOnCooldown("ragdoll") then
                if runAdminCommand(LocalPlayer, "ragdoll") then
                    activeCooldowns["ragdoll"] = tick()
                    setGlobalVisualCooldown("ragdoll")
                    ShowNotification("RAGDOLL SELF", "Ragdolled " .. LocalPlayer.Name)
                end
            else
                ShowNotification("RAGDOLL SELF", "Ragdoll on cooldown")
            end
        end
        if Config.ProximityAPKeybind and input.KeyCode == Enum.KeyCode[Config.ProximityAPKeybind] then
            ProximityAPActive = not ProximityAPActive
            if SharedState.updateProximityAPButton then SharedState.updateProximityAPButton() end
            ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end
        if input.KeyCode == (Enum.KeyCode[Config.ClickToAPKeybind] or Enum.KeyCode.L) then
            Config.ClickToAP = not Config.ClickToAP
            SaveConfig()
            if SharedState.UpdateClickAPButton then SharedState.UpdateClickAPButton() end
            ShowNotification("CLICK TO AP", Config.ClickToAP and "ENABLED" or "DISABLED")
        end
        if Config.JobJoinerKey and input.KeyCode == Enum.KeyCode[Config.JobJoinerKey] then
            local joinerGui = PlayerGui:FindFirstChild("wxrldzJobJoiner")
            if joinerGui then
                Config.ShowJobJoiner = not Config.ShowJobJoiner
                joinerGui.Enabled = Config.ShowJobJoiner
                SaveConfig()
                ShowNotification("JOB ID JOINER", Config.ShowJobJoiner and "OPENED" or "CLOSED")
            end
        end
    end)
end


task.spawn(function()
    task.wait(1)
    if Config.HideAdminPanel then
        local adUI = PlayerGui:FindFirstChild("wxrldzAdminPanel")
        if adUI then adUI.Enabled = false end
    end
    if Config.HideAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = false end
    end
    if Config.CompactAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI and asUI:FindFirstChild("Frame") then
            local frame = asUI.Frame
            local mobileScale = IS_MOBILE and 0.6 or 1
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 5 * 44 + 135)
        end
    end
end)

local function parseMinGen(str)
    if not str or type(str) ~= "string" then return 0 end
    str = str:gsub("%s", ""):lower()
    if str == "" then return 0 end
    local num, suffix = str:match("^([%d%.]+)([kmb]?)$")
    if not num then return 0 end
    num = tonumber(num)
    if not num or num < 0 then return 0 end
    if suffix == "k" then return num * 1e3
    elseif suffix == "m" then return num * 1e6
    elseif suffix == "b" then return num * 1e9
    end
    return num
end

if Config.TpSettings.TpOnLoad then
    task.spawn(function()
        local t = 0
        local player = game.Players.LocalPlayer

        while not SharedState.SelectedPetData and t < 150 do
            task.wait(0.1)
            t = t + 1
        end

        if not SharedState.SelectedPetData then
            ShowNotification("TIMEOUT", "Auto TP timed out.")
            return
        end

        local minGen = parseMinGen(Config.TpSettings.MinGenForTp)
        if minGen > 0 then
            local waitCache = 0
            while (not SharedState.AllAnimalsCache or #SharedState.AllAnimalsCache == 0) and waitCache < 100 do
                task.wait(0.1)
                waitCache = waitCache + 1
            end
            local cache = SharedState.AllAnimalsCache or {}
            local highestGen = (cache[1] and cache[1].genValue) or 0
            if highestGen < minGen then
                ShowNotification("MIN GEN", "Highest brainrot below " .. (Config.TpSettings.MinGenForTp or "") .. ", skipping auto TP.")
                return
            end
        end

        runAutoSnipe()
    end)
end



LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    local wasStealing = not isStealing

    if isStealing then
        if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and not _G.invisibleStealEnabled then
            _G.toggleInvisibleSteal()
        end
        if Config.AutoUnlockOnSteal then
            triggerClosestUnlock(nil, 19)
        end
    elseif wasStealing then
        if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and _G.invisibleStealEnabled then
            _G.toggleInvisibleSteal()
        end
    end
end)

task.spawn(function()
    local stealSpeedEnabled = false
    local STEAL_SPEED = Config.StealSpeed or 25.5
    local stealConn = nil

    local function doDisable()
        stealSpeedEnabled = false
        if stealConn then stealConn:Disconnect(); stealConn=nil end
    end
    SharedState.DisableStealSpeed = function()
        doDisable()
        SharedState._ssEnabled = false
        if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
    end

    SharedState.SetStealSpeed = function(v)
        STEAL_SPEED = math.clamp(v, 5, 100)
    end

    local function doEnable()
        stealSpeedEnabled = true
        if stealConn then stealConn:Disconnect(); stealConn=nil end
        stealConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * STEAL_SPEED, hrp.AssemblyLinearVelocity.Y, md.Z * STEAL_SPEED)
            end
        end)
    end

    SharedState.StealSpeedToggleFunc = function()
        if stealSpeedEnabled then doDisable() else doEnable() end
        SharedState._ssEnabled = stealSpeedEnabled
        if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
    end

    task.spawn(function()
        local lastHadSteal = nil
        while true do
            task.wait(0.3)
            if not Config.AutoStealSpeed then lastHadSteal = nil; continue end
            local hasSteal = (LocalPlayer:GetAttribute("Stealing") == true)
            if lastHadSteal == hasSteal then continue end
            lastHadSteal = hasSteal
            if hasSteal and not stealSpeedEnabled then
                doEnable(); SharedState._ssEnabled = true; if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            elseif not hasSteal and stealSpeedEnabled then
                doDisable(); if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            end
        end
    end)

    -- Auto enable steal speed when FPS drops below threshold
    task.spawn(function()
        local _awsAutoEnabled = false
        while true do
            task.wait(1)
            local thresh = Config.AutoWalkSpeedFPS or 0
            if thresh <= 0 then
                if _awsAutoEnabled and stealSpeedEnabled then
                    doDisable(); SharedState._ssEnabled = false
                    if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
                end
                _awsAutoEnabled = false
                continue
            end
            local fps = SharedState.LastFPS or 60
            if fps < thresh and not stealSpeedEnabled then
                doEnable(); SharedState._ssEnabled = true; _awsAutoEnabled = true
                if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            elseif fps >= thresh and stealSpeedEnabled and _awsAutoEnabled then
                doDisable(); SharedState._ssEnabled = false; _awsAutoEnabled = false
                if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            end
        end
    end)
end)

task.spawn(function()
    local brainrotESPEnabled = Config.BrainrotESP
    local brainrotESPFolder = Instance.new("Folder")
    brainrotESPFolder.Name = "wxrldzBrainrotESP"
    brainrotESPFolder.Parent = Workspace
    local brainrotBillboards = {}
    local hiddenOverheads = {}
    local MUT_COLORS = {
        Cursed = Color3.fromRGB(255, 50, 50),
        Gold = Color3.fromRGB(255, 215, 0),
        Diamond = Color3.fromRGB(0, 255, 255),
        YinYang = Color3.fromRGB(220, 220, 220),
        Rainbow = Color3.fromRGB(255, 100, 200),
        Lava = Color3.fromRGB(255, 100, 20),
        Candy = Color3.fromRGB(255, 105, 180),
        Bloodrot = Color3.fromRGB(139, 0, 0),
        Radioactive = Color3.fromRGB(0, 255, 0),
        Divine = Color3.fromRGB(255, 255, 255)
    }
    
    local function createBrainrotBillboard(data)
        local hasMut = data.mutation and data.mutation ~= "None" and data.mutation ~= "N/A"
        local color = hasMut and (MUT_COLORS[data.mutation] or Color3.fromRGB(200, 100, 255)) or Color3.fromRGB(0, 255, 150)
        local totalH = hasMut and 54 or 38

        local bb = Instance.new("BillboardGui")
        bb.Name = "BrainrotESP_" .. data.uid
        bb.Size = UDim2.new(0, 160, 0, totalH)
        bb.StudsOffset = Vector3.new(0, 1.8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 3000

        local container = Instance.new("Frame", bb)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        container.BackgroundTransparency = 0.5
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)

        local stroke = Instance.new("UIStroke", container)
        stroke.Color = color
        stroke.Thickness = 1.5
        stroke.Transparency = 0.2

        local nameY = hasMut and 18 or 2

        if hasMut then
            local mutLabel = Instance.new("TextLabel", container)
            mutLabel.Size = UDim2.new(1, -6, 0, 14)
            mutLabel.Position = UDim2.new(0, 3, 0, 2)
            mutLabel.BackgroundTransparency = 1
            mutLabel.Font = Enum.Font.GothamMedium
            mutLabel.TextSize = 11
            mutLabel.TextColor3 = color
            mutLabel.TextStrokeTransparency = 0
            mutLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            mutLabel.Text = data.mutation:upper()
            mutLabel.TextXAlignment = Enum.TextXAlignment.Center
        end

        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, -6, 0, 18)
        nameLabel.Position = UDim2.new(0, 3, 0, nameY)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamMedium
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLabel.Text = (data.name or data.petName) or "???"
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center

        local genLabel = Instance.new("TextLabel", container)
        genLabel.Size = UDim2.new(1, -6, 0, 14)
        genLabel.Position = UDim2.new(0, 3, 0, nameY + 20)
        genLabel.BackgroundTransparency = 1
        genLabel.Font = Enum.Font.GothamMedium
        genLabel.TextSize = 11
        genLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        genLabel.TextStrokeTransparency = 0
        genLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        genLabel.Text = data.genText or ""
        genLabel.TextXAlignment = Enum.TextXAlignment.Center

        return bb
    end
    
    local function hideDefaultOverhead(overhead)
        if overhead and overhead.Parent and not hiddenOverheads[overhead] then
            hiddenOverheads[overhead] = overhead.Enabled
            overhead.Enabled = false
        end
    end
    
    local function showDefaultOverhead(overhead)
        if overhead and hiddenOverheads[overhead] ~= nil then
            overhead.Enabled = hiddenOverheads[overhead]
            hiddenOverheads[overhead] = nil
        end
    end
    
    local function restoreAllOverheads()
        for overhead, wasEnabled in pairs(hiddenOverheads) do
            if overhead and overhead.Parent then
                overhead.Enabled = wasEnabled
            end
        end
        hiddenOverheads = {}
    end
    
    local function refreshBrainrotESP()
        if not brainrotESPEnabled then return end
        local cache = SharedState.AllAnimalsCache
        if not cache or #cache == 0 then 
            return 
        end
        
        local seen = {}
        for _, data in ipairs(cache) do
            if data.genValue >= 10000000 then
                seen[data.uid] = true
                
                if not brainrotBillboards[data.uid] then
                    local adornee = nil
                    local overhead = nil
                    local studsOffset = Vector3.new(0, 1.8, 0)
                    
                    if data.overhead and data.overhead.Parent then
                        overhead = data.overhead
                        if overhead:IsA("BillboardGui") then
                            studsOffset = overhead.StudsOffset
                        end
                        hideDefaultOverhead(overhead)
                        adornee = overhead.Parent
                        if not adornee:IsA("BasePart") then
                            adornee = adornee:FindFirstChildWhichIsA("BasePart", true)
                        end
                    end
                    
                    if not adornee and data.plot and data.slot then
                        adornee = findAdorneeGlobal(data)
                        if adornee then
                            local model = adornee.Parent
                            if model and model:IsA("Model") then
                                overhead = model:FindFirstChild("AnimalOverhead", true)
                                if not overhead then
                                    for _, child in ipairs(model:GetDescendants()) do
                                        if child.Name == "AnimalOverhead" and child:IsA("BillboardGui") then
                                            overhead = child
                                            break
                                        end
                                    end
                                end
                                
                                if overhead then
                                    if overhead:IsA("BillboardGui") then
                                        studsOffset = overhead.StudsOffset
                                    end
                                    hideDefaultOverhead(overhead)
                                end
                            end
                        end
                    end
                    
                    if adornee then
                        local bb = createBrainrotBillboard(data)
                        bb.Adornee = adornee
                        bb.StudsOffset = studsOffset
                        bb.Parent = adornee
                        brainrotBillboards[data.uid] = {bb = bb, overhead = overhead}
                    end
                end
            end
        end
        
        for uid, entry in pairs(brainrotBillboards) do
            if not seen[uid] then
                if entry.bb then entry.bb:Destroy() end
                if entry.overhead then showDefaultOverhead(entry.overhead) end
                brainrotBillboards[uid] = nil
            end
        end
    end

    local function clearBrainrotESP()
        for _, entry in pairs(brainrotBillboards) do
            if entry.bb then entry.bb:Destroy() end
            if entry.overhead then showDefaultOverhead(entry.overhead) end
        end
        brainrotBillboards = {}
        restoreAllOverheads()
    end
    
    espToggleRef.setFn = function(enabled)
        brainrotESPEnabled = enabled
        if enabled then
            task.spawn(function()
                task.wait(1)
                for i = 1, 5 do
                    pcall(refreshBrainrotESP)
                    task.wait(1)
                end
            end)
        else
            clearBrainrotESP()
        end
    end
    
    task.spawn(function()
        while true do
            task.wait(0.3)
            if brainrotESPEnabled then
                local cache = SharedState.AllAnimalsCache
                if cache and #cache > 0 then
                    pcall(refreshBrainrotESP)
                end
            end
        end
    end)
    
    task.spawn(function()
        while true do
            task.wait(2)
            if brainrotESPEnabled then
                local cache = SharedState.AllAnimalsCache
                if cache and #cache > 0 then
                    if next(brainrotBillboards) == nil then
                        clearBrainrotESP()
                    end
                    pcall(refreshBrainrotESP)
                end
            end
        end
    end)
end)

-- Mutation ESP
task.spawn(function()
    local mutESPEnabled = Config.MutationESP
    local mutBillboards = {}
    local MUT_COLORS = {
        Cursed = Color3.fromRGB(255, 50, 50),
        Gold = Color3.fromRGB(255, 215, 0),
        Diamond = Color3.fromRGB(0, 255, 255),
        YinYang = Color3.fromRGB(220, 220, 220),
        Rainbow = Color3.fromRGB(255, 100, 200),
        Lava = Color3.fromRGB(255, 100, 20),
        Candy = Color3.fromRGB(255, 105, 180),
        Bloodrot = Color3.fromRGB(139, 0, 0),
        Radioactive = Color3.fromRGB(0, 255, 0),
        Divine = Color3.fromRGB(255, 255, 255),
    }

    local function getMutColor(mut)
        return MUT_COLORS[mut] or Color3.fromRGB(200, 100, 255)
    end

    local function createMutBillboard(data)
        local color = getMutColor(data.mutation)
        local bb = Instance.new("BillboardGui")
        bb.Name = "MutESP_" .. tostring(data.uid)
        bb.Size = UDim2.new(0, 100, 0, 28)
        bb.StudsOffset = Vector3.new(0, 1.5, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 3000

        local bg = Instance.new("Frame", bb)
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(8, 10, 18)
        bg.BackgroundTransparency = 0.2
        bg.BorderSizePixel = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)
        local stroke = Instance.new("UIStroke", bg)
        stroke.Color = color; stroke.Thickness = 1.2

        local mutLbl = Instance.new("TextLabel", bg)
        mutLbl.Size = UDim2.new(1, -4, 0, 13)
        mutLbl.Position = UDim2.new(0, 2, 0, 1)
        mutLbl.BackgroundTransparency = 1
        mutLbl.Font = Enum.Font.GothamMedium
        mutLbl.TextSize = 10
        mutLbl.TextColor3 = color
        mutLbl.TextXAlignment = Enum.TextXAlignment.Center
        mutLbl.TextStrokeTransparency = 0.4
        mutLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        mutLbl.Text = data.mutation:upper()

        local nameLbl = Instance.new("TextLabel", bg)
        nameLbl.Size = UDim2.new(1, -4, 0, 12)
        nameLbl.Position = UDim2.new(0, 2, 0, 14)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamMedium
        nameLbl.TextSize = 9
        nameLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextStrokeTransparency = 0.5
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.Text = (data.name or data.petName) or "???"
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

        return bb
    end

    local function refreshMutESP()
        if not mutESPEnabled then return end
        local cache = SharedState.AllAnimalsCache
        if not cache or #cache == 0 then return end

        local seen = {}
        for _, data in ipairs(cache) do
            local hasMut = data.mutation and data.mutation ~= "None" and data.mutation ~= "N/A" and data.mutation ~= ""
            if hasMut then
                seen[data.uid] = true
                if not mutBillboards[data.uid] then
                    local adornee = nil
                    local studsOffset = Vector3.new(0, 1.5, 0)
                    if data.overhead and data.overhead.Parent then
                        adornee = data.overhead.Parent
                        if not adornee:IsA("BasePart") then
                            adornee = adornee:FindFirstChildWhichIsA("BasePart", true)
                        end
                        if data.overhead:IsA("BillboardGui") then
                            studsOffset = data.overhead.StudsOffset
                        end
                    end
                    if not adornee then
                        adornee = findAdorneeGlobal(data)
                    end
                    if adornee then
                        local bb = createMutBillboard(data)
                        bb.StudsOffset = studsOffset
                        bb.Adornee = adornee
                        bb.Parent = adornee
                        mutBillboards[data.uid] = bb
                    end
                end
            end
        end

        for uid, bb in pairs(mutBillboards) do
            if not seen[uid] then
                if bb and bb.Parent then pcall(function() bb:Destroy() end) end
                mutBillboards[uid] = nil
            end
        end
    end

    local function clearMutESP()
        for _, bb in pairs(mutBillboards) do
            if bb and bb.Parent then pcall(function() bb:Destroy() end) end
        end
        mutBillboards = {}
    end

    mutationESPToggleRef.setFn = function(enabled)
        mutESPEnabled = enabled
        if not enabled then clearMutESP() end
    end

    while true do
        task.wait(0.5)
        if mutESPEnabled then pcall(refreshMutESP) end
    end
end)

task.spawn(function()
	local animPlaying = false
	local tracks = {}
	local clone, oldRoot, hip, connection
	local folderConnections = {}
	local SINK_AMOUNT = 5
	local serverGhosts = {}
	local ghostEnabled = true
	local lagbackCallCount = 0
	local lagbackWindowStart = 0
	local lastLagbackTime = 0
	local errorOrbActive = false
	local errorOrb = nil
	local errorOrbConnection = nil

	local function clearErrorOrb()
		if errorOrb and errorOrb.Parent then errorOrb:Destroy() end
		errorOrb = nil; errorOrbActive = false
		if errorOrbConnection then errorOrbConnection:Disconnect(); errorOrbConnection = nil end
	end

	local function createErrorOrb()
		if errorOrbActive then return end
		errorOrbActive = true
		for _, ghost in pairs(serverGhosts) do if ghost and ghost.Parent then ghost:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "ErrorOrbGui"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local fr = Instance.new("Frame")
		fr.Size = UDim2.new(0, 500, 0, 60)
		fr.Position = UDim2.new(0.5, -250, 0.3, 0)
		fr.BackgroundTransparency = 1; fr.BorderSizePixel = 0; fr.Parent = sg
		local l1 = Instance.new("TextLabel")
		l1.Size = UDim2.new(1, 0, 0.5, 0); l1.BackgroundTransparency = 1
		l1.Text = "ERROR CAUSED BY PLAYER DEATH"
		l1.TextColor3 = Color3.fromRGB(255, 0, 0)
		l1.TextStrokeTransparency = 0; l1.TextStrokeColor3 = Color3.new(0, 0, 0)
		l1.Font = Enum.Font.SourceSansBold; l1.TextScaled = true; l1.Parent = fr
		local l2 = Instance.new("TextLabel")
		l2.Size = UDim2.new(1, 0, 0.5, 0); l2.Position = UDim2.new(0, 0, 0.5, 0)
		l2.BackgroundTransparency = 1; l2.Text = "MUST RESET TO FIX ERROR"
		l2.TextColor3 = Color3.fromRGB(255, 0, 0)
		l2.TextStrokeTransparency = 0; l2.TextStrokeColor3 = Color3.new(0, 0, 0)
		l2.Font = Enum.Font.SourceSansBold; l2.TextScaled = true; l2.Parent = fr
		errorOrb = sg
	end

	local function createServerGhost(position)
		if not ghostEnabled or errorOrbActive then return end
		local now = tick()
		if now - lastLagbackTime < 0.05 then return end
		lastLagbackTime = now
		if now - lagbackWindowStart > 1 then lagbackCallCount = 0; lagbackWindowStart = now end
		lagbackCallCount = lagbackCallCount + 1
		if lagbackCallCount >= 7 then createErrorOrb(); return end
		for _, g in pairs(serverGhosts) do if g and g.Parent then g:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "LagbackNotification"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local sl = Instance.new("TextLabel")
		sl.Size = UDim2.new(0, 500, 0, 30); sl.Position = UDim2.new(0.5, -250, 0.15, 0)
		sl.BackgroundTransparency = 1; sl.Text = "LAGBACK DETECTED"
		sl.TextColor3 = Color3.fromRGB(255, 0, 0)
		sl.TextStrokeTransparency = 0; sl.TextStrokeColor3 = Color3.new(0, 0, 0)
		sl.Font = Enum.Font.SourceSansBold; sl.TextScaled = true; sl.Parent = sg
		local sw = Instance.new("TextLabel")
		sw.Size = UDim2.new(0, 650, 0, 25); sw.Position = UDim2.new(0.5, -325, 0.15, 32)
		sw.BackgroundTransparency = 1
		sw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		sw.TextColor3 = Color3.fromRGB(200, 200, 200)
		sw.TextStrokeTransparency = 0; sw.TextStrokeColor3 = Color3.new(0, 0, 0)
		sw.Font = Enum.Font.SourceSansBold; sw.TextScaled = true; sw.Parent = sg
		task.delay(1.5, function() if sg and sg.Parent then sg:Destroy() end end)
		local ghost = Instance.new("Part")
		ghost.Name = "LagbackGhost"; ghost.Shape = Enum.PartType.Ball
		ghost.Size = Vector3.new(3, 3, 3); ghost.Color = Color3.fromRGB(255, 0, 0)
		ghost.Material = Enum.Material.Glass; ghost.Transparency = 0.3
		ghost.CanCollide = false; ghost.Anchored = true; ghost.CastShadow = false
		ghost.Position = position + Vector3.new(0, 5, 0); ghost.Parent = Workspace.CurrentCamera
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0, 400, 0, 60); bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = true; bb.Parent = ghost
		local bl = Instance.new("TextLabel")
		bl.Size = UDim2.new(1, 0, 0, 25); bl.BackgroundTransparency = 1
		bl.Text = "LAGBACK DETECTED"; bl.TextColor3 = Color3.fromRGB(255, 0, 0)
		bl.TextStrokeTransparency = 0; bl.TextStrokeColor3 = Color3.new(0, 0, 0)
		bl.Font = Enum.Font.SourceSansBold; bl.TextScaled = true; bl.Parent = bb
		local bw = Instance.new("TextLabel")
		bw.Size = UDim2.new(1, 0, 0, 25); bw.Position = UDim2.new(0, 0, 0, 25)
		bw.BackgroundTransparency = 1
		bw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		bw.TextColor3 = Color3.fromRGB(200, 200, 200)
		bw.TextStrokeTransparency = 0; bw.TextStrokeColor3 = Color3.new(0, 0, 0)
		bw.Font = Enum.Font.SourceSansBold; bw.TextScaled = true; bw.Parent = bb
		table.insert(serverGhosts, ghost)
	end

	local function clearAllGhosts()
		for _, ghost in pairs(serverGhosts) do pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end) end
		serverGhosts = {}; clearErrorOrb(); lagbackCallCount = 0; lastLagbackTime = 0
		pcall(function()
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name == "LagbackNotification" then gui:Destroy() end end end
		end)
		pcall(function() if Workspace.CurrentCamera then for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c.Name == "LagbackGhost" then c:Destroy() end end end end)
		pcall(function() for _, c in pairs(Workspace:GetDescendants()) do if c.Name == "LagbackGhost" then c:Destroy() end end end)
	end

	local function removeFolders()
		local pf = Workspace:FindFirstChild(LocalPlayer.Name)
		if not pf then return end
		local dr = pf:FindFirstChild("DoubleRig")
		if dr then
			local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
			if rr and ghostEnabled then createServerGhost(rr.Position) end
			dr:Destroy()
		end
		local cs = pf:FindFirstChild("Constraints")
		if cs then cs:Destroy() end
		local conn = pf.ChildAdded:Connect(function(child)
			if child.Name == "DoubleRig" then
				task.defer(function()
					local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
					if rr and ghostEnabled then createServerGhost(rr.Position) end
					child:Destroy()
				end)
			elseif child.Name == "Constraints" then child:Destroy() end
		end)
		table.insert(folderConnections, conn)
	end

	local function doClone()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			hip = character.Humanoid.HipHeight
			oldRoot = character:FindFirstChild("HumanoidRootPart")
			if not oldRoot or not oldRoot.Parent then return false end
			for _, c in pairs(oldRoot:GetChildren()) do
				if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then c:Destroy() end
			end
			for _, c in pairs(oldRoot:GetChildren()) do if c:IsA("Beam") then c:Destroy() end end
			local tmp = Instance.new("Model"); tmp.Parent = game
			character.Parent = tmp
			clone = oldRoot:Clone(); clone.Parent = character
			oldRoot.Parent = Workspace.CurrentCamera
			clone.CFrame = oldRoot.CFrame; character.PrimaryPart = clone
			character.Parent = Workspace
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("Weld") or v:IsA("Motor6D") then
					if v.Part0 == oldRoot then v.Part0 = clone end
					if v.Part1 == oldRoot then v.Part1 = clone end
				end
			end
			tmp:Destroy(); return true
		end
		return false
	end

	local function revertClone()
		local character = LocalPlayer.Character
		if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then return end
		local tmp = Instance.new("Model"); tmp.Parent = game
		character.Parent = tmp
		oldRoot.Parent = character; character.PrimaryPart = oldRoot
		character.Parent = Workspace; oldRoot.CanCollide = true
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Motor6D") then
				if v.Part0 == clone then v.Part0 = oldRoot end
				if v.Part1 == clone then v.Part1 = oldRoot end
			end
		end
		if clone then local p = clone.CFrame; clone:Destroy(); clone = nil; oldRoot.CFrame = p end
		oldRoot = nil
		if character and character.Humanoid then character.Humanoid.HipHeight = hip end
		clearAllGhosts()
	end

	local function animationTrickery()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			local anim = Instance.new("Animation")
			anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
			local humanoid = character.Humanoid
			local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
			local animTrack = animator:LoadAnimation(anim)
			animTrack.Priority = Enum.AnimationPriority.Action4
			animTrack:Play(0, 1, 0); anim:Destroy()
			table.insert(tracks, animTrack)
			animTrack.Stopped:Connect(function() if animPlaying then animationTrickery() end end)
			task.delay(0, function()
				animTrack.TimePosition = 0.7
				task.delay(0.3, function() if animTrack then animTrack:AdjustSpeed(math.huge) end end)
			end)
		end
	end

	local function turnOff()
		clearAllGhosts()
		if not animPlaying then return end
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		animPlaying = false; _G.invisibleStealEnabled = false
		for _, t in pairs(tracks) do pcall(function() t:Stop() end) end
		tracks = {}
		if connection then connection:Disconnect(); connection = nil end
		for _, c in ipairs(folderConnections) do if c then c:Disconnect() end end
		folderConnections = {}
		revertClone(); clearAllGhosts()
		if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		if updateVisualState then updateVisualState(false) end
	end

	local function turnOn()
		if animPlaying then return end
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		animPlaying = true; _G.invisibleStealEnabled = true
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, true) end
		if updateVisualState then updateVisualState(true) end
		tracks = {}; removeFolders()
		local success = doClone()
		if success then
			task.wait(0.05); animationTrickery()
			task.defer(function()
				if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end
				if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
				task.wait(0.1)
				if _G.updateBrainrotBeam then pcall(_G.updateBrainrotBeam) end
				if _G.createPlotBeam then pcall(_G.createPlotBeam) end
			end)
			local lastSetPosition = nil; local skipFrames = 5
			connection = RunService.PreSimulation:Connect(function()
				if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and oldRoot then
					local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
					if root then
						if skipFrames > 0 then skipFrames = skipFrames - 1; lastSetPosition = nil
						elseif lastSetPosition and ghostEnabled then
							local currentPos = oldRoot.Position
							local jumpDist = (currentPos - lastSetPosition).Magnitude
							if jumpDist > 3 and not _G.RecoveryInProgress then
								lastSetPosition = nil; createServerGhost(currentPos)
								if _G.AutoRecoverLagback and _G.toggleInvisibleSteal then
									_G.RecoveryInProgress = true
									task.spawn(function()
										pcall(_G.toggleInvisibleSteal); task.wait(0.5)
										pcall(_G.toggleInvisibleSteal); _G.RecoveryInProgress = false
									end)
								end
							end
						end
						if clone then clone.CanCollide = false end
						for _, c in pairs(oldRoot:GetChildren()) do
							if c:IsA("Attachment") or c:IsA("Beam") then c:Destroy() end
						end
						local rotAngle = _G.InvisStealAngle or 180
						local sa = (_G.SinkSliderValue or 5) * 0.5
						local cf = root.CFrame - Vector3.new(0, sa, 0)
						oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
						oldRoot.AssemblyLinearVelocity = root.AssemblyLinearVelocity; oldRoot.CanCollide = false
						lastSetPosition = oldRoot.Position
					end
				end
			end)
		end
	end

-- Invis Panel - Codify layout + full logic
-- Put in LocalScript inside StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ScreenGui (uses outer Theme so accent changes propagate)
local XiInvisPanel = Instance.new("ScreenGui")
XiInvisPanel.Name = "wxrldzStealHelper"
XiInvisPanel.ResetOnSpawn = false
XiInvisPanel.DisplayOrder = 999
XiInvisPanel.Parent = PlayerGui

-- Main Frame
local Frame = Instance.new("Frame")
Frame.ClipsDescendants = true
Frame.Size = UDim2.new(0, 220, 0, 310)
local uiScale = Instance.new("UIScale", Frame)
uiScale.Scale = IS_MOBILE and math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0, 1) or 1
if IS_MOBILE then SharedState.MobileScaleObjects[Frame] = uiScale end
do local _ip = Config.Positions and Config.Positions.InvisPanel; Frame.Position = _ip and UDim2.new(_ip.X, 0, _ip.Y, 0) or UDim2.new(0.50, -431, 0.30, 144) end
Frame.BorderSizePixel = 0
Frame.BackgroundColor3 = Theme.Background
Frame.Active = not IS_MOBILE
Frame.Parent = XiInvisPanel
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
RegisterClamp(Frame)

local borderStroke = Instance.new("UIStroke", Frame)
borderStroke.Color = Color3.fromRGB(0, 210, 255)
borderStroke.Thickness = 1
borderStroke.Transparency = 0.8

do local _sc=Instance.new("Frame",Frame); _sc.Name="_SparkCont"; _sc.BackgroundTransparency=1; _sc.Size=UDim2.new(1,0,1,0); _sc.Position=UDim2.new(0,0,0,0); _sc.BorderSizePixel=0; _sc.ZIndex=1; _sc.Visible=Config.HudSparkles~=false; SharedState.SparkleCont1=_sc; local _stars={{0.07,0.04,1,0.55,2.0},{0.23,0.09,2,0.35,3.2},{0.61,0.06,1,0.70,2.5},{0.84,0.12,1,0.40,4.1},{0.45,0.03,2,0.60,3.7},{0.92,0.20,1,0.30,2.8},{0.14,0.18,1,0.65,5.0},{0.50,0.15,2,0.45,2.3},{0.76,0.28,1,0.50,3.5},{0.32,0.22,1,0.75,4.6},{0.05,0.35,2,0.40,2.1},{0.68,0.38,1,0.55,3.0},{0.88,0.42,1,0.30,4.8},{0.40,0.44,2,0.65,2.7},{0.19,0.50,1,0.45,3.9},{0.55,0.52,1,0.70,5.0},{0.79,0.55,2,0.35,2.2},{0.30,0.60,1,0.60,3.3},{0.10,0.65,1,0.50,4.0},{0.63,0.62,2,0.40,2.9},{0.94,0.68,1,0.55,3.6},{0.47,0.70,1,0.30,2.4},{0.22,0.75,2,0.70,4.5},{0.72,0.72,1,0.45,3.1},{0.38,0.80,1,0.60,2.6},{0.85,0.78,2,0.35,5.0},{0.15,0.85,1,0.55,3.8},{0.56,0.82,1,0.40,2.2},{0.02,0.90,2,0.65,4.3},{0.70,0.88,1,0.50,3.0}}; for _,s in ipairs(_stars) do local d=Instance.new("Frame",_sc); d.Size=UDim2.new(0,s[3],0,s[3]); d.Position=UDim2.new(s[1],0,s[2],0); d.AnchorPoint=Vector2.new(0.5,0.5); d.BackgroundColor3=Color3.fromRGB(220,235,255); d.BackgroundTransparency=s[4]; d.BorderSizePixel=0; d.ZIndex=1; Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); TweenService:Create(d,TweenInfo.new(s[5],Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=math.min(s[4]+0.45,0.95)}):Play() end end

-- Top accent bar
local _shAccent = Instance.new("Frame", Frame)
_shAccent.Size = UDim2.new(1, 0, 0, 4); _shAccent.Position = UDim2.new(0, 0, 0, 0)
_shAccent.BackgroundColor3 = Theme.Accent1; _shAccent.BorderSizePixel = 0; _shAccent.ZIndex = 5
Instance.new("UICorner", _shAccent).CornerRadius = UDim.new(0, 8)
SharedState.StealHelperAccentBar = _shAccent

-- Header
local header = Instance.new("Frame", Frame)
header.Size = UDim2.new(1, 0, 0, 46)
header.Position = UDim2.new(0, 0, 0, 3)
header.BackgroundTransparency = 1
header.Active = true

-- Title split: "STEAL" white + "HELPER" cyan
local _shTitleA = Instance.new("TextLabel", header)
_shTitleA.Font = Enum.Font.GothamBold; _shTitleA.TextXAlignment = Enum.TextXAlignment.Left
_shTitleA.TextSize = 15; _shTitleA.Size = UDim2.new(0, 58, 1, 0); _shTitleA.Position = UDim2.new(0, 14, 0, 0)
_shTitleA.Text = "STEAL"; _shTitleA.TextColor3 = Color3.fromRGB(220, 225, 240); _shTitleA.BackgroundTransparency = 1

local _shTitleB = Instance.new("TextLabel", header)
_shTitleB.Font = Enum.Font.GothamBold; _shTitleB.TextXAlignment = Enum.TextXAlignment.Left
_shTitleB.TextSize = 15; _shTitleB.Size = UDim2.new(0, 70, 1, 0); _shTitleB.Position = UDim2.new(0, 68, 0, 0)
_shTitleB.Text = "PANEL"; _shTitleB.TextColor3 = Theme.Accent1; _shTitleB.BackgroundTransparency = 1

-- Clone cooldown label next to header title
local _shCloneLabel = Instance.new("TextLabel", header)
_shCloneLabel.Font = Enum.Font.GothamBold; _shCloneLabel.TextXAlignment = Enum.TextXAlignment.Left
_shCloneLabel.TextSize = 10; _shCloneLabel.Size = UDim2.new(0, 66, 0, 18)
_shCloneLabel.Position = UDim2.new(0, 142, 0.5, -9)
_shCloneLabel.Text = "CLONE: --"; _shCloneLabel.TextColor3 = Theme.Accent1; _shCloneLabel.BackgroundTransparency = 1
RunService.Heartbeat:Connect(function()
    if not _shCloneLabel.Parent then return end
    local elapsed = tick() - _lastCloneTime
    local remaining = math.max(0, 10 - elapsed)
    if _lastCloneTime == 0 then
        _shCloneLabel.Text = "CLONE: --"
        _shCloneLabel.TextColor3 = Theme.Accent1
    elseif remaining > 0 then
        _shCloneLabel.Text = string.format("CLONE: %.1fs", remaining)
        _shCloneLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
    else
        _shCloneLabel.Text = "CLONE: RDY"
        _shCloneLabel.TextColor3 = Color3.fromRGB(0, 210, 100)
    end
end)

-- Header separator
local _shHSep = Instance.new("Frame", Frame)
_shHSep.Size = UDim2.new(1, -20, 0, 1); _shHSep.Position = UDim2.new(0, 10, 0, 49)
_shHSep.BackgroundColor3 = Color3.fromRGB(25, 28, 40); _shHSep.BorderSizePixel = 0

-- Resize button
local resizeBtn = Instance.new("TextButton", header)
resizeBtn.ZIndex = 10
resizeBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
resizeBtn.Font = Enum.Font.GothamMedium
resizeBtn.TextSize = 11
resizeBtn.Size = UDim2.new(0, 22, 0, 22)
resizeBtn.TextColor3 = Color3.fromRGB(0, 200, 255)
resizeBtn.Text = "↕"
resizeBtn.Position = UDim2.new(1, -26, 0.5, -11)
Instance.new("UICorner", resizeBtn).CornerRadius = UDim.new(1, 0)

-- Drag logic (mouse + touch)
do
    local dragging, dragStart, startAbsX, startAbsY
    local function overHeader(pos)
        local hp = header.AbsolutePosition
        local hs = header.AbsoluteSize
        return pos.X >= hp.X and pos.X <= hp.X + hs.X and pos.Y >= hp.Y and pos.Y <= hp.Y + hs.Y
    end
    local function overResize(pos)
        local rp = resizeBtn.AbsolutePosition; local rs = resizeBtn.AbsoluteSize
        return pos.X >= rp.X and pos.X <= rp.X + rs.X and pos.Y >= rp.Y and pos.Y <= rp.Y + rs.Y
    end
    UserInputService.InputBegan:Connect(function(inp)
        if Config.UILocked then return end
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        if not isMouse and not isTouch then return end
        if overResize(inp.Position) then return end
        if not overHeader(inp.Position) then return end
        dragging = true
        dragStart = inp.Position
        startAbsX = Frame.AbsolutePosition.X
        startAbsY = Frame.AbsolutePosition.Y
    end)
    UserInputService.InputEnded:Connect(function(inp)
        local isMouse = inp.UserInputType == Enum.UserInputType.MouseButton1
        local isTouch = inp.UserInputType == Enum.UserInputType.Touch
        if (isMouse or isTouch) and dragging then
            dragging = false
            local vp = workspace.CurrentCamera.ViewportSize
            Config.Positions = Config.Positions or {}
            Config.Positions.InvisPanel = {
                X = Frame.AbsolutePosition.X / vp.X,
                Y = Frame.AbsolutePosition.Y / vp.Y,
            }
            SaveConfig()
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not dragging then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local d = inp.Position - dragStart
            local vp = workspace.CurrentCamera.ViewportSize
            local m = 40
            local newX = math.clamp(startAbsX + d.X, -(Frame.AbsoluteSize.X - m), vp.X - m)
            local newY = math.clamp(startAbsY + d.Y, -(Frame.AbsoluteSize.Y - m), vp.Y - m)
            Frame.Position = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- Resize logic (supports both mouse and touch)
do
    local dragY, startScale, resizing
    local function isOverResizeBtn(pos)
        local rp = resizeBtn.AbsolutePosition
        local rs = resizeBtn.AbsoluteSize
        return pos.X >= rp.X and pos.X <= rp.X + rs.X and pos.Y >= rp.Y and pos.Y <= rp.Y + rs.Y
    end
    UserInputService.InputBegan:Connect(function(inp)
        if Config.UILocked then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if inp.UserInputType == Enum.UserInputType.Touch and not isOverResizeBtn(inp.Position) then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                -- only start resize if clicking directly on resizeBtn
                local rp = resizeBtn.AbsolutePosition; local rs = resizeBtn.AbsoluteSize
                if not (inp.Position.X >= rp.X and inp.Position.X <= rp.X + rs.X and inp.Position.Y >= rp.Y and inp.Position.Y <= rp.Y + rs.Y) then return end
            end
            resizing = true
            dragY = inp.Position.Y
            startScale = uiScale.Scale
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not resizing then return end
        if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
            local delta = inp.Position.Y - dragY
            uiScale.Scale = math.clamp(startScale + delta / 200, 0.4, 1.4)
            Config.MobileGuiScale = tostring(uiScale.Scale)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            if resizing then resizing = false; SaveConfig() end
        end
    end)
end

-- Content container
local container = Instance.new("Frame", Frame)
container.Size = UDim2.new(1, -20, 1, -52)
container.Position = UDim2.new(0, 10, 0, 52)
container.BackgroundTransparency = 1
local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 1)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function Row(height)
    local r = Instance.new("Frame", container)
    r.Size = UDim2.new(1, 0, 0, height or 26)
    r.BackgroundTransparency = 1
    return r
end

local function Divider()
    local r = Row(1)
    local d = Instance.new("Frame", r)
    d.Size = UDim2.new(1, 0, 0, 1)
    d.BackgroundColor3 = Color3.fromRGB(25, 28, 40)
    d.BorderSizePixel = 0
end

-- Steal Speed slider
local ssSliderValue = Config.StealSpeed or 20
local rSS = Row(40)
local ssLbl = Instance.new("TextLabel", rSS)
ssLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
ssLbl.TextXAlignment = Enum.TextXAlignment.Left
ssLbl.TextSize = 10
ssLbl.Size = UDim2.new(0.60, 0, 0, 15)
ssLbl.Text = "Steal Speed: " .. ssSliderValue
ssLbl.TextColor3 = Color3.fromRGB(65, 70, 95)
ssLbl.BackgroundTransparency = 1
local ssToggleBtn = Instance.new("TextButton", rSS)
ssToggleBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
ssToggleBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
ssToggleBtn.TextSize = 11
ssToggleBtn.Size = UDim2.new(0, 40, 0, 24)
ssToggleBtn.TextColor3 = Theme.Accent1
ssToggleBtn.Text = "OFF"
ssToggleBtn.Position = UDim2.new(1, -40, 0, 0)
Instance.new("UICorner", ssToggleBtn).CornerRadius = UDim.new(1, 0)
local _ssToggleStroke = Instance.new("UIStroke", ssToggleBtn)
_ssToggleStroke.Color = Theme.Accent1; _ssToggleStroke.Thickness = 1; _ssToggleStroke.Transparency = 0.5
ssToggleBtn.MouseButton1Click:Connect(function()
    if SharedState and SharedState.StealSpeedToggleFunc then
        SharedState.StealSpeedToggleFunc()
    end
end)
SharedState._ssUpdateBtn = function()
    local on = SharedState._ssEnabled or false
    ssToggleBtn.Text = on and "ON" or "OFF"
    ssToggleBtn.BackgroundColor3 = on and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    ssToggleBtn.TextColor3 = on and Color3.fromRGB(5, 5, 10) or Theme.Accent1
    _ssToggleStroke.Transparency = on and 1 or 0.5
end
local ssBg = Instance.new("Frame", rSS)
ssBg.Size = UDim2.new(1, 0, 0, 6)
ssBg.Position = UDim2.new(0, 0, 0, 25)
ssBg.BorderSizePixel = 0
ssBg.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
Instance.new("UICorner", ssBg).CornerRadius = UDim.new(1, 0)
local ssFill = Instance.new("Frame", ssBg)
ssFill.Size = UDim2.new((ssSliderValue - 5) / 95, 0, 1, 0)
ssFill.BorderSizePixel = 0
ssFill.BackgroundColor3 = Theme.Accent1
Instance.new("UICorner", ssFill).CornerRadius = UDim.new(1, 0)
local ssKnob = Instance.new("Frame", ssBg)
ssKnob.AnchorPoint = Vector2.new(0.5, 0.5)
ssKnob.Size = UDim2.new(0, 12, 0, 12)
ssKnob.Position = UDim2.new((ssSliderValue - 5) / 95, 0, 0.5, 0)
ssKnob.BorderSizePixel = 0
ssKnob.BackgroundColor3 = Color3.fromRGB(220, 225, 240)
Instance.new("UICorner", ssKnob).CornerRadius = UDim.new(1, 0)
local ssKnobStroke = Instance.new("UIStroke", ssKnob)
ssKnobStroke.Color = Theme.Accent1
ssKnobStroke.Thickness = 1.5
do
    local dragging = false
    local function update(x)
        local p = math.clamp((x - ssBg.AbsolutePosition.X) / ssBg.AbsoluteSize.X, 0, 1)
        ssSliderValue = math.floor(5 + p * 95)
        ssFill.Size = UDim2.new(p, 0, 1, 0)
        ssKnob.Position = UDim2.new(p, 0, 0.5, 0)
        ssLbl.Text = "Steal Speed: " .. ssSliderValue
        Config.StealSpeed = ssSliderValue
        SaveConfig()
        if SharedState and SharedState.SetStealSpeed then SharedState.SetStealSpeed(ssSliderValue) end
    end
    ssBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; update(i.Position.X) end
    end)
    ssKnob.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then update(i.Position.X) end
    end)
end

Divider()

-- Auto-Destroy Turrets toggle
local rADT = Row(26)
local adtLbl = Instance.new("TextLabel", rADT)
adtLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
adtLbl.TextXAlignment = Enum.TextXAlignment.Left
adtLbl.TextSize = 12
adtLbl.Size = UDim2.new(0.70, 0, 1, 0)
adtLbl.Text = "Auto-Destroy Turrets"
adtLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
adtLbl.BackgroundTransparency = 1
local btnADT = Instance.new("TextButton", rADT)
btnADT.BackgroundColor3 = Config.AutoDestroyTurrets and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
btnADT.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnADT.TextSize = 11
btnADT.Size = UDim2.new(0, 40, 0, 24)
btnADT.TextColor3 = Config.AutoDestroyTurrets and Color3.fromRGB(5, 5, 10) or Theme.Accent1
btnADT.Text = Config.AutoDestroyTurrets and "ON" or "OFF"
btnADT.Position = UDim2.new(1, -40, 0.5, -12)
Instance.new("UICorner", btnADT).CornerRadius = UDim.new(1, 0)
local _btnADTStroke = Instance.new("UIStroke", btnADT)
_btnADTStroke.Color = Theme.Accent1; _btnADTStroke.Thickness = 1; _btnADTStroke.Transparency = Config.AutoDestroyTurrets and 1 or 0.5
btnADT.MouseButton1Click:Connect(function()
    Config.AutoDestroyTurrets = not Config.AutoDestroyTurrets
    SaveConfig()
    btnADT.Text = Config.AutoDestroyTurrets and "ON" or "OFF"
    btnADT.BackgroundColor3 = Config.AutoDestroyTurrets and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnADT.TextColor3 = Config.AutoDestroyTurrets and Color3.fromRGB(5, 5, 10) or Theme.Accent1
    _btnADTStroke.Transparency = Config.AutoDestroyTurrets and 1 or 0.5
end)

Divider()

-- Auto-Kick on Steal toggle
local rAKS = Row(26)
local aksLbl = Instance.new("TextLabel", rAKS)
aksLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
aksLbl.TextXAlignment = Enum.TextXAlignment.Left
aksLbl.TextSize = 12
aksLbl.Size = UDim2.new(0.70, 0, 1, 0)
aksLbl.Text = "Auto-Kick on Steal"
aksLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
aksLbl.BackgroundTransparency = 1
local btnAKS = Instance.new("TextButton", rAKS)
btnAKS.BackgroundColor3 = Config.AutoKickOnSteal and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
btnAKS.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnAKS.TextSize = 11
btnAKS.Size = UDim2.new(0, 40, 0, 24)
btnAKS.TextColor3 = Config.AutoKickOnSteal and Color3.fromRGB(5, 5, 10) or Theme.Accent1
btnAKS.Text = Config.AutoKickOnSteal and "ON" or "OFF"
btnAKS.Position = UDim2.new(1, -40, 0.5, -12)
Instance.new("UICorner", btnAKS).CornerRadius = UDim.new(1, 0)
local _btnAKSStroke = Instance.new("UIStroke", btnAKS)
_btnAKSStroke.Color = Theme.Accent1; _btnAKSStroke.Thickness = 1; _btnAKSStroke.Transparency = Config.AutoKickOnSteal and 1 or 0.5
btnAKS.MouseButton1Click:Connect(function()
    Config.AutoKickOnSteal = not Config.AutoKickOnSteal
    SaveConfig()
    btnAKS.Text = Config.AutoKickOnSteal and "ON" or "OFF"
    btnAKS.BackgroundColor3 = Config.AutoKickOnSteal and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnAKS.TextColor3 = Config.AutoKickOnSteal and Color3.fromRGB(5, 5, 10) or Theme.Accent1
    _btnAKSStroke.Transparency = Config.AutoKickOnSteal and 1 or 0.5
end)

Divider()

-- Anti Steal toggle (steal panel)
local rAS2 = Row(26)
local asLbl2 = Instance.new("TextLabel", rAS2)
asLbl2.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
asLbl2.TextXAlignment = Enum.TextXAlignment.Left
asLbl2.TextSize = 12
asLbl2.Size = UDim2.new(0, 78, 1, 0)
asLbl2.Text = "Anti Steal"
asLbl2.TextColor3 = Color3.fromRGB(220, 225, 240)
asLbl2.BackgroundTransparency = 1
local btnAS2 = Instance.new("TextButton", rAS2)
btnAS2.BackgroundColor3 = Config.AntiStealEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
btnAS2.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnAS2.TextSize = 11
btnAS2.Size = UDim2.new(0, 40, 0, 22)
btnAS2.TextColor3 = Config.AntiStealEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
btnAS2.Text = Config.AntiStealEnabled and "ON" or "OFF"
btnAS2.Position = UDim2.new(1, -125, 0.5, -11)
Instance.new("UICorner", btnAS2).CornerRadius = UDim.new(1, 0)
local _btnAS2Stroke = Instance.new("UIStroke", btnAS2)
_btnAS2Stroke.Color = Theme.Accent1; _btnAS2Stroke.Thickness = 1; _btnAS2Stroke.Transparency = Config.AntiStealEnabled and 1 or 0.5
btnAS2.MouseButton1Click:Connect(function()
    Config.AntiStealEnabled = not Config.AntiStealEnabled
    SaveConfig()
    btnAS2.Text = Config.AntiStealEnabled and "ON" or "OFF"
    btnAS2.BackgroundColor3 = Config.AntiStealEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnAS2.TextColor3 = Config.AntiStealEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
    _btnAS2Stroke.Transparency = Config.AntiStealEnabled and 1 or 0.5
    if Config.AntiStealEnabled then
        if SharedState.StartAntiSteal then SharedState.StartAntiSteal() end
    else
        if SharedState.StopAntiSteal then SharedState.StopAntiSteal() end
    end
    ShowNotification("ANTI STEAL", Config.AntiStealEnabled and "ON" or "OFF")
end)

-- FILL button (buy carpet pets until base is full, only when not stealing)
local btnFill = Instance.new("TextButton", rAS2)
btnFill.Size = UDim2.new(0, 38, 0, 22)
btnFill.Position = UDim2.new(1, -82, 0.5, -11)
btnFill.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
btnFill.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnFill.TextSize = 10
btnFill.TextColor3 = Theme.Accent1
btnFill.Text = "FILL"
btnFill.BorderSizePixel = 0
btnFill.AutoButtonColor = false
Instance.new("UICorner", btnFill).CornerRadius = UDim.new(1, 0)
local _fillStroke = Instance.new("UIStroke", btnFill)
_fillStroke.Color = Theme.Accent1; _fillStroke.Thickness = 1; _fillStroke.Transparency = 0.5
btnFill.MouseButton1Click:Connect(function()
    if LocalPlayer:GetAttribute("Stealing") then
        ShowNotification("FILL", "Cannot fill while stealing!"); return
    end
    if SharedState.RunFillBase then task.spawn(SharedState.RunFillBase) end
end)

-- DELETE button (delete X random slots spread across floors)
local btnDel = Instance.new("TextButton", rAS2)
btnDel.Size = UDim2.new(0, 38, 0, 22)
btnDel.Position = UDim2.new(1, -40, 0.5, -11)
btnDel.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
btnDel.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnDel.TextSize = 10
btnDel.TextColor3 = Theme.Accent1
btnDel.Text = "DEL"
btnDel.BorderSizePixel = 0
btnDel.AutoButtonColor = false
Instance.new("UICorner", btnDel).CornerRadius = UDim.new(1, 0)
local _delStroke = Instance.new("UIStroke", btnDel)
_delStroke.Color = Theme.Accent1; _delStroke.Thickness = 1; _delStroke.Transparency = 0.5
btnDel.MouseButton1Click:Connect(function()
    if SharedState.RunDeleteSlots then task.spawn(SharedState.RunDeleteSlots) end
end)

Divider()

-- Auto Buy
local _autoBuyEnabled = false
local _abLastFired = {}
local _abLockedBest = nil
local _abCachedPrompts = {}
local _abPromptCacheTime = 0
local AB_PROMPT_CACHE_DURATION = 2

local function _abParseGen(txt)
    if not txt then return 0 end
    local s = string.lower(tostring(txt))
    local n = tonumber(s:match("[%d%.]+")) or 0
    if s:find("t") then n = n * 1e12
    elseif s:find("b") then n = n * 1e9
    elseif s:find("m") then n = n * 1e6
    elseif s:find("k") then n = n * 1e3 end
    return n
end

local function _abCollectPrompts()
    local prompts = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Model") then
            for _, d in ipairs(obj:GetDescendants()) do
                pcall(function()
                    if d:IsA("ProximityPrompt") then
                        local act = (d.ActionText or ""):lower()
                        if act:find("purchase") or act:find("buy") or act:find("kauf") then
                            local pos, par = nil, d.Parent
                            if par and par:IsA("Attachment") then
                                pos = par.WorldPosition
                            elseif par and par:IsA("BasePart") then
                                pos = par.Position
                            end
                            if pos then prompts[#prompts + 1] = { prompt = d, pos = pos } end
                        end
                    end
                end)
            end
        end
    end
    return prompts
end

local function _abGetCachedPrompts()
    local now = tick()
    if (now - _abPromptCacheTime) < AB_PROMPT_CACHE_DURATION and #_abCachedPrompts > 0 then
        return _abCachedPrompts
    end
    _abCachedPrompts = _abCollectPrompts()
    _abPromptCacheTime = now
    return _abCachedPrompts
end

local function _abFindNearest(tpos, prompts)
    local best, bd = nil, 20
    for _, e in ipairs(prompts) do
        local d = (e.pos - tpos).Magnitude
        if d < bd then best = e.prompt; bd = d end
    end
    return best
end

local function _abScanItems()
    local items = {}
    local debris = Workspace:FindFirstChild("Debris")
    if not debris then return items end
    local prompts = _abGetCachedPrompts()
    for _, obj in ipairs(debris:GetChildren()) do
        pcall(function()
            if not obj:IsA("BasePart") then return end
            local displayName, genValue
            for _, child in ipairs(obj:GetChildren()) do
                if child:IsA("BillboardGui") or child:IsA("SurfaceGui") then
                    for _, label in ipairs(child:GetDescendants()) do
                        if label:IsA("TextLabel") then
                            if label.Name == "DisplayName" then displayName = label.Text
                            elseif label.Name == "Generation" and (label.Text or ""):find("/s") then
                                genValue = _abParseGen(label.Text)
                            end
                        end
                    end
                end
            end
            if not displayName or not genValue or genValue <= 0 then return end
            local prompt = _abFindNearest(obj.Position, prompts)
            if not prompt then return end
            items[#items + 1] = { name = displayName, genValue = genValue, part = obj, position = obj.Position, prompt = prompt }
        end)
    end
    return items
end

local function _abParseMinGen()
    local raw = Config.AutoBuyMinGen or ""
    if raw == "" then return 0 end
    return _abParseGen(raw)
end

local function _abGetBest()
    local items = _abScanItems()
    if #items == 0 then return nil end
    local minGen = _abParseMinGen()

    -- filter by min gen
    local eligible = {}
    for _, e in ipairs(items) do
        if e.genValue >= minGen then
            eligible[#eligible + 1] = e
        end
    end
    if #eligible == 0 then return nil end

    -- try priority list first (highest priority wins)
    for _, pName in ipairs(PRIORITY_LIST) do
        local search = pName:lower()
        for _, e in ipairs(eligible) do
            if e.name and e.name:lower() == search then
                return e
            end
        end
    end

    -- fallback: highest gen among eligible
    local best, bg = nil, -1
    for _, e in ipairs(eligible) do
        if e.genValue > bg then best = e; bg = e.genValue end
    end
    return best
end

local function _abEquipCarpet()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local currentTool = char:FindFirstChildOfClass("Tool")
        if currentTool and currentTool.Name == "Flying Carpet" then return end
        if currentTool then hum:UnequipTools() end
        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            local tool = bp:FindFirstChild("Flying Carpet")
            if tool and tool:IsA("Tool") then hum:EquipTool(tool) end
        end
    end)
end

do
    local antiDieConn, antiDieDiedConn
    local function enableAntiDie()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        if antiDieConn then antiDieConn:Disconnect() end
        antiDieConn = hum:GetPropertyChangedSignal("Health"):Connect(function()
            if _autoBuyEnabled and not _G.AntiDieDisabled and hum.Health <= 0 then hum.Health = hum.MaxHealth end
        end)
        if antiDieDiedConn then antiDieDiedConn:Disconnect() end
        antiDieDiedConn = hum.Died:Connect(function()
            if not _autoBuyEnabled or _G.AntiDieDisabled then return end
            task.wait()
            local newHum = Instance.new("Humanoid")
            newHum.Name = "ReplacedHumanoid"
            newHum.Parent = char
            Workspace.CurrentCamera.CameraSubject = newHum
            hum:Destroy()
        end)
    end
    enableAntiDie()
    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.1)
        enableAntiDie()
    end)
end

task.spawn(function()
    task.wait(3)
    while task.wait(0.05) do
        if not _autoBuyEnabled then
            _abLockedBest = nil
            continue
        end
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            if not _abLockedBest or not _abLockedBest.part or not _abLockedBest.part.Parent
                or not _abLockedBest.prompt or not _abLockedBest.prompt.Parent then
                _abLockedBest = _abGetBest()
            end
            local best = _abLockedBest
            if not best or not best.prompt or not best.prompt.Parent then return end
            if best.part and best.part.Parent then best.position = best.part.Position end
            _abEquipCarpet()
            hrp.CFrame = CFrame.new(best.position.X, best.position.Y, best.position.Z)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            local prompt = best.prompt
            if not _abLastFired[prompt] or (tick() - _abLastFired[prompt] > 0.01) then
                _abLastFired[prompt] = tick()
                pcall(function()
                    local oldHold = prompt.HoldDuration
                    local oldMax = prompt.MaxActivationDistance
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = math.huge
                    pcall(fireproximityprompt, prompt)
                    prompt.HoldDuration = oldHold
                    prompt.MaxActivationDistance = oldMax
                end)
            end
            local now = tick()
            for p, t in pairs(_abLastFired) do
                if now - t > 0.15 or not p.Parent then _abLastFired[p] = nil end
            end
        end)
    end
end)

local rAB = Row(26)
local abLbl = Instance.new("TextLabel", rAB)
abLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
abLbl.TextXAlignment = Enum.TextXAlignment.Left
abLbl.TextSize = 12
abLbl.Size = UDim2.new(0.70, 0, 1, 0)
abLbl.Text = "Auto Buy"
abLbl.TextColor3 = Color3.fromRGB(220, 225, 240)
abLbl.BackgroundTransparency = 1
local btnAB = Instance.new("TextButton", rAB)
btnAB.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
btnAB.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnAB.TextSize = 11
btnAB.Size = UDim2.new(0, 40, 0, 24)
btnAB.TextColor3 = Theme.Accent1
btnAB.Text = "OFF"
btnAB.Position = UDim2.new(1, -40, 0.5, -12)
Instance.new("UICorner", btnAB).CornerRadius = UDim.new(1, 0)
local _btnABStroke = Instance.new("UIStroke", btnAB)
_btnABStroke.Color = Theme.Accent1; _btnABStroke.Thickness = 1; _btnABStroke.Transparency = 0.5
btnAB.MouseButton1Click:Connect(function()
    _autoBuyEnabled = not _autoBuyEnabled
    if not _autoBuyEnabled then _abLockedBest = nil end
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.BreakJointsOnDeath = not _autoBuyEnabled
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, not _autoBuyEnabled)
        end
    end)
    btnAB.Text = _autoBuyEnabled and "ON" or "OFF"
    btnAB.BackgroundColor3 = _autoBuyEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnAB.TextColor3 = _autoBuyEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
    _btnABStroke.Transparency = _autoBuyEnabled and 1 or 0.5
    ShowNotification("AUTO BUY", _autoBuyEnabled and "ON" or "OFF")
end)

Divider()

-- Compact 2-col action rows
do
    local function ActionBtn(parent, text, xOff, width, onClick)
        local b = Instance.new("TextButton", parent)
        b.Size = UDim2.new(0, width, 1, -4)
        b.Position = UDim2.new(0, xOff, 0, 2)
        b.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
        b.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        b.TextSize = 11; b.TextColor3 = Theme.Accent1; b.Text = text
        b.BorderSizePixel = 0; b.AutoButtonColor = false
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
        local sk = Instance.new("UIStroke", b); sk.Color = Theme.Accent1; sk.Thickness = 1; sk.Transparency = 0.5
        b.MouseEnter:Connect(function() b.BackgroundColor3 = Theme.Accent1; b.TextColor3 = Color3.fromRGB(5,5,10); sk.Transparency = 1 end)
        b.MouseLeave:Connect(function() b.BackgroundColor3 = Color3.fromRGB(16,18,26); b.TextColor3 = Theme.Accent1; sk.Transparency = 0.5 end)
        b.MouseButton1Click:Connect(onClick)
        return b
    end
    local half = 97
    local gap = 6

    local rRow1 = Row(26)
    ActionBtn(rRow1, "RESET",   0,    half, function() task.spawn(executeReset) end)
    ActionBtn(rRow1, "REJOIN",  half+gap, half, function()
        ShowNotification("REJOIN","Rejoining...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)

    local rRow2 = Row(26)
    ActionBtn(rRow2, "KICK",     0,    half, function() kickPlayer() end)
    ActionBtn(rRow2, "SETTINGS", half+gap, half, function()
        if settingsGui then
            settingsGui.Enabled = not settingsGui.Enabled
            if not Config.UIVisible then Config.UIVisible = {} end
            Config.UIVisible.Settings = settingsGui.Enabled; SaveConfig()
        end
    end)
end

Divider()

-- Invis Panel toggle row
local rInvisPanel = Row(22)
local ipLbl = Instance.new("TextLabel", rInvisPanel)
ipLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
ipLbl.TextXAlignment = Enum.TextXAlignment.Left; ipLbl.TextSize = 11
ipLbl.Size = UDim2.new(0.60, 0, 1, 0); ipLbl.Text = "Invis Panel"
ipLbl.TextColor3 = Theme.TextSecondary; ipLbl.BackgroundTransparency = 1
local btnIPToggle = Instance.new("TextButton", rInvisPanel)
btnIPToggle.BackgroundColor3 = (not Config.HideInvisPanel) and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
btnIPToggle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
btnIPToggle.TextSize = 10; btnIPToggle.Size = UDim2.new(0, 38, 0, 18)
btnIPToggle.TextColor3 = (not Config.HideInvisPanel) and Color3.fromRGB(5,5,10) or Theme.Accent1
btnIPToggle.Text = Config.HideInvisPanel and "HIDE" or "SHOW"
btnIPToggle.Position = UDim2.new(1, -40, 0.5, -9); btnIPToggle.BorderSizePixel = 0
Instance.new("UICorner", btnIPToggle).CornerRadius = UDim.new(1, 0)
local _ipStroke = Instance.new("UIStroke", btnIPToggle); _ipStroke.Color = Theme.Accent1; _ipStroke.Thickness = 1
_ipStroke.Transparency = Config.HideInvisPanel and 0.5 or 1
local function _syncInvisPanelBtn(show)
    btnIPToggle.Text = show and "SHOW" or "HIDE"
    btnIPToggle.BackgroundColor3 = show and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnIPToggle.TextColor3 = show and Color3.fromRGB(5,5,10) or Theme.Accent1
    _ipStroke.Transparency = show and 1 or 0.5
end
SharedState.SyncInvisPanelBtn = _syncInvisPanelBtn

btnIPToggle.MouseButton1Click:Connect(function()
    Config.HideInvisPanel = not Config.HideInvisPanel; SaveConfig()
    local show = not Config.HideInvisPanel
    _syncInvisPanelBtn(show)
    local ipGui = PlayerGui:FindFirstChild("wxrldzInvisPanel")
    if ipGui then ipGui.Enabled = show end
end)

print("Steal Panel loaded!")

-- ===== INVIS MINI PANEL =====
do
    local _ipGui = Instance.new("ScreenGui")
    _ipGui.Name = "wxrldzInvisPanel"
    _ipGui.ResetOnSpawn = false
    _ipGui.DisplayOrder = 999
    _ipGui.Parent = PlayerGui
    _ipGui.Enabled = not (Config.HideInvisPanel)

    local _ipFrame = Instance.new("Frame")
    _ipFrame.Name = "Frame"
    _ipFrame.Size = UDim2.new(0, 200, 0, 198)
    _ipFrame.BackgroundColor3 = Theme.Background
    _ipFrame.BorderSizePixel = 0
    _ipFrame.ClipsDescendants = true
    do local _ip = Config.Positions and Config.Positions.InvisMiniPanel; _ipFrame.Position = _ip and UDim2.new(_ip.X,0,_ip.Y,0) or UDim2.new(0.58,0,0.17,0) end
    _ipFrame.Parent = _ipGui
    Instance.new("UICorner", _ipFrame).CornerRadius = UDim.new(0, 8)
    RegisterClamp(_ipFrame)

    local _ipStroke = Instance.new("UIStroke", _ipFrame)
    _ipStroke.Color = Theme.Accent1; _ipStroke.Thickness = 1; _ipStroke.Transparency = 0.8

    -- Sparkle background
    do local _sc=Instance.new("Frame",_ipFrame); _sc.Name="_SparkCont"; _sc.BackgroundTransparency=1; _sc.Size=UDim2.new(1,0,1,0); _sc.Position=UDim2.new(0,0,0,0); _sc.BorderSizePixel=0; _sc.ZIndex=1; _sc.Visible=Config.HudSparkles~=false; SharedState.SparkleCont3=_sc; local _stars={{0.12,0.08,1,0.55,2.5},{0.55,0.05,2,0.40,3.1},{0.82,0.15,1,0.60,2.0},{0.28,0.20,1,0.45,4.0},{0.70,0.30,2,0.35,2.8},{0.08,0.45,1,0.65,3.5},{0.48,0.55,1,0.50,2.3},{0.90,0.60,2,0.40,4.2},{0.35,0.70,1,0.55,2.7},{0.65,0.80,1,0.45,3.8},{0.20,0.88,2,0.30,2.1}}; for _,s in ipairs(_stars) do local d=Instance.new("Frame",_sc); d.Size=UDim2.new(0,s[3],0,s[3]); d.Position=UDim2.new(s[1],0,s[2],0); d.AnchorPoint=Vector2.new(0.5,0.5); d.BackgroundColor3=Color3.fromRGB(220,235,255); d.BackgroundTransparency=s[4]; d.BorderSizePixel=0; d.ZIndex=1; Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); TweenService:Create(d,TweenInfo.new(s[5],Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=math.min(s[4]+0.45,0.95)}):Play() end end

    -- Top accent bar
    local _ipAccent = Instance.new("Frame", _ipFrame)
    _ipAccent.Size = UDim2.new(1, 0, 0, 3); _ipAccent.Position = UDim2.new(0,0,0,0)
    _ipAccent.BackgroundColor3 = Theme.Accent1; _ipAccent.BorderSizePixel = 0; _ipAccent.ZIndex = 5
    Instance.new("UICorner", _ipAccent).CornerRadius = UDim.new(0, 8)

    -- Header
    local _ipHeader = Instance.new("Frame", _ipFrame)
    _ipHeader.Size = UDim2.new(1, 0, 0, 36); _ipHeader.Position = UDim2.new(0, 0, 0, 2)
    _ipHeader.BackgroundTransparency = 1; _ipHeader.Active = true

    local _ipTA = Instance.new("TextLabel", _ipHeader)
    _ipTA.Font = Enum.Font.GothamBold; _ipTA.TextXAlignment = Enum.TextXAlignment.Left
    _ipTA.TextSize = 13; _ipTA.Size = UDim2.new(0, 46, 1, 0); _ipTA.Position = UDim2.new(0, 12, 0, 0)
    _ipTA.Text = "INVIS"; _ipTA.TextColor3 = Color3.fromRGB(220, 225, 240); _ipTA.BackgroundTransparency = 1

    local _ipTB = Instance.new("TextLabel", _ipHeader)
    _ipTB.Font = Enum.Font.GothamBold; _ipTB.TextXAlignment = Enum.TextXAlignment.Left
    _ipTB.TextSize = 13; _ipTB.Size = UDim2.new(0, 60, 1, 0); _ipTB.Position = UDim2.new(0, 55, 0, 0)
    _ipTB.Text = "PANEL"; _ipTB.TextColor3 = Theme.Accent1; _ipTB.BackgroundTransparency = 1

    -- Close button
    local _ipClose = Instance.new("TextButton", _ipHeader)
    _ipClose.ZIndex = 10; _ipClose.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    _ipClose.Font = Enum.Font.GothamMedium; _ipClose.TextSize = 12
    _ipClose.Size = UDim2.new(0, 20, 0, 20); _ipClose.TextColor3 = Theme.Accent1; _ipClose.Text = "×"
    _ipClose.Position = UDim2.new(1, -24, 0.5, -10)
    Instance.new("UICorner", _ipClose).CornerRadius = UDim.new(1, 0)
    _ipClose.MouseButton1Click:Connect(function()
        Config.HideInvisPanel = true; SaveConfig()
        _ipGui.Enabled = false
        if SharedState.SyncInvisPanelBtn then SharedState.SyncInvisPanelBtn(false) end
    end)

    -- Header separator
    local _ipHSep = Instance.new("Frame", _ipFrame)
    _ipHSep.Size = UDim2.new(1, -16, 0, 1); _ipHSep.Position = UDim2.new(0, 8, 0, 38)
    _ipHSep.BackgroundColor3 = Color3.fromRGB(25, 28, 40); _ipHSep.BorderSizePixel = 0

    -- Drag
    do
        local _drag, _dStart, _dAbsX, _dAbsY = false
        _ipHeader.InputBegan:Connect(function(inp)
            if Config.UILocked then return end
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                _drag=true; _dStart=inp.Position; _dAbsX=_ipFrame.AbsolutePosition.X; _dAbsY=_ipFrame.AbsolutePosition.Y
            end
        end)
        UserInputService.InputEnded:Connect(function(inp)
            if (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch) and _drag then
                _drag=false
                local vp=workspace.CurrentCamera.ViewportSize
                Config.Positions=Config.Positions or {}
                Config.Positions.InvisMiniPanel={X=_ipFrame.AbsolutePosition.X/vp.X,Y=_ipFrame.AbsolutePosition.Y/vp.Y}
                SaveConfig()
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if not _drag then return end
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                local d=inp.Position-_dStart; local vp=workspace.CurrentCamera.ViewportSize; local m=30
                _ipFrame.Position=UDim2.new(0,math.clamp(_dAbsX+d.X,-(_ipFrame.AbsoluteSize.X-m),vp.X-m),0,math.clamp(_dAbsY+d.Y,-(_ipFrame.AbsoluteSize.Y-m),vp.Y-m))
            end
        end)
    end

    -- Content container
    local _ipCont = Instance.new("Frame", _ipFrame)
    _ipCont.Size = UDim2.new(1, -16, 1, -44); _ipCont.Position = UDim2.new(0, 8, 0, 44)
    _ipCont.BackgroundTransparency = 1
    local _ipLayout = Instance.new("UIListLayout", _ipCont)
    _ipLayout.Padding = UDim.new(0, 1); _ipLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function IPRow(h) local r=Instance.new("Frame",_ipCont); r.Size=UDim2.new(1,0,0,h or 22); r.BackgroundTransparency=1; return r end
    local function IPDiv() local r=IPRow(1); local d=Instance.new("Frame",r); d.Size=UDim2.new(1,0,0,1); d.BackgroundColor3=Color3.fromRGB(25,28,40); d.BorderSizePixel=0 end
    -- Row: Invis toggle + keybind
    local _ipR1 = IPRow(22)
    local _ipInvisLbl = Instance.new("TextLabel", _ipR1)
    _ipInvisLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    _ipInvisLbl.TextXAlignment = Enum.TextXAlignment.Left; _ipInvisLbl.TextSize = 11
    _ipInvisLbl.Size = UDim2.new(0, 36, 1, 0); _ipInvisLbl.Text = "Invis"
    _ipInvisLbl.TextColor3 = Color3.fromRGB(220, 225, 240); _ipInvisLbl.BackgroundTransparency = 1

    local btnInvis = Instance.new("TextButton", _ipR1)
    btnInvis.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    btnInvis.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    btnInvis.TextSize = 10; btnInvis.Size = UDim2.new(0, 36, 0, 18)
    btnInvis.TextColor3 = Theme.Accent1; btnInvis.Text = "OFF"
    btnInvis.Position = UDim2.new(1, -38, 0.5, -9); btnInvis.BorderSizePixel = 0
    Instance.new("UICorner", btnInvis).CornerRadius = UDim.new(1, 0)
    local _btnInvisStroke = Instance.new("UIStroke", btnInvis)
    _btnInvisStroke.Color = Theme.Accent1; _btnInvisStroke.Thickness = 1; _btnInvisStroke.Transparency = 0.5
    btnInvis.MouseButton1Click:Connect(function()
        if _G.toggleInvisibleSteal then pcall(_G.toggleInvisibleSteal) end
    end)

    local keyBtn = Instance.new("TextButton", _ipR1)
    keyBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    keyBtn.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    keyBtn.TextSize = 10; keyBtn.Size = UDim2.new(0, 28, 0, 18)
    keyBtn.TextColor3 = Theme.Accent1; keyBtn.Text = Config.InvisToggleKey or "I"
    keyBtn.Position = UDim2.new(1, -70, 0.5, -9); keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(1, 0)
    local _keyBtnSk = Instance.new("UIStroke", keyBtn); _keyBtnSk.Color = Theme.Accent1; _keyBtnSk.Thickness = 1; _keyBtnSk.Transparency = 0.5
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."
        local c; c = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                local kn = inp.KeyCode.Name; keyBtn.Text = kn
                Config.InvisToggleKey = kn; SaveConfig()
                if _G then _G.INVISIBLE_STEAL_KEY = inp.KeyCode end
                c:Disconnect()
            end
        end)
    end)

    IPDiv()

    -- Row: Auto Fix Lagback
    local _ipR2 = IPRow(22)
    local _ipLagLbl = Instance.new("TextLabel", _ipR2)
    _ipLagLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    _ipLagLbl.TextXAlignment = Enum.TextXAlignment.Left; _ipLagLbl.TextSize = 11
    _ipLagLbl.Size = UDim2.new(0.65, 0, 1, 0); _ipLagLbl.Text = "Auto Fix Lagback"
    _ipLagLbl.TextColor3 = Color3.fromRGB(220, 225, 240); _ipLagLbl.BackgroundTransparency = 1
    local _initLag = (_G and _G.AutoRecoverLagback ~= nil) and _G.AutoRecoverLagback or Config.AutoRecoverLagback ~= false
    local btnFix = Instance.new("TextButton", _ipR2)
    btnFix.BackgroundColor3 = _initLag and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnFix.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    btnFix.TextSize = 10; btnFix.Size = UDim2.new(0, 36, 0, 18)
    btnFix.TextColor3 = _initLag and Color3.fromRGB(5,5,10) or Theme.Accent1
    btnFix.Text = _initLag and "ON" or "OFF"
    btnFix.Position = UDim2.new(1, -38, 0.5, -9); btnFix.BorderSizePixel = 0
    Instance.new("UICorner", btnFix).CornerRadius = UDim.new(1, 0)
    local _fixSk = Instance.new("UIStroke", btnFix); _fixSk.Color = Theme.Accent1; _fixSk.Thickness = 1; _fixSk.Transparency = _initLag and 1 or 0.5
    btnFix.MouseButton1Click:Connect(function()
        if _G then _G.AutoRecoverLagback = not (_G.AutoRecoverLagback) end
        local on = _G and _G.AutoRecoverLagback or false
        btnFix.Text = on and "ON" or "OFF"
        btnFix.BackgroundColor3 = on and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        btnFix.TextColor3 = on and Color3.fromRGB(5,5,10) or Theme.Accent1
        _fixSk.Transparency = on and 1 or 0.5
    end)

    IPDiv()

    -- Row: Rotation slider
    do
        local rotValue = Config.InvisStealAngle or 233
        local _ipR3 = IPRow(36)
        local rotLbl = Instance.new("TextLabel", _ipR3)
        rotLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        rotLbl.TextXAlignment = Enum.TextXAlignment.Left; rotLbl.TextSize = 10
        rotLbl.Size = UDim2.new(1, 0, 0, 14); rotLbl.Text = "Rotation: " .. rotValue
        rotLbl.TextColor3 = Color3.fromRGB(65, 70, 95); rotLbl.BackgroundTransparency = 1
        local rotBg = Instance.new("Frame", _ipR3)
        rotBg.Size = UDim2.new(1, 0, 0, 5); rotBg.Position = UDim2.new(0, 0, 0, 20)
        rotBg.BorderSizePixel = 0; rotBg.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
        Instance.new("UICorner", rotBg).CornerRadius = UDim.new(1, 0)
        local rotFill = Instance.new("Frame", rotBg)
        rotFill.Size = UDim2.new((rotValue - 180) / 180, 0, 1, 0); rotFill.BorderSizePixel = 0
        rotFill.BackgroundColor3 = Theme.Accent1; Instance.new("UICorner", rotFill).CornerRadius = UDim.new(1, 0)
        local rotKnob = Instance.new("Frame", rotBg)
        rotKnob.AnchorPoint = Vector2.new(0.5, 0.5); rotKnob.Size = UDim2.new(0, 11, 0, 11)
        rotKnob.Position = UDim2.new((rotValue - 180) / 180, 0, 0.5, 0); rotKnob.BorderSizePixel = 0
        rotKnob.BackgroundColor3 = Color3.fromRGB(220, 225, 240); Instance.new("UICorner", rotKnob).CornerRadius = UDim.new(1, 0)
        local rotKSk = Instance.new("UIStroke", rotKnob); rotKSk.Color = Theme.Accent1; rotKSk.Thickness = 1.5
        do local drag = false
            local function upd(x) local p=math.clamp((x-rotBg.AbsolutePosition.X)/rotBg.AbsoluteSize.X,0,1); rotValue=math.floor(180+p*180); rotFill.Size=UDim2.new(p,0,1,0); rotKnob.Position=UDim2.new(p,0,0.5,0); rotLbl.Text="Rotation: "..rotValue; if _G then _G.InvisStealAngle=rotValue end; Config.InvisStealAngle=rotValue; SaveConfig() end
            rotBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position.X) end end)
            rotKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
        end
    end

    IPDiv()

    -- Row: Depth slider
    do
        local depValue = Config.SinkSliderValue or 5
        local _ipR4 = IPRow(36)
        local depLbl = Instance.new("TextLabel", _ipR4)
        depLbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        depLbl.TextXAlignment = Enum.TextXAlignment.Left; depLbl.TextSize = 10
        depLbl.Size = UDim2.new(1, 0, 0, 14); depLbl.Text = "Depth: " .. depValue
        depLbl.TextColor3 = Color3.fromRGB(65, 70, 95); depLbl.BackgroundTransparency = 1
        local depBg = Instance.new("Frame", _ipR4)
        depBg.Size = UDim2.new(1, 0, 0, 5); depBg.Position = UDim2.new(0, 0, 0, 20)
        depBg.BorderSizePixel = 0; depBg.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
        Instance.new("UICorner", depBg).CornerRadius = UDim.new(1, 0)
        local depFill = Instance.new("Frame", depBg)
        depFill.Size = UDim2.new((depValue-0.5)/9.5, 0, 1, 0); depFill.BorderSizePixel = 0
        depFill.BackgroundColor3 = Theme.Accent1; Instance.new("UICorner", depFill).CornerRadius = UDim.new(1, 0)
        local depKnob = Instance.new("Frame", depBg)
        depKnob.AnchorPoint = Vector2.new(0.5, 0.5); depKnob.Size = UDim2.new(0, 11, 0, 11)
        depKnob.Position = UDim2.new((depValue-0.5)/9.5, 0, 0.5, 0); depKnob.BorderSizePixel = 0
        depKnob.BackgroundColor3 = Color3.fromRGB(220, 225, 240); Instance.new("UICorner", depKnob).CornerRadius = UDim.new(1, 0)
        local depKSk = Instance.new("UIStroke", depKnob); depKSk.Color = Theme.Accent1; depKSk.Thickness = 1.5
        do local drag = false
            local function upd(x) local p=math.clamp((x-depBg.AbsolutePosition.X)/depBg.AbsoluteSize.X,0,1); depValue=math.floor((0.5+p*9.5)*10)/10; depFill.Size=UDim2.new(p,0,1,0); depKnob.Position=UDim2.new(p,0,0.5,0); depLbl.Text="Depth: "..depValue; if _G then _G.SinkSliderValue=depValue end; Config.SinkSliderValue=depValue; SaveConfig() end
            depBg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true; upd(i.Position.X) end end)
            depKnob.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
            UserInputService.InputChanged:Connect(function(i) if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
        end
    end

    IPDiv()

    -- Row: Auto Invis During Steal
    local _ipR5 = IPRow(22)
    local _ipAILbl = Instance.new("TextLabel", _ipR5)
    _ipAILbl.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    _ipAILbl.TextXAlignment = Enum.TextXAlignment.Left; _ipAILbl.TextSize = 11
    _ipAILbl.Size = UDim2.new(0.65, 0, 1, 0); _ipAILbl.Text = "Auto Invis on Steal"
    _ipAILbl.TextColor3 = Color3.fromRGB(220, 225, 240); _ipAILbl.BackgroundTransparency = 1
    local btnAI = Instance.new("TextButton", _ipR5)
    btnAI.BackgroundColor3 = Config.AutoInvisDuringSteal and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
    btnAI.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    btnAI.TextSize = 10; btnAI.Size = UDim2.new(0, 36, 0, 18)
    btnAI.TextColor3 = Config.AutoInvisDuringSteal and Color3.fromRGB(5,5,10) or Theme.Accent1
    btnAI.Text = Config.AutoInvisDuringSteal and "ON" or "OFF"
    btnAI.Position = UDim2.new(1, -38, 0.5, -9); btnAI.BorderSizePixel = 0
    Instance.new("UICorner", btnAI).CornerRadius = UDim.new(1, 0)
    local _aiSk = Instance.new("UIStroke", btnAI); _aiSk.Color = Theme.Accent1; _aiSk.Thickness = 1; _aiSk.Transparency = Config.AutoInvisDuringSteal and 1 or 0.5
    btnAI.MouseButton1Click:Connect(function()
        Config.AutoInvisDuringSteal = not Config.AutoInvisDuringSteal; SaveConfig()
        if _G then _G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal end
        btnAI.Text = Config.AutoInvisDuringSteal and "ON" or "OFF"
        btnAI.BackgroundColor3 = Config.AutoInvisDuringSteal and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        btnAI.TextColor3 = Config.AutoInvisDuringSteal and Color3.fromRGB(5,5,10) or Theme.Accent1
        _aiSk.Transparency = Config.AutoInvisDuringSteal and 1 or 0.5
    end)

    -- Wire invis button visual update to _G.updateMovementPanelInvisVisual
    _G.updateMovementPanelInvisVisual = function(on)
        if not btnInvis or not btnInvis.Parent then return end
        btnInvis.Text = on and "ON" or "OFF"
        btnInvis.BackgroundColor3 = on and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
        btnInvis.TextColor3 = on and Color3.fromRGB(5, 5, 10) or Theme.Accent1
        _btnInvisStroke.Transparency = on and 1 or 0.5
    end
end
-- ===========================

    local function updateVisualState(on)
        if _G.updateMovementPanelInvisVisual then
            pcall(_G.updateMovementPanelInvisVisual, on)
        end
    end

	_G.toggleInvisibleSteal = function()
		if animPlaying then turnOff() else turnOn() end
	end

	UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == (_G.INVISIBLE_STEAL_KEY or Enum.KeyCode.V) then
			pcall(_G.toggleInvisibleSteal)
			if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, _G.invisibleStealEnabled or false) end
			if updateVisualState then updateVisualState(_G.invisibleStealEnabled or false) end
		end
	end)

	local function onCharacterAdded(newChar)
		clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0
		pcall(function() for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then c:Destroy() end end end)
		if oldRoot then pcall(function() oldRoot:Destroy() end); oldRoot = nil end
		if clone then pcall(function() clone:Destroy() end); clone = nil end
		animPlaying = false; _G.invisibleStealEnabled = false
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		task.wait(0.2)
		local camera = Workspace.CurrentCamera
		if camera and newChar then
			local h = newChar:FindFirstChildOfClass("Humanoid")
			if h then camera.CameraSubject = h; camera.CameraType = Enum.CameraType.Custom end
		end
	end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

    local function setupDeathListener()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h then h.Died:Connect(function() clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0 end) end
        end
    end
    setupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1); setupDeathListener() end)

    task.spawn(function()
        local currentConnection = nil
        _G.AntiDieConnection = nil
        _G.AntiDieDisabled = false
        local function setupAntiDie()
            if _G.AntiDieDisabled then return end
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if currentConnection then pcall(function() currentConnection:Disconnect() end) end
            currentConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if _G.AntiDieDisabled then return end
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
            _G.AntiDieConnection = currentConnection
        end
        _G.setupAntiDie = setupAntiDie
        setupAntiDie()
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if not _G.AntiDieDisabled then
                setupAntiDie()
            end
        end)
    end)
end)

task.spawn(function()
    local wasStealingForInvis = false
    local invisWasEnabledBefore = false
    local autoEnabledInvis = false
    task.wait(1)
    while task.wait(0.1) do
        if _G.AutoInvisDuringSteal == false then
            wasStealingForInvis = false
            autoEnabledInvis = false
        else
            local isStealing = LocalPlayer:GetAttribute("Stealing")
            if isStealing and not wasStealingForInvis then
                invisWasEnabledBefore = _G.invisibleStealEnabled or false
                if not _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                    task.delay(0.25, function()
                        if LocalPlayer:GetAttribute("Stealing") and not _G.invisibleStealEnabled then
                            pcall(_G.toggleInvisibleSteal)
                            autoEnabledInvis = true
                        end
                    end)
                end
            end
            if not isStealing and autoEnabledInvis and _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                pcall(_G.toggleInvisibleSteal)
                autoEnabledInvis = false
            end
            wasStealingForInvis = isStealing
        end
    end
end)

task.spawn(function()
    local function getChar()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        return char, hrp, hum
    end

    local function hasExclamation(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BillboardGui") then
                local label = d:FindFirstChildWhichIsA("TextLabel", true)
                if label and label.Text:find("!") then
                    return true
                end
            end
        end
        return false
    end

    local function applyVisuals(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BasePart") and d ~= target then
                d.Transparency = 0.5
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
            elseif d:IsA("BillboardGui") and d.Name ~= "SentryLabel" then
                d:Destroy()
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 0.5
            end
        end
        if target:IsA("BasePart") and target.Name ~= "ProxyVisual" then
            target.Transparency = 1
            target.CanCollide = false
        end
    end

    local function getClosestSentry()
        local _, hrp = getChar()
        local closest, shortestDist = nil, math.huge
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst.Name:match("^Sentry_") then
                if hasExclamation(inst) then
                    local root = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                    if root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = inst
                        end
                    end
                end
            end
        end
        return closest
    end

    while true do
        if Config.AutoDestroyTurrets then
            if LocalPlayer:GetAttribute("Stealing") == true then
                task.wait(0.5)
            else
                local targetSentry = getClosestSentry()
                if targetSentry then
                    while targetSentry and targetSentry.Parent and (LocalPlayer:GetAttribute("Stealing") ~= true) do
                        local char, hrp, hum = getChar()
                        local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
                        applyVisuals(targetSentry)
                        local offset = hrp.CFrame.LookVector * 4
                        local targetCF = CFrame.new(hrp.Position + offset, hrp.Position)
                        if targetSentry:IsA("Model") then
                            targetSentry:PivotTo(targetCF)
                        elseif targetSentry:IsA("BasePart") then
                            targetSentry.CFrame = targetCF
                        end
                        if bat then
                            if bat.Parent ~= char then hum:EquipTool(bat) end
                            bat:Activate()
                        end
                        task.wait(0.1)
                        if not hasExclamation(targetSentry) then break end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

SharedState.FOV_MANAGER = {
    activeCount = 0,
    conn = nil,
    forcedFOV = 70,
}
function SharedState.FOV_MANAGER:Start()
    if self.conn then return end
    self.forcedFOV = Config.FOV or 70
    self.conn = RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if cam then
            local targetFOV = Config.FOV or self.forcedFOV
            if cam.FieldOfView ~= targetFOV then
                cam.FieldOfView = targetFOV
            end
        end
    end)
end
function SharedState.FOV_MANAGER:Stop()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
end
function SharedState.FOV_MANAGER:Push()
    self.activeCount = self.activeCount + 1
    self:Start()
end
function SharedState.FOV_MANAGER:Pop()
    if self.activeCount > 0 then
        self.activeCount = self.activeCount - 1
    end
    if self.activeCount == 0 then
        self:Stop()
    end
end

SharedState.ANTI_BEE_DISCO = {
    running = false,
    connections = {},
    originalMoveFunction = nil,
    controlsProtected = false,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
}
function SharedState.ANTI_BEE_DISCO.nuke(obj)
    if not obj or not obj.Parent then return end
    if SharedState.ANTI_BEE_DISCO.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end
function SharedState.ANTI_BEE_DISCO.disconnectAll()
    for _, conn in ipairs(SharedState.ANTI_BEE_DISCO.connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    SharedState.ANTI_BEE_DISCO.connections = {}
end
function SharedState.ANTI_BEE_DISCO.protectControls()
    if SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer.PlayerScripts
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        local ab = SharedState.ANTI_BEE_DISCO
        if not ab.originalMoveFunction then ab.originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if ab.originalMoveFunction then ab.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        table.insert(ab.connections, RunService.Heartbeat:Connect(function()
            if not ab.running or not Config.AntiBeeDisco then return end
            if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
        end))
        Controls.moveFunction = protectedMoveFunction
        ab.controlsProtected = true
    end)
end
function SharedState.ANTI_BEE_DISCO.restoreControls()
    if not SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        local ab = SharedState.ANTI_BEE_DISCO
        if Controls and ab.originalMoveFunction then
            Controls.moveFunction = ab.originalMoveFunction
            ab.controlsProtected = false
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.blockBuzzingSound()
    pcall(function()
        local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.Enable()
    local ab = SharedState.ANTI_BEE_DISCO
    if ab.running then return end
    ab.running = true
    for _, inst in ipairs(Lighting:GetDescendants()) do ab.nuke(inst) end
    table.insert(ab.connections, Lighting.DescendantAdded:Connect(function(obj)
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.nuke(obj)
    end))
    ab.protectControls()
    table.insert(ab.connections, RunService.Heartbeat:Connect(function()
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.blockBuzzingSound()
    end))
    SharedState.FOV_MANAGER:Push()
    ShowNotification("ANTI-BEE & DISCO", "Enabled")
end
function SharedState.ANTI_BEE_DISCO.Disable()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    SharedState.FOV_MANAGER:Pop()
    ShowNotification("ANTI-BEE & DISCO", "Disabled")
end

_G.ANTI_BEE_DISCO = SharedState.ANTI_BEE_DISCO

if Config.AntiBeeDisco then
    task.delay(1, function()
        if SharedState.ANTI_BEE_DISCO.Enable then SharedState.ANTI_BEE_DISCO.Enable() end
    end)
end

task.spawn(function()
    while true do
        if Workspace.CurrentCamera then
            if Config.FOV and Config.FOV ~= Workspace.CurrentCamera.FieldOfView then
                Workspace.CurrentCamera.FieldOfView = Config.FOV
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    if PlayerGui:FindFirstChild("wxrldzHUD") then PlayerGui.wxrldzHUD:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "wxrldzHUD"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = PlayerGui

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.AnchorPoint = Vector2.new(0.5, 0)
    Main.BackgroundColor3 = Color3.fromRGB(3, 3, 13)
    Main.BackgroundTransparency = Config.HudTransparency
    Main.BorderSizePixel = 0
    Main.Position = UDim2.new(0.5, 0, 0, IS_MOBILE and 6 or 18)
    Main.Size = UDim2.new(0, 380, 0, 56)
    Main.ClipsDescendants = false
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    if IS_MOBILE then
        local _hudScale = Instance.new("UIScale", Main)
        _hudScale.Scale = 0.6
    end

    local _hudStroke = Instance.new("UIStroke", Main)
    _hudStroke.Color = Theme.Accent1
    _hudStroke.Thickness = 1
    _hudStroke.Transparency = 0.65
    _hudStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    local _hudAccent = Instance.new("Frame", Main)
    _hudAccent.Size = UDim2.new(1, 0, 0, 4)
    _hudAccent.Position = UDim2.new(0, 0, 0, 0)
    _hudAccent.BackgroundColor3 = Theme.Accent1
    _hudAccent.BorderSizePixel = 0; _hudAccent.ZIndex = 5
    Instance.new("UICorner", _hudAccent).CornerRadius = UDim.new(0, 10)
    SharedState.HudAccentBar = _hudAccent

    do local _sc2=Instance.new("Frame",Main); _sc2.Name="_SparkCont"; _sc2.BackgroundTransparency=1; _sc2.Size=UDim2.new(1,0,1,0); _sc2.Position=UDim2.new(0,0,0,0); _sc2.BorderSizePixel=0; _sc2.ZIndex=1; _sc2.Visible=Config.HudSparkles~=false; SharedState.SparkleCont2=_sc2; local _st={{0.04,0.15,1,0.50,2.5},{0.10,0.72,1,0.62,3.1},{0.18,0.30,2,0.42,2.8},{0.26,0.80,1,0.55,4.0},{0.34,0.18,1,0.65,2.3},{0.44,0.55,1,0.45,3.7},{0.54,0.25,2,0.50,2.1},{0.62,0.75,1,0.38,4.5},{0.72,0.40,1,0.60,3.2},{0.80,0.20,2,0.55,2.9},{0.88,0.68,1,0.42,3.6},{0.94,0.85,1,0.70,5.0},{0.50,0.90,1,0.35,2.4},{0.30,0.50,2,0.58,3.0},{0.68,0.08,1,0.48,4.2}}; for _,s in ipairs(_st) do local d=Instance.new("Frame",_sc2); d.Size=UDim2.new(0,s[3],0,s[3]); d.Position=UDim2.new(s[1],0,s[2],0); d.AnchorPoint=Vector2.new(0.5,0.5); d.BackgroundColor3=Color3.fromRGB(220,235,255); d.BackgroundTransparency=s[4]; d.BorderSizePixel=0; d.ZIndex=1; Instance.new("UICorner",d).CornerRadius=UDim.new(1,0); TweenService:Create(d,TweenInfo.new(s[5],Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundTransparency=math.min(s[4]+0.40,0.95)}):Play() end end

    local _hudTitle = Instance.new("TextLabel", Main)
    _hudTitle.Name = "HudTitle"
    _hudTitle.Size = UDim2.new(0, 155, 0, 26); _hudTitle.Position = UDim2.new(0, 12, 0, 5)
    _hudTitle.BackgroundTransparency = 1; _hudTitle.RichText = true
    _hudTitle.FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold)
    _hudTitle.TextSize = 18; _hudTitle.TextXAlignment = Enum.TextXAlignment.Left
    do
        local r,g,b = math.floor(Theme.Accent1.R*255), math.floor(Theme.Accent1.G*255), math.floor(Theme.Accent1.B*255)
        local txt = privateBuild and "ABYSS PRIVATE" or "ABYSS"
        _hudTitle.Text = string.format("<font color='rgb(220,225,240)'>%s</font> <font color='rgb(%d,%d,%d)'>HUB</font>", txt, r, g, b)
    end

    local _hudSub = Instance.new("TextLabel", Main)
    _hudSub.Size = UDim2.new(0, 145, 0, 14); _hudSub.Position = UDim2.new(0, 13, 0, 34)
    _hudSub.BackgroundTransparency = 1; _hudSub.Text = privateBuild and "" or "discord.gg/abysshub"
    _hudSub.Font = Enum.Font.GothamMedium; _hudSub.TextSize = 11
    _hudSub.TextColor3 = Color3.fromRGB(155, 175, 230); _hudSub.TextXAlignment = Enum.TextXAlignment.Left

    local _hudVDiv1 = Instance.new("Frame", Main)
    _hudVDiv1.Size = UDim2.new(0, 1, 1, -16); _hudVDiv1.Position = UDim2.new(0, 162, 0, 8)
    _hudVDiv1.BackgroundColor3 = Color3.fromRGB(25, 28, 40); _hudVDiv1.BorderSizePixel = 0

    local TextLabel_3 = Instance.new("TextLabel", Main)
    TextLabel_3.Size = UDim2.new(0, 70, 0, 18); TextLabel_3.Position = UDim2.new(0, 172, 0, 8)
    TextLabel_3.BackgroundTransparency = 1; TextLabel_3.Font = Enum.Font.GothamMedium
    TextLabel_3.Text = string.format("<font color='rgb(65,70,95)'>FPS</font>  <font color='rgb(%d,%d,%d)'><b>60</b></font>", math.floor(Theme.Accent1.R*255), math.floor(Theme.Accent1.G*255), math.floor(Theme.Accent1.B*255))
    TextLabel_3.TextColor3 = Color3.fromRGB(220, 225, 240); TextLabel_3.TextSize = 13
    TextLabel_3.TextXAlignment = Enum.TextXAlignment.Left; TextLabel_3.RichText = true

    local TextLabel_4 = Instance.new("TextLabel", Main)
    TextLabel_4.Size = UDim2.new(0, 70, 0, 18); TextLabel_4.Position = UDim2.new(0, 172, 0, 27)
    TextLabel_4.BackgroundTransparency = 1; TextLabel_4.Font = Enum.Font.GothamMedium
    TextLabel_4.Text = string.format("<font color='rgb(65,70,95)'>PING</font>  <font color='rgb(%d,%d,%d)'><b>0ms</b></font>", math.floor(Theme.Accent1.R*255), math.floor(Theme.Accent1.G*255), math.floor(Theme.Accent1.B*255))
    TextLabel_4.TextColor3 = Color3.fromRGB(220, 225, 240); TextLabel_4.TextSize = 13
    TextLabel_4.TextXAlignment = Enum.TextXAlignment.Left; TextLabel_4.RichText = true

    local _hudVDiv2 = Instance.new("Frame", Main)
    _hudVDiv2.Size = UDim2.new(0, 1, 1, -16); _hudVDiv2.Position = UDim2.new(0, 252, 0, 8)
    _hudVDiv2.BackgroundColor3 = Color3.fromRGB(25, 28, 40); _hudVDiv2.BorderSizePixel = 0

    local desyncStatusLabel = Instance.new("TextLabel", Main)
    desyncStatusLabel.Size = UDim2.new(0, 100, 0, 36); desyncStatusLabel.Position = UDim2.new(0, 262, 0, 8)
    desyncStatusLabel.BackgroundTransparency = 1; desyncStatusLabel.Font = Enum.Font.GothamBold
    desyncStatusLabel.Text = "DESYNC: OFF"
    desyncStatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    desyncStatusLabel.TextSize = 14
    desyncStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    desyncStatusLabel.RichText = true

    task.spawn(function()
        while true do
            task.wait(0.1)
            if desyncActive or mobileDesyncActive then
                desyncStatusLabel.Text = "<font color='rgb(100,255,100)'>DESYNC: ON</font>"
            else
                desyncStatusLabel.Text = "<font color='rgb(255,100,100)'>DESYNC: OFF</font>"
            end
        end
    end)

    local acc, rate, lastFps = 0, 1, 60
    SharedState.LastFPS = 60
    RunService.Heartbeat:Connect(function(dt)
        acc = acc + dt
        if acc >= rate then
            lastFps = math.floor(1/dt)
            SharedState.LastFPS = lastFps
            acc = 0
        end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local _ar = math.floor(Theme.Accent1.R*255); local _ag = math.floor(Theme.Accent1.G*255); local _ab = math.floor(Theme.Accent1.B*255)
        local accentRgb = string.format("rgb(%d,%d,%d)", _ar, _ag, _ab)
        local fc = (lastFps >= 50) and accentRgb or (lastFps >= 30) and "rgb(255,200,0)" or "rgb(255,70,70)"
        local pc = (ping < 100) and accentRgb or (ping < 200) and "rgb(255,200,0)" or "rgb(255,70,70)"
        TextLabel_3.Text = string.format("<font color='rgb(65,70,95)'>FPS</font>  <font color='%s'><b>%d</b></font>", fc, lastFps)
        TextLabel_4.Text = string.format("<font color='rgb(65,70,95)'>PING</font>  <font color='%s'><b>%dms</b></font>", pc, ping)
    end)

    -- Expose live-update hook for theme/transparency changes
    SharedState.ApplyHudTheme = function(accentColor, transparency)
        _hudStroke.Color = accentColor
        _hudAccent.BackgroundColor3 = accentColor
        Main.BackgroundTransparency = transparency
        local r = math.floor(accentColor.R*255)
        local g = math.floor(accentColor.G*255)
        local b = math.floor(accentColor.B*255)
        local txt = privateBuild and "ABYSS PRIVATE" or "ABYSS"
        _hudTitle.Text = string.format("<font color='rgb(220,225,240)'>%s</font> <font color='rgb(%d,%d,%d)'>HUB</font>", txt, r, g, b)
    end

    local unlockContainer = Instance.new("Frame", ScreenGui)
    unlockContainer.Name = "UnlockButtonsContainer"
    unlockContainer.Size = UDim2.new(0, 136, 0, 44)
    unlockContainer.Position = UDim2.new(0.5, -68, 0, IS_MOBILE and 94 or 112)
    unlockContainer.AnchorPoint = Vector2.new(0, 0)
    unlockContainer.BackgroundTransparency = 1
    unlockContainer.Visible = IS_MOBILE and true or (Config.ShowUnlockButtonsHUD or false)
    _G._unlockContainer = unlockContainer
    MakeDraggable(unlockContainer, unlockContainer, nil)

    -- Helper: make a styled unlock button
    local function makeUnlockBtn(parent, text, xPos, yPos, width, height, onClick)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(0, width, 0, height)
        btn.Position = UDim2.new(0, xPos, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
        btn.BackgroundTransparency = 0
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 14
        btn.TextColor3 = Theme.Accent1
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = Theme.Accent1
        bs.Thickness = 1
        bs.Transparency = 0.5
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Theme.Accent1
            btn.TextColor3 = Color3.fromRGB(5, 5, 10)
            bs.Transparency = 1
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
            btn.TextColor3 = Theme.Accent1
            bs.Transparency = 0.5
        end)
        btn.MouseButton1Click:Connect(onClick)
        return btn
    end

    -- Row 1: [1] [2] [3] unlock buttons
    local _ub_w = IS_MOBILE and 50 or 40
    local _ub_h = IS_MOBILE and 40 or 36
    local _ub_gap = IS_MOBILE and 58 or 48
    unlockContainer.Size = UDim2.new(0, _ub_gap * 2 + _ub_w, 0, _ub_h + 4)
    makeUnlockBtn(unlockContainer, "1", 0, 0, _ub_w, _ub_h, function()
        triggerClosestUnlock(-2)
        ShowNotification("UNLOCK", "Level 1")
    end)
    makeUnlockBtn(unlockContainer, "2", _ub_gap, 0, _ub_w, _ub_h, function()
        triggerClosestUnlock(15)
        ShowNotification("UNLOCK", "Level 2")
    end)
    makeUnlockBtn(unlockContainer, "3", _ub_gap * 2, 0, _ub_w, _ub_h, function()
        triggerClosestUnlock(32)
        ShowNotification("UNLOCK", "Level 3")
    end)

    -- STEALERS button — always visible, parented to ScreenGui
    local stealersBtn = Instance.new("TextButton", ScreenGui)
    stealersBtn.Size = UDim2.new(0, IS_MOBILE and 100 or 136, 0, IS_MOBILE and 22 or 28)
    stealersBtn.AnchorPoint = Vector2.new(0.5, 0)
    stealersBtn.Position = UDim2.new(0.5, 0, 0, IS_MOBILE and 42 or 78)
    stealersBtn.BackgroundColor3 = Color3.fromRGB(40, 10, 10)
    stealersBtn.BackgroundTransparency = 0
    stealersBtn.Text = "STEALERS 0"
    stealersBtn.Font = Enum.Font.GothamBold
    stealersBtn.TextSize = 12
    stealersBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    stealersBtn.BorderSizePixel = 0
    stealersBtn.AutoButtonColor = false
    Instance.new("UICorner", stealersBtn).CornerRadius = UDim.new(0, 8)
    local _sBtnStroke = Instance.new("UIStroke", stealersBtn)
    _sBtnStroke.Color = Color3.fromRGB(200, 50, 50)
    _sBtnStroke.Thickness = 1
    _sBtnStroke.Transparency = 0.4
    stealersBtn.MouseButton1Click:Connect(function()
        if _G.toggleStealerPanel then _G.toggleStealerPanel() end
    end)

    -- Mobile-only: Carpet Speed + TP buttons
    if IS_MOBILE then
        local function makeMobileBtn(label, xOffset, onClick)
            local btn = Instance.new("TextButton", ScreenGui)
            btn.Size = UDim2.new(0, 90, 0, 22)
            btn.AnchorPoint = Vector2.new(0.5, 0)
            btn.Position = UDim2.new(0.5, xOffset, 0, 68)
            btn.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
            btn.BackgroundTransparency = 0
            btn.Text = label
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.TextColor3 = Theme.Accent1
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", btn)
            bs.Color = Theme.Accent1
            bs.Thickness = 1
            bs.Transparency = 0.5
            btn.MouseButton1Click:Connect(onClick)
            return btn
        end

        -- Carpet Speed toggle button
        local carpetBtn = makeMobileBtn("CARPET: OFF", -50, function() end)
        local function updateCarpetBtn()
            carpetBtn.Text = carpetSpeedEnabled and "CARPET: ON" or "CARPET: OFF"
            carpetBtn.BackgroundColor3 = carpetSpeedEnabled and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
            carpetBtn.TextColor3 = carpetSpeedEnabled and Color3.fromRGB(5, 5, 10) or Theme.Accent1
        end
        carpetBtn.MouseButton1Click:Connect(function()
            carpetSpeedEnabled = not carpetSpeedEnabled
            setCarpetSpeed(carpetSpeedEnabled)
            updateCarpetBtn()
            ShowNotification("CARPET SPEED", carpetSpeedEnabled and ("ON  |  "..Config.TpSettings.Tool.."  |  140") or "OFF")
        end)
        updateCarpetBtn()

        -- TP button
        makeMobileBtn("TP", 50, function()
            runAutoSnipe()
        end)
    end

    -- live stealer count update
    task.spawn(function()
        while true do
            task.wait(0.5)
            local count = 0
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("Stealing") then
                    count = count + 1
                end
            end
            stealersBtn.Text = "STEALERS " .. count
            stealersBtn.TextColor3 = count > 0 and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(180, 80, 80)
        end
    end)
end)


-- ============================================================
--  REVAMPED PLAYER ESP  (display name · steal · BL badge + outline)
-- ============================================================
task.spawn(function()
    local playerESPEnabled = Config.PlayerESP
    local playerBillboards = {}

    local FONT_EXTRABOLD = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.ExtraBold, Enum.FontStyle.Normal)
    local FONT_BOLD      = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold,      Enum.FontStyle.Normal)

    local COL_NAME       = Color3.fromRGB(228, 233, 255)
    local COL_NAME_BL    = Color3.fromRGB(255, 155, 155)
    local COL_STEAL_TEXT = Color3.fromRGB(255, 185, 185)

    local BB_W_NORMAL  = 200
    local BB_H_NORMAL  = 18
    local BB_H_STEAL   = 36

    local function makePlayerESP(player)
        local isBL = Config.Blacklist and Config.Blacklist[tostring(player.UserId)] ~= nil

        -- Root billboard — no background box, pure floating text
        local bb = Instance.new("BillboardGui")
        bb.Name       = "PlayerESP_" .. player.UserId
        bb.Size       = UDim2.new(0, BB_W_NORMAL, 0, BB_H_NORMAL)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 3.4, 0)
        bb.AlwaysOnTop  = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false

        -- Display name
        local nameLbl = Instance.new("TextLabel", bb)
        nameLbl.Name = "NameLbl"
        nameLbl.Size = UDim2.new(1, 0, 0, BB_H_NORMAL)
        nameLbl.Position = UDim2.new(0, 0, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.FontFace = FONT_EXTRABOLD
        nameLbl.TextSize = 13
        nameLbl.TextColor3 = isBL and COL_NAME_BL or COL_NAME
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextStrokeTransparency = 0.3
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Text = isBL and (player.DisplayName .. "  ·  BL") or player.DisplayName

        -- BL suffix glow stroke (makes the BL text stand out more)
        if isBL then
            local nameStroke = Instance.new("UIStroke", nameLbl)
            nameStroke.Color = Color3.fromRGB(200, 0, 0)
            nameStroke.Thickness = 1.5
            nameStroke.Transparency = 0.4
        end

        -- Steal label (hidden by default, appears below name)
        local stealLbl = Instance.new("TextLabel", bb)
        stealLbl.Name = "StealLbl"
        stealLbl.Size = UDim2.new(1, 0, 0, 16)
        stealLbl.Position = UDim2.new(0, 0, 0, BB_H_NORMAL + 2)
        stealLbl.BackgroundTransparency = 1
        stealLbl.FontFace = FONT_BOLD
        stealLbl.TextSize = 11
        stealLbl.TextColor3 = COL_STEAL_TEXT
        stealLbl.TextXAlignment = Enum.TextXAlignment.Center
        stealLbl.TextStrokeTransparency = 0.25
        stealLbl.TextStrokeColor3 = Color3.fromRGB(120, 0, 0)
        stealLbl.TextTruncate = Enum.TextTruncate.AtEnd
        stealLbl.Text = ""
        stealLbl.Visible = false
        local stealStroke = Instance.new("UIStroke", stealLbl)
        stealStroke.Color = Color3.fromRGB(255, 60, 60)
        stealStroke.Thickness = 1
        stealStroke.Transparency = 0.5

        -- Reactive steal watcher
        local function refreshSteal()
            local active  = player:GetAttribute("Stealing")
            local petName = player:GetAttribute("StealingIndex")
            if active then
                stealLbl.Text    = "▶  STEALING · " .. (petName and tostring(petName) or "...")
                stealLbl.Visible = true
                bb.Size          = UDim2.new(0, BB_W_NORMAL, 0, BB_H_STEAL)
            else
                stealLbl.Visible = false
                bb.Size          = UDim2.new(0, BB_W_NORMAL, 0, BB_H_NORMAL)
            end
        end
        refreshSteal()
        pcall(function()
            player:GetAttributeChangedSignal("Stealing"):Connect(refreshSteal)
            player:GetAttributeChangedSignal("StealingIndex"):Connect(refreshSteal)
        end)

        return bb
    end

    local function makeCharHighlight(char)
        local hl = Instance.new("Highlight")
        hl.Adornee            = char
        hl.OutlineColor       = Color3.fromRGB(255, 30, 30)
        hl.FillColor          = Color3.fromRGB(255, 0, 0)
        hl.FillTransparency   = 0.91
        hl.OutlineTransparency = 0
        hl.Parent             = char
        return hl
    end

    local function createOrRefresh(player)
        if player == LocalPlayer then return end
        local char = player.Character; if not char then return end
        local hrp  = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local hum  = char:FindFirstChild("Humanoid")
        if hum then hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None end

        local uid  = player.UserId
        local isBL = Config.Blacklist and Config.Blacklist[tostring(uid)] ~= nil
        local entry = playerBillboards[uid]
        local needCreate = not entry or not entry.bb or not entry.bb.Parent
                        or entry.isBL ~= isBL

        if needCreate then
            if entry then
                if entry.bb        and entry.bb.Parent        then pcall(function() entry.bb:Destroy()        end) end
                if entry.highlight and entry.highlight.Parent then pcall(function() entry.highlight:Destroy() end) end
            end
            local bb = makePlayerESP(player)
            bb.Adornee = hrp; bb.Parent = hrp
            local hl = isBL and makeCharHighlight(char) or nil
            playerBillboards[uid] = {bb=bb, player=player, isBL=isBL, highlight=hl}
        else
            if entry.bb.Adornee ~= hrp then entry.bb.Adornee = hrp; entry.bb.Parent = hrp end
            if entry.highlight and entry.highlight.Parent then entry.highlight.Adornee = char end
        end
    end

    local function clearAll()
        for uid, entry in pairs(playerBillboards) do
            if entry.bb        and entry.bb.Parent        then pcall(function() entry.bb:Destroy()        end) end
            if entry.highlight and entry.highlight.Parent then pcall(function() entry.highlight:Destroy() end) end
            local p = Players:GetPlayerByUserId(uid)
            if p and p.Character then
                local h = p.Character:FindFirstChild("Humanoid")
                if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
            playerBillboards[uid] = nil
        end
    end

    playerESPToggleRef.setFn = function(enabled)
        playerESPEnabled = enabled
        if not enabled then clearAll() end
    end

    -- Main refresh loop
    task.spawn(function()
        while true do
            task.wait(0.5)
            if not playerESPEnabled then continue end
            for uid, entry in pairs(playerBillboards) do
                if not Players:GetPlayerByUserId(uid) then
                    if entry.bb        and entry.bb.Parent        then pcall(function() entry.bb:Destroy()        end) end
                    if entry.highlight and entry.highlight.Parent then pcall(function() entry.highlight:Destroy() end) end
                    playerBillboards[uid] = nil
                end
            end
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then pcall(createOrRefresh, p) end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if playerESPEnabled then pcall(createOrRefresh, p) end
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                if playerESPEnabled then pcall(createOrRefresh, p) end
            end)
        end
    end
end)

task.spawn(function()
    local subspaceMineESPToggleRef = {setFn=nil} 

    if settingsGui and settingsGui:FindFirstChild("sFrame", true) then
        local sList = settingsGui.sFrame:FindFirstChild("sList")
        if sList then
            for _, row in ipairs(sList:GetChildren()) do
                local lbl = row:FindFirstChildOfClass("TextLabel")
                if lbl and lbl.Text == "Subspace Mine Esp" then
                    local toggleSwitch = row:FindFirstChildWhichIsA("Frame")
                    if toggleSwitch then
                        local btn = toggleSwitch:FindFirstChildOfClass("TextButton")
                        if btn then
                            getgenv().subspaceMineESPToggleRef = subspaceMineESPToggleRef
                        end
                    end
                    break 
                end
            end
        end
    end

    local subspaceMineESPData = {}
    local FolderName = "ToolsAdds" 

    local function getMineOwner(mineName)
        local ownerName = mineName:match("SubspaceTripmine(.+)")
        
        if not ownerName then return "Unknown" end 

        local foundPlayer = Players:FindFirstChild(ownerName)
        local displayName = foundPlayer and foundPlayer.DisplayName or ownerName
        
        return displayName
    end

    local function createMineESP(mine)
        local ownerName = getMineOwner(mine.Name)

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_Hitbox"
        selectionBox.Adornee = mine 
        selectionBox.Color3 = Color3.fromRGB(167, 142, 255)
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = mine 

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Label"
        billboardGui.Adornee = mine
        billboardGui.Size = UDim2.new(0, 250, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = false 
        billboardGui.Parent = mine

        local textLabel = Instance.new("TextLabel", billboardGui)
        textLabel.Size = UDim2.new(1, 0, 1, 0) 
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ownerName .. "'s Subspace Mine"
        textLabel.TextColor3 = Color3.fromRGB(167, 142, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0 
        textLabel.Font = Enum.Font.GothamMedium 
        textLabel.TextSize = 16

        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine }
    end

    local function refreshSubspaceMineESP()
        if not Config.SubspaceMineESP then
            for i, data in pairs(subspaceMineESPData) do
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[i] = nil
            end
            return
        end

        local toolsFolder = Workspace:FindFirstChild(FolderName)
        if not toolsFolder then return end

        local currentMines = {}

        for _, obj in pairs(toolsFolder:GetChildren()) do
            if obj.Name:match("^SubspaceTripmine") and obj:IsA("BasePart") then
                currentMines[obj] = true

                if not subspaceMineESPData[obj] then
                    subspaceMineESPData[obj] = createMineESP(obj)
                end
            end
        end

        for mineObj, data in pairs(subspaceMineESPData) do
            if not currentMines[mineObj] or not mineObj.Parent then
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[mineObj] = nil
            end
        end
    end

    if subspaceMineESPToggleRef then
        subspaceMineESPToggleRef.setFn = function(enabled)
            Config.SubspaceMineESP = enabled
            if not enabled then
                for _, data in pairs(subspaceMineESPData) do
                    if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                    if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                end
                table.clear(subspaceMineESPData)
            end
        end
    end

    while true do
        task.wait(0.5) 
        
        local success, errorMessage = pcall(refreshSubspaceMineESP)
    end
end)


task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    
    local function getPetsByRarity(rarityName)
        local petList = {}
        for petName, data in pairs(AnimalsData) do
            if data.Rarity == rarityName and not petName:find("Lucky Block") then
                table.insert(petList, petName)
            end
        end
        table.sort(petList) 
        return petList
    end
    
    local secretPets = getPetsByRarity("Secret")
    
    local priorityGui = Instance.new("ScreenGui")
    priorityGui.Name = "PriorityListGUI"
    priorityGui.ResetOnSpawn = false
    priorityGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    priorityGui.DisplayOrder = 999
    pcall(function() priorityGui.Parent = game:GetService("CoreGui") end)
    if not priorityGui.Parent then priorityGui.Parent = PlayerGui end

    local priorityPopup = Instance.new("Frame", priorityGui)
    priorityPopup.Size = UDim2.new(0, 270, 0, 320)
    priorityPopup.BackgroundColor3 = Color3.fromRGB(10, 11, 18)
    priorityPopup.BackgroundTransparency = 0.04
    priorityPopup.BorderSizePixel = 0
    priorityPopup.Visible = false
    priorityPopup.ZIndex = 50
    task.defer(function()
        local cam = workspace.CurrentCamera
        if cam then
            local vp = cam.ViewportSize
            priorityPopup.Position = UDim2.new(0, vp.X/2 - 135, 0, vp.Y/2 - 160)
        end
    end)
    Instance.new("UICorner", priorityPopup).CornerRadius = UDim.new(0, 10)
    local _ppStroke = Instance.new("UIStroke", priorityPopup)
    _ppStroke.Color = Theme.Accent1; _ppStroke.Thickness = 1; _ppStroke.Transparency = 0.72

    local popTitle = Instance.new("TextLabel", priorityPopup)
    popTitle.Size = UDim2.new(1, -30, 0, 32)
    popTitle.Position = UDim2.new(0, 10, 0, 0)
    popTitle.BackgroundTransparency = 1
    popTitle.Text = "PRIORITY LIST"
    popTitle.TextColor3 = Theme.TextPrimary
    popTitle.TextSize = 13
    popTitle.Font = Enum.Font.GothamBold
    popTitle.TextXAlignment = Enum.TextXAlignment.Center
    popTitle.ZIndex = 51
    popTitle.Active = true

    local popClose = Instance.new("TextButton", priorityPopup)
    popClose.Size = UDim2.new(0, 22, 0, 22)
    popClose.Position = UDim2.new(1, -26, 0, 5)
    popClose.BackgroundTransparency = 1
    popClose.Text = "✕"
    popClose.TextColor3 = Theme.TextSecondary
    popClose.TextSize = 12
    popClose.Font = Enum.Font.GothamBold
    popClose.AutoButtonColor = false
    popClose.ZIndex = 52
    popClose.MouseEnter:Connect(function() popClose.TextColor3 = Theme.TextPrimary end)
    popClose.MouseLeave:Connect(function() popClose.TextColor3 = Theme.TextSecondary end)

    local popDiv = Instance.new("Frame", priorityPopup)
    popDiv.Size = UDim2.new(1, -16, 0, 1)
    popDiv.Position = UDim2.new(0, 8, 0, 32)
    popDiv.BackgroundColor3 = Theme.Accent1
    popDiv.BackgroundTransparency = 0.8
    popDiv.BorderSizePixel = 0; popDiv.ZIndex = 51

    local searchInput = Instance.new("TextBox", priorityPopup)
    searchInput.Size = UDim2.new(1, -16, 0, 26)
    searchInput.Position = UDim2.new(0, 8, 0, 37)
    searchInput.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    searchInput.Text = ""; searchInput.PlaceholderText = "Search..."
    searchInput.PlaceholderColor3 = Theme.TextSecondary
    searchInput.TextColor3 = Theme.TextPrimary
    searchInput.TextSize = 10; searchInput.Font = Enum.Font.GothamMedium
    searchInput.ClearTextOnFocus = false
    searchInput.TextXAlignment = Enum.TextXAlignment.Left
    searchInput.BorderSizePixel = 0; searchInput.ZIndex = 52
    Instance.new("UICorner", searchInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", searchInput).PaddingLeft = UDim.new(0, 8)
    local _siStroke = Instance.new("UIStroke", searchInput)
    _siStroke.Color = Theme.Accent1; _siStroke.Thickness = 1; _siStroke.Transparency = 0.7

    local popScroll = Instance.new("ScrollingFrame", priorityPopup)
    popScroll.Size = UDim2.new(1, -16, 1, -106)
    popScroll.Position = UDim2.new(0, 8, 0, 68)
    popScroll.BackgroundTransparency = 1
    popScroll.ScrollBarThickness = 3
    popScroll.ScrollBarImageColor3 = Theme.Accent1
    popScroll.ScrollBarImageTransparency = 0.4
    popScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    popScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    popScroll.BorderSizePixel = 0; popScroll.ZIndex = 51

    local addDiv = Instance.new("Frame", priorityPopup)
    addDiv.Size = UDim2.new(1, -16, 0, 1)
    addDiv.Position = UDim2.new(0, 8, 1, -34)
    addDiv.BackgroundColor3 = Theme.Accent1; addDiv.BackgroundTransparency = 0.8
    addDiv.BorderSizePixel = 0; addDiv.ZIndex = 51

    local addRow = Instance.new("Frame", priorityPopup)
    addRow.Size = UDim2.new(1, -16, 0, 28)
    addRow.Position = UDim2.new(0, 8, 1, -30)
    addRow.BackgroundTransparency = 1; addRow.ZIndex = 51

    local addInput = Instance.new("TextBox", addRow)
    addInput.Size = UDim2.new(1, -52, 1, 0)
    addInput.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
    addInput.Text = ""; addInput.PlaceholderText = "Add brainrot name..."
    addInput.PlaceholderColor3 = Theme.TextSecondary
    addInput.TextColor3 = Theme.TextPrimary; addInput.TextSize = 10
    addInput.Font = Enum.Font.GothamMedium; addInput.ClearTextOnFocus = false
    addInput.TextXAlignment = Enum.TextXAlignment.Left
    addInput.BorderSizePixel = 0; addInput.ZIndex = 52
    Instance.new("UICorner", addInput).CornerRadius = UDim.new(0, 6)
    Instance.new("UIPadding", addInput).PaddingLeft = UDim.new(0, 8)
    local _adStroke = Instance.new("UIStroke", addInput)
    _adStroke.Color = Theme.Accent1; _adStroke.Thickness = 1; _adStroke.Transparency = 0.7

    local addBtn = Instance.new("TextButton", addRow)
    addBtn.Size = UDim2.new(0, 46, 1, 0)
    addBtn.Position = UDim2.new(1, -46, 0, 0)
    addBtn.BackgroundColor3 = Theme.Accent1
    addBtn.Text = "ADD"; addBtn.TextColor3 = Color3.fromRGB(5, 5, 10)
    addBtn.TextSize = 10; addBtn.Font = Enum.Font.GothamBold
    addBtn.AutoButtonColor = false; addBtn.BorderSizePixel = 0; addBtn.ZIndex = 52
    Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 6)

    local popLayout = Instance.new("UIListLayout", popScroll)
    popLayout.Padding = UDim.new(0, 2)
    popLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function rebuildPriorityList()
        for _, child in ipairs(popScroll:GetChildren()) do
            if child:IsA("Frame") then child:Destroy() end
        end
        local query = (searchInput.Text or ""):lower():match("^%s*(.-)%s*$") or ""
        local firstMatchRow = nil
        for idx, name in ipairs(PRIORITY_LIST) do
            local nl = name:lower()
            local isMatch = query ~= "" and nl:find(query, 1, true)
            local row = Instance.new("Frame", popScroll)
            row.Size = UDim2.new(1, 0, 0, 22)
            row.BackgroundColor3 = isMatch and Theme.Accent1 or Color3.fromRGB(16, 18, 26)
            row.BackgroundTransparency = isMatch and 0.6 or 0
            row.LayoutOrder = idx; row.ZIndex = 52
            Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)
            if isMatch and not firstMatchRow then firstMatchRow = row end

            local numLabel = Instance.new("TextLabel", row)
            numLabel.Size = UDim2.new(0, 20, 1, 0); numLabel.Position = UDim2.new(0, 4, 0, 0)
            numLabel.BackgroundTransparency = 1; numLabel.Text = tostring(idx)
            numLabel.TextColor3 = Theme.TextSecondary; numLabel.TextSize = 9
            numLabel.Font = Enum.Font.GothamBold; numLabel.ZIndex = 53

            local nameLabel = Instance.new("TextLabel", row)
            nameLabel.Size = UDim2.new(1, -80, 1, 0); nameLabel.Position = UDim2.new(0, 24, 0, 0)
            nameLabel.BackgroundTransparency = 1; nameLabel.Text = name
            nameLabel.TextColor3 = isMatch and Theme.Accent1 or Theme.TextPrimary
            nameLabel.TextSize = 10; nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd; nameLabel.ZIndex = 53

            local function makeBtn(txt, xOff, clr, onClick)
                local b = Instance.new("TextButton", row)
                b.Size = UDim2.new(0, 16, 0, 16); b.Position = UDim2.new(1, xOff, 0.5, -8)
                b.BackgroundTransparency = 1; b.Text = txt
                b.TextColor3 = clr; b.TextSize = 9; b.Font = Enum.Font.GothamBold
                b.AutoButtonColor = false; b.ZIndex = 54
                b.MouseButton1Click:Connect(onClick)
                return b
            end
            makeBtn("▲", -54, Theme.TextSecondary, function()
                if idx > 1 then
                    PRIORITY_LIST[idx], PRIORITY_LIST[idx-1] = PRIORITY_LIST[idx-1], PRIORITY_LIST[idx]
                    _plSave(); rebuildPriorityList()
                end
            end)
            makeBtn("▼", -36, Theme.TextSecondary, function()
                if idx < #PRIORITY_LIST then
                    PRIORITY_LIST[idx], PRIORITY_LIST[idx+1] = PRIORITY_LIST[idx+1], PRIORITY_LIST[idx]
                    _plSave(); rebuildPriorityList()
                end
            end)
            makeBtn("✕", -16, Color3.fromRGB(255, 80, 80), function()
                table.remove(PRIORITY_LIST, idx)
                _plSave(); rebuildPriorityList()
            end)
        end
        if firstMatchRow then
            task.defer(function()
                local yPos = firstMatchRow.AbsolutePosition.Y - popScroll.AbsolutePosition.Y + popScroll.CanvasPosition.Y
                popScroll.CanvasPosition = Vector2.new(0, math.max(0, yPos - 10))
            end)
        end
    end

    addBtn.MouseButton1Click:Connect(function()
        local name = (addInput.Text or ""):match("^%s*(.-)%s*$"):lower()
        if name == "" then return end
        for _, existing in ipairs(PRIORITY_LIST) do
            if existing:lower() == name then addInput.Text = ""; return end
        end
        local titled = name:gsub("(%a)([%w_']*)", function(a, b) return a:upper()..b end)
        table.insert(PRIORITY_LIST, titled)
        addInput.Text = ""; _plSave(); rebuildPriorityList()
    end)

    searchInput:GetPropertyChangedSignal("Text"):Connect(rebuildPriorityList)

    popClose.MouseButton1Click:Connect(function()
        priorityPopup.Visible = false
    end)

    local _ppDg, _ppDs, _ppSp = false, nil, nil
    popTitle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            _ppDg = true; _ppDs = input.Position; _ppSp = priorityPopup.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then _ppDg = false end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if _ppDg and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - _ppDs
            priorityPopup.Position = UDim2.new(0, _ppSp.X.Offset + d.X, 0, _ppSp.Y.Offset + d.Y)
        end
    end)

    if not IS_MOBILE then
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                priorityPopup.Visible = not priorityPopup.Visible
            end
        end)
    end

    -- Expose toggle for settings button
    _G._togglePriorityPopup = function()
        priorityPopup.Visible = not priorityPopup.Visible
    end

    rebuildPriorityList()
    print("[wxrldz mogs] Loaded | " .. #PRIORITY_LIST .. " items")
end)

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils = require(Utils:WaitForChild("NumberUtils"))

    local isStealing = false
    local baseSnapshot = {}
    local stealStartTime = 0
    local stealStartPosition = Vector3.new(0, 0, 0)

    local function GetMyPlot()
        for _, plot in ipairs(Workspace.Plots:GetChildren()) do
            local channel = Synchronizer:Get(plot.Name)
            if channel then
                local owner = channel:Get("Owner")
                if (typeof(owner) == "Instance" and owner == LocalPlayer) or
                   (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                    return plot
                end
            end
        end
        return nil
    end

    local function GetPetsOnPlot(plot)
        local pets = {}
        if not plot then return pets end
        local channel = Synchronizer:Get(plot.Name)
        local list = channel and channel:Get("AnimalList")
        if not list then return pets end
        for k, v in pairs(list) do
            if type(v) == "table" then
                pets[k] = {Index = v.Index, Mutation = v.Mutation, Traits = v.Traits}
            end
        end
        return pets
    end

    local function GetInfo(data)
        local info = AnimalsData[data.Index]
        local name = info and info.DisplayName or data.Index
        local genVal = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
        local valStr = "$" .. NumberUtils:ToString(genVal) .. "/s"
        return name, valStr, data.Mutation
    end

    local function TeleportToTarget()
        local targetPetData = SharedState.SelectedPetData and SharedState.SelectedPetData.animalData
        if not targetPetData then return end
        local targetPart = findAdorneeGlobal(targetPetData)
        if not targetPart then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local itemPos = targetPart.Position
        local targetY = hrp.Position.Y
        if itemPos.Y > 23.15 then
            targetY = 21
        elseif itemPos.Y >= 11 and itemPos.Y <= 23.15 then
            targetY = 14.5
        elseif itemPos.Y >= -6.9 and itemPos.Y <= 8.9 then
            targetY = -4
        end
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(itemPos.X, targetY, itemPos.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        if itemPos.Y > 23.15 then
            task.wait(0.05)
            if _G.enableFloat then pcall(_G.enableFloat) end
        end
    end

    -- Anti Steal core logic
    local _antiStealActive = false
    local _antiStealBoughtCount = 0

    local function asWalkToPos(pos, timeout)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local startT = tick()
        local done = false
        local conn = hum.MoveToFinished:Connect(function() done = true end)
        hum:MoveTo(pos)
        while not done and _antiStealActive and (tick() - startT) < (timeout or 25) do task.wait(0.2) end
        conn:Disconnect()
    end

    local function asGetMyBasePos()
        local myPlot = GetMyPlot()
        if not myPlot then return nil end
        local refPos = nil
        for _, p in ipairs(myPlot:GetDescendants()) do
            if p:IsA("BasePart") then refPos = p.Position; break end
        end
        if not refPos then return nil end
        local idx = getClosestBaseIdx(refPos)
        local isHigh = refPos.Y > 10
        return isHigh and BASES_HIGH[idx] or BASES_LOW[idx]
    end

    local function asWalkAndCollect()
        local basePos = asGetMyBasePos()
        if not basePos then return end
        local needed = Config.AntiStealWalkBackAfter or _antiStealBoughtCount

        local myPlot = GetMyPlot()

        -- Snapshot AnimalList count before we start waiting
        local countBefore = 0
        if myPlot then
            for _ in pairs(GetPetsOnPlot(myPlot)) do countBefore = countBefore + 1 end
        end

        -- Walk to base entry
        ShowNotification("ANTI STEAL", "At base — waiting for " .. needed .. " brainrots...")
        asWalkToPos(basePos, 25)
        if not _antiStealActive then return end

        -- Event-driven scanner: listen for new direct workspace children appearing near base.
        -- workspace.ChildAdded fires rarely (only direct children), so it won't freeze.
        local arrivedEvent = 0
        local seenByEvent = {}
        local childConn = workspace.ChildAdded:Connect(function(obj)
            if arrivedEvent >= needed then return end
            pcall(function()
                local pos
                if obj:IsA("Model") then
                    local ok; ok, pos = pcall(function() return obj:GetPivot().Position end)
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                end
                if not pos then return end
                if (pos - basePos).Magnitude > 120 then return end
                if seenByEvent[obj] then return end
                seenByEvent[obj] = true
                arrivedEvent = arrivedEvent + 1
            end)
        end)

        -- Poll loop — only polls GetPetsOnPlot (one Synchronizer lookup, very fast)
        -- and checks arrivedEvent counter. No workspace scanning.
        local waitStart = tick()
        while _antiStealActive and (tick() - waitStart) < 120 do
            -- Check event-driven counter first (fires instantly from ChildAdded)
            if arrivedEvent >= needed then
                ShowNotification("ANTI STEAL", needed .. " brainrots detected — moving to collect!")
                break
            end
            -- Method 1: AnimalList changed (brainrot placed in podium)
            if myPlot then
                local countNow = 0
                for _ in pairs(GetPetsOnPlot(myPlot)) do countNow = countNow + 1 end
                if (countNow - countBefore) >= needed then
                    ShowNotification("ANTI STEAL", needed .. " brainrots detected — moving to collect!")
                    break
                end
            end
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum:MoveTo(basePos) end
            task.wait(0.15)
        end
        childConn:Disconnect()

        if not _antiStealActive then return end

        -- Walk into collect zone (nearest CLONE_POSITIONS_FLOOR position to our base entry)
        local collectPos = basePos
        local minDist = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (basePos - v).Magnitude
            if d < minDist then minDist = d; collectPos = v end
        end
        ShowNotification("ANTI STEAL", "Walking to collect zone!")
        asWalkToPos(collectPos, 15)
    end

    local function isBaseFull()
        local myPlot = GetMyPlot()
        if not myPlot then return false end
        local podiums = myPlot:FindFirstChild("AnimalPodiums")
        if not podiums then return false end
        local totalSlots = #podiums:GetChildren()
        local current = GetPetsOnPlot(myPlot)
        local count = 0
        for _ in pairs(current) do count = count + 1 end
        return count >= totalSlots
    end

    -- runFillBase(): TPs to every buy prompt and buys until base is full.
    -- Each pass visits ALL available prompts; stops when base full is detected.
    local _fillActive = false
    local function runFillBase()
        if _fillActive then return end
        if LocalPlayer:GetAttribute("Stealing") then
            ShowNotification("FILL", "Cannot fill while stealing!"); return
        end
        _fillActive = true
        ShowNotification("FILL", "Filling base...")

        local function countPets()
            local myPlot = GetMyPlot()
            if not myPlot then return 0 end
            local current = GetPetsOnPlot(myPlot)
            local n = 0; for _ in pairs(current) do n = n + 1 end
            return n
        end

        local function getPrompts(hrp)
            local list = {}
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if not obj:IsA("ProximityPrompt") then continue end
                    local act = (obj.ActionText or ""):lower()
                    if not (act:find("purchase") or act:find("buy")) then continue end
                    if act:find("steal") then continue end
                    local par = obj.Parent
                    local pos
                    if par and par:IsA("Attachment") then pos = par.WorldPosition
                    elseif par and par:IsA("BasePart") then pos = par.Position end
                    if pos then table.insert(list, {prompt=obj, pos=pos}) end
                end
            end)
            table.sort(list, function(a, b)
                return (a.pos - hrp.Position).Magnitude < (b.pos - hrp.Position).Magnitude
            end)
            return list
        end

        local totalBought = 0
        while true do
            if LocalPlayer:GetAttribute("Stealing") then
                ShowNotification("FILL", "Stopped — started stealing"); break
            end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then task.wait(0.3); continue end

            local prompts = getPrompts(hrp)
            if #prompts == 0 then
                ShowNotification("FILL", "No more brainrots (" .. totalBought .. " bought)"); break
            end

            local passGot = 0
            for _, entry in ipairs(prompts) do
                if LocalPlayer:GetAttribute("Stealing") then
                    ShowNotification("FILL", "Stopped — started stealing"); _fillActive = false; return
                end
                local prompt = entry.prompt
                if not prompt or not prompt.Parent then continue end
                local name = (prompt.ObjectText or "?"):gsub("%s*%$%d+.*$", "")
                local c2 = LocalPlayer.Character
                local h2 = c2 and c2:FindFirstChild("HumanoidRootPart")
                if h2 then pcall(function() h2.CFrame = CFrame.new(entry.pos + Vector3.new(0, 3, 0)) end) end
                task.wait(0.15)
                local countBefore = countPets()
                pcall(function()
                    local oldHold = prompt.HoldDuration
                    local oldMax = prompt.MaxActivationDistance
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = math.huge
                    pcall(fireproximityprompt, prompt)
                    prompt.HoldDuration = oldHold
                    prompt.MaxActivationDistance = oldMax
                end)
                task.wait(0.4)
                local countAfter = countPets()
                if countAfter <= countBefore then
                    ShowNotification("FILL", "Base full — stopped (" .. totalBought .. " bought)")
                    _fillActive = false; return
                end
                totalBought = totalBought + 1
                passGot = passGot + 1
                ShowNotification("FILL", "Bought " .. totalBought .. ": " .. name)
                task.wait(0.1)
            end

            if passGot == 0 then
                ShowNotification("FILL", "No room or brainrots (" .. totalBought .. " bought)"); break
            end
        end
        _fillActive = false
    end
    SharedState.RunFillBase = runFillBase

    -- runDeleteSlots():
    --   total deletions = DeleteSlotCount + 1 (always one extra)
    --   floor plan: 1 from floor 1, then alternate floor 2/3 for (count-1) slots,
    --               then always 1 guaranteed floor 3 at the end.
    --   e.g. count=3 → total=4 → floor plan: 1,2,3,3
    --        count=1 → total=2 → floor plan: 1,3
    --        count=2 → total=3 → floor plan: 1,2,3
    --        count=4 → total=5 → floor plan: 1,2,3,2,3
    local function runDeleteSlots()
        local count = math.max(1, math.floor(Config.DeleteSlotCount or 3))
        local total = count + 1  -- always one extra
        local myPlot = GetMyPlot()
        if not myPlot then ShowNotification("DELETE", "Plot not found"); return end
        local ch = Synchronizer:Get(myPlot.Name)
        local al = ch and ch:Get("AnimalList")
        if not al then ShowNotification("DELETE", "AnimalList not found"); return end
        local podiums = myPlot:FindFirstChild("AnimalPodiums")
        if not podiums then ShowNotification("DELETE", "No podiums"); return end

        -- Get the Y position of a podium using the first BasePart found anywhere in it
        local function getPodiumY(pod)
            if pod:IsA("BasePart") then return pod.Position.Y end
            for _, d in ipairs(pod:GetDescendants()) do
                if d:IsA("BasePart") then return d.Position.Y end
            end
            return 0
        end

        local function findRemovePrompt(pod)
            for _, d in ipairs(pod:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    local act = (d.ActionText or ""):lower()
                    if act:find("remove") or act:find("delete") or act:find("sell") or act:find("evict") or act:find("release") or act:find("free") then
                        return d
                    end
                end
            end
        end

        -- Collect occupied pods under 100k/s with their Y positions
        local allOccupied = {}
        for _, pod in ipairs(podiums:GetChildren()) do
            local slotKey = pod.Name
            local ad = al[tonumber(slotKey)] or al[slotKey]
            if type(ad) == "table" then
                local gv = 0
                pcall(function()
                    gv = AnimalsShared:GetGeneration(ad.Index, ad.Mutation, ad.Traits, nil)
                end)
                if gv < 100000 then
                    local prompt = findRemovePrompt(pod)
                    if prompt then
                        table.insert(allOccupied, {slot=slotKey, prompt=prompt, y=getPodiumY(pod)})
                    end
                end
            end
        end

        if #allOccupied == 0 then ShowNotification("DELETE", "No deletable slots found"); return end

        -- Sort by Y ascending so we can split into floor thirds dynamically
        table.sort(allOccupied, function(a, b) return a.y < b.y end)

        -- Divide into 3 floor buckets by splitting the sorted list into thirds
        local n = #allOccupied
        local third = math.max(1, math.floor(n / 3))
        local buckets = {[1]={}, [2]={}, [3]={}}
        for i, entry in ipairs(allOccupied) do
            local fl
            if i <= third then fl = 1
            elseif i <= third * 2 then fl = 2
            else fl = 3
            end
            table.insert(buckets[fl], entry)
        end

        -- Shuffle each bucket so picks are random within a floor
        for fl = 1, 3 do
            local b = buckets[fl]
            for i = #b, 2, -1 do local j = math.random(1, i); b[i], b[j] = b[j], b[i] end
        end

        -- Build floor plan: floor1, then alternate 2/3, then guaranteed floor3 at end
        -- e.g. count=3 → total=4 → {1, 2, 3, 3}
        local floorPlan = {1}
        local altIdx = 1
        for _ = 2, total - 1 do
            table.insert(floorPlan, altIdx == 1 and 2 or 3)
            altIdx = (altIdx % 2) + 1
        end
        table.insert(floorPlan, 3)

        -- Pull from target floor; fallback to any non-empty bucket
        local toDelete = {}
        local function pullFrom(targetFl)
            if #buckets[targetFl] > 0 then
                table.insert(toDelete, table.remove(buckets[targetFl], 1))
                return
            end
            for _, f in ipairs({1, 2, 3}) do
                if #buckets[f] > 0 then
                    table.insert(toDelete, table.remove(buckets[f], 1))
                    return
                end
            end
        end

        for _, fl in ipairs(floorPlan) do
            pullFrom(fl)
        end

        if #toDelete == 0 then ShowNotification("DELETE", "No deletable slots found"); return end

        for i, entry in ipairs(toDelete) do
            local prompt = entry.prompt
            if prompt and prompt.Parent then
                pcall(function()
                    local oldMax = prompt.MaxActivationDistance
                    prompt.MaxActivationDistance = math.huge
                    pcall(fireproximityprompt, prompt)
                    prompt.MaxActivationDistance = oldMax
                end)
                ShowNotification("DELETE", "Deleted slot " .. tostring(entry.slot) .. " (" .. i .. "/" .. #toDelete .. ")")
                task.wait(0.35)
            end
        end
        ShowNotification("DELETE", "Done — " .. #toDelete .. " slot(s) freed")
    end
    SharedState.RunDeleteSlots = runDeleteSlots

    -- On join: poll until plot loads, then if base is full auto-run delete twice
    task.spawn(function()
        local deadline = tick() + 30
        while tick() < deadline do
            local plot = GetMyPlot()
            if plot and isBaseFull() then
                ShowNotification("DELETE", "Base full on join — auto-deleting...")
                runDeleteSlots()
                task.wait(1)
                runDeleteSlots()
                break
            end
            task.wait(1)
        end
    end)

    local function runAntiSteal()
        if _antiStealActive then return end
        _antiStealActive = true
        _antiStealBoughtCount = 0
        ShowNotification("ANTI STEAL", "Active — finding brainrots...")

        local boughtPrompts = {}

        -- Build buy list set for filtering (nil = buy anything)
        local buySet = nil
        if #Config.AntiStealBuyList > 0 then
            buySet = {}
            for _, n in ipairs(Config.AntiStealBuyList) do buySet[n:lower()] = true end
        end

        local function getNearestPromptEntry(hrp)
            -- Full workspace scan so items nested inside any folder are found
            local eligible = {}
            pcall(function()
                for _, d in ipairs(workspace:GetDescendants()) do
                    if not d:IsA("ProximityPrompt") then continue end
                    local act = (d.ActionText or ""):lower()
                    if not (act:find("purchase") or act:find("buy")) then continue end
                    if boughtPrompts[d] then continue end
                    if not d.Parent then continue end
                    local pos
                    local par = d.Parent
                    if par:IsA("Attachment") then
                        pos = par.WorldPosition
                    elseif par:IsA("BasePart") then
                        pos = par.Position
                    end
                    if not pos then continue end
                    -- Skip steal prompts (already handled by auto steal)
                    if act:find("steal") then continue end
                    if buySet then
                        local objText = (d.ObjectText or ""):lower()
                        local match = false
                        for name in pairs(buySet) do
                            if objText:find(name, 1, true) then match = true; break end
                        end
                        if not match then continue end
                    end
                    table.insert(eligible, { prompt = d, pos = pos })
                end
            end)
            table.sort(eligible, function(a, b)
                return (a.pos - hrp.Position).Magnitude < (b.pos - hrp.Position).Magnitude
            end)
            return eligible[1]
        end

        while _antiStealActive and _antiStealBoughtCount < Config.AntiStealBuyCount do
            if isBaseFull() then
                ShowNotification("ANTI STEAL", "Base full, stopping")
                break
            end

            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or hum.Health <= 0 then task.wait(0.2); continue end

            local entry = getNearestPromptEntry(hrp)
            if not entry then
                hum:MoveTo(hrp.Position)
                task.wait(0.3)
                continue
            end

            local dist = (hrp.Position - entry.pos).Magnitude

            -- Only walk toward it if it's already reasonably close; otherwise wait for it to come to us
            if dist > 25 then
                hum:MoveTo(hrp.Position)
                task.wait(0.3)
                continue
            end

            if dist > 7 then
                hum:MoveTo(entry.pos)
                task.wait(0.15)
                continue
            end

            -- Within range — buy
            local prompt = entry.prompt
            if prompt and prompt.Parent then
                boughtPrompts[prompt] = true
                _antiStealBoughtCount = _antiStealBoughtCount + 1
                local name = (prompt.ObjectText or "?"):gsub("%s*%$%d+.*$", "")
                pcall(function()
                    local oldHold = prompt.HoldDuration
                    local oldMax = prompt.MaxActivationDistance
                    prompt.HoldDuration = 0
                    prompt.MaxActivationDistance = math.huge
                    pcall(fireproximityprompt, prompt)
                    prompt.HoldDuration = oldHold
                    prompt.MaxActivationDistance = oldMax
                end)
                ShowNotification("ANTI STEAL", "Bought " .. _antiStealBoughtCount .. "/" .. Config.AntiStealBuyCount .. ": " .. name)
            else
                boughtPrompts[prompt] = true
            end
            task.wait(0.1)
        end

        if _antiStealActive then
            asWalkAndCollect()
        end

        _antiStealActive = false
    end

    SharedState.StartAntiSteal = function()
        if not _antiStealActive then task.spawn(runAntiSteal) end
    end
    SharedState.StopAntiSteal = function()
        _antiStealActive = false
    end

    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")

        if state then
            isStealing = true
            baseSnapshot = GetPetsOnPlot(GetMyPlot())
            stealStartTime = tick()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then stealStartPosition = hrp.Position end
        else
            if not isStealing then return end
            isStealing = false

            local stealDuration = tick() - stealStartTime
            local distanceMoved = 0
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then distanceMoved = (hrp.Position - stealStartPosition).Magnitude end

            task.wait(0.1)

            local currentPets = GetPetsOnPlot(GetMyPlot())
            local stolenData = nil
            for slot, data in pairs(currentPets) do
                local old = baseSnapshot[slot]
                if not old or (old.Index ~= data.Index or old.Mutation ~= data.Mutation) then
                    stolenData = data
                    break
                end
            end

            if stolenData then
                if Config.AutoKickOnSteal then kickPlayer(); return end
                local name, gen, mut = GetInfo(stolenData)
            elseif Config.AutoTpOnFailedSteal then
                if distanceMoved > 60 then
                    -- Knocked far out of the base — find a new target
                    ShowNotification("STEAL FAILED", string.format("Kicked far (%.0f studs), re-sniping...", distanceMoved))
                    task.spawn(runAutoSnipe)
                elseif distanceMoved >= 2 then
                    -- Hit inside or near the base — go straight back to the pet
                    ShowNotification("STEAL FAILED", string.format("Knocked back (%.0f studs), returning to pet...", distanceMoved))
                    task.spawn(TeleportToTarget)
                end
            end
        end
    end)
end)


SharedState.XrayData = {
    TARGET_TRANS = 0.7,
    INVISIBLE_TRANS = 1,
    ENFORCE_EVERY_FRAME = true,
    trackedObjects = {},
    trackedModels = {},
}


SharedState.XrayFunctions = {}
SharedState.XrayFunctions.nameHasClone = function(name)
	return string.find(string.lower(name), "clone", 1, true) ~= nil
end
SharedState.XrayFunctions.getTargetTransparency = function(obj)
	local xd = SharedState.XrayData
	if obj.Name == "HumanoidRootPart" then return xd.INVISIBLE_TRANS end
	return xd.TARGET_TRANS
end
SharedState.XrayFunctions.applyObject = function(obj)
	local target = SharedState.XrayFunctions.getTargetTransparency(obj)
	if obj:IsA("BasePart") then
		obj.CanCollide = false
		obj.Transparency = target
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = target
	end
end
SharedState.XrayFunctions.trackObject = function(obj)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedObjects[obj] then return end
	if not (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) then return end
	xd.trackedObjects[obj] = true
	xf.applyObject(obj)
	if obj:IsA("BasePart") then
		obj:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if obj.CanCollide ~= false then obj.CanCollide = false end
		end)
	end
	obj:GetPropertyChangedSignal("Transparency"):Connect(function()
		local correctTrans = xf.getTargetTransparency(obj)
		if obj.Transparency ~= correctTrans then obj.Transparency = correctTrans end
	end)
	obj.AncestryChanged:Connect(function()
		if obj.Parent == nil then xd.trackedObjects[obj] = nil end
	end)
end
SharedState.XrayFunctions.trackModel = function(model)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedModels[model] then return end
	xd.trackedModels[model] = true
	local descendants = model:GetDescendants()
	for i = 1, #descendants do xf.trackObject(descendants[i]) end
	model.DescendantAdded:Connect(function(d) xf.trackObject(d) end)
	model.AncestryChanged:Connect(function()
		if model.Parent == nil then xd.trackedModels[model] = nil end
	end)
end
SharedState.XrayFunctions.handleWorkspaceChild = function(child)
	if child.Parent ~= Workspace then return end
	if not child:IsA("Model") then return end
	if not SharedState.XrayFunctions.nameHasClone(child.Name) then return end
	SharedState.XrayFunctions.trackModel(child)
end
SharedState.XrayFunctions.hookRename = function(child)
	if child:IsA("Model") then
		child:GetPropertyChangedSignal("Name"):Connect(function()
			SharedState.XrayFunctions.handleWorkspaceChild(child)
		end)
	end
end
SharedState.XrayFunctions.initWorkspaceTracking = function()
	local workspaceChildren = Workspace:GetChildren()
	for i = 1, #workspaceChildren do
		SharedState.XrayFunctions.handleWorkspaceChild(workspaceChildren[i])
		SharedState.XrayFunctions.hookRename(workspaceChildren[i])
	end
end
SharedState.XrayFunctions.initWorkspaceTracking()
Workspace.ChildAdded:Connect(function(child)
	task.defer(function() SharedState.XrayFunctions.handleWorkspaceChild(child) end)
	SharedState.XrayFunctions.hookRename(child)
end)
if SharedState.XrayData.ENFORCE_EVERY_FRAME then
	SharedState.XrayFunctions.enforceXrayFrame = function()
		local xd = SharedState.XrayData
		local xf = SharedState.XrayFunctions
		local objList = {}
		for obj in pairs(xd.trackedObjects) do table.insert(objList, obj) end
		for i = 1, #objList do
			local obj = objList[i]
			if obj.Parent == nil then
				xd.trackedObjects[obj] = nil
			else
				if obj:IsA("BasePart") and obj.CanCollide ~= false then obj.CanCollide = false end
				local target = xf.getTargetTransparency(obj)
				if obj.Transparency ~= target then obj.Transparency = target end
			end
		end
	end
	RunService.Heartbeat:Connect(SharedState.XrayFunctions.enforceXrayFrame)
end


if Config.CleanErrorGUIs then
    task.spawn(function()
        local GuiService = cloneref and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
        while true do
            if Config.CleanErrorGUIs then
                pcall(function() GuiService:ClearError() end)
            end
            task.wait(0.005)
        end
    end)
end


task.spawn(function()
    local HTheme = {
        Background = Color3.fromRGB(15,17,22),
        Accent1 = Color3.fromRGB(0,225,255),
        Accent2 = Color3.fromRGB(170,0,255),
        White   = Color3.fromRGB(235,235,245),
        Gray    = Color3.fromRGB(130,130,145),
        Success = Color3.fromRGB(30, 150, 90),
        Error   = Color3.fromRGB(255, 60, 80)
    }

    local SCALE = (IS_MOBILE and 0.65 or 1)
    local HEIGHT = 50 * SCALE
    
    if not Config.Positions then Config.Positions = {} end
    
    local joinerGui = Instance.new("ScreenGui")
    joinerGui.Name = "wxrldzJobJoiner"
    joinerGui.ResetOnSpawn = false
    joinerGui.DisplayOrder = 999
    joinerGui.Enabled = Config.ShowJobJoiner
    joinerGui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500 * SCALE, 0, HEIGHT)
    
    local savedPos = Config.Positions.JobJoiner
    if not savedPos then
        savedPos = {X = 0.5, Y = 0.85}
        Config.Positions.JobJoiner = savedPos
    end
    
    main.AnchorPoint = Vector2.new(0.5, 0) 
    main.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    main.BackgroundColor3 = Color3.fromRGB(20,22,28)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = joinerGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main

    local bgGradient = Instance.new("UIGradient")
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20,22,28)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,27,35))
    }
    bgGradient.Rotation = 45
    bgGradient.Parent = main

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    stroke.Parent = main
    
    local strokeGrad = Instance.new("UIGradient")
    strokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.5, HTheme.Accent2),
        ColorSequenceKeypoint.new(1, HTheme.Accent1)
    }
    strokeGrad.Parent = stroke
    
    task.spawn(function()
        while strokeGrad and strokeGrad.Parent do
            strokeGrad.Rotation = (strokeGrad.Rotation + 1) % 360
            task.wait(0.05)
        end
    end)

    local function MakeDraggable(frame, dragFrame, configName)
        local dragging = false
        local dragStart = nil
        local startPos = nil

        dragFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = frame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)

        dragFrame.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
                           input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                local viewport = workspace.CurrentCamera.ViewportSize
                local newX = math.clamp(startPos.X.Scale + (delta.X / viewport.X), 0, 1)
                local newY = math.clamp(startPos.Y.Scale + (delta.Y / viewport.Y), 0, 1)
                
                frame.Position = UDim2.new(newX, 0, newY, 0)
            end
        end)

        dragFrame.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or 
               input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                
                if Config.Positions then
                    Config.Positions[configName] = {
                        X = frame.Position.X.Scale,
                        Y = frame.Position.Y.Scale
                    }
                    if SaveConfig then
                        SaveConfig()
                    end
                end
            end
        end)
    end

    MakeDraggable(main, main, "JobJoiner")

    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, -20 * SCALE, 1, 0)
    content.Position = UDim2.new(0, 10 * SCALE, 0, 0)
    content.BackgroundTransparency = 1
    content.Parent = main
    
    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8 * SCALE)
    layout.Parent = content

    local function CreateInput(placeholder, width, default)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        frame.Parent = content
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, 10 * SCALE)
        label.Position = UDim2.new(0, 0, 0, -10 * SCALE)
        label.BackgroundTransparency = 1
        label.Text = placeholder
        label.TextColor3 = HTheme.Accent1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9 * SCALE
        label.Parent = frame
        
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.BackgroundTransparency = 0.5
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.TextColor3 = HTheme.White
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12 * SCALE
        box.ClearTextOnFocus = false
        box.Parent = frame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = box
        
        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = HTheme.Gray
        boxStroke.Thickness = 0.1
        boxStroke.Transparency = 0.6
        boxStroke.Parent = box
        
        box.Focused:Connect(function() 
            TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = HTheme.Accent1, Transparency = 0}):Play() 
        end)
        
        box.FocusLost:Connect(function() 
            TweenService:Create(boxStroke, TweenInfo.new(0.2), {Color = HTheme.Gray, Transparency = 0.6}):Play() 
        end)
        
        return frame, box
    end

    local function CreateButton(text, width, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12 * SCALE
        btn.TextColor3 = HTheme.White
        btn.AutoButtonColor = false
        btn.Parent = content
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        local btnStroke = Instance.new("UIStroke")
        btnStroke.Color = color
        btnStroke.Thickness = 1.5
        btnStroke.Transparency = 0.4
        btnStroke.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(btnStroke, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        
        return btn
    end

    local joinBtn = CreateButton("JOIN", 60, HTheme.Success)
    local idFrame, idBox = CreateInput("", 180, "")
    idBox.PlaceholderText = ""
    idBox.TextTruncate = Enum.TextTruncate.AtEnd
    local clearBtn = CreateButton("CLEAR", 50, Color3.fromRGB(60, 60, 70))
    local attFrame, attBox = CreateInput("Attempts", 60, "2000")
    local delFrame, delBox = CreateInput("Delay", 50, "0.01")
    local keyFrame, keyBox = CreateInput("Rejoin Key", 70, Config.ReJoinKey or "")
    keyBox.PlaceholderText = "e.g. F"

    keyBox.FocusLost:Connect(function()
        local val = keyBox.Text:gsub("%s+", "")
        if val == "" then return end
        local ok, keyCode = pcall(function() return Enum.KeyCode[val] end)
        if ok and keyCode then
            Config.ReJoinKey = val
            if SaveConfig then SaveConfig() end
            if ShowNotification then ShowNotification("REJOIN KEY", "Set to " .. val) end
        else
            if ShowNotification then ShowNotification("REJOIN KEY", "Invalid key: " .. val) end
            keyBox.Text = Config.ReJoinKey or ""
        end
    end)

    local isJoining = false

    local function doJoin()
        if isJoining then
            isJoining = false
            joinBtn.Text = "JOIN"
            joinBtn.BackgroundColor3 = HTheme.Success
            if ShowNotification then ShowNotification("JOINER", "Process Cancelled") end
            return
        end

        local jobId = idBox.Text:gsub("%s+", "")
        local attempts = tonumber(attBox.Text) or 2000
        local delayTime = tonumber(delBox.Text) or 0.01

        if jobId == "" or #jobId < 5 then
            if ShowNotification then ShowNotification("ERROR", "Invalid JobID") end
            return
        end

        isJoining = true
        joinBtn.Text = "STOP"
        joinBtn.BackgroundColor3 = HTheme.Error

        task.spawn(function()
            for i = 1, attempts do
                if not isJoining then break end

                if ShowNotification then 
                    ShowNotification("JOINING", string.format("Attempt %d/%d...", i, attempts)) 
                end

                local success = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
                end)

                task.wait(delayTime)
            end

            isJoining = false
            if joinBtn and joinBtn.Parent then
                joinBtn.Text = "JOIN"
                joinBtn.BackgroundColor3 = HTheme.Success
            end
        end)
    end
    
    joinBtn.MouseButton1Click:Connect(doJoin)

    clearBtn.MouseButton1Click:Connect(function()
        idBox.Text = ""
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not Config.ReJoinKey or Config.ReJoinKey == "" then return end
        local ok, keyCode = pcall(function() return Enum.KeyCode[Config.ReJoinKey] end)
        if ok and keyCode and input.KeyCode == keyCode then
            if ShowNotification then ShowNotification("REJOIN", "Rejoining...") end
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end
    end)
end)

-- FPS Boost
do
    local protectedBeams = {
        PlotBeam = true, BrainrotBeam = true, HighlightBeam = true,
        ESPBeam = true, SpawnBeam = true,
    }

    local function isProtectedBeam(beam)
        if protectedBeams[beam.Name] then return true end
        if beam.Parent and beam.Parent.Name == "HumanoidRootPart" then return true end
        if beam.Parent and beam.Parent:FindFirstChild("Humanoid") then return true end
        return false
    end

    local function isPlayerCharacter(model)
        return Players:GetPlayerFromCharacter(model) ~= nil
    end

    local animatorConnections = {}
    local function handleAnimator(animator)
        local model = animator:FindFirstAncestorOfClass("Model")
        if model and isPlayerCharacter(model) then return end
        pcall(function()
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
            local conn = animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
            table.insert(animatorConnections, conn)
        end)
    end

    local function stripVisuals(obj)
        local model = obj:FindFirstAncestorOfClass("Model")
        local isPlayer = model and isPlayerCharacter(model)
        if obj:IsA("Animator") then handleAnimator(obj) end
        if not isPlayer then
            if obj:IsA("ParticleEmitter") then
                pcall(function()
                    obj.Transparency = NumberRange.new(0.85, 1)
                    obj.LightEmission = 0
                    obj.Rate = math.min(obj.Rate * 0.1, 2)
                    obj:Clear()
                end)
            elseif obj:IsA("Trail") then
                pcall(function()
                    obj.Transparency = NumberRange.new(0.85, 1)
                end)
            elseif obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or obj:IsA("Highlight") then
                pcall(function() obj.Enabled = false end)
            end
            if obj:IsA("Beam") and not isProtectedBeam(obj) then
                pcall(function() obj.Enabled = false end)
            end
            if obj:IsA("Explosion") then
                pcall(function() obj:Destroy() end)
            end
            if obj:IsA("MeshPart") then
                pcall(function() obj.TextureID = "" end)
            end
            if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                pcall(function() obj.Enabled = false; obj.Brightness = 0 end)
            end
            if obj:IsA("BasePart") then
                pcall(function()
                    obj.Material = Enum.Material.Plastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                end)
            end
            if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
                pcall(function() obj:Destroy() end)
            end
        end
    end

    local _fpsDescConn = nil

    local function applyBoost()
        if _G.FPSBoostLoaded then return end
        _G.FPSBoostLoaded = true

        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or
               v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                pcall(function() v:Destroy() end)
            end
        end

        pcall(function()
            local terrain = workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.WaterTransparency = 1
            end
            if sethiddenproperty then
                pcall(function() sethiddenproperty(terrain, "Decoration", false) end)
            end
        end)

        pcall(function()
            settings().Physics.AllowSleep = true
            settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip
            settings().Physics.ThrottleAdjustTime = 0
        end)

        task.spawn(function()
            local descendants = workspace:GetDescendants()
            for i, obj in ipairs(descendants) do
                pcall(function() stripVisuals(obj) end)
                if i % 150 == 0 then task.wait() end
            end
        end)

        if not _fpsDescConn then
            _fpsDescConn = workspace.DescendantAdded:Connect(function(obj)
                if Config.FPSBoost then pcall(stripVisuals, obj) end
            end)
        end

        pcall(function() if setfpscap then setfpscap(999) end end)
    end

    _G.setFPSBoost = function(enabled)
        Config.FPSBoost = enabled
        SaveConfig()
        if enabled then
            applyBoost()
        else
            if _fpsDescConn then _fpsDescConn:Disconnect(); _fpsDescConn = nil end
            _G.FPSBoostLoaded = nil
        end
    end

    SharedState.FPSFunctions = {}
    SharedState.FPSFunctions.removeMeshes = function(tool)
        if not tool:IsA("Tool") then return end
        local handle = tool:FindFirstChild("Handle")
        if not handle then return end
        for _, d in ipairs(handle:GetDescendants()) do
            if d:IsA("SpecialMesh") or d:IsA("Mesh") or d:IsA("FileMesh") then
                d:Destroy()
            end
        end
    end
    SharedState.FPSFunctions.onCharacterAdded = function(character)
        local ff = SharedState.FPSFunctions
        character.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and Config.FPSBoost then ff.removeMeshes(child) end
        end)
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then ff.removeMeshes(child) end
        end
    end
    SharedState.FPSFunctions.onPlayerAdded = function(player)
        local ff = SharedState.FPSFunctions
        player.CharacterAdded:Connect(ff.onCharacterAdded)
        if player.Character then ff.onCharacterAdded(player.Character) end
    end
    SharedState.FPSFunctions.initPlayerTracking = function()
        local ff = SharedState.FPSFunctions
        for _, p in ipairs(Players:GetPlayers()) do ff.onPlayerAdded(p) end
        Players.PlayerAdded:Connect(ff.onPlayerAdded)
    end
    SharedState.FPSFunctions.initPlayerTracking()

    if Config.FPSBoost then
        task.spawn(function() task.wait(1); _G.setFPSBoost(true) end)
    end

    -- Apply theme to all GUIs after everything is created (fixes startup cyan on non-cyan themes)
    task.defer(function()
        if SharedState.ApplyFullTheme then SharedState.ApplyFullTheme() end
    end)
end


