local ESP = {
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
    Cache = {}
}

ESP.__index = ESP

function ESP.New(Player)
    local self = setmetatable({
        Player = Player,
        Drawings = {},
        Misc = "",
        Connection = nil
    }, ESP)

    self:Construct()
    self:Render()
    table.insert(ESP.Cache, self)
    return self
end

function ESP:_Create(Type, Properties)
    local drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        drawing[Property] = Value
    end
    return drawing
end

function ESP:Remove()
    for _, drawing in pairs(self.Drawings) do
        drawing:Remove()
    end
    table.remove(ESP.Cache, table.find(ESP.Cache, self))
    if self.Connection then self.Connection:Disconnect() end
end

function ESP:Construct()
    self.Drawings.Box = self:_Create("Square", {Visible = false, Thickness = 1, Color = ESP.Settings.BoxColor})
    self.Drawings.BoxOutline = self:_Create("Square", {Visible = false, Thickness = 1, Color = Color3.new(0, 0, 0)})
    self.Drawings.HealthBar = self:_Create("Square", {Visible = false, Filled = true, Color = Color3.new(0, 1, 0)})
    self.Drawings.Name = self:_Create("Text", {Visible = false, Color = ESP.Settings.NameColor, Size = ESP.Settings.TextSize, Font = ESP.Settings.TextFont, Center = true})
    self.Drawings.HealthText = self:_Create("Text", {Visible = false, Color = ESP.Settings.HealthTextColor, Size = 10, Font = ESP.Settings.TextFont, Center = true})
end

function ESP:Render()
    self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        local Character = self.Player.Character
        if Character and Character:FindFirstChild("HumanoidRootPart") then
            local RootPart = Character.HumanoidRootPart
            local Camera = workspace.CurrentCamera
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(RootPart.Position)
            
            if ESP.Settings.Enabled and OnScreen then
                self.Drawings.Box.Visible = ESP.Settings.Box
                self.Drawings.Box.Position = Vector2.new(ScreenPos.X, ScreenPos.Y)
                self.Drawings.Box.Color = ESP.Settings.UseTeamColor and ESP.Settings.TeamColor or ESP.Settings.BoxColor
            else
                self.Drawings.Box.Visible = false
            end
        else
            self.Drawings.Box.Visible = false
        end
    end)
end

return ESP
