--<>----<>----<>----<>----<>----<>----<>--
repeat wait() until game:IsLoaded() wait()
    game:GetService("Players").LocalPlayer.Idled:connect(function()
    game:GetService("VirtualUser"):ClickButton2(Vector2.new());
end);
--<>----<>----<>----<>----<>----<>----<>--
local Library = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Drifter0507/Shamrock/main/MainLibrary", true))();
--<>----<>----<>----<>----<>----<>----<>--
pcall(function()
    for i, v in pairs(getconnections(game:GetService("ScriptContext").Error)) do
        v:Disable();
    end;
end);
--<>----<>----<>----<>----<>----<>----<>--

--<>----<>----<>----<>----<>----<>----<>--
local Workspace = game:GetService('Workspace');
local ReplicatedStorage = game:GetService('ReplicatedStorage');
local Players = game:GetService('Players');
local RunService = game:GetService('RunService');
local Workspace = game:GetService("Workspace");
local Lighting = game:GetService("Lighting");
local UIS = game:GetService("UserInputService");
local Teams = game:GetService("Teams");
local ScriptContext = game:GetService("ScriptContext");
local CoreGui = game:GetService("CoreGui");
local Camera = Workspace.CurrentCamera;
--<>----<>----<>----<>----<>----<>----<>--
local Client = Players.LocalPlayer;
local Character = nil;
local RootPart = nil;
local Humanoid = nil;
local Mouse = Client:GetMouse();
local States = Client:FindFirstChild('States');
local Stats = Client:FindFirstChild('Stats');
getgenv().WS = 16
function SetCharVars()
	Character = Client.Character;
	Humanoid = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid");
	RootPart = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart");
	if getgenv().WS then
		Humanoid.WalkSpeed = getgenv().WS;
	end
	Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if getgenv().WS then
			Humanoid.WalkSpeed = getgenv().WS;
		end
	end)
end
SetCharVars();
Client.CharacterAdded:Connect(SetCharVars);


--<>----<>----<>----<>----<>----<>----<>--
local GeneralEvents = ReplicatedStorage:FindFirstChild('GeneralEvents');
local RobRemote = GeneralEvents:FindFirstChild('Rob');
local ChangeCharacter = Character:FindFirstChild('ChangeCharacter');
local LassoEvent = GeneralEvents:FindFirstChild('LassoEvents');
local Chests = Workspace:FindFirstChild('ChestFolder');
local Lassod = States:FindFirstChild('Lassod');
local Hogtied = States:FindFirstChild('Hogtied');
local BagLevel = Stats:FindFirstChild('BagSizeLevel'):FindFirstChild('CurrentAmount');
local BagAmount = States:FindFirstChild('Bag');
--<>----<>----<>----<>----<>----<>----<>--
local Camp = CFrame.new(1636.62537, 104.349976, -1736.184)
--<>----<>----<>----<>----<>----<>----<>--
coroutine.wrap(function()
	while true do
		if not table.find(getgenv().Whitelisted,Client.Name) then
			table.insert(getgenv().Whitelisted,Client.Name);
		end;
		wait(5);
	end;
end)();
--<>----<>----<>----<>----<>----<>----<>--
local Old;
Old = hookmetamethod(game, "__index", function(self, Value)
    if tostring(self) == "Humanoid" and tostring(Value) == "WalkSpeed" then
        return 16;
    end;
    return Old(self, Value);
end);
--<>----<>----<>----<>----<>----<>----<>--
local target;

local block = Instance.new("Part",workspace);
block.Anchored = true;
block.Size = Vector3.new(5,5,5);

local parameters = RaycastParams.new();
parameters.FilterDescendantsInstances = {workspace.Horses};
parameters.FilterType = Enum.RaycastFilterType.Blacklist;

function RayCheck(_hrp)
	local A,B = Camera.CFrame.Position,_hrp.Position;
	block.Position = _hrp.Position;
	local raycast = workspace:Raycast(A,B - A,parameters);
	if raycast and raycast.Instance == block then
		return true;
	end;
	return false;
end;

function TeamCheck(Client,player)
	if Client.Team == Teams.Cowboys and player.Team == Teams.Cowboys then
		return false;
	end;
	return true;
end;

function GetTarget(hrp)
	local targets = {}
	for _,player in ipairs(Players:GetPlayers()) do
		pcall(function()
			local character = player.Character;
			local _hrp = character.HumanoidRootPart;
			if character.Humanoid.Health > 0 and not character:FindFirstChildOfClass("ForceField") and not table.find(getgenv().Whitelisted,player.Name) and TeamCheck(Client,player) and RayCheck(_hrp) then
				local _,visible = Camera:WorldToScreenPoint(_hrp.Position);
				if visible then
					table.insert(targets,{
						HRP = _hrp,
						Magnitude = (_hrp.Position - hrp.Position).Magnitude
					});
				end;
			end;
		end);
	end;
	table.sort(targets,function(A,B)
		return A.Magnitude < B.Magnitude;
	end)
	block.Position = Vector3.new(0,0,0);
	if targets[1] then
		return targets[1].HRP;
	end;
end;

local oldNewIndex
oldNewIndex = hookmetamethod(game,"__newindex",newcclosure(function(self,key,value)
	if target and self:IsA("Camera") and (key == "CFrame" or key == "CoordinateFrame")  then
		local head = Client.Character.Head;
		value = CFrame.new(head.CFrame:PointToWorldSpace(Vector3.new(2,3,8)),target.Position);
	end;
	return oldNewIndex(self,key,value);
end));

function InputBegan(input)
	local character = Client.Character;
	if character and input.UserInputType == Enum.UserInputType.MouseButton2 and getgenv().Aimbot then
		local tool = character:FindFirstChildOfClass("Tool");
		if tool and tool:FindFirstChild("GunType") then
			target = GetTarget(character.HumanoidRootPart);
		end;
	end;
end;

function InputEnded(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 and target then
		target = nil;
	end;
end;

UIS.InputBegan:Connect(InputBegan);
UIS.InputEnded:Connect(InputEnded);

RunService.Heartbeat:Connect(function()
	if target then
		Camera.CFrame = "";
	end;
end);

function HumanoidWatch(character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.HealthChanged:Connect(function(value)
		if (value == 0 and target and target:IsDescendantOf(character)) or (value == 0 and character == Client.Character) then
			target = nil;
		end;
	end);
end;

function CharacterWatch(player)
	player.CharacterAdded:Connect(function(character)
		table.insert(parameters.FilterDescendantsInstances,character);
		HumanoidWatch(character);
	end);
	player.CharacterRemoving:Connect(function(character)
		table.remove(parameters.FilterDescendantsInstances,table.find(parameters.FilterDescendantsInstances,character));
	end);
end;

Players.PlayerAdded:Connect(CharacterWatch);

for _,player in ipairs(Players:GetPlayers()) do
	if player.Character then
		table.insert(parameters.FilterDescendantsInstances,player.Character);
		HumanoidWatch(player.Character);
	end;
	CharacterWatch(player);
end;
--<>----<>----<>----<>----<>----<>----<>--

local Window = Library:CreateWindow({Title = "Westbound"});
local tab1 = Window:CreateTab({Title = "Main", ScrollBar = false});

--<>----<>----<>----<>----<>----<>----<>--

local CombatSection = tab1:CreateSection({
	Title = "Combat",
	Order = 1
});
--<>----<>----<>----<>----<>----<>----<>--
local ClientSection = tab1:CreateSection({
	Title = "Client",
	Order = 2
});
--<>----<>----<>----<>----<>----<>----<>--
local EconomySection = tab1:CreateSection({
	Title = "Economy",
	Order = 4
});
--<>----<>----<>----<>----<>----<>----<>--
local VisualSection = tab1:CreateSection({
	Title = "Visuals",
	Order = 3
});
--<>----<>----<>----<>----<>----<>----<>--

CombatSection:CreateToggle({
	Title = "Aimbot",
	Order = 1,
	Default = false,
	Callback = function(state)
		getgenv().Aimbot = state;
		if not getgenv().Aimbot then
			target = nil;
		end;
	end;
});

CombatSection:CreateToggle({
	Title = "Circle",
	Order = 2,
	Default = false,
	Callback = function(state)
        getgenv().Circle = state;
	end;
});
CombatSection:CreateSlider({
	Title = "Circle Size",
	Min = 60,
	Max = 250,
	Default = 80,
    Order = 3,
	Callback = function(val)
		getgenv().FOV = val;
	end;
});
CombatSection:CreateColorPicker({
    Title = "Circle Color",
    Order = 4, 
	Default = Color3.fromRGB(255,0,0),
    callback = function(color)
	    getgenv().CircleColor = color;
    end;
});
--<>----<>----<>----<>----<>----<>----<>--

--<>----<>----<>----<>----<>----<>----<>--
ClientSection:CreateSlider({
	Title = "WalkSpeed",
	Min = 16,
	Max = 250,
	Default = 16,
    Order = 1,
	Callback = function(val)
		getgenv().WS = val;
		Humanoid.WalkSpeed = val;
	end;
});
ClientSection:CreateToggle({
	Title = "High Jump",
	Default = false,
    Order = 2,
	Callback = function(val)
		getgenv().JP = val;
	end
});
UIS.InputBegan:connect(function(input, processed)
	if processed then return end;
	Character:WaitForChild("Humanoid").JumpPower = 100;
	if UIS:IsKeyDown(Enum.KeyCode.Space) and getgenv().JP then
		repeat RunService.RenderStepped:Wait()
			Humanoid:ChangeState(Enum.HumanoidStateType.Jumping);
		until UIS:IsKeyDown(Enum.KeyCode.Space) == false;
	end;
end);
ClientSection:CreateToggle({
	Title = "Hide Name",
	Order = 3,
	Default = false,
	Callback = function(state)
        getgenv().HideName = state;
		while getgenv().HideName do
			wait()
			if Character.Head:FindFirstChild("NameTag") then
				Character.Head:FindFirstChild("NameTag"):Destroy();
			end;
		end;
	end;
});

getgenv().NoFall = false

local hook; 
hook = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "FireServer" and tostring(self) == "ChangeCharacter" and args[1] == "Damage" and getgenv().NoFall then
       return
    end
    return hook(self, table.unpack(args))
end))

ClientSection:CreateToggle({
	Title = "No Fall Damage",
	Order = 3,
	Default = false,
	Callback = function(state)
		getgenv().NoFall = state
	end;
});

ClientSection:CreateButton({
	Text = "Godmode",
	Order = 3,
	Callback = function()
		ChangeCharacter:FireServer('Damage', 0/0);
	end;
});

getgenv().SWD = false
ClientSection:CreateToggle({
	Title = "Spawn Where Died",
	Order = 4,
	Default = false,
	Callback = function(state)
		getgenv().SWD = state;
	end;
});
Character:WaitForChild("Humanoid").Died:Connect(function()
	if getgenv().SWD then
		DeathPos = RootPart.Position;
	end;
end);
Client.CharacterAdded:connect(function()
    wait(0.6);
	if getgenv().SWD then
		RootPart.CFrame = CFrame.new(DeathPos);
	end;
end);

ClientSection:CreateButton({
	Title = "Force Respawn",
	Order = 30,
	Callback = function(state)
		Character.Head.Died:Remove();
		Humanoid.BreakJointsOnDeath = false;
		Humanoid.Health = 0;
	end;
});

--<>----<>----<>----<>----<>----<>----<>--
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))();

VisualSection:CreateToggle({
	Title = "Player ESP",
	Order = 1,
	Default = false,
	Callback = function(state)
		getgenv().PESP = state;
		ESP:Toggle(getgenv().PESP);
		ESP.TeamColor = getgenv().PESP;
	end;
});

VisualSection:CreateToggle({
	Title = "Always Day",
	Order = 1,
	Default = false,
	Callback = function(state)
		getgenv().Fullbright = state;
	end;
});
Lighting.Changed:Connect(function()
	if getgenv().Fullbright then
		Lighting.TimeOfDay = "14:00:00";
	end;
end);
--<>----<>----<>----<>----<>----<>----<>--
EconomySection:CreateDropdown({
	Text = "Locations",
	Array = {"Cash Register"},
    Order = 1,
	Callback = function(val)
		getgenv().SelectedLocation = val;
	end,
});

local function CashRegisterFarm()
    for _, Item in next, Workspace:GetChildren() do
        if BagAmount.Value == BagLevel.Value then 
            RootPart.CFrame = Camp;
            CashRegisterFinished = true;
            break;
        elseif Item:IsA('Model') and Item.Name == 'CashRegister' then
            RootPart.CFrame = Item:FindFirstChild('Open').CFrame;
            RobRemote:FireServer('Register', {['Part'] = Item:FindFirstChild('Union'), ['OpenPart'] = Item:FindFirstChild('Open'), ['ActiveValue'] = Item:FindFirstChild('Active'), ['Active'] = true});
        end;
    end;
    return true;
end;
EconomySection:CreateToggle({
	Title = "Auto Farm",
	Order = 2,
	Default = false,
	Callback = function(state)
		getgenv().Autofarming = state;
		if getgenv().Autofarming then
			if getgenv().SelectedLocation then
				ChangeCharacter:FireServer('Damage', 0/0);
				if Character.Head:FindFirstChild("NameTag") then
					Character.Head:FindFirstChild("NameTag"):Destroy();
				end;
				if getgenv().SelectedLocation == "Cash Register" then
					while getgenv().Autofarming and getgenv().SelectedLocation do
						wait();
						local a = CashRegisterFarm();
					end;
				end;
			end;
		else
			respawn = 0;
			Character.Head.Died:Remove();
			Humanoid.BreakJointsOnDeath = false;
			Humanoid.Health = respawn;
		end;
	end;
});

--<>----<>----<>----<>----<>----<>----<>--
local OuterLine = Drawing.new("Circle")
RunService.Stepped:Connect(function()
    OuterLine.Radius = getgenv().FOV or 80;
    OuterLine.Thickness = 4;
    OuterLine.Position = Vector2.new(Mouse.X, Mouse.Y + 36);
    OuterLine.Transparency = 1;
    OuterLine.Color = getgenv().CircleColor or Color3.new(255,0,0);
    OuterLine.Visible = getgenv().Circle or false;
    OuterLine.ZIndex = 1;
end);
