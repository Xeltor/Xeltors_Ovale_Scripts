local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Xelhelpsurv"
	local desc = "[Xel][8.0] Spellhelper: Survival"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_hunter_raptorstrike) # Raptor Strike
	Texture(ability_hunter_carve) # Carve
	Texture(ability_hunter_killcommand) # Kill Command
	Texture(spell_hunter_exoticmunitions_poisoned) # Serpent Sting
	Texture(inv_wildfirebomb) # Wildfire Bomb
	Texture(ability_hunter_harpoon) # Harpoon
	Texture(ability_hunter_negate) # Muzzle

	# Buffs
	Texture(spell_hunter_aspectoftheironhawk) # Aspect of the Eagle
	Texture(inv_coordinatedassault) # Coordinated Assault
	Texture(ability_hunter_onewithnature) # Exhilaration
	Texture(ability_hunter_mendpet) # Mend Pet
	Texture(inv_misc_pheonixpet_01) # Heart of the Phoenix
	Texture(ability_hunter_beastsoothe) # Revive Pet
	Texture(ability_physical_taunt) # Pet Growl
	Texture(icon_orangebird_toy) # Call Pet
	
	# Items
	Texture(inv_jewelry_talisman_12) # Link to a trinket macro

	# Talents
	Texture(ability_butcher_cleave) # Butchery (T2) (Replaces Carve)
	Texture(ability_hunter_camouflage) # Camouflage (T3)
	Texture(inv_pet_pettrap02) # Steel Trap (T4)
	Texture(ability_hunter_murderofcrows) # A Murder of Crows (T4)
	Texture(spell_fire_incinerate) # Mongoose Bite (T6) (Replaces Raptor Strike)
	Texture(ability_hunter_invigeration) # Flanking Strike (T6)
	Texture(inv_wildfirebomb_shrapnel) # Wildfire Infusion Shrapnel (T7) (Replaces Wildfire Bomb)
	Texture(inv_wildfirebomb_blood) # Wildfore Infusion Pheromone (T7) (Replaces Wildfire Bomb)
	Texture(inv_wildfirebomb_poison) # Wildfire Infusion Volatile (T7) (Replaces Wildfire Bomb)
	Texture(ability_glaivetoss) # Chakrams (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(pandarenracial_quiveringpain) # Quaking Palm (Pandaren)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
