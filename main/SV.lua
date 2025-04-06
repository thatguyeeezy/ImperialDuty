local OnDutyUnits = {}
local OnDutyLEOUnits = {}
local OnDutyFireUnits = {}

-- Table to store department information for each player
local PlayerDepartments = {}

local sendWebhook = Config.SendWebhook
local webhookURL = Config.WebhookURL

RegisterNetEvent("Imperial:AddUnitOnDuty")
AddEventHandler("Imperial:AddUnitOnDuty", function(job, dept)
    local serverId = source
    
    if job ~= "LEO" and job ~= "FIRE" then
        print("[ImperialDuty] Player " .. GetPlayerName(serverId) .. " attempted to go on duty with invalid job type: " .. tostring(job))
        return
    end
    
    local deptValid = false
    if Config.Departments[job] then
        for _, deptInfo in ipairs(Config.Departments[job]) do
            if deptInfo.code == dept then
                deptValid = true
                break
            end
        end
    end
    
    if not deptValid then
        print("[ImperialDuty] Player " .. GetPlayerName(serverId) .. " attempted to go on duty with invalid department: " .. tostring(dept))
        return
    end
    
    table.insert(OnDutyUnits, serverId)
    local jobName = "Unknown" 

    if job == "LEO" then
        table.insert(OnDutyLEOUnits, serverId)
        jobName = "Law Enforcement Officer"
    elseif job == "FIRE" then
        table.insert(OnDutyFireUnits, serverId)
        jobName = "Fire/Medical"
    end
    
    PlayerDepartments[serverId] = {
        job = job,
        dept = dept
    }

    TriggerClientEvent("Imperial:ShowBlip", -1, serverId, job, dept)

    if sendWebhook then
        local playerName = GetPlayerName(serverId)
        
        local deptName = dept
        for _, deptInfo in ipairs(Config.Departments[job]) do
            if deptInfo.code == dept then
                deptName = deptInfo.name
                break
            end
        end
        
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player went On-Duty",
                    ["description"] = "Player: "..playerName.."\nJob: "..jobName.."\nDepartment: "..deptName,
                    ["footer"] = {
                        ["text"] = "ImperialCAD - ImperialDuty | In-game"
                    }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP "..tostring(err).."^0")
                if text then print("^1[ImperialDuty] Response: "..text.."^0") end
            else
                print("^2[ImperialDuty] Webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end

    print("Added to OnDuty Units: "..GetPlayerName(serverId).." Job: "..job.." Department: "..dept)
end)

RegisterNetEvent("Imperial:RemoveUnitOnDuty")
AddEventHandler("Imperial:RemoveUnitOnDuty", function(job, dept)
    local serverId = source
    local jobName = "Unknown" 
    local deptName = dept or "Unknown"

    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end
    end

    if job == "LEO" then
        jobName = "Law Enforcement Officer"
        for i, unitId in ipairs(OnDutyLEOUnits) do
            if unitId == serverId then
                table.remove(OnDutyLEOUnits, i)
                break
            end
        end
    elseif job == "FIRE" then
        jobName = "Fire/Medical"
        for i, unitId in ipairs(OnDutyFireUnits) do
            if unitId == serverId then
                table.remove(OnDutyFireUnits, i)
                break
            end
        end
    end
    
    if job and dept and Config.Departments[job] then
        for _, deptInfo in ipairs(Config.Departments[job]) do
            if deptInfo.code == dept then
                deptName = deptInfo.name
                break
            end
        end
    end
    
    PlayerDepartments[serverId] = nil

    TriggerClientEvent("Imperial:RemoveBlip", -1, serverId)

    if sendWebhook then
        local playerName = GetPlayerName(serverId)
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player Went Off-Duty",
                    ["description"] = "Player: "..playerName.."\nJob: "..jobName.."\nDepartment: "..deptName,
                    ["footer"] = {
                        ["text"] = "ImperialCAD - ImperialDuty | In-game"
                    }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP "..tostring(err).."^0")
                if text then print("^1[ImperialDuty] Response: "..text.."^0") end
            else
                print("^2[ImperialDuty] Webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end

    print("Removed from OnDuty Units: " .. GetPlayerName(serverId))
end)

RegisterNetEvent("Imperial:RequestJobBlips")
AddEventHandler("Imperial:RequestJobBlips", function(job)
    local requestingPlayer = source
    local jobBlips = {}
    
    if job == "LEO" then
        for _, unitId in ipairs(OnDutyLEOUnits) do
            if PlayerDepartments[unitId] then
                table.insert(jobBlips, {
                    serverId = unitId, 
                    job = "LEO",
                    dept = PlayerDepartments[unitId].dept
                })
            end
        end
    elseif job == "FIRE" then
        for _, unitId in ipairs(OnDutyFireUnits) do
            if PlayerDepartments[unitId] then
                table.insert(jobBlips, {
                    serverId = unitId, 
                    job = "FIRE",
                    dept = PlayerDepartments[unitId].dept
                })
            end
        end
    end
    
    TriggerClientEvent("Imperial:ReceiveJobBlips", requestingPlayer, jobBlips)
end)

RegisterNetEvent("Imperial:UpdateBlip")
AddEventHandler("Imperial:UpdateBlip", function(coords, showBlip)
    local serverId = source

    local jobType = nil
    local dept = nil
    
    if PlayerDepartments[serverId] then
        jobType = PlayerDepartments[serverId].job
        dept = PlayerDepartments[serverId].dept
    else
        for _, unitId in ipairs(OnDutyLEOUnits) do
            if unitId == serverId then
                jobType = "LEO"
                break
            end
        end

        for _, unitId in ipairs(OnDutyFireUnits) do
            if unitId == serverId then
                jobType = "FIRE"
                break
            end
        end
    end

    if jobType then
        TriggerClientEvent("Imperial:SyncBlips", -1, serverId, coords, jobType, dept, showBlip)
    end
end)

RegisterNetEvent("playerDropped")
AddEventHandler("playerDropped", function(reason)
    local serverId = source
    local playerName = GetPlayerName(serverId)

    for i, unitId in ipairs(OnDutyUnits) do
        if unitId == serverId then
            table.remove(OnDutyUnits, i)
            break
        end
    end

    local jobName = "Unknown"
    local jobType = nil
    local deptName = "Unknown"
    
    if PlayerDepartments[serverId] then
        jobType = PlayerDepartments[serverId].job
        local dept = PlayerDepartments[serverId].dept
        
        if jobType and dept and Config.Departments[jobType] then
            for _, deptInfo in ipairs(Config.Departments[jobType]) do
                if deptInfo.code == dept then
                    deptName = deptInfo.name
                    break
                end
            end
        end
    end

    for i, unitId in ipairs(OnDutyLEOUnits) do
        if unitId == serverId then
            table.remove(OnDutyLEOUnits, i)
            jobName = "Law Enforcement Officer"
            jobType = "LEO"
            break
        end
    end

    for i, unitId in ipairs(OnDutyFireUnits) do
        if unitId == serverId then
            table.remove(OnDutyFireUnits, i)
            jobName = "Fire/Medical"
            jobType = "FIRE"
            break
        end
    end
    
    PlayerDepartments[serverId] = nil

    TriggerClientEvent("Imperial:RemoveBlip", -1, serverId)
    print("[ImperialDuty] Player " .. serverId .. " disconnected. Removed from duty: " .. jobName .. " - " .. deptName)

    if sendWebhook and jobType then
        local webhookData = {
            ["embeds"] = {
                {
                    ["color"] = 16711680,
                    ["title"] = "Player Disconnected While On-Duty",
                    ["description"] = "**Player:** " .. playerName .. "\n**Job:** " .. jobName .. "\n**Department:** " .. deptName .. "\n**Reason:** " ..(reason),
                    ["footer"] = { ["text"] = "ImperialCAD - ImperialDuty | In-game" }
                }
            }
        }

        PerformHttpRequest(webhookURL, function(err, text, headers)
            if err ~= 204 then
                print("^1[ImperialDuty] Error sending webhook: HTTP " .. tostring(err) .. "^0")
                if text then print("^1[ImperialDuty] Response: " .. text .. "^0") end
            else
                print("^2[ImperialDuty] Disconnection webhook sent successfully.^0")
            end
        end, 'POST', json.encode(webhookData), { ['Content-Type'] = 'application/json' })
    end
end)


function GetOnDutyUnits()
    return OnDutyUnits
end

function GetOnDutyLEOUnits()
    return OnDutyLEOUnits
end

function GetOnDutyFireUnits()
    return OnDutyFireUnits
end

function GetPlayerDepartment(serverId)
    return PlayerDepartments[serverId]
end

function PrintTable(tbl)
    for k, v in pairs(tbl) do
        print(k, v)
    end
end

exports('GetOnDutyUnits', GetOnDutyUnits)
exports('GetOnDutyLEOUnits', GetOnDutyLEOUnits)
exports('GetOnDutyFireUnits', GetOnDutyFireUnits)
exports('GetPlayerDepartment', GetPlayerDepartment)

