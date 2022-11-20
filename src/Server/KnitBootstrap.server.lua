local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load core module:
local Knit = require(ReplicatedStorage.Packages.Knit)
Knit.AddServicesDeep(script.Parent:WaitForChild("Services"))

-- Start Knit:
local startTime = os.clock()
Knit.Start({ ServicePromises = false })
	:catch(function(err)
		warn("Knit framework failure: " .. tostring(err))
	end)
	:andThen(function()
		warn("[Server] Knit framework started in " .. tostring(os.clock() - startTime) .. " seconds")
	end)
