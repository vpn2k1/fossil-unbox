# Fossil Unbox · Màn T‑Rex
Game ghép xương dọc cho Android và iOS. Mốc bàn giao đầu tiên có 1 màn, 2 thùng và 4 cụm xương tự vẽ. Mục tiêu MVP trong plan gốc là 30 màn, 10 loài, khoảng 8 tuần với đội hình đề xuất. Đây là source bàn giao cho đội phát triển.

## Chạy trên thiết bị
Cần Flutter stable với Dart ≥ 3.5, Android SDK hoặc macOS + Xcode cho iOS. Từ thư mục chứa pubspec.yaml, chạy trong Bash:

```sh
bash tool/bootstrap.sh
flutter devices
flutter run
```

Bootstrap tạo vỏ dự án Android/iOS từ template của Flutter SDK đang dùng, giữ nguyên phần game. Lần lấy dependency đầu cần mạng. Bản UI này đã khóa dependency trong pubspec.lock và chạy kiểm thử bằng Flutter 3.32.8 / Dart 3.8.1. Khi chạy, asset và save đều ở máy.

Chọn **Chơi → Tyrannosaurus rex**, mở hai thùng rồi kéo từng mảnh vào hình tương ứng. Có thể mở một thùng trước rồi quay lại lấy phần còn lại. Dùng hai ngón để phóng to, kéo nền để di chuyển khi đã zoom. Màn đầu tắt xoay. Hoàn tất để xem hiện vật, sau đó ghép lại để cải thiện sao. Cài đặt âm thanh và rung áp dụng cho lần khớp tiếp theo.

## Kiểm tra và build
```sh
python3 tool/validate.py
flutter analyze
flutter test
SYMBOL_DIR="$HOME/fossil-symbols/android-0.1.0-1" bash tool/release.sh appbundle
# Trên macOS đã cấu hình signing cho iOS
SYMBOL_DIR="$HOME/fossil-symbols/ios-0.1.0-1" bash tool/release.sh ipa
```

Bản phân phối cần application ID, signing và provisioning của chủ sản phẩm. Script release bật obfuscation cho Dart. Lưu symbol riêng theo nền tảng, ABI, phiên bản và số build. Dùng `flutter symbolize -i trace.txt -d <file.symbols>` với đúng build khi điều tra crash. Asset đóng gói vẫn đọc được. Chưa build hay kiểm tra symbolication trong phiên này.

## Hồ sơ bàn giao
- [Spec và kiểm chứng màn T‑Rex](docs/slice.md)
- [Spec các phần tiếp theo](docs/spec-tiep-theo.md)
- [Kế hoạch triển khai, phụ thuộc và mốc nghiệm thu](docs/plan-tiep-theo.md)
- [Kịch bản kiểm thử trên thiết bị](docs/qa.md)
- [Quy trình tiếp tục sửa dữ liệu game](.agents/skills/demo-crud/SKILL.md)

lib/model.dart giữ hợp đồng level, luật snap, điểm và save. lib/board.dart vẽ bàn bằng Flame. lib/main.dart phụ trách tương tác, điều hướng và ghi snapshot qua shared_preferences. Bản một màn dùng state cục bộ và Navigator của Flutter; việc chuyển sang Riverpod/go_router nằm ở mốc catalog nhiều màn. Tái tạo art và âm bằng Python có Pillow qua `python tool/art.py`.
Từ gốc dự án có thể gọi `$demo-crud` để thêm hoặc sửa chức năng lưu tiến trình theo tiêu chí chấp nhận.

## Hướng dẫn lần đầu
Lần đầu bấm Chơi, mở thùng tập rồi kéo đuôi vào bóng mẫu. Chọn Vào bản đồ để chơi màn T‑Rex hoặc Bỏ qua hướng dẫn để đi thẳng. Cài đặt → Tập ghép xương lại mở lại bài tập. Hồ sơ cũ đã mở thùng hoặc có sao tiếp tục vào bản đồ. Bài tập dùng cùng PNG đuôi với màn 01 và độc lập với lượt chơi, sao, xu và gợi ý.

## Thiết kế giao diện và skill dự án
Xem [DESIGN.md](DESIGN.md) để tiếp tục chỉnh giao diện. Các skill từ năm kho được đóng gói trong thư mục ẩn .agents/skills; bảng nguồn trong skills-lock.json và giấy phép trong docs/skill-licenses. Cấu hình Flutter và Flame nằm trong pubspec.yaml.
