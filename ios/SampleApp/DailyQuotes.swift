//
//  DailyQuotes.swift
//  Deterministic “quote of the day” for app + widget (same index for a given calendar day).
//

import Foundation

enum DailyQuotes {
    /// Stable index for the given calendar day in the current time zone.
    static func dayIndex(for date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: date)
        let y = calendar.component(.year, from: start)
        let ord = calendar.ordinality(of: .day, in: .year, for: start) ?? 1
        return abs(y &* 31 &+ ord)
    }

    static func quote(for date: Date, languageCode: String, calendar: Calendar = .current) -> String {
        let list = languageCode == "vi" ? vietnamese : english
        guard !list.isEmpty else { return "" }
        let raw = dayIndex(for: date, calendar: calendar)
        let n = list.count
        let idx = ((raw % n) + n) % n
        return list[idx]
    }

    private static let english: [String] = [
        "Every sunrise is a new page.",
        "Small steps still move you forward.",
        "Calm mind, clear path.",
        "Kindness returns in unexpected ways.",
        "Today, choose patience over pride.",
        "Gratitude turns ordinary into enough.",
        "Listen more than you speak.",
        "Rest is part of the work.",
        "Let go of what you cannot steer.",
        "Light a candle instead of cursing darkness.",
        "Do the next right thing.",
        "Your pace is yours alone.",
        "Joy hides in simple moments.",
        "Courage is quiet persistence.",
        "Plant seeds; harvest comes later.",
        "Breathe before you answer.",
        "Hope is a habit, not a feeling.",
        "Forgive yourself, then try again.",
        "Walk outside; the sky still holds you.",
        "What you practice grows stronger.",
        "Honesty saves time.",
        "Be soft with yourself today.",
        "A clear desk helps a clear mind.",
        "Love is shown in small acts.",
        "Discipline is remembering what you want.",
        "Silence can be an answer.",
        "Start where you are.",
        "The moon waxes and wanes; so do we.",
        "Trust the slow work.",
        "End the day with peace if you can."
    ]

    private static let vietnamese: [String] = [
        "Mỗi sớm mai là một trang giấy mới.",
        "Từng bước nhỏ vẫn đưa ta tới đích.",
        "Tâm an thì lối rộng.",
        "Lòng tốt sẽ quay về theo cách không ngờ.",
        "Hôm nay, chọn nhẫn nại hơn kiêu căng.",
        "Biết ơn biến thường thành đủ.",
        "Nghe nhiều hơn nói.",
        "Nghỉ ngơi cũng là một phần của việc.",
        "Buông những gì không thể điều khiển.",
        "Thắp nến thay vì chê bóng tối.",
        "Làm điều đúng tiếp theo.",
        "Nhịp của bạn là của riêng bạn.",
        "Niềm vui nấp trong khoảnh khắc giản dị.",
        "Can đảm là kiên trì yên lặng.",
        "Gieo hạt; mùa gặt sẽ tới sau.",
        "Hít thở trước khi trả lời.",
        "Hy vọng là thói quen, không chỉ là cảm xúc.",
        "Tha thứ cho mình, rồi thử lại.",
        "Ra ngoài trời; trời vẫn ôm bạn.",
        "Điều bạn luyện tập sẽ lớn mạnh.",
        "Thật thà tiết kiệm thời gian.",
        "Hôm nay hãy dịu với chính mình.",
        "Gọn gàng giúp tâm sáng.",
        "Yêu thương thể hiện trong việc nhỏ.",
        "Kỷ luật là nhớ mình muốn gì.",
        "Im lặng cũng có thể là lời đáp.",
        "Bắt đầu từ chỗ bạn đang đứng.",
        "Trăng khuyết tròn; lòng người cũng vậy.",
        "Tin vào công việc chậm mà chắc.",
        "Kết ngày bằng an yên nếu có thể."
    ]
}
