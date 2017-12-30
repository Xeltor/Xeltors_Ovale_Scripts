local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Xelhelpsurv"
	local desc = "[Xel][7.0.3] Spellhelper: Survival"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_hunter_raptorstrike) # Raptor Strike
	Texture(ability_hunter_mongoosebite) # Mongoose Bite
	Texture(ability_hunter_invigeration) # Flanking Strike
	Texture(ability_hunter_laceration) # Lacerate
	Texture(ability_hunter_carve) # Carve
	Texture(spell_fire_selfdestruct) # Explosive Trap
	Texture(ability_hunter_harpoon) # Harpoon
	Texture(ability_hunter_negate) # Muzzle

	# Buffs
	Texture(spell_hunter_aspectoftheironhawk) # Aspect of the Eagle
	Texture(ability_hunter_onewithnature) # Exhilaration
	Texture(ability_hunter_misdirection) # Misdirection
	Texture(ability_hunter_mendpet) # Mend Pet
	Texture(inv_misc_pheonixpet_01) # Heart of the Phoenix
	Texture(ability_hunter_beastsoothe) # Revive Pet
	Texture(ability_physical_taunt) # Pet Growl
	
	# Artifact
	Texture(inv_polearm_2h_artifacteagle_d_01) # Fury of the Eagle

	# Talents
	Texture(inv_throwingaxepvp320_07) # Throwing Axes (T1)
	Texture(ability_hunter_murderofcrows) # A Murder of Crows (T2)
	Texture(achievement_boss_epochhunter) # Snake Hunter (T2)
	Texture(ability_ironmaidens_incindiarydevice) # Caltrops (T4)
	Texture(inv_pet_pettrap02) # Steel Trap (T4)
	Texture(inv_misc_bomb_08) # Sticky Bomb (T5)
	Texture(inv_misc_net_01) # Ranger's Net (T5)
	Texture(ability_hunter_camouflage) # Camouflage (T5)
	Texture(ability_butcher_cleave) # Butchery (T6)
	Texture(spell_fire_incinerate) # Dragonsfire Grenade (T6)
	Texture(ability_hunter_cobrastrikes) # Spitting Cobra (T7)

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
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
