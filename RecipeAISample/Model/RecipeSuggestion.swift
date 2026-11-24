//
//  RecipeSuggestion.swift
//  RecipeAISample
//  
//  Created by mickey-wp on 2026/11/24
//  
//

import Foundation
import FoundationModels

/// FoundationModels の @Generable による構造化出力モデル
@Generable
struct RecipeSuggestion: Equatable {
    
    @Guide(description: "料理名")
    let title: String
    
    @Guide(description: "調理時間の目安(分)")
    let cookingTimeMinutes: Int
    
    @Guide(description: "1人あたりの推定コスト(円)")
    let estimatedCost: Int
    
    @Guide(description: "タンパク質(g)")
    let proteinGrams: Int
    
    @Guide(description: "脂質(g)")
    let fatGrams: Int
    
    @Guide(description: "炭水化物(g)")
    let carbsGrams: Int
    
    @Guide(description: "調理手順のリスト")
    let steps: [String]
}

extension RecipeSuggestion {
    
    /// Swift Charts 表示用の栄養素データ
    struct NutrientChartItem: Identifiable, Equatable {
        var id: String { name }
        let name: String
        let grams: Int
    }
    
    var nutrientItems: [NutrientChartItem] {
        [
            NutrientChartItem(name: "タンパク質", grams: proteinGrams),
            NutrientChartItem(name: "脂質", grams: fatGrams),
            NutrientChartItem(name: "炭水化物", grams: carbsGrams)
        ]
    }
}
