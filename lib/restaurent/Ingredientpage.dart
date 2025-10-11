import 'package:flutter/material.dart';

class Recipe {
  String name;
  List<Ingredient> ingredients;
  String instructions;

  Recipe({this.name = '', this.ingredients = const [], this.instructions = ''});
}

class Ingredient {
  String name;
  String quantity;
  String unit;
  String group;

  Ingredient({
    this.name = '',
    this.quantity = '',
    this.unit = 'g',
    this.group = '',
  });
}

class Ingredientpage extends StatefulWidget {
  const Ingredientpage({super.key});

  @override
  State<Ingredientpage> createState() => _IngredientpageState();
}

class _IngredientpageState extends State<Ingredientpage> {
  final Recipe recipe = Recipe(ingredients: [Ingredient()]);
  final _formKey = GlobalKey<FormState>();

  static const List<String> _ingredientNames = <String>[
    'all-purpose flour',
    'baking powder',
    'baking soda',
    'butter',
    'egg',
    'granulated sugar',
    'milk',
    'salt',
    'vanilla extract',
  ];

  static const List<String> _units = <String>[
    'g',
    'kg',
    'ml',
    'l',
    'tsp',
    'tbsp',
    'cup',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Recipe')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    initialValue: recipe.name,
                    onChanged: (value) {
                      recipe.name = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Recipe Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recipe.ingredients.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Autocomplete<String>(
                                      optionsBuilder:
                                          (TextEditingValue textEditingValue) {
                                            if (textEditingValue.text == '') {
                                              return const Iterable<
                                                String
                                              >.empty();
                                            }
                                            return _ingredientNames.where((
                                              String option,
                                            ) {
                                              return option.contains(
                                                textEditingValue.text
                                                    .toLowerCase(),
                                              );
                                            });
                                          },
                                      onSelected: (String selection) {
                                        recipe.ingredients[index].name =
                                            selection;
                                      },
                                      fieldViewBuilder:
                                          (
                                            BuildContext context,
                                            TextEditingController
                                            textEditingController,
                                            FocusNode focusNode,
                                            VoidCallback onFieldSubmitted,
                                          ) {
                                            return TextFormField(
                                              controller: textEditingController,
                                              focusNode: focusNode,
                                              onChanged: (value) {
                                                recipe.ingredients[index].name =
                                                    value;
                                              },
                                              decoration: const InputDecoration(
                                                labelText: 'Ingredient Name',
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        recipe.ingredients.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue:
                                          recipe.ingredients[index].quantity,
                                      onChanged: (value) {
                                        recipe.ingredients[index].quantity =
                                            value;
                                      },
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  DropdownButton<String>(
                                    value: recipe.ingredients[index].unit,
                                    items: _units.map<DropdownMenuItem<String>>(
                                      (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      },
                                    ).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        recipe.ingredients[index].unit =
                                            newValue!;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                initialValue: recipe.ingredients[index].group,
                                onChanged: (value) {
                                  recipe.ingredients[index].group = value;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Group (e.g., For the dough)',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: recipe.instructions,
                    onChanged: (value) {
                      recipe.instructions = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Instructions',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16.0),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Save recipe logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Recipe saved!')),
                          );
                        }
                      },
                      child: const Text('Save Recipe'),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            recipe.ingredients.add(Ingredient());
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
