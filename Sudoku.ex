defmodule Sudoku do

  # %{ [rowidx, colidx, blockidx] => value}
  # return a map
  def list_to_map(list) do
    list
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({cell, cell_index}, acc) -> # acc, accumulator is the prev map
      row = div(cell_index, 9)    # rowindex, divide by 9
      col = rem(cell_index, 9)     # colindex, reminder by 9
      block = div(row, 3) * 3 + div(col, 3) # block index

      cell = String.to_integer(cell)
      possible = []

      if cell == 0 do
        possible = [1,2,3,4,5,6,7,8,9]
        Map.merge(acc, %{ [row, col, block] => {cell, possible} })
      else
        Map.merge(acc, %{ [row, col, block] => {cell, possible} })
      end
    end)
  end

  def possibility_map(list) do
    list
    |> Stream.with_index
    |> Enum.reduce(%{}, fn({cell, cell_index}, acc) ->
      row = div(cell_index, 9)    # rowindex, divide by 9
      col = rem(cell_index, 9)     # colindex, reminder by 9
      block = div(row, 3) * 3 + div(col, 3) # block index
      possible = []
      cell = String.to_integer(cell)
      if cell == 0 do
        possible = [1,2,3,4,5,6,7,8,9]
        Map.merge(acc, %{ [row, col, block] => possible })
      else
        Map.merge(acc, %{ [row, col, block] => possible })
      end
    end)
  end

  def possibility_value(value) do
    [1,2,3,4,5,6,7,8,9] -- value
  end

  def update_possible(board) do
    Enum.map(board, fn({[row, col, block], {v, p}}) -> # p is a list of possible value
        possi_r = MapSet.new(fetch_row(board, row))
        possi_c = MapSet.new(fetch_col(board, col))
        possi_b = MapSet.new(fetch_block(board, block))

        intersect = MapSet.union(MapSet.union(possi_b, possi_c), possi_r)
        intersect = MapSet.to_list(intersect)

        {[row, col, block], {v, p -- intersect}}

      end)
  end

  def update_one(board) do
    Enum.map(board, fn {[row, col, block], {v, p}} ->
      if length(p) == 1 do
        {[row, col, block], {List.first(p), p}}
      else
        {[row, col, block], {v, p}}
      end
    end)
  end

  def fetch_row(board, fetch_row) do
    board
    |> Enum.filter(fn ({[row, _col, _block], {_value, _p}}) -> row == fetch_row end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def fetch_col(board, fetch_col) do
    board
    |> Enum.filter(fn ({[_row, col, _block], {_value, _p}}) -> col == fetch_col end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def fetch_block(board, fetch_block) do
    board
    |> Enum.filter(fn ({[_row, _col, block], {_value, _p}}) -> block == fetch_block end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def board_to_s(board) do
    board
    |> Enum.sort()
    |> Enum.reduce([], fn ({[_row, _col, _block], {v, _p}}, acc) ->
      acc ++ [v]
    end)
    |> Enum.chunk_every(9)
  end

  def count_unsolve(list) do
    list
    |> List.flatten()
    |> Enum.filter(fn n -> n==0 end)
    |> Enum.count()
  end

  def possibility_to_s(board) do
    Enum.map(board, fn {[row, col, _block], {_v, p}} ->
        IO.puts "At row:#{row} col:#{col}, the possible is "
        IO.inspect p
    end)
  end


  def update_recur(board) do
    board
    |> Enum.sort()
    |> Enum.reduce(%{}, fn ({[row, col, block], {value, possi}}, acc) ->
      #Enum.into(acc, update_row(board, row, col, block, v, p) )
      {[r, c, b], {v, p}} = update_row(board, row, col, block, value, possi)
      Map.merge(acc, %{ [r, c, b] => {v, p} } )
    end)
  end

  def update_row(board, row, col, block, v, p) when p == [] do
    {[row, col, block], {v, p}}
  end

  def update_row(board, row, col, block, v, p) do
    guess = List.first(p)
    if is_valid(board, row, col, block, guess) do
      {[row, col, block], {guess, []}}
    else
      p = p -- [guess] # remove invalid value
      update_row(board, row, col, block, v, p)
    end
  end

  def is_valid(board, row, col, block, guess) do
    possi_r = MapSet.new(fetch_row(board, row))
    possi_c = MapSet.new(fetch_col(board, col))
    possi_b = MapSet.new(fetch_block(board, block))

    intersect = MapSet.union(MapSet.union(possi_b, possi_c), possi_r)
    intersect = MapSet.to_list(intersect)


    IO.puts "in row #{row}, col #{col}"
    if guess in intersect do
      false
    else
      IO.puts "guess is #{guess}, list is"
      IO.inspect intersect
      true
    end
  end

end

# a Cell represent a single number in Sudoku
