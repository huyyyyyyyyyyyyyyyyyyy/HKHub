local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local isActive = false  -- Trạng thái bật/tắt toàn bộ chức năng
local clickDelay = 0.1  -- Giảm delay để đánh xa nhanh hơn
local questDelay = 1  -- Thời gian chờ giữa mỗi lần nhận nhiệm vụ
local lastLevel = 0  -- Lưu level trước đó để kiểm tra khi qua level mới
local bossRespawnTime = 23  -- Thời gian chờ spawn lại cho quái đặc biệt
local skillZDelay = 0.5  -- Thời gian chờ giữa mỗi lần nhấn Z

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

-- **TẮT/BẬT TOÀN BỘ HỆ THỐNG BẰNG PHÍM `X`**
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
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
    end
end)