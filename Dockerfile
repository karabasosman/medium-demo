# Stage 1: Build
FROM maven:3.8.5-openjdk-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY .github/settings.xml /root/.m2/settings.xml
RUN mvn dependency:go-offline
COPY . .
RUN mvn package -DskipTests

# Stage 2: Run
FROM openjdk:17-slim
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid appuser --shell /bin/bash --create-home appuser
WORKDIR /home/appuser
COPY --from=builder /app/target/medium-demo-0.0.1-SNAPSHOT.jar app.jar
RUN chown -R appuser:appuser /home/appuser
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]