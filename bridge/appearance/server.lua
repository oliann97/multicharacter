local function fetchPlayerSkin(identifier)
    if GetResourceState('illenium-appearance') ~= 'missing' 
    or GetResourceState('qb-clothing') ~= 'missing'
    or GetResourceState('fivem-appearance') ~= 'missing' then
        return MySQL.single.await('SELECT * FROM playerskins WHERE citizenid = ? AND active = 1', {identifier})
    elseif GetResourceState('skinchanger') ~= 'missing' then
        local skin = MySQL.single.await('SELECT skin FROM users WHERE identifier = ?', {identifier})
        local skinData = json.decode(skin.skin)
        local model = skinData.sex == 1 and "mp_f_freemode_01" or "mp_m_freemode_01"
        return skinData, model
    end
    return nil
end

lib.callback.register('server:getPreviewPedData', function(_, identifier)
    local ped, model = fetchPlayerSkin(identifier)
    if not ped then return end
    if GetResourceState('skinchanger') ~= 'missing' then
        return ped, model
    else
        return ped.skin, ped.model and joaat(ped.model)
    end
end)