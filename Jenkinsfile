pipeline {
  agent any

  environment {

    // Image Config
    IMAGE_NAME = "app"
    IMAGE_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"

    // Cache
    CACHE_BASE = "/var/lib/jenkins/cache"

    // Harbor Config
    HARBOR_REGISTRY = "harbor.server.thweb.click"
    HARBOR_PROJECT = "boardgame-devsecops"
    HARBOR_CREDS = credentials("jenkins-harbor-credentials")

    // Trivy Config
    TRIVY_CACHE = "${CACHE_BASE}/trivy"

    // SonarQube Config
    SONAR_HOST_URL = "http://sonarqube.internal:9000"
    SONAR_TOKEN = credentials("sonarqube-token")
    SONAR_CACHE = "${CACHE_BASE}/sonar"
    
  }

  stages {

    stage("Set up") {
      steps {
        echo "Set up"
        sh """
          mkdir -p ${CACHE_BASE} ${TRIVY_CACHE}
          chmod -R 775 ${CACHE_BASE}
        """
      }
    }

    stage("Checkout") {

      steps {
        echo "📥 Checking out code from GitLab..."
        checkout scm
      }

    }

    stage("Build Maven") {

      agent {
        docker {
          image "maven:3.8.5-openjdk-11"
          args "-v $HOME/.m2:/root/.m2"
        }
      }
      
      steps {
        echo "Build Maven from inside docker"
        sh "mvn clean package -DskipTests"
      }

    }

    stage("Test") {

      agent {
        docker {
          image "maven:3.8.5-openjdk-11"
        }
      }

      steps {
        echo "Test Maven from inside docker"
        sh "mvn test"
      }

      post {
        always {
          junit "**/target/surefire-reports/*.xml"
        }
      }

    }

    stage("SonarQube Analysis") {
      agent {
        docker {
          image "sonarsource/sonar-scanner-cli:latest"
          args "-v ${SONAR_CACHE}:/opt/sonar-scanner/.sonar"
        }
      }

      steps {
        echo "SonarQube Analysis"
        withSonarQubeEnv("SonarQube") {
          sh """
            sonar-scanner \
              -Dsonar.projectKey=boardgame \
              -Dsonar.sources=src/main/java \
              -Dsonar.java.binaries=target/classes \
              -Dsonar.host.url=\${SONAR_HOST_URL} \
              -Dsonar.login=\${SONAR_TOKEN}
          """
        }
      }
    }

    stage("Quality Gate") {
      steps {
        echo "Wait for QualityGate trigger webhook"
        timeout(time: 5, unit: "MINUTES") {
          waitForQualityGate abortPipeline: true
        }
      }
    }

    stage("Trivy FS Scan") {

      agent {
        docker {
          image "aquasec/trivy:latest"
          args "--entrypoint=\"\"  -v ${TRIVY_CACHE}:/.cache"
        }
      }

      steps {
        echo "Trivy FileSystem Scan"
        sh "trivy fs --format table -o trivy-fs.html ."
      }

      post {
        always {
          publishHTML ([
            reportDir: ".",
            reportFiles: "trivy-fs.html",
            reportName: "Trivy FS Report"
          ])
        }
      }

    }

    stage("Build Docker Image") {

      steps {
        echo "Build Docker Image"
        sh """
        docker build -t ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG} .
        """
      }

    }

    stage("Trivy Image Scan") {

      agent {
        docker {
          image "aquasec/trivy:latest"
          args "--entrypoint=\"\" --group-add 999 -v /var/run/docker.sock:/var/run/docker.sock -v ${TRIVY_CACHE}:/.cache"
        }
      }

      steps {

        echo "Trivy Image Scan from inside docker with docker.socket mount"
        sh """
          trivy image \
            --severity HIGH,CRITICAL \
            --format table \
            -o trivy-image.html \
            ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
        """

      }

    }

  }

  post {

    success {
      echo "✅ Pipeline completed succesfully!!"
      echo "🧹 Cleaning workspace"
      cleanWs()
    }

    failure {
      echo "❌ Pipeline failed"
    }

    always {
      echo "THE END"
    }

  }
}