# Kế hoạch triển khai tiếp theo
Mốc tuần tính từ lúc đội bắt đầu dự án. Nguồn lực theo plan gốc gồm 1 Flutter developer, 1 game artist và designer/QA bán thời gian. Tuần 1–4 đã có mã nền trong gói này. Cần vượt cổng A trước khi coi giai đoạn đó hoàn thành.

| Mốc | Người phụ trách và đầu vào | Công việc theo thứ tự | Bàn giao và điều kiện chuyển bước |
|---|---|---|---|
| A · Tuần 1–4, xác nhận màn mẫu | Dev + QA, source slice | Khởi tạo Android/iOS; khóa phiên bản package; analyze, test, chạy QA-01…06. Artist tinh chỉnh các cụm khó nhận. Thử người mới trong 60 giây | Build có thể cài, log test và nhận xét theo từng mảnh. Chạy lại sau sửa. Chỉ nhân bản màn khi thao tác ghép, save và đọc hình đều đạt |
| B · Đầu tuần 5, editor | Dev + designer, schema và loader đã xác nhận | Viết module validate dùng chung; thêm pivot mặc định để tương thích level 001; triển khai import → canvas → inspector → export; gắn preview. Designer tái tạo màn 001 từ asset độc lập | ED-02a/b/c có fixture trước–sau và kiểm tra lỗi. Xuất một màn mới rồi chơi từ menu thật |
| C · Tuần 5, art và nội dung | Artist + designer; chuẩn bị concept từ tuần 1, sản xuất sau A | Duyệt danh sách 10 loài và tỷ lệ silhouette. Pilot thêm 1 loài, đo giờ vẽ/cắt/QA. Lập catalog; author 3 màn/loài theo lô, validate mỗi commit. Dev kết nối map, router và mở khóa | ART-03, LV-04: thống kê đủ 10 loài/30 ID, thư mục nguồn asset, log validator, phiếu hoàn thành từng màn. Nếu tốc độ pilot thiếu, báo số màn hoàn chỉnh và điều chỉnh lịch |
| D · Tuần 6, save v2 và Museum | Dev + QA, ID catalog ổn định | Tạo repository có transaction; đọc v1 trước; migrate các fixture; chuyển Victory sang một lệnh complete; cấp hiện vật theo speciesId. Dựng lưới bộ sưu tập và chi tiết | SAVE-05, MUS-05: ảnh trước/sau migration, số xu trước/sau replay, thử tắt tiến trình ở mảnh cuối. Tất cả kiểm tra offline |
| E · Tuần 7, rewarded và polish | Dev + designer, attemptId và ví ổn định | Dùng adapter giả lập cho chuỗi callback, rồi tích hợp SDK với ad unit thử nghiệm; thêm earned ledger, đếm giới hạn theo lượt; kiểm tra âm/rung và mức âm. Xác định có cần analytics cho thử nghiệm hay chưa | ADS-06: log test có thành công, lỗi mạng, đóng sớm và callback trùng. Người từ chối tiếp tục giải màn. Audio không phát khi tắt |
| F · Tuần 8, release candidate | Dev + QA, ma trận thiết bị và signing của dự án | Freeze catalog, chạy hồi quy toàn bộ, profile màn nặng nhất, thử nâng cấp từ bản cũ, build có obfuscation; smoke test chính file phân phối | REL-07: checklist theo OS, build ID, symbols lưu riêng, kết quả đo FPS và thử novice. Bản có lỗi mất save/thưởng trùng quay lại D/E |

## Backlog đầu sprint kế tiếp
1. **DEV-01** Chạy bootstrap và model_test trên máy có SDK. Lưu pubspec.lock, phiên bản SDK, log và lỗi build nếu có. Phụ thuộc duy nhất là toolchain mobile.
2. **QA-01** Thử màn 001 offline, zoom rồi kéo đúng, sai và hủy; quay lại sau force-stop. Ghi video hoặc bước tái hiện và ảnh vị trí nếu pointer lệch. Dev sửa trước khi thay kích thước sprite.
3. **ART-01** Duyệt bộ xương T‑Rex ghép đủ với designer. Đánh dấu ranh giới các khớp, điều chỉnh artwork và tọa độ cùng một thay đổi. Chạy validator và QA-02 lại.
4. **ED-01** Chốt fixture round-trip gồm một mảnh xoay qua 0°, pivot lệch tâm và thùng rỗng. Implement preview trên cùng lớp game, test tọa độ trước khi làm toolbar.
5. **LV-01** Sau khi editor pass, author màn 002 và mở khóa từ Victory 001. Dùng cặp màn này làm fixture cho save v2, sau đó mới nhập toàn bộ catalog.

## Quyết định còn mở
Designer chọn danh sách chín loài tiếp theo sau khi duyệt silhouette và chi phí art. QA và chủ sản phẩm chọn thiết bị tối thiểu trước khi đo FPS. Quyết định trần quảng cáo và ngưỡng sao dựa trên quan sát playtest. Interstitial, IAP và backend ở backlog sau MVP.
