--[[ 
📌 Aimbot / Aimlock Script (Headshot Lock)
💡 วิธีใช้:
- คลิกขวาเพื่อ Lock เป้าหมายที่อยู่ใน FOV
- คลิกซ้ายเพื่อยิง กระสุนจะเล็งเข้าหัวเป้าหมายอัตโนมัติ
- ปลดล็อคเมื่อเป้าหมายตาย

⚠️ เปลี่ยนชื่อ Remote ในเงื่อนไข FireServer ด้านล่างให้ตรงกับเกมที่คุณเล่น
]]

--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--// Environment Settings
local Settings = {
    FOV = 200,
    LockPart = "Head",
    UnlockOnDeath = true
}

local LockedPlayer = nil
local Locking = false

--// FOV Circle (Visual)
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 1.5
Circle.Radius = Settings.FOV
Circle.Transparency = 0.4
Circle.Visible = true
Circle.Filled = false

RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end)

--// Utility Functions
local function IsAlive(player)
    return player
        and player.Character
        and player.Character:FindFirstChild("Humanoid")
        and player.Character:FindFirstChild("HumanoidRootPart")
        and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer()
    local closest = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            local part = player.Character:FindFirstChild(Settings.LockPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < shortestDist and dist < Settings.FOV then
                        shortestDist = dist
                        closest = player
                    end
                end
            end
        end
    end

    return closest
end

--// Toggle Lock with Right Click
UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Locking then
            Locking = false
            LockedPlayer = nil
        else
            local target = GetClosestPlayer()
            if target then
                LockedPlayer = target
                Locking = true
            end
        end
    end
end)

--// Auto Unlock if player dies
RunService.RenderStepped:Connect(function()
    if Settings.UnlockOnDeath and LockedPlayer and not IsAlive(LockedPlayer) then
        LockedPlayer = nil
        Locking = false
    end
end)

--// Hook __namecall to Redirect Bullets
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- 🔧 เปลี่ยนตรงนี้ให้เป็นชื่อ Remote จริงในเกมคุณ (เช่น "ShootEvent", "FireBullet", "RemoteEvent")
    if tostring(self):lower():find("fire") and method == "FireServer" and LockedPlayer and IsAlive(LockedPlayer) then
        local lockPart = LockedPlayer.Character:FindFirstChild(Settings.LockPart)
        if lockPart then
            args[1] = lockPart.Position
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)
