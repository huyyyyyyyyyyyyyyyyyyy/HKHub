--// Services
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

--// Auto Farm Script Variables
local isActive = false  -- Trạng thái bật/tắt auto farm
local clickDelay = 0.1  -- Giảm delay để đánh xa nhanh hơn
local questDelay = 1  -- Thời gian chờ giữa mỗi lần nhận nhiệm vụ
local lastLevel = 0  -- Lưu level trước đó để kiểm tra khi qua level mới
local bossRespawnTime = 23  -- Thời gian chờ spawn lại cho quái đặc biệt
local skillZDelay = 0.5  -- Thời gian chờ giữa mỗi lần nhấn Z
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Hàm cập nhật character và humanoidRootPart khi hồi sinh
local function updateCharacter()
    character = player.Character or player.CharacterAdded:Wait()
    humanoidRootPart = character:WaitForChild("HumanoidRootPart")
end

-- Tự động cầm Tool "Combat"
local function autoEquipTool()
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild("Combat")
        if tool and character then
            character.Humanoid:EquipTool(tool)
            print("Đã cầm Tool Combat!")
        end
    end
end

-- Hàm mô phỏng nhấn phím Z
local function useSkillZ()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
    wait(0.05)  -- Thời gian giữ phím
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
    print("Đã tự động nhấn phím Z!")
end

-- Lắng nghe sự kiện hồi sinh và tự động cầm tool
player.CharacterAdded:Connect(function(newCharacter)
    if isActive then
        updateCharacter()
        autoEquipTool()  -- Cầm tool ngay sau khi hồi sinh
        print("Nhân vật đã hồi sinh, tiếp tục hoạt động!")
    end
end)

-- Lấy cấp độ từ GUI
local function getLevel()
    local levelLabel = player.PlayerGui.HUD.Left.LevelAndCurrency.LevelAndRace.Level
    local levelText = levelLabel.Text  
    local levelNumber = tonumber(levelText:match("%d+"))  
    return levelNumber or 0  
end

-- Xác định NPC nhận quest theo level
local function getQuestNPC()
    local level = getLevel()
    if level < 25 then
        return workspace.Islands["Starter Island"].NPCs.FloppaQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 50 then
        return workspace.Islands["Starter Island"].NPCs.DiamondFloppaQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 100 then
        return workspace.Islands["Starter Island"].NPCs.DogeQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 125 then
        return workspace.Islands["Starter Island"].NPCs.PopcatBossQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 150 then
        return workspace.Islands["Desert Island"].NPCs.QuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 200 then
        return workspace.Islands["Desert Island"].NPCs:GetChildren()[5].FloppaNPC.ProximityPrompt
    elseif level < 250 then
        return workspace.Islands["Desert Island"].NPCs:GetChildren()[6].FloppaNPC.ProximityPrompt
    elseif level < 300 then
        return workspace.Islands["Desert Island"].NPCs.BossQuestNPC.HumanoidRootPart.ProximityPrompt
    elseif level < 350 then
        return workspace.Islands["Forest Island"].NPCs.QuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 400 then
        return workspace.Islands["Forest Island"].NPCs:GetChildren()[5].FloppaNPC.ProximityPrompt
    elseif level < 475 then
        return workspace.Islands["Forest Island"].NPCs:GetChildren()[6].FloppaNPC.ProximityPrompt
    elseif level < 500 then
        return workspace.Islands["Forest Island"].NPCs.BossQuestNPC.HumanoidRootPart.ProximityPrompt
    elseif level < 550 then
        return workspace.Islands["Bacon Island"].NPCs.BaconNoobQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 600 then
        return workspace.Islands["Bacon Island"].NPCs.HamsterQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 650 then
        return workspace.Islands["Bacon Island"].NPCs.EggDogeQuestNPC.FloppaNPC.ProximityPrompt
    elseif level < 700 then
        return workspace.Islands["Bacon Island"].NPCs.LordBaconBossQuestNPC.HumanoidRootPart.ProximityPrompt
    elseif level < 750 then
        return workspace.Islands["Meme Mountain"].NPCs:GetChildren()[5].FloppaNPC.ProximityPrompt
    elseif level < 800 then
        return workspace.Islands["Meme Mountain"].NPCs.QuestNPC.FloppaNPC.ProximityPrompt
    end
    return nil
end

-- Xác định quái theo level
local function getMob()
    local level = getLevel()
    local mobPath = nil
    if level < 25 then
        mobPath = workspace.Mobs.Floppa
    elseif level < 50 then
        mobPath = workspace.Mobs["Diamond Floppa"]
    elseif level < 100 then
        mobPath = workspace.Mobs.Doge
    elseif level < 125 then
        mobPath = workspace.Mobs.Popcat
    elseif level < 150 then
        mobPath = workspace.Mobs.Noob
    elseif level < 200 then
        mobPath = workspace.Mobs.Cheems
    elseif level < 250 then
        mobPath = workspace.Mobs.Walter
    elseif level < 300 then
        mobPath = workspace.Mobs.StrongNoob
    elseif level < 350 then
        mobPath = workspace.Mobs["Toy Monkey"]
    elseif level < 400 then
        mobPath = workspace.Mobs.Gorilla
    elseif level < 475 then
        mobPath = workspace.Mobs:GetChildren()[84]
    elseif level < 500 then
        mobPath = workspace.Mobs.MonkeyKing
    elseif level < 550 then
        mobPath = workspace.Mobs:GetChildren()[62]
    elseif level < 600 then
        mobPath = workspace.Mobs.Hamster
    elseif level < 650 then
        mobPath = workspace.Mobs:GetChildren()[79]
    elseif level < 700 then
        mobPath = workspace.Mobs.LordBacon
    elseif level < 750 then
        mobPath = workspace.Mobs:GetChildren()[115]
    elseif level < 800 then
        mobPath = workspace.Mobs:GetChildren()[94]
    end
    return mobPath
end

-- Auto nhận quest và trả về trạng thái thành công
local function autoQuest()
    while isActive do
        local npc = getQuestNPC()
        if npc then
            fireproximityprompt(npc)
            print("Nhận nhiệm vụ từ NPC:", npc.Parent.Name)
            wait(questDelay)
            return true  -- Nhiệm vụ nhận thành công
        end
        wait(questDelay)
    end
    return false
end

-- Kiểm tra Tool có đang được cầm không
local function isToolEquipped()
    character = player.Character or player.CharacterAdded:Wait()
    if character then
        for _, item in ipairs(character:GetChildren()) do
            if item:IsA("Tool") and item.Name == "Combat" then
                return item
            end
        end
    end
    return nil
end

-- Auto Click (đánh xa)
local function autoClickLoop()
    while isActive do
        local tool = isToolEquipped()
        if tool then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            wait(0.05)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
        wait(clickDelay)  -- Delay nhỏ để đánh nhanh hơn từ xa
    end
end

-- **DỊCH CHUYỂN, BAY LÊN ĐẦU QUÁI VÀ GOM QUÁI MƯỢT**
local function moveToMob(mob)
    if mob and mob:FindFirstChild("HumanoidRootPart") then
        local mobHRP = mob.HumanoidRootPart
        local targetPosition = mobHRP.Position + Vector3.new(0, 10, 0)  -- Trên đầu quái
        local startPosition = humanoidRootPart.Position
        local duration = 0.5  -- Thời gian di chuyển ban đầu (giây)
        local elapsed = 0

        -- Di chuyển ban đầu lên đầu quái
        local moveConnection
        moveConnection = RunService.Heartbeat:Connect(function(deltaTime)
            elapsed = elapsed + deltaTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            humanoidRootPart.CFrame = CFrame.new(startPosition:Lerp(targetPosition, alpha))

            if alpha >= 1 then
                moveConnection:Disconnect()
                print("Đã bay lên đầu quái:", mob.Name)
            end
        end)

        -- Gom quái cùng loại lại dưới chân người chơi (mượt mà), trừ các quái chờ 23 giây
        local mobType = mob.Name
        local shouldGather = mobType ~= "Popcat" and mobType ~= "StrongNoob" and mobType ~= "MonkeyKing" and mobType ~= "LordBacon"
        
        if shouldGather then
            local mobsFolder = workspace.Mobs
            local gatherPosition = mobHRP.Position - Vector3.new(0, 5, 0)  -- Gom dưới chân quái chính
            local gatherDuration = 1  -- Thời gian gom quái (giây)

            for _, otherMob in ipairs(mobsFolder:GetChildren()) do
                if otherMob.Name == mobType and otherMob ~= mob and otherMob:FindFirstChild("HumanoidRootPart") then
                    local otherMobHRP = otherMob.HumanoidRootPart
                    local startMobPosition = otherMobHRP.Position
                    local mobElapsed = 0

                    local gatherConnection
                    gatherConnection = RunService.Heartbeat:Connect(function(deltaTime)
                        mobElapsed = mobElapsed + deltaTime
                        local alpha = math.clamp(mobElapsed / gatherDuration, 0, 1)
                        otherMobHRP.CFrame = CFrame.new(startMobPosition:Lerp(gatherPosition, alpha))

                        if alpha >= 1 then
                            gatherConnection:Disconnect()
                        end
                    end)
                end
            end
            print("Đã gom các quái loại:", mobType, "dưới chân quái chính")
        else
            print("Không gom quái vì đây là:", mobType)
        end

        -- Giữ cố định trên đầu quái, xử lý khi quái chết
        local followConnection
        followConnection = RunService.Heartbeat:Connect(function()
            if not isActive then
                followConnection:Disconnect()
                return
            end

            -- Nếu quái hiện tại vẫn tồn tại, bay trên đầu nó
            if mob and mob:FindFirstChild("HumanoidRootPart") then
                humanoidRootPart.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 10, 0))
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)  -- Xóa vận tốc để tránh trôi
                humanoidRootPart.Anchored = true  -- Neo để bay lơ lửng

                -- Tự động nhấn Z nếu là quái đặc biệt
                if mobType == "Popcat" or mobType == "StrongNoob" or mobType == "MonkeyKing" or mobType == "LordBacon" then
                    useSkillZ()
                    wait(skillZDelay)  -- Chờ giữa các lần nhấn Z
                end
            else
                humanoidRootPart.Anchored = false  -- Bỏ neo khi quái chết
                -- Kiểm tra nếu là quái đặc biệt thì chờ spawn lại
                if mobType == "Popcat" or mobType == "StrongNoob" or mobType == "MonkeyKing" or mobType == "LordBacon" then
                    print("Quái", mobType, "đã chết, chờ", bossRespawnTime, "giây để spawn lại...")
                    wait(bossRespawnTime)
                    local newMob = getMob()  -- Tìm quái mới sau khi chờ
                    if newMob and newMob:FindFirstChild("HumanoidRootPart") then
                        mob = newMob
                        mobHRP = mob.HumanoidRootPart
                        humanoidRootPart.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 10, 0))
                        print("Quái", mob.Name, "đã spawn lại, tiếp tục bay lên đầu!")
                    else
                        print("Chưa tìm thấy quái", mobType, "sau khi chờ!")
                        followConnection:Disconnect()
                    end
                else
                    -- Tìm quái khác cùng loại nếu không phải quái đặc biệt
                    local newMob = nil
                    local mobsFolder = workspace.Mobs
                    for _, otherMob in ipairs(mobsFolder:GetChildren()) do
                        if otherMob.Name == mobType and otherMob:FindFirstChild("HumanoidRootPart") then
                            newMob = otherMob
                            break
                        end
                    end

                    if newMob then
                        mob = newMob  -- Chuyển sang quái mới
                        mobHRP = mob.HumanoidRootPart
                        humanoidRootPart.CFrame = CFrame.new(mobHRP.Position + Vector3.new(0, 10, 0))
                        print("Chuyển sang quái mới:", mob.Name)
                    else
                        followConnection:Disconnect()  -- Không còn quái nào, dừng bám
                        print("Không còn quái cùng loại để bám!")
                    end
                end
            end
        end)
    end
end

-- Auto di chuyển và bám theo quái
local function autoMoveToMob()
    while isActive do
        updateCharacter()  -- Cập nhật character mỗi vòng lặp để xử lý hồi sinh
        autoEquipTool()    -- Tự động cầm tool mỗi vòng lặp
        local currentLevel = getLevel()
        local mob = getMob()

        if currentLevel > lastLevel then
            -- Nếu level tăng, nhận nhiệm vụ mới trước khi đánh mobs mới
            if autoQuest() then
                lastLevel = currentLevel  -- Cập nhật level sau khi nhận nhiệm vụ thành công
            end
        end

        if mob then
            moveToMob(mob)
            
            -- Nếu đánh Popcat, StrongNoob, MonkeyKing hoặc LordBacon thì chờ 23 giây sau khi giết
            if mob.Name == "Popcat" or mob.Name == "StrongNoob" or mob.Name == "MonkeyKing" or mob.Name == "LordBacon" then
                print("Chờ", bossRespawnTime, "giây sau khi giết", mob.Name)
                wait(bossRespawnTime)
            else
                wait(1)  -- Chờ bình thường với các quái khác
            end
        else
            wait(1)  -- Nếu không tìm thấy quái, chờ 1 giây
        end
    end
end

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
        subButton.Text = sub .. " (OFF)"
        subButton.BackgroundColor3 = Color3.fromRGB(255, 160, 180)
        subButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        subButton.Parent = pageFrame
        
        -- Thêm sự kiện click cho nút "Auto Fram"
        if sub == "Auto Fram" then
            subButton.MouseButton1Click:Connect(function()
                isActive = not isActive
                if isActive then
                    updateCharacter()  -- Cập nhật ngay khi bật
                    autoEquipTool()    -- Cầm tool ngay khi bật
                    lastLevel = getLevel()  -- Khởi tạo level ban đầu
                    print("🚀 Auto ON: Quest + Click + Bay lên đầu quái và đánh xa")
                    task.spawn(autoQuest)
                    task.spawn(autoClickLoop)
                    task.spawn(autoMoveToMob)
                else
                    humanoidRootPart.Anchored = false  -- Bỏ neo khi tắt
                    print("🛑 Auto OFF!")
                end
                subButton.Text = isActive and "Auto Fram (ON)" or "Auto Fram (OFF)"
            end)
        end
    end
    categoryButton.MouseButton1Click:Connect(function()
        if activePage then activePage.Visible = false end
        activePage = pageFrame
        pageFrame.Visible = true
    end)
end