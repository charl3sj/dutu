# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Dutu.Repo.insert!(%Dutu.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Dutu.Repo
alias Dutu.DietTracker.{Category, Food}

categorized_foods = %{
  "Grain" => [
    "Boiled Rice",
    "Rice",
    "Whole Wheat",
    "Barley",
    "Quinoa",
    "Oats",
    "Semolina",
    "Millet"
  ],
  "Veggies" => [
    "Spinach",
    "Broccoli",
    "Cauliflower",
    "Tomato",
    "Beans",
    "Carrot",
    "Cabbage",
    "Green Peas",
    "Red/Green/Yellow Peppers",
    "Potatoes",
    "Radish",
    "Yam",
    "Tapioca",
    "Sweet Potato",
    "[Other]"
  ],
  "Fruit/Nut" => [
    "Avocado",
    "Apple",
    "Banana/Plantain",
    "Orange",
    "[Seasonal]",
    "Pomegranate",
    "Walnut",
    "Cashew",
    "Pistachio",
    "Fig"
  ],
  "Veg. Protein" => [
    "Lentils",
    "Chickpeas",
    "Green moong",
    "Red moong",
    "Lobia",
    "Peanuts",
    "Urad dal"
  ],
  "Animal Protein" => ["Fish", "Chicken", "Egg", "Beef", "Mutton", "[Seafood]"],
  "Limit/Avoid" => []
}

# Insert categories
{_, categories} =
  Repo.insert_all(
    Category,
    Enum.map(Map.keys(categorized_foods), &%{name: &1}),
    returning: [:id, :name]
  )

# Insert foods
foods =
  Enum.reduce(categories, [], fn category, acc ->
    acc ++
      Enum.map(Map.get(categorized_foods, category.name), fn food ->
        %{name: food, category_id: category.id}
      end)
  end)

Repo.insert_all(Food, foods)
