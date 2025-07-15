import SwiftUI

struct ZoneViewer: View {
    
    var zone: Int
    private let zones: [Int] = [1,2,3,4,5]
    
    func getColorForZone(_ zone: Int) -> Color {
        switch zone {
        case 1: return .blue
        case 2: return .yellow
        case 3: return .green
        case 4: return .orange
        case 5: return .red
        default: return .black
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 3) {
                ForEach(zones, id: \.self) { z in
                    RoundedRectangle(cornerRadius: 3)
                        .foregroundStyle(getColorForZone(z))
                        .overlay {
                            if z == zone {
                                Text("\(z)")
                                    .foregroundStyle(.black)
                                    .font(.caption2)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(
                            width: z == zone ? 40 : 25,
                            height: z == zone ? 20 : 16
                        )
                }
            }.padding(.horizontal, 8)
            
            Text("Zone \(zone)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(getColorForZone(zone))
        }
    }
}

#Preview {
    ZoneViewer(zone: 1)
}
