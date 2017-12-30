local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Balancehelper"
	local desc = "[Xel][7.x] Spellhelper: Balance"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(spell_nature_wrathv2) # Solar Wrath
	Texture(spell_arcane_starfire) # Lunar Strike
	Texture(ability_mage_firestarter) # Sunfire
	Texture(spell_nature_starfall) # Moonfire
	Texture(spell_arcane_arcane03) # Starsurge
	Texture(ability_druid_starfall) # Starfall
	Texture(ability_vehicle_sonicshockwave) # Solar Beam
	
	# Buffs
	Texture(spell_nature_forceofnature) # Moonkin Form
	Texture(spell_nature_natureguardian) # Celestial Alignment
	
	# Artifact (All icons are the same button)
	Texture(artifactability_balancedruid_newmoon) # New Moon
	Texture(artifactability_balancedruid_halfmoon) # Half Moon
	Texture(artifactability_balancedruid_fullmoon) # Full Moon
	
	# Talents
	Texture(ability_druid_forceofnature) # Force of Nature (T1)
	Texture(spell_holy_elunesgrace) # Warrior of Elune (T1)
	Texture(spell_nature_natureblessing) # Renewal (T2)
	Texture(spell_druid_displacement) # Displacer Beast (T2)
	Texture(spell_druid_wildcharge) # Wild Charge (T2)
	Texture(ability_druid_bash) # Mighty Bash (T4)
	Texture(spell_druid_massentanglement) # Mass Entanglement (T4)
	Texture(ability_druid_typhoon) # Typhoon (T4)
	Texture(spell_druid_incarnation) # Incarnation (T5)
	Texture(ability_druid_stellarflare) # Stellar Flare (T5)
	Texture(talentspec_druid_balance) # Astral Communion (T6)
	Texture(inv_pet_ancientprotector) # Blessing of the Ancients (T6)
	Texture(ability_druid_dreamstate) # Fury of Elune (T7)
	
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
	Texture(ability_ambush) # Shadowmeld (Night elf)
	
	# Legendary Rings
	Texture(inv_60legendary_ring1c) # Maalus / Thorasus
	Texture(inv_60legendary_ring1e) # Nithramus
	Texture(inv_60legendary_ring1a) # Etheralus
	Texture(inv_60legendary_ring1b) # Sanctus
}
]]

	OvaleScripts:RegisterScript("DRUID", "balance", name, desc, code, "script")
end
