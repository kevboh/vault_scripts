defmodule Vault do
  def traverse_journal(journal_root, f) do
    {:ok, years} = File.ls(journal_root)

    for year <- years do
      year_path = Path.join(journal_root, year)
      {:ok, months} = File.ls(year_path)

      for month <- months do
        month_path = Path.join(year_path, month)
        {:ok, days} = File.ls(month_path)

        for day_file <- days do
          day =
            String.split(day_file, "-")
            |> List.last()
            |> String.trim_trailing(".md")

          p = Path.join(month_path, day_file)

          f.(year, month, day, p)
        end
      end
    end
  end
end
