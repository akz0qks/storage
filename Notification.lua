-- // Ars.red Notification Library (Full & Fixed Version)
local Notifications = {}
Notifications.Font = 'Plex'
Notifications.ChatGui = nil

-- // Bypass for LPH_NO_VIRTUALIZE (To ensure it works on every executor)
local LPH_NO_VIRTUALIZE = (getgenv and getgenv().LPH_NO_VIRTUALIZE) or function(f) return f end

local yOffset = 15
local defaultPosition = Vector2.new(15, 327)
local watermarkFormat = '[%s]'
local notifs = {}

local Notification = LPH_NO_VIRTUALIZE(function(waittime, text, mode, color)
    task.spawn(function()
        local selfIdx = 0

        for i, v in next, notifs do
            selfIdx = math.max(selfIdx, v)
        end
        
        selfIdx += 1
        table.insert(notifs, selfIdx)
        
        -- // Mode Text (Outline/Shadow)
        local modeShadow = Drawing.new("Text")
        modeShadow.Font = Drawing.Fonts[Notifications.Font] or 2
        modeShadow.Size = 13
        modeShadow.Outline = false
        modeShadow.Color = Color3.fromRGB(0, 0, 0)
        modeShadow.Text = mode
        modeShadow.Visible = true
        modeShadow.Transparency = 1 -- เปลี่ยนเป็น 1 เพื่อให้เห็นชัดตอนเริ่ม

        -- // Calculate Position (Based on Chat or Default)
        local yPosition = 300
        if (Notifications.ChatGui) then
            pcall(function()
                yPosition = Notifications.ChatGui:WaitForChild("Input").Position.Y.Offset
            end)
        end

        modeShadow.Position = Vector2.new(-10, yPosition + 26) + (Vector2.new(0, 15) * (selfIdx - 1))

        local modeTxt = Drawing.new("Text")
        modeTxt.Font = modeShadow.Font
        modeTxt.Size = 13
        modeTxt.Color = color
        modeTxt.Text = mode
        modeTxt.Visible = true
        modeTxt.Transparency = 1
        modeTxt.Position = modeShadow.Position - Vector2.new(1, 1)

        -- // Notification Text
        local textShadow = Drawing.new("Text")
        textShadow.Font = modeShadow.Font
        textShadow.Size = 13
        textShadow.Color = Color3.fromRGB(0, 0, 0)
        textShadow.Text = text
        textShadow.Visible = true
        textShadow.Transparency = 1
        textShadow.Position = modeShadow.Position + Vector2.new(modeShadow.TextBounds.X + 4, 0)

        local textTxt = Drawing.new("Text")
        textTxt.Font = modeShadow.Font
        textTxt.Size = 13
        textTxt.Color = Color3.fromRGB(235, 235, 235)
        textTxt.Text = text
        textTxt.Visible = true
        textTxt.Transparency = 1
        textTxt.Position = textShadow.Position - Vector2.new(1, 1)

        -- // Smooth Fade-in & Movement
        for i = 0, 15, 3 do
            task.wait()
            local move = Vector2.new(i, 0)
            modeShadow.Position += move
            modeTxt.Position += move
            textShadow.Position += move
            textTxt.Position += move
        end

        -- // Wait for the duration
        task.wait(tonumber(waittime))

        -- // Fade-out logic
        for i = 1, 0, -0.25 do
            task.wait()
            modeShadow.Transparency = i
            textShadow.Transparency = i
            modeTxt.Transparency = i
            textTxt.Transparency = i
        end
        
        -- // Cleanup
        modeShadow:Remove()
        textShadow:Remove()
        modeTxt:Remove()
        textTxt:Remove()
        
        local findIdx = table.find(notifs, selfIdx)
        if findIdx then
            table.remove(notifs, findIdx)
        end
    end)
end)

Notifications.Notify = LPH_NO_VIRTUALIZE(function(self, message, lifeTime, cheatName, cheatColor)
    return Notification(lifeTime or 5, message or "", cheatName or "[ars.red]", cheatColor or Color3.fromRGB(255, 73, 73))
end)

return Notifications
