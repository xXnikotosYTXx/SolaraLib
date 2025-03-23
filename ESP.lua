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

    self.Index = #Esp.Cache + 1
    Esp.Cache[self.Index] = self

    return self
end

function Esp:_Create(Type, Properties)
    local drawing = Drawing.new(Type)
    for Property, Value in next, Properties do
        drawing[Property] = Value
    end
    return drawing
end

function Esp:Remove()
    for _, drawing in next, self.Drawings do
        drawing:Remove()
    end
    table.remove(Esp.Cache, self.Index)
    self.Connection:Disconnect()
end

function Esp:Construct()
    -- Конструктор рисунков (оставить как есть)
    -- ... (ваш оригинальный код Construct)
end

function Esp:Render()
    -- Рендер функция (оставить как есть)
    -- ... (ваш оригинальный код Render)
end

function Esp:Toggle(state)
    self.Settings.Enabled = state
    for _, instance in pairs(self.Cache) do
        instance:Render()
    end
end

function Esp:Init()
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        Esp.New(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        for i, esp in pairs(Esp.Cache) do
            if esp.Player == player then
                esp:Remove()
            end
        end
    end)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            Esp.New(player)
        end
    end
end

return Esp
