defmodule Memory.Game do
  def new do
    %{
      squares: shuffle_deck(),
      cards: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15],
      selected_indices: [],    # selected index
      selected_value: [],      # selected card
      paired_value: [],        # pairs card
      paired_indices: [],      # pairs index
      moves: 0,
    }
  end

  def client_view(game) do
    deck = game.squares               # The shuffled deck
    card_indices = game.cards         # The card indices
    selected_indices = game.selected_indices  # The selected card indices
    paired_indices = game.paired_indices     # The paired card indices
    %{
      skel: skeleton(deck, card_indices, paired_indices, selected_indices),
      completed: paired_indices,
      show: selected_indices,
      step: game.moves              # The total steps so far
    }
  end

  def set(game, _flag) do
      game
      |> Map.put(:selected_indices, [])
      |> Map.put(:selected_value, [])
  end

  def skeleton(deck, card_indices, paired_indices, selected_indices) do
    Enum.map card_indices, fn i ->
      if Enum.member?(selected_indices, i) or Enum.member?(paired_indices, i) do
        Enum.at(deck, i)
      else
        "?"
      end
    end
  end

  def guess(game, card) do
    deck = game.squares
    paired_indices = game.paired_indices
    selected_indices = game.selected_indices
    selected_value = game.selected_value

    if length(selected_indices) == 2 do
      selected_indices = [card]
      selected_value = [Enum.at(deck, card)]
    else
      selected_indices = selected_indices ++ [card]
      selected_value = selected_value ++ [Enum.at(deck, card)]
    end

    paired_value = game.paired_value
    if (length(selected_indices) == 2) do
      [first | tail1] = selected_indices
      [second | tail2] = tail1
      fval = Enum.at(deck, first)
      sval = Enum.at(deck, second)
      if (!Enum.member?(paired_value, fval) and !Enum.member?(paired_value, sval)) do
        if (Enum.at(deck, first) == Enum.at(deck, second)) do
          paired_value = paired_value ++ [Enum.at(deck, first)] ++ [Enum.at(deck, second)]
          paired_indices = paired_indices ++ [first] ++ [second]
        end
      end
    end

    game
    |> Map.put(:paired_value, paired_value)
    |> Map.put(:paired_indices, paired_indices)
    |> Map.put(:selected_indices, selected_indices)
    |> Map.put(:moves, game.moves + 1)
    |> Map.put(:selected_value, selected_value)
  end

  def shuffle_deck do
    deck = ~w(
      A B C D E F G H
    )
    deck ++ deck
    Enum.shuffle(deck ++ deck)
  end
end
