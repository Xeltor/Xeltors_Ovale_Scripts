local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "DKUhelp"
	local desc = "[Xel][7.1.5] Spellhelper: Unholy"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_deathknight_festering_strike) # Festering Strike
	Texture(spell_deathknight_scourgestrike) # Scourge Strike
	Texture(spell_shadow_deathcoil) # Death Coil
	Texture(spell_deathvortex) # Outbreak
	Texture(spell_deathknight_butcher2) # Death Strike
	Texture(spell_deathknight_mindfreeze) # Mind Freeze
	Texture(spell_shadow_deathanddecay) # Death and Decay

	# Buffs
	Texture(spell_shadow_animatedead) # Raise Dead
	Texture(achievement_boss_festergutrotface) # Dark Transformation
	Texture(ability_deathknight_summongargoyle) # Summon Gargoyle
	Texture(spell_deathknight_iceboundfortitude) # Icebound Fortitude
	Texture(spell_deathknight_armyofthedead) # Army of the Dead
	
	# Artifact
	Texture(artifactability_unholydeathknight_deathsembrace) # Apocalypse

	# Talents
	Texture(spell_deathknight_unholypresence) # Epidemic (T2)
	Texture(spell_deathknight_plaguestrike) # Blighted Rune Weapon (T2)
	Texture(warlock_curse_shadow) # Clawing Shadows (T3)
	Texture(ability_deathknight_asphixiate) # Asphyxiate (T4)
	Texture(inv_pet_ghoul) # Corpse Shield (T5)
	Texture(achievement_boss_svalasorrowgrave) # Dark Arbiter (T7)
	Texture(spell_deathknight_defile) # Defile (T7)
	Texture(ability_deathknight_soulreaper) # Soul Reaper (T7)

	# Racials
	Texture(racial_orc_berserkerstrength) # Blood Fury (Orc)
	Texture(racial_troll_berserk) # Berserking (Troll)
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
	Texture(spell_shadow_raisedead) # Will of the Forsaken (Undead)
	Texture(inv_gizmo_rocketlauncher) # Rocket Barrage (Goblin)
	Texture(spell_shadow_unholystrength) # Stoneform (Dwarf)
	Texture(spell_shadow_charm) # Every Man for Himself (Human)
	Texture(spell_holy_holyprotection) # Gift of the Naaru (Draenei)
	Texture(ability_racial_darkflight) # Darkflight (Worgen)
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("DEATHKNIGHT", "unholy", name, desc, code, "script")
end
