#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <stdbool.h>

#define MAXSIZE 100

char* convertMorse(char* word);
char randomChar();
char* word_to_morse(char* word);

char* morseCode[] = {"-----", ".----", "..---","...--", "....--", ".....", "-....", "--...", "---..", "----.",".-", "-...", "-.-.", "-..", ".", "..-.",
    "--.", "....", "..", ".---", "-.-", ".-..", "--", "-.", "---", ".--.", "--.-",
    ".-.", "...", "-", "..-", "...-", ".--", "-..-", "-.--", "--.."};

char* words[] = {
    "ace", "apple", "blue", "bunny", "cape",
    "chair", "daisy", "dance", "eagle", "ember",
    "frost", "fudge", "glide", "grape", "honey",
    "icicle", "jazz", "jelly", "kangaroo", "kitten",
    "lemon", "lucky", "marble", "mango", "navy",
    "ocean", "opal", "pepper", "piano", "quilt",
    "rabbit", "river", "sunny", "swirl", "tiger",
    "turtle", "umbrella", "unique", "violet", "wave",
    "wheat", "whisk", "yellow", "lunch", "zebra",
    "acorn", "badger", "banana", "butter", "cactus",
    "coffee", "comet", "dagger", "dragon", "flamingo",
    "gorilla", "guitar", "hippo", "hockey", "jungle",
    "ketchup", "kiwi", "koala", "laptop", "lizard",
    "mascot", "monkey", "mountain", "mustard", "necklace",
    "octopus", "penguin", "pumpkin", "rainbow", "robot",
    "sailor", "seagull", "shark", "snowman", "squirrel",
    "treasure", "unicorn", "volcano", "watermelon", "whale",
    "wizard", "xylophone", "yak", "yellowstone", "zeppelin"
};

// Main entry point of the application
int main() {
        // Use the current microsecond count to seed the random number generator
    srand(time(NULL));

    char* string_morse = "----- .-- ...- -..--. -.-- ";    // test string (must end with a space)

    //char x = randomChar();
    char* string_converted = convertMorse(string_morse);

    printf("Converted: %s\n" , string_converted);

    char* myname = "CONOR";
    char* morseName = word_to_morse(myname);
    printf("Name: %s, Morse Name = %s\n", myname, morseName);

    char* convertedBack = convertMorse(morseName);
    printf("Converted back: %s\n", convertedBack);


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

//}

char* convertMorse(char* word){
    char* converted = (char*)malloc(MAXSIZE);                           // allocate memory space for output string
    int converted_index = 0, word_index = 0, letter_index = 0;          // initiliase index counters to 0
    char letter[MAXSIZE] = " ";                                         // declare char array to temporarily store each letter
    bool found = false;

    while(word[word_index] != '\0'){                                    // while there are still more code signals to read in
        if(word[word_index] == ' ')  {                                  // if we read in a space, then we have finished a letter
            word_index++;                                               // increment to next morse code signal for default flow following this if statement
            letter[letter_index] = '\0';                                // null-terminate string containing morse code for the letter
            for (int i = 0; i < 35; i++){                               // for each letter in the alphabet
                if (strcmp(letter,morseCode[i]) == 0){                  // check if the morse code produced so far is equal to a letter in the alphabet
                    found = true;                                       // set found to true
                    if(i < 10)
                        converted[converted_index++] = i + '0';         // add number to output if it is and post-increment converted_index
                    else
                        converted[converted_index++] = (i - 10) + 'A';  // add letter to output if it is and post-increment converted_index
                }               
                letter_index = 0;                                       // start new letter
            }
            if(!found){                                                 // if no letter found
                converted[converted_index++] = '?';                     // set letter to ? for unknown        
            }
            found = false;                                              // set found to false regardless
        }    
                                                     
        letter[letter_index++] = word[word_index++];                    // either way, read in another characted from the input, post incrementing both char arrays
    }
    converted[converted_index] = '\0';                                // null-terminate output (removing trailing question mark)
    return converted;                       
}

char* word_to_morse(char* word){
    char* morse = (char*)malloc(MAXSIZE);
    int word_index = 0;

    while(word[word_index] != '\0'){
        strcat(morse, morseCode[word[word_index] + 10 - 'A']);
        strcat(morse, " ");
        word_index++;
    }

    return morse;
}