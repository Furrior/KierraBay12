/obj/screen/psi/hub
	name = "Psi"
	icon_state = "psi_suppressed"
	screen_loc = "EAST-1:28,CENTER-3:11"
	hidden = FALSE
	maptext_x = 6
	maptext_y = -8
	var/image/on_cooldown
	var/list/components

/obj/screen/psi/hub/Initialize(mapload)
	. = ..()
	on_cooldown = image(icon, "cooldown")
	components = list(
		new /obj/screen/psi/armour(owner),
		new /obj/screen/psi/toggle_psi_menu(owner, src)
	)
	START_PROCESSING(SSprocessing, src)

/obj/screen/psi/hub/on_update_icon()

	if(!owner.psi)
		return

	icon_state = owner.psi.suppressed ? "psi_suppressed" : "psi_active"
	if(world.time < owner.psi.next_power_use)
		overlays |= on_cooldown
	else
		overlays.Cut()
	var/offset = 1
	for(var/thing in components)
		var/obj/screen/psi/component = thing
		component.update_icon()
		if(!component.invisibility) component.screen_loc = "EAST-[++offset]:28,CENTER-3:11"

/obj/screen/psi/hub/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	owner = null
	for(var/thing in components)
		qdel(thing)
	components.Cut()
	. = ..()

/obj/screen/psi/hub/Process()
	if(!istype(owner))
		qdel(src)
		return
	if(!owner.psi)
		return
	maptext = "[round((owner.psi.stamina/owner.psi.max_stamina)*100)]%"
	update_icon()

/obj/screen/psi/hub/Click(location, control, click_params)
	var/list/params = params2list(click_params)
	if(params["shift"])
		owner.show_psi_assay(owner)
		return

	if(owner.psi.suppressed && owner.psi.stun)
		to_chat(owner, SPAN_WARNING("You are dazed and reeling, and cannot muster enough focus to do that!"))
		return

	owner.psi.suppressed = !owner.psi.suppressed
	to_chat(owner, SPAN_NOTICE("You are <b>[owner.psi.suppressed ? "now suppressing" : "no longer suppressing"]</b> your psi-power."))
	if(owner.psi.suppressed)
		owner.psi.cancel()
		owner.psi.hide_auras()
	else
		sound_to(owner, sound('sound/effects/psi/power_unlock.ogg'))
		owner.psi.show_auras()
	update_icon()
