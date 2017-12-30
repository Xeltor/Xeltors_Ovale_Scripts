local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Retrihelp"
	local desc = "[Xel][7.0.3] Spellhelper: Retribution"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_holy_crusaderstrike) # Crusader Strike
	Texture(ability_paladin_bladeofjustice) # Blade of Justice
	Texture(spell_holy_righteousfury) # Judgment
	Texture(spell_paladin_templarsverdict) # Templar's Verdict
	Texture(ability_paladin_divinestorm) # Divine Storm
	Texture(spell_holy_rebuke) # Rebuke
	Texture(spell_holy_sealofmight) # Hammer of Justice

	# Buffs
	Texture(spell_magic_greaterblessingofkings) # Greater Blessing of Kings
	Texture(spell_holy_greaterblessingofkings) # Greater Blessing of Might
	Texture(spell_holy_greaterblessingofwisdom) # Greater Blessing of Wisdom
	Texture(spell_holy_avenginewrath) # Avenging Wrath
	
	# Artifact
	Texture(inv_sword_2h_artifactashbringer_d_01) # Wake of Ashes

	# Talents
	Texture(spell_paladin_executionsentence) # Execution Sentence (T1)
	Texture(spell_holy_innerfire) # Consecration (T1)
	Texture(spell_holy_sealofblood) # Zeal (T2) (Replaces Crusader Strike)
	Texture(spell_holy_prayerofhealing) # Repentance (T3)
	Texture(ability_paladin_blindinglight) # Blinding Light (T3)
	Texture(ability_paladin_bladeofjusticeblue) # Blade of Wrath (T4) (Replaces Blade of Justice)
	Texture(classicon_paladin) # Divine Hammer (T4) (Replaces Blade of Justice)
	Texture(spell_holy_retributionaura) # Justicar's Vengeance (T5)
	Texture(spell_paladin_inquisition) # Eye for an Eye (T5)
	Texture(inv_helmet_96) # Word of Glory (T5)
	Texture(spell_holy_sealofvengeance) # Seal of Light (T6)
	Texture(ability_paladin_sanctifiedwrath) # Crusade (T7) (Replaces Avenging Wrath)
	Texture(spell_holy_vindication) # Holy Wrath (T7)

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
	Texture(ability_rogue_trip) # Escape Artist (Gnome)
	Texture(ability_ambush) # Shadowmeld (Night Elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("PALADIN", "retribution", name, desc, code, "script")
end
