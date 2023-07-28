-- Variables

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ViewportSize = workspace.CurrentCamera.ViewportSize

local Managers = {}

-- Esp Object

local Manager = {}
Manager.__index = Manager

function Manager.new(Configuration)
    local self = setmetatable({}, Manager)
    
    -- Data
    self.Objects = {}
    self.Configuration = {
        Enabled = true,
        MaxDistance = Configuration.MaxDistance,
        Chams = {
            FillColor = Color3.fromRGB(255, 0, 0),
            FillTransparency = 0.5,
            OutlineColor = Color3.new(1,1,1),
            OutlineTransparency = 0,
            DepthMode = Enum.HighlightDepthMode.AlwaysOnTop,
            Enabled = true
        },
        Text = {
            Visible = true,
            Color = Color3.new(1,1,1),
            Transparency = 1,
            Text = "Esp Object", -- Keywords: "{name}" will return the object's name, "{distance}" will return the distance of the object from the camera
            Size = 12,
            Outline = true,
            OutlineColor = Color3.new(0,0,0),
            Center = false,
            Font = 1
        },
        Box = {
            Visible = true,
            Color = Color3.new(1,1,1),
            Filled = false,
            Transparency = 1,
            Thickness = 1
        },
        Tracer = {
            Visible = true,
            Color = Color3.new(1,1,1),
            Transparency = 1,
            Thickness = 1,
            TracerPosition = "Bottom",
            From = Vector2.new(0.5, 1),
            Outline = true
        }
    }

    self.Cache = {}

    for _,Settings in pairs(Configuration.Settings or {}) do
        for Property,Value in pairs(Settings) do
            self.Configuration[_][Property] = Value
        end
    end

    self.AvailableTypes = Configuration.Types

    for _,Object in pairs(Configuration.Objects) do
        local NewObject = {}
        self.Objects[#self.Objects+1] = NewObject
        NewObject.Object = (typeof(Object) == "table" and Object[1]) or Object
        NewObject.Types = {}

        for _,Type in pairs(self.AvailableTypes) do
            if Type == "Box" then
                NewObject.Types.BoxOutline = Drawing.new("Square")
                table.insert(self.Cache, NewObject.Types.BoxOutline)

                NewObject.Types.BoxOutline.Visible = self.Configuration.Box.Visible
                NewObject.Types.BoxOutline.Color = Color3.new(0,0,0)
                NewObject.Types.BoxOutline.Filled = false
                NewObject.Types.BoxOutline.Transparency = 1
                NewObject.Types.BoxOutline.Thickness = self.Configuration.Box.Thickness + 2
            end

            if Type == "Tracer" then
                NewObject.Types.TracerOutline = Drawing.new("Line")
                table.insert(self.Cache, NewObject.Types.TracerOutline)

                NewObject.Types.TracerOutline.Visible = self.Configuration.Tracer.Visible
                NewObject.Types.TracerOutline.Color = Color3.new(0,0,0)
                NewObject.Types.TracerOutline.Transparency = 1
                NewObject.Types.TracerOutline.Thickness = self.Configuration.Tracer.Thickness + 2
            end
            
            NewObject.Types[Type] = self:DrawObject(Type)
            table.insert(self.Cache, NewObject.Types[Type])
        end

        NewObject.IsPlayer = (game.Players:GetPlayerFromCharacter(NewObject.Object.Parent) and true) or false
        if NewObject.IsPlayer then
            NewObject.Player = game.Players:GetPlayerFromCharacter(NewObject.Object.Parent)
            NewObject.Character = NewObject.Player.Character
            NewObject.Humanoid = NewObject.Character.Humanoid
        end
        
        if typeof(Object) == "table" and Object[2] then
            NewObject.ParentObject = Object[2]
        end
    end

    table.insert(Managers, self)

    return self
end

function Manager:UpdateObjects()
    for _,object in pairs(self.Objects) do
        local WorldPosition, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(object.Object:GetPivot().Position) 
        local OnRange = WorldPosition.Z < self.Configuration.MaxDistance
        
        if OnScreen and OnRange then
            if object.IsPlayer then
                if not Players:FindFirstChild(object.Player.Name) or not object.Character or not object.Humanoid or object.Humanoid.Health == 0 then
                    self:RemoveObject(object.Object)
                    return
                end
            else
                if not object.Object or not object.Object.Parent then
                    self:RemoveObject(object.Object)
                    return
                end
            end

            for drawingType,_ in pairs(object.Types) do
                if drawingType ~= "BoxOutline" and drawingType ~= "TracerOutline" then
                    for property, value in pairs(self.Configuration[drawingType]) do
                        object.Types[drawingType][property] = value
                    end
                end
            end

            if object.Types.Chams then
                object.Types.Chams.Adornee = (object.IsPlayer and object.Character) or (object.ParentObject ~= nil and object.ParentObject) or object.Object
            end
            
            if object.Types.Text then
                local TextBounds = object.Types.Text.TextBounds
                object.Types.Text.Position = Vector2.new(WorldPosition.X, WorldPosition.Y) - TextBounds * 0.5
                object.Types.Text.Text = object.Types.Text.Text:gsub("{name}", object.Object.Name):gsub("{distance}", WorldPosition.Z)
            end

            if object.Types.Box then
                object.Types.BoxOutline.Thickness = self.Configuration.Box.Thickness + 2

                local RootPosition, RootVis = workspace.CurrentCamera:WorldToViewportPoint(object.Character.HumanoidRootPart.Position)
                local HeadPosition = workspace.CurrentCamera:WorldToViewportPoint(object.Character.Head.Position + Vector3.new(0, 0.5, 0))
                local LegPosition = workspace.CurrentCamera:WorldToViewportPoint(object.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0))

                object.Types.Box.Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                object.Types.Box.Position = Vector2.new(RootPosition.X - object.Types.Box.Size.X / 2, RootPosition.Y - object.Types.Box.Size.Y / 2)
                object.Types.BoxOutline.Position = Vector2.new(RootPosition.X - object.Types.BoxOutline.Size.X / 2, RootPosition.Y - object.Types.BoxOutline.Size.Y / 2)
                object.Types.BoxOutline.Size = Vector2.new(ViewportSize.X / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
            end

            if object.Types.Tracer then
                object.Types.TracerOutline.Thickness = self.Configuration.Tracer.Thickness + 2

                object.Types.TracerOutline.From =  (self.Configuration.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Configuration.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Configuration.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                object.Types.TracerOutline.To =  Vector2.new(WorldPosition.X, WorldPosition.Y)

                object.Types.Tracer.From =  (self.Configuration.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Configuration.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Configuration.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                object.Types.Tracer.To =  Vector2.new(WorldPosition.X, WorldPosition.Y)
            end

            --[[
                    self.RenderedObjects.TracerOutline.From = (self.Settings.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Settings.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Settings.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    self.RenderedObjects.TracerOutline.To = Vector2.new(WorldPosition.X, WorldPosition.Y)

                    self.RenderedObjects.Tracer.Visible = self.Settings.Tracer.Outline
                    self.RenderedObjects.Tracer.From = (self.Settings.Tracer.TracerPosition == "Bottom" and Vector2.new(ViewportSize.X / 2, ViewportSize.Y)) or (self.Settings.Tracer.TracerPosition == "Middle" and ViewportSize * 0.5) or (self.Settings.Tracer.TracerPosition == "Top" and Vector2.new(ViewportSize.X / 2, 0)) or Vector2.new(ViewportSize.X / 2, ViewportSize.Y)
                    self.RenderedObjects.Tracer.To = Vector2.new(WorldPosition.X, WorldPosition.Y)
]]
        else
            for drawingType,_ in pairs(object.Types) do
                for property, value in pairs(self.Configuration[drawingType:gsub("Outline", "")]) do
                    object.Types[drawingType][drawingType == "Chams" and "Enabled" or "Visible"] = false
                end
            end
        end
    end
end

function Manager:Eject()
    for i,drawing in pairs(self.Cache) do
        task.spawn(function()
            if typeof(drawing) == "Instance" and drawing:IsA("Highlight") then
                drawing:Destroy()
            else
                pcall(function()
                    drawing:Remove()
                end)
            end
        end)
    end

    table.remove(Managers, table.find(Managers, self))
    table.clear(self)
end

function Manager:DrawObject(Type)
    local Object = (Type ~= "Chams" and Drawing.new((Type == "Box" and "Square") or (Type == "Tracer" and "Line") or Type)) or Instance.new("Highlight", gethui and gethui() or game:GetService("CoreGui"))

    for Property, Value in pairs(self.Configuration[Type]) do
        Object[Property] = Value
    end

    return Object
end

function Manager:RemoveObject(Object)
    for _,object in ipairs(self.Objects) do
        if object.Object == Object then
            for _,drawing in pairs(object.Types) do
                if typeof(drawing) == "Instance" and drawing:IsA("Highlight") then
                    drawing:Destroy()
                else
                    drawing:Remove()
                end
            end

            table.remove(self.Objects, _)
        end
    end
end

function Manager:AddInstance(Object)
    if typeof(Object) == "table" then
        for i,v in pairs(Object) do
            local NewObject = {}
            self.Objects[#self.Objects+1] = NewObject
            NewObject.Object = (typeof(v) == "table" and v[1]) or v
            NewObject.Types = {}

            for _,Type in pairs(self.AvailableTypes) do
                if Type == "Box" then
                    NewObject.Types.BoxOutline = Drawing.new("Square")
                    table.insert(self.Cache, NewObject.Types.BoxOutline)

                    NewObject.Types.BoxOutline.Visible = self.Configuration.Box.Visible
                    NewObject.Types.BoxOutline.Color = Color3.new(0,0,0)
                    NewObject.Types.BoxOutline.Filled = false
                    NewObject.Types.BoxOutline.Transparency = 1
                    NewObject.Types.BoxOutline.Thickness = self.Configuration.Box.Thickness + 2
                end

                if Type == "Tracer" then
                    NewObject.Types.TracerOutline = Drawing.new("Line")
                    table.insert(self.Cache, NewObject.Types.BoxOutline)

                    NewObject.Types.TracerOutline.Visible = self.Configuration.Tracer.Visible
                    NewObject.Types.TracerOutline.Color = Color3.new(0,0,0)
                    NewObject.Types.TracerOutline.Transparency = 1
                    NewObject.Types.TracerOutline.Thickness = self.Configuration.Tracer.Thickness + 2
                end
                
                NewObject.Types[Type] = self:DrawObject(Type)
                table.insert(self.Cache, NewObject.Types[Type])
            end

            NewObject.IsPlayer = (game.Players:GetPlayerFromCharacter(NewObject.Object.Parent) and true) or false
            if NewObject.IsPlayer then
                NewObject.Player = game.Players:GetPlayerFromCharacter(NewObject.Object.Parent)
                NewObject.Character = NewObject.Player.Character
                NewObject.Humanoid = NewObject.Character.Humanoid
            end
            
            if typeof(NewObject.Object) == "table" then
                NewObject.ParentObject = Object[2]
            end
        end
    else
        local NewObject = {}
        self.Objects[#self.Objects+1] = NewObject
        NewObject.Object = (typeof(Object) == "table" and Object[1]) or Object
        NewObject.Types = {}

        for _,Type in pairs(self.AvailableTypes) do
            if Type == "Box" then
                NewObject.Types.BoxOutline = Drawing.new("Square")
                table.insert(self.Cache, NewObject.Types.BoxOutline)

                NewObject.Types.BoxOutline.Visible = self.Configuration.Box.Visible
                NewObject.Types.BoxOutline.Color = Color3.new(0,0,0)
                NewObject.Types.BoxOutline.Filled = false
                NewObject.Types.BoxOutline.Transparency = 1
                NewObject.Types.BoxOutline.Thickness = self.Configuration.Box.Thickness + 2
            end

            if Type == "Tracer" then
                NewObject.Types.TracerOutline = Drawing.new("Line")
                table.insert(self.Cache, NewObject.Types.BoxOutline)

                NewObject.Types.TracerOutline.Visible = self.Configuration.Tracer.Visible
                NewObject.Types.TracerOutline.Color = Color3.new(0,0,0)
                NewObject.Types.TracerOutline.Transparency = 1
                NewObject.Types.TracerOutline.Thickness = self.Configuration.Tracer.Thickness + 2
            end
            
            NewObject.Types[Type] = self:DrawObject(Type)
            table.insert(self.Cache, NewObject.Types[Type])
        end

        NewObject.IsPlayer = (game.Players:GetPlayerFromCharacter(NewObject.Object.Parent) and true) or false
        if NewObject.IsPlayer then
            NewObject.Player = game.Players:GetPlayerFromCharacter(NewObject.Object.Parent)
            NewObject.Character = NewObject.Player.Character
            NewObject.Humanoid = NewObject.Character.Humanoid
        end
        
        if typeof(NewObject.Object) == "table" then
            NewObject.ParentObject = Object[2]
        end
    end
end

RunService:BindToRenderStep("EspUpdating", 5, function()
    for _,ESPManager in pairs(Managers) do
        ESPManager:UpdateObjects()
    end
end)

return Manager