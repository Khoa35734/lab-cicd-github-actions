# Thực hành CI/CD ngôn ngữ C với GitHub Actions

## Cấu trúc

```text
.
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── release.yml
├── .gitattributes
├── .gitignore
├── Makefile
├── prime_utils.c
├── test_app.c
├── setup_and_run.sh
└── README.md
```

## Kiểm tra trên Ubuntu/WSL

```bash
sudo apt-get update && sudo apt-get install -y gcc make cppcheck
make lint
make build
make test
make clean
```

### Cấu hình lint cho CI

Makefile sử dụng lệnh:

```bash
cppcheck --enable=all --error-exitcode=1 \
  --suppress=missingIncludeSystem --suppress=checkersReport \
  prime_utils.c test_app.c
```

`--enable=all` kết hợp `--error-exitcode=1` có thể làm CI thất bại chỉ vì
hai thông báo thông tin: `missingIncludeSystem` (không tìm thấy header hệ thống)
và `checkersReport` (thống kê các checker đang hoạt động).
Hai tùy chọn `--suppress` bỏ qua đúng hai thông báo này; các chẩn đoán khác
vẫn làm lint thất bại theo `--error-exitcode=1`.
Theo [tài liệu Cppcheck](https://cppcheck.sourceforge.io/manual.html), Cppcheck
hỗ trợ suppression theo ID và không cần phân tích header thư viện chuẩn
để kiểm tra mã nguồn.

`make test` biên dịch lại rồi kiểm tra 1, 2, 3, 4, 5 và `INT_MAX` (2147483647).
Khi thành công, chương trình in:

```text
TẤT CẢ CÁC BÀI UNIT TEST ĐÃ VƯỢT QUA SẠCH LỖI!
```

## Đẩy code và phát hành

Tạo một repository GitHub **rỗng**, cấu hình danh tính Git và xác thực GitHub
trên máy. Chạy trong Git Bash, WSL hoặc Linux, thay URL bằng repository của bạn:

```bash
git config --global user.name "Tên của bạn"
git config --global user.email "email@example.com"
bash setup_and_run.sh https://github.com/USERNAME/REPOSITORY.git
```

Script dành cho lần khởi tạo đầu tiên: tạo repo, commit các file thực hành,
đẩy `main`, sau đó tạo và đẩy tag `v1.0.0`. Tài liệu Word có sẵn không nằm trong
danh sách file được script đưa vào commit.

CI chạy Lint → Build → Test khi push hoặc mở/cập nhật pull request vào `main`.
CD chạy khi push tag `v*`, build và đóng gói `validator` thành
`prime-validator-linux-amd64.tar.gz`, sau đó đưa lên GitHub Releases với ghi chú
phát hành tự động. Cấu hình release sử dụng `contents: write` và `GITHUB_TOKEN`
theo [tài liệu action-gh-release v2](https://github.com/softprops/action-gh-release/tree/v2).

Hai workflow chạy độc lập theo yêu cầu bài thực hành; CD không đợi kết quả CI.

## Mô phỏng lỗi và khôi phục

Sau khi khởi tạo, script in hướng dẫn đầy đủ. Có thể chạy trực tiếp các lệnh sau
trong cùng phiên Bash tại thư mục repository:

```bash
# Làm sai kết quả cho số 4.
sed -i '/^int is_prime(int n)$/,/^}/ s/^    if (n <= 1) {/    if (n == 4) { return 1; }\n    if (n <= 1) {/' prime_utils.c
git diff -- prime_utils.c
git add -- prime_utils.c
git commit -m "test: intentionally break primality check for 4"
BROKEN_COMMIT=$(git rev-parse HEAD)
printf 'Lưu mã commit lỗi: %s\n' "$BROKEN_COMMIT"
git push origin main

# CI sẽ thất bại tại Stage 3 - Test vì assert cho số 4.
# Đợi lượt CI hoàn tất trong tab Actions, rồi khôi phục.
git revert --no-edit "$BROKEN_COMMIT"
git push origin main
```

Nếu mở terminal mới, thay `$BROKEN_COMMIT` bằng mã commit lỗi đã lưu.
Sau khi khôi phục, unit test sẽ chạy thành công trở lại. Kiểm tra CI chạy xanh
trở lại trong tab Actions.
