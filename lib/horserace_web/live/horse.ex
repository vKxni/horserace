defmodule HorseraceWeb.HorseController do
  use HorseraceWeb, :live_view

  defstruct selected_horse_id: 0,
            bet_amount: 0,
            coins: 100,
            horses: [
              %{id: 1, name: "Thunderbolt", emoji: "🐎", odds: 2, position: 0},
              %{id: 2, name: "Lightning", emoji: "🐴", odds: 3, position: 0},
              %{id: 3, name: "Flash", emoji: "🦌", odds: 4, position: 0},
              %{id: 4, name: "Bolt", emoji: "🐉", odds: 5, position: 0},
              %{id: 5, name: "Speedy", emoji: "🦄", odds: 6, position: 0}
            ],
            race_in_progress: false,
            race_ended: false,
            winner_id: 0

  def mount(_params, _session, socket) do
    {:ok, assign(socket, %__MODULE__{} = %HorseraceWeb.HorseController{})}
  end

  def handle_event("select_horse", %{"horse_id" => horse_id}, socket) do
    {:noreply, assign(socket, selected_horse_id: String.to_integer(horse_id))}
  end

  def handle_event("change_bet_amount", %{"bet_amount" => bet_amount}, socket) do
    {:noreply, assign(socket, bet_amount: String.to_integer(bet_amount))}
  end

  def handle_event("start_race", _, socket) do
    if can_start_race?(socket) do
      new_coins = socket.assigns.coins - socket.assigns.bet_amount

      new_socket =
        socket
        |> assign(coins: new_coins, race_in_progress: true, winner_id: 0)
        |> update_horse_positions()

      {:noreply, new_socket}
    else
      {:noreply, socket}
    end
  end

  def handle_event("reset", _, socket) do
    {:noreply, assign(socket, %__MODULE__{} = %HorseraceWeb.HorseController{})}
  end

  defp can_start_race?(assigns) do
    not assigns.race_ended and not assigns.race_in_progress and
      assigns.bet_amount > 0 and assigns.bet_amount <= assigns.coins and
      assigns.selected_horse_id != 0
  end

  defp update_horse_positions(socket) do
    new_horses =
      socket.assigns.horses
      |> Enum.map(fn horse ->
        new_position = horse.position + :rand.uniform(5) + 1
        %{horse | position: min(new_position, 100)}
      end)

    finished_horses = get_finished_horses(new_horses)

    case length(finished_horses) do
      0 ->
        assign(socket, horses: new_horses)

      _ ->
        winning_horse = get_winning_horse(finished_horses)
        add_win = socket.assigns.bet_amount * 2

        new_coins =
          if winning_horse.id == socket.assigns.selected_horse_id do
            socket.assigns.coins + add_win
          else
            socket.assigns.coins
          end

        assign(socket,
          horses: new_horses,
          winner_id: winning_horse.id,
          coins: new_coins,
          race_in_progress: false,
          race_ended: true
        )
    end
  end

  def render(assigns) do
    ~H"""
    <h1>Implement horses</h1>
    """
  end

  defp get_finished_horses(horses) do
    Enum.filter(horses, fn horse -> horse.position == 100 end)
  end

  defp get_winning_horse(horses) do
    Enum.max_by(horses, fn horse -> horse.position end)
  end
end
