# Introduction
This repository contains a group project I completed as part of a "Microprocessor Systems" module at University. The program, written in ARM Assembly and C, is a morse code game where the player is tasked with inputting the morse code equivalent of characters displayed on the command line. 

# Functional description
The following is an excerpt from our project report, which outlines the operation of the program.

When started, the Morse Code game displays a 'home screen' in the terminal which includes a welcome message, the group number and members, a title graphic and instructions on how the player can choose a level. 

By inputting a series of dots and dashes, the player can choose whichever level they would like to play, depending on skill level. The basic level structure is shown in the block diagram below. 

 <img width="338" alt="Picture 1" src="https://user-images.githubusercontent.com/106957733/236921849-1d6d2248-91fd-4c22-8150-f9652d68e5c3.png">
* Block diagram of level flow *

Each of the following levels is built around this structure, with minor changes being made to the gameplay for each section. These changes include removing the equivalent morse code for a given letter, or by changing the input to a full word instead of a single letter. 

As per the International Morse Code standard (1), a dot is designated as one time unit (TU), a dash is 3TUs, a space between signals forming the same letter is equal to 1TU and the space between two letters in a word is 3TUs. If there has been no input for a pre-defined amount of time, the game will reset back to the home screen, where a level can be chosen again. 

The timing for each of the short sequences is handled by an alarm timer, which is reset when the GP21 button on the Raspberry Pi is pressed. The time between presses and the duration of the press is recorded in ARM and returned to C where it is calculated and interpreted as either a dot, dash, or space. A Watchdog Timer is used as the gameplay timeout, after about 8.3 seconds without any input the game will return to the home screen, ready to be played again. 

The status of the game is indicated on the on-board LED and are as follows:  

- 3 lives: Green 

- 2 lives: Orange 

- 1 life: Yellow 

- 0 lives: Red (Game Over) 

 For each sequence that is incorrect, a life is removed from the total and the LED indicates the number of lives left. Additionally, the current streak is reset to 0. If a correct sequence is input, a life is added, and the LED once again reflects this change. If 5 correct sequences are input in a row, the player may continue to the next level if it exists. However, if the player is on their last life and they input an incorrect sequence, the LED will light up in red and the player will be returned to the home screen. 
