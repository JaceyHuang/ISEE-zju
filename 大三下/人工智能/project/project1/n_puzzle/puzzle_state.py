from re import T
from tkinter import RIGHT
import numpy as np
from enum import Enum
import copy


# Enum of operation in EightPuzzle problem
class Move(Enum):
    """
    The class of move operation
    NOTICE: The direction denotes the 'blank' space move
    """
    Up = 0
    Down = 1
    Left = 2
    Right = 3


# EightPuzzle state
class PuzzleState(object):
    """
    Class for state in EightPuzzle-Problem
    Attr:
        square_size: Chessboard size, e.g: In 8-puzzle problem, square_size = 3
        state: 'square_size' x 'square_size square', '-1' indicates the 'blank' block  (For 8-puzzle, state is a 3 x 3 array)
        g: The cost from initial state to current state
        h: The value of heuristic function
        pre_move:  The previous operation to get to current state
        pre_state: Parent state of this state
    """
    def __init__(self, square_size = 3):
        self.square_size = square_size
        self.state = None
        self.g = 0
        self.h = 0
        self.pre_move = None
        self.pre_state = None

        self.generate_state()

    def __eq__(self, other):
        return (self.state == other.state).all()

    def blank_pos(self):
        """
        Find the 'blank' position of current state
        :return:
            row: 'blank' row index, '-1' indicates the current state may be invalid
            col: 'blank' col index, '-1' indicates the current state may be invalid
        """
        index = np.argwhere(self.state == -1)
        row = -1
        col = -1
        if index.shape[0] == 1:  # find blank
            row = index[0][0]
            col = index[0][1]
        return row, col

    def num_pos(self, num):
        """
        Find the 'num' position of current state
        :return:
            row: 'num' row index, '-1' indicates the current state may be invalid
            col: 'num' col index, '-1' indicates the current state may be invalid
        """
        index = np.argwhere(self.state == num)
        row = -1
        col = -1
        if index.shape[0] == 1:  # find number
            row = index[0][0]
            col = index[0][1]
        return row, col

    def is_valid(self):
        """
        Check current state is valid or not (A valid state should have only one 'blank')
        :return:
            flag: boolean, True - valid state, False - invalid state
        """
        row, col = self.blank_pos()
        if row == -1 or col == -1:
            return False
        else:
            return True

    def clone(self):
        """
        Return the state's deepcopy
        :return:
        """
        return copy.deepcopy(self)

    def generate_state(self, random=False, seed=None):
        """
        Generate a new state
        :param random: True - generate state randomly, False - generate a normal state
        :param seed: Choose the seed of random, only used when random = True
        :return:
        """
        self.state = np.arange(0, self.square_size ** 2).reshape(self.square_size, -1)
        self.state[self.state == 0] = -1  # Set blank

        if random:
            np.random.seed(seed)
            np.random.shuffle(self.state)

    def display(self):
        """
        Print state
        :return:
        """
        print("----------------------")
        for i in range(self.state.shape[0]):
            # print("{}\t{}\t{}\t".format(self.state[i][0], self.state[i][1], self.state[i][2]))
            # print(self.state[i, :])
            for j in range(self.state.shape[1]):
                if j == self.state.shape[1] - 1:
                    print("{}\t".format(self.state[i][j]))
                else:
                    print("{}\t".format(self.state[i][j]), end='')
        print("----------------------\n")


def check_move(curr_state, move):
    """
    Check the operation 'move' can be performed on current state 'curr_state'
    :param curr_state: Current puzzle state
    :param move: Operation to be performed
    :return:
        valid_op: boolean, True - move is valid; False - move is invalid
        src_row: int, current blank row index
        src_col: int, current blank col index
        dst_row: int, future blank row index after move
        dst_col: int, future blank col index after move
    """
    # assert isinstance(move, Move)  # Check operation type
    assert curr_state.is_valid()

    if not isinstance(move, Move):
        move = Move(move)

    src_row, src_col = curr_state.blank_pos()
    dst_row, dst_col = src_row, src_col
    valid_op = False

    if move == Move.Up:  # Number moves up, blank moves down
        dst_row -= 1
    elif move == Move.Down:
        dst_row += 1
    elif move == Move.Left:
        dst_col -= 1
    elif move == Move.Right:
        dst_col += 1
    else:  # Invalid operation
        dst_row = -1
        dst_col = -1

    if dst_row < 0 or dst_row > curr_state.state.shape[0] - 1 or dst_col < 0 or dst_col > curr_state.state.shape[1] - 1:
        valid_op = False
    else:
        valid_op = True

    return valid_op, src_row, src_col, dst_row, dst_col


def once_move(curr_state, move):
    """
    Perform once move to current state
    :param curr_state:
    :param move:
    :return:
        valid_op: boolean, flag of this move is valid or not. True - valid move, False - invalid move
        next_state: EightPuzzleState, state after this move
    """
    valid_op, src_row, src_col, dst_row, dst_col = check_move(curr_state, move)

    next_state = curr_state.clone()

    if valid_op:
        it = next_state.state[dst_row][dst_col]
        next_state.state[dst_row][dst_col] = -1
        next_state.state[src_row][src_col] = it
        next_state.pre_state = curr_state
        next_state.pre_move = move
        return True, next_state
    else:
        return False, next_state


def check_state(src_state, dst_state):
    """
    Check current state is same as destination state
    :param src_state:
    :param dst_state:
    :return:
    """
    return (src_state.state == dst_state.state).all()


def run_moves(curr_state, dst_state, moves):
    """
    Perform list of move to current state, and check the final state is same as destination state or not
    Ideally, after we perform moves to current state, we will get a state same as the 'dst_state'
    :param curr_state: EightPuzzleState, current state
    :param dst_state: EightPuzzleState, destination state
    :param moves: List of Move
    :return:
        flag of moves: True - We can get 'dst_state' from 'curr_state' by 'moves'
    """
    pre_state = curr_state.clone()
    next_state = None

    for move in moves:
        valid_move, next_state = once_move(pre_state, move)

        if not valid_move:
            return False

        pre_state = next_state.clone()

    if check_state(next_state, dst_state):
        return True
    else:
        return False


def runs(curr_state, moves):
    """
    Perform list of move to current state, get the result state
    NOTICE: The invalid move operation would be ignored
    :param curr_state:
    :param moves:
    :return:
    """
    pre_state = curr_state.clone()
    next_state = None

    for move in moves:
        valid_move, next_state = once_move(pre_state, move)
        pre_state = next_state.clone()
    return next_state


def print_moves(init_state, moves):
    """
    While performing the list of move to current state, this function will also print how each move is performed
    :param init_state: The initial state
    :param moves: List of move
    :return:
    """
    print("Initial state")
    init_state.display()

    pre_state = init_state.clone()
    next_state = None

    for idx, move in enumerate(moves):
        # if move == Move.Up:  # Number moves up, blank moves down
        #     print("{} th move. Goes up.".format(idx))
        # elif move == Move.Down:
        #     print("{} th move. Goes down.".format(idx))
        # elif move == Move.Left:
        #     print("{} th move. Goes left.".format(idx))
        # elif move == Move.Right:
        #     print("{} th move. Goes right.".format(idx))
        # else:  # Invalid operation
        #     print("{} th move. Invalid move: {}".format(idx, move))

        valid_move, next_state = once_move(pre_state, move)

        if not valid_move:
            print("Invalid move: {}, ignore".format(move))

        # next_state.display()

        pre_state = next_state.clone()

    print("We get final state: ")
    next_state.display()


def generate_moves(move_num = 30):
    """
    Generate a list of move in a determined length randomly
    :param move_num:
    :return:
        move_list: list of move
    """
    move_dict = {}
    move_dict[0] = Move.Up
    move_dict[1] = Move.Down
    move_dict[2] = Move.Left
    move_dict[3] = Move.Right

    index_arr = np.random.randint(0, 4, move_num)
    index_list = list(index_arr)

    move_list = [move_dict[idx] for idx in index_list]

    return move_list


def convert_moves(moves):
    """
    Convert moves from int into Move type
    :param moves:
    :return:
    """
    if len(moves):
        if isinstance(moves[0], Move):
            return moves
        else:
            return [Move(move) for move in moves]
    else:
        return moves


"""
NOTICE:
1. init_state is a 3x3 numpy array, the "space" is indicated as -1, for example
    1 2 -1              1 2
    3 4 5   stands for  3 4 5
    6 7 8               6 7 8
2. moves contains directions that transform initial state to final state. Here
    0 stands for up
    1 stands for down
    2 stands for left
    3 stands for right
    We 
   There might be several ways to understand "moving up/down/left/right". Here we define
   that "moving up" means to move 'space' up, not move other numbers up. For example
    1 2 5                1 2 -1
    3 4 -1   move up =>  3 4 5
    6 7 8                6 7 8
   This definition is actually consistent with where your finger moves to
   when you are playing 8 puzzle game.
   
3. It's just a simple example of A-Star search. You can implement this function in your own design.  
"""
def astar_search_for_puzzle_problem(init_state, dst_state):
    """
    Use AStar-search to find the path from init_state to dst_state
    :param init_state:  Initial puzzle state
    :param dst_state:   Destination puzzle state
    :return:  All operations needed to be performed from init_state to dst_state
        moves: list of Move. e.g: move_list = [Move.Up, Move.Left, Move.Right, Move.Up]
    """

    start_state = init_state.clone()
    end_state = dst_state.clone()
    # print(dst_state.state,"\n")

    open_list = []   # You can also use priority queue instead of list
    close_list = []

    move_list = []  # The operations from init_state to dst_state

    # Initial A-star
    open_list.append(start_state)
    # print(start_state.state)

    num_expand = 0
    print("Manhattan distance\n")

    while len(open_list) > 0:
        # Get best node from open_list
        curr_idx, curr_state = find_front_node(open_list)
        # print(curr_state.state,"\n")

        # Delete best node from open_list
        open_list.pop(curr_idx)

        # Add best node in close_list
        close_list.append(curr_state)

        # Check whether found solution
        if curr_state == dst_state:
            move_list = get_path(curr_state)
            print("node expanded: %d" %num_expand)
            return move_list

        # Expand node
        children = expand_state(curr_state)

        for child_state in children:
            # print(child_state.state)
            # Explored node
            num_expand += 1
            in_list, match_state = state_in_list(child_state, close_list)
            if in_list:
                continue

            # Assign cost to child state. You can also do this in Expand operation
            child_state = update_cost(child_state, dst_state)

            # Find a better state in open_list
            in_list, match_state = state_in_list(child_state, open_list)
            if in_list:
                continue

            open_list.append(child_state)  


def find_front_node(open_list):
    """
    Find the best node in the open_list with smallest f 
    :param open_list:  the open list of A* search
    :return:  
        the best node and its index in the open list
    """
    curr_state = open_list[0]
    curr_idx = 0
    for state in open_list:
        if state.g + state.h < curr_state.g + curr_state.h:
            # if state.g + 1.2*state.h < curr_state.g + 1.2*curr_state.h:
            curr_state = state                                # get the node with smallest f = g + h
            curr_idx = open_list.index(state)                 # the node's index in the list
    return curr_idx, curr_state


def get_path(curr_state):
    """
    Return moving commands list from initial state to current state.
    :param curr_state:  the current state
    :return:  
        moving commands list
    """
    moves = []
    temp_state = copy.deepcopy(curr_state)
    while temp_state.pre_state:                              # untill current state is the initial state
        # print(temp_state.pre_move)
        moves.append(temp_state.pre_move)                    # append the move
        temp_state = copy.deepcopy(temp_state.pre_state)     # trace back
    moves.reverse()                                          # mind the order of the moves
    return moves                                


def expand_state(curr_state):
    """
    Expand current state to generate children nodes.
    :param curr_state:  the current state
    :return:  
        the children nodes of current state
    """
    children = []
    square_size = curr_state.square_size
    row, col = curr_state.blank_pos()
    if row == 0:                                             # the blank is in the 0 row
        if col == 0:                                         # the blank is in the [0][0], so only tow children exits
            child1 = move_right(curr_state, row, col) 
            children.append(child1)
            
            child2 = move_down(curr_state, row, col)
            children.append(child2)

        elif col == square_size - 1:                         # the blank is in the [0][square_size-1], and only two children exits
            child1 = move_left(curr_state, row, col)
            children.append(child1)
            
            child2 = move_down(curr_state, row, col)
            children.append(child2)

        else:                                                # there are 3 options
            child1 = move_left(curr_state, row, col)
            children.append(child1)

            child2 = move_right(curr_state, row, col)
            children.append(child2)

            child3 = move_down(curr_state, row, col)
            children.append(child3)

    elif row == square_size - 1:
        if col == 0:                                         # the blank is in the [square_size-1][0], so only tow children exits
            child1 = move_right(curr_state, row, col) 
            children.append(child1)
            
            child2 = move_up(curr_state, row, col)
            children.append(child2)

        elif col == square_size - 1:                         # the blank is in the [square_size-1][square_size-1], and only two children exits
            child1 = move_left(curr_state, row, col) 
            children.append(child1)
            
            child2 = move_up(curr_state, row, col)
            children.append(child2)

        else:                                                # there are 3 options
            child1 = move_left(curr_state, row, col)
            children.append(child1)

            child2 = move_right(curr_state, row, col)
            children.append(child2)

            child3 = move_up(curr_state, row, col)
            children.append(child3)
    
    else:
        if col == 0:                                         # there are 3 options
            child1 = move_right(curr_state, row, col)
            children.append(child1)

            child2 = move_up(curr_state, row, col)
            children.append(child2)

            child3 = move_down(curr_state, row, col)
            children.append(child3)

        elif col == square_size - 1:                         # there are 3 options
            child1 = move_left(curr_state, row, col)
            children.append(child1)

            child2 = move_up(curr_state, row, col)
            children.append(child2)

            child3 = move_down(curr_state, row, col)
            children.append(child3)

        else:                                                # there are 4 options
            child1 = move_up(curr_state, row, col)
            children.append(child1)

            child2 = move_down(curr_state, row, col)
            children.append(child2)

            child3 = move_left(curr_state, row, col)
            children.append(child3)

            child4 = move_right(curr_state, row, col)
            children.append(child4)

    return children


def state_in_list(child_state, list):
    """
    Check whether a state is in the state list.
    :param child_state:  the state waiting to be checked
    :param list:  the list of A* search, may be open list or close lists
    :return:  
        a flag shows whether the state is in the list. True - in, False - not in
        the matched state if the child_state is in the list
    """
    for state in list:
        if (child_state.state == state.state).all():                     # the states are the same
            return True, state
    return False, None


def update_cost(child_state, dst_state):
    """
    Update the cost value of current state.
    :param child_state:  the current state
    :param dst_state:  the destination state
    :return:
        the child node with its cost
    """
    child_state.g = 0
    square_size = child_state.square_size
    temp_child = copy.deepcopy(child_state)
    # print(type(temp_child.pre_state))
    while temp_child.pre_state:                                          # backward cost g
        child_state.g += 1
        temp_child = temp_child.pre_state

    # Hamming distance
    # d = np.argwhere(child_state.state != dst_state.state)
    # child_state.h = len(d)                                               # forward cost h: the number of elements that are different between child_state and dst_state

    # Manhattan distance
    child_state.h = 0
    for i in range(-1,square_size**2):
        child_d = np.argwhere(child_state.state == i)
        dst_d = np.argwhere(dst_state.state == i)
        if not (child_d == dst_d).all():
            child_state.h += abs(child_d[0][0]-dst_d[0][0])+abs(child_d[0][1]-dst_d[0][1])  # forward cost h: the sum of the differences between the child_state and dst_state on x and y axis

    # Euclidean Distance
    # child_state.h = 0
    # for i in range(-1,square_size**2):
    #     child_d = np.argwhere(child_state.state == i)
    #     dst_d = np.argwhere(dst_state.state == i)
    #     if not (child_d == dst_d).all():
    #         child_state.h += ((child_d[0][0]-dst_d[0][0])**2+(child_d[0][1]-dst_d[0][1])**2)**0.5  # forward cost h: the direct distance between misplaced elements of the child_state and dst_state

    return child_state


def move_up(curr_state, row, col):
    """
    Get a child note which can be obtained by move up the blank.
    :param curr_state:  the current state
    :param row:  the row where blank locates
    :param col:  the col where blank locates
    :return:
        the child note obtained by move up the blank
    """
    square_size = curr_state.square_size
    move = Move
    child = PuzzleState(square_size=square_size)
    child.pre_state = curr_state.clone()            # the parent node
    child.pre_move = move.Up                        # move Up
    child.state = copy.deepcopy(curr_state.state)
    child.state[[row,row-1],[col]], child.state[[row-1],[col]] = child.state[[row-1],[col]], child.state[[row],[col]]  # swap the elements
    return child


def move_down(curr_state, row, col):
    """
    Get a child note which can be obtained by move down the blank.
    :param curr_state:  the current state
    :param row:  the row where blank locates
    :param col:  the col where blank locates
    :return:
        the child note obtained by move down the blank
    """
    square_size = curr_state.square_size
    move = Move
    child = PuzzleState(square_size=square_size)
    child.pre_state = curr_state.clone()            # the parent node
    child.pre_move = move.Down                      # move Down
    child.state = copy.deepcopy(curr_state.state)
    child.state[[row],[col]], child.state[[row+1],[col]] = child.state[[row+1],[col]], child.state[[row],[col]]  # swap the elements
    return child


def move_left(curr_state, row, col):
    """
    Get a child note which can be obtained by move left the blank.
    :param curr_state:  the current state
    :param row:  the row where blank locates
    :param col:  the col where blank locates
    :return:
        the child note obtained by move left the blank
    """
    square_size = curr_state.square_size
    move = Move
    child = PuzzleState(square_size=square_size)
    child.pre_state = curr_state.clone()            # the parent node
    child.pre_move = move.Left                      # move left
    child.state = copy.deepcopy(curr_state.state)
    child.state[[row],[col]], child.state[[row],[col-1]] = child.state[[row],[col-1]], child.state[[row],[col]]  # swap the elements
    return child


def move_right(curr_state, row, col):
    """
    Get a child note which can be obtained by move right the blank.
    :param curr_state:  the current state
    :param row:  the row where blank locates
    :param col:  the col where blank locates
    :return:
        the child note obtained by move right the blank
    """
    square_size = curr_state.square_size
    move = Move
    child = PuzzleState(square_size=square_size)
    child.pre_state = curr_state.clone()            # the parent node
    child.pre_move = move.Right                     # move right
    child.state = copy.deepcopy(curr_state.state)
    child.state[[row],[col]], child.state[[row],[col+1]] = child.state[[row],[col+1]], child.state[[row],[col]]  # swap the elements
    return child