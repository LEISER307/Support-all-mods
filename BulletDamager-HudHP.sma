/* Раскомментировать SUPPORT_BIO, если у Вас стоит мод Biohazerd v2.00 Beta 3b */

#include <amxmodx>

//#define SUPPORT_BIO				// Поддердка Biohazerd v2.00 Beta 3b

#if defined SUPPORT_BIO
	#tryinclude <biohazard>
#endif

public plugin_init() {
	register_plugin("ZP Bullet Damager | Hud HP", "1.0.42", "L4D2");
	
	register_event("Damage", "EventDamage", "b", "2!0", "3=0", "4!0");
}

public EventDamage(id) {
	new iAttacker = get_user_attacker(id);
	
	#if defined SUPPORT_BIO
	if(id == iAttacker || is_user_infected(iAttacker) || is_user_zombie(iAttacker)) return;
	#endif
	
	if(is_user_connected(iAttacker)) {
		new iDamage = read_data(2);
		
		set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02);
		ShowSyncHudMsg(iAttacker, CreateHudSyncObj(), "%i^n", iDamage);
		
		new iVictimHealth = get_user_health(id);
		if(iVictimHealth < 0) iVictimHealth = 0;
		
		client_print(iAttacker, print_center, "HP: %d", iVictimHealth);
	}
}
