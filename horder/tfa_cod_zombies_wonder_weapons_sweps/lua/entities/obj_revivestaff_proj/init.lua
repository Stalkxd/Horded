AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Think()
	if CurTime() > self.LifeTime then 
		self:Remove()
		return
	end
end

function ENT:StartTouch(ent)
	if self.HasCollided then return end
	local data = self:GetTouchTrace()
	
	if data.HitSky then 
		self:Remove() 
		return 
	end
	
	if ent == self.Owner then return false end
	self.HasCollided = true
	
	for k, v in pairs(ents.FindInSphere(data.HitPos, 65)) do
		if v:IsPlayer() then
			if v.RevivePlayer then v:RevivePlayer(self.Owner) end
		elseif ent:IsNPC() or ent:IsNextBot() then
			ent:TakeDamageInfo(self.DamageInfo)
		end
	end
	
	self:Remove()
	return true
end