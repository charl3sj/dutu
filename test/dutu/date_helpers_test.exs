defmodule Dutu.DateHelpersTest do
  use ExUnit.Case

  alias Dutu.DateHelpers

  describe "now/0" do
    test "defaults to Asia/Calcutta if :default_tz env var is unset" do
      assert Application.fetch_env!(:dutu, :default_tz) == "Asia/Calcutta"

      assert DateHelpers.now() |> DateTime.truncate(:second) ==
               Timex.now("Asia/Calcutta") |> DateTime.truncate(:second)
    end

    test "is in accordance with :default_tz" do
      Application.put_env(:dutu, :default_tz, "Africa/Cairo")

      assert DateHelpers.now() |> DateTime.truncate(:second) ==
               Timex.now("Africa/Cairo") |> DateTime.truncate(:second)

      Application.put_env(:dutu, :default_tz, "Asia/Calcutta")
    end
  end
end
