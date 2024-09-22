# React + TypeScript + Vite
## สร้าง web app ด้วย Docker แล้ว deploy ขึ้น AWS
### IP เครื่อง http://18.139.217.19:3002/
-----------------------------------------------
ขั้นตอนการดำเนินการ

   สร้าง Dockerfile ไว้ในโปรเจกต์ เพื่อตั้งค่าโปรเจกต์ Bun ที่ทำงานร่วมกับ Nginx โดยมีการทำงานแบบสองขั้นตอน (multi-stage build) ซึ่งช่วยให้ขนาดของ image ที่ได้มีขนาดเล็กลง และทำงานได้อย่างมีประสิทธิภาพมากขึ้น
การสร้างแอปด้วย Bun เป็นการเตรียมและสร้างแอปพลิเคชัน Bun ก่อนนำไปใช้งานกับ Nginx ในขั้นต่อไป

```
# Build stage
FROM node:16-buster as build

# Install Bun
RUN apt-get update && apt-get install -y curl && \
    curl -fsSL https://bun.sh/install | bash

# Set PATH for Bun
ENV PATH="/root/.bun/bin:${PATH}"

WORKDIR /app
COPY package*.json ./
RUN bun install
COPY . .
RUN bun run build
```

   การใช้ Nginx เพื่อให้บริการแอป ขั้นตอนนี้ใช้ Nginx ในการทำให้แอปพลิเคชันที่ถูกสร้างพร้อมให้เข้าถึงผ่านเว็บ

```
FROM nginx:alpine-slim
COPY --from=bun-builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

ไปสร้าง repository ชื่อ amorntheps/as2-react ไว้ที่ Docker Hub https://hub.docker.com/
กลับมาที่โปรแกรม VSCODE สร้าง Docker image ชื่อ arrukex/ct648_bun_react_docker:react-app จาก Dockerfile ในไดเรกทอรีปัจจุบัน และ push image ขึ้นไปยัง Docker Hub ด้วยคำสั่ง

```
docker push amorntheps/as2-react
```

ทดสอบ run ด้วยคำสั่ง
```
docker run -d -p 3002:80 amorntheps/as2-react
```

ขั้นตอนการดำเนิน Deploy
SSH เข้าไปที่ instance EC2 ที่สร้างไว้ใน aws ในที่นี้ใช้ Ubuntu
install docker โดยคำสั่ง

```
Update
sudo apt update
install docker
sudo apt install docker.io
```

ดึง Docker image ที่ชื่อ amorntheps/as2-react จาก Docker Hub ที่สร้างและ push ขึ้นไปไว้ก่อนหน้านี้มายังเครื่อง instance EC2 ของเรา ด้วยคำสั่งนี้
```
sudo docker pull amorntheps/as2-react
```
ทดสอบ run ด้วยคำสั่ง
```
docker run -d -p 3002:80 amorntheps/as2-react
```
เมื่อ run ผ่านและไม่มี error ก็เข้าไปดูหน้า web ด้วย Public IP ของเครื่อง instance EC2
