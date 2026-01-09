//
//  DashboardView.swift
//  H2Only
//
//  Created by Trangptt on 7/1/26.
//

import SwiftUI
import RealmSwift

struct DashboardView: View {
    @StateObject var viewModel = DashboardViewModel()
    // Biến để quản lý hiệu ứng chữ bay
    @State private var floatingTexts: [FloatingTextData] = []
    @State private var showChangeCupSheet = false
    
    var selectedCup: Int {
        return viewModel.userProfile?.selectedCupSize ?? 0
    }
    let adviceList = [
        "Không uống nước ngay sau khi ăn",
        "Uống một ly nước từ từ với vài ngụm nhỏ",
        "Uống nước ở tư thế ngồi tốt hơn tư thế đứng hoặc chạy",
        "Luôn uống nước trước khi đi tiểu và không uống nước ngay sau khi đi tiểu",
        "Ngậm nước trong miệng một lúc trước khi nuốt",
        "Uống một ly nước từ từ với vài ngụm nhỏ"
    ]
    @State private var currentAdvice: String = "Không uống nước ngay sau khi ăn"
    
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    HeaderView()
                    // Header
                    AdviceView(content: currentAdvice)
                    
                    Spacer().frame(height: 10)
                    VStack() {
                        
                        // Cụm vòng tròn + Nút đổi cốc
                        ZStack {
                            
                            HalfCircleProgressView(
                                progress: Double(viewModel.currentIntake) / Double(viewModel.dailyGoal)
                            )
                            .frame(width: 320, height: 320)
                            .offset(y: -80)
                            
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
                                            Text("\(viewModel.currentIntake)")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.blue)
                                            Text("/\(viewModel.dailyGoal) ml")
                                                .font(.system(size: 20, weight: .medium))
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text("Mục tiêu uống hàng ngày")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 100)
                                    .padding(.bottom,50)
                                    // Nút cộng nước
                                    Button(action: {
                                        addWaterWithAnimation()
                                    }) {
                                        VStack(spacing: 5) {
                                            Text("\(viewModel.userProfile?.selectedCupSize ?? 125) ml")
                                            
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.black)
                                            
                                            Image(viewModel.getCurrentIconName(postFix: "add"))
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 50, height: 50)
                                        }
                                    }
                                }
                                
                                
                            }
                            
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
                    
                    // Hiệu ứng chữ bay
                    .overlay(
                        ZStack {
                            ForEach(floatingTexts) { data in
                                Text("+ \(data.amount) ml")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .position(x: data.position.x, y: data.position.y)
                                    .opacity(data.opacity)
                            }
                        }
                    )
                    VStack(spacing: 5) {
                        Image("ic_arrow")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 15, height: 20)
                        
                        Text("Xác nhận rằng bạn vừa uống nước")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Lịch sử
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Hồ sơ hôm nay")
                            .font(.headline)
                            .padding(.horizontal)
                            .foregroundStyle(.black)
                        VStack(spacing: 0) {
//                            HStack(alignment: .top) {
//                                VStack {
//                                    Image("ic_next_time")
//                                        .frame(width: 50,height: 50)
//                                    Image("line_graps")
//                                        .resizable()
//                                        .frame(width: 2, height: 40)
//                                        .offset(x:-4)
//                                }
//                                .frame(width: 30)
//                                
//                                VStack(alignment: .leading) {
//                                    Text("10:20") // Giờ giả định
//                                        .font(.system(size: 16, weight: .bold))
//                                    Text("Lần tới")
//                                        .font(.caption)
//                                        .foregroundColor(.gray)
//                                }
//                                Spacer()
//                                Text("125 ml").foregroundColor(.gray)
//                            }
//                            .padding(.horizontal, 7)
                            
                            // Danh sách đã uống (Lấy từ Realm)
                            ForEach(viewModel.todayLogs) { log in
                                HistoryRow(log: log)
                            }
                        }
                        .padding(.vertical, 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 10)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }.padding(20)
                }
            }
            .sheet(isPresented: $showChangeCupSheet) {
                ChangeCupSheet(viewModel: viewModel)
                    .presentationDetents([.medium, .large]) // Cho phép kéo nửa màn hình hoặc full
            }
        }
    }
    
    // Logic thêm nước + Hiệu ứng
    func addWaterWithAnimation() {
        // Thêm vào DB
        viewModel.addWater()
        
        // Tạo hiệu ứng chữ bay
        let amount = viewModel.userProfile?.selectedCupSize ?? 125
        let newFloatingText = FloatingTextData(amount: amount, position: CGPoint(x: 150, y: 150)) // Vị trí xuất phát (giữa vòng tròn)
        
        floatingTexts.append(newFloatingText)
        
        withAnimation{
            currentAdvice = adviceList.randomElement() ?? adviceList[0]
        }
        
        // Animation bay lên
        if let index = floatingTexts.firstIndex(where: { $0.id == newFloatingText.id }) {
            withAnimation(.easeOut(duration: 1.0)) {
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

// Subview: Dòng lịch sử
struct HistoryRow: View {
    var log: WaterLog
    
    var body: some View {
        HStack(alignment: .top) {
            VStack (alignment: .center){
                Image(log.iconName)
                    .frame(width: 50,height: 50)
                
                Image("line_graps")
                    .resizable()
                    .frame(width: 2, height: 40)
                    .offset(x: -4)
            }
            .frame(width: 30)
            
            Text(formatTime(log.date))
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.black)
            
            Spacer()
            
            Text("\(log.amount) ml")
                .foregroundColor(.gray)
            
            // Dấu 3 chấm
            Button(action: {}) {
                Image("ic_more_options")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
    }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

// Subview: Header
struct AdviceView: View {
    @State private var showAdvice = false
    var content : String
    
    var body: some View {
        HStack(alignment: .top) {
            Image("ic_character_home")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            HStack{
                Image("ic_triangle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15, height: 15)
                    .offset(x: 11, y: -15)
                // Bong bóng chat
                Text(content)
                    .font(.caption)
                    .padding()
                    .foregroundStyle(.black)
                    .background(Color.blue.opacity(0.1))
                    .id(content)
                    .cornerRadius(12)
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
}

// Thanh tiến trình
struct HalfCircleProgressView: View {
    var progress: Double
    
    // Cấu hình giao diện
    let lineWidth: CGFloat = 7
    let iconPadding: CGFloat = 20
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size.width
            let radius = size / 2
            
            ZStack {
                // Nền mờ (Track) - Nửa vòng trên
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(Color.gray.opacity(0.15), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(180)) // Úp ngược lên
                
                // 2Thanh tiến độ (Blue)
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

