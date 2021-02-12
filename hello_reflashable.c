#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/bootrom.h"
#include "class/cdc/cdc_device.h"
#include "hardware/watchdog.h"
#include "hardware/structs/watchdog.h"

// callback is invoked on receiving NULL character on USB
void tud_cdc_rx_wanted_cb(uint8_t itf, char wanted_char)
{
    // go to flash mode
    reset_usb_boot(0, 0);
}

// timer invoked every 250 ms to let watchdog know we are ok
static bool time_to_nudge_dog_cb(repeating_timer_t *rt)
{
    watchdog_update();
    return true;
}

int main()
{
    // necessary to make things reflashable
    stdio_init_all();
    tud_cdc_set_wanted_char('\0');

    // only necessary if you want to go to flash mode
    // when things go seriously bad and system hangs
    if (watchdog_caused_reboot() && watchdog_hw->scratch[5] == 0)
    {
        reset_usb_boot(0, 0);
    }
    watchdog_hw->scratch[5] = 0;
    watchdog_enable(1000, 1);
    repeating_timer_t dog_timer;
    add_repeating_timer_ms(-250, time_to_nudge_dog_cb, NULL, &dog_timer);

    // main program starts here
    // just blinking led as example
    const uint LED_PIN = 25;
    bool led_on = false;
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);

    while (true)
    {
        led_on = !led_on;
        gpio_put(LED_PIN, led_on);
        sleep_ms(250);
    }

    return 0;
}
