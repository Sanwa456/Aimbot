local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local mouse = localPlayer:GetMouse()


local projectileSpeed = 100
local maxTargetDistance = 100 
local projectileLifetime = 5 


local function GetNearestTarget(origin)
	local nearestTarget = nil
	local shortestDistance = maxTargetDistance

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local targetPos = player.Character.HumanoidRootPart.Position
			local distance = (targetPos - origin).Magnitude
			if distance < shortestDistance then
				shortestDistance = distance
				nearestTarget = player.Character
			end
		end
	end

	return nearestTarget
end


local function FireProjectile()
	local origin = character:WaitForChild("HumanoidRootPart").Position + Vector3.new(0, 2, 0)
	local targetCharacter = GetNearestTarget(origin)

	
	local projectile = Instance.new("Part")
	projectile.Size = Vector3.new(0.4, 0.4, 0.4)
	projectile.Shape = Enum.PartType.Ball
	projectile.Material = Enum.Material.Neon
	projectile.BrickColor = BrickColor.new("Bright red")
	projectile.CFrame = CFrame.new(origin)
	projectile.Anchored = false
	projectile.CanCollide = false
	projectile.Parent = workspace

	local bv = Instance.new("BodyVelocity")
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.MaxForce = Vector3.new(1, 1, 1) * 5000
	bv.P = 1250
	bv.Parent = projectile

	
	local connection
	connection = RunService.Heartbeat:Connect(function()
		if projectile == nil or not projectile.Parent then
			connection:Disconnect()
			return
		end

		if targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart") then
			local direction = (targetCharacter.HumanoidRootPart.Position - projectile.Position).Unit
			bv.Velocity = direction * projectileSpeed
		else
			
			bv.Velocity = mouse.Hit.LookVector * projectileSpeed
		end
	end)


	task.delay(projectileLifetime, function()
		if projectile then
			projectile:Destroy()
		end
	end)
end


mouse.Button1Down:Connect(function()
	FireProjectile()
end)
