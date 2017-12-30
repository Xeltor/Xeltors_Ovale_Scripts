local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "WLKAFFLICTIONhelp"
	local desc = "[Xel][7.x] Spellhelper: Affliction"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_shadow_curseofsargeras) # Agony
	Texture(spell_shadow_abominationexplosion) # Corruption
	Texture(spell_shadow_unstableaffliction_3) # Unstable Affliction
	Texture(spell_shadow_haunting) # Drain Soul
	Texture(spell_shadow_seedofdestruction) # Seed of Corruption
	Texture(spell_shadow_mindrot) # Spel Lock (Felhunter)

	# Buffs
	Texture(spell_shadow_burningspirit) # Life Tap
	Texture(warlock_summon_doomguard) # Summon Doomguard
	Texture(spell_shadow_summoninfernal) # Summon Infernal
	Texture(spell_shadow_lifedrain) # Health Funnel
	
	# Artifact
	Texture(inv_staff_2h_artifactdeadwind_d_01) # Reap Souls
	
	# Talents
	Texture(ability_warlock_haunt) # Haunt (T1)
	Texture(inv_enchant_voidsphere) # Phantom Singularity (T4)
	Texture(spell_warlock_demonsoul) # Soul Harvest (T4)
	Texture(spell_shadow_summonfelhunter) # Grimoire of Service (T6) (Grimoire: Felhunter)
	Texture(spell_shadow_requiem) # Siphon Life (T7)

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

	OvaleScripts:RegisterScript("WARLOCK", "affliction", name, desc, code, "script")
end
