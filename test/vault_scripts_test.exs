defmodule VaultScriptsTest do
  use ExUnit.Case
  doctest VaultScripts

  test "greets the world" do
    assert VaultScripts.hello() == :world
  end
end
