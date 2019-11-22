################################
### Builder image
################################
FROM maven:3.6-jdk-8-alpine as builder

WORKDIR /usr/src/app

COPY pom.xml ./
RUN mvn dependency:go-offline

COPY src/ src/
RUN mvn clean package -DskipTests

#################################
#### Runner image
#################################
FROM openjdk:8-jre-alpine

ENV SPRING_PROFILES_ACTIVE=main

RUN addgroup app && \
    adduser -G app -s /bin/sh -D app -h /home/app

USER app
WORKDIR /home/app

COPY --from=builder /usr/src/app/target/*.jar statistics.jar
COPY src/main/resources/application*.yml config/

CMD ["java", "-jar", "statistics.jar"]