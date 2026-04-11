//
//  HolidayData.swift
//  Static catalog — Vietnamese copy, offline. Extend by appending to `allHolidays`.
//

import Foundation

enum HolidayData {
    /// Same Vietnam civil clock as `HolidayService` / `LunarReminderConverter` so solar templates
    /// decode to the same month/day used when computing `nextOccurrence`.
    private static var vietnamCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = LunarReminderConverter.vietnamTimeZone
        return c
    }

    /// Template `Date` for recurring solar holidays (year segment ignored by `HolidayService`).
    private static func solar(month: Int, day: Int) -> Date {
        let comps = DateComponents(year: 2000, month: month, day: day, hour: 8, minute: 0)
        if let d = vietnamCalendar.date(from: comps) { return d }
        assertionFailure("HolidayData: invalid solar template month=\(month) day=\(day)")
        var c = Calendar(identifier: .gregorian)
        c.timeZone = LunarReminderConverter.vietnamTimeZone
        return c.date(from: DateComponents(year: 2000, month: 6, day: 1, hour: 8, minute: 0))!
    }

    // MARK: - Stable IDs (notifications + persistence)

    private static let idTet = UUID(uuidString: "A1000000-0000-4000-8000-000000000001")!
    private static let idRam = UUID(uuidString: "A1000000-0000-4000-8000-000000000002")!
    private static let idHanThuc = UUID(uuidString: "A1000000-0000-4000-8000-000000000003")!
    private static let idHungVuong = UUID(uuidString: "A1000000-0000-4000-8000-000000000004")!
    private static let idDoanNgo = UUID(uuidString: "A1000000-0000-4000-8000-000000000005")!
    private static let idVuLan = UUID(uuidString: "A1000000-0000-4000-8000-000000000006")!
    private static let idTrungThu = UUID(uuidString: "A1000000-0000-4000-8000-000000000007")!
    private static let idOngTao = UUID(uuidString: "A1000000-0000-4000-8000-000000000008")!
    private static let id304 = UUID(uuidString: "A1000000-0000-4000-8000-000000000009")!
    private static let id105 = UUID(uuidString: "A1000000-0000-4000-8000-00000000000A")!
    private static let id209 = UUID(uuidString: "A1000000-0000-4000-8000-00000000000B")!

    /// Catalog entries use one of two shapes (see `HolidayService.nextOccurrence`):
    /// - **Lunar** — `isLunar == true`, `lunarMonth` / `lunarDay` set, `solarDate == nil`. Reminders resolve the next solar instant via `LunarEngine`; `solarDate` must stay nil.
    /// - **Solar (fixed civil)** — `isLunar == false`, `solarDate` is a month/day template (year ignored), `lunarMonth` / `lunarDay` nil.
    static let allHolidays: [Holiday] = [
        Holiday(
            id: idTet,
            name: "Tết Nguyên Đán",
            solarDate: nil,
            lunarDay: 1,
            lunarMonth: 1,
            isLunar: true,
            shortDescription: "Tết cổ truyền — khởi đầu năm mới, sum họp gia đình và nhớ về tổ tiên.",
            meaning: "Tết là khoảnh khắc giao thoa giữa năm cũ và năm mới: dọn dẹp để \"bỏ cũ đón mới\", quây quần bên mâm cơm, thắp nén hương thành kính và chúc nhau điều lành. Với nhiều người, đó còn là dịp trở về quê, nắm tay cha mẹ và cảm nhận rõ mình thuộc về một mái nhà.",
            activities: [
                "Dọn dẹp nhà cửa, sắp xếp lại góc làm việc và bếp núc.",
                "Gói bánh chưng hoặc cùng nhà làm món Tết, chuẩn bị mứt, dưa hành.",
                "Thắp hương bàn thờ, chúc Tết ông bà cha mẹ theo thứ tự trong gia đình.",
                "Đi chùa đầu năm, lì xì cho trẻ, du xuân thăm họ hàng.",
            ],
            history: "Tết gắn bó lâu đời với nền văn minh lúa nước: nghỉ ngơi sau vụ gặt, cảm tạ trời đất và cầu mùa mới thuận hòa. Qua các triều đại, phong tục cung đình và làng xã chồng chất, dần hình thành Tết như ngày lễ lớn nhất của người Việt — nơi chữ Hiếu và chữ Tình được nhắc nhở bằng hương khói, lời chúc và bữa cơm sum họp.",
            funFact: "Lì xì đỏ không chỉ là tiền lẻ: nhiều người tin màu đỏ và đồng xu \"mới\" mang lại may mắn và xua điều không lành.",
            category: .traditional,
            icon: "🧧"
        ),
        Holiday(
            id: idRam,
            name: "Rằm tháng Giêng",
            solarDate: nil,
            lunarDay: 15,
            lunarMonth: 1,
            isLunar: true,
            shortDescription: "Trăng tròn đầu năm — lễ chùa, cầu an và lắng nghe lòng mình.",
            meaning: "Rằm tháng Giêng như một nhịp thở chậm sau những ngày Tết vội vã: người ta dành thời gian cho điều thiêng liêng, cho hy vọng cả năm. Đi chùa hay ở nhà, ý nghĩa cốt lõi vẫn là an yên — cho bản thân và cho người thân.",
            activities: [
                "Lễ Phật, dâng hương hoa, tụng kinh hoặc ngồi yên một lát trước bàn thờ.",
                "Ăn chay trong ngày, bố thí, giúp việc nhỏ cho người khó khăn.",
                "Đi thăm ông bà, kể chuyện đầu năm, hàn gắn điều chưa trọn.",
            ],
            history: "Trăng rằm trong văn hóa Việt lâu nay vừa mang nét Phật giáo vừa gắn phong tục làng: chợ chùa đông vui, mái đình rộn tiếng mõ. Rằm tháng Giêng đặc biệt được xem là thời điểm \"mở hàng\" tâm linh: cầu phúc, cầu an, và nhắc nhở mình sống tử tế hơn.",
            funFact: "Không phải ai cũng biết: nhiều làng xưa coi rằm Giêng là dịp hòa giải mâu thuẫn trong họ, trước khi bước vào nhịp làm ruộng dồn dập.",
            category: .spiritual,
            icon: "🌕"
        ),
        Holiday(
            id: idHanThuc,
            name: "Tết Hàn Thực",
            solarDate: nil,
            lunarDay: 3,
            lunarMonth: 3,
            isLunar: true,
            shortDescription: "Mồng 3 tháng 3 âm — ngày ăn đồ nguội, nhớ tổ tiên và thanh nhẹ bữa ăn.",
            meaning: "Hàn Thực mang tinh thần giản dị: tạm gác mùi khói bếp, dùng bánh trái chay/nấu sẵn để tưởng nhớ người đi khuất và để cơ thể \"nhẹ\" theo cách xưa. Đó cũng là dịp con cháu quây quần, kể chuyện dòng họ và cảm nhận sự liền mạch giữa các thế hệ.",
            activities: [
                "Chuẩn bị bánh đúc, bánh nếp hoặc xôi nguội — tùy phong tục từng nhà.",
                "Lễ tổ tiên, dọn dẹp mộ phần (nếu có) hoặc thắp hương tại nhà.",
                "Cùng trẻ trong nhà làm một món chay đơn giản để nhớ ý nghĩa ngày lễ.",
            ],
            history: "Tết Hàn Thực có gốc tích xa ở văn hóa Trung Hoa cổ, song người Việt đã biến nó thành phần của đời sống làng: xen kẽ giữa tiết xuân và mùa làm đồng. Dần dần, ý \"ăn nguội\" không chỉ là luật lệ mà còn là cách nói về sự tiết chế, tri ân và thanh tịnh trước những tháng nắng mưa phía trước.",
            funFact: "Ở nhiều vùng, Hàn Thực đi đôi với hội đình làng hoặc trò chơi dân gian — không chỉ \"ăn nguội\" mà còn là ngày cộng đồng sum vầy.",
            category: .traditional,
            icon: "🍃"
        ),
        Holiday(
            id: idHungVuong,
            name: "Giỗ Tổ Hùng Vương",
            solarDate: nil,
            lunarDay: 10,
            lunarMonth: 3,
            isLunar: true,
            shortDescription: "Mồng 10 tháng 3 âm — ngày của cội nguồn, của lòng tự hào dân tộc.",
            meaning: "Giỗ Tổ nhắc người Việt về một chuỗi sử thi: thuở các vua Hùng dạy dân trồng lúa, dệt vải, biết yêu đất nước. Hôm nay, ý nghĩa ấy chuyển thành lòng biết ơn với tổ tiên, với những người đi trước đã vun đắp làng quê và bản sắc.",
            activities: [
                "Dự lễ dâng hương tại đền Hùng hoặc lễ tại địa phương, xem múa hát truyền thống.",
                "Các gia đình làm mâm cơm chay hoặc mặn để nhớ nguồn gốc.",
                "Kể cho trẻ nghe câu chuyện \"Con Rồng cháu Tiên\" bằng lời đời thường, gần gũi.",
            ],
            history: "Tục thờ Hùng Vương có chiều dài hàng thế kỷ trong tập quán làng xã. Ngày mồng 10 tháng Ba âm lịch được cố định là dịp Quốc lễ để cả nước cùng hướng về Phú Thọ và về trong tâm: nhớ một thời dựng nước, giữ đất, và truyền lại ngọn lửa ấy cho thế hệ sau.",
            funFact: "Bánh dày — bánh chưng trong truyền thuyết Lang Liêu không chỉ là món ăn: đó là hình ảnh Trời — Đất được người xưa kể bằng chuyện cổ tích dễ nhớ.",
            category: .traditional,
            icon: "🐉"
        ),
        Holiday(
            id: idDoanNgo,
            name: "Tết Đoan Ngọ",
            solarDate: nil,
            lunarDay: 5,
            lunarMonth: 5,
            isLunar: true,
            shortDescription: "Mồng 5 tháng 5 âm — giữa hè, dọn \"khí độc\" trong nhà và trong người.",
            meaning: "Đoan Ngọ nằm giữa năm như một điểm cân: người ta ăn chua ngọt, rửa ráy, lau bếp, để cơ thể và không gian sống \"sạch\" hơn trước những ngày nắng gắt. Cũng là lúc nhắc nhở nhau giữ sức khỏe, trông nom trẻ nhỏ và người già khi thời tiết đổi.",
            activities: [
                "Ăn hoa quả chín, rượu nếp, gỏi sứa hoặc các món dân gian theo vùng miền.",
                "Lau dọn bếp, thay nước lá xông, quét góc nhà — phần nhiều mang ý phòng bệnh mùa hè.",
                "Một số nhà làm mâm cúng giữa trưa, hoặc cùng nhau ăn bữa cơm thanh đạm.",
            ],
            history: "Tết Đoan Ngọ ở Việt Nam hòa trộn kinh nghiệm nông thôn (trừ sâu bọ, giữ vệ sinh) với quan niệm dân gian về \"giết sâu bọ\" trong bụng bằng đồ chua, rượu nếp. Theo thời gian, ngày lễ vừa thực dụng vừa mang màu cộng đồng: chợ phiên, làng xóm rủ nhau ăn uống cho vui khí trời.",
            funFact: "Tên \"Đoan Ngọ\" gợi đúng giữa ngày: \"Ngọ\" là giờ giữa trưa — nhiều nơi chọn khung giờ này để làm lễ cúng.",
            category: .traditional,
            icon: "🌿"
        ),
        Holiday(
            id: idVuLan,
            name: "Lễ Vu Lan",
            solarDate: nil,
            lunarDay: 15,
            lunarMonth: 7,
            isLunar: true,
            shortDescription: "Rằm tháng Bảy — mùa báo hiếu, nhớ công cha mẹ và người đi trước.",
            meaning: "Vu Lan là lời nhắc dịu dàng: dù bận rộn đến đâu, ta vẫn cần một ngày để cảm ơn cha mẹ — bằng lời nói, bằng việc làm, bằng sự hiện diện. Với Phật tử, đó còn là tinh thần cứu khổ — mở rộng lòng từ bi ra người xa lạ.",
            activities: [
                "Đi chùa làm lễ Vu Lan, nghe giảng kinh hoặc tham gia cúng chúng sinh.",
                "Cài hoa hồng lên áo theo phong tục: hồng đỏ — còn mẹ; hồng trắng — mẹ đã khuất.",
                "Cúng tổ tiên, nấu cháo phóng sinh, hoặc đơn giản là về nhà ăn cơm cùng cha mẹ.",
            ],
            history: "Vu Lan bắt nguồn từ chuyện Mục Kiền Liên trong kinh điển Phật giáo, truyền vào Việt Nam và hòa cùng đạo hiếu của người Việt. Rằm tháng Bảy dần trở thành không gian chung: chùa đông đúc, nhà nhà bày mâm, và nhiều người chọn ngày này để làm lành những điều chưa nói kịp.",
            funFact: "Hoa hồng trên ngực áo không chỉ là hình thức: với nhiều người, đó là khoảnh khắc nước mắt và lòng biết ơn được phép bộc lộ công khai.",
            category: .spiritual,
            icon: "🪷"
        ),
        Holiday(
            id: idTrungThu,
            name: "Tết Trung Thu",
            solarDate: nil,
            lunarDay: 15,
            lunarMonth: 8,
            isLunar: true,
            shortDescription: "Tết đoàn viên dưới trăng — đèn lồng, tiếng trống lân và tiếng cười trẻ thơ.",
            meaning: "Trung Thu là lời mời các thế hệ ngồi gần nhau: trăng tròn như nhắc \"đủ đầy\", bánh tròn như mong sum họp. Người lớn nhìn trẻ rước đèn mà nhớ tuổi thơ mình; xa quê thì gửi bánh qua điện thoại, qua bưu điện — vẫn là một kiểu về nhà.",
            activities: [
                "Rước đèn, phá cỗ, múa lân nơi sân nhà, sân chung cư hoặc phố làng.",
                "Ăn bánh nướng, bánh dẻo, nhâm nhi trà và ngắm trăng.",
                "Kể chuyện sự tích Hằng Nga, Chú Cuội cho trẻ — hoặc cùng trẻ làm đèn handmade.",
            ],
            history: "Trung Thu ở Việt Nam chịu ảnh hưởng từ văn hóa Đông Á nhưng đã \"Việt hóa\" bằng chợ đêm, làn điệu dân ca và cách kể chuyện riêng. Từ một lễ hội gắn mùa màng, dần hình ảnh trung tâm là trẻ em — song vẫn giữ sợi dây đoàn viên cho cả người lớn.",
            funFact: "Trung Thu từng có thời là dịp vui của người trưởng thành; dần dần, trẻ em trở thành \"nhân vật chính\" — nhưng ý đoàn viên thì không đổi.",
            category: .traditional,
            icon: "🏮"
        ),
        Holiday(
            id: idOngTao,
            name: "Tết Ông Công Ông Táo",
            solarDate: nil,
            lunarDay: 23,
            lunarMonth: 12,
            isLunar: true,
            shortDescription: "Ngày 23 tháng Chạp — tiễn Táo quân về trời, chuẩn bị tâm thế đón Tết.",
            meaning: "Ông Táo được kể như người cận kề bếp núc: chứng kiến bữa ăn, chuyện nhà, và cả những lỗi nhỏ của con người. Lễ tiễn là dịp thành kính, cũng là lúc nhà nhà rửa bếp, thay muối mỡ, khép một năm bằng sự chỉn chu.",
            activities: [
                "Cúng ông Táo với cá chép — thật hoặc bằng giấy tùy phong tục địa phương.",
                "Lau bếp, dọn tủ lạnh, vứt đồ hỏng; nhiều nhà bắt đầu trang trí cành đào, mai.",
                "Cả nhà cùng ăn bữa cơm thanh đạm sau lễ, nói chuyện kế hoạch Tết.",
            ],
            history: "Tín ngưỡng bếp ở Việt Nam gắn với đời sống nông gia và tình làng: bếp là trung tâm ấm áp. Chuyện ba ông Táo — hai ông một bà — là cách dân gian nhân hoá điều thiêng, để mỗi nhà đều có \"chứng nhân\" hiền lành cho sự chừng mực, yêu thương.",
            funFact: "Cá chép không chỉ là lễ vật: nó là hình ảnh cõi thiêng gần gũi — \"cá vượt vũ môn\" như lời chúc thuận buồm xuôi gió.",
            category: .spiritual,
            icon: "🐟"
        ),
        Holiday(
            id: id304,
            name: "Ngày Giải phóng miền Nam (30/4)",
            solarDate: solar(month: 4, day: 30),
            lunarDay: nil,
            lunarMonth: nil,
            isLunar: false,
            shortDescription: "Kỷ niệm thống nhất đất nước — ngày của ký ức và hy vọng hòa bình.",
            meaning: "30/4 là mốc lịch sử khiến nhiều gia đình Việt nhớ về chia cắt, về hy sinh, và về niềm vui sum họp sau bão giông. Hôm nay, ý nghĩa thường được đọc theo cách riêng của mỗi người: tưởng nhớ, tri ân, và trân trọng giá trị của hòa bình.",
            activities: [
                "Xem lễ thượng cờ, diễu binh (ở các đô thị có tổ chức) hoặc theo dõi truyền hình cùng gia đình.",
                "Thăm di tích, bảo tàng, hoặc ngồi nghe người lớn tuổi kể chuyện năm ấy.",
                "Dành thời gian nghỉ ngơi, du lịch ngắn ngày cùng người thân.",
            ],
            history: "Sự kiện 30/4/1975 khép lại một giai đoạn chiến tranh dài ở miền Nam Việt Nam, mở ra chương thống nhất về mặt nhà nước. Qua nhiều thập kỷ, ngày lễ vừa mang tính chính thức vừa mang tính riêng tư: mỗi gia đình có một câu chuyện để nhớ và để kể.",
            funFact: "Ở nhiều nơi, người ta vẫn gọi thân mật là \"30/4 — 1/5\" như một cụm nghỉ lễ dài, gắn với ký ức xuân hè của cả nước.",
            category: .national,
            icon: "🇻🇳"
        ),
        Holiday(
            id: id105,
            name: "Ngày Quốc tế Lao động (1/5)",
            solarDate: solar(month: 5, day: 1),
            lunarDay: nil,
            lunarMonth: nil,
            isLunar: false,
            shortDescription: "Ngày của người lao động — tôn vinh đôi tay làm ra của cải và sự đồng đều.",
            meaning: "1/5 nhắc xã hội nhớ về quyền được nghỉ ngơi, được an toàn nơi làm việc, và về giá trị của lao động — từ công nhân xưởng đến người bán hàng chợ, từ giáo viên đến tài xế. Đó cũng là dịp nhiều người tri ân đồng nghiệp và gia đình đã chịu khó cùng mình.",
            activities: [
                "Công đoàn, công ty tổ chức gặp mặt, khen thưởng, team-building.",
                "Gia đình đi picnic, nghỉ ngơi sau chuỗi ngày làm việc.",
                "Tham gia hoạt động cộng đồng: hiến máu, tình nguyện — theo sức mỗi người.",
            ],
            history: "Ngày Quốc tế Lao động bắt nguồn từ các phong trào công nhân thế kỷ XIX ở châu Âu và Hoa Kỳ, rồi lan rộng toàn cầu. Việt Nam cố định 1/5 là ngày nghỉ lễ để thể chế hóa sự tôn trọng dành cho người làm ra của cải vật chất và tinh thần cho xã hội.",
            funFact: "Khối nghỉ \"30/4 — 1/5\" khiến nhiều người lầm tưởng hai ngày này cùng một sự kiện — thực ra nguồn gốc lịch sử khác nhau, chỉ là thường nối liền một kỳ nghỉ vui.",
            category: .national,
            icon: "🛠️"
        ),
        Holiday(
            id: id209,
            name: "Quốc khánh (2/9)",
            solarDate: solar(month: 9, day: 2),
            lunarDay: nil,
            lunarMonth: nil,
            isLunar: false,
            shortDescription: "Ngày độc lập — nhớ tuyên ngôn năm 1945 và những người đã dựng nên cơ hội đó.",
            meaning: "2/9 là dịp cả nước nhìn về một khoảnh khắc lịch sử: bản Tuyên ngôn vang lên giữa Thủ đô, mở ra kỳ vọng về tự do, tự chủ. Với nhiều người trẻ, đó còn là ngày để hiểu thêm về ông cha, về những lựa chọn khó khăn của thế hệ trước.",
            activities: [
                "Xem lễ mít tinh, chào cờ, pháo hoa (nơi được phép) hoặc theo dõi trực tiếp truyền hình.",
                "Du lịch trong nước, về thăm quê, sum họp gia đình.",
                "Đọc lại văn kiện lịch sử, tham quan di tích — cách riêng để \"chạm\" vào ký ức dân tộc.",
            ],
            history: "Cách mạng tháng Tám 1945 chấm dứt ách đô hộ của phát xít Nhật ở Đông Dương, mở đường cho lễ Tuyên bố độc lập ngày 2/9. Quốc khánh vì thế không chỉ là ngày nghỉ: đó là mốc neo ký ức chung của một quốc gia đi qua chiến tranh và tái thiết.",
            funFact: "Nhiều người Hà Nội quen gọi Quốc khánh là dịp \"về thăm Ba Đình\" — dù chỉ là đi bộ quanh khu phố cổ cho đỡ đông.",
            category: .national,
            icon: "🎆"
        ),
    ]
}
