defmodule Sudoku do

  # %{ [rowidx, colidx, blockidx] => value}
  # return a map
  # possible = [], initial number, can't change
  # possible = [v], guess number
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

  @doc """
  Update lists of possible values of each cell from board
  param: board
  return: list of tuple
  """
  def update_possible(board) do
    Enum.map(board, fn({[row, col, block], {v, p}}) -> # p is a list of possible value
        if v != 0 do
          {[row, col, block], {v, [v]}}
        end
        if p != [] && v == 0 do
          intersect = get_neighbors(board, row, col, block)
          #IO.puts "At row:#{row} col:#{col} value#{v}, the intersect is "
          #IO.inspect intersect, charlists: :as_lists
          if length(intersect) == 8 do
            v = List.first([1,2,3,4,5,6,7,8,9] -- intersect)
            {[row, col, block], {v, [v]}}
          else
            {[row, col, block], {v, p -- intersect}}
          end
        else
          {[row, col, block], {v, p}} # if v is init value, don't change
        end

      end)
  end

  @doc """
  finding neighbor's value of specific cell
  param: board, row, col, block index
  return: a list of int
  """
  def get_neighbors(board, row, col, block) do
    possi_r = MapSet.new(fetch_row(board, row, col))
    possi_c = MapSet.new(fetch_col(board, row, col))
    possi_b = MapSet.new(fetch_block(board, row, col, block))

    intersect = MapSet.union(MapSet.union(possi_b, possi_c), possi_r)
    MapSet.to_list(intersect)
  end

  @doc """
  check whether the guess value for specific cell is valid
  return: boolean
  """
  def is_valid(board, row, col, block, guess) do
    intersect = get_neighbors(board, row, col, block)
    #IO.puts "in row #{row}, col #{col}, the guess is #{guess}, the neighbor is "
    #IO.inspect intersect
    if guess in intersect do false else true end
  end


  @doc """
  for each cell, if it's possible value list contains only one number,
  update its value
  Then, call update_possible() to update other possible value list
  return: list of tuple
  """
  def update_one(board) do
    board
    |> Enum.map(fn {[row, col, block], {v, p}} ->
        if length(p) == 1 && v == 0 do
          {[row, col, block], {List.first(p), p}}
        else
          {[row, col, block], {v, p}}
        end
      end)
    |> update_possible()
  end

  @doc """
  gather the value from specific row, col and block
  return: list
  """
  def fetch_row(board, fetch_row, fetch_col) do
    board
    |> Enum.filter(fn ({[row, _col, _block], {_value, _p}}) -> row == fetch_row end)
    |> Enum.filter(fn ({[_row, col, _block], {_value, _p}}) -> col != fetch_col end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def fetch_col(board, fetch_row, fetch_col) do
    board
    |> Enum.filter(fn ({[_row, col, _block], {_value, _p}}) -> col == fetch_col end)
    |> Enum.filter(fn ({[row, _col, _block], {_value, _p}}) -> row != fetch_row end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def fetch_block(board,  fetch_row, fetch_col, fetch_block) do
    board
    |> Enum.filter(fn ({[_row, _col, block], {_value, _p}}) -> block == fetch_block end)
    |> Enum.filter(fn ({[row, col, _block], {_value, _p}}) -> row != fetch_row && col != fetch_col end)
    |> Enum.filter(fn ({[_row, _col, _block], {value, _p}}) -> value != 0 end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {value, _p}}, acc) ->
      acc ++ [value]
    end)
  end

  def get_p_neighbors(board, row, col, block, p) do
    row_p = fetch_row_p(board, row, col)
    col_p = fetch_col_p(board, row, col)
    block_p = fetch_block_p(board, row, col, block)
    sum = row_p ++ col_p ++ block_p
    p -- sum
  end
  @doc """
  gather all the possible value from specific row, col, and block
  return: an int or nil
  """
  def fetch_row_p(board, fetch_row, fetch_col) do
    board
    |> Enum.filter(fn ({[row, _col, _block], {_value, _p}}) -> row == fetch_row end)
    |> Enum.filter(fn ({[_row, col, _block], {_value, _p}}) -> col != fetch_col end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {_value, p}}, acc) ->
      acc ++ p
    end)
    |> List.flatten()
    |> Enum.sort()
  end

  def fetch_col_p(board, fetch_row, fetch_col) do
    board
    |> Enum.filter(fn ({[_row, col, _block], {_value, _p}}) -> col == fetch_col end)
    |> Enum.filter(fn ({[row, _col, _block], {_value, _p}}) -> row != fetch_row end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {_value, p}}, acc) ->
      acc ++ p
    end)
    |> List.flatten()
    |> Enum.sort()
  end

  def fetch_block_p(board, fetch_row, fetch_col, fetch_block) do
    board
    |> Enum.filter(fn ({[_row, _col, block], {_value, _p}}) -> block == fetch_block end)
    |> Enum.filter(fn ({[row, col, _block], {_value, _p}}) -> row != fetch_row && col != fetch_col end)
    |> Enum.reduce([], fn ({[_row, _col, _block], {_value, p}}, acc) ->
      acc ++ p
    end)
    |> List.flatten()
    |> Enum.sort()
  end


  @doc """
  print board from map to string
  """
  def board_to_s(board) do
    board
    |> Enum.sort()
    |> Enum.reduce([], fn ({[_row, _col, _block], {v, _p}}, acc) ->
      acc ++ [v]
    end)
    |> Enum.chunk_every(9)
  end

  @doc """
  Count how many value are == 0, which means the value is unsolved
  """
  def count_unsolve(list) do
    list
    |> List.flatten()
    |> Enum.filter(fn n -> n==0 end)
    |> Enum.count()
  end

  @doc """
  print all the possibility of cell
  """
  def possibility_to_s(board) do
    Enum.map(board, fn {[row, col, _block], {v, p}} ->
      IO.puts "At row:#{row} col:#{col} value#{v}, the possible is "
      IO.inspect p, charlists: :as_lists
    end)
  end

  def guess_value(board) do
    board
    |> Enum.map(fn {[row, col, block], {v, p}} ->
        # find unique case
        if length(p) > 1 && v == 0 do
          rnd = :rand.uniform(length(p)-1)
          guess = Enum.at(p, rnd)
          {[row, col, block], {guess, p -- [guess]}}
        else
          {[row, col, block], {v, p}}
        end
       end)
  end

  @doc """
  check validation for each cell, if not valid, change value back to 0
  """
  def update_valid(board) do
    board
    |> Enum.map(fn {[row, col, block], {v, p}} ->
        #IO.puts "at row#{row} col#{col}, value#{v}"
        #IO.inspect p, charlists: :as_lists
        isv = is_valid(board, row, col, block, v)
        cond do
          # init value
          p == [] ->
            {[row, col, block], {v, p}}
          # already calcualted value
          v == List.first(p) && length(p) == 1 ->
            {[row, col, block], {v, p}}
          # got valid value
          isv ->
            {[row, col, block], {v, [v]}}
          # no more guess in p, restart p
          #!isv && length(p) == 1 ->
          #  {[row, col, block], {0, [1,2,3,4,5,6,7,8,9] -- [v]}}
          # not valid guess, try again
          !isv ->
            {[row, col, block], {0, p ++ [v]}}
          true ->
            {[row, col, block], {v, p}}
        end
      end)
  end

  def check_unique(board) do
    board
    |> Enum.map(fn {[row, col, block], {v, p}} ->
      uniq = get_p_neighbors(board, row, col, block, p)
      uniq_num = List.first(uniq)
      cond do
        length(uniq) == 1 ->
          {[row, col, block], {uniq_num, [uniq_num]}}
        length(p) == 1 ->
          {[row, col, block], {List.first(p), p}}
        true ->
          {[row, col, block], {v, p}}
      end

    end)

  end



end

# a Cell represent a single number in Sudoku
