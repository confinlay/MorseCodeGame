#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

#define MAXSIZE 100

char* convertMorse(char* word);

char* morseCode[] = {".-", "-...", "-.-.", "-..", ".", "..-.",
    "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-",
    ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."};

// Main entry point of the application
int main() {
    
    char* string_morse = "-.-. --- -- .--. ..- - . .-. --.. --.. --.. ";    // test string (must end with a space)
    char* string_converted = convertMorse(string_morse);

    printf("%s\n", string_converted);

    return(0);
}

// Function to convert an inputed word in morse code into a regular string
char* convertMorse(char* word){
    char* converted = (char*)malloc(MAXSIZE);               // allocate memory space for output string
    int converted_index, word_index, letter_index = 0;      // initiliase index counters to 0
    char letter[MAXSIZE];                                   // declare char array to temporarily store each letter

    while(word[word_index] != '\0'){                        // while there are still more code signals to read in
        if(word[word_index] == ' ')  {                      // if we read in a space, then we have finished a letter
            word_index++;                                   // increment to next morse code signal for default flow following this if statement
            letter[letter_index] = '\0';                    // null-terminate string containing morse code for the letter
            for (int i = 0; i < 26; i++){                   // for each letter in the alphabet
                if (strcmp(letter,morseCode[i]) == 0){      // check if the morse code produced so far is equal to a letter in the alphabet
                    printf("%s\n", letter);                 // DEBUG PRINT STATEMENT
                    converted[converted_index++] = i + 'A'; // add letter to output if it is and post-increment converted_index
                    printf("%c\n", (i + 'A'));              // DEBUG PRINT STATEMENT
                }               
                letter_index = 0;                           // start new letter
            }
        }                                                    
        letter[letter_index++] = word[word_index++];        // either way, read in another characted from the input, post incrementing both char arrays
    }
    converted[converted_index] = '\0';                      // null-terminate output
    return converted;                       
}
