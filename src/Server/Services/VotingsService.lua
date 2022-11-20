local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)

local VotingService = Knit.CreateService({
	Name = "VotingService",
	Client = {},
})

return VotingService
