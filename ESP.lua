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
    Cache = {}
}

Esp.__index = Esp

function Esp.New(Player)
    local self = setmetatable({
        Player = Player,
        Drawings = {},
        Misc = "",
        Connection = nil
    }, Esp)

    self:Construct()
    self:Render()
    table.insert(Esp.Cache, self)

    return self
end

function Esp:_Create(Type, Properties)
    local drawing = Drawing.new(Type)
    for Property, Value in next, Properties do
        drawing[Property] = Value
    end
    return drawing
end

function Esp:Construct()
    self.Drawings.Box = self:_Create("Square", { Visible = false, Thickness = 1, Color = Color3.new(1, 1, 1) })
    self.Drawings.HealthBar = self:_Create("Square", { Visible = false, Thickness = 1, Color = Color3.new(0, 1, 0) })
    self.Drawings.Name = self:_Create("Text", { Visible = false, Outline = true, Color = Color3.new(1, 1, 1) })
end

function Esp:Render()
    self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Player.Character and self.Player.Character:FindFirstChild("HumanoidRootPart") then
            local CurrentCamera = workspace.CurrentCamera
            local RootVector, Visible = CurrentCamera:WorldToViewportPoint(self.Player.Character.HumanoidRootPart.Position)

            if Esp.Settings.Enabled and Visible then
                self.Drawings.Box.Position = Vector2.new(RootVector.X - 50, RootVector.Y - 50)
                self.Drawings.Box.Size = Vector2.new(100, 100)
                self.Drawings.Box.Visible = Esp.Settings.Box
                self.Drawings.Box.Color = Esp.Settings.BoxColor

                self.Drawings.Name.Position = Vector2.new(RootVector.X, RootVector.Y - 60)
                self.Drawings.Name.Text = self.Player.Name
                self.Drawings.Name.Visible = Esp.Settings.Name
                self.Drawings.Name.Color = Esp.Settings.NameColor
            else
                self.Drawings.Box.Visible = false
                self.Drawings.Name.Visible = false
            end
        end
    end)
end

return Esp
