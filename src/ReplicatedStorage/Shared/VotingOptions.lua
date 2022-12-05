export type VotingOptionData = {
	title: string,
	owner: string,
	preview: string,
	id: string,
}

local VotingOptions: { [string]: { VotingOptionData } } = { --// VotingOptions[Category][index] = VotingOptionData
	["Best Airline <1000"] = {
		-- AIRLINE	<1000	Azul Linhas Aéreas Virtual	opicityy
		-- AIRLINE	<1000	Swedconnect	suomidev
		-- AIRLINE	<1000	TAP Air Portugal	duaxrte
		-- AIRLINE	<1000	United (B<1000)	Eyxxn
		{
			title = "Azul Linhas Aéreas Virtual",
			owner = "opicityy",
			preview = "rbxassetid://11744795918",
			id = "azul_linhas_1000",
		},
		{
			title = "Swedconnect",
			owner = "suomidev",
			preview = "rbxassetid://11489362884",
			id = "swedconnect_1000",
		},
		{
			title = "TAP Air Portugal",
			owner = "duaxrte",
			preview = "rbxassetid://11744799062",
			id = "tap_air_1000",
		},
		{
			title = "United",
			owner = "Eyxxn",
			preview = "rbxassetid://11744798322",
			id = "united_1000",
		},
	},
	["Best Airline >5000"] = {
		-- AIRLINE	>5000	LeMonde Airlines	LMDHolder
		-- AIRLINE	>5000	Qatar	adyneet
		-- AIRLINE	>5000	Ryanair	MichaelO_Leary
		-- AIRLINE	>5000	Southwest Airlines	SFranxisco
		{
			title = "LeMonde Airlines",
			owner = "LMDHolder",
			preview = "rbxassetid://11744842584",
			id = "lemonde_airline_best_5000",
		},
		{
			title = "Qatar",
			owner = "adyneet",
			preview = "rbxassetid://11744841624",
			id = "qatar_best_5000",
		},
		{
			title = "Ryanair",
			owner = "MichaelO_Leary",
			preview = "rbxassetid://11744841244",
			id = "ryanair_best_5000",
		},
		{
			title = "Southwest Airlines",
			owner = "SFranxisco",
			preview = "rbxassetid://11744840397",
			id = "southwest_airlines_best_5000",
		},
	},
	["Best Airline 1000-5000"] = {
		-- AIRLINE	1000-5000	Dynasty	aaditbh12
		-- AIRLINE	1000-5000	Qantas	horridrbx
		-- AIRLINE	1000-5000	Skyrden	EuroMalik
		-- AIRLINE	1000-5000	KoreanAir	Ja_xxon
		{
			title = "Dynasty",
			owner = "aaditbh12",
			preview = "rbxassetid://11489332878",
			id = "dynasty_best_1000_5000",
		},
		{
			title = "Qantas",
			owner = "VH_NHP",
			preview = "rbxassetid://11744822985",
			id = "qantas_best_1000_5000",
		},
		{
			title = "Skyrden",
			owner = "EuroMalik",
			preview = "rbxassetid://11744823947",
			id = "skyrden_best_1000_5000",
		},
		{
			title = "KoreanAir",
			owner = "Ja_xxon",
			preview = "rbxassetid://11744826331",
			id = "koreanair_best_1000_5000",
		},
	},
	-- AIRLINE	Tech	LeMonde Airlines	LMDHolder
	-- AIRLINE	Tech	Qatar	adyneet
	-- AIRLINE	Tech	Skylink	cloudscitizen
	-- AIRLINE	Tech	Dynasty	aaditbh12
	["Best Airline Tech"] = {
		{
			title = "LeMonde Airlines",
			owner = "LMDHolder",
			preview = "rbxassetid://11744774499",
			id = "lemonde_airline_best_tech",
		},
		{
			title = "Qatar",
			owner = "adyneet",
			preview = "rbxassetid://11744773472",
			id = "qatar_best_tech",
		},
		{
			title = "Skylink",
			owner = "cloudscitizen",
			preview = "rbxassetid://11744772887",
			id = "skylink_best_tech",
		},
		{
			title = "Dynasty",
			owner = "aaditbh12",
			preview = "rbxassetid://11489332878",
			id = "dynasty_best_tech",
		},
	},
	-- MISC	Aviator	luxckxy	0
	-- MISC	Aviator	Opicityy	0
	-- MISC	Aviator	Patron	0
	-- MISC	Aviator	Neoptic	0
	["Best Aviator"] = {
		{
			title = "luxckxy",
			owner = "luxckxy",
			preview = "rbxassetid://11744752070",
			id = "luxckxy_best_aviator",
		},
		{
			title = "Opicityy",
			owner = "Opicityy",
			preview = "rbxassetid://11744687235",
			id = "Opicityy_best_aviator",
		},
		{
			title = "Patron",
			owner = "Patron",
			preview = "rbxassetid://11744661816",
			id = "Patron_best_aviator",
		},
		{
			title = "Neoptic",
			owner = "Neoptic",
			preview = "rbxassetid://11744661816",
			id = "Neoptic_best_aviator",
		},
	},
	-- MISC	DispTeam	Virtual Roblox Blue Display Group	Immortalemx
	-- MISC	DispTeam	Roblox Red Arrows	unasterism
	-- MISC	DispTeam	Virtual Roblox Patrouille Acrobatique De France	 Mams134
	-- MISC	DispTeam	Roblox Red Bull Air Force	TwoPatronimo
	["Best Display Team"] = {
		{
			title = "Virtual Roblox Blue Angels",
			owner = "Riceiix",
			preview = "rbxassetid://11735252134",
			id = "virtual_roblox_blue_display_group_best_disp_team",
		},
		{
			title = "Roblox Red Arrows",
			owner = "unasterism",
			preview = "rbxassetid://11735253527",
			id = "roblox_red_arrows_best_disp_team",
		},
		{
			title = "Virtual Roblox Patrouille Acrobatique De France",
			owner = "Mams134",
			preview = "rbxassetid://11735254299",
			id = "virtual_roblox_patrouille_acrobatique_de_france_best_disp_team",
		},
		{
			title = "Roblox Red Bull Air Force",
			owner = "Anversev",
			preview = "rbxassetid://11735254925",
			id = "roblox_red_bull_air_force_best_disp_team",
		},
	},
	-- MISC	Event	NATA22	martinamrtins1
	-- MISC	Event	VRFAT2022
	-- MISC	Event	"ZeroTech Landing Competition
	-- MISC Event   AviAwards
	-- MISC	Event	-
	["Best Event"] = {
		{
			title = "NATA22",
			owner = "martinamrtins1",
			preview = "rbxassetid://11750678528",
			id = "nata22_best_event",
		},
		{
			title = "VRFAT2022",
			owner = "Roblox Red Arrows",
			preview = "rbxassetid://11735253527",
			id = "vrfat2022_best_event",
		},
		{
			title = "ZeroTech Landing Competition",
			owner = "ZeroTech",
			preview = "rbxassetid://0",
			id = "zerotech_landing_competition_best_event",
		},
		{
			title = "AviAwards",
			owner = "JoeBiden",
			preview = "rbxassetid://0",
			id = "aviawards_best_event",
		},
	},
	-- MISC	YouTuber	Executive757	0
	-- MISC	YouTuber	Patron	0
	-- MISC	YouTuber	EclipseDownBad	0
	-- MISC	YouTuber	neopticrblx	0
	["Best YouTuber"] = {
		{
			title = "Executive757",
			owner = "Executive757",
			preview = "rbxassetid://11744664560",
			id = "executive757_best_youtuber",
		},
		{
			title = "Patron",
			owner = "Patron",
			preview = "rbxassetid://11744662922",
			id = "patron_best_youtuber",
		},
		{
			title = "EclipseDownBad",
			owner = "EclipseDownBad",
			preview = "rbxassetid://11744663781",
			id = "eclipsedownbad_best_youtuber",
		},
		{
			title = "neopticrblx",
			owner = "neopticrblx",
			preview = "rbxassetid://11744661816",
			id = "neopticrblx_best_youtuber",
		},
	},
	-- DEV	Tech Group	Eurowhite	BritishAviator_RBX
	-- DEV	Tech Group	Vuela	mezzaRBX
	-- DEV	Tech Group	MiaTech	sxcribble
	-- DEV	Tech Group	PROP	P_ikachoo
	["Best Tech Group"] = {
		{
			title = "Eurowhite",
			owner = "BritishAviator_RBX",
			preview = "rbxassetid://0",
			id = "eurowhite_best_tech_group",
		},
		{
			title = "Vuela",
			owner = "mezzaRBX",
			preview = "rbxassetid://0",
			id = "vuela_best_tech_group",
		},
		{
			title = "MiaTech",
			owner = "sxcribble",
			preview = "rbxassetid://0",
			id = "miatech_best_tech_group",
		},
		{
			title = "PROP",
			owner = "P_ikachoo",
			preview = "rbxassetid://0",
			id = "prop_best_tech_group",
		},
	},
	-- DEV	Mesh	Spidercatcher1 (ZeroTech)	0
	-- DEV	Mesh	devdecimal (Eurowhite)	0
	-- DEV	Mesh	Kokobin_HD	0
	-- DEV	Mesh	OmniiDev (Nikoleta)	0
	["Best Mesh Developer"] = {
		{
			title = "Spidercatcher1 (ZeroTech)",
			owner = "Spidercatcher1",
			preview = "rbxassetid://11735238700",
			id = "spidercatcher1_zerotech_best_mesh_developer",
		},
		{
			title = "devdecimal (Eurowhite)",
			owner = "devdecimal",
			preview = "rbxassetid://11735239759",
			id = "devdecimal_eurowhite_best_mesh_developer",
		},
		{
			title = "Kokobin_HD",
			owner = "Kokobin_HD",
			preview = "rbxassetid://11736485088",
			id = "kokobin_hd_best_mesh_developer",
		},
		{
			title = "OmniiDev (Nikoleta)",
			owner = "OmniiDev",
			preview = "rbxassetid://11735242086",
			id = "omniidev_nikoleta_best_mesh_developer",
		},
	},
	-- DEV	CSG	nghtRBX	0
	-- DEV	CSG	Efficient7_x	0
	-- DEV	CSG	SimulatedJosh	0
	-- DEV	CSG	realistictraindev	0
	["Best CSG Developer"] = {
		{
			title = "nghtRBX",
			owner = "nghtRBX",
			preview = "rbxassetid://11735218726",
			id = "nghtrbx_best_csg_developer",
		},
		{
			title = "Efficient7_x",
			owner = "Efficient7_x",
			preview = "rbxassetid://11735221922",
			id = "efficient7_x_best_csg_developer",
		},
		{
			title = "SimulatedJosh",
			owner = "SimulatedJosh",
			preview = "rbxassetid://11745115502",
			id = "simulatedjosh_best_csg_developer",
		},
		{
			title = "realistictraindev",
			owner = "realistictraindev",
			preview = "rbxassetid://11735226951",
			id = "realistictraindev_best_csg_developer",
		},
	},
	-- DEV	Airport	LeMonde Airlines	LMDHolder
	-- DEV	Airport	globalSkies	laceboyo
	-- DEV	Airport	United (BA)	galaxxTM
	-- DEV	Airport	Qantas	horridrbx
	["Best Airport"] = {
		{
			title = "Rostock Laage",
			owner = "LeMonde Airlines",
			preview = "rbxassetid://11735170813",
			id = "lemonde_airlines_best_airport",
		},
		{
			title = "John F. Kennedy",
			owner = "globalSkies",
			preview = "rbxassetid://11735202256",
			id = "globalskies_best_airport",
		},
		{
			title = "Washington Dulles",
			owner = "United (BA)",
			preview = "rbxassetid://11735209099",
			id = "united_ba_best_airport",
		},
		{
			title = "Sydney",
			owner = "Qantas (axstralia_nx)",
			preview = "rbxassetid://11735214020",
			id = "qantas_best_airport",
		},
	},
}
return VotingOptions
