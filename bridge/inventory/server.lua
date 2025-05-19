local config = require 'shared.config'
function giveStarterItems(source)
    if GetResourceState('ox_inventory') ~= 'missing' then
        while not exports.ox_inventory:GetInventory(source) do
            Wait(100)
        end
        for i = 1, #config.starterItems do
            local item = config.starterItems[i]
            exports.ox_inventory:AddItem(source, item.name, item.amount)
        end
    elseif GetResourceState('qb-inventory') ~= 'missing' or GetResourceState('lj-inventory') ~= 'missing' or GetResourceState('ps-inventory') ~= 'missing' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for i = 1, #config.starterItems do
                local item = config.starterItems[i]
                Player.Functions.AddItem(item.name, item.amount)
            end
        end
    end
end