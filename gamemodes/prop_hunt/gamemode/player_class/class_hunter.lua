-- Create new class
local CLASS = {}


-- Some settings for the class
CLASS.DisplayName			= "Pony"
CLASS.WalkSpeed 			= 230
CLASS.CrouchedWalkSpeed 	= 0.2
CLASS.RunSpeed				= 250
CLASS.DuckSpeed				= 0.2
CLASS.DrawTeamRing			= false


-- Called by spawn and sets loadout
function CLASS:Loadout(pl)
    pl:GiveAmmo(64, "Buckshot")
    pl:GiveAmmo(255, "SMG1")
    pl:GiveAmmo(12, "357")
    
    pl:Give("weapon_crowbar")
    pl:Give("weapon_shotgun")
    pl:Give("weapon_smg1")
	pl:Give("item_ar2_grenade")
    pl:Give("weapon_357")
	
	local cl_defaultweapon = pl:GetInfo("cl_defaultweapon") 
 	 
 	if pl:HasWeapon(cl_defaultweapon) then 
 		pl:SelectWeapon(cl_defaultweapon)
 	end 
end


-- Called when player spawns with this class
-- This player spawns frozen if there is more than 2 secs left from the unlock time (This is only useful when the player joins DURING a game)
-- The server handle unlocking in the OnRoundStart function
function CLASS:OnSpawn(pl)
	local round_timer = (CurTime() - GetGlobalFloat("RoundStartTime", 0))
	
	if round_timer < -2 then  // more than 2 secs remaining, that's a workaround...
	
		pl:Blind(true)
		timer.Simple(2, function()
			pl.Lock(pl)
		end )
	
	end
	
end


-- Called when a player dies with this class
function CLASS:OnDeath(pl, attacker, dmginfo)
	pl:CreateRagdoll()
	pl:UnLock()
end


-- Register
player_class.Register("Pony", CLASS)
