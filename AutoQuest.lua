-- Định nghĩa đường dẫn đến ProximityPrompt
local proximityPrompt = workspace.Islands["Starter Island"].NPCs.FloppaQuestNPC.FloppaNPC.ProximityPrompt

-- Hàm để kích hoạt ProximityPrompt
local function activatePrompt()
    -- Kiểm tra xem ProximityPrompt có tồn tại không
    if proximityPrompt and proximityPrompt:IsA("ProximityPrompt") then
        -- Kích hoạt ProximityPrompt
        fireproximityprompt(proximityPrompt)
    else
        warn("Không tìm thấy ProximityPrompt!")
    end
end

-- Gọi hàm ngay lập tức
activatePrompt()

-- Tùy chọn: Lặp lại sau khoảng thời gian nhất định (ví dụ: mỗi 5 giây)
while true do
    wait(5) -- Đợi 5 giây
    activatePrompt()
end