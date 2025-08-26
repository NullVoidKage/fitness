import SwiftUI
import HealthKit

// MARK: - Enhanced Data Models
struct FitnessData: Identifiable {
    let id = UUID()
    var steps: Int
    var distance: Double // in kilometers
    var calories: Int
    var activeMinutes: Int
    var heartRate: Int
    var sleepHours: Double
    var wakeUps: Int
    var hydration: Int // in ml
    var streak: Int
    var dailyGoal: Int
    var weeklyGoal: Int
    var monthlyGoal: Int
}

struct Workout: Identifiable {
    let id = UUID()
    var name: String
    var type: WorkoutType
    var duration: TimeInterval
    var calories: Int
    var distance: Double?
    var heartRate: [Int]
    var startTime: Date
    var endTime: Date
    var isActive: Bool
}

enum WorkoutType: String, CaseIterable {
    case running = "Running"
    case cycling = "Cycling"
    case walking = "Walking"
    case hiit = "HIIT"
    case yoga = "Yoga"
    case swimming = "Swimming"
    
    var icon: String {
        switch self {
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .walking: return "figure.walk"
        case .hiit: return "flame.fill"
        case .yoga: return "figure.mind.and.body"
        case .swimming: return "figure.pool.swim"
        }
    }
    
    var color: Color {
        switch self {
        case .running: return .red
        case .cycling: return .blue
        case .walking: return .green
        case .hiit: return .orange
        case .yoga: return .purple
        case .swimming: return .cyan
        }
    }
}

struct Achievement: Identifiable {
    let id = UUID()
    var name: String
    var description: String
    var icon: String
    var isUnlocked: Bool
    var progress: Double
    var color: Color
}

struct Reminder: Identifiable {
    let id = UUID()
    var type: ReminderType
    var time: Date
    var isEnabled: Bool
    var message: String
}

enum ReminderType: String, CaseIterable {
    case stand = "Stand"
    case hydration = "Hydration"
    case bedtime = "Bedtime"
    case workout = "Workout"
    
    var icon: String {
        switch self {
        case .stand: return "figure.stand"
        case .hydration: return "drop.fill"
        case .bedtime: return "bed.double.fill"
        case .workout: return "dumbbell.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .stand: return .green
        case .hydration: return .blue
        case .bedtime: return .purple
        case .workout: return .orange
        }
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @State private var selectedTab = 0
    @State private var fitnessData = FitnessData(
        steps: 0,
        distance: 0.0,
        calories: 0,
        activeMinutes: 0,
        heartRate: 72,
        sleepHours: 7.5,
        wakeUps: 2,
        hydration: 0,
        streak: 0,
        dailyGoal: 10000,
        weeklyGoal: 70000,
        monthlyGoal: 300000
    )
    
    @State private var workouts: [Workout] = []
    @State private var achievements: [Achievement] = []
    @State private var reminders: [Reminder] = []
    @State private var showingWorkoutSheet = false
    @State private var showingReminderSheet = false
    
    // Timer for real-time updates
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Dashboard Tab
            DashboardView(
                fitnessData: $fitnessData,
                workouts: $workouts,
                showingWorkoutSheet: $showingWorkoutSheet
            )
            .tabItem {
                Image(systemName: "house.fill")
                Text("Dashboard")
            }
            .tag(0)
            
            // MARK: - Workouts Tab
            WorkoutsView(
                workouts: $workouts,
                showingWorkoutSheet: $showingWorkoutSheet
            )
            .tabItem {
                Image(systemName: "figure.run")
                Text("Workouts")
            }
            .tag(1)
            
            // MARK: - Heart Rate Tab
            HeartRateView(fitnessData: $fitnessData)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Heart Rate")
                }
                .tag(2)
            
            // MARK: - Sleep Tab
            SleepView(fitnessData: $fitnessData)
                .tabItem {
                    Image(systemName: "bed.double.fill")
                    Text("Sleep")
                }
                .tag(3)
            
            // MARK: - Achievements Tab
            AchievementsView(achievements: $achievements)
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Achievements")
                }
                .tag(4)
        }
        .accentColor(.green)
        .onReceive(timer) { _ in
            updateFitnessData()
        }
        .onAppear {
            setupInitialData()
        }
        .sheet(isPresented: $showingWorkoutSheet) {
            WorkoutSheet(workouts: $workouts)
        }
    }
    
    private func setupInitialData() {
        // Initialize sample data
        workouts = [
            Workout(name: "Morning Run", type: .running, duration: 1800, calories: 180, distance: 3.2, heartRate: [140, 150, 160, 155, 145], startTime: Date().addingTimeInterval(-7200), endTime: Date().addingTimeInterval(-5400), isActive: false),
            Workout(name: "Evening Walk", type: .walking, duration: 1200, calories: 80, distance: 1.8, heartRate: [90, 95, 100, 98, 92], startTime: Date().addingTimeInterval(-3600), endTime: Date().addingTimeInterval(-2400), isActive: false)
        ]
        
        achievements = [
            Achievement(name: "First Steps", description: "Complete your first workout", icon: "figure.walk", isUnlocked: true, progress: 1.0, color: .green),
            Achievement(name: "Streak Master", description: "Maintain a 7-day streak", icon: "flame.fill", isUnlocked: false, progress: 0.6, color: .orange),
            Achievement(name: "Goal Crusher", description: "Hit your daily goal 5 times", icon: "target", isUnlocked: false, progress: 0.4, color: .blue)
        ]
        
        reminders = [
            Reminder(type: .stand, time: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()) ?? Date(), isEnabled: true, message: "Time to stand up and move around!"),
            Reminder(type: .hydration, time: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date(), isEnabled: true, message: "Stay hydrated! Drink some water."),
            Reminder(type: .bedtime, time: Calendar.current.date(bySettingHour: 22, minute: 0, second: 0, of: Date()) ?? Date(), isEnabled: true, message: "Time to wind down and prepare for bed.")
        ]
    }
    
    private func updateFitnessData() {
        // Simulate real-time data updates
        withAnimation(.easeInOut(duration: 0.5)) {
            fitnessData.steps += Int.random(in: 0...5)
            fitnessData.distance = Double(fitnessData.steps) * 0.0008 // Rough conversion
            fitnessData.calories = fitnessData.steps / 20
            fitnessData.activeMinutes = fitnessData.steps / 100
            fitnessData.heartRate += Int.random(in: -2...2)
            fitnessData.heartRate = max(60, min(180, fitnessData.heartRate))
            fitnessData.hydration += Int.random(in: 0...10)
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @Binding var fitnessData: FitnessData
    @Binding var workouts: [Workout]
    @Binding var showingWorkoutSheet: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with greeting
                    HeaderView(fitnessData: fitnessData)
                    
                    // Activity Rings
                    ActivityRingsView(fitnessData: fitnessData)
                    
                    // Quick Stats
                    QuickStatsView(fitnessData: fitnessData)
                    
                    // Recent Workouts
                    RecentWorkoutsView(workouts: workouts)
                    
                    // Quick Actions
                    QuickActionsView(showingWorkoutSheet: $showingWorkoutSheet)
                }
                .padding()
            }
            .navigationTitle("FitVA")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    let fitnessData: FitnessData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Let's crush your goals today!")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Streak badge
                VStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    Text("\(fitnessData.streak)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(16)
            }
        }
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        case 17..<22: return "Good Evening"
        default: return "Good Night"
        }
    }
}

// MARK: - Activity Rings View
struct ActivityRingsView: View {
    let fitnessData: FitnessData
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Progress")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 20) {
                // Steps Ring
                RingView(
                    progress: Double(fitnessData.steps) / Double(fitnessData.dailyGoal),
                    color: .green,
                    title: "Steps",
                    value: "\(fitnessData.steps)",
                    subtitle: "Goal: \(fitnessData.dailyGoal)"
                )
                
                // Calories Ring
                RingView(
                    progress: Double(fitnessData.calories) / 500.0,
                    color: .red,
                    title: "Calories",
                    value: "\(fitnessData.calories)",
                    subtitle: "Goal: 500"
                )
                
                // Active Minutes Ring
                RingView(
                    progress: Double(fitnessData.activeMinutes) / 30.0,
                    color: .blue,
                    title: "Active",
                    value: "\(fitnessData.activeMinutes)m",
                    subtitle: "Goal: 30m"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Ring View
struct RingView: View {
    let progress: Double
    let color: Color
    let title: String
    let value: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
                
                VStack(spacing: 2) {
                    Text(value)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(color)
                    
                    Text(title)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    let fitnessData: FitnessData
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Stats")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(
                    title: "Distance",
                    value: String(format: "%.1f km", fitnessData.distance),
                    icon: "figure.walk",
                    color: .green
                )
                
                StatCard(
                    title: "Heart Rate",
                    value: "\(fitnessData.heartRate) bpm",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Sleep",
                    value: String(format: "%.1f hrs", fitnessData.sleepHours),
                    icon: "bed.double.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Hydration",
                    value: "\(fitnessData.hydration) ml",
                    icon: "drop.fill",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Recent Workouts View
struct RecentWorkoutsView: View {
    let workouts: [Workout]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Recent Workouts")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                NavigationLink("View All", destination: WorkoutsView(workouts: .constant([]), showingWorkoutSheet: .constant(false)))
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            if workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No workouts yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Start your first workout to see it here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(16)
            } else {
                ForEach(workouts.prefix(3)) { workout in
                    WorkoutCard(workout: workout)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Workout Card
struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: workout.type.icon)
                .font(.title2)
                .foregroundColor(workout.type.color)
                .frame(width: 40, height: 40)
                .background(workout.type.color.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(workout.type.rawValue)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label("\(Int(workout.duration/60))m", systemImage: "clock")
                    Label("\(workout.calories) cal", systemImage: "flame")
                    if let distance = workout.distance {
                        Label(String(format: "%.1f km", distance), systemImage: "figure.walk")
                    }
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(formatDate(workout.startTime))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if workout.isActive {
                    Text("Active")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

// MARK: - Quick Actions View
struct QuickActionsView: View {
    @Binding var showingWorkoutSheet: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                QuickActionButton(
                    title: "Start Workout",
                    icon: "play.fill",
                    color: .green
                ) {
                    showingWorkoutSheet = true
                }
                
                QuickActionButton(
                    title: "Log Water",
                    icon: "drop.fill",
                    color: .blue
                ) {
                    // Handle water logging
                }
                
                QuickActionButton(
                    title: "Set Reminder",
                    icon: "bell.fill",
                    color: .orange
                ) {
                    // Handle reminder setting
                }
                
                QuickActionButton(
                    title: "View Progress",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                ) {
                    // Handle progress viewing
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Workouts View
struct WorkoutsView: View {
    @Binding var workouts: [Workout]
    @Binding var showingWorkoutSheet: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(workouts) { workout in
                    WorkoutCard(workout: workout)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        showingWorkoutSheet = true
                    }
                }
            }
        }
    }
}

// MARK: - Heart Rate View
struct HeartRateView: View {
    @Binding var fitnessData: FitnessData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Current Heart Rate
                    VStack(spacing: 16) {
                        Text("Current Heart Rate")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(fitnessData.heartRate)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.red)
                        
                        Text("BPM")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        // Heart Rate Zone
                        HeartRateZoneView(heartRate: fitnessData.heartRate)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    
                    // Heart Rate History (simulated)
                    HeartRateHistoryView()
                }
                .padding()
            }
            .navigationTitle("Heart Rate")
        }
    }
}

// MARK: - Heart Rate Zone View
struct HeartRateZoneView: View {
    let heartRate: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(zoneName)
                .font(.headline)
                .foregroundColor(zoneColor)
            
            Text(zoneDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(zoneColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var zoneName: String {
        if heartRate < 60 { return "Resting" }
        else if heartRate < 100 { return "Light" }
        else if heartRate < 140 { return "Moderate" }
        else if heartRate < 170 { return "Vigorous" }
        else { return "Maximum" }
    }
    
    private var zoneColor: Color {
        if heartRate < 60 { return .blue }
        else if heartRate < 100 { return .green }
        else if heartRate < 140 { return .yellow }
        else if heartRate < 170 { return .orange }
        else { return .red }
    }
    
    private var zoneDescription: String {
        if heartRate < 60 { return "Resting heart rate" }
        else if heartRate < 100 { return "Light activity zone" }
        else if heartRate < 140 { return "Moderate exercise zone" }
        else if heartRate < 170 { return "Vigorous exercise zone" }
        else { return "Maximum effort zone" }
    }
}

// MARK: - Heart Rate History View
struct HeartRateHistoryView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Today's Heart Rate")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Simulated heart rate chart
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.1))
                .frame(height: 200)
                .overlay(
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.red)
                        
                        Text("Heart Rate Chart")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Tap to view detailed history")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Sleep View
struct SleepView: View {
    @Binding var fitnessData: FitnessData
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Sleep Summary
                    VStack(spacing: 16) {
                        Text("Last Night's Sleep")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text(String(format: "%.1f", fitnessData.sleepHours))
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.purple)
                                
                                Text("Hours")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(fitnessData.wakeUps)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                
                                Text("Wake-ups")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Sleep Quality
                        SleepQualityView(sleepHours: fitnessData.sleepHours)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    
                    // Sleep Tips
                    SleepTipsView()
                }
                .padding()
            }
            .navigationTitle("Sleep")
        }
    }
}

// MARK: - Sleep Quality View
struct SleepQualityView: View {
    let sleepHours: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Text(qualityText)
                .font(.headline)
                .foregroundColor(qualityColor)
            
            Text(qualityDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(qualityColor.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var qualityText: String {
        if sleepHours >= 8 { return "Excellent" }
        else if sleepHours >= 7 { return "Good" }
        else if sleepHours >= 6 { return "Fair" }
        else { return "Poor" }
    }
    
    private var qualityColor: Color {
        if sleepHours >= 8 { return .green }
        else if sleepHours >= 7 { return .blue }
        else if sleepHours >= 6 { return .yellow }
        else { return .red }
    }
    
    private var qualityDescription: String {
        if sleepHours >= 8 { return "Great job! You're getting optimal sleep." }
        else if sleepHours >= 7 { return "Good sleep duration. Keep it up!" }
        else if sleepHours >= 6 { return "Consider getting more sleep for better health." }
        else { return "Try to increase your sleep duration for optimal health." }
    }
}

// MARK: - Sleep Tips View
struct SleepTipsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Sleep Tips")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                TipRow(icon: "moon.fill", title: "Stick to a schedule", description: "Go to bed and wake up at the same time every day")
                TipRow(icon: "bed.double.fill", title: "Create a routine", description: "Develop a relaxing bedtime routine")
                TipRow(icon: "iphone", title: "Limit screen time", description: "Avoid screens 1 hour before bedtime")
                TipRow(icon: "thermometer", title: "Keep it cool", description: "Maintain a cool, comfortable bedroom temperature")
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.purple)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    @Binding var achievements: [Achievement]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Progress Overview
                    VStack(spacing: 16) {
                        Text("Achievement Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 40) {
                            VStack(spacing: 8) {
                                Text("\(achievements.filter { $0.isUnlocked }.count)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.green)
                                
                                Text("Unlocked")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 8) {
                                Text("\(achievements.count)")
                                    .font(.system(size: 48, weight: .bold, design: .rounded))
                                    .foregroundColor(.blue)
                                
                                Text("Total")
                                    .font(.title3)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    
                    // Achievements List
                    VStack(spacing: 16) {
                        Text("All Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(achievements) { achievement in
                            AchievementCard(achievement: achievement)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Achievements")
        }
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: achievement.icon)
                .font(.title2)
                .foregroundColor(achievement.isUnlocked ? achievement.color : .gray)
                .frame(width: 40, height: 40)
                .background((achievement.isUnlocked ? achievement.color : .gray).opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.name)
                    .font(.headline)
                    .foregroundColor(achievement.isUnlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if !achievement.isUnlocked {
                    ProgressView(value: achievement.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: achievement.color))
                    
                    Text("\(Int(achievement.progress * 100))% Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Workout Sheet
struct WorkoutSheet: View {
    @Binding var workouts: [Workout]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: WorkoutType = .walking
    @State private var workoutName = ""
    @State private var duration: TimeInterval = 1800 // 30 minutes
    @State private var calories = 0
    @State private var distance: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                Section("Workout Details") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(WorkoutType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Workout Name", text: $workoutName)
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(duration/60)) minutes")
                    }
                    
                    Slider(value: $duration, in: 300...7200, step: 300)
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        TextField("Calories", value: $calories, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Distance (km)")
                        Spacer()
                        TextField("Distance", value: $distance, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(workoutName.isEmpty)
                }
            }
        }
    }
    
    private func saveWorkout() {
        let newWorkout = Workout(
            name: workoutName,
            type: selectedType,
            duration: duration,
            calories: calories,
            distance: distance > 0 ? distance : nil,
            heartRate: [Int.random(in: 120...160)],
            startTime: Date().addingTimeInterval(-duration),
            endTime: Date(),
            isActive: false
        )
        
        workouts.insert(newWorkout, at: 0)
        dismiss()
    }
}



