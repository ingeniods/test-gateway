# Imagen alternativa a Jib (mismo resultado — Jib es el camino del CI).
FROM eclipse-temurin:21-jre-alpine
COPY target/test-gateway-*.jar /app/app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
