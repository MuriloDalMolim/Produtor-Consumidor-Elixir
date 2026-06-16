defmodule Buffer do
  def iniciar(capacidade) do
    IO.puts("[Buffer] Iniciado com capacidade: #{capacidade}")
    loop(:queue.new(), capacidade, [])
  end

  defp loop(fila, capacidade, aguardando) do
    receive do

      {:produzir, item, produtor_pid} ->
        if :queue.len(fila) >= capacidade do
          send(produtor_pid, {:recusado, :buffer_cheio})
          loop(fila, capacidade, aguardando)
        else
          case aguardando do
            [consumidor | restante] ->
              send(consumidor, {:item, item})
              send(produtor_pid, :aceito)
              loop(fila, capacidade, restante)
            [] ->
              send(produtor_pid, :aceito)
              loop(:queue.in(item, fila), capacidade, [])
          end
        end

      {:consumir, consumidor_pid} ->
        case :queue.out(fila) do
          {{:value, item}, nova_fila} ->
            send(consumidor_pid, {:item, item})
            loop(nova_fila, capacidade, aguardando)
          {:empty, _} ->
            loop(fila, capacidade, aguardando ++ [consumidor_pid])
        end

      :encerrar ->
        IO.puts("[Buffer] Encerrado. Itens restantes: #{:queue.len(fila)}")
    end
  end
end

defmodule Produtor do
  def iniciar(nome, buffer_pid, itens, intervalo_ms) do
    IO.puts("[#{nome}] Iniciado.")
    produzir(nome, buffer_pid, itens, intervalo_ms)
    IO.puts("[#{nome}] Producao encerrada.")
  end

  defp produzir(_, _, [], _), do: :ok
  defp produzir(nome, buffer_pid, [item | restante], intervalo) do
    :timer.sleep(intervalo)
    send(buffer_pid, {:produzir, item, self()})
    receive do
      :aceito ->
        IO.puts("[#{nome}]Produziu: '#{item}'")
        produzir(nome, buffer_pid, restante, intervalo)
      {:recusado, :buffer_cheio} ->
        IO.puts("[#{nome}]Buffer cheio!Recuando e tentando novamente o item '#{item}")
        :timer.sleep(500)
        produzir(nome, buffer_pid, [item | restante], intervalo)
    end
  end
end

defmodule Consumidor do
  def iniciar(nome, buffer_pid, quantidade, intervalo_ms) do
    IO.puts("[#{nome}] Iniciado.")
    consumir(nome, buffer_pid, quantidade, intervalo_ms)
    IO.puts("[#{nome}] Consumo encerrado.")
  end

  defp consumir(_, _, 0, _), do: :ok
  defp consumir(nome, buffer_pid, n, intervalo) do
    send(buffer_pid, {:consumir, self()})
    receive do
      {:item, dado} ->
        IO.puts("[#{nome}] Processando: '#{dado}'")
        :timer.sleep(intervalo)
    end
    consumir(nome, buffer_pid, n - 1, intervalo)
  end
end


buffer = spawn(fn -> Buffer.iniciar(3) end)
:timer.sleep(50)

spawn(fn -> Produtor.iniciar("Produtor-A", buffer, ["A1","A2","A3","A4","A5"], 500) end)
spawn(fn -> Produtor.iniciar("Produtor-B", buffer, ["B1","B2","B3","B4"], 700) end)
spawn(fn -> Consumidor.iniciar("Consumidor", buffer, 9, 1100) end)

:timer.sleep(10000)
send(buffer, :encerrar)
:timer.sleep(100)

IO.puts("Sistema encerrado.")
