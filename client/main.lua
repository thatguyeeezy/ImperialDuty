local onduty = false
local playerBlip = nil

--

local weapons = Config.Weapons
local serverId = PlayerId()

RegisterCommand("duty", function()
    
    if onduty then
        onduty = false
        TriggerServerEvent("Imperial:RemoveUnitOnDuty", serverId)
        ShowNotification("You are now ~r~off-duty~w~.")
        
        for _, weapon in ipairs(weapons) do
            RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
        end
        
        if playerBlip then
            RemoveBlip(playerBlip)
            playerBlip = nil
        end

    else
        onduty = true
        TriggerServerEvent("Imperial:AddUnitOnDuty", serverId)
        ShowNotification("You are now ~g~on-duty~w~.")
        SetPedArmour(PlayerPedId(), 100)
        
        for _, weapon in ipairs(weapons) do
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 250, false, true)
            SetPedAmmo(PlayerPedId(), GetHashKey(weapon), 250)
        end
    end
end, false)

function ShowNotification(message)  
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostMessagetext("CHAR_CHAT_CALL", "CHAR_CHAT_CALL", true, 1, "ImperialCAD", "Law Enforcement")
end