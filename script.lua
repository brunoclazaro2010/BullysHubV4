if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)
pcall(function() if setfpscap then setfpscap(9999) end end)

local SharedState = {
    ConveyorAnimals = {},
    BestConveyorGv = -1,
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    BalloonedPlayers = {},
    PetPreviewModelCache = {},
    MobileScaleObjects = {},
}

do

    local Sync = require(game.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))

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
                    end
                end
            end
        end
    end
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

-- Safe conversion for configurable keybind strings.
local _F = {}

function _F.safeKeyCode(name, fallback)
    if type(name) ~= "string" then return fallback end
    local cleaned = name:gsub("^%s+", ""):gsub("%s+$", "")
    if cleaned == "" or cleaned == "--" then return fallback end
    local ok, kc = pcall(function() return Enum.KeyCode[cleaned] end)
    if ok and kc then return kc end
    return fallback
end

local FileName = "YinHub_v1.json" 
local DefaultConfig = {
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        AdminToolsPanel = {X = 0.02, Y = 0.25},
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        StealPanel = {X = 0.02, Y = 0.55},
        StealingHUD = {X = 0.8, Y = 0.15},
        JobJoiner = {X = 0.5, Y = 0.85},
        AutoBuy   = {X = 0.01, Y = 0.35},
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
    },
    StealSpeed   = 20,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = true,
    PlayerESP    = true,
    FPSBoost     = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    AutoBack = false,
    ShowStealingHUD = true,
    ShowStealingPlotESP = true,
    ConveyorESP = false,
    PriorityList = {},
    DefaultToDisable = false,
    UILocked     = false,
    HideAdminPanel = false,
    ShowAdminToolsPanel = true,
    HideAutoSteal = false,
    HideStealPanel = false,
    AutoKickOnSteal = false,
    InstantSteal = false,
    InvisStealAngle = 233,
    SinkSliderValue = 2.5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,

    InvisToggleKey = "I",
    ClickToAP = false,
    ClickToAPKeybind = "L",
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    AntiBeeDisco = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = true,
    AutoTPOnFailedSteal = false,
    AutoTPPriority = true,
    KickKey = "",
    CleanErrorGUIs = false,
    ClickToAPSingleCommand = false,
    RagdollSelfKey = "",
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://6518811702",
    AutoStealSpeed = false,
    ShowJobJoiner = true,
    JobJoinerKey = "J",
    CurrentTheme = "preto",
    ShowMiniActions = true,
    AutoHideMiniUI = false,
    MiniUIPos = {X = 0.01, Y = 0.35},
    MiniUILocked = false,
    Blacklist = {},
    BlacklistESP = true,
    BlacklistMsg = "BLOCKED",
    AutoBuyEnabled = false,
    AutoBuyKey = "K",
    AutoBuyRange = 17,
    AutoBuyColor = {R=0, G=220, B=255},
    HideAutoBuyUI = false,
    HideStealSpeedUI = false,
    HideStatusHUD = false,
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
        if type(decoded.Blacklist) ~= "table" then decoded.Blacklist = {} end
        Config = decoded
    end)
end
Config.ProximityAP = false

if Config.CurrentTheme and THEMES and THEMES[Config.CurrentTheme] then
    for k, v in pairs(THEMES[Config.CurrentTheme]) do Theme[k] = v end
end

function _F.SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do toSave[k] = v end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
do
    local invisKey = Enum.KeyCode.I
    if type(Config.InvisToggleKey) == "string" and Config.InvisToggleKey ~= "" then
        local ok, kc = pcall(function() return Enum.KeyCode[Config.InvisToggleKey] end)
        if ok and kc then invisKey = kc end
    end
    _G.INVISIBLE_STEAL_KEY = invisKey
end
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false

function _F.getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = _F.getControls()

function _F.kickPlayer()
    local ok = pcall(function()
        if game.Shutdown then
            game:Shutdown()
        else
            LocalPlayer:Kick("\nICEMAN V2")
        end
    end)
    if not ok then
        pcall(function() LocalPlayer:Kick("\nICEMAN V2") end)
    end
end

function _F.walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = _F.getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end


function _F.instantClone()
    if _G.isCloning then return end
    _G.isCloning = true

    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end

        local cloner =
            LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or char:FindFirstChild("Quantum Cloner")

        if not cloner then error("No Quantum Cloner") end

        pcall(function()
            hum:EquipTool(cloner)
        end)

        task.wait(0.01)

        cloner:Activate()
        task.wait(0.01)

        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.01)
        end

        if not Workspace:FindFirstChild(cloneName) then
            error("")
        end

        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if not tpButton then error("Teleport button missing") end

        tpButton.Visible = true

        if firesignal then
            firesignal(tpButton.MouseButton1Up)
        else
            local vim = cloneref and cloneref(game:GetService("VirtualInputManager")) or VirtualInputManager
            local inset = (cloneref and cloneref(game:GetService("GuiService")) or GuiService):GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset

            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end
    end)

    _G.isCloning = false
end

function _F.triggerClosestUnlock(yLevel, maxY)
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

local Theme = {
    Background      = Color3.fromRGB(18, 20, 26),
    Surface         = Color3.fromRGB(26, 29, 38),
    SurfaceHighlight= Color3.fromRGB(32, 36, 48),
    Accent1         = Color3.fromRGB(0, 220, 255),
    Accent2         = Color3.fromRGB(0, 180, 230),
    TextPrimary     = Color3.fromRGB(240, 248, 255),
    TextSecondary   = Color3.fromRGB(130, 200, 230),
    Success         = Color3.fromRGB(0, 220, 255),
    Error           = Color3.fromRGB(255, 70, 90),
}

THEMES = {
    preto = {
        Background       = Color3.fromRGB(18, 20, 26),
        Surface          = Color3.fromRGB(26, 29, 38),
        SurfaceHighlight = Color3.fromRGB(32, 36, 48),
        Accent1          = Color3.fromRGB(0, 220, 255),
        Accent2          = Color3.fromRGB(0, 180, 230),
        TextPrimary      = Color3.fromRGB(240, 248, 255),
        TextSecondary    = Color3.fromRGB(130, 200, 230),
        Success          = Color3.fromRGB(0, 220, 255),
        Error            = Color3.fromRGB(255, 70, 90),
        GlowColor1       = Color3.fromRGB(0, 220, 255),
        GlowColor2       = Color3.fromRGB(0, 160, 210),
    },
}

function applyTheme(themeName)
    local t = THEMES[themeName]
    if not t then return end

    local colorMap = {}
    for k, oldColor in pairs(Theme) do
        if t[k] then
            colorMap[oldColor] = t[k]
        end
    end

    for k, v in pairs(t) do
        Theme[k] = v
    end
    Config.CurrentTheme = themeName
    _F.SaveConfig()

    local function matchColor(c1, c2)
        if not c1 or not c2 then return false end
        local dr = math.abs(c1.R - c2.R)
        local dg = math.abs(c1.G - c2.G)
        local db = math.abs(c1.B - c2.B)
        return (dr + dg + db) < 0.04
    end

    local function remapColor(c)
        if not c then return c end
        for oldC, newC in pairs(colorMap) do
            if matchColor(c, oldC) then return newC end
        end
        return c
    end

    local guiNames = {
        "AutoStealUI", "XiAdminPanel", "SettingsUI",
        "YinStatusHUD", "YinNotif",
        "YinThemeUI", "PriorityListGUI", "YinJobJoiner", "YinPriorityAlert",
        "YinSettings"
    }

    for _, guiName in ipairs(guiNames) do
        local sg = PlayerGui:FindFirstChild(guiName)
        if sg then
            for _, obj in ipairs(sg:GetDescendants()) do
                pcall(function()
                    if obj:IsA("Frame") or obj:IsA("TextButton") or
                       obj:IsA("TextBox") or obj:IsA("ScrollingFrame") or
                       obj:IsA("ImageLabel") then
                        if obj.BackgroundTransparency < 1 then
                            obj.BackgroundColor3 = remapColor(obj.BackgroundColor3)
                        end
                    end
                    if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                        obj.TextColor3 = remapColor(obj.TextColor3)
                    end
                    if obj:IsA("UIStroke") then
                        obj.Color = remapColor(obj.Color)
                    end
                    if obj:IsA("ScrollingFrame") then
                        obj.ScrollBarImageColor3 = remapColor(obj.ScrollBarImageColor3)
                    end
                    if obj:IsA("UIGradient") then
                        local kps = obj.Color.Keypoints
                        local changed = false
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            local nc = remapColor(kp.Value)
                            if nc ~= kp.Value then changed = true end
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, nc))
                        end
                        if changed then
                            obj.Color = ColorSequence.new(newKps)
                        end
                    end
                    if obj:IsA("Beam") then
                        local kps = obj.Color.Keypoints
                        local newKps = {}
                        for _, kp in ipairs(kps) do
                            table.insert(newKps, ColorSequenceKeypoint.new(kp.Time, remapColor(kp.Value)))
                        end
                        obj.Color = ColorSequence.new(newKps)
                    end
                end)
            end
            pcall(function()
                local root = sg:FindFirstChildWhichIsA("Frame")
                if root and root.BackgroundTransparency < 1 then
                    root.BackgroundColor3 = remapColor(root.BackgroundColor3)
                end
            end)
        end
    end

    task.spawn(function()
        local savedTab  = (_G.YinSettingsUI and _G.YinSettingsUI.currentTab) or "cfg"
        local wasVis    = _G.YinSettingsUI and _G.YinSettingsUI.panel and _G.YinSettingsUI.panel.Visible
        if buildYinSettingsUI then
            buildYinSettingsUI()
        end
        task.wait()
        if _G.YinSettingsUI then
            if _G.YinSettingsUI.switchTab then
                _G.YinSettingsUI.switchTab(savedTab)
            end
            if wasVis and _G.YinSettingsUI.panel then
                _G.YinSettingsUI.panel.Visible = true
            end
        end
        if _G.rebuildStatusHUD then
            _G.rebuildStatusHUD()
        end
        if _G.updateAutoBuyRingColor then _G.updateAutoBuyRingColor() end
        if _G.rebuildAutoBuyCirclePresets then _G.rebuildAutoBuyCirclePresets() end
        if buildMiniActionsUI then
            local miniWasVis = _G.MiniActionsUI and _G.MiniActionsUI.panel and _G.MiniActionsUI.panel.Visible
            buildMiniActionsUI()
            task.wait()
            if miniWasVis and _G.MiniActionsUI and _G.MiniActionsUI.panel then
                _G.MiniActionsUI.panel.Visible = true
            end
        end

        local guisRT = {"AutoStealUI","XiAdminPanel","SettingsUI","YinSettings","YinStatusHUD","YinMiniActions"}
        for _, gn in ipairs(guisRT) do
            local sg = PlayerGui:FindFirstChild(gn)
            if sg then
                for _, obj in ipairs(sg:GetDescendants()) do
                    if obj.Name == "RacetrackBorder" and obj:IsA("UIStroke") then
                        local g2 = obj:FindFirstChildOfClass("UIGradient")
                        if g2 then
                            g2.Color = ColorSequence.new{
                                ColorSequenceKeypoint.new(0, Theme.Accent1),
                                ColorSequenceKeypoint.new(1, Theme.Accent2),
                            }
                            g2.Rotation = 0
                            obj.Color = Theme.Accent1
                        end
                    end
                end
            end
        end
    end)

    if _F.ShowNotification then
    _F.ShowNotification("TEMA", "Tema " .. themeName .. " aplicado!")
end
end

function addRacetrackBorder(parentFrame, speed)
    if not parentFrame or not parentFrame:IsA("Frame") then return end
    local CYAN_A = Color3.fromRGB(0, 220, 255)
    local CYAN_B = Color3.fromRGB(0, 160, 210)
    speed = tonumber(speed) or 2.8

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RacetrackBorder"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness  = 1.6
    stroke.Color      = Color3.new(1, 1, 1)
    stroke.Transparency = 0.14
    stroke.Parent = parentFrame

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, CYAN_A),
        ColorSequenceKeypoint.new(0.20, CYAN_B),
        ColorSequenceKeypoint.new(0.50, CYAN_A),
        ColorSequenceKeypoint.new(0.80, CYAN_B),
        ColorSequenceKeypoint.new(1.00, CYAN_A),
    }
    grad.Rotation = 0
    grad.Parent   = stroke

    local t0 = tick()
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parentFrame.Parent or not stroke.Parent or not grad.Parent then
            if conn then conn:Disconnect() end
            return
        end
        local t = tick() - t0
        local p = (t / speed) % 1
        grad.Rotation = (p * 360)
        stroke.Transparency = 0.12 + (math.sin(t * 4.2) + 1) * 0.5 * 0.16
    end)

    return stroke
end

local PRIORITY_LIST = {
   "Strawberry Elephant",
   "Meowl",
   "Skibidi Toilet",
   "Headless Horseman",
   "Dragon Gingerini",
   "Dragon Cannelloni",
   "Ketupat Bros",
   "Hydra Dragon Cannelloni",
   "La Supreme Combinasion",
   "Love Love Bear",
   "Ginger Gerat",
   "Cerberus",
   "Capitano Moby",
   "La Casa Boo",
   "Burguro and Fryuro",
   "Spooky and Pumpky",
   "Cooki and Milki",
   "Rosey and Teddy",
   "Popcuru and Fizzuru",
   "Reinito Sleighito",
   "Fragrama and Chocrama",
   "Garama and Madundung",
   "Ketchuru and Musturu",
   "La Secret Combinasion",
   "Tralaledon",
   "Tictac Sahur",
   "Ketupat Kepat",
   "Tang Tang Keletang",
   "Orcaledon",
   "La Ginger Sekolah",
   "Los Spaghettis",
   "Lavadorito Spinito",
   "Swaggy Bros",
   "La Taco Combinasion",
   "Los Primos",
   "Chillin Chili",
   "Tuff Toucan",
   "W or L",
   "Chipso and Queso"
}

do
    local saved = Config and Config.PriorityList
    if saved and type(saved) == "table" and #saved > 0 then
        PRIORITY_LIST = saved
    end
end

function _F.savePriorityToConfig()
    Config.PriorityList = {}
    for i, v in ipairs(PRIORITY_LIST) do Config.PriorityList[i] = v end
    _F.SaveConfig()
end

function _F.findAdorneeGlobal(animalData)
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



function _F.CreateGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Theme.Accent2),
        ColorSequenceKeypoint.new(1, Theme.Accent2)
    }
    g.Rotation = 45
    return g
end

function _F.MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        _F.SaveConfig()
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
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local DANGER_TOOLS = {
    ["Boogie Bomb"] = true,
    ["Medusa's Head"] = true,
    ["Body Swap Potion"] = true,
    ["Laser Cape"] = true,
    ["Rainbowrath Sword"] = true,
    ["Gummy Bear"] = true,
}
function _F.isMobileDevice()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end
local IS_MOBILE = _F.isMobileDevice()
function _F.ApplyViewportUIScaleAdmin(targetFrame, _, _, minScale, maxScale)
    if not targetFrame or not IS_MOBILE then return end
    local existing = targetFrame:FindFirstChildOfClass("UIScale")
    if existing then existing:Destroy() end
    local sc = Instance.new("UIScale")
    sc.Parent = targetFrame
    sc.Scale = math.clamp(0.65, minScale or 0.45, maxScale or 0.85)
end
function _F.AddMobileMinimizeAdmin(frame, labelText)
    if not IS_MOBILE or not frame then return end
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)
    local guiParent = frame.Parent
    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 10)
    _F.MakeDraggable(restoreBtn, restoreBtn)
    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)
    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

function _F.ShowNotification(title, text) end

function _F.isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

function _F.handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and _F.isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

function _F.stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and _F.isPlayerCharacter(model)

    if obj:IsA("Animator") then _F.handleAnimator(obj) end

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

local fpsBoostState = {
    enabled = false,
    original = nil,
    effectStates = {},
    atmosphereStates = {},
    descendantConn = nil,
}

local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    xrayEnabled = false,
    antiRagdollMode = Config.AntiRagdoll or 0,
    isTpMoving = false,
    manualTargetEnabled = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    _ijInputBegan = nil,
    _ijInputEnded = nil,
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

function _F.setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end

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
                    md.X * 200, 
                    hrp.AssemblyLinearVelocity.Y, 
                    md.Z * 200
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

function _F.correctPositionAfterTeleport()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local pos = hrp.Position
    local ray = Ray.new(pos, Vector3.new(0, -20, 0))
    local hit, groundPos = Workspace:FindPartOnRay(ray, char)

    if hit and groundPos then
        local dist = (pos - groundPos).Magnitude
        if dist < 2 then
            hrp.CFrame = CFrame.new(groundPos + Vector3.new(0, 3, 0))
        end
    end
    
    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
end

RunService.Heartbeat:Connect(function()
    if State.isTpMoving then
        _F.correctPositionAfterTeleport()
        State.isTpMoving = false
    end
end)

local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

function _F.setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    _F.SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    if Connections._ijInputBegan then Connections._ijInputBegan:Disconnect(); Connections._ijInputBegan = nil end
    if Connections._ijInputEnded then Connections._ijInputEnded:Disconnect(); Connections._ijInputEnded = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    local isSpaceHeld = false
    local inputBegan = UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.Space then isSpaceHeld = true end
    end)
    local inputEnded = UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Space then isSpaceHeld = false end
    end)
    Connections.infiniteJumpConnection = RunService.RenderStepped:Connect(function()
    infiniteJumpConnection = Connections.infiniteJumpConnection
        if not isSpaceHeld then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z)
    end)
    Connections._ijInputBegan = inputBegan
    Connections._ijInputEnded = inputEnded
end
if infiniteJumpEnabled then _F.setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

function _F.isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

function _F.enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and _F.isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
function _F.disableXray()
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
    _F.enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and _F.isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

function _F.isRagdolled()
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

function _F.stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end


function _F.startAntiRagdoll(mode)
    _F.stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        _F.stopAntiRagdollV2()
    end
    if mode == 0 then return end

    Connections.antiRagdollConn = RunService.Heartbeat:Connect(function()
    antiRagdollConn = Connections.antiRagdollConn
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if _F.isRagdolled() then
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
function _F.cleanRagdollV2(char)
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
function _F.cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then _F.cleanRagdollV2(char) end
    end)
end
function _F.isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end

function _F.hookAntiRagV2(char)
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
            _F.cleanRagdollV2(char)
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
        if _F.isRagdollRelatedDescendant(desc) then
            _F.cleanRagdollV2Debounced(char)
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
            _F.cleanRagdollV2(char)
            local vel = hrp.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                hrp.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, 15)
            end
        end
        lastVel = hrp.AssemblyLinearVelocity
    end)
    table.insert(antiRagdollConns, c4)

    _F.cleanRagdollV2(char)
end

function _F.stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end

function _F.startAntiRagdollV2(enabled)
    _F.stopAntiRagdoll()
    _F.stopAntiRagdollV2()
    if not enabled then
        return
    end

    local char = LocalPlayer.Character
    if char then task.spawn(function() _F.hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() _F.hookAntiRagV2(c) end)
    end)
end

if antiRagdollMode > 0 then _F.startAntiRagdoll(antiRagdollMode) end
Config.AntiRagdollV2 = true
_F.startAntiRagdollV2(true)
if Config.AntiRagdollV2 then _F.startAntiRagdollV2(true) end

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
    local Datas    = ReplicatedStorage:WaitForChild("Datas")
    local Shared   = ReplicatedStorage:WaitForChild("Shared")
    local Utils    = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer  = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData   = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils   = require(Utils:WaitForChild("NumberUtils"))

    local autoStealEnabled   = true
    
    
    if Config.DefaultToPriority and Config.DefaultToHighest then
        Config.DefaultToHighest = false
    end
    if Config.DefaultToPriority and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    if Config.DefaultToHighest and Config.DefaultToNearest then
        Config.DefaultToNearest = false
    end
    
    if not Config.DefaultToPriority and not Config.DefaultToHighest and not Config.DefaultToNearest and not Config.DefaultToDisable then
        Config.DefaultToHighest = true
    end
    
    local stealNearestEnabled = false
    local stealHighestEnabled = false
    local stealPriorityEnabled = false
    
    if Config.DefaultToNearest then
        stealNearestEnabled = true
        Config.StealNearest = true
        Config.StealHighest = false
        Config.StealPriority = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToHighest then
        stealHighestEnabled = true
        Config.StealHighest = true
        Config.StealNearest = false
        Config.StealPriority = false
        Config.AutoTPPriority = false
    elseif Config.DefaultToPriority then
        stealPriorityEnabled = true
        Config.StealPriority = true
        Config.StealNearest = false
        Config.StealHighest = false
        Config.AutoTPPriority = true
    elseif Config.DefaultToDisable then
        -- Disable mode: don't activate any steal mode on load
        stealNearestEnabled = false
        stealHighestEnabled = false
        stealPriorityEnabled = false
        Config.StealNearest = false
        Config.StealHighest = false
        Config.StealPriority = false
    else
        stealNearestEnabled = Config.StealNearest
        stealHighestEnabled = Config.StealHighest
        stealPriorityEnabled = Config.StealPriority
        
        if Config.InstantSteal == nil then Config.InstantSteal = false end
        if Config.StealPriority then
            Config.AutoTPPriority = true
        elseif Config.StealNearest then
            Config.AutoTPPriority = true
        elseif Config.StealHighest then
            Config.AutoTPPriority = false
        end
    end
    
    local instantStealEnabled = true
    local instantStealReady = false
    local instantStealDidInit = false
    local selectedTargetIndex = 1
    local selectedTargetUID   = nil 
    local allAnimalsCache    = {}
    local InternalStealCache = {}
    local PromptMemoryCache  = {}
    local activeProgressTween = nil
    local currentStealTargetUID = nil
    local petButtons         = {}
    local ShowPriorityAlert = function() end

    -- ── STEAL REMOTE RESOLVER ─────────────────────────────────────────────
    -- Resolved once and cached. Used in all steal paths for maximum speed.
    
    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot)
        if not plot then return false end
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

    -- With inline controls hidden, keep auto-steal active by default.
    if Config.DefaultToDisable then
        Config.DefaultToDisable = false
        _F.SaveConfig()
    end

    -- Safety: if all modes are OFF, fall back to Highest.
    if not stealNearestEnabled and not stealHighestEnabled and not stealPriorityEnabled then
        stealHighestEnabled = true
        Config.StealNearest = false
        Config.StealHighest = true
        Config.StealPriority = false
        _F.SaveConfig()
    end

    local function get_all_pets()
        local out = {}
        for _, a in ipairs(allAnimalsCache) do
            if a.genValue >= 1 and not isMyBaseAnimal(a) then
                table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                    owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a, source="CARPET"})
            end
        end
        -- also include conveyor brainrots
        -- (REMOVED: conveyor detection disabled)
        return out
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoStealUI"; screenGui.ResetOnSpawn = false; screenGui.Parent = PlayerGui

    local C_BG         = Color3.fromRGB(18, 20, 26)
    local C_HEADER_BG  = Color3.fromRGB(26, 29, 38)
    local C_ACCENT_AS  = Color3.fromRGB(0, 220, 255)
    local C_BORDER_AS  = Color3.fromRGB(0, 180, 230)
    local C_TEXTSEC_AS = Color3.fromRGB(130, 200, 230)

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 315, 0, 390)
    frame.Position = UDim2.new(Config.Positions.AutoSteal.X, 0, Config.Positions.AutoSteal.Y, 0)
    frame.BackgroundColor3 = C_BG; frame.BackgroundTransparency = 0
    frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Parent = screenGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local frameStroke = Instance.new("UIStroke", frame)
    frameStroke.Color = C_BORDER_AS; frameStroke.Thickness = 1; frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    task.defer(function() applyIceToPanel(frame, 8, 7) end)

    -- Header background (52 px)
    local headerBg = Instance.new("Frame", frame)
    headerBg.Size = UDim2.new(1, 0, 0, 38)
    headerBg.Position = UDim2.new(0, 0, 0, 0)
    headerBg.BackgroundColor3 = C_HEADER_BG; headerBg.BorderSizePixel = 0
    -- top corners only via corner + clip fix
    local hbCorner = Instance.new("UICorner", headerBg); hbCorner.CornerRadius = UDim.new(0, 12)
    local hbFix = Instance.new("Frame", headerBg)
    hbFix.Size = UDim2.new(1,0,0,10); hbFix.Position = UDim2.new(0,0,1,-10)
    hbFix.BackgroundColor3 = C_HEADER_BG; hbFix.BorderSizePixel = 0

    -- Separator line below header
    local headerDiv = Instance.new("Frame", frame)
    headerDiv.Size = UDim2.new(1,-24,0,1); headerDiv.Position = UDim2.new(0,12,0,38)
    headerDiv.BackgroundColor3 = C_BORDER_AS; headerDiv.BorderSizePixel = 0



    -- Subtitle
    local subLabel = Instance.new("TextLabel", headerBg)
    subLabel.Size = UDim2.new(1,-28,0,14); subLabel.Position = UDim2.new(0,14,0.5,-7)
    subLabel.BackgroundTransparency = 1; subLabel.Text = "Steal Target"
    subLabel.Font = Enum.Font.GothamBold; subLabel.TextSize = 10
    subLabel.TextColor3 = C_TEXTSEC_AS; subLabel.TextXAlignment = Enum.TextXAlignment.Left


    -- Draggable header region
    local header = Instance.new("Frame", headerBg)
    header.Size = UDim2.new(1,0,1,0); header.BackgroundTransparency = 1; header.ZIndex = 10
    _F.MakeDraggable(header, frame, "AutoSteal")

    local ITEM_H, ITEM_PAD, VISIBLE_ROWS = 29, 4, 10
    local LIST_H = ITEM_H * VISIBLE_ROWS + ITEM_PAD * (VISIBLE_ROWS - 1)
    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1,-10,1,-46); listFrame.Position = UDim2.new(0,5,0,44)
    listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ScrollBarThickness = 0
    listFrame.ScrollBarImageColor3 = Theme.Accent1
    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0,ITEM_PAD); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Progress visual is optional (UI removed from panel).
    local progressBarFill = nil

    local function resetProgressVisual()
        if progressBarFill then
            progressBarFill.Size = UDim2.new(0, 0, 1, 0)
            progressBarFill.BackgroundTransparency = 0
        end
    end

    local function setProgressVisualFull()
        if progressBarFill then
            progressBarFill.Size = UDim2.new(1, 0, 1, 0)
            progressBarFill.BackgroundTransparency = 0
        end
    end

    local function runProgressTimer()
        if progressBarFill then
            activeProgressTween = TweenService:Create(
                progressBarFill,
                TweenInfo.new(STEAL_DURATION, Enum.EasingStyle.Linear),
                {Size = UDim2.new(1, 0, 1, 0)}
            )
            activeProgressTween:Play()
            activeProgressTween.Completed:Wait()
        else
            task.wait(STEAL_DURATION)
        end
    end

    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1,-30,0,144); toggleBtnContainer.Position = UDim2.new(0,15,1,-154)
    toggleBtnContainer.BackgroundTransparency = 1
    toggleBtnContainer.Visible = false
    
    local enableBtn = Instance.new("TextButton", toggleBtnContainer)
    local uiScale = 1
    enableBtn.Size = UDim2.new(1,0,0,32*uiScale); enableBtn.BackgroundColor3 = Theme.Success
    enableBtn.Text = "ENABLED"; enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 13*uiScale; enableBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", enableBtn).CornerRadius = UDim.new(0, 8)
    
    local nearestBtn = Instance.new("TextButton", toggleBtnContainer)
    nearestBtn.Size = UDim2.new(0.48,0,0,28*uiScale); nearestBtn.Position = UDim2.new(0,0,0,36*uiScale)
    nearestBtn.BackgroundColor3 = Theme.SurfaceHighlight
    nearestBtn.Text = "NEAREST"; nearestBtn.Font = Enum.Font.GothamBold
    nearestBtn.TextSize = 11*uiScale; nearestBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 6)

    local highestBtn = Instance.new("TextButton", toggleBtnContainer)
    highestBtn.Size = UDim2.new(0.48,0,0,28*uiScale); highestBtn.Position = UDim2.new(0.52,0,0,36*uiScale)
    highestBtn.BackgroundColor3 = Theme.SurfaceHighlight
    highestBtn.Text = "HIGHEST"; highestBtn.Font = Enum.Font.GothamBold
    highestBtn.TextSize = 11*uiScale; highestBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", highestBtn).CornerRadius = UDim.new(0, 6)

    local priorityBtn = Instance.new("TextButton", toggleBtnContainer)
    priorityBtn.Size = UDim2.new(1,0,0,24*uiScale); priorityBtn.Position = UDim2.new(0,0,0,68*uiScale)
    priorityBtn.BackgroundColor3 = Theme.SurfaceHighlight
    priorityBtn.Text = "PRIORITY"; priorityBtn.Font = Enum.Font.GothamBold
    priorityBtn.TextSize = 11*uiScale; priorityBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", priorityBtn).CornerRadius = UDim.new(0, 6)

    local function attachPet3DPreview(parentBtn, petData, layoutOpts)
        layoutOpts = layoutOpts or {}
        local holder = Instance.new("Frame", parentBtn)
        holder.Size = layoutOpts.Size or UDim2.new(0, 20, 0, 20)
        holder.Position = layoutOpts.Position or UDim2.new(0, 34, 0.5, -10)
        holder.BackgroundColor3 = Theme.SurfaceHighlight
        holder.BackgroundTransparency = 0.05
        holder.BorderSizePixel = 0
        Instance.new("UICorner", holder).CornerRadius = UDim.new(0, layoutOpts.CornerRadius or 5)
        local hs = Instance.new("UIStroke", holder)
        hs.Color = Theme.Accent1
        hs.Thickness = 1
        hs.Transparency = 0.45

        local vp = Instance.new("ViewportFrame", holder)
        vp.Size = UDim2.new(1, 0, 1, 0)
        vp.Position = UDim2.new(0, 0, 0, 0)
        vp.BackgroundTransparency = 1
        vp.BorderSizePixel = 0
        vp.Ambient = Color3.fromRGB(245, 245, 245)
        vp.LightColor = Color3.new(1, 1, 1)
        vp.LightDirection = Vector3.new(-0.45, -0.9, -0.35)
        vp.ImageTransparency = 0

        local failLbl = Instance.new("TextLabel", holder)
        failLbl.Size = UDim2.new(1, 0, 1, 0)
        failLbl.BackgroundTransparency = 1
        failLbl.Text = "3D"
        failLbl.Font = Enum.Font.GothamBlack
        failLbl.TextSize = 9
        failLbl.TextColor3 = Theme.TextSecondary
        failLbl.Visible = true

        local ad = petData and petData.animalData
        local srcModel, srcPart = nil, nil
        local petNameNorm = (petData and petData.petName and tostring(petData.petName):lower()) or ""
        local slotNorm = ad and ad.slot and tostring(ad.slot) or ""
        local forceLiveModelOnly = (petData and petData.ForceLiveModelOnly == true) or (layoutOpts and layoutOpts.ForceLiveModelOnly == true)
        local preferFallbackModelOnly = (petData and petData.ForceFallbackModel == true) or (layoutOpts and layoutOpts.ForceFallbackModel == true)
        local forceEmbeddedAnimation = (petData and petData.ForceEmbeddedAnimation == true) or (layoutOpts and layoutOpts.ForceEmbeddedAnimation == true)

        local function getAnimatorFrom(obj)
            if not obj then return nil end
            local hum = obj:FindFirstChildOfClass("Humanoid")
            if hum then
                return hum:FindFirstChildOfClass("Animator") or hum:FindFirstChildWhichIsA("Animator", true)
            end
            local ac = obj:FindFirstChildOfClass("AnimationController")
            if ac then
                return ac:FindFirstChildOfClass("Animator") or ac:FindFirstChildWhichIsA("Animator", true)
            end
            return obj:FindFirstChildWhichIsA("Animator", true)
        end
        local function ensureAnimatorForPreviewModel(model)
            if not model or not model:IsA("Model") then return nil end
            local animator = getAnimatorFrom(model)
            if animator then return animator end
            local ac = model:FindFirstChildOfClass("AnimationController")
            if not ac then
                ac = Instance.new("AnimationController")
                ac.Name = "PreviewAnimationController"
                ac.Parent = model
            end
            animator = ac:FindFirstChildOfClass("Animator")
            if not animator then
                animator = Instance.new("Animator")
                animator.Parent = ac
            end
            return animator
        end

        local function playEmbeddedPreviewAnimations(model)
            local animator = getAnimatorFrom(model)
            -- Se não tiver animator, tenta criar via ensureAnimatorForPreviewModel
            if not animator then animator = ensureAnimatorForPreviewModel(model) end
            if not animator then return false end
            local any = false
            -- Coleta animações únicas (evita duplicatas)
            local seen = {}
            for _, d in ipairs(model:GetDescendants()) do
                if d:IsA("Animation") and d.AnimationId ~= "" and not seen[d.AnimationId] then
                    seen[d.AnimationId] = true
                    local okLoad, track = pcall(function() return animator:LoadAnimation(d) end)
                    if okLoad and track then
                        pcall(function() track.Looped = true end)
                        pcall(function() track:Play(0.15, 1, 1) end)
                        any = true
                    end
                end
            end
            return any
        end

        local function buildPetPreviewCacheKey()
            if petData and type(petData.previewCacheKey) == "string" and petData.previewCacheKey ~= "" then
                return petData.previewCacheKey
            end
            if petData and type(petData.uid) == "string" and petData.uid ~= "" then
                return petData.uid
            end
            if ad and ad.plot and ad.slot then
                return tostring(ad.plot) .. "|" .. tostring(ad.slot)
            end
            if petNameNorm ~= "" then
                return petNameNorm
            end
            return ""
        end
        local cacheKey = buildPetPreviewCacheKey()

        local function getAnimalsTemplateFolder()
            local root = ReplicatedStorage:FindFirstChild("Models")
            return root and root:FindFirstChild("Animals")
        end
        local function findAnimalModelInFolder(folder, nameKey)
            if not folder or not nameKey or nameKey == "" then return nil end
            local key = tostring(nameKey)
            local inst = folder:FindFirstChild(key)
            if inst and inst:IsA("Model") then return inst end
            local kl = key:lower()
            for _, ch in ipairs(folder:GetChildren()) do
                if ch:IsA("Model") and ch.Name:lower() == kl then
                    return ch
                end
            end
            return nil
        end
        local function resolveTemplateModelFromStorage()
            local folder = getAnimalsTemplateFolder()
            if not folder then return nil end
            local order = {}
            local function push(v)
                if v == nil or v == "" then return end
                local s = tostring(v)
                for _, ex in ipairs(order) do
                    if ex == s then return end
                end
                table.insert(order, s)
            end
            if ad then
                push(ad.Index)
                push(ad.index)
            end
            if petData and petData.petName then
                push(petData.petName)
                -- Tenta normalizar DisplayName → chave do RS (remove espaços)
                local norm = tostring(petData.petName):gsub("%s+", "")
                push(norm)
            end
            for _, key in ipairs(order) do
                local m = findAnimalModelInFolder(folder, key)
                if m then return m end
            end
            -- Busca fuzzy: procura modelo cujo nome contém o petName
            if petData and petData.petName and petData.petName ~= "" then
                local pnl = tostring(petData.petName):lower():gsub("%s+", "")
                for _, ch in ipairs(folder:GetChildren()) do
                    if ch:IsA("Model") then
                        local nl = ch.Name:lower()
                        if nl == pnl or nl:find(pnl, 1, true) or pnl:find(nl, 1, true) then
                            return ch
                        end
                    end
                end
            end
            return nil
        end
        local function findModelByPetNameInPlot(plot, animalData, petNameLower)
            if not plot then return nil end
            local wanted = {}
            local function addWanted(v)
                if v == nil or v == "" then return end
                wanted[tostring(v):lower()] = true
            end
            if animalData then
                addWanted(animalData.Index)
                addWanted(animalData.index)
            end
            addWanted(petNameLower)

            local exact = nil
            for _, d in ipairs(plot:GetDescendants()) do
                if d:IsA("Model") and d ~= plot and d.Name ~= "Base" then
                    local nl = d.Name:lower()
                    if wanted[nl] then
                        exact = d
                        break
                    end
                end
            end
            return exact
        end

        local templateModel = resolveTemplateModelFromStorage()

        local previewObj = nil
        local previewFromCache = false
        local previewFromLiveModel = false
        if not forceLiveModelOnly then
            if templateModel and templateModel.Archivable then
                local ok, cloned = pcall(function() return templateModel:Clone() end)
                if ok then previewObj = cloned end
            end
            if not previewObj and cacheKey ~= "" then
                local tmpl = SharedState.PetPreviewModelCache[cacheKey]
                if tmpl and tmpl.Parent == nil and tmpl.Archivable then
                    local ok, cloned = pcall(function() return tmpl:Clone() end)
                    if ok and cloned then
                        previewObj = cloned
                        previewFromCache = true
                    end
                end
            end
        end

        do
            local plot = ad and ad.plot and Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(ad.plot)
            local podiums = plot and plot:FindFirstChild("AnimalPodiums")
            local podium = podiums and ad.slot and podiums:FindFirstChild(tostring(ad.slot))
            if plot then
                srcModel = findModelByPetNameInPlot(plot, ad, petNameNorm)
                local base = podium and podium:FindFirstChild("Base")
                local spawnPart = base and (base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("BasePart"))

                if not srcModel then
                    if forceLiveModelOnly then
                        local targetPart = _F.findAdorneeGlobal(ad)
                        if targetPart and targetPart:IsA("BasePart") then
                            srcPart = targetPart
                        elseif spawnPart then
                            srcPart = spawnPart
                        end
                    else

                        local bestModel, bestScore = nil, -math.huge
                        for _, d in ipairs(plot:GetDescendants()) do
                            if d:IsA("Model") and d ~= plot and d.Name ~= "Base" then
                                local pp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                                if pp then
                                    local nameL = d.Name:lower()
                                    local score = 0
                                    if petNameNorm ~= "" and (nameL:find(petNameNorm, 1, true) or petNameNorm:find(nameL, 1, true)) then
                                        score = score + 200
                                    end
                                    if slotNorm ~= "" and nameL:find(slotNorm, 1, true) then
                                        score = score + 100
                                    end
                                    if nameL:find("podium", 1, true) or nameL:find("base", 1, true) then
                                        score = score - 120
                                    end
                                    if spawnPart then
                                        local dist = (pp.Position - spawnPart.Position).Magnitude
                                        score = score - dist
                                    end
                                    if score > bestScore then
                                        bestScore = score
                                        bestModel = d
                                    end
                                end
                            end
                        end

                        srcModel = bestModel
                        if not srcModel and spawnPart then
                            srcPart = spawnPart
                        end
                    end
                end
            end
        end

        if (not srcModel) and (not forceLiveModelOnly) and petNameNorm ~= "" then
            local plots = Workspace:FindFirstChild("Plots")
            if plots then
                local bestModel, bestScore = nil, -math.huge
                for _, plot in ipairs(plots:GetChildren()) do
                    for _, d in ipairs(plot:GetDescendants()) do
                        if d:IsA("Model") and d ~= plot and d.Name ~= "Base" then
                            local pp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                            if pp then
                                local nameL = d.Name:lower()
                                if nameL:find("podium", 1, true) or nameL:find("base", 1, true) or nameL:find("plotsign", 1, true) then
                                    continue
                                end
                                local score = 0
                                if nameL == petNameNorm then
                                    score = score + 320
                                elseif nameL:find(petNameNorm, 1, true) or petNameNorm:find(nameL, 1, true) then
                                    score = score + 220
                                end
                                if slotNorm ~= "" and nameL:find(slotNorm, 1, true) then
                                    score = score + 60
                                end
                                if score > bestScore then
                                    bestScore = score
                                    bestModel = d
                                end
                            end
                        end
                    end
                end
                if bestModel then
                    srcModel = bestModel
                end
            end
        end

        -- srcModel é apenas o driver de animação (não substitui previewObj)
        -- Se não tiver templateModel (RS), usa live model como fallback visual
        if not previewObj then
            if srcModel and srcModel.Archivable then
                local ok, clonedLive = pcall(function() return srcModel:Clone() end)
                if ok and clonedLive then
                    previewObj = clonedLive
                    previewFromCache = false
                    previewFromLiveModel = true
                end
            elseif srcPart and srcPart.Archivable then
                local ok, clonedPart = pcall(function() return srcPart:Clone() end)
                if ok and clonedPart then
                    previewObj = clonedPart
                    previewFromCache = false
                end
            end
        end

        if not previewObj then return holder end

        failLbl.Visible = false

        -- WorldModel é necessário para AnimationController + Bone funcionarem no ViewportFrame
        local worldModel = Instance.new("WorldModel", vp)
        previewObj.Parent = worldModel

        for _, d in ipairs(previewObj:GetDescendants()) do
            if d:IsA("BasePart") then
                d.Massless = true
                d.CanCollide = false
                -- Para RS template: partes desancoradas para o WorldModel mover via animação
                -- Para live model como visual: ancoramos e copiamos CFrame
                if previewFromLiveModel then
                    d.Anchored = true
                else
                    d.Anchored = false
                end
            end
        end

        -- Posicionar o modelo no origin do WorldModel para a câmera enquadrar corretamente
        if not previewFromLiveModel and previewObj:IsA("Model") then
            pcall(function()
                local cf, sz = previewObj:GetBoundingBox()
                if cf then
                    local offset = cf.Position
                    previewObj:PivotTo(CFrame.new(-offset.X, -offset.Y, -offset.Z) * cf.Rotation)
                end
            end)
        end

        -- Detectar tipo de rig
        local hasAnimController = previewObj:IsA("Model") and previewObj:FindFirstChildOfClass("AnimationController") ~= nil
        local hasMotor6D = false
        if previewObj:IsA("Model") then
            for _, d in ipairs(previewObj:GetDescendants()) do
                if d:IsA("Motor6D") then hasMotor6D = true; break end
            end
        end
        local isBoneBased = hasAnimController and not hasMotor6D

        -- Busca animador vivo em qualquer plot pelo petName (para pegar IDs das tracks)
        local function findLiveAnimatorByName()
            local plots = Workspace:FindFirstChild("Plots")
            if not plots or petNameNorm == "" then return nil end
            for _, plot in ipairs(plots:GetChildren()) do
                for _, d in ipairs(plot:GetDescendants()) do
                    if d:IsA("Model") then
                        local nl = d.Name:lower()
                        if nl == petNameNorm
                            or nl:find(petNameNorm, 1, true)
                            or (petNameNorm ~= "" and petNameNorm:find(nl, 1, true)) then
                            local a = getAnimatorFrom(d)
                            if a and #a:GetPlayingAnimationTracks() > 0 then
                                return a
                            end
                        end
                    end
                end
            end
            return nil
        end

        local embeddedAnimPlaying = false
        if previewObj:IsA("Model") then
            if forceEmbeddedAnimation then
                embeddedAnimPlaying = playEmbeddedPreviewAnimations(previewObj)
            elseif isBoneBased then
                -- Bone-based: RS template não tem Animation objects embutidos.
                -- Busca o animador vivo e usa os IDs das tracks dele.
                local liveAnim = (srcModel and getAnimatorFrom(srcModel)) or findLiveAnimatorByName()
                if liveAnim then
                    local dstAnim = ensureAnimatorForPreviewModel(previewObj) or getAnimatorFrom(previewObj)
                    if dstAnim then
                        local dstTracksById = {}
                        -- Carregar imediatamente as tracks que estão tocando
                        task.defer(function()
                            if not holder.Parent then return end
                            local srcTracks = liveAnim:GetPlayingAnimationTracks()
                            for _, st in ipairs(srcTracks) do
                                local anim = st.Animation
                                local animId = anim and anim.AnimationId
                                if animId and animId ~= "" and not dstTracksById[animId] then
                                    local okL, track = pcall(function() return dstAnim:LoadAnimation(anim) end)
                                    if okL and track then
                                        dstTracksById[animId] = track
                                        pcall(function() track.Looped = true; track:Play(0, 1, 1) end)
                                    end
                                end
                            end
                        end)
                        -- Manter sincronizado quando tracks mudam
                        animSyncConn = RunService.Heartbeat:Connect(function()
                            if not holder.Parent then
                                if animSyncConn then animSyncConn:Disconnect() end
                                return
                            end
                            local srcTracks = liveAnim:GetPlayingAnimationTracks()
                            local activeIds = {}
                            for _, st in ipairs(srcTracks) do
                                local anim = st.Animation
                                local animId = anim and anim.AnimationId
                                if animId and animId ~= "" then
                                    activeIds[animId] = true
                                    if not dstTracksById[animId] then
                                        local okL, track = pcall(function() return dstAnim:LoadAnimation(anim) end)
                                        if okL and track then
                                            dstTracksById[animId] = track
                                            pcall(function() track.Looped = true; track:Play(0, 1, 1) end)
                                        end
                                    end
                                end
                            end
                            for animId, track in pairs(dstTracksById) do
                                if not activeIds[animId] then
                                    pcall(function() track:Stop(0.2) end)
                                    dstTracksById[animId] = nil
                                end
                            end
                            refreshPreviewCamera()
                        end)
                        embeddedAnimPlaying = true
                    end
                else
                    -- Sem live model: tenta embedded como último recurso
                    embeddedAnimPlaying = playEmbeddedPreviewAnimations(previewObj)
                end
            elseif not srcModel then
                embeddedAnimPlaying = playEmbeddedPreviewAnimations(previewObj)
            end
        end

        if not previewFromCache and cacheKey ~= "" and previewObj:IsA("Model") and previewObj.Archivable then
            pcall(function()
                local old = SharedState.PetPreviewModelCache[cacheKey]
                local tmpl = previewObj:Clone()
                tmpl.Parent = nil
                SharedState.PetPreviewModelCache[cacheKey] = tmpl
                if old and old ~= tmpl and old.Parent == nil then
                    pcall(function() old:Destroy() end)
                end
            end)
        end

        local function relPath(obj, root)
            local parts = {}
            local cur = obj
            while cur and cur ~= root do
                table.insert(parts, 1, cur.Name)
                cur = cur.Parent
            end
            return table.concat(parts, "/")
        end

        local syncConn = nil
        local animSyncConn = nil
        local cam = nil
        local function refreshPreviewCamera()
            if not cam or not previewObj or not previewObj.Parent then return end
            local center, size
            if previewObj:IsA("Model") then
                local ok, cf, sz = pcall(function() return previewObj:GetBoundingBox() end)
                if ok then
                    center = cf.Position
                    size = sz
                else
                    local okPivot, piv = pcall(function() return previewObj:GetPivot() end)
                    local okSize, ext = pcall(function() return previewObj:GetExtentsSize() end)
                    if okPivot then center = piv.Position end
                    if okSize then size = ext end
                end
            elseif previewObj:IsA("BasePart") then
                center = previewObj.Position
                size = previewObj.Size
            end
            if not center or not size then return end
            local maxDim = math.max(size.X, size.Y, size.Z)
            local halfFov = math.rad(cam.FieldOfView * 0.5)
            local fitDist = (maxDim * 0.62) / math.tan(halfFov)
            local dist = math.max(fitDist, maxDim * 1.15)
            local lookAt = center
            local camPos = lookAt + Vector3.new(dist * 0.58, maxDim * 0.08, dist * 0.58)
            cam.CFrame = CFrame.new(camPos, lookAt)
        end

        if srcModel and previewObj:IsA("Model") then
            local srcPartMap, srcBoneMap, srcMotorMap = {}, {}, {}
            local srcPartByName, srcBoneByName, srcMotorByName = {}, {}, {}
            for _, d in ipairs(srcModel:GetDescendants()) do
                if d:IsA("BasePart") then
                    srcPartMap[relPath(d, srcModel)] = d
                    srcPartByName[d.Name] = srcPartByName[d.Name] or d
                elseif d:IsA("Bone") then
                    srcBoneMap[relPath(d, srcModel)] = d
                    srcBoneByName[d.Name] = srcBoneByName[d.Name] or d
                elseif d:IsA("Motor6D") then
                    srcMotorMap[relPath(d, srcModel)] = d
                    srcMotorByName[d.Name] = srcMotorByName[d.Name] or d
                end
            end

            local partPairs, bonePairs, motorPairs = {}, {}, {}
            for _, d in ipairs(previewObj:GetDescendants()) do
                if d:IsA("BasePart") then
                    local src = srcPartMap[relPath(d, previewObj)] or srcPartByName[d.Name]
                    if src then
                        table.insert(partPairs, {src = src, dst = d})
                    end
                elseif d:IsA("Bone") then
                    local src = srcBoneMap[relPath(d, previewObj)] or srcBoneByName[d.Name]
                    if src then
                        table.insert(bonePairs, {src = src, dst = d})
                    end
                elseif d:IsA("Motor6D") then
                    local src = srcMotorMap[relPath(d, previewObj)] or srcMotorByName[d.Name]
                    if src then
                        table.insert(motorPairs, {src = src, dst = d})
                    end
                end
            end

            if not preferFallbackModelOnly then
                syncConn = RunService.RenderStepped:Connect(function()
                    if not holder.Parent or not srcModel.Parent then
                        if syncConn then syncConn:Disconnect() end
                        return
                    end
                    -- Quando usando RS template (previewFromLiveModel=false),
                    -- NÃO copiar CFrame mundial (jogaria as partes para as coords do jogo).
                    -- Apenas Motor6D.Transform e Bone.Transform (rotações relativas).
                    if previewFromLiveModel then
                        for _, p in ipairs(partPairs) do
                            if p.src.Parent and p.dst.Parent then
                                p.dst.CFrame = p.src.CFrame
                            end
                        end
                    end
                    for _, b in ipairs(bonePairs) do
                        if b.src.Parent and b.dst.Parent then
                            b.dst.Transform = b.src.Transform
                        end
                    end
                    for _, m in ipairs(motorPairs) do
                        if m.src.Parent and m.dst.Parent then
                            m.dst.Transform = m.src.Transform
                            -- C0/C1 só quando live model é o visual (mesmo rig)
                            if previewFromLiveModel then
                                m.dst.C0 = m.src.C0
                                m.dst.C1 = m.src.C1
                            end
                        end
                    end
                    refreshPreviewCamera()
                end)
            end

            local srcAnimator = getAnimatorFrom(srcModel)
            local dstAnimator = ensureAnimatorForPreviewModel(previewObj) or getAnimatorFrom(previewObj)
            -- Não sobrescrever animSyncConn já definido para bone-based
            if srcAnimator and dstAnimator and not animSyncConn then
                local dstTracksById = {}
                animSyncConn = RunService.Heartbeat:Connect(function()
                    if not holder.Parent or not srcAnimator.Parent or not dstAnimator.Parent then
                        if animSyncConn then animSyncConn:Disconnect() end
                        return
                    end

                    local srcTracks = srcAnimator:GetPlayingAnimationTracks()
                    local activeIds = {}
                    for _, st in ipairs(srcTracks) do
                        local anim = st.Animation
                        local animId = anim and anim.AnimationId
                        if animId and animId ~= "" then
                            activeIds[animId] = true
                            local dt = dstTracksById[animId]
                            if (not dt) or (not dt.IsPlaying) then
                                local okLoad, loaded = pcall(function() return dstAnimator:LoadAnimation(anim) end)
                                if okLoad and loaded then
                                    dstTracksById[animId] = loaded
                                    dt = loaded
                                    pcall(function() dt:Play(0.1, st.WeightCurrent, math.max(st.Speed, 0.01)) end)
                                end
                            end
                            if dt then
                                pcall(function()
                                    dt:AdjustSpeed(math.max(st.Speed, 0.01))
                                    dt.TimePosition = st.TimePosition
                                end)
                            end
                        end
                    end

                    for animId, dt in pairs(dstTracksById) do
                        if not activeIds[animId] then
                            pcall(function() dt:Stop(0.1) end)
                            dstTracksById[animId] = nil
                        end
                    end
                    refreshPreviewCamera()
                end)
            end
        elseif embeddedAnimPlaying and not animSyncConn then
            animSyncConn = RunService.RenderStepped:Connect(function()
                if not holder.Parent or not previewObj.Parent then
                    if animSyncConn then animSyncConn:Disconnect() end
                    return
                end
                refreshPreviewCamera()
            end)
        elseif srcPart and previewObj:IsA("BasePart") then
            syncConn = RunService.RenderStepped:Connect(function()
                if not holder.Parent or not srcPart.Parent or not previewObj.Parent then
                    if syncConn then syncConn:Disconnect() end
                    return
                end
                previewObj.CFrame = srcPart.CFrame
                refreshPreviewCamera()
            end)
        end
        holder.Destroying:Connect(function()
            if syncConn then syncConn:Disconnect() end
            if animSyncConn then animSyncConn:Disconnect() end
        end)

        cam = Instance.new("Camera")
        cam.Parent = vp
        vp.CurrentCamera = cam
        cam.FieldOfView = layoutOpts.Fov or 28

        refreshPreviewCamera()
        return holder
    end

    _G.XiAttachPet3DPreview = attachPet3DPreview

    local function updateUI(enabled, allPets)
        autoStealEnabled = true
        instantStealEnabled = true -- Force always ON (lefa9)
        enableBtn.Text = "ENABLED"
        enableBtn.BackgroundColor3 = Theme.Success

        listFrame.ScrollBarThickness = 0
        listFrame.ScrollingEnabled = true

        -- Keep list in sync when target pool changes without explicit redraw flag.
        if allPets then
            local needsSync = (#petButtons ~= #allPets)
            if not needsSync then
                for i = 1, #allPets do
                    local pb = petButtons[i]
                    local currentUid = pb and pb.uid
                    if currentUid ~= allPets[i].uid then
                        needsSync = true
                        break
                    end
                end
            end
            if needsSync then
                SharedState.ListNeedsRedraw = true
            end
        end
        
        nearestBtn.BackgroundColor3 = stealNearestEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        nearestBtn.TextColor3 = stealNearestEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        highestBtn.BackgroundColor3 = stealHighestEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        highestBtn.TextColor3 = stealHighestEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        priorityBtn.BackgroundColor3 = stealPriorityEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        priorityBtn.TextColor3 = stealPriorityEnabled and Color3.new(0,0,0) or Theme.TextPrimary

        if instantStealBtn then
            instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
            instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
            instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        end

        if selectedTargetUID and allPets then
            local found = false
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then
                    selectedTargetIndex = i
                    found = true
                    break
                end
            end
        end

        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            petButtons = {}
            if allPets and #allPets > 0 then
                for i = 1, #allPets do
                    local petData = allPets[i]
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1,0,0,31); btn.BackgroundTransparency = 1
                    btn.Text = ""; btn.Parent = listFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

                    local cardBg = Instance.new("Frame", btn)
                    cardBg.Size = UDim2.new(1, -2, 1, -2)
                    cardBg.Position = UDim2.new(0, 1, 0, 1)
                    cardBg.BackgroundColor3 = Theme.Surface
                    cardBg.BackgroundTransparency = 0.04
                    cardBg.BorderSizePixel = 0
                    cardBg.ZIndex = 1
                    Instance.new("UICorner", cardBg).CornerRadius = UDim.new(0, 6)

                    local bStroke = Instance.new("UIStroke", cardBg)
                    bStroke.Color = Color3.fromRGB(0, 220, 255); bStroke.Thickness = 1; bStroke.Transparency = 0.55

                    local rankChip = Instance.new("Frame", btn)
                    rankChip.Size = UDim2.new(0,18,0,18); rankChip.Position = UDim2.new(0,10,0.5,-9)
                    rankChip.BackgroundColor3 = Color3.fromRGB(70, 160, 230)
                    rankChip.BorderSizePixel = 0
                    Instance.new("UICorner", rankChip).CornerRadius = UDim.new(0, 5)
                    local rankLabel = Instance.new("TextLabel", rankChip)
                    rankLabel.Size = UDim2.new(1,0,1,0)
                    rankLabel.BackgroundTransparency = 1; rankLabel.Text = tostring(i)
                    rankLabel.Font = Enum.Font.GothamBlack; rankLabel.TextSize = 9
                    attachPet3DPreview(btn, petData, {
                        ForceLiveModelOnly = true,
                        ForceFallbackModel = false,
                        ForceEmbeddedAnimation = true,
                    })
                    local infoLabel = Instance.new("TextLabel", btn)
                    infoLabel.Size = UDim2.new(1,-124,1,0); infoLabel.Position = UDim2.new(0,58,0,0)
                    infoLabel.BackgroundTransparency = 1; infoLabel.RichText = true
                    infoLabel.Text = formatMutationText(petData.mutation).."<font weight='700'>"..(petData.petName or "No target").."</font>"
                    infoLabel.Font = Enum.Font.GothamBold; infoLabel.TextSize = 11
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    local mpsLabel = Instance.new("TextLabel", btn)
                    mpsLabel.Size = UDim2.new(0,66,1,0); mpsLabel.Position = UDim2.new(1,-72,0,0)
                    mpsLabel.BackgroundTransparency = 1
                    mpsLabel.Text = petData.mpsText or "$0/s"
                    mpsLabel.Font = Enum.Font.GothamBold
                    mpsLabel.TextSize = 10
                    mpsLabel.TextColor3 = Theme.Accent1
                    mpsLabel.TextXAlignment = Enum.TextXAlignment.Right
                    petButtons[i] = {button=btn, card=cardBg, stroke=bStroke, rank=rankLabel, rankBg=rankChip, info=infoLabel, mps=mpsLabel, uid=petData.uid}

                    local function onSelectTarget()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid
                        State.manualTargetEnabled = true
                        SharedState.ListNeedsRedraw = false
                        updateUI(autoStealEnabled, get_all_pets())
                    end

                    local hit = Instance.new("TextButton", btn)
                    hit.Name = "HitArea"
                    hit.Size = UDim2.new(1,0,1,0)
                    hit.Position = UDim2.new(0,0,0,0)
                    hit.BackgroundTransparency = 1
                    hit.BorderSizePixel = 0
                    hit.Text = ""
                    hit.ZIndex = 20
                    hit.AutoButtonColor = false
                    hit.MouseButton1Click:Connect(onSelectTarget)
                end
            end
            SharedState.ListNeedsRedraw = false
        end
        
        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end

        for i, pb in ipairs(petButtons) do
            local sel = (i == selectedTargetIndex)
            local rankColor = Color3.fromRGB(70, 160, 230)
            local rankTextColor = Color3.fromRGB(200, 240, 255)
            if i == 1 then
                rankColor = Color3.fromRGB(0, 220, 255)
                rankTextColor = Color3.fromRGB(255,255,255)
            elseif i == 2 then
                rankColor = Color3.fromRGB(0, 140, 230)
                rankTextColor = Color3.fromRGB(255,255,255)
            elseif i == 3 then
                rankColor = Color3.fromRGB(0, 100, 180)
                rankTextColor = Color3.fromRGB(255,255,255)
            end
            pb.stroke.Transparency = sel and 0.18 or 0.55
            if pb.card then
                pb.card.BackgroundColor3 = sel and Color3.fromRGB(0, 40, 60) or Theme.Surface
            end
            pb.rankBg.BackgroundColor3 = rankColor
            pb.rank.TextColor3  = rankTextColor
            pb.info.TextColor3  = sel and Theme.TextPrimary or Theme.TextSecondary
            if pb.mps then
                pb.mps.TextColor3 = sel and Theme.Accent1 or Theme.TextSecondary
            end
        end
        local ct = allPets and allPets[selectedTargetIndex]
        local prevUID = SharedState.SelectedPetData and SharedState.SelectedPetData.uid
        SharedState.SelectedPetData = ct
        local newUID = ct and ct.uid

        -- Make selected pet transparent; restore previous
        if newUID ~= prevUID then
            -- Restore previous
            local prev = _G._YinPetSaved
            if prev then
                for _, e in ipairs(prev) do
                    if e.part and e.part.Parent then
                        e.part.Transparency = e.trans
                        e.part.Color        = e.color
                        e.part.Material     = e.mat
                    end
                end
                _G._YinPetSaved = nil
            end

            -- Apply to new target
            if ct and ct.animalData then
                local ad = ct.animalData
                local plots   = Workspace:FindFirstChild("Plots")
                local plot    = plots and plots:FindFirstChild(tostring(ad.plot))
                local podiums = plot and plot:FindFirstChild("AnimalPodiums")
                local podium  = podiums and podiums:FindFirstChild(tostring(ad.slot))
                local base    = podium and podium:FindFirstChild("Base")
                local spawn   = base and (base:FindFirstChild("Spawn") or base:FindFirstChildWhichIsA("BasePart"))

                local adornee = nil
                if spawn and plot then
                    local spawnPos = spawn.Position
                    local best, bestDist = nil, math.huge
                    for _, d in ipairs(plot:GetDescendants()) do
                        if d:IsA("Model") then
                            local n = d.Name:lower()
                            if n ~= "base" and n ~= "podium" then
                                local pp = d.PrimaryPart or d:FindFirstChildWhichIsA("BasePart")
                                if pp then
                                    local pos = pp.Position
                                    local hz = Vector2.new(pos.X-spawnPos.X, pos.Z-spawnPos.Z).Magnitude
                                    local dist = (pos-spawnPos).Magnitude
                                    if hz < 6 and pos.Y >= spawnPos.Y-2 and dist < bestDist then
                                        bestDist = dist; best = d
                                    end
                                end
                            end
                        end
                    end
                    adornee = best
                end

                if adornee then
                    local saved = {}
                    for _, d in ipairs(adornee:GetDescendants()) do
                        if d:IsA("BasePart") then
                            table.insert(saved, {part=d, trans=d.Transparency, color=d.Color, mat=d.Material})
                            d.Transparency = 0.6
                        end
                    end
                    _G._YinPetSaved = saved
                end
            end
        end

        if Config.AutoBack and _G.startAutoBack and _G.stopAutoBack and newUID ~= prevUID then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bp = hrp:FindFirstChild("TP_BodyPosition")
                    if bp then bp:Destroy() end
                end
            end)
            task.spawn(function()
                _G.stopAutoBack()
                task.wait(0.1)
                _G.startAutoBack()
            end)
        end
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)
    
    SharedState.UpdateAutoStealUI = function()
        autoStealEnabled = true
        updateUI(true, get_all_pets())
    end
    
    enableBtn.MouseButton1Click:Connect(function()
        autoStealEnabled = true
        SharedState.ListNeedsRedraw = false
        updateUI(true, get_all_pets())
    end)
    
    nearestBtn.MouseButton1Click:Connect(function()
        stealNearestEnabled = not stealNearestEnabled
        if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        _F.SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    highestBtn.MouseButton1Click:Connect(function()
        stealHighestEnabled = not stealHighestEnabled
        if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        _F.SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    priorityBtn.MouseButton1Click:Connect(function()
        stealPriorityEnabled = not stealPriorityEnabled
        if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false; State.manualTargetEnabled = false end
        Config.StealNearest = stealNearestEnabled; Config.StealHighest = stealHighestEnabled; Config.StealPriority = stealPriorityEnabled
        _F.SaveConfig()
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    -- ── Funções globais para controle externo do modo de steal ─────────────
    -- Permite que o Steal Panel UI modifique as vars locais deste escopo.
    -- Simula o clique no botão nativo do auto steal — forma mais segura de mudar o modo
    _G.setStealMode = function(mode)
        if mode == "highest" then
            stealHighestEnabled  = true
            stealNearestEnabled  = false
            stealPriorityEnabled = false
        elseif mode == "nearest" then
            stealNearestEnabled  = true
            stealHighestEnabled  = false
            stealPriorityEnabled = false
        elseif mode == "priority" then
            stealPriorityEnabled = true
            stealHighestEnabled  = false
            stealNearestEnabled  = false
        end
        State.manualTargetEnabled = false
        Config.StealNearest  = stealNearestEnabled
        Config.StealHighest  = stealHighestEnabled
        Config.StealPriority = stealPriorityEnabled
        _F.SaveConfig()
        SharedState.ListNeedsRedraw = true
        -- não chama updateUI diretamente — o loop de 0.5s já relê as vars locais
    end

    _G.getStealModes = function()
        return {
            highest  = stealHighestEnabled,
            nearest  = stealNearestEnabled,
            priority = stealPriorityEnabled,
        }
    end


    local customizePriorityBtn = Instance.new("TextButton", toggleBtnContainer)
    customizePriorityBtn.Size = UDim2.new(1,0,0,24); customizePriorityBtn.Position = UDim2.new(0,0,0,92)
    customizePriorityBtn.BackgroundColor3 = Theme.Accent2
    customizePriorityBtn.Text = "CUSTOMIZE PRIORITY"; customizePriorityBtn.Font = Enum.Font.GothamBold
    customizePriorityBtn.TextSize = 10; customizePriorityBtn.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", customizePriorityBtn).CornerRadius = UDim.new(0, 6)
    customizePriorityBtn.Visible = true
    
    customizePriorityBtn.MouseButton1Click:Connect(function()
        local priorityGui = PlayerGui:FindFirstChild("PriorityListGUI")
        if priorityGui then
            priorityGui.Enabled = not priorityGui.Enabled
            if priorityGui.Enabled and SharedState.RefreshPriorityGUI then SharedState.RefreshPriorityGUI() end
        end
    end)

    local instantStealBtn = Instance.new("TextButton", toggleBtnContainer)
    instantStealBtn.Size = UDim2.new(1,0,0,24*uiScale); instantStealBtn.Position = UDim2.new(0,0,0,116*uiScale)
    instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
    instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"; instantStealBtn.Font = Enum.Font.GothamBold
    instantStealBtn.TextSize = 10*uiScale; instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
    Instance.new("UICorner", instantStealBtn).CornerRadius = UDim.new(0, 6)

    instantStealBtn.MouseButton1Click:Connect(function()
        instantStealEnabled = not instantStealEnabled
        if not instantStealEnabled then
            instantStealReady = false
            instantStealDidInit = false
        end
        Config.InstantSteal = instantStealEnabled
        _F.SaveConfig()
        instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
        instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)

    local function findProximityPromptForAnimal(animalData)
        if not animalData then return nil end
        local cp = PromptMemoryCache[animalData.uid]
        if cp and cp.Parent then return cp end
        local plot = Workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
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
                                PromptMemoryCache[animalData.uid] = p
                                return p
                            end
                        end
                    end
                end
            end
            return nil
        end
        
        local al = ch:Get("AnimalList")
        if not al then return nil end
        
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local targetSlot = animalData.slot
        
        
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == targetSlot then
                local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot))
                    break
                end
            end
        end
        
        
        if not foundPodium then
            foundPodium = podiums:FindFirstChild(animalData.slot)
        end
        
        if foundPodium then
            local base = foundPodium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then
                            PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
                
                
                local startPos = spawn.Position
                local slotX, slotZ = startPos.X, startPos.Z
                local nearestPrompt = nil
                local minDist = math.huge
                
                for _, desc in pairs(plot:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
                        local part = desc.Parent
                        local promptPos = nil
                        
                        if part and part:IsA("BasePart") then
                            promptPos = part.Position
                        elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                            promptPos = part.Parent.Position
                        end
                        
                        if promptPos then
                            local checkStartY = startPos.Y
                            if brainrotName:find("la secret combinasion") then
                                checkStartY = startPos.Y - 5
                            end
                            local horizontalDist = math.sqrt((promptPos.X - slotX)^2 + (promptPos.Z - slotZ)^2)
                            if horizontalDist < 5 and promptPos.Y > checkStartY then
                                local yDist = promptPos.Y - checkStartY
                                if yDist < minDist then
                                    minDist = yDist
                                    nearestPrompt = desc
                                end
                            end
                        end
                    end
                end
                
                if nearestPrompt then
                    PromptMemoryCache[animalData.uid] = nearestPrompt
                    return nearestPrompt
                end
            end
        end
        
        return nil
    end

    local STEAL_DURATION = 0.8

    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then return end
        local data = {holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true}
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table" then
            for _, conn in ipairs(conns1) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdCallbacks, conn.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table" then
            for _, conn in ipairs(conns2) do
                if type(conn.Function) == "function" then
                    table.insert(data.triggerCallbacks, conn.Function)
                end
            end
        end
        local ok3, conns3 = pcall(getconnections, prompt.PromptButtonHoldEnded)
        if ok3 and type(conns3) == "table" then
            for _, conn in ipairs(conns3) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdEndCallbacks, conn.Function)
                end
            end
        end
        if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) or (#data.holdEndCallbacks > 0) then
            InternalStealCache[prompt] = data
        end
    end

    local function runCallbackList(list)
        for _, fn in ipairs(list) do
            task.spawn(fn)
        end
    end

    local INSTANT_STEAL_RADIUS = 60
    local INSTANT_STEAL_COOLDOWN = 0.04
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
        if not hrp then return nil, math.huge, nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil, math.huge, nil end
        local bestPrompt, bestDist, bestName = nil, math.huge, nil
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
                    bestPrompt = prompt
                    bestDist = dist
                    bestName = pod.Name
                end
            end
        end
        return bestPrompt, bestDist, bestName
    end
    -- STEAL: fireproximityprompt + direct remote callbacks
    local function executeInstantSteal(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return end
        local now = os.clock()
        if now - lastInstantStealTime < INSTANT_STEAL_COOLDOWN then return end
        lastInstantStealTime = now

        -- Fire the proximity prompt (mimics real E press)
        pcall(function()
            if fireproximityprompt then
                fireproximityprompt(prompt)
            end
        end)

        -- Also fire server remote directly via getconnections callbacks
        task.spawn(function()
            buildStealCallbacks(prompt)
            local data = InternalStealCache[prompt]
            if data then
                if #data.holdCallbacks > 0 then
                    runCallbackList(data.holdCallbacks)
                end
                task.wait(0.05)
                if #data.triggerCallbacks > 0 then
                    runCallbackList(data.triggerCallbacks)
                end
            end
        end)
    end

    local function executeInternalStealAsync(prompt, animalUID)
        local data = InternalStealCache[prompt]
        if not data or not data.ready then return false end
        data.ready = false

        task.spawn(function()
            if currentStealTargetUID ~= animalUID then
                if activeProgressTween then activeProgressTween:Cancel() end
                resetProgressVisual()
                currentStealTargetUID = animalUID
            end

            -- Hold begin
            if #data.holdCallbacks > 0 then
                runCallbackList(data.holdCallbacks)
            end

            resetProgressVisual()
            runProgressTimer()

            if currentStealTargetUID == animalUID and #data.triggerCallbacks > 0 then
                runCallbackList(data.triggerCallbacks)
            end

            data.ready = true
        end)

        return true
    end

    local function attemptSteal(prompt, animalUID)
        if not prompt or not prompt.Parent then return false end
        buildStealCallbacks(prompt)
        if not InternalStealCache[prompt] then return false end

        if currentStealTargetUID ~= animalUID then
            if activeProgressTween then
                activeProgressTween:Cancel()
                activeProgressTween = nil
            end
            resetProgressVisual()
        end

        return executeInternalStealAsync(prompt, animalUID)
    end

    local function prebuildStealCallbacks()
        for _, prompt in pairs(PromptMemoryCache) do
            if prompt and prompt.Parent then
                buildStealCallbacks(prompt)
            end
        end
    end

    task.spawn(function()
        while task.wait(2) do
            if autoStealEnabled then
                prebuildStealCallbacks()
            end
        end
    end)

    local lastAnimalData = {}
    local function getAnimalHash(al)
        if not al then return "" end; local h=""
        for slot, d in pairs(al) do if type(d)=="table" then h=h..tostring(slot)..tostring(d.Index)..tostring(d.Mutation) end end
        return h
    end

    local function scanSinglePlot(plot)
        local changed = false
        pcall(function()
            local ch = Synchronizer:Get(plot.Name); if not ch then return end
            local al = ch:Get("AnimalList")
            local hash = getAnimalHash(al)
            if lastAnimalData[plot.Name]==hash then return end
            lastAnimalData[plot.Name]=hash; changed=true
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==plot.Name then table.remove(allAnimalsCache,i) end end
            local owner = ch:Get("Owner")
            if not owner or not Players:FindFirstChild(owner.Name) then return end
            local ownerName = owner.Name or "Unknown"
            if not al then return end
            for slot, ad in pairs(al) do
                if type(ad)=="table" then
                    local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                    if aInfo then
                        local mut = ad.Mutation or "None"
                        if mut == "Yin Yang" then mut = "YinYang" end
                        local traits = (ad.Traits and #ad.Traits>0) and table.concat(ad.Traits,", ") or "None"
                        local gv = AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil)
                        local gt = "$"..NumberUtils:ToString(gv).."/s"
                        table.insert(allAnimalsCache, {
                            name=aInfo.DisplayName or aName, index=aName, genText=gt, genValue=gv,
                            mutation=mut, traits=traits, owner=ownerName,
                            plot=plot.Name, slot=tostring(slot), uid=plot.Name.."_"..tostring(slot)
                        })
                    end
                end
            end
        end)
        if changed then
            table.sort(allAnimalsCache, function(a,b) return a.genValue>b.genValue end)
            SharedState.ListNeedsRedraw = true
            
            
            if not hasShownPriorityAlert and Config.AlertsEnabled then
                task.spawn(function()
                    
                    local foundPriorityPet = nil
                    for i = 1, #PRIORITY_LIST do
                        local priorityName = PRIORITY_LIST[i]
                        local searchName = priorityName:lower()
                        
                        
                        for _, pet in ipairs(allAnimalsCache) do
                            if pet.name and pet.name:lower() == searchName then
                                foundPriorityPet = pet
                                break
                            end
                        end
                        
                        
                        if foundPriorityPet then
                            break
                        end
                    end
                    
                    if foundPriorityPet then
                        
                        local ownerUsername = foundPriorityPet.owner
                        local ownerPlayer = nil
                        
                        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                        if plot then
                            
                            local sync = Synchronizer
                            if not sync then
                                local Packages = ReplicatedStorage:FindFirstChild("Packages")
                                if Packages then
                                    local ok, syncModule = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                    if ok then sync = syncModule end
                                end
                            end
                            
                            if sync then
                                local ok, ch = pcall(function() return sync:Get(plot.Name) end)
                                if ok and ch then
                                    local owner = ch:Get("Owner")
                                    if owner then
                                        if typeof(owner) == "Instance" and owner:IsA("Player") then
                                            ownerPlayer = owner
                                            ownerUsername = owner.Name
                                        elseif type(owner) == "table" and owner.Name then
                                            ownerUsername = owner.Name
                                            ownerPlayer = Players:FindFirstChild(owner.Name)
                                        end
                                    end
                                end
                            end
                        end
                        
                        
                        if not ownerPlayer and ownerUsername then
                            ownerPlayer = Players:FindFirstChild(ownerUsername)
                        end
                        
                        ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                    end
                end)
            end
        end
    end

    local function setupPlotListener(plot)
        local ch, retries = nil, 0
        while not ch and retries<50 do
            local ok, r = pcall(function() return Synchronizer:Get(plot.Name) end)
            if ok and r then ch=r; break else retries=retries+1; task.wait(0.1) end
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
            lastAnimalData[p.Name]=nil
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==p.Name then table.remove(allAnimalsCache,i) end end
            SharedState.ListNeedsRedraw=true
        end)
    end
    
    local hasShownPriorityAlert = false
    
    ShowPriorityAlert = function(brainrotName, genText, mutation, ownerUsername)
        if not Config.AlertsEnabled then return end
        if hasShownPriorityAlert then return end
        
        local ownerPlayer = ownerUsername and Players:FindFirstChild(ownerUsername) or nil
        local isInDuel = ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true or false
        local duelStatusText = isInDuel and "IN DUEL" or "NOT IN DUEL"
        local duelStatusColor = isInDuel and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
        
        local mutationColors = {
            ["rainbow"] = Color3.fromRGB(170, 170, 170),
            ["bloodrot"] = Color3.fromRGB(120, 120, 120),
            ["candy"] = Color3.fromRGB(185, 185, 185),
            ["radioactive"] = Color3.fromRGB(160, 160, 160),
            ["cursed"] = Color3.fromRGB(130, 130, 130),
            ["gold"] = Color3.fromRGB(190, 190, 190),
            ["diamond"] = Color3.fromRGB(210, 210, 210),
            ["yinyang"] = Color3.fromRGB(230, 230, 230),
            ["lava"] = Color3.fromRGB(140, 140, 140)
        }
        
        local normalizedMutation = mutation and mutation:gsub("%s+", ""):lower() or ""
        local color = mutationColors[normalizedMutation] or Color3.fromRGB(170, 170, 170)
        
        local existing = PlayerGui:FindFirstChild("YinPriorityAlert")
        if existing then existing:Destroy() end
        
        local alertGui = Instance.new("ScreenGui")
        alertGui.Name = "YinPriorityAlert"
        alertGui.ResetOnSpawn = false
        alertGui.DisplayOrder = 999
        alertGui.Parent = PlayerGui
        
        hasShownPriorityAlert = true
        
        local alertFrame = Instance.new("Frame")
        alertFrame.Size = UDim2.new(0, 400, 0, 60)
        alertFrame.Position = UDim2.new(0.5, 0, 0, -70)
        alertFrame.AnchorPoint = Vector2.new(0.5, 0)
        alertFrame.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        alertFrame.BackgroundTransparency = 0.05
        alertFrame.BorderSizePixel = 0
        alertFrame.Parent = alertGui
        
        Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 12)
        
        local glowStroke = Instance.new("UIStroke", alertFrame)
        glowStroke.Name = "GlowStroke"
        glowStroke.Thickness = 3
        glowStroke.Color = color
        glowStroke.Transparency = 1
        
        local innerGlow = Instance.new("Frame", alertFrame)
        innerGlow.Name = "InnerGlow"
        innerGlow.Size = UDim2.new(1, 6, 1, 6)
        innerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        innerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        innerGlow.BackgroundColor3 = color
        innerGlow.BackgroundTransparency = 1
        innerGlow.ZIndex = 0
        Instance.new("UICorner", innerGlow).CornerRadius = UDim.new(0, 14)
        
        local accentBar = Instance.new("Frame", alertFrame)
        accentBar.Size = UDim2.new(0, 4, 1, -12)
        accentBar.Position = UDim2.new(0, 8, 0, 6)
        accentBar.BackgroundColor3 = color
        accentBar.BorderSizePixel = 0
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)
        
        local nameLabel = Instance.new("TextLabel", alertFrame)
        nameLabel.Size = UDim2.new(1, -30, 0.55, 0)
        nameLabel.Position = UDim2.new(0, 20, 0, 6)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = brainrotName .. " - " .. genText
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextSize = 18
        nameLabel.TextColor3 = color
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 20, 50)
        
        local genLabel = Instance.new("TextLabel", alertFrame)
        genLabel.Size = UDim2.new(1, -30, 0.4, 0)
        genLabel.Position = UDim2.new(0, 20, 0.55, 0)
        genLabel.BackgroundTransparency = 1
        genLabel.Text = duelStatusText
        genLabel.Font = Enum.Font.GothamBold
        genLabel.TextSize = 17
        genLabel.TextColor3 = duelStatusColor
        genLabel.TextXAlignment = Enum.TextXAlignment.Center
        genLabel.TextStrokeColor3 = color
        
        TweenService:Create(alertFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 15)
        }):Play()
        
        if Config.AlertSoundID and Config.AlertSoundID ~= "" then
            local sound = Instance.new("Sound")
            sound.SoundId = Config.AlertSoundID
            sound.Volume = 0.5
            sound.Parent = alertFrame
            sound:Play()
            
            TweenService:Create(glowStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 0
            }):Play()
            TweenService:Create(innerGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 0.85
            }):Play()
            
            task.delay(0.4, function()
                TweenService:Create(glowStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Transparency = 0.6
                }):Play()
                TweenService:Create(innerGlow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 1
                }):Play()
            end)
            
            sound.Ended:Connect(function() sound:Destroy() end)
        end
        
        task.delay(4, function()
            TweenService:Create(alertFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -70)
            }):Play()
            task.wait(0.35)
            alertGui:Destroy()
        end)
    end
    
    
    task.spawn(function()
        task.wait(0.5)  
        while true do
            task.wait(0.5)  
            if not hasShownPriorityAlert and Config.AlertsEnabled and #allAnimalsCache > 0 then
                
                local foundPriorityPet = nil
                for i = 1, #PRIORITY_LIST do
                    local priorityName = PRIORITY_LIST[i]
                    local searchName = priorityName:lower()
                    
                    
                    for _, pet in ipairs(allAnimalsCache) do
                        if pet.name and pet.name:lower() == searchName then
                            foundPriorityPet = pet
                            break
                        end
                    end
                    
                    
                    if foundPriorityPet then
                        break
                    end
                end
                
                if foundPriorityPet then
                    
                    local ownerUsername = foundPriorityPet.owner
                    local ownerPlayer = nil
                    
                    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                    if plot then
                        
                        local sync = Synchronizer
                        if not sync then
                            local Packages = ReplicatedStorage:FindFirstChild("Packages")
                            if Packages then
                                local ok, syncModule = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                if ok then sync = syncModule end
                            end
                        end
                        
                        if sync then
                            local ok, ch = pcall(function() return sync:Get(plot.Name) end)
                            if ok and ch then
                                local owner = ch:Get("Owner")
                                if owner then
                                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                                        ownerPlayer = owner
                                        ownerUsername = owner.Name
                                    elseif type(owner) == "table" and owner.Name then
                                        ownerUsername = owner.Name
                                        ownerPlayer = Players:FindFirstChild(owner.Name)
                                    end
                                end
                            end
                        end
                    end
                    
                    
                    if not ownerPlayer and ownerUsername then
                        ownerPlayer = Players:FindFirstChild(ownerUsername)
                    end
                    
                    ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            autoStealEnabled = true
            -- Nenhum modo de steal ativo e sem seleção manual → pausa a seleção
            local anyModeActive = stealHighestEnabled or stealNearestEnabled or stealPriorityEnabled or State.manualTargetEnabled
            if autoStealEnabled and anyModeActive then
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

                    local manualFound = false
                    if State.manualTargetEnabled and selectedTargetUID then
                        for i, p in ipairs(pets) do
                            if p.uid == selectedTargetUID then
                                if selectedTargetIndex ~= i then
                                    selectedTargetIndex = i
                                    updateUI(autoStealEnabled, pets)
                                end
                                manualFound = true
                                break
                            end
                        end
                    end

                    if manualFound then
                        -- Manual selection takes priority as long as pet exists
                    elseif stealPriorityEnabled then
                        local foundPrioIndex = nil
                        for _, pName in ipairs(PRIORITY_LIST) do
                            local searchName = pName:lower()
                            for i, p in ipairs(pets) do
                                if p.petName and p.petName:lower() == searchName then
                                    foundPrioIndex = i
                                    break
                                end
                            end
                            if foundPrioIndex then break end
                        end
                        if foundPrioIndex then
                            applySelection(foundPrioIndex)
                        else
                            applySelection(1)
                        end
                    elseif stealNearestEnabled then
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bestIndex = nil
                            local bestDist = math.huge
                            for i, p in ipairs(pets) do
                                local targetPart = p.animalData and _F.findAdorneeGlobal(p.animalData)
                                if targetPart and targetPart:IsA("BasePart") then
                                    local d = (hrp.Position - targetPart.Position).Magnitude
                                    if d < bestDist then
                                        bestDist = d
                                        bestIndex = i
                                    end
                                end
                            end
                            if bestIndex then
                                applySelection(bestIndex)
                            else
                                applySelection(1)
                            end
                        else
                            applySelection(1)
                        end
                    elseif stealHighestEnabled then
                        applySelection(1)
                    else
                        State.manualTargetEnabled = false
                    end
                end
            end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if not autoStealEnabled then
            autoStealEnabled = true
        end
        if instantStealEnabled then
            if activeProgressTween then activeProgressTween:Cancel() activeProgressTween = nil end
            setProgressVisualFull()
            -- Nenhum modo ativo → não executa instant steal
            if not (stealHighestEnabled or stealNearestEnabled or stealPriorityEnabled or State.manualTargetEnabled) then return end
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
                    local prompt, dist, name = findNearestPrompt_Instant()
                    if prompt and dist <= INSTANT_STEAL_RADIUS then
                        executeInstantSteal(prompt)
                    end
                else
                    local pets = get_all_pets()
                    if #pets > 0 then
                        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
                        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
                        local tp = pets[selectedTargetIndex]
                        if tp and not isMyBaseAnimal(tp.animalData) then
                            local pr = PromptMemoryCache[tp.uid]
                            if not pr or not pr.Parent then
                                pr = findProximityPromptForAnimal(tp.animalData)
                            end
                            if pr then
                                executeInstantSteal(pr)
                            end
                        end
                    end
                end
            end
            return
        end
        -- Se nenhum modo ativo e não há seleção manual, não rouba
        if not (stealHighestEnabled or stealNearestEnabled or stealPriorityEnabled or State.manualTargetEnabled) then return end
        local pets = get_all_pets()
        if #pets == 0 then return end
        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
        local tp = pets[selectedTargetIndex]
        if not tp or isMyBaseAnimal(tp.animalData) then return end
        local pr = PromptMemoryCache[tp.uid]
        if not pr or not pr.Parent then
            pr = findProximityPromptForAnimal(tp.animalData)
        end
        if pr then
            attemptSteal(pr, tp.uid)
        end
    end)

    task.spawn(function() while task.wait(0.5) do updateUI(autoStealEnabled, get_all_pets()) end end)
    task.delay(1, function() SharedState.ListNeedsRedraw=true; updateUI(autoStealEnabled, get_all_pets()) end)
    task.spawn(function() while true do SharedState.AllAnimalsCache=allAnimalsCache; task.wait(0.5) end end)

    local beamFolder = Instance.new("Folder", Workspace)
    beamFolder.Name = "YinTracers"
    local currentBeam = nil
    local currentAtt0 = nil
    local currentAtt1 = nil

    local function updateTracer()
        if not autoStealEnabled or not Config.TracerEnabled then
            if currentBeam then currentBeam:Destroy() currentBeam=nil end
            if currentAtt0 then currentAtt0:Destroy() currentAtt0=nil end
            if currentAtt1 then currentAtt1:Destroy() currentAtt1=nil end
            return
        end

        local best = nil
        local targetPart = nil
        if Config.LineToBase then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local plots = Workspace:FindFirstChild("Plots")
                if plots then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local ok, ch = pcall(function() return Synchronizer:Get(plot.Name) end)
                        if ok and ch then
                            local owner = ch:Get("Owner")
                            local ownerId = (typeof(owner) == "Instance" and owner:IsA("Player")) and owner.UserId or (type(owner) == "table" and owner.UserId)
                            if ownerId == LocalPlayer.UserId then
                                local plotPos = plot:FindFirstChild("Base") and plot.Base:FindFirstChild("Spawn")
                                if plotPos and plotPos:IsA("BasePart") then
                                    targetPart = plotPos
                                    break
                                end
                            end
                        end
                    end
                end
            end
        else
            local pets = get_all_pets()
            if #pets == 0 then
                if currentBeam then currentBeam.Enabled=false end
                return
            end
            if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
            if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
            best = pets[selectedTargetIndex] or pets[1]
            targetPart = _F.findAdorneeGlobal(best.animalData)
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
                currentBeam.FaceCamera = true
                currentBeam.Width0 = 0.8
                currentBeam.Width1 = 0.8
                currentBeam.TextureMode = Enum.TextureMode.Static
                currentBeam.TextureSpeed = 3
            end

            currentBeam.Attachment0 = currentAtt0
            currentBeam.Attachment1 = currentAtt1
            currentBeam.Enabled = true

            local col = Color3.fromRGB(170,170,170)
            currentBeam.Color = ColorSequence.new(col)
        else
            if currentBeam then currentBeam.Enabled = false end
        end
    end

    RunService.Heartbeat:Connect(updateTracer)
end)

task.spawn(function()
repeat task.wait() until game:IsLoaded()
task.wait(2)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local sync
do
    local syncModule = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
    local function HasBooleanUpvalue(Fn)
        local Ok, Ups = xpcall(debug.getupvalues, function() end, Fn)
        if not Ok then return false end
        for _, Val in pairs(Ups) do
            if typeof(Val) == "boolean" then return true end
        end
        return false
    end
    local function PatchFunction(Name, Fn)
        if typeof(Fn) ~= "function" or isexecutorclosure(Fn) then return end
        local Ok, Ups = xpcall(debug.getupvalues, function() end, Fn)
        if not Ok then return end
        for Idx, Val in pairs(Ups) do
            if typeof(Val) ~= "function" or isexecutorclosure(Val) then continue end
            if not HasBooleanUpvalue(Val) then continue end
            debug.setupvalue(Fn, Idx, newcclosure(function() end))
        end
    end
    for Name, Fn in pairs(syncModule) do
        PatchFunction(Name, Fn)
    end
    sync = syncModule
end

local AnimalsData = require(ReplicatedStorage.Datas.Animals)
local AnimalsShared = require(ReplicatedStorage.Shared.Animals)
local NumberUtils = require(ReplicatedStorage.Utils.NumberUtils)

local AdminRemote, CommandId, AdminCmdsData
local CommandCooldowns = {}
local Commands = {}
local LastCommandUse = {}
local ProximityEnabled = false
local ProximityKeybind = Enum.KeyCode.C
local PlayerCommandPools = {}
local LastHit = {}
local GlobalCommandsLeft = 0
local ProximityRange = 60
local AllModeEnabled = true
local ClickEnabled = false
local ClickTarget = nil
local ClickHighlight = nil
local PlayerFrames = {}
local CooldownLabels = {}
local AwaitingKeybind = false

local GAMEPASS_ID = 1227013099
local PlayerGamepassCache = {}

function _F.CheckGamepass(player)
    if PlayerGamepassCache[player.UserId] ~= nil then return end
    local url = "https://inventory.roblox.com/v1/users/" .. player.UserId .. "/items/GamePass/" .. GAMEPASS_ID
    local success, response = pcall(function()
        return game:HttpGet(url)
    end)
    if success then
        local ok, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(response)
        end)
        PlayerGamepassCache[player.UserId] = ok and data and data.data and #data.data > 0
    else
        PlayerGamepassCache[player.UserId] = false
    end
end

local THEME = {
    DarkBg        = Color3.fromRGB(18, 20, 26),
    CardBg        = Color3.fromRGB(26, 29, 38),
    AccentPurple  = Color3.fromRGB(0, 220, 255),
    AccentWhite   = Color3.fromRGB(240, 248, 255),
    AccentGreen   = Color3.fromRGB(0, 220, 255),
    AccentRed     = Color3.fromRGB(255, 90, 110),
    AccentOrange  = Color3.fromRGB(0, 180, 230),
    AccentCyan    = Color3.fromRGB(140, 215, 255),
    TextPrimary   = Color3.fromRGB(240, 248, 255),
    TextSecondary = Color3.fromRGB(130, 200, 230),
    TextMuted     = Color3.fromRGB(120, 160, 190),
    Border        = Color3.fromRGB(148, 210, 245),
    Divider       = Color3.fromRGB(170, 220, 250),
}

local PositionFile = "RoyalAP_Positions.json"
local TrollPanel, CoolPanel

_G.NetRemoteCache = _G.NetRemoteCache or {}
_G.LaserCapeData = _G.LaserCapeData or {useItemEvent = nil}

function _F.GetNetRemote(logicalName)
    if _G.NetRemoteCache[logicalName] ~= nil then
        return _G.NetRemoteCache[logicalName] or nil
    end
    local ok, Net = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 5):WaitForChild("Net", 5)
    end)
    if not ok or not Net then return nil end
    local byName, byIdx = {}, {}
    for i, obj in ipairs(Net:GetChildren()) do
        byName[obj.Name] = i
        byIdx[i] = obj
    end
    local anchorIdx = byName[logicalName]
    if anchorIdx then
        local prev = byIdx[anchorIdx - 1]
        local next = byIdx[anchorIdx + 1]
        local hexPattern = "^RE/[0-9a-fA-F]+$"
        if prev and prev:IsA("RemoteEvent") and prev.Name:match(hexPattern) then
            _G.NetRemoteCache[logicalName] = prev
            return prev
        elseif next and next:IsA("RemoteEvent") and next.Name:match(hexPattern) then
            _G.NetRemoteCache[logicalName] = next
            return next
        end
    end
    local fallback = Net:FindFirstChild(logicalName)
    if fallback and (fallback:IsA("RemoteEvent") or fallback:IsA("RemoteFunction")) then
        _G.NetRemoteCache[logicalName] = fallback
        return fallback
    end
    _G.NetRemoteCache[logicalName] = false
    return nil
end

function _F.playerHasLaserCape()
    local hasCape = false
    pcall(function()
        if LocalPlayer.Backpack:FindFirstChild("Laser Cape") or
           (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Laser Cape")) then
            hasCape = true
        end
    end)
    return hasCape
end

function _F.useLaserCapeOnPlayer(targetPlayer)
    if not LocalPlayer.Character then return false end
    if not _F.playerHasLaserCape() then return false end
    if not targetPlayer.Character then return false end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return false end
    local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
    local humanoidRootPart = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not humanoidRootPart then return false end
    local laserCape = LocalPlayer.Backpack:FindFirstChild("Laser Cape") or LocalPlayer.Character:FindFirstChild("Laser Cape")
    if not laserCape then return false end
    if laserCape.Parent ~= LocalPlayer.Character then
        humanoid:EquipTool(laserCape)
        task.wait(0.1)
    end
    local useItemRemote = _G.LaserCapeData.useItemEvent or _F.GetNetRemote("RE/UseItem")
    if useItemRemote then
        local success = pcall(function()
            useItemRemote:FireServer(targetRoot.Position, targetRoot)
        end)
        if success and not _G.LaserCapeData.useItemEvent then
            _G.LaserCapeData.useItemEvent = useItemRemote
        end
        return success
    end
    return false
end

function _F.SavePositions()
    if not writefile then return end
    if not TrollPanel or not CoolPanel then return end
    local positions = {
        TrollPanel = {TrollPanel.Position.X.Scale, TrollPanel.Position.X.Offset, TrollPanel.Position.Y.Scale, TrollPanel.Position.Y.Offset},
        CoolPanel = {CoolPanel.Position.X.Scale, CoolPanel.Position.X.Offset, CoolPanel.Position.Y.Scale, CoolPanel.Position.Y.Offset},
        ProximityKeybind = ProximityKeybind.Name,
    }
    pcall(function()
        writefile(PositionFile, game:GetService("HttpService"):JSONEncode(positions))
    end)
end

function _F.LoadPositions()
    if not readfile or not isfile then return nil end
    if not isfile(PositionFile) then return nil end
    local success, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(readfile(PositionFile))
    end)
    if success and data then
        return data
    end
    return nil
end

function _F.Tween(obj, props, dur)
    TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quad), props):Play()
end

function _F.AddCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
end

function _F.AddStroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.Border
    s.Thickness = thickness or 1
    s.Transparency = 0.3
    s.Parent = parent
end

function _F.AddGradient(parent)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, THEME.AccentPurple), ColorSequenceKeypoint.new(1, THEME.AccentWhite)}
    g.Parent = parent
end

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local AdminPanelFolder = PlayerGui:WaitForChild("AdminPanel", 10)
if not AdminPanelFolder then
    return
end
local path = AdminPanelFolder:WaitForChild("AdminPanel", 5)
if not path then
    return
end

local adminpanel = function(player, command)
    local player_ui = path:FindFirstChild("Profiles").ScrollingFrame:FindFirstChild(player.Name)
    if not player_ui then return end
    firesignal(player_ui.Activated)
    wait(0.1)
    local command_ui = path:FindFirstChild("Content").ScrollingFrame:FindFirstChild(command)
    if not command_ui then return end
    firesignal(command_ui.Activated)
end

function _F.IsOnCooldown(cmd)
    return LastCommandUse[cmd] and (tick() - LastCommandUse[cmd]) < (CommandCooldowns[cmd] or 0)
end

function _F.GetRemaining(cmd)
    if not LastCommandUse[cmd] then return 0 end
    return math.max(0, (CommandCooldowns[cmd] or 0) - (tick() - LastCommandUse[cmd]))
end

function _F.Execute(plr, cmd, src)
    if _F.IsOnCooldown(cmd) then return end
    pcall(function() adminpanel(plr, cmd) end)
    LastCommandUse[cmd] = tick()
    if src == "proximity" and GlobalCommandsLeft > 0 then
        GlobalCommandsLeft = GlobalCommandsLeft - 1
    end
    if src == "manual" and (CommandCooldowns[cmd] or 0) > 0 and cmd:lower() ~= "control" then
        task.spawn(function()
            task.wait(CommandCooldowns[cmd])
            local pool = PlayerCommandPools[plr]
            if pool and not table.find(pool, cmd) then
                table.insert(pool, cmd)
                for i = #pool, 2, -1 do pool[i], pool[math.random(i)] = pool[math.random(i)], pool[i] end
            end
        end)
    end
end

function _F.ResetPool(plr)
    PlayerCommandPools[plr] = {}
    for _, cmd in ipairs(Commands) do
        if cmd:lower() ~= "control" then
            table.insert(PlayerCommandPools[plr], cmd)
        end
    end
    for i = #PlayerCommandPools[plr], 2, -1 do
        local j = math.random(i)
        PlayerCommandPools[plr][i], PlayerCommandPools[plr][j] = PlayerCommandPools[plr][j], PlayerCommandPools[plr][i]
    end
end

function _F.GetNearestPlayer()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest = nil
    local minDist = math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if dist < minDist then
                minDist = dist
                nearest = plr
            end
        end
    end
    return nearest
end

local lockedInfo = {}

local CurrentBaseOwner = nil

function _F.GetAnimalInfo(Animal)
    if type(Animal) ~= "table" then return nil end
    local Info = AnimalsData[Animal.Index]
    local GenVal = AnimalsShared:GetGeneration(Animal.Index, Animal.Mutation, Animal.Traits, nil)
    return GenVal
end

function _F.GetCurrentBaseOwner()
    local MaxGen = -1
    local BestOwner = nil

    for _, Plot in ipairs(workspace.Plots:GetChildren()) do
        local Ch = sync:Get(Plot.Name)
        if not Ch then continue end

        local Owner = Ch:Get("Owner")
        if not Owner or Owner == LocalPlayer then continue end

        local AnimalList = Ch:Get("AnimalList") or {}

        for _, Animal in pairs(AnimalList) do
            local GenValue = _F.GetAnimalInfo(Animal)
            if GenValue and GenValue > MaxGen then
                MaxGen = GenValue
                BestOwner = Owner
            end
        end
    end

    return BestOwner
end

local tp_remote_name_to_index = {}
local tp_all_remotes = {}
local tp_use_item_index = nil

task.spawn(function()
    local net = game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net")
    local children = net:GetChildren()
    for i, obj in ipairs(children) do
        if obj:IsA("RemoteEvent") then
            tp_remote_name_to_index[obj.Name] = i
            tp_all_remotes[i] = obj
        end
    end
    for name, index in pairs(tp_remote_name_to_index) do
        if name:find("UseItem") then
            tp_use_item_index = index
            break
        end
    end
end)

local tp_waypointOffsetsByFloor = {
    [1] = {Vector3.new(19.06,1.56,19.85), Vector3.new(-82.42,20.85,-5.87)},
    [2] = {Vector3.new(27.29,19.13,19.84), Vector3.new(32.83,20.24,56.88), Vector3.new(-82.26,20.24,57.85)},
    [3] = {Vector3.new(29.18,23.12,53.91), Vector3.new(-74.37,23.28,49.80), Vector3.new(28.87,24.13,20.98), Vector3.new(28.77,40.77,18.06)},
}

function _F.tp_isPlotInverted(plot)
    local plotSign = plot and plot:FindFirstChild("PlotSign")
    if not plotSign then return false end
    local r = plotSign.Rotation
    return (math.abs(r.X) < 45 and math.abs(r.Y) < 45 and math.abs(r.Z) < 45)
end

function _F.tp_invertOffsets(offsets)
    local inv = {}
    for _, o in ipairs(offsets) do table.insert(inv, Vector3.new(-o.X, o.Y, -o.Z)) end
    return inv
end

function _F.tp_getPlotSpawn()
    local plotsFolder = workspace:FindFirstChild("Plots")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not plotsFolder or not root then return nil, nil end
    local closestPlot, closestSpawn, closestDist = nil, nil, math.huge
    for _, plot in ipairs(plotsFolder:GetChildren()) do
        local ap = plot:FindFirstChild("AnimalPodiums")
        if ap then
            local p1 = ap:FindFirstChild("1")
            if p1 then
                local base = p1:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn and spawn:IsA("BasePart") then
                        local d = (root.Position - spawn.Position).Magnitude
                        if d < closestDist then closestDist = d; closestPlot = plot; closestSpawn = spawn end
                    end
                end
            end
        end
    end
    if closestPlot and closestSpawn then return closestPlot, closestSpawn.Position end
    return nil, nil
end

function _F.tp_detectFloor(y)
    if y < 6 then return 1 elseif y < 23 then return 2 elseif y < 40 then return 3 else return nil end
end

function _F.tp_getWaypoints()
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return {} end
    local plot, spawnPos = _F.tp_getPlotSpawn()
    if not spawnPos then return {} end
    local floor = _F.tp_detectFloor(root.Position.Y)
    if not floor then return {} end
    local offsets = tp_waypointOffsetsByFloor[floor] or {}
    if _F.tp_isPlotInverted(plot) then offsets = _F.tp_invertOffsets(offsets) end
    local wps = {}
    for _, o in ipairs(offsets) do table.insert(wps, spawnPos + o) end
    return wps
end

function _F.tp_flyToTarget(targetPlr, onProgress)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false, "no_flying_tool" end
    local flyingTool = nil
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and (tool.Name:find("Carpet") or tool.Name:find("Broom") or tool.Name:find("Sleigh")) then
            flyingTool = tool break
        end
    end
    if not flyingTool then return false, "no_flying_tool" end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false, "no_character" end
    local root = char.HumanoidRootPart
    local waypoints = {}
    if root.Position.Y < 46 then waypoints = _F.tp_getWaypoints() end
    if targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        table.insert(waypoints, targetPlr.Character.HumanoidRootPart.Position + Vector3.new(0, 3, 0))
    else
        if #waypoints == 0 then return false, "no_target" end
    end
    if #waypoints == 0 then return false, "no_waypoints" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum:EquipTool(flyingTool) end
    wait(0.1)
    local attachment = root:FindFirstChildOfClass("Attachment") or Instance.new("Attachment", root)
    local velocity = Instance.new("LinearVelocity")
    velocity.Attachment0 = attachment
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = Vector3.zero
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.Parent = root
    local flying = true
    local wpIdx = 1
    task.spawn(function()
        while flying and wpIdx <= #waypoints do
            if not root or not root.Parent then flying = false; break end
            local wp = waypoints[wpIdx]
            local dist = (wp - root.Position).Magnitude
            if onProgress then onProgress(dist, wpIdx, #waypoints) end
            local threshold = wpIdx == #waypoints and 12 or 8
            if dist <= threshold then
                wpIdx = wpIdx + 1
                if wpIdx > #waypoints then flying = false; break end
            else
                velocity.VectorVelocity = (wp - root.Position).Unit * 350
            end
            task.wait()
        end
        pcall(function() if root and root.Parent then root.AssemblyLinearVelocity = Vector3.zero end end)
        pcall(function() if velocity and velocity.Parent then velocity:Destroy() end end)
    end)
    local timeout = 0
    while flying and timeout < 150 do task.wait(0.05) timeout = timeout + 1 end
    pcall(function() if velocity and velocity.Parent then velocity:Destroy() end end)
    pcall(function() if root and root.Parent then root.AssemblyLinearVelocity = Vector3.zero end end)
    if timeout >= 150 then return false, "timeout" end
    if targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
        local cn = LocalPlayer.Character
        if cn and cn:FindFirstChild("HumanoidRootPart") then
            return true, "success", (cn.HumanoidRootPart.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude
        end
    end
    return true, "success", math.huge
end

function _F.tp_fireRemote(targetPlr)
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return false, "no_backpack" end
    local potion = backpack:FindFirstChild("Body Swap Potion")
    if not potion then
        local c = LocalPlayer.Character
        if c then potion = c:FindFirstChild("Body Swap Potion") end
    end
    if not potion then return false, "no_potion" end
    if potion:GetAttribute("CooldownTime") then return false, "tool_cooldown" end
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false, "no_character" end
    if not targetPlr.Character or not targetPlr.Character:FindFirstChild("HumanoidRootPart") then return false, "no_target_character" end
    if (char.HumanoidRootPart.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude > 70 then return false, "too_far" end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:EquipTool(potion)
        wait(0.1)
        if potion:IsA("Tool") then potion:Activate() end
    else return false, "no_humanoid" end
    if tp_use_item_index then
        for _, idx in ipairs({tp_use_item_index - 1, tp_use_item_index + 1}) do
            local remote = tp_all_remotes[idx]
            if remote then remote:FireServer(targetPlr) end
        end
        return true, "success"
    end
    return false, "no_remote"
end

AdminCmdsData = require(ReplicatedStorage.Datas.AdminCommands)
for name, info in pairs(AdminCmdsData) do
    CommandCooldowns[name] = info.cooldown
    table.insert(Commands, name)
end
GlobalCommandsLeft = #Commands

local GUI = Instance.new("ScreenGui")
GUI.Name = tostring(math.random(100000, 999999))
local success = pcall(function()
    GUI.Parent = game:GetService("CoreGui")
end)
if not success then
    GUI.Parent = gethui()
end
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
if protect_gui then protect_gui(GUI) end

-- =====================================================
-- ICE THEME HELPERS: snowflakes, frost overlay, spikes
-- =====================================================
local ICE_COLORS = {
    Color3.fromRGB(180, 235, 255),
    Color3.fromRGB(140, 210, 250),
    Color3.fromRGB(200, 245, 255),
    Color3.fromRGB(120, 195, 240),
}

local function addIceFrostOverlay(frame)
    -- Semi-transparent ice-blue gradient overlay
    local frost = Instance.new("Frame")
    frost.Size = UDim2.new(1, 0, 1, 0)
    frost.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
    frost.BackgroundTransparency = 0.92
    frost.ZIndex = frame.ZIndex
    frost.BorderSizePixel = 0
    frost.Parent = frame
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 200, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 160, 220)),
    })
    grad.Rotation = 135
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.95),
    })
    grad.Parent = frost
end

local function addSnowflakes(frame, count)
    count = count or 8
    local SNOWFLAKES = {"❄", "❅", "❆", "*", "·"}
    local ts = game:GetService("TweenService")
    for i = 1, count do
        task.spawn(function()
            task.wait(math.random(0, 30) * 0.1)
            while frame.Parent do
                local flake = Instance.new("TextLabel")
                flake.Size = UDim2.new(0, 14, 0, 14)
                flake.Position = UDim2.new(math.random(5, 95) * 0.01, 0, -0.05, 0)
                flake.BackgroundTransparency = 1
                flake.Text = SNOWFLAKES[math.random(1, #SNOWFLAKES)]
                flake.Font = Enum.Font.GothamBold
                flake.TextSize = math.random(8, 13)
                flake.TextColor3 = ICE_COLORS[math.random(1, #ICE_COLORS)]
                flake.TextTransparency = 0.2
                flake.ZIndex = frame.ZIndex + 5
                flake.BorderSizePixel = 0
                flake.Parent = frame
                local fallTime = math.random(30, 60) * 0.1
                local targetY = 1.05
                ts:Create(flake, TweenInfo.new(fallTime, Enum.EasingStyle.Linear), {
                    Position = UDim2.new(flake.Position.X.Scale + math.random(-8, 8) * 0.01, 0, targetY, 0),
                    TextTransparency = 0.7,
                }):Play()
                task.wait(fallTime)
                flake:Destroy()
                task.wait(math.random(5, 20) * 0.1)
            end
        end)
    end
end

local function applyIceToPanel(frame, _, flakeCount)
    addIceFrostOverlay(frame)
    addSnowflakes(frame, flakeCount or 6)
end
-- =====================================================

TrollPanel = Instance.new("Frame")
TrollPanel.Size = UDim2.new(0, 310, 0, 580)
TrollPanel.Position = UDim2.new(1, -330, 0.5, -340)
TrollPanel.BackgroundColor3 = THEME.DarkBg
TrollPanel.BackgroundTransparency = 0.1
TrollPanel.Parent = GUI
_F.AddCorner(TrollPanel, 12)
_F.AddStroke(TrollPanel, THEME.AccentPurple, 2)
-- snowflakes removidos do Admin Panel

local TrollTitle = Instance.new("TextLabel")
TrollTitle.Size = UDim2.new(1, -30, 0, 35)
TrollTitle.Position = UDim2.new(0, 15, 0, 8)
TrollTitle.BackgroundTransparency = 1
TrollTitle.Text = "Admin Panel"
TrollTitle.Font = Enum.Font.GothamBold
TrollTitle.TextSize = 16
TrollTitle.TextColor3 = THEME.AccentWhite
TrollTitle.TextXAlignment = Enum.TextXAlignment.Left
TrollTitle.Parent = TrollPanel
_F.AddGradient(TrollTitle)

local ProxSliderFrame = Instance.new("Frame")
ProxSliderFrame.Size = UDim2.new(1, -30, 0, 35)
ProxSliderFrame.Position = UDim2.new(0, 15, 0, 48)
ProxSliderFrame.BackgroundTransparency = 1
ProxSliderFrame.Parent = TrollPanel

local ProxToggle = Instance.new("TextButton")
ProxToggle.Size = UDim2.new(0, 60, 0, 28)
ProxToggle.Position = UDim2.new(0, 0, 0, 3)
ProxToggle.BackgroundColor3 = THEME.AccentRed
ProxToggle.Text = "Prox"
ProxToggle.Font = Enum.Font.GothamBold
ProxToggle.TextSize = 12
ProxToggle.TextColor3 = THEME.TextPrimary
ProxToggle.AutoButtonColor = false
ProxToggle.Parent = ProxSliderFrame
_F.AddCorner(ProxToggle, 6)

local ProxRangeLabel = Instance.new("TextLabel")
ProxRangeLabel.Size = UDim2.new(0, 30, 0, 20)
ProxRangeLabel.Position = UDim2.new(0, 70, 0, 8)
ProxRangeLabel.BackgroundTransparency = 1
ProxRangeLabel.Text = "60"
ProxRangeLabel.Font = Enum.Font.GothamBold
ProxRangeLabel.TextSize = 14
ProxRangeLabel.TextColor3 = THEME.TextPrimary
ProxRangeLabel.TextXAlignment = Enum.TextXAlignment.Left
ProxRangeLabel.Parent = ProxSliderFrame

local SliderTrack = Instance.new("Frame")
SliderTrack.Size = UDim2.new(1, -115, 0, 6)
SliderTrack.Position = UDim2.new(0, 105, 0, 14)
SliderTrack.BackgroundColor3 = THEME.Border
SliderTrack.Parent = ProxSliderFrame
_F.AddCorner(SliderTrack, 3)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.22, 0, 1, 0)
SliderFill.BackgroundColor3 = THEME.AccentPurple
SliderFill.Parent = SliderTrack
_F.AddCorner(SliderFill, 3)

local SliderHandle = Instance.new("TextButton")
SliderHandle.Size = UDim2.new(0, 18, 0, 18)
SliderHandle.Position = UDim2.new(0.22, -9, 0.5, -9)
SliderHandle.BackgroundColor3 = THEME.AccentWhite
SliderHandle.Text = ""
SliderHandle.AutoButtonColor = false
SliderHandle.Parent = SliderTrack
_F.AddCorner(SliderHandle, 9)

local SelfCmdFrame = Instance.new("Frame")
SelfCmdFrame.Size = UDim2.new(1, -30, 0, 40)
SelfCmdFrame.Position = UDim2.new(0, 15, 0, 93)
SelfCmdFrame.BackgroundTransparency = 1
SelfCmdFrame.Parent = TrollPanel

local SelfCmdLabel = Instance.new("TextLabel")
SelfCmdLabel.Size = UDim2.new(0, 120, 0, 40)
SelfCmdLabel.Position = UDim2.new(0, 0, 0, 0)
SelfCmdLabel.BackgroundTransparency = 1
SelfCmdLabel.Text = "Self Commands"
SelfCmdLabel.Font = Enum.Font.GothamBold
SelfCmdLabel.TextSize = 12
SelfCmdLabel.TextColor3 = THEME.TextPrimary
SelfCmdLabel.TextXAlignment = Enum.TextXAlignment.Left
SelfCmdLabel.Parent = SelfCmdFrame

local RagBtn = Instance.new("TextButton")
RagBtn.Size = UDim2.new(0, 60, 0, 32)
RagBtn.Position = UDim2.new(1, -125, 0, 4)
RagBtn.BackgroundColor3 = THEME.AccentPurple
RagBtn.Text = "RAG"
RagBtn.Font = Enum.Font.GothamBold
RagBtn.TextSize = 11
RagBtn.TextColor3 = THEME.TextPrimary
RagBtn.AutoButtonColor = false
RagBtn.Parent = SelfCmdFrame
_F.AddCorner(RagBtn, 6)

local RktBtn = Instance.new("TextButton")
RktBtn.Size = UDim2.new(0, 60, 0, 32)
RktBtn.Position = UDim2.new(1, -60, 0, 4)
RktBtn.BackgroundColor3 = THEME.AccentOrange
RktBtn.Text = "RKT"
RktBtn.Font = Enum.Font.GothamBold
RktBtn.TextSize = 11
RktBtn.TextColor3 = THEME.TextPrimary
RktBtn.AutoButtonColor = false
RktBtn.Parent = SelfCmdFrame
_F.AddCorner(RktBtn, 6)

local SpamAllFrame = Instance.new("Frame")
SpamAllFrame.Size = UDim2.new(1, -30, 0, 40)
SpamAllFrame.Position = UDim2.new(0, 15, 0, 143)
SpamAllFrame.BackgroundTransparency = 1
SpamAllFrame.Parent = TrollPanel

local SpamAllLabel = Instance.new("TextLabel")
SpamAllLabel.Size = UDim2.new(0, 120, 0, 40)
SpamAllLabel.Position = UDim2.new(0, 0, 0, 0)
SpamAllLabel.BackgroundTransparency = 1
SpamAllLabel.Text = "Spam All"
SpamAllLabel.Font = Enum.Font.GothamBold
SpamAllLabel.TextSize = 12
SpamAllLabel.TextColor3 = THEME.TextPrimary
SpamAllLabel.TextXAlignment = Enum.TextXAlignment.Left
SpamAllLabel.Parent = SpamAllFrame

local NearBtn = Instance.new("TextButton")
NearBtn.Size = UDim2.new(0, 60, 0, 32)
NearBtn.Position = UDim2.new(1, -125, 0, 4)
NearBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
NearBtn.Text = "NEAR"
NearBtn.Font = Enum.Font.GothamBold
NearBtn.TextSize = 11
NearBtn.TextColor3 = THEME.TextPrimary
NearBtn.AutoButtonColor = false
NearBtn.Parent = SpamAllFrame
_F.AddCorner(NearBtn, 6)

local OwnBtn = Instance.new("TextButton")
OwnBtn.Size = UDim2.new(0, 60, 0, 32)
OwnBtn.Position = UDim2.new(1, -60, 0, 4)
OwnBtn.BackgroundColor3 = THEME.AccentOrange
OwnBtn.Text = "OWN"
OwnBtn.Font = Enum.Font.GothamBold
OwnBtn.TextSize = 11
OwnBtn.TextColor3 = THEME.TextPrimary
OwnBtn.AutoButtonColor = false
OwnBtn.Parent = SpamAllFrame
_F.AddCorner(OwnBtn, 6)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(1, -30, 1, -198)
PlayerList.Position = UDim2.new(0, 15, 0, 193)
PlayerList.BackgroundTransparency = 1
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.ScrollBarImageColor3 = THEME.AccentPurple
PlayerList.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.Parent = TrollPanel

local Layout = Instance.new("UIListLayout")
Layout.SortOrder = Enum.SortOrder.Name
Layout.Padding = UDim.new(0, 5)
Layout.Parent = PlayerList

CoolPanel = Instance.new("Frame")
CoolPanel.Size = UDim2.new(0, 380, 0, 220)
CoolPanel.Position = UDim2.new(1, -400, 1, -240)
CoolPanel.BackgroundColor3 = THEME.DarkBg
CoolPanel.BackgroundTransparency = 0.1
CoolPanel.Parent = GUI
_F.AddCorner(CoolPanel, 12)
_F.AddStroke(CoolPanel, THEME.AccentPurple, 2)
task.defer(function() applyIceToPanel(CoolPanel, 6, 5) end)

local ClickTitle = Instance.new("TextLabel")
ClickTitle.Size = UDim2.new(0.45, 0, 0, 30)
ClickTitle.Position = UDim2.new(0, 10, 0, 10)
ClickTitle.BackgroundTransparency = 1
ClickTitle.Text = "Click Commands"
ClickTitle.Font = Enum.Font.GothamBold
ClickTitle.TextSize = 13
ClickTitle.TextColor3 = THEME.AccentWhite
ClickTitle.TextXAlignment = Enum.TextXAlignment.Left
ClickTitle.Parent = CoolPanel
_F.AddGradient(ClickTitle)

local LeftClickLabel = Instance.new("TextLabel")
LeftClickLabel.Size = UDim2.new(0.45, -10, 0, 16)
LeftClickLabel.Position = UDim2.new(0, 10, 0, 45)
LeftClickLabel.BackgroundTransparency = 1
LeftClickLabel.Text = "Left Click"
LeftClickLabel.Font = Enum.Font.GothamBold
LeftClickLabel.TextSize = 11
LeftClickLabel.TextColor3 = THEME.TextPrimary
LeftClickLabel.TextXAlignment = Enum.TextXAlignment.Left
LeftClickLabel.Parent = CoolPanel

local LeftClickCmds = Instance.new("TextLabel")
LeftClickCmds.Size = UDim2.new(0.45, -10, 0, 14)
LeftClickCmds.Position = UDim2.new(0, 10, 0, 63)
LeftClickCmds.BackgroundTransparency = 1
LeftClickCmds.Text = "Tiny, Rocket"
LeftClickCmds.Font = Enum.Font.Gotham
LeftClickCmds.TextSize = 10
LeftClickCmds.TextColor3 = THEME.TextSecondary
LeftClickCmds.TextXAlignment = Enum.TextXAlignment.Left
LeftClickCmds.Parent = CoolPanel

local RightClickLabel = Instance.new("TextLabel")
RightClickLabel.Size = UDim2.new(0.45, -10, 0, 16)
RightClickLabel.Position = UDim2.new(0, 10, 0, 85)
RightClickLabel.BackgroundTransparency = 1
RightClickLabel.Text = "Right Click"
RightClickLabel.Font = Enum.Font.GothamBold
RightClickLabel.TextSize = 11
RightClickLabel.TextColor3 = THEME.TextPrimary
RightClickLabel.TextXAlignment = Enum.TextXAlignment.Left
RightClickLabel.Parent = CoolPanel

local RightClickCmds = Instance.new("TextLabel")
RightClickCmds.Size = UDim2.new(0.45, -10, 0, 14)
RightClickCmds.Position = UDim2.new(0, 10, 0, 103)
RightClickCmds.BackgroundTransparency = 1
RightClickCmds.Text = "Jail"
RightClickCmds.Font = Enum.Font.Gotham
RightClickCmds.TextSize = 10
RightClickCmds.TextColor3 = THEME.TextSecondary
RightClickCmds.TextXAlignment = Enum.TextXAlignment.Left
RightClickCmds.Parent = CoolPanel

local MiddleClickLabel = Instance.new("TextLabel")
MiddleClickLabel.Size = UDim2.new(0.45, -10, 0, 16)
MiddleClickLabel.Position = UDim2.new(0, 10, 0, 125)
MiddleClickLabel.BackgroundTransparency = 1
MiddleClickLabel.Text = "Middle Click"
MiddleClickLabel.Font = Enum.Font.GothamBold
MiddleClickLabel.TextSize = 11
MiddleClickLabel.TextColor3 = THEME.TextPrimary
MiddleClickLabel.TextXAlignment = Enum.TextXAlignment.Left
MiddleClickLabel.Parent = CoolPanel

local MiddleClickCmds = Instance.new("TextLabel")
MiddleClickCmds.Size = UDim2.new(0.45, -10, 0, 14)
MiddleClickCmds.Position = UDim2.new(0, 10, 0, 143)
MiddleClickCmds.BackgroundTransparency = 1
MiddleClickCmds.Text = "Inverse, Jumpscare, Morph"
MiddleClickCmds.Font = Enum.Font.Gotham
MiddleClickCmds.TextSize = 9
MiddleClickCmds.TextColor3 = THEME.TextSecondary
MiddleClickCmds.TextXAlignment = Enum.TextXAlignment.Left
MiddleClickCmds.Parent = CoolPanel

local ClickToggleBtn = Instance.new("TextButton")
ClickToggleBtn.Size = UDim2.new(0.45, -10, 0, 30)
ClickToggleBtn.Position = UDim2.new(0, 10, 1, -40)
ClickToggleBtn.BackgroundColor3 = THEME.AccentRed
ClickToggleBtn.Text = "Disabled"
ClickToggleBtn.Font = Enum.Font.GothamBold
ClickToggleBtn.TextSize = 11
ClickToggleBtn.TextColor3 = THEME.TextPrimary
ClickToggleBtn.AutoButtonColor = false
ClickToggleBtn.Parent = CoolPanel
_F.AddCorner(ClickToggleBtn, 6)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 1, -20)
Divider.Position = UDim2.new(0.5, 0, 0, 10)
Divider.BackgroundColor3 = THEME.Divider
Divider.BorderSizePixel = 0
Divider.Parent = CoolPanel

local CoolTitle = Instance.new("TextLabel")
CoolTitle.Size = UDim2.new(0.45, 0, 0, 30)
CoolTitle.Position = UDim2.new(0.5, 10, 0, 10)
CoolTitle.BackgroundTransparency = 1
CoolTitle.Text = "Cooldowns"
CoolTitle.Font = Enum.Font.GothamBold
CoolTitle.TextSize = 13
CoolTitle.TextColor3 = THEME.AccentWhite
CoolTitle.TextXAlignment = Enum.TextXAlignment.Left
CoolTitle.Parent = CoolPanel
_F.AddGradient(CoolTitle)

local CoolCmds = {
    {Name = "Rocket",      Cmd = "rocket"},
    {Name = "Ragdoll",     Cmd = "ragdoll"},
    {Name = "Balloon",     Cmd = "balloon"},
    {Name = "Inverse",     Cmd = "inverse"},
    {Name = "Jail",        Cmd = "jail"},
    {Name = "NightVision", Cmd = "nightvision"},
    {Name = "Tiny",        Cmd = "tiny"},
    {Name = "Morph",       Cmd = "morph"}
}

for i, cmd in ipairs(CoolCmds) do
    local item = Instance.new("Frame")
    item.Size = UDim2.new(0.45, -10, 0, 16)
    item.Position = UDim2.new(0.5, 10, 0, 40 + (i-1) * 18)
    item.BackgroundTransparency = 1
    item.Parent = CoolPanel
    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(0.55, 0, 1, 0)
    name.BackgroundTransparency = 1
    name.Text = cmd.Name .. ":"
    name.Font = Enum.Font.Gotham
    name.TextSize = 10
    name.TextColor3 = THEME.TextSecondary
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.Parent = item
    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(0.45, 0, 1, 0)
    status.Position = UDim2.new(0.55, 0, 0, 0)
    status.BackgroundTransparency = 1
    status.Text = "Ready"
    status.Font = Enum.Font.GothamBold
    status.TextSize = 10
    status.TextColor3 = THEME.AccentGreen
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.Parent = item
    CooldownLabels[cmd.Cmd] = status
end

local savedPos = _F.LoadPositions()
if savedPos then
    task.wait(0.1)
    if savedPos.TrollPanel then
        TrollPanel.Position = UDim2.new(savedPos.TrollPanel[1], savedPos.TrollPanel[2], savedPos.TrollPanel[3], savedPos.TrollPanel[4])
    end
    if savedPos.CoolPanel then
        CoolPanel.Position = UDim2.new(savedPos.CoolPanel[1], savedPos.CoolPanel[2], savedPos.CoolPanel[3], savedPos.CoolPanel[4])
    end
    if savedPos.ProximityKeybind then
        local ok2 = pcall(function()
            ProximityKeybind = Enum.KeyCode[savedPos.ProximityKeybind]
        end)
        if not ok2 then
            ProximityKeybind = Enum.KeyCode.C
        end
    end
end

function _F.CreatePlayerBtn(plr, slotNum, isOwnerSlot)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 70)
    frame.BackgroundColor3 = THEME.CardBg
    frame.Parent = PlayerList
    _F.AddCorner(frame, 6)

    local infoContainer = Instance.new("Frame")
    infoContainer.Size = UDim2.new(0, 130, 1, 0)
    infoContainer.Position = UDim2.new(0, 8, 0, 0)
    infoContainer.BackgroundTransparency = 1
    infoContainer.Parent = frame

    local name = Instance.new("TextLabel")
    name.Size = UDim2.new(1, 0, 0, 18)
    name.Position = UDim2.new(0, 0, 0, 9)
    name.BackgroundTransparency = 1
    name.Font = Enum.Font.GothamBold
    name.TextSize = 13
    name.TextColor3 = Color3.fromRGB(240, 248, 255)
    name.TextXAlignment = Enum.TextXAlignment.Left
    name.TextTruncate = Enum.TextTruncate.AtEnd
    name.Parent = infoContainer

    local username = Instance.new("TextLabel")
    username.Size = UDim2.new(1, 0, 0, 11)
    username.Position = UDim2.new(0, 0, 0, 23)
    username.BackgroundTransparency = 1
    username.Font = Enum.Font.Gotham
    username.TextSize = 10
    username.TextColor3 = THEME.TextMuted
    username.TextXAlignment = Enum.TextXAlignment.Left
    username.TextTruncate = Enum.TextTruncate.AtEnd
    username.Parent = infoContainer

    local stealingLabel = Instance.new("TextLabel")
    stealingLabel.Size = UDim2.new(1, 0, 0, 11)
    stealingLabel.Position = UDim2.new(0, 0, 0, 47)
    stealingLabel.BackgroundTransparency = 1
    stealingLabel.Text = ""
    stealingLabel.Font = Enum.Font.GothamBold
    stealingLabel.TextSize = 10
    stealingLabel.TextColor3 = Color3.fromRGB(255, 150, 0)
    stealingLabel.TextXAlignment = Enum.TextXAlignment.Left
    stealingLabel.TextTruncate = Enum.TextTruncate.AtEnd
    stealingLabel.Visible = false
    stealingLabel.Parent = infoContainer

    local baseOwnerLabel = Instance.new("TextLabel")
    baseOwnerLabel.Size = UDim2.new(1, 0, 0, 11)
    baseOwnerLabel.Position = UDim2.new(0, 0, 0, 36)
    baseOwnerLabel.BackgroundTransparency = 1
    baseOwnerLabel.Text = "Base Owner"
    baseOwnerLabel.Font = Enum.Font.GothamBold
    baseOwnerLabel.TextSize = 10
    baseOwnerLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    baseOwnerLabel.TextXAlignment = Enum.TextXAlignment.Left
    baseOwnerLabel.Visible = false
    baseOwnerLabel.Parent = infoContainer

    local apLabel = Instance.new("TextLabel")
    apLabel.Size = UDim2.new(1, 0, 0, 11)
    apLabel.Position = UDim2.new(0, 0, 0, 36)
    apLabel.BackgroundTransparency = 1
    apLabel.Text = "Has AP"
    apLabel.Font = Enum.Font.GothamBold
    apLabel.TextSize = 10
    apLabel.TextColor3 = THEME.AccentPurple
    apLabel.TextXAlignment = Enum.TextXAlignment.Left
    apLabel.Visible = false
    apLabel.Parent = infoContainer

    if plr then
        PlayerFrames[plr] = frame
        name.Text = plr.DisplayName
        username.Text = "@" .. plr.Name
    else
        if isOwnerSlot then
            name.Text = "Owner Slot"
        else
            name.Text = "Slot " .. slotNum
        end
        username.Text = "Empty"
        username.TextColor3 = Color3.fromRGB(100, 100, 100)
        frame.BackgroundTransparency = 0.5
    end

    if not plr then return end

    task.spawn(function()
        _F.CheckGamepass(plr)
        local timeout = 0
        while PlayerGamepassCache[plr.UserId] == nil and timeout < 100 do
            task.wait(0.1)
            timeout += 1
        end
        if PlayerGamepassCache[plr.UserId] == true then
            apLabel.Visible = true
        end
    end)

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 160, 1, -12)
    container.Position = UDim2.new(1, -165, 0, 6)
    container.BackgroundTransparency = 1
    container.Parent = frame

    local mainBtnHeight = isOwnerSlot and 32 or 58
    local mainRow = Instance.new("Frame")
    mainRow.Size = UDim2.new(1, 0, 0, mainBtnHeight)
    mainRow.Position = UDim2.new(0, 0, 0, 0)
    mainRow.BackgroundTransparency = 1
    mainRow.Parent = container
    local mainLayout = Instance.new("UIListLayout")
    mainLayout.FillDirection = Enum.FillDirection.Horizontal
    mainLayout.Padding = UDim.new(0, 4)
    mainLayout.Parent = mainRow

    local btns = {
        {Text = "JAIL", Color = THEME.AccentRed,    Command = "jail",    Size = UDim2.new(0, 36, 0, mainBtnHeight), Row = "main"},
        {Text = "RAG",  Color = THEME.AccentPurple,   Command = "ragdoll", Size = UDim2.new(0, 36, 0, mainBtnHeight), Row = "main"},
        {Text = "RKT",  Color = THEME.AccentOrange, Command = "rocket",  Size = UDim2.new(0, 36, 0, mainBtnHeight), Row = "main"},
        {Text = "BLN",  Color = THEME.AccentGreen,  Command = "balloon", Size = UDim2.new(0, 36, 0, mainBtnHeight), Row = "main"}
    }

    local extraRow
    if isOwnerSlot then
        extraRow = Instance.new("Frame")
        extraRow.Size = UDim2.new(1, 0, 0, 24)
        extraRow.Position = UDim2.new(0, 0, 0, mainBtnHeight + 2)
        extraRow.BackgroundTransparency = 1
        extraRow.Parent = container
        local extraLayout = Instance.new("UIListLayout")
        extraLayout.FillDirection = Enum.FillDirection.Horizontal
        extraLayout.Padding = UDim.new(0, 4)
        extraLayout.Parent = extraRow

        table.insert(btns, {Text = "I", Color = Color3.fromRGB(0, 255, 255), Command = "inverse", Size = UDim2.new(0, 36, 0, 24), Row = "extra"})
        table.insert(btns, {Text = "M", Color = Color3.fromRGB(180, 0, 255), Command = "morph", Size = UDim2.new(0, 36, 0, 24), Row = "extra"})
        table.insert(btns, {Text = "T", Color = Color3.fromRGB(100, 255, 100), Command = "tiny", Size = UDim2.new(0, 36, 0, 24), Row = "extra"})
        table.insert(btns, {Text = "C", Color = Color3.fromRGB(255, 255, 0), Command = "control", Size = UDim2.new(0, 36, 0, 24), Row = "extra"})
    end

    for _, b in ipairs(btns) do
        local parentRow = (b.Row == "extra") and extraRow or mainRow
        local btn = Instance.new("TextButton")
        btn.Size = b.Size
        btn.BackgroundColor3 = b.Color
        btn.Text = b.Text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = (b.Row == "extra") and 9 or 10
        btn.TextColor3 = THEME.TextPrimary
        btn.AutoButtonColor = false
        btn.Parent = parentRow
        _F.AddCorner(btn, 4)
        btn.MouseButton1Click:Connect(function()
            if not _F.IsOnCooldown(b.Command) then
                _F.Execute(plr, b.Command, "manual")
                local pool = PlayerCommandPools[plr]
                if pool then
                    for i = #pool, 1, -1 do
                        if pool[i] == b.Command then table.remove(pool, i) break end
                    end
                end
                _F.Tween(btn, {BackgroundTransparency = 0.5}, 0.1)
                task.wait(0.1)
                _F.Tween(btn, {BackgroundTransparency = 0}, 0.1)
            end
        end)
        btn.MouseEnter:Connect(function()
            if not _F.IsOnCooldown(b.Command) then
                _F.Tween(btn, {BackgroundColor3 = Color3.fromRGB(math.min(255, b.Color.R * 255 + 30), math.min(255, b.Color.G * 255 + 30), math.min(255, b.Color.B * 255 + 30))}, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            _F.Tween(btn, {BackgroundColor3 = b.Color}, 0.15)
        end)
        task.spawn(function()
            while btn.Parent do
                btn.BackgroundTransparency = _F.IsOnCooldown(b.Command) and 0.6 or 0
                btn.TextTransparency = _F.IsOnCooldown(b.Command) and 0.5 or 0
                task.wait(0.5)
            end
        end)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and AllModeEnabled then
            for cmd, _ in pairs(CommandCooldowns) do
                if not _F.IsOnCooldown(cmd) and cmd:lower() ~= "control" then
                    _F.Execute(plr, cmd, "manual")
                    local pool = PlayerCommandPools[plr]
                    if pool then
                        for i = #pool, 1, -1 do
                            if pool[i] == cmd then table.remove(pool, i) break end
                        end
                    end
                    task.wait(0.05)
                end
            end
        end
    end)

    frame.MouseEnter:Connect(function()
        _F.Tween(frame, {BackgroundColor3 = Color3.fromRGB(math.min(255, THEME.CardBg.R * 255 + 10), math.min(255, THEME.CardBg.G * 255 + 10), math.min(255, THEME.CardBg.B * 255 + 10))}, 0.2)
    end)
    frame.MouseLeave:Connect(function()
        _F.Tween(frame, {BackgroundColor3 = THEME.CardBg}, 0.2)
    end)

    task.spawn(function()
        while frame.Parent do
            if plr and plr.Parent and frame and frame.Parent then
                local char = plr.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum and hum.WalkSpeed > 13 and hum.WalkSpeed < 30 then
                        frame.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
                    else
                        frame.BackgroundColor3 = THEME.CardBg
                    end
                end

                local isStealing = plr:GetAttribute("Stealing")
                local userId = plr.UserId
                local isBaseOwner = (CurrentBaseOwner == plr)
                local hasAP = PlayerGamepassCache[plr.UserId] == true

                if isBaseOwner then
                    if hasAP then
                        baseOwnerLabel.Text = "Base Owner - Has AP"
                    else
                        baseOwnerLabel.Text = "Base Owner"
                    end
                    baseOwnerLabel.Visible = true
                    apLabel.Visible = false
                else
                    baseOwnerLabel.Visible = false
                    apLabel.Visible = hasAP
                end

                if isStealing then
                    if not lockedInfo[userId] then
                        local stealingIndex = plr:GetAttribute("StealingIndex")
                        if stealingIndex and stealingIndex ~= "" then
                            lockedInfo[userId] = "Stealing " .. stealingIndex
                        end
                    end
                    stealingLabel.Text = lockedInfo[userId] or "Stealing ???"
                    stealingLabel.Visible = true
                else
                    lockedInfo[userId] = nil
                    stealingLabel.Visible = false
                end
            end
            task.wait(0.5)
        end
    end)
end

function _F.RefreshList()
    for _, child in ipairs(PlayerList:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    PlayerFrames = {}

    CurrentBaseOwner = _F.GetCurrentBaseOwner()

    local activePlayers = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr ~= CurrentBaseOwner then
            table.insert(activePlayers, plr)
        end
    end

    if CurrentBaseOwner then
        if not PlayerCommandPools[CurrentBaseOwner] then _F.ResetPool(CurrentBaseOwner) end
        _F.CreatePlayerBtn(CurrentBaseOwner, 1, true)
    else
        _F.CreatePlayerBtn(nil, 1, true)
    end

    for i = 2, 7 do
        local plr = activePlayers[i - 1]
        if plr then
            if not PlayerCommandPools[plr] then _F.ResetPool(plr) end
            _F.CreatePlayerBtn(plr, i, false)
        else
            _F.CreatePlayerBtn(nil, i, false)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    _F.RefreshList()
end)
Players.PlayerRemoving:Connect(function(plr)
    PlayerFrames[plr] = nil
    _F.RefreshList()
end)

ProxToggle.MouseButton1Click:Connect(function()
    ProximityEnabled = not ProximityEnabled
    ProxToggle.BackgroundColor3 = ProximityEnabled and THEME.AccentGreen or THEME.AccentRed
end)
ProxToggle.MouseEnter:Connect(function()
    local c = ProximityEnabled and THEME.AccentGreen or THEME.AccentRed
    _F.Tween(ProxToggle, {BackgroundColor3 = Color3.fromRGB(math.max(0, c.R * 255 - 30), math.max(0, c.G * 255 - 30), math.max(0, c.B * 255 - 30))}, 0.2)
end)
ProxToggle.MouseLeave:Connect(function()
    ProxToggle.BackgroundColor3 = ProximityEnabled and THEME.AccentGreen or THEME.AccentRed
end)

local isDragging = false
SliderHandle.MouseButton1Down:Connect(function()
    isDragging = true
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)
RunService.RenderStepped:Connect(function()
    if isDragging then
        local mouse = UserInputService:GetMouseLocation()
        local relativeX = mouse.X - SliderTrack.AbsolutePosition.X
        local percentage = math.clamp(relativeX / SliderTrack.AbsoluteSize.X, 0, 1)
        ProximityRange = math.floor(20 + (percentage * 180))
        ProxRangeLabel.Text = tostring(ProximityRange)
        SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
        SliderHandle.Position = UDim2.new(percentage, -9, 0.5, -9)
    end
end)

RagBtn.MouseButton1Click:Connect(function()
    if not _F.IsOnCooldown("ragdoll") then
        _F.Execute(LocalPlayer, "ragdoll", "self")
    end
end)
RagBtn.MouseEnter:Connect(function()
    _F.Tween(RagBtn, {BackgroundColor3 = Color3.fromRGB(math.max(0, THEME.AccentPurple.R * 255 - 30), math.max(0, THEME.AccentPurple.G * 255 - 30), math.max(0, THEME.AccentPurple.B * 255 - 30))}, 0.2)
end)
RagBtn.MouseLeave:Connect(function()
    RagBtn.BackgroundColor3 = THEME.AccentPurple
end)

RktBtn.MouseButton1Click:Connect(function()
    if not _F.IsOnCooldown("rocket") then
        _F.Execute(LocalPlayer, "rocket", "self")
    end
end)
RktBtn.MouseEnter:Connect(function()
    _F.Tween(RktBtn, {BackgroundColor3 = Color3.fromRGB(math.max(0, THEME.AccentOrange.R * 255 - 30), math.max(0, THEME.AccentOrange.G * 255 - 30), math.max(0, THEME.AccentOrange.B * 255 - 30))}, 0.2)
end)
RktBtn.MouseLeave:Connect(function()
    RktBtn.BackgroundColor3 = THEME.AccentOrange
end)

NearBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        local nearestPlr = _F.GetNearestPlayer()
        if not nearestPlr then
            NearBtn.Text = "NONE"
            task.wait(1)
            NearBtn.Text = "NEAR"
            return
        end

        NearBtn.Text = "..."
        NearBtn.BackgroundColor3 = THEME.AccentGreen

        for _, cmd in ipairs(Commands) do
            if cmd:lower() ~= "control" and not _F.IsOnCooldown(cmd) then
                _F.Execute(nearestPlr, cmd, "manual")
                task.wait(0.05)
            end
        end

        task.wait(0.4)
        NearBtn.Text = "NEAR"
        NearBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
    end)
end)
NearBtn.MouseEnter:Connect(function()
    _F.Tween(NearBtn, {BackgroundColor3 = Color3.fromRGB(0, 180, 230)}, 0.2)
end)
NearBtn.MouseLeave:Connect(function()
    NearBtn.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
end)

function _F.GetClosestBaseOwner()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local plots = workspace:FindFirstChild("Plots")
    if not plots then return nil end

    local closestPlot, closestDist = nil, math.huge
    for _, plot in ipairs(plots:GetChildren()) do
        if not plot:IsA("Model") then continue end

        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local yb = sign:FindFirstChild("YourBase")
            if yb and yb:IsA("BillboardGui") and yb.Enabled then continue end
        end

        local dist = (hrp.Position - plot:GetPivot().Position).Magnitude
        if dist < closestDist then
            closestDist = dist
            closestPlot = plot
        end
    end

    if not closestPlot or closestDist >= 50 then return nil end

    local sign = closestPlot:FindFirstChild("PlotSign")
    if not sign then return nil end
    local label = sign:FindFirstChildWhichIsA("TextLabel", true)
    if not label or label.Text == "" then return nil end

    local ownerText = label.Text:gsub("'s Base", ""):gsub("'s Plot", "")

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (plr.Name == ownerText or plr.DisplayName == ownerText) then
            return plr
        end
    end

    return nil
end

OwnBtn.MouseButton1Click:Connect(function()
    task.spawn(function()
        OwnBtn.Text = "..."
        OwnBtn.BackgroundColor3 = THEME.AccentGreen

        local targetPlayer = _F.GetClosestBaseOwner()

        if not targetPlayer then
            OwnBtn.Text = "NO OWNER"
            OwnBtn.BackgroundColor3 = THEME.AccentRed
            task.wait(1.5)
            OwnBtn.Text = "OWN"
            OwnBtn.BackgroundColor3 = THEME.AccentOrange
            return
        end

        for _, cmd in ipairs(Commands) do
            if cmd:lower() ~= "control" and not _F.IsOnCooldown(cmd) then
                _F.Execute(targetPlayer, cmd, "manual")
                task.wait(0.05)
            end
        end

        task.wait(0.4)
        OwnBtn.Text = "OWN"
        OwnBtn.BackgroundColor3 = THEME.AccentOrange
    end)
end)
OwnBtn.MouseEnter:Connect(function()
    if OwnBtn.Text == "OWN" then
        _F.Tween(OwnBtn, {BackgroundColor3 = Color3.fromRGB(
            math.max(0, THEME.AccentOrange.R * 255 - 30),
            math.max(0, THEME.AccentOrange.G * 255 - 30),
            math.max(0, THEME.AccentOrange.B * 255 - 30)
        )}, 0.2)
    end
end)
OwnBtn.MouseLeave:Connect(function()
    if OwnBtn.Text == "OWN" then
        OwnBtn.BackgroundColor3 = THEME.AccentOrange
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == ProximityKeybind then
        ProximityEnabled = not ProximityEnabled
        ProxToggle.BackgroundColor3 = ProximityEnabled and THEME.AccentGreen or THEME.AccentRed
    end
end)

local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

function _F.GetPlayerUnderMouse()
    local unitRay = Camera:ScreenPointToRay(Mouse.X, Mouse.Y)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    if LocalPlayer.Character then
        params.FilterDescendantsInstances = {LocalPlayer.Character}
    end
    local result = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000, params)
    if result then
        local char = result.Instance:FindFirstAncestorOfClass("Model")
        if char and char:FindFirstChildOfClass("Humanoid") then
            local plr = Players:GetPlayerFromCharacter(char)
            if plr and plr ~= LocalPlayer then return plr, char end
        end
    end
    local closest, closestDist = nil, 50
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local screenPos, onScreen = Camera:WorldToScreenPoint(root.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < closestDist then closestDist = dist; closest = plr end
                end
            end
        end
    end
    return closest, closest and closest.Character
end

RunService.RenderStepped:Connect(function()
    if not ClickEnabled then return end
    local plr, char = _F.GetPlayerUnderMouse()
    if plr and char then
        if ClickTarget ~= plr then
            ClickTarget = plr
            if ClickHighlight then ClickHighlight:Destroy() end
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255, 80, 80)
            h.OutlineColor = Color3.fromRGB(255, 50, 50)
            h.FillTransparency = 0.3
            h.OutlineTransparency = 0
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Parent = char
            ClickHighlight = h
        end
    else
        ClickTarget = nil
        if ClickHighlight then ClickHighlight:Destroy() ClickHighlight = nil end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if ClickEnabled and ClickTarget then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local cmds = {"tiny", "rocket"}
            for _, cmd in ipairs(cmds) do
                if not _F.IsOnCooldown(cmd) then
                    _F.Execute(ClickTarget, cmd, "manual")
                    task.wait(0.05)
                end
            end
            if ClickHighlight then
                _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(50, 255, 50), OutlineColor = Color3.fromRGB(50, 255, 50)}, 0.1)
                task.delay(0.5, function()
                    if ClickHighlight then
                        _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(255, 80, 80), OutlineColor = Color3.fromRGB(255, 50, 50)}, 0.4)
                    end
                end)
            end

        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
            if not _F.IsOnCooldown("jail") then
                _F.Execute(ClickTarget, "jail", "manual")
            end
            if ClickHighlight then
                _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(255, 100, 100), OutlineColor = Color3.fromRGB(255, 100, 100)}, 0.1)
                task.delay(0.5, function()
                    if ClickHighlight then
                        _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(255, 80, 80), OutlineColor = Color3.fromRGB(255, 50, 50)}, 0.4)
                    end
                end)
            end

        elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
            local cmds = {"inverse", "jumpscare", "morph"}
            for _, cmd in ipairs(cmds) do
                if not _F.IsOnCooldown(cmd) then
                    _F.Execute(ClickTarget, cmd, "manual")
                    task.wait(0.05)
                end
            end
            if ClickHighlight then
                _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(100, 100, 255), OutlineColor = Color3.fromRGB(100, 100, 255)}, 0.1)
                task.delay(0.5, function()
                    if ClickHighlight then
                        _F.Tween(ClickHighlight, {FillColor = Color3.fromRGB(255, 80, 80), OutlineColor = Color3.fromRGB(255, 50, 50)}, 0.4)
                    end
                end)
            end
        end
    end
end)

task.spawn(function()
    while true do
        for cmd, label in pairs(CooldownLabels) do
            if _F.IsOnCooldown(cmd) then
                label.Text = math.ceil(_F.GetRemaining(cmd)) .. "s"
                label.TextColor3 = THEME.AccentRed
            else
                label.Text = "Ready"
                label.TextColor3 = THEME.AccentGreen
            end
        end
        task.wait(0.5)
    end
end)

RunService.Heartbeat:Connect(function()
    if not ProximityEnabled then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local pos = hrp.Position
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if (plr.Character.HumanoidRootPart.Position - pos).Magnitude <= ProximityRange then
                if (not LastHit[plr]) or (tick() - LastHit[plr]) >= 1.5 then
                    local pool = PlayerCommandPools[plr]
                    if pool and #pool > 0 and GlobalCommandsLeft > 0 then
                        local cmd = table.remove(pool, 1)
                        _F.Execute(plr, cmd, "proximity")
                        LastHit[plr] = tick()
                    end
                end
            end
        end
    end
end)

ClickToggleBtn.MouseButton1Click:Connect(function()
    ClickEnabled = not ClickEnabled
    ClickToggleBtn.Text = ClickEnabled and "Enabled" or "Disabled"
    ClickToggleBtn.BackgroundColor3 = ClickEnabled and THEME.AccentGreen or THEME.AccentRed
    if not ClickEnabled and ClickHighlight then
        ClickHighlight:Destroy()
        ClickHighlight = nil
        ClickTarget = nil
    end
end)
ClickToggleBtn.MouseEnter:Connect(function()
    local c = ClickEnabled and THEME.AccentGreen or THEME.AccentRed
    _F.Tween(ClickToggleBtn, {BackgroundColor3 = Color3.fromRGB(math.max(0, c.R * 255 - 30), math.max(0, c.G * 255 - 30), math.max(0, c.B * 255 - 30))}, 0.2)
end)
ClickToggleBtn.MouseLeave:Connect(function()
    ClickToggleBtn.BackgroundColor3 = ClickEnabled and THEME.AccentGreen or THEME.AccentRed
end)

function _F.MakeDrag(frame)
    local drag, start, pos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            drag = true
            start = input.Position
            pos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false
                    _F.SavePositions()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - start
            frame.Position = UDim2.new(pos.X.Scale, pos.X.Offset + delta.X, pos.Y.Scale, pos.Y.Offset + delta.Y)
        end
    end)
end

_F.MakeDrag(TrollPanel)
_F.MakeDrag(CoolPanel)

_F.RefreshList()

task.spawn(function()
    while task.wait(2) do
        local newOwner = _F.GetCurrentBaseOwner()
        if newOwner ~= CurrentBaseOwner then
            _F.RefreshList()
        end
    end
end)

print("AP Loaded")
end)

function _F.findFlyingCarpet()
    local map = Workspace:FindFirstChild("Map")
    if not map then return nil end
    local carpet = map:FindFirstChild("Carpet")
    if not carpet then return nil end
    if carpet:IsA("Model") then
        if carpet.PrimaryPart then return carpet.PrimaryPart end
        for _, c in ipairs(carpet:GetChildren()) do if c:IsA("BasePart") then return c end end
    elseif carpet:IsA("BasePart") then
        return carpet
    end
    return nil
end

function _F.findClaimModel(podium)
    if not podium or not podium.Parent then return nil end
    local claim = podium:FindFirstChild("Claim")
    if claim and claim:IsA("Model") then
        if claim.PrimaryPart then return claim.PrimaryPart end
        for _, c in ipairs(claim:GetChildren()) do if c:IsA("BasePart") then return c end end
    end
    return nil
end

function _F.getTargetPodiumAndSafePosition(animalData, fallbackPos)
    if not animalData or not animalData.plot then return nil, fallbackPos end
    local plots = Workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(animalData.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil, fallbackPos end
    local safeName = (fallbackPos and fallbackPos.Y > 8.8) and "13" or "3"
    local safePod = podiums:FindFirstChild(safeName)
    local safeBase = safePod and safePod:FindFirstChild("Base")
    local safeSpawn = safeBase and safeBase:FindFirstChild("Spawn")
    return safePod, (safeSpawn and safeSpawn:IsA("BasePart") and safeSpawn.Position) or fallbackPos
end

function _F.playFullScreenFlash()
    local flashGui = Instance.new("ScreenGui")
    flashGui.Name = "AutoTPFlash"
    flashGui.ResetOnSpawn = false
    flashGui.DisplayOrder = 999999
    flashGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    flashGui.IgnoreGuiInset = true
    flashGui.Parent = PlayerGui

    local flashFrame = Instance.new("Frame")
    flashFrame.Size = UDim2.new(1, 0, 1, 0)
    flashFrame.Position = UDim2.new(0, 0, 0, 0)
    flashFrame.AnchorPoint = Vector2.new(0, 0)
    flashFrame.BackgroundColor3 = Color3.new(1, 1, 1)
    flashFrame.BackgroundTransparency = 1
    flashFrame.BorderSizePixel = 0
    flashFrame.Parent = flashGui

    local tweenIn = TweenService:Create(flashFrame, TweenInfo.new(0.075, Enum.EasingStyle.Linear), {BackgroundTransparency = 0})
    local tweenOut = TweenService:Create(flashFrame, TweenInfo.new(0.125, Enum.EasingStyle.Linear), {BackgroundTransparency = 1})
    tweenIn:Play()
    tweenIn.Completed:Connect(function()
        tweenOut:Play()
        tweenOut.Completed:Connect(function()
            flashGui:Destroy()
        end)
    end)
end

local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100)
}
local BASES_HIGH = {
    [1] = Vector3.new(-476.474853515625, 20.732906341552734, 220.94090270996094),   [5] = Vector3.new(-342.5367126464844, 20.69801902770996, 221.44737243652344),
    [2] = Vector3.new(-476.5684814453125, 20.70664405822754, 113.77315521240234),   [6] = Vector3.new(-342.8604736328125, 20.669641494750977, 113.41409301757812),
    [3] = Vector3.new(-476.8675842285156, 20.74148178100586, 6.178487777709961),    [7] = Vector3.new(-342.42108154296875, 20.687667846679688, 6.249461650848389),
    [4] = Vector3.new(-476.6324768066406, 20.744949340820312, -101.07275390625),    [8] = Vector3.new(-342.7937927246094, 20.748071670532227, -99.73458862304688)
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
function _F.getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
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

function _F.runAutoSnipe()
    if State.isTpMoving then return end
    
    if State.carpetSpeedEnabled then
        _F.setCarpetSpeed(false)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = "OFF"
            _carpetStatusLabel.TextColor3 = Theme.Error
        end
    end

    local targetPetData = nil
    if Config.AutoTPPriority then
        local bestEntry = nil
        local cache = SharedState.AllAnimalsCache
        if cache and type(cache) == "table" then
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.name:lower() == searchName and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
                if bestEntry then break end
            end
            if not bestEntry then
                for _, a in ipairs(cache) do
                    if a and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
            end
        end
        if bestEntry then
            targetPetData = bestEntry
        else
            if not SharedState.SelectedPetData then _F.ShowNotification("ERROR","No target selected!"); return end
            targetPetData = SharedState.SelectedPetData.animalData
        end
    else
        if not SharedState.SelectedPetData then _F.ShowNotification("ERROR","No target selected!"); return end
        targetPetData = SharedState.SelectedPetData.animalData
    end
    if not targetPetData then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then return end
    
    State.isTpMoving = true
    isTpMoving = State.isTpMoving
    
    local targetPart = _F.findAdorneeGlobal(targetPetData)
    if not targetPart then 
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        return 
    end
    
    local exactPos = targetPart.Position
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")

    if carpet then hum:EquipTool(carpet) end
    task.wait(0.01)
    local isSecondFloor = exactPos.Y > 10
    local plotIndex = _F.getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]
    
    local minHeight = 50
    local targetHeight = math.max(targetBasePos.Y, minHeight)

    local jumpStart = tick()
    while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 2 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 280, hrp.AssemblyLinearVelocity.Z)
        RunService.Heartbeat:Wait()
    end

    for i = 1, 8 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        if (hrp.Position - targetBasePos).Magnitude > 3 then
            hrp.CFrame = CFrame.new(targetBasePos)
            task.wait(0.03)
        end
    end

    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetPart.Position - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        for i = 1, 4 do
            if (hrp.Position - bestSpot).Magnitude > 3 then
                hrp.CFrame = CFrame.new(bestSpot)
                task.wait(0.03)
            end
        end
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
    if isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot) then
        _F.walkForward(0.25)
        task.wait(0.25)
        task.wait(0.10) -- Confirma conclusão do _F.walkForward antes do clone
        _F.instantClone()
        while _G.isCloning do task.wait() end
        task.wait(0.05) -- Delay para o clone ser concluído no servidor
        task.wait(0.15) -- Confirmação do clone antes de TP pro brainrot
    end
    task.wait(0.10)

    if carpet then hum:EquipTool(carpet) end

    local verticalDiff = targetPart.Position.Y - hrp.Position.Y

    if verticalDiff > 2 then
        local airPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 8, targetPart.Position.Z)
        
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 5, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        
        RunService.Heartbeat:Wait()
        
        for i = 1, 10 do
            if not LocalPlayer:GetAttribute("Stealing") then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
                hrp.CFrame = CFrame.new(airPos)
                task.wait(0.05)
            end
        end
        
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    else
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
            if (hrp.Position - targetPart.Position).Magnitude > 3 then
                hrp.CFrame = CFrame.new(targetPart.Position)
                task.wait(0.05)
            end
            task.wait(0.05)
        end
    end
    
    State.isTpMoving = false
    isTpMoving = State.isTpMoving
end
_G.runAutoSnipe = _F.runAutoSnipe

;(function()
    local function isInsideStealHitbox()
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        local petData = SharedState.SelectedPetData
        if not petData then return false end
        local animalData = petData.animalData or petData
        if not animalData or not animalData.plot then return false end

        local Plots = Workspace:FindFirstChild("Plots")
        if not Plots then return false end
        local plot = Plots:FindFirstChild(animalData.plot)
        if not plot then return false end

        local stealHitbox = plot:FindFirstChild("StealHitbox")
        if not stealHitbox then return false end

        local playerPos = hrp.Position

        local function checkPart(part)
            local cf = part.CFrame
            local sz = part.Size
            local lp = cf:PointToObjectSpace(playerPos)
            return math.abs(lp.X) <= sz.X/2
               and math.abs(lp.Y) <= sz.Y/2
               and math.abs(lp.Z) <= sz.Z/2
        end

        if stealHitbox:IsA("BasePart") then
            return checkPart(stealHitbox)
        elseif stealHitbox:IsA("Model") then
            for _, part in ipairs(stealHitbox:GetDescendants()) do
                if part:IsA("BasePart") and part.Transparency < 1 then
                    if checkPart(part) then return true end
                end
            end
        end
        return false
    end

    local _autoBackThread = nil
    local _autoBackStealConn = nil
    local _autoBackCharConn = nil
    local _autoBackHealthConn = nil
    local _autoBackImpulseConn = nil
    local _autoBackPhysConn = nil
    local _teleportingBelow = false
    local _forceAutoBackInstantCount = 0
    local _autoBackLastHealth = nil
    local _autoBackLastDamageTrigger = 0
    local _autoBackLastPhysTrigger = 0
    local _autoBackLastImpulseTrigger = 0
    local _autoBackArmedUntil = 0

    local function _autoBackForce(times)
        _forceAutoBackInstantCount = math.max(_forceAutoBackInstantCount, math.max(tonumber(times) or 1, 1))
    end

    local function _autoBackIsArmed()
        return Config.AutoBack
            and (not State.isTpMoving)
            and (_autoBackArmedUntil > 0)
            and (tick() <= _autoBackArmedUntil)
            and (LocalPlayer:GetAttribute("Stealing") ~= true)
    end

    local function _autoBackIsInAnyBaseArea()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local best = math.huge
        for _, plot in ipairs(plots:GetChildren()) do
            if plot:IsA("Model") then
                local ok, p = pcall(function() return plot:GetPivot().Position end)
                if ok and p then
                    local d = (Vector2.new(hrp.Position.X, hrp.Position.Z) - Vector2.new(p.X, p.Z)).Magnitude
                    if d < best then best = d end
                end
            end
        end
        return best < 160
    end

    local function stopAutoBack()
        if _autoBackThread then task.cancel(_autoBackThread); _autoBackThread = nil end
        if _autoBackStealConn then _autoBackStealConn:Disconnect(); _autoBackStealConn = nil end
        if _autoBackCharConn then _autoBackCharConn:Disconnect(); _autoBackCharConn = nil end
        if _autoBackHealthConn then _autoBackHealthConn:Disconnect(); _autoBackHealthConn = nil end
        if _autoBackImpulseConn then _autoBackImpulseConn:Disconnect(); _autoBackImpulseConn = nil end
        if _autoBackPhysConn then _autoBackPhysConn:Disconnect(); _autoBackPhysConn = nil end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bp = hrp:FindFirstChild("TP_BodyPosition")
            if bp then bp:Destroy() end
        end
        _teleportingBelow = false
        _autoBackLastHealth = nil
        _autoBackArmedUntil = 0
    end

    local function getAutoBackTarget()
        local petData = SharedState.SelectedPetData
        if not petData then return nil end
        local animalData = petData.animalData or petData
        local part = _F.findAdorneeGlobal(animalData)
        if not part then return nil end
        return part.Position, animalData
    end

    local function teleportBelowPet()
        if _teleportingBelow then return end
        _teleportingBelow = true
        pcall(function()
            local targetPos, animalData = getAutoBackTarget()
            if not targetPos then return end

            local char = LocalPlayer.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            local petX, petY, petZ = targetPos.X, targetPos.Y, targetPos.Z
            local playerY = hrp.Position.Y

            if playerY > 25 and petY > 25 then
                hrp.CFrame = CFrame.new(targetPos)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
                _teleportingBelow = false
                return
            end

            if playerY >= 8.8 and petY < 8.8 then return end
            if playerY <= 8.8 and petY > 24 then return end

            local carpetName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
            local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
            if carpet and hum then hum:EquipTool(carpet); task.wait(0.1) end

            local targetY
            if petY > 22 or (playerY < 8.8 and petY >= 8.8) then
                targetY = petY - 6.8
            else
                local rp = RaycastParams.new()
                rp.FilterDescendantsInstances = {char}
                rp.FilterType = Enum.RaycastFilterType.Exclude
                local res = Workspace:Raycast(Vector3.new(petX, petY + 6, petZ), Vector3.new(0, -60, 0), rp)
                if res and (petY - res.Position.Y) <= 10 then
                    -- 1st floor: ficamos rente ao pet, não acima dele
                    targetY = res.Position.Y + 1.8
                else
                    targetY = petY - 2.5
                end
            end

            local tPos = Vector3.new(petX, targetY, petZ)
            local dist = (Vector3.new(hrp.Position.X, targetY, hrp.Position.Z) - tPos).Magnitude

            if dist > 1.5 or math.abs(hrp.Position.Y - targetY) > 2 then
                hrp.CFrame = CFrame.new(petX, targetY, petZ)
                hrp.AssemblyLinearVelocity = Vector3.zero
                hrp.AssemblyAngularVelocity = Vector3.zero
            end

            local bp = hrp:FindFirstChild("TP_BodyPosition")
            if not bp then
                bp = Instance.new("BodyPosition")
                bp.Name = "TP_BodyPosition"
                bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bp.P = 10000
                bp.D = 500
                bp.Parent = hrp
            end
            bp.Position = tPos
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        end)
        _teleportingBelow = false
    end

    local function startAutoBack()
        stopAutoBack()

        local lastStealing = (LocalPlayer:GetAttribute("Stealing") == true)

        local function attachCharacter(c)
            if _autoBackHealthConn then _autoBackHealthConn:Disconnect(); _autoBackHealthConn = nil end
            _autoBackLastHealth = nil
            local hum = c and c:FindFirstChildOfClass("Humanoid")
            if not hum then
                local ok, h = pcall(function() return c:WaitForChild("Humanoid", 2) end)
                if ok then hum = h end
            end
            if not hum then return end
            _autoBackLastHealth = hum.Health
            _autoBackHealthConn = hum.HealthChanged:Connect(function(newHealth)
                if not Config.AutoBack then _autoBackLastHealth = newHealth; return end
                if State.isTpMoving then _autoBackLastHealth = newHealth; return end
                local last = _autoBackLastHealth
                if last and newHealth < last then
                    local now = tick()
                    if now - _autoBackLastDamageTrigger >= 0.25 then
                        _autoBackLastDamageTrigger = now
                        if _autoBackIsArmed() then
                            _autoBackForce(1)
                        end
                    end
                end
                _autoBackLastHealth = newHealth
            end)
        end

        if LocalPlayer.Character then
            attachCharacter(LocalPlayer.Character)
        end
        _autoBackCharConn = LocalPlayer.CharacterAdded:Connect(function(c)
            task.wait(0.1)
            attachCharacter(c)
        end)

        _autoBackStealConn = LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
            local nowStealing = (LocalPlayer:GetAttribute("Stealing") == true)
            if nowStealing and not lastStealing then
                _autoBackArmedUntil = 0
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local bp = hrp:FindFirstChild("TP_BodyPosition")
                    if bp then bp:Destroy() end
                    task.spawn(function()
                        task.wait(0.1)
                        local rp = RaycastParams.new()
                        rp.FilterDescendantsInstances = {char}
                        rp.FilterType = Enum.RaycastFilterType.Exclude
                        local res = Workspace:Raycast(
                            Vector3.new(hrp.Position.X, hrp.Position.Y, hrp.Position.Z),
                            Vector3.new(0, -200, 0), rp
                        )
                        if res and (hrp.Position.Y - res.Position.Y) <= 10 then
                            local floorY = res.Position.Y + 3.1
                            hrp.CFrame = CFrame.new(hrp.Position.X, floorY, hrp.Position.Z)
                        end
                    end)
                end
            elseif (not nowStealing) and lastStealing then
                task.spawn(function()
                    task.wait(0.15)
                    if not Config.AutoBack then return end
                    if State.isTpMoving then return end
                    if _autoBackIsInAnyBaseArea() then
                        _autoBackArmedUntil = 0
                        return
                    end
                    _autoBackArmedUntil = tick() + 12
                    _autoBackForce(1)
                end)
            end
            lastStealing = nowStealing
        end)

        local lastTeleportTime = 0

        if not _autoBackImpulseConn then
            pcall(function()
                local pkg = ReplicatedStorage:FindFirstChild("Packages")
                local net = pkg and pkg:FindFirstChild("Net")
                local applyImp = net and net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    _autoBackImpulseConn = applyImp.OnClientEvent:Connect(function()
                        if not Config.AutoBack then return end
                        if State.isTpMoving then return end
                        local now = tick()
                        if now - _autoBackLastImpulseTrigger < 0.25 then return end
                        _autoBackLastImpulseTrigger = now
                        if _autoBackIsArmed() then
                            _autoBackForce(1)
                        end
                    end)
                end
            end)
        end

        _autoBackPhysConn = RunService.Heartbeat:Connect(function()
            if not Config.AutoBack then return end
            if State.isTpMoving then return end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end
            local stealing = (LocalPlayer:GetAttribute("Stealing") == true)
            if stealing then return end

            local velocity = hrp.AssemblyLinearVelocity
            local state = hum:GetState()
            local abnormal = (velocity.Y > 150) or (state == Enum.HumanoidStateType.Physics) or (hum.Sit == true)
            if not abnormal then return end

            local now = tick()
            if now - _autoBackLastPhysTrigger < 1.5 then return end
            _autoBackLastPhysTrigger = now
            if _autoBackIsArmed() then
                _autoBackForce(1)
            end
        end)

        _autoBackThread = task.spawn(function()
            while Config.AutoBack do
                pcall(function()
                    local stealing = LocalPlayer:GetAttribute("Stealing")
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    if stealing == true then
                        local bp = hrp:FindFirstChild("TP_BodyPosition")
                        if bp then bp:Destroy() end
                        return
                    end

                    local hasBP = hrp:FindFirstChild("TP_BodyPosition") ~= nil
                    local targetPos = getAutoBackTarget()
                    local inHitbox = isInsideStealHitbox()
                    local selected = SharedState.SelectedPetData
                    local selectedAnimal = selected and (selected.animalData or selected)
                    local targetPlotOpen = false
                    if selectedAnimal and selectedAnimal.plot and _G._isTargetPlotUnlocked then
                        targetPlotOpen = (_G._isTargetPlotUnlocked(selectedAnimal.plot) == true)
                    end

                    local forceInstantNow = (_forceAutoBackInstantCount or 0) > 0
                    local canAutoBackNow = forceInstantNow or (inHitbox and not targetPlotOpen)
                    if not hasBP and not _teleportingBelow and targetPos and canAutoBackNow then
                        local now = os.clock()
                        local delay = forceInstantNow and 0 or 0.05
                        if now - lastTeleportTime >= delay then
                            teleportBelowPet()
                            if forceInstantNow and _forceAutoBackInstantCount > 0 then
                                _forceAutoBackInstantCount = _forceAutoBackInstantCount - 1
                            end
                            lastTeleportTime = now
                        end
                    end
                end)
                task.wait(0.01)
            end
            stopAutoBack()
        end)
    end

    if not Config.AutoBack then Config.AutoBack = false end

    _G.isInsideStealHitbox = isInsideStealHitbox
    _G.startAutoBack = startAutoBack
    _G.stopAutoBack = stopAutoBack
    _G.forceAutoBackInstant = function(times)
        _autoBackForce(times)
    end

    if Config.AutoBack then startAutoBack() end
end)()

function _F.executeReset()
    _F.ShowNotification("RESET", "Reiniciando personagem...")
    local plr = LocalPlayer
    if not plr then return end

    task.spawn(function()
        pcall(function()
            local char = plr.Character
            if not char then return end

            local hum = char:FindFirstChildWhichIsA("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Dead) end

            char:ClearAllChildren()

            local dummy = Instance.new("Model")
            dummy.Parent = Workspace
            plr.Character = dummy
            plr.Character = char
            dummy:Destroy()
        end)
    end)
end

task.spawn(function()
    local function checkSteal(gui)
        if not Config.AutoKickOnSteal then return end
        local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
        if txt and string.find(txt, "You stole") then
            _F.kickPlayer()
        end
    end
    PlayerGui.DescendantAdded:Connect(function(gui)
        checkSteal(gui)
        if gui:IsA("TextLabel") or gui:IsA("TextButton") then
            gui:GetPropertyChangedSignal("Text"):Connect(function()
                checkSteal(gui)
            end)
        end
    end)
    for _, gui in ipairs(PlayerGui:GetDescendants()) do
        checkSteal(gui)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    -- M key: open/close Priority List GUI
    if input.KeyCode == Enum.KeyCode.M then
        local pg = PlayerGui:FindFirstChild("PriorityListGUI")
        if pg then
            pg.Enabled = not pg.Enabled
            if pg.Enabled and SharedState.RefreshPriorityGUI then
                SharedState.RefreshPriorityGUI()
            end
        end
        return
    end

    local tpKey = _F.safeKeyCode(Config.TpSettings.TpKey, Enum.KeyCode.T)
    local cloneKey = _F.safeKeyCode(Config.TpSettings.CloneKey, Enum.KeyCode.V)
    local carpetKey = _F.safeKeyCode(Config.TpSettings.CarpetSpeedKey, Enum.KeyCode.Q)
    local stealSpeedKey = _F.safeKeyCode(Config.StealSpeedKey, Enum.KeyCode.Z)
    local resetKey = _F.safeKeyCode(Config.ResetKey, Enum.KeyCode.X)
    local ragdollKey = _F.safeKeyCode(Config.RagdollSelfKey, Enum.KeyCode.R)

    if input.KeyCode == tpKey then
        if _G._activePinConn then _G._activePinConn:Disconnect(); _G._activePinConn = nil end
        if _G._activePlat and _G._activePlat.Parent then _G._activePlat:Destroy(); _G._activePlat = nil end
        if _G.tpToBestBrainrot then pcall(_G.tpToBestBrainrot) else pcall(_F.runAutoSnipe) end
    end

    if input.KeyCode == cloneKey then
        if _G._activePinConn then _G._activePinConn:Disconnect(); _G._activePinConn = nil end
        if _G._activePlat and _G._activePlat.Parent then _G._activePlat:Destroy(); _G._activePlat = nil end
        _F.instantClone()
    end
    
    if input.KeyCode == carpetKey then
        carpetSpeedEnabled = not carpetSpeedEnabled
        _F.setCarpetSpeed(carpetSpeedEnabled)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = carpetSpeedEnabled and "ON" or "OFF"
            _carpetStatusLabel.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.Error
        end
        _F.ShowNotification("CARPET SPEED", carpetSpeedEnabled and ("ON  |  "..Config.TpSettings.Tool.."  |  140") or "OFF")
    end

    if input.KeyCode == stealSpeedKey then
        if SharedState.StealSpeedToggleFunc then
            SharedState.StealSpeedToggleFunc()
        end
    end

    if input.KeyCode == resetKey then
        _F.executeReset()
    end
    
    if input.KeyCode == ragdollKey then
        task.spawn(function()
            if _G.runAdminCommand then
                if _G.runAdminCommand(LocalPlayer, "ragdoll") then
                    _F.ShowNotification("RAGDOLL SELF", "Triggered")
                else
                    _F.ShowNotification("RAGDOLL SELF", "Failed")
                end
            else
                _F.ShowNotification("RAGDOLL SELF", "Function not available")
            end
        end)
    end

end)

local settingsGui = UI.settingsGui

settingsGui = Instance.new("ScreenGui")
settingsGui.Name = "SettingsUI"; settingsGui.ResetOnSpawn = false
settingsGui.Parent = PlayerGui; settingsGui.Enabled = false

local sFrame = Instance.new("Frame")
sFrame.Size = UDim2.new(0, 300, 0, 650)
sFrame.Position = UDim2.new(Config.Positions.Settings.X, 0, Config.Positions.Settings.Y, 0)
sFrame.BackgroundColor3 = Theme.Background; sFrame.BackgroundTransparency = 0.05
sFrame.BorderSizePixel = 0; sFrame.ClipsDescendants = true; sFrame.Parent = settingsGui


Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 12)
local sStroke = Instance.new("UIStroke", sFrame)
sStroke.Color = Theme.Accent2; sStroke.Thickness = 1.5; sStroke.Transparency = 0.3
_F.CreateGradient(sStroke)
task.defer(function() if addRacetrackBorder then addRacetrackBorder(sFrame, Theme.Accent1, 4) end end)
task.defer(function() applyIceToPanel(sFrame, 9, 8) end)

local sHeader = Instance.new("Frame", sFrame)
sHeader.Size = UDim2.new(1,0,0,40); sHeader.BackgroundTransparency = 1
_F.MakeDraggable(sHeader, sFrame, "Settings") 
local sTitle = Instance.new("TextLabel", sHeader)
sTitle.Size = UDim2.new(1,-20,1,0); sTitle.Position = UDim2.new(0,15,0,0)
sTitle.BackgroundTransparency = 1; sTitle.Text = "SETTINGS"
sTitle.Font = Enum.Font.GothamBlack; sTitle.TextSize = 16
sTitle.TextColor3 = Color3.fromRGB(190, 240, 255); sTitle.TextXAlignment = Enum.TextXAlignment.Left

local sList = Instance.new("ScrollingFrame", sFrame)
sList.Size = UDim2.new(1,-20,1,-50); sList.Position = UDim2.new(0,10,0,45)
sList.BackgroundTransparency = 1; sList.BorderSizePixel = 0
sList.ScrollBarThickness = 0; sList.ScrollBarImageColor3 = Theme.Accent1

local sLayout = Instance.new("UIListLayout", sList)
sLayout.Padding = UDim.new(0,8); sLayout.SortOrder = Enum.SortOrder.LayoutOrder

function _F.CreateToggleSwitch(parent, initialState, callback)
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,20); sw.Position = UDim2.new(1,-50,0.5,-10)
    sw.BackgroundColor3 = initialState and Theme.Success or Theme.SurfaceHighlight
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
        local tc = isOn and Theme.Success or Theme.SurfaceHighlight
        TweenService:Create(dot, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position=tp}):Play()
        TweenService:Create(sw,  TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3=tc}):Play()
    end
    btn.MouseButton1Click:Connect(function() callback(not isOn, SetState) end)
    return {Set=SetState, Container=sw}
end

function _F.CreateRow(text, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,height or 34); row.BackgroundColor3 = Theme.Surface
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium; lbl.TextColor3 = Theme.TextPrimary
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = sList; return row
end

function _F.CreateSectionHeader(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = sList
    
    local accent = Instance.new("Frame", row)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 4, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent1
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 2)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Accent1
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1, -80, 0, 1)
    line.Position = UDim2.new(0, 75, 0.5, 0)
    line.BackgroundColor3 = Theme.Accent1
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    
    return row
end

_F.CreateRow("Auto TP on Script Load")
_F.CreateToggleSwitch(sList:FindFirstChildOfClass("Frame"), Config.TpSettings.TpOnLoad, function(ns, set)
    set(ns); Config.TpSettings.TpOnLoad = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO TP ON LOAD", ns and "ENABLED" or "DISABLED")
end)

local rMinGen = _F.CreateRow("Min Gen for Auto TP")
local minGenBox = Instance.new("TextBox", rMinGen)
minGenBox.Size = UDim2.new(0, 100, 0, 24)
minGenBox.Position = UDim2.new(1, -110, 0.5, -12)
minGenBox.BackgroundColor3 = Theme.SurfaceHighlight
minGenBox.Text = tostring(Config.TpSettings.MinGenForTp or "")
minGenBox.Font = Enum.Font.Gotham
minGenBox.TextSize = 11
minGenBox.TextColor3 = Theme.TextPrimary
minGenBox.PlaceholderText = "e.g. 5k, 1m, 1b"
Instance.new("UICorner", minGenBox).CornerRadius = UDim.new(0, 4)
minGenBox.FocusLost:Connect(function()
    local raw = minGenBox.Text:gsub("%s", "")
    Config.TpSettings.MinGenForTp = (raw == "" and "" or raw)
    _F.SaveConfig()
    _F.ShowNotification("MIN GEN FOR TP", Config.TpSettings.MinGenForTp == "" and "No minimum" or "Min: " .. (Config.TpSettings.MinGenForTp or ""))
end)


local rTrace = _F.CreateRow("Tracer Best Brainrot")
_F.CreateToggleSwitch(rTrace, Config.TracerEnabled, function(ns, set)
    set(ns); Config.TracerEnabled = ns; _F.SaveConfig()
    _F.ShowNotification("TRACER", ns and "ENABLED" or "DISABLED")
end)

local rLineToBase = _F.CreateRow("Line to base")
_F.CreateToggleSwitch(rLineToBase, Config.LineToBase, function(ns, set)
    set(ns); Config.LineToBase = ns; _F.SaveConfig()
    if not ns and _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
    _F.ShowNotification("LINE TO BASE", ns and "ENABLED" or "DISABLED")
end)

local rXray = _F.CreateRow("X-Ray")
_F.CreateToggleSwitch(rXray, Config.XrayEnabled, function(ns, set)
    set(ns); Config.XrayEnabled = ns; if ns then _F.enableXray() else _F.disableXray() end; _F.SaveConfig()
    _F.ShowNotification("X-RAY", ns and "ENABLED" or "DISABLED")
end)

_F.CreateSectionHeader("Auto TP")
local toolOptions = {"Flying Carpet", "Cupid's Wings", "Santa's Sleigh", "Witch's Broom"}
local toolSwitches = {}
for _, toolName in ipairs(toolOptions) do
    local r = _F.CreateRow(toolName)
    local ts = _F.CreateToggleSwitch(r, Config.TpSettings.Tool==toolName, function(rs, set)
        if rs then
            Config.TpSettings.Tool=toolName; _F.SaveConfig(); set(true)
            for n, sw in pairs(toolSwitches) do if n~=toolName then sw.Set(false) end end
            _F.ShowNotification("TP TOOL", toolName)
        else
            set(Config.TpSettings.Tool==toolName)
        end
    end)
    toolSwitches[toolName] = ts
end

local rSpeed = _F.CreateRow("Teleport Delay (1=Fast)")
local speedCont = Instance.new("Frame", rSpeed)
speedCont.Size = UDim2.new(0,100,0,24); speedCont.Position = UDim2.new(1,-110,0.5,-12); speedCont.BackgroundTransparency=1
local speedBtns = {}
for i = 1, 4 do
    local b = Instance.new("TextButton", speedCont)
    b.Size = UDim2.new(0.22,0,1,0); b.Position = UDim2.new((i-1)*0.26,0,0,0)
    local act = Config.TpSettings.Speed==i
    b.BackgroundColor3 = act and Theme.Accent1 or Theme.SurfaceHighlight
    b.Text = tostring(i); b.TextColor3 = act and Color3.new(0,0,0) or Theme.TextPrimary
    b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function()
        Config.TpSettings.Speed=i; _F.SaveConfig()
        for idx, btn in ipairs(speedBtns) do
            local a=(idx==i); btn.BackgroundColor3=a and Theme.Accent1 or Theme.SurfaceHighlight
            btn.TextColor3=a and Color3.new(0,0,0) or Theme.TextPrimary
        end
        _F.ShowNotification("TP SPEED", "Set to " .. tostring(i))
    end)
    table.insert(speedBtns,b)
end

local rBind = _F.CreateRow("TP Keybind")
local bBind = Instance.new("TextButton", rBind)
bBind.Size=UDim2.new(0,60,0,24); bBind.Position=UDim2.new(1,-70,0.5,-12)
bBind.BackgroundColor3=Theme.SurfaceHighlight; bBind.Text=Config.TpSettings.TpKey
bBind.Font=Enum.Font.GothamBold; bBind.TextColor3=Theme.TextPrimary; bBind.TextSize=12
Instance.new("UICorner",bBind).CornerRadius=UDim.new(0,4)
bBind.MouseButton1Click:Connect(function()
    bBind.Text="..."; bBind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.TpKey=inp.KeyCode.Name; bBind.Text=inp.KeyCode.Name
            bBind.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("TP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rBindClone = _F.CreateRow("Auto Clone Keybind")
local bBindClone = Instance.new("TextButton", rBindClone)
bBindClone.Size=UDim2.new(0,60,0,24); bBindClone.Position=UDim2.new(1,-70,0.5,-12)
bBindClone.BackgroundColor3=Theme.SurfaceHighlight; bBindClone.Text=Config.TpSettings.CloneKey
bBindClone.Font=Enum.Font.GothamBold; bBindClone.TextColor3=Theme.TextPrimary; bBindClone.TextSize=12
Instance.new("UICorner",bBindClone).CornerRadius=UDim.new(0,4)
bBindClone.MouseButton1Click:Connect(function()
    bBindClone.Text="..."; bBindClone.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CloneKey=inp.KeyCode.Name; bBindClone.Text=inp.KeyCode.Name
            bBindClone.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("CLONE KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

_F.CreateSectionHeader("CARPET SPEED")
local rCarpetBind = _F.CreateRow("Carpet Speed Keybind")
local bCarpet = Instance.new("TextButton", rCarpetBind)
bCarpet.Size=UDim2.new(0,60,0,24); bCarpet.Position=UDim2.new(1,-70,0.5,-12)
bCarpet.BackgroundColor3=Theme.SurfaceHighlight; bCarpet.Text=Config.TpSettings.CarpetSpeedKey
bCarpet.Font=Enum.Font.GothamBold; bCarpet.TextColor3=Theme.TextPrimary; bCarpet.TextSize=12
Instance.new("UICorner",bCarpet).CornerRadius=UDim.new(0,4)
bCarpet.MouseButton1Click:Connect(function()
    bCarpet.Text="..."; bCarpet.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CarpetSpeedKey=inp.KeyCode.Name; bCarpet.Text=inp.KeyCode.Name
            bCarpet.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("CARPET SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rRagdollSelf = _F.CreateRow("Ragdoll Self Keybind")
local bRagdollSelf = Instance.new("TextButton", rRagdollSelf)
bRagdollSelf.Size=UDim2.new(0,60,0,24); bRagdollSelf.Position=UDim2.new(1,-70,0.5,-12)
bRagdollSelf.BackgroundColor3=Theme.SurfaceHighlight; bRagdollSelf.Text=Config.RagdollSelfKey ~= "" and Config.RagdollSelfKey or "NONE"
bRagdollSelf.Font=Enum.Font.GothamBold; bRagdollSelf.TextColor3=Theme.TextPrimary; bRagdollSelf.TextSize=12
Instance.new("UICorner",bRagdollSelf).CornerRadius=UDim.new(0,4)
bRagdollSelf.MouseButton1Click:Connect(function()
    bRagdollSelf.Text="..."; bRagdollSelf.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.RagdollSelfKey=inp.KeyCode.Name; bRagdollSelf.Text=inp.KeyCode.Name
            bRagdollSelf.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("RAGDOLL SELF KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rCarpetStatus = _F.CreateRow("Carpet Speed Status")
local carpetStatusLbl = Instance.new("TextLabel", rCarpetStatus)
carpetStatusLbl.Size=UDim2.new(0,50,0,20); carpetStatusLbl.Position=UDim2.new(1,-60,0.5,-10)
carpetStatusLbl.BackgroundTransparency=1
carpetStatusLbl.Text=carpetSpeedEnabled and "ON" or "OFF"
carpetStatusLbl.TextColor3=carpetSpeedEnabled and Theme.Success or Theme.Error
carpetStatusLbl.Font=Enum.Font.GothamBlack; carpetStatusLbl.TextSize=13
carpetStatusLbl.TextXAlignment=Enum.TextXAlignment.Right
_carpetStatusLabel = carpetStatusLbl

_F.CreateSectionHeader("MOVEMENT")
local rInfJump = _F.CreateRow("Infinite Jump")
_F.CreateToggleSwitch(rInfJump, infiniteJumpEnabled, function(ns, set)
    set(ns); _F.setInfiniteJump(ns)
    _F.ShowNotification("INFINITE JUMP", ns and "ENABLED" or "DISABLED")
end)
local rAutoStealSpeed = _F.CreateRow("Auto Steal Speed")
_F.CreateToggleSwitch(rAutoStealSpeed, Config.AutoStealSpeed, function(ns, set)
    set(ns); Config.AutoStealSpeed = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO STEAL SPEED", ns and "ENABLED" or "DISABLED")
end)

local rStealSpeedKey = _F.CreateRow("Steal Speed Keybind")
local bStealSpeedKey = Instance.new("TextButton", rStealSpeedKey)
bStealSpeedKey.Size=UDim2.new(0,60,0,24); bStealSpeedKey.Position=UDim2.new(1,-70,0.5,-12)
bStealSpeedKey.BackgroundColor3=Theme.SurfaceHighlight; bStealSpeedKey.Text=Config.StealSpeedKey
bStealSpeedKey.Font=Enum.Font.GothamBold; bStealSpeedKey.TextColor3=Theme.TextPrimary; bStealSpeedKey.TextSize=12
Instance.new("UICorner",bStealSpeedKey).CornerRadius=UDim.new(0,4)
bStealSpeedKey.MouseButton1Click:Connect(function()
    bStealSpeedKey.Text="..."; bStealSpeedKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.StealSpeedKey=inp.KeyCode.Name; bStealSpeedKey.Text=inp.KeyCode.Name
            bStealSpeedKey.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("STEAL SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

_F.CreateSectionHeader("AUTO UNLOCK")
local rAutoUnlock = _F.CreateRow("Auto Unlock on Steal")
_F.CreateToggleSwitch(rAutoUnlock, Config.AutoUnlockOnSteal, function(ns, set)
    set(ns); Config.AutoUnlockOnSteal = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO UNLOCK", ns and "ENABLED" or "DISABLED")
end)

local rShowUnlockHUD = _F.CreateRow("Show Unlock Buttons HUD")
_F.CreateToggleSwitch(rShowUnlockHUD, Config.ShowUnlockButtonsHUD, function(ns, set)
    set(ns); Config.ShowUnlockButtonsHUD = ns; _F.SaveConfig()
    local hudGui = PlayerGui:FindFirstChild("YinStatusHUD")
    if hudGui then
        local main = hudGui:FindFirstChild("Main")
        local unlockContainer = main and main:FindFirstChild("UnlockButtonsContainer")
        if main and unlockContainer then
            unlockContainer.Visible = ns
            if ns then
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 100)
                }):Play()
            else
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 50)
                }):Play()
            end
        end
    end
end)
_F.CreateSectionHeader("ANTI-RAGDOLL")
local arV1SetRef, arV2SetRef = {}, {}
local rAr = _F.CreateRow("V1")
_F.CreateToggleSwitch(rAr, Config.AntiRagdoll > 0, function(ns, set)
    arV1SetRef.fn = set
    if ns and Config.AntiRagdollV2 then
        set(false)
        _F.ShowNotification("ANTI-RAGDOLL", "DISABLE V2 FIRST")
        return
    end
    set(ns)
    local mode = ns and 1 or 0
    Config.AntiRagdoll = mode
    if ns then
        Config.AntiRagdollV2 = false
        if arV2SetRef.fn then arV2SetRef.fn(false) end
    end
    _F.SaveConfig()
    _F.startAntiRagdoll(mode)
    if ns then _F.startAntiRagdollV2(false) end
    _F.ShowNotification("ANTI-RAGDOLL V1", ns and "ENABLED" or "DISABLED")
end)
local rArV2 = _F.CreateRow("V2")
_F.CreateToggleSwitch(rArV2, Config.AntiRagdollV2, function(ns, set)
    arV2SetRef.fn = set
    if ns and Config.AntiRagdoll > 0 then
        set(false)
        _F.ShowNotification("ANTI-RAGDOLL", "DISABLE V1 FIRST")
        return
    end
    set(ns)
    Config.AntiRagdollV2 = ns
    if ns then
        Config.AntiRagdoll = 0
        _F.SaveConfig()
        if arV1SetRef.fn then arV1SetRef.fn(false) end
        _F.startAntiRagdoll(0)
        _F.startAntiRagdollV2(true)
    else
        _F.SaveConfig()
        _F.startAntiRagdollV2(false)
    end
    _F.ShowNotification("ANTI-RAGDOLL V2", ns and "ENABLED" or "DISABLED")
end)













_F.CreateSectionHeader("ESP")

local rXray = _F.CreateRow("Base X-Ray")
local xrayToggle = _F.CreateToggleSwitch(rXray, xrayEnabled, function(ns, set)
    set(ns)
    if ns then
        _F.enableXray()
        xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
            if xrayEnabled and obj:IsA("BasePart") and obj.Anchored and _F.isBaseWall(obj) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end)
    else
        _F.disableXray()
    end
    Config.XrayEnabled = ns; _F.SaveConfig()
    _F.ShowNotification("BASE X-RAY", ns and "ENABLED" or "DISABLED")
end)
local playerESPToggleRef = {setFn=nil}
local rPlayerEsp = _F.CreateRow("Player ESP (Hides Names)")
_F.CreateToggleSwitch(rPlayerEsp, Config.PlayerESP, function(ns, set)
    set(ns); Config.PlayerESP = ns; _F.SaveConfig()
    if playerESPToggleRef.setFn then playerESPToggleRef.setFn(ns) end
    _F.ShowNotification("PLAYER ESP", ns and "ENABLED" or "DISABLED")
end)

local espToggleRef = {enabled=true, setFn=nil}
local rEsp = _F.CreateRow("Brainrot ESP")
local espSettingsSwitch = _F.CreateToggleSwitch(rEsp, Config.BrainrotESP, function(ns, set)
    set(ns); Config.BrainrotESP = ns; _F.SaveConfig()
    if espToggleRef.setFn then espToggleRef.setFn(ns) end
    _F.ShowNotification("BRAINROT ESP", ns and "ENABLED" or "DISABLED")
end)
local subspaceMineESPToggleRef = {setFn=nil}
local rSubspaceMineEsp = _F.CreateRow("Subspace Mine Esp")
_F.CreateToggleSwitch(rSubspaceMineEsp, Config.SubspaceMineESP, function(ns, set)
    set(ns); Config.SubspaceMineESP = ns; _F.SaveConfig()
    if subspaceMineESPToggleRef.setFn then subspaceMineESPToggleRef.setFn(ns) end
    _F.ShowNotification("SUBSPACE MINE ESP", ns and "ENABLED" or "DISABLED")
end)
_F.CreateSectionHeader("AUTO STEAL DEFAULTS")
local nearestToggleRef = {}
local highestToggleRef = {}
local priorityToggleRef = {}
local autoTPPriorityToggleRef = {setFn = nil}

local rDefaultNearest = _F.CreateRow("Default To Nearest")
local nearestToggleSwitch = _F.CreateToggleSwitch(rDefaultNearest, Config.DefaultToNearest, function(ns, set)
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
            _F.ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToNearest = false
        set(false)
    end
    _F.SaveConfig()
    _F.ShowNotification("DEFAULT TO NEAREST", ns and "ENABLED" or "DISABLED")
end)
nearestToggleRef.setFn = nearestToggleSwitch.Set

local rDefaultHighest = _F.CreateRow("Default To Highest")
local highestToggleSwitch = _F.CreateToggleSwitch(rDefaultHighest, Config.DefaultToHighest, function(ns, set)
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
            _F.ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToHighest = false
        set(false)
    end
    _F.SaveConfig()
    _F.ShowNotification("DEFAULT TO HIGHEST", ns and "ENABLED" or "DISABLED")
end)
highestToggleRef.setFn = highestToggleSwitch.Set

local rDefaultPriority = _F.CreateRow("Default To Priority")
local priorityToggleSwitch = _F.CreateToggleSwitch(rDefaultPriority, Config.DefaultToPriority, function(ns, set)
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
            _F.ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToPriority = false
        set(false)
    end
    _F.SaveConfig()
    _F.ShowNotification("DEFAULT TO PRIORITY", ns and "ENABLED" or "DISABLED")
end)
priorityToggleRef.setFn = priorityToggleSwitch.Set

_F.CreateSectionHeader("AUTOMATION")
local rAutoInvis = _F.CreateRow("Auto Invis During Steal")
_F.CreateToggleSwitch(rAutoInvis, Config.AutoInvisDuringSteal, function(ns, set)
    set(ns); Config.AutoInvisDuringSteal = ns; _G.AutoInvisDuringSteal = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO INVIS", ns and "ENABLED" or "DISABLED")
end)
local rAutoTpFail = _F.CreateRow("Auto TP on Failed Steal")
_F.CreateToggleSwitch(rAutoTpFail, Config.AutoTpOnFailedSteal, function(ns, set)
    set(ns); Config.AutoTpOnFailedSteal = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO TP ON FAILED STEAL", ns and "ENABLED" or "DISABLED")
end)
local rAutoTpPriority = _F.CreateRow("Auto TP Priority Mode")
local autoTPPriorityToggleSwitch = _F.CreateToggleSwitch(rAutoTpPriority, Config.AutoTPPriority, function(ns, set)
    set(ns); Config.AutoTPPriority = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO TP PRIORITY", ns and "PRIORITY" or "HIGHEST")
end)
autoTPPriorityToggleRef.setFn = autoTPPriorityToggleSwitch.Set
local rAutoKick = _F.CreateRow("Auto-Kick on Steal")
_F.CreateToggleSwitch(rAutoKick, Config.AutoKickOnSteal, function(ns, set)
    set(ns); Config.AutoKickOnSteal = ns; _F.SaveConfig()
    _F.ShowNotification("AUTO-KICK ON STEAL", ns and "ENABLED" or "DISABLED")
end)

_F.CreateSectionHeader("HIDE GUIS")
local rHideAdminPanel = _F.CreateRow("Hide Admin Panel GUI")
_F.CreateToggleSwitch(rHideAdminPanel, Config.HideAdminPanel, function(ns, set)
    set(ns); Config.HideAdminPanel = ns; _F.SaveConfig()
    local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
    if adUI then adUI.Enabled = not ns end
    _F.ShowNotification("HIDE ADMIN PANEL", ns and "ENABLED" or "DISABLED")
end)
local rHideAdminToolsPanel = _F.CreateRow("Hide Admin Tools Panel GUI")
_F.CreateToggleSwitch(rHideAdminToolsPanel, Config.ShowAdminToolsPanel == false, function(ns, set)
    set(ns); Config.ShowAdminToolsPanel = not ns; _F.SaveConfig()
    local toolsGui = PlayerGui:FindFirstChild("XiAdminToolsPanel")
    if toolsGui then toolsGui.Enabled = not ns end
    if SharedState.AdminToolsSetEnabled then pcall(SharedState.AdminToolsSetEnabled, not ns) end
    if ns then
        Config.ClickToAP = false; State.ProximityAPActive = false; _F.SaveConfig()
        if SharedState.UpdateClickToAPButton then SharedState.UpdateClickToAPButton() end
        if SharedState.UpdateProximityAPButton then SharedState.UpdateProximityAPButton() end
    end
    _F.ShowNotification("HIDE ADMIN TOOLS", ns and "ENABLED" or "DISABLED")
end)
local rHideAutoSteal = _F.CreateRow("Hide Auto Steal GUI")
_F.CreateToggleSwitch(rHideAutoSteal, Config.HideAutoSteal, function(ns, set)
    set(ns); Config.HideAutoSteal = ns; _F.SaveConfig()
    local asUI = PlayerGui:FindFirstChild("AutoStealUI")
    if asUI then asUI.Enabled = not ns end
    _F.ShowNotification("HIDE AUTO STEAL", ns and "ENABLED" or "DISABLED")
end)
_F.CreateSectionHeader("EXTRAS")   

local rResetKey = _F.CreateRow("Reset")
local bResetKey = Instance.new("TextButton", rResetKey)
bResetKey.Size=UDim2.new(0,60,0,24); bResetKey.Position=UDim2.new(1,-70,0.5,-12)
bResetKey.BackgroundColor3=Theme.SurfaceHighlight; bResetKey.Text=Config.ResetKey
bResetKey.Font=Enum.Font.GothamBold; bResetKey.TextColor3=Theme.TextPrimary; bResetKey.TextSize=12
Instance.new("UICorner",bResetKey).CornerRadius=UDim.new(0,4)
bResetKey.MouseButton1Click:Connect(function()
    bResetKey.Text="..."; bResetKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ResetKey=inp.KeyCode.Name; bResetKey.Text=inp.KeyCode.Name
            bResetKey.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("RESET KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rKickKey = _F.CreateRow("Kick")
local bKickKey = Instance.new("TextButton", rKickKey)
bKickKey.Size=UDim2.new(0,60,0,24); bKickKey.Position=UDim2.new(1,-70,0.5,-12)
bKickKey.BackgroundColor3=Theme.SurfaceHighlight; bKickKey.Text=Config.KickKey ~= "" and Config.KickKey or "NONE"
bKickKey.Font=Enum.Font.GothamBold; bKickKey.TextColor3=Theme.TextPrimary; bKickKey.TextSize=12
Instance.new("UICorner",bKickKey).CornerRadius=UDim.new(0,4)
bKickKey.MouseButton1Click:Connect(function()
    bKickKey.Text="..."; bKickKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.KickKey=inp.KeyCode.Name; bKickKey.Text=inp.KeyCode.Name
            bKickKey.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("KICK KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rCleanErrors = _F.CreateRow("Clean Error GUIs")
_F.CreateToggleSwitch(rCleanErrors, Config.CleanErrorGUIs, function(ns, set)
    set(ns); Config.CleanErrorGUIs = ns; _F.SaveConfig()
    _F.ShowNotification("CLEAN ERROR GUIS", ns and "ENABLED" or "DISABLED")
end)


_F.CreateSectionHeader("ADMIN PANEL")
local rClickToAP = _F.CreateRow("Click To Admin Panel")
_F.CreateToggleSwitch(rClickToAP, Config.ClickToAP, function(ns, set)
    set(ns); Config.ClickToAP = ns; _F.SaveConfig()
    _F.ShowNotification("CLICK TO AP", ns and "ENABLED" or "DISABLED")
end)
local rClickToAPSingle = _F.CreateRow("Click To AP Single Command")
_F.CreateToggleSwitch(rClickToAPSingle, Config.ClickToAPSingleCommand, function(ns, set)
    set(ns); Config.ClickToAPSingleCommand = ns; _F.SaveConfig()
    _F.ShowNotification("CLICK TO AP SINGLE", ns and "ENABLED" or "DISABLED")
end)
local rClickToAPKeybind = _F.CreateRow("Click To AP Keybind")
local bClickToAPKeybind = Instance.new("TextButton", rClickToAPKeybind)
bClickToAPKeybind.Size=UDim2.new(0,60,0,24); bClickToAPKeybind.Position=UDim2.new(1,-65,0.5,-12)
bClickToAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bClickToAPKeybind.Text=Config.ClickToAPKeybind or "L"
bClickToAPKeybind.Font=Enum.Font.GothamBold; bClickToAPKeybind.TextColor3=Theme.TextPrimary; bClickToAPKeybind.TextSize=12
Instance.new("UICorner",bClickToAPKeybind).CornerRadius=UDim.new(0,4)
bClickToAPKeybind.MouseButton1Click:Connect(function()
    bClickToAPKeybind.Text="..."; bClickToAPKeybind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ClickToAPKeybind=inp.KeyCode.Name; bClickToAPKeybind.Text=inp.KeyCode.Name
            bClickToAPKeybind.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("CLICK TO AP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)
local rProximityAPKeybind = _F.CreateRow("Proximity AP Keybind")
local bProximityAPKeybind = Instance.new("TextButton", rProximityAPKeybind)
bProximityAPKeybind.Size=UDim2.new(0,60,0,24); bProximityAPKeybind.Position=UDim2.new(1,-70,0.5,-12)
bProximityAPKeybind.BackgroundColor3=Theme.SurfaceHighlight; bProximityAPKeybind.Text=Config.ProximityAPKeybind or "P"
bProximityAPKeybind.Font=Enum.Font.GothamBold; bProximityAPKeybind.TextColor3=Theme.TextPrimary; bProximityAPKeybind.TextSize=12
Instance.new("UICorner",bProximityAPKeybind).CornerRadius=UDim.new(0,4)
bProximityAPKeybind.MouseButton1Click:Connect(function()
    bProximityAPKeybind.Text="..."; bProximityAPKeybind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ProximityAPKeybind=inp.KeyCode.Name; bProximityAPKeybind.Text=inp.KeyCode.Name
            bProximityAPKeybind.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("PROXIMITY AP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

_F.CreateSectionHeader("ALERTS")
local rAlertsEnabled = _F.CreateRow("Enable Alerts")
_F.CreateToggleSwitch(rAlertsEnabled, Config.AlertsEnabled, function(ns, set)
    set(ns); Config.AlertsEnabled = ns; _F.SaveConfig()
    _F.ShowNotification("PRIORITY ALERTS", ns and "ENABLED" or "DISABLED")
end)
local rAlertSound = _F.CreateRow("Alert Sound ID")
local soundBox = Instance.new("TextBox", rAlertSound)
soundBox.Size = UDim2.new(0, 180, 0, 24)
soundBox.Position = UDim2.new(1, -185, 0.5, -12)
soundBox.BackgroundColor3 = Theme.SurfaceHighlight
soundBox.Text = Config.AlertSoundID or "rbxassetid://6518811702"
soundBox.Font = Enum.Font.Gotham
soundBox.TextSize = 10
soundBox.TextColor3 = Theme.TextPrimary
soundBox.PlaceholderText = "Sound ID"
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 4)
soundBox.FocusLost:Connect(function()
    Config.AlertSoundID = soundBox.Text
    _F.SaveConfig()
    _F.ShowNotification("ALERT SOUND", "Updated")
end)

_F.CreateSectionHeader("JOB JOINER")
local rJoinerRow = _F.CreateRow("Job ID Joiner")
_F.CreateToggleSwitch(rJoinerRow, Config.ShowJobJoiner, function(ns, set)
    set(ns); Config.ShowJobJoiner = ns; _F.SaveConfig()
    local gui = PlayerGui:FindFirstChild("YinJobJoiner")
    if gui then gui.Enabled = Config.ShowJobJoiner end
    _F.ShowNotification("JOB ID JOINER", ns and "ENABLED" or "DISABLED")
end)
local rJoinerKey = _F.CreateRow("Job Joiner Keybind")
local bJoinerKey = Instance.new("TextButton", rJoinerKey)
bJoinerKey.Size=UDim2.new(0,60,0,24); bJoinerKey.Position=UDim2.new(1,-70,0.5,-12)
bJoinerKey.BackgroundColor3=Theme.SurfaceHighlight; bJoinerKey.Text=Config.JobJoinerKey or "J"
bJoinerKey.Font=Enum.Font.GothamBold; bJoinerKey.TextColor3=Theme.TextPrimary; bJoinerKey.TextSize=12
Instance.new("UICorner",bJoinerKey).CornerRadius=UDim.new(0,4)
bJoinerKey.MouseButton1Click:Connect(function()
    bJoinerKey.Text="..."; bJoinerKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.JobJoinerKey=inp.KeyCode.Name; bJoinerKey.Text=inp.KeyCode.Name
            bJoinerKey.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
            _F.ShowNotification("JOB JOINER KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

_F.CreateSectionHeader("PROTECTION")
local rAntiBeeDisco = _F.CreateRow("Anti-Bee & Anti-Disco")
_F.CreateToggleSwitch(rAntiBeeDisco, Config.AntiBeeDisco, function(ns, set)
    set(ns); Config.AntiBeeDisco = ns; _F.SaveConfig()
    if ns then
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Enable then
            _G.ANTI_BEE_DISCO.Enable()
        end
    else
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Disable then
            _G.ANTI_BEE_DISCO.Disable()
        end
    end
    _F.ShowNotification("ANTI-BEE & DISCO", ns and "ENABLED" or "DISABLED")
end)

_F.CreateSectionHeader("CAMERA")
local rFOV = _F.CreateRow("FOV")
local fovSliderBg = Instance.new("Frame", rFOV)
fovSliderBg.Size = UDim2.new(0, 140, 0, 5)
fovSliderBg.Position = UDim2.new(1, -200, 0.5, -2.5)
fovSliderBg.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
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
fovValLbl.Font = Enum.Font.GothamBold
fovValLbl.TextSize = 13

function _F.updateFOVSlider(val)
    val = math.clamp(val, 30, 180)
    Config.FOV = val
    _F.SaveConfig()
    fovValLbl.Text = string.format("%.1f", val)
    local pct = (val - 30) / 150
    fovFill.Size = UDim2.new(pct, 0, 1, 0)
    fovKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = val
    end
    _F.ShowNotification("FIELD OF VIEW", string.format("%.1f", val))
end
_F.updateFOVSlider(Config.FOV)

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
        _F.updateFOVSlider(30 + (p * 150))
    end
end)

_F.CreateSectionHeader("MENU")
    local rMenu = _F.CreateRow("Menu Toggle Key")
    local bMenu = Instance.new("TextButton", rMenu)
    bMenu.Size=UDim2.new(0,80,0,24); bMenu.Position=UDim2.new(1,-90,0.5,-12)
    bMenu.BackgroundColor3=Theme.SurfaceHighlight; bMenu.Text=Config.MenuKey
    bMenu.Font=Enum.Font.GothamBold; bMenu.TextColor3=Theme.TextPrimary; bMenu.TextSize=12
    Instance.new("UICorner",bMenu).CornerRadius=UDim.new(0,4)
    bMenu.MouseButton1Click:Connect(function()
        bMenu.Text="..."; bMenu.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.MenuKey=inp.KeyCode.Name; bMenu.Text=inp.KeyCode.Name
                bMenu.TextColor3=Theme.TextPrimary; _F.SaveConfig(); con:Disconnect()
                _F.ShowNotification("MENU KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)

_F.CreateSectionHeader("UI CONTROLS")
local rLock = _F.CreateRow("Lock UI Dragging")
_F.CreateToggleSwitch(rLock, Config.UILocked, function(ns, set)
    set(ns); Config.UILocked = ns; _F.SaveConfig()
    _F.ShowNotification("UI LOCK", ns and "ENABLED" or "DISABLED")
end)


local rReset = _F.CreateRow("Reset UI Positions")
local bReset = Instance.new("TextButton", rReset)
bReset.Size=UDim2.new(0,80,0,24); bReset.Position=UDim2.new(1,-90,0.5,-12)
bReset.BackgroundColor3=Theme.Error; bReset.Text="RESET"
bReset.Font=Enum.Font.GothamBold; bReset.TextColor3=Theme.TextPrimary; bReset.TextSize=12
Instance.new("UICorner",bReset).CornerRadius=UDim.new(0,4)
bReset.MouseButton1Click:Connect(function()
    Config.Positions = DefaultConfig.Positions
    _F.SaveConfig()
    _F.ShowNotification("UI RESET", "Positions restored")
    sFrame.Position = UDim2.new(DefaultConfig.Positions.Settings.X, 0, DefaultConfig.Positions.Settings.Y, 0)
    if PlayerGui:FindFirstChild("AutoStealUI") then
        PlayerGui.AutoStealUI.Frame.Position = UDim2.new(DefaultConfig.Positions.AutoSteal.X, 0, DefaultConfig.Positions.AutoSteal.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiAdminPanel") and PlayerGui.XiAdminPanel:FindFirstChild("Frame") then
        PlayerGui.XiAdminPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminPanel.X, 0, DefaultConfig.Positions.AdminPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiAdminToolsPanel") and PlayerGui.XiAdminToolsPanel:FindFirstChild("Frame") then
        PlayerGui.XiAdminToolsPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminToolsPanel.X, 0, DefaultConfig.Positions.AdminToolsPanel.Y, 0)
    end
    _F.ShowNotification("UI RESET", "Positions restored to default")
end)

function _F.updateSettingsCanvasSize()
    local contentHeight = sLayout.AbsoluteContentSize.Y
    sList.CanvasSize = UDim2.new(0, 0, 0, math.max(contentHeight + 20, sList.AbsoluteSize.Y))
end

sLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(_F.updateSettingsCanvasSize)
task.defer(_F.updateSettingsCanvasSize)


    sList.ScrollBarThickness = 0
    sList.ScrollingEnabled = true
    sList.ElasticBehavior = Enum.ElasticBehavior.Always

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == _F.safeKeyCode(Config.MenuKey, Enum.KeyCode.LeftControl) then
            if _G.YinSettingsUI and _G.YinSettingsUI.panel then
                _G.YinSettingsUI.panel.Visible = not _G.YinSettingsUI.panel.Visible
            else
                settingsGui.Enabled = not settingsGui.Enabled
            end
        end
        if input.KeyCode == _F.safeKeyCode(Config.KickKey, nil) then
            _F.kickPlayer()
        end
        if input.KeyCode == _F.safeKeyCode(Config.RagdollSelfKey, nil) then
            if not isOnCooldown("ragdoll") then
                if runAdminCommand(LocalPlayer, "ragdoll") then
                    activeCooldowns["ragdoll"] = tick()
                    setGlobalVisualCooldown("ragdoll")
                    _F.ShowNotification("RAGDOLL SELF", "Ragdolled " .. LocalPlayer.Name)
                end
            else
                _F.ShowNotification("RAGDOLL SELF", "Ragdoll on cooldown")
            end
        end
        if input.KeyCode == _F.safeKeyCode(Config.ProximityAPKeybind, nil) then
            ProximityAPActive = not ProximityAPActive
            if _G.updateAdminToolsPanel then pcall(_G.updateAdminToolsPanel) end
            _F.ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end
        if input.KeyCode == _F.safeKeyCode(Config.ClickToAPKeybind, Enum.KeyCode.L) then
            Config.ClickToAP = not Config.ClickToAP
            _F.SaveConfig()
            if _G.updateAdminToolsPanel then pcall(_G.updateAdminToolsPanel) end
            _F.ShowNotification("CLICK TO AP", Config.ClickToAP and "ENABLED" or "DISABLED")
        end
        if input.KeyCode == _F.safeKeyCode(Config.JobJoinerKey, nil) then
            local joinerGui = PlayerGui:FindFirstChild("YinJobJoiner")
            if joinerGui then
                Config.ShowJobJoiner = not Config.ShowJobJoiner
                joinerGui.Enabled = Config.ShowJobJoiner
                _F.SaveConfig()
                _F.ShowNotification("JOB ID JOINER", Config.ShowJobJoiner and "OPENED" or "CLOSED")
            end
        end
    end)


task.spawn(function()
    task.wait(1)
    if Config.HideAdminPanel then
        local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
        if adUI then adUI.Enabled = false end
    end
    if Config.ShowAdminToolsPanel == false then
        local toolsUI = PlayerGui:FindFirstChild("XiAdminToolsPanel")
        if toolsUI then toolsUI.Enabled = false end
    end
    if Config.HideAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = false end
    end
    if Config.HideStatusHUD then
        local g = PlayerGui:FindFirstChild("YinStatusHUD")
        if g then g.Enabled = false end
    end
end)

function _F.parseMinGen(str)
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
        local started = false
        local minGen = _F.parseMinGen(Config.TpSettings.MinGenForTp)

        local function tryStart()
            if started then return true end
            if State and State.isTpMoving then return false end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (char and hrp and hum and hum.Health > 0) then return false end

            if not SharedState.SelectedPetData then
                local ok, top = pcall(function()
                    if getTopPets then
                        return getTopPets(1, true)
                    end
                    return {}
                end)
                if ok and top and #top > 0 then
                    local g = top[1].generation or 0
                    if minGen <= 0 or g >= minGen then
                        SharedState.SelectedPetData = {
                            animalData = {
                                plot = top[1].plotName,
                                slot = tostring(top[1].podiumId),
                                name = top[1].petName
                            }
                        }
                    end
                end
            end

            local cache = SharedState.AllAnimalsCache
            if not ((cache and #cache > 0) or SharedState.SelectedPetData) then return false end

            if minGen > 0 and cache and #cache > 0 and not SharedState.SelectedPetData then
                if ((cache[1] and cache[1].genValue) or 0) < minGen then
                    return false
                end
            end

            if _G.tpToBestBrainrot then
                pcall(_G.tpToBestBrainrot)
            else
                pcall(_F.runAutoSnipe)
            end
            started = true
            return true
        end

        local conn
        conn = LocalPlayer.CharacterAdded:Connect(function()
            task.defer(tryStart)
        end)

        for _ = 1, 900 do
            if tryStart() then break end
            RunService.Heartbeat:Wait()
        end

        if conn then conn:Disconnect() end
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
            _F.triggerClosestUnlock(nil, 19)
        end
    elseif wasStealing then
        if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and _G.invisibleStealEnabled then
            _G.toggleInvisibleSteal()
        end
    end
end)

task.spawn(function()
    local oldSS = PlayerGui:FindFirstChild("StealSpeedUI")
    if oldSS then oldSS:Destroy() end

    local MIN_SPEED, MAX_SPEED = 5, 30
    local stealSpeedEnabled = false
    local STEAL_SPEED = math.clamp(math.floor((tonumber(Config.StealSpeed) or 20) + 0.5), MIN_SPEED, MAX_SPEED)
    if Config.StealSpeed ~= STEAL_SPEED then
        Config.StealSpeed = STEAL_SPEED
        _F.SaveConfig()
    end
    local stealConn = nil

    local function doDisable()
        stealSpeedEnabled = false
        if stealConn then stealConn:Disconnect(); stealConn = nil end
    end

    local function doEnable()
        stealSpeedEnabled = true
        if stealConn then stealConn:Disconnect(); stealConn = nil end
        stealConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
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

    SharedState.applyStealSpeedValue = function(s)
        s = math.clamp(math.floor((tonumber(s) or STEAL_SPEED) + 0.5), MIN_SPEED, MAX_SPEED)
        STEAL_SPEED = s
        Config.StealSpeed = s
        _F.SaveConfig()
        if SharedState._refreshMiniStealSpeedSlider then
            pcall(SharedState._refreshMiniStealSpeedSlider)
        end
    end

    SharedState.DisableStealSpeed = function()
        doDisable()
    end

    SharedState.StealSpeedToggleFunc = function()
        if stealSpeedEnabled then doDisable() else doEnable() end
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
                doEnable()
            elseif not hasSteal and stealSpeedEnabled then
                doDisable()
            end
        end
    end)
end)

task.spawn(function()
    local brainrotESPEnabled = Config.BrainrotESP
    local brainrotESPFolder = Instance.new("Folder")
    brainrotESPFolder.Name = "YinBrainrotESP"
    brainrotESPFolder.Parent = Workspace
    local brainrotBillboards = {}
    local hiddenOverheads = {}
    local MUT_COLORS = {
        Cursed = Color3.fromRGB(170, 170, 170),
        Gold = Color3.fromRGB(170, 170, 170),
        Diamond = Color3.fromRGB(170, 170, 170),
        YinYang = Color3.fromRGB(170, 170, 170),
        Rainbow = Color3.fromRGB(170, 170, 170),
        Lava = Color3.fromRGB(170, 170, 170),
        Candy = Color3.fromRGB(170, 170, 170),
        Bloodrot = Color3.fromRGB(170, 170, 170),
        Radioactive = Color3.fromRGB(170, 170, 170),
        Divine = Color3.fromRGB(170, 170, 170)
    }
    
    local function createBrainrotBillboard(data)
        local bb = Instance.new("BillboardGui")
        bb.Name = "BrainrotESP_" .. data.uid
        bb.Size = UDim2.new(0, 160, 0, 38)
        bb.StudsOffset = Vector3.new(0, 1.8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.MaxDistance = 3000
        
        local hasMut = data.mutation and data.mutation ~= "None" and data.mutation ~= "N/A"
        local color = hasMut and (MUT_COLORS[data.mutation] or Color3.fromRGB(175, 175, 175)) or Color3.fromRGB(175, 175, 175)
        
        local container = Instance.new("Frame", bb)
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        container.BackgroundTransparency = 0.5
        container.BorderSizePixel = 0
        Instance.new("UICorner", container).CornerRadius = UDim.new(0, 4)
        
        local stroke = Instance.new("UIStroke", container)
        stroke.Color = color
        stroke.Thickness = 1.5
        stroke.Transparency = 0.2
        
        local nameLabel = Instance.new("TextLabel", container)
        nameLabel.Size = UDim2.new(1, -6, 0, 18)
        nameLabel.Position = UDim2.new(0, 3, 0, 2)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextSize = 13
        nameLabel.TextColor3 = color
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 20, 50)
        nameLabel.Text = (data.name or data.petName) or "???"
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        local genLabel = Instance.new("TextLabel", container)
        genLabel.Size = UDim2.new(1, -6, 0, 14)
        genLabel.Position = UDim2.new(0, 3, 0, 20)
        genLabel.BackgroundTransparency = 1
        genLabel.Font = Enum.Font.GothamBold
        genLabel.TextSize = 11
        genLabel.TextColor3 = Color3.fromRGB(240, 248, 255)
        genLabel.TextStrokeTransparency = 0
        genLabel.TextStrokeColor3 = Color3.fromRGB(10, 5, 18)
        genLabel.Text = data.genText or ""
        genLabel.TextXAlignment = Enum.TextXAlignment.Center
        
        if hasMut then
            local mutBadge = Instance.new("TextLabel", bb)
            mutBadge.Size = UDim2.new(0, 60, 0, 14)
            mutBadge.Position = UDim2.new(0.5, -30, 0, -16)
            mutBadge.BackgroundColor3 = color
            mutBadge.BackgroundTransparency = 0.3
            mutBadge.Font = Enum.Font.GothamBlack
            mutBadge.TextSize = 9
            mutBadge.TextColor3 = Color3.fromRGB(240, 248, 255)
            mutBadge.TextStrokeTransparency = 0
            mutBadge.TextStrokeColor3 = Color3.fromRGB(10, 5, 18)
            mutBadge.Text = data.mutation:upper()
            Instance.new("UICorner", mutBadge).CornerRadius = UDim.new(0, 3)
        end
        
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
                        adornee = _F.findAdorneeGlobal(data)
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
						local sa = math.clamp(_G.SinkSliderValue or Config.SinkSliderValue or 2.5, 0.5, 10)
						local cf = root.CFrame - Vector3.new(0, sa, 0)
						oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
						oldRoot.AssemblyLinearVelocity = root.AssemblyLinearVelocity; oldRoot.CanCollide = false
						lastSetPosition = oldRoot.Position
					end
				end
			end)
		end
	end

    local invisGui = Instance.new("ScreenGui")
    invisGui.Name = "YinInvisPanel"
    invisGui.ResetOnSpawn = false
    -- Dedicated Invisible Steal panel removed: keep controls in Mini Actions / Settings only.
    invisGui.Enabled = false

    local iFrame = Instance.new("Frame", invisGui)
    iFrame.Size = UDim2.new(0, 250, 0, 260)
    iFrame.Position = UDim2.new(Config.Positions.InvisPanel.X, 0, Config.Positions.InvisPanel.Y, 0)
    iFrame.BackgroundColor3 = Theme.Background
    iFrame.BackgroundTransparency = 0.05
    Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 12)
    local iStroke = Instance.new("UIStroke", iFrame)
    iStroke.Color = Theme.Accent2
    iStroke.Thickness = 1.5
    iStroke.Transparency = 0.3
    _F.CreateGradient(iStroke)
    task.defer(function() if addRacetrackBorder then addRacetrackBorder(iFrame, Theme.Accent1, 3) end end)
    task.defer(function() applyIceToPanel(iFrame, 5, 4) end)

    local iHeader = Instance.new("Frame", iFrame)
    iHeader.Size = UDim2.new(1, 0, 0, 35)
    iHeader.BackgroundTransparency = 1
    _F.MakeDraggable(iHeader, iFrame, "InvisPanel")

    local iTitle = Instance.new("TextLabel", iHeader)
    iTitle.Size = UDim2.new(1, -15, 1, 0)
    iTitle.Position = UDim2.new(0, 15, 0, 0)
    iTitle.BackgroundTransparency = 1
    iTitle.Text = "INVISIBLE STEAL"
    iTitle.Font = Enum.Font.GothamBlack
    iTitle.TextSize = 14
    iTitle.TextColor3 = Color3.fromRGB(240, 248, 255)
    iTitle.TextXAlignment = Enum.TextXAlignment.Left

    local iContainer = Instance.new("Frame", iFrame)
    iContainer.Size = UDim2.new(1, -20, 1, -40)
    iContainer.Position = UDim2.new(0, 10, 0, 35)
    iContainer.BackgroundTransparency = 1
    local iLayout = Instance.new("UIListLayout", iContainer)
    iLayout.Padding = UDim.new(0, 8)
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateIRow(height)
        local r = Instance.new("Frame", iContainer)
        r.Size = UDim2.new(1, 0, 0, height or 30)
        r.BackgroundTransparency = 1
        return r
    end

    local row1 = CreateIRow(30)
    local lbl1 = Instance.new("TextLabel", row1)
    lbl1.Size = UDim2.new(0.6, 0, 1, 0)
    lbl1.BackgroundTransparency = 1
    lbl1.Text = "Toggle Invis"
    lbl1.TextColor3 = Theme.TextPrimary
    lbl1.Font = Enum.Font.GothamBold
    lbl1.TextSize = 12
    lbl1.TextXAlignment = Enum.TextXAlignment.Left

    local btnInvis = Instance.new("TextButton", row1)
    btnInvis.Size = UDim2.new(0, 40, 0, 24)
    btnInvis.Position = UDim2.new(1, -40, 0.5, -12)
    btnInvis.BackgroundColor3 = Theme.SurfaceHighlight
    btnInvis.Text = "OFF"
    btnInvis.Font = Enum.Font.GothamBold
    btnInvis.TextSize = 11
    btnInvis.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnInvis).CornerRadius = UDim.new(0, 6)

    local keyBtn = Instance.new("TextButton", row1)
    keyBtn.Size = UDim2.new(0, 40, 0, 24)
    keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
    keyBtn.BackgroundColor3 = Theme.Surface
    keyBtn.Text = Config.InvisToggleKey
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextColor3 = Theme.Accent1
    keyBtn.TextSize = 11
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 6)
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."
        local c
        c = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                Config.InvisToggleKey = i.KeyCode.Name
                _G.INVISIBLE_STEAL_KEY = i.KeyCode
                keyBtn.Text = i.KeyCode.Name
                _F.SaveConfig()
                c:Disconnect()
            end
        end)
    end)

    local row2 = CreateIRow(30)
    local lbl2 = Instance.new("TextLabel", row2)
    lbl2.Size = UDim2.new(0.6, 0, 1, 0)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = "Auto Fix Lagback"
    lbl2.TextColor3 = Theme.TextPrimary
    lbl2.Font = Enum.Font.GothamBold
    lbl2.TextSize = 12
    lbl2.TextXAlignment = Enum.TextXAlignment.Left

    local btnFix = Instance.new("TextButton", row2)
    btnFix.Size = UDim2.new(0, 50, 0, 24)
    btnFix.Position = UDim2.new(1, -50, 0.5, -12)
    btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
    btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
    btnFix.Font = Enum.Font.GothamBold
    btnFix.TextSize = 11
    btnFix.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnFix).CornerRadius = UDim.new(0, 6)
    btnFix.MouseButton1Click:Connect(function()
        _G.AutoRecoverLagback = not _G.AutoRecoverLagback
        Config.AutoRecoverLagback = _G.AutoRecoverLagback
        _F.SaveConfig()
        btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
        btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
    end)

    local function CreateFancySlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundTransparency = 1
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.TextSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = name .. ": " .. default
            local slideBg = Instance.new("Frame", frame)
            slideBg.Size = UDim2.new(1, 0, 0, 6)
            slideBg.Position = UDim2.new(0, 0, 0, 25)
            slideBg.BackgroundColor3 = Color3.fromRGB(50, 20, 80)
            Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
            slideBg.Parent = frame
            local fill = Instance.new("Frame", slideBg)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(120, 50, 220)
            fill.ZIndex = 12
            fill.Parent = slideBg
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame", slideBg)
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.ZIndex = 13
            knob.Parent = slideBg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local function update(inputX)
                local p = math.clamp((inputX - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
                local val = min + (p * (max - min))
                if max > 100 then val = math.floor(val) else val = math.floor(val*10)/10 end
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                label.Text = name .. ": " .. val
                callback(val)
            end
            local dragging = false
            slideBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input.Position.X)
                end
            end)
            local p = (default - min)/(max-min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            return frame
    end

    local rotationSliderManuallyChanged = false
    CreateFancySlider(iContainer, "Rotation", 0, 360, Config.InvisStealAngle, function(v)
        rotationSliderManuallyChanged = true
        Config.InvisStealAngle = v
        _G.InvisStealAngle = v
        _F.SaveConfig()
    end)

    CreateFancySlider(iContainer, "Depth", 0.5, 10, Config.SinkSliderValue, function(v)
        Config.SinkSliderValue = v
        _G.SinkSliderValue = v
        _F.SaveConfig()
    end)


    local function updateVisualState(on)
        if btnInvis then
            btnInvis.Text = on and "ON" or "OFF"
            btnInvis.BackgroundColor3 = on and Theme.Success or Theme.SurfaceHighlight
        end
        if _G.updateMovementPanelInvisVisual then
            pcall(_G.updateMovementPanelInvisVisual, on)
        end
    end

    btnInvis.MouseButton1Click:Connect(function()
		if _G.toggleInvisibleSteal then
			pcall(_G.toggleInvisibleSteal)
			updateVisualState(_G.invisibleStealEnabled or false)
		end
	end)

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
    _F.ShowNotification("ANTI-BEE & DISCO", "Enabled")
end
function SharedState.ANTI_BEE_DISCO.Disable()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    SharedState.FOV_MANAGER:Pop()
    _F.ShowNotification("ANTI-BEE & DISCO", "Disabled")
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
    -- Destroi e reconstroi o HUD (chamado tambem pelo applyTheme)
    local function buildHUD()
        local existing = PlayerGui:FindFirstChild("YinStatusHUD")
        if existing then existing:Destroy() end

        local hudGui = Instance.new("ScreenGui")
        hudGui.Name = "YinStatusHUD"
        hudGui.ResetOnSpawn = false
        hudGui.DisplayOrder = 10
        hudGui.Parent = PlayerGui

        -- Painel principal - preto neon igual à screenshot
        local main = Instance.new("Frame", hudGui)
        main.Name = "Main"
        main.Size = UDim2.new(0, 460, 0, 52)
        main.Position = UDim2.new(0.5, -230, 1, -125)
        main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        main.BackgroundTransparency = 0
        main.BorderSizePixel = 0
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

        -- Gradiente escuro sutil
        local iceGrad = Instance.new("UIGradient", main)
        iceGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(22, 25, 34)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(16, 18, 24)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(22, 25, 34)),
        }
        iceGrad.Rotation = 90

        -- Borda neon cyan grossa
        local mainStroke = Instance.new("UIStroke", main)
        mainStroke.Color = Color3.fromRGB(0, 220, 255)
        mainStroke.Thickness = 2.8
        mainStroke.Transparency = 0.0

        -- Copos de neve - movimento livre natural, flotando em todas direcoes
        local TS = game:GetService("TweenService")
        local snowData = {
            {x=0.08, y=0.2, sz=6, delay=0.0},
            {x=0.18, y=0.6, sz=5, delay=0.9},
            {x=0.28, y=0.3, sz=7, delay=1.8},
            {x=0.38, y=0.7, sz=5, delay=0.3},
            {x=0.48, y=0.4, sz=6, delay=2.4},
            {x=0.58, y=0.8, sz=7, delay=1.1},
            {x=0.68, y=0.2, sz=5, delay=3.2},
            {x=0.76, y=0.5, sz=6, delay=0.7},
            {x=0.85, y=0.7, sz=5, delay=2.0},
            {x=0.93, y=0.3, sz=7, delay=1.5},
        }
        for i, d in ipairs(snowData) do
            local flake = Instance.new("TextLabel", main)
            flake.Size = UDim2.new(0, d.sz + 2, 0, d.sz + 2)
            flake.Position = UDim2.new(d.x, 0, d.y, 0)
            flake.BackgroundTransparency = 1
            flake.Text = "❄"
            flake.Font = Enum.Font.GothamBold
            flake.TextSize = d.sz
            flake.TextColor3 = Color3.fromRGB(200, 230, 255)
            flake.TextTransparency = 0.25
            flake.ZIndex = 3
            flake.BorderSizePixel = 0

            -- posicao atual do floco
            local curX = d.x
            local curY = d.y

            local function moveToNext()
                if not flake.Parent then return end

                -- novo destino aleatorio dentro do frame
                local nextX = math.clamp(curX + (math.random() - 0.5) * 0.35, 0.02, 0.96)
                local nextY = math.clamp(curY + (math.random() - 0.5) * 0.6, 0.05, 0.90)
                local dur   = math.random(28, 55) * 0.1  -- 2.8s a 5.5s por segmento

                local tween = TS:Create(flake,
                    TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {
                        Position = UDim2.new(nextX, 0, nextY, 0),
                        Rotation = math.random(-20, 20),
                        TextTransparency = math.random(10, 35) * 0.01,
                    }
                )
                curX = nextX
                curY = nextY

                tween:Play()
                tween.Completed:Connect(function()
                    task.wait(math.random(1, 4) * 0.1)
                    moveToNext()
                end)
            end

            task.spawn(function()
                task.wait(d.delay)
                moveToNext()
            end)
        end


        -- Titulo: ICEMAN V2 (branco neon)
        local title = Instance.new("TextLabel", main)
        title.Name = "Title"
        title.Size = UDim2.new(1, -190, 0, 22)
        title.Position = UDim2.new(0, 12, 0, 6)
        title.BackgroundTransparency = 1
        title.RichText = true
        title.Text = "ICEMAN V2"
        title.Font = Enum.Font.GothamBlack
        title.TextSize = 14
        title.TextColor3 = Color3.fromRGB(240, 248, 255)
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.TextStrokeTransparency = 0.6
        title.TextStrokeColor3 = Color3.fromRGB(0, 220, 255)
        title.ZIndex = 5

        -- Subtitulo: gg/semenhub (cyan claro)
        local sub = Instance.new("TextLabel", main)
        sub.Name = "Sub"
        sub.Size = UDim2.new(1, -190, 0, 14)
        sub.Position = UDim2.new(0, 12, 0, 30)
        sub.BackgroundTransparency = 1
        sub.Text = ".gg/semenhub"
        sub.Font = Enum.Font.GothamMedium
        sub.TextSize = 10
        sub.TextColor3 = Color3.fromRGB(130, 200, 230)
        sub.TextXAlignment = Enum.TextXAlignment.Left
        sub.ZIndex = 5

        -- Barra separadora vertical neon
        local fpsSeparator = Instance.new("Frame", main)
        fpsSeparator.Size = UDim2.new(0, 1.5, 0, 28)
        fpsSeparator.Position = UDim2.new(1, -165, 0.5, -14)
        fpsSeparator.BackgroundColor3 = Color3.fromRGB(0, 220, 255)
        fpsSeparator.BackgroundTransparency = 0.1
        fpsSeparator.BorderSizePixel = 0
        fpsSeparator.ZIndex = 5

        -- FPS (direita, cima) - branco com valor neon
        local fpsLabel = Instance.new("TextLabel", main)
        fpsLabel.Name = "FpsLabel"
        fpsLabel.Size = UDim2.new(0, 148, 0, 16)
        fpsLabel.Position = UDim2.new(1, -158, 0, 9)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.RichText = true
        fpsLabel.Text = "FPS: --"
        fpsLabel.Font = Enum.Font.GothamBold
        fpsLabel.TextSize = 11
        fpsLabel.TextColor3 = Color3.fromRGB(200, 230, 240)
        fpsLabel.TextXAlignment = Enum.TextXAlignment.Right
        fpsLabel.ZIndex = 5

        -- PING (direita, baixo) - branco com valor neon
        local pingLabel = Instance.new("TextLabel", main)
        pingLabel.Name = "PingLabel"
        pingLabel.Size = UDim2.new(0, 148, 0, 16)
        pingLabel.Position = UDim2.new(1, -158, 0, 27)
        pingLabel.BackgroundTransparency = 1
        pingLabel.RichText = true
        pingLabel.Text = "PING: --ms"
        pingLabel.Font = Enum.Font.GothamBold
        pingLabel.TextSize = 11
        pingLabel.TextColor3 = Color3.fromRGB(200, 230, 240)
        pingLabel.TextXAlignment = Enum.TextXAlignment.Right
        pingLabel.ZIndex = 5

        local fr2, ac3 = 0, 0
        RunService.Heartbeat:Connect(function(dt)
            fr2 += 1; ac3 += dt
            if ac3 >= 1 then
                local ping3 = math.floor(LocalPlayer:GetNetworkPing()*1000)
                local fc3 = fr2>=50 and "rgb(80,255,150)" or (fr2>=30 and "rgb(255,210,80)" or "rgb(255,80,80)")
                local pc3 = ping3<100 and "rgb(80,255,150)" or (ping3<200 and "rgb(255,210,80)" or "rgb(255,80,80)")
                fpsLabel.Text = string.format("FPS: <font color='%s'><b>%d</b></font>", fc3, fr2)
                pingLabel.Text = string.format("PING: <font color='%s'><b>%dms</b></font>", pc3, ping3)
                fr2, ac3 = 0, 0
            end
        end)

        -- Unlock buttons (1 2 3)
        local unlockContainer = Instance.new("Frame", hudGui)
        unlockContainer.Name = "UnlockButtonsContainer"
        unlockContainer.Size = UDim2.new(0, 170, 0, 44)
        unlockContainer.Position = UDim2.new(0.5, -85, 1, -178)
        unlockContainer.BackgroundTransparency = 1
        unlockContainer.Visible = Config.ShowUnlockButtonsHUD or false
        unlockContainer.ZIndex = 10

        local uLayout = Instance.new("UIListLayout", unlockContainer)
        uLayout.FillDirection = Enum.FillDirection.Horizontal
        uLayout.Padding = UDim.new(0, 12)
        uLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

        local unlockLevels = {-2, 15, 32}
        for i = 1, 3 do
            local btn = Instance.new("TextButton", unlockContainer)
            btn.Size = UDim2.new(0, 48, 0, 40)
            btn.BackgroundColor3 = Theme.Surface
            btn.BackgroundTransparency = 0.2
            btn.Text = tostring(i)
            btn.Font = Enum.Font.GothamBlack
            btn.TextSize = 16
            btn.TextColor3 = Theme.TextPrimary
            btn.BorderSizePixel = 0
            btn.AutoButtonColor = false
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            local bs = Instance.new("UIStroke", btn)
            bs.Color = Theme.Accent1
            bs.Thickness = 1.2
            bs.Transparency = 0.45
            local lvl = unlockLevels[i]
            btn.MouseEnter:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency=0}):Play()
                TweenService:Create(bs, TweenInfo.new(0.1), {Transparency=0.1}):Play()
            end)
            btn.MouseLeave:Connect(function()
                TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundTransparency=0.2}):Play()
                TweenService:Create(bs, TweenInfo.new(0.1), {Transparency=0.45}):Play()
            end)
            btn.MouseButton1Click:Connect(function()
                _F.triggerClosestUnlock(lvl)
                _F.ShowNotification("UNLOCK", "Level "..i)
            end)
        end

        -- Racetrack border
        task.defer(function()
            if addRacetrackBorder then addRacetrackBorder(main, Color3.fromRGB(0, 220, 255), 4) end
        end)

        return hudGui
    end

    buildHUD()
    _G.rebuildStatusHUD = buildHUD
end)


task.spawn(function()
    local playerESPEnabled = Config.PlayerESP
    local playerBillboards = {}
    
    local function makePlayerBillboard(player)
        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_"..tostring(player.UserId)
        bb.Size = UDim2.new(0, 100, 0, 20)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.ResetOnSpawn = false
        local nameLbl = Instance.new("TextLabel", bb)
        nameLbl.Size = UDim2.new(1,0,1,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBlack; nameLbl.TextSize = 13
        nameLbl.TextColor3 = Theme.Accent1
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        nameLbl.Text = player.Name
        return bb, nameLbl
    end

    local function getHRP(player)
        local char = player.Character; if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function createOrRefresh(player)
        if player == LocalPlayer then return end
        local hrp = getHRP(player); if not hrp then return end
        local hum = player.Character:FindFirstChild("Humanoid")
        
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end

        local uid = player.UserId
        local entry = playerBillboards[uid]
        if not entry or not entry.bb or not entry.bb.Parent then
            if entry and entry.bb then pcall(function() entry.bb:Destroy() end) end
            local bb, nameLbl = makePlayerBillboard(player)
            bb.Adornee = hrp; bb.Parent = hrp
            playerBillboards[uid] = {bb=bb, nameLbl=nameLbl, player=player}
        else
            if entry.bb.Adornee ~= hrp then entry.bb.Adornee = hrp; entry.bb.Parent = hrp end
        end
    end

    local function clearAll()
        for uid, entry in pairs(playerBillboards) do
            if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
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

    task.spawn(function()
        while true do
            task.wait(0.5)
            if playerESPEnabled then
            for uid, entry in pairs(playerBillboards) do
                if not Players:GetPlayerByUserId(uid) then
                    if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
                    playerBillboards[uid] = nil
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(createOrRefresh, player)
                end
            end
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
    local function makeBlacklistESP(player)
        local char = player.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local old = char:FindFirstChild("YinBlacklistESP")
        if old then old:Destroy() end

        local msg = Config.BlacklistMsg or "BLOCKED"

        local bb = Instance.new("BillboardGui")
        bb.Name                  = "YinBlacklistESP"
        bb.Size                  = UDim2.new(0, 120, 0, 22)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 5.5, 0)  -- above regular ESP (2.8)
        bb.AlwaysOnTop           = true
        bb.LightInfluence        = 0
        bb.ResetOnSpawn          = false
        bb.Adornee               = hrp
        bb.Parent                = hrp

        local bg = Instance.new("Frame", bb)
        bg.Size                  = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3      = Theme.Background or Color3.fromRGB(18, 20, 26)
        bg.BackgroundTransparency = 0.15
        bg.BorderSizePixel       = 0
        Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)
        local bgStroke = Instance.new("UIStroke", bg)
        bgStroke.Color           = Theme.Error or Color3.fromRGB(255, 60, 60)
        bgStroke.Thickness       = 1.5
        bgStroke.Transparency    = 0.1

        local lbl = Instance.new("TextLabel", bg)
        lbl.Name                 = "MsgLbl"
        lbl.Size                 = UDim2.new(1, -8, 1, 0)
        lbl.Position             = UDim2.new(0, 4, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text                 = "🚫 " .. msg
        lbl.Font                 = Enum.Font.GothamBlack
        lbl.TextSize             = 11
        lbl.TextColor3           = Theme.Error or Color3.fromRGB(255, 80, 80)
        lbl.TextStrokeTransparency = 0.5
        lbl.TextStrokeColor3     = Color3.fromRGB(10, 5, 18)
        lbl.TextXAlignment       = Enum.TextXAlignment.Center
        lbl.TextTruncate         = Enum.TextTruncate.AtEnd

        char.AncestryChanged:Connect(function()
            if not char.Parent then pcall(function() bb:Destroy() end) end
        end)
    end

    local function removeBlacklistESP(player)
        local char = player.Character
        if char then
            local bb = char:FindFirstChild("YinBlacklistESP")
            if bb then bb:Destroy() end
        end
    end
    -- Expose so removeFromBlacklist can call it immediately
    _G.removeBlacklistESP = removeBlacklistESP

    -- Watch for player leaving and clean up ESP
    Players.PlayerRemoving:Connect(function(p)
        removeBlacklistESP(p)
    end)

    -- Watch for character respawn to re-apply ESP if still blacklisted
    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.BlacklistESP ~= false and isBlacklisted and isBlacklisted(p.Name) then
                makeBlacklistESP(p)
            end
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if Config.BlacklistESP ~= false and isBlacklisted and isBlacklisted(p.Name) then
                makeBlacklistESP(p)
            end
        end)
    end

    -- Main loop
    while true do
        task.wait(0.5)
        if Config.BlacklistESP == false then continue end
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            pcall(function()
                if isBlacklisted and isBlacklisted(p.Name) then
                    local char = p.Character
                    if char and not char:FindFirstChild("YinBlacklistESP") then
                        makeBlacklistESP(p)
                    end
                else
                    removeBlacklistESP(p)
                end
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
        textLabel.TextStrokeColor3 = Color3.fromRGB(10, 5, 18)
        textLabel.TextStrokeTransparency = 0 
        textLabel.Font = Enum.Font.GothamBold 
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
    local secretPets = {}
    local _seen = {}
    for _, rar in ipairs({"Secret","Divine","Legendary","Epic","Rare"}) do
        for _, nm in ipairs(getPetsByRarity(rar)) do
            if not _seen[nm:lower()] then _seen[nm:lower()]=true; table.insert(secretPets,nm) end
        end
    end
    table.sort(secretPets)
    
    local priorityGui = Instance.new("ScreenGui")
    priorityGui.Name = "PriorityListGUI"
    priorityGui.ResetOnSpawn = false
    priorityGui.Parent = PlayerGui
    priorityGui.Enabled = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 650, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -300)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = priorityGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Theme.Accent2
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    _F.CreateGradient(mainStroke)
    task.defer(function() applyIceToPanel(mainFrame, 10, 9) end)
    
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    _F.MakeDraggable(header, mainFrame, nil)
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PRIORITY LIST CUSTOMIZER"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 80, 0, 30)
    closeBtn.Position = UDim2.new(1, -95, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.Text = "CLOSE"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    
    closeBtn.MouseButton1Click:Connect(function()
        priorityGui.Enabled = false
    end)
    
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1, -30, 1, -100)
    contentFrame.Position = UDim2.new(0, 15, 0, 50)
    contentFrame.BackgroundTransparency = 1
    
    local availableLabel = Instance.new("TextLabel", contentFrame)
    availableLabel.Size = UDim2.new(0.45, 0, 0, 25)
    availableLabel.Position = UDim2.new(0, 0, 0, 0)
    availableLabel.BackgroundTransparency = 1
    availableLabel.Text = "AVAILABLE SECRET BRAINROTS"
    availableLabel.Font = Enum.Font.GothamBold
    availableLabel.TextSize = 12
    availableLabel.TextColor3 = Theme.TextSecondary
    
    local availableScroll = Instance.new("ScrollingFrame", contentFrame)
    availableScroll.Size = UDim2.new(0.45, 0, 1, -30)
    availableScroll.Position = UDim2.new(0, 0, 0, 30)
    availableScroll.BackgroundColor3 = Theme.Surface
    availableScroll.BorderSizePixel = 0
    availableScroll.ScrollBarThickness = 0
    Instance.new("UICorner", availableScroll).CornerRadius = UDim.new(0, 8)
    
    local availablePadding = Instance.new("UIPadding", availableScroll)
    availablePadding.PaddingTop = UDim.new(0, 5)
    availablePadding.PaddingLeft = UDim.new(0, 5)
    availablePadding.PaddingRight = UDim.new(0, 5)
    availablePadding.PaddingBottom = UDim.new(0, 5)
    
    local availableListLayout = Instance.new("UIListLayout", availableScroll)
    availableListLayout.Padding = UDim.new(0, 5)
    availableListLayout.SortOrder = Enum.SortOrder.Name
    
    local priorityLabel = Instance.new("TextLabel", contentFrame)
    priorityLabel.Size = UDim2.new(0.45, 0, 0, 25)
    priorityLabel.Position = UDim2.new(0.55, 0, 0, 0)
    priorityLabel.BackgroundTransparency = 1
    priorityLabel.Text = "PRIORITY LIST"
    priorityLabel.Font = Enum.Font.GothamBold
    priorityLabel.TextSize = 12
    priorityLabel.TextColor3 = Theme.TextSecondary
    
    local priorityScroll = Instance.new("ScrollingFrame", contentFrame)
    priorityScroll.Size = UDim2.new(0.45, 0, 1, -30)
    priorityScroll.Position = UDim2.new(0.55, 0, 0, 30)
    priorityScroll.BackgroundColor3 = Theme.Surface
    priorityScroll.BorderSizePixel = 0
    priorityScroll.ScrollBarThickness = 0
    Instance.new("UICorner", priorityScroll).CornerRadius = UDim.new(0, 8)
    
    local priorityPadding = Instance.new("UIPadding", priorityScroll)
    priorityPadding.PaddingTop = UDim.new(0, 5)
    priorityPadding.PaddingLeft = UDim.new(0, 5)
    priorityPadding.PaddingRight = UDim.new(0, 5)
    priorityPadding.PaddingBottom = UDim.new(0, 5)
    
    local priorityListLayout = Instance.new("UIListLayout", priorityScroll)
    priorityListLayout.Padding = UDim.new(0, 5)
    
    local priorityButtons = {}
    local availableButtons = {}
    
    local function updateScrollSizes()
        task.wait()
        availableScroll.CanvasSize = UDim2.new(0, 0, 0, availableListLayout.AbsoluteContentSize.Y + 10)
        priorityScroll.CanvasSize = UDim2.new(0, 0, 0, priorityListLayout.AbsoluteContentSize.Y + 10)
    end
    
    availableListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    priorityListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    
    local function refreshPriorityList()
        for _, btn in pairs(priorityButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        priorityButtons = {}
        
        for i, petName in ipairs(PRIORITY_LIST) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 35)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            itemFrame.Parent = priorityScroll
            
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -110, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 12
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local upBtn = Instance.new("TextButton", itemFrame)
            upBtn.Size = UDim2.new(0, 25, 0, 25)
            upBtn.Position = UDim2.new(1, -100, 0.5, 0)
            upBtn.AnchorPoint = Vector2.new(0, 0.5)
            upBtn.BackgroundColor3 = Theme.Accent1
            upBtn.Text = "↑"
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 12
            upBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 4)
            
            local downBtn = Instance.new("TextButton", itemFrame)
            downBtn.Size = UDim2.new(0, 25, 0, 25)
            downBtn.Position = UDim2.new(1, -70, 0.5, 0)
            downBtn.AnchorPoint = Vector2.new(0, 0.5)
            downBtn.BackgroundColor3 = Theme.Accent1
            downBtn.Text = "↓"
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 12
            downBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 4)
            
            local removeBtn = Instance.new("TextButton", itemFrame)
            removeBtn.Size = UDim2.new(0, 35, 0, 25)
            removeBtn.Position = UDim2.new(1, -30, 0.5, 0)
            removeBtn.AnchorPoint = Vector2.new(0, 0.5)
            removeBtn.BackgroundColor3 = Theme.Error
            removeBtn.Text = "X"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 12
            removeBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 4)
            
            upBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex > 1 then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex - 1] = PRIORITY_LIST[currentIndex - 1], PRIORITY_LIST[currentIndex]
                    _F.savePriorityToConfig()
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            
            downBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex < #PRIORITY_LIST then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex + 1] = PRIORITY_LIST[currentIndex + 1], PRIORITY_LIST[currentIndex]
                    _F.savePriorityToConfig()
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            
            removeBtn.MouseButton1Click:Connect(function()
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        table.remove(PRIORITY_LIST, idx)
                        _F.savePriorityToConfig()
                        refreshPriorityList()
                        refreshAvailableList()
                        break
                    end
                end
            end)
            
            table.insert(priorityButtons, itemFrame)
        end
        
        updateScrollSizes()
    end
    
    local function refreshAvailableList()
        for _, btn in pairs(availableButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        availableButtons = {}
        
        for _, petName in ipairs(secretPets) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 30)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
            itemFrame.Parent = availableScroll
            
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -50, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 11
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local addBtn = Instance.new("TextButton", itemFrame)
            addBtn.Size = UDim2.new(0, 40, 0, 25)
            addBtn.Position = UDim2.new(1, -45, 0.5, 0)
            addBtn.AnchorPoint = Vector2.new(0, 0.5)
            addBtn.BackgroundColor3 = Theme.Success
            addBtn.Text = "ADD"
            addBtn.Font = Enum.Font.GothamBold
            addBtn.TextSize = 10
            addBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 4)
            
            local isInPriority = false
            for _, pName in ipairs(PRIORITY_LIST) do
                if pName:lower() == petName:lower() then
                    isInPriority = true
                    break
                end
            end
            
            if isInPriority then
                addBtn.BackgroundColor3 = Theme.Error
                addBtn.Text = "REM"
                addBtn.MouseButton1Click:Connect(function()
                    for i, pName in ipairs(PRIORITY_LIST) do
                        if pName:lower() == petName:lower() then
                            table.remove(PRIORITY_LIST, i)
                            _F.savePriorityToConfig()
                            refreshPriorityList()
                            refreshAvailableList()
                            break
                        end
                    end
                end)
            else
                addBtn.MouseButton1Click:Connect(function()
                    table.insert(PRIORITY_LIST, petName)
                    _F.savePriorityToConfig()
                    refreshPriorityList()
                    refreshAvailableList()
                end)
            end
            
            table.insert(availableButtons, itemFrame)
        end
        
        updateScrollSizes()
    end
    
    refreshAvailableList()
    refreshPriorityList()
    SharedState.RefreshPriorityGUI = function() task.defer(function() refreshAvailableList(); refreshPriorityList() end) end
    priorityGui:GetPropertyChangedSignal("Enabled"):Connect(function()
        if priorityGui.Enabled then SharedState.RefreshPriorityGUI() end
    end)
    
    local saveBtn = Instance.new("TextButton", mainFrame)
    saveBtn.Size = UDim2.new(0, 120, 0, 35)
    saveBtn.Position = UDim2.new(0.5, -60, 1, -45)
    saveBtn.BackgroundColor3 = Theme.Success
    saveBtn.Text = "SAVE PRIORITY"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 6)
    
    saveBtn.MouseButton1Click:Connect(function()
        _F.savePriorityToConfig()
        _F.ShowNotification("PRIORITY LIST", "Saved " .. #PRIORITY_LIST .. " pets!")
        local successLabel = Instance.new("TextLabel", mainFrame)
        successLabel.Size = UDim2.new(0, 200, 0, 30)
        successLabel.Position = UDim2.new(0.5, -100, 1, -80)
        successLabel.BackgroundColor3 = Theme.Success
        successLabel.Text = "Priority List Saved! (" .. #PRIORITY_LIST .. " pets)"
        successLabel.Font = Enum.Font.GothamBold
        successLabel.TextSize = 11
        successLabel.TextColor3 = Color3.new(1, 1, 1)
        successLabel.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", successLabel).CornerRadius = UDim.new(0, 6)
        
        task.spawn(function()
            task.wait(2)
            if successLabel and successLabel.Parent then
                successLabel:Destroy()
            end
        end)
    end)
    
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                priorityGui.Enabled = not priorityGui.Enabled
            end
        end)
end)

task.spawn(function()


    local SUPER_PRIORITY = {
        "Strawberry Elephant",
        "Meowl",
        "Skibidi Toilet",
        "Headless Horseman",
        "Griffin",
        "Signore Carapace",
    }

    local function isOGPet(petName)
        if not petName then return false end
        local lower = petName:lower()
        for _, v in ipairs(SUPER_PRIORITY) do
            if v:lower() == lower then return true end
        end
        return false
    end

    local GITHUB_BASE = "https://raw.githubusercontent.com/buenowhh/bullys-hub-pets/main/pets/"

    local function getBrainrotImageId(petName)
        if not petName or petName == "" then return "" end
        local fileName = petName:lower():gsub("%s+", "_") .. ".png"
        return GITHUB_BASE .. fileName
    end

    local function SendWebhook(petName, value, mutation)
        local isOG = isOGPet(petName)
        local embedColor = isOG and 16711680 or 16711935

        local mutPrefix = (mutation and mutation ~= "None" and mutation ~= "") and ("[" .. mutation .. "] ") or ""
        local brainrotField = "`" .. mutPrefix .. petName .. " (" .. value .. ")`"
        local stealerField = "@!" .. LocalPlayer.Name .. " (" .. LocalPlayer.DisplayName .. ")"

        local thumbnailUrl = getBrainrotImageId(petName)

        local embedBody = {
            title = "🔥 Steal Detected",
            color = embedColor,
            fields = {
                {
                    name = "☠️ Brainrot",
                    value = brainrotField,
                    inline = false
                },
                {
                    name = "🕵️ Stealer",
                    value = stealerField,
                    inline = false
                }
            },
            footer = { text = "Iceman V2" },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }

        if thumbnailUrl ~= "" then
            embedBody.thumbnail = { url = thumbnailUrl }
        end

        local body = { embeds = { embedBody } }
        if isOG then body.content = "@here" end

        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["X-Secret-Key"] = SECRET_KEY,
            },
            Body = HttpService:JSONEncode(body)
        })
    end
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
                if (typeof(owner) == "Instance" and owner == LocalPlayer) or (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
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
    
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")
        
        if state then
            isStealing = true
            baseSnapshot = GetPetsOnPlot(GetMyPlot())
            
            stealStartTime = tick()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                stealStartPosition = hrp.Position
            end
        else
            if not isStealing then return end
            isStealing = false

            local stealDuration = tick() - stealStartTime
            local distanceMoved = 0
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                distanceMoved = (hrp.Position - stealStartPosition).Magnitude
            end
            
            task.wait(0.6)
            
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
    local name, gen, mut = GetInfo(stolenData)

    SendWebhook(name, gen, mut)
                if Config.AutoTpOnFailedSteal and stealDuration > 3 and distanceMoved > 60 then
                    _F.ShowNotification("STEAL FAILED", string.format("Auto TPing... (%.1fs, %d studs)", stealDuration, distanceMoved))
                    task.spawn(_F.runAutoSnipe)
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

SharedState.FPSFunctions = {}
SharedState.FPSFunctions.removeMeshes = function(tool)
	if not tool:IsA("Tool") then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local descendants = handle:GetDescendants()
	for i = 1, #descendants do
		local descendant = descendants[i]
		if descendant:IsA("SpecialMesh") or descendant:IsA("Mesh") or descendant:IsA("FileMesh") then
			descendant:Destroy()
		end
	end
end
SharedState.FPSFunctions.onCharacterAdded = function(character)
	local ff = SharedState.FPSFunctions
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and Config.FPSBoost then ff.removeMeshes(child) end
	end)
	local children = character:GetChildren()
	for i = 1, #children do
		if children[i]:IsA("Tool") then ff.removeMeshes(children[i]) end
	end
end
SharedState.FPSFunctions.onPlayerAdded = function(player)
	local ff = SharedState.FPSFunctions
	player.CharacterAdded:Connect(ff.onCharacterAdded)
	if player.Character then ff.onCharacterAdded(player.Character) end
end
SharedState.FPSFunctions.initPlayerTracking = function()
	local ff = SharedState.FPSFunctions
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do ff.onPlayerAdded(allPlayers[i]) end
	Players.PlayerAdded:Connect(ff.onPlayerAdded)
end
SharedState.FPSFunctions.initPlayerTracking()

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
        Background = Color3.fromRGB(10,10,10),
        Accent1 = Color3.fromRGB(170,170,170),
        Accent2 = Color3.fromRGB(125,125,125),
        White   = Color3.fromRGB(240,240,240),
        Gray    = Color3.fromRGB(125,125,125),
        Success = Color3.fromRGB(170,170,170),
        Error   = Color3.fromRGB(210, 90, 90)
    }

    local SCALE = 1
    local HEIGHT = 50 * SCALE
    
    local joinerGui = Instance.new("ScreenGui")
    joinerGui.Name = "YinJobJoiner"
    joinerGui.ResetOnSpawn = false
    joinerGui.Enabled = Config.ShowJobJoiner
    joinerGui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500 * SCALE, 0, HEIGHT)
    
    local savedPos = Config.Positions.JobJoiner or {X = 0.5, Y = 0.85}
    
    main.AnchorPoint = Vector2.new(0.5, 0) 
    main.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    
    main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    main.BackgroundTransparency = 0.15
    main.BorderSizePixel = 0
    main.Parent = joinerGui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local bgGradient = Instance.new("UIGradient", main)
    bgGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 20, 26)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25,27,35))
    }
    bgGradient.Rotation = 45

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Transparency = 0.3
    
    local strokeGrad = Instance.new("UIGradient", stroke)
    strokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.5, HTheme.Accent2),
        ColorSequenceKeypoint.new(1, HTheme.Accent1)
    }
    
    task.spawn(function()
        while stroke.Parent do
            strokeGrad.Rotation = strokeGrad.Rotation + 1
            task.wait(0.05)
        end
    end)

    _F.MakeDraggable(main, main, "JobJoiner")

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -20*SCALE, 1, 0)
    content.Position = UDim2.new(0, 10*SCALE, 0, 0)
    content.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", content)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8 * SCALE)

    local function CreateInput(placeholder, width, default)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 10 * SCALE)
        label.Position = UDim2.new(0, 0, 0, -10 * SCALE)
        label.BackgroundTransparency = 1
        label.Text = placeholder
        label.TextColor3 = HTheme.Accent1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9 * SCALE
        
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(190, 230, 255)
        box.BackgroundTransparency = 0.5
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.TextColor3 = HTheme.White
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12 * SCALE
        box.ClearTextOnFocus = false
        
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", box)
        s.Color = HTheme.Gray
        s.Thickness = 0.1
        s.Transparency = 0.6
        
        box.Focused:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Accent1, Transparency = 0}):Play() 
        end)
        box.FocusLost:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Gray, Transparency = 0.6}):Play() 
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
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local s = Instance.new("UIStroke", btn)
        s.Color = color
        s.Thickness = 1.5
        s.Transparency = 0.4
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        
        return btn
    end

    local joinBtn = CreateButton("JOIN", 60, HTheme.Success)
    joinBtn.Parent = content

    local idFrame, idBox = CreateInput("", 180, "")
    idBox.PlaceholderText = ""
    idFrame.Parent = content
    idBox.TextTruncate = Enum.TextTruncate.AtEnd

    local clearBtn = CreateButton("CLEAR", 50, Color3.fromRGB(60, 60, 70))
    clearBtn.Parent = content

    local attFrame, attBox = CreateInput("Attempts", 60, "2000")
    attFrame.Parent = content

    local delFrame, delBox = CreateInput("Delay", 50, "0.01")
    delFrame.Parent = content

    local isJoining = false
    
    joinBtn.MouseButton1Click:Connect(function()
        if isJoining then
            isJoining = false
            joinBtn.Text = "JOIN"
            joinBtn.BackgroundColor3 = HTheme.Success
            _F.ShowNotification("JOINER", "Process Cancelled")
            return
        end

        local jobId = idBox.Text:gsub("%s+", "") 
        local attempts = tonumber(attBox.Text) or 10
        local delayTime = tonumber(delBox.Text) or 0.5

        if jobId == "" or #jobId < 5 then
            _F.ShowNotification("ERROR", "Invalid JobID")
            return
        end

        isJoining = true
        joinBtn.Text = "STOP"
        joinBtn.BackgroundColor3 = HTheme.Error
        
        task.spawn(function()
            for i = 1, attempts do
                if not isJoining then break end
                
                _F.ShowNotification("JOINING", string.format("Attempt %d/%d...", i, attempts))
                
                local success, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
                end)

                if not success then
                    
                end
                
                task.wait(delayTime)
            end
            
            isJoining = false
            if joinBtn and joinBtn.Parent then
                joinBtn.Text = "JOIN"
                joinBtn.BackgroundColor3 = HTheme.Success
            end
        end)
    end)

    clearBtn.MouseButton1Click:Connect(function()
        idBox.Text = ""
    end)
end)

task.spawn(function()
    local tGui = Instance.new("ScreenGui")
    tGui.Name = "YinThemeUI"
    tGui.ResetOnSpawn = false
    tGui.DisplayOrder = 50
    tGui.Parent = PlayerGui

    -- Painel principal
    local tPanel = Instance.new("Frame", tGui)
    tPanel.Name = "ThemePanel"
    tPanel.Size = UDim2.new(0, 220, 0, 440)
    tPanel.Position = UDim2.new(0.5, -110, 0, 80)
    tPanel.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    tPanel.BackgroundTransparency = 0.12
    tPanel.BorderSizePixel = 0
    tPanel.Visible = false
    Instance.new("UICorner", tPanel).CornerRadius = UDim.new(0, 12)

    local tStroke = Instance.new("UIStroke", tPanel)
    tStroke.Color = Color3.fromRGB(255, 120, 200)
    tStroke.Thickness = 1.5
    tStroke.Transparency = 0.3

    -- Gradiente de borda animado
    local tStrokeGrad = Instance.new("UIGradient", tStroke)
    tStrokeGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(170, 170, 170)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(125, 125, 125)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170)),
    }
    task.spawn(function()
        while tStroke.Parent do
            tStrokeGrad.Rotation = (tStrokeGrad.Rotation + 2) % 360
            task.wait(0.05)
        end
    end)

    -- Header / drag
    local tHeader = Instance.new("Frame", tPanel)
    tHeader.Size = UDim2.new(1, 0, 0, 36)
    tHeader.BackgroundTransparency = 1

    local tTitle = Instance.new("TextLabel", tHeader)
    tTitle.Size = UDim2.new(1, -40, 1, 0)
    tTitle.Position = UDim2.new(0, 14, 0, 0)
    tTitle.BackgroundTransparency = 1
    tTitle.Text = "🎨 TEMAS"
    tTitle.Font = Enum.Font.GothamBlack
    tTitle.TextSize = 14
    tTitle.TextColor3 = Color3.fromRGB(240, 240, 240)
    tTitle.TextXAlignment = Enum.TextXAlignment.Left

    local tClose = Instance.new("TextButton", tHeader)
    tClose.Size = UDim2.new(0, 24, 0, 24)
    tClose.Position = UDim2.new(1, -30, 0.5, -12)
    tClose.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    tClose.Text = "✕"
    tClose.Font = Enum.Font.GothamBold
    tClose.TextSize = 12
    tClose.TextColor3 = Color3.new(1, 1, 1)
    tClose.AutoButtonColor = false
    Instance.new("UICorner", tClose).CornerRadius = UDim.new(1, 0)
    tClose.MouseButton1Click:Connect(function()
        tPanel.Visible = false
    end)

    -- Drag
    _F.MakeDraggable(tHeader, tPanel)

    -- Divisor
    local tDiv = Instance.new("Frame", tPanel)
    tDiv.Size = UDim2.new(1, -20, 0, 1)
    tDiv.Position = UDim2.new(0, 10, 0, 36)
    tDiv.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
    tDiv.BackgroundTransparency = 0.6
    tDiv.BorderSizePixel = 0

    -- Container dos botões
    local tContent = Instance.new("Frame", tPanel)
    tContent.Size = UDim2.new(1, -20, 1, -46)
    tContent.Position = UDim2.new(0, 10, 0, 44)
    tContent.BackgroundTransparency = 1

    local tLayout = Instance.new("UIListLayout", tContent)
    tLayout.Padding = UDim.new(0, 8)
    tLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Theme data
    local TD = {
        {"BLACK",   "preto",    Color3.fromRGB(170,170,170), Color3.fromRGB(10,10,10)},
    }

    for i, td in ipairs(TD) do
        local row = Instance.new("Frame", tContent)
        row.Size = UDim2.new(1, 0, 0, 36)
        row.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
        row.BackgroundTransparency = 0.2
        row.BorderSizePixel = 0
        row.LayoutOrder = i
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = td[3]
        rowStroke.Thickness = 1
        rowStroke.Transparency = 0.6

        local dot = Instance.new("Frame", row)
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.Position = UDim2.new(0, 12, 0.5, -6)
        dot.BackgroundColor3 = td[3]
        dot.BorderSizePixel = 0
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local nameLbl = Instance.new("TextLabel", row)
        nameLbl.Size = UDim2.new(0.5, 0, 1, 0)
        nameLbl.Position = UDim2.new(0, 32, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = td[1]
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 12
        nameLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left

        local apBtn = Instance.new("TextButton", row)
        apBtn.Size = UDim2.new(0, 72, 0, 24)
        apBtn.Position = UDim2.new(1, -78, 0.5, -12)
        apBtn.BackgroundColor3 = td[3]
        apBtn.Text = "APPLY"
        apBtn.Font = Enum.Font.GothamBold
        apBtn.TextSize = 10
        apBtn.TextColor3 = Color3.new(0, 0, 0)
        apBtn.AutoButtonColor = false
        Instance.new("UICorner", apBtn).CornerRadius = UDim.new(0, 6)

        local apStroke = Instance.new("UIStroke", apBtn)
        apStroke.Color = td[3]
        apStroke.Thickness = 1
        apStroke.Transparency = 0.3

        local tid = td[2]
        apBtn.MouseButton1Click:Connect(function()
            applyTheme(tid)
            -- feedback visual
            local oldBg = tPanel.BackgroundColor3
            TweenService:Create(tPanel, TweenInfo.new(0.15), {BackgroundColor3 = td[4]}):Play()
            task.delay(0.5, function()
                TweenService:Create(tPanel, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Background}):Play()
            end)
        end)
        apBtn.MouseEnter:Connect(function()
            TweenService:Create(apBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0.25}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.1), {Transparency = 0.1}):Play()
        end)
        apBtn.MouseLeave:Connect(function()
            TweenService:Create(apBtn, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
            TweenService:Create(rowStroke, TweenInfo.new(0.1), {Transparency = 0.6}):Play()
        end)
    end

    -- Botão de tema desativado - substituido pela nova UI
    local tToggle = Instance.new("TextButton", tGui)
    tToggle.Name = "ThemeToggleBtn"
    tToggle.Visible = false
    tToggle.Size = UDim2.new(0, 36, 0, 36)
    tToggle.Position = UDim2.new(0, 10, 0, 10)
    tToggle.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
    tToggle.BackgroundTransparency = 0.1
    tToggle.Text = "🎨"
    tToggle.Font = Enum.Font.GothamBlack
    tToggle.TextSize = 18
    tToggle.TextColor3 = Color3.fromRGB(185, 185, 185)
    tToggle.AutoButtonColor = false
    Instance.new("UICorner", tToggle).CornerRadius = UDim.new(1, 0)
    local togStroke = Instance.new("UIStroke", tToggle)
    togStroke.Color = Color3.fromRGB(170, 170, 170)
    togStroke.Thickness = 1.5
    togStroke.Transparency = 0.3
    _F.MakeDraggable(tToggle, tToggle)

    tToggle.MouseButton1Click:Connect(function()
        tPanel.Visible = not tPanel.Visible
        if tPanel.Visible then
            tPanel.Position = UDim2.new(
                tToggle.Position.X.Scale, tToggle.AbsolutePosition.X + 44,
                tToggle.Position.Y.Scale, tToggle.AbsolutePosition.Y
            )
        end
    end)

    -- Pulso no botão toggle
    task.spawn(function()
        while tToggle.Parent do
            TweenService:Create(togStroke, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.7}):Play()
            task.wait(1.6)
        end
    end)

    -- Expor ref global para outros scripts
    _G.ThemeUI = {panel = tPanel, toggle = tToggle, apply = applyTheme}
end)

function buildYinSettingsUI()
    local pg = PlayerGui
    if not pg then return end
    local oldBSG2 = pg:FindFirstChild("YinSettings")
    if oldBSG2 then oldBSG2:Destroy() end

    local bsg = Instance.new("ScreenGui")
    bsg.Name = "YinSettings"
    bsg.ResetOnSpawn = false
    bsg.DisplayOrder = 20
    bsg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    bsg.Parent = pg

    -- ── cores base do tema ──
    local function C() return {
        BG   = Theme.Background,
        SURF = Theme.Surface,
        SH   = Theme.SurfaceHighlight,
        AC   = Theme.Accent1,
        TP   = Theme.TextPrimary,
        TS   = Theme.TextSecondary,
        ERR  = Theme.Error,
        SUC  = Theme.Success,
    } end

    -- Painel principal
    local panel = Instance.new("Frame", bsg)
    panel.Name = "MainPanel"
    panel.Size = UDim2.new(0, 330, 0, 510)
    do
        local sp = Config.YinSettingsPos
        if sp then
            panel.Position = UDim2.new(sp.X, 0, sp.Y, 0)
        else
            panel.Position = UDim2.new(0, 60, 0.5, -235)
        end
    end
    panel.BackgroundColor3 = C().BG
    panel.BackgroundTransparency = 0.08
    panel.BorderSizePixel = 0
    panel.Visible = false
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)

    local panStroke = Instance.new("UIStroke", panel)
    panStroke.Color = Theme.Accent1
    panStroke.Thickness = 1.5
    panStroke.Transparency = 0.35
    task.defer(function() if addRacetrackBorder then addRacetrackBorder(panel, Theme.Accent1, 3) end end)
    task.defer(function() applyIceToPanel(panel, 7, 6) end)
    local hdr = Instance.new("Frame", panel)
    hdr.Size = UDim2.new(1, 0, 0, 38)
    hdr.BackgroundTransparency = 1
    _F.MakeDraggable(hdr, panel)
    -- Save position after drag ends
    hdr.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            inp.Changed:Connect(function()
                if inp.UserInputState == Enum.UserInputState.End then
                    local ps = panel.Parent.AbsoluteSize
                    Config.YinSettingsPos = {
                        X = panel.AbsolutePosition.X / ps.X,
                        Y = panel.AbsolutePosition.Y / ps.Y,
                    }
                    _F.SaveConfig()
                end
            end)
        end
    end)

    local hTitle = Instance.new("TextLabel", hdr)
    hTitle.Size = UDim2.new(0, 120, 1, 0)
    hTitle.Position = UDim2.new(0, 12, 0, 0)
    hTitle.BackgroundTransparency = 1
    hTitle.Text = "Iceman V2"
    hTitle.Font = Enum.Font.GothamBlack
    hTitle.TextSize = 16
    hTitle.TextColor3 = C().TP
    hTitle.TextXAlignment = Enum.TextXAlignment.Left

    local hFps = Instance.new("TextLabel", hdr)
    hFps.Size = UDim2.new(0, 150, 1, 0)
    hFps.Position = UDim2.new(0, 120, 0, 0)
    hFps.BackgroundTransparency = 1
    hFps.RichText = true
    hFps.Text = ""
    hFps.Font = Enum.Font.GothamBold
    hFps.TextSize = 11
    hFps.TextColor3 = C().TS
    hFps.TextXAlignment = Enum.TextXAlignment.Left
    task.spawn(function()
        local fr, ac2 = 0, 0
        RunService.Heartbeat:Connect(function(dt)
            fr += 1; ac2 += dt
            if ac2 >= 1 then
                local p2 = math.floor(LocalPlayer:GetNetworkPing()*1000)
                local fc = fr>=50 and "rgb(80,255,150)" or "rgb(255,210,80)"
                local pc = p2<100 and "rgb(80,255,150)" or "rgb(255,210,80)"
                hFps.Text = string.format("<font color='%s'>FPS:%d</font>  <font color='%s'>PING:%dms</font>",fc,fr,pc,p2)
                fr, ac2 = 0, 0
            end
        end)
    end)

    local hClose = Instance.new("TextButton", hdr)
    hClose.Size = UDim2.new(0, 20, 0, 20)
    hClose.Position = UDim2.new(1, -28, 0.5, -10)
    hClose.BackgroundTransparency = 1
    hClose.Text = "─"
    hClose.Font = Enum.Font.GothamBold
    hClose.TextSize = 14
    hClose.TextColor3 = C().TS
    hClose.AutoButtonColor = false
    hClose.MouseButton1Click:Connect(function() panel.Visible = false end)
    hClose.MouseEnter:Connect(function() hClose.TextColor3 = C().TP end)
    hClose.MouseLeave:Connect(function() hClose.TextColor3 = C().TS end)

    -- Divisor
    local hDiv = Instance.new("Frame", panel)
    hDiv.Size = UDim2.new(1,-24,0,1)
    hDiv.Position = UDim2.new(0,12,0,38)
    hDiv.BackgroundColor3 = C().SH
    hDiv.BackgroundTransparency = 0
    hDiv.BorderSizePixel = 0

    -- Tab Bar (3 rows of 3)
    local tabBar = Instance.new("Frame", panel)
    tabBar.Size = UDim2.new(1,-20,0,96)
    tabBar.Position = UDim2.new(0,10,0,44)
    tabBar.BackgroundTransparency = 1

    -- Content Area
    local cArea = Instance.new("Frame", panel)
    cArea.Size = UDim2.new(1,-20,1,-148)
    cArea.Position = UDim2.new(0,10,0,148)
    cArea.BackgroundTransparency = 1
    cArea.ClipsDescendants = true

    -- ── helpers ──
    local function makeScroll()
        local sf = Instance.new("ScrollingFrame", cArea)
        sf.Size = UDim2.new(1,0,1,0)
        sf.BackgroundTransparency = 1
        sf.BorderSizePixel = 0
        sf.ScrollBarThickness = 0
        sf.ScrollBarImageColor3 = Theme.Accent1
        sf.CanvasSize = UDim2.new(0,0,0,0)
        sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sf.Visible = false
        local ll = Instance.new("UIListLayout", sf)
        ll.Padding = UDim.new(0,5)
        ll.SortOrder = Enum.SortOrder.LayoutOrder
        local pp = Instance.new("UIPadding", sf)
        pp.PaddingTop  = UDim.new(0,5)
        pp.PaddingBottom = UDim.new(0,5)
        pp.PaddingLeft = UDim.new(0,2)
        pp.PaddingRight = UDim.new(0,2)
        return sf
    end

    local function makeBtn(parent, lbl, order, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1,0,0,38)
        btn.BackgroundColor3 = C().SURF
        btn.BackgroundTransparency = 0
        btn.Text = lbl
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextColor3 = C().TP
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.LayoutOrder = order
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
        local bs = Instance.new("UIStroke", btn)
        bs.Color = C().SH
        bs.Thickness = 1
        bs.Transparency = 0
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=C().SH}):Play()
            TweenService:Create(bs, TweenInfo.new(0.1), {Color=Theme.Accent1, Transparency=0.3}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=C().SURF}):Play()
            TweenService:Create(bs, TweenInfo.new(0.1), {Color=C().SH, Transparency=0}):Play()
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    local function makeSec(parent, lbl, order)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,22)
        row.BackgroundTransparency = 1
        row.LayoutOrder = order
        local bar = Instance.new("Frame", row)
        bar.Size = UDim2.new(1,0,0,1)
        bar.Position = UDim2.new(0,0,1,-1)
        bar.BackgroundColor3 = C().SH
        bar.BorderSizePixel = 0
        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(1,0,1,0)
        tl.BackgroundTransparency = 1
        tl.Text = lbl
        tl.Font = Enum.Font.GothamBlack
        tl.TextSize = 11
        tl.TextColor3 = Theme.Accent1
        tl.TextXAlignment = Enum.TextXAlignment.Left
        return row
    end

    local function makeToggle(parent, lbl, get, set, order)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,36)
        row.BackgroundColor3 = C().SURF
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)

        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(1,-54,1,0)
        tl.Position = UDim2.new(0,10,0,0)
        tl.BackgroundTransparency = 1
        tl.Text = lbl
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextColor3 = C().TP
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local sw = Instance.new("Frame", row)
        sw.Size = UDim2.new(0,38,0,20)
        sw.Position = UDim2.new(1,-46,0.5,-10)
        sw.BackgroundColor3 = get() and Theme.Accent1 or C().SH
        Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)

        local dot = Instance.new("Frame", sw)
        dot.Size = UDim2.new(0,15,0,15)
        dot.Position = get() and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)
        dot.BackgroundColor3 = Color3.new(1,1,1)
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

        local swb = Instance.new("TextButton", sw)
        swb.Size = UDim2.new(1,0,1,0)
        swb.BackgroundTransparency = 1
        swb.Text = ""
        swb.ZIndex = 4; swb.AutoButtonColor = false
        local function doT()
            local ns=not get(); set(ns)
            TweenService:Create(dot,TweenInfo.new(0.15),{Position=ns and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)}):Play()
            TweenService:Create(sw,TweenInfo.new(0.15),{BackgroundColor3=ns and Theme.Accent1 or C().SH}):Play()
        end
        swb.MouseButton1Click:Connect(doT)
        swb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.Touch then doT() end end)
        return row
    end

    local function makeKey(parent, lbl, get, set2, order)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1,0,0,36)
        row.BackgroundColor3 = C().SURF
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)

        local tl = Instance.new("TextLabel", row)
        tl.Size = UDim2.new(1,-80,1,0)
        tl.Position = UDim2.new(0,10,0,0)
        tl.BackgroundTransparency = 1
        tl.Text = lbl
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 12
        tl.TextColor3 = C().TP
        tl.TextXAlignment = Enum.TextXAlignment.Left

        local kb = Instance.new("TextButton", row)
        kb.Size = UDim2.new(0,64,0,24)
        kb.Position = UDim2.new(1,-72,0.5,-12)
        kb.BackgroundColor3 = C().SH
        kb.Text = get() or "NONE"
        kb.Font = Enum.Font.GothamBold
        kb.TextSize = 11
        kb.TextColor3 = Theme.Accent1
        kb.AutoButtonColor = false
        Instance.new("UICorner", kb).CornerRadius = UDim.new(0,5)
        kb.MouseButton1Click:Connect(function()
            kb.Text = "..."; kb.TextColor3 = C().TS
            local con; con = UserInputService.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Keyboard then
                    set2(inp.KeyCode.Name)
                    kb.Text = inp.KeyCode.Name
                    kb.TextColor3 = Theme.Accent1
                    _F.SaveConfig(); con:Disconnect()
                end
            end)
        end)
        return row
    end

    -- ── TABS ──
    local TABS2 = {
        {name="Config",    id="cfg"},
        {name="Visuals",   id="vis"},
        {name="Movement",  id="mov"},
        {name="TP",        id="tp"},
        {name="UI Hide's", id="uih"},
        {name="Invis",     id="inv"},
        {name="Temas",     id="tem"},
        {name="BList",     id="bl"},
    }
    local tBtns2 = {}
    local tScrolls2 = {}
    local activTab2 = "cfg"

    local function switchTab2(id)
        if not tScrolls2[id] then id = "cfg" end
        activTab2 = id
        if _G.YinSettingsUI then _G.YinSettingsUI.currentTab = id end
        for tid, sc in pairs(tScrolls2) do sc.Visible = (tid==id) end
        for tid, tb in pairs(tBtns2) do
            local on = tid==id
            tb.BackgroundColor3 = on and Theme.Accent1 or C().SURF
            tb.BackgroundTransparency = 0
            tb.TextColor3 = on and Color3.new(0,0,0) or C().TS
            local s2 = tb:FindFirstChildOfClass("UIStroke")
            if s2 then s2.Transparency = on and 1 or 0.3 end
        end
    end

    do
        local COLS,BTN_H,GAP=4,28,4
        local rows = math.max(1, math.ceil(#TABS2 / COLS))
        tabBar.Size = UDim2.new(1,-20,0, rows * BTN_H + math.max(0, rows - 1) * GAP)
        cArea.Position = UDim2.new(0,10,0,44 + tabBar.Size.Y.Offset + 8)
        cArea.Size = UDim2.new(1,-20,1,-(cArea.Position.Y.Offset + 10))
        for i,td in ipairs(TABS2) do
            local col=(i-1)%COLS; local row=math.floor((i-1)/COLS)
            local tb=Instance.new("TextButton",tabBar)
            tb.Size=UDim2.new(1/COLS,-(GAP*(COLS-1)/COLS),0,BTN_H)
            tb.Position=UDim2.new(col/COLS,col==0 and 0 or GAP*(col/(COLS)),0,row*(BTN_H+GAP))
            tb.BackgroundColor3=C().SURF; tb.BackgroundTransparency=0
            tb.Text=td.name; tb.Font=Enum.Font.GothamBold; tb.TextSize=11
            tb.TextColor3=C().TS; tb.BorderSizePixel=0; tb.AutoButtonColor=false; tb.LayoutOrder=i
            Instance.new("UICorner",tb).CornerRadius=UDim.new(0,6)
            local ts2=Instance.new("UIStroke",tb); ts2.Color=C().SH; ts2.Thickness=1; ts2.Transparency=0.3
            tBtns2[td.id]=tb; tScrolls2[td.id]=makeScroll()
            local tid=td.id; tb.MouseButton1Click:Connect(function() switchTab2(tid) end)
        end
    end

    -- ── CONFIG TAB ──
    local cS = tScrolls2["cfg"]
    makeSec(cS, "AÇÕES RÁPIDAS", 0)
    makeBtn(cS, "Abrir Painel Admin", 1, function()
        local g = PlayerGui:FindFirstChild("XiAdminPanel")
        if g then g.Enabled = not g.Enabled end
    end)
    makeBtn(cS, "Auto Steal Painel", 2, function()
        local g = PlayerGui:FindFirstChild("AutoStealUI")
        if g then g.Enabled = not g.Enabled end
    end)
    makeToggle(cS, "Job Joiner", function()
        return Config.ShowJobJoiner
    end, function(v)
        Config.ShowJobJoiner = v
        _F.SaveConfig()
        local g = PlayerGui:FindFirstChild("YinJobJoiner")
        if g then g.Enabled = v end
    end, 3)

    -- ─── AUTO STEAL DEFAULTS ─────────────────────────────────────────────
    makeSec(cS, "AUTO STEAL DEFAULTS", 37)
    do
        local rSwitches = {}
        local function applyDefMode(mode)
            Config.DefaultToNearest  = (mode == "nearest")
            Config.DefaultToHighest  = (mode == "highest")
            Config.DefaultToPriority = (mode == "priority")
            Config.DefaultToDisable  = (mode == "disable")
            Config.AutoTPPriority    = (mode == "nearest" or mode == "priority")
            _F.SaveConfig()
            for _id, _sw in pairs(rSwitches) do
                local _on = (_id=="nearest"  and Config.DefaultToNearest)
                         or (_id=="highest"  and Config.DefaultToHighest)
                         or (_id=="priority" and Config.DefaultToPriority)
                         or (_id=="disable"  and Config.DefaultToDisable)
                TweenService:Create(_sw.dot, TweenInfo.new(0.15), {Position = _on and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)}):Play()
                TweenService:Create(_sw.bg,  TweenInfo.new(0.15), {BackgroundColor3 = _on and Theme.Accent1 or Theme.SurfaceHighlight}):Play()
            end
        end
        local function makeRadioSwitch(parent, label, id, order)
            local isOn = (id=="nearest"  and Config.DefaultToNearest)
                      or (id=="highest"  and Config.DefaultToHighest)
                      or (id=="priority" and Config.DefaultToPriority)
                      or (id=="disable"  and Config.DefaultToDisable)
            local row = Instance.new("Frame", parent)
            row.Size = UDim2.new(1,0,0,36)
            row.BackgroundColor3 = C().SURF
            row.BackgroundTransparency = 0
            row.BorderSizePixel = 0
            row.LayoutOrder = order
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
            local tl = Instance.new("TextLabel", row)
            tl.Size = UDim2.new(1,-54,1,0)
            tl.Position = UDim2.new(0,10,0,0)
            tl.BackgroundTransparency = 1
            tl.Text = label
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 12
            tl.TextColor3 = C().TP
            tl.TextXAlignment = Enum.TextXAlignment.Left
            local sw = Instance.new("Frame", row)
            sw.Size = UDim2.new(0,38,0,20)
            sw.Position = UDim2.new(1,-46,0.5,-10)
            sw.BackgroundColor3 = isOn and Theme.Accent1 or Theme.SurfaceHighlight
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
            local dot = Instance.new("Frame", sw)
            dot.Size = UDim2.new(0,15,0,15)
            dot.Position = isOn and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            local btn = Instance.new("TextButton", sw)
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.MouseButton1Click:Connect(function() applyDefMode(id) end)
            rSwitches[id] = {bg=sw, dot=dot}
        end
        makeRadioSwitch(cS, "Default To Nearest",  "nearest",  38)
        makeRadioSwitch(cS, "Default To Highest",  "highest",  39)
        makeRadioSwitch(cS, "Default To Priority", "priority", 40)
        makeRadioSwitch(cS, "Default Disable",     "disable",  41)
    end

    -- ─── AUTO STEAL ─────────────────────────────────────────────────────
    makeSec(cS, "AUTO STEAL", 60)
    do
        local stealSwitches = {}
        local function applyStealMode(mode)
            -- mode: "nearest" | "highest" | "priority"
            Config.StealNearest  = (mode == "nearest")
            Config.StealHighest  = (mode == "highest")
            Config.StealPriority = (mode == "priority")
            -- also mirror onto DefaultTo so the logic persists on reload
            Config.DefaultToNearest  = (mode == "nearest")
            Config.DefaultToHighest  = (mode == "highest")
            Config.DefaultToPriority = (mode == "priority")
            Config.DefaultToDisable  = false
            Config.AutoTPPriority    = (mode == "nearest" or mode == "priority")
            _F.SaveConfig()
            for _id, _sw in pairs(stealSwitches) do
                local _on = (_id=="nearest"  and Config.StealNearest)
                         or (_id=="highest"  and Config.StealHighest)
                         or (_id=="priority" and Config.StealPriority)
                TweenService:Create(_sw.dot, TweenInfo.new(0.15), {Position = _on and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)}):Play()
                TweenService:Create(_sw.bg,  TweenInfo.new(0.15), {BackgroundColor3 = _on and Theme.Accent1 or Theme.SurfaceHighlight}):Play()
            end
            _F.ShowNotification("STEAL MODE", "Steal " .. mode:sub(1,1):upper() .. mode:sub(2) .. " ENABLED")
        end
        local function makeStealRadio(parent, label, id, order)
            local isOn = (id=="nearest"  and Config.StealNearest)
                      or (id=="highest"  and Config.StealHighest)
                      or (id=="priority" and Config.StealPriority)
            local row = Instance.new("Frame", parent)
            row.Size = UDim2.new(1,0,0,36)
            row.BackgroundColor3 = C().SURF
            row.BackgroundTransparency = 0
            row.BorderSizePixel = 0
            row.LayoutOrder = order
            Instance.new("UICorner", row).CornerRadius = UDim.new(0,7)
            local tl = Instance.new("TextLabel", row)
            tl.Size = UDim2.new(1,-54,1,0)
            tl.Position = UDim2.new(0,10,0,0)
            tl.BackgroundTransparency = 1
            tl.Text = label
            tl.Font = Enum.Font.GothamBold
            tl.TextSize = 12
            tl.TextColor3 = C().TP
            tl.TextXAlignment = Enum.TextXAlignment.Left
            local sw = Instance.new("Frame", row)
            sw.Size = UDim2.new(0,38,0,20)
            sw.Position = UDim2.new(1,-46,0.5,-10)
            sw.BackgroundColor3 = isOn and Theme.Accent1 or Theme.SurfaceHighlight
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0)
            local dot = Instance.new("Frame", sw)
            dot.Size = UDim2.new(0,15,0,15)
            dot.Position = isOn and UDim2.new(1,-17,0.5,-7.5) or UDim2.new(0,2,0.5,-7.5)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
            local btn = Instance.new("TextButton", sw)
            btn.Size = UDim2.new(1,0,1,0)
            btn.BackgroundTransparency = 1
            btn.Text = ""
            btn.MouseButton1Click:Connect(function() applyStealMode(id) end)
            stealSwitches[id] = {bg=sw, dot=dot}
        end
        makeStealRadio(cS, "Steal Nearest",  "nearest",  61)
        makeStealRadio(cS, "Steal Highest",  "highest",  62)
        makeStealRadio(cS, "Steal Priority", "priority", 63)
    end

    -- ── VISUALS TAB ──
    local vS = tScrolls2["vis"]
    makeSec(vS,"ESP",1)
    makeToggle(vS,"X-Ray Base",function() return Config.XrayEnabled end,function(v) Config.XrayEnabled=v; if v then _F.enableXray() else _F.disableXray() end; _F.SaveConfig() end,11)
    makeToggle(vS,"Player ESP",function() return Config.PlayerESP end,function(v) Config.PlayerESP=v; if playerESPToggleRef and playerESPToggleRef.setFn then playerESPToggleRef.setFn(v) end; _F.SaveConfig() end,12)
    makeToggle(vS,"Brainrot ESP",function() return Config.BrainrotESP end,function(v) Config.BrainrotESP=v; if espToggleRef and espToggleRef.setFn then espToggleRef.setFn(v) end; _F.SaveConfig() end,13)
    makeToggle(vS,"Conveyor ESP",function() return Config.ConveyorESP end,function(v) Config.ConveyorESP=v; _F.SaveConfig() end,14)
    makeToggle(vS,"Tracer Brainrot",function() return Config.TracerEnabled end,function(v) Config.TracerEnabled=v; _F.SaveConfig() end,15)
    makeToggle(vS,"Subspace Mine ESP",function() return Config.SubspaceMineESP end,function(v) Config.SubspaceMineESP=v; _F.SaveConfig() end,17)
    makeToggle(vS,"Stealing HUD",function() return Config.ShowStealingHUD~=false end,function(v) Config.ShowStealingHUD=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("XiStealingHUD"); if g then g.Enabled=v end end,18)
    makeToggle(vS,"Steal Plot ESP",function() return Config.ShowStealingPlotESP~=false end,function(v) Config.ShowStealingPlotESP=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("XiStealingPlotESP"); if g then g.Enabled=v end end,19)
    makeSec(vS,"OVERLAYS",20)
    makeToggle(vS,"Line to Base",function() return Config.LineToBase end,function(v) Config.LineToBase=v; if not v and _G.resetPlotBeam then pcall(_G.resetPlotBeam) end; _F.SaveConfig() end,21)
    makeToggle(vS,"Unlock Buttons HUD",function() return Config.ShowUnlockButtonsHUD end,function(v)
        Config.ShowUnlockButtonsHUD=v; _F.SaveConfig()
        local hudGui=PlayerGui:FindFirstChild("YinStatusHUD")
        if not hudGui then return end
        local uc=hudGui:FindFirstChild("UnlockButtonsContainer")
        if uc then uc.Visible=v end
    end,22)
    makeSec(vS,"CAMERA",30)
    do
        local fR=Instance.new("Frame",vS); fR.Size=UDim2.new(1,0,0,52); fR.BackgroundColor3=C().SURF; fR.BorderSizePixel=0; fR.LayoutOrder=31
        Instance.new("UICorner",fR).CornerRadius=UDim.new(0,7)
        local fl=Instance.new("TextLabel",fR); fl.Size=UDim2.new(0.5,0,0,18); fl.Position=UDim2.new(0,10,0,4); fl.BackgroundTransparency=1; fl.Text="FOV"; fl.Font=Enum.Font.GothamBold; fl.TextSize=12; fl.TextColor3=C().TP; fl.TextXAlignment=Enum.TextXAlignment.Left
        local fV=Instance.new("TextLabel",fR); fV.Size=UDim2.new(0,40,0,18); fV.Position=UDim2.new(1,-48,0,4); fV.BackgroundTransparency=1; fV.Font=Enum.Font.GothamBlack; fV.TextSize=13; fV.TextColor3=Theme.Accent1; fV.TextXAlignment=Enum.TextXAlignment.Right; fV.Text=tostring(Config.FOV or 70)
        local fbg=Instance.new("Frame",fR); fbg.Size=UDim2.new(1,-20,0,6); fbg.Position=UDim2.new(0,10,0,34); fbg.BackgroundColor3=C().SH; fbg.BorderSizePixel=0; Instance.new("UICorner",fbg).CornerRadius=UDim.new(1,0)
        local ff=Instance.new("Frame",fbg); ff.BackgroundColor3=Theme.Accent1; ff.BorderSizePixel=0; ff.Size=UDim2.new(0,0,1,0); Instance.new("UICorner",ff).CornerRadius=UDim.new(1,0)
        local fk=Instance.new("Frame",fbg); fk.Size=UDim2.new(0,13,0,13); fk.AnchorPoint=Vector2.new(0.5,0.5); fk.BackgroundColor3=Color3.new(1,1,1); fk.BorderSizePixel=0; Instance.new("UICorner",fk).CornerRadius=UDim.new(1,0)
        local function updFOV(v) v=math.clamp(math.floor(v),30,180); Config.FOV=v; _F.SaveConfig(); fV.Text=tostring(v); local p=(v-30)/150; ff.Size=UDim2.new(p,0,1,0); fk.Position=UDim2.new(p,0,0.5,0); if Workspace.CurrentCamera then Workspace.CurrentCamera.FieldOfView=v end end
        updFOV(Config.FOV or 70)
        local fD=false
        fbg.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then fD=false end end)
        UserInputService.InputChanged:Connect(function(i) if fD and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then updFOV(30+math.clamp((i.Position.X-fbg.AbsolutePosition.X)/fbg.AbsoluteSize.X,0,1)*150) end end)
    end
    makeSec(vS,"PERFORMANCE",40)

    -- ── MOVEMENT TAB ──
    local mS = tScrolls2["mov"]
    makeSec(mS,"MOVIMENTO",1)
    makeToggle(mS,"Infinite Jump",function() return State.infiniteJumpEnabled end,function(v) _F.setInfiniteJump(v) end,11)
    makeToggle(mS,"Auto Steal Speed",function() return Config.AutoStealSpeed end,function(v) Config.AutoStealSpeed=v; _F.SaveConfig() end,12)
    makeToggle(mS,"Auto Back",function() return Config.AutoBack end,function(v) Config.AutoBack=v; _F.SaveConfig(); if v and _G.startAutoBack then _G.startAutoBack() elseif _G.stopAutoBack then _G.stopAutoBack() end end,14)
    
    makeSec(mS,"ANTI-RAGDOLL",20)
    makeToggle(mS,"Anti-Ragdoll V1",function() return Config.AntiRagdoll>0 end,function(v) Config.AntiRagdoll=v and 1 or 0; if v then Config.AntiRagdollV2=false; _F.startAntiRagdollV2(false) end; _F.startAntiRagdoll(Config.AntiRagdoll); _F.SaveConfig() end,21)
    makeToggle(mS,"Anti-Ragdoll V2",function() return Config.AntiRagdollV2 end,function(v) Config.AntiRagdollV2=v; if v then Config.AntiRagdoll=0; _F.startAntiRagdoll(0); _F.startAntiRagdollV2(true) else _F.startAntiRagdollV2(false) end; _F.SaveConfig() end,22)
    makeSec(mS,"PROTECTION",25)
    makeSec(mS,"AUTO UNLOCK",28)
    makeToggle(mS,"Auto Unlock on Steal",function() return Config.AutoUnlockOnSteal end,function(v) Config.AutoUnlockOnSteal=v; _F.SaveConfig() end,281)
    makeSec(mS,"AUTOMATION",30)
    makeToggle(mS,"Auto Invis no Steal",function() return Config.AutoInvisDuringSteal end,function(v) Config.AutoInvisDuringSteal=v; _G.AutoInvisDuringSteal=v; _F.SaveConfig() end,31)
    makeToggle(mS,"Auto Kick no Steal",function() return Config.AutoKickOnSteal end,function(v) if _G.setAutoKickFromSettings then _G.setAutoKickFromSettings(v) else Config.AutoKickOnSteal=v; _F.SaveConfig() end end,32)
    makeToggle(mS,"Anti-Bee & Disco",function() return Config.AntiBeeDisco end,function(v) Config.AntiBeeDisco=v; _F.SaveConfig(); if v and SharedState.ANTI_BEE_DISCO then SharedState.ANTI_BEE_DISCO.Enable() elseif SharedState.ANTI_BEE_DISCO then SharedState.ANTI_BEE_DISCO.Disable() end end,34)
    makeToggle(mS,"Limpar Error GUIs",function() return Config.CleanErrorGUIs end,function(v) Config.CleanErrorGUIs=v; _F.SaveConfig() end,35)
    makeSec(mS,"BINDS",40)
    makeKey(mS,"Steal Speed",function() return Config.StealSpeedKey end,function(v) Config.StealSpeedKey=v end,41)
    makeKey(mS,"Invis Toggle",function() return Config.InvisToggleKey end,function(v) Config.InvisToggleKey=v; _G.INVISIBLE_STEAL_KEY=Enum.KeyCode[v] or Enum.KeyCode.I end,42)
    makeKey(mS,"Ragdoll Self",function() return Config.RagdollSelfKey ~= "" and Config.RagdollSelfKey or "NONE" end,function(v) Config.RagdollSelfKey=v; _F.SaveConfig() end,43)
    makeKey(mS,"Reset",function() return Config.ResetKey end,function(v) Config.ResetKey=v end,44)
    makeKey(mS,"Menu",function() return Config.MenuKey end,function(v) Config.MenuKey=v end,46)
    makeKey(mS,"Kick",function() return Config.KickKey ~= "" and Config.KickKey or "NONE" end,function(v) Config.KickKey=(v=="NONE" and "" or v) end,47)
    makeKey(mS,"Click To AP",function() return Config.ClickToAPKeybind or "L" end,function(v) Config.ClickToAPKeybind=v; _F.SaveConfig() end,48)
    makeKey(mS,"Proximity AP",function() return Config.ProximityAPKeybind or "P" end,function(v) Config.ProximityAPKeybind=v; _F.SaveConfig() end,49)
    do
        local rRejoin=Instance.new("Frame",mS); rRejoin.Size=UDim2.new(1,0,0,36); rRejoin.BackgroundColor3=C().SURF; rRejoin.BorderSizePixel=0; rRejoin.LayoutOrder=51; Instance.new("UICorner",rRejoin).CornerRadius=UDim.new(0,7)
        local rl=Instance.new("TextLabel",rRejoin); rl.Size=UDim2.new(0.6,0,1,0); rl.Position=UDim2.new(0,10,0,0); rl.BackgroundTransparency=1; rl.Text="Rejoin"; rl.Font=Enum.Font.GothamBold; rl.TextSize=11; rl.TextColor3=C().TP; rl.TextXAlignment=Enum.TextXAlignment.Left
        local rb=Instance.new("TextButton",rRejoin); rb.Size=UDim2.new(0,80,0,26); rb.Position=UDim2.new(1,-88,0.5,-13); rb.BackgroundColor3=Theme.Error; rb.Text="REJOIN"; rb.Font=Enum.Font.GothamBold; rb.TextSize=11; rb.TextColor3=Color3.new(1,1,1); rb.AutoButtonColor=false; Instance.new("UICorner",rb).CornerRadius=UDim.new(0,6)
        rb.MouseButton1Click:Connect(function() _F.ShowNotification("REJOIN","Reconnecting..."); task.delay(0.5,function() pcall(function() TeleportService:Teleport(game.PlaceId,LocalPlayer) end) end) end)
    end

    -- ── TP TAB ──
    local tpS = tScrolls2["tp"]

    makeSec(tpS,"AUTO TP",10)
    makeToggle(tpS,"Auto TP on Script Load",function() return Config.TpSettings.TpOnLoad end,function(v) Config.TpSettings.TpOnLoad=v; _F.SaveConfig() end,11)
    do
        local r=Instance.new("Frame",tpS); r.Size=UDim2.new(1,0,0,36); r.BackgroundColor3=C().SURF; r.BorderSizePixel=0; r.LayoutOrder=12; Instance.new("UICorner",r).CornerRadius=UDim.new(0,7)
        local lbl=Instance.new("TextLabel",r); lbl.Size=UDim2.new(0.6,0,0,16); lbl.Position=UDim2.new(0,10,0,10); lbl.BackgroundTransparency=1; lbl.Text="Min Gen for Auto TP"; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextColor3=C().TP; lbl.TextXAlignment=Enum.TextXAlignment.Left
        local tb=Instance.new("TextBox",r); tb.Size=UDim2.new(0,110,0,24); tb.Position=UDim2.new(1,-118,0.5,-12); tb.BackgroundColor3=C().SH; tb.Text=tostring(Config.TpSettings.MinGenForTp or ""); tb.Font=Enum.Font.Gotham; tb.TextSize=11; tb.TextColor3=C().TP; tb.PlaceholderText="e.g. 5k, 1m, 1b"; tb.ClearTextOnFocus=false; Instance.new("UICorner",tb).CornerRadius=UDim.new(0,5)
        tb.FocusLost:Connect(function() Config.TpSettings.MinGenForTp=tb.Text:gsub("%s",""); _F.SaveConfig() end)
    end

    makeSec(tpS,"TP TOOL",19)
    do
        local tools={"Flying Carpet","Cupid's Wings","Santa's Sleigh","Witch's Broom"}; local sws={}
        for idx,tn in ipairs(tools) do
            local r=Instance.new("Frame",tpS); r.Size=UDim2.new(1,0,0,34); r.BackgroundColor3=C().SURF; r.BorderSizePixel=0; r.LayoutOrder=20+idx; Instance.new("UICorner",r).CornerRadius=UDim.new(0,7)
            local lbl=Instance.new("TextLabel",r); lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,10,0,0); lbl.BackgroundTransparency=1; lbl.Text=tn; lbl.Font=Enum.Font.GothamBold; lbl.TextSize=11; lbl.TextColor3=C().TP; lbl.TextXAlignment=Enum.TextXAlignment.Left
            local sw=Instance.new("TextButton",r); sw.Size=UDim2.new(0,50,0,22); sw.Position=UDim2.new(1,-58,0.5,-11); sw.Font=Enum.Font.GothamBold; sw.TextSize=11; sw.AutoButtonColor=false; Instance.new("UICorner",sw).CornerRadius=UDim.new(0,5)
            local function ref() local on=Config.TpSettings.Tool==tn; sw.Text=on and"ON"or"OFF"; sw.BackgroundColor3=on and Theme.Accent1 or C().SH; sw.TextColor3=on and Color3.new(0,0,0) or C().TP end
            ref(); sw.MouseButton1Click:Connect(function() Config.TpSettings.Tool=tn; _F.SaveConfig(); for _,s in pairs(sws) do pcall(s) end end); sws[tn]=ref
        end
        local sRow=Instance.new("Frame",tpS); sRow.Size=UDim2.new(1,0,0,34); sRow.BackgroundColor3=C().SURF; sRow.BorderSizePixel=0; sRow.LayoutOrder=25; Instance.new("UICorner",sRow).CornerRadius=UDim.new(0,7)
        local sl=Instance.new("TextLabel",sRow); sl.Size=UDim2.new(0.55,0,1,0); sl.Position=UDim2.new(0,10,0,0); sl.BackgroundTransparency=1; sl.Text="Teleport Delay (1=Fast)"; sl.Font=Enum.Font.GothamBold; sl.TextSize=11; sl.TextColor3=C().TP; sl.TextXAlignment=Enum.TextXAlignment.Left
        local sCont=Instance.new("Frame",sRow); sCont.Size=UDim2.new(0,100,0,24); sCont.Position=UDim2.new(1,-108,0.5,-12); sCont.BackgroundTransparency=1
        local sBtns={}
        for i=1,4 do
            local sb=Instance.new("TextButton",sCont); sb.Size=UDim2.new(0.22,0,1,0); sb.Position=UDim2.new((i-1)*0.26,0,0,0); sb.Font=Enum.Font.GothamBold; sb.TextSize=12; sb.AutoButtonColor=false; sb.Text=tostring(i); Instance.new("UICorner",sb).CornerRadius=UDim.new(0,4)
            local function ref() for j,b in ipairs(sBtns) do local on=j==Config.TpSettings.Speed; b.BackgroundColor3=on and Theme.Accent1 or C().SH; b.TextColor3=on and Color3.new(0,0,0) or C().TP end end
            sb.MouseButton1Click:Connect(function() Config.TpSettings.Speed=i; _F.SaveConfig(); ref() end); table.insert(sBtns,sb)
        end
        task.defer(function() for j,b in ipairs(sBtns) do local on=j==(Config.TpSettings.Speed or 2); b.BackgroundColor3=on and Theme.Accent1 or C().SH; b.TextColor3=on and Color3.new(0,0,0) or C().TP end end)
    end

    makeSec(tpS,"TP AUTOMATION",30)
    makeToggle(tpS,"Auto TP Priority Mode",function() return Config.AutoTPPriority end,function(v) Config.AutoTPPriority=v; _F.SaveConfig() end,31)
    makeToggle(tpS,"Auto TP on Failed Steal",function() return Config.AutoTpOnFailedSteal or false end,function(v) Config.AutoTpOnFailedSteal=v; _F.SaveConfig() end,32)
    makeToggle(tpS,"Auto TP Follow Target",function() return Config.AutoTPFollowTarget or false end,function(v) Config.AutoTPFollowTarget=v; _F.SaveConfig() end,33)

    makeSec(tpS,"TP KEYBINDS",40)
    makeKey(tpS,"TP Keybind",function() return Config.TpSettings.TpKey end,function(v) Config.TpSettings.TpKey=v end,41)
    makeKey(tpS,"Auto Clone Keybind",function() return Config.TpSettings.CloneKey end,function(v) Config.TpSettings.CloneKey=v end,42)
    makeKey(tpS,"Carpet Speed Keybind",function() return Config.TpSettings.CarpetSpeedKey end,function(v) Config.TpSettings.CarpetSpeedKey=v end,43)
    do
        local csRow=Instance.new("Frame",tpS); csRow.Size=UDim2.new(1,0,0,34); csRow.BackgroundColor3=C().SURF; csRow.BorderSizePixel=0; csRow.LayoutOrder=44; Instance.new("UICorner",csRow).CornerRadius=UDim.new(0,7)
        local csl=Instance.new("TextLabel",csRow); csl.Size=UDim2.new(0.6,0,1,0); csl.Position=UDim2.new(0,10,0,0); csl.BackgroundTransparency=1; csl.Text="Carpet Speed Status"; csl.Font=Enum.Font.GothamBold; csl.TextSize=11; csl.TextColor3=C().TP; csl.TextXAlignment=Enum.TextXAlignment.Left
        local cslv=Instance.new("TextLabel",csRow); cslv.Size=UDim2.new(0,50,0,20); cslv.Position=UDim2.new(1,-58,0.5,-10); cslv.BackgroundTransparency=1; cslv.Font=Enum.Font.GothamBlack; cslv.TextSize=13; cslv.TextXAlignment=Enum.TextXAlignment.Right
        task.spawn(function() while csRow and csRow.Parent do local on=State.carpetSpeedEnabled; cslv.Text=on and"ON"or"OFF"; cslv.TextColor3=on and Theme.Success or Theme.Error; task.wait(0.3) end end)
    end


    -- ── UI HIDE'S TAB ──
    local uhS = tScrolls2["uih"]
    makeSec(uhS,"HIDE UIs",1)
    makeToggle(uhS,"Hide Admin Panel",function() return Config.HideAdminPanel end,function(v) Config.HideAdminPanel=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("XiAdminPanel"); if g then g.Enabled=not v end end,11)
    makeToggle(uhS,"Hide Auto Steal",function() return Config.HideAutoSteal end,function(v) Config.HideAutoSteal=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("AutoStealUI"); if g then g.Enabled=not v end end,12)
    makeToggle(uhS,"Hide Status HUD",function() return Config.HideStatusHUD end,function(v) Config.HideStatusHUD=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("YinStatusHUD"); if g then g.Enabled=not v end end,15)
    makeToggle(uhS,"Mostrar Mini UI",function() return Config.ShowMiniActions end,function(v) Config.ShowMiniActions=v; _F.SaveConfig(); local g=PlayerGui:FindFirstChild("YinMiniActions"); if g then local mp=g:FindFirstChild("MiniPanel"); if mp then mp.Visible=v end end end,19)
    makeToggle(uhS,"Auto Hide ao Iniciar",function() return Config.AutoHideMiniUI end,function(v) Config.AutoHideMiniUI=v; _F.SaveConfig() end,20)
    makeSec(uhS,"UI CONTROLS",25)
    makeToggle(uhS,"Lock GUI (No Drag)",function() return Config.UILocked end,function(v)
        Config.UILocked=v; _F.SaveConfig()
        _F.ShowNotification("LOCK GUI", v and "🔒 Locked" or "🔓 Unlocked")
    end,26)

    -- ── INVIS TAB ──
    local iS = tScrolls2["inv"]
    makeToggle(iS,"Auto Fix Lagback",function() return _G.AutoRecoverLagback end,function(v) _G.AutoRecoverLagback=v; Config.AutoRecoverLagback=v; _F.SaveConfig() end,1)

    do  -- Rotation slider
        local r = Instance.new("Frame", iS)
        r.Size = UDim2.new(1,0,0,52)
        r.BackgroundColor3 = C().SURF
        r.BorderSizePixel = 0
        r.LayoutOrder = 2
        Instance.new("UICorner", r).CornerRadius = UDim.new(0,7)
        local rl = Instance.new("TextLabel", r)
        rl.Size = UDim2.new(1,-20,0,18)
        rl.Position = UDim2.new(0,10,0,4)
        rl.BackgroundTransparency = 1
        rl.Text = "Rotation: "..Config.InvisStealAngle
        rl.Font = Enum.Font.GothamBold
        rl.TextSize = 12
        rl.TextColor3 = C().TP
        rl.TextXAlignment = Enum.TextXAlignment.Left
        local rbg = Instance.new("Frame", r)
        rbg.Size = UDim2.new(1,-20,0,6)
        rbg.Position = UDim2.new(0,10,0,32)
        rbg.BackgroundColor3 = C().SH
        rbg.BorderSizePixel = 0
        Instance.new("UICorner", rbg).CornerRadius = UDim.new(1,0)
        local rfill = Instance.new("Frame", rbg)
        rfill.BackgroundColor3 = Theme.Accent1
        rfill.BorderSizePixel = 0
        Instance.new("UICorner", rfill).CornerRadius = UDim.new(1,0)
        local rk = Instance.new("Frame", rbg)
        rk.Size = UDim2.new(0,13,0,13)
        rk.AnchorPoint = Vector2.new(0.5,0.5)
        rk.BackgroundColor3 = Color3.new(1,1,1)
        rk.BorderSizePixel = 0
        Instance.new("UICorner", rk).CornerRadius = UDim.new(1,0)
        local function updRot(v)
            v = math.clamp(math.floor(v),180,360)
            Config.InvisStealAngle=v; _G.InvisStealAngle=v; _F.SaveConfig()
            rl.Text = "Rotation: "..v
            local p2 = (v-180)/180
            rfill.Size = UDim2.new(p2,0,1,0)
            rk.Position = UDim2.new(p2,0,0.5,0)
        end
        updRot(Config.InvisStealAngle)
        local rd = false
        rbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                rd=true; updRot(180+((i.Position.X-rbg.AbsolutePosition.X)/rbg.AbsoluteSize.X)*180)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then rd=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if rd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                updRot(180+((i.Position.X-rbg.AbsolutePosition.X)/rbg.AbsoluteSize.X)*180)
            end
        end)
    end

    do  -- Depth slider
        local r = Instance.new("Frame", iS)
        r.Size = UDim2.new(1,0,0,52)
        r.BackgroundColor3 = C().SURF
        r.BorderSizePixel = 0
        r.LayoutOrder = 3
        Instance.new("UICorner", r).CornerRadius = UDim.new(0,7)
        local rl = Instance.new("TextLabel", r)
        rl.Size = UDim2.new(1,-20,0,18)
        rl.Position = UDim2.new(0,10,0,4)
        rl.BackgroundTransparency = 1
        rl.Text = "Depth: "..Config.SinkSliderValue
        rl.Font = Enum.Font.GothamBold
        rl.TextSize = 12
        rl.TextColor3 = C().TP
        rl.TextXAlignment = Enum.TextXAlignment.Left
        local rbg = Instance.new("Frame", r)
        rbg.Size = UDim2.new(1,-20,0,6)
        rbg.Position = UDim2.new(0,10,0,32)
        rbg.BackgroundColor3 = C().SH
        rbg.BorderSizePixel = 0
        Instance.new("UICorner", rbg).CornerRadius = UDim.new(1,0)
        local rfill = Instance.new("Frame", rbg)
        rfill.BackgroundColor3 = Theme.Accent1
        rfill.BorderSizePixel = 0
        Instance.new("UICorner", rfill).CornerRadius = UDim.new(1,0)
        local rk = Instance.new("Frame", rbg)
        rk.Size = UDim2.new(0,13,0,13)
        rk.AnchorPoint = Vector2.new(0.5,0.5)
        rk.BackgroundColor3 = Color3.new(1,1,1)
        rk.BorderSizePixel = 0
        Instance.new("UICorner", rk).CornerRadius = UDim.new(1,0)
        local function updDepth(v)
            v = math.clamp(math.floor(v*10)/10, 0.5, 10)
            Config.SinkSliderValue=v; _G.SinkSliderValue=v; _F.SaveConfig()
            rl.Text = "Depth: "..v
            local p2 = (v-0.5)/9.5
            rfill.Size = UDim2.new(p2,0,1,0)
            rk.Position = UDim2.new(p2,0,0.5,0)
        end
        updDepth(Config.SinkSliderValue)
        local dd = false
        rbg.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                dd=true; updDepth(0.5+((i.Position.X-rbg.AbsolutePosition.X)/rbg.AbsoluteSize.X)*9.5)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dd=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dd and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                updDepth(0.5+((i.Position.X-rbg.AbsolutePosition.X)/rbg.AbsoluteSize.X)*9.5)
            end
        end)
    end

    -- ── TEMAS TAB ──
    local tS = tScrolls2["tem"]
    do
        local TDEFS2 = {
            {"Black",  "preto",    Color3.fromRGB(170,170,170)},
        }
        for i2, td2 in ipairs(TDEFS2) do
            local r = Instance.new("Frame", tS)
            r.Size = UDim2.new(1,0,0,36)
            r.BackgroundColor3 = C().SURF
            r.BorderSizePixel = 0
            r.LayoutOrder = i2
            Instance.new("UICorner", r).CornerRadius = UDim.new(0,7)

            local dot2 = Instance.new("Frame", r)
            dot2.Size = UDim2.new(0,12,0,12)
            dot2.Position = UDim2.new(0,12,0.5,-6)
            dot2.BackgroundColor3 = td2[3]
            dot2.BorderSizePixel = 0
            Instance.new("UICorner", dot2).CornerRadius = UDim.new(1,0)

            local nl = Instance.new("TextLabel", r)
            nl.Size = UDim2.new(0.5,0,1,0)
            nl.Position = UDim2.new(0,32,0,0)
            nl.BackgroundTransparency = 1
            nl.Text = td2[1]
            nl.Font = Enum.Font.GothamBold
            nl.TextSize = 12
            nl.TextColor3 = C().TP
            nl.TextXAlignment = Enum.TextXAlignment.Left

            local isActive = (Config.CurrentTheme == td2[2])
            local apb = Instance.new("TextButton", r)
            apb.Size = UDim2.new(0,72,0,24)
            apb.Position = UDim2.new(1,-80,0.5,-12)
            apb.BackgroundColor3 = isActive and td2[3] or C().SH
            apb.Text = isActive and "ACTIVE" or "APPLY"
            apb.Font = Enum.Font.GothamBold
            apb.TextSize = 10
            apb.TextColor3 = isActive and Color3.new(0,0,0) or C().TP
            apb.AutoButtonColor = false
            Instance.new("UICorner", apb).CornerRadius = UDim.new(0,5)
            local tid2 = td2[2]; local tc2 = td2[3]
            apb.MouseButton1Click:Connect(function()
                applyTheme(tid2)
                -- atualiza visual de todos os botoes
                for _, ch in ipairs(tS:GetChildren()) do
                    local b2 = ch:FindFirstChildOfClass("TextButton")
                    if b2 then
                        b2.BackgroundColor3 = C().SH
                        b2.Text = "APPLY"
                        b2.TextColor3 = C().TP
                    end
                end
                apb.BackgroundColor3 = tc2
                apb.Text = "ACTIVE"
                apb.TextColor3 = Color3.new(0,0,0)
            end)
        end
    end

    -- ── BLACKLIST TAB ──
    local blS = tScrolls2["bl"]

    -- ESP config for blacklisted players
    makeSec(blS, "BLACKLIST ESP", 0)
    makeToggle(blS, "Show Blacklist ESP", function() return Config.BlacklistESP ~= false end, function(v)
        Config.BlacklistESP = v; _F.SaveConfig()
        if not v then
            for _, p in ipairs(Players:GetPlayers()) do
                local char = p.Character
                if char then
                    local existing = char:FindFirstChild("YinBlacklistESP")
                    if existing then existing:Destroy() end
                end
            end
        end
    end, 1)

    -- Custom message row
    local blMsgRow = Instance.new("Frame", blS)
    blMsgRow.Size             = UDim2.new(1,0,0,36)
    blMsgRow.BackgroundColor3 = C().SURF
    blMsgRow.BackgroundTransparency = 0.05
    blMsgRow.BorderSizePixel  = 0
    blMsgRow.LayoutOrder      = 2
    Instance.new("UICorner", blMsgRow).CornerRadius = UDim.new(0,7)
    local blMsgLbl = Instance.new("TextLabel", blMsgRow)
    blMsgLbl.Size             = UDim2.new(0,60,1,0)
    blMsgLbl.Position         = UDim2.new(0,8,0,0)
    blMsgLbl.BackgroundTransparency = 1
    blMsgLbl.Text             = "Mensagem"
    blMsgLbl.Font             = Enum.Font.GothamBold
    blMsgLbl.TextSize         = 11
    blMsgLbl.TextColor3       = C().TP
    blMsgLbl.TextXAlignment   = Enum.TextXAlignment.Left
    local blMsgBox = Instance.new("TextBox", blMsgRow)
    blMsgBox.Size             = UDim2.new(1,-78,0,24)
    blMsgBox.Position         = UDim2.new(0,72,0.5,-12)
    blMsgBox.BackgroundColor3 = C().SH
    blMsgBox.Text             = Config.BlacklistMsg or "BLOCKED"
    blMsgBox.PlaceholderText  = "BLOCKED"
    blMsgBox.Font             = Enum.Font.GothamBold
    blMsgBox.TextSize         = 11
    blMsgBox.TextColor3       = C().TP
    blMsgBox.ClearTextOnFocus = false
    blMsgBox.BorderSizePixel  = 0
    Instance.new("UICorner", blMsgBox).CornerRadius = UDim.new(0,5)
    blMsgBox.FocusLost:Connect(function()
        local msg = blMsgBox.Text:gsub("%s+", " "):match("^%s*(.-)%s*$")
        if msg == "" then msg = "BLOCKED" end
        Config.BlacklistMsg = msg; _F.SaveConfig()
        blMsgBox.Text = msg
        -- Live-update all existing ESP labels
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            if char then
                local bb = char:FindFirstChild("YinBlacklistESP")
                if bb then
                    local lbl = bb:FindFirstChild("MsgLbl", true)
                    if lbl then lbl.Text = msg end
                end
            end
        end
    end)

    -- Input row
    local blInputRow = Instance.new("Frame", blS)
    blInputRow.Size = UDim2.new(1,0,0,44)
    blInputRow.BackgroundColor3 = C().SURF
    blInputRow.BorderSizePixel = 0
    blInputRow.LayoutOrder = 1
    Instance.new("UICorner", blInputRow).CornerRadius = UDim.new(0,7)

    local blBox = Instance.new("TextBox", blInputRow)
    blBox.Size = UDim2.new(1,-80,0,28)
    blBox.Position = UDim2.new(0,8,0.5,-14)
    blBox.BackgroundColor3 = C().SH
    blBox.Text = ""
    blBox.PlaceholderText = "Username..."
    blBox.Font = Enum.Font.GothamBold
    blBox.TextSize = 12
    blBox.TextColor3 = C().TP
    blBox.ClearTextOnFocus = false
    blBox.BorderSizePixel = 0
    Instance.new("UICorner", blBox).CornerRadius = UDim.new(0,6)

    local blAddBtn = Instance.new("TextButton", blInputRow)
    blAddBtn.Size = UDim2.new(0,60,0,28)
    blAddBtn.Position = UDim2.new(1,-68,0.5,-14)
    blAddBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
    blAddBtn.Text = "ADD"
    blAddBtn.Font = Enum.Font.GothamBold
    blAddBtn.TextSize = 12
    blAddBtn.TextColor3 = Color3.new(1,1,1)
    blAddBtn.AutoButtonColor = false
    blAddBtn.BorderSizePixel = 0
    Instance.new("UICorner", blAddBtn).CornerRadius = UDim.new(0,6)

    -- Counter label
    local blCount = Instance.new("Frame", blS)
    blCount.Size = UDim2.new(1,0,0,24)
    blCount.BackgroundTransparency = 1
    blCount.LayoutOrder = 2
    local blCountLbl = Instance.new("TextLabel", blCount)
    blCountLbl.Size = UDim2.new(1,0,1,0)
    blCountLbl.BackgroundTransparency = 1
    blCountLbl.Text = "BLACKLISTED (0)"
    blCountLbl.Font = Enum.Font.GothamBlack
    blCountLbl.TextSize = 11
    blCountLbl.TextColor3 = Color3.fromRGB(180,40,40)
    blCountLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- List container
    local blListContainer = Instance.new("Frame", blS)
    blListContainer.Size = UDim2.new(1,0,0,10) -- auto grows
    blListContainer.BackgroundTransparency = 1
    blListContainer.LayoutOrder = 3
    blListContainer.AutomaticSize = Enum.AutomaticSize.Y
    local blListLayout = Instance.new("UIListLayout", blListContainer)
    blListLayout.Padding = UDim.new(0,4)
    blListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    -- refreshBlacklistUI function
    refreshBlacklistUI = function()
        -- clear existing rows
        for _, ch in ipairs(blListContainer:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        blCountLbl.Text = "BLACKLISTED (" .. #BlacklistedPlayers .. ")"

        for i, name in ipairs(BlacklistedPlayers) do
            local entRow = Instance.new("Frame", blListContainer)
            entRow.Size = UDim2.new(1,0,0,36)
            entRow.BackgroundColor3 = Color3.fromRGB(50,20,20)
            entRow.BorderSizePixel = 0
            entRow.LayoutOrder = i
            Instance.new("UICorner", entRow).CornerRadius = UDim.new(0,7)
            local entStroke = Instance.new("UIStroke", entRow)
            entStroke.Color = Color3.fromRGB(180,40,40)
            entStroke.Thickness = 1; entStroke.Transparency = 0.5

            local iconLbl = Instance.new("TextLabel", entRow)
            iconLbl.Size = UDim2.new(0,24,1,0)
            iconLbl.Position = UDim2.new(0,6,0,0)
            iconLbl.BackgroundTransparency = 1
            iconLbl.Text = "🚫"
            iconLbl.TextSize = 14
            iconLbl.Font = Enum.Font.GothamBold
            iconLbl.TextColor3 = Color3.fromRGB(255,100,100)

            local nameLbl = Instance.new("TextLabel", entRow)
            nameLbl.Size = UDim2.new(1,-70,1,0)
            nameLbl.Position = UDim2.new(0,34,0,0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = name
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 12
            nameLbl.TextColor3 = C().TP
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd

            local remBtn = Instance.new("TextButton", entRow)
            remBtn.Size = UDim2.new(0,50,0,24)
            remBtn.Position = UDim2.new(1,-56,0.5,-12)
            remBtn.BackgroundColor3 = C().SH
            remBtn.Text = "❌"
            remBtn.Font = Enum.Font.GothamBold
            remBtn.TextSize = 13
            remBtn.TextColor3 = Theme.TextPrimary
            remBtn.AutoButtonColor = false
            remBtn.BorderSizePixel = 0
            Instance.new("UICorner", remBtn).CornerRadius = UDim.new(0,6)
            local n = name
            remBtn.MouseButton1Click:Connect(function()
                pcall(function()
                    removeFromBlacklist(n)
                    _F.ShowNotification("BLACKLIST", "✅ Removed: " .. n)
                    refreshBlacklistUI()
                end)
            end)
        end

        if #BlacklistedPlayers == 0 then
            local empty = Instance.new("TextLabel", blListContainer)
            empty.Size = UDim2.new(1,0,0,36)
            empty.BackgroundTransparency = 1
            empty.Text = "No players blacklisted"
            empty.Font = Enum.Font.GothamMedium
            empty.TextSize = 12
            empty.TextColor3 = C().TS
            empty.LayoutOrder = 1
        end
    end
    refreshBlacklistUI()

    blAddBtn.MouseButton1Click:Connect(function()
        pcall(function()
            local name = blBox.Text:gsub("%s", "")
            if name == "" then return end
            if addToBlacklist(name) then
                _F.ShowNotification("BLACKLIST", "🚫 Blocked: " .. name)
                blBox.Text = ""
                refreshBlacklistUI()
            else
                _F.ShowNotification("BLACKLIST", name .. " already blacklisted")
            end
        end)
    end)

    blBox.FocusLost:Connect(function(enter)
        if enter then blAddBtn.MouseButton1Click:Fire() end
    end)

    switchTab2("act")

    -- Expor ref global
    _G.YinSettingsUI = {panel=panel, switchTab=switchTab2, currentTab="cfg"}
end
task.spawn(buildYinSettingsUI)

task.spawn(function()
    task.wait(1.5)
    if Config.CurrentTheme and THEMES and THEMES[Config.CurrentTheme] then
        applyTheme(Config.CurrentTheme)
    end
end)

function buildMiniActionsUI()
    local pg = PlayerGui
    if not pg then return end
    local oldG = pg:FindFirstChild("YinMiniActions")
    if oldG then oldG:Destroy() end

    local maGui = Instance.new("ScreenGui")
    maGui.Name = "YinMiniActions"
    maGui.ResetOnSpawn = false
    maGui.DisplayOrder = 25
    maGui.Parent = pg

    -- ── REDESIGN: Iceman V2 - Actions Panel ───────────────────────────
    local W = 220
    local BTN_H = 34
    local PANEL_H = 430

    -- Cores do novo design
    local C_BG        = Color3.fromRGB(18, 20, 26)
    local C_HEADER_BG = Color3.fromRGB(26, 29, 38)
    local C_SURFACE   = Color3.fromRGB(32, 36, 48)
    local C_SURFH     = Color3.fromRGB(26, 29, 38)
    local C_ACCENT    = Color3.fromRGB(0, 220, 255)
    local C_ACCENT2   = Color3.fromRGB(0, 180, 230)
    local C_TEXT      = Color3.fromRGB(240, 248, 255)
    local C_TEXTSEC   = Color3.fromRGB(130, 200, 230)
    local C_BORDER    = Color3.fromRGB(148, 210, 245)
    local C_DANGER    = Color3.fromRGB(255, 90, 110)
    local C_DANGERBG  = Color3.fromRGB(255, 220, 230)

    local panel = Instance.new("Frame", maGui)
    panel.Name = "MiniPanel"
    panel.Size = UDim2.new(0, W, 0, PANEL_H)
    local savedPos = Config.MiniUIPos or {X=0.01, Y=0.35}
    panel.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    panel.BackgroundColor3 = C_BG
    panel.BackgroundTransparency = 0
    panel.BorderSizePixel = 0
    panel.Visible = not Config.AutoHideMiniUI
    panel.ClipsDescendants = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)

    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = C_BORDER
    pStroke.Thickness = 1
    pStroke.Transparency = 0
    task.defer(function() applyIceToPanel(panel, 6, 5) end)

    -- ── HEADER ────────────────────────────────────────────────────────────
    local headerBg = Instance.new("Frame", panel)
    headerBg.Name = "HeaderBg"
    headerBg.Size = UDim2.new(1, 0, 0, 38)
    headerBg.Position = UDim2.new(0, 0, 0, 0)
    headerBg.BackgroundColor3 = C_HEADER_BG
    headerBg.BorderSizePixel = 0
    Instance.new("UICorner", headerBg).CornerRadius = UDim.new(0, 14)
    -- fix bottom corners
    local hbCornerFix = Instance.new("Frame", headerBg)
    hbCornerFix.Size = UDim2.new(1, 0, 0, 14)
    hbCornerFix.Position = UDim2.new(0, 0, 1, -14)
    hbCornerFix.BackgroundColor3 = C_HEADER_BG
    hbCornerFix.BackgroundTransparency = 1
    hbCornerFix.BorderSizePixel = 0

    local headerDiv = Instance.new("Frame", panel)
    headerDiv.Size = UDim2.new(1, 0, 0, 1)
    headerDiv.Position = UDim2.new(0, 0, 0, 52)
    headerDiv.BackgroundColor3 = C_BORDER
    headerDiv.BorderSizePixel = 0

    -- Dot accent
    local dotFrame = Instance.new("Frame", headerBg)
    dotFrame.Size = UDim2.new(0, 7, 0, 7)
    dotFrame.Position = UDim2.new(0, 14, 0, 14)
    dotFrame.BackgroundColor3 = C_ACCENT
    dotFrame.BorderSizePixel = 0
    Instance.new("UICorner", dotFrame).CornerRadius = UDim.new(1, 0)

    -- Hub name
    local hubName = Instance.new("TextLabel", headerBg)
    hubName.Size = UDim2.new(1, -100, 0, 18)
    hubName.Position = UDim2.new(0, 26, 0, 8)
    hubName.BackgroundTransparency = 1
    hubName.Text = "ICEMAN V2"
    hubName.Font = Enum.Font.GothamBlack
    hubName.TextSize = 12
    hubName.TextColor3 = Color3.fromRGB(240, 248, 255)
    hubName.TextXAlignment = Enum.TextXAlignment.Left

    -- Sub label
    local hubSub = Instance.new("TextLabel", headerBg)
    hubSub.Size = UDim2.new(1, -100, 0, 14)
    hubSub.Position = UDim2.new(0, 26, 0, 28)
    hubSub.BackgroundTransparency = 1
    hubSub.Text = "Actions"
    hubSub.Font = Enum.Font.GothamMedium
    hubSub.TextSize = 10
    hubSub.TextColor3 = C_TEXTSEC
    hubSub.TextXAlignment = Enum.TextXAlignment.Left

    -- V5 Badge
    local badgeBg = Instance.new("Frame", headerBg)
    badgeBg.Size = UDim2.new(0, 28, 0, 18)
    badgeBg.Position = UDim2.new(1, -42, 0, 12)
    badgeBg.BackgroundColor3 = Color3.fromRGB(100, 210, 255)
    badgeBg.BackgroundTransparency = 0.85
    badgeBg.BorderSizePixel = 0
    Instance.new("UICorner", badgeBg).CornerRadius = UDim.new(1, 0)
    local badgeStroke = Instance.new("UIStroke", badgeBg)
    badgeStroke.Color = C_ACCENT
    badgeStroke.Thickness = 1
    badgeStroke.Transparency = 0.75

    local badgeTxt = Instance.new("TextLabel", badgeBg)
    badgeTxt.Size = UDim2.new(1, 0, 1, 0)
    badgeTxt.BackgroundTransparency = 1
    badgeTxt.Text = "V5"
    badgeTxt.Font = Enum.Font.GothamBlack
    badgeTxt.TextSize = 9
    badgeTxt.TextColor3 = C_ACCENT

    -- header is headerBg for dragging
    local header = headerBg

    -- Lock button (canto do header)
    local lockBtn = Instance.new("TextButton", headerBg)
    lockBtn.Size = UDim2.new(0, 20, 0, 20)
    lockBtn.Position = UDim2.new(1, -32, 0.5, -10)
    lockBtn.BackgroundColor3 = Config.MiniUILocked and C_ACCENT or C_SURFH
    lockBtn.BackgroundTransparency = 0.1
    lockBtn.Text = Config.MiniUILocked and "L" or "U"
    lockBtn.Font = Enum.Font.GothamBold
    lockBtn.TextSize = 10
    lockBtn.TextColor3 = Color3.new(1,1,1)
    lockBtn.AutoButtonColor = false
    lockBtn.Visible = false  -- opcional: esconde o lock já que temos badge
    Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(1, 0)
    local lockStroke = Instance.new("UIStroke", lockBtn)
    lockStroke.Color = C_ACCENT
    lockStroke.Thickness = 1
    lockStroke.Transparency = 0.3

    lockBtn.MouseButton1Click:Connect(function()
        Config.MiniUILocked = not Config.MiniUILocked
        _F.SaveConfig()
        lockBtn.Text = Config.MiniUILocked and "L" or "U"
        lockBtn.BackgroundColor3 = Config.MiniUILocked and C_ACCENT or C_SURFH
    end)

    -- Drag (only when not locked)
    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(inp)
            if Config.MiniUILocked then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = inp.Position
                startPos = panel.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        local ps = panel.Parent.AbsoluteSize
                        Config.MiniUIPos = {
                            X = panel.AbsolutePosition.X / ps.X,
                            Y = panel.AbsolutePosition.Y / ps.Y,
                        }
                        _F.SaveConfig()
                    end
                end)
            end
        end)
        header.InputChanged:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
                if dragging and dragStart then
                    local delta = inp.Position - dragStart
                    panel.Position = UDim2.new(
                        startPos.X.Scale, startPos.X.Offset + delta.X,
                        startPos.Y.Scale, startPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dragStart
                panel.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            end
        end)
    end

    -- Content area (rolável) - posição ajustada para novo header de 53px
    local cont = Instance.new("ScrollingFrame", panel)
    cont.Name = "MiniContent"
    cont.Size = UDim2.new(1, -16, 1, -62)
    cont.Position = UDim2.new(0, 8, 0, 58)
    cont.BackgroundTransparency = 1
    cont.BorderSizePixel = 0
    cont.ScrollBarThickness = 2
    cont.ScrollBarImageColor3 = C_ACCENT
    cont.ScrollBarImageTransparency = 0.5
    cont.CanvasSize = UDim2.new(0, 0, 0, 0)
    cont.AutomaticCanvasSize = Enum.AutomaticSize.Y
    cont.ScrollingDirection = Enum.ScrollingDirection.Y

    local ll = Instance.new("UIListLayout", cont)
    ll.Padding = UDim.new(0, 4)
    ll.SortOrder = Enum.SortOrder.LayoutOrder

    -- Section label nova UI
    local function miniSec(lbl, ord)
        local r = Instance.new("Frame", cont)
        r.Size = UDim2.new(1, 0, 0, 16)
        r.BackgroundTransparency = 1
        r.LayoutOrder = ord
        local t = Instance.new("TextLabel", r)
        t.Size = UDim2.new(1, -6, 1, 0)
        t.Position = UDim2.new(0, 2, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = lbl
        t.Font = Enum.Font.GothamBlack
        t.TextSize = 9
        t.TextColor3 = C_TEXTSEC
        t.TextXAlignment = Enum.TextXAlignment.Left
    end

    -- ── contador de ordem para UIListLayout ─────────────────────────────────
    local _layoutOrder = 0
    local function nextOrder()
        _layoutOrder = _layoutOrder + 1
        return _layoutOrder
    end

    -- ── converte nome de key em label curta legível ───────────────────────
    local KEY_DISPLAY = {
        LeftControl="CTRL", RightControl="CTRL", LeftShift="SHF", RightShift="SHF",
        LeftAlt="ALT", RightAlt="ALT", Space="SPC", Return="ENT", BackSpace="BSP",
        Delete="DEL", Insert="INS", Home="HME", End="END", PageUp="PGU", PageDown="PGD",
        Up="▲", Down="▼", Left="◄", Right="►",
        F1="F1",F2="F2",F3="F3",F4="F4",F5="F5",F6="F6",
        F7="F7",F8="F8",F9="F9",F10="F10",F11="F11",F12="F12",
        Zero="0",One="1",Two="2",Three="3",Four="4",
        Five="5",Six="6",Seven="7",Eight="8",Nine="9",
    }
    local function displayKey(cfgStr, fallback)
        local s = (cfgStr ~= nil and cfgStr ~= "") and cfgStr or (fallback or "")
        if s == "" then return "—" end
        if KEY_DISPLAY[s] then return KEY_DISPLAY[s] end
        return s:sub(1,1):upper()  -- letras simples: "T","R","X","Y"…
    end

    -- ── helper: botão de ação com keybind no quadrado ─────────────────────
    local function makeActionBtn(labelText, keyDisplay, isDanger, onClick)
        local row = Instance.new("Frame", cont)
        row.LayoutOrder = nextOrder()
        row.Size = UDim2.new(1, 0, 0, BTN_H)
        row.BackgroundColor3 = isDanger and C_DANGERBG or C_SURFACE
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local stroke = Instance.new("UIStroke", row)
        stroke.Color = isDanger and C_DANGER or C_BORDER
        stroke.Thickness = 1
        stroke.Transparency = isDanger and 0.6 or 0.78

        -- quadrado da keybind (esquerda)
        local kBox = Instance.new("Frame", row)
        kBox.Size = UDim2.new(0, 28, 0, 22)
        kBox.Position = UDim2.new(0, 7, 0.5, -11)
        kBox.BackgroundColor3 = isDanger and C_DANGER or C_ACCENT
        kBox.BackgroundTransparency = 0.82
        kBox.BorderSizePixel = 0
        Instance.new("UICorner", kBox).CornerRadius = UDim.new(0, 5)
        local kBoxStroke = Instance.new("UIStroke", kBox)
        kBoxStroke.Color = isDanger and C_DANGER or C_ACCENT
        kBoxStroke.Thickness = 1; kBoxStroke.Transparency = 0.65

        local kLbl = Instance.new("TextLabel", kBox)
        kLbl.Size = UDim2.new(1, -2, 1, 0)
        kLbl.BackgroundTransparency = 1
        kLbl.Text = keyDisplay
        kLbl.Font = Enum.Font.GothamBlack
        kLbl.TextSize = 9
        kLbl.TextColor3 = isDanger and C_DANGER or C_ACCENT2
        kLbl.TextXAlignment = Enum.TextXAlignment.Center
        kLbl.TextTruncate = Enum.TextTruncate.AtEnd

        -- label do botão
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -44, 1, 0)
        lbl.Position = UDim2.new(0, 42, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 11
        lbl.TextColor3 = isDanger and C_DANGER or C_TEXT
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd

        -- feedback visual ao clicar
        local function flashClick()
            TweenService:Create(row, TweenInfo.new(0.07), {
                BackgroundColor3 = isDanger and Color3.fromRGB(80, 20, 20) or C_ACCENT
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.07), {Transparency = 0}):Play()
            task.delay(0.12, function()
                if row.Parent then
                    TweenService:Create(row, TweenInfo.new(0.15), {
                        BackgroundColor3 = isDanger and C_DANGERBG or C_SURFACE
                    }):Play()
                    TweenService:Create(stroke, TweenInfo.new(0.15), {
                        Transparency = isDanger and 0.6 or 0.78
                    }):Play()
                end
            end)
        end

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {
                BackgroundColor3 = isDanger and Color3.fromRGB(52, 14, 14) or C_SURFH
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.1), {
                Transparency = isDanger and 0.3 or 0.4
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {
                BackgroundColor3 = isDanger and C_DANGERBG or C_SURFACE
            }):Play()
            TweenService:Create(stroke, TweenInfo.new(0.1), {
                Transparency = isDanger and 0.6 or 0.78
            }):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            flashClick()
            task.spawn(onClick)
        end)
        return row, lbl, kLbl
    end

    local function makeDiv()
        local d = Instance.new("Frame", cont)
        d.LayoutOrder = nextOrder()
        d.Size = UDim2.new(1, 0, 0, 1)
        d.BackgroundColor3 = C_BORDER
        d.BackgroundTransparency = 0.45
        d.BorderSizePixel = 0
    end

    -- ── AÇÕES ─────────────────────────────────────────────────────────────

    -- 1. Teleport (Manual) → usa Config.TpSettings.TpKey, chama _F.tpToBestBrainrot / _F.runAutoSnipe
    makeActionBtn(
        "Teleport (Manual)",
        displayKey(Config.TpSettings and Config.TpSettings.TpKey, "T"),
        false,
        function()
            if _G.tpToBestBrainrot then
                pcall(_G.tpToBestBrainrot)
            elseif _G.runAutoSnipe then
                pcall(_G.runAutoSnipe)
            else
                pcall(_F.runAutoSnipe)
            end
            _F.ShowNotification("TELEPORT", "Teleporting...")
        end
    )

    -- 2. Ragdoll Self → usa Config.RagdollSelfKey, chama admin command "ragdoll" no próprio player
    makeActionBtn(
        "Ragdoll Self",
        displayKey(Config.RagdollSelfKey, "R"),
        false,
        function()
            local admin = _G.runAdminCommand
            if not admin then
                _F.ShowNotification("RAGDOLL", "Admin not ready")
                return
            end
            -- verifica cooldown via atributo do servidor
            local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
            local now = tick()  -- usa tick() para comparar cooldown
            if endTime and endTime > now then
                _F.ShowNotification("RAGDOLL SELF", "On cooldown")
                return
            end
            if pcall(admin, LocalPlayer, "ragdoll") then
                _F.ShowNotification("RAGDOLL SELF", "Done!")
            else
                _F.ShowNotification("RAGDOLL SELF", "Failed")
            end
        end
    )

    makeDiv()

    -- 3. Rejoin → novo servidor aleatório
    makeActionBtn(
        "Rejoin",
        "—",
        false,
        function()
            _F.ShowNotification("REJOIN", "Reconnecting to new server...")
            task.delay(0.6, function()
                local ok = pcall(function()
                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end)
                if not ok then
                    pcall(function()
                        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            end)
        end
    )

    -- 4. Rejoin PS → mesmo servidor (mesmo Job ID)
    makeActionBtn(
        "Rejoin PS",
        "—",
        false,
        function()
            _F.ShowNotification("REJOIN PS", "Rejoining same server...")
            task.delay(0.6, function()
                local ok = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end)
                if not ok then
                    _F.ShowNotification("REJOIN PS", "Failed — trying plain rejoin")
                    pcall(function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end)
                end
            end)
        end
    )

    makeDiv()

    -- 5. Kick → desconecta o próprio player usando Config.KickKey
    makeActionBtn(
        "Kick",
        displayKey(Config.KickKey, "Y"),
        false,
        function()
            _F.ShowNotification("KICK", "Kicking self...")
            task.delay(0.3, function()
                pcall(_F.kickPlayer)
            end)
        end
    )

    -- 6. Reset → reseta o personagem usando Config.ResetKey
    makeActionBtn(
        "Reset",
        displayKey(Config.ResetKey, "X"),
        true,
        function()
            _F.ShowNotification("RESET", "Resetting character...")
            task.delay(0.2, function()
                local ok = pcall(_F.executeReset)
                if not ok then
                    -- fallback: força morte via Humanoid
                    pcall(function()
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        if hum then hum.Health = 0 end
                    end)
                end
            end)
        end
    )

    makeDiv()

    makeDiv()

    -- ── Optimizer toggle ─────────────────────────────────────────────────
    makeActionBtn(
        "Optimizer",
        "OPT",
        false,
        function()
            if _G._YinOptimizerActive then
                -- Can't undo optimizer easily, notify
                _F.ShowNotification("OPTIMIZER", "Restart to disable")
            else
                _G._YinOptimizerActive = true
                -- Run the optimizer inline
                task.spawn(function()
                    local L = game:GetService("Lighting")
                    L.GlobalShadows = false
                    L.FogEnd = 9e9; L.FogStart = 9e9
                    L.EnvironmentDiffuseScale = 0
                    L.EnvironmentSpecularScale = 0
                    L.Ambient = Color3.fromRGB(160,160,160)
                    L.OutdoorAmbient = Color3.fromRGB(160,160,160)
                    -- Grey sky
                    for _, v in ipairs(L:GetChildren()) do
                        if v:IsA("PostEffect") or v:IsA("Atmosphere") or v:IsA("Sky") then v:Destroy() end
                    end
                    local cc = Instance.new("ColorCorrectionEffect", L)
                    cc.Name = "GreySkyCC"; cc.Saturation = -1; cc.Brightness = 0
                    local sky = Instance.new("Sky", L)
                    sky.SkyboxBk="rbxassetid://6444320088"; sky.SkyboxDn="rbxassetid://6444320088"
                    sky.SkyboxFt="rbxassetid://6444320088"; sky.SkyboxLf="rbxassetid://6444320088"
                    sky.SkyboxRt="rbxassetid://6444320088"; sky.SkyboxUp="rbxassetid://6444320088"
                    sky.CelestialBodiesShown = false
                    -- Remove visuals from workspace
                    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
                    pcall(function() setfpscap(999) end)
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        pcall(function()
                            if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                                obj.Enabled = false
                            elseif obj:IsA("SurfaceAppearance") then
                                obj:Destroy()
                            elseif obj:IsA("BasePart") then
                                obj.CastShadow = false
                            end
                        end)
                    end
                    _F.ShowNotification("OPTIMIZER", "Applied ✓")
                end)
            end
        end
    )

    -- ── Instant Sell ──────────────────────────────────────────────────────
    makeActionBtn(
        "Instant Sell",
        "SL",
        false,
        function()
            -- Find my plots and sell a random brainrot
            local function findMyPlotsSell()
                local plots = workspace:FindFirstChild("Plots")
                local mine = {}
                if not plots then return mine end
                for _, plot in ipairs(plots:GetChildren()) do
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign then
                        local yb = sign:FindFirstChild("YourBase")
                        if yb and yb:IsA("BillboardGui") and yb.Enabled then table.insert(mine,plot); continue end
                        for _, d in ipairs(sign:GetDescendants()) do
                            if d:IsA("TextLabel") then
                                local t = d.Text:lower()
                                if t:find(LocalPlayer.Name:lower(),1,true) or t:find(LocalPlayer.DisplayName:lower(),1,true) then
                                    table.insert(mine,plot); break
                                end
                            end
                        end
                    end
                end
                return mine
            end
            local valid = {}
            for _, plot in ipairs(findMyPlotsSell()) do
                local pods = plot:FindFirstChild("AnimalPodiums")
                if pods then
                    for _, pod in ipairs(pods:GetChildren()) do
                        for _, d in ipairs(pod:GetDescendants()) do
                            if d:IsA("ProximityPrompt") and d.Enabled then
                                table.insert(valid, d); break
                            end
                        end
                    end
                end
            end
            if #valid == 0 then _F.ShowNotification("SELL", "No brainrots found"); return end
            local prompt = valid[math.random(1,#valid)]
            local ok = pcall(function()
                if fireproximityprompt then fireproximityprompt(prompt) end
            end)
            _F.ShowNotification("SELL", ok and "Sold ✓" or "Failed ✗")
        end
    )

    -- ── Settings (botão largo roxo) ───────────────────────────────────────
    do
        local settingsRow = Instance.new("Frame", cont)
        settingsRow.LayoutOrder = nextOrder()
        settingsRow.Size = UDim2.new(1, 0, 0, 36)
        settingsRow.BackgroundColor3 = C_ACCENT
        settingsRow.BackgroundTransparency = 0.82
        settingsRow.BorderSizePixel = 0
        Instance.new("UICorner", settingsRow).CornerRadius = UDim.new(0, 8)

        local sStroke = Instance.new("UIStroke", settingsRow)
        sStroke.Color = C_ACCENT; sStroke.Thickness = 1; sStroke.Transparency = 0.6

        local sLbl = Instance.new("TextLabel", settingsRow)
        sLbl.Size = UDim2.new(1, 0, 1, 0)
        sLbl.BackgroundTransparency = 1
        sLbl.Text = "⚙  Settings"
        sLbl.Font = Enum.Font.GothamBold
        sLbl.TextSize = 12
        sLbl.TextColor3 = C_ACCENT2
        sLbl.TextXAlignment = Enum.TextXAlignment.Center

        local sBtn = Instance.new("TextButton", settingsRow)
        sBtn.Size = UDim2.new(1, 0, 1, 0)
        sBtn.BackgroundTransparency = 1; sBtn.Text = ""; sBtn.AutoButtonColor = false
        sBtn.MouseEnter:Connect(function()
            TweenService:Create(settingsRow, TweenInfo.new(0.1), {BackgroundTransparency = 0.6}):Play()
            TweenService:Create(sStroke, TweenInfo.new(0.1), {Transparency = 0.25}):Play()
        end)
        sBtn.MouseLeave:Connect(function()
            TweenService:Create(settingsRow, TweenInfo.new(0.1), {BackgroundTransparency = 0.82}):Play()
            TweenService:Create(sStroke, TweenInfo.new(0.1), {Transparency = 0.6}):Play()
        end)
        sBtn.MouseButton1Click:Connect(function()
            -- tenta a Settings nova (YinSettingsUI) e cai no SettingsUI antigo
            if _G.YinSettingsUI and _G.YinSettingsUI.panel then
                _G.YinSettingsUI.panel.Visible = not _G.YinSettingsUI.panel.Visible
            else
                local sg = PlayerGui:FindFirstChild("SettingsUI") or PlayerGui:FindFirstChild("YinSettings")
                if sg then sg.Enabled = not sg.Enabled end
            end
        end)
    end

    -- altura total calculada
    local totalH = 54 + (BTN_H * 8) + (6 * 9) + 3 + 36 + 20
    panel.Size = UDim2.new(0, W, 0, totalH)

    _G.MiniActionsUI = {panel = panel, gui = maGui}
    return maGui
end


task.spawn(function()
    buildMiniActionsUI()
    -- Auto hide on start
    if Config.AutoHideMiniUI then
        local g = PlayerGui:FindFirstChild("YinMiniActions")
        if g and g:FindFirstChild("MiniPanel") then
            g.MiniPanel.Visible = false
        end
    end
end)

-- ══════════════════════════════════════════════════════════════════════
-- ICEMAN V2 — STEAL PANEL UI
-- ══════════════════════════════════════════════════════════════════════
task.spawn(function()
    local pg = PlayerGui
    if not pg then return end

    -- ── cores (mesmas do Actions panel) ─────────────────────────────────
    local C_BG      = Color3.fromRGB(18, 20, 26)
    local C_HEADER  = Color3.fromRGB(26, 29, 38)
    local C_SURFACE = Color3.fromRGB(32, 36, 48)
    local C_SURFH   = Color3.fromRGB(26, 29, 38)
    local C_ACCENT  = Color3.fromRGB(0, 220, 255)
    local C_ACCENT2 = Color3.fromRGB(0, 180, 230)
    local C_TEXT    = Color3.fromRGB(240, 248, 255)
    local C_TEXTSEC = Color3.fromRGB(130, 200, 230)
    local C_BORDER  = Color3.fromRGB(148, 210, 245)
    local C_ON      = Color3.fromRGB(0, 220, 255)
    local C_ONBG    = Color3.fromRGB(200, 240, 255)
    local C_OFF     = Color3.fromRGB(170, 210, 240)
    local C_OFFBG   = C_SURFACE

    local W, ROW_H = 230, 34

    -- ── ScreenGui ────────────────────────────────────────────────────────
    local oldG = pg:FindFirstChild("YinStealPanel")
    if oldG then oldG:Destroy() end

    local spGui = Instance.new("ScreenGui")
    spGui.Name = "YinStealPanel"
    spGui.ResetOnSpawn = false
    spGui.DisplayOrder = 24
    spGui.Parent = pg

    -- ── painel ────────────────────────────────────────────────────────────
    local spPos = Config.Positions and Config.Positions.StealPanel or {X=0.02, Y=0.55}
    local panel = Instance.new("Frame", spGui)
    panel.Name = "StealPanel"
    panel.Size = UDim2.new(0, W, 0, 10) -- sera ajustada depois
    panel.Position = UDim2.new(spPos.X, 0, spPos.Y, 0)
    panel.BackgroundColor3 = C_BG
    panel.BackgroundTransparency = 0
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = C_BORDER; pStroke.Thickness = 1; pStroke.Transparency = 0
    task.defer(function() applyIceToPanel(panel, 7, 6) end)

    -- drag
    do
        local dragging, dragStart, startPos
        panel.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; startPos = panel.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        local ps = panel.Parent.AbsoluteSize
                        if Config.Positions then
                            Config.Positions.StealPanel = {
                                X = panel.AbsolutePosition.X / ps.X,
                                Y = panel.AbsolutePosition.Y / ps.Y,
                            }
                            _F.SaveConfig()
                        end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dragStart
                panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- ── content (lista de toggles) ────────────────────────────────────────
    local cont = Instance.new("Frame", panel)
    cont.Size = UDim2.new(1, -16, 0, 0)
    cont.Position = UDim2.new(0, 8, 0, 8)
    cont.BackgroundTransparency = 1
    cont.AutomaticSize = Enum.AutomaticSize.Y
    local ll = Instance.new("UIListLayout", cont)
    ll.Padding = UDim.new(0, 5); ll.SortOrder = Enum.SortOrder.LayoutOrder; ll.FillDirection = Enum.FillDirection.Vertical

    -- ── toggle row helper ─────────────────────────────────────────────────
    -- isRadio: true = só um do grupo pode ser ON
    local allToggles = {}  -- {getState, setState, updateVisual}

    local function makeToggleRow(labelText, order, getState, onToggle)
        local row = Instance.new("Frame", cont)
        row.Size = UDim2.new(1, 0, 0, ROW_H)
        row.BackgroundColor3 = C_SURFACE
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        local rStroke = Instance.new("UIStroke", row)
        rStroke.Color = C_BORDER; rStroke.Thickness = 1; rStroke.Transparency = 0.75

        -- label
        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -76, 1, 0); lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1; lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
        lbl.TextColor3 = C_TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd

        -- pill ON/OFF
        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0, 52, 0, 22); pill.Position = UDim2.new(1, -62, 0.5, -11)
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0, 6)
        local pillStroke = Instance.new("UIStroke", pill)
        pillStroke.Thickness = 1

        local pillTxt = Instance.new("TextLabel", pill)
        pillTxt.Size = UDim2.new(1, 0, 1, 0); pillTxt.BackgroundTransparency = 1
        pillTxt.Font = Enum.Font.GothamBlack; pillTxt.TextSize = 10

        local function updateVisual()
            local on = getState()
            pill.BackgroundColor3 = on and C_ONBG or C_OFFBG
            pill.BackgroundTransparency = 0
            pillStroke.Color = on and C_ON or C_BORDER
            pillStroke.Transparency = on and 0.5 or 0.7
            pillTxt.Text = on and "ON" or "OFF"
            pillTxt.TextColor3 = on and C_ON or C_OFF
            rStroke.Color = on and C_ACCENT or C_BORDER
            rStroke.Transparency = on and 0.6 or 0.75
        end
        updateVisual()

        -- botão invisível sobre toda a row
        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.AutoButtonColor = false
        btn.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFH}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFACE}):Play()
        end)
        btn.MouseButton1Click:Connect(function()
            onToggle()
            updateVisual()
        end)

        table.insert(allToggles, updateVisual)
        return updateVisual
    end

    -- ── 6 opções ──────────────────────────────────────────────────────────

    -- 1. Steal Highest
    -- Lê Config (mantido em sync pelo _G.setStealMode)
    local function getHighest()  return Config.StealHighest  == true end
    local function getPriority() return Config.StealPriority == true end
    local function getNearest()  return Config.StealNearest  == true end

    -- Radio toggle: chama _G.setStealMode (que altera as vars locais do auto steal)
    -- e depois atualiza os visuais do painel
    local function radioToggle(mode)
        if _G.setStealMode then
            pcall(_G.setStealMode, mode)
        else
            Config.StealHighest  = (mode == "highest")
            Config.StealNearest  = (mode == "nearest")
            Config.StealPriority = (mode == "priority")
            _F.SaveConfig()
        end
        task.defer(function()
            for _, u in ipairs(allToggles) do pcall(u) end
        end)
    end

    -- 1. Steal Highest — busca o pet de maior valor $/s do server
    local updHigh = makeToggleRow("Steal Highest", 1, getHighest, function()
        radioToggle("highest")
    end)

    -- 2. Steal Priority — prioriza pets da Priority List em ordem
    local updPri = makeToggleRow("Steal Priority", 2, getPriority, function()
        radioToggle("priority")
    end)

    -- 3. Steal Nearest — pega o pet mais próximo do player
    local updNear = makeToggleRow("Steal Nearest", 3, getNearest, function()
        radioToggle("nearest")
    end)

    -- divisor
    local div = Instance.new("Frame", cont)
    div.Size = UDim2.new(1, 0, 0, 1); div.BackgroundColor3 = C_BORDER
    div.BackgroundTransparency = 0.45; div.BorderSizePixel = 0; div.LayoutOrder = 4

    -- 4. Auto Turret — destrói SubspaceTripmines do ToolsAdds folder
    local updTurret = makeToggleRow("Auto Turret", 5,
        function() return Config.AutoDestroyTurrets == true end,
        function()
            Config.AutoDestroyTurrets = not (Config.AutoDestroyTurrets == true)
            _F.SaveConfig()
            if _G.setAutoDestroyTurretsFromSettings then
                pcall(_G.setAutoDestroyTurretsFromSettings, Config.AutoDestroyTurrets)
            end
        end)

    -- 5. Auto Kick
    local updKick = makeToggleRow("Auto Kick", 6,
        function() return Config.AutoKickOnSteal == true end,
        function()
            Config.AutoKickOnSteal = not (Config.AutoKickOnSteal == true)
            _F.SaveConfig()
            if _G.setAutoKickFromSettings then
                pcall(_G.setAutoKickFromSettings, Config.AutoKickOnSteal)
            end
        end)

    -- 6. Auto Buy — compra automaticamente o melhor pet do conveyor
    local updAutoBuy = makeToggleRow("Auto Buy", 7,
        function() return Config.AutoBuyEnabled == true end,
        function()
            Config.AutoBuyEnabled = not (Config.AutoBuyEnabled == true)
            _F.SaveConfig()
            if _G.setAutoBuyEnabled then
                pcall(_G.setAutoBuyEnabled, Config.AutoBuyEnabled)
            end
        end)

    -- ── ajusta altura do panel ─────────────────────────────────────────────
    task.defer(function()
        local contentH = ll.AbsoluteContentSize.Y
        panel.Size = UDim2.new(0, W, 0, 16 + contentH + 10)
    end)
    ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        panel.Size = UDim2.new(0, W, 0, 16 + ll.AbsoluteContentSize.Y + 10)
    end)

    -- ── expõe refresh global ───────────────────────────────────────────────
    _G.refreshStealPanel = function()
        for _, u in ipairs(allToggles) do pcall(u) end
    end
    SharedState.UpdateStealPanelUI = _G.refreshStealPanel
end)


-- ══════════════════════════════════════════════════════════════════════
-- ICEMAN V2 — AUTO TURRET
-- ══════════════════════════════════════════════════════════════════════
task.spawn(function()
    local function getChar()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChildWhichIsA("BasePart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        return char, hrp, hum
    end

    local function hasExclamation(target)
        if not target or not target.Parent then return false end
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                for _, label in ipairs(d:GetDescendants()) do
                    if label:IsA("TextLabel") and label.Text:find("!") then return true end
                end
            end
        end
        return false
    end

    local function applyVisuals(target)
        if not target or not target.Parent then return end
        pcall(function()
            local sel = target:FindFirstChildWhichIsA("SelectionBox") or Instance.new("SelectionBox")
            sel.Color3 = Color3.fromRGB(255, 50, 50)
            sel.LineThickness = 0.08
            sel.SurfaceColor3 = Color3.fromRGB(255, 50, 50)
            sel.SurfaceTransparency = 0.7
            sel.Adornee = target
            sel.Parent = target
        end)
    end

    local function getClosestSentry()
        local char, hrp = getChar()
        if not hrp then return nil end
        local closest, closestDist = nil, 60
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if (inst.Name:lower():find("sentry") or inst.Name:lower():find("turret"))
                and (inst:IsA("Model") or inst:IsA("BasePart"))
                and hasExclamation(inst) then
                local pos = inst:IsA("Model") and inst:GetPivot().Position
                    or inst.Position
                local dist = (pos - hrp.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist; closest = inst
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
                    while targetSentry and targetSentry.Parent
                        and (LocalPlayer:GetAttribute("Stealing") ~= true) do
                        local char, hrp, hum = getChar()
                        local bat = LocalPlayer.Backpack:FindFirstChild("Bat")
                            or char:FindFirstChild("Bat")
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

-- ══════════════════════════════════════════════════════════════════════
-- ICEMAN V2 — AUTO BUY
-- ══════════════════════════════════════════════════════════════════════
task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end
    task.wait(2)

    local autoBuyActive = false

    -- Expõe toggle externo para o Steal Panel
    _G.setAutoBuyEnabled = function(enabled)
        Config.AutoBuyEnabled = enabled
        autoBuyActive = enabled
        _F.SaveConfig()
        if _G.refreshStealPanel then pcall(_G.refreshStealPanel) end
        _F.ShowNotification("AUTO BUY", enabled and "ENABLED" or "DISABLED")
    end

    -- Keybind (K por padrão, configurável via Config.AutoBuyKey)
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local buyKC = _F.safeKeyCode(Config.AutoBuyKey, Enum.KeyCode.K)
        if input.KeyCode == buyKC then
            Config.AutoBuyEnabled = not (Config.AutoBuyEnabled == true)
            autoBuyActive = Config.AutoBuyEnabled
            _F.SaveConfig()
            _F.ShowNotification("AUTO BUY", autoBuyActive and "ENABLED" or "DISABLED")
            if _G.refreshStealPanel then pcall(_G.refreshStealPanel) end
        end
    end)

    local function firePurchase(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return end
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt)
        else
            local vim = VirtualInputManager
            local inset = GuiService:GetGuiInset()
            -- tenta via VIM como fallback
            pcall(function()
                prompt:InputBegan(Enum.UserInputType.MouseButton1)
                task.wait(0.05)
                prompt:InputEnded(Enum.UserInputType.MouseButton1)
            end)
        end
    end

    local function getBestConveyorPet()
        local best, bestGv = nil, -1
        for _, entry in ipairs(SharedState.ConveyorAnimals or {}) do
            local gv = tonumber(entry.gv) or 0
            if entry.prompt and entry.prompt.Parent and entry.prompt.Enabled
            and entry.part and entry.part.Parent and gv > bestGv then
                bestGv = gv
                best = entry
            end
        end
        return best
    end

    while true do
        task.wait(0.1)
        if not (Config.AutoBuyEnabled == true) then continue end

        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        local best = getBestConveyorPet()
        if not best then continue end

        local dist = (hrp.Position - best.part.Position).Magnitude
        local range = Config.AutoBuyRange or 17

        if dist <= range then
            firePurchase(best.prompt)
        end
    end
end)


-- ══════════════════════════════════════════════════════════════════════
-- ICEMAN V2 — TP TO PLAYER BASE
-- ══════════════════════════════════════════════════════════════════════
do
    local _isTpMoving = false

    -- Encontra o plot de um player pelo PlotSign
    local function findPlotBySignForPlayer(player)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots or not player then return nil end
        local username    = tostring(player.Name        or ""):lower()
        local displayName = tostring(player.DisplayName or ""):lower()

        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    for _, ui in ipairs(surfaceGui:GetDescendants()) do
                        if ui:IsA("TextLabel") or ui:IsA("TextButton") then
                            local t = ui.Text
                            if type(t) == "string" then
                                local tl = t:lower()
                                if (username ~= "" and tl:find(username, 1, true))
                                or (displayName ~= "" and tl:find(displayName, 1, true)) then
                                    local signPart = sign:IsA("BasePart") and sign
                                                  or sign:FindFirstChildWhichIsA("BasePart", true)
                                    return plot, signPart
                                end
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    -- Teleporta o LocalPlayer para a base do player alvo
    _G.tpToPlayerBase = function(targetPlayer)
        if _isTpMoving then
            _F.ShowNotification("TP BASE", "Already teleporting!")
            return
        end

        local char = LocalPlayer.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then
            _F.ShowNotification("TP BASE", "Character not ready")
            return
        end

        local targetPlot, targetSignPart = findPlotBySignForPlayer(targetPlayer)
        if not targetPlot then
            _F.ShowNotification("TP BASE", "Base not found for " .. (targetPlayer.Name or "?"))
            return
        end

        local ok, err = pcall(function()
            -- Posição central do plot
            local plotPos = nil
            pcall(function() plotPos = targetPlot:GetPivot().Position end)
            if not plotPos then
                local plotPart = targetPlot:FindFirstChild("MainRootPart")
                              or targetPlot:FindFirstChildWhichIsA("BasePart")
                if plotPart then plotPos = plotPart.Position end
            end
            if not plotPos then error("Plot position not found") end

            _isTpMoving = true
            _F.ShowNotification("TP BASE", "Going to " .. (targetPlayer.DisplayName or targetPlayer.Name))

            -- Equipa a ferramenta de TP se existir
            local carpetName = Config.TpSettings and Config.TpSettings.Tool or "Flying Carpet"
            if carpetName and carpetName ~= "" then
                local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName)
                            or char:FindFirstChild(carpetName)
                if carpet then pcall(function() hum:EquipTool(carpet) end) end
            end

            -- Ponto de entrada: em frente ao sign, levemente acima
            local entryPos = plotPos + Vector3.new(0, 5, 0)
            if targetSignPart and targetSignPart:IsA("BasePart") then
                local signPos = targetSignPart.Position
                local dir = (signPos - plotPos)
                dir = (dir.Magnitude < 0.5) and targetSignPart.CFrame.LookVector or dir.Unit
                entryPos = signPos + dir * 10 + Vector3.new(0, 3, 0)
            end

            -- Sobe para altura segura antes de teletransportar
            local minHeight = 30
            local jumpStart = tick()
            while hrp.Position.Y < math.max(entryPos.Y, minHeight) and (tick() - jumpStart) < 2 do
                hrp.AssemblyLinearVelocity = Vector3.new(
                    hrp.AssemblyLinearVelocity.X, 280, hrp.AssemblyLinearVelocity.Z)
                RunService.Heartbeat:Wait()
            end

            -- Teletransporte final (8 tentativas suaves)
            for _ = 1, 8 do
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                if (hrp.Position - entryPos).Magnitude > 3 then
                    hrp.CFrame = CFrame.new(entryPos)
                    task.wait(0.03)
                end
            end
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)

        _isTpMoving = false
        if not ok then
            _F.ShowNotification("TP BASE", "Failed: " .. tostring(err):sub(1, 40))
        end
    end
end


-- ══════════════════════════════════════════════════════════════════════
-- ICEMAN V2 — ADMIN TOOLS PANEL
-- ══════════════════════════════════════════════════════════════════════
task.spawn(function()
    local pg = PlayerGui
    if not pg then return end

    -- ── Cores (mesmo padrão das outras UIs) ────────────────────────────────
    local C_BG      = Color3.fromRGB(18, 20, 26)
    local C_HEADER  = Color3.fromRGB(26, 29, 38)
    local C_SURFACE = Color3.fromRGB(32, 36, 48)
    local C_SURFH   = Color3.fromRGB(26, 29, 38)
    local C_ACCENT  = Color3.fromRGB(0, 220, 255)
    local C_ACCENT2 = Color3.fromRGB(0, 180, 230)
    local C_TEXT    = Color3.fromRGB(240, 248, 255)
    local C_TEXTSEC = Color3.fromRGB(130, 200, 230)
    local C_BORDER  = Color3.fromRGB(148, 210, 245)
    local C_ON      = Color3.fromRGB(0, 220, 255)
    local C_ONBG    = Color3.fromRGB(200, 240, 255)

    local W = 220

    -- Destrói instância anterior
    local old = pg:FindFirstChild("YinAdminTools")
    if old then old:Destroy() end

    local atGui = Instance.new("ScreenGui")
    atGui.Name = "YinAdminTools"
    atGui.ResetOnSpawn = false
    atGui.DisplayOrder = 26
    atGui.Enabled = Config.ShowAdminToolsPanel ~= false
    atGui.Parent = pg

    -- Expõe para settings toggle
    SharedState.AdminToolsSetEnabled = function(v)
        if atGui and atGui.Parent then atGui.Enabled = v end
    end

    -- ── Painel principal ──────────────────────────────────────────────────
    local atPos = (Config.Positions and Config.Positions.AdminToolsPanel) or {X=0.02, Y=0.25}
    local panel = Instance.new("Frame", atGui)
    panel.Name = "Frame"
    panel.BackgroundColor3 = C_BG
    panel.BackgroundTransparency = 0
    panel.BorderSizePixel = 0
    panel.ClipsDescendants = true
    panel.AutomaticSize = Enum.AutomaticSize.Y
    panel.Size = UDim2.new(0, W, 0, 0)
    panel.Position = UDim2.new(atPos.X, 0, atPos.Y, 0)
    Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 14)
    local pStroke = Instance.new("UIStroke", panel)
    pStroke.Color = C_BORDER; pStroke.Thickness = 1; pStroke.Transparency = 0
    task.defer(function() applyIceToPanel(panel, 6, 5) end)

    -- Drag
    do
        local dragging, dragStart, startPos
        panel.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = inp.Position; startPos = panel.Position
                inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        local ps = panel.Parent.AbsoluteSize
                        if Config.Positions then
                            Config.Positions.AdminToolsPanel = {
                                X = panel.AbsolutePosition.X / ps.X,
                                Y = panel.AbsolutePosition.Y / ps.Y,
                            }
                            _F.SaveConfig()
                        end
                    end
                end)
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                local delta = inp.Position - dragStart
                panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    -- ── Content ───────────────────────────────────────────────────────────
    local cont = Instance.new("Frame", panel)
    cont.Size = UDim2.new(1,-16,0,0)
    cont.Position = UDim2.new(0,8,0,8)
    cont.BackgroundTransparency = 1
    cont.AutomaticSize = Enum.AutomaticSize.Y
    local ll = Instance.new("UIListLayout", cont)
    ll.Padding = UDim.new(0,5); ll.SortOrder = Enum.SortOrder.LayoutOrder

    -- Padding bottom
    local padBot = Instance.new("Frame", cont)
    padBot.LayoutOrder = 999; padBot.Size = UDim2.new(1,0,0,8); padBot.BackgroundTransparency = 1

    -- ── Helper: linha de botão toggle ON/OFF ──────────────────────────────
    local updateFns = {}
    local function makeRow(labelText, order, getState, onToggle)
        local row = Instance.new("Frame", cont)
        row.Size = UDim2.new(1,0,0,34); row.LayoutOrder = order
        row.BackgroundColor3 = C_SURFACE; row.BackgroundTransparency = 0; row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)
        local rStroke = Instance.new("UIStroke", row)
        rStroke.Color = C_BORDER; rStroke.Thickness = 1; rStroke.Transparency = 0.75

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1,-76,1,0); lbl.Position = UDim2.new(0,12,0,0)
        lbl.BackgroundTransparency = 1; lbl.Text = labelText
        lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 11
        lbl.TextColor3 = C_TEXT; lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextTruncate = Enum.TextTruncate.AtEnd

        local pill = Instance.new("Frame", row)
        pill.Size = UDim2.new(0,52,0,22); pill.Position = UDim2.new(1,-62,0.5,-11)
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(0,6)
        local pillStroke = Instance.new("UIStroke", pill); pillStroke.Thickness = 1

        local pillTxt = Instance.new("TextLabel", pill)
        pillTxt.Size = UDim2.new(1,0,1,0); pillTxt.BackgroundTransparency = 1
        pillTxt.Font = Enum.Font.GothamBlack; pillTxt.TextSize = 10

        local function upd()
            local on = getState()
            pill.BackgroundColor3 = on and C_ONBG or C_SURFACE
            pill.BackgroundTransparency = 0
            pillStroke.Color = on and C_ON or C_BORDER
            pillStroke.Transparency = on and 0.5 or 0.7
            pillTxt.Text = on and "ON" or "OFF"
            pillTxt.TextColor3 = on and C_ON or C_TEXTSEC
            rStroke.Color = on and C_ACCENT or C_BORDER
            rStroke.Transparency = on and 0.6 or 0.75
        end
        upd()
        table.insert(updateFns, upd)

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""; btn.AutoButtonColor = false
        btn.MouseEnter:Connect(function() TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFH}):Play() end)
        btn.MouseLeave:Connect(function() TweenService:Create(row, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFACE}):Play() end)
        btn.MouseButton1Click:Connect(function() onToggle(); task.defer(upd) end)
        return upd
    end

    -- ── 1. Spam Base Owner ────────────────────────────────────────────────
    local isSpamming = false
    local spamRow = Instance.new("Frame", cont)
    spamRow.Size = UDim2.new(1,0,0,34); spamRow.LayoutOrder = 1
    spamRow.BackgroundColor3 = C_SURFACE; spamRow.BackgroundTransparency = 0; spamRow.BorderSizePixel = 0
    Instance.new("UICorner", spamRow).CornerRadius = UDim.new(0,8)
    local spamStroke = Instance.new("UIStroke", spamRow); spamStroke.Color = C_BORDER; spamStroke.Thickness = 1; spamStroke.Transparency = 0.75

    local spamLbl = Instance.new("TextLabel", spamRow)
    spamLbl.Size = UDim2.new(1,-10,1,0); spamLbl.Position = UDim2.new(0,12,0,0)
    spamLbl.BackgroundTransparency = 1; spamLbl.Text = "Spam Base Owner"
    spamLbl.Font = Enum.Font.GothamBold; spamLbl.TextSize = 11
    spamLbl.TextColor3 = C_TEXT; spamLbl.TextXAlignment = Enum.TextXAlignment.Left

    local spamBtn = Instance.new("TextButton", spamRow)
    spamBtn.Size = UDim2.new(1,0,1,0); spamBtn.BackgroundTransparency = 1; spamBtn.Text = ""; spamBtn.AutoButtonColor = false
    spamBtn.MouseEnter:Connect(function() TweenService:Create(spamRow, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFH}):Play() end)
    spamBtn.MouseLeave:Connect(function() TweenService:Create(spamRow, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFACE}):Play() end)
    spamBtn.MouseButton1Click:Connect(function()
        if isSpamming then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then _F.ShowNotification("SPAM OWNER", "No character"); return end

        local nearestPlot, nearestDist = nil, math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local yb = sign:FindFirstChild("YourBase")
                    if not yb or not yb.Enabled then
                        local signPart = sign:IsA("BasePart") and sign or sign:FindFirstChildWhichIsA("BasePart", true)
                        if signPart then
                            local d = (hrp.Position - signPart.Position).Magnitude
                            if d < nearestDist then nearestDist = d; nearestPlot = plot end
                        end
                    end
                end
            end
        end
        if not nearestPlot then _F.ShowNotification("SPAM OWNER", "No base found"); return end

        local targetPlayer = nil
        pcall(function()
            local S = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
            local ch = S:Get(nearestPlot.Name)
            if ch then
                local owner = ch:Get("Owner")
                if typeof(owner) == "Instance" and owner:IsA("Player") then
                    targetPlayer = owner
                elseif type(owner) == "table" and owner.Name then
                    targetPlayer = Players:FindFirstChild(owner.Name)
                end
            end
        end)
        if not targetPlayer or targetPlayer == LocalPlayer then
            _F.ShowNotification("SPAM OWNER", "Owner not found or is you"); return
        end

        isSpamming = true
        spamRow.BackgroundColor3 = Color3.fromRGB(20, 40, 20)
        spamStroke.Color = C_ON
        spamLbl.TextColor3 = C_ON
        _F.ShowNotification("SPAM OWNER", "Spamming " .. targetPlayer.DisplayName)

        task.spawn(function()
            local cmds = {"balloon","inverse","jail","jumpscare","morph","nightvision","ragdoll","rocket","tiny"}
            local n = 0
            local adminFn = _G.runAdminCommand
            if adminFn then
                for _, cmd in ipairs(cmds) do
                    local ok, r = pcall(adminFn, targetPlayer, cmd)
                    if ok and r then n = n + 1 end
                    task.wait(0.15)
                end
            end
            task.wait(0.2)
            isSpamming = false
            spamRow.BackgroundColor3 = C_SURFACE
            spamStroke.Color = C_BORDER
            spamLbl.TextColor3 = C_TEXT
            _F.ShowNotification("SPAM OWNER", "Sent " .. n .. " cmds to " .. targetPlayer.DisplayName)
        end)
    end)

    -- ── 2. Click to AP ─────────────────────────────────────────────────────
    -- Botão esquerdo: liga/desliga Click to AP
    -- Botão direito: alterna modo SGL (um comando por vez) / ALL (todos os comandos)
    do
        local capRow = Instance.new("Frame", cont)
        capRow.Size = UDim2.new(1,0,0,34); capRow.LayoutOrder = 2
        capRow.BackgroundColor3 = C_SURFACE; capRow.BackgroundTransparency = 0; capRow.BorderSizePixel = 0
        Instance.new("UICorner", capRow).CornerRadius = UDim.new(0,8)
        local capStroke = Instance.new("UIStroke", capRow)
        capStroke.Color = C_BORDER; capStroke.Thickness = 1; capStroke.Transparency = 0.75

        local capLbl = Instance.new("TextLabel", capRow)
        capLbl.Size = UDim2.new(1,-76,1,0); capLbl.Position = UDim2.new(0,12,0,0)
        capLbl.BackgroundTransparency = 1
        capLbl.Font = Enum.Font.GothamBold; capLbl.TextSize = 11
        capLbl.TextColor3 = C_TEXT; capLbl.TextXAlignment = Enum.TextXAlignment.Left
        capLbl.TextTruncate = Enum.TextTruncate.AtEnd

        local capPill = Instance.new("Frame", capRow)
        capPill.Size = UDim2.new(0,52,0,22); capPill.Position = UDim2.new(1,-62,0.5,-11)
        capPill.BorderSizePixel = 0
        Instance.new("UICorner", capPill).CornerRadius = UDim.new(0,6)
        local capPillStroke = Instance.new("UIStroke", capPill); capPillStroke.Thickness = 1

        local capPillTxt = Instance.new("TextLabel", capPill)
        capPillTxt.Size = UDim2.new(1,0,1,0); capPillTxt.BackgroundTransparency = 1
        capPillTxt.Font = Enum.Font.GothamBlack; capPillTxt.TextSize = 10

        local function updateClickAPVisual()
            local on = Config.ClickToAP == true
            local mode = Config.ClickToAPSingleCommand and "SGL" or "ALL"
            -- Label: "Click to AP  [SGL]" ou "Click to AP  [ALL]"
            capLbl.Text = "Click to AP  [" .. mode .. "]"
            capPill.BackgroundColor3 = on and C_ONBG or C_SURFACE
            capPill.BackgroundTransparency = 0
            capPillStroke.Color = on and C_ON or C_BORDER
            capPillStroke.Transparency = on and 0.5 or 0.7
            capPillTxt.Text = on and "ON" or "OFF"
            capPillTxt.TextColor3 = on and C_ON or C_TEXTSEC
            capStroke.Color = on and C_ACCENT or C_BORDER
            capStroke.Transparency = on and 0.6 or 0.75
        end
        updateClickAPVisual()
        table.insert(updateFns, updateClickAPVisual)
        SharedState.UpdateClickToAPButton = updateClickAPVisual

        local capBtn = Instance.new("TextButton", capRow)
        capBtn.Size = UDim2.new(1,0,1,0); capBtn.BackgroundTransparency = 1
        capBtn.Text = ""; capBtn.AutoButtonColor = false
        capBtn.MouseEnter:Connect(function()
            TweenService:Create(capRow, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFH}):Play()
        end)
        capBtn.MouseLeave:Connect(function()
            TweenService:Create(capRow, TweenInfo.new(0.1), {BackgroundColor3 = C_SURFACE}):Play()
        end)
        -- Botão esquerdo: toggle ON/OFF
        capBtn.MouseButton1Click:Connect(function()
            Config.ClickToAP = not (Config.ClickToAP == true)
            _F.SaveConfig()
            updateClickAPVisual()
            _F.ShowNotification("CLICK TO AP", Config.ClickToAP and "ON" or "OFF")
        end)
        -- Botão direito: alterna SGL / ALL (exatamente como o lefa)
        capBtn.MouseButton2Click:Connect(function()
            Config.ClickToAPSingleCommand = not Config.ClickToAPSingleCommand
            _F.SaveConfig()
            updateClickAPVisual()
            _F.ShowNotification("CLICK AP MODE", Config.ClickToAPSingleCommand and "SINGLE COMMAND" or "ALL COMMANDS")
        end)
    end

    -- ── 3. Proximity ──────────────────────────────────────────────────────
    makeRow("Proximity", 3,
        function() return ProximityAPActive == true end,
        function()
            ProximityAPActive = not ProximityAPActive
            _F.ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end)

    -- ── 4. Distance slider ───────────────────────────────────────────────
    do
        local sliderRow = Instance.new("Frame", cont)
        sliderRow.Size = UDim2.new(1,0,0,46); sliderRow.LayoutOrder = 4
        sliderRow.BackgroundColor3 = C_SURFACE; sliderRow.BackgroundTransparency = 0; sliderRow.BorderSizePixel = 0
        Instance.new("UICorner", sliderRow).CornerRadius = UDim.new(0,8)
        local slStroke = Instance.new("UIStroke", sliderRow); slStroke.Color = C_BORDER; slStroke.Thickness = 1; slStroke.Transparency = 0.75

        local distLbl = Instance.new("TextLabel", sliderRow)
        distLbl.Size = UDim2.new(1,-10,0,16); distLbl.Position = UDim2.new(0,12,0,5)
        distLbl.BackgroundTransparency = 1
        distLbl.Font = Enum.Font.GothamBold; distLbl.TextSize = 11
        distLbl.TextColor3 = C_TEXT; distLbl.TextXAlignment = Enum.TextXAlignment.Left

        local slBg = Instance.new("Frame", sliderRow)
        slBg.Size = UDim2.new(1,-24,0,6); slBg.Position = UDim2.new(0,12,0,28)
        slBg.BackgroundColor3 = C_SURFH; slBg.BorderSizePixel = 0
        Instance.new("UICorner", slBg).CornerRadius = UDim.new(1,0)

        local slFill = Instance.new("Frame", slBg)
        slFill.BackgroundColor3 = C_ACCENT; slFill.BorderSizePixel = 0
        Instance.new("UICorner", slFill).CornerRadius = UDim.new(1,0)

        local slKnob = Instance.new("Frame", slBg)
        slKnob.Size = UDim2.new(0,14,0,14); slKnob.AnchorPoint = Vector2.new(0.5,0.5)
        slKnob.BackgroundColor3 = Color3.new(1,1,1); slKnob.BorderSizePixel = 0
        Instance.new("UICorner", slKnob).CornerRadius = UDim.new(1,0)
        local slKS = Instance.new("UIStroke", slKnob); slKS.Color = C_ACCENT; slKS.Thickness = 1.5

        local SL_MIN, SL_MAX = 5, 50
        local function setSlider(v)
            v = math.clamp(math.floor(v + 0.5), SL_MIN, SL_MAX)
            Config.ProximityRange = v; _F.SaveConfig()
            local pct = (v - SL_MIN) / (SL_MAX - SL_MIN)
            slFill.Size = UDim2.new(pct,0,1,0)
            slKnob.Position = UDim2.new(pct,0,0.5,0)
            distLbl.Text = "Distance: " .. v .. " studs"
        end
        setSlider(Config.ProximityRange or 15)

        local slDrag = false
        slBg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                slDrag = true
                setSlider(SL_MIN + ((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X) * (SL_MAX - SL_MIN))
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then slDrag = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if slDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                setSlider(SL_MIN + ((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X) * (SL_MAX - SL_MIN))
            end
        end)
    end

    -- Proximity visualizer (cylinder)
    do
        local proxViz = nil
        RunService.Heartbeat:Connect(function()
            if ProximityAPActive then
                if not proxViz or not proxViz.Parent then
                    proxViz = Instance.new("Part")
                    proxViz.Name = "YinProxViz"
                    proxViz.Anchored = true; proxViz.CanCollide = false
                    proxViz.Shape = Enum.PartType.Cylinder
                    proxViz.Color = Color3.fromRGB(124,106,245); proxViz.Transparency = 0.7
                    proxViz.CastShadow = false; proxViz.Parent = Workspace
                end
                local char = LocalPlayer.Character
                if char then
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local r = Config.ProximityRange or 15
                        proxViz.Size = Vector3.new(0.5, r*2, r*2)
                        proxViz.CFrame = hrp.CFrame * CFrame.Angles(0,0,math.rad(90)) + Vector3.new(0,-2.5,0)
                    end
                end
            else
                if proxViz and proxViz.Parent then proxViz:Destroy(); proxViz = nil end
            end
        end)
    end

    -- Expõe update global para keybinds e outros módulos
    _G.updateAdminToolsPanel = function()
        for _, u in ipairs(updateFns) do pcall(u) end
    end

    -- Sync com settings: "XiAdminToolsPanel" key é lido pelo toggle existente nas settings
    -- Criamos também alias com o nome antigo para compatibilidade
    task.spawn(function()
        task.wait(0.1)
        local alias = Instance.new("ScreenGui")
        alias.Name = "XiAdminToolsPanel"
        alias.ResetOnSpawn = false
        alias.Enabled = false  -- vazia, só para o toggle de settings encontrar
        alias.Parent = pg
        -- Quando o toggle desabilitar "XiAdminToolsPanel", desabilita o real também
        alias:GetPropertyChangedSignal("Enabled"):Connect(function()
            if atGui and atGui.Parent then atGui.Enabled = alias.Enabled end
        end)
    end)
end)

task.spawn(function()
    if not game:IsLoaded() then game.Loaded:Wait() end; task.wait(2)
    local BL={STOLEN=true,STEAL=true,PURCHASE=true,COMPRAR=true,BUY=true,COLLECT=true,COLETAR=true,CASH=true,VALUE=true,BASE=true,EMPTY=true,GENERATION=true,COMMON=true,UNCOMMON=true,RARE=true,EPIC=true,LEGENDARY=true,DIVINE=true,RAINBOW=true,CURSED=true,GOLD=true,DIAMOND=true,CANDY=true,MUTATION=true}
    local function cvOk(t) if not t or t=="" then return false end; local c=(t:gsub("<[^>]+>","")):match("^%s*(.-)%s*$") or ""; if #c<=1 then return false end; local u=c:upper(); if u:find("^%$") or u:find("/S$") or u:find("^[%d%.]+") then return false end; return not BL[u] end
    local function pgv(t) if type(t)~="string" then return nil end; local u=t:gsub("<[^>]+>",""):upper(); if not u:find("%$") or not u:find("/S") then return nil end; local c=u:gsub("%$",""):gsub("/S",""):gsub("%s+",""); local n=tonumber(c:match("[%d%.]+")); if not n then return nil end; if c:find("B") then return n*1e9 elseif c:find("M") then return n*1e6 elseif c:find("K") then return n*1e3 else return n end end
    local function exM(m) if not m then return nil,nil,0 end; local bN,bG,bV=nil,nil,0; for _,bb in ipairs(m:GetDescendants()) do if bb:IsA("BillboardGui") or bb:IsA("SurfaceGui") then for _,d in ipairs(bb:GetDescendants()) do if d:IsA("TextLabel") and d.Text then local v=pgv(d.Text); if v and v>bV then bV=v;bG=d.Text:gsub("<[^>]+>",""); local co=d.Parent; if co then local f=nil; for _,s in ipairs(co:GetChildren()) do if s:IsA("TextLabel") and s.Name=="DisplayName" then local c2=(s.Text or ""):gsub("<[^>]+>",""):match("^%s*(.-)%s*$"); if cvOk(c2) then f=c2;break end end end; if not f then local bt,bl=nil,0; for _,s in ipairs(co:GetChildren()) do if s:IsA("TextLabel") then local c2=(s.Text or ""):gsub("<[^>]+>",""):match("^%s*(.-)%s*$") or ""; if cvOk(c2) and #c2>bl then bt,bl=c2,#c2 end end end; if bt then f=bt end end; if f then bN=f end end end end end end end; return bN,bG,bV end
    local function scan() local res,vis={},{}; local deb=Workspace:FindFirstChild("Debris") or Workspace; for _,c in ipairs(deb:GetChildren()) do if c:IsA("Model") or c:IsA("BasePart") then local n,g,gv=exM(c); if gv and gv>0 then local p=c:IsA("BasePart") and c or (c:IsA("Model") and c.PrimaryPart); if not p then for _,ch in ipairs(c:GetChildren()) do if ch:IsA("BasePart") then p=ch;break end end end; if p then table.insert(vis,{name=n,gen=g,gv=gv,part=p,model=c}) end end end end; for _,obj in ipairs(Workspace:GetDescendants()) do if obj:IsA("ProximityPrompt") and obj.Enabled then local tx=(obj.ActionText or ""):lower(); if tx:find("purchase") or tx:find("comprar") or tx:find("buy") then local pp=obj.Parent; if not pp then continue end; local rp=pp:IsA("Attachment") and pp.Parent or pp; if not(rp and rp:IsA("BasePart")) then continue end; local fN,fG,fGV,fM="Brainrot","",0,nil; local md,mt=15,nil; for _,v in ipairs(vis) do local d=(v.part.Position-rp.Position).Magnitude; if d<md then md=d;mt=v end end; if mt then fN=mt.name or "Brainrot";fG=mt.gen or "";fGV=mt.gv or 0;fM=mt.model else local sr=rp;local cu=rp; while cu and cu.Parent and cu.Parent~=Workspace do sr=cu;cu=cu.Parent end; local n,g,gv=exM(sr); if n then fN=n end; if g then fG=g end; if gv and gv>0 then fGV=gv end; fM=sr end; table.insert(res,{name=fN,gen=fG,gv=fGV,prompt=obj,part=rp,model=fM,uid="conv_"..tostring(obj)}) end end end; return res end
    while true do local ok2,found=pcall(scan); if ok2 and found then SharedState.ConveyorAnimals=found; local b=-1; for _,e in ipairs(found) do if(e.gv or 0)>b then b=e.gv end end; SharedState.BestConveyorGv=b end; task.wait(0.5) end
end)

function _F.tpToBestBrainrot()
    local minGenVal=_F.parseMinGen(Config.TpSettings.MinGenForTp)
    local bestBase,bestBaseGv=nil,-1; local cache=SharedState.AllAnimalsCache
    if cache then if Config.AutoTPPriority then for _,pN in ipairs(PRIORITY_LIST) do local sn=pN:lower(); for _,a in ipairs(cache) do if a and a.name and a.name:lower()==sn and a.owner~=LocalPlayer.Name and(minGenVal<=0 or(tonumber(a.genValue) or 0)>=minGenVal) then bestBase=a;bestBaseGv=tonumber(a.genValue) or 0;break end end; if bestBase then break end end end; if not bestBase then for _,a in ipairs(cache) do if a and a.owner~=LocalPlayer.Name and(minGenVal<=0 or(tonumber(a.genValue) or 0)>=minGenVal) then bestBase=a;bestBaseGv=tonumber(a.genValue) or 0;break end end end end
    SharedState.BestBaseGv=bestBaseGv
    local bestConv,bestConvGv=nil,-1; for _,e in ipairs(SharedState.ConveyorAnimals or {}) do local gv=tonumber(e.gv) or 0; if e.prompt and e.prompt.Parent and e.prompt.Enabled and e.part and e.part.Parent and gv>bestConvGv and(minGenVal<=0 or gv>=minGenVal) then bestConvGv=gv;bestConv=e end end; SharedState.BestConveyorGv=bestConvGv
    local useConv=bestConv and bestConv.part and bestConv.part.Parent and(not bestBase or bestConvGv>bestBaseGv)
    if useConv then _F.ShowNotification("TP BEST","ESTEIRA → "..(bestConv.name or "?")); task.spawn(function() local char=LocalPlayer.Character; local hrp=char and char:FindFirstChild("HumanoidRootPart"); local hum=char and char:FindFirstChild("Humanoid"); if not hrp or not hum then return end; local tool=LocalPlayer.Backpack:FindFirstChild(Config.TpSettings.Tool) or char:FindFirstChild(Config.TpSettings.Tool); if tool then hum:EquipTool(tool) end; hrp.AssemblyLinearVelocity=Vector3.new(0,280,0); RunService.Heartbeat:Wait(); hrp.CFrame=CFrame.new(bestConv.part.Position+Vector3.new(0,3,0)) end); return end
    if bestBase then _F.ShowNotification("TP BEST","BASE → "..bestBase.name); SharedState.SelectedPetData={petName=bestBase.name,mpsText=bestBase.genText,mpsValue=bestBase.genValue,owner=bestBase.owner,plot=bestBase.plot,slot=bestBase.slot,uid=bestBase.uid,mutation=bestBase.mutation,animalData=bestBase}; task.spawn(_F.runAutoSnipe)
    else _F.ShowNotification("TP BEST","No brainrot found!") end
end
_G.tpToBestBrainrot=_F.tpToBestBrainrot

-- STEALING HUD (Admin Panel Style)
task.spawn(function()
    local stealingHudGui = Instance.new("ScreenGui")
    stealingHudGui.Name = "XiStealingHUD"
    stealingHudGui.ResetOnSpawn = false
    stealingHudGui.Enabled = Config.ShowStealingHUD
    stealingHudGui.Parent = PlayerGui

    local mainFrame = Instance.new("Frame", stealingHudGui)
    mainFrame.Name = "Frame"
    mainFrame.Size = UDim2.new(0, 300, 0, 350)
    local savedPos = Config.Positions.StealingHUD or {X = 0.8, Y = 0.15}
    mainFrame.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Color3.fromRGB(100, 200, 255)
    mainStroke.Thickness = 1.5
    mainStroke.Transparency = 0.3
    task.defer(function() applyIceToPanel(mainFrame, 7, 5) end)

    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    _F.MakeDraggable(header, mainFrame, "StealingHUD")

    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(1, -20, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Stealers Panel"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 13
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local line = Instance.new("Frame", mainFrame)
    line.Size = UDim2.new(1, -24, 0, 1)
    line.Position = UDim2.new(0.5, 0, 0, 40)
    line.AnchorPoint = Vector2.new(0.5, 0)
    line.BackgroundColor3 = Color3.fromRGB(26, 29, 38)
    line.BorderSizePixel = 0

    local scroll = Instance.new("ScrollingFrame", mainFrame)
    scroll.Size = UDim2.new(1, -16, 1, -50)
    scroll.Position = UDim2.new(0, 8, 0, 45)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 0
    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createHudRow(plr, parent)
        local row = Instance.new("Frame", parent)
        row.Name = plr.Name
        row.Size = UDim2.new(1, 0, 0, 54)
        row.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
        
        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Color3.fromRGB(26, 29, 38)
        rowStroke.Thickness = 1

        local headshot = Instance.new("ImageLabel", row)
        headshot.Size = UDim2.new(0, 38, 0, 38)
        headshot.Position = UDim2.new(0, 8, 0.5, -19)
        headshot.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        task.spawn(function()
            local success, thumb = pcall(function() return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48) end)
            if success and headshot and headshot.Parent then headshot.Image = thumb end
        end)
        Instance.new("UICorner", headshot).CornerRadius = UDim.new(0, 6)
        
        local dName = Instance.new("TextLabel", row)
        dName.Size = UDim2.new(1, -130, 0, 18)
        dName.Position = UDim2.new(0, 54, 0.5, -16)
        dName.BackgroundTransparency = 1
        dName.Text = plr.DisplayName
        dName.Font = Enum.Font.GothamBold
        dName.TextSize = 12
        dName.TextColor3 = Color3.new(1, 1, 1)
        dName.TextXAlignment = Enum.TextXAlignment.Left

        local brainrotLabel = Instance.new("TextLabel", row)
        brainrotLabel.Size = UDim2.new(1, -130, 0, 14)
        brainrotLabel.Position = UDim2.new(0, 54, 0.5, 2)
        brainrotLabel.BackgroundTransparency = 1
        brainrotLabel.Text = "No target"
        brainrotLabel.Font = Enum.Font.GothamMedium
        brainrotLabel.TextSize = 10
        brainrotLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        brainrotLabel.TextXAlignment = Enum.TextXAlignment.Left
        brainrotLabel.TextTruncate = Enum.TextTruncate.AtEnd

        local btnCont = Instance.new("Frame", row)
        btnCont.Size = UDim2.new(0, 120, 1, 0)
        btnCont.Position = UDim2.new(1, -125, 0, 0)
        btnCont.BackgroundTransparency = 1

        local buttonsDef = {
            {icon = "💥", cmd = "ragdoll"},
            {icon = "🔒", cmd = "jail"},
            {icon = "🚀", cmd = "rocket"},
            {icon = "🎈", cmd = "balloon"}
        }

        for i, def in ipairs(buttonsDef) do
            local bBox = Instance.new("Frame", btnCont)
            bBox.Size = UDim2.new(0, 26, 0, 26)
            bBox.Position = UDim2.new(0, (i-1)*30, 0.5, -13)
            bBox.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
            Instance.new("UICorner", bBox).CornerRadius = UDim.new(0, 6)
            
            local bStroke = Instance.new("UIStroke", bBox)
            bStroke.Color = Color3.fromRGB(35, 35, 35)
            bStroke.Thickness = 1

            local b = Instance.new("TextButton", bBox)
            b.Size = UDim2.new(1, 0, 1, 0)
            b.BackgroundTransparency = 1
            b.Text = def.icon
            b.TextSize = 12
            b.Font = Enum.Font.GothamBold
            
            b.MouseButton1Click:Connect(function()
                if _G.runAdminCommand then
                    _G.runAdminCommand(plr, def.cmd)
                end
            end)
        end

        local function update()
            if not plr or not plr.Parent or not Players:FindFirstChild(plr.Name) then
                row:Destroy()
                return
            end
            local stealing = plr:GetAttribute("Stealing")
            local brName = plr:GetAttribute("StealingIndex")
            if stealing then
                if brName then
                    brainrotLabel.Text = tostring(brName)
                else
                    brainrotLabel.Text = "No target"
                end
            else
                row:Destroy()
            end
        end

        task.spawn(function()
            while row and row.Parent do
                update()
                task.wait(0.5)
            end
        end)

        return row
    end

    local activeRows = {}
    while true do
        task.wait(1)
        if Config.ShowStealingHUD then
            mainFrame.Visible = true
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p:GetAttribute("Stealing") and not activeRows[p.UserId] then
                    local row = createHudRow(p, scroll)
                    activeRows[p.UserId] = row
                    row.AncestryChanged:Connect(function()
                        if not row.Parent then activeRows[p.UserId] = nil end
                    end)
                end
            end
            scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y)
        else
            mainFrame.Visible = false
        end
    end
end)

-- Iceman V2: Paint my own base purple (50% brightness, SmoothPlastic)
task.spawn(function()
    local PURPLE = Color3.fromRGB(140, 0, 255)

    local function findMyPlotGlobal()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yb = sign:FindFirstChild("YourBase")
                if yb and yb:IsA("BillboardGui") and yb.Enabled then return plot end
                for _, d in ipairs(sign:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        local t = d.Text:lower()
                        if t:find(LocalPlayer.Name:lower(),1,true) or t:find(LocalPlayer.DisplayName:lower(),1,true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function paintPlot(plot)
        if not plot then return end
        for _, d in ipairs(plot:GetDescendants()) do
            if d:IsA("BasePart") then
                pcall(function()
                    d.Color = PURPLE
                    d.Material = Enum.Material.Neon
                end)
            end
        end
    end

    local function watchPlot(plot)
        if not plot then return end
        plot.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then
                task.wait(0.1)
                pcall(function()
                    d.Color = PURPLE
                    d.Material = Enum.Material.Neon
                end)
            end
        end)
    end

    task.wait(3)
    local myPlot = findMyPlotGlobal()
    if myPlot then paintPlot(myPlot); watchPlot(myPlot) end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(3)
        local p = findMyPlotGlobal()
        if p then paintPlot(p); watchPlot(p) end
    end)
end)


-- Iceman V2: Glowing purple circle at the front of my base
task.spawn(function()
    task.wait(3)

    local function findMyPlotGlobal()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local yb = sign:FindFirstChild("YourBase")
                if yb and yb:IsA("BillboardGui") and yb.Enabled then return plot end
                for _, d in ipairs(sign:GetDescendants()) do
                    if d:IsA("TextLabel") then
                        local t = d.Text:lower()
                        if t:find(LocalPlayer.Name:lower(),1,true) or t:find(LocalPlayer.DisplayName:lower(),1,true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local ring = nil

    local function createRing(plot)
        if ring and ring.Parent then ring:Destroy() end

        -- Find the front/entrance of the base using MainRootPart or first BasePart
        local basePart = plot:FindFirstChild("MainRootPart") or plot:FindFirstChildWhichIsA("BasePart")
        if not basePart then return end

        -- Create a flat cylinder as the ring
        local r = Instance.new("Part")
        r.Name = "_YinBaseRing"
        r.Shape = Enum.PartType.Cylinder
        r.Size = Vector3.new(0.3, 14, 14)  -- thin flat ring
        r.Color = Color3.fromRGB(180, 0, 255)
        r.Material = Enum.Material.Neon
        r.Transparency = 0.2
        r.CanCollide = false
        r.Anchored = true
        r.CastShadow = false

        -- Position at base front, flat on the ground
        local pos = basePart.Position
        r.CFrame = CFrame.new(pos.X, pos.Y - basePart.Size.Y/2 + 0.2, pos.Z)
                 * CFrame.Angles(0, 0, math.rad(90))
        r.Parent = Workspace

        -- Hollow it out with a slightly smaller inner cylinder
        local inner = Instance.new("Part")
        inner.Name = "_YinBaseRingInner"
        inner.Shape = Enum.PartType.Cylinder
        inner.Size = Vector3.new(0.31, 11, 11)
        inner.Color = Color3.fromRGB(12, 6, 20)
        inner.Material = Enum.Material.Plastic
        inner.Transparency = 0
        inner.CanCollide = false
        inner.Anchored = true
        inner.CastShadow = false
        inner.CFrame = r.CFrame
        inner.Parent = Workspace

        ring = r

        -- Pulse animation
        task.spawn(function()
            local t = 0
            while r and r.Parent do
                t += 0.05
                local pulse = 0.15 + math.abs(math.sin(t)) * 0.35
                r.Transparency = pulse
                task.wait(0.05)
            end
            if inner and inner.Parent then inner:Destroy() end
        end)
    end

    local myPlot = findMyPlotGlobal()
    if myPlot then createRing(myPlot) end

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(3)
        local p = findMyPlotGlobal()
        if p then createRing(p) end
    end)
end)


task.spawn(function()
    local espGui = Instance.new("ScreenGui")
    espGui.Name = "XiStealingPlotESP"
    espGui.ResetOnSpawn = false
    espGui.Enabled = Config.ShowStealingPlotESP ~= false
    espGui.Parent = PlayerGui

    local byUser = {}

    local SyncStealEsp = nil
    local AnimalsDataStealEsp = nil
    local AnimalsSharedStealEsp = nil
    local function ensureStealEspModules()
        if not SyncStealEsp then
            pcall(function()
                SyncStealEsp = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
            end)
        end
        if not AnimalsDataStealEsp then
            pcall(function()
                AnimalsDataStealEsp = require(ReplicatedStorage:WaitForChild("Datas"):WaitForChild("Animals"))
            end)
        end
        if not AnimalsSharedStealEsp then
            pcall(function()
                AnimalsSharedStealEsp = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Animals"))
            end)
        end
    end

    local function normStealName(s)
        return tostring(s or ""):lower():gsub("%s+", ""):gsub("[^%w]", "")
    end

    local function stealIdxMatchesAnimal(stealIdx, adIndex, displayName)
        if stealIdx == nil or stealIdx == "" then return false end
        local si = tostring(stealIdx)
        local sil = si:lower()
        if adIndex then
            local ai = tostring(adIndex)
            if ai == si or ai:lower() == sil then return true end
        end
        if displayName then
            local d = tostring(displayName)
            local dl = d:lower()
            if dl == sil or dl:find(sil, 1, true) or sil:find(dl, 1, true) then return true end
            if normStealName(d) == normStealName(si) then return true end
        end
        local AD = AnimalsDataStealEsp
        if AD then
            local infDirect = AD[si]
            if type(infDirect) == "table" and infDirect.DisplayName and displayName then
                if infDirect.DisplayName:lower() == displayName:lower() or normStealName(infDirect.DisplayName) == normStealName(displayName) then
                    return true
                end
            end
            if adIndex and AD[adIndex] and type(AD[adIndex]) == "table" and AD[adIndex].DisplayName then
                local disp = AD[adIndex].DisplayName
                if disp:lower() == sil or normStealName(disp) == normStealName(si) then return true end
            end
            for key, inf in pairs(AD) do
                if type(inf) == "table" and inf.DisplayName then
                    if key == si or key:lower() == sil then
                        if not displayName or inf.DisplayName:lower() == displayName:lower() or normStealName(inf.DisplayName) == normStealName(displayName) then
                            return true
                        end
                    end
                    if inf.DisplayName:lower() == sil or normStealName(inf.DisplayName) == normStealName(si) then
                        if adIndex and (key == adIndex or key:lower() == tostring(adIndex):lower()) then return true end
                        if displayName and (normStealName(inf.DisplayName) == normStealName(displayName) or inf.DisplayName:lower() == displayName:lower()) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function findPlotForPlayer(plr)
        if not plr then return nil end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local dn = (plr.DisplayName or ""):lower()
        local un = (plr.Name or ""):lower()
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if (dn ~= "" and text:find(dn, 1, true)) or (un ~= "" and text:find(un, 1, true)) then
                            return plot
                        end
                    end
                end
            end
        end
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        local syncMod = pkg and pkg:FindFirstChild("Synchronizer")
        if syncMod then
            local okReq, Sync = pcall(function() return require(syncMod) end)
            if okReq and Sync then
                for _, plot in ipairs(plots:GetChildren()) do
                    local okCh, ch = pcall(function() return Sync:Get(plot.Name) end)
                    if okCh and ch then
                        local owner = ch:Get("Owner")
                        if owner then
                            if typeof(owner) == "Instance" and owner:IsA("Player") and owner == plr then
                                return plot
                            end
                            if type(owner) == "table" and owner.UserId == plr.UserId then
                                return plot
                            end
                        end
                    end
                end
            end
        end
        return nil
    end

    local function getPlotSignAdorneePart(plot)
        if not plot then return nil end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return nil end
        if sign:IsA("BasePart") then return sign end
        if sign:IsA("Model") then
            return sign.PrimaryPart or sign:FindFirstChildWhichIsA("BasePart", true)
        end
        return sign:FindFirstChildWhichIsA("BasePart", true)
    end

    local function resolveStolenPetEntry(plr, stealIdx)
        if stealIdx == nil or stealIdx == "" then return nil end
        ensureStealEspModules()
        local myPlot = findPlotForPlayer(plr)
        local myPlotName = myPlot and myPlot.Name
        local cache = SharedState.AllAnimalsCache
        local best, bestGv = nil, -1

        local function considerEntry(entry, gv)
            if not entry or not entry.plot then return end
            if myPlotName and entry.plot == myPlotName then return end
            if entry.owner and entry.owner == plr.Name then return end
            local g = tonumber(gv) or tonumber(entry.genValue) or 0
            if g > bestGv then
                bestGv = g
                best = entry
            end
        end

        if cache then
            for _, a in ipairs(cache) do
                if a and a.name and a.owner and a.owner ~= plr.Name then
                    if stealIdxMatchesAnimal(stealIdx, nil, a.name) then
                        considerEntry(a, a.genValue)
                    end
                end
            end
        end

        if best then return best end

        if not SyncStealEsp or not AnimalsDataStealEsp then return nil end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end

        for _, plot in ipairs(plots:GetChildren()) do
            if not myPlotName or plot.Name ~= myPlotName then
                local okCh, ch = pcall(function() return SyncStealEsp:Get(plot.Name) end)
                if okCh and ch then
                    local owner = ch:Get("Owner")
                    local ownerName = nil
                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                        ownerName = owner.Name
                    elseif type(owner) == "table" and owner.Name then
                        ownerName = owner.Name
                    end
                    if ownerName ~= plr.Name then
                        local al = ch:Get("AnimalList")
                        if type(al) == "table" then
                            for slot, ad in pairs(al) do
                                if type(ad) == "table" and ad.Index then
                                    local aInfo = AnimalsDataStealEsp[ad.Index]
                                    local disp = (aInfo and aInfo.DisplayName) or ad.Index
                                    if stealIdxMatchesAnimal(stealIdx, ad.Index, disp) then
                                        local gv = 0
                                        pcall(function()
                                            if AnimalsSharedStealEsp then
                                                gv = AnimalsSharedStealEsp:GetGeneration(ad.Index, ad.Mutation, ad.Traits, nil)
                                            end
                                        end)
                                        considerEntry({
                                            name = disp,
                                            index = ad.Index,
                                            genText = "",
                                            genValue = gv,
                                            mutation = ad.Mutation,
                                            traits = "",
                                            owner = ownerName or "?",
                                            plot = plot.Name,
                                            slot = tostring(slot),
                                            uid = plot.Name .. "_" .. tostring(slot),
                                        }, gv)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        return best
    end

    local function clearRow(uid)
        local r = byUser[uid]
        if not r then return end
        if r.bill and r.bill.Parent then r.bill:Destroy() end
        byUser[uid] = nil
    end

    Players.PlayerRemoving:Connect(function(plr)
        clearRow(plr.UserId)
    end)

    while true do
        task.wait(0.35)
        local enabled = Config.ShowStealingPlotESP ~= false
        espGui.Enabled = enabled
        if not enabled then
            local clearIds = {}
            for uid in pairs(byUser) do table.insert(clearIds, uid) end
            for _, uid in ipairs(clearIds) do clearRow(uid) end
        else
            local attachFn = _G.XiAttachPet3DPreview
            local active = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr:GetAttribute("Stealing") then
                    local idx = plr:GetAttribute("StealingIndex")
                    if idx ~= nil and idx ~= "" then
                        local plot = findPlotForPlayer(plr)
                        local part = getPlotSignAdorneePart(plot)
                        if part and part:IsDescendantOf(Workspace) then
                            active[plr.UserId] = true
                            local petEntry = resolveStolenPetEntry(plr, idx)
                            local petName = petEntry and petEntry.name or tostring(idx)
                            local stealKey = tostring(idx) .. "|" .. tostring(petEntry and petEntry.uid or "") .. "|" .. part:GetFullName()
                            local row = byUser[plr.UserId]
                            if row and (row.stealKey ~= stealKey or row.adornee ~= part) then
                                clearRow(plr.UserId)
                                row = nil
                            end
                            if not byUser[plr.UserId] then
                                local bb = Instance.new("BillboardGui")
                                bb.Name = "StealPlotESP_" .. plr.Name
                                bb.Adornee = part
                                bb.AlwaysOnTop = true
                                bb.Size = UDim2.new(0, 210, 0, 52)
                                bb.StudsOffset = Vector3.new(0, 4, 0)
                                bb.MaxDistance = 650
                                bb.LightInfluence = 0
                                bb.Parent = espGui

                                local root = Instance.new("Frame")
                                root.Name = "Root"
                                root.Size = UDim2.new(1, 0, 1, 0)
                                root.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
                                root.BackgroundTransparency = 0.08
                                root.BorderSizePixel = 0
                                root.Parent = bb
                                Instance.new("UICorner", root).CornerRadius = UDim.new(0, 10)
                                local stroke = Instance.new("UIStroke", root)
                                stroke.Color = Color3.fromRGB(148, 210, 245)
                                stroke.Thickness = 1
                                stroke.Transparency = 0.3

                                local thumbBox = Instance.new("Frame")
                                thumbBox.Name = "ThumbBox"
                                thumbBox.Size = UDim2.new(0, 44, 0, 44)
                                thumbBox.AnchorPoint = Vector2.new(0, 0.5)
                                thumbBox.Position = UDim2.new(0, 4, 0.5, 0)
                                thumbBox.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
                                thumbBox.BackgroundTransparency = 0
                                thumbBox.BorderSizePixel = 0
                                thumbBox.Parent = root
                                Instance.new("UICorner", thumbBox).CornerRadius = UDim.new(0, 6)
                                local thumbStroke = Instance.new("UIStroke", thumbBox)
                                thumbStroke.Color = Color3.fromRGB(100, 210, 255)
                                thumbStroke.Thickness = 1
                                thumbStroke.Transparency = 0.35

                                local title = Instance.new("TextLabel")
                                title.Name = "Title"
                                title.Size = UDim2.new(1, -58, 0, 20)
                                title.Position = UDim2.new(0, 54, 0, 9)
                                title.BackgroundTransparency = 1
                                title.Font = Enum.Font.GothamBlack
                                title.TextSize = 13
                                title.TextColor3 = Color3.fromRGB(240, 248, 255)
                                title.TextXAlignment = Enum.TextXAlignment.Left
                                title.TextTruncate = Enum.TextTruncate.AtEnd
                                title.Text = petName
                                title.Parent = root

                                local sub = Instance.new("TextLabel")
                                sub.Name = "Sub"
                                sub.Size = UDim2.new(1, -58, 0, 14)
                                sub.Position = UDim2.new(0, 54, 0, 31)
                                sub.BackgroundTransparency = 1
                                sub.Font = Enum.Font.GothamMedium
                                sub.TextSize = 10
                                sub.TextColor3 = Color3.fromRGB(130, 200, 230)
                                sub.TextXAlignment = Enum.TextXAlignment.Left
                                sub.Text = "@" .. plr.Name
                                sub.Parent = root

                                if attachFn then
                                    local petData = {
                                        petName = petName,
                                        previewCacheKey = petName ~= "" and petName:lower() or nil,
                                        animalData = {
                                            plot = petEntry and petEntry.plot or nil,
                                            slot = petEntry and petEntry.slot or nil,
                                            Index = petEntry and (petEntry.index or petEntry.Index) or nil,
                                            index = petEntry and (petEntry.index or petEntry.Index) or nil,
                                        }
                                    }
                                    task.defer(function()
                                        if not thumbBox.Parent then return end
                                        local okAttach = pcall(function()
                                            attachFn(thumbBox, petData, {
                                                Size = UDim2.new(1, 0, 1, 0),
                                                Position = UDim2.new(0, 0, 0, 0),
                                                CornerRadius = 6,
                                                Fov = 34,
                                                ForceLiveModelOnly = false,
                                                ForceFallbackModel = false,
                                                ForceEmbeddedAnimation = false,
                                            })
                                        end)
                                        if (not okAttach) and thumbBox.Parent then
                                            local no3dErr = Instance.new("TextLabel")
                                            no3dErr.Size = UDim2.new(1, 0, 1, 0)
                                            no3dErr.BackgroundTransparency = 0.35
                                            no3dErr.BackgroundColor3 = Theme.SurfaceHighlight
                                            no3dErr.Text = "?"
                                            no3dErr.Font = Enum.Font.GothamBold
                                            no3dErr.TextSize = 14
                                            no3dErr.TextColor3 = Theme.TextSecondary
                                            no3dErr.Parent = thumbBox
                                            Instance.new("UICorner", no3dErr).CornerRadius = UDim.new(0, 6)
                                        end
                                    end)
                                else
                                    local no3d = Instance.new("TextLabel")
                                    no3d.Size = UDim2.new(1, 0, 1, 0)
                                    no3d.BackgroundTransparency = 0.35
                                    no3d.BackgroundColor3 = Theme.SurfaceHighlight
                                    no3d.Text = "..."
                                    no3d.Font = Enum.Font.GothamBold
                                    no3d.TextSize = 10
                                    no3d.TextColor3 = Theme.TextSecondary
                                    no3d.Parent = thumbBox
                                    Instance.new("UICorner", no3d).CornerRadius = UDim.new(0, 6)
                                end

                                byUser[plr.UserId] = { bill = bb, adornee = part, stealKey = stealKey }
                            else
                                row = byUser[plr.UserId]
                                if row and row.bill and row.bill.Parent then
                                    local rootFrame = row.bill:FindFirstChild("Root")
                                    if rootFrame then
                                        local t = rootFrame:FindFirstChild("Title")
                                        if t and t:IsA("TextLabel") then
                                            t.Text = petName
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            local stale = {}
            for uid in pairs(byUser) do
                if not active[uid] then table.insert(stale, uid) end
            end
            for _, uid in ipairs(stale) do clearRow(uid) end
        end
    end
end)

-- ── Titanz Optimizer ────────────────────────────────────────────
local Threads = {}
local Connections = {}

local Services = {
	Players         = game:GetService("Players"),
	Lighting        = game:GetService("Lighting"),
	MaterialService = game:GetService("MaterialService"),
}

local XMin, XMax = -560, -240

local ClothingClasses = {
	"Shirt","Pants","ShirtGraphic",
	"Accessory","Hat","HairAccessory",
	"FaceAccessory","NeckAccessory","ShoulderAccessory",
	"FrontAccessory","BackAccessory","WaistAccessory",
}

function _F.AddThread(f)
	table.insert(Threads, task.spawn(f))
end

function _F.AddConnection(c)
	table.insert(Connections, c)
end

function _F.SafeDestroy(obj)
	if obj.Name == "Overhead" then return end
	pcall(function() obj:Destroy() end)
end

local Opt = {}

function Opt.IsClothing(obj)
	for _, c in ipairs(ClothingClasses) do
		if obj:IsA(c) then return true end
	end
end

function Opt.IsCharacterPart(obj)
	for _, plr in ipairs(Services.Players:GetPlayers()) do
		if plr.Character and obj:IsDescendantOf(plr.Character) then
			return true
		end
	end
end

function Opt.IsOutOfRange(obj)
	if obj:IsA("BasePart") then
		local x = obj.Position.X
		return x < XMin or x > XMax
	end
end

-- ============================
-- TRANSPARENT BASES
-- ============================
local BASE_NAMES = {
	"baseplate", "spawnlocation", "spawn location", "spawn",
}

function Opt.IsBase(obj)
	if not obj:IsA("BasePart") then return false end
	local nameLower = obj.Name:lower()
	for _, n in ipairs(BASE_NAMES) do
		if nameLower:find(n, 1, true) then return true end
	end
	return false
end

function Opt.MakeTransparent(obj)
	pcall(function()
		if Opt.IsBase(obj) and not Opt.IsCharacterPart(obj) then
			obj.Transparency = 1
			obj.CastShadow   = false
		end
	end)
end

function Opt.ApplyTransparentBases()
	for _, obj in ipairs(workspace:GetDescendants()) do
		Opt.MakeTransparent(obj)
	end
end

-- ============================
-- STRIP OBJECT
-- ============================
function Opt.StripObject(obj)
	pcall(function()
		if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
			_F.SafeDestroy(obj)
		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
			or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
			pcall(function() obj.Enabled = false end)
			_F.SafeDestroy(obj)
		elseif obj:IsA("SurfaceAppearance") then
			_F.SafeDestroy(obj)
		elseif obj:IsA("BasePart") then
			obj.CastShadow      = false
			obj.Material        = Enum.Material.Plastic
			obj.MaterialVariant = ""
			obj.Reflectance     = 0
		end
	end)
end

-- ============================
-- CLEAN OBJECT
-- ============================
function Opt.CleanObject(obj)
	pcall(function()
		if obj:IsA("SurfaceAppearance") then
			_F.SafeDestroy(obj)

		elseif obj:IsA("Decal") or obj:IsA("Texture") then
			if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then
				_F.SafeDestroy(obj)
			end

		elseif obj:IsA("SpecialMesh") then
			obj.TextureId = ""

		elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
			_F.SafeDestroy(obj)

		elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
			_F.SafeDestroy(obj)

		elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
			_F.SafeDestroy(obj)

		elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
			_F.SafeDestroy(obj)

		elseif obj:IsA("BasePart") then
			obj.CastShadow      = false
			obj.Material        = Enum.Material.Plastic
			obj.MaterialVariant = ""
			obj.Reflectance     = 0
		end
	end)
end

-- ============================
-- STOP ANIMATIONS
-- ============================
function Opt.StopAnimations(animator)
	pcall(function()
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			local isChar = false

			for _, plr in ipairs(Services.Players:GetPlayers()) do
				if plr.Character and animator:IsDescendantOf(plr.Character) then
					isChar = true
					break
				end
			end

			if not isChar then
				track:Stop()
			end
		end
	end)
end

-- ============================
-- OPTIMIZE CHARACTER
-- ============================
function Opt.OptimizeCharacter(char)
	if not char then return end

	task.spawn(function()
		task.wait(0.3)

		for _, obj in ipairs(char:GetDescendants()) do
			if Opt.IsClothing(obj) then
				_F.SafeDestroy(obj)
			else
				Opt.CleanObject(obj)
			end
		end
	end)
end

-- ============================
-- GREY SKY (blank sky fast flag)
-- ============================
function Opt.ApplyGreySky()
	pcall(function()
		-- Remove any existing Sky instances first
		for _, obj in ipairs(Services.Lighting:GetChildren()) do
			if obj:IsA("Sky") then
				obj:Destroy()
			end
		end

		-- Insert a blank Sky — renders as a flat grey void
		local sky        = Instance.new("Sky")
		sky.SkyboxBk     = ""
		sky.SkyboxDn     = ""
		sky.SkyboxFt     = ""
		sky.SkyboxLf     = ""
		sky.SkyboxRt     = ""
		sky.SkyboxUp     = ""
		sky.CelestialBodiesShown = false
		sky.Parent       = Services.Lighting
	end)
end

-- ============================
-- LIGHTING (remove effects + grey sky + dim slightly)
-- ============================
function Opt.OptimizeLighting()
	local L = Services.Lighting

	L.GlobalShadows            = false
	L.FogEnd                   = 9e9
	L.FogStart                 = 9e9
	L.EnvironmentDiffuseScale  = 0
	L.EnvironmentSpecularScale = 0

	-- Dim the scene down just a touch
	L.Brightness               = 1.5   -- default is 2; slightly darker
	L.Ambient                  = Color3.fromRGB(60, 60, 60)  -- subtle dim ambient

	for _, v in ipairs(L:GetChildren()) do
		if v:IsA("BloomEffect") or v:IsA("BlurEffect")
		or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
		or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere")
		or v:IsA("Clouds") then
			v:Destroy()
		end
	end

	Opt.ApplyGreySky()
end

-- ============================
-- TERRAIN
-- ============================
function Opt.ApplyTerrain()
	pcall(function()
		local T = workspace.Terrain
		T.Decoration        = false
		T.WaterWaveSize     = 0
		T.WaterWaveSpeed    = 0
		T.WaterReflectance  = 0
		T.WaterTransparency = 1
	end)
end

-- ============================
-- RENDER / PHYSICS SETTINGS
-- ============================
pcall(function()
	settings().Rendering.QualityLevel        = Enum.QualityLevel.Level01
	settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01

	workspace.Terrain.WaterWaveSize     = 0
	workspace.Terrain.WaterWaveSpeed    = 0
	workspace.Terrain.WaterReflectance  = 0
	workspace.Terrain.WaterTransparency = 1
	workspace.Terrain.Decoration        = false

	settings().Physics.AllowSleep = true
	settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Skip
end)

pcall(function() setfpscap(999) end)

-- ============================
-- MAIN INIT THREAD
-- ============================
_F.AddThread(function()
	if not game:IsLoaded() then game.Loaded:Wait() end
	task.wait(2)

	Opt.OptimizeLighting()
	Opt.ApplyTerrain()

	for _, obj in ipairs(workspace:GetDescendants()) do
		if Opt.IsBase(obj) then
			Opt.MakeTransparent(obj)

		elseif Opt.IsClothing(obj) then
			_F.SafeDestroy(obj)

		elseif Opt.IsCharacterPart(obj) then
			-- skip

		elseif Opt.IsOutOfRange(obj) then
			_F.SafeDestroy(obj)

		else
			Opt.CleanObject(obj)
			Opt.StripObject(obj)

			if obj:IsA("Animator") then
				Opt.StopAnimations(obj)
			end
		end
	end

	Opt.ApplyTransparentBases()
end)

-- ============================
-- LIGHTING EFFECT GUARD THREAD
-- ============================
_F.AddThread(function()
	while true do
		task.wait(2)
		pcall(function()
			local L = Services.Lighting
			for _, obj in ipairs(L:GetChildren()) do
				if obj:IsA("Atmosphere") or obj:IsA("Clouds")
				or obj:IsA("PostEffect") then
					_F.SafeDestroy(obj)
				end
			end
		end)
	end
end)

-- ============================
-- WORKSPACE WATCHER
-- ============================
_F.AddConnection(workspace.DescendantAdded:Connect(function(obj)
	task.defer(function()
		if Opt.IsBase(obj) then
			Opt.MakeTransparent(obj)
			return
		end

		if Opt.IsClothing(obj) then
			_F.SafeDestroy(obj)

		elseif Opt.IsCharacterPart(obj) then
			-- skip

		elseif Opt.IsOutOfRange(obj) then
			_F.SafeDestroy(obj)

		else
			Opt.CleanObject(obj)
			Opt.StripObject(obj)

			if obj:IsA("Animator") then
				Opt.StopAnimations(obj)
			end
		end
	end)
end))

-- ============================
-- LIGHTING GUARD
-- ============================
_F.AddConnection(Services.Lighting.DescendantAdded:Connect(function(obj)
	if obj:IsA("Atmosphere") or obj:IsA("Clouds")
	or obj:IsA("PostEffect") then
		_F.SafeDestroy(obj)
	end
end))

-- ============================
-- MATERIAL SERVICE GUARD
-- ============================
_F.AddConnection(Services.MaterialService.DescendantAdded:Connect(function(obj)
	_F.SafeDestroy(obj)
end))

-- ============================
-- PLAYER HOOKS
-- ============================
for _, plr in ipairs(Services.Players:GetPlayers()) do
	Opt.OptimizeCharacter(plr.Character)
	_F.AddConnection(plr.CharacterAdded:Connect(Opt.OptimizeCharacter))
end

_F.AddConnection(Services.Players.PlayerAdded:Connect(function(plr)
	_F.AddConnection(plr.CharacterAdded:Connect(Opt.OptimizeCharacter))
end))

-- ============================
-- GC THREAD
-- ============================
_F.AddThread(function()
	while true do
		task.wait(15)
		pcall(function() collectgarbage("collect") end)
	end
end)

print("[Optimizer] Loaded ✓")
raknet.add_send_hook(function(packet)
    if packet.PacketId == 0x1B then
        local data = packet.AsBuffer
        buffer.writeu32(data, 1, 0xFFFFFFFF)
        packet:SetData(data)
    end
end)
