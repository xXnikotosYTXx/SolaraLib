local Esp = {
    Settings = {
        Enabled = false,
        LimitDistance = false,
        MaxDistance = 9e9,
        CheckTeam = false,
        UseTeamColor = false,
        TeamColor = Color3.fromRGB(255, 255, 255),
        ShowDistance = true,
        Box = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        HealthBar = true,
        Name = true,
        NameColor = Color3.fromRGB(255, 255, 255),
        Misc = true,
        MiscColor = Color3.fromRGB(255, 255, 255),
        HealthText = true,
        HealthTextColor = Color3.fromRGB(0, 255, 0),
        TextFont = 3,
        TextSize = 13
    },
    Cache = {},
    Connections = {}
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Internal functions
function Esp:_CreateDrawing(type, properties)
    local drawing = Drawing.new(type)
    for prop, value in pairs(properties) do
        drawing[prop] = value
    end
    return drawing
end

function Esp:CreatePlayerEsp(player)
    if player == LocalPlayer then return end
    
    local self = {
        Player = player,
        Drawings = {},
        Connection = nil
    }
    
    -- Initialize drawings
    self.Drawings.Box = self:_CreateDrawing("Square", {
        Visible = false,
        Filled = false,
        Thickness = 1,
        Color = self.Settings.BoxColor,
        ZIndex = 2
    })
    
    self.Drawings.BoxOutline = self:_CreateDrawing("Square", {
        Visible = false,
        Filled = false,
        Thickness = 1,
        Color = Color3.new(0, 0, 0),
        ZIndex = 1
    })
    
    self.Drawings.HealthBarBackground = self:_CreateDrawing("Square", {
        Visible = false,
        Filled = true,
        Thickness = 1,
        Color = Color3.new(0, 0, 0),
        ZIndex = 1
    })
    
    self.Drawings.HealthBar = self:_CreateDrawing("Square", {
        Visible = false,
        Filled = true,
        Thickness = 1,
        Color = Color3.new(0, 1, 0),
        ZIndex = 2
    })
    
    self.Drawings.Name = self:_CreateDrawing("Text", {
        Visible = false,
        Outline = true,
        Color = self.Settings.NameColor,
        Size = self.Settings.TextSize,
        Font = self.Settings.TextFont,
        Center = true,
        ZIndex = 3
    })
    
    self.Drawings.HealthText = self:_CreateDrawing("Text", {
        Visible = false,
        Outline = true,
        Color = self.Settings.HealthTextColor,
        Size = 10,
        Font = self.Settings.TextFont,
        Center = true,
        ZIndex = 3
    })
    
    -- Start rendering
    self.Connection = RunService.RenderStepped:Connect(function()
        self:Update()
    end)
    
    table.insert(self.Cache, self)
    return self
end

function Esp:Update()
    if not self.Player.Character then return end
    local humanoid = self.Player.Character:FindFirstChild("Humanoid")
    local rootPart = self.Player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
    if not onScreen then return end
    
    -- Calculate box dimensions
    local offset = Vector3.new(0, 3, 0)
    local headPos = Camera:WorldToViewportPoint(rootPart.Position + offset)
    local legPos = Camera:WorldToViewportPoint(rootPart.Position - offset)
    
    local height = (headPos.Y - legPos.Y) * 0.95
    local width = height * 0.75
    local distance = math.round((Camera.CFrame.Position - rootPart.Position).Magnitude)
    
    -- Visibility checks
    local visible = self.Settings.Enabled
    visible = visible and (not self.Settings.CheckTeam or self.Player.Team ~= LocalPlayer.Team)
    visible = visible and (not self.Settings.LimitDistance or distance <= self.Settings.MaxDistance)
    
    -- Update elements
    local healthPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
    
    -- Box
    self.Drawings.Box.Visible = visible and self.Settings.Box
    self.Drawings.Box.Size = Vector2.new(width, height)
    self.Drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height/2)
    self.Drawings.Box.Color = self.Settings.UseTeamColor and self.Settings.TeamColor or self.Settings.BoxColor
    
    -- Name
    self.Drawings.Name.Visible = visible and self.Settings.Name
    self.Drawings.Name.Text = self.Settings.ShowDistance and 
        string.format("%s [%d]", self.Player.Name, distance) or self.Player.Name
    self.Drawings.Name.Position = Vector2.new(
        rootPos.X,
        rootPos.Y - height/2 - self.Settings.TextSize - 5
    )
    
    -- Health bar
    self.Drawings.HealthBar.Visible = visible and self.Settings.HealthBar
    self.Drawings.HealthBar.Size = Vector2.new(2, height * healthPct)
    self.Drawings.HealthBar.Position = Vector2.new(
        rootPos.X + width/2 + 3,
        rootPos.Y - height/2 + (height * (1 - healthPct))
    )
    
    -- Health text
    self.Drawings.HealthText.Visible = visible and self.Settings.HealthText
    self.Drawings.HealthText.Text = math.round(healthPct * 100) .. "%"
    self.Drawings.HealthText.Position = self.Drawings.HealthBar.Position + Vector2.new(5, 0)
end

function Esp:DestroyPlayer()
    for _, drawing in pairs(self.Drawings) do
        drawing:Remove()
    end
    if self.Connection then
        self.Connection:Disconnect()
    end
end

-- Public API
function Esp:Init()
    -- Existing players
    for _, player in ipairs(Players:GetPlayers()) do
        self:CreatePlayerEsp(player)
    end
    
    -- New players
    self.Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        self:CreatePlayerEsp(player)
    end)
    
    -- Player leaving
    self.Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(player)
        for i, entry in ipairs(self.Cache) do
            if entry.Player == player then
                entry:DestroyPlayer()
                table.remove(self.Cache, i)
                break
            end
        end
    end)
end

function Esp:Destroy()
    for _, connection in pairs(self.Connections) do
        connection:Disconnect()
    end
    for _, entry in ipairs(self.Cache) do
        entry:DestroyPlayer()
    end
    table.clear(self.Cache)
    table.clear(self.Connections)
end

return Esp
