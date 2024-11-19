local OnDutyUnits = {}

RegisterNetEvent("Imperial:AddUnitOnDuty")
AddEventHandler("Imperial:AddUnitOnDuty", function()
    local serverId = source
    table.insert(OnDutyUnits, serverId)
    print("Added to OnDuty Units: " .. GetPlayerName(serverId))
    PrintTable(OnDutyUnits)

end)

RegisterNetEvent("Imperial:RemoveUnitOnDuty")
AddEventHandler("Imperial:RemoveUnitOnDuty", function()
    local serverId = source

    -- Remove player from OnDutyUnits table
    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end
    end

    print("Removed from OnDuty Units: " .. GetPlayerName(serverId))
end)

function GetOnDutyUnits()
    return OnDutyUnits
end

-- Utility function to print tables
    function PrintTable(tbl)
        for k, v in pairs(tbl) do
            print(k, v)
        end
    end

    exports('GetOnDutyUnits', GetOnDutyUnits)