---@diagnostic disable: 1030
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalizationService = game:GetService("LocalizationService")

local LocalPlayer = Players.LocalPlayer

local SHA1 = require(script:WaitForChild("sha1"))
local Knit = require(ReplicatedStorage.Packages.Knit)
local FingerprintController = Knit.CreateController({
	Name = "FingerprintController",
	Client = {},
})

local function round(x, y)
	return math.round(x / y) * y
end

local function GetDaylightSaving()
	local currentDate = os.date("*t") :: any
	return currentDate.isdst
end

local function GetGeoIPLocation()
	local result, code = pcall(LocalizationService.GetCountryRegionForPlayerAsync, LocalizationService, LocalPlayer)
	if result then
		return code
	end
	return "Unknown"
end

function ToBase64(data)
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
	return (
		(data:gsub(".", function(x)
			local r, b = "", x:byte()
			for i = 8, 1, -1 do
				r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
			end
			return r
		end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
			if #x < 6 then
				return ""
			end
			local c = 0
			for i = 1, 6 do
				c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
			end
			return b:sub(c + 1, c + 1)
		end) .. ({ "", "==", "=" })[#data % 3 + 1]
	)
end

local Fingerprint = SHA1.sha1(HttpService:JSONEncode({
	-- Any number of data points can be added here
	time = {
		-- CPU start is the main data point used
		cpuStart = round(tick() - os.clock(), 5),
		timezone = ToBase64(os.date("%Z")),
		isDST = GetDaylightSaving(),
		geoLocation = GetGeoIPLocation(),
	},
	device = {
		accelerometerEnabled = UserInputService.AccelerometerEnabled,
		touchEnabled = UserInputService.TouchEnabled,
	},
}))

function FingerprintController:KnitStart()
	local AuthService = Knit.GetService("AuthService")
	AuthService:SetFingerprint(Fingerprint)
end

return FingerprintController
