#----- Stage 1 -----
FROM maven:3.8.3-openjdk-17 AS builder 

WORKDIR /app

COPY . .

RUN mvn clean package -DskipTests=true

#----- Stage 2 -----
FROM eclipse-temurin:17-jdk-alpine AS deployer

COPY --from=builder /app/target/*.jar /app/target/app.jar

EXPOSE 8080    

CMD ["java", "-jar", "/app/target/app.jar"]
