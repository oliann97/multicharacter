local config = require 'shared.config'
local PREFIX = "char"

if GetResourceState('es_extended') == 'missing' then return end

local function checkAndAddNationalityColumn()
    local columnExists = MySQL.scalar.await("SHOW COLUMNS FROM users LIKE 'nationality'")
    if not columnExists then
        MySQL.update.await("ALTER TABLE users ADD COLUMN nationality VARCHAR(50) DEFAULT 'Unknown'")
    end
end

CreateThread(function()
    Wait(1000)
    checkAndAddNationalityColumn()
end)

local function fetchAllPlayerEntities(source)
  local chars = {}
  local licenses = {
      GetPlayerIdentifierByType(source, 'license'),
      GetPlayerIdentifierByType(source, 'license2')
  }

  local result = {}

  for _, license in ipairs(licenses) do
      if license then
          local pureLicense = string.match(license, "license:(.+)") or license
          local queryResult = MySQL.query.await('SELECT * FROM users WHERE identifier LIKE ?', {'char%:'..pureLicense})
          for i = 1, #queryResult do
              table.insert(result, queryResult[i])
          end
      end
  end

  for i = 1, #result do
      local firstname = result[i].firstname or ""
      local lastname = result[i].lastname or ""
      local job = ""
      local grade = ""

      chars[i] = {
          identifier = result[i].identifier,
          name = firstname .. ' ' .. lastname,
          cid = 0,
          metadata = {}
      }

      local cidMatch = string.match(result[i].identifier, "char(%d+):")
      if cidMatch then
          chars[i].cid = tonumber(cidMatch)
      end
      local jobs = tostring(result[i].job)
      local job_grades = tostring(result[i].job_grade)
      if ESX.Jobs[jobs] and ESX.Jobs[jobs].grades and ESX.Jobs[jobs].grades[job_grades] then
          grade = ESX.Jobs[jobs].grades[job_grades].label or ""
          job = ESX.Jobs[jobs].label or ""
      end

      chars[i].metadata = {
          { key = "job", value = job .. ' (' .. grade .. ')' },
          { key = "nationality", value = result[i].nationality or "Unknown" },
          { key = "bank", value = json.decode(result[i].accounts).bank or 0 },
          { key = "cash", value = json.decode(result[i].accounts).money or 0 },
          { key = "birthdate", value = result[i].dateofbirth or "Unknown" },
          { key = "gender", value = result[i].sex == 'm' and '男' or '女' },
      }
  end

  return chars
end

local function getAllowedAmountOfCharacters(license2, license)
    return config.playersNumberOfCharacters[license2] or license and config.playersNumberOfCharacters[license] or config.defaultNumberOfCharacters
end

lib.callback.register('server:getCharacters', function(source)
  local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
  local chars = fetchAllPlayerEntities(source)
  local allowedAmount = getAllowedAmountOfCharacters(license2, license)
  
  local sortedChars = {}
  
  for i = 1, allowedAmount do
    sortedChars[i] = nil
  end

  for i = 1, #chars do
    local char = chars[i]
    sortedChars[i] = char
  end

  return sortedChars, allowedAmount
end)

lib.callback.register('server:loadCharacter', function(source, identifier, cid)
  local identifierSource = ESX.GetIdentifier(source)
  ESX.Players[ESX.GetIdentifier(source)] = true
  TriggerEvent("esx:onPlayerJoined", source, ("%s%s"):format(PREFIX, cid))
  SetPlayerRoutingBucket(source, 0)
end)

lib.callback.register('server:createCharacter', function(source, data)
 local newData = {
    firstname = data.firstname,
    lastname = data.lastname,
    nationality = data.nationality,
    dateofbirth = data.birthdate,
    sex = data.gender == 'Male' and 'm' or 'f',
    height = 175,
  }
  TriggerEvent("esx:onPlayerJoined", source, ("%s%s"):format(PREFIX, data.cid), newData)
  giveStarterItems(source)
  SetPlayerRoutingBucket(source, 0)
  return data
end)

lib.callback.register('server:setCharBucket', function(source)
  SetPlayerRoutingBucket(source, source)
  assert(GetPlayerRoutingBucket(source) == source, '多角色桶未设置。')
end)

RegisterNetEvent('server:deleteCharacter', function(identifier)
  local src = source
  MySQL.update('DELETE FROM `users` WHERE `identifier` = ?', { identifier }, function(affectedRows)
    if affectedRows then
        TriggerClientEvent('esx:showNotification', src, 'Successfully deleted your character', "success")
        return true
    end
end)
end)

RegisterCommand("relog", function(source, _, _)
  TriggerEvent("esx:playerLogout", source)
end, true)