pipeline {
  agent any

  options {
    // Build timeout
    timeout(time: 30, unit: 'MINUTES')
    
    // Disable concurrent builds per branch
    disableConcurrentBuilds()
    
    // Timestamp logs
    timestamps()
    
    // ANSI color output
    ansiColor('xterm')

    // Keep last 10 builds only
    buildDiscarder(logRotator(numToKeepStr: '10'))
  
    
    // Retry on agent failure
    retry(2)

  }


  environment {


    // Image Config
    IMAGE_NAME = "app"
    IMAGE_TAG = "${env.GIT_COMMIT?.take(7) ?: 'latest'}"

    // Cache
    CACHE_BASE = "/var/lib/jenkins/cache"
    MAVEN_CACHE = "${CACHE_BASE}/maven"
    SONAR_CACHE = "${CACHE_BASE}/sonar"
    TRIVY_CACHE = "${CACHE_BASE}/trivy"

    // Harbor Config
    HARBOR_REGISTRY = "harbor.server.thweb.click"
    HARBOR_PROJECT = "boardgame-devsecops"
    HARBOR_CREDS = credentials("jenkins-harbor-credentials")

    // Trivy Config

    // SonarQube Config || Config on Jenkins UI -> System -> SonarQube Server
    // SONAR_HOST_URL = "http://sonarqube.internal:9000"
    // SONAR_TOKEN = credentials("sonarqube-token")
    
  }

  stages {

    stage("Set up") {
      steps {
        echo "Set up"
        sh """
          mkdir -p ${MAVEN_CACHE} ${TRIVY_CACHE} ${SONAR_CACHE}
          chmod -R 775 ${CACHE_BASE}

          #Cleanup old images (keep last 5)
          docker image prune -a -f --filter "until=168h" || true
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
          args "-v ${MAVEN_CACHE}:/root/.m2"
          reuseNode true
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
          reuseNode true
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

    stage("Code Quality - SonarQube") {
      agent {
        docker {
          image "sonarsource/sonar-scanner-cli:latest"
          args "-v ${SONAR_CACHE}:/opt/sonar-scanner/.sonar"
          reuseNode true
        }
      }

      steps {
        echo "Running  SonarQube Analysis"
        withSonarQubeEnv("SonarQube") {
          sh """
            sonar-scanner \
              -Dsonar.projectKey=boardgame \
              -Dsonar.sources=src/main/java \
              -Dsonar.java.binaries=target/classes \
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

    stage("Security Scan - FS") {

      agent {
        docker {
          image "aquasec/trivy:latest"
          args """
            --entrypoint=''  
            -v ${TRIVY_CACHE}:/home/scanner/.cache
          """
        }
      }

      steps {
        echo "Scanning filesystem"
        sh """
          trivy fs \
            --cache-dir /home/scanner/.cache \
            --format table \
            -o trivy-fs.html \
            .
        """
      }

      post {
        always {
          publishHTML ([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
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
          docker build \
            -f Dockerfile-jenkins-optimize \
            -t ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG} \
            -t ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:latest \
            .
            # --label commit,build number, build user if needed \
        """
      }

    }

    stage("Security Scan - Image") {

      agent {
        docker {
          image "aquasec/trivy:latest"
          args """
            --entrypoint='' \
            --group-add 999 \
            -v /var/run/docker.sock:/var/run/docker.sock:ro \
            -v ${TRIVY_CACHE}:/home/scanner/.cache
          """
        }
      }

      steps {

        echo "Trivy Image Scan from inside docker with docker.socket mount"
        sh """
          trivy image \
            --cache-dir /home/scanner/.cache \
            --severity HIGH,CRITICAL \
            --format table \
            -o trivy-image.html \
            ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
        """

      }

      post {
        always {
          publishHTML([
            allowMissing: false,
            alwaysLinkToLastBuild: true,
            keepAll: true,
            reportDir: '.',
            reportFiles: 'trivy-image.html',
            reportName: 'Trivy Image Report'
          ])
        }
      }

    }

    stage("Push to Registry") {
      steps {
        echo "Push to Harbor"
        sh """
          echo "${HARBOR_CREDS_PSW}" | docker login ${HARBOR_REGISTRY} \
            -u ${HARBOR_CREDS_USR} \
            --password-stdin

          docker push ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}
          docker push ${HARBOR_REGISTRY}/${HARBOR_PROJECT}/${IMAGE_NAME}:latest

          docker logout ${HARBOR_REGISTRY}
        """
      }
      
    }

    stage("Deploy to K8s") {
      steps {
        script {
          
          
          
          // Multibranch Branch Detection
          echo "=== Multibranch Branch Detection ==="
          echo "BRANCH_NAME: ${env.BRANCH_NAME}"
          echo "GIT_BRANCH: ${env.GIT_BRANCH}"



          // Determine environment based on branch
          def environment = 'dev'
          def namespace = 'boardgame-dev'
          def valuesFile = 'values-dev.yaml'

          // PRODUCTION: main or master
          if (env.BRANCH_NAME == 'main' || env.BRANCH_NAME == 'master') {
            environment = 'prod'
            namespace = 'boardgame'
            valuesFile = 'values-prod.yaml'
          }

          // STAGING: hotfix branches (future expansion)
          else if (env.BRANCH_NAME.startsWith('hotfix/')) {
            environment = 'staging'
            namespace = 'boardgame-staging'
            valuesFile = 'values-staging.yaml'
          }

          // DEV: all other branches (feature/*, etc)

          echo "Deploying to ${environment} environment (namespace: ${namespace})"

          // Deploy with Helm
          sh """
            helm upgrade --install boardgame-${environment} helm-charts/boardgame \
              -f helm-charts/boardgame/values.yaml \
              -f helm-charts/boardgame/${valuesFile} \
              --namespace ${namespace} \
              --create-namespace \
              --set image.tag=${IMAGE_TAG} \
              --atomic \
              --timeout 5m \
              --wait
          """

          echo "✅ Deployed ${environment} successfully!"

          sh """
            echo "=== Helm Release ==="
            helm list -n ${namespace}

            echo "=== K8s Resources ==="
            kubectl get all,ingress -n ${namespace}
          """
        }
      }
    }
  } 

  post {

    success {
      echo "✅ Pipeline completed succesfully!!"

    }

    failure {
      script {
        echo "❌ Deployment failed! Helm will automatically rollback."

      }
    }

    always {
      echo "🧹 Cleaning workspace"
      cleanWs()
      echo "=== THE END ==="
    }

  }
}