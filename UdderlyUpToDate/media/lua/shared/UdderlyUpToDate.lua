local getTimestamp = getTimestamp
local isServer = getCore():isDedicated()

UdderlyUpToDate = UdderlyUpToDate or {}

local chat do
	if isServer then
		chat = print
	else
		chat = function(msg)
			UdderlyUpToDate.message(msg, true)
		end
	end
end

function UdderlyUpToDate.message(msg, isAlert)
	local chatMsg =
	{
		getTextWithPrefix = function(self)
			return msg
		end,

		getText = function(self)
			return msg
		end,

		setText = function(self, newMsg)
			msg = newMsg
		end,

		isOverHeadSpeech = function() return not isAlert end,
		isServerAlert = function() return isAlert end,
		isShowAuthor = function() return false end,
		isServerAuthor = function() return true end,
		getAuthor = function() return false end,
		getRadioChannel = function() return -1 end
	}
	chatMsg.__index = chatMsg
	if not isAlert then
		msg = "[Server] "..msg
	end
	ISChat.addLineInChat(setmetatable({ msg = msg.."\t" }, chatMsg), 0)
end

function UdderlyUpToDate.minutes(secs)
	if secs < 60 then
		if secs == 1 then
			return secs .. " second"
		else
			return secs .. " seconds"
		end
	else
		if secs / 60 == 1 then
			return "1 minute"
		else
			return (string.gsub(string.gsub(string.format("%.2f", secs / 60), "(%.%d-)0*$", "%1"), "%.$", "")) .. " minutes"
		end
	end
end

local restartingAt
local nextChatPrint
local function countdown()
	local time = getTimestamp()
	local delta = restartingAt - time
	if not nextChatPrint or nextChatPrint - time <= 0 then
		nextChatPrint = time + math.min(delta / 2, 60 * 15)
		if not isServer then -- We only force quit here for players, not the server!
			if delta <= 10 then
				getCore():quit() -- Boot the player out so the saving can occur without data loss.
			elseif math.floor(delta / 60) <= 0 then
				chat("WARNING: Server is restarting to update workshop mods, you will be kicked soon!")
			else
				chat("WARNING: Server is restarting in " .. UdderlyUpToDate.minutes(delta) .. " to update workshop mods!")
			end
		elseif delta <= 10 then
			Events.OnTickEvenPaused.Remove(countdown)
			print("[UdderlyUpToDate] Kicking players.")
		end
	end
end

function UdderlyUpToDate.startRestartCountdown(__restartingAt)
	nextChatPrint = nil
	restartingAt = __restartingAt
	if restartingAt then
		Events.OnTickEvenPaused.Add(countdown)
	else
		Events.OnTickEvenPaused.Remove(countdown)
	end
end

if not isServer then
	Events.OnInitGlobalModData.Add(function()
		Events.OnReceiveGlobalModData.Add(function(key, modData)
			if key == "UdderlyUpToDate" then
				UdderlyUpToDate.startRestartCountdown(modData and modData.restartingAt or nil)
			end
		end)

		ModData.request("UdderlyUpToDate")
	end)
end
