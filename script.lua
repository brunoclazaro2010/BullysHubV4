-- ============================================================
-- HAVAIANAS HUB (completo)
-- ============================================================
-- Cria uma HUD com:
--   * Painel superior com FPS / Ping
--   * Bolinha de configurações no canto superior esquerdo com LED verde claro
--   * Menu de configurações centralizado com opções: Auto Steal, Anti Ragdoll, Ferramentas de TP, Auto TP on Script Load
--   * Opção Anti Ragdoll (V1)
--   * Menu Auto Steal no canto direito com botão TP manual
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ========== CONFIGURAÇÕES ==========
local Config = {
    ShowUnlockButtonsHUD = true,
    FOV = 70,
    AntiRagdoll = false,
    AutoStealEnabled = true,
    StealNearest = true,
    StealHighest = false,
    SelectedTool = "Flying Carpet",
    TpOnLoad = false,
    MinGenForTp = "",
}

-- ========== TEMAS (verde claro) ==========
local Theme = {
    Background       = Color3.fromRGB(20, 15, 20),
    Surface          = Color3.fromRGB(35, 25, 35),
    SurfaceHighlight = Color3.fromRGB(50, 35, 50),
    Accent1          = Color3.fromRGB(144, 238, 144),
    Accent2          = Color3.fromRGB(50, 205, 50),
    TextPrimary      = Color3.fromRGB(255, 240, 250),
    TextSecondary    = Color3.fromRGB(200, 160, 190),
    Success          = Color3.fromRGB(144, 238, 144),
    Error            = Color3.fromRGB(255, 90, 140),
}

-- Variável global para controlar clonagem
_G.isCloning = false

-- ========== FUNÇÕES AUXILIARES DO TP ORIGINAL ==========
local function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    
    local Controls = nil
    pcall(function()
        local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
        local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
        Controls = playerModule:GetControls()
    end)
    
    local lookVector = hrp.CFrame.LookVector
    if Controls then Controls:Disable() end
    
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            if hum then hum:Move(Vector3.zero, false) end
            if Controls then Controls:Enable() end
            return
        end
        if hum then hum:Move(lookVector, false) end
    end)
end

local function instantClone()
    if _G.isCloning then return end
    _G.isCloning = true

    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end

        local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")
        if not cloner then error("No Quantum Cloner") end

        pcall(function() hum:EquipTool(cloner) end)
        task.wait(0.05)
        cloner:Activate()
        task.wait(0.05)

        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.1)
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

-- ========== ANTI RAGDOLL V1 ==========
local antiRagdollConn = nil
local function isRagdolled()
    local char = LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return false end
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

local function startAntiRagdoll()
    if antiRagdollConn then antiRagdollConn:Disconnect() end
    if not Config.AntiRagdoll then return end
    
    antiRagdollConn = RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if isRagdolled() then
            pcall(function() 
                LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) 
            end)
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

local function stopAntiRagdoll()
    if antiRagdollConn then 
        antiRagdollConn:Disconnect() 
        antiRagdollConn = nil 
    end
end

local function setAntiRagdoll(enabled)
    Config.AntiRagdoll = enabled
    if enabled then startAntiRagdoll() else stopAntiRagdoll() end
end

setAntiRagdoll(Config.AntiRagdoll)

-- ========== CARREGAR MÓDULOS DO JOGO ==========
local Synchronizer, AnimalsData, AnimalsShared, NumberUtils

pcall(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")
    
    Synchronizer = require(Packages:WaitForChild("Synchronizer"))
    AnimalsData = require(Datas:WaitForChild("Animals"))
    AnimalsShared = require(Shared:WaitForChild("Animals"))
    NumberUtils = require(Utils:WaitForChild("NumberUtils"))
end)

-- ========== AUTO STEAL - DADOS REAIS ==========
local allAnimalsCache = {}
local selectedTargetIndex = 1
local selectedTargetUID = nil
local autoStealEnabled = Config.AutoStealEnabled
local stealNearestEnabled = Config.StealNearest
local stealHighestEnabled = Config.StealHighest
local manualModeEnabled = false
local petButtons = {}
local listFrame = nil
local targetValueLabel = nil
local lastAnimalData = {}
local activeProgressTween = nil
local currentStealTargetUID = nil
local STEAL_DURATION = 0.8

-- ========== BASES E POSIÇÕES PARA TP ==========
local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100) 
}

local BASES_HIGH = {
    [1] = Vector3.new(-476.474853515625, 20.732906341552734, 220.94090270996094), 
    [5] = Vector3.new(-342.5367126464844, 20.69801902770996, 221.44737243652344),
    [2] = Vector3.new(-476.5684814453125, 20.70664405822754, 113.77315521240234), 
    [6] = Vector3.new(-342.8604736328125, 20.669641494750977, 113.41409301757812),
    [3] = Vector3.new(-476.8675842285156, 20.74148178100586, 6.178487777709961),  
    [7] = Vector3.new(-342.42108154296875, 20.687667846679688, 6.249461650848389),
    [4] = Vector3.new(-476.6324768066406, 20.744949340820312, -101.07275390625), 
    [8] = Vector3.new(-342.7937927246094, 20.748071670532227, -99.73458862304688)
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

local function findAdorneeGlobal(animalData)
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

local function getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
end

local function _isTargetPlotUnlocked(plotName)
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

-- Função principal de TP (manual ou automática)
local function runAutoSnipe()
    local targetPetData = nil
    
    if selectedTargetUID and petButtons[selectedTargetIndex] then
        targetPetData = petButtons[selectedTargetIndex].pet
    else
        local cache = allAnimalsCache
        if cache and #cache > 0 then
            targetPetData = cache[1]
        end
    end
    
    if not targetPetData then return false end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then return false end
    
    local targetPart = findAdorneeGlobal(targetPetData)
    if not targetPart then return false end
    
    local exactPos = targetPart.Position
    local toolName = Config.SelectedTool
    local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)

    if tool then hum:EquipTool(tool) end
    task.wait(0.01)
    
    local isSecondFloor = exactPos.Y > 10
    local plotIndex = getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]
    
    local minHeight = 50
    local targetHeight = math.max(targetBasePos.Y, minHeight)

    -- SOBE
    local jumpStart = tick()
    while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 3 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 200, hrp.AssemblyLinearVelocity.Z)
        RunService.Heartbeat:Wait()
    end

    -- POSICIONA NA BASE
    for i = 1, 6 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        if (hrp.Position - targetBasePos).Magnitude > 3 then
            hrp.CFrame = CFrame.new(targetBasePos)
            task.wait(0.05)
        end
    end

    -- POSICIONA NO CHÃO (clone positions)
    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetPart.Position - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        for i = 1, 6 do
            if (hrp.Position - bestSpot).Magnitude > 3 then
                hrp.CFrame = CFrame.new(bestSpot)
                task.wait(0.05)
            end
        end
    end

    -- FACE TARGET
    local bestFace = FACE_TARGETS[1]
    local minFaceDist = math.huge
    for _, v in ipairs(FACE_TARGETS) do
        local d = (hrp.Position - v).Magnitude
        if d < minFaceDist then
            minFaceDist = d
            bestFace = v
        end
    end

    task.wait(0.08)
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))
    
    -- WALK FORWARD E CLONE
    if isSecondFloor or not _isTargetPlotUnlocked(targetPetData.plot) then
        walkForward(0.3)
        task.wait(0.3)
        instantClone()
        while _G.isCloning do task.wait() end
    end
    task.wait(0.1)

    if tool then hum:EquipTool(tool) end

    -- PLATAFORMA
    local verticalDiff = targetPart.Position.Y - hrp.Position.Y
    if verticalDiff > 2 then
        local CHAR_ABOVE_PLAT = 5.5
        local offset = 12.5

        local platY = targetPart.Position.Y - offset
        local charY = platY + 0.5 + CHAR_ABOVE_PLAT - 2
        local platPos = Vector3.new(targetPart.Position.X, platY, targetPart.Position.Z)
        local charPos = Vector3.new(targetPart.Position.X, charY, targetPart.Position.Z)

        local plat = Instance.new("Part")
        plat.Name = "BullysTempPlatform"
        plat.Size = Vector3.new(4, 1, 4)
        plat.Position = platPos
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace

        RunService.Heartbeat:Wait()

        for i = 1, 10 do
            if not LocalPlayer:GetAttribute("Stealing") then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = CFrame.new(charPos)
                task.wait(0.05)
            end
        end

        local pinConn
        pinConn = RunService.Heartbeat:Connect(function()
            if LocalPlayer:GetAttribute("Stealing") then
                pinConn:Disconnect()
                _G._activePinConn = nil
                return
            end
            local newPlatY = targetPart.Position.Y - 12.5
            plat.Position = Vector3.new(targetPart.Position.X, newPlatY, targetPart.Position.Z)
        end)
        _G._activePinConn = pinConn
        _G._activePlat = plat

        task.spawn(function()
            local start = tick()
            local platTime = 10
            while tick() - start < platTime do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            if pinConn then pinConn:Disconnect() end
            _G._activePinConn = nil
            _G._activePlat = nil
            if plat and plat.Parent then plat:Destroy() end
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
    
    return true
end

-- Executar Auto TP on load (desliga automaticamente após executar)
local function executeAutoTpOnLoad()
    task.spawn(function()
        local t = 0
        while (#allAnimalsCache == 0 or not selectedTargetUID) and t < 150 do
            task.wait(0.1)
            t = t + 1
        end

        if #allAnimalsCache == 0 then
            -- Desliga o toggle se não encontrar brainrots
            if Config.TpOnLoad then
                Config.TpOnLoad = false
                if autoTpToggleKnob and autoTpToggleBg then
                    TweenService:Create(autoTpToggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -12)}):Play()
                    TweenService:Create(autoTpToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHighlight}):Play()
                end
            end
            return
        end

        local minGen = parseMinGen(Config.MinGenForTp)
        if minGen > 0 then
            local highestGen = (allAnimalsCache[1] and allAnimalsCache[1].genValue) or 0
            if highestGen < minGen then
                -- Desliga o toggle se a geração for insuficiente
                if Config.TpOnLoad then
                    Config.TpOnLoad = false
                    if autoTpToggleKnob and autoTpToggleBg then
                        TweenService:Create(autoTpToggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -12)}):Play()
                        TweenService:Create(autoTpToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHighlight}):Play()
                    end
                end
                return
            end
        end

        local success = runAutoSnipe()
        
        -- Após o TP, desliga o toggle
        if Config.TpOnLoad then
            Config.TpOnLoad = false
            if autoTpToggleKnob and autoTpToggleBg then
                TweenService:Create(autoTpToggleKnob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -12)}):Play()
                TweenService:Create(autoTpToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = Theme.SurfaceHighlight}):Play()
            end
        end
    end)
end

-- Executar TP manual (usado pelo botão)
local function executeManualTp()
    task.spawn(function()
        if #allAnimalsCache == 0 then
            return
        end
        runAutoSnipe()
    end)
end

-- Inicializar Auto TP on Load se estiver ativado
if Config.TpOnLoad then
    task.spawn(executeAutoTpOnLoad)
end

local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot then return false end
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return false end
    local plot = plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local channel = Synchronizer and Synchronizer:Get(plot.Name)
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

local function getAnimalHash(al)
    if not al then return "" end
    local h = ""
    for slot, d in pairs(al) do
        if type(d) == "table" then
            h = h .. tostring(slot) .. tostring(d.Index) .. tostring(d.Mutation)
        end
    end
    return h
end

local function scanSinglePlot(plot)
    if not Synchronizer then return end
    pcall(function()
        local ch = Synchronizer:Get(plot.Name)
        if not ch then return end
        local al = ch:Get("AnimalList")
        local hash = getAnimalHash(al)
        if lastAnimalData[plot.Name] == hash then return end
        lastAnimalData[plot.Name] = hash
        
        for i = #allAnimalsCache, 1, -1 do
            if allAnimalsCache[i].plot == plot.Name then
                table.remove(allAnimalsCache, i)
            end
        end
        
        local owner = ch:Get("Owner")
        if not owner or not Players:FindFirstChild(owner.Name) then return end
        local ownerName = owner.Name or "Unknown"
        if not al then return end
        
        for slot, ad in pairs(al) do
            if type(ad) == "table" then
                local aName, aInfo = ad.Index, AnimalsData and AnimalsData[ad.Index]
                if aInfo then
                    local mut = ad.Mutation or "None"
                    if mut == "Yin Yang" then mut = "YinYang" end
                    local traits = (ad.Traits and #ad.Traits > 0) and table.concat(ad.Traits, ", ") or "None"
                    local gv = AnimalsShared and AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil) or 0
                    local gt = "$" .. (NumberUtils and NumberUtils:ToString(gv) or tostring(gv)) .. "/s"
                    table.insert(allAnimalsCache, {
                        name = aInfo.DisplayName or aName,
                        genText = gt,
                        genValue = gv,
                        mutation = mut,
                        traits = traits,
                        owner = ownerName,
                        plot = plot.Name,
                        slot = tostring(slot),
                        uid = plot.Name .. "_" .. tostring(slot)
                    })
                end
            end
        end
    end)
    
    table.sort(allAnimalsCache, function(a, b) return a.genValue > b.genValue end)
end

local function setupPlotListener(plot)
    if not Synchronizer then return end
    local ch = nil
    local retries = 0
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

local function initPlotListeners()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, p in ipairs(plots:GetChildren()) do
        setupPlotListener(p)
    end
    plots.ChildAdded:Connect(function(p) task.wait(0.5); setupPlotListener(p) end)
end

task.spawn(initPlotListeners)

-- ========== STEAL LOGIC ==========
local PromptMemoryCache = {}
local InternalStealCache = {}

local function findProximityPromptForAnimal(animalData)
    if not animalData then return nil end
    local cp = PromptMemoryCache[animalData.uid]
    if cp and cp.Parent then return cp end
    local plot = Workspace.Plots:FindFirstChild(animalData.plot)
    if not plot then return nil end
    local podiums = plot:FindFirstChild("AnimalPodiums")
    if not podiums then return nil end
    
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

local function executeInternalStealAsync(prompt, animalUID)
    local data = InternalStealCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false

    task.spawn(function()
        if currentStealTargetUID ~= animalUID then
            if activeProgressTween then activeProgressTween:Cancel() end
            currentStealTargetUID = animalUID
        end

        if #data.holdCallbacks > 0 then
            runCallbackList(data.holdCallbacks)
        end

        task.wait(STEAL_DURATION)

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
    return executeInternalStealAsync(prompt, animalUID)
end

local function updateSelectionByMode()
    if manualModeEnabled then return end
    
    local availablePets = {}
    for _, pet in ipairs(allAnimalsCache) do
        if pet.genValue >= 1 and not isMyBaseAnimal(pet) then
            table.insert(availablePets, pet)
        end
    end
    
    if #availablePets == 0 then
        if targetValueLabel then targetValueLabel.Text = "Nenhum" end
        return
    end
    
    table.sort(availablePets, function(a, b) return a.genValue > b.genValue end)
    
    local newIndex = selectedTargetIndex
    if newIndex > #availablePets then newIndex = 1 end
    if newIndex < 1 then newIndex = 1 end
    
    if newIndex ~= selectedTargetIndex then
        selectedTargetIndex = newIndex
        if petButtons[selectedTargetIndex] then
            selectedTargetUID = petButtons[selectedTargetIndex].pet.uid
            if targetValueLabel then
                targetValueLabel.Text = petButtons[selectedTargetIndex].pet.name .. " (" .. petButtons[selectedTargetIndex].pet.genText .. ")"
            end
            for idx, pb in ipairs(petButtons) do
                local isSelected = (idx == selectedTargetIndex)
                if pb.bar then
                    pb.bar.BackgroundColor3 = isSelected and Theme.Accent2 or Theme.Accent1
                end
                if pb.rank then
                    pb.rank.TextColor3 = isSelected and Theme.Accent1 or Theme.TextSecondary
                end
                if pb.info then
                    pb.info.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
                end
                if pb.button then
                    local stroke = pb.button:FindFirstChild("SelectStroke")
                    if stroke then stroke.Transparency = isSelected and 0 or 1 end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        if not autoStealEnabled then continue end
        
        local availablePets = {}
        for _, pet in ipairs(allAnimalsCache) do
            if pet.genValue >= 1 and not isMyBaseAnimal(pet) then
                table.insert(availablePets, pet)
            end
        end
        
        if #availablePets == 0 then continue end
        
        table.sort(availablePets, function(a, b) return a.genValue > b.genValue end)
        
        local targetPet = nil
        
        if manualModeEnabled then
            if selectedTargetIndex >= 1 and selectedTargetIndex <= #availablePets then
                targetPet = availablePets[selectedTargetIndex]
            end
        elseif stealNearestEnabled then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local bestDist = math.huge
            for i, pet in ipairs(availablePets) do
                local plot = Workspace.Plots and Workspace.Plots:FindFirstChild(pet.plot)
                if plot then
                    local podiums = plot:FindFirstChild("AnimalPodiums")
                    if podiums then
                        local podium = podiums:FindFirstChild(pet.slot)
                        if podium then
                            local base = podium:FindFirstChild("Base")
                            local spawn = base and base:FindFirstChild("Spawn")
                            if spawn and hrp then
                                local dist = (hrp.Position - spawn.Position).Magnitude
                                if dist < bestDist then
                                    bestDist = dist
                                    targetPet = pet
                                    selectedTargetIndex = i
                                end
                            end
                        end
                    end
                end
            end
        elseif stealHighestEnabled then
            targetPet = availablePets[1]
            selectedTargetIndex = 1
        end
        
        if targetPet and not isMyBaseAnimal(targetPet) then
            if not manualModeEnabled and petButtons[selectedTargetIndex] then
                selectedTargetUID = petButtons[selectedTargetIndex].pet.uid
                if targetValueLabel then
                    targetValueLabel.Text = petButtons[selectedTargetIndex].pet.name .. " (" .. petButtons[selectedTargetIndex].pet.genText .. ")"
                end
                for idx, pb in ipairs(petButtons) do
                    local isSelected = (idx == selectedTargetIndex)
                    if pb.bar then
                        pb.bar.BackgroundColor3 = isSelected and Theme.Accent2 or Theme.Accent1
                    end
                    if pb.rank then
                        pb.rank.TextColor3 = isSelected and Theme.Accent1 or Theme.TextSecondary
                    end
                    if pb.info then
                        pb.info.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
                    end
                    if pb.button then
                        local stroke = pb.button:FindFirstChild("SelectStroke")
                        if stroke then stroke.Transparency = isSelected and 0 or 1 end
                    end
                end
            end
            
            local prompt = findProximityPromptForAnimal(targetPet)
            if prompt then
                attemptSteal(prompt, targetPet.uid)
            end
        end
    end
end)

-- ========== FUNÇÃO AUXILIAR: addRacetrackBorder ==========
local function addRacetrackBorder(parentFrame, carColor, speed)
    if not parentFrame or not parentFrame:IsA("Frame") then return end
    carColor = carColor or Theme.Accent1
    speed    = speed or 2.5

    local stroke = Instance.new("UIStroke")
    stroke.Name = "RacetrackBorder"
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Thickness  = 6
    stroke.Color      = carColor
    stroke.Transparency = 0.3
    stroke.Parent = parentFrame

    local grad = Instance.new("UIGradient")
    local bg = Theme.Background
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0,   bg),
        ColorSequenceKeypoint.new(0.3, carColor),
        ColorSequenceKeypoint.new(0.5, Theme.Accent2),
        ColorSequenceKeypoint.new(0.7, carColor),
        ColorSequenceKeypoint.new(1,   bg),
    }
    grad.Rotation = 0
    grad.Parent   = stroke

    local startTime = tick()
    local lastUp    = 0
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if not parentFrame.Parent then
            conn:Disconnect()
            return
        end
        local now = tick()
        if now - lastUp < 0.016 then return end
        lastUp = now

        local W = parentFrame.AbsoluteSize.X
        local H = parentFrame.AbsoluteSize.Y
        if W <= 0 or H <= 0 then return end

        local perim    = (W + H) * 2
        local elapsed  = (now - startTime) % speed
        local progress = elapsed / speed
        local dist     = (progress * perim) % perim
        local rot      = 0

        if dist < W then
            rot = (dist / W) * 90
        elseif dist < W + H then
            rot = 90 + ((dist - W) / H) * 90
        elseif dist < W * 2 + H then
            rot = 180 + ((dist - W - H) / W) * 90
        else
            rot = 270 + ((dist - W * 2 - H) / H) * 90
        end

        grad.Rotation = rot

        local wave = math.sin(progress * math.pi * 2)
        local intensity = (wave + 1) * 0.5
        stroke.Transparency = 0.05 + intensity * 0.4
        stroke.Thickness    = 6 + math.sin(now * 5) * 0.15
    end)

    return stroke
end

-- ========== FUNÇÃO PARA SELECIONAR FERRAMENTA ==========
local function selectTool(toolName)
    Config.SelectedTool = toolName
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        local tool = LocalPlayer.Backpack:FindFirstChild(toolName) or char:FindFirstChild(toolName)
        if tool then
            hum:EquipTool(tool)
        end
    end
end

-- ========== CRIAÇÃO DA HUD PRINCIPAL ==========
local function buildStatusHUD()
    local existing = PlayerGui:FindFirstChild("BullysStatusHUD")
    if existing then existing:Destroy() end

    local hudGui = Instance.new("ScreenGui")
    hudGui.Name = "BullysStatusHUD"
    hudGui.ResetOnSpawn = false
    hudGui.DisplayOrder = 10
    hudGui.Parent = PlayerGui

    -- Painel principal (FPS/Ping)
    local main = Instance.new("Frame", hudGui)
    main.Name = "Main"
    main.Size = UDim2.new(0, 460, 0, 44)
    main.Position = UDim2.new(0.5, -230, 1, -125)
    main.BackgroundColor3 = Theme.Background
    main.BackgroundTransparency = 0.25
    main.BorderSizePixel = 0
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    local mainStroke = Instance.new("UIStroke", main)
    mainStroke.Color = Theme.Accent1
    mainStroke.Thickness = 1.2
    mainStroke.Transparency = 0.55

    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(0, 3, 0, 22)
    bar.Position = UDim2.new(0, 10, 0.5, -11)
    bar.BackgroundColor3 = Theme.Accent1
    bar.BorderSizePixel = 0
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 2)

    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(0, 140, 1, 0)
    title.Position = UDim2.new(0, 18, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "HAVAIANAS HUB"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 14
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left

    local stats = Instance.new("TextLabel", main)
    stats.Size = UDim2.new(0, 160, 1, 0)
    stats.Position = UDim2.new(1, -168, 0, 0)
    stats.BackgroundTransparency = 1
    stats.RichText = true
    stats.Text = ""
    stats.Font = Enum.Font.GothamBold
    stats.TextSize = 12
    stats.TextColor3 = Theme.TextPrimary
    stats.TextXAlignment = Enum.TextXAlignment.Right

    local frameCount = 0
    local timeAcc = 0
    RunService.Heartbeat:Connect(function(dt)
        frameCount = frameCount + 1
        timeAcc = timeAcc + dt
        if timeAcc >= 1 then
            local fps = frameCount
            local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
            local fpsColor = fps >= 50 and "rgb(80,255,150)" or (fps >= 30 and "rgb(255,210,80)" or "rgb(255,80,80)")
            local pingColor = ping < 100 and "rgb(80,255,150)" or (ping < 200 and "rgb(255,210,80)" or "rgb(255,80,80)")
            stats.Text = string.format(
                "<font color='rgb(140,140,160)'>FPS:</font> <font color='%s'><b>%d</b></font>  <font color='rgb(140,140,160)'>PING:</font> <font color='%s'><b>%dms</b></font>",
                fpsColor, fps, pingColor, ping
            )
            frameCount = 0
            timeAcc = 0
        end
    end)

    task.spawn(function()
        addRacetrackBorder(main, Theme.Accent1, 4)
    end)

    -- ========== BOLINHA DE CONFIGURAÇÕES ==========
    local settingsButton = Instance.new("TextButton", hudGui)
    settingsButton.Name = "SettingsButton"
    settingsButton.Size = UDim2.new(0, 48, 0, 48)
    settingsButton.Position = UDim2.new(0, 12, 0, 12)
    settingsButton.BackgroundColor3 = Theme.Surface
    settingsButton.BackgroundTransparency = 0.1
    settingsButton.Text = "⚙️"
    settingsButton.Font = Enum.Font.GothamBlack
    settingsButton.TextSize = 24
    settingsButton.TextColor3 = Theme.TextPrimary
    settingsButton.BorderSizePixel = 0
    settingsButton.AutoButtonColor = false
    settingsButton.ZIndex = 15
    Instance.new("UICorner", settingsButton).CornerRadius = UDim.new(1, 0)

    local settingsLED = Instance.new("UIStroke", settingsButton)
    settingsLED.Color = Theme.Accent1
    settingsLED.Thickness = 4
    settingsLED.Transparency = 0.1
    settingsLED.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while settingsButton and settingsButton.Parent do
            for t = 0, 1, 0.05 do
                if not settingsButton.Parent then break end
                local intensity = 0.1 + math.sin(t * math.pi * 2) * 0.15
                settingsLED.Transparency = intensity
                task.wait(0.05)
            end
        end
    end)

    -- ========== MENU DE CONFIGURAÇÕES ==========
    local settingsMenu = Instance.new("Frame", hudGui)
    settingsMenu.Name = "SettingsMenu"
    settingsMenu.Size = UDim2.new(0, 380, 0, 420)
    settingsMenu.Position = UDim2.new(0.5, -190, 0.35, -210)
    settingsMenu.BackgroundColor3 = Theme.Background
    settingsMenu.BackgroundTransparency = 0.08
    settingsMenu.BorderSizePixel = 0
    settingsMenu.Visible = false
    settingsMenu.ZIndex = 20
    Instance.new("UICorner", settingsMenu).CornerRadius = UDim.new(0, 12)

    local menuLED = Instance.new("UIStroke", settingsMenu)
    menuLED.Color = Theme.Accent1
    menuLED.Thickness = 4
    menuLED.Transparency = 0.2
    menuLED.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while settingsMenu and settingsMenu.Parent do
            for t = 0, 1, 0.05 do
                if not settingsMenu.Parent then break end
                local intensity = 0.2 + math.sin(t * math.pi * 2) * 0.2
                menuLED.Transparency = intensity
                task.wait(0.05)
            end
        end
    end)

    local menuTitle = Instance.new("TextLabel", settingsMenu)
    menuTitle.Size = UDim2.new(1, 0, 0, 40)
    menuTitle.Position = UDim2.new(0, 0, 0, 0)
    menuTitle.BackgroundColor3 = Theme.Surface
    menuTitle.BackgroundTransparency = 0.15
    menuTitle.Text = "HAVAIANAS CONFIGURAÇÕES"
    menuTitle.Font = Enum.Font.GothamBlack
    menuTitle.TextSize = 18
    menuTitle.TextColor3 = Theme.Accent1
    menuTitle.TextXAlignment = Enum.TextXAlignment.Center
    menuTitle.ZIndex = 25
    Instance.new("UICorner", menuTitle).CornerRadius = UDim.new(0, 12)

    local titleStroke = Instance.new("UIStroke", menuTitle)
    titleStroke.Color = Theme.Accent1
    titleStroke.Thickness = 2
    titleStroke.Transparency = 0.2

    local divider = Instance.new("Frame", settingsMenu)
    divider.Size = UDim2.new(1, -40, 0, 2)
    divider.Position = UDim2.new(0, 20, 0, 40)
    divider.BackgroundColor3 = Theme.Accent1
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.ZIndex = 21

    local optionsContainer = Instance.new("ScrollingFrame", settingsMenu)
    optionsContainer.Size = UDim2.new(1, -20, 1, -55)
    optionsContainer.Position = UDim2.new(0, 10, 0, 50)
    optionsContainer.BackgroundTransparency = 1
    optionsContainer.BorderSizePixel = 0
    optionsContainer.ScrollBarThickness = 3
    optionsContainer.ScrollBarImageColor3 = Theme.Accent1
    optionsContainer.ZIndex = 30

    local optionsLayout = Instance.new("UIListLayout", optionsContainer)
    optionsLayout.Padding = UDim.new(0, 6)
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function createToggleRow(parent, labelText, isOn, onToggle, order)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.ZIndex = 31
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Theme.Accent1
        rowStroke.Thickness = 1
        rowStroke.Transparency = 0.3

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.6, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.TextColor3 = Theme.TextPrimary
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 32

        local toggleBg = Instance.new("Frame", row)
        toggleBg.Size = UDim2.new(0, 56, 0, 28)
        toggleBg.Position = UDim2.new(1, -68, 0.5, -14)
        toggleBg.BackgroundColor3 = isOn and Theme.Accent1 or Theme.SurfaceHighlight
        toggleBg.BorderSizePixel = 0
        toggleBg.ZIndex = 31
        Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

        local toggleKnob = Instance.new("Frame", toggleBg)
        toggleKnob.Size = UDim2.new(0, 24, 0, 24)
        toggleKnob.Position = isOn and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleKnob.BorderSizePixel = 0
        toggleKnob.ZIndex = 32
        Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

        local knobShadow = Instance.new("UIStroke", toggleKnob)
        knobShadow.Color = Theme.Accent2
        knobShadow.Thickness = 1
        knobShadow.Transparency = 0.5

        local toggleButton = Instance.new("TextButton", toggleBg)
        toggleButton.Size = UDim2.new(1, 0, 1, 0)
        toggleButton.BackgroundTransparency = 1
        toggleButton.Text = ""
        toggleButton.ZIndex = 33

        local function updateToggle(state)
            isOn = state
            local targetPos = isOn and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
            local targetColor = isOn and Theme.Accent1 or Theme.SurfaceHighlight
            TweenService:Create(toggleKnob, TweenInfo.new(0.15), {Position = targetPos}):Play()
            TweenService:Create(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
            if onToggle then onToggle(isOn) end
        end

        toggleButton.MouseButton1Click:Connect(function()
            updateToggle(not isOn)
        end)

        return {update = updateToggle}
    end

    -- Função para criar botão de seleção de ferramenta (radio button)
    local function createToolButton(parent, toolName, yPos, isActive, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, 0, 0, 34)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = isActive and Theme.Accent1 or Theme.Surface
        btn.BackgroundTransparency = 0.1
        btn.Text = toolName
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = isActive and Color3.fromRGB(0, 0, 0) or Theme.TextPrimary
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.ZIndex = 35
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Theme.Accent1
        btnStroke.Thickness = 1
        btnStroke.Transparency = isActive and 0.2 or 0.6

        btn.MouseButton1Click:Connect(function()
            callback(toolName)
        end)

        return btn
    end

    -- Função para criar input de texto
    local function createInputRow(parent, labelText, placeholder, value, order, callback)
        local row = Instance.new("Frame", parent)
        row.Size = UDim2.new(1, 0, 0, 46)
        row.BackgroundColor3 = Theme.Surface
        row.BackgroundTransparency = 0
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.ZIndex = 31
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local rowStroke = Instance.new("UIStroke", row)
        rowStroke.Color = Theme.Accent1
        rowStroke.Thickness = 1
        rowStroke.Transparency = 0.3

        local label = Instance.new("TextLabel", row)
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 12, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.Font = Enum.Font.GothamBold
        label.TextSize = 12
        label.TextColor3 = Theme.TextPrimary
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 32

        local inputBox = Instance.new("TextBox", row)
        inputBox.Size = UDim2.new(0, 120, 0, 32)
        inputBox.Position = UDim2.new(1, -132, 0.5, -16)
        inputBox.BackgroundColor3 = Theme.SurfaceHighlight
        inputBox.Text = value or ""
        inputBox.PlaceholderText = placeholder
        inputBox.Font = Enum.Font.GothamMedium
        inputBox.TextSize = 12
        inputBox.TextColor3 = Theme.TextPrimary
        inputBox.ClearTextOnFocus = false
        inputBox.ZIndex = 32
        Instance.new("UICorner", inputBox).CornerRadius = UDim.new(0, 6)

        inputBox.FocusLost:Connect(function()
            if callback then callback(inputBox.Text) end
        end)

        return inputBox
    end

    -- Auto Steal Toggle
    local autoStealToggle = createToggleRow(optionsContainer, "Auto Steal", autoStealEnabled, function(enabled)
        autoStealEnabled = enabled
        Config.AutoStealEnabled = enabled
    end, 1)

    -- Anti Ragdoll Toggle
    createToggleRow(optionsContainer, "Anti Ragdoll", Config.AntiRagdoll, function(enabled)
        setAntiRagdoll(enabled)
    end, 2)

    -- Seção de Ferramentas de TP
    local toolsSection = Instance.new("Frame", optionsContainer)
    toolsSection.Size = UDim2.new(1, 0, 0, 150)
    toolsSection.BackgroundColor3 = Theme.Surface
    toolsSection.BackgroundTransparency = 0
    toolsSection.BorderSizePixel = 0
    toolsSection.LayoutOrder = 3
    toolsSection.ZIndex = 34
    Instance.new("UICorner", toolsSection).CornerRadius = UDim.new(0, 8)

    local toolsSectionStroke = Instance.new("UIStroke", toolsSection)
    toolsSectionStroke.Color = Theme.Accent1
    toolsSectionStroke.Thickness = 1
    toolsSectionStroke.Transparency = 0.3

    local toolsLabel = Instance.new("TextLabel", toolsSection)
    toolsLabel.Size = UDim2.new(1, -20, 0, 28)
    toolsLabel.Position = UDim2.new(0, 10, 0, 5)
    toolsLabel.BackgroundTransparency = 1
    toolsLabel.Text = "FERRAMENTAS DE TP"
    toolsLabel.Font = Enum.Font.GothamBlack
    toolsLabel.TextSize = 11
    toolsLabel.TextColor3 = Theme.Accent1
    toolsLabel.TextXAlignment = Enum.TextXAlignment.Left
    toolsLabel.ZIndex = 35

    local toolsPanel = Instance.new("Frame", toolsSection)
    toolsPanel.Size = UDim2.new(1, -20, 0, 105)
    toolsPanel.Position = UDim2.new(0, 10, 0, 36)
    toolsPanel.BackgroundTransparency = 1
    toolsPanel.ZIndex = 35

    local tools = {"Flying Carpet", "Cupid's Wings", "Santa's Sleigh", "Witch's Broom"}
    local toolButtons = {}

    for i, toolName in ipairs(tools) do
        local yPos = (i - 1) * 25
        local btn = createToolButton(toolsPanel, toolName, yPos, Config.SelectedTool == toolName, function(selected)
            selectTool(selected)
            for _, tb in ipairs(toolButtons) do
                local isActive = (tb.toolName == selected)
                tb.button.BackgroundColor3 = isActive and Theme.Accent1 or Theme.Surface
                tb.button.TextColor3 = isActive and Color3.fromRGB(0, 0, 0) or Theme.TextPrimary
                local stroke = tb.button:FindFirstChildOfClass("UIStroke")
                if stroke then stroke.Transparency = isActive and 0.2 or 0.6 end
            end
        end)
        table.insert(toolButtons, {button = btn, toolName = toolName})
    end

    -- Auto TP on Script Load (Toggle + Input)
    local autoTpSection = Instance.new("Frame", optionsContainer)
    autoTpSection.Size = UDim2.new(1, 0, 0, 90)
    autoTpSection.BackgroundColor3 = Theme.Surface
    autoTpSection.BackgroundTransparency = 0
    autoTpSection.BorderSizePixel = 0
    autoTpSection.LayoutOrder = 4
    autoTpSection.ZIndex = 34
    Instance.new("UICorner", autoTpSection).CornerRadius = UDim.new(0, 8)

    local autoTpSectionStroke = Instance.new("UIStroke", autoTpSection)
    autoTpSectionStroke.Color = Theme.Accent1
    autoTpSectionStroke.Thickness = 1
    autoTpSectionStroke.Transparency = 0.3

    -- Toggle do Auto TP on Script Load
    local autoTpRow = Instance.new("Frame", autoTpSection)
    autoTpRow.Size = UDim2.new(1, 0, 0, 46)
    autoTpRow.Position = UDim2.new(0, 0, 0, 0)
    autoTpRow.BackgroundColor3 = Theme.Surface
    autoTpRow.BackgroundTransparency = 0
    autoTpRow.BorderSizePixel = 0
    autoTpRow.ZIndex = 35
    Instance.new("UICorner", autoTpRow).CornerRadius = UDim.new(0, 8)

    local autoTpLabel = Instance.new("TextLabel", autoTpRow)
    autoTpLabel.Size = UDim2.new(0.6, 0, 1, 0)
    autoTpLabel.Position = UDim2.new(0, 12, 0, 0)
    autoTpLabel.BackgroundTransparency = 1
    autoTpLabel.Text = "Auto TP on Script Load"
    autoTpLabel.Font = Enum.Font.GothamBold
    autoTpLabel.TextSize = 13
    autoTpLabel.TextColor3 = Theme.TextPrimary
    autoTpLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoTpLabel.ZIndex = 36

    local autoTpToggleBg = Instance.new("Frame", autoTpRow)
    autoTpToggleBg.Size = UDim2.new(0, 56, 0, 28)
    autoTpToggleBg.Position = UDim2.new(1, -68, 0.5, -14)
    autoTpToggleBg.BackgroundColor3 = Config.TpOnLoad and Theme.Accent1 or Theme.SurfaceHighlight
    autoTpToggleBg.BorderSizePixel = 0
    autoTpToggleBg.ZIndex = 35
    Instance.new("UICorner", autoTpToggleBg).CornerRadius = UDim.new(1, 0)

    autoTpToggleKnob = Instance.new("Frame", autoTpToggleBg)
    autoTpToggleKnob.Size = UDim2.new(0, 24, 0, 24)
    autoTpToggleKnob.Position = Config.TpOnLoad and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
    autoTpToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    autoTpToggleKnob.BorderSizePixel = 0
    autoTpToggleKnob.ZIndex = 36
    Instance.new("UICorner", autoTpToggleKnob).CornerRadius = UDim.new(1, 0)

    local autoTpToggleButton = Instance.new("TextButton", autoTpToggleBg)
    autoTpToggleButton.Size = UDim2.new(1, 0, 1, 0)
    autoTpToggleButton.BackgroundTransparency = 1
    autoTpToggleButton.Text = ""
    autoTpToggleButton.ZIndex = 37

    -- Input de geração mínima
    local minGenInput = createInputRow(autoTpSection, "Min Gen for TP", "e.g. 5k, 1m, 1b", Config.MinGenForTp, nil, function(value)
        Config.MinGenForTp = value
    end)
    minGenInput.Position = UDim2.new(0, 0, 0, 46)

    -- Variáveis globais para o toggle (usadas na função executeAutoTpOnLoad)
    autoTpToggleBg = autoTpToggleBg
    autoTpToggleKnob = autoTpToggleKnob

    local function updateAutoTpToggle(state)
        Config.TpOnLoad = state
        local targetPos = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
        local targetColor = state and Theme.Accent1 or Theme.SurfaceHighlight
        TweenService:Create(autoTpToggleKnob, TweenInfo.new(0.15), {Position = targetPos}):Play()
        TweenService:Create(autoTpToggleBg, TweenInfo.new(0.15), {BackgroundColor3 = targetColor}):Play()
        
        if state then
            executeAutoTpOnLoad()
        end
    end

    autoTpToggleButton.MouseButton1Click:Connect(function()
        updateAutoTpToggle(not Config.TpOnLoad)
    end)

    local function updateOptionsCanvas()
        task.wait()
        optionsContainer.CanvasSize = UDim2.new(0, 0, 0, optionsLayout.AbsoluteContentSize.Y + 10)
    end
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateOptionsCanvas)
    task.defer(updateOptionsCanvas)

    -- ========== MENU AUTO STEAL (CANTO DIREITO) ==========
    local autoStealGui = Instance.new("ScreenGui")
    autoStealGui.Name = "AutoStealUI"
    autoStealGui.ResetOnSpawn = false
    autoStealGui.Parent = hudGui

    local autoFrame = Instance.new("Frame", autoStealGui)
    autoFrame.Name = "AutoStealFrame"
    autoFrame.Size = UDim2.new(0, 280, 0, 420)
    autoFrame.Position = UDim2.new(1, -295, 0.2, -210)
    autoFrame.BackgroundColor3 = Theme.Background
    autoFrame.BackgroundTransparency = 0.08
    autoFrame.BorderSizePixel = 0
    Instance.new("UICorner", autoFrame).CornerRadius = UDim.new(0, 12)

    local autoLED = Instance.new("UIStroke", autoFrame)
    autoLED.Color = Theme.Accent1
    autoLED.Thickness = 4
    autoLED.Transparency = 0.2
    autoLED.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

    task.spawn(function()
        while autoFrame and autoFrame.Parent do
            for t = 0, 1, 0.05 do
                if not autoFrame.Parent then break end
                local intensity = 0.2 + math.sin(t * math.pi * 2) * 0.2
                autoLED.Transparency = intensity
                task.wait(0.05)
            end
        end
    end)

    task.spawn(function()
        addRacetrackBorder(autoFrame, Theme.Accent1, 3.5)
    end)

    local autoTitle = Instance.new("TextLabel", autoFrame)
    autoTitle.Size = UDim2.new(1, 0, 0, 40)
    autoTitle.Position = UDim2.new(0, 0, 0, 0)
    autoTitle.BackgroundColor3 = Theme.Surface
    autoTitle.BackgroundTransparency = 0.15
    autoTitle.Text = "AUTO STEAL"
    autoTitle.Font = Enum.Font.GothamBlack
    autoTitle.TextSize = 16
    autoTitle.TextColor3 = Theme.Accent1
    autoTitle.TextXAlignment = Enum.TextXAlignment.Center
    Instance.new("UICorner", autoTitle).CornerRadius = UDim.new(0, 12)

    local autoDivider = Instance.new("Frame", autoFrame)
    autoDivider.Size = UDim2.new(1, -40, 0, 2)
    autoDivider.Position = UDim2.new(0, 20, 0, 40)
    autoDivider.BackgroundColor3 = Theme.Accent1
    autoDivider.BackgroundTransparency = 0.3
    autoDivider.BorderSizePixel = 0

    -- Botão TP manual
    local tpButton = Instance.new("TextButton", autoFrame)
    tpButton.Size = UDim2.new(1, -30, 0, 38)
    tpButton.Position = UDim2.new(0, 15, 0, 50)
    tpButton.BackgroundColor3 = Theme.Accent1
    tpButton.Text = "TP"
    tpButton.Font = Enum.Font.GothamBold
    tpButton.TextSize = 14
    tpButton.TextColor3 = Color3.fromRGB(0, 0, 0)
    tpButton.BorderSizePixel = 0
    tpButton.AutoButtonColor = false
    Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 8)
    
    local tpButtonStroke = Instance.new("UIStroke", tpButton)
    tpButtonStroke.Color = Theme.Accent2
    tpButtonStroke.Thickness = 1.5
    tpButtonStroke.Transparency = 0.2
    
    tpButton.MouseButton1Click:Connect(function()
        executeManualTp()
    end)
    
    tpButton.MouseEnter:Connect(function()
        TweenService:Create(tpButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.2}):Play()
    end)
    tpButton.MouseLeave:Connect(function()
        TweenService:Create(tpButton, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
    end)

    -- Target display (movido para baixo por causa do botão TP)
    local targetPanel = Instance.new("Frame", autoFrame)
    targetPanel.Size = UDim2.new(1, -30, 0, 55)
    targetPanel.Position = UDim2.new(0, 15, 0, 95)
    targetPanel.BackgroundColor3 = Theme.Surface
    targetPanel.BackgroundTransparency = 0.1
    targetPanel.BorderSizePixel = 0
    Instance.new("UICorner", targetPanel).CornerRadius = UDim.new(0, 8)

    local targetLabel = Instance.new("TextLabel", targetPanel)
    targetLabel.Size = UDim2.new(1, -10, 0, 18)
    targetLabel.Position = UDim2.new(0, 5, 0, 6)
    targetLabel.BackgroundTransparency = 1
    targetLabel.Text = "CURRENT TARGET"
    targetLabel.Font = Enum.Font.GothamBold
    targetLabel.TextSize = 9
    targetLabel.TextColor3 = Theme.TextSecondary
    targetLabel.TextXAlignment = Enum.TextXAlignment.Left

    targetValueLabel = Instance.new("TextLabel", targetPanel)
    targetValueLabel.Size = UDim2.new(1, -10, 0, 22)
    targetValueLabel.Position = UDim2.new(0, 5, 0, 26)
    targetValueLabel.BackgroundTransparency = 1
    targetValueLabel.Text = "Carregando..."
    targetValueLabel.Font = Enum.Font.GothamBlack
    targetValueLabel.TextSize = 11
    targetValueLabel.TextColor3 = Theme.Accent1
    targetValueLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetValueLabel.TextTruncate = Enum.TextTruncate.AtEnd

    -- Botões de modo (movidos para baixo)
    local modePanel = Instance.new("Frame", autoFrame)
    modePanel.Size = UDim2.new(1, -30, 0, 85)
    modePanel.Position = UDim2.new(0, 15, 0, 160)
    modePanel.BackgroundTransparency = 1

    local function createModeButton(text, yPos, isActive, callback)
        local btn = Instance.new("TextButton", modePanel)
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Position = UDim2.new(0, 0, 0, yPos)
        btn.BackgroundColor3 = isActive and Theme.Accent1 or Theme.Surface
        btn.BackgroundTransparency = 0.1
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = isActive and Color3.fromRGB(0, 0, 0) or Theme.TextPrimary
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = Theme.Accent1
        btnStroke.Thickness = 1
        btnStroke.Transparency = isActive and 0.2 or 0.6

        btn.MouseButton1Click:Connect(function()
            manualModeEnabled = false
            callback()
            for _, child in ipairs(modePanel:GetChildren()) do
                if child:IsA("TextButton") then
                    local isActiveBtn = (child == btn)
                    child.BackgroundColor3 = isActiveBtn and Theme.Accent1 or Theme.Surface
                    child.TextColor3 = isActiveBtn and Color3.fromRGB(0, 0, 0) or Theme.TextPrimary
                    local stroke = child:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Transparency = isActiveBtn and 0.2 or 0.6 end
                end
            end
            updateSelectionByMode()
        end)

        return btn
    end

    createModeButton("NEAREST", 0, stealNearestEnabled, function()
        stealNearestEnabled = true
        stealHighestEnabled = false
        Config.StealNearest = true
        Config.StealHighest = false
    end)

    createModeButton("HIGHEST", 40, stealHighestEnabled, function()
        stealNearestEnabled = false
        stealHighestEnabled = true
        Config.StealNearest = false
        Config.StealHighest = true
    end)

    local listLabel = Instance.new("TextLabel", autoFrame)
    listLabel.Size = UDim2.new(1, -30, 0, 18)
    listLabel.Position = UDim2.new(0, 15, 0, 253)
    listLabel.BackgroundTransparency = 1
    listLabel.Text = "AVAILABLE BRAINROTS"
    listLabel.Font = Enum.Font.GothamBold
    listLabel.TextSize = 9
    listLabel.TextColor3 = Theme.TextSecondary
    listLabel.TextXAlignment = Enum.TextXAlignment.Left

    listFrame = Instance.new("ScrollingFrame", autoFrame)
    listFrame.Size = UDim2.new(1, -30, 0, 105)
    listFrame.Position = UDim2.new(0, 15, 0, 273)
    listFrame.BackgroundColor3 = Theme.Surface
    listFrame.BackgroundTransparency = 0.1
    listFrame.BorderSizePixel = 0
    listFrame.ScrollBarThickness = 3
    listFrame.ScrollBarImageColor3 = Theme.Accent1
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 8)

    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.Padding = UDim.new(0, 3)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateBrainrotList()
        if not listFrame then return end
        
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child:Destroy()
            end
        end
        petButtons = {}
        
        local availablePets = {}
        for _, pet in ipairs(allAnimalsCache) do
            if pet.genValue >= 1 and not isMyBaseAnimal(pet) then
                table.insert(availablePets, pet)
            end
        end
        
        if #availablePets == 0 then
            if targetValueLabel then targetValueLabel.Text = "Nenhum" end
            return
        end
        
        table.sort(availablePets, function(a, b) return a.genValue > b.genValue end)
        
        for i, pet in ipairs(availablePets) do
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, -10, 0, 28)
            btn.BackgroundColor3 = Theme.SurfaceHighlight
            btn.BackgroundTransparency = 0.3
            btn.Text = ""
            btn.BorderSizePixel = 0
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)
            
            local selectStroke = Instance.new("UIStroke", btn)
            selectStroke.Name = "SelectStroke"
            selectStroke.Color = Theme.Accent2
            selectStroke.Thickness = 2.5
            selectStroke.Transparency = (selectedTargetIndex == i) and 0 or 1
            selectStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            
            local bar = Instance.new("Frame", btn)
            bar.Size = UDim2.new(0, 3, 1, -4)
            bar.Position = UDim2.new(0, 3, 0, 2)
            bar.BackgroundColor3 = (selectedTargetIndex == i) and Theme.Accent2 or Theme.Accent1
            bar.BorderSizePixel = 0
            Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)
            
            local rankLabel = Instance.new("TextLabel", btn)
            rankLabel.Size = UDim2.new(0, 22, 1, 0)
            rankLabel.Position = UDim2.new(0, 8, 0, 0)
            rankLabel.BackgroundTransparency = 1
            rankLabel.Text = "#" .. i
            rankLabel.Font = Enum.Font.GothamBlack
            rankLabel.TextSize = 9
            rankLabel.TextColor3 = (selectedTargetIndex == i) and Theme.Accent1 or Theme.TextSecondary
            rankLabel.TextXAlignment = Enum.TextXAlignment.Left
            
            local infoLabel = Instance.new("TextLabel", btn)
            infoLabel.Size = UDim2.new(1, -38, 1, 0)
            infoLabel.Position = UDim2.new(0, 32, 0, 0)
            infoLabel.BackgroundTransparency = 1
            infoLabel.RichText = true
            infoLabel.Text = formatMutationText(pet.mutation) .. pet.name .. " - " .. pet.genText
            infoLabel.Font = Enum.Font.GothamMedium
            infoLabel.TextSize = 9
            infoLabel.TextColor3 = (selectedTargetIndex == i) and Theme.TextPrimary or Theme.TextSecondary
            infoLabel.TextXAlignment = Enum.TextXAlignment.Left
            infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local btnData = {button = btn, rank = rankLabel, info = infoLabel, bar = bar, pet = pet, stroke = selectStroke}
            table.insert(petButtons, btnData)
            
            btn.MouseButton1Click:Connect(function()
                manualModeEnabled = true
                selectedTargetIndex = i
                selectedTargetUID = pet.uid
                if targetValueLabel then
                    targetValueLabel.Text = pet.name .. " (" .. pet.genText .. ")"
                end
                for idx, pb in ipairs(petButtons) do
                    local isSelected = (idx == selectedTargetIndex)
                    if pb.bar then
                        pb.bar.BackgroundColor3 = isSelected and Theme.Accent2 or Theme.Accent1
                    end
                    if pb.rank then
                        pb.rank.TextColor3 = isSelected and Theme.Accent1 or Theme.TextSecondary
                    end
                    if pb.info then
                        pb.info.TextColor3 = isSelected and Theme.TextPrimary or Theme.TextSecondary
                    end
                    if pb.stroke then
                        pb.stroke.Transparency = isSelected and 0 or 1
                    end
                end
            end)
        end
        
        if selectedTargetUID == nil and #petButtons > 0 then
            selectedTargetIndex = 1
            selectedTargetUID = petButtons[1].pet.uid
            if targetValueLabel then
                targetValueLabel.Text = petButtons[1].pet.name .. " (" .. petButtons[1].pet.genText .. ")"
            end
            if petButtons[1].bar then
                petButtons[1].bar.BackgroundColor3 = Theme.Accent2
                petButtons[1].rank.TextColor3 = Theme.Accent1
                if petButtons[1].stroke then petButtons[1].stroke.Transparency = 0 end
            end
        end
        
        task.wait()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end
    
    task.spawn(function()
        while true do
            task.wait(0.5)
            updateBrainrotList()
            if autoStealEnabled and #allAnimalsCache > 0 then
                updateSelectionByMode()
            end
        end
    end)
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        task.wait()
        if listFrame then
            listFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        end
    end)

    local menuOpen = false
    settingsButton.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        settingsMenu.Visible = menuOpen
        
        TweenService:Create(settingsButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.3}):Play()
        task.delay(0.1, function()
            TweenService:Create(settingsButton, TweenInfo.new(0.1), {BackgroundTransparency = 0.1}):Play()
        end)
    end)

    return hudGui
end

buildStatusHUD()
_G.rebuildStatusHUD = buildStatusHUD
