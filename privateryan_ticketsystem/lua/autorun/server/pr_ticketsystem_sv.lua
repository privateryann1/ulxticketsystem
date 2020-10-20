util.AddNetworkString("PR_TicketSystem.Ticket")
util.AddNetworkString("PR_TicketSystem.Cancel")
util.AddNetworkString("PR_TicketSystem.Close")
util.AddNetworkString("PR_TicketSystem.Closed")
util.AddNetworkString("PR_TicketSystem.Accepted")
util.AddNetworkString("PR_TicketSystem.Hide")
util.AddNetworkString("PR_TicketSystem.Canceled")

local function hasPerm(ply)
    if ply:query("ulx seeasay") then
        return true
    end
end

function PR_TicketSystem.Chat(ply,text)
    if string.StartWith(text,"#") and !string.find(string.lower(text),"#cancel") then
        if ply:GetNWBool("pr_ticketsystem_active", false) then
            ply:ChatPrint("You already have a ticket open. Write '#cancel' to cancel your current ticket.")
        return "" end
        ply:SetNWBool("pr_ticketsystem_active", true)
        ply:ChatPrint("You have opened a ticket, a staff member will be with you shortly.")
        for k,v in pairs(player.GetAll()) do
            if hasPerm(ply) then
                net.Start("PR_TicketSystem.Ticket")
                    net.WriteString(string.sub(text,2))
                    net.WriteEntity(ply)
                net.Send(v)
            end
        end
    return "" end
    if string.lower(text) == "#cancel" then
        if !ply:GetNWBool("pr_ticketsystem_active", false) then
            ply:ChatPrint("You do not have a ticket open.")
        return "" end
        for k,v in pairs(player.GetAll()) do
            if hasPerm(ply) then
                net.Start("PR_TicketSystem.Cancel")
                    net.WriteEntity(ply)
                net.Send(v)
            end
        end
    return "" end
    --[[if string.lower(text) == "/cleartickets" then
        for k,v in pairs(player.GetAll()) do
            v:SetNWBool("pr_ticketsystem_active", false)
        end
    return "" end]]
end
hook.Add("PlayerSay", "PR_TicketSystemChat", PR_TicketSystem.Chat)
--[[
function PR_TicketSystem.DisableDefault(ply,cmd)
    if cmd == "ulx asay" then
        return false
    end
end
hook.Add("ULibCommandCalled", "PR_TicketSystemDisableAsay", PR_TicketSystem.DisableDefault)]]

function PR_TicketSystem.CloseSV()
    local caller = net.ReadEntity()
    caller:SetNWBool("pr_ticketsystem_active", false)
end
net.Receive("PR_TicketSystem.Close", PR_TicketSystem.CloseSV)

net.Receive("PR_TicketSystem.Hide", function()
    local ply = net.ReadString()
    for k,v in pairs(player.GetAll()) do
        if v:SteamID64() != ply then
            net.Start("PR_TicketSystem.Hide")
                net.WriteString(v:SteamID64())
                net.WriteString(ply)
            net.Send(v)
            --print("Removing ticket from " .. v:Nick() .. "'s screen")
        end
    end
end)

net.Receive("PR_TicketSystem.Accepted", function()
    for k,v in pairs(player.GetAll()) do
        if v:SteamID64() == net.ReadString() then
            net.Start("PR_TicketSystem.Accepted")
                net.WriteString(v:SteamID64())
            net.Send(v)
        end
    end
end)

net.Receive("PR_TicketSystem.Closed", function()
    local caller = net.ReadEntity()
    for k,v in pairs(player.GetAll()) do
        if v:SteamID64() == caller:SteamID64() then
            net.Start("PR_TicketSystem.Closed")
                net.WriteString(v:SteamID64())
            net.Send(v)
        end
    end
end)

net.Receive("PR_TicketSystem.Canceled", function()
    local caller = net.ReadEntity()
    for k,v in pairs(player.GetAll()) do
        if v:SteamID64() == caller:SteamID64() then
            net.Start("PR_TicketSystem.Canceled")
                net.WriteString(v:SteamID64())
            net.Send(v)
        end
    end
end)