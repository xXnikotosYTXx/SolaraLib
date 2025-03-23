local Esp = {
    Settings = {
        Enabled = false,
        LimitDistance = false,
        MaxDistance = 9e9,
        CheckTeam = false,
        UseTeamColor = false,
        
        TeamColor = Color3.fromRGB(255, 255, 255), -- Added TeamColor setting
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
        TextSize = 13,
        -- ... остальные настройки ...
    },
    Groups = {},
    Cache = {}
}

Esp.__index = Esp

-- В конструкторе объектов исправляем обращение к настройкам:
-- В методе Construct исправляем все обращения к настройкам:
function Esp:Construct()
    self.Drawings.Box = self:_Create("Square", {
        Visible = false,
        Filled = false,
        Thickness = 1,
        Color = Color3.new(1, 1, 1),
        ZIndex = 2
    })

    self.Drawings.Name = self:_Create("Text", {
        Visible = false,
        Outline = true,
        Color = Color3.new(1, 1, 1),
        Size = Esp.Settings.TextSize, -- Используем Esp.Settings вместо self.Settings
        Font = Esp.Settings.TextFont, -- Обращаемся к глобальным настройкам
        Center = true,
        ZIndex = 3
    })
    -- Аналогично исправляем для всех элементов Drawings
end

-- В методе Render:
function Esp:Render()
    self.Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Player.Character then
            -- Используем Esp.Settings вместо self.Settings
            local Visible = Esp.Settings.Enabled
            if Esp.Settings.CheckTeam then
                Visible = Visible and (self.Player.Team ~= game.Players.LocalPlayer.Team)
            end
            -- ... остальная логика с Esp.Settings ...
        end
    end)
end
