/* Name: James Guan
 * Project 8
 * Description: ROT 13 main that uses bitwise arithmetic to
 *				access data and sends data through a function pointer.
 *
 */

#include <stdlib.h>
#include <stdio.h>
#include "rot13_dev.h"

// ISR which gets called that uses printf to output the 
//	output to the screen. For some reason, it doesn't
//  print right when there are multiple (s) in the word or
//  (u). Not sure why.
//  Handles the other stuff fine.
void ISR ( void * data )
{
	int ** temp = data;
	fprintf(stdout, "%c", (*temp)[2]); // Print each character from output
	fflush(stdout); // Flush the stdout to print the character
	( ** temp ) = ( ** temp ) ^ 0x08; // Flip acknowledge bit
	( ** temp ) = ( ** temp ) ^ 0x02; // Flip output bit
	//fprintf(stdout, "Output after flip: %d\n" ,(** temp )& 2);
}	

// The main that handles everything
int main ( int argc, char *argv[] )
{
	int * chart = init_rot13_dev( ISR, &chart); // Call init and get the memory address of the data
	* chart = * chart | 4; // Enable ISR

	
	do {
		int i = 0; // for going through input
		char input[256] = "\0";
		input[0] = '\0';
		
		fprintf(stdout, "Input to ROT13 (ENTER to exit)\n");
		fgets(input,sizeof(input),stdin); // This works in detecting enter better than scanf
		fflush(stdout); // Flush buffer
		if(input[0] == '\n')
		{
			printf("Enter pressed. Exiting...\n");
			return 0;
		}
		while (input[i] != '\0' && input[i] != '\n') {
			if ( ((* chart) & 1) == 0 ) // Check if the input is not in there already
			{	
				chart[1] = input[i];
				i++;
				* chart = * chart | 0x01; // This turns on the input bit
			}
		}
		sleep(1); // Don't know why but I needed this to work
		fprintf(stdout, "\n");
		fflush(stdout); // Flush out buffer
		
	} //while (input[0] != '\n' && input[i] != '\0');
	while ( 1 );
	
	
	return 0;
}// end main
