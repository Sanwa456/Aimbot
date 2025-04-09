--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// Variables
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

--// Environment
local Environment = {
    Settings = {
        FOV = 200,
        LockPart = "Head",
        UnlockOnDeath = true
    },
    Locking = false,
    Locked = nil
}

--// FOV Circle
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 0, 0)
Circle.Thickness = 1.5
Circle.Radius = Environment.Settings.FOV
Circle.Transparency = 0.4
Circle.Visible = true
Circle.Filled = false

RunService.RenderStepped:Connect(function()
    Circle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
end)

--// Find Closest Player to Cursor
local function IsAlive(player)
    return player and player.Character and player.Character:FindFirstChild("Humanoid") and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.Humanoid.Health > 0
end

local function GetClosestPlayer()
    local Closest = nil
    local ShortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsAlive(player) then
            local part = player.Character:FindFirstChild(Environment.Settings.LockPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                    if dist < ShortestDistance and dist < Environment.Settings.FOV then
                        ShortestDistance = dist
                        Closest = player
                    end
                end
            end
        end
    end

    return Closest
end

--// Toggle Lock Target
UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right Click
        if Environment.Locking then
            Environment.Locking = false
            Environment.Locked = nil
        else
            local target = GetClosestPlayer()
            if target then
                Environment.Locked = target
                Environment.Locking = true
            end
        end
    end
end)

--// Unlock when target dies
RunService.RenderStepped:Connect(function()
    if Environment.Settings.UnlockOnDeath and Environment.Locked then
        if not IsAlive(Environment.Locked) then
            Environment.Locked = nil
            Environment.Locking = false
        end
    end
end)

--// Bullet Redirect
UserInputService.InputBegan:Connect(function(input, gp)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and Environment.Locked then
        local LockPart = Environment.Locked.Character:FindFirstChild(Environment.Settings.LockPart)
        if LockPart then
            -- ดัดแปลงทิศยิงที่เกมจะใช้
            local origin = Camera.CFrame.Position
            local direction = (LockPart.Position - origin).Unit * 1000

            -- ทำให้กระสุนเล็งไปที่หัว
            -- ถ้าเกมใช้ RemoteEvent ในการยิง เราต้องดัก FireServer ด้วย hook

            -- ตัวอย่างนี้ไม่ยิงเอง แค่เปลี่ยนค่าที่จะถูกส่งเวลาเกมยิง
            -- จะจัดการใน hook __namecall ด้านล่าง
        end
    end
end)

--// Hook FireServer เพื่อเปลี่ยนตำแหน่งยิงไปหัว
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()

    -- เปลี่ยนชื่อนี้ให้ตรงกับ Remote ที่เกมใช้ยิงกระสุน
    if tostring(self):lower():find("fire") and method == "FireServer" and Environment.Locked then
        local LockPart = Environment.Locked.Character:FindFirstChild(Environment.Settings.LockPart)
        if LockPart then
            args[1] = LockPart.Position
            return oldNamecall(self, unpack(args))
        end
    end

    return oldNamecall(self, ...)
end)
