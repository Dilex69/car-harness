local QBCore = exports['qb-core']:GetCoreObject()
local seatbeltOn = false
local harnessOn = false
local harnessHp = 20
local handbrake = 0
local sleep = 0
local newvehicleBodyHealth = 0
local currentvehicleBodyHealth = 0
local frameBodyChange = 0
local lastFrameVehiclespeed = 0
local lastFrameVehiclespeed2 = 0
local thisFrameVehicleSpeed = 0
local tick = 0
local damagedone = false
local modifierDensity = true
local lastVehicle = nil
local veloc

-- Functions

local function EjectFromVehicle()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped,false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    Wait(1)
    SetPedToRagdoll(ped, 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(ped, veloc.x*4,veloc.y*4,veloc.z*4)
    local ejectspeed = math.ceil(GetEntitySpeed(ped) * 8)
    if IsPedWearingHelmet(ped) and IsThisModelABicycle(GetEntityModel(veh)) then
        local damageAmount = GetEntityHealth(ped) - 1
        if damageAmount > ejectspeed then
            damageAmount = ejectspeed
        end
        SetEntityHealth(ped, GetEntityHealth(ped) - damageAmount)
        return
    end
    SetEntityHealth(ped, (GetEntityHealth(ped) - ejectspeed))
end

RegisterNetEvent('seatbelt:client:Togglebelt', function()
    ToggleSeatbelt()
end)
function ToggleSeatbelt()
    seatbeltOn = not seatbeltOn
    TriggerEvent("seatbelt:client:ToggleSeatbelt")
    TriggerServerEvent("InteractSound_SV:PlayOnSource", seatbeltOn and "carbuckle" or "carunbuckle", 0.25)
end

local function ToggleHarness()
    ToggleSeatbelt()
    harnessOn = not harnessOn
    if not harnessOn then return end
end

local function ResetHandBrake()
    if handbrake <= 0 then return end
    handbrake -= 1
end

function HasHarness()
    return harnessOn
end

exports("HasHarness", HasHarness)

-- Main Thread

CreateThread(function()
    while true do
        sleep = 1000
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            sleep = 0
            if seatbeltOn or harnessOn then
                DisableControlAction(0, 75, true)
                DisableControlAction(27, 75, true)
            end
        else
            seatbeltOn = false
            harnessOn = false
        end
        Wait(sleep)
    end
end)

-- Ejection Logic

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()
        local currentVehicle = GetVehiclePedIsIn(playerPed, false)
        if currentVehicle and currentVehicle ~= false and currentVehicle ~= 0 then
            SetPedHelmet(playerPed, false)
            lastVehicle = GetVehiclePedIsIn(playerPed, false)
            if GetVehicleEngineHealth(currentVehicle) < 0.0 then
                SetVehicleEngineHealth(currentVehicle, 0.0)
            end
            if (GetVehicleHandbrake(currentVehicle) or (GetVehicleSteeringAngle(currentVehicle)) > 25.0 or (GetVehicleSteeringAngle(currentVehicle)) < -25.0) then
                if handbrake == 0 then
                    handbrake = 100
                    ResetHandBrake()
                else
                    handbrake = 100
                end
            end

            thisFrameVehicleSpeed = GetEntitySpeed(currentVehicle) * 3.6
            currentvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
            if currentvehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
                frameBodyChange = 0
            end
            if frameBodyChange ~= 0 then
                if lastFrameVehiclespeed > 110 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * 0.75) and not damagedone then
                    if frameBodyChange > 18.0 then
                        if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if math.random(math.ceil(lastFrameVehiclespeed)) > 60 then
                                if not harnessOn then
                                    EjectFromVehicle()
                                end
                            end
                        elseif (seatbeltOn or harnessOn) and not IsThisModelABike(currentVehicle) then
                            if lastFrameVehiclespeed > 150 then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 150 then
                                    if not harnessOn then
                                        EjectFromVehicle()
                                    end
                                end
                            end
                        end
                    else
                        if not seatbeltOn and not IsThisModelABike(currentVehicle) then
                            if math.random(math.ceil(lastFrameVehiclespeed)) > 60 then
                                if not harnessOn then
                                    EjectFromVehicle()
                                end
                            end
                        elseif (seatbeltOn or harnessOn) and not IsThisModelABike(currentVehicle) then
                            if lastFrameVehiclespeed > 120 then
                                if math.random(math.ceil(lastFrameVehiclespeed)) > 200 then
                                    if not harnessOn then
                                        EjectFromVehicle()
                                    end
                                end
                            end
                        end
                    end
                    damagedone = true
                    SetVehicleEngineOn(currentVehicle, false, true, true)
                end
                if currentvehicleBodyHealth < 350.0 and not damagedone then
                    damagedone = true
                    SetVehicleEngineOn(currentVehicle, false, true, true)
                    Wait(1000)
                end
            end
            if lastFrameVehiclespeed < 100 then
                Wait(100)
                tick = 0
            end
            frameBodyChange = newvehicleBodyHealth - currentvehicleBodyHealth
            if tick > 0 then
                tick -= 1
                if tick == 1 then
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
            else
                if damagedone then
                    damagedone = false
                    frameBodyChange = 0
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
                lastFrameVehiclespeed2 = GetEntitySpeed(currentVehicle) * 3.6
                if lastFrameVehiclespeed2 > lastFrameVehiclespeed then
                    lastFrameVehiclespeed = GetEntitySpeed(currentVehicle) * 3.6
                end
                if lastFrameVehiclespeed2 < lastFrameVehiclespeed then
                    tick = 25
                end

            end
            if tick < 0 then
                tick = 0
            end
            newvehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
            if not modifierDensity then
                modifierDensity = true
            end
            veloc = GetEntityVelocity(currentVehicle)
        else
            if lastVehicle then
                SetPedHelmet(playerPed, true)
                Wait(200)
                newvehicleBodyHealth = GetVehicleBodyHealth(lastVehicle)
                if not damagedone and newvehicleBodyHealth < currentvehicleBodyHealth then
                    damagedone = true
                    SetVehicleEngineOn(lastVehicle, false, true, true)
                    Wait(1000)
                end
                lastVehicle = nil
            end
            lastFrameVehiclespeed2 = 0
            lastFrameVehiclespeed = 0
            newvehicleBodyHealth = 0
            currentvehicleBodyHealth = 0
            frameBodyChange = 0
            Wait(2000)
        end
    end
end)

if not Config then
    Config = {}
    Config.AllowedJobs = nil -- Work With All Jobs
    if not Config.AllowedJobs then
        print("^3INFO: Config.AllowedJobs not set. Allowing all jobs to use this functionality.^7")
    end
end

-- Add this function at the top of your file
local function isJobAllowed(jobName)
    -- If Config.AllowedJobs is nil or an empty table, allow all jobs
    if not Config.AllowedJobs or #Config.AllowedJobs == 0 then
        return true
    end
    
    -- Otherwise, check if the job is in the allowed list
    for _, allowedJob in ipairs(Config.AllowedJobs) do
        if jobName == allowedJob then
            return true
        end
    end
    return false
end

RegisterNetEvent('seatbelt:client:useHarnessItemAdd', function()
    local Player = QBCore.Functions.GetPlayerData()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify("You must be in a vehicle to add a harness.", "error")
        return
    end

    if isJobAllowed(Player.job.name) then
        local plate = QBCore.Functions.GetPlate(vehicle)
        TriggerServerEvent('seatbelt:server:AddHarnessToVehicle', plate)
    else
        QBCore.Functions.Notify("You are not authorized to add a harness.", "error")
    end
end)

RegisterNetEvent('seatbelt:client:useHarnessItemRemove', function()
    local Player = QBCore.Functions.GetPlayerData()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    
    if vehicle == 0 then
        QBCore.Functions.Notify("You must be in a vehicle to remove a harness.", "error")
        return
    end

    if isJobAllowed(Player.job.name) then
        local plate = QBCore.Functions.GetPlate(vehicle)
        TriggerServerEvent('seatbelt:server:RemoveHarnessToVehicle', plate)
    else
        QBCore.Functions.Notify("You are not authorized to remove a harness.", "error")
    end
end)


local function PerformMinigame(actionType)
    if Config.MinigameType == 'qb-skillbar' then
        local Skillbar = exports['qb-skillbar']:GetSkillbarObject()
        Skillbar.Start({
            duration = Config.BreakOutCuffing.duration, -- how long the skillbar runs for
            pos = Config.BreakOutCuffing.pos, -- how far to the right the static box is
            width = Config.BreakOutCuffing.width, -- how wide the static box is
        }, function()
            success = true
            local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId()))
            TriggerServerEvent('seatbelt:server:' .. actionType .. 'HarnessToVehicleSuccess', plate)
            return true
        end)
    elseif Config.MinigameType == 'qb-minigames' then
        local finished = exports['qb-minigames']:Skillbar(Config.SkillbarConfig.difficulty, Config.SkillbarConfig.keys)
        if finished then
            success = true
            local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId()))
            TriggerServerEvent('seatbelt:server:' .. actionType .. 'HarnessToVehicleSuccess', plate)
            return true
        end
    elseif Config.MinigameType == 'ps' then
        exports['ps-ui']:Circle(function(done)
            if done then
                success = true
             local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId()))
             TriggerServerEvent('seatbelt:server:' .. actionType .. 'HarnessToVehicleSuccess', plate)
             return true
            end
        end, Config.PSUIConfig.numcircle, Config.PSUIConfig.ms) -- NumberOfCircles, MS
elseif Config.MinigameType == 'ox' then
    local success = lib.skillCheck(Config.OXLibConfig.difficulty, Config.OXLibConfig.inputs)
    if success then
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if vehicle ~= 0 then
            local plate = QBCore.Functions.GetPlate(vehicle)
            TriggerServerEvent('seatbelt:server:' .. actionType .. 'HarnessToVehicleSuccess', plate)
            return true
        else
            QBCore.Functions.Notify("You must be in a vehicle to " .. string.lower(actionType) .. " a harness", "error")
        end
    else
        QBCore.Functions.Notify("Failed to " .. string.lower(actionType) .. " harness", "error")
    end
    return false
end
    while success == nil do Wait(10) end
    while success == nil do Wait(10) end

if success then
if actionType == 'Added' then
TriggerServerEvent('seatbelt:server:ConfirmHarnessAddition', plate)
else
TriggerServerEvent('seatbelt:server:' .. actionType .. 'HarnessToVehicleSuccess', plate)
end
TriggerEvent('seatbelt:client:toggleHarness')
return true
else
QBCore.Functions.Notify("Failed to " .. string.lower(actionType) .. " harness", "error")
return false
end
end

RegisterNetEvent('seatbelt:client:StartAddHarnessMinigame', function(plate)
    LocalPlayer.state:set("inv_busy", true, true)
    QBCore.Functions.Progressbar("harness_equip", "Attaching Harness To Vehicle", Config.ProgressBarDuration.Add, false, true, {
    disableMovement = false,
    disableCarMovement = false,
    disableMouse = false,
    disableCombat = true,
    }, {}, {}, {}, function()
    if PerformMinigame('Added') then
    TriggerServerEvent('seatbelt:server:AddHarnessToVehicleSuccess', plate)
    else
    TriggerEvent('QBCore:Notify', 'Failed to attach harness', 'error')
    end
    LocalPlayer.state:set("inv_busy", false, true)
    end)
    end)
    
    RegisterNetEvent('seatbelt:client:AddedHarnessToVehicle', function()
    TriggerEvent('seatbelt:client:toggleHarness')
    end)

    RegisterNetEvent('seatbelt:client:RemovedHarnessToVehicle', function()
        LocalPlayer.state:set("inv_busy", true, true)
        QBCore.Functions.Progressbar("harness_equip", "Removing Harness From Vehicle", Config.ProgressBarDuration.Remove, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
        }, {}, {}, {}, function()
        PerformMinigame('Removed')
        LocalPlayer.state:set("inv_busy", false, true)
        end)
        end)

RegisterNetEvent('seatbelt:client:toggleHarness', function() -- On Item Use (registered server side)
    local ped = PlayerPedId()
    local inveh = IsPedInAnyVehicle(ped, false)
    local class = GetVehicleClass(GetVehiclePedIsUsing(ped))
    if inveh and class ~= 8 and class ~= 13 and class ~= 14 then
        if not harnessOn then
            LocalPlayer.state:set("inv_busy", true, true)
            QBCore.Functions.Progressbar("harness_equip", "Putting On Harness", 1000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                LocalPlayer.state:set("inv_busy", false, true)
                ToggleHarness()
                TriggerEvent('hud:client:UpdateHarness', harnessHp)
            end)
        else
            LocalPlayer.state:set("inv_busy", true, true)
            QBCore.Functions.Progressbar("harness_equip", "Taking Off Harness", 1000, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
                LocalPlayer.state:set("inv_busy", false, true)
                ToggleHarness()
            end)
        end
    else
        QBCore.Functions.Notify('You\'re not in a car.', 'error')
    end
end)

-- Register Key

RegisterCommand('+toggleseatbelt', function()
    if not IsPedInAnyVehicle(PlayerPedId(), false) or IsPauseMenuActive() then return end
    local class = GetVehicleClass(GetVehiclePedIsUsing(PlayerPedId()))
    if class == 8 or class == 13 or class == 14 then return end
    local plate = QBCore.Functions.GetPlate(GetVehiclePedIsIn(PlayerPedId()))
    TriggerServerEvent('qb-samllresources:server:hasHarness', plate)
end)

RegisterKeyMapping('+toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'b')