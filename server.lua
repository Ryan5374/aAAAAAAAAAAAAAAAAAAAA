local discordia = require('discordia')

local client = discordia.Client {
	logFile = 'mybot.log',
	cacheAllMembers = true,
	autoReconnect = true,
}

local Utopia = require('utopia')
local app = Utopia:new()

app:listen(8080)

local config = require("/app/config.lua") --// Get the config you predefined in config.lua (Read the README.md)
local startOS = os.time()

local http = require('coro-http')
client:on("ready", function()
  client:setGame(config.game)
  app:use(function (req, res)
    res:finish("Hi!")
  end)
  while true do
    if startOS - os.time() >= 39600 then os.exit() os.exit() os.exit() return end
    require("coro-http").request("GET","https://"..process.env.PROJECT_DOMAIN..".glitch.me/")
    require("timer").sleep(60000)
  end
end)

local function sepMsg(msg)
	local Args = {}
	local Command = msg
	for Match in Command:gmatch("[^%s]+") do
	table.insert(Args, Match)
	end;
	local Data = {
	["MessageData"] = Message;
	["Args"] = Args;
	}
	return Args
end

local cooldown = {}
--userid..guildid = {time = os.time(), strike = num}

client:on("messageCreate",function(message)
  if message.content == nil then return end --// The message recieved was an embed, there's no command here.
  if message.guild == nil then return end --// The message was sent via DM, no need to verify in DMs.
  if message.author.bot or message.guild.id == nil then return end --// The message was by a bot, we won't allow that.
  if string.sub(message.content,1,string.len(config.prefix)) == config.prefix then --// Message contains prefix.
    local args = sepMsg(string.sub(message.content,string.len(config.prefix)+1)) --// Remove the prefix, seperate the string
    local command
    for file, _type in require("fs").scandirSync("./commands") do
      if _type ~= "directory" then
        if string.lower(args[1]) == string.lower(require("/app/commands/"..file).info.Name) then
          command = require("/app/commands/"..file)
          break
        elseif #require("/app/commands/"..file).info.Alias >= 1 then
          for _,alias in pairs(require("/app/commands/"..file).info.Alias) do
            if alias ~= "" and string.lower(alias) == string.lower(args[1]) then
              command = require("/app/commands/"..file)
              break
            end
          end
        end
      end  
    end
    if command == nil then return end
    if cooldown[message.author.id..message.guild.id] ~= nil and cooldown[message.author.id..message.guild.id].time > os.time() then
      cooldown[message.author.id..message.guild.id].strike = cooldown[message.author.id..message.guild.id].strike + 1
      if cooldown[message.author.id..message.guild.id].strike >= 3 then
        print("[CMD COOLDOWN]: "..message.author.tag.." ("..message.author.id..") has been put on cooldown in "..message.guild.name.." ("..message.guild.id.."). [STRIKES: "..cooldown[message.author.id..message.guild.id].strike.."]")
        if cooldown[message.author.id..message.guild.id].strike == 3 then
          local reply = message:reply("⚠️ **Slow down!** Try running another command in "..cooldown[message.author.id..message.guild.id].time-os.time().." seconds.")
          require("timer").sleep(5000)
          reply:delete()
        end
        return
      end
    else
        cooldown[message.author.id..message.guild.id] = {time = 0, strike = 0}
    end
    local execute
    cooldown[message.author.id..message.guild.id].time = os.time() + (command.info.Cooldown == nil and 2 or command.info.Cooldown)
    local cmdSuccess, cmdMsg = pcall(function() execute = command.execute(message,args,client) end)
    if not (cmdSuccess) then
      message:reply(":rotating_light: **An error occured!**```lua\n"..cmdMsg.."\n```")
    elseif execute == nil or type(execute) ~= "table" then
      message:reply(":rotating_light: **An error occured.**```lua\nBROKEN COMMAND\n```")
    elseif execute.success == nil or execute.success == false then
      message:reply("❎  "..(execute.msg and execute.msg or "Command failed."))
    elseif execute.success == true then
      message:reply("✅  "..(execute.msg and execute.msg or "Command successful."))
    end
  end
end)

if (config) then
  if config.token ~= nil then
    if config.token == "" or config.token == "YOUR_TOKEN_HERE" then
      print("Bot failed to start: No token provided.")
    else
      client:run("Bot "..config.token)
    end
  else
    print("Bot failed to start: config.token is nil.")
  end
else
  print("Bot failed to start: Config table is nil.")
end