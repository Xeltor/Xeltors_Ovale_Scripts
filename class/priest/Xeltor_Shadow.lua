local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_shadow"
	local desc = "[Xel][8.0] Priest: Shadow"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_priest_spells)

AddIcon specialization=3 help=main
{
	if not mounted() and not PlayerIsResting()
	{
		if BuffExpires(power_word_fortitude_buff) and { not target.Present() or not target.IsFriend() } Spell(power_word_fortitude)
		#shadowform,if=!buff.shadowform.up
		if not BuffPresent(shadowform_buff) Spell(shadowform)
	}
	
	if InCombat() InterruptActions()
	
	if InCombat() and HasFullControl() and target.InRange(mind_blast)
	{
		if Speed() == 0 or CanMove() > 0
		{
			if Boss() ShadowDefaultCdActions()
			ShadowDefaultShortCdActions()
			ShadowDefaultMainActions()
		}
		
		if Speed() > 0
		{
			#shadow_word_pain,moving=1,cycle_targets=1
			if target.DebuffExpires(shadow_word_pain_debuff) Spell(shadow_word_pain)
		}
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
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

AddFunction ShadowInterruptActions
{
 if not target.IsFriend() and target.Casting()
 {
  if target.InRange(silence) and target.IsInterruptible() Spell(silence)
  if target.InRange(mind_bomb) and not target.Classification(worldboss) and target.RemainingCastTime() > 2 Spell(mind_bomb)
  if target.Distance(less 8) and target.IsInterruptible() Spell(arcane_torrent_mana)
  if target.InRange(quaking_palm) and not target.Classification(worldboss) Spell(quaking_palm)
  if target.Distance(less 5) and not target.Classification(worldboss) Spell(war_stomp)
 }
}

### actions.default

AddFunction ShadowDefaultMainActions
{
 #run_action_list,name=aoe,if=spell_targets.mind_sear>(5+1*talent.misery.enabled)
 if Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) ShadowAoeMainActions()

 unless Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeMainPostConditions()
 {
  #run_action_list,name=cleave,if=active_enemies>1
  if Enemies(tagged=1) > 1 ShadowCleaveMainActions()

  unless Enemies(tagged=1) > 1 and ShadowCleaveMainPostConditions()
  {
   #run_action_list,name=single,if=active_enemies=1
   if Enemies(tagged=1) == 1 ShadowSingleMainActions()
  }
 }
}

AddFunction ShadowDefaultMainPostConditions
{
 Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeMainPostConditions() or Enemies(tagged=1) > 1 and ShadowCleaveMainPostConditions() or Enemies(tagged=1) == 1 and ShadowSingleMainPostConditions()
}

AddFunction ShadowDefaultShortCdActions
{
 #run_action_list,name=aoe,if=spell_targets.mind_sear>(5+1*talent.misery.enabled)
 if Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) ShadowAoeShortCdActions()

 unless Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeShortCdPostConditions()
 {
  #run_action_list,name=cleave,if=active_enemies>1
  if Enemies(tagged=1) > 1 ShadowCleaveShortCdActions()

  unless Enemies(tagged=1) > 1 and ShadowCleaveShortCdPostConditions()
  {
   #run_action_list,name=single,if=active_enemies=1
   if Enemies(tagged=1) == 1 ShadowSingleShortCdActions()
  }
 }
}

AddFunction ShadowDefaultShortCdPostConditions
{
 Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeShortCdPostConditions() or Enemies(tagged=1) > 1 and ShadowCleaveShortCdPostConditions() or Enemies(tagged=1) == 1 and ShadowSingleShortCdPostConditions()
}

AddFunction ShadowDefaultCdActions
{
 #potion,if=buff.bloodlust.react|target.time_to_die<=80|target.health.pct<35
 # if { BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 80 or target.HealthPercent() < 35 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
 #berserking
 Spell(berserking)
 #run_action_list,name=aoe,if=spell_targets.mind_sear>(5+1*talent.misery.enabled)
 if Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) ShadowAoeCdActions()

 unless Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeCdPostConditions()
 {
  #run_action_list,name=cleave,if=active_enemies>1
  if Enemies(tagged=1) > 1 ShadowCleaveCdActions()

  unless Enemies(tagged=1) > 1 and ShadowCleaveCdPostConditions()
  {
   #run_action_list,name=single,if=active_enemies=1
   if Enemies(tagged=1) == 1 ShadowSingleCdActions()
  }
 }
}

AddFunction ShadowDefaultCdPostConditions
{
 Enemies(tagged=1) > 5 + 1 * TalentPoints(misery_talent) and ShadowAoeCdPostConditions() or Enemies(tagged=1) > 1 and ShadowCleaveCdPostConditions() or Enemies(tagged=1) == 1 and ShadowSingleCdPostConditions()
}

### actions.aoe

AddFunction ShadowAoeMainActions
{
 #void_eruption
 Spell(void_eruption)
 #void_bolt,if=talent.dark_void.enabled&dot.shadow_word_pain.remains>travel_time
 if Talent(dark_void_talent) and target.DebuffRemaining(shadow_word_pain_debuff) > TravelTime(void_bolt) Spell(void_bolt)
 #mindbender
 Spell(mindbender)
 #mind_sear,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
 Spell(mind_sear)
 #shadow_word_pain
 Spell(shadow_word_pain)
}

AddFunction ShadowAoeMainPostConditions
{
}

AddFunction ShadowAoeShortCdActions
{
 unless Spell(void_eruption)
 {
  #dark_ascension,if=buff.voidform.down
  if BuffExpires(voidform_buff) Spell(dark_ascension)

  unless Talent(dark_void_talent) and target.DebuffRemaining(shadow_word_pain_debuff) > TravelTime(void_bolt) and Spell(void_bolt)
  {
   #dark_void,if=raid_event.adds.in>10
   if 600 > 10 Spell(dark_void)

   unless Spell(mindbender)
   {
    #shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if 600 > 5 and 10 < 20 Spell(shadow_crash)
   }
  }
 }
}

AddFunction ShadowAoeShortCdPostConditions
{
 Spell(void_eruption) or Talent(dark_void_talent) and target.DebuffRemaining(shadow_word_pain_debuff) > TravelTime(void_bolt) and Spell(void_bolt) or Spell(mindbender) or Spell(mind_sear) or Spell(shadow_word_pain)
}

AddFunction ShadowAoeCdActions
{
 unless Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Talent(dark_void_talent) and target.DebuffRemaining(shadow_word_pain_debuff) > TravelTime(void_bolt) and Spell(void_bolt)
 {
  #surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
  if BuffStacks(voidform_buff) >= 15 + BuffPresent(burst_haste_buff any=1) Spell(surrender_to_madness)
 }
}

AddFunction ShadowAoeCdPostConditions
{
 Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Talent(dark_void_talent) and target.DebuffRemaining(shadow_word_pain_debuff) > TravelTime(void_bolt) and Spell(void_bolt) or 600 > 10 and Spell(dark_void) or Spell(mindbender) or 600 > 5 and 10 < 20 and Spell(shadow_crash) or Spell(mind_sear) or Spell(shadow_word_pain)
}

### actions.cleave

AddFunction ShadowCleaveMainActions
{
 #void_eruption
 Spell(void_eruption)
 #void_bolt
 Spell(void_bolt)
 #shadow_word_death,target_if=target.time_to_die<3|buff.voidform.down
 if target.TimeToDie() < 3 or BuffExpires(voidform_buff) Spell(shadow_word_death)
 #mindbender
 Spell(mindbender)
 #mind_blast
 Spell(mind_blast)
 #shadow_word_pain,target_if=refreshable&target.time_to_die>4,if=!talent.misery.enabled&!talent.dark_void.enabled
 if not Talent(misery_talent) and not Talent(dark_void_talent) and target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 Spell(shadow_word_pain)
 #vampiric_touch,target_if=refreshable,if=(target.time_to_die>6)
 if target.TimeToDie() > 6 and target.Refreshable(vampiric_touch_debuff) Spell(vampiric_touch)
 #vampiric_touch,target_if=dot.shadow_word_pain.refreshable,if=(talent.misery.enabled&target.time_to_die>4)
 if Talent(misery_talent) and target.TimeToDie() > 4 and target.DebuffRefreshable(shadow_word_pain_debuff) Spell(vampiric_touch)
 #void_torrent
 Spell(void_torrent)
 #mind_sear,target_if=spell_targets.mind_sear>2,chain=1,interrupt=1
 if Enemies(tagged=1) > 2 Spell(mind_sear)
 #mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
 Spell(mind_flay)
 #shadow_word_pain
 Spell(shadow_word_pain)
}

AddFunction ShadowCleaveMainPostConditions
{
}

AddFunction ShadowCleaveShortCdActions
{
 unless Spell(void_eruption)
 {
  #dark_ascension,if=buff.voidform.down
  if BuffExpires(voidform_buff) Spell(dark_ascension)

  unless Spell(void_bolt) or { target.TimeToDie() < 3 or BuffExpires(voidform_buff) } and Spell(shadow_word_death)
  {
   #dark_void,if=raid_event.adds.in>10
   if 600 > 10 Spell(dark_void)

   unless Spell(mindbender) or Spell(mind_blast)
   {
    #shadow_crash,if=(raid_event.adds.in>5&raid_event.adds.duration<2)|raid_event.adds.duration>2
    if 600 > 5 and 10 < 2 or 10 > 2 Spell(shadow_crash)
   }
  }
 }
}

AddFunction ShadowCleaveShortCdPostConditions
{
 Spell(void_eruption) or Spell(void_bolt) or { target.TimeToDie() < 3 or BuffExpires(voidform_buff) } and Spell(shadow_word_death) or Spell(mindbender) or Spell(mind_blast) or not Talent(misery_talent) and not Talent(dark_void_talent) and target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 and Spell(shadow_word_pain) or target.TimeToDie() > 6 and target.Refreshable(vampiric_touch_debuff) and Spell(vampiric_touch) or Talent(misery_talent) and target.TimeToDie() > 4 and target.DebuffRefreshable(shadow_word_pain_debuff) and Spell(vampiric_touch) or Spell(void_torrent) or Enemies(tagged=1) > 2 and Spell(mind_sear) or Spell(mind_flay) or Spell(shadow_word_pain)
}

AddFunction ShadowCleaveCdActions
{
 unless Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Spell(void_bolt) or { target.TimeToDie() < 3 or BuffExpires(voidform_buff) } and Spell(shadow_word_death)
 {
  #surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)
  if BuffStacks(voidform_buff) >= 15 + BuffPresent(burst_haste_buff any=1) Spell(surrender_to_madness)
 }
}

AddFunction ShadowCleaveCdPostConditions
{
 Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Spell(void_bolt) or { target.TimeToDie() < 3 or BuffExpires(voidform_buff) } and Spell(shadow_word_death) or 600 > 10 and Spell(dark_void) or Spell(mindbender) or Spell(mind_blast) or { 600 > 5 and 10 < 2 or 10 > 2 } and Spell(shadow_crash) or not Talent(misery_talent) and not Talent(dark_void_talent) and target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 and Spell(shadow_word_pain) or target.TimeToDie() > 6 and target.Refreshable(vampiric_touch_debuff) and Spell(vampiric_touch) or Talent(misery_talent) and target.TimeToDie() > 4 and target.DebuffRefreshable(shadow_word_pain_debuff) and Spell(vampiric_touch) or Spell(void_torrent) or Enemies(tagged=1) > 2 and Spell(mind_sear) or Spell(mind_flay) or Spell(shadow_word_pain)
}

### actions.precombat

AddFunction ShadowPrecombatMainActions
{
 #shadowform,if=!buff.shadowform.up
 if not BuffPresent(shadowform_buff) Spell(shadowform)
 #mind_blast
 Spell(mind_blast)
 #shadow_word_void
 Spell(shadow_word_void)
}

AddFunction ShadowPrecombatMainPostConditions
{
}

AddFunction ShadowPrecombatShortCdActions
{
}

AddFunction ShadowPrecombatShortCdPostConditions
{
 not BuffPresent(shadowform_buff) and Spell(shadowform) or Spell(mind_blast) or Spell(shadow_word_void)
}

AddFunction ShadowPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(battle_potion_of_intellect usable=1)
}

AddFunction ShadowPrecombatCdPostConditions
{
 not BuffPresent(shadowform_buff) and Spell(shadowform) or Spell(mind_blast) or Spell(shadow_word_void)
}

### actions.single

AddFunction ShadowSingleMainActions
{
 #void_eruption
 Spell(void_eruption)
 #void_bolt
 Spell(void_bolt)
 #shadow_word_death,if=target.time_to_die<3|cooldown.shadow_word_death.charges=2
 if target.TimeToDie() < 3 or SpellCharges(shadow_word_death) == 2 Spell(shadow_word_death)
 #mindbender
 Spell(mindbender)
 #vampiric_touch,if=((dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking)|(talent.shadow_word_void.enabled&cooldown.shadow_word_void.charges=2))&azerite.thought_harvester.rank>1&cooldown.mind_blast.up&buff.harvested_thoughts.down
 if { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) > 1 and not SpellCooldown(mind_blast) > 0 and BuffExpires(harvested_thoughts_buff) Spell(vampiric_touch)
 #mind_blast,if=((dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking)|(talent.shadow_word_void.enabled&cooldown.shadow_word_void.charges=2))&azerite.thought_harvester.rank<2
 if { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) < 2 Spell(mind_blast)
 #mind_blast,if=(prev_gcd.1.vampiric_touch|buff.harvested_thoughts.up)&azerite.thought_harvester.rank>1
 if { PreviousGCDSpell(vampiric_touch) or BuffPresent(harvested_thoughts_buff) } and AzeriteTraitRank(thought_harvester_trait) > 1 Spell(mind_blast)
 #shadow_word_death,if=!buff.voidform.up|(cooldown.shadow_word_death.charges=2&buff.voidform.stack<15)
 if not BuffPresent(voidform_buff) or SpellCharges(shadow_word_death) == 2 and BuffStacks(voidform_buff) < 15 Spell(shadow_word_death)
 #mind_blast,if=dot.shadow_word_pain.ticking&dot.vampiric_touch.ticking
 if target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) Spell(mind_blast)
 #void_torrent,if=dot.shadow_word_pain.remains>4&dot.vampiric_touch.remains>4
 if target.DebuffRemaining(shadow_word_pain_debuff) > 4 and target.DebuffRemaining(vampiric_touch_debuff) > 4 Spell(void_torrent)
 #shadow_word_pain,if=refreshable&target.time_to_die>4&!talent.misery.enabled&!talent.dark_void.enabled
 if target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 and not Talent(misery_talent) and not Talent(dark_void_talent) Spell(shadow_word_pain)
 #vampiric_touch,if=refreshable&target.time_to_die>6|(talent.misery.enabled&dot.shadow_word_pain.refreshable)
 if target.Refreshable(vampiric_touch_debuff) and target.TimeToDie() > 6 or Talent(misery_talent) and target.DebuffRefreshable(shadow_word_pain_debuff) Spell(vampiric_touch)
 #mind_flay,chain=1,interrupt_immediate=1,interrupt_if=ticks>=2&(cooldown.void_bolt.up|cooldown.mind_blast.up)
 Spell(mind_flay)
 #shadow_word_pain
 Spell(shadow_word_pain)
}

AddFunction ShadowSingleMainPostConditions
{
}

AddFunction ShadowSingleShortCdActions
{
 unless Spell(void_eruption)
 {
  #dark_ascension,if=buff.voidform.down
  if BuffExpires(voidform_buff) Spell(dark_ascension)

  unless Spell(void_bolt) or { target.TimeToDie() < 3 or SpellCharges(shadow_word_death) == 2 } and Spell(shadow_word_death)
  {
   #dark_void,if=raid_event.adds.in>10
   if 600 > 10 Spell(dark_void)

   unless Spell(mindbender) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) > 1 and not SpellCooldown(mind_blast) > 0 and BuffExpires(harvested_thoughts_buff) and Spell(vampiric_touch) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) < 2 and Spell(mind_blast) or { PreviousGCDSpell(vampiric_touch) or BuffPresent(harvested_thoughts_buff) } and AzeriteTraitRank(thought_harvester_trait) > 1 and Spell(mind_blast) or { not BuffPresent(voidform_buff) or SpellCharges(shadow_word_death) == 2 and BuffStacks(voidform_buff) < 15 } and Spell(shadow_word_death)
   {
    #shadow_crash,if=raid_event.adds.in>5&raid_event.adds.duration<20
    if 600 > 5 and 10 < 20 Spell(shadow_crash)
   }
  }
 }
}

AddFunction ShadowSingleShortCdPostConditions
{
 Spell(void_eruption) or Spell(void_bolt) or { target.TimeToDie() < 3 or SpellCharges(shadow_word_death) == 2 } and Spell(shadow_word_death) or Spell(mindbender) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) > 1 and not SpellCooldown(mind_blast) > 0 and BuffExpires(harvested_thoughts_buff) and Spell(vampiric_touch) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) < 2 and Spell(mind_blast) or { PreviousGCDSpell(vampiric_touch) or BuffPresent(harvested_thoughts_buff) } and AzeriteTraitRank(thought_harvester_trait) > 1 and Spell(mind_blast) or { not BuffPresent(voidform_buff) or SpellCharges(shadow_word_death) == 2 and BuffStacks(voidform_buff) < 15 } and Spell(shadow_word_death) or target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) and Spell(mind_blast) or target.DebuffRemaining(shadow_word_pain_debuff) > 4 and target.DebuffRemaining(vampiric_touch_debuff) > 4 and Spell(void_torrent) or target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 and not Talent(misery_talent) and not Talent(dark_void_talent) and Spell(shadow_word_pain) or { target.Refreshable(vampiric_touch_debuff) and target.TimeToDie() > 6 or Talent(misery_talent) and target.DebuffRefreshable(shadow_word_pain_debuff) } and Spell(vampiric_touch) or Spell(mind_flay) or Spell(shadow_word_pain)
}

AddFunction ShadowSingleCdActions
{
 unless Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Spell(void_bolt) or { target.TimeToDie() < 3 or SpellCharges(shadow_word_death) == 2 } and Spell(shadow_word_death)
 {
  #surrender_to_madness,if=buff.voidform.stack>=(15+buff.bloodlust.up)&target.time_to_die>200|target.time_to_die<75
  if BuffStacks(voidform_buff) >= 15 + BuffPresent(burst_haste_buff any=1) and target.TimeToDie() > 200 or target.TimeToDie() < 75 Spell(surrender_to_madness)
 }
}

AddFunction ShadowSingleCdPostConditions
{
 Spell(void_eruption) or BuffExpires(voidform_buff) and Spell(dark_ascension) or Spell(void_bolt) or { target.TimeToDie() < 3 or SpellCharges(shadow_word_death) == 2 } and Spell(shadow_word_death) or 600 > 10 and Spell(dark_void) or Spell(mindbender) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) > 1 and not SpellCooldown(mind_blast) > 0 and BuffExpires(harvested_thoughts_buff) and Spell(vampiric_touch) or { target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) or Talent(shadow_word_void_talent) and SpellCharges(shadow_word_void) == 2 } and AzeriteTraitRank(thought_harvester_trait) < 2 and Spell(mind_blast) or { PreviousGCDSpell(vampiric_touch) or BuffPresent(harvested_thoughts_buff) } and AzeriteTraitRank(thought_harvester_trait) > 1 and Spell(mind_blast) or { not BuffPresent(voidform_buff) or SpellCharges(shadow_word_death) == 2 and BuffStacks(voidform_buff) < 15 } and Spell(shadow_word_death) or 600 > 5 and 10 < 20 and Spell(shadow_crash) or target.DebuffPresent(shadow_word_pain_debuff) and target.DebuffPresent(vampiric_touch_debuff) and Spell(mind_blast) or target.DebuffRemaining(shadow_word_pain_debuff) > 4 and target.DebuffRemaining(vampiric_touch_debuff) > 4 and Spell(void_torrent) or target.Refreshable(shadow_word_pain_debuff) and target.TimeToDie() > 4 and not Talent(misery_talent) and not Talent(dark_void_talent) and Spell(shadow_word_pain) or { target.Refreshable(vampiric_touch_debuff) and target.TimeToDie() > 6 or Talent(misery_talent) and target.DebuffRefreshable(shadow_word_pain_debuff) } and Spell(vampiric_touch) or Spell(mind_flay) or Spell(shadow_word_pain)
}
]]

	OvaleScripts:RegisterScript("PRIEST", "shadow", name, desc, code, "script")
end
