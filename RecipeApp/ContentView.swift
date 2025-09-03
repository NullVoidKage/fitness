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
            todaySteps: todaySteps,
            todayHeartRate: todayHeartRate,
            todayCalories: todayCalories,
            todayDistance: todayDistance,
            todaySleep: todaySleep,
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
            // Dashboard Tab
            FamilyDashboardView(
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
            .tag(3)
            
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
            .tag(4)
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
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
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
            VStack(spacing: 12) {
                HStack {
                    Circle()
                        .fill(member.color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text(String(member.name.prefix(1)))
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(member.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text(member.relationship)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(member.rank)
                            .font(.title2)
                        
                        Text(member.title)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text("\(member.todaySteps)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(member.todayCalories)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Text("cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", member.todayDistance))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        Text("km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Online status
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
                    
                    // Family Members Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
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
            VStack(spacing: 16) {
                // Header
                HStack {
                    Circle()
                        .fill(member.color)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Text(String(member.name.prefix(1)))
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        )
                    
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
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(member.rank)
                            .font(.title2)
                        
                        Text(member.title)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                // Quick Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("\(member.todaySteps)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        Text("steps")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(member.todayCalories)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("cal")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", member.todayDistance))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        Text("km")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Status and Streak
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(member.isOnline ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                        
                        Text(member.isOnline ? "Online" : "Offline")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
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
                
                // Badge Preview
                if !member.badges.filter({ $0.isUnlocked }).isEmpty {
                    HStack {
                        Text("Badges:")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            ForEach(member.badges.filter { $0.isUnlocked }.prefix(3)) { badge in
                                Image(systemName: badge.icon)
                                    .font(.caption2)
                                    .foregroundColor(badge.color)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
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
            todaySteps: 0,
            todayHeartRate: 0,
            todayCalories: 0,
            todayDistance: 0.0,
            todaySleep: 0.0,
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
    
    // Today's data
    var todaySteps: Int = 0
    var todayHeartRate: Int = 0
    var todayCalories: Int = 0
    var todayDistance: Double = 0.0
    var todaySleep: Double = 0.0 // Added for sleep
    
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
        todaySteps: 8432,
        todayHeartRate: 72,
        todayCalories: 420,
        todayDistance: 6.8,
        todaySleep: 7.5,
        weeklySteps: 45000,
        weeklyCalories: 2800,
        weeklyDistance: 35.2,
        activeDays: 6,
        monthlySteps: 180000,
        monthlyCalories: 12000,
        monthlyDistance: 140.8,
        currentStreak: 5,
        longestStreak: 12,
        badges: Badge.allBadges,
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
            todaySteps: 9200,
            todayHeartRate: 68,
            todayCalories: 480,
            todayDistance: 7.2,
            todaySleep: 8.0,
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
            todaySteps: 6500,
            todayHeartRate: 75,
            todayCalories: 320,
            todayDistance: 4.8,
            todaySleep: 9.0,
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
            todaySteps: 7800,
            todayHeartRate: 70,
            todayCalories: 380,
            todayDistance: 5.9,
            todaySleep: 7.0,
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





