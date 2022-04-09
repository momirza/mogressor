import CoreData
import SwiftUI

import SwiftUICharts

struct ContentView: View {
    
    
    @ObservedObject var bluetooth = BluetoothManager()
    
    var body: some View {
        VStack {
            VStack {
                HStack(alignment: .center, spacing: 10) {
                    Text("Mogressor")
                        .font(.title)
                    Button("Clear") {
                        bluetooth.data = []
                    }
                    Button("Tare") {
                        bluetooth.tare()
                    }
                    Spacer()
                    if let last = bluetooth.data.last {
                        Text("\(String(format: "%.1f", last)) kg")
                            .font(.title)
                    }
                    if let maxLoad = bluetooth.maxLoad {
                        Text("\(String(format: "%.1f", maxLoad)) kg")
                            .font(.title)
                            .foregroundColor(Color(.systemOrange))
                    }
                }
                
            }
            if bluetooth.data.isEmpty {
                ZStack {
                    Color(.secondarySystemBackground)
                    Text("No data")
                        .foregroundColor(.secondary)
                }
            } else {
                
                LineChart()
                    .data(bluetooth.data)
                    .chartStyle(
                        ChartStyle(
                            backgroundColor: .white,
                            foregroundColor: ColorGradient(.orange, .purple)
                        )
                    )
                    .padding()
                    .border(.blue)
            }
        }
        .padding()
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewLayout(.fixed(width: 600, height: 400))
    }
}
