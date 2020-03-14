import 'package:projectquiche/model/models.dart';

// "Database" but really just hardcoded variables for now

var cremeVichyssoise = Recipe(
  name: 'Crème Vichyssoise',
  ingredients: {
    Ingredient('Butter', 4, QuantityUnit.tbsp),
    Ingredient('Leeks', 8, QuantityUnit.item),
    Ingredient('Potatoes', 2, QuantityUnit.item, qualifier: 'medium'),
    Ingredient('Chicken stock', 2, QuantityUnit.cup),
    Ingredient('Heavy cream', 2, QuantityUnit.cup),
    Ingredient('Chives', 4, QuantityUnit.item, qualifier: 'fresh'),
    Ingredient('Nutmeg', 1, QuantityUnit.pinch),
    Ingredient('Salt', 1, QuantityUnit.item),
    Ingredient('Pepper', 1, QuantityUnit.item, qualifier: 'fresh'),
  },
  steps: [
    PreparationStep(
      title: 'Prepare produce',
      instructions:
          'Clean the leeks, keeping only the white part. Thinly slice. Cut potatoes into small cubes. Finely chop chives.',
    ),
    PreparationStep(
      instructions:
          'In a large, heavy bottom pot, melt butter over medium-low heat. Once butter is melted, add the leeks and sweat for 5 minutes, making sure they do not take on any color.',
    ),
    PreparationStep(
      instructions:
          'Add potatoes and cook for a minute or two, stirring a few times.',
    ),
    PreparationStep(
      instructions: 'Stir in the chicken broth and bring to a boil.',
    ),
    PreparationStep(
      instructions:
          'Reduce heat to a simmer. Cook on low heat, gently simmering for 35 minutes, or until the leeks and potatoes are very soft. Allow to cool for a few minutes.',
    ),
    PreparationStep(
      instructions:
          'Slowly, and in SMALL batches, puree the soup at a high speed in the blender. Do this bit by bit, never filling the blender too high. Make sure the benders lid is on, and lean on the top when you turn on. If not the burn you will get is awful, and a most frequent accident in even professional kitchens.',
    ),
    PreparationStep(
      instructions:
          'Return soup to the cooking pot and whisk in cream and nutmeg. Season with salt and pepper. Return to a boil, reduce to simmer and cook 5 minutes. If you want to thin soup out, add more broth, if needed.',
    ),
    PreparationStep(
      instructions:
          'If desired warm, then just serve sprinkling some chives on top.',
    ),
    PreparationStep(
      instructions:
          'If to be served chilled transfer soup to the mixing bowl an chill over the ice bath, stirring occasionally. When soup is at Room temperature, and only at room temperature, cover in plastic wrap and put into the refrigerator to cool. Check seasoning, sprinkle with chives and serve in chilled bowls.',
    ),
  ],
);
