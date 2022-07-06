//
//  ContentView.swift
//  BetterRest
//
//  Created by Corwin Rainier on 6/20/22.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWake
    @State private var sleepDesired = 8.0
    @State private var coffeeAmount = 0
    @State private var alertTitle = ""
    @State private var alertMesage = ""
    @State private var alertShow = false
    static var defaultWake: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView {
            ZStack {
            Form {
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.wheel)
                } header: {
                    Text("When would you like to wake up?")
                        .foregroundColor(.white)
                        .background(.black)
                }
                Section {
                    Stepper("\(sleepDesired.formatted()) hours", value: $sleepDesired, in: 4...16, step: 0.5)
                } header: {
                    Text("What is your desired amount of sleep?")
                        .foregroundColor(.white)
                        .background(.black)
                }
                Section {
                    Picker("Daily cups of coffee:", selection: $coffeeAmount) {
                        ForEach(1..<16) {
                            Text("\($0) cups")
                        }
                    }
                } header: {
                    Text("How much coffee do you drink a day?")
                        .foregroundColor(.white)
                        .background(.black)
                }
            }
            }
            .navigationTitle("BetterRest")
            .background(
                Image("Starry Background")
                    .resizable()
                    .scaledToFill()
                    .overlay(
                        VStack {
                            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                                .frame(height: 400)
                            Spacer()
                        }
                    )
                    .edgesIgnoringSafeArea(.all)
            )
            .toolbar {
                Button{
                    calcSleepStart()
                } label: {
                    Image(systemName: "play.fill")
                }
                .buttonStyle(.plain)
            }
            .alert(alertTitle, isPresented: $alertShow) {
                Button("Okay") { }
            } message: {
                Text(alertMesage)
            }
            .preferredColorScheme(.dark)
        }
    }
    func calcSleepStart() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepDesired, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            alertTitle = "Your ideal bedtime is..."
            alertMesage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMesage = "Something went wrong while calculating the result."
        }
        alertShow = true
    }
    init() {
        UITableView.appearance().backgroundColor = .clear // For tableView
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
