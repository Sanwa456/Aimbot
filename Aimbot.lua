
local Camera = game:GetService("Workspace").CurrentCamera
local LocalPlayer = game.Players.LocalPlayer
local RunService = game:GetService("RunService")
local Players = game.Players
local Settings = {Enabled = true, LockPart = "Head", FOVRadius = 90}
local Environment = {
    Settings = Settings,
    Locked = nil,
    FOVSettings = {Enabled = true, Radius = Settings.FOVRadius},
    DeveloperSettings = {UpdateMode = "RenderStepped"},
    Blacklisted = {},
}


local function GetClosestPlayer()
    local LockPart = Environment.Settings.LockPart
    local closestPlayer = nil
    local closestDistance = math.huge  

    if not Environment.Locked then
        local RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000
        for _, Value in pairs(Players:GetPlayers()) do
            local Character = Value.Character
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
            if Value ~= LocalPlayer and not table.find(Environment.Blacklisted, Value.Name) and Character and Character:FindFirstChild(LockPart) and Humanoid then
                local PartPosition = Character[LockPart].Position
                local Vector, OnScreen, Distance = Camera:WorldToViewportPoint(PartPosition)
                
                
                if Distance < RequiredDistance and OnScreen then
                    if Distance < closestDistance then
                        closestDistance = Distance
                        closestPlayer = Value
                    end
                end
            end
        end

        
        if closestPlayer then
            Environment.Locked = closestPlayer
            ShootAtHead(closestPlayer)  
        end
    end
end


local function ShootAtHead(TargetPlayer)
    if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Head") then
        local HeadPosition = TargetPlayer.Character.Head.Position
        local Mouse = LocalPlayer:GetMouse()
        local Direction = (HeadPosition - Camera.CFrame.Position).unit
       
        
        Mouse.Hit = CFrame.new(HeadPosition)
        Mouse.Button1Down:Fire()  
    end
end


RunService.RenderStepped:Connect(function()
    if Settings.Enabled then
        GetClosestPlayer()  
    end
end)
