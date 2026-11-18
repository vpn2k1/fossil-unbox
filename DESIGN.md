# Giao diện xưởng hóa thạch

Người chơi cầm điện thoại dọc, mở thùng và ghép xương trong các phiên ngắn. Hình xương là thông tin chính. Trang chủ và bảo tàng dùng cùng một giá trưng bày màu xanh sẫm, thước khắc và nhãn tên loài. Bàn chơi dùng nền sáng để người chơi phân biệt bóng mẫu, mảnh đang chọn và mảnh đã ghép.

| Thành phần | Quy ước trong mã |
|---|---|
| Màu và chữ | `lib/workshop_style.dart` định nghĩa nền giấy, màu thông, màu đồng, kiểu tiêu đề serif và hai theme. Nhãn và nội dung dùng phông hệ thống |
| Trang chủ | Tên xưởng, giá trưng bày, một nút Chơi hoặc Tiếp tục, hai hàng điều hướng Bảo tàng và Cài đặt |
| Bài hướng dẫn | Thanh tiến độ theo thao tác mở thùng và ghép đuôi. Có thể kéo thả hoặc chạm mảnh rồi chạm bóng. Xem lại từ Cài đặt sẽ quay về Cài đặt |
| Bàn ghép | Số mảnh và thanh tiến độ đặt trên bàn. Khay có nhãn riêng. Mảnh được chọn có viền và dấu kiểm. Hai cách nhập dùng cùng phép kiểm tra vị trí |
| Bảo tàng | Trạng thái trống giải thích cách kiếm hiện vật và có nút đến xưởng. Khi đã hoàn tất, hiện bộ xương và kỷ lục |
| Kích thước | Điều khiển chính cao từ 52 dp, danh sách cuộn trong SafeArea, bề rộng nội dung tối đa 600 dp |

## Tiếp tục thiết kế trong dự án
Các chỉ dẫn phát triển được đặt tại `.agents/skills/`. Tên kho, phiên bản nguồn và đường dẫn từng SKILL.md nằm trong `skills-lock.json`. Khi thay đổi giao diện, đọc mobile-design, interface-design, ui-ux-pro-max và game-ui-ux; dùng expo-design-system cho nguyên tắc tổ chức token, rồi triển khai bằng Flutter. Đối chiếu màu, kích thước chữ, trạng thái trống và khả năng thao tác của các luồng trước khi bàn giao.

## Kiểm chứng bản giao diện
Flutter 3.32.8, Dart 3.8.1. Đã kiểm tra 7 ca model/widget, gồm luồng Home → hướng dẫn → bản đồ → mở thùng → bàn ghép → ghép đuôi bằng hai lần chạm. Trường hợp khổ 320 dp với chữ 160% bao phủ bài hướng dẫn. Đã dựng và xem ảnh trang chủ và bàn ghép ở 390 × 800 bằng Flutter widget renderer; ảnh dùng font thử nghiệm hỗ trợ tiếng Việt. Có thể xem ảnh trong docs/home-preview.png và docs/board-preview.png. Đã biên dịch web release. Chưa chạy trên Android/iOS thật hoặc đo FPS.
