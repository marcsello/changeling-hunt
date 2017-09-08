include("sh_init.lua")

-- Decides where  the player view should be (forces third person for props)
function GM:CalcView(pl, origin, angles, fov)
	local view = {} 
	
	if blind then
		view.origin = Vector(20000, 0, 0)
		view.angles = Angle(0, 0, 0)
		view.fov = fov
		
		return view
	end
	
 	view.origin = origin 
 	view.angles	= angles 
 	view.fov = fov 
 	
 	-- Give the active weapon a go at changing the viewmodel position 
	if pl:Team() == TEAM_PROPS && pl:Alive() then
		view.origin = origin + Vector(0, 0, hullz - 60) + (angles:Forward() * -80)
	else
	 	local wep = pl:GetActiveWeapon() 
	 	if wep && wep != NULL then 
	 		local func = wep.GetViewModelPosition 
	 		if func then 
	 			view.vm_origin, view.vm_angles = func(wep, origin*1, angles*1) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end
	 		 
	 		local func = wep.CalcView 
	 		if func then 
	 			view.origin, view.angles, view.fov = func(wep, pl, origin*1, angles*1, fov) -- Note: *1 to copy the object so the child function can't edit it. 
	 		end 
	 	end
	end
 	
 	return view 
end

-- This is a work around... we draw a big black rectangle on the screen, because viewport based blinding is a bit unrealible (but better)
function HUDPaint()

	if blind then
		
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect(0,0,ScrW(),ScrH())
	
	end


	
	
	
	
	
	
end
hook.Add("HUDPaint", "PH_HUDPaint", HUDPaint)


-- Called immediately after starting the gamemode 
function Initialize()
	hullz = 80
end
hook.Add("Initialize", "PH_Initialize", Initialize)


-- Resets the player hull
function ResetHull( len )
	if LocalPlayer() && LocalPlayer():IsValid() then
		LocalPlayer():ResetHull()
		hullz = 80
	end
end
net.Receive("ResetHull", ResetHull)

-- Don't show hands! Ponies don't have hands...
function GM:PostDrawViewModel( vm, pl, weapon )
	--[[
   if weapon.UseHands or (not weapon:IsScripted()) then
      local hands = LocalPlayer():GetHands()
      if IsValid(hands) then hands:DrawModel() end
   end
   ]]
end

-- Sets the local blind variable to be used in CalcView
net.Receive("SetBlind", function ( len )
	blind = net.ReadBool()
end )
 


-- Sets the player hull
net.Receive("SetHull", function ( len )
	hullxy = net.ReadInt(32)
	hullz = net.ReadInt(32)
	new_health = net.ReadInt(16)
	
	LocalPlayer():SetHull(Vector(hullxy * -1, hullxy * -1, 0), Vector(hullxy, hullxy, hullz))
	LocalPlayer():SetHullDuck(Vector(hullxy * -1, hullxy * -1, 0), Vector(hullxy, hullxy, hullz))
	LocalPlayer():SetHealth(new_health)
end )

-- Stuff happens after round ends, like showing the logo, and playing music, and such
include("cl_round_end.lua")