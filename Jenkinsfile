// CI test-gateway — igual patrón que test-back (Jib, tag = version pom).
pipeline {
  agent any
  stages {
    stage('verify') {
      steps { sh './mvnw -B verify' }
      post { always { junit 'target/surefire-reports/*.xml' } }
    }
    stage('image') {
      when { anyOf { branch 'develop'; branch 'master' } }
      steps {
        script {
          def ver = sh(returnStdout: true, script:
            "./mvnw -q help:evaluate -Dexpression=project.version -DforceStdout | tail -1").trim()
          currentBuild.displayName = ver
          withCredentials([string(credentialsId: 'ghcr-token', variable: 'GHCR_PAT')]) {
            withEnv(["GHCR_USER=ingeniods", "IMG=ghcr.io/ingeniods/test-gateway:${ver}"]) {
              sh '''
                ARCH=$(docker info -f '{{.Architecture}}' | sed 's/aarch64/arm64/;s/x86_64/amd64/')
                ./mvnw -B jib:dockerBuild -Djib.to.image="$IMG" -Djib.arch="$ARCH"
                docker save "$IMG" | docker exec -i agd-control-plane ctr -n k8s.io images import -
                if [ -n "$GHCR_PAT" ]; then
                  echo "$GHCR_PAT" | docker login ghcr.io -u "$GHCR_USER" --password-stdin
                  docker push "$IMG"
                fi
              '''
            }
          }
        }
      }
    }
    stage('sonar') {
      steps {
        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
          sh './mvnw -B org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar \
                -Dsonar.host.url=http://sonarqube:9000 \
                -Dsonar.token=$SONAR_TOKEN \
                -Dsonar.projectKey=test-gateway'
        }
      }
    }
  }
}
