import SwiftUI
import HealthKit
import CloudKit
import Combine

// MARK: - Weekly Health Digest Model
struct WeeklyHealthDigest {
    let totalFamilySteps: Int
    let totalFamilyCalories: Int
    let totalFamilyDistance: Double
    let averageFamilyHeartRate: Int
    let totalFamilySleep: Double
    let mostActiveMember: String
    let mostStepsInDay: Int
    let bestDay: String
    
    static func generate(from familyMembers: [FamilyMember]) -> WeeklyHealthDigest {
        let totalSteps = familyMembers.reduce(0) { $0 + $1.weeklySteps }
        let totalCalories = familyMembers.reduce(0) { $0 + $1.weeklyCalories }
        let totalDistance = familyMembers.reduce(0.0) { $0 + $1.weeklyDistance }
        let totalHeartRate = familyMembers.reduce(0) { $0 + $1.todayHeartRate }
        let averageHeartRate = familyMembers.isEmpty ? 0 : totalHeartRate / familyMembers.count
        let totalSleep = familyMembers.reduce(0.0) { $0 + $1.todaySleep }
        
        let mostActiveMember = familyMembers.max(by: { $0.weeklySteps < $1.weeklySteps })?.name ?? "No one"
        let mostStepsInDay = familyMembers.max(by: { $0.todaySteps < $1.todaySteps })?.todaySteps ?? 0
        let bestDay = "Today" // Simplified for now
        
        return WeeklyHealthDigest(
            totalFamilySteps: totalSteps,
            totalFamilyCalories: totalCalories,
            totalFamilyDistance: totalDistance,
            averageFamilyHeartRate: averageHeartRate,
            totalFamilySleep: totalSleep,
            mostActiveMember: mostActiveMember,
            mostStepsInDay: mostStepsInDay,
            bestDay: bestDay
        )
    }
}

// MARK: - Enhanced Health Data Models
struct HealthMetrics: Codable {
    // Basic metrics
    var steps: Int = 0
    var heartRate: Int = 0
    var calories: Int = 0
    var distance: Double = 0.0
    var sleep: Double = 0.0
    
    // Enhanced metrics
    var bloodPressureSystolic: Int = 0
    var bloodPressureDiastolic: Int = 0
    var weight: Double = 0.0
    var bmi: Double = 0.0
    var bodyFatPercentage: Double = 0.0
    var vo2Max: Double = 0.0
    
    // Workout metrics
    var workoutMinutes: Int = 0
    var activeCalories: Int = 0
    var exerciseMinutes: Int = 0
    var standHours: Int = 0
    
    // Nutrition metrics
    var waterIntake: Double = 0.0 // in liters
    var calorieIntake: Int = 0
    var protein: Double = 0.0 // in grams
    var carbs: Double = 0.0 // in grams
    var fat: Double = 0.0 // in grams
    
    // Mental health metrics
    var moodScore: Int = 5 // 1-10 scale
    var stressLevel: Int = 5 // 1-10 scale
    var meditationMinutes: Int = 0
    var mindfulnessScore: Int = 5 // 1-10 scale
    
    // Calculated properties
    var bloodPressureCategory: String {
        if bloodPressureSystolic == 0 || bloodPressureDiastolic == 0 {
            return "Not measured"
        } else if bloodPressureSystolic < 120 && bloodPressureDiastolic < 80 {
            return "Normal"
        } else if bloodPressureSystolic < 130 && bloodPressureDiastolic < 80 {
            return "Elevated"
        } else if bloodPressureSystolic < 140 || bloodPressureDiastolic < 90 {
            return "High Stage 1"
        } else {
            return "High Stage 2"
        }
    }
    
    var bmiCategory: String {
        if bmi == 0 {
            return "Not calculated"
        } else if bmi < 18.5 {
            return "Underweight"
        } else if bmi < 25 {
            return "Normal"
        } else if bmi < 30 {
            return "Overweight"
        } else {
            return "Obese"
        }
    }
    
    var overallHealthScore: Int {
        var score = 0
        
        // Steps (0-25 points)
        if steps >= 10000 { score += 25 }
        else if steps >= 7500 { score += 20 }
        else if steps >= 5000 { score += 15 }
        else if steps >= 2500 { score += 10 }
        else { score += 5 }
        
        // Heart rate (0-15 points)
        if heartRate >= 60 && heartRate <= 100 { score += 15 }
        else if heartRate >= 50 && heartRate <= 110 { score += 10 }
        else { score += 5 }
        
        // Sleep (0-20 points)
        if sleep >= 7 && sleep <= 9 { score += 20 }
        else if sleep >= 6 && sleep <= 10 { score += 15 }
        else if sleep >= 5 { score += 10 }
        else { score += 5 }
        
        // Workout (0-15 points)
        if workoutMinutes >= 30 { score += 15 }
        else if workoutMinutes >= 15 { score += 10 }
        else if workoutMinutes > 0 { score += 5 }
        
        // Mood (0-15 points)
        if moodScore >= 8 { score += 15 }
        else if moodScore >= 6 { score += 10 }
        else if moodScore >= 4 { score += 5 }
        
        // Water intake (0-10 points)
        if waterIntake >= 2.5 { score += 10 }
        else if waterIntake >= 2.0 { score += 8 }
        else if waterIntake >= 1.5 { score += 5 }
        else { score += 2 }
        
        return min(score, 100)
    }
}

struct WorkoutData: Codable, Identifiable {
    let id = UUID()
    let type: String
    let duration: Int // in minutes
    let calories: Int
    let date: Date
    let intensity: String // Low, Moderate, High
    let heartRateAvg: Int
    let heartRateMax: Int
}

struct NutritionData: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let water: Double
    let meals: [MealData]
}

struct MealData: Codable, Identifiable {
    let id = UUID()
    let name: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let time: Date
}

struct MentalHealthData: Codable, Identifiable {
    let id = UUID()
    let date: Date
    let moodScore: Int
    let stressLevel: Int
    let meditationMinutes: Int
    let mindfulnessScore: Int
    let notes: String
}

struct HealthGoals: Codable {
    var dailySteps: Int = 10000
    var dailyCalories: Int = 2000
    var dailyWater: Double = 2.5
    var weeklyWorkouts: Int = 3
    var dailySleep: Double = 8.0
    var targetWeight: Double = 0.0
    var targetBMI: Double = 22.0
}

struct UserPreferences: Codable {
    var shareHealthData: Bool = true
    var shareAchievements: Bool = true
    var shareLocation: Bool = false
    var allowInvites: Bool = true
    var theme: String = "system" // light, dark, system
    var units: String = "metric" // metric, imperial
    var language: String = "en"
}

struct NotificationSettings: Codable {
    var achievementNotifications: Bool = true
    var goalReminders: Bool = true
    var familyUpdates: Bool = true
    var workoutReminders: Bool = true
    var mealReminders: Bool = false
    var meditationReminders: Bool = false
    var quietHours: Bool = true
    var quietStart: String = "22:00"
    var quietEnd: String = "08:00"
}

// MARK: - Smart Notifications System
struct SmartNotification: Identifiable, Codable {
    let id = UUID()
    let type: NotificationType
    let title: String
    let message: String
    let memberName: String
    let timestamp: Date
    let isRead: Bool
    let priority: NotificationPriority
    let actionType: NotificationAction?
    
    enum NotificationType: String, Codable, CaseIterable {
        case achievement = "achievement"
        case goalReminder = "goal_reminder"
        case familyUpdate = "family_update"
        case workoutReminder = "workout_reminder"
        case mealReminder = "meal_reminder"
        case meditationReminder = "meditation_reminder"
        case challenge = "challenge"
        case milestone = "milestone"
        case encouragement = "encouragement"
        case healthAlert = "health_alert"
    }
    
    enum NotificationPriority: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case urgent = "urgent"
    }
    
    enum NotificationAction: String, Codable {
        case viewProfile = "view_profile"
        case joinChallenge = "join_challenge"
        case logWorkout = "log_workout"
        case logMeal = "log_meal"
        case startMeditation = "start_meditation"
        case viewAchievement = "view_achievement"
        case shareUpdate = "share_update"
        case viewGoals = "view_goals"
        case viewFamily = "view_family"
    }
}

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var notifications: [SmartNotification] = []
    @Published var unreadCount: Int = 0
    
    private var notificationTimer: Timer?
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadNotifications()
        generateSampleNotifications()
        startSmartNotificationScheduler()
    }
    
    func addNotification(_ notification: SmartNotification) {
        notifications.insert(notification, at: 0)
        updateUnreadCount()
        saveNotifications()
        
        // Send local notification if app is in background
        scheduleLocalNotification(notification)
    }
    
    func markAsRead(_ notification: SmartNotification) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index] = SmartNotification(
                type: notification.type,
                title: notification.title,
                message: notification.message,
                memberName: notification.memberName,
                timestamp: notification.timestamp,
                isRead: true,
                priority: notification.priority,
                actionType: notification.actionType
            )
            updateUnreadCount()
            saveNotifications()
        }
    }
    
    func markAllAsRead() {
        for i in 0..<notifications.count {
            notifications[i] = SmartNotification(
                type: notifications[i].type,
                title: notifications[i].title,
                message: notifications[i].message,
                memberName: notifications[i].memberName,
                timestamp: notifications[i].timestamp,
                isRead: true,
                priority: notifications[i].priority,
                actionType: notifications[i].actionType
            )
        }
        updateUnreadCount()
        saveNotifications()
    }
    
    func clearOldNotifications() {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        notifications = notifications.filter { $0.timestamp > cutoffDate }
        updateUnreadCount()
        saveNotifications()
    }
    
    private func updateUnreadCount() {
        unreadCount = notifications.filter { !$0.isRead }.count
    }
    
    private func startSmartNotificationScheduler() {
        notificationTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.generateSmartNotifications()
        }
    }
    
    private func generateSmartNotifications() {
        // Generate contextual notifications based on time, user behavior, and family activity
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        // Morning motivation (7-9 AM)
        if currentHour >= 7 && currentHour <= 9 {
            generateMorningMotivation()
        }
        
        // Afternoon check-in (2-4 PM)
        if currentHour >= 14 && currentHour <= 16 {
            generateAfternoonCheckIn()
        }
        
        // Evening reflection (8-10 PM)
        if currentHour >= 20 && currentHour <= 22 {
            generateEveningReflection()
        }
        
        // Weekend challenges
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        if weekday == 1 || weekday == 7 { // Sunday or Saturday
            generateWeekendChallenges()
        }
    }
    
    private func generateMorningMotivation() {
        let motivationalMessages = [
            "Good morning! Ready to crush your health goals today? 🌅",
            "Start your day with a healthy breakfast and some movement! 💪",
            "Your family is counting on you to stay active today! 👨‍👩‍👧‍👦",
            "Time to log your morning workout and inspire the family! 🏃‍♀️"
        ]
        
        if let message = motivationalMessages.randomElement() {
            let notification = SmartNotification(
                type: .encouragement,
                title: "Morning Motivation",
                message: message,
                memberName: "System",
                timestamp: Date(),
                isRead: false,
                priority: .medium,
                actionType: .logWorkout
            )
            addNotification(notification)
        }
    }
    
    private func generateAfternoonCheckIn() {
        let checkInMessages = [
            "How's your day going? Don't forget to stay hydrated! 💧",
            "Time for a quick walk or stretch break! 🚶‍♀️",
            "Your family is cheering you on! Keep up the great work! 👏",
            "Halfway through the day - how are your goals looking? 📊"
        ]
        
        if let message = checkInMessages.randomElement() {
            let notification = SmartNotification(
                type: .goalReminder,
                title: "Afternoon Check-in",
                message: message,
                memberName: "System",
                timestamp: Date(),
                isRead: false,
                priority: .low,
                actionType: nil
            )
            addNotification(notification)
        }
    }
    
    private func generateEveningReflection() {
        let reflectionMessages = [
            "Great job today! Time to log your evening activities 📝",
            "How did you do with your health goals today? 🎯",
            "Your family would love to see your progress! Share an update 📱",
            "Don't forget to log your meals and prepare for tomorrow! 🍽️"
        ]
        
        if let message = reflectionMessages.randomElement() {
            let notification = SmartNotification(
                type: .encouragement,
                title: "Evening Reflection",
                message: message,
                memberName: "System",
                timestamp: Date(),
                isRead: false,
                priority: .medium,
                actionType: .shareUpdate
            )
            addNotification(notification)
        }
    }
    
    private func generateWeekendChallenges() {
        let challengeMessages = [
            "Weekend family challenge: Who can get the most steps today? 🏆",
            "Perfect weather for a family walk or bike ride! 🚴‍♀️",
            "Weekend wellness: Try a new healthy recipe together! 👨‍🍳",
            "Family fitness time! Let's all get moving together! 💪"
        ]
        
        if let message = challengeMessages.randomElement() {
            let notification = SmartNotification(
                type: .challenge,
                title: "Weekend Challenge",
                message: message,
                memberName: "System",
                timestamp: Date(),
                isRead: false,
                priority: .high,
                actionType: .joinChallenge
            )
            addNotification(notification)
        }
    }
    
    private func scheduleLocalNotification(_ notification: SmartNotification) {
        // This would integrate with UNUserNotificationCenter for actual push notifications
        // For now, we'll just store them locally
    }
    
    private func saveNotifications() {
        if let data = try? JSONEncoder().encode(notifications) {
            userDefaults.set(data, forKey: "smart_notifications")
        }
    }
    
    private func loadNotifications() {
        if let data = userDefaults.data(forKey: "smart_notifications"),
           let loadedNotifications = try? JSONDecoder().decode([SmartNotification].self, from: data) {
            notifications = loadedNotifications
            updateUnreadCount()
        }
    }
    
    private func generateSampleNotifications() {
        // Add some sample notifications for testing
        let sampleNotifications = [
            SmartNotification(
                type: .achievement,
                title: "Great Job! 🎉",
                message: "You've completed your daily step goal for 3 days in a row!",
                memberName: "John Doe",
                timestamp: Date().addingTimeInterval(-3600), // 1 hour ago
                isRead: false,
                priority: .high,
                actionType: .viewAchievement
            ),
            SmartNotification(
                type: .goalReminder,
                title: "Daily Goal Reminder",
                message: "You're 2,000 steps away from your daily goal. Keep going! 💪",
                memberName: "System",
                timestamp: Date().addingTimeInterval(-1800), // 30 minutes ago
                isRead: false,
                priority: .medium,
                actionType: .viewGoals
            ),
            SmartNotification(
                type: .familyUpdate,
                title: "Family Activity Update",
                message: "Sarah just completed a 5K run! 🏃‍♀️",
                memberName: "Sarah Doe",
                timestamp: Date().addingTimeInterval(-900), // 15 minutes ago
                isRead: false,
                priority: .low,
                actionType: .viewFamily
            ),
            SmartNotification(
                type: .challenge,
                title: "New Challenge Available",
                message: "Join the '10K Steps Daily' family challenge!",
                memberName: "System",
                timestamp: Date().addingTimeInterval(-300), // 5 minutes ago
                isRead: false,
                priority: .high,
                actionType: .joinChallenge
            )
        ]
        
        for notification in sampleNotifications {
            notifications.append(notification)
        }
        updateUnreadCount()
    }
}

// MARK: - Family Challenges System
struct FamilyChallenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let type: ChallengeType
    let duration: Int // in days
    let startDate: Date
    let endDate: Date
    let target: Int
    let unit: String
    let reward: String
    let isActive: Bool
    var participants: [String] // Family member names
    var progress: [String: Int] // Member name -> progress value
    let leaderboard: [ChallengeParticipant]
    
    enum ChallengeType: String, Codable, CaseIterable {
        case steps = "steps"
        case calories = "calories"
        case workouts = "workouts"
        case water = "water"
        case sleep = "sleep"
        case meditation = "meditation"
        case familyTime = "family_time"
        case healthyMeals = "healthy_meals"
    }
    
    var isCompleted: Bool {
        return Date() > endDate
    }
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: Date(), to: endDate)
        return max(0, components.day ?? 0)
    }
    
    var totalProgress: Int {
        return progress.values.reduce(0, +)
    }
    
    var completionPercentage: Double {
        guard target > 0 else { return 0 }
        return min(100.0, Double(totalProgress) / Double(target) * 100.0)
    }
}

struct ChallengeParticipant: Identifiable, Codable {
    let id = UUID()
    let name: String
    let progress: Int
    let rank: Int
    let avatar: String
    let isCurrentUser: Bool
}

class ChallengeManager: ObservableObject {
    static let shared = ChallengeManager()
    
    @Published var activeChallenges: [FamilyChallenge] = []
    @Published var completedChallenges: [FamilyChallenge] = []
    @Published var availableChallenges: [FamilyChallenge] = []
    
    private init() {
        loadChallenges()
        generateSampleChallenges()
    }
    
    func createChallenge(_ challenge: FamilyChallenge) {
        activeChallenges.append(challenge)
        saveChallenges()
        
        // Notify family members
        NotificationManager.shared.addNotification(SmartNotification(
            type: .challenge,
            title: "New Family Challenge!",
            message: "\(challenge.title) - Join now and compete with your family!",
            memberName: "System",
            timestamp: Date(),
            isRead: false,
            priority: .high,
            actionType: .joinChallenge
        ))
    }
    
    func joinChallenge(_ challengeId: UUID, memberName: String) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challengeId }) {
            var challenge = activeChallenges[index]
            if !challenge.participants.contains(memberName) {
                challenge.participants.append(memberName)
                challenge.progress[memberName] = 0
                activeChallenges[index] = challenge
                saveChallenges()
            }
        }
    }
    
    func updateProgress(_ challengeId: UUID, memberName: String, progress: Int) {
        if let index = activeChallenges.firstIndex(where: { $0.id == challengeId }) {
            var challenge = activeChallenges[index]
            challenge.progress[memberName] = progress
            activeChallenges[index] = challenge
            saveChallenges()
            
            // Check if challenge is completed
            if challenge.completionPercentage >= 100 {
                completeChallenge(challenge)
            }
        }
    }
    
    private func completeChallenge(_ challenge: FamilyChallenge) {
        // Move to completed challenges
        completedChallenges.append(challenge)
        activeChallenges.removeAll { $0.id == challenge.id }
        
        // Notify family
        NotificationManager.shared.addNotification(SmartNotification(
            type: .achievement,
            title: "Challenge Completed! 🎉",
            message: "Your family completed '\(challenge.title)'! Great job everyone!",
            memberName: "System",
            timestamp: Date(),
            isRead: false,
            priority: .high,
            actionType: .viewAchievement
        ))
        
        saveChallenges()
    }
    
    private func generateSampleChallenges() {
        if activeChallenges.isEmpty {
            let sampleChallenges = [
                FamilyChallenge(
                    title: "10K Steps Daily",
                    description: "Everyone aims for 10,000 steps each day for a week",
                    type: .steps,
                    duration: 7,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                    target: 70000, // 10K * 7 days
                    unit: "steps",
                    reward: "Family movie night",
                    isActive: true,
                    participants: [],
                    progress: [:],
                    leaderboard: []
                ),
                FamilyChallenge(
                    title: "Hydration Heroes",
                    description: "Drink 8 glasses of water daily",
                    type: .water,
                    duration: 5,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date(),
                    target: 40, // 8 glasses * 5 days
                    unit: "glasses",
                    reward: "New water bottles for everyone",
                    isActive: true,
                    participants: [],
                    progress: [:],
                    leaderboard: []
                ),
                FamilyChallenge(
                    title: "Sleep Champions",
                    description: "Get 8 hours of sleep every night",
                    type: .sleep,
                    duration: 10,
                    startDate: Date(),
                    endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
                    target: 80, // 8 hours * 10 days
                    unit: "hours",
                    reward: "Sleep-in weekend",
                    isActive: true,
                    participants: [],
                    progress: [:],
                    leaderboard: []
                )
            ]
            
            activeChallenges = sampleChallenges
            saveChallenges()
        }
    }
    
    private func saveChallenges() {
        let encoder = JSONEncoder()
        if let activeData = try? encoder.encode(activeChallenges),
           let completedData = try? encoder.encode(completedChallenges) {
            UserDefaults.standard.set(activeData, forKey: "active_challenges")
            UserDefaults.standard.set(completedData, forKey: "completed_challenges")
        }
    }
    
    private func loadChallenges() {
        let decoder = JSONDecoder()
        if let activeData = UserDefaults.standard.data(forKey: "active_challenges"),
           let active = try? decoder.decode([FamilyChallenge].self, from: activeData) {
            activeChallenges = active
        }
        if let completedData = UserDefaults.standard.data(forKey: "completed_challenges"),
           let completed = try? decoder.decode([FamilyChallenge].self, from: completedData) {
            completedChallenges = completed
        }
    }
}

// MARK: - Advanced Analytics System
struct HealthAnalytics: Codable {
    let memberId: UUID
    let period: AnalyticsPeriod
    let startDate: Date
    let endDate: Date
    let metrics: AnalyticsMetrics
    let trends: [TrendData]
    let insights: [HealthInsight]
    let recommendations: [HealthRecommendation]
    
    enum AnalyticsPeriod: String, Codable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
        case yearly = "yearly"
    }
}

struct AnalyticsMetrics: Codable {
    var averageSteps: Double = 0
    var averageHeartRate: Double = 0
    var averageCalories: Double = 0
    var averageDistance: Double = 0
    var averageSleep: Double = 0
    var averageWorkoutMinutes: Double = 0
    var averageWaterIntake: Double = 0
    var averageMoodScore: Double = 0
    var averageStressLevel: Double = 0
    
    var consistencyScore: Double = 0 // 0-100
    var improvementRate: Double = 0 // percentage change
    var goalAchievementRate: Double = 0 // percentage of goals met
    var healthScore: Double = 0 // overall health score
}

struct HealthInsight: Identifiable, Codable {
    let id = UUID()
    let type: InsightType
    let title: String
    let description: String
    let impact: InsightImpact
    let actionable: Bool
    let category: InsightCategory
    
    enum InsightType: String, Codable {
        case positive = "positive"
        case warning = "warning"
        case improvement = "improvement"
        case achievement = "achievement"
    }
    
    enum InsightImpact: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
        case critical = "critical"
    }
    
    enum InsightCategory: String, Codable {
        case activity = "activity"
        case sleep = "sleep"
        case nutrition = "nutrition"
        case mentalHealth = "mental_health"
        case consistency = "consistency"
        case goals = "goals"
    }
}

struct HealthRecommendation: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: RecommendationCategory
    let priority: RecommendationPriority
    let estimatedImpact: String
    let actionSteps: [String]
    
    enum RecommendationCategory: String, Codable {
        case exercise = "exercise"
        case nutrition = "nutrition"
        case sleep = "sleep"
        case stress = "stress"
        case hydration = "hydration"
        case consistency = "consistency"
    }
    
    enum RecommendationPriority: String, Codable {
        case low = "low"
        case medium = "medium"
        case high = "high"
    }
}

struct TrendData: Identifiable, Codable {
    let id = UUID()
    let metric: String
    let value: Double
    let date: Date
    let trend: TrendDirection
    
    enum TrendDirection: String, Codable {
        case up = "up"
        case down = "down"
        case stable = "stable"
    }
}

class AnalyticsManager: ObservableObject {
    static let shared = AnalyticsManager()
    
    @Published var familyAnalytics: [HealthAnalytics] = []
    @Published var currentInsights: [HealthInsight] = []
    @Published var currentRecommendations: [HealthRecommendation] = []
    
    private init() {
        generateSampleAnalytics()
    }
    
    func generateAnalytics(for member: FamilyMember, period: HealthAnalytics.AnalyticsPeriod) -> HealthAnalytics {
        let calendar = Calendar.current
        let now = Date()
        
        let (startDate, endDate) = getDateRange(for: period, from: now)
        
        let metrics = calculateMetrics(for: member, from: startDate, to: endDate)
        let trends = generateTrends(for: member, from: startDate, to: endDate)
        let insights = generateInsights(for: member, metrics: metrics, trends: trends)
        let recommendations = generateRecommendations(for: member, insights: insights)
        
        return HealthAnalytics(
            memberId: member.id,
            period: period,
            startDate: startDate,
            endDate: endDate,
            metrics: metrics,
            trends: trends,
            insights: insights,
            recommendations: recommendations
        )
    }
    
    private func getDateRange(for period: HealthAnalytics.AnalyticsPeriod, from date: Date) -> (Date, Date) {
        let calendar = Calendar.current
        
        switch period {
        case .daily:
            return (calendar.startOfDay(for: date), calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date)
        case .weekly:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
            return (startOfWeek, calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek) ?? date)
        case .monthly:
            let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
            return (startOfMonth, calendar.date(byAdding: .month, value: 1, to: startOfMonth) ?? date)
        case .yearly:
            let startOfYear = calendar.dateInterval(of: .year, for: date)?.start ?? date
            return (startOfYear, calendar.date(byAdding: .year, value: 1, to: startOfYear) ?? date)
        }
    }
    
    private func calculateMetrics(for member: FamilyMember, from startDate: Date, to endDate: Date) -> AnalyticsMetrics {
        // In a real app, this would calculate from historical data
        // For now, we'll use current data as sample
        return AnalyticsMetrics(
            averageSteps: Double(member.healthMetrics.steps),
            averageHeartRate: Double(member.healthMetrics.heartRate),
            averageCalories: Double(member.healthMetrics.calories),
            averageDistance: member.healthMetrics.distance,
            averageSleep: member.healthMetrics.sleep,
            averageWorkoutMinutes: Double(member.healthMetrics.workoutMinutes),
            averageWaterIntake: member.healthMetrics.waterIntake,
            averageMoodScore: Double(member.healthMetrics.moodScore),
            averageStressLevel: Double(member.healthMetrics.stressLevel),
            consistencyScore: calculateConsistencyScore(for: member),
            improvementRate: calculateImprovementRate(for: member),
            goalAchievementRate: calculateGoalAchievementRate(for: member),
            healthScore: Double(member.healthMetrics.overallHealthScore)
        )
    }
    
    private func calculateConsistencyScore(for member: FamilyMember) -> Double {
        // Simplified consistency calculation
        let activeDays = member.activeDays
        let totalDays = 7 // Assuming weekly calculation
        return Double(activeDays) / Double(totalDays) * 100
    }
    
    private func calculateImprovementRate(for member: FamilyMember) -> Double {
        // Simplified improvement calculation
        return Double.random(in: -10...20) // Sample data
    }
    
    private func calculateGoalAchievementRate(for member: FamilyMember) -> Double {
        let goals = member.healthGoals
        var achievedGoals = 0
        var totalGoals = 0
        
        if member.healthMetrics.steps >= goals.dailySteps { achievedGoals += 1 }
        totalGoals += 1
        
        if member.healthMetrics.calories >= goals.dailyCalories { achievedGoals += 1 }
        totalGoals += 1
        
        if member.healthMetrics.waterIntake >= goals.dailyWater { achievedGoals += 1 }
        totalGoals += 1
        
        if member.healthMetrics.sleep >= goals.dailySleep { achievedGoals += 1 }
        totalGoals += 1
        
        return totalGoals > 0 ? Double(achievedGoals) / Double(totalGoals) * 100 : 0
    }
    
    private func generateTrends(for member: FamilyMember, from startDate: Date, to endDate: Date) -> [TrendData] {
        // Generate sample trend data
        return [
            TrendData(metric: "Steps", value: Double(member.healthMetrics.steps), date: Date(), trend: .up),
            TrendData(metric: "Heart Rate", value: Double(member.healthMetrics.heartRate), date: Date(), trend: .stable),
            TrendData(metric: "Sleep", value: member.healthMetrics.sleep, date: Date(), trend: .up),
            TrendData(metric: "Mood", value: Double(member.healthMetrics.moodScore), date: Date(), trend: .up)
        ]
    }
    
    private func generateInsights(for member: FamilyMember, metrics: AnalyticsMetrics, trends: [TrendData]) -> [HealthInsight] {
        var insights: [HealthInsight] = []
        
        // Steps insight
        if metrics.averageSteps >= 10000 {
            insights.append(HealthInsight(
                type: .positive,
                title: "Excellent Activity Level",
                description: "You're consistently hitting your daily step goal! Keep up the great work.",
                impact: .high,
                actionable: false,
                category: .activity
            ))
        } else if metrics.averageSteps < 5000 {
            insights.append(HealthInsight(
                type: .warning,
                title: "Low Activity Level",
                description: "Your daily steps are below recommended levels. Try to increase your activity.",
                impact: .high,
                actionable: true,
                category: .activity
            ))
        }
        
        // Sleep insight
        if metrics.averageSleep >= 8 {
            insights.append(HealthInsight(
                type: .positive,
                title: "Great Sleep Habits",
                description: "You're getting excellent sleep duration. This supports your overall health.",
                impact: .high,
                actionable: false,
                category: .sleep
            ))
        } else if metrics.averageSleep < 6 {
            insights.append(HealthInsight(
                type: .warning,
                title: "Insufficient Sleep",
                description: "You're not getting enough sleep. Aim for 7-9 hours nightly.",
                impact: .critical,
                actionable: true,
                category: .sleep
            ))
        }
        
        // Mood insight
        if metrics.averageMoodScore >= 8 {
            insights.append(HealthInsight(
                type: .positive,
                title: "Positive Mood",
                description: "Your mood scores are consistently high. Great mental health!",
                impact: .medium,
                actionable: false,
                category: .mentalHealth
            ))
        } else if metrics.averageMoodScore < 5 {
            insights.append(HealthInsight(
                type: .warning,
                title: "Low Mood",
                description: "Your mood scores are lower than usual. Consider stress management techniques.",
                impact: .high,
                actionable: true,
                category: .mentalHealth
            ))
        }
        
        // Consistency insight
        if metrics.consistencyScore >= 80 {
            insights.append(HealthInsight(
                type: .achievement,
                title: "Highly Consistent",
                description: "You're maintaining excellent consistency with your health habits.",
                impact: .high,
                actionable: false,
                category: .consistency
            ))
        }
        
        return insights
    }
    
    private func generateRecommendations(for member: FamilyMember, insights: [HealthInsight]) -> [HealthRecommendation] {
        var recommendations: [HealthRecommendation] = []
        
        // Generate recommendations based on insights
        for insight in insights where insight.actionable {
            switch insight.category {
            case .activity:
                recommendations.append(HealthRecommendation(
                    title: "Increase Daily Activity",
                    description: "Try to add more movement to your daily routine.",
                    category: .exercise,
                    priority: .high,
                    estimatedImpact: "15-20% increase in daily steps",
                    actionSteps: [
                        "Take the stairs instead of elevators",
                        "Park farther from your destination",
                        "Take 5-minute walking breaks every hour",
                        "Try a new physical activity this week"
                    ]
                ))
            case .sleep:
                recommendations.append(HealthRecommendation(
                    title: "Improve Sleep Quality",
                    description: "Establish better sleep habits for optimal rest.",
                    category: .sleep,
                    priority: .high,
                    estimatedImpact: "Better mood and energy levels",
                    actionSteps: [
                        "Set a consistent bedtime",
                        "Avoid screens 1 hour before bed",
                        "Create a relaxing bedtime routine",
                        "Keep your bedroom cool and dark"
                    ]
                ))
            case .mentalHealth:
                recommendations.append(HealthRecommendation(
                    title: "Stress Management",
                    description: "Incorporate stress-reduction techniques into your routine.",
                    category: .stress,
                    priority: .medium,
                    estimatedImpact: "Improved mood and overall well-being",
                    actionSteps: [
                        "Practice 10 minutes of meditation daily",
                        "Try deep breathing exercises",
                        "Engage in activities you enjoy",
                        "Consider talking to a professional if needed"
                    ]
                ))
            default:
                break
            }
        }
        
        return recommendations
    }
    
    private func generateSampleAnalytics() {
        // Generate sample insights and recommendations
        currentInsights = [
            HealthInsight(
                type: .positive,
                title: "Family Health Trend",
                description: "Your family's overall health score has improved by 12% this month.",
                impact: .high,
                actionable: false,
                category: .consistency
            ),
            HealthInsight(
                type: .achievement,
                title: "Goal Achievement",
                description: "You've achieved 85% of your health goals this week.",
                impact: .medium,
                actionable: false,
                category: .goals
            )
        ]
        
        currentRecommendations = [
            HealthRecommendation(
                title: "Family Workout Challenge",
                description: "Start a weekly family fitness challenge to boost everyone's activity.",
                category: .exercise,
                priority: .high,
                estimatedImpact: "20% increase in family activity levels",
                actionSteps: [
                    "Choose a fun activity everyone can do",
                    "Set a weekly goal together",
                    "Track progress as a family",
                    "Celebrate achievements together"
                ]
            )
        ]
    }
}

// MARK: - Apple Watch App Support
struct WatchAppData: Codable {
    let memberId: UUID
    let timestamp: Date
    let heartRate: Int
    let steps: Int
    let activeCalories: Int
    let standHours: Int
    let exerciseMinutes: Int
    let workoutType: String?
    let isWorkoutActive: Bool
    let batteryLevel: Int
    let isConnected: Bool
}

class WatchConnectivityManager: ObservableObject {
    static let shared = WatchConnectivityManager()
    
    @Published var isWatchConnected = false
    @Published var watchData: WatchAppData?
    @Published var lastSyncTime: Date?
    
    private init() {
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        // In a real app, this would use WCSession for Apple Watch communication
        // For now, we'll simulate watch connectivity
        simulateWatchConnection()
    }
    
    private func simulateWatchConnection() {
        // Simulate watch connection status
        isWatchConnected = Bool.random()
        
        if isWatchConnected {
            // Generate sample watch data
            watchData = WatchAppData(
                memberId: UUID(),
                timestamp: Date(),
                heartRate: Int.random(in: 60...100),
                steps: Int.random(in: 1000...15000),
                activeCalories: Int.random(in: 200...800),
                standHours: Int.random(in: 8...12),
                exerciseMinutes: Int.random(in: 0...60),
                workoutType: ["Running", "Walking", "Cycling", "Yoga", nil].randomElement() ?? nil,
                isWorkoutActive: Bool.random(),
                batteryLevel: Int.random(in: 20...100),
                isConnected: true
            )
            lastSyncTime = Date()
        }
    }
    
    func syncWithWatch() {
        // Simulate syncing with Apple Watch
        simulateWatchConnection()
        
        // Update family member data with watch data
        if let data = watchData {
            // This would update the current user's health metrics
            // In a real app, this would integrate with HealthKit and CloudKit
        }
    }
    
    func startWorkout(type: String) {
        // Simulate starting a workout on Apple Watch
        if isWatchConnected {
            // This would send a command to the Apple Watch to start a workout
            print("Starting \(type) workout on Apple Watch")
        }
    }
    
    func endWorkout() {
        // Simulate ending a workout on Apple Watch
        if isWatchConnected {
            // This would send a command to the Apple Watch to end the workout
            print("Ending workout on Apple Watch")
        }
    }
}

// MARK: - Enhanced UI Components for New Features
struct EnhancedHealthDashboard: View {
    @StateObject private var familyManager = FamilyManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var challengeManager = ChallengeManager.shared
    @StateObject private var analyticsManager = AnalyticsManager.shared
    @StateObject private var watchManager = WatchConnectivityManager.shared
    
    @Binding var currentUser: FamilyMember
    @Binding var familyMembers: [FamilyMember]
    @Binding var weeklyDigest: WeeklyHealthDigest
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Header with User Info
                WelcomeHeaderView(currentUser: currentUser)
                
                // Today's Activity Section with Progress Rings
                ActivityRingsSection(currentUser: currentUser)
                
                // Today's Progress Section with Progress Bars
                TodayProgressSection(currentUser: currentUser)
                
                // Badges & Achievements Section
                BadgesSection(currentUser: currentUser)
                
                // Enhanced Health Score Card
                HealthScoreCard(healthScore: currentUser.healthMetrics.overallHealthScore)
                
                // Smart Notifications Section
                SmartNotificationsSection()
                
                // Active Challenges Section
                ActiveChallengesSection()
                
                // Analytics Insights Section
                AnalyticsInsightsSection()
                
                // Apple Watch Status
                AppleWatchStatusCard()
                
                // Enhanced Health Metrics
                EnhancedHealthMetricsSection(currentUser: Binding(
                    get: { currentUser },
                    set: { currentUser = $0 }
                ))
                
                // Family Overview (existing)
                FamilyOverviewSection(familyMembers: familyMembers)
            }
            .padding()
        }
        .navigationTitle("Health Dashboard")
        .onAppear {
            watchManager.syncWithWatch()
        }
    }
}

struct WelcomeHeaderView: View {
    let currentUser: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text(currentUser.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        // Achievement badge
                        HStack(spacing: 4) {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                            
                            Text("Active Walker")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
            }
            
            // Streak information
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    
                    Text("\(currentUser.currentStreak) day streak")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text("Best: \(currentUser.longestStreak) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

struct HealthScoreCard: View {
    let healthScore: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Overall Health Score")
                    .font(.headline)
                Spacer()
                Text("\(healthScore)/100")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(healthScoreColor)
            }
            
            ProgressView(value: Double(healthScore), total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: healthScoreColor))
            
            Text(healthScoreDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var healthScoreColor: Color {
        switch healthScore {
        case 80...100: return .green
        case 60...79: return .orange
        case 40...59: return .yellow
        default: return .red
        }
    }
    
    private var healthScoreDescription: String {
        switch healthScore {
        case 80...100: return "Excellent health! Keep up the great work!"
        case 60...79: return "Good health! A few improvements could help."
        case 40...59: return "Fair health. Consider lifestyle changes."
        default: return "Health needs attention. Consult a healthcare provider."
        }
    }
}

struct SmartNotificationsSection: View {
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Smart Notifications")
                    .font(.headline)
                Spacer()
                if notificationManager.unreadCount > 0 {
                    Text("\(notificationManager.unreadCount)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
            
            if notificationManager.notifications.isEmpty {
                Text("No notifications yet")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(notificationManager.notifications.prefix(3)) { notification in
                    NotificationRow(notification: notification)
                }
                
                if notificationManager.notifications.count > 3 {
                    Button("View All Notifications") {
                        // Navigate to full notifications view
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct NotificationRow: View {
    let notification: SmartNotification
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notificationIcon)
                .foregroundColor(notificationColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(notification.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(timeAgo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.vertical, 4)
        .onTapGesture {
            notificationManager.markAsRead(notification)
        }
    }
    
    private var notificationIcon: String {
        switch notification.type {
        case .achievement: return "trophy.fill"
        case .challenge: return "gamecontroller.fill"
        case .goalReminder: return "target"
        case .encouragement: return "heart.fill"
        case .familyUpdate: return "person.3.fill"
        default: return "bell.fill"
        }
    }
    
    private var notificationColor: Color {
        switch notification.priority {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .blue
        case .low: return .gray
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: notification.timestamp, relativeTo: Date())
    }
}

struct ActiveChallengesSection: View {
    @StateObject private var challengeManager = ChallengeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Challenges")
                    .font(.headline)
                Spacer()
                Button("View All") {
                    // Navigate to challenges view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if challengeManager.activeChallenges.isEmpty {
                Text("No active challenges")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(challengeManager.activeChallenges.prefix(2)) { challenge in
                    ChallengeCard(challenge: challenge)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct ChallengeCard: View {
    let challenge: FamilyChallenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(challenge.daysRemaining) days left")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(challenge.description)
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressView(value: challenge.completionPercentage, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
            
            HStack {
                Text("\(Int(challenge.completionPercentage))% complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Reward: \(challenge.reward)")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct AnalyticsInsightsSection: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health Insights")
                .font(.headline)
            
            if analyticsManager.currentInsights.isEmpty {
                Text("No insights available")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ForEach(analyticsManager.currentInsights.prefix(2)) { insight in
                    InsightCard(insight: insight)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct InsightCard: View {
    let insight: HealthInsight
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: insightIcon)
                .foregroundColor(insightColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(insight.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    
    private var insightIcon: String {
        switch insight.type {
        case .positive: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .improvement: return "arrow.up.circle.fill"
        case .achievement: return "star.fill"
        }
    }
    
    private var insightColor: Color {
        switch insight.type {
        case .positive: return .green
        case .warning: return .orange
        case .improvement: return .blue
        case .achievement: return .purple
        }
    }
}

struct AppleWatchStatusCard: View {
    @StateObject private var watchManager = WatchConnectivityManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "applewatch")
                .font(.title2)
                .foregroundColor(watchManager.isWatchConnected ? .green : .gray)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Apple Watch")
                    .font(.headline)
                
                Text(watchManager.isWatchConnected ? "Connected" : "Not Connected")
                    .font(.subheadline)
                    .foregroundColor(watchManager.isWatchConnected ? .green : .secondary)
                
                if let data = watchManager.watchData {
                    Text("Battery: \(data.batteryLevel)%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if watchManager.isWatchConnected {
                Button("Sync") {
                    watchManager.syncWithWatch()
                }
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct EnhancedHealthMetricsSection: View {
    @Binding var currentUser: FamilyMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Enhanced Health Metrics")
                .font(.headline)
            
            VStack(spacing: 8) {
                EnhancedMetricCard(
                    title: "Blood Pressure",
                    value: "\(currentUser.healthMetrics.bloodPressureSystolic)/\(currentUser.healthMetrics.bloodPressureDiastolic)",
                    unit: "mmHg",
                    category: currentUser.healthMetrics.bloodPressureCategory,
                    color: bloodPressureColor
                )
                
                EnhancedMetricCard(
                    title: "BMI",
                    value: String(format: "%.1f", currentUser.healthMetrics.bmi),
                    unit: "kg/m²",
                    category: currentUser.healthMetrics.bmiCategory,
                    color: bmiColor
                )
                
                EnhancedMetricCard(
                    title: "Water Intake",
                    value: String(format: "%.1f", currentUser.healthMetrics.waterIntake),
                    unit: "L",
                    category: waterCategory,
                    color: .blue
                )
                
                EnhancedMetricCard(
                    title: "Mood Score",
                    value: "\(currentUser.healthMetrics.moodScore)",
                    unit: "/10",
                    category: moodCategory,
                    color: moodColor
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var bloodPressureColor: Color {
        let systolic = currentUser.healthMetrics.bloodPressureSystolic
        let diastolic = currentUser.healthMetrics.bloodPressureDiastolic
        
        if systolic < 120 && diastolic < 80 {
            return .green
        } else if systolic < 140 || diastolic < 90 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var bmiColor: Color {
        let bmi = currentUser.healthMetrics.bmi
        if bmi >= 18.5 && bmi < 25 {
            return .green
        } else if bmi >= 25 && bmi < 30 {
            return .orange
        } else {
            return .red
        }
    }
    
    private var waterCategory: String {
        let water = currentUser.healthMetrics.waterIntake
        if water >= 2.5 {
            return "Excellent"
        } else if water >= 2.0 {
            return "Good"
        } else if water >= 1.5 {
            return "Fair"
        } else {
            return "Low"
        }
    }
    
    private var moodCategory: String {
        let mood = currentUser.healthMetrics.moodScore
        if mood >= 8 {
            return "Excellent"
        } else if mood >= 6 {
            return "Good"
        } else if mood >= 4 {
            return "Fair"
        } else {
            return "Low"
        }
    }
    
    private var moodColor: Color {
        let mood = currentUser.healthMetrics.moodScore
        if mood >= 8 {
            return .green
        } else if mood >= 6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct EnhancedMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let category: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(category)
                    .font(.caption2)
                    .foregroundColor(color)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Badge Model
struct Badge: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    var isUnlocked: Bool
    var unlockedDate: Date?
    
    static let allBadges = [
        Badge(name: "7-Day Streak", description: "7 consecutive active days", icon: "flame.fill", color: .orange, isUnlocked: false, unlockedDate: nil),
        Badge(name: "10K Steps", description: "10,000+ steps in a day", icon: "figure.walk", color: .green, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Calorie Burner", description: "500+ calories burned", icon: "flame", color: .orange, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Distance Master", description: "10+ km in a day", icon: "location.fill", color: .blue, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Sleep Champion", description: "8+ hours of sleep", icon: "bed.double.fill", color: .purple, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Early Bird", description: "Active before 7 AM", icon: "sunrise.fill", color: .yellow, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Night Owl", description: "Active after 10 PM", icon: "moon.fill", color: .indigo, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Weekend Warrior", description: "Active on weekends", icon: "calendar", color: .pink, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Marathon Walker", description: "20,000+ steps in a day", icon: "figure.walk.circle.fill", color: .red, isUnlocked: false, unlockedDate: nil),
        Badge(name: "Consistency King", description: "30 days of activity", icon: "crown.fill", color: .yellow, isUnlocked: false, unlockedDate: nil)
    ]
}

// MARK: - Achievement Model
struct Achievement: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    var isUnlocked: Bool
    var unlockedDate: Date?
    let requirement: String
}

// MARK: - Daily Data Model
struct DailyData: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let steps: Int
    let calories: Int
    let distance: Double
    let heartRate: Int
    let sleep: Double
}

// MARK: - Progress Ring View
struct ProgressRing: View {
    let progress: Double
    let ringWidth: CGFloat
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.2), lineWidth: ringWidth)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: ringWidth, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

// MARK: - Weekly Health Digest View
struct WeeklyHealthDigestView: View {
    let digest: WeeklyHealthDigest
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Weekly Health Digest")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("This week")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                DigestCard(
                    title: "Total Steps",
                    value: "\(digest.totalFamilySteps)",
                    icon: "figure.walk",
                    color: .green
                )
                
                DigestCard(
                    title: "Total Calories",
                    value: "\(digest.totalFamilyCalories)",
                    icon: "flame",
                    color: .orange
                )
                
                DigestCard(
                    title: "Total Distance",
                    value: String(format: "%.1f km", digest.totalFamilyDistance),
                    icon: "location.fill",
                    color: .blue
                )
                
                DigestCard(
                    title: "Avg Heart Rate",
                    value: "\(digest.averageFamilyHeartRate) bpm",
                    icon: "heart.fill",
                    color: .red
                )
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Most Active Member:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(digest.mostActiveMember)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
                
                HStack {
                    Text("Best Day:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(digest.bestDay)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Digest Card
struct DigestCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Family Manager for Real-time Data Synchronization
class FamilyManager: ObservableObject {
    static let shared = FamilyManager()
    
    @Published var familyMembers: [FamilyMember] = []
    @Published var currentUser: FamilyMember?
    @Published var isConnected = false
    @Published var lastSyncDate: Date?
    
    private let container = CKContainer.default()
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase
    private var cancellables = Set<AnyCancellable>()
    private var syncTimer: Timer?
    
    // Family sharing settings
    @Published var shareHealthData = true
    @Published var shareAchievements = true
    @Published var shareLocation = false
    @Published var allowInvites = true
    
    private init() {
        self.privateDatabase = container.privateCloudDatabase
        self.publicDatabase = container.publicCloudDatabase
        
        setupCloudKit()
        startPeriodicSync()
    }
    
    // MARK: - CloudKit Setup
    private func setupCloudKit() {
        container.accountStatus { [weak self] status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    self?.isConnected = true
                    self?.fetchFamilyData()
                case .noAccount:
                    self?.isConnected = false
                    print("No iCloud account")
                case .restricted:
                    self?.isConnected = false
                    print("iCloud restricted")
                case .couldNotDetermine:
                    self?.isConnected = false
                    print("Could not determine iCloud status")
                @unknown default:
                    self?.isConnected = false
                }
            }
        }
    }
    
    // MARK: - Family Data Synchronization
    func fetchFamilyData() {
        guard isConnected else { 
            // Use sample data when not connected
            self.familyMembers = FamilyMember.sampleFamilyMembers
            self.currentUser = FamilyMember.sampleCurrentUser
            return 
        }
        
        let query = CKQuery(recordType: "FamilyMember", predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { [weak self] records, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching family data: \(error)")
                    // Fallback to sample data
                    self?.familyMembers = FamilyMember.sampleFamilyMembers
                    self?.currentUser = FamilyMember.sampleCurrentUser
                    return
                }
                
                guard let records = records else { 
                    // Fallback to sample data
                    self?.familyMembers = FamilyMember.sampleFamilyMembers
                    self?.currentUser = FamilyMember.sampleCurrentUser
                    return 
                }
                
                let members = records.compactMap { record -> FamilyMember? in
                    return self?.familyMemberFromRecord(record)
                }
                
                self?.familyMembers = members
                self?.currentUser = members.first { $0.isCurrentUser }
                self?.lastSyncDate = Date()
            }
        }
    }
    
    func syncCurrentUserData() {
        guard let currentUser = currentUser else { return }
        
        let record = recordFromFamilyMember(currentUser)
        
        privateDatabase.save(record) { [weak self] savedRecord, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error syncing user data: \(error)")
                    return
                }
                
                self?.lastSyncDate = Date()
                print("User data synced successfully")
            }
        }
    }
    
    func syncFamilyMemberData(_ member: FamilyMember) {
        let record = recordFromFamilyMember(member)
        
        privateDatabase.save(record) { [weak self] savedRecord, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error syncing family member data: \(error)")
                    return
                }
                
                self?.lastSyncDate = Date()
                print("Family member data synced successfully")
            }
        }
    }
    
    // MARK: - Real-time Updates
    func startPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.fetchFamilyData()
        }
    }
    
    func stopPeriodicSync() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    // MARK: - Family Invitations
    func inviteFamilyMember(email: String, relationship: String) {
        guard isConnected else { 
            print("Not connected to iCloud - invitation not sent")
            return 
        }
        
        let invitation = CKRecord(recordType: "FamilyInvitation")
        invitation["inviterEmail"] = currentUser?.appleID ?? ""
        invitation["inviteeEmail"] = email
        invitation["relationship"] = relationship
        invitation["invitationDate"] = Date()
        invitation["status"] = "pending"
        
        privateDatabase.save(invitation) { [weak self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error sending invitation: \(error)")
                    return
                }
                
                print("Invitation sent successfully")
                // Send push notification to invitee
                self?.sendInvitationNotification(to: email)
            }
        }
    }
    
    func acceptInvitation(invitationId: String) {
        let recordID = CKRecord.ID(recordName: invitationId)
        
        privateDatabase.fetch(withRecordID: recordID) { [weak self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching invitation: \(error)")
                    return
                }
                
                guard let record = record else { return }
                
                // Update invitation status
                record["status"] = "accepted"
                record["acceptedDate"] = Date()
                
                self?.privateDatabase.save(record) { savedRecord, error in
                    if let error = error {
                        print("Error accepting invitation: \(error)")
                        return
                    }
                    
                    print("Invitation accepted successfully")
                }
            }
        }
    }
    
    // MARK: - Live Achievement Notifications
    func notifyFamilyOfAchievement(_ achievement: String, member: FamilyMember) {
        guard shareAchievements else { return }
        
        let notification = CKRecord(recordType: "FamilyNotification")
        notification["type"] = "achievement"
        notification["message"] = "\(member.name) achieved: \(achievement)"
        notification["memberId"] = member.id.uuidString
        notification["timestamp"] = Date()
        notification["isRead"] = false
        
        privateDatabase.save(notification) { record, error in
            if let error = error {
                print("Error sending achievement notification: \(error)")
                return
            }
            
            print("Achievement notification sent")
        }
    }
    
    func notifyFamilyOfGoalCompletion(_ goal: String, member: FamilyMember) {
        guard shareHealthData else { return }
        
        let notification = CKRecord(recordType: "FamilyNotification")
        notification["type"] = "goal_completion"
        notification["message"] = "\(member.name) completed their \(goal) goal!"
        notification["memberId"] = member.id.uuidString
        notification["timestamp"] = Date()
        notification["isRead"] = false
        
        privateDatabase.save(notification) { record, error in
            if let error = error {
                print("Error sending goal notification: \(error)")
                return
            }
            
            print("Goal completion notification sent")
        }
    }
    
    // MARK: - Data Conversion
    private func familyMemberFromRecord(_ record: CKRecord) -> FamilyMember? {
        guard let name = record["name"] as? String,
              let relationship = record["relationship"] as? String,
              let appleID = record["appleID"] as? String,
              let colorHex = record["color"] as? String,
              let isOnline = record["isOnline"] as? Bool else {
            return nil
        }
        
        let color = Color(hex: colorHex)
        let isCurrentUser = record["isCurrentUser"] as? Bool ?? false
        
        // Health data
        let todaySteps = record["todaySteps"] as? Int ?? 0
        let todayHeartRate = record["todayHeartRate"] as? Int ?? 0
        let todayCalories = record["todayCalories"] as? Int ?? 0
        let todayDistance = record["todayDistance"] as? Double ?? 0.0
        let todaySleep = record["todaySleep"] as? Double ?? 0.0
        
        // Weekly data
        let weeklySteps = record["weeklySteps"] as? Int ?? 0
        let weeklyCalories = record["weeklyCalories"] as? Int ?? 0
        let weeklyDistance = record["weeklyDistance"] as? Double ?? 0.0
        let activeDays = record["activeDays"] as? Int ?? 0
        
        // Monthly data
        let monthlySteps = record["monthlySteps"] as? Int ?? 0
        let monthlyCalories = record["monthlyCalories"] as? Int ?? 0
        let monthlyDistance = record["monthlyDistance"] as? Double ?? 0.0
        
        // Streaks
        let currentStreak = record["currentStreak"] as? Int ?? 0
        let longestStreak = record["longestStreak"] as? Int ?? 0
        
        // Last updated
        let lastUpdated = record["lastUpdated"] as? Date ?? Date()
        
        return FamilyMember(
            name: name,
            relationship: relationship,
            appleID: appleID,
            color: color,
            isOnline: isOnline,
            isCurrentUser: isCurrentUser,
            lastUpdated: lastUpdated,
            createdDate: Date(),
            healthMetrics: HealthMetrics(
                steps: todaySteps,
                heartRate: todayHeartRate,
                calories: todayCalories,
                distance: todayDistance,
                sleep: todaySleep
            ),
            workoutHistory: [],
            nutritionHistory: [],
            mentalHealthHistory: [],
            healthGoals: HealthGoals(),
            preferences: UserPreferences(),
            notifications: NotificationSettings(),
            weeklySteps: weeklySteps,
            weeklyCalories: weeklyCalories,
            weeklyDistance: weeklyDistance,
            activeDays: activeDays,
            monthlySteps: monthlySteps,
            monthlyCalories: monthlyCalories,
            monthlyDistance: monthlyDistance,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            badges: [], // Will be loaded separately
            achievements: [], // Will be loaded separately
            weeklyTrends: [] // Will be loaded separately
        )
    }
    
    private func recordFromFamilyMember(_ member: FamilyMember) -> CKRecord {
        let record = CKRecord(recordType: "FamilyMember", recordID: CKRecord.ID(recordName: member.id.uuidString))
        
        record["name"] = member.name
        record["relationship"] = member.relationship
        record["appleID"] = member.appleID
        record["color"] = member.color.toHex
        record["isOnline"] = member.isOnline
        record["isCurrentUser"] = member.isCurrentUser
        
        // Health data
        record["todaySteps"] = member.todaySteps
        record["todayHeartRate"] = member.todayHeartRate
        record["todayCalories"] = member.todayCalories
        record["todayDistance"] = member.todayDistance
        record["todaySleep"] = member.todaySleep
        
        // Weekly data
        record["weeklySteps"] = member.weeklySteps
        record["weeklyCalories"] = member.weeklyCalories
        record["weeklyDistance"] = member.weeklyDistance
        record["activeDays"] = member.activeDays
        
        // Monthly data
        record["monthlySteps"] = member.monthlySteps
        record["monthlyCalories"] = member.monthlyCalories
        record["monthlyDistance"] = member.monthlyDistance
        
        // Streaks
        record["currentStreak"] = member.currentStreak
        record["longestStreak"] = member.longestStreak
        
        // Timestamps
        record["lastUpdated"] = Date()
        record["createdDate"] = member.createdDate
        
        return record
    }
    
    // MARK: - Push Notifications
    private func sendInvitationNotification(to email: String) {
        // This would integrate with your push notification service
        // For now, we'll just log it
        print("Sending invitation notification to: \(email)")
    }
    
    // MARK: - Family Settings
    func updateFamilySettings() {
        let settings = CKRecord(recordType: "FamilySettings")
        settings["shareHealthData"] = shareHealthData
        settings["shareAchievements"] = shareAchievements
        settings["shareLocation"] = shareLocation
        settings["allowInvites"] = allowInvites
        settings["familyId"] = currentUser?.id.uuidString ?? ""
        
        privateDatabase.save(settings) { record, error in
            if let error = error {
                print("Error updating family settings: \(error)")
                return
            }
            
            print("Family settings updated successfully")
        }
    }
    
    // MARK: - Offline Sync
    func syncOfflineData() {
        // This would handle syncing data when the device comes back online
        // For now, we'll just fetch the latest data
        fetchFamilyData()
    }
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    var toHex: String {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let rgb: Int = (Int)(red * 255) << 16 | (Int)(green * 255) << 8 | (Int)(blue * 255) << 0
        
        return String(format: "#%06x", rgb)
    }
}

// MARK: - Family Activity Feed View
struct FamilyActivityFeed: View {
    @StateObject private var familyManager = FamilyManager.shared
    @State private var activities: [ActivityItem] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(activities) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding()
            }
            .navigationTitle("Family Activity")
            .onAppear {
                loadActivities()
            }
        }
    }
    
    private func loadActivities() {
        // Sample activities for demonstration
        activities = [
            ActivityItem(
                id: UUID(),
                type: .achievement,
                memberName: "Sarah",
                message: "Completed 10,000 steps goal!",
                timestamp: Date().addingTimeInterval(-3600),
                icon: "trophy.fill",
                color: .orange
            ),
            ActivityItem(
                id: UUID(),
                type: .goal,
                memberName: "Mike",
                message: "Reached weekly exercise target",
                timestamp: Date().addingTimeInterval(-7200),
                icon: "target",
                color: .green
            ),
            ActivityItem(
                id: UUID(),
                type: .streak,
                memberName: "Emma",
                message: "7-day activity streak!",
                timestamp: Date().addingTimeInterval(-10800),
                icon: "flame.fill",
                color: .red
            )
        ]
    }
}

// MARK: - Activity Item Model
struct ActivityItem: Identifiable {
    let id: UUID
    let type: ActivityType
    let memberName: String
    let message: String
    let timestamp: Date
    let icon: String
    let color: Color
}

enum ActivityType {
    case achievement
    case goal
    case streak
    case challenge
}

// MARK: - Activity Card View
struct ActivityCard: View {
    let activity: ActivityItem
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: activity.icon)
                .foregroundColor(activity.color)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(activity.color.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.memberName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(activity.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(activity.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Family Invitation View
struct FamilyInvitationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var familyManager = FamilyManager.shared
    @State private var email = ""
    @State private var relationship = "Family Member"
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let relationships = ["Spouse", "Child", "Parent", "Sibling", "Family Member", "Friend"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Invite Family Member")) {
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    
                    Picker("Relationship", selection: $relationship) {
                        ForEach(relationships, id: \.self) { rel in
                            Text(rel).tag(rel)
                        }
                    }
                }
                
                Section {
                    Button("Send Invitation") {
                        sendInvitation()
                    }
                    .disabled(email.isEmpty)
                }
            }
            .navigationTitle("Invite Family")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Invitation", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func sendInvitation() {
        guard !email.isEmpty else { return }
        
        familyManager.inviteFamilyMember(email: email, relationship: relationship)
        alertMessage = "Invitation sent to \(email)"
        showingAlert = true
        
        // Clear form
        email = ""
        relationship = "Family Member"
    }
}

// MARK: - Challenges View
struct ChallengesView: View {
    @StateObject private var challengeManager = ChallengeManager.shared
    @State private var showingCreateChallenge = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Active Challenges
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Challenges")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Button("Create New") {
                                showingCreateChallenge = true
                            }
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        
                        if challengeManager.activeChallenges.isEmpty {
                            Text("No active challenges")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(challengeManager.activeChallenges) { challenge in
                                DetailedChallengeCard(challenge: challenge)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Completed Challenges
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Completed Challenges")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if challengeManager.completedChallenges.isEmpty {
                            Text("No completed challenges yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(challengeManager.completedChallenges.prefix(3)) { challenge in
                                CompletedChallengeCard(challenge: challenge)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("Family Challenges")
            .sheet(isPresented: $showingCreateChallenge) {
                CreateChallengeView()
            }
        }
    }
}

struct DetailedChallengeCard: View {
    let challenge: FamilyChallenge
    @StateObject private var challengeManager = ChallengeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(challenge.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(challenge.daysRemaining)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text("days left")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text("\(Int(challenge.completionPercentage))%")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                ProgressView(value: challenge.completionPercentage, total: 100)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .frame(height: 8)
            }
            
            // Participants
            HStack {
                Text("Participants: \(challenge.participants.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Reward: \(challenge.reward)")
                    .font(.caption)
                    .foregroundColor(.green)
                    .fontWeight(.medium)
            }
            
            // Join Button
            if !challenge.participants.contains("You") {
                Button("Join Challenge") {
                    challengeManager.joinChallenge(challenge.id, memberName: "You")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct CompletedChallengeCard: View {
    let challenge: FamilyChallenge
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(challenge.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Completed \(challenge.endDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("🏆")
                .font(.title2)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

struct CreateChallengeView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var challengeManager = ChallengeManager.shared
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedType = FamilyChallenge.ChallengeType.steps
    @State private var duration = 7
    @State private var target = 10000
    @State private var reward = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Challenge Details") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Challenge Type") {
                    Picker("Type", selection: $selectedType) {
                        ForEach(FamilyChallenge.ChallengeType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                }
                
                Section("Duration & Target") {
                    Stepper("Duration: \(duration) days", value: $duration, in: 1...30)
                    Stepper("Target: \(target)", value: $target, in: 1...100000, step: 100)
                }
                
                Section("Reward") {
                    TextField("Reward (e.g., Family movie night)", text: $reward)
                }
            }
            .navigationTitle("Create Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createChallenge()
                    }
                    .disabled(title.isEmpty || description.isEmpty || reward.isEmpty)
                }
            }
        }
    }
    
    private func createChallenge() {
        let newChallenge = FamilyChallenge(
            title: title,
            description: description,
            type: selectedType,
            duration: duration,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: duration, to: Date()) ?? Date(),
            target: target,
            unit: selectedType.rawValue,
            reward: reward,
            isActive: true,
            participants: [],
            progress: [:],
            leaderboard: []
        )
        
        challengeManager.createChallenge(newChallenge)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Analytics View
struct AnalyticsView: View {
    @StateObject private var analyticsManager = AnalyticsManager.shared
    @StateObject private var familyManager = FamilyManager.shared
    @State private var selectedPeriod = HealthAnalytics.AnalyticsPeriod.weekly
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Period Selector
                    Picker("Period", selection: $selectedPeriod) {
                        ForEach([HealthAnalytics.AnalyticsPeriod.daily, .weekly, .monthly, .yearly], id: \.self) { period in
                            Text(period.rawValue.capitalized).tag(period)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Health Insights
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Health Insights")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if analyticsManager.currentInsights.isEmpty {
                            Text("No insights available")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(analyticsManager.currentInsights) { insight in
                                DetailedInsightCard(insight: insight)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Health Recommendations
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommendations")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if analyticsManager.currentRecommendations.isEmpty {
                            Text("No recommendations available")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(analyticsManager.currentRecommendations) { recommendation in
                                RecommendationCard(recommendation: recommendation)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Family Analytics Summary
                    FamilyAnalyticsSummary()
                }
                .padding()
            }
            .navigationTitle("Health Analytics")
        }
    }
}

struct DetailedInsightCard: View {
    let insight: HealthInsight
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: insightIcon)
                .foregroundColor(insightColor)
                .font(.title2)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(insight.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text(insight.impact.rawValue.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(impactColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Text(insight.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if insight.actionable {
                    Text("Actionable")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .foregroundColor(.blue)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var insightIcon: String {
        switch insight.type {
        case .positive: return "checkmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .improvement: return "arrow.up.circle.fill"
        case .achievement: return "star.fill"
        }
    }
    
    private var insightColor: Color {
        switch insight.type {
        case .positive: return .green
        case .warning: return .orange
        case .improvement: return .blue
        case .achievement: return .purple
        }
    }
    
    private var impactColor: Color {
        switch insight.impact {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        case .critical: return .red
        }
    }
}

struct RecommendationCard: View {
    let recommendation: HealthRecommendation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recommendation.title)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Text(recommendation.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(recommendation.priority.rawValue.capitalized)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(priorityColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Text("Estimated Impact: \(recommendation.estimatedImpact)")
                .font(.caption)
                .foregroundColor(.blue)
                .fontWeight(.medium)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Action Steps:")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ForEach(recommendation.actionSteps, id: \.self) { step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                            .foregroundColor(.blue)
                        Text(step)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private var priorityColor: Color {
        switch recommendation.priority {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .orange
        }
    }
}

struct FamilyAnalyticsSummary: View {
    @StateObject private var familyManager = FamilyManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Family Health Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                SummaryMetricCard(
                    title: "Average Health Score",
                    value: "\(Int(familyAverageHealthScore))",
                    unit: "/100",
                    color: .green
                )
                
                SummaryMetricCard(
                    title: "Active Members",
                    value: "\(activeMembersCount)",
                    unit: "members",
                    color: .blue
                )
                
                SummaryMetricCard(
                    title: "Total Steps Today",
                    value: "\(totalFamilySteps)",
                    unit: "steps",
                    color: .orange
                )
                
                SummaryMetricCard(
                    title: "Goals Achieved",
                    value: "\(goalsAchievedCount)",
                    unit: "/\(totalGoalsCount)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var familyAverageHealthScore: Double {
        let totalScore = familyManager.familyMembers.reduce(0) { $0 + $1.healthMetrics.overallHealthScore }
        return familyManager.familyMembers.isEmpty ? 0 : Double(totalScore) / Double(familyManager.familyMembers.count)
    }
    
    private var activeMembersCount: Int {
        familyManager.familyMembers.filter { $0.isOnline }.count
    }
    
    private var totalFamilySteps: Int {
        familyManager.familyMembers.reduce(0) { $0 + $1.healthMetrics.steps }
    }
    
    private var goalsAchievedCount: Int {
        var total = 0
        for member in familyManager.familyMembers {
            let stepsGoal = member.healthMetrics.steps >= member.healthGoals.dailySteps ? 1 : 0
            let caloriesGoal = member.healthMetrics.calories >= member.healthGoals.dailyCalories ? 1 : 0
            let waterGoal = member.healthMetrics.waterIntake >= member.healthGoals.dailyWater ? 1 : 0
            let sleepGoal = member.healthMetrics.sleep >= member.healthGoals.dailySleep ? 1 : 0
            total += stepsGoal + caloriesGoal + waterGoal + sleepGoal
        }
        return total
    }
    
    private var totalGoalsCount: Int {
        familyManager.familyMembers.count * 4 // 4 goals per member
    }
}

struct SummaryMetricCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Main Content View
struct ContentView: View {
    @StateObject private var familyManager = FamilyManager.shared
    @State private var selectedTab = 0
    @State private var showAddFamilyMember = false
    @State private var showFamilyInvitation = false
    @State private var showActivityFeed = false
    @State private var healthStore = HKHealthStore()
    @State private var isHealthKitAuthorized = false
    @State private var weeklyDigest = WeeklyHealthDigest(totalFamilySteps: 0, totalFamilyCalories: 0, totalFamilyDistance: 0, averageFamilyHeartRate: 0, totalFamilySleep: 0, mostActiveMember: "", mostStepsInDay: 0, bestDay: "")
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Enhanced Dashboard Tab
            EnhancedHealthDashboard(
                currentUser: Binding(
                    get: { familyManager.currentUser ?? FamilyMember.sampleCurrentUser },
                    set: { familyManager.currentUser = $0 }
                ),
                familyMembers: $familyManager.familyMembers,
                weeklyDigest: $weeklyDigest
            )
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }
            .tag(0)
            
            // Family Tab
            FamilyMembersView(
                familyMembers: $familyManager.familyMembers,
                showAddFamilyMember: $showAddFamilyMember
            )
            .tabItem {
                Label("Family", systemImage: "person.3.fill")
            }
            .tag(1)
            
            // Activity Feed Tab
            FamilyActivityFeed()
                .tabItem {
                    Label("Activity", systemImage: "heart.text.square")
                }
                .tag(2)
            
            // Challenges Tab
            ChallengesView()
                .tabItem {
                    Label("Challenges", systemImage: "gamecontroller.fill")
                }
                .tag(3)
            
            // Analytics Tab
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(4)
            
            // Leaderboards Tab
            LeaderboardsView(
                currentUser: Binding(
                    get: { familyManager.currentUser ?? FamilyMember.sampleCurrentUser },
                    set: { familyManager.currentUser = $0 }
                ),
                familyMembers: $familyManager.familyMembers
            )
            .tabItem {
                Label("Leaderboards", systemImage: "trophy.fill")
            }
                .tag(5)
            
            // Settings Tab
            SettingsView(
                currentUser: Binding(
                    get: { familyManager.currentUser ?? FamilyMember.sampleCurrentUser },
                    set: { familyManager.currentUser = $0 }
                ),
                familyMembers: $familyManager.familyMembers,
                isHealthKitAuthorized: $isHealthKitAuthorized
            )
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
                .tag(6)
        }
        .accentColor(.blue)
        .onAppear {
            // Initialize family manager and load data
            familyManager.fetchFamilyData()
            setupHealthKit()
            updateWeeklyDigest()
        }
        .sheet(isPresented: $showAddFamilyMember) {
            FamilyInvitationView()
        }
        .sheet(isPresented: $showFamilyInvitation) {
            FamilyInvitationView()
        }
    }
    
    private func setupHealthKit() {
        // Request HealthKit authorization
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        ]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            DispatchQueue.main.async {
                self.isHealthKitAuthorized = success
                if success {
                    self.fetchTodayHealthData()
                }
            }
        }
    }
    
    private func fetchTodayHealthData() {
        // Fetch today's health data for current user
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch steps
        if let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) {
            let stepQuery = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate), options: .cumulativeSum) { _, result, _ in
                if let result = result, let sum = result.sumQuantity() {
                    DispatchQueue.main.async {
                        self.familyManager.currentUser?.todaySteps = Int(sum.doubleValue(for: HKUnit.count()))
                        self.familyManager.currentUser?.checkBadges()
                        self.familyManager.syncCurrentUserData()
                        self.updateWeeklyDigest()
                    }
                }
            }
            healthStore.execute(stepQuery)
        }
        
        // Fetch heart rate
        if let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) {
            let heartRateQuery = HKStatisticsQuery(quantityType: heartRateType, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate), options: .discreteAverage) { _, result, _ in
                if let result = result, let average = result.averageQuantity() {
                    DispatchQueue.main.async {
                        self.familyManager.currentUser?.todayHeartRate = Int(average.doubleValue(for: HKUnit(from: "count/min")))
                        self.familyManager.syncCurrentUserData()
                        self.updateWeeklyDigest()
                    }
                }
            }
            healthStore.execute(heartRateQuery)
        }
        
        // Fetch calories
        if let calorieType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) {
            let calorieQuery = HKStatisticsQuery(quantityType: calorieType, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate), options: .cumulativeSum) { _, result, _ in
                if let result = result, let sum = result.sumQuantity() {
                    DispatchQueue.main.async {
                        self.familyManager.currentUser?.todayCalories = Int(sum.doubleValue(for: HKUnit.kilocalorie()))
                        self.familyManager.currentUser?.checkBadges()
                        self.familyManager.syncCurrentUserData()
                        self.updateWeeklyDigest()
                    }
                }
            }
            healthStore.execute(calorieQuery)
        }
        
        // Fetch distance
        if let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) {
            let distanceQuery = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate), options: .cumulativeSum) { _, result, _ in
                if let result = result, let sum = result.sumQuantity() {
                    DispatchQueue.main.async {
                        self.familyManager.currentUser?.todayDistance = sum.doubleValue(for: HKUnit.meter()) / 1000.0 // Convert to km
                        self.familyManager.currentUser?.checkBadges()
                        self.familyManager.syncCurrentUserData()
                        self.updateWeeklyDigest()
                    }
                }
            }
            healthStore.execute(distanceQuery)
        }
        
        // Fetch sleep (simplified)
        if let sleepType = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis) {
            let sleepQuery = HKSampleQuery(sampleType: sleepType, predicate: HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate), limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                if let samples = samples as? [HKCategorySample] {
                    let totalSleep = samples.reduce(0.0) { total, sample in
                        return total + sample.endDate.timeIntervalSince(sample.startDate) / 3600.0 // Convert to hours
                    }
                    DispatchQueue.main.async {
                        self.familyManager.currentUser?.todaySleep = totalSleep
                        self.familyManager.currentUser?.checkBadges()
                        self.familyManager.syncCurrentUserData()
                        self.updateWeeklyDigest()
                    }
                }
            }
            healthStore.execute(sleepQuery)
        }
    }
    
    private func loadFamilyMembers() {
        // Family members are now loaded through FamilyManager
        // This method is kept for compatibility but data comes from CloudKit
        updateWeeklyDigest()
    }
    
    private func updateWeeklyDigest() {
        let allMembers = familyManager.familyMembers + (familyManager.currentUser != nil ? [familyManager.currentUser!] : [])
        weeklyDigest = WeeklyHealthDigest.generate(from: allMembers)
    }
}

// MARK: - Enhanced Dashboard Views
struct FamilyDashboardView: View {
    @Binding var currentUser: FamilyMember
    @Binding var familyMembers: [FamilyMember]
    @Binding var weeklyDigest: WeeklyHealthDigest
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with current user stats
                    CurrentUserHeaderView(currentUser: $currentUser)
                    
                    // Activity Rings Section (Apple-style)
                    ActivityRingsSection(currentUser: currentUser)
                    
                    // Today's Progress with Progress Rings
                    TodayProgressSection(currentUser: currentUser)
                    
                    // Badges and Achievements
                    BadgesSection(currentUser: currentUser)
                    
                    // Family Overview
                    FamilyOverviewSection(familyMembers: familyMembers)
                    
                    // Weekly Summary
                    WeeklySummarySection(familyMembers: familyMembers)
                    
                    // Weekly Health Digest
                    WeeklyHealthDigestView(digest: weeklyDigest)
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Family Health")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Current User Header View
struct CurrentUserHeaderView: View {
    @Binding var currentUser: FamilyMember
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back,")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(currentUser.name)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(currentUser.rank)
                        .font(.title)
                    
                    Text(currentUser.title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            // Current streak
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                
                Text("\(currentUser.currentStreak) day streak")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Best: \(currentUser.longestStreak) days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.orange.opacity(0.1))
            )
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Activity Rings Section (Apple-style)
struct ActivityRingsSection: View {
    let currentUser: FamilyMember
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Activity")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("Close your rings!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            
            HStack(spacing: 20) {
                // Steps Ring
                VStack(spacing: 8) {
                    ZStack {
                        ProgressRing(
                            progress: currentUser.todayStepsProgress,
                            ringWidth: 8,
                            color: .green,
                            size: 80
                        )
                        
                        VStack(spacing: 2) {
                            Text("\(currentUser.todaySteps)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("steps")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Steps")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Calories Ring
                VStack(spacing: 8) {
                    ZStack {
                        ProgressRing(
                            progress: currentUser.todayCaloriesProgress,
                            ringWidth: 8,
                            color: .orange,
                            size: 80
                        )
                        
                        VStack(spacing: 2) {
                            Text("\(currentUser.todayCalories)")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("cal")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Calories")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                // Distance Ring
                VStack(spacing: 8) {
                    ZStack {
                        ProgressRing(
                            progress: currentUser.todayDistanceProgress,
                            ringWidth: 8,
                            color: .blue,
                            size: 80
                        )
                        
                        VStack(spacing: 2) {
                            Text(String(format: "%.1f", currentUser.todayDistance))
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("km")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Text("Distance")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Today's Progress Section
struct TodayProgressSection: View {
    let currentUser: FamilyMember
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("vs. Goals")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            
            VStack(spacing: 16) {
                ProgressRow(
                    title: "Steps",
                    current: Double(currentUser.todaySteps),
                    goal: 10000,
                    color: .green,
                    icon: "figure.walk"
                )
                
                ProgressRow(
                    title: "Calories",
                    current: Double(currentUser.todayCalories),
                    goal: 500,
                    color: .orange,
                    icon: "flame"
                )
                
                ProgressRow(
                    title: "Distance",
                    current: currentUser.todayDistance,
                    goal: 10.0,
                    color: .blue,
                    icon: "location.fill",
                    isDistance: true
                )
                
                ProgressRow(
                    title: "Sleep",
                    current: currentUser.todaySleep,
                    goal: 8.0,
                    color: .purple,
                    icon: "bed.double.fill",
                    isDistance: true
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Progress Row
struct ProgressRow: View {
    let title: String
    let current: Double
    let goal: Double
    let color: Color
    let icon: String
    var isDistance: Bool = false
    
    private var progress: Double {
        min(current / goal, 1.0)
    }
    
    private var displayCurrent: String {
        if isDistance {
            return String(format: "%.1f", current)
        } else {
            return String(format: "%.0f", current)
        }
    }
    
    private var displayGoal: String {
        if isDistance {
            return String(format: "%.1f", goal)
        } else {
            return String(format: "%.0f", goal)
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text("\(displayCurrent) / \(displayGoal)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: color))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
        }
    }
}

// MARK: - Badges Section
struct BadgesSection: View {
    let currentUser: FamilyMember
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Badges & Achievements")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(currentUser.badges.filter { $0.isUnlocked }.count) unlocked")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(Badge.allBadges) { badge in
                    BadgeView(badge: badge, isUnlocked: currentUser.badges.contains { $0.id == badge.id && $0.isUnlocked })
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Badge View
struct BadgeView: View {
    let badge: Badge
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? badge.color : Color(.systemGray4))
                    .frame(width: 50, height: 50)
                
                Image(systemName: badge.icon)
                    .font(.title2)
                    .foregroundColor(isUnlocked ? .white : Color(.systemGray))
            }
            
            Text(badge.name)
                .font(.caption2)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(isUnlocked ? .primary : .secondary)
        }
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

// MARK: - Family Overview Section
struct FamilyOverviewSection: View {
    let familyMembers: [FamilyMember]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Family Overview")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(familyMembers.count) members")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            
            VStack(spacing: 12) {
                ForEach(familyMembers) { member in
                    FamilyMemberCard(member: member)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Family Member Card
struct FamilyMemberCard: View {
    let member: FamilyMember
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            HStack(spacing: 16) {
                // Avatar
                    Circle()
                        .fill(member.color)
                    .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(member.name.prefix(1)))
                            .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                // Member info and metrics
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                                .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(member.relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                        // Achievement badge
                        HStack(spacing: 4) {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        
                        Text(member.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    }
                    
                    // Health metrics in a compact row
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                        Text("\(member.todaySteps)")
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                        VStack(alignment: .leading, spacing: 2) {
                        Text("\(member.todayCalories)")
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                        VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", member.todayDistance))
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                        
                        Spacer()
                }
                
                    // Status and streak
                HStack {
                    Circle()
                        .fill(member.isOnline ? Color.green : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(member.isOnline ? "Online" : "Offline")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(member.currentStreak) day streak")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            FamilyMemberDetailView(member: member)
        }
    }
}

// MARK: - Family Member Detail View
struct FamilyMemberDetailView: View {
    let member: FamilyMember
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 16) {
                        Circle()
                            .fill(member.color)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(String(member.name.prefix(1)))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            )
                        
                        VStack(spacing: 4) {
                            Text(member.name)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text(member.relationship)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text(member.rank + " " + member.title)
                                .font(.headline)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    // Today's Stats with Progress Rings
                    VStack(spacing: 20) {
                        Text("Today's Activity")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            ProgressRing(
                                progress: member.todayStepsProgress,
                                ringWidth: 8,
                                color: .green,
                                size: 80
                            )
                            
                            ProgressRing(
                                progress: member.todayCaloriesProgress,
                                ringWidth: 8,
                                color: .orange,
                                size: 80
                            )
                            
                            ProgressRing(
                                progress: member.todayDistanceProgress,
                                ringWidth: 8,
                                color: .blue,
                                size: 80
                            )
                        }
                        
                        HStack(spacing: 20) {
                            VStack(spacing: 4) {
                                Text("\(member.todaySteps)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("Steps")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text("\(member.todayCalories)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.orange)
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            VStack(spacing: 4) {
                                Text(String(format: "%.1f", member.todayDistance))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Distance")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    // Weekly Stats
                    VStack(spacing: 20) {
                        Text("Weekly Summary")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        VStack(spacing: 16) {
                            StatRow(title: "Total Steps", value: "\(member.weeklySteps)", color: .green)
                            StatRow(title: "Total Calories", value: "\(member.weeklyCalories)", color: .orange)
                            StatRow(title: "Total Distance", value: String(format: "%.1f km", member.weeklyDistance), color: .blue)
                            StatRow(title: "Active Days", value: "\(member.activeDays)/7", color: .purple)
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                    
                    // Badges
                    VStack(spacing: 20) {
                        Text("Badges")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            ForEach(member.badges) { badge in
                                BadgeView(badge: badge, isUnlocked: badge.isUnlocked)
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    )
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Member Details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

// MARK: - Stat Row
struct StatRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

// MARK: - Enhanced Family Members View
struct FamilyMembersView: View {
    @Binding var familyMembers: [FamilyMember]
    @Binding var showAddFamilyMember: Bool
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Family Stats Summary
                    FamilyStatsSummary(familyMembers: familyMembers)
                    
                    // Family Members List
                    VStack(spacing: 12) {
                        ForEach(familyMembers) { member in
                            EnhancedFamilyMemberCard(member: member)
                        }
                    }
                    
                    // Add Family Member Button
                    Button(action: {
                        showAddFamilyMember = true
                    }) {
                        HStack {
                            Image(systemName: "person.badge.plus")
                                .font(.title2)
                            
                            Text("Add Family Member")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Family Members")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Family Stats Summary
struct FamilyStatsSummary: View {
    let familyMembers: [FamilyMember]
    
    private var totalSteps: Int {
        familyMembers.reduce(0) { $0 + $1.todaySteps }
    }
    
    private var totalCalories: Int {
        familyMembers.reduce(0) { $0 + $1.todayCalories }
    }
    
    private var totalDistance: Double {
        familyMembers.reduce(0.0) { $0 + $1.todayDistance }
    }
    
    private var averageHeartRate: Int {
        let total = familyMembers.reduce(0) { $0 + $1.todayHeartRate }
        return familyMembers.isEmpty ? 0 : total / familyMembers.count
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Family Health Summary")
                .font(.title2)
                .fontWeight(.bold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                SummaryCard(
                    title: "Total Steps",
                    value: "\(totalSteps)",
                    icon: "figure.walk",
                    color: .green
                )
                
                SummaryCard(
                    title: "Total Calories",
                    value: "\(totalCalories)",
                    icon: "flame",
                    color: .orange
                )
                
                SummaryCard(
                    title: "Total Distance",
                    value: String(format: "%.1f km", totalDistance),
                    icon: "location.fill",
                    color: .blue
                )
                
                SummaryCard(
                    title: "Avg Heart Rate",
                    value: "\(averageHeartRate) bpm",
                    icon: "heart.fill",
                    color: .red
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Summary Card
struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Enhanced Family Member Card
struct EnhancedFamilyMemberCard: View {
    let member: FamilyMember
    @State private var showDetail = false
    
    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            HStack(spacing: 16) {
                // Avatar
                    Circle()
                        .fill(member.color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(member.name.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                // Member info and metrics
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(member.relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                        // Achievement badge
                        HStack(spacing: 4) {
                            Image(systemName: "medal.fill")
                                .foregroundColor(.yellow)
                                .font(.caption)
                        
                        Text(member.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.yellow.opacity(0.1))
                        )
                    }
                    
                    // Health metrics in a compact row
                HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 2) {
                        Text("\(member.todaySteps)")
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                            
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                        VStack(alignment: .leading, spacing: 2) {
                        Text("\(member.todayCalories)")
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            
                        Text("cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                        VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%.1f", member.todayDistance))
                                .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            
                        Text("km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                        
                        Spacer()
                }
                
                    // Status and streak
                HStack {
                        Circle()
                            .fill(member.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(member.isOnline ? "Online" : "Offline")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                            .font(.caption2)
                        
                        Text("\(member.currentStreak) day streak")
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showDetail) {
            FamilyMemberDetailView(member: member)
        }
    }
}

// MARK: - Weekly Summary Section
struct WeeklySummarySection: View {
    let familyMembers: [FamilyMember]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Weekly Summary")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("This week")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray5))
                    )
                }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                WeeklySummaryCard(
                    title: "Total Steps",
                    value: "\(familyMembers.reduce(0) { $0 + $1.weeklySteps })",
                    icon: "figure.walk",
                    color: .green
                )
                
                WeeklySummaryCard(
                    title: "Total Calories",
                    value: "\(familyMembers.reduce(0) { $0 + $1.weeklyCalories })",
                    icon: "flame",
                    color: .orange
                )
                
                WeeklySummaryCard(
                    title: "Total Distance",
                    value: String(format: "%.1f km", familyMembers.reduce(0.0) { $0 + $1.weeklyDistance }),
                    icon: "location.fill",
                    color: .blue
                )
                
                WeeklySummaryCard(
                    title: "Active Days",
                    value: "\(familyMembers.reduce(0) { $0 + $1.activeDays })",
                    icon: "calendar",
                    color: .purple
                )
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Weekly Summary Card
struct WeeklySummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Add Family Member View
struct AddFamilyMemberView: View {
    @Binding var familyMembers: [FamilyMember]
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var relationship = "Family Member"
    @State private var appleID = ""
    @State private var selectedColor: Color = .blue
    
    private let relationships = ["Parent", "Child", "Sibling", "Spouse", "Family Member"]
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .indigo, .teal]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Member Information")) {
                    TextField("Name", text: $name)
                    
                    Picker("Relationship", selection: $relationship) {
                        ForEach(relationships, id: \.self) { rel in
                            Text(rel).tag(rel)
                        }
                    }
                    
                    TextField("Apple ID (Optional)", text: $appleID)
                }
                
                Section(header: Text("Color")) {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 30, height: 30)
                                .overlay(
                                    Circle()
                                        .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                }
            }
            .navigationTitle("Add Family Member")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Add") {
                    addFamilyMember()
                }
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func addFamilyMember() {
        let newMember = FamilyMember(
            name: name,
            relationship: relationship,
            appleID: appleID,
            color: selectedColor,
            isOnline: true,
            isCurrentUser: false,
            lastUpdated: Date(),
            createdDate: Date(),
            healthMetrics: HealthMetrics(),
            workoutHistory: [],
            nutritionHistory: [],
            mentalHealthHistory: [],
            healthGoals: HealthGoals(),
            preferences: UserPreferences(),
            notifications: NotificationSettings(),
            weeklySteps: 0,
            weeklyCalories: 0,
            weeklyDistance: 0.0,
            activeDays: 0,
            monthlySteps: 0,
            monthlyCalories: 0,
            monthlyDistance: 0.0,
            currentStreak: 0,
            longestStreak: 0,
            badges: [],
            achievements: [],
            weeklyTrends: []
        )
        
        familyMembers.append(newMember)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Enhanced Leaderboards View with Gamification
struct LeaderboardsView: View {
    @Binding var currentUser: FamilyMember
    @Binding var familyMembers: [FamilyMember]
    
    private var allMembers: [FamilyMember] {
        [currentUser] + familyMembers
    }
    
    private var sortedBySteps: [FamilyMember] {
        allMembers.sorted { $0.todaySteps > $1.todaySteps }
    }
    
    private var sortedByCalories: [FamilyMember] {
        allMembers.sorted { $0.todayCalories > $1.todayCalories }
    }
    
    private var sortedByDistance: [FamilyMember] {
        allMembers.sorted { $0.todayDistance > $1.todayDistance }
    }
    
    private var sortedByStreak: [FamilyMember] {
        allMembers.sorted { $0.currentStreak > $1.currentStreak }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Today's Champions
                    ChampionsSection(sortedMembers: sortedBySteps)
                    
                    // Steps Leaderboard
                    LeaderboardSection(
                        title: "Steps Champion",
                        subtitle: "Most steps today",
                        members: sortedBySteps,
                        metric: "steps",
                        color: .green,
                        icon: "figure.walk"
                    )
                    
                    // Calories Leaderboard
                    LeaderboardSection(
                        title: "Calorie Burner",
                        subtitle: "Most calories burned",
                        members: sortedByCalories,
                        metric: "cal",
                        color: .orange,
                        icon: "flame"
                    )
                    
                    // Distance Leaderboard
                    LeaderboardSection(
                        title: "Distance Master",
                        subtitle: "Longest distance today",
                        members: sortedByDistance,
                        metric: "km",
                        color: .blue,
                        icon: "location.fill"
                    )
                    
                    // Streak Leaderboard
                    LeaderboardSection(
                        title: "Streak Champion",
                        subtitle: "Longest active streak",
                        members: sortedByStreak,
                        metric: "days",
                        color: .purple,
                        icon: "flame.fill"
                    )
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Leaderboards")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Champions Section
struct ChampionsSection: View {
    let sortedMembers: [FamilyMember]
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Today's Champions")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                // Gold Medal
                if sortedMembers.count > 0 {
                    ChampionCard(
                        member: sortedMembers[0],
                        rank: "🥇",
                        title: "Gold",
                        color: .yellow
                    )
                }
                
                // Silver Medal
                if sortedMembers.count > 1 {
                    ChampionCard(
                        member: sortedMembers[1],
                        rank: "🥈",
                        title: "Silver",
                        color: .gray
                    )
                }
                
                // Bronze Medal
                if sortedMembers.count > 2 {
                    ChampionCard(
                        member: sortedMembers[2],
                        rank: "🥉",
                        title: "Bronze",
                        color: .brown
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Champion Card
struct ChampionCard: View {
    let member: FamilyMember
    let rank: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Text(rank)
                .font(.title)
            
            Circle()
                .fill(member.color)
                .frame(width: 50, height: 50)
                .overlay(
                    Text(String(member.name.prefix(1)))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            Text(member.name)
                .font(.caption)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(color)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Leaderboard Section
struct LeaderboardSection: View {
    let title: String
    let subtitle: String
    let members: [FamilyMember]
    let metric: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(spacing: 12) {
                ForEach(Array(members.enumerated()), id: \.element.id) { index, member in
                    LeaderboardRow(
                        member: member,
                        rank: index + 1,
                        metric: metric,
                        color: color
                    )
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
}

// MARK: - Leaderboard Row
struct LeaderboardRow: View {
    let member: FamilyMember
    let rank: Int
    let metric: String
    let color: Color
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }
    
    private var metricValue: String {
        switch metric {
        case "steps":
            return "\(member.todaySteps)"
        case "cal":
            return "\(member.todayCalories)"
        case "km":
            return String(format: "%.1f", member.todayDistance)
        case "days":
            return "\(member.currentStreak)"
        default:
            return "0"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Text(rankEmoji)
                .font(.title3)
                .foregroundColor(rankColor)
                .frame(width: 30)
            
            Circle()
                .fill(member.color)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(member.name.prefix(1)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(member.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(member.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(metricValue)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(metric)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @Binding var currentUser: FamilyMember
    @Binding var familyMembers: [FamilyMember]
    @Binding var isHealthKitAuthorized: Bool
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Health Data")) {
                    HStack {
                        Text("HealthKit Access")
                        Spacer()
                        Text(isHealthKitAuthorized ? "Authorized" : "Not Authorized")
                            .foregroundColor(isHealthKitAuthorized ? .green : .red)
                    }
                    
                    if !isHealthKitAuthorized {
                        Button("Request HealthKit Access") {
                            // This would trigger HealthKit authorization
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("App Information")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("1")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Data Management")) {
                    Button("Export Family Data") {
                        // Export functionality
                    }
                    .foregroundColor(.blue)
                    
                    Button("Clear All Data") {
                        // Clear data functionality
                    }
                    .foregroundColor(.red)
                }
                
                Section(header: Text("About")) {
                    Text("Family Health is designed to help families stay healthy together by sharing and comparing health data in a fun, competitive way.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Data Models
struct FamilyMember: Identifiable, Codable {
    let id = UUID()
    let name: String
    let relationship: String
    let appleID: String
    let color: Color
    var isOnline: Bool
    var isCurrentUser: Bool = false
    var lastUpdated: Date = Date()
    var createdDate: Date = Date()
    
    // Enhanced health data
    var healthMetrics: HealthMetrics = HealthMetrics()
    var workoutHistory: [WorkoutData] = []
    var nutritionHistory: [NutritionData] = []
    var mentalHealthHistory: [MentalHealthData] = []
    var healthGoals: HealthGoals = HealthGoals()
    var preferences: UserPreferences = UserPreferences()
    var notifications: NotificationSettings = NotificationSettings()
    
    // Legacy properties for backward compatibility
    var todaySteps: Int {
        get { healthMetrics.steps }
        set { healthMetrics.steps = newValue }
    }
    var todayHeartRate: Int {
        get { healthMetrics.heartRate }
        set { healthMetrics.heartRate = newValue }
    }
    var todayCalories: Int {
        get { healthMetrics.calories }
        set { healthMetrics.calories = newValue }
    }
    var todayDistance: Double {
        get { healthMetrics.distance }
        set { healthMetrics.distance = newValue }
    }
    var todaySleep: Double {
        get { healthMetrics.sleep }
        set { healthMetrics.sleep = newValue }
    }
    
    // Weekly data
    var weeklySteps: Int = 0
    var weeklyCalories: Int = 0
    var weeklyDistance: Double = 0.0
    var activeDays: Int = 0
    
    // Monthly data
    var monthlySteps: Int = 0
    var monthlyCalories: Int = 0
    var monthlyDistance: Double = 0.0
    
    // Streaks and achievements
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var badges: [Badge] = []
    var achievements: [Achievement] = []
    
    // Weekly trends (last 7 days)
    var weeklyTrends: [DailyData] = []
    
    // Goals
    var dailyStepGoal: Int = 10000
    var dailyCalorieGoal: Int = 500
    var dailyDistanceGoal: Double = 5.0
    
    var initials: String {
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            return "\(components[0].prefix(1))\(components[1].prefix(1))"
        } else {
            return String(name.prefix(2))
        }
    }
    
    // Computed properties
    var todayStepsProgress: Double {
        min(Double(todaySteps) / 10000.0, 1.0)
    }
    
    var todayCaloriesProgress: Double {
        min(Double(todayCalories) / 500.0, 1.0)
    }
    
    var todayDistanceProgress: Double {
        min(todayDistance / 10.0, 1.0)
    }
    
    var todaySleepProgress: Double {
        min(todaySleep / 8.0, 1.0)
    }
    
    var weeklyStepsProgress: Double {
        min(Double(weeklySteps) / 70000.0, 1.0)
    }
    
    var weeklyCaloriesProgress: Double {
        min(Double(weeklyCalories) / 3500.0, 1.0)
    }
    
    var weeklyDistanceProgress: Double {
        min(weeklyDistance / 50.0, 1.0)
    }
    
    var weeklyActiveProgress: Double {
        min(Double(activeDays) / 7.0, 1.0)
    }
    
    // Rank calculations
    var rank: String {
        if todaySteps >= 12000 { return "🥇" }
        if todaySteps >= 10000 { return "🥈" }
        if todaySteps >= 8000 { return "🥉" }
        if todaySteps >= 6000 { return "🏃‍♂️" }
        return "🚶‍♂️"
    }
    
    var title: String {
        if todaySteps >= 12000 { return "Elite Walker" }
        if todaySteps >= 10000 { return "Top Walker" }
        if todaySteps >= 8000 { return "Active Walker" }
        if todaySteps >= 6000 { return "Casual Walker" }
        return "Getting Started"
    }
    
    // Badge checking
    mutating func checkBadges() {
        // 7-Day Streak
        if let streakBadge = badges.first(where: { $0.name == "7-Day Streak" }) {
            if currentStreak >= 7 && !streakBadge.isUnlocked {
                if let index = badges.firstIndex(where: { $0.name == "7-Day Streak" }) {
                    badges[index] = Badge(name: "7-Day Streak", description: "7 consecutive active days", icon: "flame.fill", color: .orange, isUnlocked: true, unlockedDate: Date())
                }
            }
        }
        
        // 10K Steps
        if let stepsBadge = badges.first(where: { $0.name == "10K Steps" }) {
            if todaySteps >= 10000 && !stepsBadge.isUnlocked {
                if let index = badges.firstIndex(where: { $0.name == "10K Steps" }) {
                    badges[index] = Badge(name: "10K Steps", description: "10,000+ steps in a day", icon: "figure.walk", color: .green, isUnlocked: true, unlockedDate: Date())
                }
            }
        }
        
        // Calorie Burner
        if let calorieBadge = badges.first(where: { $0.name == "Calorie Burner" }) {
            if todayCalories >= 500 && !calorieBadge.isUnlocked {
                if let index = badges.firstIndex(where: { $0.name == "Calorie Burner" }) {
                    badges[index] = Badge(name: "Calorie Burner", description: "500+ calories burned", icon: "flame", color: .orange, isUnlocked: true, unlockedDate: Date())
                }
            }
        }
        
        // Distance Master
        if let distanceBadge = badges.first(where: { $0.name == "Distance Master" }) {
            if todayDistance >= 10.0 && !distanceBadge.isUnlocked {
                if let index = badges.firstIndex(where: { $0.name == "Distance Master" }) {
                    badges[index] = Badge(name: "Distance Master", description: "10+ km in a day", icon: "location.fill", color: .blue, isUnlocked: true, unlockedDate: Date())
                }
            }
        }
        
        // Sleep Champion
        if let sleepBadge = badges.first(where: { $0.name == "Sleep Champion" }) {
            if todaySleep >= 8.0 && !sleepBadge.isUnlocked {
                if let index = badges.firstIndex(where: { $0.name == "Sleep Champion" }) {
                    badges[index] = Badge(name: "Sleep Champion", description: "8+ hours of sleep", icon: "bed.double.fill", color: .purple, isUnlocked: true, unlockedDate: Date())
                }
            }
        }
    }
    
    static let sampleCurrentUser = FamilyMember(
        name: "John Doe",
        relationship: "Parent",
        appleID: "john.doe@icloud.com",
        color: .blue,
        isOnline: true,
        isCurrentUser: true,
        lastUpdated: Date(),
        createdDate: Date(),
        healthMetrics: HealthMetrics(
            steps: 8432,
            heartRate: 72,
            calories: 420,
            distance: 6.8,
            sleep: 7.5,
            bloodPressureSystolic: 120,
            bloodPressureDiastolic: 80,
            weight: 75.0,
            bmi: 23.5,
            bodyFatPercentage: 18.0,
            vo2Max: 42.0,
            workoutMinutes: 25,
            activeCalories: 180,
            exerciseMinutes: 20,
            standHours: 9,
            waterIntake: 2.2,
            calorieIntake: 2200,
            protein: 110.0,
            carbs: 280.0,
            fat: 85.0,
            moodScore: 7,
            stressLevel: 4,
            meditationMinutes: 5,
            mindfulnessScore: 6
        ),
        workoutHistory: [],
        nutritionHistory: [],
        mentalHealthHistory: [],
        healthGoals: HealthGoals(),
        preferences: UserPreferences(),
        notifications: NotificationSettings(),
        weeklySteps: 45000,
        weeklyCalories: 2800,
        weeklyDistance: 35.2,
        activeDays: 6,
        monthlySteps: 180000,
        monthlyCalories: 12000,
        monthlyDistance: 140.8,
        currentStreak: 5,
        longestStreak: 12,
        badges: [
            Badge(name: "7-Day Streak", description: "7 consecutive active days", icon: "flame.fill", color: .orange, isUnlocked: true, unlockedDate: Date().addingTimeInterval(-86400)),
            Badge(name: "10K Steps", description: "10,000+ steps in a day", icon: "figure.walk", color: .green, isUnlocked: false, unlockedDate: nil),
            Badge(name: "Calorie Burner", description: "500+ calories burned", icon: "flame", color: .orange, isUnlocked: false, unlockedDate: nil),
            Badge(name: "Distance Master", description: "10+ km in a day", icon: "location.fill", color: .blue, isUnlocked: false, unlockedDate: nil),
            Badge(name: "Sleep Champion", description: "8+ hours of sleep", icon: "bed.double.fill", color: .purple, isUnlocked: true, unlockedDate: Date().addingTimeInterval(-172800)),
            Badge(name: "Early Bird", description: "Active before 7 AM", icon: "sunrise.fill", color: .yellow, isUnlocked: true, unlockedDate: Date().addingTimeInterval(-259200)),
            Badge(name: "Night Owl", description: "Active after 10 PM", icon: "moon.fill", color: .indigo, isUnlocked: false, unlockedDate: nil),
            Badge(name: "Weekend Warrior", description: "Active on weekends", icon: "calendar", color: .pink, isUnlocked: true, unlockedDate: Date().addingTimeInterval(-345600)),
            Badge(name: "Marathon Walker", description: "20,000+ steps in a day", icon: "figure.walk.circle.fill", color: .red, isUnlocked: false, unlockedDate: nil),
            Badge(name: "Consistency King", description: "30 days of activity", icon: "crown.fill", color: .yellow, isUnlocked: false, unlockedDate: nil)
        ],
        achievements: [],
        weeklyTrends: []
    )
    
    static let sampleFamilyMembers = [
        FamilyMember(
            name: "Sarah Doe",
            relationship: "Parent",
            appleID: "sarah.doe@icloud.com",
            color: .green,
            isOnline: true,
            isCurrentUser: false,
            lastUpdated: Date(),
            createdDate: Date(),
            healthMetrics: HealthMetrics(
                steps: 9200,
                heartRate: 68,
                calories: 480,
                distance: 7.2,
                sleep: 8.0,
                bloodPressureSystolic: 115,
                bloodPressureDiastolic: 75,
                weight: 65.0,
                bmi: 22.0,
                bodyFatPercentage: 20.0,
                vo2Max: 48.0,
                workoutMinutes: 35,
                activeCalories: 220,
                exerciseMinutes: 30,
                standHours: 11,
                waterIntake: 2.8,
                calorieIntake: 1900,
                protein: 95.0,
                carbs: 220.0,
                fat: 70.0,
                moodScore: 8,
                stressLevel: 2,
                meditationMinutes: 15,
                mindfulnessScore: 8
            ),
            workoutHistory: [],
            nutritionHistory: [],
            mentalHealthHistory: [],
            healthGoals: HealthGoals(),
            preferences: UserPreferences(),
            notifications: NotificationSettings(),
            weeklySteps: 52000,
            weeklyCalories: 3100,
            weeklyDistance: 40.1,
            activeDays: 7,
            monthlySteps: 200000,
            monthlyCalories: 13500,
            monthlyDistance: 155.3,
            currentStreak: 7,
            longestStreak: 15,
            badges: Badge.allBadges,
            achievements: [],
            weeklyTrends: []
        ),
        FamilyMember(
            name: "Emma Doe",
            relationship: "Child",
            appleID: "emma.doe@icloud.com",
            color: .orange,
            isOnline: false,
            isCurrentUser: false,
            lastUpdated: Date(),
            createdDate: Date(),
            healthMetrics: HealthMetrics(
                steps: 6500,
                heartRate: 75,
                calories: 320,
                distance: 4.8,
                sleep: 9.0,
                bloodPressureSystolic: 110,
                bloodPressureDiastolic: 70,
                weight: 45.0,
                bmi: 18.5,
                bodyFatPercentage: 22.0,
                vo2Max: 35.0,
                workoutMinutes: 20,
                activeCalories: 150,
                exerciseMinutes: 15,
                standHours: 8,
                waterIntake: 1.8,
                calorieIntake: 1800,
                protein: 70.0,
                carbs: 200.0,
                fat: 60.0,
                moodScore: 9,
                stressLevel: 1,
                meditationMinutes: 5,
                mindfulnessScore: 7
            ),
            workoutHistory: [],
            nutritionHistory: [],
            mentalHealthHistory: [],
            healthGoals: HealthGoals(),
            preferences: UserPreferences(),
            notifications: NotificationSettings(),
            weeklySteps: 38000,
            weeklyCalories: 2100,
            weeklyDistance: 28.5,
            activeDays: 5,
            monthlySteps: 150000,
            monthlyCalories: 9500,
            monthlyDistance: 110.2,
            currentStreak: 3,
            longestStreak: 8,
            badges: Badge.allBadges,
            achievements: [],
            weeklyTrends: []
        ),
        FamilyMember(
            name: "Mike Doe",
            relationship: "Child",
            appleID: "mike.doe@icloud.com",
            color: .purple,
            isOnline: true,
            isCurrentUser: false,
            lastUpdated: Date(),
            createdDate: Date(),
            healthMetrics: HealthMetrics(
                steps: 7800,
                heartRate: 70,
                calories: 380,
                distance: 5.9,
                sleep: 7.0,
                bloodPressureSystolic: 105,
                bloodPressureDiastolic: 65,
                weight: 50.0,
                bmi: 19.0,
                bodyFatPercentage: 18.0,
                vo2Max: 38.0,
                workoutMinutes: 25,
                activeCalories: 170,
                exerciseMinutes: 20,
                standHours: 9,
                waterIntake: 2.0,
                calorieIntake: 2000,
                protein: 80.0,
                carbs: 240.0,
                fat: 65.0,
                moodScore: 7,
                stressLevel: 3,
                meditationMinutes: 8,
                mindfulnessScore: 6
            ),
            workoutHistory: [],
            nutritionHistory: [],
            mentalHealthHistory: [],
            healthGoals: HealthGoals(),
            preferences: UserPreferences(),
            notifications: NotificationSettings(),
            weeklySteps: 42000,
            weeklyCalories: 2400,
            weeklyDistance: 32.8,
            activeDays: 6,
            monthlySteps: 165000,
            monthlyCalories: 10800,
            monthlyDistance: 125.6,
            currentStreak: 4,
            longestStreak: 10,
            badges: Badge.allBadges,
            achievements: [],
            weeklyTrends: []
        )
    ]
}

// MARK: - Color Extension for Codable
extension Color: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let hex = try container.decode(String.self)
        self.init(hex: hex)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(toHex)
    }
    

}





