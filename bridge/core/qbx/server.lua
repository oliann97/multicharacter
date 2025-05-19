local config = require 'shared.config'

if GetResourceState('qbx_core') == 'missing' then return end
local function fetchAllPlayerEntities(license2, license)
  local chars = {}
  local result = MySQL.query.await('SELECT * FROM players WHERE license = ? OR license = ?', {license, license2})

  for i = 1, #result do
    local charinfo = json.decode(result[i].charinfo)
    chars[i] = {
      identifier = '',
      name = '',
      cid = 0,
      metadata = {}
    }
    chars[i].identifier = result[i].citizenid
    chars[i].name = charinfo.firstname .. ' ' .. charinfo.lastname
    chars[i].cid = i
    chars[i].metadata = {
      { key = "job", value = json.decode(result[i].job).label .. ' (' .. json.decode(result[i].job).grade.name .. ')' },
      { key = "nationality", value = charinfo.nationality },
      { key = "bank", value = lib.math.groupdigits(json.decode(result[i].money).bank) },
      { key = "cash", value = lib.math.groupdigits(json.decode(result[i].money).cash) },
      { key = "birthdate", value = charinfo.birthdate },
      { key = "gender", value = charinfo.gender == 0 and '男' or '女' },
    }
  end

  return chars
end



local function getAllowedAmountOfCharacters(license2, license)
    return config.playersNumberOfCharacters[license2] or license and config.playersNumberOfCharacters[license] or config.defaultNumberOfCharacters
end

lib.callback.register('server:getCharacters', function(source)
  local license2, license = GetPlayerIdentifierByType(source, 'license2'), GetPlayerIdentifierByType(source, 'license')
  local chars = fetchAllPlayerEntities(license2, license)
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

lib.callback.register('server:loadCharacter', function(source, identifier)
  local success = exports.qbx_core:Login(source, identifier)
  if not success then return end
  exports.qbx_core:SetPlayerBucket(source, 0)
end)

lib.callback.register('server:createCharacter', function(source, data)
  local newData = {}
  newData.charinfo = data

  local success = exports.qbx_core:Login(source, nil, newData)
  if not success then return end

  giveStarterItems(source)
  exports.qbx_core:SetPlayerBucket(source, 0)
  return newData
end)

lib.callback.register('server:setCharBucket', function(source)
  exports.qbx_core:SetPlayerBucket(source, source)
  assert(GetPlayerRoutingBucket(source) == source, 'Multicharacter bucket not set.')
end)

RegisterNetEvent('server:deleteCharacter', function(identifier)
  local src = source
  exports.qbx_core:DeleteCharacter(identifier)
end)
