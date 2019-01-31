local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WLKDESTROhelp"
	local desc = "[Xel][8.x] Spellhelper: Destruction"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_fire_burnout) # Incinerate
	Texture(spell_fire_fireball) # Conflagrate
	Texture(spell_fire_immolation) # Immolate
	Texture(ability_warlock_chaosbolt) # Chaos Bolt
	Texture(spell_shadow_rainoffire) # Rain of Fire
	Texture(spell_shadow_mindrot) # Spell Lock (command demon)
	
	# Green flame spells
	Texture(spell_fire_burnoutgreen) # Incinerate GF
	Texture(spell_fire_fireballgreen2) # Conflagrate GF
	Texture(spell_fire_felimmolation) # Immolate GF
	Texture(ability_warlock_chaosbolt) # Chaos Bolt
	Texture(spell_fire_felrainoffire) # Rain of Fire GF
	Texture(spell_shadow_mindrot) # Spell Lock (command demon)
	
	# Survival stuff
	Texture(spell_shadow_lifedrain02) # Drain Life
	Texture(ability_deathwing_bloodcorruption_death) # Health Funnel
	Texture(inv_misc_gem_bloodstone_01) # Create Healthstone
	Texture(inv_stone_04) # Healthstone
	Texture(spell_shadow_demonictactics) # Unending Resolve

	# Buffs
	Texture(ability_warlock_baneofhavoc) # Havoc
	Texture(spell_shadow_summoninfernal) # Summon Infernal
	Texture(spell_shadow_demonbreath) # Unending Breath
	
	# Items
	Texture(inv_jewelry_talisman_12) # Trinkets
	
	# Talents
	Texture(spell_fire_firebolt) # Soul Fire (T1)
	Texture(spell_shadow_scourgebuild) # Shadowburn (T2)
	Texture(achievement_zone_cataclysm) # Cataclysm (T4)
	Texture(achievement_zone_cataclysmgreen) # Cataclysm GF (T4)
	Texture(ability_warlock_mortalcoil) # Mortal Coil (T5)
	Texture(warlock_grimoireofsacrifice) # Grimoire of Sacrifice (T6)
	Texture(spell_fire_ragnaros_lavaboltgreen) # Channel Demonfire (T7)
	Texture(spell_warlock_soulburn) # Dark Soul: Instability (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)


	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "destruction", name, desc, code, "script")
end
