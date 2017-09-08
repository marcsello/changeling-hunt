local winner_team = 0
local alpha = 0
local round_end_image = Material( "ponies_vs_changelings/gameend1.png", "noclamp" )


hook.Add( "HUDPaint", "PH_RoundOverSplash", function()

	if winner_team != 0 then
		surface.SetMaterial( round_end_image )
		surface.SetDrawColor( 255,255,255, alpha )
		
		if winner_team == TEAM_PROPS then
			surface.DrawTexturedRectUV((ScrW()-480)/2,ScrH()/6,480,300,0,0.5,1,1)
		else
			surface.DrawTexturedRectUV((ScrW()-480)/2,ScrH()/6,480,300,0,0,1,0.5)
		end
		
	end

end )

net.Receive("PH_RoundOverWithWinner", function( len )

	winner_team = net.ReadInt(8)
	
	if winner_team == TEAM_PROPS then
	
		surface.PlaySound("ponies_vs_changelings/changelingwin1.mp3")
	
	elseif winner_team == TEAM_HUNTERS then
	
		surface.PlaySound("ponies_vs_changelings/ponywin1.mp3")
	
	end 	
	
	-- do the fade in fade out thing
	alpha = 0
	timer.Create( "winner_splash_alpha_fade_in", 0.032, 50, function()
	
		alpha = alpha + 5.1
		
	end	)

	timer.Create( "winner_splash_alpha_stay", 12 - ((0.032*50)*2) - 1, 1, function()
	
		alpha = 255
		timer.Create( "winner_splash_alpha_fade_out", 0.032, 50, function()
		
			alpha = alpha - 5.1
		
		end )
		
		timer.Create( "winner_splash_disabler", (0.032*50), 1, function()
		
			winner_team = 0
		
		end )
	
	end )

end )