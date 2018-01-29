local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_shadow"
	local desc = "[Xel][7.3] Priest: Shadow"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_priest_spells)

AddIcon specialization=3 help=main
{
	if InCombat() InterruptActions()
	
	if InCombat() and HasFullControl() and target.InRange(mind_blast)
	{
		if Speed() == 0 or CanMove() > 0
		{
			ShadowDefaultCdActions()
			ShadowDefaultShortCdActions()
			ShadowDefaultMainActions()
		}
		
		if Speed() > 0
		{
			#shadow_word_pain,moving=1,cycle_targets=1
			if target.DebuffExpires(shadow_word_pain) Spell(shadow_word_pain)
		}
	}
}

AddFunction Boss
{
	IsBossFight() or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(silence) Spell(silence)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_mana)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddFunction haste_eval_value
{
 { SpellHaste() - 0.3 } * { 10 + 10 * HasEquippedItem(mangazas_madness) + 5 * TalentPoints(fortress_of_the_mind_talent) }
}

AddFunction dot_swp_dpgcd
{
 36.5 * 1.2 * { 1 + 0.06 * ArtifactTraitRank(to_the_pain) } * { 1 + 0.2 + MasteryRating() / 16000 } * 0.75
}

AddFunction erupt_eval
{
 26 + 1 * TalentPoints(fortress_of_the_mind_talent) - 4 * TalentPoints(sanlayn_talent) - 3 * TalentPoints(shadowy_insight_talent) + haste_eval() * 1.5
}

AddFunction cd_time
{
 12 + { 2 - 2 * TalentPoints(mindbender_talent) * ArmorSetBonus(T20 4) } * ArmorSetBonus(T19 2) + { 1 - 3 * TalentPoints(mindbender_talent) * ArmorSetBonus(T20 4) } * HasEquippedItem(mangazas_madness) + { 6 + 5 * TalentPoints(mindbender_talent) } * ArmorSetBonus(T20 4) + 2 * ArtifactTraitRank(lash_of_insanity)
}

AddFunction dot_vt_dpgcd
{
 68 * 1.2 * { 1 + 0.2 * TalentPoints(sanlayn_talent) } * { 1 + 0.05 * ArtifactTraitRank(touch_of_darkness) } * { 1 + 0.2 + MasteryRating() / 16000 } * 0.5
}

AddFunction s2mcheck
{
 if s2mcheck_value() > s2mcheck_min() s2mcheck_value()
 s2mcheck_min()
}

AddFunction s2msetup_time
{
 if Talent(surrender_to_madness_talent) 0.8 * { 83 + { 20 + 20 * TalentPoints(fortress_of_the_mind_talent) } * ArmorSetBonus(T20 4) - 5 * TalentPoints(sanlayn_talent) + { 33 - 13 * ArmorSetBonus(T20 4) } * TalentPoints(reaper_of_souls_talent) + ArmorSetBonus(T19 2) * 4 + 8 * HasEquippedItem(mangazas_madness) + SpellHaste() * 10 * { 1 + 0.7 * ArmorSetBonus(T20 4) } * { 2 + 0.8 * ArmorSetBonus(T19 2) + 1 * TalentPoints(reaper_of_souls_talent) + 2 * ArtifactTraitRank(mass_hysteria) - 1 * TalentPoints(sanlayn_talent) } }
}

AddFunction s2mcheck_min
{
 180
}

AddFunction s2mcheck_value
{
 s2msetup_time() - actors_fight_time_mod() * 0
}

AddFunction actors_fight_time_mod
{
 if TimeInCombat() + target.TimeToDie() <= 450 { 450 - { TimeInCombat() + target.TimeToDie() } } / 5
 if TimeInCombat() + target.TimeToDie() > 450 and TimeInCombat() + target.TimeToDie() < 600 -{ { -450 + TimeInCombat() + target.TimeToDie() } / 10 }
 0
}

AddFunction sear_dpgcd
{
 120 * 1.2 * { 1 + 0.05 * ArtifactTraitRank(void_corruption) }
}

AddFunction haste_eval
{
 if haste_eval_value() < haste_eval_max() haste_eval_value()
 haste_eval_max()
}

AddFunction haste_eval_max
{
 0
}

### actions.default

AddFunction ShadowDefaultMainActions
{
 #call_action_list,name=check,if=talent.surrender_to_madness.enabled&!buff.surrender_to_madness.up
 if Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) ShadowCheckMainActions()

 unless Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckMainPostConditions()
 {
  #run_action_list,name=s2m,if=buff.voidform.up&buff.surrender_to_madness.up
  if BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) ShadowS2mMainActions()

  unless BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mMainPostConditions()
  {
   #run_action_list,name=vf,if=buff.voidform.up
   if BuffPresent(voidform_buff) ShadowVfMainActions()

   unless BuffPresent(voidform_buff) and ShadowVfMainPostConditions()
   {
    #run_action_list,name=main
    ShadowMainMainActions()
   }
  }
 }
}

AddFunction ShadowDefaultMainPostConditions
{
 Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckMainPostConditions() or BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mMainPostConditions() or BuffPresent(voidform_buff) and ShadowVfMainPostConditions() or ShadowMainMainPostConditions()
}

AddFunction ShadowDefaultShortCdActions
{
 #call_action_list,name=check,if=talent.surrender_to_madness.enabled&!buff.surrender_to_madness.up
 if Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) ShadowCheckShortCdActions()

 unless Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckShortCdPostConditions()
 {
  #run_action_list,name=s2m,if=buff.voidform.up&buff.surrender_to_madness.up
  if BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) ShadowS2mShortCdActions()

  unless BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mShortCdPostConditions()
  {
   #run_action_list,name=vf,if=buff.voidform.up
   if BuffPresent(voidform_buff) ShadowVfShortCdActions()

   unless BuffPresent(voidform_buff) and ShadowVfShortCdPostConditions()
   {
    #run_action_list,name=main
    ShadowMainShortCdActions()
   }
  }
 }
}

AddFunction ShadowDefaultShortCdPostConditions
{
 Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckShortCdPostConditions() or BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mShortCdPostConditions() or BuffPresent(voidform_buff) and ShadowVfShortCdPostConditions() or ShadowMainShortCdPostConditions()
}

AddFunction ShadowDefaultCdActions
{
 #potion,if=buff.bloodlust.react|target.time_to_die<=80|(target.health.pct<35&cooldown.power_infusion.remains<30)
 # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 80 or target.HealthPercent() < 35 and SpellCooldown(power_infusion) < 30 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
 #call_action_list,name=check,if=talent.surrender_to_madness.enabled&!buff.surrender_to_madness.up
 if Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) ShadowCheckCdActions()

 unless Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckCdPostConditions()
 {
  #run_action_list,name=s2m,if=buff.voidform.up&buff.surrender_to_madness.up
  if BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) ShadowS2mCdActions()

  unless BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mCdPostConditions()
  {
   #run_action_list,name=vf,if=buff.voidform.up
   if BuffPresent(voidform_buff) ShadowVfCdActions()

   unless BuffPresent(voidform_buff) and ShadowVfCdPostConditions()
   {
    #run_action_list,name=main
    ShadowMainCdActions()
   }
  }
 }
}

AddFunction ShadowDefaultCdPostConditions
{
 Talent(surrender_to_madness_talent) and not BuffPresent(surrender_to_madness_buff) and ShadowCheckCdPostConditions() or BuffPresent(voidform_buff) and BuffPresent(surrender_to_madness_buff) and ShadowS2mCdPostConditions() or BuffPresent(voidform_buff) and ShadowVfCdPostConditions() or ShadowMainCdPostConditions()
}

### actions.check

AddFunction ShadowCheckMainActions
{
}

AddFunction ShadowCheckMainPostConditions
{
}

AddFunction ShadowCheckShortCdActions
{
}

AddFunction ShadowCheckShortCdPostConditions
{
}

AddFunction ShadowCheckCdActions
{
}

AddFunction ShadowCheckCdPostConditions
{
}

### actions.main

AddFunction ShadowMainMainActions
{
 #shadow_word_death,if=equipped.zeks_exterminatus&equipped.mangazas_madness&buff.zeks_exterminatus.react
 if HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) Spell(shadow_word_death)
 #shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd.max,moving=1,cycle_targets=1
 if Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() Spell(shadow_word_pain)
 #vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
 if Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } Spell(vampiric_touch)
 #shadow_word_pain,if=!talent.misery.enabled&dot.shadow_word_pain.remains<(3+(4%3))*gcd
 if not Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < { 3 + 4 / 3 } * GCD() Spell(shadow_word_pain)
 #vampiric_touch,if=!talent.misery.enabled&dot.vampiric_touch.remains<(4+(4%3))*gcd
 if not Talent(misery_talent) and target.DebuffRemaining(vampiric_touch_debuff) < { 4 + 4 / 3 } * GCD() Spell(vampiric_touch)
 #void_eruption,if=(talent.mindbender.enabled&cooldown.mindbender.remains<(variable.erupt_eval+gcd.max*4%3))|!talent.mindbender.enabled|set_bonus.tier20_4pc
 if Talent(mindbender_talent) and SpellCooldown(mindbender) < erupt_eval() + GCD() * 4 / 3 or not Talent(mindbender_talent) or ArmorSetBonus(T20 4) Spell(void_eruption)
 #shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2&insanity<=(85-15*talent.reaper_of_souls.enabled)|(equipped.zeks_exterminatus&buff.zeks_exterminatus.react)
 if { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 and Insanity() <= 85 - 15 * TalentPoints(reaper_of_souls_talent) or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) Spell(shadow_word_death)
 #mind_blast,if=active_enemies<=4&talent.legacy_of_the_void.enabled&(insanity<=81|(insanity<=75.2&talent.fortress_of_the_mind.enabled))
 if Enemies(tagged=1) <= 4 and Talent(legacy_of_the_void_talent) and { Insanity() <= 81 or Insanity() <= 75.2 and Talent(fortress_of_the_mind_talent) } Spell(mind_blast)
 #mind_blast,if=active_enemies<=4&!talent.legacy_of_the_void.enabled|(insanity<=96|(insanity<=95.2&talent.fortress_of_the_mind.enabled))
 if Enemies(tagged=1) <= 4 and not Talent(legacy_of_the_void_talent) or Insanity() <= 96 or Insanity() <= 95.2 and Talent(fortress_of_the_mind_talent) Spell(mind_blast)
 #shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
 if not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } Spell(shadow_word_pain)
 #vampiric_touch,if=active_enemies>1&!talent.misery.enabled&!ticking&(variable.dot_vt_dpgcd*target.time_to_die%(gcd.max*(156+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
 if Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 Spell(vampiric_touch)
 #shadow_word_pain,if=active_enemies>1&!talent.misery.enabled&!ticking&(variable.dot_swp_dpgcd*target.time_to_die%(gcd.max*(118+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
 if Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 Spell(shadow_word_pain)
 #shadow_word_void,if=talent.shadow_word_void.enabled&(insanity<=75-10*talent.legacy_of_the_void.enabled)
 if Talent(shadow_word_void_talent) and Insanity() <= 75 - 10 * TalentPoints(legacy_of_the_void_talent) Spell(shadow_word_void)
 #mind_flay,interrupt=1,chain=1
 Spell(mind_flay)
 #shadow_word_pain
 Spell(shadow_word_pain)
}

AddFunction ShadowMainMainPostConditions
{
}

AddFunction ShadowMainShortCdActions
{
 unless HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and Spell(vampiric_touch) or not Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < { 3 + 4 / 3 } * GCD() and Spell(shadow_word_pain) or not Talent(misery_talent) and target.DebuffRemaining(vampiric_touch_debuff) < { 4 + 4 / 3 } * GCD() and Spell(vampiric_touch) or { Talent(mindbender_talent) and SpellCooldown(mindbender) < erupt_eval() + GCD() * 4 / 3 or not Talent(mindbender_talent) or ArmorSetBonus(T20 4) } and Spell(void_eruption)
 {
  #shadow_crash,if=talent.shadow_crash.enabled
  if Talent(shadow_crash_talent) Spell(shadow_crash)
 }
}

AddFunction ShadowMainShortCdPostConditions
{
 HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and Spell(vampiric_touch) or not Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < { 3 + 4 / 3 } * GCD() and Spell(shadow_word_pain) or not Talent(misery_talent) and target.DebuffRemaining(vampiric_touch_debuff) < { 4 + 4 / 3 } * GCD() and Spell(vampiric_touch) or { Talent(mindbender_talent) and SpellCooldown(mindbender) < erupt_eval() + GCD() * 4 / 3 or not Talent(mindbender_talent) or ArmorSetBonus(T20 4) } and Spell(void_eruption) or { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 and Insanity() <= 85 - 15 * TalentPoints(reaper_of_souls_talent) or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) } and Spell(shadow_word_death) or Enemies(tagged=1) <= 4 and Talent(legacy_of_the_void_talent) and { Insanity() <= 81 or Insanity() <= 75.2 and Talent(fortress_of_the_mind_talent) } and Spell(mind_blast) or { Enemies(tagged=1) <= 4 and not Talent(legacy_of_the_void_talent) or Insanity() <= 96 or Insanity() <= 95.2 and Talent(fortress_of_the_mind_talent) } and Spell(mind_blast) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } and Spell(shadow_word_pain) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(shadow_word_pain) or Talent(shadow_word_void_talent) and Insanity() <= 75 - 10 * TalentPoints(legacy_of_the_void_talent) and Spell(shadow_word_void) or Spell(mind_flay) or Spell(shadow_word_pain)
}

AddFunction ShadowMainCdActions
{
 #surrender_to_madness,if=talent.surrender_to_madness.enabled&target.time_to_die<=variable.s2mcheck
 if Talent(surrender_to_madness_talent) and target.TimeToDie() <= s2mcheck() Spell(surrender_to_madness)
}

AddFunction ShadowMainCdPostConditions
{
 HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and Spell(vampiric_touch) or not Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < { 3 + 4 / 3 } * GCD() and Spell(shadow_word_pain) or not Talent(misery_talent) and target.DebuffRemaining(vampiric_touch_debuff) < { 4 + 4 / 3 } * GCD() and Spell(vampiric_touch) or { Talent(mindbender_talent) and SpellCooldown(mindbender) < erupt_eval() + GCD() * 4 / 3 or not Talent(mindbender_talent) or ArmorSetBonus(T20 4) } and Spell(void_eruption) or Talent(shadow_crash_talent) and Spell(shadow_crash) or { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 and Insanity() <= 85 - 15 * TalentPoints(reaper_of_souls_talent) or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) } and Spell(shadow_word_death) or Enemies(tagged=1) <= 4 and Talent(legacy_of_the_void_talent) and { Insanity() <= 81 or Insanity() <= 75.2 and Talent(fortress_of_the_mind_talent) } and Spell(mind_blast) or { Enemies(tagged=1) <= 4 and not Talent(legacy_of_the_void_talent) or Insanity() <= 96 or Insanity() <= 95.2 and Talent(fortress_of_the_mind_talent) } and Spell(mind_blast) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } and Spell(shadow_word_pain) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(shadow_word_pain) or Talent(shadow_word_void_talent) and Insanity() <= 75 - 10 * TalentPoints(legacy_of_the_void_talent) and Spell(shadow_word_void) or Spell(mind_flay) or Spell(shadow_word_pain)
}

### actions.precombat

AddFunction ShadowPrecombatMainActions
{
 #shadowform,if=!buff.shadowform.up
 if not BuffPresent(shadowform_buff) Spell(shadowform)
 #mind_blast
 Spell(mind_blast)
}

AddFunction ShadowPrecombatMainPostConditions
{
}

AddFunction ShadowPrecombatShortCdActions
{
}

AddFunction ShadowPrecombatShortCdPostConditions
{
 not BuffPresent(shadowform_buff) and Spell(shadowform) or Spell(mind_blast)
}

AddFunction ShadowPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #variable,name=haste_eval,op=set,value=(raw_haste_pct-0.3)*(10+10*equipped.mangazas_madness+5*talent.fortress_of_the_mind.enabled)
 #variable,name=haste_eval,op=max,value=0
 #variable,name=erupt_eval,op=set,value=26+1*talent.fortress_of_the_mind.enabled-4*talent.Sanlayn.enabled-3*talent.Shadowy_insight.enabled+variable.haste_eval*1.5
 #variable,name=cd_time,op=set,value=(12+(2-2*talent.mindbender.enabled*set_bonus.tier20_4pc)*set_bonus.tier19_2pc+(1-3*talent.mindbender.enabled*set_bonus.tier20_4pc)*equipped.mangazas_madness+(6+5*talent.mindbender.enabled)*set_bonus.tier20_4pc+2*artifact.lash_of_insanity.rank)
 #variable,name=dot_swp_dpgcd,op=set,value=36.5*1.2*(1+0.06*artifact.to_the_pain.rank)*(1+0.2+stat.mastery_rating%16000)*0.75
 #variable,name=dot_vt_dpgcd,op=set,value=68*1.2*(1+0.2*talent.sanlayn.enabled)*(1+0.05*artifact.touch_of_darkness.rank)*(1+0.2+stat.mastery_rating%16000)*0.5
 #variable,name=sear_dpgcd,op=set,value=120*1.2*(1+0.05*artifact.void_corruption.rank)
 #variable,name=s2msetup_time,op=set,value=(0.8*(83+(20+20*talent.fortress_of_the_mind.enabled)*set_bonus.tier20_4pc-(5*talent.sanlayn.enabled)+((33-13*set_bonus.tier20_4pc)*talent.reaper_of_souls.enabled)+set_bonus.tier19_2pc*4+8*equipped.mangazas_madness+(raw_haste_pct*10*(1+0.7*set_bonus.tier20_4pc))*(2+(0.8*set_bonus.tier19_2pc)+(1*talent.reaper_of_souls.enabled)+(2*artifact.mass_hysteria.rank)-(1*talent.sanlayn.enabled)))),if=talent.surrender_to_madness.enabled
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction ShadowPrecombatCdPostConditions
{
 not BuffPresent(shadowform_buff) and Spell(shadowform) or Spell(mind_blast)
}

### actions.s2m

AddFunction ShadowS2mMainActions
{
 #void_bolt,if=buff.insanity_drain_stacks.value<6&set_bonus.tier19_4pc
 if BuffAmount(insanity_drain_stacks_buff) < 6 and ArmorSetBonus(T19 4) Spell(void_bolt)
 #mindbender,if=cooldown.shadow_word_death.charges=0&buff.voidform.stack>(45+25*set_bonus.tier20_4pc)
 if SpellCharges(shadow_word_death) == 0 and BuffStacks(voidform_buff) > 45 + 25 * ArmorSetBonus(T20 4) Spell(mindbender)
 #void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&!buff.power_infusion.up|buff.voidform.stack<5
 if target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and not BuffPresent(power_infusion_buff) or BuffStacks(voidform_buff) < 5 Spell(void_torrent)
 #shadow_word_death,if=current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(30+30*talent.reaper_of_souls.enabled)<100)
 if CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 Spell(shadow_word_death)
 #void_bolt
 Spell(void_bolt)
 #shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(30+30*talent.reaper_of_souls.enabled))<100
 if { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 Spell(shadow_word_death)
 #wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
 unless SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0
 {
  #mind_blast,if=active_enemies<=5
  if Enemies(tagged=1) <= 5 Spell(mind_blast)
  #wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=5
  unless SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 5 and SpellCooldown(mind_blast) > 0
  {
   #shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2
   if { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 Spell(shadow_word_death)
   #shadowfiend,if=!talent.mindbender.enabled&buff.voidform.stack>15
   if not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 Spell(shadowfiend)
   #shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+50)<100
   if Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 50 < 100 Spell(shadow_word_void)
   #shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
   if Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() Spell(shadow_word_pain)
   #vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max),cycle_targets=1
   if Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } Spell(vampiric_touch)
   #shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
   if not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } Spell(shadow_word_pain)
   #vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
   if not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } Spell(vampiric_touch)
   #shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&(talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled)),cycle_targets=1
   if not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } Spell(shadow_word_pain)
   #vampiric_touch,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank)),cycle_targets=1
   if not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and target.TimeToDie() > 10 and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } Spell(vampiric_touch)
   #shadow_word_pain,if=!talent.misery.enabled&!ticking&target.time_to_die>10&(active_enemies<5&artifact.sphere_of_insanity.rank),cycle_targets=1
   if not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and ArtifactTraitRank(sphere_of_insanity) Spell(shadow_word_pain)
   #mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+60)<100&cooldown.shadow_word_death.charges>=1))
   Spell(mind_flay)
  }
 }
}

AddFunction ShadowS2mMainPostConditions
{
}

AddFunction ShadowS2mShortCdActions
{
 unless BuffAmount(insanity_drain_stacks_buff) < 6 and ArmorSetBonus(T19 4) and Spell(void_bolt)
 {
  #shadow_crash,if=talent.shadow_crash.enabled
  if Talent(shadow_crash_talent) Spell(shadow_crash)
 }
}

AddFunction ShadowS2mShortCdPostConditions
{
 BuffAmount(insanity_drain_stacks_buff) < 6 and ArmorSetBonus(T19 4) and Spell(void_bolt) or SpellCharges(shadow_word_death) == 0 and BuffStacks(voidform_buff) > 45 + 25 * ArmorSetBonus(T20 4) and Spell(mindbender) or { target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and not BuffPresent(power_infusion_buff) or BuffStacks(voidform_buff) < 5 } and Spell(void_torrent) or CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or Spell(void_bolt) or { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or not { SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0 } and { Enemies(tagged=1) <= 5 and Spell(mind_blast) or not { SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 5 and SpellCooldown(mind_blast) > 0 } and { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 and Spell(shadow_word_death) or not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 and Spell(shadowfiend) or Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 50 < 100 and Spell(shadow_word_void) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and target.TimeToDie() > 10 and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and ArtifactTraitRank(sphere_of_insanity) and Spell(shadow_word_pain) or Spell(mind_flay) } }
}

AddFunction ShadowS2mCdActions
{
 #silence,if=equipped.sephuzs_secret&(target.is_add|target.debuff.casting.react)&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up,cycle_targets=1
 # if HasEquippedItem(sephuzs_secret) and { not target.Classification(worldboss) or target.IsInterruptible() } and not SpellCooldown(buff_sephuzs_secret) > 0 and not BuffPresent(sephuzs_secret_buff) ShadowInterruptActions()

 unless BuffAmount(insanity_drain_stacks_buff) < 6 and ArmorSetBonus(T19 4) and Spell(void_bolt)
 {
  #mind_bomb,if=equipped.sephuzs_secret&target.is_add&cooldown.buff_sephuzs_secret.remains<1&!buff.sephuzs_secret.up,cycle_targets=1
  # if HasEquippedItem(sephuzs_secret) and not target.Classification(worldboss) and BuffCooldown(sephuzs_secret_buff) < 1 and not BuffPresent(sephuzs_secret_buff) ShadowInterruptActions()

  unless Talent(shadow_crash_talent) and Spell(shadow_crash) or SpellCharges(shadow_word_death) == 0 and BuffStacks(voidform_buff) > 45 + 25 * ArmorSetBonus(T20 4) and Spell(mindbender) or { target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and not BuffPresent(power_infusion_buff) or BuffStacks(voidform_buff) < 5 } and Spell(void_torrent)
  {
   #berserking,if=buff.voidform.stack>=65
   if BuffStacks(voidform_buff) >= 65 Spell(berserking)

   unless CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death)
   {
    #power_infusion,if=cooldown.shadow_word_death.charges=0&buff.voidform.stack>(45+25*set_bonus.tier20_4pc)|target.time_to_die<=30
    if SpellCharges(shadow_word_death) == 0 and BuffStacks(voidform_buff) > 45 + 25 * ArmorSetBonus(T20 4) or target.TimeToDie() <= 30 Spell(power_infusion)

    unless Spell(void_bolt) or { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death)
    {
     #wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
     unless SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0
     {
      #dispersion,if=current_insanity_drain*gcd.max>insanity&!buff.power_infusion.up|(buff.voidform.stack>76&cooldown.shadow_word_death.charges=0&current_insanity_drain*gcd.max>insanity)
      if CurrentInsanityDrain() * GCD() > Insanity() and not BuffPresent(power_infusion_buff) or BuffStacks(voidform_buff) > 76 and SpellCharges(shadow_word_death) == 0 and CurrentInsanityDrain() * GCD() > Insanity() Spell(dispersion)
     }
    }
   }
  }
 }
}

AddFunction ShadowS2mCdPostConditions
{
 BuffAmount(insanity_drain_stacks_buff) < 6 and ArmorSetBonus(T19 4) and Spell(void_bolt) or Talent(shadow_crash_talent) and Spell(shadow_crash) or SpellCharges(shadow_word_death) == 0 and BuffStacks(voidform_buff) > 45 + 25 * ArmorSetBonus(T20 4) and Spell(mindbender) or { target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and not BuffPresent(power_infusion_buff) or BuffStacks(voidform_buff) < 5 } and Spell(void_torrent) or CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or Spell(void_bolt) or { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 30 + 30 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or not { SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0 } and { Enemies(tagged=1) <= 5 and Spell(mind_blast) or not { SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 5 and SpellCooldown(mind_blast) > 0 } and { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 and Spell(shadow_word_death) or not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 and Spell(shadowfiend) or Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 50 < 100 and Spell(shadow_word_void) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and { Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and target.TimeToDie() > 10 and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and target.TimeToDie() > 10 and Enemies(tagged=1) < 5 and ArtifactTraitRank(sphere_of_insanity) and Spell(shadow_word_pain) or Spell(mind_flay) } }
}

### actions.vf

AddFunction ShadowVfMainActions
{
 #void_bolt
 Spell(void_bolt)
 #shadow_word_death,if=equipped.zeks_exterminatus&equipped.mangazas_madness&buff.zeks_exterminatus.react
 if HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) Spell(shadow_word_death)
 #void_torrent,if=dot.shadow_word_pain.remains>5.5&dot.vampiric_touch.remains>5.5&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+60))
 if target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 60 } Spell(void_torrent)
 #mindbender,if=buff.insanity_drain_stacks.value>=(variable.cd_time+(variable.haste_eval*!set_bonus.tier20_4pc)-(3*set_bonus.tier20_4pc*(raid_event.movement.in<15)*((active_enemies-(raid_event.adds.count*(raid_event.adds.remains>0)))=1))+(5-3*set_bonus.tier20_4pc)*buff.bloodlust.up+2*talent.fortress_of_the_mind.enabled*set_bonus.tier20_4pc)&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-buff.insanity_drain_stacks.value))
 if BuffAmount(insanity_drain_stacks_buff) >= cd_time() + haste_eval() * { not ArmorSetBonus(T20 4) } - 3 * ArmorSetBonus(T20 4) * { 600 < 15 } * { Enemies(tagged=1) - 0 * { 0 > 0 } == 1 } + { 5 - 3 * ArmorSetBonus(T20 4) } * BuffPresent(burst_haste_buff any=1) + 2 * TalentPoints(fortress_of_the_mind_talent) * ArmorSetBonus(T20 4) and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) } Spell(mindbender)
 #shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+(15+15*talent.reaper_of_souls.enabled))<100
 if { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 15 + 15 * TalentPoints(reaper_of_souls_talent) < 100 Spell(shadow_word_death)
 #wait,sec=action.void_bolt.usable_in,if=action.void_bolt.usable_in<gcd.max*0.28
 unless SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0
 {
  #mind_blast,if=active_enemies<=4
  if Enemies(tagged=1) <= 4 Spell(mind_blast)
  #wait,sec=action.mind_blast.usable_in,if=action.mind_blast.usable_in<gcd.max*0.28&active_enemies<=4
  unless SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 4 and SpellCooldown(mind_blast) > 0
  {
   #shadow_word_death,if=(active_enemies<=4|(talent.reaper_of_souls.enabled&active_enemies<=2))&cooldown.shadow_word_death.charges=2|(equipped.zeks_exterminatus&buff.zeks_exterminatus.react)
   if { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) Spell(shadow_word_death)
   #shadowfiend,if=!talent.mindbender.enabled&buff.voidform.stack>15
   if not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 Spell(shadowfiend)
   #shadow_word_void,if=talent.shadow_word_void.enabled&(insanity-(current_insanity_drain*gcd.max)+25)<100
   if Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 25 < 100 Spell(shadow_word_void)
   #shadow_word_pain,if=talent.misery.enabled&dot.shadow_word_pain.remains<gcd,moving=1,cycle_targets=1
   if Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() Spell(shadow_word_pain)
   #vampiric_touch,if=talent.misery.enabled&(dot.vampiric_touch.remains<3*gcd.max|dot.shadow_word_pain.remains<3*gcd.max)&target.time_to_die>5*gcd.max,cycle_targets=1
   if Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and target.TimeToDie() > 5 * GCD() Spell(vampiric_touch)
   #shadow_word_pain,if=!talent.misery.enabled&!ticking&(active_enemies<5|talent.auspicious_spirits.enabled|talent.shadowy_insight.enabled|artifact.sphere_of_insanity.rank)
   if not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } Spell(shadow_word_pain)
   #vampiric_touch,if=!talent.misery.enabled&!ticking&(active_enemies<4|talent.sanlayn.enabled|(talent.auspicious_spirits.enabled&artifact.unleash_the_shadows.rank))
   if not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } Spell(vampiric_touch)
   #vampiric_touch,if=active_enemies>1&!talent.misery.enabled&!ticking&((1+0.02*buff.voidform.stack)*variable.dot_vt_dpgcd*target.time_to_die%(gcd.max*(156+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
   if Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 Spell(vampiric_touch)
   #shadow_word_pain,if=active_enemies>1&!talent.misery.enabled&!ticking&((1+0.02*buff.voidform.stack)*variable.dot_swp_dpgcd*target.time_to_die%(gcd.max*(118+variable.sear_dpgcd*(active_enemies-1))))>1,cycle_targets=1
   if Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 Spell(shadow_word_pain)
   #mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(action.void_bolt.usable|(current_insanity_drain*gcd.max>insanity&(insanity-(current_insanity_drain*gcd.max)+30)<100&cooldown.shadow_word_death.charges>=1))
   Spell(mind_flay)
   #shadow_word_pain
   Spell(shadow_word_pain)
  }
 }
}

AddFunction ShadowVfMainPostConditions
{
}

AddFunction ShadowVfShortCdActions
{
 unless Spell(void_bolt) or HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death)
 {
  #shadow_crash,if=talent.shadow_crash.enabled
  if Talent(shadow_crash_talent) Spell(shadow_crash)
 }
}

AddFunction ShadowVfShortCdPostConditions
{
 Spell(void_bolt) or HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death) or target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 60 } and Spell(void_torrent) or BuffAmount(insanity_drain_stacks_buff) >= cd_time() + haste_eval() * { not ArmorSetBonus(T20 4) } - 3 * ArmorSetBonus(T20 4) * { 600 < 15 } * { Enemies(tagged=1) - 0 * { 0 > 0 } == 1 } + { 5 - 3 * ArmorSetBonus(T20 4) } * BuffPresent(burst_haste_buff any=1) + 2 * TalentPoints(fortress_of_the_mind_talent) * ArmorSetBonus(T20 4) and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) } and Spell(mindbender) or { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 15 + 15 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or not { SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0 } and { Enemies(tagged=1) <= 4 and Spell(mind_blast) or not { SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 4 and SpellCooldown(mind_blast) > 0 } and { { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) } and Spell(shadow_word_death) or not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 and Spell(shadowfiend) or Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 25 < 100 and Spell(shadow_word_void) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and target.TimeToDie() > 5 * GCD() and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(shadow_word_pain) or Spell(mind_flay) or Spell(shadow_word_pain) } }
}

AddFunction ShadowVfCdActions
{
 #surrender_to_madness,if=talent.surrender_to_madness.enabled&insanity>=25&(cooldown.void_bolt.up|cooldown.void_torrent.up|cooldown.shadow_word_death.up|buff.shadowy_insight.up)&target.time_to_die<=variable.s2mcheck-(buff.insanity_drain_stacks.value)
 if Talent(surrender_to_madness_talent) and Insanity() >= 25 and { not SpellCooldown(void_bolt) > 0 or not SpellCooldown(void_torrent) > 0 or not SpellCooldown(shadow_word_death) > 0 or BuffPresent(shadowy_insight_buff) } and target.TimeToDie() <= s2mcheck() - BuffAmount(insanity_drain_stacks_buff) Spell(surrender_to_madness)
 #silence,if=equipped.sephuzs_secret&(target.is_add|target.debuff.casting.react)&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up&buff.insanity_drain_stacks.value>10,cycle_targets=1
 # if HasEquippedItem(sephuzs_secret) and { not target.Classification(worldboss) or target.IsInterruptible() } and not SpellCooldown(buff_sephuzs_secret) > 0 and not BuffPresent(sephuzs_secret_buff) and BuffAmount(insanity_drain_stacks_buff) > 10 ShadowInterruptActions()

 unless Spell(void_bolt) or HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death)
 {
  #mind_bomb,if=equipped.sephuzs_secret&target.is_add&cooldown.buff_sephuzs_secret.remains<1&!buff.sephuzs_secret.up&buff.insanity_drain_stacks.value>10,cycle_targets=1
  # if HasEquippedItem(sephuzs_secret) and not target.Classification(worldboss) and BuffCooldown(sephuzs_secret_buff) < 1 and not BuffPresent(sephuzs_secret_buff) and BuffAmount(insanity_drain_stacks_buff) > 10 ShadowInterruptActions()

  unless Talent(shadow_crash_talent) and Spell(shadow_crash) or target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 60 } and Spell(void_torrent) or BuffAmount(insanity_drain_stacks_buff) >= cd_time() + haste_eval() * { not ArmorSetBonus(T20 4) } - 3 * ArmorSetBonus(T20 4) * { 600 < 15 } * { Enemies(tagged=1) - 0 * { 0 > 0 } == 1 } + { 5 - 3 * ArmorSetBonus(T20 4) } * BuffPresent(burst_haste_buff any=1) + 2 * TalentPoints(fortress_of_the_mind_talent) * ArmorSetBonus(T20 4) and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) } and Spell(mindbender)
  {
   #power_infusion,if=buff.insanity_drain_stacks.value>=(variable.cd_time+5*buff.bloodlust.up*(1+1*set_bonus.tier20_4pc))&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+61))
   if BuffAmount(insanity_drain_stacks_buff) >= cd_time() + 5 * BuffPresent(burst_haste_buff any=1) * { 1 + 1 * ArmorSetBonus(T20 4) } and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 61 } Spell(power_infusion)
   #berserking,if=buff.voidform.stack>=10&buff.insanity_drain_stacks.value<=20&(!talent.surrender_to_madness.enabled|(talent.surrender_to_madness.enabled&target.time_to_die>variable.s2mcheck-(buff.insanity_drain_stacks.value)+60))
   if BuffStacks(voidform_buff) >= 10 and BuffAmount(insanity_drain_stacks_buff) <= 20 and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 60 } Spell(berserking)
  }
 }
}

AddFunction ShadowVfCdPostConditions
{
 Spell(void_bolt) or HasEquippedItem(zeks_exterminatus) and HasEquippedItem(mangazas_madness) and BuffPresent(zeks_exterminatus_buff) and Spell(shadow_word_death) or Talent(shadow_crash_talent) and Spell(shadow_crash) or target.DebuffRemaining(shadow_word_pain_debuff) > 5.5 and target.DebuffRemaining(vampiric_touch_debuff) > 5.5 and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) + 60 } and Spell(void_torrent) or BuffAmount(insanity_drain_stacks_buff) >= cd_time() + haste_eval() * { not ArmorSetBonus(T20 4) } - 3 * ArmorSetBonus(T20 4) * { 600 < 15 } * { Enemies(tagged=1) - 0 * { 0 > 0 } == 1 } + { 5 - 3 * ArmorSetBonus(T20 4) } * BuffPresent(burst_haste_buff any=1) + 2 * TalentPoints(fortress_of_the_mind_talent) * ArmorSetBonus(T20 4) and { not Talent(surrender_to_madness_talent) or Talent(surrender_to_madness_talent) and target.TimeToDie() > s2mcheck() - BuffAmount(insanity_drain_stacks_buff) } and Spell(mindbender) or { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and CurrentInsanityDrain() * GCD() > Insanity() and Insanity() - CurrentInsanityDrain() * GCD() + 15 + 15 * TalentPoints(reaper_of_souls_talent) < 100 and Spell(shadow_word_death) or not { SpellCooldown(void_bolt) < GCD() * 0.28 and SpellCooldown(void_bolt) > 0 } and { Enemies(tagged=1) <= 4 and Spell(mind_blast) or not { SpellCooldown(mind_blast) < GCD() * 0.28 and Enemies(tagged=1) <= 4 and SpellCooldown(mind_blast) > 0 } and { { { Enemies(tagged=1) <= 4 or Talent(reaper_of_souls_talent) and Enemies(tagged=1) <= 2 } and SpellCharges(shadow_word_death) == 2 or HasEquippedItem(zeks_exterminatus) and BuffPresent(zeks_exterminatus_buff) } and Spell(shadow_word_death) or not Talent(mindbender_talent) and BuffStacks(voidform_buff) > 15 and Spell(shadowfiend) or Talent(shadow_word_void_talent) and Insanity() - CurrentInsanityDrain() * GCD() + 25 < 100 and Spell(shadow_word_void) or Speed() > 0 and Talent(misery_talent) and target.DebuffRemaining(shadow_word_pain_debuff) < GCD() and Spell(shadow_word_pain) or Talent(misery_talent) and { target.DebuffRemaining(vampiric_touch_debuff) < 3 * GCD() or target.DebuffRemaining(shadow_word_pain_debuff) < 3 * GCD() } and target.TimeToDie() > 5 * GCD() and Spell(vampiric_touch) or not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { Enemies(tagged=1) < 5 or Talent(auspicious_spirits_talent) or Talent(shadowy_insight_talent) or ArtifactTraitRank(sphere_of_insanity) } and Spell(shadow_word_pain) or not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { Enemies(tagged=1) < 4 or Talent(sanlayn_talent) or Talent(auspicious_spirits_talent) and ArtifactTraitRank(unleash_the_shadows) } and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(vampiric_touch_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_vt_dpgcd() * target.TimeToDie() / { GCD() * { 156 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(vampiric_touch) or Enemies(tagged=1) > 1 and not Talent(misery_talent) and not target.DebuffPresent(shadow_word_pain_debuff) and { 1 + 0.02 * BuffStacks(voidform_buff) } * dot_swp_dpgcd() * target.TimeToDie() / { GCD() * { 118 + sear_dpgcd() * { Enemies(tagged=1) - 1 } } } > 1 and Spell(shadow_word_pain) or Spell(mind_flay) or Spell(shadow_word_pain) } }
}
]]

	OvaleScripts:RegisterScript("PRIEST", "shadow", name, desc, code, "script")
end
