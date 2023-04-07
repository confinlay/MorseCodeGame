# assignment02

# registers 
r7: If r7 is low then alarm interupts rae dealt with, if high then they are ignored. 
    It is high when a button is still being pressed and set to low when it is released
    It is set to high after the two second alarm subroutine, and then reset to low again when the button is released
r6: stores the value of the rising edge time snapshot
r5: stores the value of the falling edge time snapshot
r4: This stores the alarm counter, it is incremented to 1 after the one sec alarm, and incremented to 2 after the two second alarm
    It is reset to 0 after the button has been pressed and then released and when the two second alarm is handled

# functions 
the function "timer" returns the value stored at r7 to the c part of the program. This is the interval between the last two falling / rising edge interrupts