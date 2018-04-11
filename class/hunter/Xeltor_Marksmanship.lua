local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_marksmanship"
	local desc = "[Xel][7.3.0] Hunter: Marksmanship"
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
		if { not IsDead() and HealthPercent() < 50 } or { not pet.IsDead() and pet.HealthPercent() < 15 } Spell(exhilaration)
		
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
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
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
	if vuln_window() / ExecuteTime(aimed_shot) > 0 and vuln_window() / ExecuteTime(aimed_shot) > { Focus() + FocusCastingRegen(aimed_shot) * { vuln_window() / ExecuteTime(aimed_shot) - 1 } } / PowerCost(aimed_shot) { Focus() + FocusCastingRegen(aimed_shot) * { vuln_window() / ExecuteTime(aimed_shot) - 1 } } / PowerCost(aimed_shot)
	vuln_window() / ExecuteTime(aimed_shot)
}

AddFunction waiting_for_sentinel
{
	Talent(sentinel_talent) and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and not { not SpellCooldown(sentinel) > 0 } and { SpellCooldown(sentinel) > 54 and SpellCooldown(sentinel) < 54 + GCD() or SpellCooldown(sentinel) > 48 and SpellCooldown(sentinel) < 48 + GCD() or SpellCooldown(sentinel) > 42 and SpellCooldown(sentinel) < 42 + GCD() }
}

AddFunction vuln_window
{
	if Talent(sidewinders_talent) and { 24 - SpellCharges(sidewinders count=0) * 12 } * { 100 / { 100 + MeleeHaste() } } < target.DebuffPresent(vulnerability_debuff) { 24 - SpellCharges(sidewinders count=0) * 12 } * { 100 / { 100 + MeleeHaste() } }
	target.DebuffPresent(vulnerability_debuff)
}

AddFunction trueshot_cooldown
{
	if TimeInCombat() > 15 and not SpellCooldown(trueshot) > 0 and 0 == 0 TimeInCombat() * 1.1
}

AddFunction can_gcd
{
	vuln_window() > vuln_aim_casts() * ExecuteTime(aimed_shot) + GCD()
}

### actions.default

AddFunction MarksmanshipDefaultMainActions
{
	#volley,toggle=on
	# if CheckBoxOn(opt_volley) Spell(volley)
	#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
	#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
	#call_action_list,name=cooldowns
	MarksmanshipCooldownsMainActions()

	unless MarksmanshipCooldownsMainPostConditions()
	{
		#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
		if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieMainActions()

		unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions()
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
}

AddFunction MarksmanshipDefaultMainPostConditions
{
	MarksmanshipCooldownsMainPostConditions() or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieMainPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperMainPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperMainPostConditions()
}

AddFunction MarksmanshipDefaultShortCdActions
{
	#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
	#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
	#call_action_list,name=cooldowns
	MarksmanshipCooldownsShortCdActions()

	unless MarksmanshipCooldownsShortCdPostConditions()
	{
		#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
		if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieShortCdActions()

		unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions()
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
}

AddFunction MarksmanshipDefaultShortCdPostConditions
{
	MarksmanshipCooldownsShortCdPostConditions() or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieShortCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperShortCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperShortCdPostConditions()
}

AddFunction MarksmanshipDefaultCdActions
{
	#auto_shot
	#counter_shot
	# MarksmanshipInterruptActions()

	#variable,name=pooling_for_piercing,value=talent.piercing_shot.enabled&cooldown.piercing_shot.remains<5&lowest_vuln_within.5>0&lowest_vuln_within.5>cooldown.piercing_shot.remains&(buff.trueshot.down|spell_targets=1)
	#variable,name=waiting_for_sentinel,value=talent.sentinel.enabled&(buff.marking_targets.up|buff.trueshot.up)&!cooldown.sentinel.up&((cooldown.sentinel.remains>54&cooldown.sentinel.remains<(54+gcd.max))|(cooldown.sentinel.remains>48&cooldown.sentinel.remains<(48+gcd.max))|(cooldown.sentinel.remains>42&cooldown.sentinel.remains<(42+gcd.max)))
	#call_action_list,name=cooldowns
	MarksmanshipCooldownsCdActions()

	unless MarksmanshipCooldownsCdPostConditions()
	{
		#call_action_list,name=targetdie,if=target.time_to_die<6&spell_targets.multishot=1
		if target.TimeToDie() < 6 and Enemies(tagged=1) == 1 MarksmanshipTargetdieCdActions()

		unless target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieCdPostConditions()
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
}

AddFunction MarksmanshipDefaultCdPostConditions
{
	MarksmanshipCooldownsCdPostConditions() or target.TimeToDie() < 6 and Enemies(tagged=1) == 1 and MarksmanshipTargetdieCdPostConditions() or Talent(patient_sniper_talent) and MarksmanshipPatientSniperCdPostConditions() or not Talent(patient_sniper_talent) and MarksmanshipNonPatientSniperCdPostConditions()
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
	#potion,name=prolonged_power,if=spell_targets.multishot>2&((buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<62)
	# if Enemies(tagged=1) > 2 and { BuffPresent(trueshot_buff) and BuffPresent(burst_haste_buff any=1) or BuffStacks(bullseye_buff) >= 23 or target.TimeToDie() < 62 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#potion,name=deadly_grace,if=(buff.trueshot.react&buff.bloodlust.react)|buff.bullseye.react>=23|target.time_to_die<31
	# if { BuffPresent(trueshot_buff) and BuffPresent(burst_haste_buff any=1) or BuffStacks(bullseye_buff) >= 23 or target.TimeToDie() < 31 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
	#variable,name=trueshot_cooldown,op=set,value=time*1.1,if=time>15&cooldown.trueshot.up&variable.trueshot_cooldown=0
	#trueshot,if=variable.trueshot_cooldown=0|buff.bloodlust.up|(variable.trueshot_cooldown>0&target.time_to_die>(variable.trueshot_cooldown+duration))|buff.bullseye.react>25|target.time_to_die<16
	if trueshot_cooldown() == 0 or BuffPresent(burst_haste_buff any=1) or trueshot_cooldown() > 0 and target.TimeToDie() > trueshot_cooldown() + BaseDuration(trueshot_buff) or BuffStacks(bullseye_buff) > 25 or target.TimeToDie() < 16 Spell(trueshot)
}

AddFunction MarksmanshipCooldownsCdPostConditions
{
}

### actions.non_patient_sniper

AddFunction MarksmanshipNonPatientSniperMainActions
{
	#aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&buff.sentinels_sight.stack=20
	if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 Spell(aimed_shot)
	#marked_shot,if=spell_targets>1
	if Enemies(tagged=1) > 1 Spell(marked_shot)
	#multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
	if Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
	#black_arrow,if=talent.sidewinders.enabled|spell_targets.multishot<6
	if Talent(sidewinders_talent) or Enemies(tagged=1) < 6 Spell(black_arrow)
	#windburst
	Spell(windburst)
	#marked_shot,if=buff.marking_targets.up|buff.trueshot.up
	if BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) Spell(marked_shot)
	#sidewinders,if=!variable.waiting_for_sentinel&(debuff.hunters_mark.down|(buff.trueshot.down&buff.marking_targets.down))&((buff.marking_targets.up|buff.trueshot.up)|charges_fractional>1.8)&(focus.deficit>cast_regen)
	if not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) Spell(sidewinders)
	#aimed_shot,if=talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time
	if Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) Spell(aimed_shot)
	#aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(buff.lock_and_load.up&lowest_vuln_within.5>gcd.max))&(spell_targets.multishot<4|talent.trick_shot.enabled|buff.sentinels_sight.stack=20)
	if not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } Spell(aimed_shot)
	#marked_shot
	Spell(marked_shot)
	#aimed_shot,if=talent.sidewinders.enabled&spell_targets.multi_shot=1&focus>110
	if Talent(sidewinders_talent) and Enemies(tagged=1) == 1 and Focus() > 110 Spell(aimed_shot)
	#multishot,if=spell_targets.multi_shot>1&!variable.waiting_for_sentinel
	if Enemies(tagged=1) > 1 and not waiting_for_sentinel() Spell(multishot)
	#arcane_shot,if=spell_targets.multi_shot<2&!variable.waiting_for_sentinel
	if Enemies(tagged=1) < 2 and not waiting_for_sentinel() Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipNonPatientSniperShortCdActions
{
	#explosive_shot
	Spell(explosive_shot)
	#piercing_shot,if=lowest_vuln_within.5>0&focus>100
	if target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 Spell(piercing_shot)

	unless Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot)
	{
		#sentinel,if=!debuff.hunters_mark.up
		if not target.DebuffPresent(hunters_mark_debuff) Spell(sentinel)

		unless { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow)
		{
			#a_murder_of_crows
			Spell(a_murder_of_crows)

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
	Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow) or Spell(windburst) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Talent(sidewinders_talent) and Enemies(tagged=1) == 1 and Focus() > 110 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies(tagged=1) < 2 and not waiting_for_sentinel() and Spell(arcane_shot)
}

AddFunction MarksmanshipNonPatientSniperCdActions
{
}

AddFunction MarksmanshipNonPatientSniperCdPostConditions
{
	Spell(explosive_shot) or target.DebuffRemaining(vulnerable) > 0 and Focus() > 100 and Spell(piercing_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and BuffStacks(sentinels_sight_buff) == 20 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or not target.DebuffPresent(hunters_mark_debuff) and Spell(sentinel) or { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and Spell(black_arrow) or Spell(a_murder_of_crows) or Spell(windburst) or { Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(marked_shot) or not waiting_for_sentinel() and { target.DebuffExpires(hunters_mark_debuff) or BuffExpires(trueshot_buff) and BuffExpires(marking_targets_buff) } and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.8 } and FocusDeficit() > FocusCastingRegen(sidewinders) and Spell(sidewinders) or Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or BuffPresent(lock_and_load_buff) and target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) or BuffStacks(sentinels_sight_buff) == 20 } and Spell(aimed_shot) or Spell(marked_shot) or Talent(sidewinders_talent) and Enemies(tagged=1) == 1 and Focus() > 110 and Spell(aimed_shot) or Enemies(tagged=1) > 1 and not waiting_for_sentinel() and Spell(multishot) or Enemies(tagged=1) < 2 and not waiting_for_sentinel() and Spell(arcane_shot)
}

### actions.patient_sniper

AddFunction MarksmanshipPatientSniperMainActions
{
	#aimed_shot,if=spell_targets>1&debuff.vulnerability.remains>cast_time&talent.trick_shot.enabled&(buff.sentinels_sight.stack=20|(buff.trueshot.up&buff.sentinels_sight.stack>=spell_targets.multishot*5))
	if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 } Spell(aimed_shot)
	#marked_shot,if=spell_targets>1
	if Enemies(tagged=1) > 1 Spell(marked_shot)
	#multishot,if=spell_targets>1&(buff.marking_targets.up|buff.trueshot.up)
	if Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } Spell(multishot)
	#windburst,if=variable.vuln_aim_casts<1&!variable.pooling_for_piercing
	if vuln_aim_casts() < 1 and not pooling_for_piercing() Spell(windburst)
	#black_arrow,if=variable.can_gcd&(talent.sidewinders.enabled|spell_targets.multishot<6)&(!variable.pooling_for_piercing|(lowest_vuln_within.5>gcd.max&focus>85))
	if can_gcd() and { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } Spell(black_arrow)
	#aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(spell_targets.multi_shot<4|talent.trick_shot.enabled)
	if target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) } Spell(aimed_shot)
	#aimed_shot,if=spell_targets.multishot>1&debuff.vulnerability.remains>execute_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))&(spell_targets.multishot<4|buff.sentinels_sight.stack=20|talent.trick_shot.enabled)
	if Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies(tagged=1) < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } Spell(aimed_shot)
	#multishot,if=spell_targets>1&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
	#arcane_shot,if=spell_targets.multi_shot=1&variable.vuln_aim_casts>0&variable.can_gcd&focus+cast_regen+action.aimed_shot.cast_regen<focus.max&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies(tagged=1) == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
	#aimed_shot,if=talent.sidewinders.enabled&(debuff.vulnerability.remains>cast_time|(buff.lock_and_load.down&action.windburst.in_flight))&(variable.vuln_window-(execute_time*variable.vuln_aim_casts)<1|focus.deficit<25|buff.trueshot.up)&(spell_targets.multishot=1|focus>100)
	if Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } Spell(aimed_shot)
	#aimed_shot,if=!talent.sidewinders.enabled&debuff.vulnerability.remains>cast_time&(!variable.pooling_for_piercing|(focus>100&lowest_vuln_within.5>(execute_time+gcd.max)))
	if not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } Spell(aimed_shot)
	#marked_shot,if=!talent.sidewinders.enabled&!variable.pooling_for_piercing
	if not Talent(sidewinders_talent) and not pooling_for_piercing() Spell(marked_shot)
	#marked_shot,if=talent.sidewinders.enabled&(variable.vuln_aim_casts<1|buff.trueshot.up|variable.vuln_window<action.aimed_shot.cast_time)
	if Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } Spell(marked_shot)
	#aimed_shot,if=spell_targets.multi_shot=1&focus>110
	if Enemies(tagged=1) == 1 and Focus() > 110 Spell(aimed_shot)
	#sidewinders,if=(!debuff.hunters_mark.up|(!buff.marking_targets.up&!buff.trueshot.up))&((buff.marking_targets.up&variable.vuln_aim_casts<1)|buff.trueshot.up|charges_fractional>1.9)
	if { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } Spell(sidewinders)
	#arcane_shot,if=spell_targets.multi_shot=1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(arcane_shot)
	#multishot,if=spell_targets>1&(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)
	if Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } Spell(multishot)
}

AddFunction MarksmanshipPatientSniperMainPostConditions
{
}

AddFunction MarksmanshipPatientSniperShortCdActions
{
	#variable,name=vuln_window,op=set,value=debuff.vulnerability.remains
	#variable,name=vuln_window,op=set,value=(24-cooldown.sidewinders.charges_fractional*12)*attack_haste,if=talent.sidewinders.enabled&(24-cooldown.sidewinders.charges_fractional*12)*attack_haste<variable.vuln_window
	#variable,name=vuln_aim_casts,op=set,value=floor(variable.vuln_window%action.aimed_shot.execute_time)
	#variable,name=vuln_aim_casts,op=set,value=floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost),if=variable.vuln_aim_casts>0&variable.vuln_aim_casts>floor((focus+action.aimed_shot.cast_regen*(variable.vuln_aim_casts-1))%action.aimed_shot.cost)
	#variable,name=can_gcd,value=variable.vuln_window>variable.vuln_aim_casts*action.aimed_shot.execute_time+gcd.max
	#piercing_shot,if=cooldown.piercing_shot.up&spell_targets=1&lowest_vuln_within.5>0&lowest_vuln_within.5<1
	if not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 Spell(piercing_shot)
	#piercing_shot,if=cooldown.piercing_shot.up&spell_targets>1&lowest_vuln_within.5>0&((!buff.trueshot.up&focus>80&(lowest_vuln_within.5<1|debuff.hunters_mark.up))|(buff.trueshot.up&focus>105&lowest_vuln_within.5<6))
	if not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } Spell(piercing_shot)

	unless Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow)
	{
		#a_murder_of_crows,if=(!variable.pooling_for_piercing|lowest_vuln_within.5>gcd.max)&(target.time_to_die>=cooldown+duration|target.health.pct<20|target.time_to_die<16)
		if { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } Spell(a_murder_of_crows)
		#barrage,if=spell_targets>2|(target.health.pct<20&buff.bullseye.stack<25)
		if Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 Spell(barrage)
	}
}

AddFunction MarksmanshipPatientSniperShortCdPostConditions
{
	Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies(tagged=1) < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies(tagged=1) == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and not pooling_for_piercing() and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Enemies(tagged=1) == 1 and Focus() > 110 and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

AddFunction MarksmanshipPatientSniperCdActions
{
}

AddFunction MarksmanshipPatientSniperCdPostConditions
{
	not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) == 1 and target.DebuffRemaining(vulnerable) > 0 and target.DebuffRemaining(vulnerable) < 1 and Spell(piercing_shot) or not SpellCooldown(piercing_shot) > 0 and Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerable) > 0 and { not BuffPresent(trueshot_buff) and Focus() > 80 and { target.DebuffRemaining(vulnerable) < 1 or target.DebuffPresent(hunters_mark_debuff) } or BuffPresent(trueshot_buff) and Focus() > 105 and target.DebuffRemaining(vulnerable) < 6 } and Spell(piercing_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and Talent(trick_shot_talent) and { BuffStacks(sentinels_sight_buff) == 20 or BuffPresent(trueshot_buff) and BuffStacks(sentinels_sight_buff) >= Enemies(tagged=1) * 5 } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and Spell(marked_shot) or Enemies(tagged=1) > 1 and { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(multishot) or vuln_aim_casts() < 1 and not pooling_for_piercing() and Spell(windburst) or can_gcd() and { Talent(sidewinders_talent) or Enemies(tagged=1) < 6 } and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() and Focus() > 85 } and Spell(black_arrow) or { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { target.TimeToDie() >= SpellCooldown(a_murder_of_crows) + BaseDuration(a_murder_of_crows_debuff) or target.HealthPercent() < 20 or target.TimeToDie() < 16 } and Spell(a_murder_of_crows) or { Enemies(tagged=1) > 2 or target.HealthPercent() < 20 and BuffStacks(bullseye_buff) < 25 } and Spell(barrage) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and { Enemies(tagged=1) < 4 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and { Enemies(tagged=1) < 4 or BuffStacks(sentinels_sight_buff) == 20 or Talent(trick_shot_talent) } and Spell(aimed_shot) or Enemies(tagged=1) > 1 and can_gcd() and Focus() + FocusCastingRegen(multishot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot) or Enemies(tagged=1) == 1 and vuln_aim_casts() > 0 and can_gcd() and Focus() + FocusCastingRegen(arcane_shot) + FocusCastingRegen(aimed_shot) < MaxFocus() and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Talent(sidewinders_talent) and { target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) or BuffExpires(lock_and_load_buff) and InFlightToTarget(windburst) } and { vuln_window() - ExecuteTime(aimed_shot) * vuln_aim_casts() < 1 or FocusDeficit() < 25 or BuffPresent(trueshot_buff) } and { Enemies(tagged=1) == 1 or Focus() > 100 } and Spell(aimed_shot) or not Talent(sidewinders_talent) and target.DebuffRemaining(vulnerability_debuff) > CastTime(aimed_shot) and { not pooling_for_piercing() or Focus() > 100 and target.DebuffRemaining(vulnerable) > ExecuteTime(aimed_shot) + GCD() } and Spell(aimed_shot) or not Talent(sidewinders_talent) and not pooling_for_piercing() and Spell(marked_shot) or Talent(sidewinders_talent) and { vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or vuln_window() < CastTime(aimed_shot) } and Spell(marked_shot) or Enemies(tagged=1) == 1 and Focus() > 110 and Spell(aimed_shot) or { not target.DebuffPresent(hunters_mark_debuff) or not BuffPresent(marking_targets_buff) and not BuffPresent(trueshot_buff) } and { BuffPresent(marking_targets_buff) and vuln_aim_casts() < 1 or BuffPresent(trueshot_buff) or Charges(sidewinders count=0) > 1.9 } and Spell(sidewinders) or Enemies(tagged=1) == 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(arcane_shot) or Enemies(tagged=1) > 1 and { not pooling_for_piercing() or target.DebuffRemaining(vulnerable) > GCD() } and Spell(multishot)
}

### actions.precombat

AddFunction MarksmanshipPrecombatMainActions
{
	#augmentation,type=defiled
	#windburst
	Spell(windburst)
}

AddFunction MarksmanshipPrecombatMainPostConditions
{
}

AddFunction MarksmanshipPrecombatShortCdActions
{
	#flask,type=flask_of_the_seventh_demon
	#food,type=nightborne_delicacy_platter
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
	#potion,name=prolonged_power,if=spell_targets.multi_shot>2
	# if Enemies(tagged=1) > 2 and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
	#potion,name=deadly_grace
	# if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(deadly_grace_potion usable=1)
}

AddFunction MarksmanshipPrecombatCdPostConditions
{
	Spell(windburst)
}

### actions.targetdie

AddFunction MarksmanshipTargetdieMainActions
{
	#windburst
	Spell(windburst)
	#aimed_shot,if=debuff.vulnerability.up&buff.lock_and_load.up
	if target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) Spell(aimed_shot)
	#marked_shot
	Spell(marked_shot)
	#arcane_shot,if=buff.marking_targets.up|buff.trueshot.up
	if BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) Spell(arcane_shot)
	#aimed_shot,if=debuff.vulnerability.remains>execute_time&target.time_to_die>cast_time
	if target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) Spell(aimed_shot)
	#sidewinders
	Spell(sidewinders)
	#arcane_shot
	Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieMainPostConditions
{
}

AddFunction MarksmanshipTargetdieShortCdActions
{
	#piercing_shot,if=debuff.vulnerability.up
	if target.DebuffPresent(vulnerability_debuff) Spell(piercing_shot)
	#explosive_shot
	Spell(explosive_shot)
}

AddFunction MarksmanshipTargetdieShortCdPostConditions
{
	Spell(windburst) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and Spell(aimed_shot) or Spell(marked_shot) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(arcane_shot) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(arcane_shot)
}

AddFunction MarksmanshipTargetdieCdActions
{
}

AddFunction MarksmanshipTargetdieCdPostConditions
{
	target.DebuffPresent(vulnerability_debuff) and Spell(piercing_shot) or Spell(explosive_shot) or Spell(windburst) or target.DebuffPresent(vulnerability_debuff) and BuffPresent(lock_and_load_buff) and Spell(aimed_shot) or Spell(marked_shot) or { BuffPresent(marking_targets_buff) or BuffPresent(trueshot_buff) } and Spell(arcane_shot) or target.DebuffRemaining(vulnerability_debuff) > ExecuteTime(aimed_shot) and target.TimeToDie() > CastTime(aimed_shot) and Spell(aimed_shot) or Spell(sidewinders) or Spell(arcane_shot)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "marksmanship", name, desc, code, "script")
end
