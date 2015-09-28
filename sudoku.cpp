#include <stdio.h>
#include <assert.h>

const int GRIDSIZE = 3;
const int GRID_SQUARED = GRIDSIZE*GRIDSIZE;
const int ALL_VALUES = (1<<GRID_SQUARED)-1;

int board[GRID_SQUARED][GRID_SQUARED];

char *easy_board_init[GRID_SQUARED] = {"******3**", 
													"*8***3**9", 
													"*24*7**86", 
													"9****54*8", 
													"***4*2***", 
													"1*69****5", 
													"56**3*14*", 
													"4**5***9*", 
													"**7******"};

char *hard_board_init[GRID_SQUARED] = {"*94******", 
													"1**79****", 
													"**3*86**1", 
													"92*****3*", 
													"****7****", 
													"*8*****25", 
													"4**52*9**", 
													"****61**3", 
													"******64*"};

int bit_count(int value);
int get_nth_set_bit(int value, int index);
bool singleton(int value); 
int get_singleton(int value);
bool rule2();

// Use the "board_init" variable to initialize the bitmasks for each square.
void
init_board(char *board_init[GRID_SQUARED]) {
  for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
		char c = board_init[i][j];
		if (c == '*') {
		  board[i][j] = ALL_VALUES;
		} else {
		  board[i][j] = 1 << (c - '0' - 1); 
      //  DO YOU UNDERSTAND WHAT THIS DOES?  YOU SHOULD.
		}
	 }
  }
}

// A board is done if all squares are singletons.
bool
board_done(int board[GRID_SQUARED][GRID_SQUARED]) {
  for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
		if (!singleton(board[i][j])) {
		  return false;
		}
	 }
  }
  return true;
}

// Print the board with one value per square.
void
print_board(int board[GRID_SQUARED][GRID_SQUARED]) {
  for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
		int value = board[i][j];
		char c = '*';
		if (singleton(value)) {
		  c = get_singleton(value) + '1';
		}
		printf("%c", c);
	 }
	 printf("\n");
  }
}

// Print the board with up to 9 values per square, based on what
// the possibilities are.
void
print_board_verbose() {
  for (int i = 0 ; i < GRID_SQUARED ; ++ i) {
	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
		int value = board[i][j];
		char c = ' ';
		if (singleton(value)) {
		  c = '*';
		}
		for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
		  char cc = (value & (1<<k)) ? ('1'+k) : c;
		  printf("%c", cc);
		}
		printf("%c", (j == (GRID_SQUARED-1)) ? '\n' : '|');
	 }
  }
}

int 
get_square_begin(int index) {
  return (index/GRIDSIZE) * GRIDSIZE;
}

bool
rule1() {
  bool changed = false;
  for (int i = 0 ; i < GRID_SQUARED ; ++ i) {  
	 for (int j = 0 ; j < GRID_SQUARED ; ++ j) {
		// for every square, if the value is a singleton, remove it from the row, column, and square.
		int value = board[i][j];
		if (singleton(value)) {
		  for (int k = 0 ; k < GRID_SQUARED ; ++ k) {
			 // eliminate from row
			 if (k != j) {
				if (board[i][k] & value) {
				  changed = true;
				}
				board[i][k] &= ~value;
			 }
			 // eliminate from column
			 if (k != i) {
				if (board[k][j] & value) {
				  changed = true;
				}
				board[k][j] &= ~value;
			 }
		  }

		  // elimnate from square
		  int ii = get_square_begin(i);
		  int jj = get_square_begin(j);
		  for (int k = ii ; k < ii + GRIDSIZE ; ++ k) {
		  	 for (int l = jj ; l < jj + GRIDSIZE ; ++ l) {
		  		if ((k == i) && (l == j)) {
		  		  continue;
		  		}
				if (board[k][l] & value) {
				  changed = true;
				}
		  		board[k][l] &= ~value;
		  	 }
		  }
		}
	 }
  }
  return changed;
}

bool 
solve(char *board_init[GRID_SQUARED]) {
  init_board(board_init);
  bool changed;
  do {
    print_board(board);
    changed = rule1();
    changed |= rule2();
  } while (changed);
  if (board_done(board)) {
	 printf("SUCCESS!\n");
	 print_board(board);
	 printf("\n");
	 return true;
  } else {
	 printf("FAILED!\n");
	 print_board_verbose();
	 printf("\n");
	 return false;
  }
}

int
main() {
  printf("bit_count(0x34) = %d\n", bit_count(0x34));
  printf("get_nth_set_bit(0x34, 1) = %d\n", get_nth_set_bit(0x34, 1));
  printf("singleton(0x40) = %s\n", singleton(0x40) ? "TRUE" : "FALSE");
  printf("get_singleton(0x40) = %d\n", get_singleton(0x40));
  printf("get_singleton(0x1) = %d\n", get_singleton(0x1));
  printf("singleton(0x3) = %s\n", singleton(0x3) ? "TRUE" : "FALSE");
  printf("EASY BOARD:\n");
  bool solved = solve(easy_board_init);
  print_board_verbose();
  if (solved) {
	 printf("HARD BOARD:\n");
	 solve(hard_board_init);
  }
  return 0;
}

// ALL your code goes below this line.
// 
// ---------------------------------------------------------------------

int bit_count(int value) {
  //This function counts all set bits in value
  int count = 0;
  int mask = 1;
  for(int i=0; i<31; i++){
    if( value & ( mask << i)){
      count++;
    }
  }
  return count;
  // This is also implemented as a gcc __builtin_ function
  // return __builtin_popcount(value);
}

int get_nth_set_bit(int value, int index) {
  //This function gives you the position of the indexth bit which is set
  int lastSetBitPos=0;
  int setCount=0;
  for(int i=0;i<=31;i++){
    if(value & (1<<i)){
      setCount++;
      lastSetBitPos=i;
      if(setCount>(index)){
        break;
      }
    }
  }
  return lastSetBitPos;
}

bool singleton(int value) {
  //This function checks if only a single bit is set in value
  return value && !(value & (value - 1));
}

int get_singleton(int value) {
  int returnVal;
  for(int i=0;i<31;i++){
    if(value & ( 1 << i)){
      returnVal=i;
    }
  }
  return returnVal;
}

bool rule2() {
  bool changed=false;   
  int isum=ALL_VALUES;
  int jsum=ALL_VALUES;
  int ksum=ALL_VALUES;
  for (int i = 0; i < GRID_SQUARED; ++ i){
    for (int j = 0; j < GRID_SQUARED; ++ j){
      if (!singleton(board[i][j])){
        //First, we check all values along the row
        for(int k = 0; k < GRID_SQUARED; ++k){
          //add to isum all values from board[k][j] where k!=i
          if(k!=i){
            isum = isum & board[k][j];
            }
        }
        //set board[i][j] to possibility not in i sum
        if(singleton(isum)){
           board[i][j] = board[i][j] ^ ~isum;
           changed=true;
        }
        for(int k = 0; k < GRID_SQUARED; ++k ){
        //Now we check all values along the column
          if(k!=j){
              jsum = jsum & board[i][k];
          }
        }
        //set board[i][j] to possibility not in j sum
        if(singleton(jsum)){
          board[i][j] = board[i][j] ^ ~jsum;
          changed=true;
        }
        //Now we check all quadrant values
        //We can find the quadrant the position is by dividing by 3
        int xquad = i / 3;
        int yquad = j / 3;
        for (int k = (xquad*3); k < (1+xquad)*3; k++){
            for(int l = (yquad*3); l < (1+yquad)*3; l++){
              if (k != i && l != j){
                ksum = ksum & board[k][l];
              }
            }
          }
        if(singleton(ksum)){
          board[i][j] = board[i][j] ^ ~ksum;
          changed=true;
        }
      }
    }
  }
  return changed; 
}