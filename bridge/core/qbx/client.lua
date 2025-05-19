if GetResourceState('qbx_core') == 'missing' then return end

function spawnLastLocation()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = QBX.PlayerData.position.x,
        y = QBX.PlayerData.position.y,
        z = QBX.PlayerData.position.z,
        heading = QBX.PlayerData.position.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
    DisplayRadar(true)
    while not IsScreenFadedIn() do
        Wait(0)
    end
end

function spawnDefault()
    DoScreenFadeOut(500)

    while not IsScreenFadedOut() do
        Wait(0)
    end

    destroyPreviewCam()

    pcall(function() exports.spawnmanager:spawnPlayer({
        x = defaultSpawn.x,
        y = defaultSpawn.y,
        z = defaultSpawn.z,
        heading = defaultSpawn.w
    }) end)

    TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
    TriggerEvent('QBCore:Client:OnPlayerLoaded')
    TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
    TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)

    while not IsScreenFadedIn() do
        Wait(0)
    end
    CreateFirstCharacter()
end

RegisterNetEvent('qbx_core:client:playerLoggedOut', function()
    if GetInvokingResource() then return end
    DisplayRadar(false)
    chooseCharacter()
end)