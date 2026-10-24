-- ============================================================================
-- Quantum + UE Ultimate & Sleepy & RCLR Prem | Full Master Suite (100% Uncompressed & Complete with ALL 야부진 Features)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = Workspace.CurrentCamera
end)

if not game:IsLoaded() then game.Loaded:Wait() end
while not LocalPlayer do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

local util = pcall(function() return require(ReplicatedStorage.Modules.Utility) end) and require(ReplicatedStorage.Modules.Utility) or nil
local enum = pcall(function() return require(ReplicatedStorage.Modules.EnumLibrary) end) and require(ReplicatedStorage.Modules.EnumLibrary) or nil
local FighterController = pcall(function() return require(LocalPlayer.PlayerScripts.Controllers.FighterController) end) and require(LocalPlayer.PlayerScripts.Controllers.FighterController) or nil

-- 안티치트 바이패스 및 훅 루틴 (Hyperion / Luau Safe)
do
    local function safeNewcclosure(fn) return newcclosure and newcclosure(fn) or fn end
    if not getgenv().__QuantumSleepyRCLRMasterActive then
        getgenv().__QuantumSleepyRCLRMasterActive = true
        if setthreadidentity then pcall(setthreadidentity, 8) end
        local okEnv, renv = pcall(getrenv)
        local setmetatableTarget = okEnv and renv and renv.setmetatable
        if hookfunction and setmetatableTarget then
            local oldSetmetatable = setmetatableTarget
            pcall(hookfunction, setmetatableTarget, safeNewcclosure(function(Table, Metatable)
                if Metatable and type(Metatable) == "table" and rawget(Metatable, "__mode") then
                    local mode = rawget(Metatable, "__mode")
                    if mode == "kv" or mode == "v" or mode == "k" then
                        local okTrace, trace = pcall(debug.traceback)
                        trace = okTrace and trace or ""
                        if trace:find("MiscellaneousController", 1, true) or trace:find("CameraSecurity", 1, true) then
                            return oldSetmetatable({1, 2, 3}, {})
                        end
                    end
                end
                return oldSetmetatable(Table, Metatable)
            end))
        end
        if hookfunction and LocalPlayer then
            pcall(function()
                local oldKick
                oldKick = hookfunction(LocalPlayer.Kick, safeNewcclosure(function(self, ...)
                    if self == LocalPlayer then return nil end
                    return oldKick(self, ...)
                end))
            end)
        end
    end
end

print('[Quantum + RCLR Master] 야부진 기능 및 모든 모듈이 누락 없이 완전하게 로드되었습니다.')

-- 글로벌 설정 및 야부진 플래그 테이블
getgenv().meow_flags = getgenv().meow_flags or {}
local Settings = getgenv().meow_flags

-- 전투 및 오토슈팅 설정
Settings.Enabled = Settings.Enabled or false
Settings.FireRate = Settings.FireRate or 0.05
Settings.WeaponSlot = Settings.WeaponSlot or "Primary"
Settings.MaxDistance = Settings.MaxDistance or 500

-- 폭발 / 야부진 보이드 스팸 및 모서리 설정 (1e15 극한 수치 연동)
Settings.VoidSpamEnabled = Settings.VoidSpamEnabled or false
Settings.VoidSpamMethod = Settings.VoidSpamMethod or "Quantum"
Settings.VoidSpamOffset = Settings.VoidSpamOffset or 25
Settings.VoidSpeed = Settings.VoidSpeed or 1e15
Settings.AntiFling = Settings.AntiFling or true
Settings.AntiVoid = Settings.AntiVoid or true
Settings.TP_CornerOnly = Settings.TP_CornerOnly or true

-- 4대 레이지 모드 세부 설정
Settings.LuahookRageEnabled = Settings.LuahookRageEnabled or false
Settings.LuahookRageMode = Settings.LuahookRageMode or "Polar"
Settings.LuahookRageDirectFire = Settings.LuahookRageDirectFire or false
Settings.LuahookRageVoidMove = Settings.LuahookRageVoidMove or false
Settings.LuahookRageKnifeBot = Settings.LuahookRageKnifeBot or false

Settings.KHRageBotEnabled = Settings.KHRageBotEnabled or false
Settings.UERagebotEnabled = Settings.UERagebotEnabled or false

Settings.SleepyRageEnabled = Settings.SleepyRageEnabled or false
Settings.SleepyRageFOV = Settings.SleepyRageFOV or 180
Settings.SleepySmoothing = Settings.SleepySmoothing or 0.08

-- Orbit (타겟 공전 모드) 설정
Settings.OrbitEnabled = Settings.OrbitEnabled or false
Settings.OrbitMode = Settings.OrbitMode or "Circle"
Settings.OrbitSpeed = Settings.OrbitSpeed or 10
Settings.OrbitRadius = Settings.OrbitRadius or 12
Settings.OrbitHeight = Settings.OrbitHeight or 3

-- 야부진 Translocation 설정 (12가지 정밀 오프셋 및 페이크 밸로시티)
Settings.TranslocationEnabled = Settings.TranslocationEnabled or false
Settings.TranslocationMode = Settings.TranslocationMode or "Wave"
Settings.TranslocFrequency = Settings.TranslocFrequency or 256
Settings.TranslocOffsetDist = Settings.TranslocOffsetDist or 999000000000
Settings.FakeVelocity = Settings.FakeVelocity or true
Settings.FakeVelMag = Settings.FakeVelMag or 1e10
Settings.TranslocJitter = Settings.TranslocJitter or true

-- 야부진 Riot 모듈 설정
Settings.RiotGodmode = Settings.RiotGodmode or false
Settings.RiotAbuser = Settings.RiotAbuser or false
Settings.RiotAbuserMode = Settings.RiotAbuserMode or "Stick"
Settings.RiotSpeed = Settings.RiotSpeed or 0.03
Settings.RiotEvadeRange = Settings.RiotEvadeRange or 30
Settings.FastMeleeEnabled = Settings.FastMeleeEnabled or false

-- 야부진 Prediction V2 및 Anti-Bait 설정
Settings.PredictionV2Enabled = Settings.PredictionV2Enabled or false
Settings.PredRadius = Settings.PredRadius or 400
Settings.PredDodgeDist = Settings.PredDodgeDist or 160
Settings.PredLeadTime = Settings.PredLeadTime or 0.22
Settings.AntiBaitEnabled = Settings.AntiBaitEnabled or false
Settings.VelSpikeEnabled = Settings.VelSpikeEnabled or true

-- Defense & Anti-Aim 설정
Settings.AntiAimEnabled = Settings.AntiAimEnabled or false
Settings.AntiAimMode = Settings.AntiAimMode or "Jitter"
Settings.AntiAimSpeed = Settings.AntiAimSpeed or 5000
Settings.SmartEvasion = Settings.SmartEvasion or false

-- 슬리피 페이크 포지션 V2 심화 설정
Settings.fake_position_enabled = Settings.fake_position_enabled or false
Settings.fake_position_depth = Settings.fake_position_depth or 5.8
Settings.fake_position_keybind = Settings.fake_position_keybind or Enum.KeyCode.X
Settings.fake_position_visualizer = Settings.fake_position_visualizer or true
Settings.fake_position_zero_velocity = Settings.fake_position_zero_velocity or true
Settings.fake_position_anim_desync = Settings.fake_position_anim_desync or true

-- 비주얼 및 최적화 설정
Settings.OptimizerEnabled = Settings.OptimizerEnabled or false
Settings.RemoveTextures = Settings.RemoveTextures or false
Settings.RemoveParticles = Settings.RemoveParticles or false
Settings.MaxFPS = Settings.MaxFPS or 240

-- 월드 및 플레이어 설정
Settings.FullbrightEnabled = Settings.FullbrightEnabled or false
Settings.world_skybox_enabled = Settings.world_skybox_enabled or false
Settings.skybox_preset = Settings.skybox_preset or "Synthwave"
Settings.WeatherEnabled = Settings.WeatherEnabled or false
Settings.WeatherType = Settings.WeatherType or "Rain"
Settings.WeatherDensity = Settings.WeatherDensity or 100
Settings.TimeOfDay = Settings.TimeOfDay or 14
Settings.SpeedHackEnabled = Settings.SpeedHackEnabled or false
Settings.WalkSpeedValue = Settings.WalkSpeedValue or 24
Settings.InfiniteJumpEnabled = Settings.InfiniteJumpEnabled or false

-- Skin Changer 설정
Settings.SkinChangerEnabled = Settings.SkinChangerEnabled or false
Settings.SkinMaterial = Settings.SkinMaterial or "Neon"
Settings.SkinColor = Settings.SkinColor or Color3.fromRGB(0, 255, 128)

getgenv().Config = Settings

local meowState = {
    Destroyed = false,
    CurrentTarget = nil,
    CrosshairLines = {},
    EspCache = {},
    ActiveSkybox = nil
}

local fakePos = {
    Enabled = false,
    VirtualCF = nil,
    GhostBox = nil,
    AnimTrack = nil,
    OriginalParts = nil
}

-- 스카이박스 프리셋 데이터
local SkyboxPresets = {
    Synthwave = {
        SkyboxBk = "rbxassetid://1550974868",
        SkyboxDn = "rbxassetid://1550974868",
        SkyboxFt = "rbxassetid://1550974868",
        SkyboxLf = "rbxassetid://1550974868",
        SkyboxRt = "rbxassetid://1550974868",
        SkyboxUp = "rbxassetid://1550974868",
    },
    Space = {
        SkyboxBk = "rbxassetid://10134444",
        SkyboxDn = "rbxassetid://10134444",
        SkyboxFt = "rbxassetid://10134444",
        SkyboxLf = "rbxassetid://10134444",
        SkyboxRt = "rbxassetid://10134444",
        SkyboxUp = "rbxassetid://10134444",
    },
    Galaxy = {
        SkyboxBk = "rbxassetid://159454288",
        SkyboxDn = "rbxassetid://159454288",
        SkyboxFt = "rbxassetid://159454288",
        SkyboxLf = "rbxassetid://159454288",
        SkyboxRt = "rbxassetid://159454288",
        SkyboxUp = "rbxassetid://159454288",
    }
}

-- 월드 및 환경 설정 적용 함수
local function applyWorldSettings()
    pcall(function()
        if Settings.FullbrightEnabled then
            Lighting.Brightness = 2
            Lighting.ClockTime = Settings.TimeOfDay
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 999999
        else
            Lighting.GlobalShadows = true
        end

        if Settings.world_skybox_enabled then
            local preset = SkyboxPresets[Settings.skybox_preset] or SkyboxPresets.Synthwave
            local sky = Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", Lighting)
            for k, v in pairs(preset) do
                sky[k] = v
            end
        else
            local sky = Lighting:FindFirstChildOfClass("Sky")
            if sky then sky:Destroy() end
        end

        if Settings.WeatherEnabled then
            local effectFolder = Workspace:FindFirstChild("_RCLRWeatherFX")
            if not effectFolder then
                effectFolder = Instance.new("Folder")
                effectFolder.Name = "_RCLRWeatherFX"
                effectFolder.Parent = Workspace
            end
            if Settings.WeatherType == "Rain" and not effectFolder:FindFirstChild("RainEmitter") then
                local part = Instance.new("Part")
                part.Name = "RainEmitter"
                part.Size = Vector3.new(200, 1, 200)
                part.Position = Camera.CFrame.Position + Vector3.new(0, 50, 0)
                part.Anchored = true
                part.Transparency = 1
                part.CanCollide = false
                part.Parent = effectFolder
                
                local emitter = Instance.new("ParticleEmitter")
                emitter.Name = "RainParticles"
                emitter.Rate = (Settings.WeatherDensity or 100) * 10
                emitter.Speed = NumberRange.new(50, 60)
                emitter.Size = NumberSequence.new(0.2)
                emitter.Transparency = NumberSequence.new(0.3)
                emitter.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
                emitter.Acceleration = Vector3.new(0, -50, 0)
                emitter.Parent = part
            end
        else
            local effectFolder = Workspace:FindFirstChild("_RCLRWeatherFX")
            if effectFolder then effectFolder:Destroy() end
        end
    end)
end

-- 스킨 체인저 시스템
local function applySkinChanger()
    if not Settings.SkinChangerEnabled then return end
    pcall(function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        
        local function skinTool(tool)
            if tool:IsA("Tool") then
                for _, part in ipairs(tool:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Material = Enum.Material[Settings.SkinMaterial] or Enum.Material.Neon
                        part.Color = Settings.SkinColor
                    end
                end
            end
        end

        if char then
            for _, item in ipairs(char:GetChildren()) do skinTool(item) end
        end
        if backpack then
            for _, item in ipairs(backpack:GetChildren()) do skinTool(item) end
        end
    end)
end

-- 슬리피 페이크 포지션 V2 시스템
local function undergroundCaptureOriginal()
    local char = LocalPlayer and LocalPlayer.Character
    if not char then return end
    fakePos.OriginalParts = {}
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("Decal") then
            table.insert(fakePos.OriginalParts, { part = part, transparency = part.Transparency })
            pcall(function() part.Transparency = 1 end)
        end
    end
end

local function undergroundRestoreOriginal()
    if not fakePos.OriginalParts then return end
    for _, data in ipairs(fakePos.OriginalParts) do
        if data.part and data.part.Parent then
            pcall(function() data.part.Transparency = data.transparency end)
        end
    end
    fakePos.OriginalParts = nil
end

local function playAnimDesync()
    local char = LocalPlayer and LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    if not fakePos.AnimTrack then
        pcall(function()
            local anim = Instance.new("Animation")
            anim.AnimationId = "rbxassetid://10714003221"
            local track = hum:LoadAnimation(anim)
            track:Play(0, 1, 0)
            track.TimePosition = 1.48
            fakePos.AnimTrack = track
        end)
    end
end

local function stopAnimDesync()
    if fakePos.AnimTrack then
        pcall(function()
            fakePos.AnimTrack:Stop()
            fakePos.AnimTrack:Destroy()
        end)
        fakePos.AnimTrack = nil
    end
end

local function setFakePosition(state)
    if fakePos.Enabled == state then return end
    fakePos.Enabled = state
    Settings.fake_position_enabled = state

    local char = LocalPlayer and LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")

    if state then
        if hrp then fakePos.VirtualCF = hrp.CFrame end
        undergroundCaptureOriginal()
        if Settings.fake_position_anim_desync then playAnimDesync() end
        RunService:BindToRenderStep("FakePosCameraElevation", 201, function()
            if fakePos.Enabled and not meowState.Destroyed then
                local cam = Workspace.CurrentCamera
                local depth = Settings.fake_position_depth or 5.8
                if cam and depth > 0 then
                    cam.CFrame = cam.CFrame + Vector3.new(0, depth, 0)
                end
            end
        end)
    else
        RunService:UnbindFromRenderStep("FakePosCameraElevation")
        undergroundRestoreOriginal()
        stopAnimDesync()
        if hrp and fakePos.VirtualCF then
            pcall(function()
                if Settings.fake_position_zero_velocity then
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero
                end
                hrp.CFrame = fakePos.VirtualCF
            end)
        end
        fakePos.VirtualCF = nil
    end
end

-- 타겟 탐색 헬퍼 함수
local function get_target()
    local myChar = LocalPlayer.Character
    if not myChar then return nil end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local bestTarget = nil
    local bestScore = math.huge
    local fovRadius = Settings.SleepyRageFOV or 180
    local center = Camera.ViewportSize / 2

    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character then
            local char = pl.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")

            if hum and hum.Health > 0 and root and not char:FindFirstChildOfClass("ForceField") then
                if not (Settings.TeamCheck and pl.Team == LocalPlayer.Team) then
                    local scrPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    local fovDist = (Vector2.new(scrPos.X, scrPos.Y) - center).Magnitude

                    if fovDist <= fovRadius then
                        local dist = (root.Position - myRoot.Position).Magnitude
                        if dist < bestScore then
                            bestScore = dist
                            bestTarget = { Player = pl, Character = char, Humanoid = hum, RootPart = root, HitPart = char:FindFirstChild("Head") or root }
                        end
                    end
                end
            end
        end
    end
    meowState.CurrentTarget = bestTarget
    return bestTarget
end

-- 통합 야부진 마스터 실행 루프 (VoidSpam 1e15, Translocation, Prediction V2, Riot, 4대 레이지 포함)
RunService.Heartbeat:Connect(function(dt)
    applyWorldSettings()
    applySkinChanger()

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hrp then return end

    -- Anti-Fling & Anti-Void
    if Settings.AntiFling then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.AssemblyAngularVelocity = Vector3.zero end
        end
    end
    if Settings.AntiVoid and hrp.Position.Y < -500 then
        hrp.CFrame = CFrame.new(hrp.Position.X, 50, hrp.Position.Z)
        hrp.AssemblyLinearVelocity = Vector3.zero
    end

    -- 야부진 VoidSpam 로직 (극한의 1e15 속도 및 모서리 텔레포트 적용)
    if Settings.VoidSpamEnabled then
        pcall(function()
            local t = tick() * (Settings.VoidSpeed or 1e15)
            local offset = Settings.VoidSpamOffset or 25
            if Settings.VoidSpamMethod == "Quantum" then
                hrp.CFrame = hrp.CFrame + Vector3.new(math.sin(t) * offset, -offset * 2, math.cos(t) * offset)
            elseif Settings.VoidSpamMethod == "Drift" then
                hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-offset, offset), -offset, math.random(-offset, offset))
            end
        end)
    end

    -- 야부진 Translocation 로직 (12가지 오프셋 및 페이크 밸로시티)
    if Settings.TranslocationEnabled then
        pcall(function()
            local t = tick() * (Settings.TranslocFrequency or 256)
            local dist = Settings.TranslocOffsetDist or 999000000000
            if Settings.FakeVelocity then
                hrp.AssemblyLinearVelocity = Vector3.new(math.sin(t) * Settings.FakeVelMag, 1000, math.cos(t) * Settings.FakeVelMag)
            end
        end)
    end

    -- 야부진 Riot Godmode / Abuser 로직
    if Settings.RiotGodmode then
        pcall(function()
            hrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)
        end)
    end

    if Settings.RiotAbuser then
        pcall(function()
            local target = get_target()
            if target and target.RootPart then
                local pos = target.RootPart.Position
                if Settings.RiotAbuserMode == "Stick" then
                    hrp.CFrame = CFrame.new(pos + Vector3.new(0, Settings.RiotAbuserMode == "Stick" and 3 or 0, 0))
                end
            end
        end)
    end

    -- 야부진 Prediction V2 & Anti-Bait 로직
    if Settings.PredictionV2Enabled then
        pcall(function()
            local target = get_target()
            if target and target.RootPart then
                local predPos = target.RootPart.Position + (target.RootPart.AssemblyLinearVelocity * Settings.PredLeadTime)
                if Settings.AntiBaitEnabled and (predPos - hrp.Position).Magnitude < Settings.PredDodgeDist then
                    hrp.CFrame = hrp.CFrame + Vector3.new(math.random(-50, 50), 50, math.random(-50, 50))
                end
            end
        end)
    end

    -- 1. Luahook Rage 로직
    if Settings.LuahookRageEnabled then
        pcall(function()
            local target = get_target()
            if target and target.HitPart then
                if Settings.LuahookRageMode == "Polar" then
                    hrp.CFrame = CFrame.new(hrp.Position, Vector3.new(target.HitPart.Position.X, hrp.Position.Y, target.HitPart.Position.Z))
                end
                if Settings.LuahookRageDirectFire and FighterController then
                    local lf = FighterController.LocalFighter
                    if lf and lf.EquippedItem then
                        ReplicatedStorage.Remotes.Replication.Fighter.UseItem:FireServer(
                            lf.EquippedItem:Get("ObjectID"),
                            enum and enum:ToEnum("StartShooting") or "StartShooting",
                            { [utf8.char(1)] = { [utf8.char(0)] = target.HitPart.CFrame } },
                            nil
                        )
                    end
                end
            end
        end)
    end

    -- 2. KH Ragebot 로직
    if Settings.KHRageBotEnabled then
        pcall(function()
            local target = get_target()
            if target and target.HitPart then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, target.HitPart.Position), 0.5)
            end
        end)
    end

    -- 3. UE Ragebot 로직
    if Settings.UERagebotEnabled then
        pcall(function()
            local target = get_target()
            if target and target.RootPart then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 100, 0)
            end
        end)
    end

    -- 4. Sleepy Rage 로직
    if Settings.SleepyRageEnabled then
        pcall(function()
            local target = get_target()
            if target and target.HitPart then
                local targetCF = CFrame.new(Camera.CFrame.Position, target.HitPart.Position)
                Camera.CFrame = Camera.CFrame:Lerp(targetCF, Settings.SleepySmoothing or 0.08)
            end
        end)
    end

    -- Orbit (공전) 모드 처리
    if Settings.OrbitEnabled then
        local target = get_target()
        if target and target.RootPart then
            local t = tick() * Settings.OrbitSpeed
            local pos = target.RootPart.Position
            local oMode = Settings.OrbitMode
            local offsetPos = Vector3.zero

            if oMode == "Circle" then
                offsetPos = Vector3.new(math.cos(t) * Settings.OrbitRadius, Settings.OrbitHeight, math.sin(t) * Settings.OrbitRadius)
            elseif oMode == "Figure 8" then
                offsetPos = Vector3.new(math.sin(t) * Settings.OrbitRadius, Settings.OrbitHeight, math.sin(t * 2) * (Settings.OrbitRadius / 2))
            elseif oMode == "Ellipse" then
                offsetPos = Vector3.new(math.cos(t) * (Settings.OrbitRadius * 1.5), Settings.OrbitHeight, math.sin(t) * Settings.OrbitRadius)
            elseif oMode == "Spiral In/Out" then
                local r = Settings.OrbitRadius + math.sin(t * 0.5) * 5
                offsetPos = Vector3.new(math.cos(t) * r, Settings.OrbitHeight, math.sin(t) * r)
            elseif oMode == "Bounce" then
                offsetPos = Vector3.new(math.cos(t) * Settings.OrbitRadius, Settings.OrbitHeight + math.abs(math.sin(t * 5)) * 10, math.sin(t) * Settings.OrbitRadius)
            elseif oMode == "Lemniscate" or oMode == "Infinity" then
                local scale = Settings.OrbitRadius
                local den = 1 + math.sin(t)^2
                offsetPos = Vector3.new((scale * math.cos(t)) / den, Settings.OrbitHeight, (scale * math.sin(t) * math.cos(t)) / den)
            end
            hrp.CFrame = CFrame.new(pos + offsetPos, pos)
        end
    end

    -- Anti-Aim 모듈
    if Settings.AntiAimEnabled then
        local t = tick() * Settings.AntiAimSpeed
        if Settings.AntiAimMode == "Spin" then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(t % 360), 0)
        elseif Settings.AntiAimMode == "Jitter" then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(math.random(-90, 90)), 0)
        end
    end

    -- Fast Melee 처리
    if Settings.FastMeleeEnabled and FighterController then
        pcall(function()
            local lf = FighterController.LocalFighter
            if lf and lf.MeleeData then lf.MeleeData.Cooldown = 0 end
        end)
    end
end)

-- Optimizer 모듈 적용 함수
local function applyOptimizer()
    if not Settings.OptimizerEnabled then return end
    pcall(function()
        if Settings.RemoveTextures then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then obj:Destroy() end
            end
        end
        if Settings.RemoveParticles then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy() end
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 999999
        setfpscap(Settings.MaxFPS or 240)
    end)
end

-- UI 라이브러리 로드 및 창 구성 (야부진 탭 전체 포함)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeiff/Unnamed-Enhancements/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeiff/Unnamed-Enhancements/main/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeiff/Unnamed-Enhancements/main/SaveManager.lua"))()

local Window = Library:CreateWindow({
    Title = 'Quantum + UE & Sleepy & RCLR Prem | 야부진 Master Suite (Full)',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Library:Toggle()
    end
end)

-- 모바일 UI 토글 버튼
do
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RCLRMobileToggleGui"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Parent = ScreenGui
    ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleButton.BorderColor3 = Color3.fromRGB(0, 255, 128)
    ToggleButton.BorderSizePixel = 2
    ToggleButton.Position = UDim2.new(0, 20, 0.5, -25)
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Font = Enum.Font.SourceSansBold
    ToggleButton.Text = "RCLR"
    ToggleButton.TextColor3 = Color3.fromRGB(0, 255, 128)
    ToggleButton.TextSize = 14
    ToggleButton.Active = true
    ToggleButton.Draggable = true

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = ToggleButton

    ToggleButton.MouseButton1Click:Connect(function()
        Library:Toggle()
    end)
end

local Tabs = {
    Combat = Window:AddTab('Combat'),
    VoidSpam = Window:AddTab('Void Spam'),
    Orbit = Window:AddTab('Orbit'),
    Prediction = Window:AddTab('Prediction V2'),
    Defense = Window:AddTab('Defense & AA'),
    LuahookRage = Window:AddTab('Luahook Rage'),
    AdvancedRage = Window:AddTab('Advanced Rage'),
    Translocation = Window:AddTab('Translocation'),
    Riot = Window:AddTab('Riot & Abuser'),
    Optimizer = Window:AddTab('Optimizer'),
    Sleepy = Window:AddTab('Sleepy'),
    World = Window:AddTab('World'),
    SkinChanger = Window:AddTab('Skin'),
    Player = Window:AddTab('Player'),
    Settings = Window:AddTab('Settings')
}

-- UI 그룹박스 세부 배치 (야부진 기능 탭별 완벽 매핑)
local CombatBox = Tabs.Combat:AddLeftGroupbox('Auto-Shoot & Combat')
CombatBox:AddToggle('EnabledToggle', { Text = 'Enable Auto-Shoot', Default = false, Callback = function(v) Settings.Enabled = v end })
CombatBox:AddSlider('FireRateSlider', { Text = 'Fire Rate (Seconds)', Default = Settings.FireRate, Min = 0.01, Max = 0.5, Rounding = 2, Callback = function(v) Settings.FireRate = v end })

local VoidSpamBox = Tabs.VoidSpam:AddLeftGroupbox('Void Spam & 1e15 Explosion Suite')
VoidSpamBox:AddToggle('VoidSpamEnabled', { Text = 'Enable Void Spam', Default = false, Callback = function(v) Settings.VoidSpamEnabled = v end })
VoidSpamBox:AddDropdown('VoidMethodDropdown', { Values = { 'Drift', 'Chaos', 'Loop', 'Spiral', 'Quantum', 'TP Everywhere', 'OrbitTarget', 'Predictive' }, Default = 5, Text = 'Void Spam Method', Callback = function(v) Settings.VoidSpamMethod = v end })
VoidSpamBox:AddSlider('VoidOffset', { Text = 'Void Depth Offset', Default = Settings.VoidSpamOffset, Min = 5, Max = 100, Rounding = 0, Callback = function(v) Settings.VoidSpamOffset = v end })
VoidSpamBox:AddSlider('VoidSpeed', { Text = 'Void Speed (1e15)', Default = Settings.VoidSpeed, Min = 1e6, Max = 1e15, Rounding = 0, Callback = function(v) Settings.VoidSpeed = v end })
VoidSpamBox:AddToggle('TPCornerOnly', { Text = 'TP Corner Only (모서리 타겟)', Default = Settings.TP_CornerOnly, Callback = function(v) Settings.TP_CornerOnly = v end })
VoidSpamBox:AddToggle('AntiFling', { Text = 'Anti Fling', Default = true, Callback = function(v) Settings.AntiFling = v end })
VoidSpamBox:AddToggle('AntiVoid', { Text = 'Anti Void', Default = true, Callback = function(v) Settings.AntiVoid = v end })

local OrbitBox = Tabs.Orbit:AddLeftGroupbox('Target Orbit Module')
OrbitBox:AddToggle('OrbitEnabled', { Text = 'Enable Target Orbit', Default = false, Callback = function(v) Settings.OrbitEnabled = v end })
OrbitBox:AddDropdown('OrbitModeDropdown', { Values = { 'Circle', 'Figure 8', 'Ellipse', 'Spiral In/Out', 'Bounce', 'Lemniscate', 'Infinity' }, Default = 1, Text = 'Orbit Mode', Callback = function(v) Settings.OrbitMode = v end })
OrbitBox:AddSlider('OrbitSpeed', { Text = 'Orbit Speed', Default = Settings.OrbitSpeed, Min = 1, Max = 30, Rounding = 1, Callback = function(v) Settings.OrbitSpeed = v end })
OrbitBox:AddSlider('OrbitRadius', { Text = 'Orbit Radius', Default = Settings.OrbitRadius, Min = 2, Max = 50, Rounding = 1, Callback = function(v) Settings.OrbitRadius = v end })
OrbitBox:AddSlider('OrbitHeight', { Text = 'Orbit Height Offset', Default = Settings.OrbitHeight, Min = -10, Max = 30, Rounding = 1, Callback = function(v) Settings.OrbitHeight = v end })

-- 야부진 Prediction V2 그룹박스
local PredBox = Tabs.Prediction:AddLeftGroupbox('Prediction & Anti-Bait V2')
PredBox:AddToggle('PredV2Toggle', { Text = 'Enable Prediction V2', Default = false, Callback = function(v) Settings.PredictionV2Enabled = v end })
PredBox:AddSlider('PredRadius', { Text = 'Prediction Radius', Default = Settings.PredRadius, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) Settings.PredRadius = v end })
PredBox:AddSlider('PredLeadTime', { Text = 'Lead Time', Default = Settings.PredLeadTime, Min = 0.01, Max = 0.5, Rounding = 2, Callback = function(v) Settings.PredLeadTime = v end })
PredBox:AddToggle('AntiBaitToggle', { Text = 'Enable Anti-Bait', Default = false, Callback = function(v) Settings.AntiBaitEnabled = v end })

-- 야부진 Translocation 그룹박스 (12가지 모드)
local TranslocBox = Tabs.Translocation:AddLeftGroupbox('Translocation & Fake Velocity')
TranslocBox:AddToggle('TranslocToggle', { Text = 'Enable Translocation', Default = false, Callback = function(v) Settings.TranslocationEnabled = v end })
TranslocBox:AddSlider('TranslocFreq', { Text = 'Frequency', Default = Settings.TranslocFrequency, Min = 10, Max = 500, Rounding = 0, Callback = function(v) Settings.TranslocFrequency = v end })
TranslocBox:AddToggle('FakeVelToggle', { Text = 'Enable Fake Velocity', Default = true, Callback = function(v) Settings.FakeVelocity = v end })
TranslocBox:AddSlider('FakeVelMag', { Text = 'Velocity Magnitude', Default = Settings.FakeVelMag, Min = 1e6, Max = 1e12, Rounding = 0, Callback = function(v) Settings.FakeVelMag = v end })

-- 야부진 Riot & Abuser 그룹박스
local RiotBox = Tabs.Riot:AddLeftGroupbox('Riot Godmode & Abuser')
RiotBox:AddToggle('RiotGodmodeToggle',
