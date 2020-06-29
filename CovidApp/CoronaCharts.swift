//
//  CoronaCharts.swift
//  CovidApp
//
//  Created by debi sani on 29/06/20.
//  Copyright © 2020 debi sani. All rights reserved.
//

import SwiftUI

struct TimeSeries: Decodable {
    let Indonesia: [DayData]
    let Italy: [DayData]
}

struct DayData: Decodable, Hashable {
    let date: String
    let confirmed, deaths, recovered: Int
}

class ChartViewModel: ObservableObject {
    
    @Published var dataSet = [DayData]()
    
    var max = 0
    
    init() {
        let urlString = "https://pomber.github.io/covid19/timeseries.json"
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, resp, err) in
            
            guard let data = data else { return }
            
            do {
                let timeSeries = try JSONDecoder().decode(TimeSeries.self, from: data)
                print(timeSeries.Indonesia)
                
                DispatchQueue.main.async {
                    self.dataSet = timeSeries.Indonesia.filter{ $0.deaths > 0}
                    self.max = self.dataSet.max(by: { (day1, day2) -> Bool in
                        return day2.deaths > day1.deaths
                        })?.deaths ?? 0
                }
                
//                timeSeries.Indonesia.forEach { (dayData) in
//                    print(dayData.deaths)
//                }
            } catch {
                print("JSON Decode Failed:", error)
            }
        }.resume()
    }
}

struct CoronaCharts: View {
    
    @ObservedObject var vm = ChartViewModel()
    
    var body: some View {
        VStack {
            Text("Corona")
                .font(.system(size: 30, weight: .bold))
            Text("Total Death : \(vm.max)")
            
            if !vm.dataSet.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(vm.dataSet, id: \.self) { day in
                        HStack {
                            Spacer()
                        }
                        .frame(width: 2, height: (CGFloat(day.deaths) / CGFloat(self.vm.max)) * 200)
                        .background(Color.red)
                    }
                }
            }
        }
        
    }
}

struct CoronaCharts_Previews: PreviewProvider {
    static var previews: some View {
        CoronaCharts()
    }
}
