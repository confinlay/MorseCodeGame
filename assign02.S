#include "hardware/regs/addressmap.h"
#include "hardware/regs/io_bank0.h"
#include "hardware/regs/timer.h"
#include "hardware/regs/m0plus.h"

.syntax unified                                                 @ Specify unified assembly syntax
.cpu    cortex-m0plus                                           @ Specify CPU type is Cortex M0+
.thumb                                                          @ Specify thumb assembly for RP2040
.global main_asm                                                @ Provide program starting address to the linker                                     
.global store_interval_low                                      @function declaration
.global store_interval_high                                     @function declaration
.global set_start_high                                          @function declaration
.global set_start_low                                           @function declaration
.global reset                                                   @function declaration
.global reset_input_buffer
.global check_for_interrupt                                     @function declaration
.global init_alarm
.align 4                                                        @ Specify code alignment

.equ DFLT_ALARM_TIME, 1000000                                @ Specify the default alarm timeout @ 2 sec

.equ GPIO_BTN_EN_MSK_FE, 0x00400000                          @ bit22 - when button is pressed, falling edge
.equ GPIO_BTN_EN_MSK_RE, 0x00800000                          @ bit23 - when button is released, rising edge


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
.equ NEW_INTERRUPT, 1


@ Entry point to the ASM portion of the program
main_asm:
   push    {lr}
   bl      init_gpio_led                                         @ initialise the led pin
   bl      install_gpio_interrupt                                @ install the gpio interrupt on pin 21
   bl      init_button_21                                        @ initialise the button 21 pin
   bl      alrm_isr_installer                                    @ Install the Alarm ISR Handler into the IVT 

   movs    r5, 0                                                 @ intialising regs
   movs    r6, 0                                                 @ intialising regs
   movs    r4, 0                                                 @ intialising regs
   movs    r3, 0                                                 @ intialising regs
   pop     {pc}


.thumb_func
gpio_isr:
    push   {lr} 

    @bl     watchdog_update                                      @update watchdog
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
    cmp     r6, #0                                               @ if r6 is zero then its the first falling edge interrupt and we don't want to compare time values since we only have 1
    beq     first_iteration                                      @ skip the time storing steps
    subs    r0, r5, r6                                           @ take r6 away from this value to get the time difference since the last rising edge event    
    bl      store_interval_low                                   @ store the time between button presses
    movs    r0, 1                                                @ move 1 to r0 so that we can set the start_low value in the c program
    bl      set_start_low                                        @ set the start_low value to 1 in the c program to indicate we can start recording the time intervals
    ldr     r0, =GPIO_BTN_EN_MSK_FE                              @ load the falling edge mask into r0 for clearing interrupt later on 
    movs    r7, #1                                               @ set r7 to 1 t o indicate that the button is still being pressed
    b       finish                                               @ branch to the end

 @ deal with button released
mid_released: 
    bl      init_alarm                                           @reset alarm timer
    movs    r4, #0                                               @ Move zero into reg 4 to reset alarm timer counter
    ldr     r2, =(TIMER_BASE + 0x28)                             @ load the timer register base + the offset to get "TIMERAWL" (using the name TIMERAWL wasnt working)
    ldr     r1, [r2]                                             @ store the current time in r1
    movs    r6, r1                                               @ move this to r6 (where we store the rising edge time snapshot)
    subs    r0, r6, r5                                           @ take r6 away from this value to get the time difference since the last rising edge event
    bl      store_interval_high                                  @ store the time interval between the button being pressed and released
    movs    r0, 1                                                @ move 1 to r0 so that we can the the start_high value in the c program
    bl      set_start_high                                       @ set the start_high value to 1 in the c program to inidicate that we can start recording the time intervals
    ldr     r0, =GPIO_BTN_EN_MSK_RE                              @ load the rising edge mask into r0 for clearing interrupt later on 
    movs    r7, #0                                               @ set r7 to 0 to indicate that the button has been released 
    b       finish                                               @ branch to the end

first_iteration:
    ldr     r0, =GPIO_BTN_EN_MSK_FE                              @ load the falling edge mask into r0 for clearing interrupt later on 
    b       finish                                               @ branch to the end

finish:
    @ clear the interrupt and branch back to main
    ldr    r2, =(IO_BANK0_BASE + IO_BANK0_INTR2_OFFSET)          @ load register to clear interrupts
    str    r0, [r2]                                              @ store whatever mask have in r0 at this address, clearing the interrupt
    //bl     init_alarm                                          @ reset the alarm timer
    bl     watchdog_update                                       @ update watchdog                       
    movs   r0, NEW_INTERRUPT                                     @ move 1 into r0 
    bl     check_for_interrupt                                   @ set the interrupt_occured variable to 1 in the c program so that we know an interrupt has occured
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

/////////////////////// ALARM TIMER CODE ///////////////////////////
alrm_isr_installer:
    @install the Alarm ISR Handler into the Alarm0 slot in the IVT
    ldr     r0, =(PPB_BASE + M0PLUS_VTOR_OFFSET)    @ Load in the location where the IVT address is stored in the hardware registers
    ldr     r1, [r0]                                @ Load in the adress of the Interrupt vector table
    ldr     r0, =ALRM_ISR_OFFSET                    @ Load in the Alarm ISR offset for the IVT
    adds    r0, r1                                  @ Add the Alarm ISR offset to the IVT adress to get the adress of the Alarm ISR
    ldr     r2, =alarm_isr                          @ Load in the adress of our Alarm ISR Handler subroutine
    str     r2, [r0]                                @ Store the address of our Alarm ISR Handler subroutine at the Alarm ISR address in the IVT
    
    @Enabling Alarm IRQ0 step1, Clear the interrupt
    ldr     r2, =(PPB_BASE+M0PLUS_NVIC_ICPR_OFFSET) @ Load in address of the NVIC Interrupt Clear Pending register
    movs    r0, #1                                  
    str     r0, [r2]                                @ Store 1 (replacing the 0) at bit 1 in the ICP Register to clear the interrupt
    @Enabling Alarm IRQ0 step2, Set the interrupt
    ldr     r2, =(PPB_BASE+M0PLUS_NVIC_ISER_OFFSET) @ Load in address of the NVIC Interrupt Set Pending register
    movs    r0, #1
    str     r0, [r2]                                @ Store 1 (replacing the 0) at bit 1 in the ISP Register to Set the interrupt

    bx      lr                                      @ Return to the Link registry Adress

@ Subroutine to set the alarm time and enable timer interupts
init_alarm:
    push    {lr}                                    @ Store the link register to the stack
    @bl      handle_twosec_c 
    @Enables timer interupt
    movs    r0, #1                                  @ Load 1 into the regster for use in enabling timer interupts
    ldr     r1, =(TIMER_BASE + TIMER_INTE_OFFSET)   @ Load the adress for the timer interrupt enable register    
    str     r0, [r1]                                @ Set the interrupt enable register to 1 to enable timer interrupts

    @Reads in current time and adds time delay, i.e determines the alarm time
    ldr     r1, =(TIMER_BASE + TIMER_TIMELR_OFFSET) @ Load in the address for the lower 32 bits of the timer regisiter
    ldr     r0, [r1]                                @ Load the timer count from the timer register
    ldr     r1, =DFLT_ALARM_TIME                    @ Set the default ALarm Time as 1000000 microseconds, 1 second
    adds    r0, r0, r1                              @ Add the current time delay to the current timer count

    @Sets the Alarm time in the Alarm control reg
    ldr     r1, =(TIMER_BASE + TIMER_ALARM0_OFFSET) @ Load in the address for the ALARM0 control register
    str     r0, [r1]                                @ Store the new alarm time to the Control register

    pop     {pc}                                    @ Pop the link register from the stack to the program counter

.thumb_func
alarm_isr:
    push    {lr}                                    @ Store the link register to the stack
   
    @clears the timer interrupt 
    movs    r0, #1                                  @ Load 1 into the regster for use in clearing timer interupt
    ldr     r1, =(TIMER_BASE + TIMER_INTR_OFFSET)   @ Load the adress for the TIMER raw interrupts register.  
    str     r0, [r1]                                @ Set the interrupt raw register to 1 to clear timer interrupts                
    
    cmp     r0, r7                                  @ R7 will be high if button is still being pressed 
    beq     button_still_pressed                    @ if button still pressed then dont handle interrupt
    adds    r4, r4, r0                              @ Add 1 to increment the alarm counter
    cmp     r4, r0                                  @ check if the alarm has occured once
    beq     handle_onesec_arm                       @ if so the handle the one second alarm
    b       handle_twosec_arm                       @ if not then handle the two second alarm

button_still_pressed:
    pop     {pc}
    
reset_input_buffer:
    push    {lr}
    movs    r6, #0;
    pop     {pc}

handle_onesec_arm:                    
    bl      handle_onesec_c                         @ call c function which handles spaces
    b       done                                    @ branch to done
handle_twosec_arm:                    
    movs    r7, #1                                  @ Set r7 to high to prevent the C fnctions being called, this will be reset to zero when the button is pr
    movs    r4, #0                                  @ rest alarm counte to 0 
    bl      handle_twosec_c                         @ call c function which handles user input
    b       done                                    @ branch to done
done:  
      
    bl      init_alarm                              @ re-initialise the alarm 
    pop     {pc}


@ Set data alignment
.data
    .align 4
