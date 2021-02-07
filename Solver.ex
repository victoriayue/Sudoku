Code.require_file("../assign01/Sudoku.ex")

defmodule Solver do

  def empty_puzzle() do
    puzzle = generator()
    solve(puzzle)
  end
  @doc """
  Solving specific sudoku puzzle
  """
  def solve_puzzle() do
    path = "puzzle3.txt"
    {:ok, file} = File.read(path)
    pattern = :binary.compile_pattern([" ", "\r\n", "\n"])
    file = String.split(file, pattern)
    file = List.delete_at(file, -1) # delete EOF
    solve(file)
  end

  @doc """
  solve method to call solve recursion method
  """
  def solve(file) do
    puzzle = Sudoku.list_to_map(file)
    # update possible value for each cell
    up = Sudoku.update_possible(puzzle)
    uo = Sudoku.update_one(up)
    cu = Sudoku.check_unique(uo)

    prt = Sudoku.board_to_s(cu)
    unsolve = Sudoku.count_unsolve(prt)
    IO.inspect prt
    IO.puts "unsolved: #{unsolve}"
    solve_recur(cu, unsolve, 30)
  end

  @doc """
  recursion method,
  acc: loop time for recursion
  """
  def solve_recur(board, unsolve, acc) do
    if unsolve == 0 || acc == 0 do
      prt = Sudoku.board_to_s(board)
      IO.inspect prt
      IO.puts "unsolved: #{unsolve}"
      IO.puts "===== Finish ====="
    else
      uniq = Sudoku.check_unique(board)
      uo = Sudoku.update_possible(uniq)

      guess = Sudoku.guess_value(uo)
      valid = Sudoku.update_valid(guess)
      up2 = Sudoku.update_possible(valid)

      prt = Sudoku.board_to_s(up2)
      unsolve = Sudoku.count_unsolve(prt)
      # recur
      solve_recur(up2, unsolve, acc-1)
    end
  end

  @doc """
  generate remain 0 cell
  """
  def generator() do

    first_row = generate_row()
    zero = String.duplicate("0", 81-length(first_row))
    zero = String.split(zero, "")
    zero = zero -- [""]
    zero = zero -- [""]
    zero = first_row ++ zero

    zero
  end

  @doc """
  generate first random row
  """
  def generate_row() do
    # random generate
    line = ["1","2","3","4","5","6","7","8","9"]
    Enum.reduce(line, [], fn _, acc ->
      rnd = :rand.uniform(8)
      num = Enum.at(line, rnd)
      if not(num in acc) do
        acc ++ [num]
      else
        acc
      end
    end)

  end

end

Solver.generator()
