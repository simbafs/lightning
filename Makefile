# ==============================
# Local-only build (no cross)
# ==============================

# 二進位檔名（預設用資料夾名）
BINARY ?= $(notdir $(CURDIR))

# 輸出資料夾
DIST ?= dist

# Go 與 CGO
GO ?= go
CGO ?= 1

# 模式：release / debug
MODE ?= release

# 共用 flags
GO_LDFLAGS_RELEASE ?= -s -w
GO_LDFLAGS_DEBUG   ?=
GO_GCFLAGS_DEBUG   ?= all=-N -l

# 讓你可透過環境變數覆蓋（例如指定 include/lib）
# 例：make build CGO_CFLAGS="-I$$HOME/raylib/include" CGO_LDFLAGS="-L$$HOME/raylib/lib -lraylib"
CGO_CFLAGS ?=
CGO_LDFLAGS ?=

# 偵測主機系統與附檔名
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Windows（含 MSYS2/MINGW）附檔名
EXE :=
ifeq ($(OS),Windows_NT)
  EXE := .exe
endif
# 兼容 MSYS2/MINGW 的情況
ifneq (,$(findstring MINGW,$(UNAME_S)))
  EXE := .exe
endif

# 依模式切換 flags
ifeq ($(MODE),release)
  GO_LDFLAGS := $(GO_LDFLAGS_RELEASE)
  GO_GCFLAGS :=
else
  GO_LDFLAGS := $(GO_LDFLAGS_DEBUG)
  GO_GCFLAGS := $(GO_GCFLAGS_DEBUG)
endif

# macOS：如需設定最低版本，可自行覆蓋 MACOSX_MIN
# 範例：make build MACOSX_MIN=-mmacosx-version-min=12.0
ifeq ($(UNAME_S),Darwin)
  ifneq ($(strip $(MACOSX_MIN)),)
    GO_LDFLAGS := $(GO_LDFLAGS) '-extldflags=$(MACOSX_MIN)'
  endif
endif

.PHONY: build release debug run clean info fmt vet help

default: release

help:
	@echo "用法："
	@echo "  make build          以當前 MODE 編譯（預設 release）"
	@echo "  make release        等同 MODE=release 的 build"
	@echo "  make debug          等同 MODE=debug 的 build"
	@echo "  make run            編譯後直接執行"
	@echo "  make clean          清除 dist/"
	@echo "  make info           顯示環境資訊"
	@echo
	@echo "常用覆蓋變數：BINARY, MODE, CGO_CFLAGS, CGO_LDFLAGS, MACOSX_MIN"
	@echo "例：make build MODE=debug CGO_LDFLAGS='-L$$HOME/raylib/lib -lraylib'"

$(DIST):
	@mkdir -p $(DIST)

build: $(DIST)
	@echo ">> Building (host) on $(UNAME_S)/$(UNAME_M) [MODE=$(MODE)]"
	@echo ">> Output: $(DIST)/$(BINARY)$(EXE)"
	CGO_ENABLED=$(CGO) \
	CGO_CFLAGS="$(CGO_CFLAGS)" \
	CGO_LDFLAGS="$(CGO_LDFLAGS)" \
	$(GO) build -o $(DIST)/$(BINARY)$(EXE) \
		-ldflags "$(GO_LDFLAGS)" \
		-gcflags "$(GO_GCFLAGS)" \
		.

release:
	$(MAKE) build MODE=release

debug:
	$(MAKE) build MODE=debug

run: build
	@echo ">> Running ./$(DIST)/$(BINARY)$(EXE)"
	@./$(DIST)/$(BINARY)$(EXE)

clean:
	@rm -rf $(DIST)
	@echo ">> Cleaned $(DIST)/"

fmt:
	$(GO) fmt ./...

vet:
	$(GO) vet ./...

info:
	@echo "OS:      $(UNAME_S)"
	@echo "ARCH:    $(UNAME_M)"
	@echo "GO:      $$($(GO) version)"
	@echo "CGO:     $(CGO)"
	@echo "MODE:    $(MODE)"
	@echo "BINARY:  $(BINARY)$(EXE)"
	@echo "CFLAGS:  $(CGO_CFLAGS)"
	@echo "LDFLAGS: $(CGO_LDFLAGS) | go -ldflags '$(GO_LDFLAGS)'"
	@echo
	@$(GO) env | grep -E 'GOOS|GOARCH|GOMOD|GOCACHE|GOMODCACHE' || true

