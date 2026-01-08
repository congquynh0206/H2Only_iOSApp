import SwiftUI

struct MoreAdviceView: View {
    // Biến môi trường để đóng màn hình
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            
            ZStack {
                Text("Thế nào là uống nước đúng cách?")
                    .font(.headline)
                    .fontWeight(.bold) // In đậm
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
              
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        
                        Image("ic_close")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                            .padding(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 10)
            
            Divider()
            
            
            ScrollView {
                VStack(spacing: 15) {
                    AdviceRow(imageName: "ic_how_to_1", content: "Uống một ly nước từ từ với vài ngụm nhỏ")
                    AdviceRow(imageName: "ic_how_to_2", content: "Ngậm nước trong miệng một lúc trước khi nuốt")
                    AdviceRow(imageName: "ic_how_to_3", content: "Uống nước ở tư thế ngồi tốt hơn tư thế đứng hoặc chạy")
                    AdviceRow(imageName: "ic_how_to_4", content: "Không uống nước lạnh hoặc nước đá")
                    AdviceRow(imageName: "ic_how_to_5", content: "Không uống nước ngay sau khi ăn")
                    AdviceRow(imageName: "ic_how_to_6", content: "Không uống nước lạnh ngay sau khi ăn/uống những thứ nóng như trà hoặc cà phê")
                    AdviceRow(imageName: "ic_how_to_7", content: "Luôn uống nước trước khi đi tiểu và không uống nước ngay sau khi đi tiểu")
                }
                .padding()
            }
        }
        .background(Color.white)
    }
}

struct AdviceRow: View {
    let imageName: String
    let content: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(imageName)
                .resizable()
                .scaledToFit() // Giữ tỷ lệ ảnh
                .frame(width: 50, height: 60)
            
            Text(content)
                .foregroundColor(.textSecondary)
                .font(.system(size: 15))
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
    }
}
