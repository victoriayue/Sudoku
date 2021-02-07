Code.require_file("../assign01/Sudoku.ex")

defmodule Solver do

  def solve(file) do
    puzzle = Sudoku.list_to_map(file)
    # update possible value for each cell
    up = Sudoku.update_possible(puzzle)
    uo = Sudoku.update_one(up)
    cu = Sudoku.check_unique(uo)

    solve_recur(cu, unsolve, 10)
  end

  def solve_recur(board, unsolve, acc) do
    if unsolve == 0 || acc == 0 do
      IO.puts "===== Finish ====="
    else
      #IO.puts "===== Check unique case ====="
      uniq = Sudoku.check_unique(board)
      prt = Sudoku.board_to_s(uniq)
      unsolve = Sudoku.count_unsolve(prt)
      IO.inspect prt
      IO.puts "unsolved: #{unsolve}"

      IO.puts "===== Update Possible ====="
      uo = Sudoku.update_possible(uniq)
      prt = Sudoku.board_to_s(uo)
      unsolve = Sudoku.count_unsolve(prt)
      IO.inspect prt
      IO.puts "unsolved: #{unsolve}"
      Sudoku.possibility_to_s(uo)

      IO.puts "===== Guess value ====="
      guess = Sudoku.guess_value(uniq)
      prt = Sudoku.board_to_s(guess)
      IO.inspect prt

      IO.puts "===== Check Validation ====="
      valid = Sudoku.update_valid(guess)
      prt = Sudoku.board_to_s(valid)
      unsolve = Sudoku.count_unsolve(prt)
      IO.inspect prt
      IO.puts "unsolved: #{unsolve}"
      Sudoku.possibility_to_s(valid)

      IO.puts "===== Update Possible 2 ====="
      up2 = Sudoku.update_possible(valid)
      prt = Sudoku.board_to_s(up2)
      unsolve = Sudoku.count_unsolve(prt)
      IO.inspect prt
      IO.puts "unsolved: #{unsolve}"

      # recur
      solve_recur(up2, unsolve, acc-1)
    end
  end



end


path = "puzzle3.txt"
{:ok, file} = File.read(path)
pattern = :binary.compile_pattern([" ", "\r\n", "\n"])
file = String.split(file, pattern)
file = List.delete_at(file, -1) # delete EOF

Solver.solve(file)


# , charlists: :as_lists
