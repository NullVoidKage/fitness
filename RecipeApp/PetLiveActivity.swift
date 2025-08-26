import ActivityKit
import WidgetKit
import SwiftUI

struct PetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PetAttributes.self) { context in
            // Lock screen/banner UI goes here
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: context.state.petType.icon)
                                .font(.system(size: 24))
                                .foregroundColor(context.state.petType.color)
                            
                            Text(context.state.petName)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        
                        Text("Mood: \(context.state.petMood.description)")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Hunger")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: Double(context.state.hunger), total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .orange))
                                    .frame(width: 60, height: 4)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Energy")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                ProgressView(value: Double(context.state.energy), total: 100)
                                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                    .frame(width: 60, height: 4)
                            }
                        }
                        
                        Text("Last: \(context.state.lastInteraction, style: .relative)")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 16) {
                        Button("Feed") {
                            // Feed action
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange)
                        .cornerRadius(12)
                        
                        Button("Play") {
                            // Play action
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(12)
                        
                        Button("Sleep") {
                            // Sleep action
                        }
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                // Compact leading view
                HStack(spacing: 4) {
                    Image(systemName: context.state.petType.icon)
                        .font(.system(size: 16))
                        .foregroundColor(context.state.petType.color)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.3).repeatCount(3, autoreverses: true), value: context.state.petMood)
                    
                    Text(context.state.petName)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.primary)
                }
            } compactTrailing: {
                // Compact trailing view
                HStack(spacing: 4) {
                    // Hunger indicator
                    Circle()
                        .fill(context.state.hunger < 30 ? .red : .orange)
                        .frame(width: 8, height: 8)
                        .scaleEffect(context.state.hunger < 30 ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: context.state.hunger)
                    
                    // Energy indicator
                    Circle()
                        .fill(context.state.energy < 30 ? .red : .blue)
                        .frame(width: 8, height: 8)
                        .scaleEffect(context.state.energy < 30 ? 1.3 : 1.0)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: context.state.energy)
                }
            } minimal: {
                // Minimal view
                Image(systemName: context.state.petType.icon)
                    .font(.system(size: 16))
                    .foregroundColor(context.state.petType.color)
                    .scaleEffect(context.state.petMood == .happy ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.3).repeatCount(2, autoreverses: true), value: context.state.petMood)
            }
        }
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<PetAttributes>
    
    var body: some View {
        HStack(spacing: 16) {
            // Pet avatar with mood-based animation
            ZStack {
                Circle()
                    .fill(context.state.petType.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: context.state.petType.icon)
                    .font(.system(size: 30))
                    .foregroundColor(context.state.petType.color)
                    .scaleEffect(context.state.petMood == .happy ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: context.state.petMood)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(context.state.petName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(context.state.petType.name)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Text(context.state.petMood.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.orange)
                        
                        Text("\(context.state.hunger)%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.blue)
                        
                        Text("\(context.state.energy)%")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                    }
                }
            }
            
            Spacer()
            
            // Quick action buttons
            VStack(spacing: 8) {
                Button(action: {}) {
                    Image(systemName: "bowl.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.orange)
                        .cornerRadius(16)
                }
                
                Button(action: {}) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
    }
}

#Preview("Live Activity") {
    PetAttributes(
        petId: "Luna"
    )
    .previewContext(contentState: PetAttributes.ContentState(
        petName: "Luna",
        petType: .cat,
        petMood: .happy,
        hunger: 75,
        energy: 90,
        lastInteraction: Date()
    ), showsDismissWhenLocked: true)
}

// MARK: - Pet Attributes for Live Activity
struct PetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var petName: String
        var petType: PetType
        var petMood: PetMood
        var hunger: Int
        var energy: Int
        var lastInteraction: Date
    }
    
    var petId: String
}

// MARK: - Pet Type and Mood Enums (for Live Activity compatibility)
enum PetType: String, Codable, CaseIterable {
    case cat, dog, bird, robot
    
    var name: String {
        switch self {
        case .cat: return "Cat"
        case .dog: return "Dog"
        case .bird: return "Bird"
        case .robot: return "Robot"
        }
    }
    
    var emoji: String {
        switch self {
        case .cat: return "🐱"
        case .dog: return "🐕"
        case .bird: return "🐦"
        case .robot: return "🤖"
        }
    }
    
    var icon: String {
        switch self {
        case .cat: return "cat.fill"
        case .dog: return "dog.fill"
        case .bird: return "bird.fill"
        case .robot: return "cpu"
        }
    }
    
    var color: Color {
        switch self {
        case .cat: return .orange
        case .dog: return .brown
        case .bird: return .blue
        case .robot: return .purple
        }
    }
}

enum PetMood: String, Codable, CaseIterable {
    case happy, hungry, sleepy, sad
    
    var description: String {
        switch self {
        case .happy: return "Happy and playful! 😊"
        case .hungry: return "Hungry and needs food! 🍽️"
        case .sleepy: return "Sleepy and tired... 😴"
        case .sad: return "Sad and needs attention 😢"
        }
    }
    
    var color: Color {
        switch self {
        case .happy: return .green
        case .hungry: return .orange
        case .sleepy: return .blue
        case .sad: return .red
        }
    }
}

// MARK: - Live Activity Manager
class PetLiveActivityManager: ObservableObject {
    static let shared = PetLiveActivityManager()
    
    @Published var currentActivity: Activity<PetAttributes>?
    
    private init() {}
    
    func startLiveActivity(for pet: Pet) {
        let attributes = PetAttributes(petId: pet.name)
        let contentState = PetAttributes.ContentState(
            petName: pet.name,
            petType: pet.type,
            petMood: pet.mood,
            hunger: pet.hunger,
            energy: pet.energy,
            lastInteraction: Date()
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("Started Live Activity for \(pet.name)")
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity(for pet: Pet) {
        Task {
            let contentState = PetAttributes.ContentState(
                petName: pet.name,
                petType: pet.type,
                petMood: pet.mood,
                hunger: pet.hunger,
                energy: pet.energy,
                lastInteraction: Date()
            )
            
            await currentActivity?.update(using: contentState)
        }
    }
    
    func stopLiveActivity() {
        Task {
            await currentActivity?.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
}
