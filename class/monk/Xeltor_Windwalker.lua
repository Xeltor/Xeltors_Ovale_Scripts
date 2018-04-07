local __Scripts = LibStub:GetLibrary("ovale/Scripts")
local OvaleScripts = __Scripts.OvaleScripts

do
	local name = "xeltor_windwalker"
	local desc = "[Xel][7.3.5] Monk: Windwalker"
	local code = [[
Include(ovale_common)
Include(ovale_trinkets_mop)
Include(ovale_trinkets_wod)
Include(ovale_monk_spells)

Define(ring_of_peace 116844)
Define(leg_sweep 119381)

# Windwalker
AddIcon specialization=3 help=main
{
    # if not mounted() and not {BuffPresent(critical_strike_buff any=1) or BuffPresent(str_agi_int_buff any=1)} Spell(legacy_of_the_white_tiger)
    
	#spear_hand_strike
	if InCombat() InterruptActions()
	
	if target.InRange(tiger_palm) and HasFullControl()
    {
		# Cooldowns
		if Boss()
		{
			WindwalkerDefaultCdActions()
		}
		
		WindwalkerDefaultShortCdActions()
		
		WindwalkerDefaultMainActions()
    }
}

AddFunction Boss
{
	IsBossFight() or target.Classification(rareelite) or BuffPresent(burst_haste_buff any=1) or { target.IsPvP() and not target.IsFriend() }  
}

AddFunction InterruptActions
{
	if not target.IsFriend() and target.IsInterruptible() and { target.MustBeInterrupted() or Level() < 100 or target.IsPVP() }
	{
		if target.InRange(spear_hand_strike) Spell(spear_hand_strike)
		if not target.Classification(worldboss)
		{
			if target.InRange(paralysis) Spell(paralysis)
			if target.InRange(spear_hand_strike) Spell(arcane_torrent_chi)
			if target.InRange(quaking_palm) Spell(quaking_palm)
			if target.InRange(spear_hand_strike) Spell(leg_sweep)
			if target.InRange(spear_hand_strike) Spell(ring_of_peace)
			if target.InRange(spear_hand_strike) Spell(war_stomp)
		}
	}
}

### actions.default

AddFunction WindwalkerDefaultMainActions
{
 #touch_of_death,if=target.time_to_die<=9
 if target.TimeToDie() <= 9 and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } Spell(touch_of_death)
 #call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
 if Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) WindwalkerSerenityMainActions()

 unless { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityMainPostConditions()
 {
  #call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
  if not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } WindwalkerSefMainActions()

  unless not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefMainPostConditions()
  {
   #call_action_list,name=sef,if=!talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=18&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=25|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
   if not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefMainActions()

   unless not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefMainPostConditions()
   {
    #call_action_list,name=sef,if=!talent.serenity.enabled&!equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=15|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
    if not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefMainActions()

    unless not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefMainPostConditions()
    {
     #call_action_list,name=aoe,if=active_enemies>3
     if Enemies(tagged=1) > 3 WindwalkerAoeMainActions()

     unless Enemies(tagged=1) > 3 and WindwalkerAoeMainPostConditions()
     {
      #call_action_list,name=st,if=active_enemies<=3
      if Enemies(tagged=1) <= 3 WindwalkerStMainActions()
     }
    }
   }
  }
 }
}

AddFunction WindwalkerDefaultMainPostConditions
{
 { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityMainPostConditions() or not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefMainPostConditions() or not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefMainPostConditions() or not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefMainPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeMainPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStMainPostConditions()
}

AddFunction WindwalkerDefaultShortCdActions
{
 #auto_attack
 # WindwalkerGetInMeleeRange()

 unless target.TimeToDie() <= 9 and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death)
 {
  #call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
  if Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) WindwalkerSerenityShortCdActions()

  unless { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityShortCdPostConditions()
  {
   #call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
   if not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } WindwalkerSefShortCdActions()

   unless not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefShortCdPostConditions()
   {
    #call_action_list,name=sef,if=!talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=18&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=25|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
    if not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefShortCdActions()

    unless not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefShortCdPostConditions()
    {
     #call_action_list,name=sef,if=!talent.serenity.enabled&!equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=15|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
     if not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefShortCdActions()

     unless not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefShortCdPostConditions()
     {
      #call_action_list,name=aoe,if=active_enemies>3
      if Enemies(tagged=1) > 3 WindwalkerAoeShortCdActions()

      unless Enemies(tagged=1) > 3 and WindwalkerAoeShortCdPostConditions()
      {
       #call_action_list,name=st,if=active_enemies<=3
       if Enemies(tagged=1) <= 3 WindwalkerStShortCdActions()
      }
     }
    }
   }
  }
 }
}

AddFunction WindwalkerDefaultShortCdPostConditions
{
 target.TimeToDie() <= 9 and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityShortCdPostConditions() or not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefShortCdPostConditions() or not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefShortCdPostConditions() or not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefShortCdPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeShortCdPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStShortCdPostConditions()
}

AddFunction WindwalkerDefaultCdActions
{
 #spear_hand_strike,if=target.debuff.casting.react
 # if target.IsInterruptible() WindwalkerInterruptActions()
 #touch_of_karma,interval=90,pct_health=0.5
 # if CheckBoxOn(opt_touch_of_karma) Spell(touch_of_karma)
 #potion,if=buff.serenity.up|buff.storm_earth_and_fire.up|(!talent.serenity.enabled&trinket.proc.agility.react)|buff.bloodlust.react|target.time_to_die<=60
 # if { BuffPresent(serenity_buff) or BuffPresent(storm_earth_and_fire_buff) or not Talent(serenity_talent) and BuffPresent(trinket_proc_agility_buff) or BuffPresent(burst_haste_buff any=1) or target.TimeToDie() <= 60 } and CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)

 unless target.TimeToDie() <= 9 and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death)
 {
  #call_action_list,name=serenity,if=(talent.serenity.enabled&cooldown.serenity.remains<=0)|buff.serenity.up
  if Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) WindwalkerSerenityCdActions()

  unless { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityCdPostConditions()
  {
   #call_action_list,name=sef,if=!talent.serenity.enabled&(buff.storm_earth_and_fire.up|cooldown.storm_earth_and_fire.charges=2)
   if not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } WindwalkerSefCdActions()

   unless not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefCdPostConditions()
   {
    #call_action_list,name=sef,if=!talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=18&cooldown.fists_of_fury.remains<=12&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=25|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
    if not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefCdActions()

    unless not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefCdPostConditions()
    {
     #call_action_list,name=sef,if=!talent.serenity.enabled&!equipped.drinking_horn_cover&(cooldown.strike_of_the_windlord.remains<=14&cooldown.fists_of_fury.remains<=6&chi>=3&cooldown.rising_sun_kick.remains<=1|target.time_to_die<=15|cooldown.touch_of_death.remains>112)&cooldown.storm_earth_and_fire.charges=1
     if not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 WindwalkerSefCdActions()

     unless not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefCdPostConditions()
     {
      #call_action_list,name=aoe,if=active_enemies>3
      if Enemies(tagged=1) > 3 WindwalkerAoeCdActions()

      unless Enemies(tagged=1) > 3 and WindwalkerAoeCdPostConditions()
      {
       #call_action_list,name=st,if=active_enemies<=3
       if Enemies(tagged=1) <= 3 WindwalkerStCdActions()
      }
     }
    }
   }
  }
 }
}

AddFunction WindwalkerDefaultCdPostConditions
{
 target.TimeToDie() <= 9 and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or { Talent(serenity_talent) and SpellCooldown(serenity) <= 0 or BuffPresent(serenity_buff) } and WindwalkerSerenityCdPostConditions() or not Talent(serenity_talent) and { BuffPresent(storm_earth_and_fire_buff) or SpellCharges(storm_earth_and_fire) == 2 } and WindwalkerSefCdPostConditions() or not Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 18 and SpellCooldown(fists_of_fury) <= 12 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 25 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefCdPostConditions() or not Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and { SpellCooldown(strike_of_the_windlord) <= 14 and SpellCooldown(fists_of_fury) <= 6 and Chi() >= 3 and SpellCooldown(rising_sun_kick) <= 1 or target.TimeToDie() <= 15 or SpellCooldown(touch_of_death) > 112 } and SpellCharges(storm_earth_and_fire) == 1 and WindwalkerSefCdPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeCdPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStCdPostConditions()
}

### actions.aoe

AddFunction WindwalkerAoeMainActions
{
 #call_action_list,name=cd
 WindwalkerCdMainActions()

 unless WindwalkerCdMainPostConditions()
 {
  #fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
  if Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
  if Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
  if not Talent(serenity_talent) and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=cooldown.rising_sun_kick.remains>=3.5&chi<=5
  if SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 Spell(fists_of_fury)
  #whirling_dragon_punch
  if SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 Spell(whirling_dragon_punch)
  #strike_of_the_windlord,if=!talent.serenity.enabled|cooldown.serenity.remains>=10
  if not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 Spell(strike_of_the_windlord)
  #rising_sun_kick,target_if=cooldown.whirling_dragon_punch.remains>=gcd&!prev_gcd.1.rising_sun_kick&cooldown.fists_of_fury.remains>gcd
  if SpellCooldown(whirling_dragon_punch) >= GCD() and not PreviousGCDSpell(rising_sun_kick) and SpellCooldown(fists_of_fury) > GCD() Spell(rising_sun_kick)
  #rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.1.rushing_jade_wind
  if MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) Spell(rushing_jade_wind)
  #chi_burst,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
  if Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 Spell(chi_burst)
  #chi_burst
  Spell(chi_burst)
  #spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi=chi.max))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
  if { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) Spell(spinning_crane_kick)
  #spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
  if Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) Spell(spinning_crane_kick)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled)
  if not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } Spell(blackout_kick)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!artifact.strike_of_the_windlord.enabled|cooldown.strike_of_the_windlord.remains>1)|chi>4)&(cooldown.fists_of_fury.remains>1|chi>2)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
  if { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) Spell(blackout_kick)
  #crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
  if HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 Spell(crackling_jade_lightning)
  #crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
  if HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 Spell(crackling_jade_lightning)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
  if not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) Spell(blackout_kick)
  #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)
  if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } Spell(tiger_palm)
  #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2
  if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 Spell(tiger_palm)
  #chi_wave,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
  if Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 Spell(chi_wave)
  #chi_wave
  Spell(chi_wave)
 }
}

AddFunction WindwalkerAoeMainPostConditions
{
 WindwalkerCdMainPostConditions()
}

AddFunction WindwalkerAoeShortCdActions
{
 #call_action_list,name=cd
 WindwalkerCdShortCdActions()

 unless WindwalkerCdShortCdPostConditions()
 {
  #energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&(cooldown.rising_sun_kick.remains=0|(artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains=0)|energy<50)
  if not PreviousGCDSpell(tiger_palm) and Chi() <= 1 and { not SpellCooldown(rising_sun_kick) > 0 or HasArtifactTrait(strike_of_the_windlord) and not SpellCooldown(strike_of_the_windlord) > 0 or Energy() < 50 } Spell(energizing_elixir)
 }
}

AddFunction WindwalkerAoeShortCdPostConditions
{
 WindwalkerCdShortCdPostConditions() or Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or not Talent(serenity_talent) and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 and Spell(fists_of_fury) or SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 and Spell(whirling_dragon_punch) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 } and Spell(strike_of_the_windlord) or SpellCooldown(whirling_dragon_punch) >= GCD() and not PreviousGCDSpell(rising_sun_kick) and SpellCooldown(fists_of_fury) > GCD() and Spell(rising_sun_kick) or MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) and Spell(rushing_jade_wind) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_burst) or Spell(chi_burst) or { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) and Spell(spinning_crane_kick) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } and Spell(blackout_kick) or { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } and Spell(tiger_palm) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 and Spell(tiger_palm) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_wave) or Spell(chi_wave)
}

AddFunction WindwalkerAoeCdActions
{
 #call_action_list,name=cd
 WindwalkerCdCdActions()

 unless WindwalkerCdCdPostConditions()
 {
  #arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
  if MaxChi() - Chi() >= 1 and TimeToMaxEnergy() >= 0.5 Spell(arcane_torrent_chi)
 }
}

AddFunction WindwalkerAoeCdPostConditions
{
 WindwalkerCdCdPostConditions() or Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or not Talent(serenity_talent) and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 and Spell(fists_of_fury) or SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 and Spell(whirling_dragon_punch) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 } and Spell(strike_of_the_windlord) or SpellCooldown(whirling_dragon_punch) >= GCD() and not PreviousGCDSpell(rising_sun_kick) and SpellCooldown(fists_of_fury) > GCD() and Spell(rising_sun_kick) or MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) and Spell(rushing_jade_wind) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_burst) or Spell(chi_burst) or { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) and Spell(spinning_crane_kick) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } and Spell(blackout_kick) or { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } and Spell(tiger_palm) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 and Spell(tiger_palm) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_wave) or Spell(chi_wave)
}

### actions.cd

AddFunction WindwalkerCdMainActions
{
 #invoke_xuen_the_white_tiger
 Spell(invoke_xuen_the_white_tiger)
 #touch_of_death,cycle_targets=1,max_cycle_targets=2,if=!artifact.gale_burst.enabled&equipped.hidden_masters_forbidden_touch&!prev_gcd.1.touch_of_death
 if DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and not HasArtifactTrait(gale_burst) and HasEquippedItem(hidden_masters_forbidden_touch) and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } Spell(touch_of_death)
 #touch_of_death,if=!artifact.gale_burst.enabled&!equipped.hidden_masters_forbidden_touch
 if not HasArtifactTrait(gale_burst) and not HasEquippedItem(hidden_masters_forbidden_touch) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } Spell(touch_of_death)
 #touch_of_death,cycle_targets=1,max_cycle_targets=2,if=artifact.gale_burst.enabled&((talent.serenity.enabled&cooldown.serenity.remains<=1)|chi>=2)&(cooldown.strike_of_the_windlord.remains<8|cooldown.fists_of_fury.remains<=4)&cooldown.rising_sun_kick.remains<7&!prev_gcd.1.touch_of_death
 if DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and HasArtifactTrait(gale_burst) and { Talent(serenity_talent) and SpellCooldown(serenity) <= 1 or Chi() >= 2 } and { SpellCooldown(strike_of_the_windlord) < 8 or SpellCooldown(fists_of_fury) <= 4 } and SpellCooldown(rising_sun_kick) < 7 and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } Spell(touch_of_death)
}

AddFunction WindwalkerCdMainPostConditions
{
}

AddFunction WindwalkerCdShortCdActions
{
}

AddFunction WindwalkerCdShortCdPostConditions
{
 Spell(invoke_xuen_the_white_tiger) or DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and not HasArtifactTrait(gale_burst) and HasEquippedItem(hidden_masters_forbidden_touch) and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or not HasArtifactTrait(gale_burst) and not HasEquippedItem(hidden_masters_forbidden_touch) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and HasArtifactTrait(gale_burst) and { Talent(serenity_talent) and SpellCooldown(serenity) <= 1 or Chi() >= 2 } and { SpellCooldown(strike_of_the_windlord) < 8 or SpellCooldown(fists_of_fury) <= 4 } and SpellCooldown(rising_sun_kick) < 7 and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death)
}

AddFunction WindwalkerCdCdActions
{
 unless Spell(invoke_xuen_the_white_tiger)
 {
  #blood_fury
  Spell(blood_fury_apsp)
  #berserking
  Spell(berserking)
  #arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
  if MaxChi() - Chi() >= 1 and TimeToMaxEnergy() >= 0.5 Spell(arcane_torrent_chi)
 }
}

AddFunction WindwalkerCdCdPostConditions
{
 Spell(invoke_xuen_the_white_tiger) or DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and not HasArtifactTrait(gale_burst) and HasEquippedItem(hidden_masters_forbidden_touch) and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or not HasArtifactTrait(gale_burst) and not HasEquippedItem(hidden_masters_forbidden_touch) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death) or DebuffCountOnAny(touch_of_death_debuff) < Enemies(tagged=1) and DebuffCountOnAny(touch_of_death_debuff) <= 2 and HasArtifactTrait(gale_burst) and { Talent(serenity_talent) and SpellCooldown(serenity) <= 1 or Chi() >= 2 } and { SpellCooldown(strike_of_the_windlord) < 8 or SpellCooldown(fists_of_fury) <= 4 } and SpellCooldown(rising_sun_kick) < 7 and not PreviousGCDSpell(touch_of_death) and { not UnitInRaid() and target.Classification(elite) or target.Classification(worldboss) or not BuffExpires(hidden_masters_forbidden_touch_buff) } and Spell(touch_of_death)
}

### actions.precombat

AddFunction WindwalkerPrecombatMainActions
{
 #chi_burst
 Spell(chi_burst)
 #chi_wave
 Spell(chi_wave)
}

AddFunction WindwalkerPrecombatMainPostConditions
{
}

AddFunction WindwalkerPrecombatShortCdActions
{
}

AddFunction WindwalkerPrecombatShortCdPostConditions
{
 Spell(chi_burst) or Spell(chi_wave)
}

AddFunction WindwalkerPrecombatCdActions
{
 #flask
 #food
 #augmentation
 #snapshot_stats
 #potion
 # if CheckBoxOn(opt_use_consumables) and target.Classification(worldboss) Item(prolonged_power_potion usable=1)
}

AddFunction WindwalkerPrecombatCdPostConditions
{
 Spell(chi_burst) or Spell(chi_wave)
}

### actions.sef

AddFunction WindwalkerSefMainActions
{
 #tiger_palm,target_if=debuff.mark_of_the_crane.down,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1
 if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and target.DebuffExpires(mark_of_the_crane_debuff) Spell(tiger_palm)
 #call_action_list,name=cd
 WindwalkerCdMainActions()

 unless WindwalkerCdMainPostConditions()
 {
  #call_action_list,name=aoe,if=active_enemies>3
  if Enemies(tagged=1) > 3 WindwalkerAoeMainActions()

  unless Enemies(tagged=1) > 3 and WindwalkerAoeMainPostConditions()
  {
   #call_action_list,name=st,if=active_enemies<=3
   if Enemies(tagged=1) <= 3 WindwalkerStMainActions()
  }
 }
}

AddFunction WindwalkerSefMainPostConditions
{
 WindwalkerCdMainPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeMainPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStMainPostConditions()
}

AddFunction WindwalkerSefShortCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and target.DebuffExpires(mark_of_the_crane_debuff) and Spell(tiger_palm)
 {
  #call_action_list,name=cd
  WindwalkerCdShortCdActions()

  unless WindwalkerCdShortCdPostConditions()
  {
   #call_action_list,name=aoe,if=active_enemies>3
   if Enemies(tagged=1) > 3 WindwalkerAoeShortCdActions()

   unless Enemies(tagged=1) > 3 and WindwalkerAoeShortCdPostConditions()
   {
    #call_action_list,name=st,if=active_enemies<=3
    if Enemies(tagged=1) <= 3 WindwalkerStShortCdActions()
   }
  }
 }
}

AddFunction WindwalkerSefShortCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and target.DebuffExpires(mark_of_the_crane_debuff) and Spell(tiger_palm) or WindwalkerCdShortCdPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeShortCdPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStShortCdPostConditions()
}

AddFunction WindwalkerSefCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and target.DebuffExpires(mark_of_the_crane_debuff) and Spell(tiger_palm)
 {
  #arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
  if MaxChi() - Chi() >= 1 and TimeToMaxEnergy() >= 0.5 Spell(arcane_torrent_chi)
  #call_action_list,name=cd
  WindwalkerCdCdActions()

  unless WindwalkerCdCdPostConditions()
  {
   #storm_earth_and_fire,if=!buff.storm_earth_and_fire.up
   if not BuffPresent(storm_earth_and_fire_buff) Spell(storm_earth_and_fire)
   #call_action_list,name=aoe,if=active_enemies>3
   if Enemies(tagged=1) > 3 WindwalkerAoeCdActions()

   unless Enemies(tagged=1) > 3 and WindwalkerAoeCdPostConditions()
   {
    #call_action_list,name=st,if=active_enemies<=3
    if Enemies(tagged=1) <= 3 WindwalkerStCdActions()
   }
  }
 }
}

AddFunction WindwalkerSefCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and target.DebuffExpires(mark_of_the_crane_debuff) and Spell(tiger_palm) or WindwalkerCdCdPostConditions() or Enemies(tagged=1) > 3 and WindwalkerAoeCdPostConditions() or Enemies(tagged=1) <= 3 and WindwalkerStCdPostConditions()
}

### actions.serenity

AddFunction WindwalkerSerenityMainActions
{
 #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up
 if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) Spell(tiger_palm)
 #call_action_list,name=cd
 WindwalkerCdMainActions()

 unless WindwalkerCdMainPostConditions()
 {
  #rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies<3
  if Enemies(tagged=1) < 3 Spell(rising_sun_kick)
  #strike_of_the_windlord
  Spell(strike_of_the_windlord)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(!prev_gcd.1.blackout_kick)&(prev_gcd.1.strike_of_the_windlord|prev_gcd.1.fists_of_fury)&active_enemies<2
  if not PreviousGCDSpell(blackout_kick) and { PreviousGCDSpell(strike_of_the_windlord) or PreviousGCDSpell(fists_of_fury) } and Enemies(tagged=1) < 2 Spell(blackout_kick)
  #fists_of_fury,if=((equipped.drinking_horn_cover&buff.pressure_point.remains<=2&set_bonus.tier20_4pc)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
  if HasEquippedItem(drinking_horn_cover) and BuffRemaining(pressure_point_buff) <= 2 and ArmorSetBonus(T20 4) and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } Spell(fists_of_fury)
  #fists_of_fury,if=((!equipped.drinking_horn_cover|buff.bloodlust.up|buff.serenity.remains<1)&(cooldown.rising_sun_kick.remains>1|active_enemies>1)),interrupt=1
  if { not HasEquippedItem(drinking_horn_cover) or BuffPresent(burst_haste_buff any=1) or BuffRemaining(serenity_buff) < 1 } and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } Spell(fists_of_fury)
  #spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
  if Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) Spell(spinning_crane_kick)
  #rushing_jade_wind,if=!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down&buff.serenity.remains>=4
  if not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and BuffRemaining(serenity_buff) >= 4 Spell(rushing_jade_wind)
  #rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies>=3
  if Enemies(tagged=1) >= 3 Spell(rising_sun_kick)
  #rushing_jade_wind,if=!prev_gcd.1.rushing_jade_wind&buff.rushing_jade_wind.down&active_enemies>1
  if not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and Enemies(tagged=1) > 1 Spell(rushing_jade_wind)
  #spinning_crane_kick,if=!prev_gcd.1.spinning_crane_kick
  if not PreviousGCDSpell(spinning_crane_kick) Spell(spinning_crane_kick)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick
  if not PreviousGCDSpell(blackout_kick) Spell(blackout_kick)
 }
}

AddFunction WindwalkerSerenityMainPostConditions
{
 WindwalkerCdMainPostConditions()
}

AddFunction WindwalkerSerenityShortCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and Spell(tiger_palm)
 {
  #call_action_list,name=cd
  WindwalkerCdShortCdActions()

  unless WindwalkerCdShortCdPostConditions()
  {
   #serenity
   Spell(serenity)
  }
 }
}

AddFunction WindwalkerSerenityShortCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and Spell(tiger_palm) or WindwalkerCdShortCdPostConditions() or Enemies(tagged=1) < 3 and Spell(rising_sun_kick) or Spell(strike_of_the_windlord) or not PreviousGCDSpell(blackout_kick) and { PreviousGCDSpell(strike_of_the_windlord) or PreviousGCDSpell(fists_of_fury) } and Enemies(tagged=1) < 2 and Spell(blackout_kick) or HasEquippedItem(drinking_horn_cover) and BuffRemaining(pressure_point_buff) <= 2 and ArmorSetBonus(T20 4) and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } and Spell(fists_of_fury) or { not HasEquippedItem(drinking_horn_cover) or BuffPresent(burst_haste_buff any=1) or BuffRemaining(serenity_buff) < 1 } and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } and Spell(fists_of_fury) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and BuffRemaining(serenity_buff) >= 4 and Spell(rushing_jade_wind) or Enemies(tagged=1) >= 3 and Spell(rising_sun_kick) or not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and Enemies(tagged=1) > 1 and Spell(rushing_jade_wind) or not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick)
}

AddFunction WindwalkerSerenityCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and Spell(tiger_palm)
 {
  #call_action_list,name=cd
  WindwalkerCdCdActions()
 }
}

AddFunction WindwalkerSerenityCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and Spell(tiger_palm) or WindwalkerCdCdPostConditions() or Enemies(tagged=1) < 3 and Spell(rising_sun_kick) or Spell(strike_of_the_windlord) or not PreviousGCDSpell(blackout_kick) and { PreviousGCDSpell(strike_of_the_windlord) or PreviousGCDSpell(fists_of_fury) } and Enemies(tagged=1) < 2 and Spell(blackout_kick) or HasEquippedItem(drinking_horn_cover) and BuffRemaining(pressure_point_buff) <= 2 and ArmorSetBonus(T20 4) and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } and Spell(fists_of_fury) or { not HasEquippedItem(drinking_horn_cover) or BuffPresent(burst_haste_buff any=1) or BuffRemaining(serenity_buff) < 1 } and { SpellCooldown(rising_sun_kick) > 1 or Enemies(tagged=1) > 1 } and Spell(fists_of_fury) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and BuffRemaining(serenity_buff) >= 4 and Spell(rushing_jade_wind) or Enemies(tagged=1) >= 3 and Spell(rising_sun_kick) or not PreviousGCDSpell(rushing_jade_wind) and BuffExpires(rushing_jade_wind_buff) and Enemies(tagged=1) > 1 and Spell(rushing_jade_wind) or not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick)
}

### actions.serenity_opener

AddFunction WindwalkerSerenityOpenerMainActions
{
 #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy=energy.max&chi<1&!buff.serenity.up&cooldown.fists_of_fury.remains<=0
 if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and SpellCooldown(fists_of_fury) <= 0 Spell(tiger_palm)
 #call_action_list,name=cd,if=cooldown.fists_of_fury.remains>1
 if SpellCooldown(fists_of_fury) > 1 WindwalkerCdMainActions()

 unless SpellCooldown(fists_of_fury) > 1 and WindwalkerCdMainPostConditions()
 {
  #rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=active_enemies<3&buff.serenity.up
  if Enemies(tagged=1) < 3 and BuffPresent(serenity_buff) Spell(rising_sun_kick)
  #strike_of_the_windlord,if=buff.serenity.up
  if BuffPresent(serenity_buff) Spell(strike_of_the_windlord)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(!prev_gcd.1.blackout_kick)&(prev_gcd.1.strike_of_the_windlord)
  if not PreviousGCDSpell(blackout_kick) and PreviousGCDSpell(strike_of_the_windlord) Spell(blackout_kick)
  #fists_of_fury,if=cooldown.rising_sun_kick.remains>1|buff.serenity.down,interrupt=1
  if SpellCooldown(rising_sun_kick) > 1 or BuffExpires(serenity_buff) Spell(fists_of_fury)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=buff.serenity.down&chi<=2&cooldown.serenity.remains<=0&prev_gcd.1.tiger_palm
  if BuffExpires(serenity_buff) and Chi() <= 2 and SpellCooldown(serenity) <= 0 and PreviousGCDSpell(tiger_palm) Spell(blackout_kick)
  #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&chi=1
  if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Chi() == 1 Spell(tiger_palm)
 }
}

AddFunction WindwalkerSerenityOpenerMainPostConditions
{
 SpellCooldown(fists_of_fury) > 1 and WindwalkerCdMainPostConditions()
}

AddFunction WindwalkerSerenityOpenerShortCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and SpellCooldown(fists_of_fury) <= 0 and Spell(tiger_palm)
 {
  #call_action_list,name=cd,if=cooldown.fists_of_fury.remains>1
  if SpellCooldown(fists_of_fury) > 1 WindwalkerCdShortCdActions()

  unless SpellCooldown(fists_of_fury) > 1 and WindwalkerCdShortCdPostConditions()
  {
   #serenity,if=cooldown.fists_of_fury.remains>1
   if SpellCooldown(fists_of_fury) > 1 Spell(serenity)
  }
 }
}

AddFunction WindwalkerSerenityOpenerShortCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and SpellCooldown(fists_of_fury) <= 0 and Spell(tiger_palm) or SpellCooldown(fists_of_fury) > 1 and WindwalkerCdShortCdPostConditions() or Enemies(tagged=1) < 3 and BuffPresent(serenity_buff) and Spell(rising_sun_kick) or BuffPresent(serenity_buff) and Spell(strike_of_the_windlord) or not PreviousGCDSpell(blackout_kick) and PreviousGCDSpell(strike_of_the_windlord) and Spell(blackout_kick) or { SpellCooldown(rising_sun_kick) > 1 or BuffExpires(serenity_buff) } and Spell(fists_of_fury) or BuffExpires(serenity_buff) and Chi() <= 2 and SpellCooldown(serenity) <= 0 and PreviousGCDSpell(tiger_palm) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Chi() == 1 and Spell(tiger_palm)
}

AddFunction WindwalkerSerenityOpenerCdActions
{
 unless not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and SpellCooldown(fists_of_fury) <= 0 and Spell(tiger_palm)
 {
  #arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
  if MaxChi() - Chi() >= 1 and TimeToMaxEnergy() >= 0.5 Spell(arcane_torrent_chi)
  #call_action_list,name=cd,if=cooldown.fists_of_fury.remains>1
  if SpellCooldown(fists_of_fury) > 1 WindwalkerCdCdActions()
 }
}

AddFunction WindwalkerSerenityOpenerCdPostConditions
{
 not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Energy() == MaxEnergy() and Chi() < 1 and not BuffPresent(serenity_buff) and SpellCooldown(fists_of_fury) <= 0 and Spell(tiger_palm) or SpellCooldown(fists_of_fury) > 1 and WindwalkerCdCdPostConditions() or Enemies(tagged=1) < 3 and BuffPresent(serenity_buff) and Spell(rising_sun_kick) or BuffPresent(serenity_buff) and Spell(strike_of_the_windlord) or not PreviousGCDSpell(blackout_kick) and PreviousGCDSpell(strike_of_the_windlord) and Spell(blackout_kick) or { SpellCooldown(rising_sun_kick) > 1 or BuffExpires(serenity_buff) } and Spell(fists_of_fury) or BuffExpires(serenity_buff) and Chi() <= 2 and SpellCooldown(serenity) <= 0 and PreviousGCDSpell(tiger_palm) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and Chi() == 1 and Spell(tiger_palm)
}

### actions.st

AddFunction WindwalkerStMainActions
{
 #call_action_list,name=cd
 WindwalkerCdMainActions()

 unless WindwalkerCdMainPostConditions()
 {
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&buff.bok_proc.up
  if not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) Spell(blackout_kick)
  #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&energy.time_to_max<=1&chi.max-chi>=2
  if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 Spell(tiger_palm)
  #strike_of_the_windlord,if=!talent.serenity.enabled|cooldown.serenity.remains>=10
  if not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 Spell(strike_of_the_windlord)
  #whirling_dragon_punch
  if SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 Spell(whirling_dragon_punch)
  #rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=((chi>=3&energy>=40)|chi>=5)&(!talent.serenity.enabled|cooldown.serenity.remains>=6)
  if { Chi() >= 3 and Energy() >= 40 or Chi() >= 5 } and { not Talent(serenity_talent) or SpellCooldown(serenity) >= 6 } Spell(rising_sun_kick)
  #fists_of_fury,if=talent.serenity.enabled&!equipped.drinking_horn_cover&cooldown.serenity.remains>=5&energy.time_to_max>2
  if Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=talent.serenity.enabled&equipped.drinking_horn_cover&(cooldown.serenity.remains>=15|cooldown.serenity.remains<=4)&energy.time_to_max>2
  if Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=!talent.serenity.enabled&energy.time_to_max>2
  if not Talent(serenity_talent) and TimeToMaxEnergy() > 2 Spell(fists_of_fury)
  #fists_of_fury,if=cooldown.rising_sun_kick.remains>=3.5&chi<=5
  if SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 Spell(fists_of_fury)
  #rising_sun_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!talent.serenity.enabled|cooldown.serenity.remains>=5
  if not Talent(serenity_talent) or SpellCooldown(serenity) >= 5 Spell(rising_sun_kick)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.blackout_kick&chi.max-chi>=1&set_bonus.tier21_4pc&(!set_bonus.tier19_2pc|talent.serenity.enabled)
  if not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } Spell(blackout_kick)
  #spinning_crane_kick,if=(active_enemies>=3|(buff.bok_proc.up&chi=chi.max))&!prev_gcd.1.spinning_crane_kick&set_bonus.tier21_4pc
  if { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) Spell(spinning_crane_kick)
  #crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=19&energy.time_to_max>3
  if HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 Spell(crackling_jade_lightning)
  #crackling_jade_lightning,if=equipped.the_emperors_capacitor&buff.the_emperors_capacitor.stack>=14&cooldown.serenity.remains<13&talent.serenity.enabled&energy.time_to_max>3
  if HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 Spell(crackling_jade_lightning)
  #spinning_crane_kick,if=active_enemies>=3&!prev_gcd.1.spinning_crane_kick
  if Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) Spell(spinning_crane_kick)
  #rushing_jade_wind,if=chi.max-chi>1&!prev_gcd.1.rushing_jade_wind
  if MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) Spell(rushing_jade_wind)
  #blackout_kick,target_if=min:debuff.mark_of_the_crane.remains,if=(chi>1|buff.bok_proc.up|(talent.energizing_elixir.enabled&cooldown.energizing_elixir.remains<cooldown.fists_of_fury.remains))&((cooldown.rising_sun_kick.remains>1&(!artifact.strike_of_the_windlord.enabled|cooldown.strike_of_the_windlord.remains>1)|chi>4)&(cooldown.fists_of_fury.remains>1|chi>2)|prev_gcd.1.tiger_palm)&!prev_gcd.1.blackout_kick
  if { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) Spell(blackout_kick)
  #chi_wave,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
  if Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 Spell(chi_wave)
  #chi_burst,if=chi<=3&(cooldown.rising_sun_kick.remains>=5|cooldown.whirling_dragon_punch.remains>=5)&energy.time_to_max>1
  if Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 Spell(chi_burst)
  #tiger_palm,target_if=min:debuff.mark_of_the_crane.remains,if=!prev_gcd.1.tiger_palm&!prev_gcd.1.energizing_elixir&(chi.max-chi>=2|energy.time_to_max<3)
  if not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } Spell(tiger_palm)
  #chi_wave
  Spell(chi_wave)
  #chi_burst
  Spell(chi_burst)
 }
}

AddFunction WindwalkerStMainPostConditions
{
 WindwalkerCdMainPostConditions()
}

AddFunction WindwalkerStShortCdActions
{
 #call_action_list,name=cd
 WindwalkerCdShortCdActions()

 unless WindwalkerCdShortCdPostConditions()
 {
  #energizing_elixir,if=!prev_gcd.1.tiger_palm&chi<=1&(cooldown.rising_sun_kick.remains=0|(artifact.strike_of_the_windlord.enabled&cooldown.strike_of_the_windlord.remains=0)|energy<50)
  if not PreviousGCDSpell(tiger_palm) and Chi() <= 1 and { not SpellCooldown(rising_sun_kick) > 0 or HasArtifactTrait(strike_of_the_windlord) and not SpellCooldown(strike_of_the_windlord) > 0 or Energy() < 50 } Spell(energizing_elixir)
 }
}

AddFunction WindwalkerStShortCdPostConditions
{
 WindwalkerCdShortCdPostConditions() or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 and Spell(tiger_palm) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 } and Spell(strike_of_the_windlord) or SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 and Spell(whirling_dragon_punch) or { Chi() >= 3 and Energy() >= 40 or Chi() >= 5 } and { not Talent(serenity_talent) or SpellCooldown(serenity) >= 6 } and Spell(rising_sun_kick) or Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or not Talent(serenity_talent) and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 and Spell(fists_of_fury) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 5 } and Spell(rising_sun_kick) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } and Spell(blackout_kick) or { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) and Spell(spinning_crane_kick) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) and Spell(rushing_jade_wind) or { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_wave) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_burst) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } and Spell(tiger_palm) or Spell(chi_wave) or Spell(chi_burst)
}

AddFunction WindwalkerStCdActions
{
 #call_action_list,name=cd
 WindwalkerCdCdActions()

 unless WindwalkerCdCdPostConditions()
 {
  #arcane_torrent,if=chi.max-chi>=1&energy.time_to_max>=0.5
  if MaxChi() - Chi() >= 1 and TimeToMaxEnergy() >= 0.5 Spell(arcane_torrent_chi)
 }
}

AddFunction WindwalkerStCdPostConditions
{
 WindwalkerCdCdPostConditions() or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and BuffPresent(bok_proc_buff) and Spell(blackout_kick) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and TimeToMaxEnergy() <= 1 and MaxChi() - Chi() >= 2 and Spell(tiger_palm) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 10 } and Spell(strike_of_the_windlord) or SpellCooldown(fists_of_fury) > 0 and SpellCooldown(rising_sun_kick) > 0 and Spell(whirling_dragon_punch) or { Chi() >= 3 and Energy() >= 40 or Chi() >= 5 } and { not Talent(serenity_talent) or SpellCooldown(serenity) >= 6 } and Spell(rising_sun_kick) or Talent(serenity_talent) and not HasEquippedItem(drinking_horn_cover) and SpellCooldown(serenity) >= 5 and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or Talent(serenity_talent) and HasEquippedItem(drinking_horn_cover) and { SpellCooldown(serenity) >= 15 or SpellCooldown(serenity) <= 4 } and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or not Talent(serenity_talent) and TimeToMaxEnergy() > 2 and Spell(fists_of_fury) or SpellCooldown(rising_sun_kick) >= 3.5 and Chi() <= 5 and Spell(fists_of_fury) or { not Talent(serenity_talent) or SpellCooldown(serenity) >= 5 } and Spell(rising_sun_kick) or not PreviousGCDSpell(blackout_kick) and MaxChi() - Chi() >= 1 and ArmorSetBonus(T21 4) and { not ArmorSetBonus(T19 2) or Talent(serenity_talent) } and Spell(blackout_kick) or { Enemies(tagged=1) >= 3 or BuffPresent(bok_proc_buff) and Chi() == MaxChi() } and not PreviousGCDSpell(spinning_crane_kick) and ArmorSetBonus(T21 4) and Spell(spinning_crane_kick) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 19 and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or HasEquippedItem(the_emperors_capacitor) and BuffStacks(the_emperors_capacitor_buff) >= 14 and SpellCooldown(serenity) < 13 and Talent(serenity_talent) and TimeToMaxEnergy() > 3 and Spell(crackling_jade_lightning) or Enemies(tagged=1) >= 3 and not PreviousGCDSpell(spinning_crane_kick) and Spell(spinning_crane_kick) or MaxChi() - Chi() > 1 and not PreviousGCDSpell(rushing_jade_wind) and Spell(rushing_jade_wind) or { Chi() > 1 or BuffPresent(bok_proc_buff) or Talent(energizing_elixir_talent) and SpellCooldown(energizing_elixir) < SpellCooldown(fists_of_fury) } and { { SpellCooldown(rising_sun_kick) > 1 and { not HasArtifactTrait(strike_of_the_windlord) or SpellCooldown(strike_of_the_windlord) > 1 } or Chi() > 4 } and { SpellCooldown(fists_of_fury) > 1 or Chi() > 2 } or PreviousGCDSpell(tiger_palm) } and not PreviousGCDSpell(blackout_kick) and Spell(blackout_kick) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_wave) or Chi() <= 3 and { SpellCooldown(rising_sun_kick) >= 5 or SpellCooldown(whirling_dragon_punch) >= 5 } and TimeToMaxEnergy() > 1 and Spell(chi_burst) or not PreviousGCDSpell(tiger_palm) and not PreviousGCDSpell(energizing_elixir) and { MaxChi() - Chi() >= 2 or TimeToMaxEnergy() < 3 } and Spell(tiger_palm) or Spell(chi_wave) or Spell(chi_burst)
}
]]

	OvaleScripts:RegisterScript("MONK", "windwalker", name, desc, code, "script")
end
