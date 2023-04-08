#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>

#define MAXSIZE 100

char* convertMorse(char* word);
char randomChar();

char* morseCode[] = {"-----", ".----", "..---","...--", "....--", ".....", "-....", "--...", "---..", "----.",".-", "-...", "-.-.", "-..", ".", "..-.",
    "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-",
    ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."};

// Main entry point of the application
int main() {
        // Use the current microsecond count to seed the random number generator
    srand(time(NULL));

    char* string_morse = "-.-. --- -. --- .-. ";    // test string (must end with a space)

    //char x = randomChar();
    char* string_converted = convertMorse(string_morse);

    printf("Converted: %s" , string_converted);


    return(0);
}

// char randomChar() {
//     char random_char;

//     // Use the current microsecond count to seed the random number generator
//     uint64_t seed = time_us_64();
//     srand(seed);

//     // Generate a random number (0 - 9: numbers; 10 - 35: letters)
//     int random_num = rand() % 35;

//     // If 0 -> 9, return straight away
//     // Otherwise, convert the number to an uppercase letter and return the letter
//     if (random_num < 10) {
//         random_char = random_num + '0';
//     } else {
//         random_char = (random_num - 10) + 'A';
//     }
//     char* random_morse = morseCode[random_num];

//     // Print statements
//     printf("Character: %c | Morse code equivalent: %s", random_char, random_morse);

//     // Return character for checking later
//     return random_char;

// }

// Function to convert an inputed word in morse code into a regular string
char* convertMorse(char* word){
    char* converted = (char*)malloc(MAXSIZE);                           // allocate memory space for output string
    int converted_index = 0, word_index = 0, letter_index = 0;                  // initiliase index counters to 0
    char letter[MAXSIZE] = " ";                                               // declare char array to temporarily store each letter

    while(word[word_index] != '\0'){                                    // while there are still more code signals to read in
        if(word[word_index] == ' ')  {                                  // if we read in a space, then we have finished a letter
            word_index++;                                               // increment to next morse code signal for default flow following this if statement
            letter[letter_index] = '\0';                                // null-terminate string containing morse code for the letter
            for (int i = 0; i < 35; i++){                               // for each letter in the alphabet
                if (strcmp(letter,morseCode[i]) == 0){                  // check if the morse code produced so far is equal to a letter in the alphabet
                    if(i < 10)
                        converted[converted_index++] = i + '0';         // add number to output if it is and post-increment converted_index
                    else
                        converted[converted_index++] = (i - 10) + 'A';  // add letter to output if it is and post-increment converted_index
                }               
                letter_index = 0;                                       // start new letter
            }
        }    
                                                     
        letter[letter_index++] = word[word_index++];                    // either way, read in another characted from the input, post incrementing both char arrays
    }
    converted[converted_index] = '\0';                                  // null-terminate output
    return converted;                       
}
