
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")


local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Holding = false


local Aimbot = {
    Enabled = true,
    TeamCheck = false, 
    AimPart = "Head", 
    Sensitivity = 0.15, 
    CircleSides = 60,
    CircleRadius = 120,
    CircleColor = Color3.fromRGB(255, 255, 255),
    CircleFilled = false,
    CircleVisible = true,
    CircleThickness = 1,
    Keybind = Enum.UserInputType.MouseButton2 
}


local FOVCircle = Drawing.new("Circle")
FOVCircle.Filled = Aimbot.CircleFilled
FOVCircle.NumSides = Aimbot.CircleSides
FOVCircle.Radius = Aimbot.CircleRadius
FOVCircle.Color = Aimbot.CircleColor
FOVCircle.Thickness = Aimbot.CircleThickness
FOVCircle.Visible = Aimbot.CircleVisible


local function GetClosestPlayer()
    local MaximumDistance = Aimbot.CircleRadius
    local Target = nil

    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(Aimbot.AimPart) then
            if Aimbot.TeamCheck and v.Team == LocalPlayer.Team then continue end

            local Position, OnScreen = Camera:WorldToViewportPoint(v.Character[Aimbot.AimPart].Position)
            local Distance = (Vector2.new(Position.X, Position.Y) - UserInputService:GetMouseLocation()).Magnitude

            if OnScreen and Distance < MaximumDistance then
                MaximumDistance = Distance
                Target = v
            end
        end
    end

    return Target
end


UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Aimbot.Keybind then
        Holding = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Aimbot.Keybind then
        Holding = false
    end
end)


RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()

    if Holding and Aimbot.Enabled then
        local Target = GetClosestPlayer()
        if Target and Target.Character and Target.Character:FindFirstChild(Aimbot.AimPart) then
            local AimPartPos = Camera:WorldToViewportPoint(Target.Character[Aimbot.AimPart].Position)
            mousemoverel(
                (AimPartPos.X - UserInputService:GetMouseLocation().X) * Aimbot.Sensitivity,
                (AimPartPos.Y - UserInputService:GetMouseLocation().Y) * Aimbot.Sensitivity
            )
        end
    end
end)
