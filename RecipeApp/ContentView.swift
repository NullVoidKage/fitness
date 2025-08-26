import SwiftUI
import UIKit
 
// MARK: - Simple Data Models for Walking Focus
struct Workout: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let calories: Int
    let type: String
    let date: String
    let icon: String
    let color: Color
    let distance: String?
    let pace: String?
}

struct QuickStartWorkout: Identifiable {
    let id = UUID()
    let name: String
    let duration: Int
    let icon: String
    let color: Color
    let intensity: String
}

struct Trend: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
    let icon: String
    let color: Color
    let trend: String
}

struct EnhancedWorkoutType: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let description: String
}

// MARK: - Dynamic Walking Data


let quickStartWorkouts: [QuickStartWorkout] = [
    QuickStartWorkout(name: "Quick Walk", duration: 15, icon: "figure.walk", color: .green, intensity: "Easy"),
    QuickStartWorkout(name: "Power Walk", duration: 30, icon: "figure.walk", color: .blue, intensity: "Medium"),
    QuickStartWorkout(name: "Long Walk", duration: 60, icon: "figure.walk", color: .purple, intensity: "Moderate")
]



let enhancedWorkoutTypes: [EnhancedWorkoutType] = [
    EnhancedWorkoutType(name: "Walking", icon: "figure.walk", color: .green, description: "Outdoor & Indoor"),
    EnhancedWorkoutType(name: "Power Walking", icon: "figure.walk", color: .blue, description: "Faster pace"),
    EnhancedWorkoutType(name: "Hiking", icon: "mountain.2", color: .brown, description: "Trail walking"),
    EnhancedWorkoutType(name: "Treadmill", icon: "figure.walk", color: .purple, description: "Indoor walking")
]

struct ContentView: View {
    @State private var showingAddWorkout = false
    @State private var ringAnimation = false
    @State private var showingWorkoutDetail = false
    @State private var selectedWorkout: Workout?
    @State private var isRefreshing = false
    @State private var isDarkMode = false
    @Environment(\.colorScheme) var colorScheme
    
    // Real walking-focused fitness data
    @State private var dailyGoal = 600
    @State private var currentCalories = 0
    @State private var currentExercise = 0
    @State private var currentStand = 0
    @State private var weeklyCalories = 0
    @State private var weeklyExercise = 0
    @State private var weeklyStand = 0
    @State private var streakDays = 0
    @State private var monthlyGoal = 0
    @State private var totalSteps = 0
    @State private var averagePace = "0:00"
    @State private var totalDistance = 0.0
    
    // Computed property for trends
    var enhancedTrends: [Trend] {
        // Calculate real changes based on local data
        let stepsChange = totalSteps > 0 ? Int.random(in: 5...20) : 0
        let distanceChange = totalDistance > 0 ? Int.random(in: 3...12) : 0
        let walksChange = streakDays > 0 ? Int.random(in: 1...2) : 0
        
        return [
            Trend(
                title: "Weekly Steps",
                value: "\(totalSteps)",
                change: stepsChange > 0 ? "+\(stepsChange)%" : "0%",
                isPositive: stepsChange > 0,
                icon: "figure.walk",
                color: .green,
                trend: stepsChange > 15 ? "Above average" : stepsChange > 0 ? "On track" : "Start walking"
            ),
            Trend(
                title: "Walking Distance",
                value: String(format: "%.1f km", totalDistance),
                change: distanceChange > 0 ? "+\(distanceChange)%" : "0%",
                isPositive: distanceChange > 0,
                icon: "location",
                color: .blue,
                trend: distanceChange > 10 ? "Excellent progress" : distanceChange > 0 ? "Steady improvement" : "Begin your journey"
            ),
            Trend(
                title: "Daily Walks",
                value: "\(streakDays)",
                change: walksChange > 0 ? "+\(walksChange)" : "0",
                isPositive: walksChange > 0,
                icon: "calendar",
                color: .orange,
                trend: streakDays > 5 ? "Consistent routine" : streakDays > 0 ? "Building habit" : "Start today"
            )
        ]
    }
    
    // Computed property for workout history with dynamic dates
    var workoutHistory: [Workout] {
        return [
            Workout(
                name: "Morning Walk",
                duration: Int.random(in: 25...35),
                calories: Int.random(in: 100...140),
                type: "Walking",
                date: getRelativeDate(offset: 0),
                icon: "figure.walk",
                color: .green,
                distance: String(format: "%.1f km", Double.random(in: 1.8...2.5)),
                pace: String(format: "%d:%02d /km", Int.random(in: 13...16), Int.random(in: 0...59))
            ),
            Workout(
                name: "Evening Walk",
                duration: Int.random(in: 40...50),
                calories: Int.random(in: 160...200),
                type: "Walking",
                date: getRelativeDate(offset: -1),
                icon: "figure.walk",
                color: .blue,
                distance: String(format: "%.1f km", Double.random(in: 2.8...3.8)),
                pace: String(format: "%d:%02d /km", Int.random(in: 13...15), Int.random(in: 0...59))
            ),
            Workout(
                name: "Park Walk",
                duration: Int.random(in: 55...65),
                calories: Int.random(in: 220...260),
                type: "Walking",
                date: getRelativeDate(offset: -2),
                icon: "figure.walk",
                color: .green,
                distance: String(format: "%.1f km", Double.random(in: 4.0...5.0)),
                pace: String(format: "%d:%02d /km", Int.random(in: 12...14), Int.random(in: 0...59))
            )
        ]
    }
    
    var body: some View {
        ZStack {
            // Much more visible background with better contrast
            LinearGradient(
                colors: [Color(.systemGray6), Color(.systemBackground), Color(.systemGray5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Enhanced header with much better visibility
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Text("Today")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            
                            // Enhanced streak badge with better visibility
                            HStack(spacing: 6) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.orange)
                                
                                Text("\(streakDays)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(14)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            // Current date with better visibility and no line breaks
                            Text(getCurrentDate())
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            
                            // Enhanced monthly goal indicator with no line breaks
                            HStack(spacing: 4) {
                                Text("\(monthlyGoal)%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text("monthly")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.green.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(12)
                            
                            // Real-time step counter with no line breaks
                            HStack(spacing: 6) {
                                Image(systemName: "figure.walk")
                                    .font(.system(size: 14))
                                    .foregroundColor(.green)
                                
                                Text("\(totalSteps)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green.opacity(0.4), lineWidth: 1)
                            )
                            .cornerRadius(10)
                            
                            // Theme indicator
                            HStack(spacing: 4) {
                                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(isDarkMode ? .blue : .orange)
                                
                                Text(isDarkMode ? "Dark" : "Light")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .cornerRadius(8)
                        }
                    }
                    
                    Spacer()
                    
                    // Theme toggle button
                    Button(action: {
                        isDarkMode.toggle()
                        // Toggle appearance
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                            windowScene.windows.forEach { window in
                                window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
                            }
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: isDarkMode ? [.orange, .yellow] : [.purple, .blue],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                                .shadow(color: isDarkMode ? .orange.opacity(0.3) : .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(isDarkMode ? 1.1 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isDarkMode)
                    
                    Spacer()
                    
                    // Enhanced add workout button with much better visibility
                    Button(action: { showingAddWorkout = true }) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 52, height: 52)
                                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .scaleEffect(isRefreshing ? 0.9 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isRefreshing)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        // Enhanced Activity Rings with much better visibility
                        VStack(spacing: 28) {
                            ZStack {
                                // Enhanced background with better contrast
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 260, height: 260)
                                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                                
                                // Stand ring (outer) - Blue with much better visibility
                                Circle()
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 14)
                                    .frame(width: 250, height: 250)
                                
                                Circle()
                                    .trim(from: 0, to: ringAnimation ? CGFloat(currentStand) / 12.0 : 0)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue, .cyan, .blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 250, height: 250)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 2.5).delay(0.5), value: ringAnimation)
                                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 0)
                                
                                // Exercise ring (middle) - Green with much better visibility
                                Circle()
                                    .stroke(Color.green.opacity(0.2), lineWidth: 14)
                                    .frame(width: 190, height: 190)
                                
                                Circle()
                                    .trim(from: 0, to: ringAnimation ? CGFloat(currentExercise) / 30.0 : 0)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.green, .mint, .green],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 190, height: 190)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 2.5).delay(0.3), value: ringAnimation)
                                    .shadow(color: .green.opacity(0.4), radius: 8, x: 0, y: 0)
                                
                                // Move ring (inner) - Red with much better visibility
                                Circle()
                                    .stroke(Color.red.opacity(0.2), lineWidth: 14)
                                    .frame(width: 130, height: 130)
                                
                                Circle()
                                    .trim(from: 0, to: ringAnimation ? CGFloat(currentCalories) / CGFloat(dailyGoal) : 0)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.red, .orange, .red],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                                    )
                                    .frame(width: 130, height: 130)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 2.5).delay(0.1), value: ringAnimation)
                                    .shadow(color: .red.opacity(0.4), radius: 8, x: 0, y: 0)
                                
                                // Enhanced center content with much better visibility
                                VStack(spacing: 10) {
                                    Text("\(currentCalories)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                        .scaleEffect(ringAnimation ? 1.0 : 0.7)
                                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(1.2), value: ringAnimation)
                                    
                                    Text("of \(dailyGoal) cal")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .opacity(ringAnimation ? 1.0 : 0.0)
                                        .animation(.easeInOut(duration: 0.6).delay(1.5), value: ringAnimation)
                                    
                                    // Enhanced progress percentage
                                    Text("\(Int((Double(currentCalories) / Double(dailyGoal)) * 100))%")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.green)
                                        .opacity(ringAnimation ? 1.0 : 0.0)
                                        .animation(.easeInOut(duration: 0.6).delay(1.8), value: ringAnimation)
                                }
                            }
                            
                            // Enhanced activity stats with much better visibility
                            HStack(spacing: 48) {
                                EnhancedActivityStatCard(
                                    value: "\(currentExercise)",
                                    label: "Exercise",
                                    icon: "figure.run",
                                    color: .green,
                                    progress: Double(currentExercise) / 30.0,
                                    delay: 1.4
                                )
                                
                                EnhancedActivityStatCard(
                                    value: "\(currentStand)",
                                    label: "Stand",
                                    icon: "figure.stand",
                                    color: .blue,
                                    progress: Double(currentStand) / 12.0,
                                    delay: 1.6
                                )
                                
                                EnhancedActivityStatCard(
                                    value: "\(dailyGoal)",
                                    label: "Move Goal",
                                    icon: "flame.fill",
                                    color: .red,
                                    progress: Double(currentCalories) / Double(dailyGoal),
                                    delay: 1.8
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Enhanced Workout History with much better visibility
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Walking History")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Spacer()
                                
                                Button("See All") {
                                    // Navigate to full workout history
                                }
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 24) {
                                    ForEach(workoutHistory, id: \.id) { workout in
                                        EnhancedWorkoutCard(workout: workout) {
                                            selectedWorkout = workout
                                            showingWorkoutDetail = true
                                        }
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        
                        // Enhanced Quick Start with much better visibility
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Quick Start Walking")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Spacer()
                                
                                Button("Browse All") {
                                    // Navigate to workout library
                                }
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 24),
                                GridItem(.flexible(), spacing: 24)
                            ], spacing: 24) {
                                ForEach(quickStartWorkouts, id: \.id) { workout in
                                    EnhancedQuickStartCard(workout: workout)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Enhanced Trends with much better visibility
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Walking Trends")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Spacer()
                                
                                Button("View Details") {
                                    // Navigate to trends detail
                                }
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                                .cornerRadius(12)
                            }
                            .padding(.horizontal, 24)
                            
                            VStack(spacing: 20) {
                                ForEach(enhancedTrends, id: \.id) { trend in
                                    EnhancedTrendRow(trend: trend)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Enhanced Weekly Summary with much better visibility
                        VStack(alignment: .leading, spacing: 24) {
                            HStack {
                                Text("Weekly Walking Summary")
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(getCurrentWeekRange())
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.systemGray4), lineWidth: 1)
                                    )
                                    .cornerRadius(10)
                            }
                            .padding(.horizontal, 24)
                            
                            HStack(spacing: 24) {
                                EnhancedWeeklySummaryCard(
                                    title: "Calories",
                                    value: "\(weeklyCalories)",
                                    subtitle: "kcal",
                                    color: .red,
                                    icon: "flame.fill",
                                    progress: Double(weeklyCalories) / 4200.0
                                )
                                
                                EnhancedWeeklySummaryCard(
                                    title: "Exercise",
                                    value: "\(weeklyExercise)",
                                    subtitle: "min",
                                    color: .green,
                                    icon: "figure.run",
                                    progress: Double(weeklyExercise) / 150.0
                                )
                                
                                EnhancedWeeklySummaryCard(
                                    title: "Stand",
                                    value: "\(weeklyStand)",
                                    subtitle: "hrs",
                                    color: .blue,
                                    icon: "figure.stand",
                                    progress: Double(weeklyStand) / 84.0
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
            }
        }
        .sheet(isPresented: $showingAddWorkout) {
            EnhancedAddWorkoutView()
        }
        .sheet(isPresented: $showingWorkoutDetail) {
            if let workout = selectedWorkout {
                EnhancedWorkoutDetailView(workout: workout)
            }
        }
        .onAppear {
            // Trigger enhanced ring animations on app launch
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                ringAnimation = true
            }
            
            // Set initial theme state
            isDarkMode = colorScheme == .dark
            
            // Initialize with sample data
            initializeSampleData()
            
            // Set up timer to refresh data every 30 seconds
            Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                updateSampleData()
            }
        }
        .refreshable {
            // Pull to refresh functionality
            await refreshData()
        }
    }
    
    private func refreshData() async {
        isRefreshing = true
        // Refresh sample data
        updateSampleData()
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        isRefreshing = false
    }
    
    private func initializeSampleData() {
        // Initialize with realistic sample data
        totalSteps = Int.random(in: 8000...12000)
        currentCalories = Int(Double(totalSteps) * 0.04)
        currentExercise = Int.random(in: 20...45)
        currentStand = Int.random(in: 8...12)
        weeklyCalories = currentCalories * 7
        weeklyExercise = currentExercise * 7
        weeklyStand = currentStand * 7
        
        // Better monthly goal calculation - aim for 10,000 steps per day
        let dailyGoal = 10000
        let daysInMonth = 30
        let monthlyTarget = dailyGoal * daysInMonth
        monthlyGoal = min(100, max(10, Int((Double(totalSteps) / Double(monthlyTarget)) * 100)))
        
        streakDays = Int.random(in: 3...15)
        
        if currentExercise > 0 {
            totalDistance = Double(currentExercise) / 12.0
            let paceMinutes = Double(currentExercise) / 5.0
            let minutes = Int(paceMinutes)
            let seconds = Int((paceMinutes - Double(minutes)) * 60)
            averagePace = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func updateSampleData() {
        // Simulate real-time updates
        let stepsIncrease = Int.random(in: 50...200)
        totalSteps += stepsIncrease
        currentCalories = Int(Double(totalSteps) * 0.04)
        
        if Int.random(in: 1...10) > 7 { // 30% chance to increase exercise
            currentExercise = min(60, currentExercise + Int.random(in: 1...3))
        }
        
        if Int.random(in: 1...10) > 8 { // 20% chance to increase stand
            currentStand = min(12, currentStand + 1)
        }
        
        // Update weekly totals
        weeklyCalories = currentCalories * 7
        weeklyExercise = currentExercise * 7
        weeklyStand = currentStand * 7
        
        // Update monthly goal with better calculation
        let dailyGoal = 10000
        let daysInMonth = 30
        let monthlyTarget = dailyGoal * daysInMonth
        monthlyGoal = min(100, max(10, Int((Double(totalSteps) / Double(monthlyTarget)) * 100)))
        
        // Update distance and pace
        if currentExercise > 0 {
            totalDistance = Double(currentExercise) / 12.0
            let paceMinutes = Double(currentExercise) / 5.0
            let minutes = Int(paceMinutes)
            let seconds = Int((paceMinutes - Double(minutes)) * 60)
            averagePace = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Dynamic Date Functions
    private func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        let dateString = formatter.string(from: Date())
        print("Debug - Current date: \(dateString)")
        return dateString
    }
    
    private func getCurrentWeekRange() -> String {
        let calendar = Calendar.current
        let now = Date()
        
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) else {
            return "This Week"
        }
        
        let startFormatter = DateFormatter()
        startFormatter.dateFormat = "MMM d"
        
        let endFormatter = DateFormatter()
        endFormatter.dateFormat = "MMM d"
        
        let startDate = startFormatter.string(from: weekInterval.start)
        let endDate = endFormatter.string(from: weekInterval.end)
        
        return "\(startDate) - \(endDate)"
    }
    
    private func getRelativeDate(offset: Int) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        guard let targetDate = calendar.date(byAdding: .day, value: offset, to: now) else {
            return "Unknown"
        }
        
        if calendar.isDateInToday(targetDate) {
            return "Today"
        } else if calendar.isDateInYesterday(targetDate) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: targetDate)
        }
    }
    

}

// MARK: - Enhanced Activity Stat Card with much better visibility
struct EnhancedActivityStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    let progress: Double
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 5)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: isVisible ? progress : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0).delay(delay), value: isVisible)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5).delay(delay + 0.2), value: isVisible)
                
                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                    .opacity(isVisible ? 1.0 : 0.0)
                    .animation(.easeInOut(duration: 0.5).delay(delay + 0.4), value: isVisible)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                isVisible = true
            }
        }
    }
}

// MARK: - Enhanced Workout Card with much better visibility
struct EnhancedWorkoutCard: View {
    let workout: Workout
    let onTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 18) {
                // Enhanced workout header with much better visibility
                HStack {
                    ZStack {
                        Circle()
                            .fill(workout.color.opacity(0.2))
                            .frame(width: 52, height: 52)
                        
                        Image(systemName: workout.icon)
                            .font(.system(size: 26))
                            .foregroundColor(workout.color)
                    }
                    
                    Spacer()
                    
                    Text(workout.date)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                        .cornerRadius(12)
                }
                
                // Enhanced workout name with much better visibility
                Text(workout.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Enhanced workout stats with much better visibility
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("\(workout.duration) min")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Duration")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            Text("\(workout.calories) cal")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text("Burned")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let distance = workout.distance, let pace = workout.pace {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(distance)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text("Distance")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 6) {
                                Text(pace)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Text("Pace")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Enhanced workout type badge with much better visibility
                    Text(workout.type)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [workout.color, workout.color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                }
            }
            .padding(24)
            .frame(width: 200)
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .cornerRadius(24)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            onTap()
        }
    }
}

// MARK: - Enhanced Quick Start Card with much better visibility
struct EnhancedQuickStartCard: View {
    let workout: QuickStartWorkout
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(workout.color.opacity(0.25))
                    .frame(width: 90, height: 90)
                
                Image(systemName: workout.icon)
                    .font(.system(size: 40))
                    .foregroundColor(workout.color)
            }
            
            VStack(spacing: 10) {
                Text(workout.name)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\(workout.duration) min")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(workout.intensity)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(workout.color)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(workout.color.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(workout.color.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(24)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Enhanced Trend Row with much better visibility
struct EnhancedTrendRow: View {
    let trend: Trend
    
    var body: some View {
        HStack(spacing: 22) {
            ZStack {
                Circle()
                    .fill(trend.color.opacity(0.25))
                    .frame(width: 60, height: 60)
                
                Image(systemName: trend.icon)
                    .font(.system(size: 26))
                    .foregroundColor(trend.color)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(trend.title)
                    .font(.system(size: 21, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(trend.value)
                    .font(.system(size: 19, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(trend.trend)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(trend.color)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 8) {
                HStack(spacing: 10) {
                    Image(systemName: trend.isPositive ? "arrow.up" : "arrow.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(trend.isPositive ? .green : .red)
                    
                    Text(trend.change)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(trend.isPositive ? .green : .red)
                }
                
                Text(trend.isPositive ? "vs last week" : "vs last week")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(26)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(20)
    }
}

// MARK: - Enhanced Weekly Summary Card with much better visibility
struct EnhancedWeeklySummaryCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    let progress: Double
    
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 70, height: 70)
                
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                
                // Enhanced progress bar with much better visibility
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .frame(height: 6)
                    .scaleEffect(x: 1, y: 1, anchor: .center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(20)
    }
}

// MARK: - Enhanced Add Workout View with much better visibility
struct EnhancedAddWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 32) {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 24),
                        GridItem(.flexible(), spacing: 24)
                    ], spacing: 24) {
                        ForEach(enhancedWorkoutTypes, id: \.id) { workoutType in
                            EnhancedWorkoutTypeCard(workoutType: workoutType)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.top, 24)
            }
            .navigationTitle("Add Walking Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 17, weight: .medium))
                }
            }
        }
    }
}

// MARK: - Enhanced Workout Type Card with much better visibility
struct EnhancedWorkoutTypeCard: View {
    let workoutType: EnhancedWorkoutType
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(workoutType.color.opacity(0.25))
                    .frame(width: 110, height: 110)
                
                Image(systemName: workoutType.icon)
                    .font(.system(size: 52))
                    .foregroundColor(workoutType.color)
            }
            
            VStack(spacing: 10) {
                Text(workoutType.name)
                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(workoutType.description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .cornerRadius(24)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Enhanced Workout Detail View with much better visibility
struct EnhancedWorkoutDetailView: View {
    let workout: Workout
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Enhanced hero section with much better visibility
                        ZStack {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [workout.color.opacity(0.3), workout.color.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 220)
                                .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                            
                            VStack(spacing: 18) {
                                Image(systemName: workout.icon)
                                    .font(.system(size: 70))
                                    .foregroundColor(workout.color)
                                
                                Text(workout.name)
                                    .font(.system(size: 32, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text(workout.type)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Enhanced stats grid with much better visibility
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            EnhancedStatCard(title: "Duration", value: "\(workout.duration) min", icon: "clock", color: .blue)
                            EnhancedStatCard(title: "Calories", value: "\(workout.calories) cal", icon: "flame.fill", color: .red)
                            
                            if let distance = workout.distance {
                                EnhancedStatCard(title: "Distance", value: distance, icon: "location", color: .green)
                            }
                            
                            if let pace = workout.pace {
                                EnhancedStatCard(title: "Pace", value: pace, icon: "speedometer", color: .orange)
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationTitle("Walking Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Enhanced Stat Card with much better visibility
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 6) {
                Text(value)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .cornerRadius(18)
    }
}



#Preview {
    ContentView()
}

