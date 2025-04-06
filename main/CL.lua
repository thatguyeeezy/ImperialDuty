local onduty = false
local ondutyjob = nil
local ondutydept = nil

local leoweapons = Config.LEOWeapons
local fireweapons = Config.FIREWeapons

local serverId = PlayerId()

local weapons = {}
local blipsEnabled = true -- Track if player has blips enabled

local blips = {}
local blipVisibility = {}

function GetDepartmentInfo(jobType, deptCode)
    if not Config.Departments[jobType] then return nil end
    
    for _, dept in ipairs(Config.Departments[jobType]) do
        if dept.code == deptCode then
            return dept
        end
    end
    
    return nil
end

function GetDepartmentColor(jobType, deptCode)
    local dept = GetDepartmentInfo(jobType, deptCode)
    if dept then
        return dept.color
    end
    return Config.DefaultBlipColors[jobType] or 0
end

function ListAvailableDepartments(jobType)
    if not Config.Departments[jobType] then 
        return "No departments configured for " .. jobType
    end
    
    local deptList = "Available " .. jobType .. " departments:\n"
    for _, dept in ipairs(Config.Departments[jobType]) do
        deptList = deptList .. "  " .. dept.code .. " - " .. dept.name .. "\n"
    end
    
    return deptList
end

TriggerEvent('chat:addSuggestion', '/duty', 'Toggle your duty status for direct notifications', {
    { name="JOB", help="Specify the job type (LEO or FIRE)" },
    { name="DEPT", help="Specify the department code (BSO, FHP, BCFR, etc.)" }
})

if Config.AllowBlipsToggle then
    TriggerEvent('chat:addSuggestion', '/blips', 'Toggle visibility of duty blips on your map', {})
end

TriggerEvent('chat:addSuggestion', '/depts', 'List available departments', {
    { name="JOB", help="Specify the job type (LEO or FIRE)" }
})

RegisterCommand("depts", function(source, args)
    local jobType = args[1] and string.upper(args[1]) or nil
    
    if not jobType then
        local message = "Available departments:\n\n"
        message = message .. "LEO Departments:\n"
        for _, dept in ipairs(Config.Departments.LEO) do
            message = message .. "  " .. dept.code .. " - " .. dept.name .. "\n"
        end
        
        message = message .. "\nFIRE Departments:\n"
        for _, dept in ipairs(Config.Departments.FIRE) do
            message = message .. "  " .. dept.code .. " - " .. dept.name .. "\n"
        end
        
        TriggerEvent('chat:addMessage', {
            color = {255, 255, 255},
            multiline = true,
            args = {"Imperial Duty", message}
        })
        return
    end
    
    if jobType ~= "LEO" and jobType ~= "FIRE" then
        ShowNotification("Invalid job type. Please use either ~b~LEO~w~ or ~r~FIRE~w~.", "Imperial Duty")
        return
    end
    
    local deptList = ListAvailableDepartments(jobType)
    TriggerEvent('chat:addMessage', {
        color = {255, 255, 255},
        multiline = true,
        args = {"Imperial Duty", deptList}
    })
end, false)

function ClearAllBlips()
    for serverId, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    blipVisibility = {}
end

RegisterCommand("duty", function(source, args)
    local receivedJob = args[1] or nil
    local receivedDept = args[2] or nil
    
    local job = receivedJob and string.upper(receivedJob) or nil
    local dept = receivedDept and string.upper(receivedDept) or nil
    
    local previousJob = ondutyjob
    local previousDept = ondutydept
    
    if onduty then
        onduty = false
        TriggerServerEvent("Imperial:RemoveUnitOnDuty", ondutyjob, ondutydept)
        ShowNotification("You are now ~r~off-duty~w~.", ondutyjob)
        
        for _, weapon in ipairs(weapons) do
            RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
            weapons = {} or nil
        end
        
        ClearAllBlips()
        ondutyjob = nil
        ondutydept = nil
    else
        if job == nil then
            ShowNotification("You need to specify a job type.", "Imperial Duty")
            return
        end
        
        if job ~= "LEO" and job ~= "FIRE" then
            ShowNotification("Invalid job type. Please use either ~b~LEO~w~ or ~r~FIRE~w~.", "Imperial Duty")
            return
        end
        
        if dept == nil then
            local deptList = ListAvailableDepartments(job)
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 255},
                multiline = true,
                args = {"Imperial Duty", "Please specify a department code.\n" .. deptList}
            })
            return
        end
        
        local deptInfo = GetDepartmentInfo(job, dept)
        if not deptInfo then
            ShowNotification("Invalid department code. Use /depts " .. job .. " to see available departments.", "Imperial Duty")
            return
        end   

        if previousJob ~= job or previousDept ~= dept then
            ClearAllBlips()
        end

        onduty = true
        ondutyjob = job
        ondutydept = dept
        TriggerServerEvent("Imperial:AddUnitOnDuty", job, dept)
        ShowNotification("You are now ~g~on-duty~w~ as " .. deptInfo.name .. ".", job)
        SetPedArmour(PlayerPedId(), 100)

        if job == "LEO" and Config.GiveLEOWeapons then
            weapons = leoweapons
        elseif job == "FIRE" and Config.GiveFIREWeapons then
            weapons = fireweapons
        else
            weapons = {}
        end

        for _, weapon in ipairs(weapons) do
            GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), 250, false, true)
            SetPedAmmo(PlayerPedId(), GetHashKey(weapon), 250)
        end
        
        TriggerServerEvent("Imperial:RequestJobBlips", job)
    end
end, false)

if Config.AllowBlipsToggle then
    RegisterCommand("blips", function(source, args)
        blipsEnabled = not blipsEnabled
        
        for serverId, blip in pairs(blips) do
            if blipsEnabled then
                if blipVisibility[serverId] then
                    SetBlipAlpha(blip, 255)
                end
            else
                SetBlipAlpha(blip, 0)
            end
        end
        
        if blipsEnabled then
            ShowNotification("Duty blips are now ~g~visible~w~.", "Imperial Duty")
        else
            ShowNotification("Duty blips are now ~r~hidden~w~.", "Imperial Duty")
        end
    end, false)
end

RegisterNetEvent("Imperial:ShowBlip")
AddEventHandler("Imperial:ShowBlip", function(serverId, job, dept)
    if not NetworkIsPlayerActive(GetPlayerFromServerId(serverId)) then return end

    if not onduty or ondutyjob ~= job then
        return
    end

    if blips[serverId] then
        RemoveBlip(blips[serverId])
    end
    
    local ped = GetPlayerPed(GetPlayerFromServerId(serverId))
    local coords = GetEntityCoords(ped)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    
    -- https://docs.fivem.net/docs/game-references/blips/
    SetBlipSprite(blip, job == "LEO" and 225 or 227) -- LEO = Car Blip, Fire = Car Blip
    
    local blipColor = GetDepartmentColor(job, dept)
    SetBlipColour(blip, blipColor)
    
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    SetBlipCategory(blip, 7) -- Put in "Other Players" category to show as separate entries
    
    local playerName = GetPlayerName(GetPlayerFromServerId(serverId))
    local deptInfo = GetDepartmentInfo(job, dept)
    local deptName = dept
    if deptInfo then
        deptName = deptInfo.code
    end
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("[" .. deptName .. "] " .. playerName .. " (" .. serverId .. ")")
    EndTextCommandSetBlipName(blip)

    local shouldBeVisible = true
    
    -- Check if blips are disabled by user
    if not blipsEnabled then
        shouldBeVisible = false
    -- Otherwise check vehicle-only setting
    elseif Config.ShowBlipsOnlyInVehicles then
        shouldBeVisible = false -- Will be updated by SyncBlips
    end
    
    if shouldBeVisible then
        SetBlipAlpha(blip, 255)
        blipVisibility[serverId] = true
    else
        SetBlipAlpha(blip, 0)
        blipVisibility[serverId] = false
    end
    
    blips[serverId] = blip
end)

RegisterNetEvent("Imperial:RemoveBlip")
AddEventHandler("Imperial:RemoveBlip", function(serverId)
    if blips[serverId] then
        RemoveBlip(blips[serverId])
        blips[serverId] = nil
        blipVisibility[serverId] = nil
    end
end)

RegisterNetEvent("Imperial:ReceiveJobBlips")
AddEventHandler("Imperial:ReceiveJobBlips", function(jobBlips)
    for _, data in ipairs(jobBlips) do
        TriggerEvent("Imperial:ShowBlip", data.serverId, data.job, data.dept)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000) 
        if onduty then
            local coords = GetEntityCoords(PlayerPedId())
            local showBlip = true
            
            if Config.ShowBlipsOnlyInVehicles then
                local isInVehicle = IsPedInAnyVehicle(PlayerPedId(), false)
                local isInEmergencyVehicle = false
                
                if isInVehicle then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle and vehicle ~= 0 then
                        isInEmergencyVehicle = GetVehicleClass(vehicle) == 18 -- Emergency class only
                    end
                end
                
                showBlip = isInVehicle and (isInEmergencyVehicle or true)
            end
            
            TriggerServerEvent("Imperial:UpdateBlip", coords, showBlip)
        end
    end
end)

RegisterNetEvent("Imperial:SyncBlips")
AddEventHandler("Imperial:SyncBlips", function(serverId, coords, job, dept, showBlip)
    if not onduty or ondutyjob ~= job then
        return
    end
    
    if blips[serverId] then

        SetBlipCoords(blips[serverId], coords.x, coords.y, coords.z)
        
        local shouldBeVisible = false
        
        if blipsEnabled then
            if not Config.ShowBlipsOnlyInVehicles then
                shouldBeVisible = true
            else
                shouldBeVisible = showBlip
            end
        end
        
        if shouldBeVisible and not blipVisibility[serverId] then
            SetBlipAlpha(blips[serverId], 255)
            blipVisibility[serverId] = true
        elseif not shouldBeVisible and blipVisibility[serverId] then
            SetBlipAlpha(blips[serverId], 0)
            blipVisibility[serverId] = false
        end
    end
end)

function ShowNotification(message, job)  
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostMessagetext("CHAR_CHAT_CALL", "CHAR_CHAT_CALL", true, 1, "ImperialCAD", job)
end

