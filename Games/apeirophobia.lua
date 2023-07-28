-------------
-- Libraries
-------------

for i,v in pairs(game:GetService("CoreGui"):GetChildren()) do
    if v:FindFirstChild("TextButton") then
        v:Destroy()
    end
end

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = '[Horizon] Apeirophobia',
    Center = true,
    AutoShow = true,
    TabPadding = 0,
    MenuFadeTime = 0.2
})

local HorizonEspLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AzureGP/Horizon/main/Assets/EspLibrary.lua"))()

-------------
-- Variables
-------------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

local Tabs = {
    -- Creates a new tab titled Main
    Local = Window:AddTab('Local Player'),
    Visuals = Window:AddTab('Visuals'),
}

---------------
-- Main Script
---------------

-- Local Player things here later ok

local EspBox = Tabs.Visuals:AddLeftGroupbox('Entity Esp')

local EspConfig = {
    Entities = {
        Chams = {
            FillColor = Color3.fromRGB(255, 0, 0),
            FillTransparency = 0.5,
            OutlineColor = Color3.new(1,1,1),
            OutlineTransparency = 0,
            Enabled = false
        },
        Text = {
            Visible = false,
            Color = Color3.new(1,1,1),
            Transparency = 1,
            Size = 12,
            Outline = true,
            OutlineColor = Color3.new(0,0,0),
            Center = false,
            Font = 1,
        },
    },
    Objectives = {},
    Players = {}
}


-- Chams
EspBox:AddToggle('EnableChams', {
    Text = 'Enable Chams',
    Default = false,

    Callback = function(v)
        EspConfig.Entities.Chams.Enabled = v
    end
})

EspBox:AddLabel('Fill Color'):AddColorPicker('EntityFillHighlight', {
    Default = Color3.new(1, 0, 0),    Title = 'Fill Color',
    Transparency = 0.5,
})

Options.EntityFillHighlight:OnChanged(function()
    EspConfig.Entities.Chams.FillColor = Options.EntityFillHighlight.Value
    EspConfig.Entities.Chams.FillTransparency = Options.EntityFillHighlight.Transparency
end)

EspBox:AddLabel('Outline Color'):AddColorPicker('EntityOutlineHighlight', {
    Default = Color3.new(1, 1, 1),    Title = 'Outline Color',
    Transparency = 0,
})

Options.EntityOutlineHighlight:OnChanged(function()
    EspConfig.Entities.Chams.OutlineColor = Options.EntityOutlineHighlight.Value
    EspConfig.Entities.Chams.OutlineTransparency = Options.EntityOutlineHighlight.Transparency
end)

EspBox:AddDivider()

EspBox:AddToggle('EnableChams', {
    Text = 'Enable Text',
    Default = false,

    Callback = function(v)
        EspConfig.Entities.Text.Visible = v
    end
})

EspBox:AddLabel('Text Color'):AddColorPicker('EntityTextColor', {
    Default = Color3.new(1, 1, 1), Title = 'Text Color',
    Callback = function(v)
        EspConfig.Entities.Text.Color = v
    end
})

EspBox:AddToggle('EntityOutline', {
    Text = 'Outline',
    Default = true,

    Callback = function(v)
        EspConfig.Entities.Text.Outline = v
    end
})

local function ConnectEntityEsp(entity)
    if not entity:IsA("Folder") then
        local EspObject = HorizonEspLibrary.new(entity.HumanoidRootPart, entity, MaxDistance)
        EspObject:BuildChams(EspConfig.Entities.Chams)
        EspObject:BuildText(EspConfig.Entities.Text)

        local Connection
        EspObject.EspRemoved.Event:Connect(function()
            Connection:Disconnect()
        end)

        Connection = RunService.RenderStepped:Connect(function()
            for i,v in pairs(EspConfig.Entities.Chams) do
                EspObject.Settings.Chams[i] = v
            end
            for i,v in pairs(EspConfig.Entities.Text) do
                EspObject.Settings.Text[i] = v
            end
        end)
    end
end

for _,entity: Model in pairs(game.Workspace.Entities:GetChildren()) do
    ConnectEntityEsp(entity)
end