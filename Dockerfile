###############################################################################
# Build image
###############################################################################
FROM golang:1.20-alpine AS builder
MAINTAINER helailiang

# 安装编译依赖
RUN apk add --no-cache git gcc g++ make

# 设置工作目录
WORKDIR /app

# 复制go mod文件
COPY go.mod go.sum ./
# 下载依赖
RUN go mod download

# 复制源代码
COPY . .

# 环境变量
# 用于代理下载go项目依赖的包
ENV GOPROXY https://goproxy.cn,direct
# 编译，关闭CGO，生成静态链接的二进制文件
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o gohttpd main.go

###############################################################################
# Runtime image
###############################################################################
FROM alpine:latest AS runner

# 安装ca证书，用于HTTPS请求
RUN apk --no-cache add ca-certificates tzdata
# 设置时区
ENV TZ=Asia/Shanghai

# 全局工作目录
WORKDIR /app

# 从构建阶段复制编译好的二进制文件
COPY --from=builder /app/gohttpd .

# 暴露端口（默认8888，可通过启动参数修改）
EXPOSE 8888

# docker run命令触发的真实命令
# 默认监听8888端口，可通过环境变量PORT覆盖
ENTRYPOINT ["./gohttpd"]
CMD ["8888"]