AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

	self:SetUseType( SIMPLE_USE )
	self:SetModel("models/nzombies/acidgat_buildable.mdl")
	self.AutomaticFrameAdvance = true
	--self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:DrawShadow( false )
	
	local phys = self:GetPhysicsObject()
	
	self.Running = false
	self.PaP = false
	self.LastUser = nil
	self.Done = false
end

function ENT:OnRemove( ent )
	
end

function ENT:Think()	
	self:NextThink(CurTime());  return true;
end

function ENT:Use( activator, caller )
	if self.Running then return end
	local isnz = engine.ActiveGamemode() == "nzombies"
	
	if self.Done then
		if activator == self.LastUser then
			local wep = activator:Give("tfa_acidgat")
			--print(self.PaP)
			if self.PaP and isnz then
				timer.Simple(0, function()
					wep:ApplyNZModifier("pap")
					wep:SetClip1(wep.Primary.ClipSize)
					--wep:OnPaP()
				end)
			end
			self:SetBodygroup( 0, 0 )
			self:SetBodygroup( 1, 0 )
			self.LastUser = nil
			self.PaP = false
		end
	else
		if activator:HasWeapon("tfa_blundergat") then
			self.Running = true
			self.LastUser = activator
			if isnz and activator:GetWeapon("tfa_blundergat"):HasNZModifier("pap") then
				print("weapon has Pack-a-Punch")
				self.PaP = true
				self:SetBodygroup( 1, 2 )
			else
				self:SetBodygroup( 1, 1 )
			end
			--activator:SetActiveWeapon(nil)
			activator:StripWeapon("tfa_blundergat")
			if isnz then
				activator:EquipPreviousWeapon()
			end
			local sequence = self:LookupSequence("upgrade")
			self:ResetSequence(sequence)
			self:EmitSound("weapons/blundergat/acidgat_upgrade.mp3")
			self:SetBodygroup( 0, 1 )
			timer.Simple(4.3, function() 
				if IsValid(self) then
					--activator:ChatPrint("Done!")
					self:SetBodygroup( 0, 2 )
					self.Done = true
					self.Running = false
				end
			end)
		end
	end
	
	self.Done = false
end