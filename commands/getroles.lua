command = {}

local utils = require("/app/utils.lua")

command.info = {
  Name = "Getroles",
  Alias = {},
  Cooldown = 5,
}

local codes = {
  ["no_group"] = "**Config Error:** There is no group setup.",
  ["not_verifed"] = "You're not verified with RoVer! Verify here: <https://verify.eryn.io>",
  ["verify_err"] = "There was a problem checking the verification registry. Try again.",
  ["api_down"] = "There was a problem with the Roblox API. Try again.",
}

command.execute = function(message,args,client)
  local config = require("/app/config.lua")
  local getRoles = utils.getRoles(message)
  if type(getRoles) == "table" then
    local added = getRoles.added
    local removed = getRoles.removed
    message:reply{embed = {
      title = "Roles Changed ["..#added + #removed.."]",
      fields = {
        {name = "Added ["..#added.."]", value = (#added >= 1 and table.concat(added,", ") or "None!"), inline = true},
        {name = "Removed ["..#removed.."]", value = (#removed >= 1 and table.concat(removed,", ") or "None!"), inline = true},
      },
      color = 3066993,
      footer = {icon_url = message.author:getAvatarURL(), text = "Responding to "..message.author.tag},
      timestamp = require("discordia").Date():toISO('T', 'Z'),
    }}
    return {success = "yes"}
  elseif getRoles == "no_changes" then
    return {success = true, msg = "All caught up! There's no roles to add or remove."}
  elseif codes[getRoles] == nil then
    return {success = false, msg = "Unknown error."}
  else
    return {success = false, msg = codes[getRoles]}
  end
end

return command