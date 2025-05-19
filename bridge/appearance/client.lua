local config = require 'shared.config'

function previewPed(identifier)
    if not identifier then randomPed() return end
    if GetResourceState('illenium-appearance') ~= 'missing' then
        local clothing, model = lib.callback.await('server:getPreviewPedData', false, identifier)
        print(clothing,model)
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        pcall(function() exports['illenium-appearance']:setPedAppearance(PlayerPedId(), json.decode(clothing)) end)
        SetModelAsNoLongerNeeded(model)
    elseif GetResourceState('qb-clothing') ~= 'missing' then
        local clothing, model = lib.callback.await('server:getPreviewPedData', false, identifier)
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        pcall(function() TriggerEvent('qb-clothing:client:loadPlayerClothing', json.decode(clothing), PlayerPedId()) end)
        SetModelAsNoLongerNeeded(model)
    elseif GetResourceState('fivem-appearance') ~= 'missing' then
        local clothing, model = lib.callback.await('server:getPreviewPedData', false, identifier)
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        pcall(function() exports["fivem-appearance"]:setPedAppearance(PlayerPedId(), json.decode(clothing)) end)
        SetModelAsNoLongerNeeded(model)
    elseif GetResourceState('skinchanger') ~= 'missing' then
        local clothing, model = lib.callback.await('server:getPreviewPedData', false, identifier)
        print(clothing,model)
        lib.requestModel(model, config.loadingModelsTimeout)
        SetPlayerModel(cache.playerId, model)
        pcall(function() exports["skinchanger"]:LoadSkin(clothing) end)
        SetModelAsNoLongerNeeded(model)
    end    
end

function CreateFirstCharacter()
    if GetResourceState('qb-clothing') ~= 'missing' then
        TriggerEvent('qb-clothes:client:CreateFirstCharacter')
    elseif GetResourceState('fivem-appearance') ~= 'missing' then
        exports['fivem-appearance']:startPlayerCustomization()
    elseif GetResourceState('illenium-appearance') ~= 'missing' then
        exports['illenium-appearance']:startPlayerCustomization()
    elseif GetResourceState('skinchanger') ~= 'missing' then
        exports["skinchanger"]:LoadSkin({ sex = 0 })
        TriggerEvent("esx_skin:openSaveableMenu")
    end
end