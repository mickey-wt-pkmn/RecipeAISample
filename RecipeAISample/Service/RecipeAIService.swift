//
//  RecipeAIService.swift
//  RecipeAISample
//  
//  Created by mickey-wp on 2026/11/24
//  
//

import Foundation
import FoundationModels

protocol RecipeAIServiceContract {
    /// レシピ提案
    func suggestRecipe(ingredients: [String]) async throws -> RecipeSuggestion
}

final class RecipeAIService: RecipeAIServiceContract {
    
    func suggestRecipe(ingredients: [String]) async throws -> RecipeSuggestion {
        let joined = ingredients.joined(separator: ", ")
        
        // Apple Intelligence が利用可能か確認
        if SystemLanguageModel.default.isAvailable {
            let session = LanguageModelSession()
            let prompt = "次の食材を使った簡単なレシピを1つ日本語で提案してください: \(joined)"
            let response = try await session.respond(
                to: prompt,
                generating: RecipeSuggestion.self
            )
            return response.content
        } else {
            // 利用できない場合、サンプル生成
            return makeSampleRecipe(ingredients: ingredients)
        }
    }
    
    private func makeSampleRecipe(ingredients: [String]) -> RecipeSuggestion {
        let main = ingredients.first ?? "鶏むね肉"
        
        return RecipeSuggestion(
            title: "\(main)のガーリックソテー",
            cookingTimeMinutes: 20,
            estimatedCost: 380,
            proteinGrams: 34,
            fatGrams: 14,
            carbsGrams: 18,
            steps: [
                "\(ingredients.joined(separator: "、")) を一口大にカットして下準備する",
                "フライパンにオリーブオイルを熱し、食材を中火で火が通るまで炒める",
                "塩・胡椒で味を整え、器に盛り付けて完成"
            ]
        )
    }
}
