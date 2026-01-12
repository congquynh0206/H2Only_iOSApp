//
//  ChangeHistory.swift
//  H2Only
//
//  Created by Trangptt on 12/1/26.
//
import SwiftUI

struct ChangeHistory : View {
    @Binding var isPresented : Bool
    var log : WaterLog
    
    // Biến lưu lượng nước đang chọn, trước khi đồng ý
    @State private var tempAmount: Int = 0
    @State private var animationLevel: CGFloat = 0.0
    
    
    var body: some View {
        VStack(spacing: 30){
            HStack (spacing: 10){
                Text("Uống nước lúc ")
                    .font(.headline)
                
                Text(DateFormat.formatTime(log.date))
                    .font(.headline)
                    .foregroundStyle(.blue)
                Spacer()
            }
            if log.iconName.contains("500") || log.iconName.contains("1000"){
                Image(log.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }else{
                LottieView(
                    filename: getJsonName(log.iconName),
                    loopMode: .playOnce,
                    toProgress: animationLevel //mức nước
                )
                .frame(width: 60, height: 60)
                .id(log.iconName)
            }
            
            let baseAmount = Double(log.cupSize)
            
            HStack(spacing: 20){
                // Khi bấm nút, cập nhật tempAmount
                PercentButton(percent: "1/4", amount: Int(round(baseAmount * 0.25)), isSelected: tempAmount == Int(round(baseAmount * 0.25))) {
                    tempAmount = Int(round(baseAmount * 0.25))
                    animationLevel = 0.25
                }
                
                PercentButton(percent: "2/4", amount: Int(round(baseAmount * 0.5)), isSelected: tempAmount == Int(round(baseAmount * 0.5))) {
                    tempAmount = Int(round(baseAmount * 0.5))
                    animationLevel = 0.5
                }
                
                PercentButton(percent: "3/4", amount: Int(round(baseAmount * 0.75)), isSelected: tempAmount == Int(round(baseAmount * 0.75))) {
                    tempAmount = Int(round(baseAmount * 0.75))
                    animationLevel = 0.75
                }
                
                PercentButton(percent: "4/4", amount: Int(baseAmount), isSelected: tempAmount == Int(baseAmount)) {
                    tempAmount = Int(baseAmount)
                    animationLevel = 1.0
                }
            }
            
            HStack(spacing: 90) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Huỷ bỏ")
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    // Lưu vào db
                    updateLog()
                    isPresented = false
                }) {
                    Text("Đồng ý")
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal, 30)
        .onAppear {
            tempAmount = log.amount
            if log.cupSize > 0 {
                animationLevel = CGFloat(log.amount) / CGFloat(log.cupSize)
            } else {
                animationLevel = 1.0
            }
        }
    }
    
    // Update
    func updateLog() {
        guard let realm = RealmManager.shared.realm else { return }
        do {
            try realm.write {
                log.amount = tempAmount
            }
            RealmManager.shared.objectWillChange.send()
        } catch {
            print("Lỗi update log: \(error)")
        }
    }
    
    private func getJsonName (_ name : String) -> String{
        if name.contains("100"){
            return "100"
        }else if name.contains("125"){
            return "125"
        }else if name.contains("150"){
            return "150"
        }else if name.contains("175"){
            return "175"
        }else if name.contains("200"){
            return "200"
        }else if name.contains("300"){
            return "300"
        }else if name.contains("400"){
            return "400"
        }
        return "customize"
    }
}

// Button con
struct PercentButton : View {
    let percent : String
    let amount : Int
    let isSelected: Bool
    var action: () -> Void
    
    var body : some View{
        Button(action: action) {
            VStack (spacing: 10){
                ZStack{
                    Circle()
                        .fill(Color.white) // Highlight khi chọn
                        .overlay(
                            Circle()
                                .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                        )
                        .frame(width: 40, height: 40)
                    Text(percent)
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.blue : Color.gray)
                }
                Text("\(amount) ml")
                    .font(.caption)
                    .foregroundStyle(isSelected ? Color.blue : Color.gray)
            }
        }
    }
}
