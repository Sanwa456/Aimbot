local game, workspace = game, workspace
local getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick = getrawmetatable, getmetatable, setmetatable, pcall, getgenv, next, tick
local Vector2new, Vector3zero, CFramenew, Color3fromRGB, Color3fromHSV, Drawingnew, TweenInfonew = Vector2.new, Vector3.zero, CFrame.new, Color3.fromRGB, Color3.fromHSV, Drawing.new, TweenInfo.new
local getupvalue, mousemoverel, tablefind, tableremove, stringlower, stringsub, mathclamp = debug.getupvalue, mousemoverel or (Input and Input.MouseMove), table.find, table.remove, string.lower, string.sub, math.clamp
local GameMetatable = getrawmetatable and getrawmetatable(game) or {
    __index = function(self, Index)
        return self[Index]
    end,
    __newindex = function(self, Index, Value)
        self[Index] = Value
    end
}
local __index = GameMetatable.__index
local __newindex = GameMetatable.__newindex
local getrenderproperty, setrenderproperty = getrenderproperty or __index, setrenderproperty or __newindex
local GetService = __index(game, "GetService")


local RunService = GetService(game, "RunService")
local UserInputService = GetService(game, "UserInputService")
local TweenService = GetService(game, "TweenService")
local Players = GetService(game, "Players")


local LocalPlayer = __index(Players, "LocalPlayer")
local Camera = __index(workspace, "CurrentCamera")
local FindFirstChild, FindFirstChildOfClass = __index(game, "FindFirstChild"), __index(game, "FindFirstChildOfClass")
local GetDescendants = __index(game, "GetDescendants")
local WorldToViewportPoint = __index(Camera, "WorldToViewportPoint")
local GetPartsObscuringTarget = __index(Camera, "GetPartsObscuringTarget")
local GetMouseLocation = __index(UserInputService, "GetMouseLocation")
local GetPlayers = __index(Players, "GetPlayers")


local RequiredDistance, Typing, Running, ServiceConnections, Animation, OriginalSensitivity = 2000, false, false, {}, nil, 0
local Connect, Disconnect = __index(game, "DescendantAdded").Connect
local FOVCircleOutline = Drawingnew("Circle")
local FOVCircle = Drawingnew("Circle")


getgenv().ExunysDeveloperAimbot = {
    DeveloperSettings = {
        UpdateMode = "RenderStepped",
        TeamCheckOption = "TeamColor",
        RainbowSpeed = 1 
    },
    Settings = {
        Enabled = true,
        TeamCheck = false,
        AliveCheck = true,
        WallCheck = false,
        OffsetToMoveDirection = false,
        OffsetIncrement = 15,
        Sensitivity = 0,
        Sensitivity2 = 3.5,
        LockMode = 1, 
        LockPart = "Head",
        TriggerKey = Enum.UserInputType.MouseButton2,
        Toggle = false
    },
    FOVSettings = {
        Enabled = true,
        Visible = true,
        Radius = 90,
        NumSides = 60,
        Thickness = 1,
        Transparency = 1,
        Filled = false,
        RainbowColor = false,
        RainbowOutlineColor = false,
        Color = Color3fromRGB(255, 255, 255),
        OutlineColor = Color3fromRGB(0, 0, 0),
        LockedColor = Color3fromRGB(255, 150, 150)
    },
    Blacklisted = {},
    FOVCircleOutline = FOVCircleOutline,
    FOVCircle = FOVCircle
}

local Environment = getgenv().ExunysDeveloperAimbot
setrenderproperty(Environment.FOVCircle, "Visible", false)
setrenderproperty(Environment.FOVCircleOutline, "Visible", false)


local FixUsername = function(String)
    local Result
    for _, Value in next, GetPlayers(Players) do
        local Name = __index(Value, "Name")
        if stringsub(stringlower(Name), 1, #String) == stringlower(String) then
            Result = Name
        end
    end
    return Result
end

local GetRainbowColor = function()
    local RainbowSpeed = Environment.DeveloperSettings.RainbowSpeed
    return Color3fromHSV(tick() % RainbowSpeed / RainbowSpeed, 1, 1)
end

local ConvertVector = function(Vector)
    return Vector2new(Vector.X, Vector.Y)
end

local CancelLock = function()
    Environment.Locked = nil
    local FOVCircle = Environment.FOVCircle
    setrenderproperty(FOVCircle, "Color", Environment.FOVSettings.Color)
    __newindex(UserInputService, "MouseDeltaSensitivity", OriginalSensitivity)
    if Animation then
        Animation:Cancel()
    end
end

local GetClosestPlayer = function()
    local Settings = Environment.Settings
    local LockPart = Settings.LockPart
    if not Environment.Locked then
        RequiredDistance = Environment.FOVSettings.Enabled and Environment.FOVSettings.Radius or 2000
        for _, Value in next, GetPlayers(Players) do
            local Character = __index(Value, "Character")
            local Humanoid = Character and FindFirstChildOfClass(Character, "Humanoid")
            if Value ~= LocalPlayer and not tablefind(Environment.Blacklisted, __index(Value, "Name")) and Character and FindFirstChild(Character, LockPart) and Humanoid then
                local PartPosition, TeamCheckOption = __index(Character[LockPart], "Position"), Environment.DeveloperSettings.TeamCheckOption
                if Settings.TeamCheck and __index(Value, TeamCheckOption) == __index(LocalPlayer, TeamCheckOption) then
                    continue
                end
                if Settings.AliveCheck and __index(Humanoid, "Health") <= 0 then
                    continue
                end
                if Settings.WallCheck then
                    local BlacklistTable = GetDescendants(__index(LocalPlayer, "Character"))
                    for _, Value in next, GetDescendants(Character) do
                        BlacklistTable[#BlacklistTable + 1] = Value
                    end
                    if #GetPartsObscuringTarget(Camera, {PartPosition}, BlacklistTable) > 0 then
                        continue
                    end
                end
                local Vector, OnScreen, Distance = WorldToViewportPoint(Camera, PartPosition)
                Vector = ConvertVector(Vector)
                Distance = (GetMouseLocation(UserInputService) - Vector).Magnitude
                if Distance < RequiredDistance and OnScreen then
                    RequiredDistance, Environment.Locked = Distance, Value
                end
            end
        end
    elseif (GetMouseLocation(UserInputService) - ConvertVector(WorldToViewportPoint(Camera, __index(__index(__index(Environment.Locked, "Character"), LockPart), "Position")))).Magnitude > RequiredDistance then
        CancelLock()
    end
end

local Load = function()
    OriginalSensitivity = __index(UserInputService, "MouseDeltaSensitivity")
    local Settings, FOVCircle, FOVCircleOutline, FOVSettings, Offset = Environment.Settings, Environment.FOVCircle, Environment.FOVCircleOutline, Environment.FOVSettings
    ServiceConnections.RenderSteppedConnection = Connect(__index(RunService, Environment.DeveloperSettings.UpdateMode), function()
        local OffsetToMoveDirection, LockPart = Settings.OffsetToMoveDirection, Settings.LockPart
        if FOVSettings.Enabled and Settings.Enabled then
            for Index, Value in next, FOVSettings do
                if Index == "Color" then
                    continue
                end
                if pcall(getrenderproperty, FOVCircle, Index) then
                    setrenderproperty(FOVCircle, Index, Value)
                    setrenderproperty(FOVCircleOutline, Index, Value)
                end
            end
            setrenderproperty(FOVCircle, "Color", (Environment.Locked and FOVSettings.LockedColor) or FOVSettings.RainbowColor and GetRainbowColor() or FOVSettings.Color)
            setrenderproperty(FOVCircleOutline, "Color", FOVSettings.RainbowOutlineColor and GetRainbowColor() or FOVSettings.OutlineColor)
            setrenderproperty(FOVCircleOutline, "Thickness", FOVSettings.Thickness + 1)
            setrenderproperty(FOVCircle, "Position", GetMouseLocation(UserInputService))
            setrenderproperty(FOVCircleOutline, "Position", GetMouseLocation(UserInputService))
        else
            setrenderproperty(FOVCircle, "Visible", false)
            setrenderproperty(FOVCircleOutline, "Visible", false)
        end
        if Running and Settings.Enabled then
            GetClosestPlayer()
            Offset = OffsetToMoveDirection and __index(FindFirstChildOfClass(__index(Environment.Locked, "Character"), "Humanoid"), "MoveDirection") * (mathclamp(Settings.OffsetIncrement, 1, 30) / 10) or Vector3zero
            if Environment.Locked then
                local LockedPosition_Vector3 = __index(__index(Environment.Locked, "Character")[LockPart], "Position")
                local LockedPosition = WorldToViewportPoint(Camera, LockedPosition_Vector3 + Offset)
                if Environment.Settings.LockMode == 2 then
                    mousemoverel((LockedPosition.X - GetMouseLocation(UserInputService).X) / Settings.Sensitivity2, (LockedPosition.Y - GetMouseLocation(UserInputService).Y) / Settings.Sensitivity2)
                else
                    if Settings.Sensitivity > 0 then
                        Animation = TweenService:Create(Camera, TweenInfonew(Environment.Settings.Sensitivity, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {CFrame = CFramenew(Camera.CFrame.Position, LockedPosition_Vector3)})
                        Animation:Play()
                    else
                        __newindex(Camera, "CFrame", CFramenew(Camera.CFrame.Position, LockedPosition_Vector3 + Offset))
                    end
                end
            end
        end
    end)
end

Load()
