local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local HTTP = require(script.http)

local SecretStore = DataStoreService:GetDataStore("SecretStore")
local JSONBinToken = SecretStore:GetAsync("JSONBinToken")

local VotingOptions = require(ReplicatedStorage.Shared.VotingOptions)
local EmptyVotedData = {}
local offLimitIds = { "aviawards_best_event" }

for categoryName, options in pairs(VotingOptions) do
	EmptyVotedData[categoryName] = {}
	for i, _ in ipairs(options) do
		EmptyVotedData[categoryName][i] = false
	end
end

local CSVTemplate = { "Timestamp", "SessionLoadCount", "PlayerName", "PlayerId" }
for categoryName, _ in pairs(VotingOptions) do
	table.insert(CSVTemplate, categoryName)
end
CSVTemplate = table.concat(CSVTemplate, ",")

local Knit = require(ReplicatedStorage.Packages.Knit)
local VotingService = Knit.CreateService({
	Name = "VotingService",
	Client = {
		CurrentVoted = Knit.CreateProperty(EmptyVotedData),
	},
	Profiles = {},
})

local ProfileService = require(ServerScriptService.Packages.ProfileService)
local ProfileStore = ProfileService.GetProfileStore("VotingDataProd", EmptyVotedData)

local PlayerNameCache = {}
local function GetPlayerUsername(playerId: number | string)
	if PlayerNameCache[playerId] then
		return PlayerNameCache[playerId]
	end
	local success, result = pcall(function()
		return Players:GetNameFromUserIdAsync(playerId)
	end)
	if success then
		PlayerNameCache[playerId] = result
		return result
	end
	warn("Failed to get player name for", playerId, result)
	return "Unknown"
end

function VotingService:_UploadToJSONBin(data: { [any]: any | any })
	-- import requests
	-- url = 'https://api.jsonbin.io/v3/b'
	-- headers = {
	-- 'Content-Type': 'application/json',
	-- 'X-Master-Key': '<YOUR_API_KEY>'
	-- }
	-- data = {"sample": "Hello World"}

	-- req = requests.post(url, json=data, headers=headers)
	-- print(req.text)
	local url = "https://api.jsonbin.io/v3/b"
	local headers = {
		["X-Master-Key"] = JSONBinToken,
		["X-Bin-Private"] = "false",
	}

	data = HttpService:JSONEncode(data)
	local response = HttpService:PostAsync(url, data, Enum.HttpContentType.ApplicationJson, false, headers)
	local responseJson = HttpService:JSONDecode(response)

	return responseJson.metadata
			and ("https://api.jsonbin.io/v3/b/%s/latest?meta=false"):format(responseJson.metadata.id)
		or responseJson.message
		or ""
end

function VotingService:_UploadToFileIO(data: { [any]: any | any }, encodeToJson: boolean, extension: string)
	encodeToJson = encodeToJson == nil and true or encodeToJson
	data =
		HTTP.File(("data.%s"):format(extension or ".txt"), if encodeToJson then HttpService:JSONEncode(data) else data)
	local form = HTTP.FormData()
	form:AddField("file", data)

	local r = HTTP.post("https://file.io/?expires=1d&title=data.txt", { data = form })
	return r:json().link or ""
end

function VotingService:PlayerAdded(player: Player)
	local profile = ProfileStore:LoadProfileAsync("Player_" .. player.UserId)
	if profile ~= nil then
		profile:AddUserId(player.UserId) -- GDPR compliance
		profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		profile:ListenToRelease(function()
			self.Profiles[player] = nil
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(Players) == true then
			self.Profiles[player] = profile
			self:UpdatePlayerVoted(player)
		else
			-- Player left before the profile loaded:
			profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick()
	end
end

function VotingService:UpdatePlayerVoted(player: Player)
	local profile = self.Profiles[player]
	if profile ~= nil then
		self.Client.CurrentVoted:SetFor(player, profile.Data)
	end
end

function VotingService.Client:Vote(player: Player, categoryName: string, optionId: string)
	task.wait(0.1)

	if table.find(offLimitIds, optionId) then
		return false, "Cannot register request. Please try a different candidate"
	end

	local profile = VotingService.Profiles[player]
	if profile ~= nil then
		for i, optionData in ipairs(VotingOptions[categoryName]) do
			profile.Data[categoryName][i] = optionData.id == optionId
		end
		VotingService:UpdatePlayerVoted(player)
		return true
	end

	return false, "Failed to get profile"
end

function VotingService.Client:ExportData(player: Player)
	local IsPlayerAdmin = player:GetRankInGroup(5287078) >= 252
	if not IsPlayerAdmin then
		return "PermissionInsufficient"
	end

	if self._ExportingData then
		return "AlreadyExporting"
	end
	self._ExportingData = true

	local datastore = ProfileStore._global_data_store

	local data = {}
	local allKeysPage = datastore:ListKeysAsync(nil, 100)
	while not allKeysPage.IsFinished do
		local currentPage = allKeysPage:GetCurrentPage()
		for _, key in ipairs(currentPage) do
			print("[VotingService] Exporting data for key: ", key.KeyName)
			local profile = ProfileStore:ViewProfileAsync(key.KeyName)
			if profile ~= nil then
				local playerCSV = {
					('"%s"'):format(profile.MetaData.ProfileCreateTime),
					('"%s"'):format(profile.MetaData.SessionLoadCount),
					GetPlayerUsername(profile.UserIds[1]),
					('"%s"'):format(profile.UserIds[1] or "N/A"),
				}
				local currentIndex = 4
				for categoryName, options in pairs(profile.Data) do
					currentIndex += 1
					playerCSV[currentIndex] = "N/A"
					for optionId, voted in pairs(options) do
						-- print("[VotingService] Exporting data for key: ", key.KeyName, categoryName, optionId, voted)
						local currentOptionTitle = VotingOptions[categoryName][optionId].title
						if voted then
							playerCSV[currentIndex] = currentOptionTitle
						end
					end
				end

				table.insert(data, playerCSV)
			end

			local currentGetAsyncBudget =
				DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
			local waitTime = 0.01 + math.clamp(20 - currentGetAsyncBudget, 0, 2)
			if waitTime > 0.01 then
				warn("[VotingService] Waiting for DataStoreService to catch up. Budget: ", currentGetAsyncBudget)
			end
			task.wait(waitTime)
		end
		allKeysPage:AdvanceToNextPageAsync()
	end

	self._ExportingData = false
	local rawJson = VotingService:_UploadToFileIO(data)
	--//Convert to CSV
	local csv = CSVTemplate
	for _, row in ipairs(data) do
		-- csv = csv .. "\n" .. table.concat(row, ",")
		csv = ("%s\n%s"):format(csv, table.concat(row, ","))
	end
	local csvUrl = VotingService:_UploadToFileIO(csv, false, ".csv")
	return ("JSON: %s\nCSV: %s"):format(rawJson, csvUrl)
	-- return VotingService:_UploadToJSONBin(data)
	-- return HttpService:JSONDecode(data)
end

function VotingService:KnitStart()
	Players.PlayerAdded:Connect(function(player)
		self:PlayerAdded(player)
	end)
	for _, player in pairs(Players:GetPlayers()) do
		self:PlayerAdded(player)
	end

	Players.PlayerRemoving:Connect(function(player)
		local profile = self.Profiles[player]
		if profile ~= nil then
			profile:Release()
		end
	end)
end

return VotingService
