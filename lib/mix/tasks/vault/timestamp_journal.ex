defmodule Mix.Tasks.Vault.TimestampJournal do
  @moduledoc """
  Appends a specially-formatted timestamp to each journal entry.

  Assumes journal entries are stored in a folder structure like:

  some-path/`year`/`month`/`year`-`month`-`day`.md

  where `year`, `month`, and `day` are all 0-padded number representations
  of the year, month, and day, respectively. For example, the journal entry
  on the first day of 2023 would be located at

  some-path/2023/01/2023-01-01.md

  The timestamp is a series of links to enable slicing up a journal by day/month/year,
  specifically:

  ```
  ([[journal]] entry on [[Month]] [[Day]] [[Year]])
  ```

  where `[[Month]]` is the full English name of the month,
  `[[Day]]` is the ordinal day of the month (e.g. 1st, 2nd, 3rd…),
  and `[[Year]]` is the four-digit year.

  Argument must be the path to the journal root.
  """
  @shortdoc "Appends a timestamp of links to journal files."

  use Mix.Task

  @impl Mix.Task
  def run([journal_root]) do
    if Mix.shell().yes?("Are you sure?") do
      do_traversal(journal_root)
    end
  end

  defp do_traversal(journal_root) do
    Vault.traverse_journal(journal_root, fn year, month, day, path ->
      content = File.read!(path)
      tc = timestamped_content(content, year, month, day)

      File.write!(path, tc, [:write])

      Mix.Shell.IO.info("Updated #{path}")
    end)
  end

  defp timestamped_content(c, year, month, day) do
    timestamp = "([[journal]] entry on [[#{m(month)}]] [[#{d(day)}]] [[#{year}]])"

    c
    |> String.trim_trailing()
    |> String.trim_trailing("[[journal]]")
    |> then(&(&1 <> "\n\n" <> timestamp <> "\n"))
  end

  def m("01"), do: "January"
  def m("02"), do: "February"
  def m("03"), do: "March"
  def m("04"), do: "April"
  def m("05"), do: "May"
  def m("06"), do: "June"
  def m("07"), do: "July"
  def m("08"), do: "August"
  def m("09"), do: "September"
  def m("10"), do: "October"
  def m("11"), do: "November"
  def m("12"), do: "December"

  def d("01"), do: "1st"
  def d("02"), do: "2nd"
  def d("03"), do: "3rd"
  def d("21"), do: "21st"
  def d("22"), do: "22nd"
  def d("23"), do: "23rd"
  def d("31"), do: "31st"

  def d(day) do
    day
    |> String.trim_leading("0")
    |> then(&(&1 <> "th"))
  end
end
