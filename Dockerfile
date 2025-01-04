# Stage 1: Build
FROM maven:3.8.5-openjdk-17 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Maven project file to the container
COPY pom.xml .

# Copy the Maven settings file to the container
COPY .github/settings.xml /root/.m2/settings.xml

# Download the project dependencies
RUN mvn dependency:go-offline

# Copy the entire project to the container
COPY . .

# Package the application, skipping tests
RUN mvn package -DskipTests

# Stage 2: Run
FROM openjdk:17-slim

# Define a build argument for the JAR file version
ARG JAR_FILE_VERSION=0.0.1-SNAPSHOT

# Create a new group and user to run the application
RUN groupadd --gid 1001 appuser && \
    useradd --uid 1001 --gid appuser --shell /bin/bash --create-home appuser

# Set the working directory for the new user
WORKDIR /home/appuser

# Copy the packaged JAR file from the builder stage
COPY --from=builder /app/target/medium-demo-${JAR_FILE_VERSION}.jar app.jar

# Change ownership of the working directory to the new user
RUN chown -R appuser:appuser /home/appuser

# Switch to the new user
USER appuser

# Expose the application port
EXPOSE 8080

# Define the entry point for the container
ENTRYPOINT ["java", "-jar", "app.jar"]