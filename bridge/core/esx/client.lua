if GetResourceState('es_extended') == 'missing' then return end

AddEventHandler("esx:playerLoaded", function(xPlayer, isNew, skin)

    
    pcall(function() exports.spawnmanager:spawnPlayer({
        x = xPlayer.coords.x,
        y = xPlayer.coords.y,
        z = xPlayer.coords.z,
        heading = xPlayer.coords.heading
    }) end)
    TriggerServerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:restoreLoadout")
    DisplayRadar(true)
end)

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

    TriggerServerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:onPlayerSpawn")
    TriggerEvent("esx:restoreLoadout")

    while not IsScreenFadedIn() do
        Wait(0)
    end
    CreateFirstCharacter()
end

RegisterNetEvent('esx:onPlayerLogout', function()
    if GetInvokingResource() then return end
    DisplayRadar(false)
    chooseCharacter()
end)