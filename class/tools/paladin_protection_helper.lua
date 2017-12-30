local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Prothelp"
	local desc = "[Xel][7.x] Spellhelper: Protection"
	local code = [[
AddIcon
{
	# Remove a line when you have its colour
	# Spells
	Texture(ability_paladin_shieldofvengeance) # Shield of the Righteous
	Texture(ability_paladin_hammeroftherighteous) # Hammer of the Righteous
	Texture(spell_holy_righteousfury) # Judgment
	Texture(spell_holy_innerfire) # Consecration
	Texture(spell_holy_avengersshield) # Avengers Shield
	Texture(spell_holy_rebuke) # Rebuke
	Texture(spell_holy_flashheal) # Flash of Light
	Texture(ability_paladin_lightoftheprotector) # Light of the Protector

	# Buffs
	Texture(spell_holy_heroism) # Guardian of Ancient Kings
	Texture(spell_holy_ardentdefender) # Ardent Defender
	Texture(spell_holy_divineshield) # Divine Shield
	Texture(spell_holy_sealofprotection) # Blessing of Protection
	Texture(spell_holy_avenginewrath) # Avenging Wrath
	Texture(spell_holy_sealofsacrifice) # Blessing of Sacrifice
	Texture(spell_holy_layonhands) # Lay on Hands

	# Artifact
	Texture(inv_shield_1h_artifactnorgannon_d_01) # Eye of Tyr
	
	# Talents
	Texture(paladin_retribution) # Blessed Hammer (T1)(Replaces Hammer of the Righteous)
	Texture(paladin_protection) # Bastion of Light (T2)
	Texture(spell_holy_prayerofhealing) # Repentance (T3)
	Texture(ability_paladin_blindinglight) # Blinding Light (T3)
	Texture(spell_holy_blessingofprotection) # Blessing of Spellwarding (T4)(Replaces Blessing of Protection)
	Texture(ability_paladin_blessedhands) # Hand of the Protector (T5)(Replaces Light of the Protector)
	Texture(spell_holy_greaterblessingoflight) # Aegis of Light (T6)
	Texture(ability_paladin_seraphim) # Seraphim (T7)

	# Racials
	Texture(spell_shadow_teleport) # Arcane Torrent (Blood Elf)
	Texture(ability_warstomp) # War Stomp (Tauren)
}
]]

	OvaleScripts:RegisterScript("PALADIN", "protection", name, desc, code, "script")
end
