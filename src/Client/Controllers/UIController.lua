local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local UIController = Knit.CreateController({
	Name = "UIController",
	Client = {},
})

function UIController:KnitStart()
    
end

return UIController
