-- Settings --
local Settings = {
    Visuals = {
        Esp = false,
        Distance = false,
        Name = false,
        TeamCheck = false
    },
    Aimbot = {
        AimbotKey = Enum.KeyCode.F,
        AimbotUsed = false,
        FOVRadius = 150,
        Smoothness = 1,
        TeamCheck = false,
        FOVUsed = false,
        AimbotPart = "Head",
        FOVColor = Color3.fromRGB(255,255,255)
    }
}

-- Services --
local zzWorkspace = game:GetService("Workspace")
local zzRunService = game:GetService("RunService")
local zzUIS = game:GetService("UserInputService")
local zzPlayers = game:GetService("Players")
local zzCamera = zzWorkspace.CurrentCamera
local zzLPlayer = zzPlayers.LocalPlayer
local zzMouse = zzLPlayer:GetMouse()

local FOV = Drawing.new("Circle")
FOV.Color = Settings.Aimbot.FOVColor
FOV.Thickness = 1
FOV.Filled = false
FOV.Radius = Settings.Aimbot.FOVRadius
FOV.Transparency = 1
FOV.Visible = Settings.Aimbot.FOVUsed
FOV.NumSides = 1000

local Lib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/RealZzHub/Main/main/UI_Lib.lua'),true))()

local Main = Lib:CreateMain("Universal")

MainTab = Main:NewTab("Main")

MainTab:NewToggle("Aimbot", function(state)
    Settings.Aimbot.AimbotUsed = state
end)
MainTab:NewKeybind("Aimbot Key", Settings.Aimbot.AimbotKey, function(key)
    Settings.Aimbot.AimbotKey = key
end)
MainTab:NewToggle("Team Check", function(state)
    Settings.Aimbot.TeamCheck = state
end)
MainTab:NewSlider("Smoothness", 1, 20, function(v)
    Settings.Aimbot.Smoothness = v
end)
MainTab:NewDropdown("Aim Part", {"Head"}, function(v)
    Settings.Aimbot.AimbotPart = v
end)
MainTab:NewToggle("Use FOV", function(state)
    Settings.Aimbot.FOVUsed = state
    FOV.Visible = state
end)
MainTab:NewSlider("FOV Radius", 1,1000, function(v)
    Settings.Aimbot.FOVRadius = v
    FOV.Radius = v
end, Settings.Aimbot.FOVRadius)

VisualsTab = Main:NewTab("Visuals")

VisualsTab:NewToggle("Box ESP", function(state)
    Settings.Visuals.Esp = state
end)
VisualsTab:NewToggle("Name ESP", function(state)
    Settings.Visuals.Name = state
end)
VisualsTab:NewToggle("Distance ESP", function(state)
    Settings.Visuals.Distance = state
end)
VisualsTab:NewToggle("Team Check", function(state)
    Settings.Visuals.TeamCheck = state
end)

-- Aimbot --

function getTarget()
    local Mag = math.huge
    local plr
    for i, v in pairs(zzPlayers:GetPlayers()) do 
        if v ~= zzLPlayer and v.Character:FindFirstChild("HumanoidRootPart") then 
            if not Settings.Aimbot.TeamCheck or Settings.Aimbot.TeamCheck and v.Team ~= zzLPlayer.Team then
                local Pos, onScreen = zzCamera:WorldToScreenPoint(v.Character[Settings.Aimbot.AimbotPart].Position) 
                if onScreen then
                    local Dist = (Vector2.new(zzMouse.X, zzMouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude 
                    if not Settings.Aimbot.FOVUsed and Dist < Mag or Settings.Aimbot.FOVUsed and Dist < Mag and Dist < Settings.Aimbot.FOVRadius then 
                        Mag = Dist
                        plr = v
                    end
                end
            end
        end
    end
    return plr 
end

local Aiming = false

zzRunService.RenderStepped:Connect(function()
    local MousePos = zzUIS:GetMouseLocation()
    FOV.Position = Vector2.new(MousePos.X, MousePos.Y)

    if Aiming and Settings.Aimbot.AimbotUsed then
        local plr = getTarget()
        if plr then
            local Pos = zzCamera:WorldToViewportPoint(plr.Character[Settings.Aimbot.AimbotPart].Position)
            mousemoverel((Pos.X - MousePos.X) / Settings.Aimbot.Smoothness, (Pos.Y - MousePos.Y) / Settings.Aimbot.Smoothness)
        end
    end
end)

zzUIS.InputEnded:Connect(function(v)
    if v.KeyCode == Settings.Aimbot.AimbotKey then
        Aiming = false
    end
end)

zzUIS.InputBegan:Connect(function(v)
    print(tostring(v.KeyCode))
    if v.KeyCode == Settings.Aimbot.AimbotKey then
        Aiming = true
    end
end)


-- ESP --
function StartESP(plr) 

    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.new(1,1,1)
    Box.Thickness = 2
    Box.Transparency = 1
    Box.Filled = false

    local Name = Drawing.new("Text")
    Name.Visible = false
    Name.Size = 17
    Name.Color = Color3.new(1,1,1)
    Name.Center = true
    Name.Outline = true

    local Dist = Drawing.new("Text")
    Dist.Visible = false
    Dist.Size = 17
    Dist.Color = Color3.new(1,1,1)
    Dist.Center = true
    Dist.Outline = true
 

    local Run
    Run = zzRunService.RenderStepped:Connect(function()
        if plr.Character ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and zzLPlayer ~= plr and plr then
           local _, onScreen = zzCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)


           local HeadPos = zzCamera:WorldToViewportPoint(plr.Character.Head.Position + Vector3.new(0, 0.5, 0))
           local RootPos = zzCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
           local LegPos = zzCamera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0,3,0))

            
           if onScreen then

            Box.Size = Vector2.new(1000 / RootPos.Z, HeadPos.Y - LegPos.Y)
            Box.Position = Vector2.new(RootPos.X - Box.Size.X / 2, RootPos.Y - Box.Size.Y / 2)

            Name.Position = Vector2.new(RootPos.X, (RootPos.Y + Box.Size.Y / 2) - 25)
            Name.Text = plr.Name

            Dist.Position = Vector2.new(RootPos.X, (RootPos.Y - Box.Size.Y / 2) + 25)
            Dist.Text = "["..tostring(math.floor((plr.Character.HumanoidRootPart.Position - zzCamera.CFrame.Position).Magnitude)).." Studs]"

            Dist.Color = plr.TeamColor.Color
            Name.Color = plr.TeamColor.Color
            Box.Color = plr.TeamColor.Color

            if Settings.Visuals.TeamCheck and plr.Team == zzLPlayer.Team then
                Box.Visible = false
                Name.Visible = false
                Dist.Visible = false
            else
                Dist.Visible = Settings.Visuals.Distance
                Name.Visible = Settings.Visuals.Name
                Box.Visible = Settings.Visuals.Esp
            end


           else
            Box.Visible = false
            Name.Visible = false
            Dist.Visible = false

           end

        else
            Box.Visible = false
            Name.Visible = false
            Dist.Visible = false

        end
    end)

    local Removing
    Removing = zzPlayers.PlayerRemoving:Connect(function(v)
        if v == plr then
            Removing:Disconnect()
            Run:Disconnect()
            Box:Remove()
            Name:Remove()
            Dist:Remove()
        end
    end)
end

for _,v in pairs(zzPlayers:GetPlayers()) do
    StartESP(v)
end

zzPlayers.PlayerAdded:Connect(function(v)
    StartESP(v)
end)
