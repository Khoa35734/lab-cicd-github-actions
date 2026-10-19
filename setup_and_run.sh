#!/usr/bin/env bash
set -euo pipefail

# Chạy trong Git Bash, WSL hoặc Linux:
# bash setup_and_run.sh https://github.com/USERNAME/REPOSITORY.git
# Tạo trước repository GitHub rỗng, không thêm README/license/.gitignore.
# Cần cài Git và cấu hình user.name, user.email; đăng nhập GitHub qua SSH/HTTPS.

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

if [[ $# -ne 1 || -z "$1" ]]; then
    printf 'Cách dùng: bash setup_and_run.sh <URL_REPOSITORY_GITHUB>\n' >&2
    exit 1
fi

REPO_URL="$1"

git init
git add -- prime_utils.c test_app.c Makefile .github/workflows/ci.yml \
    .github/workflows/release.yml setup_and_run.sh .gitignore .gitattributes README.md
git update-index --chmod=+x setup_and_run.sh
git commit -m "feat: initialize C CI/CD lab with GitHub Actions"
git branch -M main
git remote add origin "$REPO_URL"
git push -u origin main

git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

cat <<'GUIDE'

Đã đẩy main và tag v1.0.0. Mở tab Actions để xem CI/CD và Releases để tải artifact.

MÔ PHỎNG LÀM SẬP PIPELINE
Chạy lần lượt các lệnh sau tại thư mục repository bằng Bash:

# 1. Chèn lỗi: trả về 1 khi n == 4.
sed -i '/^int is_prime(int n)$/,/^}/ s/^    if (n <= 1) {/    if (n == 4) { return 1; }\n    if (n <= 1) {/' prime_utils.c
git diff -- prime_utils.c
git add -- prime_utils.c
git commit -m "test: intentionally break primality check for 4"
BROKEN_COMMIT=$(git rev-parse HEAD)
printf 'Lưu mã commit lỗi để khôi phục: %s\n' "$BROKEN_COMMIT"
git push origin main

# 2. Mở tab Actions, đợi CI hoàn tất. Nếu lint chạy qua, CI sẽ thất bại ở Stage 3:
#    assert(is_prime(4) == 0) sẽ thất bại.
#    Nếu CI dừng ở Stage 1, xem hạn chế Cppcheck trong README.md.
#    Không tạo tag release cho commit lỗi này.

# 3. Khôi phục trong cùng phiên Bash:
git revert --no-edit "$BROKEN_COMMIT"
git push origin main

# Nếu đã đóng terminal, thay "$BROKEN_COMMIT" bằng mã commit lỗi đã lưu.
# Mở tab Actions và kiểm tra CI; hạn chế lint trong README.md vẫn áp dụng.
GUIDE
