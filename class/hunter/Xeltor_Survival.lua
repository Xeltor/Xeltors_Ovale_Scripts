local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_survival"
	local desc = "[Xel][7.3.5] Hunter: Survival"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_hunter_spells)

Define(mend_pet 136)
	SpellInfo(mend_pet cd=10 duration=10)
	SpellAddBuff(mend_pet mend_pet=1)

# Survival
AddIcon specialization=3 help=main
{
	# Silence
	if InCombat() InterruptActions()
	
	if HasFullControl() and target.Present() and target.InRange(raptor_strike)
	{
		# Pet we needs it.
		SurvivalSummonPet()
		if { not IsDead() and HealthPercent() < 50 } or { not pet.IsDead() and pet.HealthPercent() < 15 } Spell(exhilaration)
	
		# Cooldowns
		if Boss()
		{
			SurvivalDefaultCdActions()
		}
		
		# Short Cooldowns
		SurvivalDefaultShortCdActions()
		
		# Default Actions
		SurvivalDefaultMainActions()
	}
	
	# Go forth and murder
	if InCombat() and HasFullControl() and target.Present() and not target.InRange(raptor_strike) and { TimeInCombat() < 6 or Falling() }
	{
		if target.InRange(harpoon) Spell(harpoon)
	}
}

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() } 
}

AddFunction SurvivalSummonPet
{
	if pet.IsDead()
	{
		if not DebuffPresent(heart_of_the_phoenix_debuff) Spell(heart_of_the_phoenix)
		if Speed() == 0 Spell(revive_pet)
	}
	if not pet.IsDead() and pet.HealthPercent() < 85 and not pet.BuffStacks(mend_pet) and pet.InRange(mend_pet) Spell(mend_pet)
	# if not pet.Present() and not pet.IsDead() and not PreviousSpell(revive_pet) Texture(ability_hunter_beastcall)
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(muzzle) Spell(muzzle)
		if not target.Classification(worldboss)
		{
			if target.Distance(less 8) Spell(arcane_torrent_focus)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.Distance(less 8) Spell(war_stomp)
		}
	}
}

AddFunction mokTalented
{
 Talent(way_of_the_moknathal_talent)
}

AddFunction frizzosEquipped
{
 HasEquippedItem(137043)
}

### actions.CDs

AddFunction SurvivalCdsMainActions
{
}

AddFunction SurvivalCdsMainPostConditions
{
}

AddFunction SurvivalCdsShortCdActions
{
 #snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&(cooldown.aspect_of_the_eagle.remains>5&!buff.aspect_of_the_eagle.up)
 if SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and SpellCooldown(aspect_of_the_eagle) > 5 and not BuffPresent(aspect_of_the_eagle_buff) Spell(snake_hunter)
}

AddFunction SurvivalCdsShortCdPostConditions
{
}

AddFunction SurvivalCdsCdActions
{
 #arcane_torrent,if=focus<=30
 if Focus() <= 30 Spell(arcane_torrent_focus)
 #berserking,if=buff.aspect_of_the_eagle.up
 if BuffPresent(aspect_of_the_eagle_buff) Spell(berserking)
 #blood_fury,if=buff.aspect_of_the_eagle.up
 if BuffPresent(aspect_of_the_eagle_buff) Spell(blood_fury_ap)
 #potion,if=buff.aspect_of_the_eagle.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
 # if BuffPresent(aspect_of_the_eagle_buff) and { BuffPresent(berserking_buff) or BuffPresent(blood_fury_ap_buff) or not Race(Troll) and not Race(Orc) } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

 unless SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and SpellCooldown(aspect_of_the_eagle) > 5 and not BuffPresent(aspect_of_the_eagle_buff) and Spell(snake_hunter)
 {
  #aspect_of_the_eagle,if=buff.mongoose_fury.up&(cooldown.mongoose_bite.charges=0|buff.mongoose_fury.remains<11)
  if BuffPresent(mongoose_fury_buff) and { SpellCharges(mongoose_bite) == 0 or BuffRemaining(mongoose_fury_buff) < 11 } Spell(aspect_of_the_eagle)
 }
}

AddFunction SurvivalCdsCdPostConditions
{
 SpellCharges(mongoose_bite) == 0 and BuffRemaining(mongoose_fury_buff) > 3 * GCD() and SpellCooldown(aspect_of_the_eagle) > 5 and not BuffPresent(aspect_of_the_eagle_buff) and Spell(snake_hunter)
}

### actions.default

AddFunction SurvivalDefaultMainActions
{
 #call_action_list,name=mokMaintain,if=variable.mokTalented
 if mokTalented() SurvivalMokmaintainMainActions()

 unless mokTalented() and SurvivalMokmaintainMainPostConditions()
 {
  #call_action_list,name=CDs
  SurvivalCdsMainActions()

  unless SurvivalCdsMainPostConditions()
  {
   #call_action_list,name=aoe,if=active_enemies>=3
   if Enemies(tagged=1) >= 3 SurvivalAoeMainActions()

   unless Enemies(tagged=1) >= 3 and SurvivalAoeMainPostConditions()
   {
    #call_action_list,name=fillers,if=!buff.mongoose_fury.up
    if not BuffPresent(mongoose_fury_buff) SurvivalFillersMainActions()

    unless not BuffPresent(mongoose_fury_buff) and SurvivalFillersMainPostConditions()
    {
     #call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
     if not BuffPresent(mongoose_fury_buff) SurvivalBitetriggerMainActions()

     unless not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerMainPostConditions()
     {
      #call_action_list,name=bitePhase,if=buff.mongoose_fury.up
      if BuffPresent(mongoose_fury_buff) SurvivalBitephaseMainActions()
     }
    }
   }
  }
 }
}

AddFunction SurvivalDefaultMainPostConditions
{
 mokTalented() and SurvivalMokmaintainMainPostConditions() or SurvivalCdsMainPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeMainPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalFillersMainPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerMainPostConditions() or BuffPresent(mongoose_fury_buff) and SurvivalBitephaseMainPostConditions()
}

AddFunction SurvivalDefaultShortCdActions
{
 #auto_attack
 # SurvivalGetInMeleeRange()
 #call_action_list,name=mokMaintain,if=variable.mokTalented
 if mokTalented() SurvivalMokmaintainShortCdActions()

 unless mokTalented() and SurvivalMokmaintainShortCdPostConditions()
 {
  #call_action_list,name=CDs
  SurvivalCdsShortCdActions()

  unless SurvivalCdsShortCdPostConditions()
  {
   #call_action_list,name=aoe,if=active_enemies>=3
   if Enemies(tagged=1) >= 3 SurvivalAoeShortCdActions()

   unless Enemies(tagged=1) >= 3 and SurvivalAoeShortCdPostConditions()
   {
    #call_action_list,name=fillers,if=!buff.mongoose_fury.up
    if not BuffPresent(mongoose_fury_buff) SurvivalFillersShortCdActions()

    unless not BuffPresent(mongoose_fury_buff) and SurvivalFillersShortCdPostConditions()
    {
     #call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
     if not BuffPresent(mongoose_fury_buff) SurvivalBitetriggerShortCdActions()

     unless not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerShortCdPostConditions()
     {
      #call_action_list,name=bitePhase,if=buff.mongoose_fury.up
      if BuffPresent(mongoose_fury_buff) SurvivalBitephaseShortCdActions()
     }
    }
   }
  }
 }
}

AddFunction SurvivalDefaultShortCdPostConditions
{
 mokTalented() and SurvivalMokmaintainShortCdPostConditions() or SurvivalCdsShortCdPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeShortCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalFillersShortCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerShortCdPostConditions() or BuffPresent(mongoose_fury_buff) and SurvivalBitephaseShortCdPostConditions()
}

AddFunction SurvivalDefaultCdActions
{
 #variable,name=frizzosEquipped,value=(equipped.137043)
 #variable,name=mokTalented,value=(talent.way_of_the_moknathal.enabled)
 #use_items
 # SurvivalUseItemActions()
 #muzzle,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
 if HasEquippedItem(sephuzs_secret) and target.IsInterruptible() and not SpellCooldown(buff_sephuzs_secret) > 0 and not BuffPresent(sephuzs_secret_buff) InterruptActions()
 #call_action_list,name=mokMaintain,if=variable.mokTalented
 if mokTalented() SurvivalMokmaintainCdActions()

 unless mokTalented() and SurvivalMokmaintainCdPostConditions()
 {
  #call_action_list,name=CDs
  SurvivalCdsCdActions()

  unless SurvivalCdsCdPostConditions()
  {
   #call_action_list,name=aoe,if=active_enemies>=3
   if Enemies(tagged=1) >= 3 SurvivalAoeCdActions()

   unless Enemies(tagged=1) >= 3 and SurvivalAoeCdPostConditions()
   {
    #call_action_list,name=fillers,if=!buff.mongoose_fury.up
    if not BuffPresent(mongoose_fury_buff) SurvivalFillersCdActions()

    unless not BuffPresent(mongoose_fury_buff) and SurvivalFillersCdPostConditions()
    {
     #call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
     if not BuffPresent(mongoose_fury_buff) SurvivalBitetriggerCdActions()

     unless not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerCdPostConditions()
     {
      #call_action_list,name=bitePhase,if=buff.mongoose_fury.up
      if BuffPresent(mongoose_fury_buff) SurvivalBitephaseCdActions()
     }
    }
   }
  }
 }
}

AddFunction SurvivalDefaultCdPostConditions
{
 mokTalented() and SurvivalMokmaintainCdPostConditions() or SurvivalCdsCdPostConditions() or Enemies(tagged=1) >= 3 and SurvivalAoeCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalFillersCdPostConditions() or not BuffPresent(mongoose_fury_buff) and SurvivalBitetriggerCdPostConditions() or BuffPresent(mongoose_fury_buff) and SurvivalBitephaseCdPostConditions()
}

### actions.aoe

AddFunction SurvivalAoeMainActions
{
 #butchery
 Spell(butchery)
 #caltrops,if=!ticking
 if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
 #carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)
 if Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 Spell(carve)
}

AddFunction SurvivalAoeMainPostConditions
{
}

AddFunction SurvivalAoeShortCdActions
{
 unless Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
 {
  #explosive_trap
  Spell(explosive_trap)
 }
}

AddFunction SurvivalAoeShortCdPostConditions
{
 Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or { Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 } and Spell(carve)
}

AddFunction SurvivalAoeCdActions
{
}

AddFunction SurvivalAoeCdPostConditions
{
 Spell(butchery) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Spell(explosive_trap) or { Talent(serpent_sting_talent) and target.DebuffRefreshable(serpent_sting_debuff) or Enemies(tagged=1) > 5 } and Spell(carve)
}

### actions.bitePhase

AddFunction SurvivalBitephaseMainActions
{
 #mongoose_bite,if=cooldown.mongoose_bite.charges=3
 if SpellCharges(mongoose_bite) == 3 Spell(mongoose_bite)
 #flanking_strike,if=buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+1))
 if BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 1 } Spell(flanking_strike)
 #mongoose_bite,if=buff.mongoose_fury.up
 if BuffPresent(mongoose_fury_buff) Spell(mongoose_bite)
 #lacerate,if=dot.lacerate.refreshable&(focus>((50+35)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
 if target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 35 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() Spell(lacerate)
 #raptor_strike,if=buff.t21_2p_exposed_flank.up
 if BuffPresent(t21_2p_exposed_flank_buff) Spell(raptor_strike)
 #caltrops,if=!ticking
 if not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
}

AddFunction SurvivalBitephaseMainPostConditions
{
}

AddFunction SurvivalBitephaseShortCdActions
{
 unless SpellCharges(mongoose_bite) == 3 and Spell(mongoose_bite) or BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 1 } and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite)
 {
  #fury_of_the_eagle,if=(!variable.mokTalented|(buff.moknathal_tactics.remains>(gcd*(8%3))))&!buff.aspect_of_the_eagle.up
  if { not mokTalented() or BuffRemaining(moknathal_tactics_buff) > GCD() * { 8 / 3 } } and not BuffPresent(aspect_of_the_eagle_buff) Spell(fury_of_the_eagle)

  unless target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 35 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and Spell(raptor_strike)
  {
   #spitting_cobra
   Spell(spitting_cobra)
   #dragonsfire_grenade
   Spell(dragonsfire_grenade)
   #steel_trap
   Spell(steel_trap)
   #a_murder_of_crows
   Spell(a_murder_of_crows)

   unless not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
   {
    #explosive_trap
    Spell(explosive_trap)
   }
  }
 }
}

AddFunction SurvivalBitephaseShortCdPostConditions
{
 SpellCharges(mongoose_bite) == 3 and Spell(mongoose_bite) or BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 1 } and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 35 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and Spell(raptor_strike) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops)
}

AddFunction SurvivalBitephaseCdActions
{
}

AddFunction SurvivalBitephaseCdPostConditions
{
 SpellCharges(mongoose_bite) == 3 and Spell(mongoose_bite) or BuffRemaining(mongoose_fury_buff) > GCD() * { SpellCharges(mongoose_bite) + 1 } and Spell(flanking_strike) or BuffPresent(mongoose_fury_buff) and Spell(mongoose_bite) or { not mokTalented() or BuffRemaining(moknathal_tactics_buff) > GCD() * { 8 / 3 } } and not BuffPresent(aspect_of_the_eagle_buff) and Spell(fury_of_the_eagle) or target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 35 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and Spell(raptor_strike) or Spell(spitting_cobra) or Spell(dragonsfire_grenade) or Spell(steel_trap) or Spell(a_murder_of_crows) or not target.DebuffPresent(caltrops_debuff) and Spell(caltrops) or Spell(explosive_trap)
}

### actions.biteTrigger

AddFunction SurvivalBitetriggerMainActions
{
 #lacerate,if=remains<14&set_bonus.tier20_4pc&cooldown.mongoose_bite.remains<gcd*3
 if target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 4) and SpellCooldown(mongoose_bite) < GCD() * 3 Spell(lacerate)
 #mongoose_bite,if=charges>=2
 if Charges(mongoose_bite) >= 2 Spell(mongoose_bite)
}

AddFunction SurvivalBitetriggerMainPostConditions
{
}

AddFunction SurvivalBitetriggerShortCdActions
{
}

AddFunction SurvivalBitetriggerShortCdPostConditions
{
 target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 4) and SpellCooldown(mongoose_bite) < GCD() * 3 and Spell(lacerate) or Charges(mongoose_bite) >= 2 and Spell(mongoose_bite)
}

AddFunction SurvivalBitetriggerCdActions
{
}

AddFunction SurvivalBitetriggerCdPostConditions
{
 target.DebuffRemaining(lacerate_debuff) < 14 and ArmorSetBonus(T20 4) and SpellCooldown(mongoose_bite) < GCD() * 3 and Spell(lacerate) or Charges(mongoose_bite) >= 2 and Spell(mongoose_bite)
}

### actions.fillers

AddFunction SurvivalFillersMainActions
{
 #flanking_strike,if=cooldown.mongoose_bite.charges<3
 if SpellCharges(mongoose_bite) < 3 Spell(flanking_strike)
 #lacerate,if=refreshable|!ticking
 if target.Refreshable(lacerate_debuff) or not target.DebuffPresent(lacerate_debuff) Spell(lacerate)
 #raptor_strike,if=buff.t21_2p_exposed_flank.up&!variable.mokTalented
 if BuffPresent(t21_2p_exposed_flank_buff) and not mokTalented() Spell(raptor_strike)
 #raptor_strike,if=(talent.serpent_sting.enabled&!dot.serpent_sting.ticking)
 if Talent(serpent_sting_talent) and not target.DebuffPresent(serpent_sting_debuff) Spell(raptor_strike)
 #caltrops,if=refreshable|!ticking
 if target.Refreshable(caltrops_debuff) or not target.DebuffPresent(caltrops_debuff) Spell(caltrops)
 #butchery,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
 if frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() Spell(butchery)
 #carve,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus>((50+40)-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
 if frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() Spell(carve)
 #flanking_strike
 Spell(flanking_strike)
 #raptor_strike,if=(variable.mokTalented&buff.moknathal_tactics.remains<gcd*4)|(focus>((75-focus.regen*gcd)))
 if mokTalented() and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 75 - FocusRegenRate() * GCD() Spell(raptor_strike)
}

AddFunction SurvivalFillersMainPostConditions
{
}

AddFunction SurvivalFillersShortCdActions
{
 unless SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike)
 {
  #spitting_cobra
  Spell(spitting_cobra)
  #dragonsfire_grenade
  Spell(dragonsfire_grenade)

  unless { target.Refreshable(lacerate_debuff) or not target.DebuffPresent(lacerate_debuff) } and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and not mokTalented() and Spell(raptor_strike) or Talent(serpent_sting_talent) and not target.DebuffPresent(serpent_sting_debuff) and Spell(raptor_strike)
  {
   #steel_trap,if=refreshable|!ticking
   if target.Refreshable(steel_trap_debuff) or not target.DebuffPresent(steel_trap_debuff) Spell(steel_trap)

   unless { target.Refreshable(caltrops_debuff) or not target.DebuffPresent(caltrops_debuff) } and Spell(caltrops)
   {
    #explosive_trap
    Spell(explosive_trap)
   }
  }
 }
}

AddFunction SurvivalFillersShortCdPostConditions
{
 SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or { target.Refreshable(lacerate_debuff) or not target.DebuffPresent(lacerate_debuff) } and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and not mokTalented() and Spell(raptor_strike) or Talent(serpent_sting_talent) and not target.DebuffPresent(serpent_sting_debuff) and Spell(raptor_strike) or { target.Refreshable(caltrops_debuff) or not target.DebuffPresent(caltrops_debuff) } and Spell(caltrops) or frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(butchery) or frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(carve) or Spell(flanking_strike) or { mokTalented() and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 75 - FocusRegenRate() * GCD() } and Spell(raptor_strike)
}

AddFunction SurvivalFillersCdActions
{
}

AddFunction SurvivalFillersCdPostConditions
{
 SpellCharges(mongoose_bite) < 3 and Spell(flanking_strike) or Spell(spitting_cobra) or Spell(dragonsfire_grenade) or { target.Refreshable(lacerate_debuff) or not target.DebuffPresent(lacerate_debuff) } and Spell(lacerate) or BuffPresent(t21_2p_exposed_flank_buff) and not mokTalented() and Spell(raptor_strike) or Talent(serpent_sting_talent) and not target.DebuffPresent(serpent_sting_debuff) and Spell(raptor_strike) or { target.Refreshable(steel_trap_debuff) or not target.DebuffPresent(steel_trap_debuff) } and Spell(steel_trap) or { target.Refreshable(caltrops_debuff) or not target.DebuffPresent(caltrops_debuff) } and Spell(caltrops) or Spell(explosive_trap) or frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(butchery) or frizzosEquipped() and target.DebuffRefreshable(lacerate_debuff) and Focus() > 50 + 40 - SpellCooldown(flanking_strike) / GCD() * FocusRegenRate() * GCD() and Spell(carve) or Spell(flanking_strike) or { mokTalented() and BuffRemaining(moknathal_tactics_buff) < GCD() * 4 or Focus() > 75 - FocusRegenRate() * GCD() } and Spell(raptor_strike)
}

### actions.mokMaintain

AddFunction SurvivalMokmaintainMainActions
{
 #raptor_strike,if=(buff.moknathal_tactics.remains<(gcd)|(buff.moknathal_tactics.stack<3))
 if BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 3 Spell(raptor_strike)
}

AddFunction SurvivalMokmaintainMainPostConditions
{
}

AddFunction SurvivalMokmaintainShortCdActions
{
}

AddFunction SurvivalMokmaintainShortCdPostConditions
{
 { BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 3 } and Spell(raptor_strike)
}

AddFunction SurvivalMokmaintainCdActions
{
}

AddFunction SurvivalMokmaintainCdPostConditions
{
 { BuffRemaining(moknathal_tactics_buff) < GCD() or BuffStacks(moknathal_tactics_buff) < 3 } and Spell(raptor_strike)
}

### actions.precombat

AddFunction SurvivalPrecombatMainActions
{
 #harpoon
 # if CheckBoxOn(opt_harpoon) Spell(harpoon)
}

AddFunction SurvivalPrecombatMainPostConditions
{
}

AddFunction SurvivalPrecombatShortCdActions
{
 #flask
 #augmentation
 #food
 #summon_pet
 # SurvivalSummonPet()
 #explosive_trap
 Spell(explosive_trap)
 #steel_trap
 Spell(steel_trap)
 #dragonsfire_grenade
 Spell(dragonsfire_grenade)
}

AddFunction SurvivalPrecombatShortCdPostConditions
{
 Spell(harpoon)
}

AddFunction SurvivalPrecombatCdActions
{
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction SurvivalPrecombatCdPostConditions
{
 Spell(explosive_trap) or Spell(steel_trap) or Spell(dragonsfire_grenade)
}
]]

	OvaleScripts:RegisterScript("HUNTER", "survival", name, desc, code, "script")
end
