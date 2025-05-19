local config = require 'shared.config'
defaultSpawn = require 'shared.config'.defaultSpawn

local previewCam = nil
local randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]

local function setupPreviewCam()
    DoScreenFadeIn(1000)
    SetTimecycleModifier('hud_def_blur')
    SetTimecycleModifierStrength(1.0)
    FreezeEntityPosition(cache.ped, false)
    previewCam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', randomLocation.camCoords.x, randomLocation.camCoords.y, randomLocation.camCoords.z, -6.0, 0.0, randomLocation.camCoords.w, 40.0, false, 0)
    SetCamActive(previewCam, true)
    SetCamUseShallowDofMode(previewCam, true)
    SetCamNearDof(previewCam, 0.4)
    SetCamFarDof(previewCam, 1.8)
    SetCamDofStrength(previewCam, 0.7)
    RenderScriptCams(true, false, 1, true, true)
    CreateThread(function()
        while DoesCamExist(previewCam) do
            SetUseHiDof()
            Wait(0)
        end
    end)
end

function destroyPreviewCam()
    if not previewCam then return end

    SetTimecycleModifier('default')
    SetCamActive(previewCam, false)
    DestroyCam(previewCam, true)
    RenderScriptCams(false, false, 1, true, true)
    FreezeEntityPosition(cache.ped, false)
end

local function capString(str)
  return str:gsub("(%w)([%w']*)", function(first, rest)
    return first:upper() .. rest:lower()
  end)
end

local function createCharacter(cid, character)
  DoScreenFadeOut(150)
  local newData = lib.callback.await('server:createCharacter', false, {
    firstname = capString(character.firstName),
    lastname = capString(character.lastName),
    nationality = capString(character.nationality),
    gender = character.gender == 'Male' and 0 or 1,
    birthdate = character.birthdate,
    cid = cid
  })

  if not newData then
    lib.notify({
      title = '错误',
      description = '创建角色失败，请重试',
      type = 'error'
    })
    DoScreenFadeIn(150)
    chooseCharacter()
    return false
  end

  spawnDefault()
  destroyPreviewCam()
  return true
end

function chooseCharacter()
    randomLocation = config.characters.locations[math.random(1, #config.characters.locations)]
    SetFollowPedCamViewMode(2)

    DoScreenFadeOut(500)

    while not IsScreenFadedOut() and cache.ped ~= PlayerPedId()  do
        Wait(0)
    end

	FreezeEntityPosition(cache.ped, true)
	Wait(1000)
    SetEntityCoords(cache.ped, randomLocation.pedCoords.x, randomLocation.pedCoords.y, randomLocation.pedCoords.z, false, false, false, false)
    SetEntityHeading(cache.ped, randomLocation.pedCoords.w)
	lib.callback.await('server:setCharBucket')
	Wait(1500)
	ShutdownLoadingScreen()
	ShutdownLoadingScreenNui()
	setupPreviewCam()
	local characters, amount = lib.callback.await('server:getCharacters')
	SetNuiFocus(true, true)
	SendNUIMessage({
		action = 'showMultiChar',
		data = {
			characters = characters,
            allowedCharacters = amount,
            showDeleteButton = config.DeleteCharacter
		}
	})

	SetTimecycleModifier('default')
end

RegisterNuiCallback('selectCharacter', function(data, cb)
  previewPed(data.identifier)
  cb(1)
end)

RegisterNuiCallback('playCharacter', function(data, cb)
  SetNuiFocus(false, false)
  DoScreenFadeOut(10)
  lib.callback.await('server:loadCharacter', false, data.identifier, data.cid)
  destroyPreviewCam()
  spawnLastLocation()
  cb(1)
end)

RegisterNuiCallback('deleteCharacter', function(data, cb)
  SetNuiFocus(false, false)
  TriggerServerEvent('server:deleteCharacter', data.identifier)
  destroyPreviewCam()
  chooseCharacter()
  cb(1)
end)

RegisterNuiCallback('createCharacter', function(data, cb)
  SetNuiFocus(false, false)
  local success = createCharacter(data.cid, data.character)
  if success then return end
  cb(success)
end)

CreateThread(function()
  while true do
    Wait(0)
    if NetworkIsSessionStarted() then
      Wait(250)
      DisplayRadar(false)
      chooseCharacter()
      break
    end
  end
end)
