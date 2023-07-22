getgenv().HorizonLoaded = true
if getgenv().OldHorizon ~= nil then getgenv().OldHorizon:Destroy() end

-------------
-- Variables.
-------------

local HorizonLibrary = {}
HorizonLibrary.__index = HorizonLibrary

local Horizon = game:GetObjects("rbxassetid://13702709348")[1]
Horizon.Parent = game:GetService("CoreGui")

local TweenService = game:GetService("TweenService")
local RunSevice = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

getgenv().OldHorizon = Horizon

--------
-- Init.
--------

function HorizonLibrary.new()
    assert(getgenv().HorizonLoaded == true, "Failed to load horizon")

    local Settings = {Config = {}, Modules = {Default = {}, Legit = {}}, ToggleBind = Enum.KeyCode.RightControl}
    local self = setmetatable(Settings, Horizon)

    

    return self
end