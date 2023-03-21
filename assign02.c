#include "pico/stdlib.h"

#define LED_PIN 25

#define RED_PIN 0
#define GREEN_PIN 1
#define BLUE_PIN 2

int main() {
    gpio_init(LED_PIN);
    gpio_set_dir(LED_PIN, GPIO_OUT);
    gpio_put(LED_PIN, 0);

    gpio_init(RED_PIN);
    gpio_set_dir(RED_PIN, GPIO_OUT);
    gpio_put(RED_PIN, 1);
    
    while (true) {
        gpio_put(LED_PIN, 1);   // turn the LED on
        sleep_ms(1000);         // wait for 1 second
        gpio_put(LED_PIN, 0);   // turn the LED off
        sleep_ms(1000);         // wait for 1 second
    }
    
}