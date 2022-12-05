--!strict
--literally copyright me
--do not steal this plz
local MarketplaceService = game:GetService("MarketplaceService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local Players = game:GetService("Players")
local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerFingerprintStore = MemoryStoreService:GetSortedMap("PlayerFingerprintStore")

local Knit = require(ReplicatedStorage.Packages.Knit)
local AuthService = Knit.CreateService({
	Name = "AuthService",
	Client = {},
	Fingerprints = {},
})

type FriendsData = {
	UserName: string,
	DisplayName: string,
}

local VERIFICATION_HAT_ID = 102611803
local REJECT_MESSAGE_TEMPLATE = "There was an error while joining the game. Please try again later. (%s)"
local ALL_REJECTED_REASON = {
	FingerprintInvalid = 21000,
	AccountAgeBelowMinimum = 21001,
	FriendsCountBelowMinimum = 21002,
	FriendsMostlyInactive = 21003,
	FriendsMostlyWithNoDisplayNames = 21004,
	AccountNotVerified = 21005,
	ProbablityTooLow = 21006,
	FingerprintPlayerIdMismatch = 21007,
	NotEnoughGroups = 21008,
	ServerError = 22000,
}

local CommonRoAviGroups = {
	1156950,
	7059794,
	10929040,
	7402874,
	8254555,
	9258650,
	4901539,
	3580340,
	11120952,
	8061823,
	2947220,
	4872777,
	4692437,
	11747162,
	3590840,
	832938,
	3313758,
	5687067,
	694775,
	2848557,
	2762113,
	1189759,
	5458142,
	3272666,
	2533932,
	3062338,
	3313758,
	2575242,
	3909938,
	4893536,
	4018562,
}

local function iterPageItems(pages)
	return coroutine.wrap(function()
		local pagenum = 1
		while true do
			for _, item in ipairs(pages:GetCurrentPage()) do
				coroutine.yield(item, pagenum)
			end
			if pages.IsFinished then
				break
			end
			pages:AdvanceToNextPageAsync()
			pagenum = pagenum + 1
		end
	end)
end

function AuthService:CheckPlayerHasVotePermission(player: Player): boolean | number
	if player:GetAttribute("Authorized") then
		return true
	end
	--All the infomation that we can gather from the player
	local accountAge = player.AccountAge
	local isRegularMember = player.MembershipType == Enum.MembershipType.None

	local allFriends: { FriendsData } = {}
	local getPlayerFriendsDataSuccess, friendPages = pcall(function()
		return Players:GetFriendsAsync(player.UserId)
	end)
	if getPlayerFriendsDataSuccess then
		for item, _ in iterPageItems(friendPages) do
			if #allFriends >= 100 then
				break
			end
			table.insert(allFriends, item)
		end

		if #allFriends < 8 then
			return ALL_REJECTED_REASON.FriendsCountBelowMinimum
		else
			local withDisplayName = 0
			for _, friend in pairs(allFriends) do
				if friend.DisplayName ~= "" and friend.DisplayName ~= friend.UserName then
					withDisplayName += 1
				end
			end
			if withDisplayName <= (#allFriends * 0.95) then --// 95% of friends have no display name
				return ALL_REJECTED_REASON.FriendsMostlyWithNoDisplayNames
			end
		end
	end

	if not isRegularMember then
		return true
	end

	if accountAge < 30 then
		return ALL_REJECTED_REASON.AccountAgeBelowMinimum
	end

	local checkPlayerVerifiedDataSuccess, hasVerificationHat =
		pcall(MarketplaceService.PlayerOwnsAsset, MarketplaceService, player, VERIFICATION_HAT_ID)
	if checkPlayerVerifiedDataSuccess and not hasVerificationHat then
		return ALL_REJECTED_REASON.AccountNotVerified
	end

	--//Probablity section, we can't reliably check
	local passedChecks = 0 --//Each check should return 0-1, 1 being passed
	local playerGroups = GroupService:GetGroupsAsync(player.UserId)
	local inCommonGroups = 0
	for _, groupInfo in pairs(playerGroups) do
		for _, commonGroupId in pairs(CommonRoAviGroups) do
			if groupInfo.Id == commonGroupId then
				inCommonGroups += 1
			end
		end
	end

	if #playerGroups <= 2 then
		return ALL_REJECTED_REASON.NotEnoughGroups
	end

	passedChecks += (inCommonGroups / #CommonRoAviGroups)
	passedChecks += (checkPlayerVerifiedDataSuccess and hasVerificationHat) and 1 or 0
	passedChecks += if #playerGroups > 3 and #playerGroups < 8 then 1 else 0.5
	passedChecks += if accountAge > 40 then 1 else 0
	passedChecks += if #allFriends > 15 then 1 else 0.5

	print("Passed checks: ", passedChecks)

	if passedChecks < 2.5 then
		return ALL_REJECTED_REASON.ProbablityTooLow
	end

	local fingerprintDataFetchSuccess, lastFingerprintData = pcall(function()
		return PlayerFingerprintStore:GetAsync(self.Fingerprints[player])
	end)
	if fingerprintDataFetchSuccess then
		if lastFingerprintData then
			print("Last fingerprint data: ", lastFingerprintData)
			if lastFingerprintData.PlayerId ~= player.UserId then
				return ALL_REJECTED_REASON.FingerprintPlayerIdMismatch
			end
		end
	else
		warn("Failed to get fingerprint data for player", player, self.Fingerprints[player])
	end

	task.spawn(function()
		PlayerFingerprintStore:SetAsync(self.Fingerprints[player], {
			PlayerId = player.UserId,
			Fingerprint = self.Fingerprints[player],
			LastUsed = DateTime.now().UnixTimestamp,
		}, 60 * 60 * 24 * 7) --//7 days
	end)

	return true
end

function AuthService:PlayerJoined(player: Player)
	player:SetAttribute("Authorized", false)
	local joinTime = os.clock()
	repeat
		task.wait()
	until os.clock() - joinTime > 50 or self.Fingerprints[player] or player.Parent == nil
	if player.Parent == nil then
		return
	end

	if not self.Fingerprints[player] then
		player:Kick(REJECT_MESSAGE_TEMPLATE:format(ALL_REJECTED_REASON.ServerError))
	end

	local votePermission = self:CheckPlayerHasVotePermission(player)
	print(votePermission)
	if typeof(votePermission) ~= "boolean" then
		player:Kick(REJECT_MESSAGE_TEMPLATE:format(votePermission or ALL_REJECTED_REASON.FingerprintInvalid))
	end
	player:SetAttribute("Authorized", true)
end

function AuthService:KnitStart()
	Players.PlayerRemoving:Connect(function(player)
		self.Fingerprints[player] = nil
	end)

	for _, player in pairs(Players:GetPlayers()) do
		task.spawn(function()
			self:PlayerJoined(player)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		self:PlayerJoined(player)
	end)
end

function AuthService.Client:SetFingerprint(player: Player, fingerprint: string)
	print("SetFingerprint", player, fingerprint)
	AuthService.Fingerprints[player] = AuthService.Fingerprints[player] or fingerprint
end

function AuthService.Client:CheckPlayerHasVotePermission(player: Player): boolean
	return player:GetAttribute("Authorized")
end

return AuthService
