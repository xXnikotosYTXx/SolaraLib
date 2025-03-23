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
    Groups = {},
    Cache = {},
    Connections = {}
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

function Esp:_Create(Type, Properties)
    local drawing = Drawing.new(Type)
    for Property, Value in pairs(Properties) do
        drawing[Property] = Value
    end
    return drawing
end

function Esp:Remove(player)
    local instance = self.Cache[player]
    if instance then
        for _, drawing in pairs(instance.Drawings) do
            drawing:Remove()
        end
        if instance.Connection then
            instance.Connection:Disconnect()
        end
        self.Cache[player] = nil
    end
end

function Esp:Construct(player)
    local drawings = {
        Box = self:_Create("Square", {
            Visible = false,
            Filled = false,
            Thickness = 1,
            Color = self.Settings.BoxColor,
            ZIndex = 2
        }),
        BoxOutline = self:_Create("Square", {
            Visible = false,
            Filled = false,
            Thickness = 3,
            Color = Color3.new(0, 0, 0),
            ZIndex = 1
        }),
        HealthBarBackground = self:_Create("Square", {
            Visible = false,
            Filled = true,
            Thickness = 1,
            Color = Color3.new(0, 0, 0),
            ZIndex = 1
        }),
        HealthBar = self:_Create("Square", {
            Visible = false,
            Filled = true,
            Thickness = 1,
            Color = Color3.new(0, 1, 0),
            ZIndex = 2
        }),
        Name = self:_Create("Text", {
            Visible = false,
            Outline = true,
            Color = self.Settings.NameColor,
            Size = self.Settings.TextSize,
            Font = self.Settings.TextFont,
            Center = true,
            ZIndex = 3
        }),
        Misc = self:_Create("Text", {
            Visible = false,
            Outline = true,
            Color = self.Settings.MiscColor,
            Size = self.Settings.TextSize,
            Font = self.Settings.TextFont,
            Center = true,
            ZIndex = 3
        }),
        HealthText = self:_Create("Text", {
            Visible = false,
            Outline = true,
            Color = self.Settings.HealthTextColor,
            Size = 10,
            Font = self.Settings.TextFont,
            Center = true,
            ZIndex = 3
        })
    }
    
    self.Cache[player] = {
        Player = player,
        Drawings = drawings,
        Connection = nil
    }
end

function Esp:Render()
    -- Добавляем коэффициент масштабирования
    local function getScaleFactor(depth)
        return 1 / (depth * math.tan(math.rad(workspace.CurrentCamera.FieldOfView/2)) * 100
    end

    -- Единый обработчик для всех игроков
    if not self.RenderConnection then
        self.RenderConnection = game:GetService("RunService").RenderStepped:Connect(function()
            for _, instance in pairs(Esp.Cache) do
                if instance.Player and instance.Player.Character then
                    local character = instance.Player.Character
                    local humanoid = character:FindFirstChild("Humanoid")
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    
                    if humanoid and rootPart then
                        local camera = workspace.CurrentCamera
                        local rootPos = rootPart.Position
                        local rootScreenPos, onScreen = camera:WorldToViewportPoint(rootPos)
                        
                        -- Упрощенная проверка видимости
                        local Visible = Esp.Settings.Enabled and onScreen
                        
                        if Visible and Esp.Settings.CheckTeam then
                            Visible = instance.Player.Team ~= game.Players.LocalPlayer.Team
                        end
                        
                        if Visible and Esp.Settings.LimitDistance then
                            local distance = (camera.CFrame.Position - rootPos).Magnitude
                            Visible = distance <= Esp.Settings.MaxDistance
                        end
                                local HealthDecimal = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)

            if Visible then
                self.Drawings.Box.Size = Vector2.new(Width, Height)
                self.Drawings.Box.Position = Vector2.new(RootVector.X - (Width / 2), RootVector.Y - (Height / 2))
                self.Drawings.Box.Color = Esp.Settings.UseTeamColor and Esp.Settings.TeamColor or Esp.Settings.BoxColor -- Use TeamColor if enabled

                self.Drawings.BoxOutline.Size = Vector2.new(Width - 2, Height - 2)
                self.Drawings.BoxOutline.Position = Vector2.new((RootVector.X - (Width / 2)) + 1, (RootVector.Y - (Height / 2)) + 1)

                self.Drawings.HealthBarBackground.Size = Vector2.new(5, Height - 3)
                self.Drawings.HealthBarBackground.Position = Vector2.new(self.Drawings.Box.Position.X + self.Drawings.Box.Size.X - 9, self.Drawings.Box.Position.Y + 1)

                self.Drawings.HealthBar.Size = Vector2.new(1, Height * HealthDecimal)
                self.Drawings.HealthBar.Position = Vector2.new(self.Drawings.Box.Position.X + self.Drawings.Box.Size.X - 7, self.Drawings.Box.Position.Y)
                self.Drawings.HealthBar.Color = Color3.new(1 - HealthDecimal, HealthDecimal, 0)

                self.Drawings.Name.Position = Vector2.new(self.Drawings.Box.Position.X + (self.Drawings.Box.Size.X / 2), (self.Drawings.Box.Position.Y + self.Drawings.Box.Size.Y) - (Esp.Settings.TextSize + 5))
                self.Drawings.Name.Color = Esp.Settings.UseTeamColor and Esp.Settings.TeamColor or Esp.Settings.NameColor
                self.Drawings.Name.Text = (Esp.Settings.ShowDistance and string.format("%s [%s]", self.Player.Name, Distance)) or self.Player.Name
                self.Drawings.Name.Font = Esp.Settings.TextFont
                self.Drawings.Name.Size = Esp.Settings.TextSize

                self.Drawings.Misc.Position = Vector2.new(self.Drawings.Box.Position.X + (self.Drawings.Box.Size.X / 2), self.Drawings.Box.Position.Y + 2)
                self.Drawings.Misc.Color = Esp.Settings.MiscColor
                self.Drawings.Misc.Font = Esp.Settings.TextFont
                self.Drawings.Misc.Size = Esp.Settings.TextSize
                self.Drawings.Misc.Text = self.Misc

                self.Drawings.HealthText.Position = self.Drawings.HealthBarBackground.Position + Vector2.new(-15, self.Drawings.HealthBarBackground.Size.Y - (self.Drawings.HealthBarBackground.Size.Y - self.Drawings.HealthBar.Size.Y) - 5)
                self.Drawings.HealthText.Color = Esp.Settings.HealthTextColor
                self.Drawings.HealthText.Font = Esp.Settings.TextFont
                self.Drawings.HealthText.Text = math.round(HealthDecimal * 100) .. "%"
            end

            self.Drawings.Box.Visible = Visible and Esp.Settings.Box
            self.Drawings.BoxOutline.Visible = Visible and Esp.Settings.Box
            self.Drawings.HealthBarBackground.Visible = Visible and Esp.Settings.HealthBar
            self.Drawings.HealthBar.Visible = Visible and Esp.Settings.HealthBar
            self.Drawings.Name.Visible = Visible and Esp.Settings.Name
            self.Drawings.Misc.Visible = Visible and Esp.Settings.Misc
            self.Drawings.HealthText.Visible = Visible and Esp.Settings.HealthText and HealthDecimal ~= 1
        else
            self.Drawings.Box.Visible = false
            self.Drawings.BoxOutline.Visible = false
            self.Drawings.HealthBarBackground.Visible = false
            self.Drawings.HealthBar.Visible = false
            self.Drawings.Name.Visible = false
            self.Drawings.Misc.Visible = false
            self.Drawings.HealthText.Visible = false

                        -- Корректировка размера бокса
                        local scale = getScaleFactor(rootScreenPos.Z)
                        local height = 6 * scale
                        local width = 4 * scale

                        -- Обновление позиций
                        instance.Drawings.Box.Size = Vector2.new(width, height)
                        instance.Drawings.Box.Position = Vector2.new(
                            rootScreenPos.X - width/2,
                            rootScreenPos.Y - height/2
                        )

                        -- Остальные элементы обновляются аналогично...
                    end
                end
            end
        end)
    end
end

function Esp:Init()
    -- Player handling
    Players.PlayerAdded:Connect(function(player)
        self:Construct(player)
    end)

    Players.PlayerRemoving:Connect(function(player)
        self:Remove(player)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            self:Construct(player)
        end
    end

    -- Single render loop
    self.Connections.Render = RunService.RenderStepped:Connect(function()
        if self.Settings.Enabled then
            self:UpdateRender()
        else
            for _, instance in pairs(self.Cache) do
                for _, drawing in pairs(instance.Drawings) do
                    drawing.Visible = false
                end
            end
        end
    end)
end

return Esp
