//
//  DashboardView.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift

struct DashboardView: View {
    @ObservedResults(WaterLog.self) var logs
    
    @StateObject var viewModel = DashboardViewModel()
    @State private var showChangeCupSheet = false
    @State private var showChangeHistory = false
    
    @State private var selectedLog: WaterLog?
    
    @State var currentAdvice: String = "Không uống nước ngay sau khi ăn"
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    HeaderView()
                    // Header
                    AdviceView(content: currentAdvice)
                    
                    Spacer()
                    VStack() {
                        
                        // Cụm vòng tròn + Nút đổi cốc
                        ZStack {
                            
                            HalfCircleProgressView(
                                progress: Double(viewModel.currentIntake) / Double(viewModel.dailyGoal)
                            )
                            .frame(width: 320, height: 320)
                            .offset(y: -80)
                            
                            WaterCircle(viewModel: viewModel, currentAdvice: $currentAdvice, currentIntake: viewModel.currentIntake)
                            
                            // Nút đổi dung tích
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showChangeCupSheet = true
                                    }) {
                                        ZStack (){
                                            Image("ic_change")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 60, height: 60)
                                                .shadow(radius: 12)
                                            Image(viewModel.getCurrentIconName(postFix: "selected"))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 20, height: 20)
                                                .offset(x: -3)
                                            
                                        }
                                    }
                                    .offset(x: 10, y: -30) // Chỉnh vị trí
                                }
                            }
                            .frame(width: 320, height: 320)
                            
                        }
                    }
                    
                    Spacer()
                    // Lịch sử
                    HistoryList(viewModel: viewModel, onEdit: { selectedLog in
                        self.selectedLog = selectedLog
                        self.showChangeHistory = true
                    })
                }
            }
            .fullScreenCover(isPresented: $showChangeCupSheet) {
                ZStack {
                    // Lớp nền mờ tối
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showChangeCupSheet = false
                        }
                    
                    // Popup nội dung
                    ChangeCupPopup(viewModel: viewModel, isPresented: $showChangeCupSheet)
                }
                .presentationBackground(.clear)
            }
            .fullScreenCover(item: $selectedLog) { logItem in
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            selectedLog = nil
                        }
                    ChangeHistory(
                        isPresented: Binding(
                            get: { selectedLog != nil },
                            set: { if !$0 { selectedLog = nil } }
                        ),
                        log: logItem 
                    )
                }
                .presentationBackground(.clear)
            }
        }
    }
}



// Hình tròn uống nước
struct WaterCircle : View {
    @ObservedObject var viewModel : DashboardViewModel
    @State private var floatingTexts: [FloatingTextData] = []
    @Binding var currentAdvice: String
    var currentIntake: Int
    
    var selectedCup: Int {
        return viewModel.userProfile?.selectedCupSize ?? 0
    }
    
    
    var body: some View {
        ZStack {
            Image("bg_circle")
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
                .shadow(radius: 12)
            
            // Thông tin Text + Nút uống
            VStack (){
                VStack(spacing: 5) {
                    // Số ml uống / Mục tiêu
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        
                        CountingText(value: Double(currentIntake), color: .blue, size: 20, weight: .medium)
                            .animation(.linear(duration: 0.5), value: viewModel.currentIntake)
                        
                        Text("/\(viewModel.dailyGoal) ml")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    
                    Text("Mục tiêu uống hàng ngày")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 160)
                .padding(.bottom,50)
                // Nút cộng nước
                Button(action: {
                    addWaterWithAnimation()
                }) {
                    VStack(spacing: 5) {
                        Text("\(viewModel.userProfile?.selectedCupSize ?? 100) ml")
                        
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                        
                        Image(viewModel.getCurrentIconName(postFix: "add"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.bottom, 20)
                // Xác nhận vừa uống nc
                VStack(spacing: 5) {
                    Image("ic_arrow")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 20)
                    
                    Text("Xác nhận rằng bạn vừa uống nước")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 280, height: 280)
        }
        .overlay(
            ZStack {
                ForEach(floatingTexts) { data in
                    Text(data.message)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(data.message.contains("ml") ? .blue : .orange)
                        .position(x: data.position.x, y: data.position.y)
                        .opacity(data.opacity)
                }
            }
        )
    }
    // Logic thêm nước + Hiệu ứng
    func addWaterWithAnimation() {
        viewModel.addWater()
        let newAmount = viewModel.userProfile?.selectedCupSize ?? 100
        let subMess = Constants.compliments.randomElement() ?? "Tốt lắm"
        var message = "+ \(newAmount) ml! \(subMess)"
        
        // 15p
        let time : TimeInterval = 15 * 60
        //Ngưỡng cảnh báo
        let warningThresold = 600
        
        // Thời gian bắt đầu
        
        let windowStartTime = Date().addingTimeInterval(-time)
        
        // Lọc log từ 15p trước
        let recentLogTotal = viewModel.todayLogs
            .filter { log in
                return log.date >= windowStartTime
            }
            .reduce(0){sum,log in
                return sum + log.amount
            }
        // tổng cả trước với hiện tại
        let totalIntakeInWindow = recentLogTotal + newAmount
        
        if viewModel.currentIntake >= viewModel.dailyGoal {
            message =  Constants.finish.randomElement() ?? "Hôm nay đã uống đủ nước, dừng lại thôi!"
            
        }else if totalIntakeInWindow > warningThresold {
            // Random câu cảnh báo cho đỡ nhàm chán
            message = Constants.warnings.randomElement() ?? "Chậm lại nào!"
        }
        
        
        // Tạo hiệu ứng chữ bay
        let amount = viewModel.userProfile?.selectedCupSize ?? 125
        let newFloatingText = FloatingTextData(amount: amount, position: CGPoint(x: 150, y: 150),message:  message) // Vị trí xuất phát
        
        floatingTexts.append(newFloatingText)
        
        withAnimation{
            currentAdvice = Constants.adviceList.randomElement() ?? Constants.adviceList[0]
        }
        
        // Animation bay lên
        if let index = floatingTexts.firstIndex(where: { $0.id == newFloatingText.id }) {
            withAnimation(.easeOut(duration: 2.0)) {
                floatingTexts[index].position.y -= 100 // Bay lên 100pt
                floatingTexts[index].opacity = 0 // Mờ dần
            }
            
            // Dọn dẹp mảng sau khi animation xong
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                floatingTexts.removeAll { $0.id == newFloatingText.id }
            }
        }
    }
}


// Lịch sử uống nc
struct HistoryList : View {
    @ObservedObject var viewModel : DashboardViewModel
    var onEdit: (WaterLog) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Hồ sơ hôm nay")
                .font(.headline)
                .padding(.horizontal)
                .foregroundStyle(.black)
            VStack(spacing: 0) {
                
                // Danh sách đã uống (Lấy từ Realm)
                ForEach(Array(viewModel.todayLogs.enumerated()), id: \.element.id) {index, log in
                    
                    let isLast = index == viewModel.todayLogs.count - 1
                    
                    HistoryRow(log: log, isLastRow: isLast, onDelete : {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            viewModel.deleteLog(log)
                        }
                    },onEdit : {
                        onEdit(log)
                    }).transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 0)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal, 10)
        }
        .animation(.easeInOut(duration: 1.0), value: viewModel.todayLogs.count)
        .padding(10)
    }
}



// Dòng lịch sử
struct HistoryRow: View {
    var log: WaterLog
    var isLastRow : Bool
    var onDelete : () -> Void
    var onEdit : () -> Void
    
    var body: some View {
        
        VStack{
            HStack(alignment: .top, spacing: 12){
                VStack(spacing: 0){
                    let isBigIcon = log.iconName.contains("400ml") || log.iconName.contains("500ml")
                    
                    Image(log.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: isBigIcon ? 30 : 25)
                    
                    if !isLastRow {
                        Image("line_graps")
                            .resizable()
                            .frame(width: 2)
                    }
                }.frame(width: 30)
                HStack{
                    Text(DateFormat.formatTime(log.date))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.black)
                    
                    Spacer()
                    
                    Text("\(log.amount) ml")
                        .foregroundColor(.textSecondary)
                    
                    Menu{
                        // Sửa
                        Button(action: {
                            onEdit()
                        }) {
                            Text("Chỉnh sửa")
                                .foregroundStyle(.textSecondary)
                        }
                        
                        // Xoá
                        Button(action: {
                            onDelete()
                        }) {
                            Text("Xoá bỏ")
                                .foregroundStyle(.textSecondary)
                        }
                    }label: {
                        Image("ic_more_options")
                            .foregroundColor(.gray)
                            .frame(width: 20, height: 20)
                            .contentShape(Rectangle())
                        
                    }
                }
                .frame(height: 30)
            }
        }
        .padding(.horizontal, 20)
        
    }
}

// Lời khuyên
struct AdviceView: View {
    @State private var showAdvice = false
    var content : String
    
    var body: some View {
        HStack(alignment: .top) {
            Image("ic_character_home")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            HStack(){
                Image("ic_triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .offset(x: 10, y: -15)
                // Bong bóng chat
                ZStack {
                    Text("\n\n")
                        .font(.caption)
                        .padding()
                        .opacity(0) // Ẩn
                    
                    // Nội dung thật
                    Text(content)
                        .font(.caption)
                        .padding()
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                .frame(maxWidth: .infinity, alignment: .leading) // Cho phép giãn ngang
                .foregroundStyle(.black)
                .background(Color.blue.opacity(0.15))
                .cornerRadius(12)
                 .id(content)
                    
            }
            .offset(x: -15)
            Spacer()
            
            Button(action: {
                showAdvice = true
            }) {
                VStack(spacing: 5) {
                    Image("ic_more_tips")
                        .resizable()
                        .frame(width: 40, height: 40)
                    
                    Text("Thêm lời khuyên")
                        .font(.caption2)
                        .foregroundColor(.textHighlighted)
                        .multilineTextAlignment(.center)
                }
            }
            .fullScreenCover(isPresented: $showAdvice) {
                MoreAdviceView()
                
            }
        }
        .padding()
    }
}

// Tiêu đề
struct HeaderView : View {
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Nhắc nhở uống nước")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.vertical, 15)
                Spacer()
            }
            .background(Color.white)
            .zIndex(1)
        }
    }
}



// Struct hỗ trợ Animation
struct FloatingTextData: Identifiable {
    let id = UUID()
    var amount: Int
    var position: CGPoint
    var opacity: Double = 1.0
    var message : String
}

// Thanh tiến trình
struct HalfCircleProgressView: View {
    var progress: Double
    
    let lineWidth: CGFloat = 7          // Độ dày của thanh
    let iconPadding: CGFloat = 20       // khoảng cách icon 2 đầu
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let radius = size / 2
            
            ZStack {
                // Nửa vòng tròn xám
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(180)) // Úp ngược lên
                
                // Nửa vòng tròn xanh
                Circle()
                    .trim(from: 0.0, to: 0.5 * min(progress, 1.0))
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(180))
                    .animation(.linear, value: progress)
                
                Image("ic_break_heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .offset(x: -(radius) , y: iconPadding)
                
                Image("ic_hydration")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25, height: 25)
                    .offset(x: radius , y: iconPadding)
                
            }
            // Dịch tâm xuống để vòng cung nằm cân đối hơn
            .offset(y: size / 4)
        }
    }
}

