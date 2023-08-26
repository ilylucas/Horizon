--[[
    Horizon UI Library
    Credits to Linoria and Rayfield libraries
]]

-- Preloading

getgenv().HorizonLoaded = true

if shared.LastHorizon then
    shared.LastHorizon:Destroy()
end

------------
-- Variables
------------

local Interface = game:GetObjects("rbxassetid://14485491052")[1]
local Horizon = {
    -- Settings stuff
    Settings = {},
    ToggleKeybind = "V"
}

shared.LastHorizon = Interface

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Player, PlayerMouse = game:GetService("Players").LocalPlayer, game:GetService("Players").LocalPlayer:GetMouse()

------------
-- Functions
------------

function Horizon:SafeCallback(Function, ...)
    if not f then
        return
    end

    local Success, Error = pcall(f, ...)

    if not Success then
        local _, i = string.find(Error, ":%d+: ")

        if not i then
            return error(Error, 3)
        end

        return error(Error:sub(i + 1), 3)
    end
end

function Horizon:MakeDraggable(Object, DragPoint)
    pcall(function()
        local Dragging, DragInput, MousePos, FramePos = false

        DragPoint.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                MousePos = Input.Position
                FramePos = Object.Position

                Input.Changed:Connect(function()
                    if Input.UserInputState == Enum.UserInputState.End then
                        Dragging = false
                    end
                end)
            end
        end)
        DragPoint.InputChanged:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                DragInput = Input
            end
        end)
        UserInputService.InputChanged:Connect(function(Input)
            if not DragPoint then return end
            if Input == DragInput and Dragging then
                local Delta = Input.Position - MousePos
                TweenService:Create(Object, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
            end
        end)
    end)
end

function Horizon:PlayTween(...)
    local Args = {...}

    if typeof(Args[1]) == "number" then
        return task.delay(Args[1], function()
            Args[2]:Play()
        end)
    end

    return Args[1]:Play()
end

function Horizon:WriteFolder(path)
    if not isfolder(path) then
        makefolder(path)
    end
end

function Horizon:WriteFile(path, content)
    if not isfile(path) then
        writefile(path, content)
    end
end

------------------------
-- Ugly file system part
------------------------

Horizon:WriteFolder("Horizon")
Horizon:WriteFolder("Horizon/Cache")

---------------
-- Library Code
---------------

local Notifications = Interface.Notifications

function Horizon:Notify(Configuration)
    local Notification = Notifications.Notification:Clone()

    Notification.Content.Text = Configuration.Content
    Notification.Parent = Notifications
    Notification.Size = UDim2.new(0, 0, 0, Notification.Content.TextBounds.Y + 26)
    Notification.Content.Size = UDim2.new(0, 264, 0, Notification.Content.TextBounds.Y)
    Notification.Visible = true

    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://8458409341"
    Sound:Play()

    Horizon:PlayTween(TweenService:Create(Notification, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 320, 0, Notification.Content.TextBounds.Y + 26)}))
    Horizon:PlayTween(0.2, TweenService:Create(Notification.Border, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0.023, 0, 1, 0)}))

    task.wait(Configuration.Duration)

    Sound:Destroy()
    Horizon:PlayTween(TweenService:Create(Notification, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0, Notification.Content.TextBounds.Y + 26)}))
end

function Horizon:CreateNewGui(func, modal)
    local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end)

    Interface.Parent = CoreGui
    ProtectGui(Interface)

    local Main = Interface.Main
    local Loading = Main.Loading

    Horizon:PlayTween(TweenService:Create(Main, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Size = Main:GetAttribute("LoadingSize")}))
        Horizon:PlayTween(TweenService:Create(Main, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
        Horizon:PlayTween(TweenService:Create(Main.DropShadow, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}))

    if not isfile("Horizon/Cache/Key.txt") or func(readfile("Horizon/Cache/Key.txt")) == false then
        Horizon:PlayTween(0.3, TweenService:Create(Loading.Logo, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
        Horizon:PlayTween(0.4, TweenService:Create(Loading.Key, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
        Horizon:PlayTween(0.4, TweenService:Create(Loading.Key, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {TextTransparency = 0}))
        Horizon:PlayTween(0.5, TweenService:Create(Loading.Key.Login, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
        Horizon:PlayTween(0.5, TweenService:Create(Loading.Key.Login, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {TextTransparency = 0}))
        Horizon:PlayTween(0.6, TweenService:Create(Loading.Contact, TweenInfo.new(1.65, Enum.EasingStyle.Quint), {TextTransparency = 0}))
        task.wait(0.6)
        Horizon:MakeDraggable(Main, Loading)

        Loading.Contact.MouseEnter:Connect(function()
            Loading.Contact.Text = "<u>Join the discord (Key)</u>"

            Loading.Contact.MouseLeave:Wait()
            Loading.Contact.Text = "Join the discord (Key)"
        end)

        Loading.Contact.MouseButton1Click:Connect(function()
            setclipboard("Ola!")
        end)

        Loading.Key:GetPropertyChangedSignal("Text"):Connect(function()
            if Loading.Key.Text ~= ("" or " ") then
                return Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}))
            end

            return Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))
        end)

        Loading.Key.Login.MouseEnter:Connect(function()
            if Loading.Key.Text ~= ("" or " ") then
                Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 125, 225)}))

                Loading.Key.Login.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}))
            end
        end)

        local Passthrough = false

        Loading.Key.Login.MouseButton1Down:Connect(function()
            Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.1, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 75, 180)}))

            Loading.Key.Login.MouseButton1Up:Wait()
            Horizon:PlayTween(TweenService:Create(Loading.Key.Login, TweenInfo.new(0.35, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}))

            local KeyResult = func(Loading.Key.Text)
            if KeyResult == true then
                Horizon:PlayTween(0.3, TweenService:Create(Loading.Logo, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 1}))
                Horizon:PlayTween(0.4, TweenService:Create(Loading.Key, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                Horizon:PlayTween(0.4, TweenService:Create(Loading.Key, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))
                Horizon:PlayTween(0.5, TweenService:Create(Loading.Key.Login, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                Horizon:PlayTween(0.5, TweenService:Create(Loading.Key.Login, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))
                Horizon:PlayTween(0.6, TweenService:Create(Loading.Contact, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))

                writefile("Horizon/Cache/Key.Txt", Loading.Key.Text)
                Passthrough = true
            end 
        end)

        repeat task.wait() until Passthrough
    else
        Horizon:PlayTween(TweenService:Create(Loading.Logo, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Position = UDim2.new(0.295, 0, 0.4, 0)}))
        Horizon:PlayTween(0.2, TweenService:Create(Loading.Logo, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}))

        task.wait(1.5)
        Horizon:PlayTween(TweenService:Create(Loading.Logo, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 1}))
    end

    Horizon:PlayTween(1, TweenService:Create(Main, TweenInfo.new(1.3, Enum.EasingStyle.Quint), {Size = Main:GetAttribute("LoadedSize")}))
    task.wait(2.5)

    Loading:Destroy()
    Horizon:MakeDraggable(Main, Main.Topbar)

    Horizon:PlayTween(TweenService:Create(Main.Topbar, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 40)}))
    Horizon:PlayTween(TweenService:Create(Main.Sidebar, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, .896, 0)}))
    Horizon:PlayTween(.1, TweenService:Create(Main.Topbar.Logo, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
    Horizon:PlayTween(.2, TweenService:Create(Main.Topbar.More, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
    Horizon:PlayTween(.3, TweenService:Create(Main.Topbar.Close, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}))

    task.delay(0.5, function()
        Main.Topbar.ClipsDescendants = false
        Horizon:PlayTween(TweenService:Create(Main.Topbar.Separator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
    end)

    for _,Button in pairs(Main.Topbar:GetChildren()) do
        if Button:IsA("ImageButton") then
            Button.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Button.HoverShadow, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 27, 0, 27)}))
                Horizon:PlayTween(TweenService:Create(Button.HoverShadow, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))

                Button.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Button.HoverShadow, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0, 0)}))
                Horizon:PlayTween(TweenService:Create(Button.HoverShadow, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
            end)
        end
    end
    for _,temp in pairs(Main.Topbar.MoreDropdown:GetChildren()) do
        if temp:IsA("TextButton") then
            temp.Name = temp.Text
        end
    end

    Main.Topbar.MoreDropdown.DropShadow.ImageTransparency = 1

	if modal then
		Main.Topbar.Close.Modal = true
	end

    Main.Topbar.More.MouseButton1Click:Connect(function()
        if Main.Topbar.MoreDropdown.Size == UDim2.new(0, 171, 0, 0) then
            Horizon:PlayTween(TweenService:Create(Main.Topbar.MoreDropdown, TweenInfo.new(.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 171, 0, 80)}))
            Horizon:PlayTween(0.1, TweenService:Create(Main.Topbar.MoreDropdown.Modules, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 0}))
            Horizon:PlayTween(0.3, TweenService:Create(Main.Topbar.MoreDropdown.Settings, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 0}))
        
            
            task.delay(0.3, function()
                Main.Topbar.MoreDropdown.ClipsDescendants = false
                Horizon:PlayTween(TweenService:Create(Main.Topbar.MoreDropdown.DropShadow, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}))
            end)
        else
            Horizon:PlayTween(TweenService:Create(Main.Topbar.MoreDropdown.DropShadow, TweenInfo.new(.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}))
        
            task.delay(0.1, function()
                Main.Topbar.MoreDropdown.ClipsDescendants = true
                Horizon:PlayTween(TweenService:Create(Main.Topbar.MoreDropdown, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 171, 0, 0)}))
                Horizon:PlayTween(0.3, TweenService:Create(Main.Topbar.MoreDropdown.Modules, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))
                Horizon:PlayTween(0.1, TweenService:Create(Main.Topbar.MoreDropdown.Settings, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))
            end)
        end
    end)

    -------------
    -- Components
    -------------

    -- Tabs
    local TabList = Main.Tabs
    local Components = TabList.Example
    local Sidebar = Main.Sidebar
    local FirstTab = true
    local Tabs = {}

    TabList.Visible = true
    Components.Visible = false

    Components.Parent = nil

    Sidebar.InputBegan:Connect(function()
        Horizon:PlayTween(TweenService:Create(Sidebar, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 230, .896, 0)}))
        
        for _, Tab in pairs(Tabs) do
            if typeof(_) == "number" then
                Horizon:PlayTween(TweenService:Create(Tab.Button, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 220, 0, 40)}))
                Horizon:PlayTween(TweenService:Create(Tab.Button.Title, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 40, 0, 0)}))
                Horizon:PlayTween(TweenService:Create(Tab.Button.Title, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 0}))
            end
        end

        Sidebar.InputEnded:Wait()

        Horizon:PlayTween(TweenService:Create(Sidebar, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, .896, 0)}))
        
        for _, Tab in pairs(Tabs) do
            if typeof(_) == "number" then
                Horizon:PlayTween(TweenService:Create(Tab.Button, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 40, 0, 40)}))
                Horizon:PlayTween(TweenService:Create(Tab.Button.Title, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 52, 0, 0)}))
                Horizon:PlayTween(TweenService:Create(Tab.Button.Title, TweenInfo.new(.8, Enum.EasingStyle.Quint), {TextTransparency = 1}))
            end
        end
    end)
    
    function Tabs:AddTab(Name, Icon)
        local TabData = {Elements = {}}
        local TabButton = Sidebar.Example:Clone()
        TabButton.Parent = Sidebar
        TabButton.Name = Name
        TabButton.Title.Text = Name
        TabButton.Icon.Image = string.format("rbxassetid://%s", Icon)
        TabButton.Visible = true
        TabButton.AutoButtonColor = false
        TabButton.SelectionIndicator.Size = UDim2.new(0, 5, 0, 0)
        TabData.Button = TabButton

        local Page = Components:Clone()
        Page.Parent = TabList
        Page.Name = Name
        Page.Visible = true
        TabData.Page = Page

        Horizon:PlayTween(TweenService:Create(TabButton.Icon, TweenInfo.new(.8, Enum.EasingStyle.Quint), {ImageTransparency = 0}))

        if FirstTab == true then
            Horizon:PlayTween(TweenService:Create(TabButton, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
            Horizon:PlayTween(TweenService:Create(TabButton.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            Horizon:PlayTween(TweenService:Create(TabButton.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0.5, 0)}))
            FirstTab = false
        end

        TabButton.MouseEnter:Connect(function()
            if TabList.UIPageLayout.CurrentPage ~= Page then
                Horizon:PlayTween(TweenService:Create(TabButton, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))

                TabButton.MouseLeave:Wait()
                if TabList.UIPageLayout.CurrentPage == Page then return end
                Horizon:PlayTween(TweenService:Create(TabButton, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
            end
        end)

        TabButton.MouseButton1Click:Connect(function()
            if TabList.UIPageLayout.CurrentPage == Page then return end

            for _, Button in pairs(Sidebar:GetChildren()) do
                if Button:IsA("TextButton") and Button ~= TabButton then
                    Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                    Horizon:PlayTween(TweenService:Create(Button.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                    Horizon:PlayTween(TweenService:Create(Button.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0, 0)}))

                end
            end

            Horizon:PlayTween(TweenService:Create(TabButton, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
            Horizon:PlayTween(TweenService:Create(TabButton.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            Horizon:PlayTween(TweenService:Create(TabButton.SelectionIndicator, TweenInfo.new(.8, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0.5, 0)}))
            TabList.UIPageLayout:JumpTo(Page)
        end)

        for _,Component in pairs(Page:GetChildren()) do
            if Component:IsA("GuiObject") then
                Component:Destroy()
            end
        end

        local FadeCached = false

        -- Section
        function TabData:AddSection(Name)
            local Section = Components.Section:Clone()
            Section.Text = Name
            Section.Parent = Page
            Section.Visible = true

            task.spawn(function()
                Section.TextTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Section, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0.3}))
            end)

            table.insert(TabData.Elements, Section)
        end

        -- Label
        function TabData:AddLabel(ContentLabel)
            local Label = Components.Label:Clone()
            Label.Title.Text = ContentLabel
            Label.Parent = Page
            Label.Size = UDim2.new(0.99, 0, 0, Label.Title.TextBounds.Y + 31)
            Label.Visible = true

            task.spawn(function()
                Label.BackgroundTransparency = 1
                Label.Title.TextTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Label, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Label.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
            end)

            table.insert(TabData.Elements, Section)
        end
        
        -- Button
        function TabData:AddButton(Name, Configuration)
            local Button = Components.Button:Clone()
            Button.Title.Text = Name
            Button.Parent = Page
            Button.Visible = true

            task.spawn(function()
                Button.BackgroundTransparency = 1
                Button.Title.TextTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Button.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
            end)

            Button.Interact.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))

                Button.Interact.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            Button.Interact.MouseButton1Click:Connect(function()
                Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(18,18,18)}))
                Configuration.Callback()

                task.wait(0.05)
                Horizon:PlayTween(TweenService:Create(Button, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            table.insert(TabData.Elements, Button)
        end

        -- Keybind
        function TabData:AddKeybind(Name, Configuration)
            local Keybind = Components.Keybind:Clone()
            Keybind.Title.Text = Name
            Keybind.Main.Text = Configuration.CurrentKeybind.Name
            Keybind.Parent = Page
            Keybind.Visible = true

            task.spawn(function()
                Keybind.BackgroundTransparency = 1
                Keybind.Title.TextTransparency = 1
                Keybind.Main.TextTransparency = 1
                Keybind.Main.BackgroundTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Keybind, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Keybind.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Keybind.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Keybind.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            end)

            Keybind.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Keybind, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))

                Keybind.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Keybind, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            Keybind.Main.Focused:Connect(function()
                Keybind.Main.Text = "..."

                local Connection
                Connection = UserInputService.InputBegan:Connect(function(Input)
                    if Input.KeyCode ~= Enum.KeyCode.Unknown then
                        Keybind.Main:ReleaseFocus()
                        Keybind.Main.Text = Input.KeyCode.Name
                        Configuration.CurrentKeybind = Input.KeyCode

                        Connection:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(Input, Chatting)
                if Input.KeyCode == Configuration.CurrentKeybind and not Chatting then
                    Configuration.Callback()
                end
            end)

            table.insert(TabData.Elements, Keybind)
        end

        -- Input
        function TabData:AddInput(Name, Configuration)
            local Input = Components.Input:Clone()
            Input.Title.Text = Name
            Input.Main.Text = Configuration.DefaultInput
            Input.Main.PlaceholderText = ""
            Input.Parent = Page
            Input.Visible = true

            Horizon:PlayTween(TweenService:Create(Input.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, Input.Main.TextBounds.X + 18, 0, 27)}))

            task.spawn(function()
                Input.BackgroundTransparency = 1
                Input.Title.TextTransparency = 1
                Input.Main.TextTransparency = 1
                Input.Main.BackgroundTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Input, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Input.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Input.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Input.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            end)

            Input.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Input, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))

                Input.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Input, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            Input.Main:GetPropertyChangedSignal("Text"):Connect(function()
                Horizon:PlayTween(TweenService:Create(Input.Main, TweenInfo.new(0.2, Enum.EasingStyle.Quint), {Size = UDim2.new(0, Input.Main.TextBounds.X + 18, 0, 27)}))
            end)

            Input.Main.ClearTextOnFocus = Configuration.ClearTextOnFocus

            Input.Main.Focused:Connect(function()
                Input.Main.Text = ""

                Input.Main.FocusEnded:Connect(function()
                    Configuration.Callback(Input.Main.Text)
                end)
            end)

            table.insert(TabData.Elements, Input)
        end

        -- Toggle
        function TabData:AddToggle(Name, Configuration)
            local Toggle = Components.Toggle:Clone()
            Toggle.Title.Text = Name
            Toggle.Parent = Page
            Toggle.Visible = true

            local ComponentFunctions = {}

            task.spawn(function()
                Toggle.BackgroundTransparency = 1
                Toggle.Title.TextTransparency = 1
                Toggle.Main.BackgroundTransparency = 1
                Toggle.Main.Inner.BackgroundTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Toggle, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Toggle.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Toggle.Main.Inner, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Toggle.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
            end)

            Toggle.Interact.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))

                Toggle.Interact.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            function ComponentFunctions:Toggle()
                if Configuration.Active == false then
                    Configuration.Active = true

                    Horizon:PlayTween(TweenService:Create(Toggle.Main.Inner, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 20, 0, 1)}))
                    Horizon:PlayTween(TweenService:Create(Toggle.Main.Inner, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(0, 150, 255)}))
                else
                    Configuration.Active = false
                    Horizon:PlayTween(TweenService:Create(Toggle.Main.Inner, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 1, 0, 1)}))
                    Horizon:PlayTween(TweenService:Create(Toggle.Main.Inner, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}))
                end
                
                Configuration.Callback(Configuration.Active)
            end

            Toggle.Interact.MouseButton1Click:Connect(function()
                Horizon:PlayTween(TweenService:Create(Toggle, TweenInfo.new(0.05, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(18,18,18)}))
                ComponentFunctions:Toggle()

                task.wait(0.05)
                Horizon:PlayTween(TweenService:Create(Toggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
            end)

            if Configuration.Active then
                ComponentFunctions:Toggle()
            end

            table.insert(TabData.Elements, Toggle)
            return ComponentFunctions
        end

        -- Slider
        function TabData:AddSlider(Name, Configuration)
            local Slider = Components.Slider:Clone()
            Slider.Title.Text = Name
            Slider.Parent = Page
            Slider.Visible = true
            Slider.Value.Text = Configuration.CurrentValue.." "..(Configuration.Suffix or "")

            local ComponentLibrary = {}

            task.spawn(function()
                Slider.BackgroundTransparency = 1
                Slider.Title.TextTransparency = 1
                Slider.Value.TextTransparency = 1
                Slider.Main.BackgroundTransparency = 1
                Slider.Main.Inner.BackgroundTransparency = 1
                Slider.Main.Inner.Ball.BackgroundTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Slider, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Slider.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(0.1, TweenService:Create(Slider.Value, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(0.2, TweenService:Create(Slider.Main, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(0.2, TweenService:Create(Slider.Main.Inner, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(0.2, TweenService:Create(Slider.Main.Inner.Ball, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            end)

            Slider.Main.Inner.Ball.Position = UDim2.new(1, 0, 0.5, 0)
            Slider.Main.Inner.Ball.AnchorPoint = Vector2.new(0.5, 0.5)

            Slider.Interact.MouseEnter:Connect(function()
                Horizon:PlayTween(TweenService:Create(Slider.Main.Inner.Ball, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 16, 0, 16)}))

                Slider.Interact.MouseLeave:Wait()
                Horizon:PlayTween(TweenService:Create(Slider.Main.Inner.Ball, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 14, 0, 14)}))
            end)

            

            Slider.Interact.InputBegan:Connect(function(Input)
                if (Input.UserInputType == Enum.UserInputType.MouseButton1) or (Input.UserInputType == Enum.UserInputType.Touch) then
                    local Current = Slider.Main.Inner.AbsolutePosition.X + Slider.Main.Inner.AbsoluteSize.X
                    local Start = Current
                    local Location = X
                    
                    while (Input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)) or (Input.UserInputType == Enum.UserInputType.Touch and UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)) do
                        Location = UserInputService:GetMouseLocation().X
						Current = Current + 0.025 * (Location - Start)

                        if Location < Slider.Main.AbsolutePosition.X then
							Location = Slider.Main.AbsolutePosition.X
						elseif Location > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Location = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

						if Current < Slider.Main.AbsolutePosition.X + 5 then
							Current = Slider.Main.AbsolutePosition.X + 5
						elseif Current > Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X then
							Current = Slider.Main.AbsolutePosition.X + Slider.Main.AbsoluteSize.X
						end

                        if Current <= Location and (Location - Start) < 0 then
							Start = Location
						elseif Current >= Location and (Location - Start) > 0 then
							Start = Location
						end

                        TweenService:Create(Slider.Main.Inner, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, Location - Slider.Main.AbsolutePosition.X > 5 and Location - Slider.Main.AbsolutePosition.X or 5, 1, 0)}):Play()
						local NewValue = Configuration.Range[1] + (Location - Slider.Main.AbsolutePosition.X) / Slider.Main.AbsoluteSize.X * (Configuration.Range[2] - Configuration.Range[1])

						NewValue = math.floor(NewValue / Configuration.Increment + 0.5) * (Configuration.Increment * 10000000) / 10000000
						Slider.Value.Text = NewValue.." "..(Configuration.Suffix or "")

                        if Configuration.CurrentValue ~= NewValue then
                            Configuration.Callback(NewValue)
                        end

                        RunService.RenderStepped:Wait()
                    end
                end
            end)

            table.insert(TabData.Elements, Slider)
            return ComponentLibrary
        end

        -- Dropdown
        function TabData:AddDropdown(Name, Configuration)
            local Dropdown = Components.Dropdown:Clone()
            Dropdown.Title.Text = Name
            Dropdown.Parent = Page
            Dropdown.Visible = true

            Dropdown.Options.Text = table.concat(Configuration.CurrentItems, ", ")

            local ComponentLibrary = {}

            task.spawn(function()
                Dropdown.BackgroundTransparency = 1
                Dropdown.Title.TextTransparency = 1
                Dropdown.Icon.ImageTransparency = 1
                Dropdown.Options.TextTransparency = 1
                repeat task.wait() until FadeCached == false
                FadeCached = true
                task.delay(0.1, function()
                    FadeCached = false
                end)

                Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(1, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Dropdown.Title, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Dropdown.Options, TweenInfo.new(1, Enum.EasingStyle.Quint), {TextTransparency = 0}))
                Horizon:PlayTween(TweenService:Create(Dropdown.Icon, TweenInfo.new(1, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
            end)

            Dropdown.Interact.MouseEnter:Connect(function()
                if Dropdown.Size.Y.Offset == 45 then
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}))

                    Dropdown.Interact.MouseLeave:Wait()
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
                end
            end)

            Dropdown.Interact.MouseButton1Click:Connect(function()
                if Dropdown.Size.Y.Offset == 45 then
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Size = UDim2.new(0.99, 0, 0, 185)}))
                else
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}))
                    Horizon:PlayTween(TweenService:Create(Dropdown, TweenInfo.new(0.9, Enum.EasingStyle.Quint), {Size = UDim2.new(0.99, 0, 0, 45)}))
                end
            end)

            Dropdown.Interact.Size = UDim2.new(1, 0, 0, 45)
            Dropdown.Interact.Position = UDim2.new(0, 0, 0, 0)

            Dropdown.ScrollingFrame.Option.Visible = false

            local Options = {}
            local CurrentOption = (Configuration.MultiOptions and {}) or nil

            function ComponentLibrary:Update()
                if not Configuration.MultiOptions then
                    for i,v in pairs(Dropdown.ScrollingFrame:GetChildren()) do
                        if v:IsA("TextButton") and v.Name ~= CurrentOption then
                            Horizon:PlayTween(TweenService:Create(v.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                            Horizon:PlayTween(TweenService:Create(v.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0, 0)}))
                        end
                    end

                    Dropdown.Options.Text = CurrentOption
                    Horizon:PlayTween(TweenService:Create(Dropdown.ScrollingFrame[CurrentOption].SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                    Horizon:PlayTween(TweenService:Create(Dropdown.ScrollingFrame[CurrentOption].SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0.5, 0)}))
                else
                    for i,v in pairs(Dropdown.ScrollingFrame:GetChildren()) do
                        if v:IsA("TextButton") and not table.find(CurrentOption, v.Name) then
                            Horizon:PlayTween(TweenService:Create(v.SelectionToggle.Inner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
                            Horizon:PlayTween(TweenService:Create(v.SelectionToggle.Inner.ImageDetail, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 1}))
                        elseif v:IsA("TextButton") and table.find(CurrentOption, v.Name) then
                            Horizon:PlayTween(TweenService:Create(v.SelectionToggle.Inner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                            Horizon:PlayTween(TweenService:Create(v.SelectionToggle.Inner.ImageDetail, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
                        end
                    end

                    Dropdown.Options.Text = table.concat(CurrentOption, ", ")
                end

                Configuration.Callback(CurrentOption)
            end

            function ComponentLibrary:RemoveItem(ItemTable)
                for i,v in pairs(ItemTable) do
                    table.remove(Options, table.find(Options, v))
                    Dropdown.ScrollingFrame[v]:Destroy()
                end
            end

            function ComponentLibrary:AddItem(ItemTable)
                for i,v in pairs(ItemTable) do
                    table.insert(Options, v)

                    local Option = Dropdown.ScrollingFrame.Option:Clone()
                    Option.Parent = Dropdown.ScrollingFrame
                    Option.Name = v
                    Option.Visible = true
                    Option.Text = v

                    if table.find(Configuration.CurrentItems, v) then
                        if not Configuration.MultiOptions then
                            Horizon:PlayTween(TweenService:Create(Option.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                            Horizon:PlayTween(TweenService:Create(Option.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0.5, 0)}))
                            CurrentOption = v
                        else
                            Horizon:PlayTween(TweenService:Create(Option.SelectionToggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
                            Horizon:PlayTween(TweenService:Create(Option.SelectionToggle.Inner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                            Horizon:PlayTween(TweenService:Create(Option.SelectionToggle.Inner.ImageDetail, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
                            table.insert(CurrentOption, v)
                        end
                    else
                        if Configuration.MultiOptions then
                            Horizon:PlayTween(TweenService:Create(Option.SelectionToggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
                        end
                    end

                    Option.MouseEnter:Connect(function()
                        Horizon:PlayTween(TweenService:Create(Option, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(14, 14, 14)}))
                        
                        Option.MouseLeave:Wait()
                        Horizon:PlayTween(TweenService:Create(Option, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}))
                    end)

                    Option.MouseButton1Click:Connect(function()
                        if not Configuration.MultiOptions then
                            CurrentOption = v
                        else
                            if table.find(CurrentOption, v) then
                                table.remove(CurrentOption, table.find(CurrentOption, v))
                            else
                                table.insert(CurrentOption, v)
                            end
                        end

                        ComponentLibrary:Update()
                    end)
                end
            end

            for i,v in pairs(Configuration.Items) do
                table.insert(Options, v)

                local Option = Dropdown.ScrollingFrame.Option:Clone()
                Option.Parent = Dropdown.ScrollingFrame
                Option.Name = v
                Option.Visible = true
                Option.Text = v

                if table.find(Configuration.CurrentItems, v) then
                    if not Configuration.MultiOptions then
                        Horizon:PlayTween(TweenService:Create(Option.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                        Horizon:PlayTween(TweenService:Create(Option.SelectionIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 5, 0.5, 0)}))
                        CurrentOption = v
                    else
                        Horizon:PlayTween(TweenService:Create(Option.SelectionToggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
                        Horizon:PlayTween(TweenService:Create(Option.SelectionToggle.Inner, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
                        Horizon:PlayTween(TweenService:Create(Option.SelectionToggle.Inner.ImageDetail, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {ImageTransparency = 0}))
                        table.insert(CurrentOption, v)
                    end
                else
                    if Configuration.MultiOptions then
                        Horizon:PlayTween(TweenService:Create(Option.SelectionToggle, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}))
                    end
                end

                Option.MouseEnter:Connect(function()
                    Horizon:PlayTween(TweenService:Create(Option, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(14, 14, 14)}))
                    
                    Option.MouseLeave:Wait()
                    Horizon:PlayTween(TweenService:Create(Option, TweenInfo.new(0.3, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(16, 16, 16)}))
                end)

                Option.MouseButton1Click:Connect(function()
                    if not Configuration.MultiOptions then
                        CurrentOption = v
                    else
                        if table.find(CurrentOption, v) then
                            table.remove(CurrentOption, table.find(CurrentOption, v))
                        else
                            table.insert(CurrentOption, v)
                        end
                    end

                    ComponentLibrary:Update()
                end)
            end



            table.insert(TabData.Elements, Dropdown)
            return ComponentLibrary
        end

        table.insert(Tabs, TabData)
        return TabData
    end

    local Visible = true
    local Debounce = false

    local MouseConnection
    if modal then
        MouseConnection = RunService.RenderStepped:Conenct(function()
            UserInputService.MouseIconEnabled = true
        end)
    end

    function ToggleVisibility()
        if Debounce then return end
        if Visible == true then
            Debounce = true
            Main.Topbar.ClipsDescendants = true
            Main.Tabs.Visible = false
            Horizon:PlayTween(TweenService:Create(Main.Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 0, 0.896, 0)}))
            Horizon:PlayTween(TweenService:Create(Main.Topbar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 0)}))
            Horizon:PlayTween(.1, TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 600, 0, 375)}))
            Horizon:PlayTween(.1, TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 1}))
            Horizon:PlayTween(TweenService:Create(Main.DropShadow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 1}))

            task.delay(0.6, function()
                if MouseConnection then MouseConnection:Disconnect() end
                Debounce = false
                Visible = false
                Main.Topbar.Close.Visible = false
            end)

            Horizon:Notify({
                Content = 'Press "V" to show the ui back',
                Duration = 3
            })
        else
            Debounce = true
            Horizon:PlayTween(TweenService:Create(Main.Sidebar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 50, 0.896, 0)}))
            Horizon:PlayTween(TweenService:Create(Main.Topbar, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 40)}))
            Horizon:PlayTween(TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 685, 0, 425)}))
            Horizon:PlayTween(TweenService:Create(Main, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}))
            Horizon:PlayTween(TweenService:Create(Main.DropShadow, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {ImageTransparency = 0.4}))
            task.delay(0.6, function()
                if modal then
                    MouseConnection = RunService.RenderStepped:Conenct(function()
                        UserInputService.MouseIconEnabled = true
                    end)
                end
                
                Debounce = false
                Main.Topbar.ClipsDescendants = false
                Main.Topbar.Close.Visible = true
            	Visible = true
            end)

            task.delay(0.2, function()
                Main.Tabs.Visible = true
            end)
        end
    end

    UserInputService.InputBegan:Connect(function(Input, Chatting)
        if Input.KeyCode == Enum.KeyCode.V and not Chatting then
            ToggleVisibility()
        end
    end)

    Main.Topbar.Close.MouseButton1Click:Connect(ToggleVisibility)

    return Tabs
end

return Horizon
