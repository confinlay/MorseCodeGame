#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified                                                 @ Specify unified assembly syntax
.cpu    cortex-m0plus                                           @ Specify CPU type is Cortex M0+
.thumb                                                          @ Specify thumb assembly for RP2040
.global main_asm                                                @ Provide program starting address to the linker
.global timer                                                   @ for calling timer function from the C program
.align 4                                                        @ Specify code alignment


.equ GPIO_BTN_EN_MSK_FE, 0x00400000                          @ bit22 - when button is pressed 
.equ GPIO_BTN_EN_MSK_RE, 0x00800000                          @ bit23 - when button is released 
 

.equ CLEAR_UP_BUTTON_MSK, 0xC000000 @bit 26 + 27

.equ GPIO_BTN_DN, 20                                         @ Specify pin for the "down" button
.equ GPIO_BTN_EN, 21                                         @ Specify pin for the "enter" button
.equ GPIO_BTN_UP, 22                                         @ Specify pin for the "up" button
.equ GPIO_LED_PIN, 25                                        @ Specify pin for the built-in LED
.equ GPIO_DIR_IN, 0                                          @ Specify input direction for a GPIO pin
.equ GPIO_DIR_OUT, 1                                         @ Specify output direction for a GPIO pin

.equ LED_VAL_ON, 1                                           @ Specify value that turns the LED "on"
.equ LED_VAL_OFF, 0                                          @ Specify value that turns the LED "off"

.equ GPIO_ISR_OFFSET, 0x74                                   @ GPIO is int #13 (vector table entry 29)
.equ ALRM_ISR_OFFSET, 0x40                                   @ ALARM0 is int #0 (vector table entry 16)
 
.equ DEF_SLEEP_TIME, 1000                                    @ default sleep time set to one second  

.equ SVC_ISR_OFFSET, 0x2C                                    @ The SVC is entry 11 in the vector table
.equ SVC_MAX_INSTRS, 0x01                                    @ Maximum allowed SVC subroutines

@ fuction to return the time value stored in r7, can be called from the C program to get time interval
timer:
   movs   r0, r7   
   bx     lr
  

@ Entry point to the ASM portion of the program
main_asm:
   
   bl      init_gpio_led                                         @ initialise the led pin
   bl      install_gpio_interrupt                                @ install the gpio interrupt on pin 21
   bl      init_button_20                                        @ initialise the button 20 pin
   bl      init_button_21                                        @ initialise the button 21 pin
   bl      init_button_22                                        @ initialise the button 22 pin
   movs    r5, 0                                                 @ intialising regs
   movs    r6, 0                                                 @ intialising regs
   
loop: 
   b       loop

.thumb_func
gpio_isr:
    @ load gpio interrupt register
    push   {lr}
    ldr    r2, =(IO_BANK0_BASE + IO_BANK0_PROC0_INTS2_OFFSET)    @ load i/o register memory location 
    ldr    r1, [r2]                                              @ load value into r2 to check which interrupt was triggered 
    
    @ check if its rising or falling edge
    ldr    r0, =GPIO_BTN_EN_MSK_RE                               @ load rising edge mask into r0
    subs   r2, r1, r0                                            @ subtract it from the triggered interrupt
    beq    mid_released                                          @ if the middle buttom was released  
    ldr    r0, =GPIO_BTN_EN_MSK_FE                               @ load falling edge mask into r0
    subs   r1, r0                                                @ subtract it from the triggered interrupt
    beq    mid_pressed                                           @ if middle button was pressed
 
    @ deal with button pressed
mid_pressed:
    ldr     r2, =(TIMER_BASE + 0x28)                             @ load the timer register base + the offset to get "TIMERAWL" (using the name TIMERAWL wasnt working)
    ldr     r1, [r2]                                             @ store the current time in r1
    movs    r5, r1                                               @ move this to r5 (where we store the falling edge time snapshot)
    subs    r7, r5, r6                                           @ take r6 away from this value to get the time difference since the last rising edge event
    ldr     r0, =GPIO_BTN_EN_MSK_FE                              @ load the falling edge mask into r0 for clearing interrupt later on 
    b       finish                                               @ branch to the end

 @ deal with button released
mid_released:
    ldr     r2, =(TIMER_BASE + 0x28)                             @ load the timer register base + the offset to get "TIMERAWL" (using the name TIMERAWL wasnt working)
    ldr     r1, [r2]                                             @ store the current time in r1
    movs    r6, r1                                               @ move this to r6 (where we store the rising edge time snapshot)
    subs    r7, r6, r5                                           @ take r6 away from this value to get the time difference since the last rising edge event
    ldr     r0, =GPIO_BTN_EN_MSK_RE                              @ load the rising edge mask into r0 for clearing interrupt later on 
    b       finish                                               @ branch to the end


finish:
    @ clear the interrupt and branch back to main
    ldr    r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)          @ load register to clear interrupts
    str    r0, [r2]                                              @ store whatever mask have in r0 at this address, clearing the interrupt
    pop    {pc}                                                  @ go back to previous program execution


install_gpio_interrupt:
    ldr    r2, =(PPB_BASE + M0PLUS_VTOR_OFFSET)                  @ load the interrupt vector table memory address into r2
    ldr    r1, [r2]                                              @ load the value stored at this address into r1
    movs   r2, #GPIO_ISR_OFFSET                                  @ load the offset needed for the gpio interrupt into r2
    adds   r2, r1                                                @ add the offset for gpio interrupt to the base address of the vector table
    ldr    r0, =gpio_isr                                         @ load the address of the isr into r0
    str    r0, [r2]                                              @ store the address of the isr associated with this interrupt in the vector table

    ldr    r2, =(PPB_BASE + M0PLUS_NVIC_ICPR_OFFSET)             @ load the address of the ICPR to clear the interrupt
    movs   r1, #1                                                @ load 1 into r1, this will be the bit we set in the ICPR
    lsls   r1, #13                                               @ gpio interrupt is the int 13, so shift the bit left 13 places
    str    r1, [r2]                                              @ set the correct bit in the ICPR to dissable the interrupt
    ldr    r2, =(PPB_BASE + M0PLUS_NVIC_ISER_OFFSET)             @ load the address of the ISPR to enable the interrupt
    str    r1, [r2]                                              @ set the correct bit in the ISPR to enable the interrupt
    bx     lr                                                    @ branch back to where we were before

init_gpio_led:
    push   {lr}                                                  @ push the link register, we will call other functions within this one
    movs   r0, #GPIO_LED_PIN                                     @ This value is the GPIO LED pin on the PI PICO board
    bl     asm_gpio_init                                         @ Call the subroutine to initialise the GPIO pin specified by r0
    movs   r0, #GPIO_LED_PIN                                     @ This value is the GPIO LED pin on the PI PICO
    movs   r1, #LED_VAL_ON                                       @ We want to set it as an output pin
    bl     asm_gpio_set_dir                                      @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    pop    {pc}                                                  @ pop the program counter to return to where we were before

init_button_21: 
    push    {lr}                                                 @ push the link register, we will call other functions within this one
    movs    r0, #GPIO_BTN_EN                                     @ This value is the GPIO button pin on the PI PICO 
    bl      asm_gpio_init                                        @ intialise the button pin
    movs    r0, #GPIO_BTN_EN                                     @ This value is the GPIO button pin on the PI PICO 
    movs    r1, #GPIO_DIR_IN                                     @ We want this GPIO pin to be setup as an input pin
    bl      asm_gpio_set_dir                                     @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r0, #GPIO_BTN_EN                                     @ move the gpio button pin to r0 so we can enable the falling edge interrupt 
    bl      asm_gpio_set_irq                                     @ enable the falling edge interrupt
    movs    r0, #GPIO_BTN_EN
    bl      asm_gpio_set_irq1
    pop     {pc}                                                 @ pop the program counter to return to where we were before

init_button_22:
    push    {lr}                                                 @ push the link register, we will call other functions within this one
    movs    r0, #GPIO_BTN_UP                                     @ This value is the GPIO button pin on the PI PICO 
    bl      asm_gpio_init                                        @ intialise the button pin
    movs    r0, #GPIO_BTN_UP                                     @ This value is the GPIO button pin on the PI PICO 
    movs    r1, #GPIO_DIR_IN                                     @ We want this GPIO pin to be setup as an input pin
    bl      asm_gpio_set_dir                                     @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r0, #GPIO_BTN_UP                                     @ move the gpio button pin to r0 so we can enable the falling edge interrupt 
    bl      asm_gpio_set_irq                                     @ enable the falling edge interrupt
    movs    r0, #GPIO_BTN_UP
    bl      asm_gpio_set_irq1
    pop     {pc}                                                 @ pop the program counter to return to where we were before

init_button_20:
    push    {lr}                                                 @ push the link register, we will call other functions within this one
    movs    r0, #GPIO_BTN_DN                                     @ This value is the GPIO button pin on the PI PICO 
    bl      asm_gpio_init                                        @ intialise the button pin
    movs    r0, #GPIO_BTN_DN                                     @ This value is the GPIO button pin on the PI PICO 
    movs    r1, #GPIO_DIR_IN                                     @ We want this GPIO pin to be setup as an input pin
    bl      asm_gpio_set_dir                                     @ Call the subroutine to set the GPIO pin specified by r0 to state specified by r1
    movs    r0, #GPIO_BTN_DN                                     @ move the gpio button pin to r0 so we can enable the falling edge interrupt 
    bl      asm_gpio_set_irq                                     @ enable the falling edge interrupt
    movs    r0, #GPIO_BTN_UP
    bl      asm_gpio_set_irq1
    pop     {pc}  

@ Set data alignment
.data
    .align 4
