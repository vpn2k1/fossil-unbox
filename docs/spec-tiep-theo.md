# Spec phần tiếp theo · từ một màn đến MVP
Phạm vi đích giữ nguyên Android/iOS, offline, màn dọc, 30 màn và 10 loài. Các con số dưới đây về phân bổ và giới hạn quảng cáo là cấu hình thử nghiệm để designer điều chỉnh sau playtest.

## ED-02 · Level Editor nội bộ
**Người dùng:** designer chỉnh dữ liệu mà không sửa Dart. Đầu vào là catalog PNG có kích thước và mã asset, JSON hiện có hoặc bàn trống. Toolbar có nhập, xuất, hoàn tác lần sửa và preview. Canvas giữ hệ tọa độ world khi zoom. Panel thuộc tính sửa ID, kích thước, pivot chuẩn hóa, X/Y, góc độ, zIndex và crateId.

| Tiêu chí | Hành vi nghiệm thu |
|---|---|
| ED-02a | Nhập màn 001, kéo đuôi rồi đổi góc 15°, xuất và nhập lại. Sai khác X/Y ≤ 0,1 đơn vị và sai khác góc ≤ 0,1°. Giữ thứ tự lớp và thùng. Pivot mặc định (0,5; 0,5) cho JSON cũ |
| ED-02b | Tạo và xóa mảnh cập nhật danh sách thùng. Asset thiếu, ID trùng, tọa độ ngoài bàn hoặc mảnh thuộc hai thùng chặn xuất. Hiện ID và trường cần sửa, giữ bản đang chỉnh |
| ED-02c | Preview dùng đúng loader/snap của game. Ghép thử sau khi đổi pivot ở zoom 1× và 2× cho cùng kết quả |

## ART-03 · Mười bộ xương và catalog
Mỗi loài có ID ổn định, tên hiển thị, mô tả, thumbnail, silhouette và các PNG xương nền trong. Artist giao cùng một hệ trục, pivot và bảng kích thước. Ghi tác giả hoặc nguồn và điều kiện sử dụng cho từng asset. Designer duyệt liên kết hộp sọ–cột sống, hông–chân, đuôi ở kích thước hiển thị thật. ART-03a đạt khi 10/10 bộ có provenance, ghép hoàn chỉnh trong preview và nhìn phân biệt được từng cụm xương ở màn hình nhỏ. ART-03b yêu cầu kiểm tra viền alpha trên nền tối/sáng, không cắt rìa khi xoay.

## LV-04 · Catalog 30 màn và mở khóa
Đề xuất 3 lượt phục dựng cho mỗi loài, tăng độ khó bằng cách tách cụm và bật xoay. Màn đầu có 4 mảnh, ngưỡng riêng theo board. Không áp quy tắc 40–60 của bàn lớn nguyên xi cho bàn 400 đơn vị. Level có ID bất biến, speciesId, settings, crates, bones, reward và nextLevelId tùy chọn. Map hiển thị mở/khóa, sao cao nhất, tiếp tục hoặc ghép lại. LV-04a yêu cầu hoàn thành lần đầu chỉ mở màn kế một lần; màn cuối về bảo tàng. LV-04b yêu cầu tất cả 30 JSON hợp lệ, 30/30 màn ghép đủ trên thiết bị, cả khi tắt mạng. LV-04c kiểm tra góc 359°/1°, mảnh đã khóa, zoom/pan và màn có nhiều mảnh cuộn khay. Trì hoãn xương trộn nhiều loài đến sau MVP.

## SAVE-05 và MUS-05 · Hồ sơ nhiều màn, bộ sưu tập
Save v2 gồm schemaVersion, activeLevelId, sessions[levelId], bestStars[levelId], rewardedLevelIds, collection[speciesId], wallet và settings. Mỗi lượt mới có attemptId. Hoàn tất là một giao dịch cập nhật tất cả trường liên quan. Dùng kho cục bộ có transaction khi tích hợp nhiều màn. Di trú v1 bằng cách sao lưu raw, ánh xạ màn 1, giữ xu/cài đặt/mảnh; chỉ đánh dấu thành công sau khi đọc lại và validate. Nếu lỗi, giữ v1 và cho thử lại. MUS-05a yêu cầu ba màn cùng loài tạo đúng một hiện vật, có trang chi tiết. SAVE-05a yêu cầu phát lại callback và tắt ứng dụng ngay sau mảnh cuối vẫn nhận đúng một lần thưởng. SAVE-05b kiểm tra migration khi đang ghép, đã thắng, vừa replay và save bị hỏng.

## ADS-06 · Rewarded ads khi hết gợi ý
Chỉ hiện “Xem quảng cáo — nhận 3 gợi ý” khi hết lượt và quảng cáo sẵn sàng. Có nút tiếp tục chơi. Adapter cung cấp trạng thái loading, ready, showing, rewarded và unavailable. Cấp 3 lượt theo khóa giao dịch duy nhất trên callback earned, ghi vào attemptId đã khởi tạo quảng cáo. Đóng sớm hoặc mất mạng giữ nguyên lượt. ADS-06a kiểm tra callback trùng, đóng trước/sau callback, chuyển màn và khởi động lại. ADS-06b kiểm tra trần đề xuất hai lần nhận mỗi lượt chơi, lượt chưa dùng được giữ khi tiếp tục. Dùng test ad unit khi QA. Quyết định đối tượng tuổi, cấu hình SDK và dữ liệu sự kiện trước khi đưa SDK thật vào release.

## REL-07 · Chất lượng và phát hành thử
Bảng thiết bị đích cần ghi tên máy, hệ điều hành, độ phân giải và tần số quét. REL-07a đo frame timing ở profile/release, vuốt khay, ghép mảnh cuối, zoom màn nhiều mảnh. Mục tiêu 60 FPS; đề xuất ghi p95 build/raster so với ngân sách 16,7 ms ở 60 Hz. REL-07b cho người mới chơi màn 1, ghi thời gian và chỗ mắc; mục tiêu ban đầu 60 giây. REL-07c yêu cầu build Android/iOS có signing, mở offline, đọc save phiên bản trước, smoke test quảng cáo test và giải mã được một stack trace bằng đúng symbols. Ghi log và kết quả theo build ID.

## Sau MVP
| Phần | Điều kiện bắt đầu | Spec đầu tiên cần nghiệm thu |
|---|---|---|
| Daily Challenge | Catalog và save v2 ổn định | Cùng ngày và cùng phiên bản nội dung cho cùng đề; một lần nhận thưởng mỗi ngày; đặc tả múi giờ và đổi ngày khi offline |
| Trang trí bảo tàng | Có nhiều hiện vật và ví giao dịch | Đặt, chuyển, cất vật trang trí; mở lại giữ bố cục, thử xung đột hai vật cùng vị trí |
| Gói IAP, bỏ quảng cáo | Có cấu hình cửa hàng và định nghĩa quyền lợi | Sandbox mua, hủy và khôi phục giao dịch; quyền lợi giữ sau cài lại; quyết định riêng việc hiển thị rewarded tự chọn |
| 200+ màn, ghép nhiều loài | 30 màn đạt tiêu chí chơi và pipeline art đủ năng suất | Nhiều bộ đích cùng bàn, mảnh chỉ khớp đúng loài; đo bộ nhớ ở màn nhiều sprite nhất |
