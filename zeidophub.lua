-- ZEIDOP HUB FINAL: LOCK + STUN + DASH + LOGO + GUARDADO + CERRAR
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui", 15)
if not playerGui then return end
local Camera = workspace.CurrentCamera
-- CONFIG LOCK
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
local lockPart = "torso"
local lockKey = Enum.KeyCode.L
local listeningForKey = false
local scriptClosed = false
local CAMERA_LOCK_NAME = "ZeidopCameraLock"
-- CONFIG ANTI-STUN (init seguro, no cuelga)
local antiStunEnabled = false
local jumping = true
local jumpPower = 50
local dashForce = 60
local stunLocked = false
local jumpBtnSize = 62
local dashBtnSize = 62
local character = nil
local humanoid = nil
local rootPart = nil
local function setChar(c)
character = c
humanoid = c and c:FindFirstChildOfClass("Humanoid") or nil
rootPart = c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso")) or nil
end
setChar(localPlayer.Character)
-- CONFIG DASH
local dashMultiplier = 1.5
local dashEnabled = true
-- LOGO Y SONIDO
local LOGO_ID = 97991220544918
local LOAD_SOUND_ID = 0
-- GUARDADO
local SAVE_FILE = "zeidop_hub_config.json"
local function saveConfig()
pcall(function()
if writefile then
writefile(SAVE_FILE, HttpService:JSONEncode({
buttonSize = buttonSize, buttonVisible = buttonVisible, isDraggable = isDraggable,
predictEnabled = predictEnabled, predictAmount = predictAmount,
predictVertical = predictVertical, predictAcceleration = predictAcceleration,
useDistance3D = useDistance3D, smoothMode = smoothMode, smoothAmount = smoothAmount,
menuTransparency = menuTransparency, jumpPower = jumpPower, dashForce = dashForce,
jumpBtnSize = jumpBtnSize, dashBtnSize = dashBtnSize,
dashMultiplier = dashMultiplier, dashEnabled = dashEnabled,
lockPart = lockPart, lockKeyName = lockKey.Name
}))
end
end)
end
local function loadConfig()
pcall(function()
if readfile and isfile and isfile(SAVE_FILE) then
local d = HttpService:JSONDecode(readfile(SAVE_FILE))
if type(d) == "table" then
if type(d.buttonSize) == "number" then buttonSize = d.buttonSize end
if type(d.buttonVisible) == "boolean" then buttonVisible = d.buttonVisible end
if type(d.isDraggable) == "boolean" then isDraggable = d.isDraggable end
if type(d.predictEnabled) == "boolean" then predictEnabled = d.predictEnabled end
if type(d.predictAmount) == "number" then predictAmount = d.predictAmount end
if type(d.predictVertical) == "boolean" then predictVertical = d.predictVertical end
if type(d.predictAcceleration) == "boolean" then predictAcceleration = d.predictAcceleration end
if type(d.useDistance3D) == "boolean" then useDistance3D = d.useDistance3D end
if type(d.smoothMode) == "boolean" then smoothMode = d.smoothMode end
if type(d.smoothAmount) == "number" then smoothAmount = d.smoothAmount end
if type(d.menuTransparency) == "number" then menuTransparency = d.menuTransparency end
if type(d.jumpPower) == "number" then jumpPower = d.jumpPower end
if type(d.dashForce) == "number" then dashForce = d.dashForce end
if type(d.jumpBtnSize) == "number" then jumpBtnSize = d.jumpBtnSize end
if type(d.dashBtnSize) == "number" then dashBtnSize = d.dashBtnSize end
if type(d.dashMultiplier) == "number" then dashMultiplier = d.dashMultiplier end
if type(d.dashEnabled) == "boolean" then dashEnabled = d.dashEnabled end
if type(d.lockPart) == "string" then lockPart = d.lockPart end
if type(d.lockKeyName) == "string" then
pcall(function() lockKey = Enum.KeyCode[d.lockKeyName] end)
end
end
end
end)
end
loadConfig()
-- CLEANUP
pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)
local oldGui = playerGui:FindFirstChild("ZeidopHub")
if oldGui then oldGui:Destroy() end
local oldLoad = playerGui:FindFirstChild("ZeidopLoad")
if oldLoad then oldLoad:Destroy() end
-- PANTALLA DE CARGA
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
loadBg.Active = false
loadBg.Parent = loadGui
local loadLogo = Instance.new("ImageLabel")
loadLogo.Size = UDim2.new(0, 90, 0, 90)
loadLogo.Position = UDim2.new(0.5, -45, 0.10, 0)
loadLogo.BackgroundTransparency = 1
loadLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
loadLogo.Parent = loadBg
Instance.new("UICorner", loadLogo).CornerRadius = UDim.new(1, 0)
local loadLogoStroke = Instance.new("UIStroke")
loadLogoStroke.Color = Color3.fromRGB(160, 120, 255)
loadLogoStroke.Thickness = 3
loadLogoStroke.Parent = loadLogo
local loadTitle = Instance.new("TextLabel")
loadTitle.Size = UDim2.new(0.9, 0, 0, 45)
loadTitle.Position = UDim2.new(0.05, 0, 0.36, 0)
loadTitle.BackgroundTransparency = 1
loadTitle.Text = "zeidop"
loadTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
loadTitle.TextSize = 38
loadTitle.Font = Enum.Font.GothamBlack
loadTitle.Parent = loadBg
local loadSubtitle = Instance.new("TextLabel")
loadSubtitle.Size = UDim2.new(0.9, 0, 0, 30)
loadSubtitle.Position = UDim2.new(0.05, 0, 0.50, 0)
loadSubtitle.BackgroundTransparency = 1
loadSubtitle.Text = "ohh estas usando un script de zeidop"
loadSubtitle.TextColor3 = Color3.fromRGB(220, 220, 230)
loadSubtitle.TextSize = 16
loadSubtitle.Font = Enum.Font.GothamBold
loadSubtitle.Parent = loadBg
local loadBarBg = Instance.new("Frame")
loadBarBg.Size = UDim2.new(0.5, 0, 0, 4)
loadBarBg.Position = UDim2.new(0.25, 0, 0.60, 0)
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
if LOAD_SOUND_ID > 0 then
local loadSound = Instance.new("Sound")
loadSound.SoundId = "rbxassetid://" .. LOAD_SOUND_ID
loadSound.Volume = 1
loadSound.Parent = loadGui
loadSound:Play()
end
spawn(function()
local startTime = tick()
while tick() - startTime < 2 do
local progress = (tick() - startTime) / 2
if progress > 1 then progress = 1 end
loadBar.Size = UDim2.new(progress, 0, 1, 0)
wait(0.03)
end
end)
-- GUI PRINCIPAL
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZeidopHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui
local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0, 210, 0, 290)
menuFrame.Position = UDim2.new(0.02, 0, 0.15, 0)
menuFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
menuFrame.BackgroundTransparency = menuTransparency
menuFrame.BorderSizePixel = 0
menuFrame.Active = true
menuFrame.Visible = false
menuFrame.Parent = screenGui
Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 12)
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
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 12)
titleFix.Position = UDim2.new(0, 0, 1, -12)
titleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar
local titleLogo = Instance.new("ImageLabel")
titleLogo.Size = UDim2.new(0, 22, 0, 22)
titleLogo.Position = UDim2.new(0, 6, 0, 4)
titleLogo.BackgroundTransparency = 1
titleLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
titleLogo.Parent = titleBar
Instance.new("UICorner", titleLogo).CornerRadius = UDim.new(1, 0)
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -80, 0, 30)
titleLabel.Position = UDim2.new(0, 32, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "zeidop hub"
titleLabel.TextColor3 = Color3.fromRGB(160, 120, 255)
titleLabel.TextSize = 14
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar
-- BOTON CERRAR (X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -54, 0, 3)
closeBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
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
local contentArea = Instance.new("Frame")
contentArea.Size = UDim2.new(1, -16, 1, -70)
contentArea.Position = UDim2.new(0, 8, 0, 66)
contentArea.BackgroundTransparency = 1
contentArea.Parent = menuFrame

-- LOCK PAGE
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
local showBtn = halfBtn("Boton: Visible", 0, false, Color3.fromRGB(45, 160, 70))
local dragBtn = halfBtn("Arrastrable: ON", 0, true, Color3.fromRGB(45, 160, 70))
local sizeLabel = smallLabel("Tamano: 55", 30)
local sizeMinus = smallBtn("-", 110, 28, 28)
local sizePlus = smallBtn("+", 142, 28, 28)
local predictLabel = smallLabel("Predict: 0.18s", 58, Color3.fromRGB(255, 220, 130))
local predictMinus = smallBtn("-", 80, 56, 28)
local predictPlus = smallBtn("+", 112, 56, 28)
local predictToggle = smallBtn("ON", 144, 56, 28, Color3.fromRGB(45, 160, 70))
local predictVertBtn = halfBtn("Pred Vertical: OFF", 86, false, Color3.fromRGB(160, 50, 50))
local predictAccBtn = halfBtn("Pred Accel: OFF", 86, true, Color3.fromRGB(160, 50, 50))
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
local dist3DBtn = halfBtn("Dist 3D: OFF", 142, false, Color3.fromRGB(160, 50, 50))
local transBtn = halfBtn("Transp: 0%", 142, true, Color3.fromRGB(45, 45, 60))
-- SECCION APUNTADO / TECLA (NUEVA)
local aimSep = Instance.new("TextLabel")
aimSep.Size = UDim2.new(1, 0, 0, 14)
aimSep.Position = UDim2.new(0, 0, 0, 172)
aimSep.BackgroundTransparency = 1
aimSep.Text = "--- APUNTADO / TECLA ---"
aimSep.TextColor3 = Color3.fromRGB(160, 120, 255)
aimSep.TextSize = 9
aimSep.Font = Enum.Font.GothamBold
aimSep.Parent = lockPage
local partBtn = halfBtn("Parte: Torso", 190, false, Color3.fromRGB(70, 130, 220))
local keyBtn = halfBtn("Tecla: L", 190, true, Color3.fromRGB(70, 130, 220))
local function updatePartBtn()
partBtn.Text = "Parte: " .. (lockPart == "head" and "Cabeza" or "Torso")
partBtn.BackgroundColor3 = lockPart == "head" and Color3.fromRGB(160, 50, 50) or Color3.fromRGB(70, 130, 220)
end
local function updateKeyBtn()
if listeningForKey then
keyBtn.Text = "Presiona..."
keyBtn.BackgroundColor3 = Color3.fromRGB(255, 220, 130)
keyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
else
keyBtn.Text = "Tecla: " .. lockKey.Name
keyBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
keyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
end
end
partBtn.MouseButton1Click:Connect(function()
lockPart = (lockPart == "torso") and "head" or "torso"
updatePartBtn()
saveConfig()
end)
keyBtn.MouseButton1Click:Connect(function()
listeningForKey = not listeningForKey
updateKeyBtn()
end)
-- NO STUN PAGE
local noStunPage = Instance.new("Frame")
noStunPage.Size = UDim2.new(1, 0, 1, 0)
noStunPage.BackgroundTransparency = 1
noStunPage.Visible = false
noStunPage.Parent = contentArea
local function nsBtn(text, y, isRight, color)
local b = Instance.new("TextButton")
b.Size = UDim2.new(0.5, -2, 0, 22)
b.Position = UDim2.new(isRight and 0.5 or 0, isRight and 2 or 0, 0, y)
b.BackgroundColor3 = color
b.Text = text
b.TextColor3 = Color3.fromRGB(255, 255, 255)
b.TextSize = 9
b.Font = Enum.Font.GothamBold
b.BorderSizePixel = 0
b.Parent = noStunPage
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
return b
end
local function nsLabel(text, y, color)
local l = Instance.new("TextLabel")
l.Size = UDim2.new(0.6, 0, 0, 14)
l.Position = UDim2.new(0, 0, 0, y)
l.BackgroundTransparency = 1
l.Text = text
l.TextColor3 = color or Color3.fromRGB(200, 200, 210)
l.TextSize = 9
l.Font = Enum.Font.Gotham
l.TextXAlignment = Enum.TextXAlignment.Left
l.Parent = noStunPage
return l
end
local function nsSmallBtn(text, x, y, w, color)
local b = Instance.new("TextButton")
b.Size = UDim2.new(0, w, 0, 20)
b.Position = UDim2.new(0, x, 0, y)
b.BackgroundColor3 = color or Color3.fromRGB(45, 45, 60)
b.Text = text
b.TextColor3 = Color3.fromRGB(255, 255, 255)
b.TextSize = 11
b.Font = Enum.Font.GothamBold
b.BorderSizePixel = 0
b.Parent = noStunPage
Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
return b
end
local nsToggleBtn = Instance.new("TextButton")
nsToggleBtn.Size = UDim2.new(1, 0, 0, 24)
nsToggleBtn.Position = UDim2.new(0, 0, 0, 0)
nsToggleBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
nsToggleBtn.Text = "ANTI-STUN: OFF"
nsToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nsToggleBtn.TextSize = 11
nsToggleBtn.Font = Enum.Font.GothamBold
nsToggleBtn.BorderSizePixel = 0
nsToggleBtn.Parent = noStunPage
Instance.new("UICorner", nsToggleBtn).CornerRadius = UDim.new(0, 6)
local nsJumpLabel = nsLabel("Jump Power: 50", 30)
local nsJumpMinus = nsSmallBtn("-", 75, 28, 24)
local nsJumpPlus = nsSmallBtn("+", 103, 28, 24)
local nsJumpGenBtn = nsSmallBtn("GEN", 131, 28, 32, Color3.fromRGB(80, 60, 140))
local nsDashLabel = nsLabel("Dash Force: 60", 54)
local nsDashMinus = nsSmallBtn("-", 75, 52, 24)
local nsDashPlus = nsSmallBtn("+", 103, 52, 24)
local nsDashGenBtn = nsSmallBtn("GEN", 131, 52, 32, Color3.fromRGB(70, 130, 220))
local nsJumpSizeLabel = nsLabel("Jump Size: 62", 78)
local nsJumpSizeMinus = nsSmallBtn("-", 75, 76, 24)
local nsJumpSizePlus = nsSmallBtn("+", 103, 76, 24)
local nsDashSizeLabel = nsLabel("Dash Size: 62", 102)
local nsDashSizeMinus = nsSmallBtn("-", 75, 100, 24)
local nsDashSizePlus = nsSmallBtn("+", 103, 100, 24)
local nsLockBtn = Instance.new("TextButton")
nsLockBtn.Size = UDim2.new(1, 0, 0, 22)
nsLockBtn.Position = UDim2.new(0, 0, 0, 128)
nsLockBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 100)
nsLockBtn.Text = "LOCK FLOAT: OFF"
nsLockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
nsLockBtn.TextSize = 10
nsLockBtn.Font = Enum.Font.GothamBold
nsLockBtn.BorderSizePixel = 0
nsLockBtn.Parent = noStunPage
Instance.new("UICorner", nsLockBtn).CornerRadius = UDim.new(0, 6)
local nsInfoLabel = Instance.new("TextLabel")
nsInfoLabel.Size = UDim2.new(1, 0, 0, 20)
nsInfoLabel.Position = UDim2.new(0, 0, 0, 154)
nsInfoLabel.BackgroundTransparency = 1
nsInfoLabel.Text = "Hotkeys: X=toggle Z=off Space=jump Q=dash"
nsInfoLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
nsInfoLabel.TextSize = 8
nsInfoLabel.Font = Enum.Font.Gotham
nsInfoLabel.TextXAlignment = Enum.TextXAlignment.Left
nsInfoLabel.Parent = noStunPage
-- DASH PAGE
local dashPage = Instance.new("Frame")
dashPage.Size = UDim2.new(1, 0, 1, 0)
dashPage.BackgroundTransparency = 1
dashPage.Visible = false
dashPage.Parent = contentArea
local dashTitle = Instance.new("TextLabel")
dashTitle.Size = UDim2.new(1, -10, 0, 20)
dashTitle.Position = UDim2.new(0, 5, 0, 0)
dashTitle.BackgroundTransparency = 1
dashTitle.Text = "Dash Speed"
dashTitle.TextColor3 = Color3.fromRGB(160, 120, 255)
dashTitle.TextSize = 14
dashTitle.Font = Enum.Font.GothamBold
dashTitle.TextXAlignment = Enum.TextXAlignment.Left
dashTitle.Parent = dashPage
local dashValueLabel = Instance.new("TextLabel")
dashValueLabel.Size = UDim2.new(1, -10, 0, 18)
dashValueLabel.Position = UDim2.new(0, 5, 0, 24)
dashValueLabel.BackgroundTransparency = 1
dashValueLabel.Text = "Multiplicador: 1.5x"
dashValueLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
dashValueLabel.TextSize = 11
dashValueLabel.Font = Enum.Font.Gotham
dashValueLabel.TextXAlignment = Enum.TextXAlignment.Left
dashValueLabel.Parent = dashPage
local dashMinusBtn = Instance.new("TextButton")
dashMinusBtn.Size = UDim2.new(0.5, -4, 0, 28)
dashMinusBtn.Position = UDim2.new(0, 0, 0, 50)
dashMinusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dashMinusBtn.Text = "-"
dashMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashMinusBtn.TextSize = 16
dashMinusBtn.Font = Enum.Font.GothamBold
dashMinusBtn.BorderSizePixel = 0
dashMinusBtn.Parent = dashPage
Instance.new("UICorner", dashMinusBtn).CornerRadius = UDim.new(0, 6)
local dashPlusBtn = Instance.new("TextButton")
dashPlusBtn.Size = UDim2.new(0.5, -4, 0, 28)
dashPlusBtn.Position = UDim2.new(0.5, 4, 0, 50)
dashPlusBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
dashPlusBtn.Text = "+"
dashPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashPlusBtn.TextSize = 16
dashPlusBtn.Font = Enum.Font.GothamBold
dashPlusBtn.BorderSizePixel = 0
dashPlusBtn.Parent = dashPage
Instance.new("UICorner", dashPlusBtn).CornerRadius = UDim.new(0, 6)
local dashToggleBtn = Instance.new("TextButton")
dashToggleBtn.Size = UDim2.new(1, 0, 0, 28)
dashToggleBtn.Position = UDim2.new(0, 0, 0, 86)
dashToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
dashToggleBtn.Text = "ACTIVADO"
dashToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashToggleBtn.TextSize = 12
dashToggleBtn.Font = Enum.Font.GothamBold
dashToggleBtn.BorderSizePixel = 0
dashToggleBtn.Parent = dashPage
Instance.new("UICorner", dashToggleBtn).CornerRadius = UDim.new(0, 6)
local dashDesc = Instance.new("TextLabel")
dashDesc.Size = UDim2.new(1, -10, 0, 50)
dashDesc.Position = UDim2.new(0, 5, 0, 120)
dashDesc.BackgroundTransparency = 1
dashDesc.Text = "Aumenta la velocidad del dash al multiplicar la fuerza del impulso de Rogue Demon."
dashDesc.TextColor3 = Color3.fromRGB(120, 120, 130)
dashDesc.TextSize = 10
dashDesc.Font = Enum.Font.Gotham
dashDesc.TextXAlignment = Enum.TextXAlignment.Left
dashDesc.TextWrapped = true
dashDesc.Parent = dashPage
-- TAB SYSTEM
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

-- BOTONES FLOTANTES
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
lockButton.Visible = buttonVisible
lockButton.Parent = screenGui
Instance.new("UICorner", lockButton).CornerRadius = UDim.new(1, 0)
local lockStroke = Instance.new("UIStroke")
lockStroke.Color = Color3.fromRGB(0, 0, 0)
lockStroke.Thickness = 1.5
lockStroke.Transparency = 0.3
lockStroke.Parent = lockButton
local miniMenuBtn = Instance.new("TextButton")
miniMenuBtn.Size = UDim2.new(0, 46, 0, 46)
miniMenuBtn.Position = UDim2.new(0.02, 0, 0.15, 0)
miniMenuBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
miniMenuBtn.Text = LOGO_ID > 0 and "" or "Z"
miniMenuBtn.TextColor3 = Color3.fromRGB(160, 120, 255)
miniMenuBtn.TextSize = 18
miniMenuBtn.Font = Enum.Font.GothamBlack
miniMenuBtn.BorderSizePixel = 0
miniMenuBtn.Visible = false
miniMenuBtn.Active = true
miniMenuBtn.Parent = screenGui
Instance.new("UICorner", miniMenuBtn).CornerRadius = UDim.new(1, 0)
local miniStroke = Instance.new("UIStroke")
miniStroke.Color = Color3.fromRGB(160, 120, 255)
miniStroke.Thickness = 2
miniStroke.Parent = miniMenuBtn
local miniLogo = Instance.new("ImageLabel")
miniLogo.Size = UDim2.new(1, -8, 1, -8)
miniLogo.Position = UDim2.new(0, 4, 0, 4)
miniLogo.BackgroundTransparency = 1
miniLogo.Image = LOGO_ID > 0 and ("rbxassetid://" .. LOGO_ID) or ""
miniLogo.Parent = miniMenuBtn
Instance.new("UICorner", miniLogo).CornerRadius = UDim.new(1, 0)
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
jumpBtn.Position = UDim2.new(0.72, 0, 0.68, 0)
jumpBtn.BackgroundColor3 = Color3.fromRGB(80, 60, 140)
jumpBtn.Text = "JUMP"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.TextSize = 14
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.BorderSizePixel = 0
jumpBtn.Visible = false
jumpBtn.Parent = screenGui
Instance.new("UICorner", jumpBtn).CornerRadius = UDim.new(1, 0)
local jbStroke = Instance.new("UIStroke")
jbStroke.Color = Color3.fromRGB(0, 0, 0)
jbStroke.Thickness = 1.5
jbStroke.Transparency = 0.3
jbStroke.Parent = jumpBtn
local dashFloatBtn = Instance.new("TextButton")
dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
dashFloatBtn.Position = UDim2.new(0.72, 0, 0.55, 0)
dashFloatBtn.BackgroundColor3 = Color3.fromRGB(70, 130, 220)
dashFloatBtn.Text = "DASH"
dashFloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dashFloatBtn.TextSize = 14
dashFloatBtn.Font = Enum.Font.GothamBold
dashFloatBtn.BorderSizePixel = 0
dashFloatBtn.Visible = false
dashFloatBtn.Parent = screenGui
Instance.new("UICorner", dashFloatBtn).CornerRadius = UDim.new(1, 0)
local dfStroke = Instance.new("UIStroke")
dfStroke.Color = Color3.fromRGB(0, 0, 0)
dfStroke.Thickness = 1.5
dfStroke.Transparency = 0.3
dfStroke.Parent = dashFloatBtn
-- ARRASTRE
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
makeDraggable(jumpBtn, function() return not stunLocked end)
makeDraggable(dashFloatBtn, function() return not stunLocked end)
-- FUNCIONES ANTI-STUN
local function jump()
if not humanoid or not rootPart or not jumping then return end
jumping = false
pcall(function()
humanoid.PlatformStand = true
rootPart.Velocity = Vector3.zero
task.wait()
rootPart.Velocity = Vector3.new(0, jumpPower, 0)
humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
task.wait(0.05)
humanoid.PlatformStand = false
end)
task.wait(1.2)
jumping = true
end
local function dash()
if not humanoid or not rootPart then return end
pcall(function()
local lookVector = rootPart.CFrame.LookVector
rootPart.Velocity = Vector3.new(lookVector.X * dashForce, rootPart.Velocity.Y, lookVector.Z * dashForce)
end)
end
-- LOGICA LOCK
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
local function toggleLock()
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
end
lockButton.MouseButton1Click:Connect(toggleLock)

-- EVENTOS LOCK
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
if menuTransparency > 0.75 then menuTransparency = 0 end
menuFrame.BackgroundTransparency = menuTransparency
transBtn.Text = "Transp: " .. tostring(math.floor(menuTransparency * 100 + 0.5)) .. "%"
end)
minBtn.MouseButton1Click:Connect(function()
menuFrame.Visible = false
miniMenuBtn.Visible = true
miniMenuBtn.Position = menuFrame.Position
saveConfig()
end)
miniMenuBtn.MouseButton1Click:Connect(function()
miniMenuBtn.Visible = false
menuFrame.Visible = true
menuFrame.Position = miniMenuBtn.Position
end)
-- BOTON CERRAR
closeBtn.MouseButton1Click:Connect(function()
scriptClosed = true
antiStunEnabled = false
targetLock = false
lockedPlayer = nil
pcall(function() RunService:UnbindFromRenderStep(CAMERA_LOCK_NAME) end)
pcall(function() loadGui:Destroy() end)
pcall(function() screenGui:Destroy() end)
end)
-- EVENTOS ANTI-STUN
local function updateNsToggle()
if antiStunEnabled then
nsToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 160, 70)
nsToggleBtn.Text = "ANTI-STUN: ON"
else
nsToggleBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
nsToggleBtn.Text = "ANTI-STUN: OFF"
end
end
nsToggleBtn.MouseButton1Click:Connect(function()
antiStunEnabled = not antiStunEnabled
jumping = true
updateNsToggle()
end)
nsJumpMinus.MouseButton1Click:Connect(function()
jumpPower = math.max(10, jumpPower - 5)
nsJumpLabel.Text = "Jump Power: " .. jumpPower
end)
nsJumpPlus.MouseButton1Click:Connect(function()
jumpPower = math.min(150, jumpPower + 5)
nsJumpLabel.Text = "Jump Power: " .. jumpPower
end)
nsDashMinus.MouseButton1Click:Connect(function()
dashForce = math.max(10, dashForce - 5)
nsDashLabel.Text = "Dash Force: " .. dashForce
end)
nsDashPlus.MouseButton1Click:Connect(function()
dashForce = math.min(150, dashForce + 5)
nsDashLabel.Text = "Dash Force: " .. dashForce
end)
nsJumpSizeMinus.MouseButton1Click:Connect(function()
jumpBtnSize = math.max(30, jumpBtnSize - 2)
jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
nsJumpSizeLabel.Text = "Jump Size: " .. jumpBtnSize
end)
nsJumpSizePlus.MouseButton1Click:Connect(function()
jumpBtnSize = math.min(100, jumpBtnSize + 2)
jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
nsJumpSizeLabel.Text = "Jump Size: " .. jumpBtnSize
end)
nsDashSizeMinus.MouseButton1Click:Connect(function()
dashBtnSize = math.max(30, dashBtnSize - 2)
dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
nsDashSizeLabel.Text = "Dash Size: " .. dashBtnSize
end)
nsDashSizePlus.MouseButton1Click:Connect(function()
dashBtnSize = math.min(100, dashBtnSize + 2)
dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
nsDashSizeLabel.Text = "Dash Size: " .. dashBtnSize
end)
nsJumpGenBtn.MouseButton1Click:Connect(function() jumpBtn.Visible = not jumpBtn.Visible end)
nsDashGenBtn.MouseButton1Click:Connect(function() dashFloatBtn.Visible = not dashFloatBtn.Visible end)
nsLockBtn.MouseButton1Click:Connect(function()
stunLocked = not stunLocked
nsLockBtn.Text = stunLocked and "LOCK FLOAT: ON" or "LOCK FLOAT: OFF"
nsLockBtn.BackgroundColor3 = stunLocked and Color3.fromRGB(180, 60, 60) or Color3.fromRGB(90, 90, 100)
end)
jumpBtn.MouseButton1Click:Connect(function() jump() end)
dashFloatBtn.MouseButton1Click:Connect(function() dash() end)
-- EVENTOS DASH
local function updateDashLabel()
dashValueLabel.Text = "Multiplicador: " .. string.format("%.1f", dashMultiplier) .. "x"
end
local function hookDash()
local char = localPlayer.Character
if not char then return end
local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end
root.ChildAdded:Connect(function(child)
if not dashEnabled then return end
if child:IsA("BodyVelocity") or child:IsA("LinearVelocity") then
wait()
pcall(function()
if child:IsA("BodyVelocity") then
child.Velocity = child.Velocity * dashMultiplier
elseif child:IsA("LinearVelocity") then
child.VectorVelocity = child.VectorVelocity * dashMultiplier
end
end)
end
end)
end
dashMinusBtn.MouseButton1Click:Connect(function()
dashMultiplier = math.max(0.5, dashMultiplier - 0.1)
updateDashLabel()
end)
dashPlusBtn.MouseButton1Click:Connect(function()
dashMultiplier = math.min(4, dashMultiplier + 0.1)
updateDashLabel()
end)
dashToggleBtn.MouseButton1Click:Connect(function()
dashEnabled = not dashEnabled
dashToggleBtn.BackgroundColor3 = dashEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
dashToggleBtn.Text = dashEnabled and "ACTIVADO" or "DESACTIVADO"
end)
-- HOTKEYS (con tecla lock + captura de tecla)
UserInputService.InputBegan:Connect(function(input, processed)
if scriptClosed then return end
if listeningForKey then
if input.KeyCode ~= Enum.KeyCode.Unknown then
lockKey = input.KeyCode
listeningForKey = false
updateKeyBtn()
saveConfig()
end
return
end
if processed then return end
if input.KeyCode == lockKey then
toggleLock()
elseif input.KeyCode == Enum.KeyCode.X then
antiStunEnabled = not antiStunEnabled
jumping = true
updateNsToggle()
elseif input.KeyCode == Enum.KeyCode.Z then
antiStunEnabled = false
updateNsToggle()
elseif input.KeyCode == Enum.KeyCode.Space and antiStunEnabled then
jump()
elseif input.KeyCode == Enum.KeyCode.Q then
dash()
end
end)
-- HEARTBEAT ANTI-STUN (CORREGIDO, sin Stunned)
RunService.Heartbeat:Connect(function()
if scriptClosed or not antiStunEnabled or not humanoid or not humanoid.Parent or not jumping then return end
local state = humanoid:GetState()
if state == Enum.HumanoidStateType.FallingDown
or state == Enum.HumanoidStateType.GettingUp
or state == Enum.HumanoidStateType.PlatformStanding
or state == Enum.HumanoidStateType.Ragdoll
or state == Enum.HumanoidStateType.Physics then
jump()
end
end)
-- LOOP CAMERA LOCK (con parte elegible)
local lastDeltaTime = 1/60
local function cameraLockStep(dt)
lastDeltaTime = dt or (1/60)
if scriptClosed or not targetLock or not lockedPlayer or not lockedPlayer.Character then return end
Camera = workspace.CurrentCamera
if not Camera then return end
local root = lockedPlayer.Character:FindFirstChild("HumanoidRootPart")
local hum = lockedPlayer.Character:FindFirstChildOfClass("Humanoid")
if not root or not hum or hum.Health <= 0 then
resetLock()
return
end
local aimPart = root
if lockPart == "head" then
local head = lockedPlayer.Character:FindFirstChild("Head")
if head then aimPart = head end
end
local targetPos = aimPart.Position
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
RunService:BindToRenderStep(CAMERA_LOCK_NAME, Enum.RenderPriority.Camera.Value + 1, cameraLockStep)
-- SEGURIDAD
localPlayer.CharacterAdded:Connect(function(c)
setChar(c)
jumping = true
wait(0.5)
if targetLock then resetLock() end
hookDash()
end)
if localPlayer.Character then
hookDash()
end
-- APLICAR VALORES GUARDADOS
local function refreshAllVisuals()
lockButton.Size = UDim2.new(0, buttonSize, 0, buttonSize)
lockButton.Visible = buttonVisible
sizeLabel.Text = "Tamano: " .. tostring(buttonSize)
showBtn.Text = buttonVisible and "Boton: Visible" or "Boton: Oculto"
showBtn.BackgroundColor3 = buttonVisible and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
dragBtn.Text = "Arrastrable: " .. (isDraggable and "ON" or "OFF")
dragBtn.BackgroundColor3 = isDraggable and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
predictLabel.Text = string.format("Predict: %.2fs", predictAmount)
predictToggle.Text = predictEnabled and "ON" or "OFF"
predictToggle.BackgroundColor3 = predictEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
predictLabel.TextColor3 = predictEnabled and Color3.fromRGB(255, 220, 130) or Color3.fromRGB(150, 150, 150)
predictVertBtn.Text = "Pred Vertical: " .. (predictVertical and "ON" or "OFF")
predictVertBtn.BackgroundColor3 = predictVertical and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
predictAccBtn.Text = "Pred Accel: " .. (predictAcceleration and "ON" or "OFF")
predictAccBtn.BackgroundColor3 = predictAcceleration and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
smoothBtn.Text = "Smooth: " .. (smoothMode and "ON" or "OFF")
smoothBtn.BackgroundColor3 = smoothMode and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
smoothValLabel.Text = string.format("%.2f", smoothAmount)
dist3DBtn.Text = "Dist 3D: " .. (useDistance3D and "ON" or "OFF")
dist3DBtn.BackgroundColor3 = useDistance3D and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
updatePartBtn()
updateKeyBtn()
menuFrame.BackgroundTransparency = menuTransparency
transBtn.Text = "Transp: " .. tostring(math.floor(menuTransparency * 100 + 0.5)) .. "%"
updateNsToggle()
nsJumpLabel.Text = "Jump Power: " .. jumpPower
nsDashLabel.Text = "Dash Force: " .. dashForce
nsJumpSizeLabel.Text = "Jump Size: " .. jumpBtnSize
nsDashSizeLabel.Text = "Dash Size: " .. dashBtnSize
jumpBtn.Size = UDim2.new(0, jumpBtnSize, 0, jumpBtnSize)
dashFloatBtn.Size = UDim2.new(0, dashBtnSize, 0, dashBtnSize)
updateDashLabel()
dashToggleBtn.BackgroundColor3 = dashEnabled and Color3.fromRGB(45, 160, 70) or Color3.fromRGB(160, 50, 50)
dashToggleBtn.Text = dashEnabled and "ACTIVADO" or "DESACTIVADO"
end
refreshAllVisuals()
-- AUTOGUARDADO
spawn(function()
while true do
wait(5)
saveConfig()
end
end)
-- MOSTRAR MENU
delay(2, function()
if loadGui and loadGui.Parent then
loadGui:Destroy()
end
menuFrame.Visible = true
end)
print("Zeidop Hub FINAL cargado OK")
