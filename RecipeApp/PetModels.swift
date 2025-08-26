import SwiftUI

// MARK: - Data Models
struct Pet {
    var name: String
    var type: PetType
    var mood: PetMood
    var hunger: Int
    var energy: Int
}

// MARK: - Pet Type and Mood Enums
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
