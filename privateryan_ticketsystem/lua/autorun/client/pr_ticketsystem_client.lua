local color_white = Color(255,255,255,255)
local color_black_translucent = Color(0,0,0,200)
local color_black_translucent3 = Color(100,100,100,50)
local color_hover = Color(37, 177, 247,255)

local blur = Material("pp/blurscreen")

local scale = function(num, isY)
    return num * (isY and (ScrH() / 1080) or (ScrW() / 1920))
end

local atickets = atickets or {}
local atickets_ply = {}
local atickets_acceptor = {}

local function RyanYManager(frm)
    local key
    local pos = {scale(25),scale(180),scale(335),scale(490),scale(645),scale(800)} --Table of Y positions
    for k,v in pairs(atickets) do -- Loop through the active tickets
        if !v:IsValid() then table.RemoveByValue(atickets,v) end
        key = table.KeyFromValue(atickets,v) -- Grab the key
    end
    if table.IsEmpty(atickets) then
        return pos[1]
    end
    for k,v in pairs(pos) do -- Loop through the table of Y positions
        if k == key then -- If the keys match
            return v -- Return the postions :)
        end
    end
end


surface.CreateFont( "headerfont", {
    font = "Segoe UI Light", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = scale(20),
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

surface.CreateFont( "contentfont", {
    font = "Roboto", --  Use the font-name which is shown to you by your operating system Font Viewer, not the file name
    extended = false,
    size = scale(17),
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
})

function PR_TicketSystem.DrawBlur( p, a, d )
    local x, y = p:LocalToScreen(0, 0)
    surface.SetDrawColor( 0, 0, 0 )
    surface.SetMaterial( blur )
    for i = 1, d do
    	blur:SetFloat( "$blur", (i / d ) * a  )
    	blur:Recompute()
    	render.UpdateScreenEffectTexture()
    	surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
    end
end

local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0
    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)
        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end
        return char
    end)
    return text, totalWidth
end

function PR_TicketSystem.textWrap(text, font, maxWidth)
    local totalWidth = 0
    surface.SetFont(font)
    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end
            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen
            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end
            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end
            totalWidth = wordlen
            return '\n' .. word
        end)
    return text
end

local function drawOutlinedBox(x, y, w, h, thickness, clr)
    surface.SetDrawColor(clr)
    for i = 0, thickness - 1 do
        surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
    end
end

function PR_TicketSystem.CreateWindow(caller,text)
    if !caller:IsValid() then return end
    if !caller:IsPlayer() then return end
    local color_unclaim_wt = Color(255,255,255,100)
    local color_unclaim_wt2 = Color(255,255,255,70)
    local color_border = Color(255,255,255,255)
    local frame = vgui.Create("DFrame") -- Main frame
    table.insert(atickets,frame)
    atickets_ply[caller:SteamID64()] = frame
    frame:MoveTo(scale(28),RyanYManager(frame),0,0)

    frame:SetSize(scale(300), scale(150))
    frame:SetTitle("")
    frame:SetDraggable(false)
    frame:ShowCloseButton(false)
    frame.Paint = function(self,w,h)
        PR_TicketSystem.DrawBlur(self,3,6)
        surface.SetDrawColor(color_black_translucent) -- Background
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_unclaim_wt)
        surface.DrawRect(scale(15),scale(35),w - scale(30),scale(1))
        drawOutlinedBox(0, 0, w, h, 1, color_border)
        draw.SimpleText(caller:Nick(), "headerfont", scale(145),scale(10),color_white,1)
    end
    frame.accepted = false

    local tickettext = vgui.Create("DLabel", frame)
    local wrappedtext = PR_TicketSystem.textWrap(text, "contentfont", scale(250))
    tickettext:SetPos(scale(20),scale(40))
    tickettext:SetTextColor(color_white)
    tickettext:SetFont("contentfont")
    tickettext:SetText(wrappedtext)
    tickettext:SizeToContents()

    local acceptbut = vgui.Create("DButton", frame)
    acceptbut:SetTextColor(color_white)
    acceptbut:SetText("Accept")
    acceptbut:SetSize(scale(65),scale(25))
    acceptbut:SetPos(scale(40),scale(115))
    acceptbut.Paint = function(self,w,h)
        surface.SetDrawColor(color_black_translucent3) -- Background
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_unclaim_wt2)
        surface.DrawOutlinedRect(0,0,w,h)

        if acceptbut:IsHovered() then
            acceptbut:SetTextColor(color_hover)
        else
            acceptbut:SetTextColor(color_white)
        end
    end

    local ignorebut = vgui.Create("DButton", frame)
    ignorebut:SetTextColor(color_white)
    ignorebut:SetText("Ignore")
    ignorebut:SetSize(scale(65),scale(25))
    ignorebut:SetPos(scale(115),scale(115))
    ignorebut.Paint = function(self,w,h)
        surface.SetDrawColor(color_black_translucent3) -- Background
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_unclaim_wt2)
        surface.DrawOutlinedRect(0,0,w,h)

        if ignorebut:IsHovered() then
            ignorebut:SetTextColor(color_hover)
        else
            ignorebut:SetTextColor(color_white)
        end
    end
    ignorebut.DoClick = function(self)
        color_unclaim_wt = Color(255,255,255,100)
        color_unclaim_wt2 = Color(255,255,255,70)
        color_unclaim_w = Color(255,255,255,255)
        table.RemoveByValue(atickets,frame)

        self:GetParent():Remove()
        if self:GetText() == "Cancel" then
            net.Start("PR_TicketSystem.Close")
                net.WriteEntity(caller)
            net.SendToServer()
            net.Start("PR_TicketSystem.Canceled")
                net.WriteEntity(caller)
            net.SendToServer()
        end
    end

    local actionsbut = vgui.Create("DButton", frame)
    actionsbut:SetTextColor(color_white)
    actionsbut:SetText("Actions")
    actionsbut:SetSize(scale(65),scale(25))
    actionsbut:SetPos(scale(190),scale(115))
    actionsbut.Paint = function(self,w,h)
        surface.SetDrawColor(color_black_translucent3) -- Background
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(color_unclaim_wt2)
        surface.DrawOutlinedRect(0,0,w,h)
        if actionsbut:IsHovered() then
            actionsbut:SetTextColor(color_hover)
        else
            actionsbut:SetTextColor(color_white)
        end
    end
    actionsbut.DoClick = function()
        local actionsmenu = DermaMenu(actionsbut)
        actionsmenu:SetPos(input.GetCursorPos())
        local steamidbut = actionsmenu:AddOption("Copy SteamID", function()
            SetClipboardText(tostring(caller:SteamID()))
            chat.AddText(color_white, "You copied " .. caller:Nick() .. "'s SteamID.")
        end)
        steamidbut:SetIcon("icon16/page_copy.png")
        actionsmenu:AddSpacer()
        local bringbut = actionsmenu:AddOption("Bring", function()
            LocalPlayer():ConCommand("ulx bring $" .. caller:SteamID())
        end)
        bringbut:SetIcon("icon16/arrow_left.png")
        local gotobut = actionsmenu:AddOption("Goto", function()
            LocalPlayer():ConCommand("ulx goto $" .. caller:SteamID())
        end)
        gotobut:SetIcon("icon16/arrow_right.png")
        local returnbut = actionsmenu:AddOption("Return", function()
            LocalPlayer():ConCommand("ulx return $" .. caller:SteamID())
        end)
        returnbut:SetIcon("icon16/arrow_refresh.png")
    end
    acceptbut.DoClick = function(self)
        if !frame.accepted then
            net.Start("PR_TicketSystem.Hide")
                net.WriteString(LocalPlayer():SteamID64())
            net.SendToServer()
            net.Start("PR_TicketSystem.Accepted")
                net.WriteString(caller:SteamID64())
            net.SendToServer()
            atickets_acceptor[LocalPlayer():SteamID64()] = frame
            color_unclaim_wt = Color(0, 209, 0,100)
            color_border = Color(0,209,0,100)
            color_unclaim_wt2 = Color(0, 209, 0,70)
            color_unclaim_w = Color(0, 209, 0,255)
            ignorebut:SetText("Cancel")
            acceptbut:SetText("Finish")
            frame.accepted = true
        else
            table.RemoveByValue(atickets,frame)
            table.RemoveByValue(atickets_acceptor, frame)
            self:GetParent():Remove()
            color_unclaim_wt = Color(255,255,255,100)
            color_unclaim_wt2 = Color(255,255,255,70)
            color_border = Color(255,255,255,255)
            color_unclaim_w = Color(255,255,255,255)
            net.Start("PR_TicketSystem.Close")
                net.WriteEntity(caller)
            net.SendToServer()
             net.Start("PR_TicketSystem.Closed")
                net.WriteEntity(caller)
            net.SendToServer()
        end
    end
    function PR_TicketSystem_Cancel(ent)
        table.RemoveByValue(atickets,frame)
        table.RemoveByValue(atickets_acceptor, frame)
    end
end

function PR_TicketSystem.Cancel()
    local ent = net.ReadEntity()
    for k,v in pairs(atickets_ply) do
        if k == ent:SteamID64() then
            v:Remove()
            ent:ChatPrint("Ticket cancelled.")
            net.Start("PR_TicketSystem.Close")
                net.WriteEntity(ent)
            net.SendToServer()
            PR_TicketSystem_Cancel(ent)
        end
    end
end
net.Receive("PR_TicketSystem.Cancel", PR_TicketSystem.Cancel)

net.Receive("PR_TicketSystem.Ticket", function()
    local text = net.ReadString()
    local ent = net.ReadEntity()
    PR_TicketSystem.CreateWindow(ent,text)
end)

net.Receive("PR_TicketSystem.Accepted", function(len,pl)
    LocalPlayer():ChatPrint("Your ticket has been accepted.")
end)

net.Receive("PR_TicketSystem.Closed", function(len,pl)
    LocalPlayer():ChatPrint("Your ticket has been resolved.")
end)

net.Receive("PR_TicketSystem.Canceled", function(len,pl)
    LocalPlayer():ChatPrint("Your ticket has been cancelled.")
end)

net.Receive("PR_TicketSystem.Hide", function()
    local a = net.ReadString()
    local b = net.ReadString()
    --print("received netmsg")
    for k,v in pairs(atickets_ply) do
        if k == a or b then
            v:Remove()
        end
    end
end)