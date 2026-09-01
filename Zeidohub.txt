local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then return end

local Camera = workspace.CurrentCamera

-- ==================== CONFIG ====================
local targetLock = false
local lockedPlayer = nil
local buttonVisible = true
local buttonSize = 55
local isDraggable = true

local predictEnabled = true
local predictAmount = 0.18
local lastTargetPos = nil
local smoothedVelocity = Vector3.new(0, 0, 0)
local lastVelocity = Vector3.new(0, 0, 0)
local smoothedAcceleration = Vector3.new(0, 0, 0)

local predictVertical = false
local predictAcceleration = false
local useDistance3D = false
local smoothMode = false
local smoothAmount = 0.35
local menuTransparency = 0

local CAMERA_LOCK_NAME = "ZeidopCameraLock"

-- ==================== CLEANUP ====================
pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)
local oldGui = playerGui:FindFirstChild("ZeidopHub")
if oldGui then oldGui:Destroy() end
local oldLoad = playerGui:FindFirstChild("ZeidopLoad")
if oldLoad then oldLoad:Destroy() end

-- ==================== PANTALLA DE CARGA ====================
local loadGui = Instance.new("ScreenGui")
loadGui.Name = "ZeidopLoad"
loadGui.ResetOnSpawn = false
loadGui.IgnoreGuiInset = true
loadGui.DisplayOrder = 999999
loadGui.Parent = playerGui

local loadBg = Instance.new("Frame")
loadBg.Size = UDim2.new(1, 0, 1, 0)
loadBg.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
loadBg.BorderSizePixel = 0
loadBg.InputTransparent = true
loadBg.Parent = loadGui

local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0.9, 0, 0, 45)
loadTitle.Position = UDim2.new(0.05, 0, 0.33, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "zeidop"
loadTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
loadTitle.TextSize = 38
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.Parent = loadBg

local loadSubtitle = Instance.new("TextLabel")
loadSubtitle.Size = UDim2.new(0.9, 0, 0, 30)
loadSubtitle.Position = UDim2.new(0.05, 0, 0.46, 0)
loadSubtitle.BackgroundTransparency = 1
loadSubtitle.Text = "ohh estas usando un script de zeidop"
loadSubtitle.TextColor3 = Color3.fromRGB(220, 220, 230)
loadSubtitle.TextSize = 16
loadSubtitle.Font = Enum.Font.GothamBold
loadSubtitle.Parent = loadBg

local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0.5, 0, 0, 4)
loadBarBg.Position = UDim2.new(0.25, 0, 0.56, 0)
loadBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
loadBarBg.BorderSizePixel = 0
loadBarBg.Parent = loadGui
Instance.new("UICorner", loadBarBg).CornerRadius = UDim.new(1, 0)

local loadBar = Instance.new("Frame")
loadBar.Size = UDim2.new(0, 0, 1, 0)
loadBar.BackgroundColor3 = Color3.fromRGB(160, 120, 255)
loadBar.BorderSizePixel = 0
loadBar.Parent = loadBarBg
Instance.new("UICorner", loadBar).CornerRadius = UDim.new(1, 0)

task.spawn(function()
    local startTime = tick()
    while tick() - startTime < 2 do
        local progress = (tick() - startTime) / 2
        if progress > 1 then progress = 1 end
        loadBar.Size = UDim2.new(progress, 0, 1, 0)
        task.wait(0.03)
    end
end)

-- ==================== GUI PRINCIPAL ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZeidopHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 210, 0, 250)
menuFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
menuFrame.BackgroundTransparency = menuTransparency
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Visible = false
menuFrame.Parent = screenGui

local menuCorner = Instance.new("UICorner")
menuCorner.CornerRadius = UDim.new(0, 12)
menuCorner.Parent = menuFrame

local menuStroke = Instance.new("UIStroke")
menuStroke.Color = Color3.fromRGB(60, 60, 75)
menuStroke.Thickness = 1.5
menuStroke.Parent = menuFrame

-- TITLE BAR
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleBar.BorderSizePixel = 0
titleBar.Parent = menuFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -55, 0, 30)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "zeidop hub"
titleLabel.TextColor3 = Color3.fromRGB(160, 120, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -28, 0, 3)
minBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
minBtn.Text = "-"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.TextSize = 16
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 6)

local accentLine = Instance.new("Frame")
accentLine.Size = UDim2.new(1, 0, 0, 2)
accentLine.Position = UDim2.new(0, 0, 0, 30)
accentLine.BackgroundColor3 = Color3.fromRGB(160, 120, 255)
accentLine.BorderSizePixel = 0
accentLine.Parent = menuFrame

-- TAB BAR
local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 26)
tabBar.Position = UDim2.new(0, 8, 0, 36)
tabBar.BackgroundTransparency = 1
tabBar.Parent = menuFrame

local tabW = 62

local tabLock = Instance.new("TextButton")
tabLock.Size = UDim2.new(0, tabW, 1, 0)
tabLock.Position = UDim2.new(0, 0, 0, 0)
tabLock.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
tabLock.Text = "LOCK"
tabLock.TextColor3 = Color3.fromRGB(255, 255, 255)
tabLock.TextSize = 11
tabLock.Font = Enum.Font.GothamBold
tabLock.BorderSizePixel = 0
tabLock.Parent = tabBar
Instance.new("UICorner", tabLock).CornerRadius = UDim.new(0, 6)

local tabNoStun = Instance.new("TextButton")
tabNoStun.Size = UDim2.new(0, tabW, 1, 0)
tabNoStun.Position = UDim2.new(0, tabW + 4, 0, 0)
tabNoStun.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tabNoStun.Text = "NO STUN"
tabNoStun.TextColor3 = Color3.fromRGB(180, 180, 190)
tabNoStun.TextSize = 9
tabNoStun.Font = Enum.Font.GothamBold
tabNoStun.BorderSizePixel = 0
tabNoStun.Parent = tabBar
Instance.new("UICorner", tabNoStun).CornerRadius = UDim.new(0, 6)

local tabDash = Instance.new("TextButton")
tabDash.Size = UDim2.new(0, tabW, 1, 0)
tabDash.Position = UDim2.new(0, (tabW + 4) * 2, 0, 0)
tabDash.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
tabDash.Text = "DASH"
tabDash.TextColor3 = Color3.fromRGB(180, 180, 190)
tabDash.TextSize = 11
tabDash.Font = Enum.Font.GothamBold
tabDash.BorderSizePixel = 0
tabDash.Parent = tabBar
Instance.new("UICorner", tabDash).CornerRadius = UDim.new(0, 6)

-- CONTENT AREA
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -70)
contentArea.Position = UDim2.new(0, 8, 0, 66)
contentArea.BackgroundTransparency = 1
contentArea.Parent = menuFrame

-- ==================== LOCK PAGE ====================
local lockPage = Instance.new("Frame")
lockPage.Size = UDim2.new(1, 0, 1, 0)
lockPage.BackgroundTransparency = 1
lockPage.Visible = true
lockPage.Parent = contentArea

local function halfBtn(text, y, isRight, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.5, -2, 0, 24)
    b.Position = UDim2.new(isRight and 0.5 or 0, isRight and 2 or 0, 0, y)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 10
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = lockPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local function smallLabel(text, y, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.55, 0, 0, 16)
    l.Position = UDim2.new(0, 0, 0, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
    l.TextSize = 10
    l.Font = Enum.Font.Gotham
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = lockPage
    return l
end

local function smallBtn(text, x, y, w, color)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, w, 0, 22)
    b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 12
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.Parent = lockPage
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
    return b
end

-- FILA 1: Boton visible + Arrastrable
local showBtn = halfBtn("Boton: Visible", 0, false, Color3.fromRGB(45, 160, 70))
local dragBtn = halfBtn("Arrastrable: ON", 0, true, Color3.fromRGB(45, 160, 70))

-- FILA 2: Tamano
local sizeLabel = smallLabel("Tamano: 55", 30)
local sizeMinus = smallBtn("-", 110, 28, 28)
local sizePlus = smallBtn("+", 142, 28, 28)

-- FILA 3: Predict
local predictLabel = smallLabel("Predict: 0.18s", 58, Color3.fromRGB(255, 220, 130))
local predictMinus = smallBtn("-", 80, 56, 28)
local predictPlus = smallBtn("+", 112, 56, 28)
local predictToggle = smallBtn("ON", 144, 56, 28, Color3.fromRGB(45, 160, 70))

-- FILA 4: Predict Vertical + Predict Accel
local predictVertBtn = halfBtn("Pred Vertical: OFF", 86, false, Color3.fromRGB(160, 50, 50))
local predictAccBtn = halfBtn("Pred Accel: OFF", 86, true, Color3.fromRGB(160, 50, 50))

-- FILA 5: Modo Smooth
local smoothBtn = halfBtn("Smooth: OFF", 114, false, Color3.fromRGB(160, 50, 50))
local smoothMinus = smallBtn("-", 99, 112, 28)
local smoothPlus = smallBtn("+", 131, 112, 28)

local smoothValLabel = Instance.new("TextLabel")
smoothValLabel.Size = UDim2.new(0, 30, 0, 16)
smoothValLabel.Position = UDim2.new(0, 163, 0, 114)
smoothValLabel.BackgroundTransparency = 1
smoothValLabel.Text = "0.35"
smoothValLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
smoothValLabel.TextSize = 10
smoothValLabel.Font = Enum.Font.Gotham
smoothValLabel.TextXAlignment = Enum.TextXAlignment.Left
smoothValLabel.Parent = lockPage

-- FILA 6: Dist 3D + Transparencia
local dist3DBtn = halfBtn("Dist 3D: OFF", 142, false, Color3.fromRGB(160, 50, 50))
local transBtn = halfBtn("Transp: 0%", 142, true, Color3.fromRGB(45, 45, 60))

-- ==================== PLACEHOLDER PAGES ====================
local noStunPage = Instance.new("Frame")
noStunPage.Size = UDim2.new(1, 0, 1, 0)
noStunPage.BackgroundTransparency = 1
noStunPage.Visible = false
noStunPage.Parent = contentArea

local noStunLabel = Instance.new("TextLabel")
noStunLabel.Size = UDim2.new(1, 0, 0, 40)
noStunLabel.Position = UDim2.new(0, 0, 0.3, 0)
noStunLabel.BackgroundTransparency = 1
noStunLabel.Text = "Proximamente..."
noStunLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
noStunLabel.TextSize = 14
noStunLabel.Font = Enum.Font.GothamBold
noStunLabel.Parent = noStunPage

local dashPage = Instance.new("Frame")
dashPage.Size = UDim2.new(1, 0, 1, 0)
dashPage.BackgroundTransparency = 1
dashPage.Visible = false
dashPage.Parent = contentArea

local dashLabel = Instance.new("TextLabel")
dashLabel.Size = UDim2.new(1, 0, 0, 40)
dashLabel.Position = UDim2.new(0, 0, 0.3, 0)
dashLabel.BackgroundTransparency = 1
dashLabel.Text = "Proximamente..."
dashLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
dashLabel.TextSize = 14
dashLabel.Font = Enum.Font.GothamBold
dashLabel.Parent = dashPage

-- ==================== TAB SYSTEM ====================
local tabs = {
    {btn = tabLock, page = lockPage},
    {btn = tabNoStun, page = noStunPage},
    {btn = tabDash, page = dashPage}
}

local function setActiveTab(index)
    for i, data in ipairs(tabs) do
        if i == index then
            data.page.Visible = true
            data.btn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
            data.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            data.page.Visible = false
            data.btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            data.btn.TextColor3 = Color3.fromRGB(180, 180, 190)
        end
    end
end

tabLock.MouseButton1Click:Connect(function() setActiveTab(1) end)
tabNoStun.MouseButton1Click:Connect(function() setActiveTab(2) end)
tabDash.MouseButton1Click:Connect(function() setActiveTab(3) end)

-- ==================== BOTON LOCK FLOTANTE ====================
local lockButton = Instance.new("TextButton")
lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
lockButton.Position = UDim2.new(0.75, 0, 0.65, 0)
lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
lockButton.Text = "LOCK"
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.TextSize = 14
lockButton.Font = Enum.Font.GothamBold
lockButton.BorderSizePixel = 0
lockButton.Active = true
lockButton.Parent = screenGui

local lockCorner = Instance.new("UICorner")
lockCorner.CornerRadius = UDim.new(1, 0)
lockCorner.Parent = lockButton

local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(0, 0, 0)
lockStroke.Thickness = 1.5
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton

local miniMenuBtn = Instance.new("TextButton")
miniMenuBtn.Size = UDim2.new(0, 46, 0, 46)
miniMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
miniMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
miniMenuBtn.Text = "Z"
miniMenuBtn.TextColor3 = Color3.fromRGB(160, 120, 255)
miniMenuBtn.TextSize = 18
miniMenuBtn.Font = Enum.Font.GothamBlack
miniMenuBtn.BorderSizePixel = 0
miniMenuBtn.Visible = false
miniMenuBtn.Active = true
miniMenuBtn.Parent = screenGui
Instance.new("UICorner", miniMenuBtn).CornerRadius = UDim.new(1, 0)

-- ==================== ARRASTRE ====================
local function makeDraggable(gui, condition)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    gui.InputBegan:Connect(function(input)
        if not condition() then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if not condition() then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

makeDraggable(menuFrame, function() return true end)
makeDraggable(miniMenuBtn, function() return true end)
makeDraggable(lockButton, function() return isDraggable end)

-- ==================== LOGICA DE SELECCION ====================
local function getClosestPlayer()
    Camera = workspace.CurrentCamera
    if not Camera then return nil end

    local closestPlayer = nil
    local shortestDistance = math.huge

    local myChar = localPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    local vp = Camera.ViewportSize
    local screenCenter = Vector2.new(vp.X / 2, vp.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.Health > 0 then
                local distance
                if useDistance3D and myRoot then
                    distance = (root.Position - myRoot.Position).Magnitude
                else
                    local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                    if onScreen and screenPos.Z > 0 then
                        distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    else
                        distance = math.huge
                    end
                end
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

local function resetLock()
    targetLock = false
    lockedPlayer = nil
    lockButton.BackgroundColor3 = Color3.fromRGB(190, 45, 45)
    lockButton.Text = "LOCK"
    lastTargetPos = nil
    smoothedVelocity = Vector3.new(0, 0, 0)
    lastVelocity = Vector3.new(0, 0, 0)
    smoothedAcceleration = Vector3.new(0, 0, 0)
end

-- ==================== EVENTOS ====================

lockButton.MouseButton1Click:Connect(function()
    if not targetLock then
        local closest = getClosestPlayer()
        if closest then
            lockedPlayer = closest
            targetLock = true
            lockButton.BackgroundColor3 = Color3.fromRGB(45, 170, 70)
            lockButton.Text = "ON"
            lastTargetPos = nil
            smoothedVelocity = Vector3.new(0, 0, 0)
            lastVelocity = Vector3.new(0, 0, 0)
            smoothedAcceleration = Vector3.new(0, 0, 0)
        end
    else
        resetLock()
    end
end)

showBtn.MouseButton1Click:Connect(function()
    buttonVisible = not buttonVisible
    lockButton.Visible = buttonVisible
    showBtn.Text = buttonVisible and "Boton: Visible" or "Boton: Oculto"
    showBtn.BackgroundColor3 = buttonVisible and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

sizeMinus.MouseButton1Click:Connect(function()
    buttonSize = math.max(35, buttonSize - 5)
    lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(buttonSize)
end)

sizePlus.MouseButton1Click:Connect(function()
    buttonSize = math.min(90, buttonSize + 5)
    lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
    sizeLabel.Text = "Tamano: " .. tostring(buttonSize)
end)

dragBtn.MouseButton1Click:Connect(function()
    isDraggable = not isDraggable
    dragBtn.Text = "Arrastrable: " .. (isDraggable and "ON" or "OFF")
    dragBtn.BackgroundColor3 = isDraggable and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

predictMinus.MouseButton1Click:Connect(function()
    predictAmount = math.max(0.05, predictAmount - 0.02)
    predictAmount = math.floor(predictAmount * 100 + 0.5) / 100
    predictLabel.Text = string.format("Predict: %.2fs", predictAmount)
end)

predictPlus.MouseButton1Click:Connect(function()
    predictAmount = math.min(0.4, predictAmount + 0.02)
    predictAmount = math.floor(predictAmount * 100 + 0.5) / 100
    predictLabel.Text = string.format("Predict: %.2fs", predictAmount)
end)

predictToggle.MouseButton1Click:Connect(function()
    predictEnabled = not predictEnabled
    predictToggle.Text = predictEnabled and "ON" or "OFF"
    predictToggle.BackgroundColor3 = predictEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    predictLabel.TextColor3 = predictEnabled and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(150, 150, 150)
end)

predictVertBtn.MouseButton1Click:Connect(function()
    predictVertical = not predictVertical
    predictVertBtn.Text = "Pred Vertical: " .. (predictVertical and "ON" or "OFF")
    predictVertBtn.BackgroundColor3 = predictVertical and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

predictAccBtn.MouseButton1Click:Connect(function()
    predictAcceleration = not predictAcceleration
    predictAccBtn.Text = "Pred Accel: " .. (predictAcceleration and "ON" or "OFF")
    predictAccBtn.BackgroundColor3 = predictAcceleration and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
    if not predictAcceleration then
        smoothedAcceleration = Vector3.new(0, 0, 0)
        lastVelocity = Vector3.new(0, 0, 0)
    end
end)

smoothBtn.MouseButton1Click:Connect(function()
    smoothMode = not smoothMode
    smoothBtn.Text = "Smooth: " .. (smoothMode and "ON" or "OFF")
    smoothBtn.BackgroundColor3 = smoothMode and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

smoothMinus.MouseButton1Click:Connect(function()
    smoothAmount = math.max(0.05, smoothAmount - 0.05)
    smoothAmount = math.floor(smoothAmount * 100 + 0.5) / 100
    smoothValLabel.Text = string.format("%.2f", smoothAmount)
end)

smoothPlus.MouseButton1Click:Connect(function()
    smoothAmount = math.min(1, smoothAmount + 0.05)
    smoothAmount = math.floor(smoothAmount * 100 + 0.5) / 100
    smoothValLabel.Text = string.format("%.2f", smoothAmount)
end)

dist3DBtn.MouseButton1Click:Connect(function()
    useDistance3D = not useDistance3D
    dist3DBtn.Text = "Dist 3D: " .. (useDistance3D and "ON" or "OFF")
    dist3DBtn.BackgroundColor3 = useDistance3D and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
end)

transBtn.MouseButton1Click:Connect(function()
    menuTransparency = menuTransparency + 0.15
    if menuTransparency > 0.75 then
        menuTransparency = 0
    end
    menuFrame.BackgroundTransparency = menuTransparency
    local pct = math.floor(menuTransparency * 100 + 0.5)
    transBtn.Text = "Transp: " .. tostring(pct) .. "%"
end)

minBtn.MouseButton1Click:Connect(function()
    menuFrame.Visible = false
    miniMenuBtn.Visible = true
    miniMenuBtn.Position = menuFrame.Position
end)

miniMenuBtn.MouseButton1Click:Connect(function()
    miniMenuBtn.Visible = false
    menuFrame.Visible = true
    menuFrame.Position = miniMenuBtn.Position
end)

-- ==================== LOOP DE CAMERA LOCK ====================
local lastDeltaTime = 1/60

local function cameraLockStep(dt)
    lastDeltaTime = dt or (1/60)

    if not targetLock or not lockedPlayer or not lockedPlayer.Character then
        return
    end

    Camera = workspace.CurrentCamera
    if not Camera then return end

    local root = lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
    local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")

    if not root or not hum or hum.Health <= 0 then
        resetLock()
        return
    end

    local targetPos = root.Position
    local aimPosition = targetPos

    if predictEnabled then
        local currentVelocity = Vector3.new(0, 0, 0)

        local vel = root.AssemblyLinearVelocity or root.Velocity
        if vel and vel.Magnitude > 0.5 then
            currentVelocity = vel
        elseif lastTargetPos then
            local delta = targetPos - lastTargetPos
            local elapsed = math.max(0.008, lastDeltaTime)
            currentVelocity = delta / elapsed
        end

        local velSmoothFactor = 0.3
        smoothedVelocity = smoothedVelocity * (1 - velSmoothFactor) + currentVelocity * velSmoothFactor

        if predictAcceleration then
            local currentAcceleration = Vector3.new(0, 0, 0)
            if lastVelocity.Magnitude > 0.1 then
                local accDelta = currentVelocity - lastVelocity
                local elapsed = math.max(0.008, lastDeltaTime)
                currentAcceleration = accDelta / elapsed
            end

            local accSmoothFactor = 0.2
            smoothedAcceleration = smoothedAcceleration * (1 - accSmoothFactor) + currentAcceleration * accSmoothFactor
            lastVelocity = currentVelocity

            local t = predictAmount
            local predictedOffset = (smoothedVelocity * t) + (smoothedAcceleration * 0.5 * t * t)

            if predictVertical then
                aimPosition = targetPos + predictedOffset
            else
                aimPosition = targetPos + Vector3.new(predictedOffset.X, 0, predictedOffset.Z)
            end
        else
            if smoothedVelocity.Magnitude > 0.5 then
                local predictedOffset = smoothedVelocity * predictAmount
                if predictVertical then
                    aimPosition = targetPos + predictedOffset
                else
                    aimPosition = targetPos + Vector3.new(predictedOffset.X, 0, predictedOffset.Z)
                end
            end
        end
    end

    lastTargetPos = targetPos

    local targetCFrame = CFrame.new(Camera.CFrame.Position, aimPosition)

    if smoothMode then
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothAmount)
    else
        Camera.CFrame = targetCFrame
    end
end

RunService:BindToRenderStep(
    CAMERA_LOCK_NAME,
    Enum.RenderPriority.Camera.Value + 1,
    cameraLockStep
)

-- ==================== SEGURIDAD ====================
localPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if targetLock then
        resetLock()
    end
end)

-- ==================== MOSTRAR MENU DESPUES DE CARGA ====================
task.delay(2, function()
    if loadGui and loadGui.Parent then
        loadGui:Destroy()
    end
    menuFrame.Visible = true
end)

print("zeidop hub cargado OK")
