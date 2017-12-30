local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "Foxadin"
	local desc = "[Foxy][BROKEN] Paladin: Protection, Retribution"
	local code = [[
Define(ancient_power 86700)
Define(avenging_wrath 31884)
Define(avengers_shield 31935)
Define(ardent_defender 31850)
  SpellAddBuff(ardent_defender ardent_defender=1)
Define(bastion_of_glory 114637)
Define(blessing_of_kings 20217)
Define(blessing_of_might 19740)
Define(consecration 26573)
Define(crusader_strike 35395)
Define(divine_protection 498)
Define(divine_shield 642)
Define(divine_storm 53385)
  SpellInfo(divine_storm holy=3 )
Define(execution_sentence 114157)
Define(exorcism 879)
Define(exorcism_glyphed 122032)
Define(fist_of_justice 105593)
Define(forbearance 25771)
Define(guardian_of_ancient_kings 86698)
Define(guardian_of_ancient_kings_tank 86659)
Define(grand_crusader 85416)
Define(glyph_of_divine_protection 54924)
Define(glyph_of_harsh_words 54938)
Define(glyph_of_mass_exorcism 122028)
Define(hammer_of_justice 853)
Define(hammer_of_the_righteous 53595)
Define(hammer_of_wrath 24275)
Define(holy_avenger 105809)
Define(holy_prism 114165)
Define(holy_wrath 119072)
Define(inquisition 84963)
  SpellInfo(inquisition holy=1 )
Define(judgment 20271)
Define(lay_on_hands 633)
Define(lights_hammer 114158)
Define(rebuke 96231)
Define(righteous_fury 25780)
Define(sacred_shield 20925)
Define(seal_of_insight 20165)
Define(seal_of_truth 31801)
Define(seal_of_righteousness 20154)
Define(shield_of_the_righteous 53600)
  SpellInfo(shield_of_the_righteous holy=3 )
Define(templars_verdict 85256)
  SpellInfo(templars_verdict holy=3 )
Define(weakened_blows 115798)
Define(word_of_glory 85673)
  SpellInfo(word_of_glory holy=1 )
Define(long_arm_of_the_law_talent 2)
Define(fist_of_justice_talent 4)
Define(sacred_shield_talent 9)
Define(unbreakable_spirit_talent 11)
Define(holy_avenger_talent 13)
Define(sanctified_wrath_talent 14)
Define(holy_prism_talent 16)
Define(lights_hammer_talent 17)
Define(execution_sentence_talent 18)
Define(alchemist_flask 75525)
SpellList(alchemist_flask_buff 105617 79638)
AddIcon specialization=1 help=main
{
	if not mounted() and HasFullControl()
	{
		if not BuffPresent(str_agi_int any=1) and not BuffPresent(mastery) Spell(blessing_of_kings)
		if not BuffPresent(str_agi_int) and not BuffPresent(mastery any=1) Spell(blessing_of_might)
		if not BuffPresent(alchemist_flask_buff) and ItemCount(alchemist_flask) >=1 Item(alchemist_flask)
	}
}
AddIcon specialization=2 help=main
{
	unless Stance(3) Spell(seal_of_insight)
	if not mounted() and HasFullControl()
	{
		if not BuffPresent(mastery any=1) and not BuffPresent(mastery) Spell(blessing_of_might)
		if not BuffPresent(str_agi_int any=1) and not BuffPresent(mastery) Spell(blessing_of_kings)
		if not BuffPresent(str_agi_int) and not BuffPresent(mastery any=1) Spell(blessing_of_might)
		if not BuffPresent(righteous_fury) Spell(righteous_fury)
		if not BuffPresent(alchemist_flask_buff) and ItemCount(alchemist_flask) >=1 Item(alchemist_flask)
	}
	if LifePercent() <90
	{
		if LifePercent() <=10 and not BuffPresent(ardent_defender) and not DebuffPresent(forbearance) Spell(lay_on_hands)
		if LifePercent() <15 Spell(ardent_defender)
		if LifePercent() <25 Spell(guardian_of_ancient_kings_tank)
		if LifePercent() <35 and TalentPoints(holy_avenger_talent) Spell(holy_avenger)
		if LifePercent() <35 Spell(word_of_glory)
		if BuffStacks(bastion_of_glory) ==5 and HolyPower() >=3 Spell(word_of_glory)
	}
	if TargetInRange(crusader_strike) and HasFullControl()
	{
		if TargetClassification(worldboss) or {TargetClassification(elite) and {MaxHealth() *20} <target.MaxHealth()}
		{
			Spell(avenging_wrath)
		}
		if TargetIsInterruptible() Spell(rebuke)
		if not TargetClassification(worldboss) and TargetIsInterruptible() and SpellCooldown(rebuke) >1 and not PreviousSpell(rebuke)
		{
			if TalentPoints(fist_of_justice_talent) Spell(fist_of_justice)
			if not TalentPoints(fist_of_justice_talent) Spell(hammer_of_justice)
		}
		Spell(shield_of_the_righteous)
		if BuffPresent(grand_crusader) Spell(avengers_shield)
		if CheckBoxOn(trash)
		{
			Spell(consecration)
			Spell(hammer_of_the_righteous)
			Spell(holy_wrath)
		}
		if not BuffPresent(sacred_shield) and TalentPoints(sacred_shield_talent) Spell(sacred_shield)
		if CheckBoxOff(trash) Spell(crusader_strike)
		Spell(judgment)
		Spell(avengers_shield)
		if Glyph(glyph_of_divine_protection) and TalentPoints(unbreakable_spirit_talent) Spell(divine_protection)
		if TalentPoints(execution_sentence_talent) Spell(execution_sentence)
		if TalentPoints(lights_hammer_talent) Spell(lights_hammer)
		Spell(holy_wrath)
		if target.HealthPercent() <=20 Spell(hammer_of_wrath)
		Spell(consecration)
	}
	if TargetInRange(judgment) and HasFullControl() and TalentPoints(long_arm_of_the_law_talent) and InCombat() Spell(judgment)
}
AddIcon specialization=3 help=main
{
	if not mounted() and HasFullControl()
	{
		if not BuffPresent(str_agi_int any=1) and not BuffPresent(mastery) Spell(blessing_of_kings)
		if not BuffPresent(str_agi_int) and not BuffPresent(mastery any=1) Spell(blessing_of_might)
		if not BuffPresent(alchemist_flask_buff) and ItemCount(alchemist_flask) >=1 Item(alchemist_flask)
	}
	if CheckBoxOff(aoe8) and HasFullControl()
	{
		if ManaPercent() <20 and not Stance(4) Spell(seal_of_insight)
		if {ManaPercent() >=60 and not Stance(1)} or {ManaPercent() >=20 and not Stance(4) and not Stance(1)} Spell(seal_of_truth)
	}
	if CheckBoxOn(aoe8) and not Stance(2) and HasFullControl() Spell(seal_of_righteousness)
	if not Stance(1) and not Stance(2) and not Stance(4) and HasFullControl() Spell(seal_of_truth)
	if TargetInRange(crusader_strike) and HasFullControl()
    {
		if not BuffPresent(inquisition) or {BuffRemains(inquisition) <=5 and HolyPower() >=3} Spell(inquisition)
		if TargetIsInterruptible() Spell(rebuke)
		if not TargetClassification(worldboss) and TargetIsInterruptible() and SpellCooldown(rebuke) >1 and not PreviousSpell(rebuke)
		{
			if TalentPoints(fist_of_justice_talent) Spell(fist_of_justice)
			if not TalentPoints(fist_of_justice_talent) Spell(hammer_of_justice)
		}
		if TargetClassification(worldboss) or {TargetClassification(elite) and {MaxHealth() *20} <target.MaxHealth()}
		{
			if TalentPoints(holy_avenger_talent) and HolyPower() >=3 Spell(holy_avenger)
			Spell(guardian_of_ancient_kings)
			if {BuffPresent(guardian_of_ancient_kings) and BuffStacks(ancient_power) >=20} or {not BuffPresent(guardian_of_ancient_kings) and SpellCooldown(guardian_of_ancient_kings) >2}
			{
				if TalentPoints(execution_sentence_talent) Spell(execution_sentence)
				Spell(avenging_wrath)
			}
			if TalentPoints(sanctified_wrath_talent) Spell(avenging_wrath)
		}
		if HolyPower() >=5
		{
			if CheckBoxOff(aoe2) and CheckBoxOff(aoe8)
			{
				Spell(templars_verdict)
			}
			if CheckBoxOn(aoe2) or CheckBoxOn(aoe8)
			{
				Spell(divine_storm)
			}
		}
		if target.HealthPercent() <=20 or BuffPresent(avenging_wrath) Spell(hammer_of_wrath)
		if CheckBoxOn(aoe2) or CheckBoxOn(aoe8)
		{
			if TalentPoints(holy_prism_talent) Spell(holy_prism)
		}
		if not Glyph(glyph_of_mass_exorcism) Spell(exorcism)
		if Glyph(glyph_of_mass_exorcism) Spell(exorcism_glyphed)
		if CheckBoxOff(aoe2) and CheckBoxOff(aoe8)
		{
			Spell(crusader_strike)
		}
		if CheckBoxOn(aoe2) or CheckBoxOn(aoe8)
		{
			Spell(hammer_of_the_righteous)
		}
		Spell(judgment)
		if CheckBoxOff(aoe2) and CheckBoxOff(aoe8)
		{
			Spell(templars_verdict)
		}
		if CheckBoxOn(aoe2) or CheckBoxOn(aoe8)
		{
			Spell(divine_storm)
		}
		if not BuffPresent(sacred_shield) and TalentPoints(sacred_shield_talent) Spell(sacred_shield)
	}
	if TargetInRange(word_of_glory) and HasFullControl() and Glyph(glyph_of_harsh_words) and InCombat() and HolyPower() >=3 Spell(word_of_glory)
	if TargetInRange(judgment) and HasFullControl() and TalentPoints(long_arm_of_the_law_talent) and InCombat() Spell(judgment)
}
AddCheckBox(trash "Trash" specialization=2)
AddCheckBox(aoe2 "2+" specialization=3)
AddCheckBox(aoe8 "8+" specialization=3)
]]

	OvaleScripts:RegisterScript("PALADIN", nil, name, desc, code, "script")
end
