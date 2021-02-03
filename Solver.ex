Code.require_file("../assign01/Sudoku.ex")

defmodule Solver do

  def solve(board) do
    board
    |> Sudoku.update_possible() # update possibility value for each cell
    |> Sudoku.update_one() # if there is only one possible value in p list, update v
    |> Sudoku.update_recur()
  end
end


path = "puzzle2.txt"
{:ok, file} = File.read(path)
pattern = :binary.compile_pattern([" ", "\r\n", "\n"])
file = String.split(file, pattern)
file = List.delete_at(file, -1) # delete EOF
puzzle = Sudoku.list_to_map(file)
#possi = Sudoku.possibility_map(file)
s = Solver.solve(puzzle)

prt = Sudoku.board_to_s(s)
IO.inspect prt
IO.inspect Sudoku.count_unsolve(prt)
