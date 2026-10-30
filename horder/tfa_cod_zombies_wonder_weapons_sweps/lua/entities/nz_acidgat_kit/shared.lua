//ENT.Base = "base_entity"
ENT.Type = "anim"

ENT.PrintName		= "Blundergat Upgrade"

ENT.Category = "nZombies"
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:OnRemove()
end

function ENT:PhysicsUpdate()
end

function ENT:PhysicsCollide(data,phys)
end

if CLIENT then
	function ENT:GetNZTargetText()
		if LocalPlayer():HasWeapon("tfa_blundergat") then
			return "Press E to convert Blundergat into Acidgat"
		else
			return "Requires Blundergat or Sweeper"
		end
	end
	
end