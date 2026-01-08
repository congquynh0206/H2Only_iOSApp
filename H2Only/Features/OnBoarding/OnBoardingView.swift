//
//  OnboardingView.swift
//  H2Only
//
//  Created by Trangptt on 8/1/26.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentStep = 0
    
    // Dữ liệu người dùng chọn
    @State private var gender: Gender = .male
    @State private var weight: Double = 60.0
    @State private var wakeTime: Date = Calendar.current.date(from: DateComponents(hour: 6, minute: 0)) ?? Date()
    @State private var bedTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date()
    @State private var isNext = true
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack {
                // Thanh tiến trình
                OnboardingTopBar(
                    currentStep: currentStep,
                    gender: gender,
                    weight: weight,
                    wakeTime: wakeTime,
                    bedTime: bedTime
                )
                .padding(.top, 10)
                
                Spacer()
                
                // Nội dung chính
                ZStack {
                    if currentStep == 0 {
                        GenderView(gender: $gender)
                            .transition(transitionFor(step: 0))
                    } else if currentStep == 1 {
                        WeightView(weight: $weight, gender: gender)
                            .transition(transitionFor(step: 1))
                    } else if currentStep == 2 {
                        WakeUpTimeView(wakeTime: $wakeTime, gender: gender)
                            .transition(transitionFor(step: 2))
                    } else if currentStep == 3 {
                        BedTimeView(bedTime: $bedTime, gender: gender)
                            .transition(transitionFor(step: 3))
                    }
                }
                .animation(.easeInOut(duration: 0.4), value: currentStep)
                
                Spacer()
                
                // Nút Back / Next
                HStack {
                    // Nút back
                    if currentStep > 0 {
                        Button(action: {
                            isNext = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                withAnimation { currentStep -= 1 }
                            }
                        }) {
                            Image("arrow_back")
                                .foregroundColor(.white)
                                .frame(width: 50, height: 50)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }
                    } else {
                        Spacer().frame(width: 50)
                    }
                    
                    Spacer()
                    
                    // Nút Next
                    Button(action: {
                        isNext = true
                        if currentStep < 3 {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                withAnimation { currentStep += 1 }
                            }
                        } else {
                            finishOnboarding()
                        }
                    }) {
                        Text(currentStep == 3 ? "Finish" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(Color.blue)
                            .cornerRadius(30)
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .preferredColorScheme(.light)
    }
    
    // Hàm lưu dữ liệu và vào app chính
    func finishOnboarding() {
        RealmManager.shared.updateProfile { user in
            user.gender = gender
            user.weight = weight
            user.wakeUpTime = wakeTime
            user.bedTime = bedTime
            user.dailyGoal = WaterCalculator.calculateDailyGoal(weightKg: weight, gender: gender)
            user.isOnboardingCompleted = true
        }
    }
    
    // Hàm animation chuyển trang
    func transitionFor(step: Int) -> AnyTransition {
        if isNext {
            // Bấm Next: Vào từ Phải -> Ra bên Trái
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            ).combined(with: .opacity)
        } else {
            // Bấm Back: Vào từ Trái -> Ra bên Phải
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            ).combined(with: .opacity)
        }
    }
}

// COMPONENTS: TOP BAR
struct OnboardingTopBar: View {
    var currentStep: Int
    var gender: Gender
    var weight: Double
    var wakeTime: Date
    var bedTime: Date
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Step 0: Gender
            TopBarItem(
                stepIndex: 0, currentStep: currentStep,
                title: gender == .male ? "Male" : "Female",
                iconPrefix: "ic_gender"
            )
            
            ConnectorLine(isActive: currentStep > 0)
            
            // Step 1: Weight
            TopBarItem(
                stepIndex: 1, currentStep: currentStep,
                title: "\(Int(weight)) kg",
                iconPrefix: "ic_weight"
            )
            
            ConnectorLine(isActive: currentStep > 1)
            
            // Step 2: Wake up
            TopBarItem(
                stepIndex: 2, currentStep: currentStep,
                title: formatTime(wakeTime),
                iconPrefix: "ic_wakeup"
            )
            
            ConnectorLine(isActive: currentStep > 2)
            
            // Step 3: Bed time
            TopBarItem(
                stepIndex: 3, currentStep: currentStep,
                title: formatTime(bedTime),
                iconPrefix: "ic_bedtime"
            )
        }
        .padding(.horizontal, 20)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct TopBarItem: View {
    let stepIndex: Int
    let currentStep: Int
    let title: String
    let iconPrefix: String
    
    var state: String {
        if currentStep == stepIndex { return "_selected" }
        if currentStep > stepIndex { return "_done" }
        return "_normal"
    }
    
    var body: some View {
        VStack(spacing: 5) {
            // Icon
            Image("\(iconPrefix)\(state)")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            // Text Value - Chỉ hiện khi đã chọn hoặc đang chọn
            Text(currentStep >= stepIndex ? title : "--")
                .font(.caption)
                .fontWeight(.medium)
                .font(.system(size: 24))
                .foregroundColor(currentStep >= stepIndex ? Color(.blue) : .gray)
                .fixedSize() // Giữ text không bị xuống dòng
        }
        .frame(width: 60)
    }
}

struct ConnectorLine: View {
    var isActive: Bool
    var body: some View {
        Image("line")
            .resizable()
            .foregroundStyle(isActive ? .blue : .gray)
            .frame(width: 20,height: 2)
            .padding(.top, 30)
    }
}


// Components

// Gender
struct GenderView: View {
    @Binding var gender: Gender
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Your Gender")
                .font(.title)
                .padding(.top,20)
            Spacer()
            HStack(spacing: 40) {
                // Nút chọn Male
                Button(action: { gender = .male }) {
                    VStack {
                        Image(gender == .male ? "ic_male_selected" : "ic_male_normal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text("Male")
                            .foregroundColor(gender == .male ? Color(.blue) : .gray)
                            .font(.headline)
                    }
                }
                
                // Nút chọn Female
                Button(action: { gender = .female }) {
                    VStack {
                        Image(gender == .female ? "ic_female_selected" : "ic_female_normal")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                        Text("Female")
                            .foregroundColor(gender == .female ? Color(.blue) : .gray)
                            .font(.headline)
                    }
                }
            }
            Spacer()
        }
    }
}

// Weight
struct WeightView: View {
    @Binding var weight: Double
    var gender: Gender
    
    // Biến trung gian Int để dùng cho Picker mượt hơn
    var weightInt: Binding<Int> {
        Binding<Int>(
            get: { Int(self.weight) },
            set: { self.weight = Double($0) }
        )
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Your Weight")
                .font(.title)
                .padding(.top, 20)
            Spacer()
            HStack (spacing: 20) {
                Image(gender == .female ? "ic_weight_female" : "ic_weight_male")
                    .resizable().scaledToFit().frame(height: 350)
                
                
                Picker("Weight", selection: weightInt) {
                    ForEach(30...150, id: \.self) { i in
                        Text("\(i)").tag(i)
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 100, height: 150)
                .clipped()
                
                Text("kg")
                    .font(.title3)
                    .foregroundColor(.gray)
                    .padding(.bottom, 10)
            }
            Spacer()
        }
    }
}

// Wake Up Time
struct WakeUpTimeView: View {
    @Binding var wakeTime: Date
    var gender : Gender
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Wake-up time")
                .font(.title)
                .padding(.top, 20)
            Spacer()
            HStack (spacing: 20){
                Image(gender == .female ? "ic_wake_up_time_female" : "ic_wake_up_time_male")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                DatePicker("", selection: $wakeTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 150)
                    .colorScheme(.light)
                    .clipped()
            }
            Spacer()
        }
    }
}

// Bed Time
struct BedTimeView: View {
    @Binding var bedTime: Date
    var gender : Gender
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Bedtime")
                .font(.title)
                .padding(.top, 20)
            Spacer()
            HStack( spacing: 20){
                Image(gender == .female ? "ic_sleeping_time_female" : "ic_sleeping_time_male")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 350)
                
                DatePicker("", selection: $bedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(width: 150)
                    .colorScheme(.light)
                    .clipped()
            }
            Spacer()
        }
    }
}
