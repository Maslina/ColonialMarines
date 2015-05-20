/obj/item/weapon/flamethrower
	name = "flamethrower"
	desc = "You are a firestarter!"
	icon = 'icons/obj/flamethrower.dmi'
	icon_state = "flamethrowerbase"
	item_state = "flamethrower_0"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	m_amt = 500
	origin_tech = "combat=1;plasmatech=1"
	var/status = 0
	var/throw_amount = 100
	var/lit = 0	//on or off
	var/operating = 0//cooldown
	var/turf/previousturf = null
	var/obj/item/weapon/weldingtool/weldtool = null
	var/obj/item/device/assembly/igniter/igniter = null
	var/obj/item/weapon/tank/plasma/ptank = null


/obj/item/weapon/flamethrower/Del()
	if(weldtool)
		del(weldtool)
	if(igniter)
		del(igniter)
	if(ptank)
		del(ptank)
	..()
	return


//Abby's overhaul - Stop hotspot igniting, it's unnecessary.

///obj/item/weapon/flamethrower/process()
//	if(!lit)
//		processing_objects.Remove(src)
//		return null
//	var/turf/location = loc
//	if(istype(location, /mob/))
//		var/mob/M = location
//		if(M.l_hand == src || M.r_hand == src)
//			location = M.loc
//	if(isturf(location)) //start a fire if possible
//		location.hotspot_expose(700, 2)
//	return


/obj/item/weapon/flamethrower/update_icon()
	overlays.Cut()
	if(igniter)
		overlays += "+igniter[status]"
	if(ptank)
		overlays += "+ptank"
	if(lit)
		overlays += "+lit"
		item_state = "flamethrower_1"
	else
		item_state = "flamethrower_0"
	return

/obj/item/weapon/flamethrower/afterattack(atom/target, mob/user, proximity)
	// Make sure our user is still holding us
	..()
	if(user && user.get_active_hand() == src)
		var/turf/target_turf = get_turf(target)
		if(target_turf)
			var/turflist = getline(user, target_turf)
			flame_turf(turflist)
			if(ptank)
				if(ptank.air_contents.phoron <= 0.5)
					usr << "\red You try to get your flame on, but nothing happens. You're all out of burn juice!"
				else
					for (var/mob/O in viewers(user, null))
						O << "\red [user] unleashes a blast of flames!"
			else
				usr << "Attach a tank first!"

/obj/item/weapon/flamethrower/attackby(obj/item/W as obj, mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	if(iswrench(W) && !status)//Taking this apart
		var/turf/T = get_turf(src)
		if(weldtool)
			weldtool.loc = T
			weldtool = null
		if(igniter)
			igniter.loc = T
			igniter = null
		if(ptank)
			ptank.loc = T
			ptank = null
		new /obj/item/stack/rods(T)
		del(src)
		return

	if(isscrewdriver(W) && igniter && !lit)
		status = !status
		user << "<span class='notice'>[igniter] is now [status ? "secured" : "unsecured"]!</span>"
		update_icon()
		return

	if(isigniter(W))
		var/obj/item/device/assembly/igniter/I = W
		if(I.secured)	return
		if(igniter)		return
		user.drop_item()
		I.loc = src
		igniter = I
		update_icon()
		return

	if(istype(W,/obj/item/weapon/tank/plasma))
		if(ptank)
			user << "<span class='notice'>There appears to already be a plasma tank loaded in [src]!</span>"
			return
		user.drop_item()
		ptank = W
		W.loc = src
		update_icon()
		return

	if(istype(W, /obj/item/device/analyzer) && ptank)
		var/obj/item/weapon/icon = src
		user.visible_message("<span class='notice'>[user] has used the analyzer on \icon[icon]</span>")
		var/pressure = ptank.air_contents.return_pressure()
		var/total_moles = ptank.air_contents.total_moles()

		user << "\blue Results of analysis of \icon[icon]"
		if(total_moles>0)
			var/o2_concentration = ptank.air_contents.oxygen/total_moles
			var/n2_concentration = ptank.air_contents.nitrogen/total_moles
			var/co2_concentration = ptank.air_contents.carbon_dioxide/total_moles
			var/plasma_concentration = ptank.air_contents.phoron/total_moles

			var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

			user << "\blue Pressure: [round(pressure,0.1)] kPa"
			user << "\blue Nitrogen: [round(n2_concentration*100)]%"
			user << "\blue Oxygen: [round(o2_concentration*100)]%"
			user << "\blue CO2: [round(co2_concentration*100)]%"
			user << "\blue Plasma: [round(plasma_concentration*100)]%"
			if(unknown_concentration>0.01)
				user << "\red Unknown: [round(unknown_concentration*100)]%"
			user << "\blue Temperature: [round(ptank.air_contents.temperature-T0C)]&deg;C"
		else
			user << "\blue Tank is empty!"
		return
	..()
	return


/obj/item/weapon/flamethrower/attack_self(mob/user as mob)
	if(user.stat || user.restrained() || user.lying)	return
	user.set_machine(src)
	if(!ptank)
		user << "<span class='notice'>Attach a plasma tank first!</span>"
		return
	var/dat = text("<TT><B>Flamethrower (<A HREF='?src=\ref[src];light=1'>[lit ? "<font color='red'>Lit</font>" : "Unlit"]</a>)</B><BR>\n Tank Pressure: [ptank.air_contents.return_pressure()]<BR>\nAmount to throw: <A HREF='?src=\ref[src];amount=-100'>-</A> <A HREF='?src=\ref[src];amount=-10'>-</A> <A HREF='?src=\ref[src];amount=-1'>-</A> [throw_amount] <A HREF='?src=\ref[src];amount=1'>+</A> <A HREF='?src=\ref[src];amount=10'>+</A> <A HREF='?src=\ref[src];amount=100'>+</A><BR>\n<A HREF='?src=\ref[src];remove=1'>Remove plasmatank</A> - <A HREF='?src=\ref[src];close=1'>Close</A></TT>")
	user << browse(dat, "window=flamethrower;size=600x300")
	onclose(user, "flamethrower")
	return


/obj/item/weapon/flamethrower/Topic(href,href_list[])
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
		return
	if(usr.stat || usr.restrained() || usr.lying)	return
	usr.set_machine(src)
	if(href_list["light"])
		if(!ptank)	return
		if(ptank.air_contents.phoron < 0.5)
			usr << "There's not enough gas left to ignite the flamethrower."
			return
		if(!status)	return
		lit = !lit
		if(lit)
			processing_objects.Add(src)
	if(href_list["amount"])
		throw_amount = throw_amount + text2num(href_list["amount"])
		throw_amount = max(50, min(5000, throw_amount))
	if(href_list["remove"])
		if(!ptank)	return
		usr.put_in_hands(ptank)
		ptank = null
		lit = 0
		usr.unset_machine()
		usr << browse(null, "window=flamethrower")
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	update_icon()
	return


//Called from turf.dm turf/dblclick
/obj/item/weapon/flamethrower/proc/flame_turf(turflist)
	if(!lit || operating)
		return

	operating = 1
	for(var/turf/T in turflist)
		if(T.density || istype(T, /turf/space))
			break
		if(!previousturf && length(turflist)>1)
			previousturf = get_turf(src)
			continue	//so we don't burn the tile we be standin on
		if(previousturf && LinkBlocked(previousturf, T))
			break
		ignite_turf(T)
		sleep(1)
	previousturf = null
	operating = 0
	for(var/mob/M in viewers(1, loc))
		if((M.client && M.machine == src))
			attack_self(M)
	return

//Abby's flamethrower rewrite

//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "flamethrower fire"
	desc = "Ouch!"
	anchored = 1
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	layer = 2.03
	var/firelevel = 11 //Track how "hot" the fire is, flames die down eventually

/obj/flamer_fire/process()
	var/turf/simulated/T = loc

	if (!istype(T)) //Is it a valid turf? Has to be simulated and on a floor
		processing_objects.Remove(src)
		del(src)
		return

	if(firelevel > 10) //Change the icons and luminosity based on the fire's intensity
		icon_state = "3"
		SetLuminosity(7)
	else if(firelevel > 5)
		icon_state = "2"
		SetLuminosity(5)
	else if(firelevel > 0)
		icon_state = "1"
		SetLuminosity(3)
	else  //Fire has burned out, firelevel is 0 or less. GET OUT. Shouldn't cause issues, unlike sleep() + Del
		processing_objects.Remove(src)
		del(src)
		return

	for(var/mob/living/carbon/M in loc)
		M.adjustFireLoss(rand(5,10) + firelevel)  //fwoom!
		M.show_message(text("\red You are burned!"),1)

	//This is shitty and inefficient, but the /alien/ parent obj doesn't have health.. sigh.
	for(var/obj/effect/alien/weeds/W in loc)  //Melt dem weeds
		if(istype(W)) //Just for safety
			W.health -= (firelevel * 2)
			if(W.health < 0)
				del(W) //Just deleterize it
	for(var/obj/effect/alien/resin/R in loc)  //Melt dem resins
		if(istype(R)) //Just for safety
			R.health -= (firelevel * 2)
			R.healthcheck()
	for(var/obj/effect/alien/egg/E in loc)  //Melt dem eggs
		if(istype(E)) //Just for safety
			E.health -= (firelevel * 2)
			E.healthcheck()

	for(var/obj/item/clothing/mask/facehugger/H in loc) //Melt dem huggers
		if(!istype(H))
			continue //somehow
		H.health -= firelevel
		H.healthcheck()

	firelevel -= 1 //reduce the intensity, max is 11 pulses
	return


/obj/item/weapon/flamethrower/proc/ignite_turf(turf/target)

	if(!ptank)
		return //Shouldn't be possible, just to be safe though

	if(ptank.air_contents.phoron <= 0.5) //The heck, did you attach an air tank to this thing??
		return

	ptank.air_contents.remove_ratio(0.2*(throw_amount/100)) //This should just strip out the gas
	if (!locate(/obj/flamer_fire) in target) // No stacking flames!
		var/obj/flamer_fire/F =  new/obj/flamer_fire(target)
		processing_objects.Add(F)
		F.firelevel = (throw_amount / 10) + 1
		if(F.firelevel < 1) F.firelevel = 1
		if(F.firelevel > 11) F.firelevel = 11
	for(var/mob/living/carbon/M in target) //Deal bonus damage if someone's caught directly in initial stream
		M.adjustFireLoss(rand(15,25))  //fwoom!
		M.show_message(text("\red Auuugh! You are roasted by the flamethrower!"), 1)
	return

/obj/item/weapon/flamethrower/full/New(var/loc)
	..()
	weldtool = new /obj/item/weapon/weldingtool(src)
	weldtool.status = 0
	igniter = new /obj/item/device/assembly/igniter(src)
	igniter.secured = 0
	status = 1
	update_icon()
	return
