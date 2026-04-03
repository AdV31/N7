#include "aux.h"



int main(int argc, char **argv){
  int    i, j, n, nrooms, nplayers, room, player, next_room, finish;
  int *rooms_list;
  long ts, te;
  omp_lock_t *room_locks;
  
   /* Command line argument */
  if ( argc == 3 ) {
    nrooms    = atoi(argv[1]);    /* the number of rooms */
    nplayers  = atoi(argv[2]);    /* the number of players */
  } else {
    printf("Usage:\n\n ./main nrooms nplayers, nwhere\n");
    printf("nrooms      is the number of rooms\n");
    printf("nplayers    is the number of players\n");
    return 1;
  }

  finish = 0;
  room_locks = (omp_lock_t*)malloc(nrooms*sizeof(omp_lock_t));
  for(room=0; room<nrooms; room++) omp_init_lock(room_locks + room);
  
  init(nplayers, nrooms);
  
  printf("\n==================================================\n");
  printf("The escape game begins\n\n");
  
  omp_set_num_threads(nplayers);

  #pragma omp parallel private(player,room,next_room)
  {
    player = omp_get_thread_num();
    room = get_my_first_room(player, nrooms);
    omp_set_lock(room_locks + room);
    printf("Player %2d entering the game from room %2d\n",player,room);
    
    for (;;){
      next_room = solve_enigma(player, room, nrooms);
      omp_unset_lock(room_locks + room);
      
      if(next_room==-999) {
        printf("There was an error!!!  %2d %2d\n",player,room);
        break;
      } else if (next_room==1000){
        /* Found the exit door!!! quit the game*/
        printf("Yahi! Player %2d found the exit door!\n",player);
        finish = 1;
        break;
      } else if(finish == 1) {
          break;
      } else {
        room = next_room;
      }
      omp_set_lock(room_locks + room);
    }
    printf("Player %2d is out!\n",player);

    printf("\n==================================================\n");

  }
  return 0;
}
