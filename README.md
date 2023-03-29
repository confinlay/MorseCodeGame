# assignment02

# registers 
r7 stores the latest interval button pressed time
r6 stores the value of the rising edge time snapshot
r5 stores the value of the falling edge time snapshot
r4 stores the latest interval time between presses (the spaces)

# functions 
the function "timer" returns the value stored at r7 to the c part of the program. This is the interval between the last two falling / rising edge interrupts