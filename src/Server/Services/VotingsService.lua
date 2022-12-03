local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local VotingOptions = require(ReplicatedStorage.Shared.VotingOptions)
local EmptyVotedData = {}
for categoryName, options in pairs(VotingOptions) do
	EmptyVotedData[categoryName] = {}
	for i, _ in ipairs(options) do
		EmptyVotedData[categoryName][i] = false
	end
end

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
	local profile = VotingService.Profiles[player]
	if profile ~= nil then
		for i, optionData in ipairs(VotingOptions[categoryName]) do
			profile.Data[categoryName][i] = optionData.id == optionId
		end
		VotingService:UpdatePlayerVoted(player)
	end
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

	local data = {}
	local datastore = ProfileStore._global_data_store

	local allKeysPage = datastore:ListKeysAsync(nil, 100)
	while not allKeysPage.IsFinished do
		local currentPage = allKeysPage:GetCurrentPage()
		for _, key in ipairs(currentPage) do
			print("[VotingService] Exporting data for key: ", key.KeyName)
			local profile = ProfileStore:ViewProfileAsync(key.KeyName)
			if profile ~= nil then
				for categoryName, options in pairs(profile.Data) do
					data[categoryName] = data[categoryName] or {}
					for optionId, voted in pairs(options) do
						print("[VotingService] Exporting data for key: ", key.KeyName, categoryName, optionId, voted)
						local currentOptionTitle = VotingOptions[categoryName][optionId].title
						data[categoryName][currentOptionTitle] = data[categoryName][currentOptionTitle] or {}
						if voted then
							table.insert(data[categoryName][currentOptionTitle], key.KeyName)
						end
					end
				end
			end

			local currentGetAsyncBudget = DataStoreService:GetRequestBudgetForRequestType(Enum.DataStoreRequestType.GetAsync)
			local waitTime = 0.1 + math.clamp(20 - currentGetAsyncBudget, 0, 2)
			if waitTime > 0.1 then
				warn("[VotingService] Waiting for DataStoreService to catch up. Budget: ", currentGetAsyncBudget)
			end
			task.wait(waitTime)
		end
		allKeysPage:AdvanceToNextPageAsync()
	end

	self._ExportingData = false
	return HttpService:JSONEncode(data)
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
