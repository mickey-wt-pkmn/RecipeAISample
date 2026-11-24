//
//  RecipeAIViewModel.swift
//  RecipeAISample
//  
//  Created by mickey-wp on 2026/11/24
//  
//

import Foundation
import Observation

@MainActor
@Observable
final class RecipeAIViewModel {
    
    enum State: Equatable {
        case idle
        case loading
        case success(RecipeSuggestion)
        case failure(String)
    }
    
    /// 選択可能な食材
    let availableIngredients = [
        "鶏むね肉",
        "玉ねぎ",
        "トマト",
        "オリーブオイル",
        "にんにく",
        "卵"
    ]
    
    /// 選択食材
    private(set) var selectedIngredients = [
        "鶏むね肉",
        "玉ねぎ",
        "オリーブオイル"
    ]
    
    /// 状態
    private(set) var state: State = .idle
    
    /// レシピを生成できるか
    var canGenerate: Bool {
        !selectedIngredients.isEmpty
    }
    
    private let service: RecipeAIServiceContract
    
    init(service: RecipeAIServiceContract? = nil) {
        self.service = service ?? RecipeAIService()
    }
    
    func toggleIngredient(_ ingredient: String) {
        if let index = selectedIngredients.firstIndex(of: ingredient) {
            selectedIngredients.remove(at: index)
        } else {
            selectedIngredients.append(ingredient)
        }
    }
    
    func generateRecipe() async {
        guard canGenerate else {
            return
        }
        
        state = .loading
        
        do {
            let suggestion = try await service.suggestRecipe(ingredients: selectedIngredients)
            state = .success(suggestion)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
