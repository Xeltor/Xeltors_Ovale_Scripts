local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_marksmanship"
	local desc = "[Xel][7.3.5] Hunter: Marksmanship"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(counter_shot 147362)

# Marksman
AddIcon specialization=2 help=main
{
	if InCombat() and HasFullControl() and target.Present() and target.InRange(arcane_shot)
	{
		# Silence
		if InCombat() InterruptActions()
		
		# Tank stuff
		if CheckBoxOn(tank) Spell(black_arrow)
		if not IsDead() and HealthPercent() < 50 Spell(exhilaration)
		
		# Cooldowns
		if Boss() MarksmanshipDefaultCdActions()
		
		# Short Cooldowns
		MarksmanshipDefaultShortCdActions()
		
		# Rotation
		MarksmanshipDefaultMainActions()
	}
}
AddCheckBox(tank "Tank")

AddFunction Boss
{
	IsBossFight() or target.Classification(worldboss) or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(counter_shot) Spell(counter_shot)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddFunction pooling_for_piercing
{
 Talent(piercing_shot_talent) and SpellCooldown(piercing_shot) < 5 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) > SpellCooldown(piercing_shot) and { BuffExpires(trueshot_buff) or Enemies() == 1 }
}

AddFunction vuln_aim_casts
{
	if aimed_shots_vuln() < aimed_shots_focus() aimed_shots_vuln()
	if aimed_shots_vuln() >= aimed_shots_focus() aimed_shots_focus()
}

AddFunction aimed_shots_focus
{
	if FocusCost(aimed_shot) > 0 Focus() + { FocusRegenRate() * target.DebuffRemaining(vulnerability_debuff) } / FocusCost(aimed_shot)
	0
}

AddFunction aimed_shots_vuln
{
	if target.DebuffPresent(vulnerability_debuff) and CastTime(aimed_shot) < 1 target.DebuffRemaining(vulnerability_debuff) / GCD()
	if target.DebuffPresent(vulnerability_debuff) and CastTime(aimed_shot) > 0 CastTime(aimed_shot) / target.DebuffRemaining(vulnerability_debuff)
	0
}

AddFunction waiting_for_sentinel
{
 Talent(sentinel_talent) and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and 0
}

AddFunction vuln_window
{
 if Talent(sidewinders_talent) and SpellCooldown(sidewinders) < target.DebuffRemaining(vulnerability_debuff) SpellCooldown(sidewinders)
 unless Talent(sidewinders_talent) and SpellCooldown(sidewinders) < target.DebuffRemaining(vulnerability_debuff) target.DebuffPresent(vulnerability_debuff)
}

AddFunction can_gcd
{
 vuln_window() < CastTime(aimed_shot) or vuln_window() > vuln_aim_casts() * ExecuteTime(aimed_shot) + GCD() + 0.1
}

AddFunction aimed_shot_move
{
	Speed() == 0 or CanMove() > 0 or CastTime(aimed_shot) <= 0
}

AddFunction windburst_move
{
	Speed() == 0 or CanMove() > 0 or CastTime(windburst) <= 0
}

### actions.default

AddFunction MarksmanshipDefaultMainActions
{
 #variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
 #call_action_list,name=cooldowns
 MarksmanshipCooldownsMainActions()

 unless MarksmanshipCooldownsMainPostConditions()
 {
  #call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
  if Talent(patient_sniper_talent) MarksmanshipPatientSniperMainActions()

  unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions()
  {
   #call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
   if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperMainActions()
  }
 }
}

AddFunction MarksmanshipDefaultMainPostConditions
{
 MarksmanshipCooldownsMainPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperMainPostConditions()
}

AddFunction MarksmanshipDefaultShortCdActions
{
 #variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
 #call_action_list,name=cooldowns
 MarksmanshipCooldownsShortCdActions()

 unless MarksmanshipCooldownsShortCdPostConditions()
 {
  #call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
  if Talent(patient_sniper_talent) MarksmanshipPatientSniperShortCdActions()

  unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions()
  {
   #call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
   if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperShortCdActions()
  }
 }
}

AddFunction MarksmanshipDefaultShortCdPostConditions
{
 MarksmanshipCooldownsShortCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperShortCdPostConditions()
}

AddFunction MarksmanshipDefaultCdActions
{
 #auto_shot
 #counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
 # if HasEquippedItem(sephuzs_secret) and target.IsInterruptible() and not SpellCooldown(buff_sephuzs_secret) > 0 and not BuffPresent(sephuzs_secret_buff) MarksmanshipInterruptActions()
 #variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
 #call_action_list,name=cooldowns
 MarksmanshipCooldownsCdActions()

 unless MarksmanshipCooldownsCdPostConditions()
 {
  #call_action_list,name=patient_sniper,if=talent.patient_sniper.enabled
  if Talent(patient_sniper_talent) MarksmanshipPatientSniperCdActions()

  unless Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions()
  {
   #call_action_list,name=non_patient_sniper,if=!talent.patient_sniper.enabled
   if not Talent(patient_sniper_talent) MarksmanshipNonPatientSniperCdActions()
  }
 }
}

AddFunction MarksmanshipDefaultCdPostConditions
{
 MarksmanshipCooldownsCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperCdPostConditions()
}

### actions.cooldowns

AddFunction MarksmanshipCooldownsMainActions
{
}

AddFunction MarksmanshipCooldownsMainPostConditions
{
}

AddFunction MarksmanshipCooldownsShortCdActions
{
}

AddFunction MarksmanshipCooldownsShortCdPostConditions
{
}

AddFunction MarksmanshipCooldownsCdActions
{
 #arcane_torrent,if=focus.deficit>=30&(!talent.sidewinders.enabled|cooldown.sidewinders.charges<2)
 if FocusDeficit() >= 30 and { not Talent(sidewinders_talent) or SpellCharges(sidewinders) < 2 } Spell(arcane_torrent_focus)
 #berserking,if=buff.trueshot.up
 if BuffPresent(trueshot_buff) Spell(berserking)
 #blood_fury,if=buff.trueshot.up
 if BuffPresent(trueshot_buff) Spell(blood_fury_ap)
 #trueshot,if=time=0|buff.bloodlust.up|buff.bullseye.react=30|target.time_to_die<16
 if TimeInCombat() == 0 or BuffPresent(burst_haste_buff any=1) or BuffStacks(bullseye_buff) == 30 or target.TimeToDie() < 16 Spell(trueshot)
}

AddFunction MarksmanshipCooldownsCdPostConditions
{
}

### actions.non_patient_sniper

AddFunction MarksmanshipNonPatientSniperMainActions
{
 #aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&(talent.trick_shot.enabled|buff.lock_and_load.up)&buff.sentinels_sight.stack=20
 if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { Talent(trick_shot_talent) or BuffPresent(lock_and_load_buff) } and BuffStacks(sentinels_sight_buff) == 20 and aimed_shot_move() Spell(aimed_shot)
 #aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&set_bonus.tier20_2pc&!buff.t20_2p_critical_aimed_damage.up&action.aimed_shot.in_flight
 if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and InFlightToTarget(aimed_shot) and aimed_shot_move() Spell(aimed_shot)
 #marked_shot,if=spell_targets>1
 if Enemies(tagged=1) > 1 Spell(marked_shot)
 #multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
 if Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
 #black_arrow,if=talent.sidewinders.enabled|spell_targets.multishot<6
 if Talent(sidewinders_talent) or Enemies(tagged=1) < 6 Spell(black_arrow)
 #windburst
 if windburst_move() Spell(windburst)
 #marked_shot,if=buff.marking_targets.up|buff.trueshot.up
 if BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) Spell(marked_shot)
 #sidewinders,if=!variable.waiting_for_sentinel&(debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down))&((buff.marking_targets.up|buff.trueshot.up)|charges_fractional>1.8)&(focus.deficit>cast_regen)
 if not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) Spell(sidewinders)
 #aimed_shot,if=talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time
 if Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and aimed_shot_move() Spell(aimed_shot)
 #aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(buff.lock_and_load.up&lowest_vuln_within.5>gcd.max))&(spell_targets.multishot<5|talent.trick_shot.enabled|buff.sentinels_sight.stack=20)
 if not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 5 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and aimed_shot_move() Spell(aimed_shot)
 #marked_shot
 Spell(marked_shot)
 #aimed_shot,if=focus+cast_regen>focus.max&!buff.sentinels_sight.up
 if Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and not BuffPresent(sentinels_sight_buff) and aimed_shot_move() Spell(aimed_shot)
 #multishot,if=spell_targets.multishot>1&!variable.waiting_for_sentinel
 if Enemies(tagged=1) > 1 and not waiting_for_sentinel() Spell(multishot)
 #arcane_shot,if=spell_targets.multishot=1&!variable.waiting_for_sentinel
 if Enemies(tagged=1) == 1 and not waiting_for_sentinel() Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipNonPatientSniperShortCdActions
{
 #variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&action.sentinel.marks_next_gcd
 #explosive_shot
 Spell(explosive_shot)
 #piercing_shot,if=lowest_vuln_within.5>0&focus>100
 if target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 Spell(piercing_shot)

 unless Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { Talent(trick_shot_talent) or BuffPresent(lock_and_load_buff) } and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and InFlightToTarget(aimed_shot) and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot)
 {
  #sentinel,if=!debuff.hunters_mark.up
  if not target.DebuffPresent(hunters_mark_debuff) Spell(sentinel)

  unless { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow)
  {
   #a_murder_of_crows,if=target.time_to_die>=cooldown+duration|target.health.pct<20
   if target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 Spell(a_murder_of_crows)

   unless Spell(windburst)
   {
    #barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
    if Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 Spell(barrage)
   }
  }
 }
}

AddFunction MarksmanshipNonPatientSniperShortCdPostConditions
{
 Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { Talent(trick_shot_talent) or BuffPresent(lock_and_load_buff) } and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and InFlightToTarget(aimed_shot) and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow) or Spell(windburst) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 5 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and not BuffPresent(sentinels_sight_buff) and Spell(aimed_shot) or Enemies(tagged=1) > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies(tagged=1) == 1 and not waiting_for_sentinel() and Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperCdActions
{
}

AddFunction MarksmanshipNonPatientSniperCdPostConditions
{
 Spell(explosive_shot) or target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 and Spell(piercing_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { Talent(trick_shot_talent) or BuffPresent(lock_and_load_buff) } and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and InFlightToTarget(aimed_shot) and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or not target.DebuffPresent(hunters_mark_debuff) and Spell(sentinel) or { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow) or { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 } and Spell(a_murder_of_crows) or Spell(windburst) or { Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 5 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and not BuffPresent(sentinels_sight_buff) and Spell(aimed_shot) or Enemies(tagged=1) > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies(tagged=1) == 1 and not waiting_for_sentinel() and Spell(arcane_shot)
}

### actions.patient_sniper

AddFunction MarksmanshipPatientSniperMainActions
{
 #variable,name=vuln_window,op=setif,value=cooldown.sidewinders.full_recharge_time,value_else=debuff.vulnerability.remains,condition=talent.sidewinders.enabled&cooldown.sidewinders.full_recharge_time<debuff.vulnerability.remains
 #variable,name=vuln_aim_casts,op=set,value=action.aimed_shot.vuln_casts
 #variable,name=can_gcd,value=variable.vuln_window<action.aimed_shot.cast_time|variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max+0.1
 #call_action_list,name=targetdie,if=target.time_to_die<variable.vuln_window&spell_targets.multishot=1
 if target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 MarksmanshipTargetdieMainActions()

 unless target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions()
 {
  #aimed_shot,if=spell_targets.multishot>1&talent.trick_shot.enabled&debuff.vulnerability.remains>cast_time&(buff.sentinels_sight.stack>=spell_targets.multishot*5|buff.sentinels_sight.stack+(spell_targets.multishot%2)>20|(set_bonus.tier20_2pc&!buff.t20_2p_critical_aimed_damage.up&prev.aimed_shot)|buff.lock_and_load.up&spell_targets.multishot<3)
  if Enemies(tagged=1) > 1 and Talent(trick_shot_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 or BuffStacks(sentinels_sight_buff) + Enemies(tagged=1) / 2 > 20 or ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and PreviousSpell(aimed_shot) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 } and aimed_shot_move() Spell(aimed_shot)
  #marked_shot,if=spell_targets>1
  if Enemies(tagged=1) > 1 Spell(marked_shot)
  #multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
  if Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
  #windburst,if=variable.vuln_aim_casts<1&!variable.pooling_for_piercing
  if vuln_aim_casts() < 1 and not pooling_for_piercing() and windburst_move() Spell(windburst)
  #black_arrow,if=variable.can_gcd&(!variable.pooling_for_piercing|(lowest_vuln_within.5>gcd.max&focus>85))
  if can_gcd() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } Spell(black_arrow)
  #aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
  if target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and aimed_shot_move() Spell(aimed_shot)
  #aimed_shot,if=spell_targets.multishot>1&debuff.vulnerability.remains>execute_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))
  if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and aimed_shot_move() Spell(aimed_shot)
  #multishot,if=spell_targets>1&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
  if Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
  #arcane_shot,if=spell_targets.multishot=1&(!set_bonus.tier20_2pc|!action.aimed_shot.in_flight|buff.t20_2p_critical_aimed_damage.remains>action.aimed_shot.cast_time+gcd)&(variable.vuln_aim_casts>0|action.windburst.in_flight&!set_bonus.tier21_4pc)&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd)
  if Enemies(tagged=1) == 1 and { not ArmorSetBonus(T20 2) or not InFlightToTarget(aimed_shot) or BuffRemaining(t20_2p_critical_aimed_damage_buff) > CastTime(aimed_shot) + GCD() } and { vuln_aim_casts() > 0 or InFlightToTarget(windburst) and not ArmorSetBonus(T21 4) } and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
  #aimed_shot,if=talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight))&(variable.vuln_window-(execute_time*variable.vuln_aim_casts)<1|focus.deficit<=cast_regen|buff.trueshot.up)&(spell_targets.multishot=1|focus>100)
  if Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() <= FocusCastingRegen(aimed_shot) or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } and aimed_shot_move() Spell(aimed_shot)
  #aimed_shot,if=!talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight&(!set_bonus.tier21_4pc|debuff.hunters_mark.down)))&(!variable.pooling_for_piercing|lowest_vuln_within.5>execute_time+gcd.max)
  if not Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) and { not ArmorSetBonus(T21 4) or target.DebuffExpires(hunters_mark_debuff) } } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and aimed_shot_move() Spell(aimed_shot)
  #marked_shot,if=!talent.sidewinders.enabled&((buff.lock_and_load.up&debuff.vulnerability.down)|(variable.vuln_window<action.aimed_shot.cast_time&!variable.pooling_for_piercing&(!action.windburst.in_flight|set_bonus.tier21_4pc)&((focus>65|buff.trueshot.up|(1%attack_haste)>1.217|(1%attack_haste)>1.171&set_bonus.tier20_4pc)|set_bonus.tier21_4pc&!set_bonus.tier20_2pc)))
  if not Talent(sidewinders_talent) and { BuffPresent(lock_and_load_buff) and target.DebuffExpires(vulnerability_debuff) or vuln_window() < CastTime(aimed_shot) and not pooling_for_piercing() and { not InFlightToTarget(windburst) or ArmorSetBonus(T21 4) } and { Focus() > 65 or BuffPresent(trueshot_buff) or 1 / { 100 / { 100 + MeleeHaste() } } > 1.217 or 1 / { 100 / { 100 + MeleeHaste() } } > 1.171 and ArmorSetBonus(T20 4) or ArmorSetBonus(T21 4) and not ArmorSetBonus(T20 2) } } Spell(marked_shot)
  #marked_shot,if=talent.sidewinders.enabled&(variable.vuln_aim_casts<1|buff.trueshot.up|variable.vuln_window<action.aimed_shot.cast_time)
  if Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } Spell(marked_shot)
  #aimed_shot,if=focus+cast_regen>focus.max&buff.lock_and_load.down&!buff.sentinels_sight.up
  if Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and BuffExpires(lock_and_load_buff) and not BuffPresent(sentinels_sight_buff) and aimed_shot_move() Spell(aimed_shot)
  #sidewinders,if=(!debuff.hunters_mark.up|(!buff.marking_targets.up&!buff.trueshot.up))&((buff.marking_targets.up&variable.vuln_aim_casts<1)|buff.trueshot.up|charges_fractional>1.9)
  if { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } Spell(sidewinders)
  #arcane_shot,if=spell_targets.multishot=1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
  if Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
  #multishot,if=spell_targets>1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
  if Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
 }
}

AddFunction MarksmanshipPatientSniperMainPostConditions
{
 target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions()
}

AddFunction MarksmanshipPatientSniperShortCdActions
{
 #variable,name=vuln_window,op=setif,value=cooldown.sidewinders.full_recharge_time,value_else=debuff.vulnerability.remains,condition=talent.sidewinders.enabled&cooldown.sidewinders.full_recharge_time<debuff.vulnerability.remains
 #variable,name=vuln_aim_casts,op=set,value=action.aimed_shot.vuln_casts
 #variable,name=can_gcd,value=variable.vuln_window<action.aimed_shot.cast_time|variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max+0.1
 #call_action_list,name=targetdie,if=target.time_to_die<variable.vuln_window&spell_targets.multishot=1
 if target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 MarksmanshipTargetdieShortCdActions()

 unless target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions()
 {
  #piercing_shot,if=cooldown.piercing_shot.up&spell_targets=1&lowest_vuln_within.5>0&lowest_vuln_within.5<1
  if not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 Spell(piercing_shot)
  #piercing_shot,if=cooldown.piercing_shot.up&spell_targets>1&lowest_vuln_within.5>0&((!buff.trueshot.up&focus>80&(lowest_vuln_within.5<1|debuff.hunters_mark.up))|(buff.trueshot.up&focus>105&lowest_vuln_within.5<6))
  if not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } Spell(piercing_shot)

  unless Enemies(tagged=1) > 1 and Talent(trick_shot_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 or BuffStacks(sentinels_sight_buff) + Enemies(tagged=1) / 2 > 20 or ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and PreviousSpell(aimed_shot) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow)
  {
   #a_murder_of_crows,if=(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(target.time_to_die>=cooldown+duration|target.health.pct<20|target.time_to_die<16)&variable.vuln_aim_casts=0
   if { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } and vuln_aim_casts() == 0 Spell(a_murder_of_crows)
   #barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
   if Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 Spell(barrage)
  }
 }
}

AddFunction MarksmanshipPatientSniperShortCdPostConditions
{
 target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions() or Enemies(tagged=1) > 1 and Talent(trick_shot_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 or BuffStacks(sentinels_sight_buff) + Enemies(tagged=1) / 2 > 20 or ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and PreviousSpell(aimed_shot) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies(tagged=1) == 1 and { not ArmorSetBonus(T20 2) or not InFlightToTarget(aimed_shot) or BuffRemaining(t20_2p_critical_aimed_damage_buff) > CastTime(aimed_shot) + GCD() } and { vuln_aim_casts() > 0 or InFlightToTarget(windburst) and not ArmorSetBonus(T21 4) } and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() <= FocusCastingRegen(aimed_shot) or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) and { not ArmorSetBonus(T21 4) or target.DebuffExpires(hunters_mark_debuff) } } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and { BuffPresent(lock_and_load_buff) and target.DebuffExpires(vulnerability_debuff) or vuln_window() < CastTime(aimed_shot) and not pooling_for_piercing() and { not InFlightToTarget(windburst) or ArmorSetBonus(T21 4) } and { Focus() > 65 or BuffPresent(trueshot_buff) or 1 / { 100 / { 100 + MeleeHaste() } } > 1.217 or 1 / { 100 / { 100 + MeleeHaste() } } > 1.171 and ArmorSetBonus(T20 4) or ArmorSetBonus(T21 4) and not ArmorSetBonus(T20 2) } } and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and BuffExpires(lock_and_load_buff) and not BuffPresent(sentinels_sight_buff) and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

AddFunction MarksmanshipPatientSniperCdActions
{
 #variable,name=vuln_window,op=setif,value=cooldown.sidewinders.full_recharge_time,value_else=debuff.vulnerability.remains,condition=talent.sidewinders.enabled&cooldown.sidewinders.full_recharge_time<debuff.vulnerability.remains
 #variable,name=vuln_aim_casts,op=set,value=action.aimed_shot.vuln_casts
 #variable,name=can_gcd,value=variable.vuln_window<action.aimed_shot.cast_time|variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max+0.1
 #call_action_list,name=targetdie,if=target.time_to_die<variable.vuln_window&spell_targets.multishot=1
 if target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 MarksmanshipTargetdieCdActions()
}

AddFunction MarksmanshipPatientSniperCdPostConditions
{
 target.TimeToDie() < vuln_window() and Enemies(tagged=1) == 1 and MarksmanshipTargetdieCdPostConditions() or not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 and Spell(piercing_shot) or not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } and Spell(piercing_shot) or Enemies(tagged=1) > 1 and Talent(trick_shot_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 or BuffStacks(sentinels_sight_buff) + Enemies(tagged=1) / 2 > 20 or ArmorSetBonus(T20 2) and not BuffPresent(t20_2p_critical_aimed_damage_buff) and PreviousSpell(aimed_shot) or BuffPresent(lock_and_load_buff) and Enemies(tagged=1) < 3 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } and vuln_aim_casts() == 0 and Spell(a_murder_of_crows) or { Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies(tagged=1) == 1 and { not ArmorSetBonus(T20 2) or not InFlightToTarget(aimed_shot) or BuffRemaining(t20_2p_critical_aimed_damage_buff) > CastTime(aimed_shot) + GCD() } and { vuln_aim_casts() > 0 or InFlightToTarget(windburst) and not ArmorSetBonus(T21 4) } and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() <= FocusCastingRegen(aimed_shot) or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) and { not ArmorSetBonus(T21 4) or target.DebuffExpires(hunters_mark_debuff) } } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and { BuffPresent(lock_and_load_buff) and target.DebuffExpires(vulnerability_debuff) or vuln_window() < CastTime(aimed_shot) and not pooling_for_piercing() and { not InFlightToTarget(windburst) or ArmorSetBonus(T21 4) } and { Focus() > 65 or BuffPresent(trueshot_buff) or 1 / { 100 / { 100 + MeleeHaste() } } > 1.217 or 1 / { 100 / { 100 + MeleeHaste() } } > 1.171 and ArmorSetBonus(T20 4) or ArmorSetBonus(T21 4) and not ArmorSetBonus(T20 2) } } and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Focus() + FocusCastingRegen(aimed_shot) > MaxFocus() and BuffExpires(lock_and_load_buff) and not BuffPresent(sentinels_sight_buff) and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

### actions.precombat

AddFunction MarksmanshipPrecombatMainActions
{
 #windburst
 if windburst_move() Spell(windburst)
}

AddFunction MarksmanshipPrecombatMainPostConditions
{
}

AddFunction MarksmanshipPrecombatShortCdActions
{
 #flask
 #augmentation
 #food
 #summon_pet
 # MarksmanshipSummonPet()
}

AddFunction MarksmanshipPrecombatShortCdPostConditions
{
 Spell(windburst)
}

AddFunction MarksmanshipPrecombatCdActions
{
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction MarksmanshipPrecombatCdPostConditions
{
 Spell(windburst)
}

### actions.targetdie

AddFunction MarksmanshipTargetdieMainActions
{
 #windburst
 if windburst_move() Spell(windburst)
 #aimed_shot,if=debuff.vulnerability.remains>cast_time&target.time_to_die>cast_time
 if target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and aimed_shot_move() Spell(aimed_shot)
 #marked_shot
 Spell(marked_shot)
 #arcane_shot
 Spell(arcane_shot)
 #sidewinders
 Spell(sidewinders)
}

AddFunction MarksmanshipTargetdieMainPostConditions
{
}

AddFunction MarksmanshipTargetdieShortCdActions
{
 #piercing_shot,if=debuff.vulnerability.up
 if target.DebuffPresent(vulnerability_debuff) Spell(piercing_shot)
}

AddFunction MarksmanshipTargetdieShortCdPostConditions
{
 Spell(windburst) or target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(marked_shot) or Spell(arcane_shot) or Spell(sidewinders)
}

AddFunction MarksmanshipTargetdieCdActions
{
}

AddFunction MarksmanshipTargetdieCdPostConditions
{
 target.DebuffPresent(vulnerability_debuff) and Spell(piercing_shot) or Spell(windburst) or target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(marked_shot) or Spell(arcane_shot) or Spell(sidewinders)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "marksmanship", name, desc, code, "script")
end
