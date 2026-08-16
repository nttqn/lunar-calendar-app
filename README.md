# Lịch Âm Dương

Ứng dụng lịch âm dương trên Android, viết bằng Flutter. Xem lịch tháng với
ngày dương và ngày âm song song, xem giờ/ngày hoàng đạo, can chi năm/tháng/
ngày, lễ tết, chuyển đổi ngày dương ↔ âm, và tạo sự kiện cá nhân (sinh nhật,
giỗ...) theo ngày dương hoặc âm với nhắc lịch lặp lại hằng năm. Tích hợp
quảng cáo AdMob (banner) để chuẩn bị publish lên Google Play.

## Cấu trúc dự án

```
lib/
  main.dart                    # Khởi tạo AdMob/thông báo/sự kiện, cấu hình locale, chạy app
  lunar/
    lunar_calendar.dart        # Thuật toán chuyển đổi dương <-> âm (Hồ Ngọc Đức)
    can_chi.dart                # Can-Chi năm/tháng/ngày/giờ
    hoang_dao.dart              # Bảng tra ngày/giờ hoàng đạo
    holidays.dart               # Danh sách lễ tết cố định (dương + âm)
  models/
    day_info.dart                # Gộp thông tin 1 ngày: âm lịch, can chi, hoàng đạo, lễ
    personal_event.dart          # Sự kiện cá nhân + tính ngày lặp lại hằng năm tiếp theo
  screens/
    calendar_screen.dart         # Lịch tháng dạng lưới
    convert_screen.dart          # Chuyển đổi dương <-> âm
    events_screen.dart           # Danh sách sự kiện cá nhân
    add_event_screen.dart        # Form thêm/sửa sự kiện cá nhân
  services/
    ads_service.dart             # Bọc AdMob banner
    event_repository.dart        # Lưu trữ (shared_preferences) + phát thông báo khi có thay đổi
    notification_service.dart    # Lên lịch nhắc sự kiện (flutter_local_notifications)
  widgets/
    banner_ad_widget.dart        # Widget hiển thị banner ads
    day_detail_panel.dart        # Panel chi tiết ngày (dùng trong calendar_screen)
    date_header_card.dart        # Thẻ tiêu đề ngày đang chọn
    hoang_dao_hours.dart         # Lưới giờ hoàng đạo
    number_field.dart            # Ô nhập số dùng chung (ngày/tháng/năm)
    zodiac_icon.dart             # Emoji 12 con giáp
tool/
  patch_signing.js             # CI: gắn signingConfig release vào build.gradle(.kts)
  proguard-rules-extra.pro     # CI: rule R8 giữ lại class WorkManager cần
.github/workflows/
  build-apk.yml                # Build APK/AAB tự động trên GitHub Actions (cloud)
```

Thư mục `android/` (và `ios/`, `web/`...) **không** được commit vào git —
xem phần "Vì sao không có thư mục android/" bên dưới.

## Vì sao không có thư mục android/?

Máy hiện tại có Flutter SDK nhưng chưa cài Android SDK/Android Studio
(`flutter doctor` báo "Unable to locate Android SDK"), nên không tự
`flutter create` sinh project native được ở đây. Thay vào đó:

- Toàn bộ code Dart/Flutter (logic + giao diện) đã viết đầy đủ.
- File `.github/workflows/build-apk.yml` sẽ, mỗi khi chạy trên GitHub Actions:
  1. Cài Flutter trong máy ảo cloud.
  2. Chạy `flutter create --platforms=android .` để tự sinh khung project
     Android (gradle, AndroidManifest.xml, icon mặc định...).
  3. Vá thêm vào `AndroidManifest.xml`: quyền INTERNET, AdMob App ID (dùng
     ID TEST của Google nếu bạn chưa cấu hình secret thật), và tên app
     hiển thị "Lịch Âm Dương".
  4. `flutter pub get`, `flutter build apk --release` + `appbundle --release`.
  5. Đăng file APK/AAB lên phần **Artifacts** của lần chạy đó để bạn tải về.

Lưu ý: `google_mobile_ads` yêu cầu `minSdk 24` trở lên (Android 7.0+), nên
workflow tự nâng `minSdkVersion`/`compileSdk` của project lên 24/36 sau
bước `flutter create`.

## Cách lấy file APK

1. Tạo một repo GitHub (private hoặc public đều được) và push toàn bộ thư
   mục này lên (xem lệnh git ở cuối README).
2. Vào tab **Actions** trên GitHub → chọn workflow **Build Android APK** →
   **Run workflow** (hoặc chỉ cần push lên nhánh `main`, workflow tự chạy).
3. Đợi build xong (khoảng 3-5 phút), mở lần chạy đó, kéo xuống phần
   **Artifacts**, tải file `amlich-release-apk`.
4. Giải nén ra được `app-release.apk`, copy vào điện thoại Android và cài
   (cần bật "Cài từ nguồn không xác định" trong Settings).

File APK build theo cách này **chỉ ký bằng debug key** — cài thử trên điện
thoại thoải mái, nhưng **Google Play sẽ từ chối** vì đó là khóa debug công
khai. Xem phần ký release bên dưới trước khi publish thật.

## Muốn xem giao diện nhanh mà chưa build APK?

Flutter đã cài sẵn trong máy này (không cần Android SDK để chạy trên web):

```
flutter pub get
flutter run -d chrome
```

## Trước khi publish lên Google Play — checklist

1. **Tài khoản AdMob thật** — đã cấu hình:
   - `bannerAdUnitId` trong
     [lib/services/ads_service.dart](lib/services/ads_service.dart) đã là
     Ad unit ID thật.
   - App ID thật cần được thêm làm GitHub secret `ADMOB_APP_ID` (Settings →
     Secrets and variables → Actions → New repository secret) — **secret
     này do bạn tự thêm trên GitHub**, không thể set qua code/CI.
   - Test ads chỉ để dev thử, **không được** tự bấm quảng cáo của chính
     mình sau khi dùng ID thật — vi phạm chính sách AdMob có thể bị khóa
     tài khoản.

2. **Package name / tên nhà phát triển**
   - Hiện đang dùng org `com.trungapps`, project `amlich` → applicationId
     `com.trungapps.amlich`. Muốn đổi thì sửa dòng `--org`/`--project-name`
     trong `.github/workflows/build-apk.yml`.

3. **Ký release (bắt buộc để publish)**
   - Workflow đã có sẵn bước "Configure release signing": nếu 4 secret bên
     dưới tồn tại trên GitHub repo, nó tự giải mã keystore, tạo
     `android/key.properties`, và trỏ `signingConfig` của bản release sang
     keystore đó trước khi build — cả file APK lẫn AAB đều được ký thật.
     Thiếu secret thì build vẫn chạy nhưng quay lại ký bằng debug key như
     cũ (chỉ để cài thử, Play Store sẽ từ chối).
   - Vào GitHub repo → **Settings → Secrets and variables → Actions → New
     repository secret**, thêm 4 secret:
     | Secret | Giá trị |
     |---|---|
     | `KEYSTORE_BASE64` | Nội dung file keystore, mã hoá base64 |
     | `KEYSTORE_PASSWORD` | Mật khẩu keystore |
     | `KEY_ALIAS` | Alias của key trong keystore |
     | `KEY_PASSWORD` | Mật khẩu key |
   - **Giữ file keystore thật kỹ** — mất file này (hoặc quên mật khẩu) thì
     không bao giờ update được app đã publish nữa, phải tạo app mới hoàn
     toàn trên Play Console. Đừng commit file keystore hay
     `key.properties` vào git (đã có sẵn trong `.gitignore`).
   - Tự tạo keystore mới (chạy trên máy có cài JDK — `keytool` đi kèm sẵn):
     ```
     keytool -genkeypair -v -keystore amlich-release.jks -alias amlich -keyalg RSA -keysize 2048 -validity 10000
     ```
     rồi mã hoá base64 để dán vào secret `KEYSTORE_BASE64` (PowerShell):
     ```powershell
     [Convert]::ToBase64String([IO.File]::ReadAllBytes("amlich-release.jks")) | Set-Clipboard
     ```
   - CI build ra cả **APK** (`amlich-release-apk`, cài thử trực tiếp lên
     điện thoại) và **AAB** (`amlich-release-aab`, dùng file này để nộp
     lên Play Console — Play Store bắt buộc định dạng AAB cho app mới).

4. **Icon ứng dụng**
   - Đã có icon riêng tại `assets/icon/icon.png` (mặt trời/mặt trăng +
     vòng 12 con giáp + chữ "Lịch Âm Dương"). CI tự chạy
     `flutter_launcher_icons` để sinh icon cho mọi mipmap density mỗi lần
     build. Muốn đổi icon, thay file `assets/icon/icon.png` (ảnh vuông
     PNG, nên ≥1024x1024) rồi push lại.

5. **Google Play Console**
   - Đăng ký tài khoản nhà phát triển (phí một lần 25 USD):
     https://play.google.com/console
   - Tạo app mới, điền mô tả, ảnh chụp màn hình, banner.
   - Khai báo **Data Safety** (bắt buộc vì có AdMob — AdMob có thể thu
     thập Advertising ID để cá nhân hoá quảng cáo).
   - Cung cấp **Chính sách quyền riêng tư** (Privacy Policy URL) — bắt
     buộc với app có quảng cáo.

## Sự kiện cá nhân + nhắc lịch

- Thêm sự kiện ở tab **Sự kiện**, chọn ngày dương hoặc âm, và chọn kiểu lặp:
  **Lặp lại hằng năm** (chỉ cần ngày/tháng) hoặc **Không lặp lại** (chọn cả
  ngày/tháng/năm — chỉ nhắc đúng một lần). Giữ (long-press) một sự kiện
  trong danh sách để xóa nhanh (có nút "Hoàn tác").
- Ứng dụng dùng `flutter_local_notifications` để đặt thông báo nhắc, giờ
  mặc định 8:00 sáng (chỉnh được từng sự kiện). Cần quyền
  **POST_NOTIFICATIONS** (Android 13+) — app tự xin quyền này lúc mở lần
  đầu; workflow CI đã tự thêm quyền này vào `AndroidManifest.xml`.
- **Giới hạn cần biết**: app không có backend/server đẩy thông báo, nên khi
  thêm một sự kiện, ứng dụng chỉ đặt sẵn lịch nhắc cho **5 lần lặp lại tiếp
  theo** (khoảng 5 năm), rồi tự bổ sung thêm mỗi khi mở lại app. Nếu người
  dùng không mở app trong hơn 5 năm liên tục, thông báo sẽ ngừng cho tới
  lần mở lại tiếp theo. Đây là đánh đổi hợp lý cho một app không có server.

## Độ chính xác của lịch âm và bảng hoàng đạo

- Thuật toán chuyển đổi dương ↔ âm (`lib/lunar/lunar_calendar.dart`) dựa
  trên tính toán thiên văn (điểm sóc, kinh độ mặt trời) theo thuật toán phổ
  biến của Hồ Ngọc Đức — chính xác cho khoảng thời gian rất rộng, không
  phải bảng tra cứng cho vài chục năm.
- Bảng "giờ hoàng đạo" / "ngày hoàng đạo" (`lib/lunar/hoang_dao.dart`) là
  bảng tra truyền thống theo lịch vạn niên dân gian, được cài đặt lại từ
  trí nhớ về bảng phổ biến — nên đối chiếu lại với một cuốn lịch vạn niên
  in sẵn trước khi hoàn toàn tin tưởng, vì các nguồn dân gian đôi khi lệch
  nhau vài chi tiết.

## Đưa code lên GitHub

```
git init
git add .
git commit -m "Initial commit: lunar calendar app with AdMob"
git branch -M main
git remote add origin <URL_REPO_CUA_BAN>
git push -u origin main
```
