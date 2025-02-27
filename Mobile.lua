--// Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService") -- HttpService to fetch the script from URL
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")

--// Create Main GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = gui

--// Create Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 100, 0, 50)
toggleButton.Position = UDim2.new(0.05, 0, 0.1, 0)
toggleButton.Text = "Menu"
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 182, 193) -- Light Pink
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = true
toggleButton.Parent = screenGui

toggleButton.MouseEnter:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 160, 180)}):Play()
end)
toggleButton.MouseLeave:Connect(function()
    TweenService:Create(toggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 182, 193)}):Play()
end)

--// Create Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 400, 0, 300)
mainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 245, 250)
mainFrame.Visible = false
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Bo góc và viền
local UICorner = Instance.new("UICorner", mainFrame)
UICorner.CornerRadius = UDim.new(0, 10)
local UIStroke = Instance.new("UIStroke", mainFrame)
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(255, 105, 180) -- Pink

--// Title Bar
local titleBar = Instance.new("TextLabel")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
titleBar.Text = "HK Hub - Game"
titleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
titleBar.Font = Enum.Font.GothamBold
titleBar.TextSize = 20
titleBar.Parent = mainFrame
local UICornerTitle = Instance.new("UICorner", titleBar)
UICornerTitle.CornerRadius = UDim.new(0, 10)

--// Enable Dragging
local function enableDragging(frame)
    local dragging, startPos, startMousePos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startPos = frame.Position
            startMousePos = input.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMousePos
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end
enableDragging(titleBar)

--// Toggle Menu Visibility
local function toggleMenu()
    if mainFrame.Visible then
        local tween = TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.3, 0, -0.5, 0)})
        tween:Play()
        tween.Completed:Connect(function()
            mainFrame.Visible = false
        end)
    else
        mainFrame.Visible = true
        TweenService:Create(mainFrame, TweenInfo.new(0.5), {Position = UDim2.new(0.3, 0, 0.2, 0)}):Play()
    end
end
toggleButton.MouseButton1Click:Connect(toggleMenu)

--// Create Left Panel (Categories)
local categoryPanel = Instance.new("ScrollingFrame")
categoryPanel.Size = UDim2.new(0, 120, 1, -30)
categoryPanel.Position = UDim2.new(0, 0, 0, 30)
categoryPanel.BackgroundColor3 = Color3.fromRGB(255, 182, 193)
categoryPanel.Parent = mainFrame
categoryPanel.CanvasSize = UDim2.new(0, 0, 2, 0)

--// Create Right Panel (Content)
local contentPanel = Instance.new("ScrollingFrame")
contentPanel.Size = UDim2.new(1, -130, 1, -30)
contentPanel.Position = UDim2.new(0, 130, 0, 30)
contentPanel.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
contentPanel.Parent = mainFrame
contentPanel.CanvasSize = UDim2.new(0, 0, 2, 0)

--// Add Categories
local categories = {
    {"Fram", {"Auto Fram", "Auto Frame Near", "Auto Fram Gem", "Auto Fram Boss"}}
}
local activePage = nil
for i, cat in pairs(categories) do
    local categoryButton = Instance.new("TextButton")
    categoryButton.Size = UDim2.new(1, 0, 0, 30)
    categoryButton.Position = UDim2.new(0, 0, 0, (i - 1) * 35)
    categoryButton.Text = cat[1]
    categoryButton.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    categoryButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    categoryButton.Parent = categoryPanel
    
    local pageFrame = Instance.new("Frame")
    pageFrame.Size = UDim2.new(1, 0, 1, 0)
    pageFrame.BackgroundColor3 = Color3.fromRGB(255, 240, 245)
    pageFrame.Visible = false
    pageFrame.Parent = contentPanel
    
    for j, sub in pairs(cat[2]) do
        local subButton = Instance.new("TextButton")
        subButton.Size = UDim2.new(1, 0, 0, 30)
        subButton.Position = UDim2.new(0, 0, 0, (j - 1) * 35)
        subButton.Text = sub
        subButton.BackgroundColor3 = Color3.fromRGB(255, 160, 180)
        subButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        subButton.Parent = pageFrame
    end
    categoryButton.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        activePage = pageFrame
        pageFrame.Visible = true
    end)
end

--// Load External Lua Script and Execute
local url = "https://raw.githubusercontent.com/huyyyyyyyyyyyyyyyyyyy/HKHub/refs/heads/main/AutoQuest.lua"
local success, response = pcall(function()
    return HttpService:GetAsync(url)
end)

if success then
    -- Execute the fetched Lua code
    loadstring(response)()
else
    warn("Failed to fetch the script.")
end