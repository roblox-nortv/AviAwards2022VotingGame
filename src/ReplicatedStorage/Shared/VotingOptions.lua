export type VotingOptionData = {
	title: string,
	owner: string,
	preview: string,
	id: string,
}

local VotingOptions: { [string]: { VotingOptionData } } = { --// VotingOptions[Category][index] = VotingOptionData
	["Testing category 1"] = {
		{
			title = "Testing option 1",
			owner = "Testing option 1 owner",
			preview = "rbxassetid://0",
			id = "testing_option_1",
		},
		{
			title = "Testing option 2",
			owner = "Testing option 2 owner",
			preview = "rbxassetid://0",
			id = "testing_option_2",
		},
		{
			title = "Testing option 3",
			owner = "Testing option 3 owner",
			preview = "rbxassetid://0",
			id = "testing_option_3",
		},
		{
			title = "Testing option 4",
			owner = "Testing option 4 owner",
			preview = "rbxassetid://0",
			id = "testing_option_4",
		},
	},
	["Testing category 2"] = {
		{
			title = "Testing option 5",
			owner = "Testing option 5 owner",
			preview = "rbxassetid://0",
			id = "testing_option_5",
		},
		{
			title = "Testing option 6",
			owner = "Testing option 6 owner",
			preview = "rbxassetid://0",
			id = "testing_option_6",
		},
		{
			title = "Testing option 7",
			owner = "Testing option 7 owner",
			preview = "rbxassetid://0",
			id = "testing_option_7",
		},
		{
			title = "Testing option 8",
			owner = "Testing option 8 owner",
			preview = "rbxassetid://0",
			id = "testing_option_8",
		},
	},
}
return VotingOptions
