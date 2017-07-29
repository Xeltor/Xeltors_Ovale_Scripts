local _, XelOvaleScripts = ...
local Ovale = XelOvaleScripts.Ovale
local OvaleScripts = Ovale.OvaleScripts

do
	local name = "WLKDESTROhelp"
	local desc = "[Xel][BROKEN] Spellhelper: Destruction"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_fire_burnout) # Incinerate
	Texture(spell_fire_ragnaros_lavabolt) # Incinerate FNB
	Texture(spell_fire_fireball) # Conflagrate
	Texture(spell_fire_ragnaros_molteninferno) # Conflagrate FNB
	Texture(spell_fire_immolation) # Immolate
	Texture(ability_mage_worldinflames) # Immolate FNB
	Texture(ability_warlock_chaosbolt) # Chaos Bolt
	Texture(spell_shadow_scourgebuild) # Shadowburn
	
	# Green flame spells
	Texture(spell_fire_burnoutgreen) # Incinerate GF
	Texture(spell_fire_ragnaros_lavaboltgreen) # Incinerate FNB GF
	Texture(spell_fire_fireballgreen2) # Conflagrate GF
	Texture(spell_fire_ragnaros_molteninfernogreen) # Conflagrate FNB GF
	Texture(spell_fire_felimmolation) # Immolate GF
	Texture(ability_mage_worldinflamesgreen) # Immolate FNB GF
	Texture(ability_warlock_chaosbolt) # Chaos Bolt
	Texture(spell_shadow_scourgebuild) # Shadowburn

	# Buffs
	Texture(spell_warlock_demonsoul) # Dark Soul: Instability
	Texture(spell_warlock_focusshadow) # Dark Intent
	Texture(ability_warlock_fireandbrimstone) # Fire and Brimstone
	Texture(ability_warlock_fireandbrimstonegreen) # Fire and Brimstone GF
	Texture(ability_warlock_baneofhavoc) # Havoc
	Texture(ability_mount_fireravengodmount) # Flames of Xoroth
	Texture(ability_mount_fireravengodmountgreen) # Flames of Xoroth GF
	Texture(warlock_summon_doomguard) # Summon Doomguard
	Texture(spell_shadow_summonfelhunter) # Summon Felhunter
	
	# Talents
	Texture(spell_warlock_darkregeneration) # Dark Regeneration (T1)
	Texture(spell_warlock_harvestoflife) # Harvest Life (T1)
	Texture(ability_warlock_howlofterror) # Howl of Terror (T2)
	Texture(ability_warlock_mortalcoil) # Mortal Coil (T2)
	Texture(ability_warlock_shadowfurytga) # Shadowfury (T2)
	Texture(warlock_sacrificial_pact) # Sacrificial Pact (T3)
	Texture(ability_deathwing_bloodcorruption_death) # Dark Bargain (T3)
	Texture(ability_deathwing_bloodcorruption_earth) # Blood Horror (T4)
	Texture(ability_deathwing_sealarmorbreachtga) # Burning Rush (T4)
	Texture(warlock_spelldrain) # Unbound Will (T4)
	Texture(warlock_grimoireofsacrifice) # Grimoire of Sacrifice (T5)
	Texture(achievement_boss_kiljaedan) # Kil'Jaeden's Cunning (T6)
	Texture(achievement_boss_magtheridon) # Mannoroth's Fury (T6)
	Texture(achievement_zone_cataclysm) # Cataclysm (T7)

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
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("WARLOCK", "destruction", name, desc, code, "script")
end
