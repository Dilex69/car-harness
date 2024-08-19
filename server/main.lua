local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem('harness', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('seatbelt:client:useHarnessItemAdd', source)
end)

QBCore.Functions.CreateUseableItem('harness_remover', function(source, item)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('seatbelt:client:useHarnessItemRemove', source)
end)

function IsVehicleOwned(plate)
    local result = MySQL.scalar.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
    return result
end

RegisterNetEvent('qb-samllresources:server:hasHarness', function(plate)
    local src = source
    MySQL.Async.fetchScalar('SELECT hasharness FROM player_vehicles WHERE plate = ?', { plate },
    function(state)
        if state == 1 then
            TriggerClientEvent('seatbelt:client:toggleHarness', src)
        else
            TriggerClientEvent('seatbelt:client:Togglebelt', src)
        end
    end)
end)

RegisterNetEvent('seatbelt:server:AddHarnessToVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if IsVehicleOwned(plate) then
    MySQL.Async.fetchScalar('SELECT hasharness FROM player_vehicles WHERE plate = ?', { plate },
    function(state)
    if state == 1 then
    TriggerClientEvent('QBCore:Notify', src, 'Harness Already Attached', 'error')
    else
    TriggerClientEvent('seatbelt:client:StartAddHarnessMinigame', src, plate)
    end
    end)
    else
    TriggerClientEvent('QBCore:Notify', src, 'This vehicle isnot owned!', 'error')
    end
    end)
    
    RegisterNetEvent('seatbelt:server:AddHarnessToVehicleSuccess', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
    local hasharness = 1
    MySQL.Async.execute('UPDATE player_vehicles SET hasharness = ? WHERE plate = ?', {hasharness, plate},
    function(rowsChanged)
    if rowsChanged > 0 then
    if Player.Functions.RemoveItem('harness', 1, false) then
    TriggerClientEvent('seatbelt:client:AddedHarnessToVehicle', src)
    TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items['harness'], 'remove')
    TriggerClientEvent('QBCore:Notify', src, 'Harness successfully attached', 'success')
    else
    TriggerClientEvent('QBCore:Notify', src, 'Failed to remove harness from inventory', 'error')
    end
    else
    TriggerClientEvent('QBCore:Notify', src, 'Failed to update vehicle harness status', 'error')
    end
    end)
    else
    print("Error: Player not found for source " .. src)
    end
    end)

RegisterNetEvent('seatbelt:server:RemoveHarnessToVehicle', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if IsVehicleOwned(plate) then
        MySQL.Async.fetchScalar('SELECT hasharness FROM player_vehicles WHERE plate = ?', { plate },
        function(state)
            if state == 1 then
                TriggerClientEvent('seatbelt:client:RemovedHarnessToVehicle', src)
            else
                TriggerClientEvent('QBCore:Notify', src, 'Harness Not Found!', 'error')
            end
        end)
    else
        TriggerClientEvent('QBCore:Notify', src, 'this vehicle isnt owned!...', 'error')
    end
end)

RegisterNetEvent('seatbelt:server:RemovedHarnessToVehicleSuccess', function(plate)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local hasharness = 0 
    MySQL.Async.execute('UPDATE player_vehicles SET hasharness = ? WHERE plate = ?', {hasharness, plate})                
    Player.Functions.AddItem('harness', 1, false)
    TriggerClientEvent('qb-inventory:client:ItemBox', src,  QBCore.Shared.Items['harness'], 'add')
end)
