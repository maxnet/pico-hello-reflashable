#include <stdio.h>
#include "pico/stdlib.h"
#include "pico/bootrom.h"
#include "class/cdc/cdc_device.h"

// callback is invoked on receiving NULL character on USB
void tud_cdc_rx_wanted_cb(uint8_t itf, char wanted_char)
{
    // go to flash mode
    reset_usb_boot(0, 0);
}

int main()
{
    // necessary to make things reflashable
    stdio_init_all();
    tud_cdc_set_wanted_char('\0');

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
