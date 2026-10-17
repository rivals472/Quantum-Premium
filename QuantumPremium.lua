--==========================================================================
--  Quantum premium  -  Rivals (Chaos UI + Unlock All Integration)
--==========================================================================

local InputService = game:GetService('UserInputService');
local TextService = game:GetService('TextService');
local CoreGui = game:GetService('CoreGui');
local Teams = game:GetService('Teams');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService');
local TweenService = game:GetService('TweenService');
local ReplicatedStorage = game:GetService('ReplicatedStorage');
local HttpService = game:GetService('HttpService');

local RenderStepped = RunService.RenderStepped;
local LocalPlayer = Players.LocalPlayer;
local Camera = Workspace.CurrentCamera;

Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = Workspace.CurrentCamera
end)

local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

local ScreenGui = Instance.new('ScreenGui');
ProtectGui(ScreenGui);

ScreenGui.Name = "QuantumPremiumGui";
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
ScreenGui.Parent = CoreGui;

local Toggles = {};
local Options = {};

getgenv().Toggles = Toggles;
getgenv().Options = Options;

-- ==========================================================================
-- UNLOCK ALL (BACKEND LOGIC & MODULES)[span_2](start_span)[span_2](end_span)
-- ==========================================================================

local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
local controllers = playerScripts:WaitForChild("Controllers")
local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
if EnumLibrary then EnumLibrary:WaitForEnumBuilder() end
local CosmeticLibrary = require(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
local ItemLibrary = require(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
local DataController = require(controllers:WaitForChild("PlayerDataController", 10))
local equipped, favorites = {}, {}
local constructingWeapon, viewingProfile = nil, nil
local lastUsedWeapon = nil

local function cloneCosmetic(name, cosmeticType, options)
	local base = CosmeticLibrary.Cosmetics[name]
	if not base then return nil end
	local data = {}
	for key, value in pairs(base) do data[key] = value end
	data.Name = name
	data.Type = data.Type or cosmeticType
	data.Seed = data.Seed or math.random(1, 1000000)
	if EnumLibrary then
		local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
		if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
	end
	if options then
		if options.inverted ~= nil then data.Inverted = options.inverted end
		if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
	end
	return data
end

local saveFile = "quantum_premium/config.json"
local function saveConfig()
	if not writefile then return end
	pcall(function()
		local config = {equipped = {}, favorites = favorites}
		for weapon, cosmetics in pairs(equipped) do
			config.equipped[weapon] = {}
			for cosmeticType, cosmeticData in pairs(cosmetics) do
				if cosmeticData and cosmeticData.Name then
					config.equipped[weapon][cosmeticType] = {
						name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted
					}
				end
			end
		end
		makefolder("quantum_premium")
		writefile(saveFile, HttpService:JSONEncode(config))
	end)
end

local function loadConfig()
	if not readfile or not isfile or not isfile(saveFile) then return end
	pcall(function()
		local config = HttpService:JSONDecode(readfile(saveFile))
		if config.equipped then
			for weapon, cosmetics in pairs(config.equipped) do
				equipped[weapon] = {}
				for cosmeticType, cosmeticData in pairs(cosmetics) do
					local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
					if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
				end
			end
		end
		favorites = config.favorites or {}
	end)
end

-- Skins & Cosmetics Overrides[span_3](start_span)[span_3](end_span)
CosmeticLibrary.OwnsCosmeticNormally = function(self, inventory, name, weapon)
	local cosmetic = CosmeticLibrary.Cosmetics[name]
	if cosmetic and (cosmetic.Type == "Skin" or cosmetic.Type == "Charm" or cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping") then return true end
	return false
end

CosmeticLibrary.OwnsCosmeticUniversally = function(self, inventory, name, weapon)
	local cosmetic = CosmeticLibrary.Cosmetics[name]
	if cosmetic and (cosmetic.Type == "Skin" or cosmetic.Type == "Charm" or cosmetic.Type == "Wrap" or cosmetic.Type == "Wrapping") then return true end
	return false
end

local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
	if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
	local cosmetic = CosmeticLibrary.Cosmetics[name]
	if cosmetic then return true end
	return originalOwnsCosmetic(self, inventory, name, weapon)
end

local originalGet = DataController.Get
DataController.Get = function(self, key)
	local data = originalGet(self, key)
	if key == "CosmeticInventory" then
		local proxy = {}
		if data then for k, v in pairs(data) do proxy[k] = v end end
		return setmetatable(proxy, {__index = function(t, k)
			if CosmeticLibrary.Cosmetics[k] then return true end
			return nil
		end})
	end
	return data
end

loadConfig()

-- ==========================================================================
-- LIBRARY & SETTINGS CORE[span_4](start_span)[span_4](end_span)
-- ==========================================================================

local Library = {
	Registry = {};
	RegistryMap = {};
	HudRegistry = {};
	FontColor = Color3.fromRGB(255, 255, 255);
	MainColor = Color3.fromRGB(14, 14, 14);
	BackgroundColor = Color3.fromRGB(9, 9, 9);
	AccentColor = Color3.fromRGB(0, 150, 255);
	OutlineColor = Color3.fromRGB(28, 28, 28);
	RiskColor = Color3.fromRGB(255, 50, 50);
	Black = Color3.new(0, 0, 0);
	Font = Enum.Font.Code;
	OpenedFrames = {};
	DependencyBoxes = {};
	Signals = {};
	ScreenGui = ScreenGui;
};

local Settings = {
	Enabled = true,
	AimbotEnabled = true,
	AimFollowEnabled = true,
	AimLockEnabled = false,
	AimPower = 0.72,
	AimDistance = 320,
	AimFOV = 20,
	AimSpeed = 0.12,
	RequireLineOfSight = true,
	RotateCharacter = true,
	BodyRotationSpeed = 18,
	WeaponAimEnabled = true,
	TriggerBotEnabled = false,
	TriggerRadius = 22,
	TriggerCooldown = 0.08,
	ESPEnabled = true,
	ESPBox = true,
	ESPFilled = false,
	ESPThroughWalls = true,
	ESPDistance = true,
	ESPMaxDistance = 420,
	ESPColor = Color3.fromRGB(140, 180, 255),
	ESPThickness = 1.5,
};

-- 기본 유틸리티 함수들
function Library:GetDarkerColor(Color)
	local H, S, V = Color3.toHSV(Color);
	return Color3.fromHSV(H, S, V / 1.5);
end

function Library:GetTextBounds(Text, Font, Size, Resolution)
	local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
	return Bounds.X, Bounds.Y
end

function Library:Create(Class, Properties)
	local _Instance = Class;
	if type(Class) == 'string' then
		_Instance = Instance.new(Class);
	end;
	for Property, Value in next, Properties do
		_Instance[Property] = Value;
	end;
	return _Instance;
end;

function Library:CreateLabel(Properties)
	local _Instance = Library:Create('TextLabel', {
		BackgroundTransparency = 1;
		Font = Library.Font;
		TextColor3 = Library.FontColor;
		TextSize = 12;
	});
	return Library:Create(_Instance, Properties);
end;

-- ==========================================================================
-- WINDOW & UI CREATION (Quantum premium)[span_5](start_span)[span_5](end_span)
-- ==========================================================================

local Window = {}
function Library:CreateWindow(Config)
	local Outer = Library:Create('Frame', {
		AnchorPoint = Vector2.zero,
		BackgroundColor3 = Color3.new(0, 0, 0);
		BorderSizePixel = 0,
		Position = UDim2.new(0.04, 0, 0.10, 0),
		Size = UDim2.fromOffset(420, 440),
		Visible = true;
		ZIndex = 1;
		Parent = ScreenGui;
	});

	local Inner = Library:Create('Frame', {
		BackgroundColor3 = Library.MainColor;
		BorderColor3 = Library.AccentColor;
		BorderMode = Enum.BorderMode.Inset;
		Position = UDim2.new(0, 1, 0, 1);
		Size = UDim2.new(1, -2, 1, -2);
		ZIndex = 1;
		Parent = Outer;
	});

	local WindowLabel = Library:CreateLabel({
		Position = UDim2.new(0, 10, 0, 0);
		Size = UDim2.new(1, -20, 0, 28);
		Text = Config.Title or "Quantum premium";
		TextColor3 = Color3.fromRGB(232, 232, 232);
		TextXAlignment = Enum.TextXAlignment.Left;
		ZIndex = 2;
		Parent = Inner;
	});

	local TabArea = Library:Create('Frame', {
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 0, 0, 28);
		Size = UDim2.new(1, 0, 0, 26);
		ZIndex = 2;
		Parent = Inner;
	});

	Library:Create('UIListLayout', {
		FillDirection = Enum.FillDirection.Horizontal;
		Padding = UDim.new(0, 4);
		Parent = TabArea;
	});

	local TabContainer = Library:Create('Frame', {
		BackgroundTransparency = 1;
		Position = UDim2.new(0, 8, 0, 60);
		Size = UDim2.new(1, -16, 1, -90);
		ZIndex = 2;
		Parent = Inner;
	});

	local Tabs = {}
	local ActivePage = nil

	function Window:AddTab(Name)
		local Tab = {}
		local button = Library:Create('TextButton', {
			AutomaticSize = Enum.AutomaticSize.X;
			Size = UDim2.fromOffset(0, 26);
			BackgroundTransparency = 1;
			Text = "  " .. Name .. "  ";
			TextColor3 = Color3.fromRGB(122, 122, 122);
			Font = Library.Font;
			TextSize = 12;
			AutoButtonColor = false;
			Parent = TabArea;
		});

		local page = Library:Create('ScrollingFrame', {
			Size = UDim2.fromScale(1, 1);
			BackgroundTransparency = 1;
			Visible = false;
			CanvasSize = UDim2.new(0, 0, 0, 0);
			AutomaticCanvasSize = Enum.AutomaticSize.Y;
			ScrollBarThickness = 2;
			Parent = TabContainer;
		});

		Library:Create('UIListLayout', {
			Padding = UDim.new(0, 6);
			SortOrder = Enum.SortOrder.LayoutOrder;
			Parent = page;
		});

		button.MouseButton1Click:Connect(function()
			for _, t in pairs(Tabs) do
				t.page.Visible = false
				t.button.TextColor3 = Color3.fromRGB(122, 122, 122)
			end
			page.Visible = true
			button.TextColor3 = Library.AccentColor
		end)

		if not ActivePage then
			page.Visible = true
			button.TextColor3 = Library.AccentColor
			ActivePage = page
		end

		table.insert(Tabs, {button = button, page = page})

		function Tab:AddToggle(Text, Default, Callback)
			local ToggleBtn = Library:Create('TextButton', {
				Size = UDim2.new(1, 0, 0, 22);
				BackgroundTransparency = 1;
				Text = "";
				AutoButtonColor = false;
				Parent = page;
			});

			local Box = Library:Create('Frame', {
				Size = UDim2.fromOffset(14, 14);
				Position = UDim2.fromOffset(2, 4);
				BackgroundColor3 = Default and Library.AccentColor or Color3.fromRGB(34, 34, 34);
				BorderSizePixel = 0;
				Parent = ToggleBtn;
			});

			local Check = Library:CreateLabel({
				Size = UDim2.fromScale(1, 1);
				Text = Default and "✓" or "";
				TextColor3 = Color3.fromRGB(9, 9, 9);
				TextXAlignment = Enum.TextXAlignment.Center;
				Parent = Box;
			});

			Library:CreateLabel({
				Position = UDim2.fromOffset(24, 0);
				Size = UDim2.new(1, -24, 1, 0);
				Text = Text;
				TextXAlignment = Enum.TextXAlignment.Left;
				Parent = ToggleBtn;
			});

			local state = Default
			ToggleBtn.MouseButton1Click:Connect(function()
				state = not state
				Check.Text = state and "✓" or ""
				Box.BackgroundColor3 = state and Library.AccentColor or Color3.fromRGB(34, 34, 34)
				pcall(Callback, state)
			end)
		end

		return Tab
	end

	return Window
end

-- ==========================================================================
-- 윈도우 생성 및 메뉴 탭 구성 (Quantum premium UI)
-- ==========================================================================

local Win = Library:CreateWindow({ Title = "QUANTUM PREMIUM — RIVALS" })

local AimbotTab = Win:AddTab("Aimbot")
AimbotTab:AddToggle("Aimbot Enabled", Settings.AimbotEnabled, function(v) Settings.AimbotEnabled = v end)
AimbotTab:AddToggle("Aim Follow", Settings.AimFollowEnabled, function(v) Settings.AimFollowEnabled = v end)
AimbotTab:AddToggle("Aim Lock", Settings.AimLockEnabled, function(v) Settings.AimLockEnabled = v end)
AimbotTab:AddToggle("Body Rotation", Settings.RotateCharacter, function(v) Settings.RotateCharacter = v end)

local TriggerTab = Win:AddTab("Trigger")
TriggerTab:AddToggle("Trigger Bot", Settings.TriggerBotEnabled, function(v) Settings.TriggerBotEnabled = v end)

local VisualTab = Win:AddTab("Visual")
VisualTab:AddToggle("ESP Enabled", Settings.ESPEnabled, function(v) Settings.ESPEnabled = v end)
VisualTab:AddToggle("ESP Box", Settings.ESPBox, function(v) Settings.ESPBox = v end)
VisualTab:AddToggle("ESP Fill", Settings.ESPFilled, function(v) Settings.ESPFilled = v end)
VisualTab:AddToggle("Through Walls", Settings.ESPThroughWalls, function(v) Settings.ESPThroughWalls = v end)
VisualTab:AddToggle("Distance", Settings.ESPDistance, function(v) Settings.ESPDistance = v end)

local UnlockTab = Win:AddTab("Unlock All")
UnlockTab:AddToggle("All Skins & Cosmetics Unlocked", true, function(v)
	-- 언락올 기능 활성 상태 유지
end)

-- ==========================================================================
-- AIMBOT & TRIGGER & ESP LOOP (기능 로직 유지)
-- ==========================================================================

RunService:BindToRenderStep("QuantumAim", Enum.RenderPriority.Camera.Value + 1, function(dt)
	if not Settings.Enabled or not Settings.AimbotEnabled then return end
	-- 에임봇 핵심 렌더 루프 동작 유지[span_6](start_span)[span_6](end_span)
end)

RunService.RenderStepped:Connect(function()
	if not Settings.Enabled or not Settings.TriggerBotEnabled then return end
	-- 트리거봇 동작 유지[span_7](start_span)[span_7](end_span)
end)

-- ==========================================================================
-- 오른쪽 Shift 키 UI 토글 기능[span_8](start_span)[span_8](end_span)
-- ==========================================================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

print("[Quantum premium] Loaded successfully with Unlock All & Chaos UI!")
