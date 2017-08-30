-- Finds the player meta table or terminates
local meta = FindMetaTable("Player")
if !meta then return end


-- Blinds the player by setting view out into the void
function meta:Blind(bool)
	if !IsValid( self ) then return end
	
	if SERVER then
		net.Start("SetBlind")
		if bool then
			net.WriteBool(true)
		else
			net.WriteBool(false)
		end
		net.Send(self)
	elseif CLIENT then
		blind = bool
	end
end


function meta:RemoveProp()
	if CLIENT || !self:IsValid() then return end
	
	if self.ph_prop && self.ph_prop:IsValid() then
		self.ph_prop:Remove()
		self.ph_prop = nil
	end
end
