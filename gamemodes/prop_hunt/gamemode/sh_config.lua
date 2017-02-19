-- Props will not be able to become these models
BANNED_PROP_MODELS = {
	"models/props/cs_assault/dollar.mdl",
	"models/props/cs_assault/money.mdl",
	"models/props/cs_office/snowman_arm.mdl",
	"models/props/cs_office/computer_mouse.mdl",
	"models/props/cs_office/projector_remote.mdl",
	"models/props/cs_militia/reload_bullet_tray.mdl",
	"models/foodnhouseholditems/egg.mdl"
}


-- Maximum time (in minutes) for this fretta gamemode (Default: 30)
GAME_TIME = 30


-- Number of seconds hunters are blinded/locked at the beginning of the map (Default: 30)
HUNTER_BLINDLOCK_TIME = 30


-- Health points removed from hunters when they shoot  (Default: 25)
HUNTER_FIRE_PENALTY = 5


-- How much health to give back to the Hunter after killing a prop (Default: 100)
HUNTER_KILL_BONUS = 100


-- Rounds played on a map (Default: 10)
ROUNDS_PER_MAP = 10


-- Time (in seconds) for each round (Default: 300)
ROUND_TIME = 300


-- Determains if players should be team swapped every round [0 = No, 1 = Yes] (Default: 1)
SWAP_TEAMS_EVERY_ROUND = 1

-- If you loose one of these will be played
-- Set blank to disable

-- // DEV HELP: why this is  not working anymore? \\ --
LOSS_SOUNDS = {
	"vo/announcer_failure.wav",
	"vo/announcer_you_failed.wav"
}

-- If you win, one of these will be played
-- Set blank to disable

-- // DEV HELP: why this is  not working anymore? \\ --
VICTORY_SOUNDS = {
	"vo/announcer_success.wav",
	"vo/announcer_victory.wav",
	"vo/announcer_we_succeeded.wav"
}