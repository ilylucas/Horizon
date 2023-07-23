--[[
    Horizon esp library | Its so pro
    Credits: ic3w0lf and sirius sense library
]]

------------
-- Variables
------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--------------
-- Esp Object
--------------

local EspLibrary = {}
EspLibrary.__index = EspLibrary

function EspLibrary.new(Object: Part)
    local self = setmetatable({Object = Object, Renders = {}}, EspLibrary)

    return self
end

function EspLibrary:CreateChams(Settings)
    assert(self.Object, string.format("[Horizon Esp Core] Common Error: self.Object is nil"))
    local Connection
    local NewSettings = {
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.new(1,1,1),
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Enabled = true
    }

    for i,v in pairs(Settings or {}) do
        if not NewSettings[i] then return error(string.format('[Horizon Esp Core] Unknown property "%s"', i), 3) end
        NewSettings[i] = (i == "DepthMode" and Enum.HighlightDepthMode[v] or v)
    end

    self.Renders["Chams"] = {Instance.new("Highlight"), NewSettings}
    self.Renders["Chams"][1].Parent = (gethui and gethui() or game:GetService("CoreGui"))

    function self.__DisconnectChams()
        Connection:Disconnect()
        self.Renders["Chams"][1]:Destroy()
        self.Renders["Chams"] = nil
    end

    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Renders["Chams"] then
            if self.Object ~= nil and self.Object.Parent ~= nil and (Players:GetPlayerFromCharacter(self.Object.Parent) ~= nil and Players:GetPlayerFromCharacter(self.Object.Parent).Character.Humanoid.Health > 0) or true then

                for Prop, Value in next, self.Renders["Chams"][2] or {} do
                    if self.Renders["Chams"][1][Prop] then self.Renders["Chams"][1][Prop] = (self.Renders["Chams"][1][Prop] == "DepthMode" and Enum.HighlightDepthMode[Value] or Value) end
                end

                if Players:GetPlayerFromCharacter(self.Object.Parent) then
                    self.Renders["Chams"][1].Adornee = self.Object.Parent
                else
                    self.Renders["Chams"][1].Adornee = self.Object
                end
            else
                self.__DisconnectChams()
            end
        else
            Connection:Disconnect()
        end
    end)

    return self.Renders["Chams"][1], self.Renders["Chams"][2]
end

function EspLibrary:CreateText(Settings)
    assert(self.Object, string.format("[Horizon Esp Core] Common Error: self.Object is nil"))
    local Connection
    local NewSettings = {
        Visible = true,
        Color = Color3.new(1,1,1),
        Transparency = 1,
        Text = "Esp Object",
        Size = 12,
        Outline = true,
        OutlineColor = Color3.new(0,0,0),
        Center = false,
        Font = 1,
        MaxDistance = 150
    }

    for i,v in pairs(Settings or {}) do
        if not NewSettings[i] then return error(string.format('[Horizon Esp Core] Unknown property "%s"', i), 3) end
        NewSettings[i] = v
    end

    self.Renders["Text"] = {Drawing.new("Text"), NewSettings}
    

    function self.__DisconnectText()
        Connection:Disconnect()
        self.Renders["Text"][1]:Remove()
    end

    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Renders["Text"] then
            if self.Object ~= nil and self.Object.Parent ~= nil and (Players:GetPlayerFromCharacter(self.Object.Parent) ~= nil and Players:GetPlayerFromCharacter(self.Object.Parent).Character.Humanoid.Health > 0) or true then
                for Prop, Value in next, self.Renders["Text"][2] or {} do
                    if Prop ~= "MaxDistance" then
                        self.Renders["Text"][1][Prop] = Value
                    end
                end

                local WorldPosition = self.Object.Position
                local Position, Onscreen = workspace.Camera:WorldToViewportPoint(WorldPosition)


                if Onscreen and Position.Z < self.Renders["Text"][2].MaxDistance then
                    self.Renders["Text"][1].Position = Vector2.new(Position.X, Position.Y) - Vector2.new(self.Renders["Text"][1].TextBounds.X / 2, self.Renders["Text"][1].TextBounds.Y / 2)
                    self.Renders["Text"][1].Text = self.Renders["Text"][2].Text:gsub("{name}", self.Object.Name):gsub("{distance}", math.floor(Position.Z))
                    self.Renders["Text"][1].Visible = self.Renders["Text"][2].Visible
                else
                    self.Renders["Text"][1].Visible = false
                end

            else
                self.__DisconnectText()
            end
        else
            Connection:Disconnect()
        end
    end)

    return self.Renders["Text"][1], self.Renders["Text"][2]
end

function EspLibrary:CreateBox(Settings)
    assert(self.Object, string.format("[Horizon Esp Core] Common Error: self.Object is nil"))
    assert(Players:GetPlayerFromCharacter(self.Object.Parent), string.format("[Horizon Box Esp] Failed to connect box to %s, box esp is called from the object's parent for ease of use!", self.Object:GetFullName()))

    local Connection
    local NewSettings = {
        Visible = true,
        Color = Color3.new(1,1,1),
        Filled = false,
        Transparency = 1,
        Thickness = 1,
        MaxDistance = 150
    }
    

    for i,v in pairs(Settings or {}) do
        if not NewSettings[i] then return error(string.format('[Horizon Esp Core] Unknown property "%s"', i), 3) end
        NewSettings[i] = v
    end

    self.Renders["Box"] = {Drawing.new("Square"), NewSettings, Drawing.new("Square")}

    local OldSettings = {
        Visible = true,
        Color = Color3.new(0,0,0),
        Filled = false,
        Transparency = 1,
        Thickness = self.Renders["Box"][2].Thickness + 2
    }
    
    for i,v in pairs(OldSettings or {}) do
        OldSettings[i] = v
        self.Renders["Box"][3][i] = v
    end

    function self.__DisconnectBox()
        Connection:Disconnect()
        self.Renders["Box"][1]:Remove()
        self.Renders["Box"][3]:Remove()
    end

    Connection = game:GetService("RunService").RenderStepped:Connect(function()
        if self.Renders["Box"] then
            if self.Object ~= nil and self.Object.Parent ~= nil and (Players:GetPlayerFromCharacter(self.Object.Parent) ~= nil and Players:GetPlayerFromCharacter(self.Object.Parent).Character.Humanoid.Health > 0) or true then
                for Prop, Value in next, self.Renders["Box"][2] or {} do
                    if Prop ~= "MaxDistance" then
                        self.Renders["Box"][3][Prop] = Value
                    end
                end

                for i,v in pairs(OldSettings or {}) do
                    OldSettings[i] = v
                    self.Renders["Box"][1][i] = v
                end

                local WorldPosition = self.Object.Position
                local Position, Onscreen = workspace.Camera:WorldToViewportPoint(WorldPosition)
                local ViewportSize = workspace.CurrentCamera.ViewportSize
                local Player = Players:GetPlayerFromCharacter(self.Object.Parent)

                if not Player or not Player.Character then
                    self.__DisconnectBox()
                end

                local Char = Player.Character
                local Head, Root = Char.Head, Char.HumanoidRootPart
                local RootPosition, RootVis = workspace.Camera:WorldToViewportPoint(Root.Position)
                local HeadPosition = workspace.CurrentCamera:WorldToViewportPoint(Head.Position + Vector3.new(0, 0.5, 0))
                local LegPosition = workspace.CurrentCamera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0))

                if Onscreen and Position.Z < self.Renders["Box"][2].MaxDistance then
                    self.Renders["Box"][3].Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    self.Renders["Box"][3].Position = Vector2.new(RootPosition.X - self.Renders["Box"][3].Size.X / 2, RootPosition.Y - self.Renders["Box"][3].Size.Y / 2)
                    self.Renders["Box"][3].Visible = self.Renders["Box"][2].Visible

                    self.Renders["Box"][1].Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    self.Renders["Box"][1].Position = Vector2.new(RootPosition.X - self.Renders["Box"][1].Size.X / 2, RootPosition.Y - self.Renders["Box"][1].Size.Y / 2)
                    self.Renders["Box"][1].Visible = self.Renders["Box"][2].Visible
                else
                    self.Renders["Box"][1].Visible = false
                    self.Renders["Box"][3].Visible = false
                end
            else
                self:__DisconnectBox()
            end
        else
            Connection:Disconnect()
        end
    end)

    return self.Renders["Box"][1], self.Renders["Box"][2]
end

for _,v in pairs(game.Players:GetPlayers()) do
    local playerCharacter = v.Character
    if (v and v.Character) ~= nil and playerCharacter:FindFirstChild("HumanoidRootPart") then
        local EspObject = EspLibrary.new(playerCharacter.HumanoidRootPart)
        EspObject:CreateBox()
        EspObject:CreateText({Text = string.format("%s (%s)", v.DisplayName, v.Name)})
        EspObject:CreateChams()
    end
end
