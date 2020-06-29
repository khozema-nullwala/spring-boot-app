# BUILD IMAGE
# BASE IMAGE
FROM openjdk:8-jdk-alpine as build
# WORKING DIRECTORY
WORKDIR /workspace/app
# COPY NECESSARY FILES
COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
# RUN THE MAVEN COMMAND
RUN ./mvnw install -DskipTests
RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

# FINAL APP IMAGE
FROM openjdk:8-jre-alpine
ARG DEPENDENCY=/workspace/app/target/dependency
# COPY THE FILES BUILD USING MAVEN FROM PREVIOUS BUILD IMAGE
COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app
# MAKE IT AN EXECUTABLE
ENTRYPOINT ["java","-cp","app:app/lib/*","com.example.ecommerce.ShoppingApplication"]