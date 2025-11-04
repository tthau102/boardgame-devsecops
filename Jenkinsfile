pipeline {
  agent any

  environment {
    HARBOR_REGISTRY = 'harbor.server.thweb.click'
    HARBOR_PROJECT = 'tthau'
    IMAGE_NAME = 'boardgame'
    IMAGE_TAG = '${BUILD_NUMBER}'
    HARBOR_CREDS = credentials('jenkins-harbor-credentials')
  }

  stages {

    stage('Checkout') {

      steps {
        echo '📥 Checking out code from GitLab...'
        checkout scm
      }

    }

    stage('Build Maven') {

      agent {
        docker {
          image 'maven:3.8.5-openjdk-11'
          args '-v $HOME/.m2:/root/.m2'
        }
      }
      
      steps {
        sh 'mvn clean package -DskipTests'
      }

    }

    stage('Test') {

      agent {
        docker {
          image 'maven:3.8.5-openjdk-11'
        }
      }

      steps {
        sh 'mvn test'
      }

      post {
        always {
          junit '**/target/surefire-reports/*.xml'
        }
      }

    }

    stage('SonarQube Analysis') {
      agent {
        docker {
          image 'sonarsource/sonar-scanner-cli:latest'
          args '-v /tmp/sonar-cache:/opt/sonar-scanner/.sonar'
        }
      }
      environment {
        SONAR_HOST_URL = 'https://sonarqube.server.thweb.click'
        SONAR_TOKEN = credentials('sonarqube-token')
      }
      steps {
        withSonarQubeEnv('SonarQube') {
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

    stage('Quality Gate') {
      steps {
        timeout(time: 5, unit: 'MINUTES') {
          waitForQualityGate abortPipeline: true
        }
      }
    }

  //   stage('Trivy FS Scan') {

  //     agent {
  //       docker {
  //         image 'aquasec/trivy:latest'
  //         args '--entrypoint="" -v /tmp/trivy-cache:/.cache'
  //       }
  //     }

  //     steps {
  //       sh 'trivy fs --format table -o trivy-fs.html .'
  //     }

  //     post {
  //       always {
  //         publishHTML ([
  //           reportDir: '.',
  //           reportFiles: 'trivy-fs.html',
  //           reportName: 'Trivy FS Report'
  //         ])
  //       }
  //     }

  //   }
  }

  post {
    success {
      echo '✅ Pipeline completed succesfully!!'
    }
    failure {
      echo "❌ Pipeline failed"
    }
    // always {
    //   echo '🧹 Cleaning workspace'
    //   cleanWs()
    // }
  }
}