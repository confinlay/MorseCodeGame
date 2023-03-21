#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "pico/time.h"

// Declare the main assembly code entry point. //
void main_asm();
// Initialise a GPIO pin – see SDK for detail on gpio_init()
void asm_gpio_init(uint pin) {
 gpio_init(pin);
}
// Set direction of a GPIO pin – see SDK for detail on gpio_set_dir()
void asm_gpio_set_dir(uint pin, bool out) {
 gpio_set_dir(pin, out);
}
// Get the value of a GPIO pin – see SDK for detail on gpio_get()
bool asm_gpio_get(uint pin) {
 return gpio_get(pin);
}
// Set the value of a GPIO pin – see SDK for detail on gpio_put()
void asm_gpio_put(uint pin, bool value) {
 gpio_put(pin, value);
}

// Enable falling-edge interrupt – see SDK for detail on gpio_set_irq_enabled()
void asm_gpio_set_irq(uint pin) {
 gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_FALL, true);
}

// Enable rising-edge interrupt 
void asm_gpio_set_irq1(uint pin) {
 gpio_set_irq_enabled(pin, GPIO_IRQ_EDGE_RISE, true);
}

//function returns the value stored in r7, hasnt been tested with interval timer yet
int32_t timer();

// Main entry point of the application
int main() {
 stdio_init_all(); // Initialise all basic IO
 main_asm(); // Jump into the ASM to initialise pins and interrupt

 printf("Welcome to our Morse Code Game!\n"); // Basic print to console

 sleep_ms(5000);

 int32_t holder = timer();
 
 while(1){}; // loop forever

 return 0; // Application return code
}
