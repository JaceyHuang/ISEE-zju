#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time    : 2019/3/3 9:51
# @Author  : yaoqi
# @Email   : yaoqi_isee@zju.edu.cn 
# @File    : main_tic_tac_toe.py

from tic_tac_toe import GameJudge, MinimaxSearch


if __name__ == '__main__':
    judge = GameJudge()
    player, status = -1, 2  # you move first, game is going on
    judge.print_status(-2, status)

    while status == 2:
        # your turn
        r_human, c_human = judge.human_input()
        judge.make_one_move(r_human, c_human, player)
        status = judge.check_game_status()
        judge.print_status(player, status)
        player *= -1

        if status != 2:
            break

        # computer's turn
        r_computer, c_computer = MinimaxSearch(judge.get_game_state())
        judge.make_one_move(r_computer, c_computer, player)
        status = judge.check_game_status()
        judge.print_status(player, status)
        player *= -1
