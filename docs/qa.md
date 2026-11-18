# Phiếu chạy trên điện thoại
Mỗi lần chạy ghi build ID, máy/OS, tỷ lệ màn, trạng thái mạng, kết quả, ảnh/log lỗi. Toàn bộ ca dưới đây đang chờ runtime Flutter.

| Ca | Thao tác | Kết quả mong đợi |
|---|---|---|
| QA-01 · Luồng đầu | Bật chế độ máy bay. Mở Museum trước khi chơi. Mở A, ghép hai mảnh, quay lại mở B | Bảo tàng rỗng ban đầu; A chỉ cấp hai mảnh; khi A hết vẫn mở được B; mở lại thùng không tăng tổng |
| QA-02 · Thả và camera | Thả ra ngoài hình, hủy gesture, thử điểm sát ngưỡng sau zoom/pan, chạm mảnh đã khóa | Mảnh sai/hủy vẫn ở khay. Cùng điểm trên world cho cùng kết quả ở mọi mức zoom. Mảnh đã khóa đứng yên |
| QA-03 · Gợi ý | Chọn hộp sọ, bấm gợi ý liên tiếp qua ba lần lưu; đổi màn rồi quay lại | Đích sáng khoảng 3 giây, mỗi lần tốn đúng một lượt; hết lượt vẫn kéo ghép được |
| QA-04 · Sao, xu, Museum | Thắng với 3 gợi ý; mở Museum. Ghép lại, thắng với 1 gợi ý rồi 0 | Sao 1 → 2 → 3. Ví vẫn 50 xu. Một hiện vật T‑Rex. Tắt/mở app thấy cùng kỷ lục |
| QA-05 · Dữ liệu | Thoát hẳn sau mảnh thứ hai, mở lại. Inject snapshot sai version trong môi trường test. Giả lập lỗi ghi trên thao tác mở thùng | Khay và mảnh đã khóa phục hồi; báo lỗi đọc, giữ raw cũ; lỗi ghi không mở thùng trên UI; cho thử lại |
| QA-06 · Hiển thị và cài đặt | Kiểm tra ở 360×640 và 430×932, chữ lớn. Tắt âm, bật rung; ghép một mảnh rồi đổi tùy chọn ngược lại | Đọc được tiếng Việt, cuộn đến hết khay, phản hồi theo từng tùy chọn và nhớ khi mở lại |
| QA-07 · Build | Cài bản obfuscated trên Android/iOS, thực hiện QA-01/04/05; lấy trace thử nghiệm và symbolize | Chơi offline, đọc đúng save, trace khớp symbols, không có symbol riêng trong artifact phát hành |

QA-08 · Từ hồ sơ mới, bấm Chơi, mở thùng tập, thả sai rồi ghép đúng, vào bản đồ và khởi động lại. Kỳ vọng lần tới Chơi đi thẳng bản đồ. Lặp với Bỏ qua, với save cũ đang ghép dở và với Cài đặt → Tập ghép xương lại; số mảnh, gợi ý, sao và xu của màn thật giữ nguyên.
