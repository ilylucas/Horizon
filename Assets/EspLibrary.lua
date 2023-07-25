-- Variables

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ViewportSize = workspace.CurrentCamera.ViewportSize

-- Esp Object

local EspLibrary = {}
EspLibrary.__index = EspLibrary

function EspLibrary.new(Object, ParentObject, MaxDist)
    local self = setmetatable({}, EspLibrary)
    self.Settings = {}
    self.RenderedObjects = {}
    self.Object = Object
    self.ParentObject = ParentObject
    self.MaxDistance = MaxDist or math.huge
    
    self.EspRemoved = Instance.new("BindableEvent")
    
    if Players:GetPlayerFromCharacter(self.Object.Parent) then
        self.IsPlayer = true
        self.Player = Players:GetPlayerFromCharacter(self.Object.Parent)
        self.PlayerCharacter = self.Player.Character
        self.Humanoid = self.PlayerCharacter.Humanoid

        self.Root = self.PlayerCharacter.HumanoidRootPart
        self.Head = self.PlayerCharacter.Head
    end

    self.Connection = RunService.RenderStepped:Connect(function()
        local WorldPosition, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(self.Object.Position)
        local OnRange = WorldPosition.Z < self.MaxDistance

        if self.IsPlayer then
            if not Players:FindFirstChild(self.Player.Name) or not self.PlayerCharacter or not self.Humanoid or self.Humanoid.Health == 0 then
                self:Destruct()
                return
            end
        else
            if not self.Object or not self.Object.Parent then
                self:Destruct()
                return
            end
        end

        if OnScreen and OnRange then
            if self.RenderedObjects then
                if self.RenderedObjects.TextEsp then
                    for i,v in pairs(self.Settings.Text) do
                        self.RenderedObjects.TextEsp[i] = v
                    end

                    self.RenderedObjects.TextEsp.Position = Vector2.new(WorldPosition.X, WorldPosition.Y) - Vector2.new(self.RenderedObjects.TextEsp.TextBounds.X / 2, (self.Settings.Text.PositionMode == "Top" and 0 or self.Settings.Text.PositionMode == "Middle" and self.RenderedObjects.TextEsp.TextBounds.Y / 2 or self.Settings.Text.PositionMode == "Bottom" and self.RenderedObjects.TextEsp.TextBounds.Y))
                    self.RenderedObjects.TextEsp.Text = self.Settings.Text.Text:gsub("{name}", self.Object.Name):gsub("{distance}", WorldPosition.Z)
                end

                if self.RenderedObjects.Chams then
                    for i,v in pairs(self.Settings.Chams) do
                        self.RenderedObjects.Chams[i] = v
                    end

                    self.RenderedObjects.Chams.Adornee = (self.PlayerCharacter or self.ParentObject or self.Object)
                end

                if self.RenderedObjects.BoxEsp then
                    for i,v in pairs(self.Settings.Box) do
                        self.RenderedObjects.BoxOutline[i] = v
                    end

                    local BorderSettings = {
                        Visible = self.Settings.Box.Visible,
                        Color = Color3.new(0,0,0),
                        Filled = false,
                        Transparency = 1,
                        Thickness = self.Settings.Box.Thickness + 2
                    }

                    for i,v in pairs(BorderSettings) do
                        self.RenderedObjects.BoxEsp[i] = v
                    end

                    local RootPosition, RootVis = workspace.CurrentCamera:WorldToViewportPoint(self.Root.Position)
                    local HeadPosition = workspace.CurrentCamera:WorldToViewportPoint(self.Head.Position + Vector3.new(0, 0.5, 0))
                    local LegPosition = workspace.CurrentCamera:WorldToViewportPoint(self.Root.Position - Vector3.new(0, 3, 0))

                    self.RenderedObjects.BoxEsp.Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    self.RenderedObjects.BoxEsp.Position = Vector2.new(RootPosition.X - self.RenderedObjects.BoxEsp.Size.X / 2, RootPosition.Y - self.RenderedObjects.BoxEsp.Size.Y / 2)

                    self.RenderedObjects.BoxOutline.Position = Vector2.new(RootPosition.X - self.RenderedObjects.BoxOutline.Size.X / 2, RootPosition.Y - self.RenderedObjects.BoxOutline.Size.Y / 2)
                    self.RenderedObjects.BoxOutline.Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                    
                end

                if self.RenderedObjects.Tracer then
                    for i,v in pairs(self.Settings.Tracer) do
                        self.RenderedObjects.TracerOutline[i] = v
                    end

                    local BorderSettings = {
                        Visible = self.Settings.Tracer.Visible,
                        Color = Color3.new(0,0,0),
                        Filled = false,
                        Transparency = 1,
                        Thickness = self.Settings.Tracer.Thickness + 2
                    }

                    for i,v in pairs(BorderSettings) do
                        self.RenderedObjects.Tracer[i] = v
                    end

                    self.RenderedObjects.TracerOutline.From = (self.Settings.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Settings.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Settings.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    self.RenderedObjects.TracerOutline.To = Vector2.new(WorldPosition.X, WorldPosition.Y)

                    self.RenderedObjects.Tracer.Visible = self.Settings.Tracer.Outline
                    self.RenderedObjects.Tracer.From = (self.Settings.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Settings.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Settings.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    self.RenderedObjects.Tracer.To = Vector2.new(WorldPosition.X, WorldPosition.Y)
                end
            end
        else
            for _,object in pairs(self.RenderedObjects) do
                if typeof(object) ~= "Instance" then
                    object.Visible = false
                end
            end
        end
    end)

    return self
end

function EspLibrary:Destruct()
    --# ugly part
    if self.RenderedObjects.Chams then self.RenderedObjects.Chams:Destroy() end
    if self.RenderedObjects.TextEsp then self.RenderedObjects.TextEsp:Remove() end
    if self.RenderedObjects.BoxEsp then self.RenderedObjects.BoxEsp:Remove() end
    if self.RenderedObjects.BoxOutline then self.RenderedObjects.BoxOutline:Remove() end
    if self.RenderedObjects.Tracer then self.RenderedObjects.Tracer:Remove() end
    if self.RenderedObjects.TracerOutline then self.RenderedObjects.TracerOutline:Remove() end
    --# end of ugly part

    self.EspRemoved:Fire(true)
    self.Connection:Disconnect()
    table.clear(self)
end

function EspLibrary:BuildChams(Settings)
    self.RenderedObjects.Chams = Instance.new("Highlight")
    self.RenderedObjects.Chams.Parent = (gethui and gethui()) or game:GetService("CoreGui")
    self.Settings.Chams = {
        FillColor = Color3.fromRGB(255, 0, 0),
        FillTransparency = 0.5,
        OutlineColor = Color3.new(1,1,1),
        OutlineTransparency = 0,
        DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
        Enabled = true
    }

    for i,v in pairs(Settings or {}) do
        self.Settings.Chams[i] = v
    end
end

function EspLibrary:BuildText(Settings)
    self.RenderedObjects.TextEsp = Drawing.new("Text")
    self.Settings.Text = {
        Visible = true,
        Color = Color3.new(1,1,1),
        Transparency = 1,
        Text = "Esp Object",
        Size = 12,
        Outline = true,
        OutlineColor = Color3.new(0,0,0),
        Center = false,
        Font = 1,
    }

    for i,v in pairs(Settings or {}) do
        self.Settings.Text[i] = v
    end
end

function EspLibrary:BuildBox(Settings)
    assert(self.IsPlayer, "[Horizon Box Esp] Box esp cannot be used in a part!", 1)
    self.RenderedObjects.BoxEsp = Drawing.new("Square")
    self.RenderedObjects.BoxOutline = Drawing.new("Square")
    self.Settings.Box = {
        Visible = true,
        Color = Color3.new(1,1,1),
        Filled = false,
        Transparency = 1,
        Thickness = 1
    }

    for i,v in pairs(Settings or {}) do
        self.Settings.Box[i] = v
    end
end

function EspLibrary:BuildTracer(Settings)
    self.RenderedObjects.Tracer = Drawing.new("Line")
    self.RenderedObjects.TracerOutline = Drawing.new("Line")
    self.Settings.Tracer = {
        Visible = true,
        Color = Color3.new(1,1,1),
        Transparency = 1,
        Thickness = 1,
        TracerPosition = "Bottom",
        From = Vector2.new(0.5, 1),
        Outline = true
    }

    for i,v in pairs(Settings or {}) do
        self.Settings.Tracer[i] = v
    end
end

return EspLibrary