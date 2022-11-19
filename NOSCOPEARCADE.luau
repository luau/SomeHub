for i,v in ipairs(getconnections(game.ScriptContext.Error)) do
    v:Disable();
end;

local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Drifter0507/Shamrock/main/MainLibrary", true))();

local Players = game:GetService("Players");
local Client = Players.LocalPlayer;
local RunService = game:GetService("RunService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Camera = workspace.CurrentCamera;
local Mouse = Client:GetMouse();

for i,v in pairs(getconnections(Client.Idled)) do
    v:Disable();
end;

local hook
hook = hookmetamethod(game.Players.LocalPlayer,"__namecall",function(...)
    if getnamecallmethod() == "Kick" then
        return wait(9e8);
    end;
    return hook(...);
end);

function SetCharVars()
	Character = Client.Character;
	Humanoid = Character:WaitForChild("Humanoid");
	RootPart = Character:WaitForChild("HumanoidRootPart");
end
SetCharVars();
Client.CharacterAdded:Connect(SetCharVars);

local Window = Lib:CreateWindow({Title = "No-Scope Arcade"});
local Tab1 = Window:CreateTab({Title = "Main", ScrollBar = false});

local Section1 = Tab1:CreateSection({
	Title = "Main"
});

local Aim = Section1:CreateToggle({
	Title = "Silent Aim",
	Order = 1,
	Default = false,
	Callback = function(state)
        getgenv().SilentAim = state;
	end
});
local ESP = loadstring(game:HttpGet("https://kiriot22.com/releases/ESP.lua"))();
local Aim = Section1:CreateToggle({
	Title = "Player ESP",
	Order = 1,
	Default = false,
	Callback = function(state)
        getgenv().Esp = state;
        ESP:Toggle(getgenv().Esp)
	end
});
local Parts = Section1:CreateDropdown({
	Text = "Character Part",
    Order = 3,
	Array = {"Head","HumanoidRootPart","LowerTorso","UpperTorso"},
	Callback = function(val)
		getgenv().Part = val;
	end,
});
local Circ = Section1:CreateToggle({
	Title = "Circle",
	Order = 4,
	Default = false,
	Callback = function(state)
        getgenv().Circle = state;
	end
});
local Fov = Section1:CreateSlider({
	Title = "Circle Size",
	Min = 60,
	Max = 250,
	Default = 80,
    Order = 5,
	Callback = function(val)
		getgenv().FOV = val;
	end
});
local CircColor = Section1:CreateColorPicker({
    Title = "Circle Color",
    Order = 6, 
    callback = function(color)
	    getgenv().CircleColor = color
    end
});

local function isPointVisible(worldPoint)
    local camera = workspace.CurrentCamera;
    local vector, onScreen = camera:WorldToViewportPoint(worldPoint);
    
    if onScreen then
        local origin = camera.CFrame.p;
        local ray = Ray.new(origin, worldPoint - origin);
        local hit = workspace:FindPartOnRay(ray);
        if hit then
            return false;
        end;
    else
        return false;
    end;
    return true;
end;

local function GetClosest(Fov)
    local Target, Closest = nil, math.huge;
    
    for i,v in pairs(Players:GetPlayers()) do
        if (v.Name ~= Client.Name and v.Character and v.Character.HumanoidRootPart and not table.find(getgenv().Whitelisted,v.Name)) then
            local ScreenPos, OnScreen = Camera:WorldToScreenPoint(v.Character.HumanoidRootPart.Position);
            if OnScreen then
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude;
            
                if (Distance < Closest) then
                    Closest = Distance;
                    Target = v;
                end;
            end;
        end;
    end;
    return Target;
end;


local Target;
local OuterLine = Drawing.new("Circle");
RunService.Stepped:Connect(function()
    OuterLine.Radius = getgenv().FOV or 80;
    OuterLine.Thickness = 4;
    OuterLine.Position = Vector2.new(Mouse.X, Mouse.Y + 36);
    OuterLine.Transparency = 1;
    OuterLine.Color = getgenv().CircleColor or Color3.new(255,255,255);
    OuterLine.Visible = getgenv().Circle or false;
    OuterLine.ZIndex = 1;
    
    if getgenv().SilentAim then
        Target = GetClosest(getgenv().FOV);
    end;
end);

local Old; 
Old = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...};
    local Method = getnamecallmethod();
    
    if (not checkcaller() and Method == "FireServer") then
        if (Self.Name == "RemoteEvent" and Args[2] == "Bullet" and Args[7] ~= "Knife" and Method == "FireServer") then
            if (Target and Target.Character and Target.Character.Humanoid and Target.Character.Humanoid.Health ~= 0) then
                local Hitbox = Target.Character[getgenv().Part or "Head"];
                
                if (Hitbox and getgenv().SilentAim) then
                    Args[3] = Target.Character;
                    Args[4] = Hitbox;
                    Args[5] = Hitbox.Position;
                end;
            end;
        end;
    end; 
    return Old(Self, unpack(Args));
end);
