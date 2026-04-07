//
//  ElementService.swift
//  Five Elements mapping + profiles + debug/test hooks.
//

import Foundation

final class ElementService {
    static let shared = ElementService()
    private let map: [Element: ElementProfile]
    private let napAmByPair: [String: NapAm]

    init() {
        map = [
            .kim: ElementProfile(
                element: .kim,
                description: "Kim tượng trưng cho sự kỷ luật, rõ ràng và chuẩn mực.",
                personalityTraits: ["Quyết đoán", "Nguyên tắc", "Có trách nhiệm", "Tư duy hệ thống"],
                strengths: ["Giỏi tổ chức", "Bền bỉ theo mục tiêu", "Giữ cam kết tốt"],
                weaknesses: ["Dễ cứng nhắc", "Khó chấp nhận mơ hồ", "Tự gây áp lực cao"],
                compatibleWith: [.thuy, .tho],
                incompatibleWith: [.hoa, .moc],
                suggestions: ["Linh hoạt hơn khi kế hoạch thay đổi.", "Ưu tiên đối thoại mềm trước khi phản biện.", "Đừng quên nghỉ để tái tạo năng lượng."]
            ),
            .moc: ElementProfile(
                element: .moc,
                description: "Mộc đại diện cho phát triển, sáng tạo và tinh thần học hỏi.",
                personalityTraits: ["Cởi mở", "Sáng tạo", "Linh hoạt", "Hướng tăng trưởng"],
                strengths: ["Ý tưởng dồi dào", "Dễ thích nghi", "Lan tỏa năng lượng tích cực"],
                weaknesses: ["Dễ phân tán", "Thiếu ổn định dài hạn", "Hay ôm nhiều việc"],
                compatibleWith: [.hoa, .thuy],
                incompatibleWith: [.kim, .tho],
                suggestions: ["Giữ 1-2 ưu tiên quan trọng mỗi ngày.", "Chia mục tiêu lớn thành mốc nhỏ.", "Kết hợp với người có tính kỷ luật để cân bằng."]
            ),
            .thuy: ElementProfile(
                element: .thuy,
                description: "Thủy biểu hiện sự tinh tế, thích nghi và kết nối cảm xúc.",
                personalityTraits: ["Nhạy bén", "Quan sát tốt", "Linh hoạt", "Đồng cảm"],
                strengths: ["Xử lý tình huống mềm dẻo", "Kết nối con người tốt", "Thích nghi nhanh"],
                weaknesses: ["Dễ dao động cảm xúc", "Ngại va chạm trực diện", "Đôi lúc chần chừ"],
                compatibleWith: [.moc, .kim],
                incompatibleWith: [.tho, .hoa],
                suggestions: ["Đặt hạn chót cho quyết định quan trọng.", "Giữ ranh giới cảm xúc rõ ràng.", "Duy trì vận động nhẹ để cân bằng tinh thần."]
            ),
            .hoa: ElementProfile(
                element: .hoa,
                description: "Hỏa tượng trưng cho nhiệt huyết, chủ động và khả năng truyền cảm hứng.",
                personalityTraits: ["Nhiệt tình", "Chủ động", "Thẳng thắn", "Năng lượng cao"],
                strengths: ["Tạo động lực mạnh", "Dám hành động", "Kéo đội nhóm tiến lên nhanh"],
                weaknesses: ["Dễ nóng vội", "Phản ứng nhanh khi căng thẳng", "Thiếu kiên nhẫn"],
                compatibleWith: [.tho, .moc],
                incompatibleWith: [.thuy, .kim],
                suggestions: ["Dừng vài giây trước phản hồi khi áp lực.", "Giữ nhịp đều thay vì bùng nổ ngắn hạn.", "Kết hợp kiểm tra rủi ro trước quyết định lớn."]
            ),
            .tho: ElementProfile(
                element: .tho,
                description: "Thổ đại diện cho sự ổn định, thực tế và vai trò nâng đỡ.",
                personalityTraits: ["Điềm tĩnh", "Thực tế", "Đáng tin cậy", "Kiên trì"],
                strengths: ["Xây nền tảng vững", "Bền bỉ", "Giữ cân bằng tập thể"],
                weaknesses: ["Dễ bảo thủ", "Ngại thay đổi đột ngột", "Có xu hướng ôm trách nhiệm"],
                compatibleWith: [.kim, .hoa],
                incompatibleWith: [.moc, .thuy],
                suggestions: ["Mở thêm không gian thử nghiệm nhỏ.", "Chia sẻ bớt đầu việc để tránh kiệt sức.", "Định kỳ cập nhật mục tiêu để không trì trệ."]
            ),
        ]

        var n: [String: NapAm] = [:]
        func pairKey(_ stem: HeavenlyStem, _ branch: EarthlyBranch) -> String {
            "\(stem.rawValue)-\(branch.rawValue)"
        }
        func add(_ stemA: HeavenlyStem, _ branchA: EarthlyBranch, _ stemB: HeavenlyStem, _ branchB: EarthlyBranch, _ name: String, _ element: Element) {
            let value = NapAm(name: name, element: element)
            n[pairKey(stemA, branchA)] = value
            n[pairKey(stemB, branchB)] = value
        }
        // 30 Nạp Âm pairs => full 60 Can-Chi combinations
        add(.giap, .ty, .at, .suu, "Hải Trung Kim", .kim)
        add(.binh, .dan, .dinh, .mao, "Lư Trung Hỏa", .hoa)
        add(.mau, .thin, .ky, .ty2, "Đại Lâm Mộc", .moc)
        add(.canh, .ngo, .tan, .mui, "Lộ Bàng Thổ", .tho)
        add(.nham, .than, .quy, .dau, "Kiếm Phong Kim", .kim)
        add(.giap, .tuat, .at, .hoi, "Sơn Đầu Hỏa", .hoa)
        add(.binh, .ty, .dinh, .suu, "Giản Hạ Thủy", .thuy)
        add(.mau, .dan, .ky, .mao, "Thành Đầu Thổ", .tho)
        add(.canh, .thin, .tan, .ty2, "Bạch Lạp Kim", .kim)
        add(.nham, .ngo, .quy, .mui, "Dương Liễu Mộc", .moc)
        add(.giap, .than, .at, .dau, "Tuyền Trung Thủy", .thuy)
        add(.binh, .tuat, .dinh, .hoi, "Ốc Thượng Thổ", .tho)
        add(.mau, .ty, .ky, .suu, "Tích Lịch Hỏa", .hoa)
        add(.canh, .dan, .tan, .mao, "Tùng Bách Mộc", .moc)
        add(.nham, .thin, .quy, .ty2, "Trường Lưu Thủy", .thuy)
        add(.giap, .ngo, .at, .mui, "Sa Trung Kim", .kim)
        add(.binh, .than, .dinh, .dau, "Sơn Hạ Hỏa", .hoa)
        add(.mau, .tuat, .ky, .hoi, "Bình Địa Mộc", .moc)
        add(.canh, .ty, .tan, .suu, "Bích Thượng Thổ", .tho)
        add(.nham, .dan, .quy, .mao, "Kim Bạch Kim", .kim)
        add(.giap, .thin, .at, .ty2, "Phúc Đăng Hỏa", .hoa)
        add(.binh, .ngo, .dinh, .mui, "Thiên Hà Thủy", .thuy)
        add(.mau, .than, .ky, .dau, "Đại Trạch Thổ", .tho)
        add(.canh, .tuat, .tan, .hoi, "Thoa Xuyến Kim", .kim)
        add(.nham, .ty, .quy, .suu, "Tang Đố Mộc", .moc)
        add(.giap, .dan, .at, .mao, "Đại Khê Thủy", .thuy)
        add(.binh, .thin, .dinh, .ty2, "Sa Trung Thổ", .tho)
        add(.mau, .ngo, .ky, .mui, "Thiên Thượng Hỏa", .hoa)
        add(.canh, .than, .tan, .dau, "Thạch Lựu Mộc", .moc)
        add(.nham, .tuat, .quy, .hoi, "Đại Hải Thủy", .thuy)
        napAmByPair = n
    }

    // MARK: - Required mapping

    func getElement(from stem: HeavenlyStem) -> Element {
        switch stem {
        case .giap, .at: return .moc
        case .binh, .dinh: return .hoa
        case .mau, .ky: return .tho
        case .canh, .tan: return .kim
        case .nham, .quy: return .thuy
        }
    }

    func getElementFromYear(year: Int) -> Element {
        let stem = LunarService.getHeavenlyStem(year: year)
        let element = getElement(from: stem)
        print("[ElementService] inputYear=\(year), stem=\(stem), element=\(element.rawValue)")
        return element
    }

    func getElementProfile(element: Element) -> ElementProfile {
        map[element] ?? ElementProfile(
            element: element,
            description: "",
            personalityTraits: [],
            strengths: [],
            weaknesses: [],
            compatibleWith: [],
            incompatibleWith: [],
            suggestions: []
        )
    }

    func getNapAm(stem: HeavenlyStem, branch: EarthlyBranch) -> NapAm {
        napAmByPair[key(stem, branch)] ?? NapAm(name: "Không xác định", element: getElement(from: stem))
    }

    func getFullElementProfile(year: Int) -> (element: Element, napAm: NapAm) {
        let stem = LunarService.getHeavenlyStem(year: year)
        let branch = LunarService.getEarthlyBranch(year: year)
        let element = getElement(from: stem)
        let napAm = getNapAm(stem: stem, branch: branch)
        return (element, napAm)
    }

    private func key(_ stem: HeavenlyStem, _ branch: EarthlyBranch) -> String {
        "\(stem.rawValue)-\(branch.rawValue)"
    }

    // MARK: - Requested test cases (debug hook)

    static func runElementMappingTests() {
        let s = ElementService.shared
        assert(s.getElementFromYear(year: 2001) == .kim, "2001 should map to Kim")
        assert(s.getElementFromYear(year: 2002) == .thuy, "2002 should map to Thủy")
        assert(s.getElementFromYear(year: 1998) == .tho, "1998 should map to Thổ")
        assert(s.getElementFromYear(year: 1995) == .hoa, "1995 should map to Hỏa")
        assert(s.getNapAm(stem: .canh, branch: .thin).name == "Bạch Lạp Kim", "2001 nap am should be Bạch Lạp Kim")
        assert(s.getNapAm(stem: .nham, branch: .ngo).name == "Dương Liễu Mộc", "2002 nap am should be Dương Liễu Mộc")
        assert(s.getNapAm(stem: .at, branch: .hoi).name == "Sơn Đầu Hỏa", "1995 nap am should be Sơn Đầu Hỏa")
    }
}
