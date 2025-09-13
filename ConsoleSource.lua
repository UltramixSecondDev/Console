local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LogService = game:GetService("LogService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Console"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 1000, 0, 300)
mainFrame.Position = UDim2.new(0, 50, 0, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

-- Header
local header = Instance.new("Frame", mainFrame)
header.Size = UDim2.new(1,0,0,25)
header.BackgroundColor3 = Color3.fromRGB(45,45,45)

local title = Instance.new("TextLabel", header)
title.Size = UDim2.new(1,-40,1,0)
title.Position = UDim2.new(0,8,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.Legacy
title.TextSize = 9
title.TextColor3 = Color3.fromRGB(220,220,220)
title.Text = "Console++"
title.TextXAlignment = Enum.TextXAlignment.Left

local minimizeBtn = Instance.new("TextButton", header)
minimizeBtn.Size = UDim2.new(0,28,1, -6)
minimizeBtn.Position = UDim2.new(1,-32,0,3)
minimizeBtn.Text = "-"
minimizeBtn.Font = Enum.Font.Legacy
minimizeBtn.TextSize = 9
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
minimizeBtn.TextColor3 = Color3.fromRGB(220,220,220)

-- Toolbar
local toolbar = Instance.new("Frame", mainFrame)
toolbar.Size = UDim2.new(1,0,0,25)
toolbar.Position = UDim2.new(0,0,0,25)
toolbar.BackgroundColor3 = Color3.fromRGB(50,50,50)

local buttonNames = {"Clear","Copy","Pause","Filter Info","Filter Warning","Filter Error","Save Log","Clear Filter"}
local buttons = {}
local uiList = Instance.new("UIListLayout", toolbar)
uiList.FillDirection = Enum.FillDirection.Horizontal
uiList.Padding = UDim.new(0,4)
uiList.SortOrder = Enum.SortOrder.LayoutOrder

for _, name in ipairs(buttonNames) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,100,1,-4)
    btn.Font = Enum.Font.Legacy
    btn.TextSize = 9
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
    btn.TextColor3 = Color3.fromRGB(220,220,220)
    btn.Parent = toolbar
    table.insert(buttons, btn)
end

-- Output Frame
local outputFrame = Instance.new("Frame", mainFrame)
outputFrame.Size = UDim2.new(1,-10,1,-80)
outputFrame.Position = UDim2.new(0,5,0,50)
outputFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)

-- Scroll Frame
local outputScroll = Instance.new("ScrollingFrame", outputFrame)
outputScroll.Size = UDim2.new(1,-12,1,-12)
outputScroll.Position = UDim2.new(0,5,0,5)
outputScroll.BackgroundTransparency = 1
outputScroll.BorderSizePixel = 0
outputScroll.ScrollBarThickness = 8
outputScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

-- UIListLayout
local layout = Instance.new("UIListLayout", outputScroll)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,2)

-- TextBox de comandos
local commandBox = Instance.new("TextBox", mainFrame)
commandBox.Size = UDim2.new(1,-10,0,20)
commandBox.Position = UDim2.new(0,5,1,-25)
commandBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
commandBox.TextColor3 = Color3.fromRGB(255,255,255)
commandBox.Font = Enum.Font.Code
commandBox.TextSize = 14
commandBox.ClearTextOnFocus = false
commandBox.TextXAlignment = Enum.TextXAlignment.Left
commandBox.TextYAlignment = Enum.TextYAlignment.Top
commandBox.PlaceholderText = "Ingrese comando..."
commandBox.TextEditable = true
commandBox.MultiLine = false

-- Variables
local lineCounter = 0
local autoScroll = true
local currentFilter = "All"

-- Función timestamp
local function getTimeStamp()
    local t = os.date("*t")
    return string.format("[%02d:%02d:%02d]", t.hour, t.min, t.sec)
end

-- Función agregar mensaje (linea dinámica)
local function addMessage(text, color, type)
    color = color or Color3.fromRGB(255,255,255)
    type = type or "Info"
    lineCounter = lineCounter + 1

    local lineLabel = Instance.new("TextLabel")
    lineLabel.BackgroundTransparency = 1
    lineLabel.Font = Enum.Font.Code
    lineLabel.TextSize = 14
    lineLabel.TextColor3 = color
    lineLabel.TextXAlignment = Enum.TextXAlignment.Left
    lineLabel.TextYAlignment = Enum.TextYAlignment.Top
    lineLabel.TextWrapped = true
    lineLabel.Text = string.format("%s[%03d] %s", getTimeStamp(), lineCounter, text)
    lineLabel.LayoutOrder = lineCounter
    lineLabel.Parent = outputScroll

    -- Ajustar tamaño según texto
    local textSize = lineLabel.TextBounds
    lineLabel.Size = UDim2.new(1, -4, 0, textSize.Y + 2)

    if autoScroll and (currentFilter=="All" or currentFilter==type) then
        outputScroll.CanvasPosition = Vector2.new(0, outputScroll.CanvasSize.Y.Offset)
    end
end

-- Comando
commandBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local cmd = commandBox.Text
        if cmd ~= "" then
            addMessage("> "..cmd, Color3.fromRGB(200,200,200), "Command")
            commandBox.Text = ""
        end
    end
end)

-- Funciones de botones
buttons[1].MouseButton1Click:Connect(function()
    outputScroll:ClearAllChildren()
    lineCounter = 0
end)

buttons[2].MouseButton1Click:Connect(function()
    local text = ""
    for _, child in ipairs(outputScroll:GetChildren()) do
        if child:IsA("TextLabel") then
            text = text .. child.Text .. "\n"
        end
    end
    pcall(function() setclipboard(text) end)
    addMessage("Texto copiado al portapapeles", Color3.fromRGB(0,255,0))
end)

buttons[3].MouseButton1Click:Connect(function()
    autoScroll = not autoScroll
    addMessage("Auto-scroll "..(autoScroll and "activado" or "pausado"), Color3.fromRGB(200,200,0))
end)

buttons[8].MouseButton1Click:Connect(function()
    currentFilter = "All"
    for _, child in ipairs(outputScroll:GetChildren()) do
        child.Visible = true
    end
end)

-- Minimizar
minimizeBtn.MouseButton1Click:Connect(function()
    local minimized = mainFrame.Size.Y.Offset > 50
    TweenService:Create(mainFrame, TweenInfo.new(0.25), {Size=UDim2.new(0,1000,0,minimized and 50 or 300)}):Play()
end)

-- LogService
LogService.MessageOut:Connect(function(msg, msgType)
    local color = Color3.fromRGB(255,255,255)
    local typeName = "Info"
    if msgType == Enum.MessageType.MessageWarning then
        color = Color3.fromRGB(255,180,0)
        typeName = "Warning"
    elseif msgType == Enum.MessageType.MessageError then
        color = Color3.fromRGB(255,0,0)
        typeName = "Error"
    end
    addMessage(msg, color, typeName)
end)

addMessage("NotepadConsole iniciado", Color3.fromRGB(100,255,100), "Info")
