# run: 
# 	go run -tags x11 .
#
# dev: 
# 	nodemon -e go --watch './**/*.go' --signal SIGTERM --exec go run -tags x11 .
#
# build: 
# 	go build -tags x11 .

# ---- 可自訂參數 -------------------------------------------------------------

# 專案輸出檔名（不含附檔名），預設用目前資料夾名
BINARY ?= $(notdir $(CURDIR))

# Go 執行檔
GO ?= go

# Go 共通 ldflags（精簡符號表）
GO_LDFLAGS ?= -s -w

# 若你需要額外傳入 raylib 的 include/lib 路徑，可用環境變數覆蓋
CGO_CFLAGS ?=
CGO_LDFLAGS ?=

# MinGW / OSXCross 工具鏈（依照你系統實際安裝調整）
CC_WIN64      ?= x86_64-w64-mingw32-gcc
CC_WIN32      ?= i686-w64-mingw32-gcc
CC_DARWIN_AMD ?= x86_64-apple-darwin21.1-clang
CC_DARWIN_ARM ?= aarch64-apple-darwin21.1-clang

# macOS 外部連結器版本門檻
MACOSX_MIN_AMD ?= -mmacosx-version-min=10.15
MACOSX_MIN_ARM ?= -mmacosx-version-min=12.0.0

# 成品輸出目錄
DIST ?= dist

# ---------------------------------------------------------------------------

.PHONY: all help win64 win32 darwin_amd64 darwin_arm64 linux_amd64 linux_arm64 clean

all: linux_amd64 win64 # darwin_amd64 # win32 darwin_arm64

help:
	@echo "用法：make <target>"
	@echo
	@echo "可用 target："
	@echo "  linux_amd64   編譯 Linux amd64 (本機常用)"
	@echo "  linux_arm64   編譯 Linux arm64 (樹莓派等)"
	@echo "  win64         交叉編譯 Windows amd64（需要 MinGW-w64）"
	@echo "  win32         交叉編譯 Windows 386（需要 MinGW-w64）"
	@echo "  darwin_amd64  交叉編譯 macOS x86_64（需要 OSXCross）"
	@echo "  darwin_arm64  交叉編譯 macOS arm64（需要 OSXCross）"
	@echo "  clean         刪除 dist/"
	@echo
	@echo "可覆蓋變數：BINARY, GO_LDFLAGS, CGO_CFLAGS, CGO_LDFLAGS"

$(DIST):
	@mkdir -p $(DIST)

# ---- Linux amd64 ------------------------------------------------------------
linux_amd64: $(DIST)
	@echo ">> Building Linux amd64..."
	CGO_ENABLED=1 \
	GOOS=linux GOARCH=amd64 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-linux-amd64 \
		-ldflags "$(GO_LDFLAGS)"

	@file $(DIST)/$(BINARY)-linux-amd64 || true

# ---- Linux arm64 ------------------------------------------------------------
linux_arm64: $(DIST)
	@echo ">> Building Linux arm64..."
	CGO_ENABLED=1 \
	GOOS=linux GOARCH=arm64 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-linux-arm64 \
		-ldflags "$(GO_LDFLAGS)"

	@file $(DIST)/$(BINARY)-linux-arm64 || true

# ---- Windows amd64 ----------------------------------------------------------
win64: $(DIST)
	@echo ">> Building Windows amd64..."
	CGO_ENABLED=1 \
	CC=$(CC_WIN64) \
	GOOS=windows GOARCH=amd64 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-windows-amd64.exe \
		-ldflags "$(GO_LDFLAGS)"

	@file $(DIST)/$(BINARY)-windows-amd64.exe || true

# ---- Windows 386 ------------------------------------------------------------
win32: $(DIST)
	@echo ">> Building Windows 386..."
	CGO_ENABLED=1 \
	CC=$(CC_WIN32) \
	GOOS=windows GOARCH=386 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-windows-386.exe \
		-ldflags "$(GO_LDFLAGS)"

	@file $(DIST)/$(BINARY)-windows-386.exe || true

# ---- macOS x86_64 -----------------------------------------------------------
darwin_amd64: $(DIST)
	@echo ">> Building macOS x86_64..."
	CGO_ENABLED=1 \
	CC=$(CC_DARWIN_AMD) \
	GOOS=darwin GOARCH=amd64 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-darwin-amd64 \
		-ldflags "-linkmode external $(GO_LDFLAGS) '-extldflags=$(MACOSX_MIN_AMD)'"

	@file $(DIST)/$(BINARY)-darwin-amd64 || true

# ---- macOS arm64 ------------------------------------------------------------
darwin_arm64: $(DIST)
	@echo ">> Building macOS arm64..."
	CGO_ENABLED=1 \
	CC=$(CC_DARWIN_ARM) \
	GOOS=darwin GOARCH=arm64 \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)-darwin-arm64 \
		-ldflags "-linkmode external $(GO_LDFLAGS) '-extldflags=$(MACOSX_MIN_ARM)'"

	@file $(DIST)/$(BINARY)-darwin-arm64 || true

clean:
	@rm -rf $(DIST)
	@echo ">> Cleaned $(DIST)/"

