local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WLKDESTROhelp"
	local desc = "[Xel][7.x] Spellhelper: Destruction"
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
	
	# Green flame spells
	Texture(spell_fire_burnoutgreen) # Incinerate GF
	Texture(spell_fire_fireballgreen2) # Conflagrate GF
	Texture(spell_fire_felimmolation) # Immolate GF
	Texture(ability_warlock_chaosbolt) # Chaos Bolt
	Texture(spell_fire_felrainoffire) # Rain of Fire GF

	# Buffs
	Texture(spell_shadow_burningspirit) # Life Tap
	Texture(spell_warlock_demonsoul) # Soul Harvest
	Texture(warlock_summon_doomguard) # Summon Doomguard
	Texture(spell_shadow_summoninfernal) # Summon Infernal
	
	# Artifact
	Texture(spell_warlock_demonicportal_purple) # Dimensional Rift
	
	# Talents
	Texture(spell_shadow_scourgebuild) # Shadowburn (T1)
	Texture(ability_warlock_mortalcoil) # Mortal Coil (T3)
	Texture(ability_warlock_shadowfurytga) # Shadowfury (T3)
	Texture(achievement_zone_cataclysm) # Cataclysm (T4)
	Texture(achievement_zone_cataclysmgreen) # Cataclysm GF (T4)
	Texture(spell_shadow_summonimp) # Grimoire: Imp (T5)
	Texture(spell_shadow_summonvoidwalker) # Grimoire: Voidwalker (T5)
	Texture(spell_shadow_summonsuccubus) # Grimoire: Succubus (T5)
	Texture(spell_shadow_summonfelhunter) # Grimoire: Felhunter (T5)
	Texture(warlock_grimoireofsacrifice) # Grimoire of Sacrifice (T5)
	Texture(spell_fire_ragnaros_lavaboltgreen) # Channel Demonfire (T6)

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
