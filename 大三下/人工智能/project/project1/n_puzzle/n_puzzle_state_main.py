from puzzle_state import PuzzleState, astar_search_for_puzzle_problem, run_moves, generate_moves, print_moves, convert_moves, runs
import numpy as np
import time

def main():

    # Create a initial state randomly
    square_size = 4

    init_state = PuzzleState(square_size=square_size)
    # dst = [1, 2, 3,
    #        8,-1, 6,
    #        7, 4, 5]
    dst = [1,  4, 5,  14,
           2,  6, 13, 15,
           11, 7, -1, 10,
           8,  9, 12, 3  ]
    # dst = [1,  21, 5,  14, 16,
    #        2,  17, 13, 15, 6,
    #        11, 7, 18, 24, -1,
    #        8,  9, 22, 3, 10,
    #        20, 4, 12, 23, 19]
    # dst = [1,  21, 5,  25, 16, 14,
    #        2,  17, 13, 26, 35, 15, 
    #        11, 31, 18, -1, 24, 27,
    #        8,  9, 22, 33, 10, 28,
    #        20, 4, 29, 23, 19, 12,
    #        30, 7, 32, 3, 34, 6]

    init_state.state = np.asarray(dst).reshape(square_size, square_size)

    move_list = generate_moves(50)
    init_state.state = runs(init_state, move_list).state

    # Set a determined destination state
    dst_state = PuzzleState(square_size=square_size)
    dst_state.state = np.asarray(dst).reshape(square_size, square_size)

    # Find the path from 'init_state' to 'dst_state'
    tick_start = time.time()
    move_list = astar_search_for_puzzle_problem(init_state, dst_state)
    ticks = time.time() - tick_start
    # print(move_list)
    print("time consumed: %fs\n" %ticks)

    # move_list = convert_moves(move_list)      # cause I have stored the move as Move type when I generate child notes

    # Perform your path
    if run_moves(init_state, dst_state, move_list):
        print_moves(init_state, move_list)
        print("Our dst state: ")
        dst_state.display()
        print("Get to dst state. Success !!!")
    else:
        print_moves(init_state, move_list)
        print("Our dst state: ")
        dst_state.display()
        print("Can not get to dst state. Failed !!!")

main()
