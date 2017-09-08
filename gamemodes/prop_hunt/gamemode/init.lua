-- Send the required lua files to the client
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("sh_config.lua")
AddCSLuaFile("sh_init.lua")
AddCSLuaFile("sh_player.lua")
AddCSLuaFile("cl_round_end.lua")

util.AddNetworkString( "SetHull" )
util.AddNetworkString( "ResetHull" )
util.AddNetworkString( "SetBlind" )

util.AddNetworkString( "PH_RoundOverWithWinner" ) -- used for round ending things, since it's not clearly solved how this is broadcasted

-- If there is a mapfile send it to the client (sometimes servers want to change settings for certain maps)
if file.Exists("../gamemodes/prop_hunt/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	AddCSLuaFile("maps/"..game.GetMap()..".lua")
end


-- Include the required lua files
include("sh_init.lua")


-- Server only constants
EXPLOITABLE_DOORS = {
	"func_door",
	"prop_door_rotating", 
	"func_door_rotating"
}
USABLE_PROP_ENTITIES = {
	"prop_physics",
	"prop_physics_multiplayer"
}

-- Called alot
function GM:CheckPlayerDeathRoundEnd()
	if !GAMEMODE.RoundBased || !GAMEMODE:InRound() then 
		return
	end

	local Teams = GAMEMODE:GetTeamAliveCounts()

	if table.Count(Teams) == 0 then
		GAMEMODE:RoundEndWithResult(1001, "Draw, everypony loses!")
		return
	end

	if table.Count(Teams) == 1 then
		local TeamID = table.GetFirstKey(Teams)
		GAMEMODE:RoundEndWithResult(TeamID, team.GetName(1).." win!")
		return
	end
	
end


-- Called when an entity takes damage
function EntityTakeDamage(ent, dmginfo)
    local att = dmginfo:GetAttacker()
	if GAMEMODE:InRound() && ent && ent:GetClass() != "ph_prop" && !ent:IsPlayer() && att && att:IsPlayer() && att:Team() == TEAM_HUNTERS && att:Alive() then
		att:SetHealth(att:Health() - HUNTER_FIRE_PENALTY)
		if att:Health() <= 0 then
			MsgAll(att:Name() .. " felt guilty for hurting so many innocent props and committed suicide\n")
			att:Kill()
		end
	end
end
hook.Add("EntityTakeDamage", "PH_EntityTakeDamage", EntityTakeDamage)


-- Called when player tries to pickup a weapon
function GM:PlayerCanPickupWeapon(pl, ent)

 	return pl:Team() == TEAM_HUNTERS

end

-- Make a variable for custom 3 combines.
local playerModels = {}
local function addModel(model)
	local t = {}
	t.model = model
	table.insert(playerModels, t)
end

-- delivered from stock Gmod's player manager
--[[ those are not poniez
addModel("combine")
addModel("combineprison")
addModel("combineelite")
addModel("police")
]]--

addModel("Trixie")
addModel("Derpy Hooves")
--addModel("Princess Celestia")
--addModel("Princess Luna")
addModel("Lyra")
addModel("Rainbow Dash")
addModel("Fluttershy")
addModel("Pinkie Pie")
addModel("Rarity")
addModel("Twilight Sparkle")
addModel("Applejack")
addModel("Bon Bon")
addModel("Colgate (Minuette)")
addModel("Vinyl Scratch")
addModel("Raindrops")
addModel("Daring Do")
addModel("Spitfire")
addModel("Roseluck")
addModel("Octavia")
addModel("Princess Twilight")


function GM:PlayerSetModel(pl)

	-- set antlion gib small for Prop model. Do not change into others because this might purposed as a hitbox.
	local player_model = "models/Gibs/Antlion_gib_small_3.mdl"
	
	-- Hunters have their models selected by the method in PreRoundStart (To avoid duplications)
	if pl:Team() == TEAM_HUNTERS then
		player_model = player_manager.TranslatePlayerModel( pl.pony_playermodel )
	end

	-- Precache it
	util.PrecacheModel(player_model)
	pl:SetModel(player_model)

end
	
-- Called when a player tries to use an object
function GM:PlayerUse(pl, ent)
	if !pl:Alive() || pl:Team() == TEAM_SPECTATOR then return false end
	
	if pl:Team() == TEAM_PROPS && pl:IsOnGround() && !pl:Crouching() && table.HasValue(USABLE_PROP_ENTITIES, ent:GetClass()) && ent:GetModel() then
		if table.HasValue(BANNED_PROP_MODELS, ent:GetModel()) then
			pl:ChatPrint("That prop has been banned by the server.")
		elseif ent:GetPhysicsObject():IsValid() && pl.ph_prop:GetModel() != ent:GetModel() then
			local ent_health = math.Clamp(ent:GetPhysicsObject():GetVolume() / 250, 1, 200)
			local new_health = math.Clamp((pl.ph_prop.health / pl.ph_prop.max_health) * ent_health, 1, 200)
			local per = pl.ph_prop.health / pl.ph_prop.max_health
			pl.ph_prop.health = new_health
			
			pl.ph_prop.max_health = ent_health
			pl.ph_prop:SetModel(ent:GetModel())
			pl.ph_prop:SetSkin(ent:GetSkin())
			pl.ph_prop:SetSolid(SOLID_BSP)
			pl.ph_prop:SetPos(pl:GetPos() - Vector(0, 0, ent:OBBMins().z))
			pl.ph_prop:SetAngles(pl:GetAngles())
			
			local hullxymax = math.Round(math.Max(ent:OBBMaxs().x, ent:OBBMaxs().y))
			local hullxymin = hullxymax * -1
			local hullz = math.Round(ent:OBBMaxs().z)
			
			pl:SetHull(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			pl:SetHullDuck(Vector(hullxymin, hullxymin, 0), Vector(hullxymax, hullxymax, hullz))
			pl:SetHealth(new_health)
			
			net.Start("SetHull")
				net.WriteInt(hullxymax,32)
				net.WriteInt(hullz,32)
				net.WriteInt(new_health,16)
			net.Send(pl)
		end
	end
	
	-- Prevent the door exploit
	if table.HasValue(EXPLOITABLE_DOORS, ent:GetClass()) && pl.last_door_time && pl.last_door_time + 1 > CurTime() then
		return false
	end
	
	pl.last_door_time = CurTime()
	return true
end

--[[
-- Called when the gamemode is initialized -- This does not even working since the command is blocked.
function Initialize()
	game.ConsoleCommand("mp_flashlight 1\n")
end
hook.Add("Initialize", "PH_Initialize", Initialize)
]]--

-- Called when a player leaves
function PlayerDisconnected(pl)
	pl:RemoveProp()
end
hook.Add("PlayerDisconnected", "PH_PlayerDisconnected", PlayerDisconnected)


-- Called when the players spawns
function PlayerSpawn(pl) 


	local hands = pl:GetHands() -- I don't want hands... I'm a pony
	if ( IsValid( hands ) ) then hands:Remove() end

	pl:Blind(false)
	pl:RemoveProp()
	pl:SetColor( Color(255, 255, 255, 255))
	pl:SetRenderMode( RENDERMODE_TRANSALPHA )
	pl:UnLock()
	pl:ResetHull()
	pl.last_taunt_time = 0
	
	net.Start("ResetHull")
	net.Send(pl)
	
	pl:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
end
hook.Add("PlayerSpawn", "PH_PlayerSpawn", PlayerSpawn)


-- Removes all weapons on a map
function RemoveWeaponsAndItems()
	for _, wep in pairs(ents.FindByClass("weapon_*")) do
		wep:Remove()
	end
	
	for _, item in pairs(ents.FindByClass("item_*")) do
		item:Remove()
	end
end
hook.Add("InitPostEntity", "PH_RemoveWeaponsAndItems", RemoveWeaponsAndItems)


function release_hunters() 

	for _, pl in pairs(team.GetPlayers(TEAM_HUNTERS)) do
		pl:Blind(false)
		pl:Freeze(false)
		pl:UnLock() // lock happens after spawn
	end

end

function lock_hunters()

	for _, pl in pairs(team.GetPlayers(TEAM_HUNTERS)) do
		pl:Blind(true)
		pl:Freeze(true)
	end

end

-- Called when round ends
function GM:OnRoundEnd( num, winner )


	if (winner != nil) and (type(winner) == "number") then
	
		net.Start("PH_RoundOverWithWinner")
			net.WriteInt(winner,8)
		net.Broadcast()
	
	end

	release_hunters() -- round ends during the freeze time
	
end


-- This is called when the round time ends (props win)
function GM:RoundTimerEnd()
	if !GAMEMODE:InRound() then
		return
	end
   
	GAMEMODE:RoundEndWithResult(TEAM_PROPS)
end


function GM:CanStartRound( iNum ) -- We only want to start the round, when players joined (prevent game starting from the second round)
	return (#team.GetPlayers(TEAM_PROPS) > 0) && (#team.GetPlayers(TEAM_HUNTERS) > 0)
end



function GM:OnRoundStart( num )

	release_hunters()

end 


-- Called before start of round (and b4 players getting their models)
function GM:OnPreRoundStart(num)

	-- do some game stuff
	game.CleanUpMap()
	
	-- Swap teams if needed
	if GetGlobalInt("RoundNumber") != 1 && (SWAP_TEAMS_EVERY_ROUND == 1 || ((team.GetScore(TEAM_PROPS) + team.GetScore(TEAM_HUNTERS)) > 0 || SWAP_TEAMS_POINTS_ZERO==1)) then
		for _, pl in pairs(player.GetAll()) do
				if pl:Team() == TEAM_PROPS || pl:Team() == TEAM_HUNTERS then
				if pl:Team() == TEAM_PROPS then
					pl:SetTeam(TEAM_HUNTERS)
				else
					pl:SetTeam(TEAM_PROPS)
				end
				
				pl:ChatPrint("Teams have been swapped!")

			end
		end
	end
	
	-- Generate playermodel list
	local clist = {}
	for _, pl in pairs(player.GetAll()) do 
		if pl:Team() == TEAM_HUNTERS then
		
			if #clist == 0 then -- this is actually a very slow way to make sure everypony is unique
				clist = table.Copy(playerModels)
			end
			
			local pony_playermodel_cid = math.random( #clist )
			pl.pony_playermodel = clist[pony_playermodel_cid].model
			table.remove( clist, pony_playermodel_cid )
		
		end
	end
	
	-- Do some other game stuff
	UTIL_StripAllPlayers()
	UTIL_SpawnAllPlayers()	
	
	lock_hunters()
	
	-- release changelings for the pre-game
	for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
		pl:UnLock() // this removes the freeze as well
	end

	
end


-- We have our own badass roundend stuff
function GM:OnEndOfGame(bGamemodeVote)

	for k,v in pairs( player.GetAll() ) do

		v:Lock(true) // Lock > Freeze
		-- We don't want to show the scoreboard
	end
	
end