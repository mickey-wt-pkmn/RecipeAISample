//
//  ContentView.swift
//  RecipeAISample
//  
//  Created by mickey-wp on 2026/11/24
//  
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @State private var viewModel = RecipeAIViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "fork.knife")
                        .font(.title)
                        .foregroundStyle(.black)
                    Divider()
                    ingredientSelectionSection
                    Divider()
                    generateButton
                    resultSection
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .background(.white)
            .navigationTitle("AI レシピ提案")
            .toolbarBackground(.white, for: .navigationBar)
        }
    }
    
    private var ingredientSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("在庫食材")
                .foregroundStyle(.gray)
            
            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 140), spacing: 10)],
                spacing: 10) {
                    
                    ForEach(viewModel.availableIngredients, id: \.self) { ingredient in
                        let isSelected = viewModel.selectedIngredients.contains(ingredient)
                        
                        Button {
                            viewModel.toggleIngredient(ingredient)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                Text(ingredient)
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            .foregroundStyle(isSelected ? .black : .gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .background(.white)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(isSelected ? .black : .gray.opacity(0.4), lineWidth: isSelected ? 2 : 1)
                            }
                        }
                    }
                }
        }
    }
    
    private var generateButton: some View {
        HStack {
            Spacer()
            Button {
                Task {
                    await viewModel.generateRecipe()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "frying.pan")
                    Text("レシピを生成")
                }
                .font(.title3)
                .foregroundStyle(viewModel.canGenerate ? .black : .gray)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                .background(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(
                            viewModel.canGenerate ? .black : .gray,
                            lineWidth: 2
                        )
                }
            }
            .disabled(!viewModel.canGenerate)
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private var resultSection: some View {
        switch viewModel.state {
        case .idle:
            EmptyView()
        case .loading:
            HStack {
                Spacer()
                ProgressView("レシピを生成中...")
                    .tint(.black)
                    .padding(.vertical, 40)
                Spacer()
            }
        case .success(let recipe):
            Divider()
            recipeSection(recipe)
            Divider()
            nutritionChartSection(recipe)
        case .failure(let message):
            Text(message)
                .foregroundStyle(.black)
        }
    }
    
    private func recipeSection(_ recipe: RecipeSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("料理名")
                    .foregroundStyle(.gray)
                    .padding(.trailing)
                Text(recipe.title)
                    .foregroundStyle(.black)
                    .fontWeight(.bold)
            }
            HStack {
                Text("調理時間")
                    .foregroundStyle(.gray)
                    .padding(.trailing)
                Text("約\(recipe.cookingTimeMinutes)分")
                    .foregroundStyle(.black)
            }
            HStack {
                Text("推定コスト")
                    .foregroundStyle(.gray)
                    .padding(.trailing)
                Text("¥ \(recipe.estimatedCost)")
                    .foregroundStyle(.black)
            }
            Divider()
                .padding(.vertical, 4)
            Text("作り方")
                .foregroundStyle(.gray)
            
            ForEach(Array(recipe.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .foregroundStyle(.gray)
                    Text(step)
                        .foregroundStyle(.black)
                }
                .font(.subheadline)
            }
        }
    }
            
    private func nutritionChartSection(_ recipe: RecipeSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("栄養バランス")
                .foregroundStyle(.gray)
            
            Chart(recipe.nutrientItems) { item in
                BarMark(
                    x: .value("栄養素", item.name),
                    y: .value("グラム", item.grams)
                )
                .foregroundStyle(by: .value("栄養素", item.name))
                .annotation(position: .top) {
                    Text("\(item.grams)g")
                        .font(.caption)
                        .foregroundStyle(.black)
                }
            }
            .frame(height: 180)
        }
    }
}

#Preview {
    ContentView()
}
