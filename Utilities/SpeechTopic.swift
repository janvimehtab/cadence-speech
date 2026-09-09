import Foundation

struct SpeechTopic: Identifiable, Hashable {
    
    let id: UUID
    let title: String
    let category: TopicCategory
    
    init(
        id: UUID = UUID(),
        title: String,
        category: TopicCategory
    ) {
        self.id = id
        self.title = title
        self.category = category
    }
}

enum TopicCategory: String, CaseIterable, Identifiable {
    
    case everyday
    case personalGrowth
    case people
    case education
    case work
    case opinions
    case world
    case fun
    
    var id: String {
        rawValue
    }
    
    var title: String {
        switch self {
        case .everyday:
            return "Everyday Life"
        case .personalGrowth:
            return "Personal Growth"
        case .people:
            return "People & Relationships"
        case .education:
            return "Education"
        case .work:
            return "Work"
        case .opinions:
            return "Opinions"
        case .world:
            return "World"
        case .fun:
            return "Fun & Imagination"
        }
    }
    
    var icon: String {
        switch self {
        case .everyday:
            return "sun.max.fill"
        case .personalGrowth:
            return "person.fill.checkmark"
        case .people:
            return "person.2.fill"
        case .education:
            return "book.fill"
        case .work:
            return "briefcase.fill"
        case .opinions:
            return "bubble.left.and.bubble.right.fill"
        case .world:
            return "globe"
        case .fun:
            return "sparkles"
        }
    }
}

enum SpeechTopicBank {
    
    // MARK: - All Topics
    
    static let allTopics: [SpeechTopic] = [
        
        // ==================================================
        // EVERYDAY LIFE — 15
        // ==================================================
        
        SpeechTopic(
            title: "Describe your typical day.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What do you usually do in your free time?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What is your favorite part of the day?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "Describe your morning routine.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What makes a day feel productive?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What do you usually do on weekends?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "Describe your favorite meal.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What is something you do every day?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What makes you feel relaxed?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "Describe a memorable day from your life.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What is your favorite time of the year?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "Describe your favorite place at home.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What is something that always makes you happy?",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "Describe your ideal weekend.",
            category: .everyday
        ),
        
        SpeechTopic(
            title: "What is one small thing that improves your day?",
            category: .everyday
        ),
        
        // ==================================================
        // PERSONAL GROWTH — 15
        // ==================================================
        
        SpeechTopic(
            title: "What is one skill everyone should learn?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What does confidence mean to you?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What makes someone a good listener?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What makes a good leader?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "Why is learning from mistakes important?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What is something you would like to improve?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What does success mean to you?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "Why is patience important?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What makes someone trustworthy?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What is one habit that can improve your life?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "Why is self-discipline important?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What does being responsible mean to you?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "How can someone become a better listener?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "Why is it important to try new things?",
            category: .personalGrowth
        ),
        
        SpeechTopic(
            title: "What is one lesson life has taught you?",
            category: .personalGrowth
        ),
        
        // ==================================================
        // PEOPLE & RELATIONSHIPS — 15
        // ==================================================
        
        SpeechTopic(
            title: "What makes a good friend?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What qualities do you value in people?",
            category: .people
        ),
        
        SpeechTopic(
            title: "Why is communication important?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes someone easy to talk to?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What can we learn from our parents?",
            category: .people
        ),
        
        SpeechTopic(
            title: "Why is teamwork important?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes a good teacher?",
            category: .people
        ),
        
        SpeechTopic(
            title: "How can people resolve disagreements?",
            category: .people
        ),
        
        SpeechTopic(
            title: "Why is listening important in a conversation?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes a person inspiring?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes someone a good teammate?",
            category: .people
        ),
        
        SpeechTopic(
            title: "Why is kindness important?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes a healthy friendship?",
            category: .people
        ),
        
        SpeechTopic(
            title: "Why should people respect different opinions?",
            category: .people
        ),
        
        SpeechTopic(
            title: "What makes a good conversation?",
            category: .people
        ),
        
        // ==================================================
        // EDUCATION — 10
        // ==================================================
        
        SpeechTopic(
            title: "What makes a good student?",
            category: .education
        ),
        
        SpeechTopic(
            title: "What is the best way to learn something new?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Should students learn more practical skills?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Why is asking questions important?",
            category: .education
        ),
        
        SpeechTopic(
            title: "What makes a good teacher?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Why is reading useful?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Is learning from mistakes important for students?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Why is time management important for students?",
            category: .education
        ),
        
        SpeechTopic(
            title: "What makes a good presentation?",
            category: .education
        ),
        
        SpeechTopic(
            title: "Should students work in teams more often?",
            category: .education
        ),
        
        // ==================================================
        // WORK — 10
        // ==================================================
        
        SpeechTopic(
            title: "What makes someone good at their job?",
            category: .work
        ),
        
        SpeechTopic(
            title: "What makes a workplace enjoyable?",
            category: .work
        ),
        
        SpeechTopic(
            title: "Why is teamwork important at work?",
            category: .work
        ),
        
        SpeechTopic(
            title: "What makes a good manager?",
            category: .work
        ),
        
        SpeechTopic(
            title: "Why is communication important at work?",
            category: .work
        ),
        
        SpeechTopic(
            title: "What makes a good work-life balance?",
            category: .work
        ),
        
        SpeechTopic(
            title: "Why is learning new skills important for a career?",
            category: .work
        ),
        
        SpeechTopic(
            title: "What makes a good team?",
            category: .work
        ),
        
        SpeechTopic(
            title: "Why is punctuality important?",
            category: .work
        ),
        
        SpeechTopic(
            title: "What makes a good interview?",
            category: .work
        ),
        
        // ==================================================
        // OPINIONS — 15
        // ==================================================
        
        SpeechTopic(
            title: "Is technology making life easier?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is social media helpful or harmful?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is it better to work alone or with others?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is it better to plan everything or be spontaneous?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Should people spend less time on their phones?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is failure necessary for success?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is it better to be busy or relaxed?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Should everyone learn how to cook?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is money important for happiness?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is online learning better than classroom learning?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is it better to live in a city or a small town?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Should people exercise every day?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is traveling important for personal growth?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Should people spend more time outdoors?",
            category: .opinions
        ),
        
        SpeechTopic(
            title: "Is it important to have a hobby?",
            category: .opinions
        ),
        
        // ==================================================
        // WORLD — 10
        // ==================================================
        
        SpeechTopic(
            title: "What makes a city a good place to live?",
            category: .world
        ),
        
        SpeechTopic(
            title: "Why is keeping the environment clean important?",
            category: .world
        ),
        
        SpeechTopic(
            title: "What makes a country attractive to visitors?",
            category: .world
        ),
        
        SpeechTopic(
            title: "Why do people enjoy traveling?",
            category: .world
        ),
        
        SpeechTopic(
            title: "What can people do to reduce waste?",
            category: .world
        ),
        
        SpeechTopic(
            title: "Why are public parks important?",
            category: .world
        ),
        
        SpeechTopic(
            title: "What makes a place feel like home?",
            category: .world
        ),
        
        SpeechTopic(
            title: "Why is public transportation important?",
            category: .world
        ),
        
        SpeechTopic(
            title: "What can communities do to help each other?",
            category: .world
        ),
        
        SpeechTopic(
            title: "What makes a culture interesting?",
            category: .world
        ),
        
        // ==================================================
        // FUN & IMAGINATION — 10
        // ==================================================
        
        SpeechTopic(
            title: "If you could learn any skill instantly, what would it be?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could visit any place, where would you go?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could have dinner with anyone, who would you choose?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could change one thing about your city, what would it be?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you had an extra hour every day, how would you use it?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could invent something, what would you invent?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could live anywhere for a year, where would you live?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could master one hobby, what would it be?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could go back in time, which period would you visit?",
            category: .fun
        ),
        
        SpeechTopic(
            title: "If you could give everyone one piece of advice, what would it be?",
            category: .fun
        )
    ]
    
    // MARK: - Recent Topic Selection
    
    static func randomTopic(
        excluding recentTopics: [SpeechTopic] = []
    ) -> SpeechTopic {
        
        let recentIDs =
        Set(
            recentTopics.map {
                $0.id
            }
        )
        
        let availableTopics =
        allTopics.filter {
            !recentIDs.contains($0.id)
        }
        
        return (
            availableTopics.randomElement()
            ?? allTopics.randomElement()
            ?? SpeechTopic(
                title:
                    "What makes a good friend?",
                category:
                        .people
            )
        )
    }
    
    // MARK: - Category Selection
    
    static func randomTopic(
        from category: TopicCategory
    ) -> SpeechTopic {
        
        let topics =
        allTopics.filter {
            $0.category == category
        }
        
        return (
            topics.randomElement()
            ?? allTopics.randomElement()
            ?? SpeechTopic(
                title:
                    "What makes a good friend?",
                category:
                        .people
            )
        )
    }
}
