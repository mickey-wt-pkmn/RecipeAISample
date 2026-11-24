//
//  RecipeAISampleTests.swift
//  RecipeAISampleTests
//  
//  Created by mickey-wp on 2026/11/24
//  
//

import Testing
@testable import RecipeAISample

@MainActor
struct RecipeAISampleTests {
    
    @Test("食材をすべて外すと生成ボタンが無効になり、選ぶと有効になる")
    func toggleIngredientsUpdatesCanGenerate() {
        let viewModel = RecipeAIViewModel(service: StubRecipeAIService())
        
        // 初期選択の3つを外す
        for item in viewModel.selectedIngredients {
            viewModel.toggleIngredient(item)
        }
        #expect(!viewModel.canGenerate)
        
        // 1つ選択する
        viewModel.toggleIngredient("トマト")
        #expect(viewModel.canGenerate)
        #expect(viewModel.selectedIngredients == ["トマト"])
    }
    
    @Test("レシピ生成成功時に Swift Charts 用の 栄養素データが3件作られる")
    func generateRecipeUpdatesStateAndChartItems() async {
        let viewModel = RecipeAIViewModel(service: StubRecipeAIService())
        
        await viewModel.generateRecipe()
        
        guard case .success(let recipe) = viewModel.state else {
            Issue.record("期待と違う結果")
            return
        }
        #expect(recipe.title == "トマトパスタ")
        #expect(recipe.nutrientItems == [
            RecipeSuggestion.NutrientChartItem(name: "タンパク質", grams: 25),
            RecipeSuggestion.NutrientChartItem(name: "脂質", grams: 10),
            RecipeSuggestion.NutrientChartItem(name: "炭水化物", grams: 45)
        ])
    }
}

// MARK: - Stub

private final class StubRecipeAIService: RecipeAIServiceContract {
    
    func suggestRecipe(ingredients: [String]) async throws -> RecipeSuggestion {
        RecipeSuggestion(
            title: "トマトパスタ",
            cookingTimeMinutes: 15,
            estimatedCost: 300,
            proteinGrams: 25,
            fatGrams: 10,
            carbsGrams: 45,
            steps: ["茹でる", "和える"]
        )
    }
}
