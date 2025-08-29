import SwiftUI
import Foundation
import HealthKit
import WatchConnectivity
import WatchKit


struct ContentView: View {
    var body: some View {
        StartView()

    }
}

#Preview {
    ContentView()
}
struct StartView: View {
    @StateObject var viewModel = HeartRateViewModel()

    var body: some View {
        VStack {
            if !viewModel.isAuthorized {
                VStack(spacing: 8) {
                    Text("Heart rate and workout permission not granted.")
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("Please enable Health permissions in Settings to start measuring")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    Button("Allow Access") {
                        viewModel.requestAuthorization()
                    }
                    .padding(.top, 6)
                }
            } else if viewModel.isMeasuring {
                MeasuringView(viewModel: viewModel)
            } else if viewModel.canRepeat {
                Text("Your data is sended to app")
                    .padding()
                Button("Repeat") {
                    viewModel.start()
                }
            } else {
                Button("Start measuring") {
                    viewModel.start()
                }
            }
        }
    }
}

struct MeasuringView: View {
    @ObservedObject var viewModel: HeartRateViewModel

    var body: some View {
        VStack(spacing: 16) {
            NeonECGView(isRunning: viewModel.isMeasuring)
                .frame(width: 120, height: 80, alignment: .center)

            VStack(alignment: .leading, spacing: 0) {
                Text("Current")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(Int(viewModel.bpm))")
                        .font(.system(size: 39, weight: .regular))
                        .foregroundColor(.white)
                    Text("BPM")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Color(red: 1, green: 0, blue: 0)) // #FF0000
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
    }
}



// MARK: - Готовая неоновая ЭКГ-анимация

struct NeonECGView: View {
    var isRunning: Bool = true          // можно привязать к viewModel.isMeasuring
    var duration: Double = 2.4          // время одного прохода слева-направо
    var windowFraction: CGFloat = 0.18  // ширина «щётки» (≈18% ширины)
    var lineWidth: CGFloat = 3.0
    var feather: CGFloat = 0.36 // softer edges by default (0…0.49)
    var edgeInset: CGFloat = 1.0 // minimal visual margin to screen edges
    var maskBlur: CGFloat = 12.0 // extra blur on the mask for smoother fade

    @State private var travel: CGFloat = 0
    @State private var hapticTimer: Timer?

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let f = min(max(self.feather, 0.0), 0.49) // clamp
            let winW = max(12, w * windowFraction)
            // Align visible mask content nearly flush with edges, with tiny inset
            let startX = -100.0
            let endX   =  w - winW * (1 - f) - edgeInset

            // Moving "window" with feathered edges that reveals ONLY a slice of the waveform
            let windowMask =
                Rectangle()
                    .fill(
                        LinearGradient(
                            stops: [
                                .init(color: .clear, location: 0.00),
                                .init(color: .white, location: f),
                                .init(color: .white, location: 1.0 - f),
                                .init(color: .clear, location: 1.00),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: winW, height: h)
                    .offset(x: startX + travel * (endX - startX))
                    .blur(radius: maskBlur) // extra feathering for smoother edges

            ZStack {
                // Background grid stays visible across screen
                NeonGrid(spacing: 8, color: Color.red.opacity(0.12))
                    .blur(radius: 0.6)

                // Everything related to the waveform is inside a moving MASK so only the "neon window" is visible
                Group {
                    // Base, slightly visible stroke to keep structure in the window
                    WaveformShape()
                        .stroke(Color.red.opacity(0.28),
                                style: StrokeStyle(lineWidth: lineWidth,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: w, height: h)

                    // Soft glow (wide)
                    WaveformShape()
                        .stroke(Color.red,
                                style: StrokeStyle(lineWidth: lineWidth * 5.5,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: w, height: h)
                        .opacity(0.16)
                        .blur(radius: 14)
                        .blendMode(.plusLighter)

                    // Tighter glow (mid)
                    WaveformShape()
                        .stroke(Color.red,
                                style: StrokeStyle(lineWidth: lineWidth * 3.2,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: w, height: h)
                        .opacity(0.28)
                        .blur(radius: 8)
                        .blendMode(.plusLighter)

                    // Core line
                    WaveformShape()
                        .stroke(Color.red,
                                style: StrokeStyle(lineWidth: lineWidth,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                        .frame(width: w, height: h)
                        .overlay(
                            WaveformShape()
                                .stroke(Color.white.opacity(0.85),
                                        style: StrokeStyle(lineWidth: 1.0,
                                                           lineCap: .round,
                                                           lineJoin: .round))
                                .frame(width: w, height: h)
                                .blur(radius: 0.6)
                                .blendMode(.screen)
                        )
                }
                .mask(windowMask) // ← reveals only a slice with feathered edges

                // Narrow, extra-bright "sweep" that runs inside the same window
                WaveformShape()
                    .stroke(Color.red,
                            style: StrokeStyle(lineWidth: lineWidth * 1.2,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .frame(width: w, height: h)
                    .mask(
                        Rectangle()
                            .fill(LinearGradient(colors: [.clear, .white, .clear],
                                                 startPoint: .leading,
                                                 endPoint: .trailing))
                            .frame(width: max(8, winW * max(0.2, 1.0 - 2.0 * f) * 0.5), height: h)
                            .offset(x: startX + travel * (endX - startX))
                            .blur(radius: maskBlur)
                    )
                    .blendMode(.plusLighter)
            }
            .frame(width: w, height: h)
            .compositingGroup()
            .onAppear { start() }
            .onChange(of: isRunning) { _, running in
                running ? start() : stop()
            }
        }
    }

    private func start() {
        // анимация «щётки»
        travel = 0
        withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
            travel = 1
        }
        // опционально — таптик в середине прохода (как «удар»)
        hapticTimer?.invalidate()
        hapticTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: true) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration * 0.5) {
                WKInterfaceDevice.current().play(.click)
            }
        }
    }

    private func stop() {
        hapticTimer?.invalidate()
        hapticTimer = nil
    }
}

// MARK: - Сетка из тонких линий
struct NeonGrid: View {
    let spacing: CGFloat
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let cols = Int(size.width / spacing)
            let rows = Int(size.height / spacing)
            let stroke = StrokeStyle(lineWidth: 0.6)

            for i in 0...cols {
                let x = CGFloat(i) * spacing + 0.5
                var p = Path()
                p.move(to: CGPoint(x: x, y: 0))
                p.addLine(to: CGPoint(x: x, y: size.height))
                ctx.stroke(p, with: .color(color), style: stroke)
            }
            for j in 0...rows {
                let y = CGFloat(j) * spacing + 0.5
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: .color(color), style: stroke)
            }
        }
    }
}

// MARK: - Волна ЭКГ (нормализованная, масштабируется под доступный rect)
struct WaveformShape: Shape {
    func path(in rect: CGRect) -> Path {
        // Helper to map normalized points (x in 0...1, y in -1...1) into rect
        func P(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width,
                    y: rect.midY - y * rect.height * 0.42) // 0.42 keeps headroom
        }

        var p = Path()

        // Start on baseline, slight lead-in
        p.move(to: P(0.00, 0.00))
        p.addLine(to: P(0.06, 0.00))

        // Small pre-bump
        p.addLine(to: P(0.10, 0.22))
        p.addLine(to: P(0.12, -0.35))

        // BIG upstroke (central tall spike)
        p.addLine(to: P(0.17, 1.20))
        p.addLine(to: P(0.22, -1.00))
        p.addLine(to: P(0.28, 0.00))

        // Low-amplitude ripple section
        p.addLine(to: P(0.35, 0.28))
        p.addLine(to: P(0.38, -0.18))
        p.addLine(to: P(0.42, 0.32))
        p.addLine(to: P(0.48, 0.00))

        // Quiet baseline
        p.addLine(to: P(0.62, 0.00))

        // Right-side complex (medium peak then deep notch, then rebound)
        p.addLine(to: P(0.68, 0.55))
        p.addLine(to: P(0.72, -1.10))
        p.addLine(to: P(0.77, 0.85))
        p.addLine(to: P(0.82, 0.00))

        // Tail-out
        p.addLine(to: P(1.00, 0.00))

        return p
    }
}



final class HeartRateViewModel: NSObject, ObservableObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate, WCSessionDelegate {
    @Published var isAuthorized = false

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
       
   }

   func sessionReachabilityDidChange(_ session: WCSession) {
       
   }
    
    private var healthStore = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var dataSource: HKLiveWorkoutDataSource?
    
    private var hrQuery: HKAnchoredObjectQuery?
    private var hrAnchor: HKQueryAnchor?
    private var lastSampleAt: Date?
    
    private let thresholdSamples = 15
    private var earlyFinishTriggered = false
    
    private var bpmUpdateTimer: Timer?
    @Published var bpm: Double = 0
    @Published var measurements: [Double] = []
    @Published var isMeasuring = false
    @Published var canRepeat = false

    private var timer: Timer?

    private func stateName(_ state: HKWorkoutSessionState) -> String {
        switch state {
        case .notStarted: return "notStarted"
        case .running: return "running"
        case .ended: return "ended"
        case .paused: return "paused"
        case .prepared: return "prepared"
        case .stopped: return "stopped"
        @unknown default: return "unknown"
        }
    }

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        requestAuthorization()
    }

    func requestAuthorization() {
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let workoutType = HKObjectType.workoutType()

        healthStore.requestAuthorization(toShare: [workoutType], read: [heartRateType]) { success, error in
            DispatchQueue.main.async {
                self.isAuthorized = success
            }
            if success {
                
            } else {
                
            }
        }
    }

    private func fetchMostRecentHeartRate() {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { [weak self] _, samples, _ in
            guard let self = self, let s = samples?.first as? HKQuantitySample else { return }
            let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let hr = s.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                self.bpm = hr
            }
            
        }
        healthStore.execute(q)
    }

    private func startHeartRateStreaming(from startDate: Date) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(type: type, predicate: predicate, anchor: hrAnchor, limit: HKObjectQueryNoLimit) { [weak self] _, samples, _, newAnchor, error in
            self?.hrAnchor = newAnchor
            self?.processHeartRateSamples(samples)
        }
        query.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            self?.hrAnchor = newAnchor
            self?.processHeartRateSamples(samples)
        }
        hrQuery = query
        healthStore.execute(query)
        
    }

    private func stopHeartRateStreaming() {
        if let q = hrQuery { healthStore.stop(q) }
        hrQuery = nil
        
    }

    private func processHeartRateSamples(_ samples: [HKSample]?) {
        guard let qs = samples as? [HKQuantitySample], !qs.isEmpty else { return }
        let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
        for s in qs {
            let hr = s.quantity.doubleValue(for: unit)
            DispatchQueue.main.async {
                self.bpm = hr
                self.measurements.append(hr)
                self.checkThresholdAndFinish()
            }
            WKInterfaceDevice.current().play(.click) // haptic on real measurement
            self.lastSampleAt = Date()
            
            
        }
    }

    func start() {
        
        // Switch UI to Measuring instantly and optionally seed last HR
        DispatchQueue.main.async {
            self.isMeasuring = true
            self.earlyFinishTriggered = false
            self.canRepeat = false
            self.measurements = []
            self.bpm = 0
        }
        // Optionally seed with last known HR so the UI isn't blank while HK starts
        self.fetchMostRecentHeartRate()

        guard HKHealthStore.isHealthDataAvailable() else {
            
            return
        }

        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()

            session?.delegate = self
            builder?.delegate = self

            dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            builder?.dataSource = dataSource

            WKInterfaceDevice.current().play(.start)
            

            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date()) { success, error in
                if let error = error {
                    DispatchQueue.main.async { self.isMeasuring = false }
                } else {
                    DispatchQueue.main.async {
                        self.startHeartRateStreaming(from: Date())
                    }
                }
            }

            // Measure for 30 seconds, then stop automatically
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { _ in
                self.stop()
            }
            
            bpmUpdateTimer?.invalidate()
            bpmUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                // If no fresh sample yet, reuse last known HR to keep 1 Hz cadence
                let shouldAppend: Bool
                if let last = self.lastSampleAt {
                    shouldAppend = Date().timeIntervalSince(last) >= 0.9
                } else {
                    shouldAppend = true
                }
                
                if shouldAppend {
                    DispatchQueue.main.async {
                        self.measurements.append(self.bpm)
                    }
                    
                    DispatchQueue.main.async { WKInterfaceDevice.current().play(.click) }
                } else {
                    
                }
                
            }

        } catch {
            
            DispatchQueue.main.async { self.isMeasuring = false }
        }
    }
    private func checkThresholdAndFinish() {
        guard isMeasuring, !earlyFinishTriggered, measurements.count >= thresholdSamples else { return }
        earlyFinishTriggered = true
        
        stop() // stop() сам вызовет sendToPhone() и покажет “The data is saved in the app”
    }

    func stop() {
        
        stopHeartRateStreaming()
        timer?.invalidate()
        timer = nil

        session?.end()
        builder?.endCollection(withEnd: Date()) { _, endError in
            if let endError = endError {
                
            } else {
                
            }

            self.builder?.finishWorkout { _, finishError in
                if let finishError = finishError {
                    
                } else {
                    
                    self.sendToPhone()
                    WKInterfaceDevice.current().play(.success)
                }
            }
        }

        bpmUpdateTimer?.invalidate()
        bpmUpdateTimer = nil

        DispatchQueue.main.async {
            self.isMeasuring = false
            self.canRepeat = true
        }
    }

    func sendToPhone() {
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["DATA": measurements], replyHandler: nil)
        } else {
            
        }
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf types: Set<HKSampleType>) {
        guard let type = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            
            return
        }
        if types.contains(type) {
            if let stats = workoutBuilder.statistics(for: type) {
                let unit = HKUnit.count().unitDivided(by: HKUnit.minute())
                if let bpm = stats.mostRecentQuantity()?.doubleValue(for: unit) {
                    DispatchQueue.main.async {
                        self.bpm = bpm
                    }
                    
                } else {
                    
                }
            } else {
                
            }
        } else {
            
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}
